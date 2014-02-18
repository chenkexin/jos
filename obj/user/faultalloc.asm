
obj/user/faultalloc:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  80004b:	e8 07 02 00 00       	call   800257 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 8d 0d 00 00       	call   800dfc <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 a0 13 80 	movl   $0x8013a0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 8a 13 80 00 	movl   $0x80138a,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 cc 13 80 	movl   $0x8013cc,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 96 07 00 00       	call   800849 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 99 0f 00 00       	call   801064 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  8000da:	e8 78 01 00 00       	call   800257 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  8000ee:	e8 64 01 00 00       	call   800257 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80010a:	e8 8d 0c 00 00       	call   800d9c <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 db                	test   %ebx,%ebx
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 06                	mov    (%esi),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800130:	89 1c 24             	mov    %ebx,(%esp)
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 e5 0b 00 00       	call   800d3f <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80016d:	e8 2a 0c 00 00       	call   800d9c <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 74 24 08          	mov    %esi,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  80018f:	e8 c3 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 53 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 9e 13 80 00 	movl   $0x80139e,(%esp)
  8001aa:	e8 a8 00 00 00       	call   800257 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	83 c0 01             	add    $0x1,%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 19                	jne    8001ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001da:	00 
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 fa 0a 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  800232:	e8 bb 01 00 00       	call   8003f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 91 0a 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 87 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800291:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	b8 00 00 00 00       	mov    $0x0,%eax
  80029f:	39 d8                	cmp    %ebx,%eax
  8002a1:	72 17                	jb     8002ba <printnum+0x3a>
  8002a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002a9:	76 0f                	jbe    8002ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	8b 75 14             	mov    0x14(%ebp),%esi
  8002ae:	83 ee 01             	sub    $0x1,%esi
  8002b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b4:	85 f6                	test   %esi,%esi
  8002b6:	7f 63                	jg     80031b <printnum+0x9b>
  8002b8:	eb 75                	jmp    80032f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c4:	83 e8 01             	sub    $0x1,%eax
  8002c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e7:	00 
  8002e8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002eb:	89 1c 24             	mov    %ebx,(%esp)
  8002ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f5:	e8 a6 0d 00 00       	call   8010a0 <__udivdi3>
  8002fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800300:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800304:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	89 fa                	mov    %edi,%edx
  800311:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800314:	e8 67 ff ff ff       	call   800280 <printnum>
  800319:	eb 14                	jmp    80032f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031f:	8b 45 18             	mov    0x18(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800327:	83 ee 01             	sub    $0x1,%esi
  80032a:	75 ef                	jne    80031b <printnum+0x9b>
  80032c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800333:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800337:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800345:	00 
  800346:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	e8 98 0e 00 00       	call   8011f0 <__umoddi3>
  800358:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035c:	0f be 80 1b 14 80 00 	movsbl 0x80141b(%eax),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800369:	ff d0                	call   *%eax
}
  80036b:	83 c4 4c             	add    $0x4c,%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800376:	83 fa 01             	cmp    $0x1,%edx
  800379:	7e 0e                	jle    800389 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	8b 52 04             	mov    0x4(%edx),%edx
  800387:	eb 22                	jmp    8003ab <getuint+0x38>
	else if (lflag)
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 10                	je     80039d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 0e                	jmp    8003ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c1:	88 0a                	mov    %cl,(%edx)
  8003c3:	83 c2 01             	add    $0x1,%edx
  8003c6:	89 10                	mov    %edx,(%eax)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	e8 02 00 00 00       	call   8003f2 <vprintfmt>
	va_end(ap);
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 4c             	sub    $0x4c,%esp
  8003fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	eb 11                	jmp    800417 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800406:	85 c0                	test   %eax,%eax
  800408:	0f 84 db 03 00 00    	je     8007e9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800417:	0f b6 07             	movzbl (%edi),%eax
  80041a:	83 c7 01             	add    $0x1,%edi
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e4                	jne    800406 <vprintfmt+0x14>
  800422:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800426:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80042d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800434:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 2b                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800449:	eb 22                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800452:	eb 19                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800457:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045e:	eb 0d                	jmp    80046d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800460:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	0f b6 0f             	movzbl (%edi),%ecx
  800470:	8d 47 01             	lea    0x1(%edi),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	0f b6 07             	movzbl (%edi),%eax
  800479:	83 e8 23             	sub    $0x23,%eax
  80047c:	3c 55                	cmp    $0x55,%al
  80047e:	0f 87 40 03 00 00    	ja     8007c4 <vprintfmt+0x3d2>
  800484:	0f b6 c0             	movzbl %al,%eax
  800487:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048e:	83 e9 30             	sub    $0x30,%ecx
  800491:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800494:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049b:	83 f9 09             	cmp    $0x9,%ecx
  80049e:	77 57                	ja     8004f7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ac:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004af:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b9:	83 f9 09             	cmp    $0x9,%ecx
  8004bc:	76 eb                	jbe    8004a9 <vprintfmt+0xb7>
  8004be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	eb 34                	jmp    8004fa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d7:	eb 21                	jmp    8004fa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	0f 88 71 ff ff ff    	js     800454 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e6:	eb 85                	jmp    80046d <vprintfmt+0x7b>
  8004e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004eb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004f2:	e9 76 ff ff ff       	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fe:	0f 89 69 ff ff ff    	jns    80046d <vprintfmt+0x7b>
  800504:	e9 57 ff ff ff       	jmp    800460 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800509:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	e9 59 ff ff ff       	jmp    80046d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052b:	e9 e7 fe ff ff       	jmp    800417 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 c2                	mov    %eax,%edx
  80053d:	c1 fa 1f             	sar    $0x1f,%edx
  800540:	31 d0                	xor    %edx,%eax
  800542:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800544:	83 f8 08             	cmp    $0x8,%eax
  800547:	7f 0b                	jg     800554 <vprintfmt+0x162>
  800549:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800550:	85 d2                	test   %edx,%edx
  800552:	75 20                	jne    800574 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800558:	c7 44 24 08 33 14 80 	movl   $0x801433,0x8(%esp)
  80055f:	00 
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	89 34 24             	mov    %esi,(%esp)
  800567:	e8 5e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 a3 fe ff ff       	jmp    800417 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800578:	c7 44 24 08 3c 14 80 	movl   $0x80143c,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	89 34 24             	mov    %esi,(%esp)
  800587:	e8 3e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80058f:	e9 83 fe ff ff       	jmp    800417 <vprintfmt+0x25>
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800597:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80059a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	b8 2c 14 80 00       	mov    $0x80142c,%eax
  8005af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005b6:	74 06                	je     8005be <vprintfmt+0x1cc>
  8005b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005bc:	7f 16                	jg     8005d4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	0f b6 17             	movzbl (%edi),%edx
  8005c1:	0f be c2             	movsbl %dl,%eax
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 85 9f 00 00 00    	jne    80066e <vprintfmt+0x27c>
  8005cf:	e9 8b 00 00 00       	jmp    80065f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d8:	89 3c 24             	mov    %edi,(%esp)
  8005db:	e8 c2 02 00 00       	call   8008a2 <strnlen>
  8005e0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e3:	29 c2                	sub    %eax,%edx
  8005e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	7e d2                	jle    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005ec:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005f3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005f6:	89 d7                	mov    %edx,%edi
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	75 ef                	jne    8005f8 <vprintfmt+0x206>
  800609:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80060f:	eb ad                	jmp    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800615:	74 20                	je     800637 <vprintfmt+0x245>
  800617:	0f be d2             	movsbl %dl,%edx
  80061a:	83 ea 20             	sub    $0x20,%edx
  80061d:	83 fa 5e             	cmp    $0x5e,%edx
  800620:	76 15                	jbe    800637 <vprintfmt+0x245>
					putch('?', putdat);
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800630:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800633:	ff d1                	call   *%ecx
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800644:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	0f b6 17             	movzbl (%edi),%edx
  80064c:	0f be c2             	movsbl %dl,%eax
  80064f:	83 c7 01             	add    $0x1,%edi
  800652:	85 c0                	test   %eax,%eax
  800654:	75 24                	jne    80067a <vprintfmt+0x288>
  800656:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800659:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800666:	0f 8e ab fd ff ff    	jle    800417 <vprintfmt+0x25>
  80066c:	eb 20                	jmp    80068e <vprintfmt+0x29c>
  80066e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800671:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800674:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800677:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	85 f6                	test   %esi,%esi
  80067c:	78 93                	js     800611 <vprintfmt+0x21f>
  80067e:	83 ee 01             	sub    $0x1,%esi
  800681:	79 8e                	jns    800611 <vprintfmt+0x21f>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800686:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800689:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068c:	eb d1                	jmp    80065f <vprintfmt+0x26d>
  80068e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800691:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800695:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	75 ee                	jne    800691 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006a6:	e9 6c fd ff ff       	jmp    800417 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ab:	83 fa 01             	cmp    $0x1,%edx
  8006ae:	66 90                	xchg   %ax,%ax
  8006b0:	7e 16                	jle    8006c8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c6:	eb 32                	jmp    8006fa <vprintfmt+0x308>
	else if (lflag)
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e2:	eb 16                	jmp    8006fa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f2:	89 c7                	mov    %eax,%edi
  8006f4:	c1 ff 1f             	sar    $0x1f,%edi
  8006f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800700:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800705:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800709:	79 7d                	jns    800788 <vprintfmt+0x396>
				putch('-', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800716:	ff d6                	call   *%esi
				num = -(long long) num;
  800718:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80071e:	f7 d8                	neg    %eax
  800720:	83 d2 00             	adc    $0x0,%edx
  800723:	f7 da                	neg    %edx
			}
			base = 10;
  800725:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072a:	eb 5c                	jmp    800788 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 3f fc ff ff       	call   800373 <getuint>
			base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800739:	eb 4d                	jmp    800788 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 30 fc ff ff       	call   800373 <getuint>
      base = 8;
  800743:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800748:	eb 3e                	jmp    800788 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800755:	ff d6                	call   *%esi
			putch('x', putdat);
  800757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800762:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800774:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 f0 fb ff ff       	call   800373 <getuint>
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80078c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800790:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800793:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800797:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 da                	mov    %ebx,%edx
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	e8 d5 fa ff ff       	call   800280 <printnum>
			break;
  8007ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007ae:	e9 64 fc ff ff       	jmp    800417 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	89 0c 24             	mov    %ecx,(%esp)
  8007ba:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007bf:	e9 53 fc ff ff       	jmp    800417 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d5:	0f 84 3c fc ff ff    	je     800417 <vprintfmt+0x25>
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e2:	75 f7                	jne    8007db <vprintfmt+0x3e9>
  8007e4:	e9 2e fc ff ff       	jmp    800417 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007e9:	83 c4 4c             	add    $0x4c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 28             	sub    $0x28,%esp
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800800:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800804:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800807:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080e:	85 d2                	test   %edx,%edx
  800810:	7e 30                	jle    800842 <vsnprintf+0x51>
  800812:	85 c0                	test   %eax,%eax
  800814:	74 2c                	je     800842 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 ad 03 80 00 	movl   $0x8003ad,(%esp)
  800832:	e8 bb fb ff ff       	call   8003f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800840:	eb 05                	jmp    800847 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 82 ff ff ff       	call   8007f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
	...

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	80 3a 00             	cmpb   $0x0,(%edx)
  800889:	74 10                	je     80089b <strlen+0x1b>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
  800899:	eb 05                	jmp    8008a0 <strlen+0x20>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 1c                	je     8008cc <strnlen+0x2a>
  8008b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b3:	74 1e                	je     8008d3 <strnlen+0x31>
  8008b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ba:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	39 ca                	cmp    %ecx,%edx
  8008be:	74 18                	je     8008d8 <strnlen+0x36>
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c8:	75 f0                	jne    8008ba <strnlen+0x18>
  8008ca:	eb 0c                	jmp    8008d8 <strnlen+0x36>
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strnlen+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ea:	88 1a                	mov    %bl,(%edx)
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 f1                	jne    8008e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 75 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	01 d8                	add    %ebx,%eax
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	e8 bf ff ff ff       	call   8008db <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	83 c4 08             	add    $0x8,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	85 db                	test   %ebx,%ebx
  800934:	74 16                	je     80094c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	01 f3                	add    %esi,%ebx
  800938:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80093a:	0f b6 02             	movzbl (%edx),%eax
  80093d:	88 01                	mov    %al,(%ecx)
  80093f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800942:	80 3a 01             	cmpb   $0x1,(%edx)
  800945:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	39 d9                	cmp    %ebx,%ecx
  80094a:	75 ee                	jne    80093a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094c:	89 f0                	mov    %esi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800961:	89 f8                	mov    %edi,%eax
  800963:	85 f6                	test   %esi,%esi
  800965:	74 33                	je     80099a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800967:	83 fe 01             	cmp    $0x1,%esi
  80096a:	74 25                	je     800991 <strlcpy+0x3f>
  80096c:	0f b6 0b             	movzbl (%ebx),%ecx
  80096f:	84 c9                	test   %cl,%cl
  800971:	74 22                	je     800995 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800973:	83 ee 02             	sub    $0x2,%esi
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	88 08                	mov    %cl,(%eax)
  80097d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800980:	39 f2                	cmp    %esi,%edx
  800982:	74 13                	je     800997 <strlcpy+0x45>
  800984:	83 c2 01             	add    $0x1,%edx
  800987:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098b:	84 c9                	test   %cl,%cl
  80098d:	75 ec                	jne    80097b <strlcpy+0x29>
  80098f:	eb 06                	jmp    800997 <strlcpy+0x45>
  800991:	89 f8                	mov    %edi,%eax
  800993:	eb 02                	jmp    800997 <strlcpy+0x45>
  800995:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f8                	sub    %edi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	84 c0                	test   %al,%al
  8009af:	74 15                	je     8009c6 <strcmp+0x25>
  8009b1:	3a 02                	cmp    (%edx),%al
  8009b3:	75 11                	jne    8009c6 <strcmp+0x25>
		p++, q++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	84 c0                	test   %al,%al
  8009c0:	74 04                	je     8009c6 <strcmp+0x25>
  8009c2:	3a 02                	cmp    (%edx),%al
  8009c4:	74 ef                	je     8009b5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 c0             	movzbl %al,%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	74 29                	je     800a0b <strncmp+0x3b>
  8009e2:	0f b6 03             	movzbl (%ebx),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 30                	je     800a19 <strncmp+0x49>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	75 2c                	jne    800a19 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009ed:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009f2:	89 c3                	mov    %eax,%ebx
  8009f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	74 17                	je     800a12 <strncmp+0x42>
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	84 c9                	test   %cl,%cl
  800a00:	74 17                	je     800a19 <strncmp+0x49>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 e9                	je     8009f2 <strncmp+0x22>
  800a09:	eb 0e                	jmp    800a19 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	eb 0f                	jmp    800a21 <strncmp+0x51>
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 08                	jmp    800a21 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 03             	movzbl (%ebx),%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	53                   	push   %ebx
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a2f:	0f b6 18             	movzbl (%eax),%ebx
  800a32:	84 db                	test   %bl,%bl
  800a34:	74 1d                	je     800a53 <strchr+0x2e>
  800a36:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a38:	38 d3                	cmp    %dl,%bl
  800a3a:	75 06                	jne    800a42 <strchr+0x1d>
  800a3c:	eb 1a                	jmp    800a58 <strchr+0x33>
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 16                	je     800a58 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	75 f2                	jne    800a3e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strchr+0x33>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a65:	0f b6 18             	movzbl (%eax),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	74 16                	je     800a82 <strfind+0x27>
  800a6c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a6e:	38 d3                	cmp    %dl,%bl
  800a70:	75 06                	jne    800a78 <strfind+0x1d>
  800a72:	eb 0e                	jmp    800a82 <strfind+0x27>
  800a74:	38 ca                	cmp    %cl,%dl
  800a76:	74 0a                	je     800a82 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	0f b6 10             	movzbl (%eax),%edx
  800a7e:	84 d2                	test   %dl,%dl
  800a80:	75 f2                	jne    800a74 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a82:	5b                   	pop    %ebx
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a91:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a9a:	85 c9                	test   %ecx,%ecx
  800a9c:	74 36                	je     800ad4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 28                	jne    800ace <memset+0x49>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 23                	jne    800ace <memset+0x49>
		c &= 0xFF;
  800aab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	c1 e3 08             	shl    $0x8,%ebx
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	c1 e6 18             	shl    $0x18,%esi
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 10             	shl    $0x10,%eax
  800abe:	09 f0                	or     %esi,%eax
  800ac0:	09 c2                	or     %eax,%edx
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac9:	fc                   	cld    
  800aca:	f3 ab                	rep stos %eax,%es:(%edi)
  800acc:	eb 06                	jmp    800ad4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	fc                   	cld    
  800ad2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ad9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800adc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800adf:	89 ec                	mov    %ebp,%esp
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af8:	39 c6                	cmp    %eax,%esi
  800afa:	73 36                	jae    800b32 <memmove+0x4f>
  800afc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aff:	39 d0                	cmp    %edx,%eax
  800b01:	73 2f                	jae    800b32 <memmove+0x4f>
		s += n;
		d += n;
  800b03:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f6 c2 03             	test   $0x3,%dl
  800b09:	75 1b                	jne    800b26 <memmove+0x43>
  800b0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b11:	75 13                	jne    800b26 <memmove+0x43>
  800b13:	f6 c1 03             	test   $0x3,%cl
  800b16:	75 0e                	jne    800b26 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b18:	83 ef 04             	sub    $0x4,%edi
  800b1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b21:	fd                   	std    
  800b22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b24:	eb 09                	jmp    800b2f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b26:	83 ef 01             	sub    $0x1,%edi
  800b29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2c:	fd                   	std    
  800b2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b2f:	fc                   	cld    
  800b30:	eb 20                	jmp    800b52 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b38:	75 13                	jne    800b4d <memmove+0x6a>
  800b3a:	a8 03                	test   $0x3,%al
  800b3c:	75 0f                	jne    800b4d <memmove+0x6a>
  800b3e:	f6 c1 03             	test   $0x3,%cl
  800b41:	75 0a                	jne    800b4d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 05                	jmp    800b52 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b58:	89 ec                	mov    %ebp,%esp
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b62:	8b 45 10             	mov    0x10(%ebp),%eax
  800b65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 04 24             	mov    %eax,(%esp)
  800b76:	e8 68 ff ff ff       	call   800ae3 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	74 36                	je     800bc9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b93:	0f b6 03             	movzbl (%ebx),%eax
  800b96:	0f b6 0e             	movzbl (%esi),%ecx
  800b99:	38 c8                	cmp    %cl,%al
  800b9b:	75 17                	jne    800bb4 <memcmp+0x37>
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	eb 1a                	jmp    800bbe <memcmp+0x41>
  800ba4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bb0:	38 c8                	cmp    %cl,%al
  800bb2:	74 0a                	je     800bbe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bb4:	0f b6 c0             	movzbl %al,%eax
  800bb7:	0f b6 c9             	movzbl %cl,%ecx
  800bba:	29 c8                	sub    %ecx,%eax
  800bbc:	eb 10                	jmp    800bce <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbe:	39 fa                	cmp    %edi,%edx
  800bc0:	75 e2                	jne    800ba4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	eb 05                	jmp    800bce <memcmp+0x51>
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be2:	39 d0                	cmp    %edx,%eax
  800be4:	73 13                	jae    800bf9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	89 d9                	mov    %ebx,%ecx
  800be8:	38 18                	cmp    %bl,(%eax)
  800bea:	75 06                	jne    800bf2 <memfind+0x1f>
  800bec:	eb 0b                	jmp    800bf9 <memfind+0x26>
  800bee:	38 08                	cmp    %cl,(%eax)
  800bf0:	74 07                	je     800bf9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	39 d0                	cmp    %edx,%eax
  800bf7:	75 f5                	jne    800bee <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 04             	sub    $0x4,%esp
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0b:	0f b6 02             	movzbl (%edx),%eax
  800c0e:	3c 09                	cmp    $0x9,%al
  800c10:	74 04                	je     800c16 <strtol+0x1a>
  800c12:	3c 20                	cmp    $0x20,%al
  800c14:	75 0e                	jne    800c24 <strtol+0x28>
		s++;
  800c16:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	0f b6 02             	movzbl (%edx),%eax
  800c1c:	3c 09                	cmp    $0x9,%al
  800c1e:	74 f6                	je     800c16 <strtol+0x1a>
  800c20:	3c 20                	cmp    $0x20,%al
  800c22:	74 f2                	je     800c16 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c24:	3c 2b                	cmp    $0x2b,%al
  800c26:	75 0a                	jne    800c32 <strtol+0x36>
		s++;
  800c28:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	eb 10                	jmp    800c42 <strtol+0x46>
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	75 07                	jne    800c42 <strtol+0x46>
		s++, neg = 1;
  800c3b:	83 c2 01             	add    $0x1,%edx
  800c3e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c48:	75 15                	jne    800c5f <strtol+0x63>
  800c4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4d:	75 10                	jne    800c5f <strtol+0x63>
  800c4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c53:	75 0a                	jne    800c5f <strtol+0x63>
		s += 2, base = 16;
  800c55:	83 c2 02             	add    $0x2,%edx
  800c58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5d:	eb 10                	jmp    800c6f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c5f:	85 db                	test   %ebx,%ebx
  800c61:	75 0c                	jne    800c6f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c63:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c65:	80 3a 30             	cmpb   $0x30,(%edx)
  800c68:	75 05                	jne    800c6f <strtol+0x73>
		s++, base = 8;
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c77:	0f b6 0a             	movzbl (%edx),%ecx
  800c7a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 09             	cmp    $0x9,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x90>
			dig = *s - '0';
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 30             	sub    $0x30,%ecx
  800c8a:	eb 22                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c8c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 08                	ja     800c9e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c96:	0f be c9             	movsbl %cl,%ecx
  800c99:	83 e9 57             	sub    $0x57,%ecx
  800c9c:	eb 10                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 16                	ja     800cbe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800ca8:	0f be c9             	movsbl %cl,%ecx
  800cab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cae:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800cb1:	7d 0f                	jge    800cc2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cba:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cbc:	eb b9                	jmp    800c77 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cbe:	89 c1                	mov    %eax,%ecx
  800cc0:	eb 02                	jmp    800cc4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc8:	74 05                	je     800ccf <strtol+0xd3>
		*endptr = (char *) s;
  800cca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ccd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ccf:	89 ca                	mov    %ecx,%edx
  800cd1:	f7 da                	neg    %edx
  800cd3:	85 ff                	test   %edi,%edi
  800cd5:	0f 45 c2             	cmovne %edx,%eax
}
  800cd8:	83 c4 04             	add    $0x4,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d23:	b8 01 00 00 00       	mov    $0x1,%eax
  800d28:	89 d1                	mov    %edx,%ecx
  800d2a:	89 d3                	mov    %edx,%ebx
  800d2c:	89 d7                	mov    %edx,%edi
  800d2e:	89 d6                	mov    %edx,%esi
  800d30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3b:	89 ec                	mov    %ebp,%esp
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 38             	sub    $0x38,%esp
  800d45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d53:	b8 03 00 00 00       	mov    $0x3,%eax
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 cb                	mov    %ecx,%ebx
  800d5d:	89 cf                	mov    %ecx,%edi
  800d5f:	89 ce                	mov    %ecx,%esi
  800d61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 28                	jle    800d8f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d72:	00 
  800d73:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d82:	00 
  800d83:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800d8a:	e8 cd f3 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 02 00 00 00       	mov    $0x2,%eax
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	89 d7                	mov    %edx,%edi
  800dbb:	89 d6                	mov    %edx,%esi
  800dbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_yield>:

void
sys_yield(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	ba 00 00 00 00       	mov    $0x0,%edx
  800de0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	89 d3                	mov    %edx,%ebx
  800de9:	89 d7                	mov    %edx,%edi
  800deb:	89 d6                	mov    %edx,%esi
  800ded:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800def:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 38             	sub    $0x38,%esp
  800e02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	be 00 00 00 00       	mov    $0x0,%esi
  800e10:	b8 04 00 00 00       	mov    $0x4,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	89 f7                	mov    %esi,%edi
  800e20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 28                	jle    800e4e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e31:	00 
  800e32:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e41:	00 
  800e42:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800e49:	e8 0e f3 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e57:	89 ec                	mov    %ebp,%esp
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 38             	sub    $0x38,%esp
  800e61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e72:	8b 55 08             	mov    0x8(%ebp),%edx
  800e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 28                	jle    800eac <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800ea7:	e8 b0 f2 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eaf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb5:	89 ec                	mov    %ebp,%esp
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 38             	sub    $0x38,%esp
  800ebf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	89 df                	mov    %ebx,%edi
  800eda:	89 de                	mov    %ebx,%esi
  800edc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	7e 28                	jle    800f0a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eed:	00 
  800eee:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f05:	e8 52 f2 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f13:	89 ec                	mov    %ebp,%esp
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 38             	sub    $0x38,%esp
  800f1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	89 df                	mov    %ebx,%edi
  800f38:	89 de                	mov    %ebx,%esi
  800f3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	7e 28                	jle    800f68 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f63:	e8 f4 f1 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f68:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f71:	89 ec                	mov    %ebp,%esp
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 38             	sub    $0x38,%esp
  800f7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f89:	b8 09 00 00 00       	mov    $0x9,%eax
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	89 df                	mov    %ebx,%edi
  800f96:	89 de                	mov    %ebx,%esi
  800f98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	7e 28                	jle    800fc6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa9:	00 
  800faa:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb9:	00 
  800fba:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800fc1:	e8 96 f1 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fcf:	89 ec                	mov    %ebp,%esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	be 00 00 00 00       	mov    $0x0,%esi
  800fe7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ffa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801000:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801003:	89 ec                	mov    %ebp,%esp
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 38             	sub    $0x38,%esp
  80100d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801010:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801013:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	89 cb                	mov    %ecx,%ebx
  801025:	89 cf                	mov    %ecx,%edi
  801027:	89 ce                	mov    %ecx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 28                	jle    801057 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801033:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80103a:	00 
  80103b:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  801042:	00 
  801043:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104a:	00 
  80104b:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  801052:	e8 05 f1 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801057:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801060:	89 ec                	mov    %ebp,%esp
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80106a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801071:	75 1c                	jne    80108f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801073:	c7 44 24 08 90 16 80 	movl   $0x801690,0x8(%esp)
  80107a:	00 
  80107b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801082:	00 
  801083:	c7 04 24 b4 16 80 00 	movl   $0x8016b4,(%esp)
  80108a:	e8 cd f0 ff ff       	call   80015c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
  80109b:	00 00                	add    %al,(%eax)
  80109d:	00 00                	add    %al,(%eax)
	...

008010a0 <__udivdi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8010a7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010ab:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010af:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010b3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8010b7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010c1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c5:	89 ea                	mov    %ebp,%edx
  8010c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010cb:	75 33                	jne    801100 <__udivdi3+0x60>
  8010cd:	39 e9                	cmp    %ebp,%ecx
  8010cf:	77 6f                	ja     801140 <__udivdi3+0xa0>
  8010d1:	85 c9                	test   %ecx,%ecx
  8010d3:	89 ce                	mov    %ecx,%esi
  8010d5:	75 0b                	jne    8010e2 <__udivdi3+0x42>
  8010d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010dc:	31 d2                	xor    %edx,%edx
  8010de:	f7 f1                	div    %ecx
  8010e0:	89 c6                	mov    %eax,%esi
  8010e2:	31 d2                	xor    %edx,%edx
  8010e4:	89 e8                	mov    %ebp,%eax
  8010e6:	f7 f6                	div    %esi
  8010e8:	89 c5                	mov    %eax,%ebp
  8010ea:	89 f8                	mov    %edi,%eax
  8010ec:	f7 f6                	div    %esi
  8010ee:	89 ea                	mov    %ebp,%edx
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	39 e8                	cmp    %ebp,%eax
  801102:	77 24                	ja     801128 <__udivdi3+0x88>
  801104:	0f bd c8             	bsr    %eax,%ecx
  801107:	83 f1 1f             	xor    $0x1f,%ecx
  80110a:	89 0c 24             	mov    %ecx,(%esp)
  80110d:	75 49                	jne    801158 <__udivdi3+0xb8>
  80110f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801113:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801117:	0f 86 ab 00 00 00    	jbe    8011c8 <__udivdi3+0x128>
  80111d:	39 e8                	cmp    %ebp,%eax
  80111f:	0f 82 a3 00 00 00    	jb     8011c8 <__udivdi3+0x128>
  801125:	8d 76 00             	lea    0x0(%esi),%esi
  801128:	31 d2                	xor    %edx,%edx
  80112a:	31 c0                	xor    %eax,%eax
  80112c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801130:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801134:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801138:	83 c4 1c             	add    $0x1c,%esp
  80113b:	c3                   	ret    
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	89 f8                	mov    %edi,%eax
  801142:	f7 f1                	div    %ecx
  801144:	31 d2                	xor    %edx,%edx
  801146:	8b 74 24 10          	mov    0x10(%esp),%esi
  80114a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80114e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801152:	83 c4 1c             	add    $0x1c,%esp
  801155:	c3                   	ret    
  801156:	66 90                	xchg   %ax,%ax
  801158:	0f b6 0c 24          	movzbl (%esp),%ecx
  80115c:	89 c6                	mov    %eax,%esi
  80115e:	b8 20 00 00 00       	mov    $0x20,%eax
  801163:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801167:	2b 04 24             	sub    (%esp),%eax
  80116a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80116e:	d3 e6                	shl    %cl,%esi
  801170:	89 c1                	mov    %eax,%ecx
  801172:	d3 ed                	shr    %cl,%ebp
  801174:	0f b6 0c 24          	movzbl (%esp),%ecx
  801178:	09 f5                	or     %esi,%ebp
  80117a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80117e:	d3 e6                	shl    %cl,%esi
  801180:	89 c1                	mov    %eax,%ecx
  801182:	89 74 24 04          	mov    %esi,0x4(%esp)
  801186:	89 d6                	mov    %edx,%esi
  801188:	d3 ee                	shr    %cl,%esi
  80118a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80118e:	d3 e2                	shl    %cl,%edx
  801190:	89 c1                	mov    %eax,%ecx
  801192:	d3 ef                	shr    %cl,%edi
  801194:	09 d7                	or     %edx,%edi
  801196:	89 f2                	mov    %esi,%edx
  801198:	89 f8                	mov    %edi,%eax
  80119a:	f7 f5                	div    %ebp
  80119c:	89 d6                	mov    %edx,%esi
  80119e:	89 c7                	mov    %eax,%edi
  8011a0:	f7 64 24 04          	mull   0x4(%esp)
  8011a4:	39 d6                	cmp    %edx,%esi
  8011a6:	72 30                	jb     8011d8 <__udivdi3+0x138>
  8011a8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011ac:	0f b6 0c 24          	movzbl (%esp),%ecx
  8011b0:	d3 e5                	shl    %cl,%ebp
  8011b2:	39 c5                	cmp    %eax,%ebp
  8011b4:	73 04                	jae    8011ba <__udivdi3+0x11a>
  8011b6:	39 d6                	cmp    %edx,%esi
  8011b8:	74 1e                	je     8011d8 <__udivdi3+0x138>
  8011ba:	89 f8                	mov    %edi,%eax
  8011bc:	31 d2                	xor    %edx,%edx
  8011be:	e9 69 ff ff ff       	jmp    80112c <__udivdi3+0x8c>
  8011c3:	90                   	nop
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cf:	e9 58 ff ff ff       	jmp    80112c <__udivdi3+0x8c>
  8011d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e9:	83 c4 1c             	add    $0x1c,%esp
  8011ec:	c3                   	ret    
  8011ed:	00 00                	add    %al,(%eax)
	...

008011f0 <__umoddi3>:
  8011f0:	83 ec 2c             	sub    $0x2c,%esp
  8011f3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011f7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011fb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8011ff:	8b 74 24 38          	mov    0x38(%esp),%esi
  801203:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801207:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80120b:	85 c0                	test   %eax,%eax
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801213:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801217:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80121b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80121f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801223:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801227:	75 1f                	jne    801248 <__umoddi3+0x58>
  801229:	39 fe                	cmp    %edi,%esi
  80122b:	76 63                	jbe    801290 <__umoddi3+0xa0>
  80122d:	89 c8                	mov    %ecx,%eax
  80122f:	89 fa                	mov    %edi,%edx
  801231:	f7 f6                	div    %esi
  801233:	89 d0                	mov    %edx,%eax
  801235:	31 d2                	xor    %edx,%edx
  801237:	8b 74 24 20          	mov    0x20(%esp),%esi
  80123b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80123f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801243:	83 c4 2c             	add    $0x2c,%esp
  801246:	c3                   	ret    
  801247:	90                   	nop
  801248:	39 f8                	cmp    %edi,%eax
  80124a:	77 64                	ja     8012b0 <__umoddi3+0xc0>
  80124c:	0f bd e8             	bsr    %eax,%ebp
  80124f:	83 f5 1f             	xor    $0x1f,%ebp
  801252:	75 74                	jne    8012c8 <__umoddi3+0xd8>
  801254:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801258:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80125c:	0f 87 0e 01 00 00    	ja     801370 <__umoddi3+0x180>
  801262:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801266:	29 f1                	sub    %esi,%ecx
  801268:	19 c7                	sbb    %eax,%edi
  80126a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80126e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801272:	8b 44 24 14          	mov    0x14(%esp),%eax
  801276:	8b 54 24 18          	mov    0x18(%esp),%edx
  80127a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80127e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801282:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801286:	83 c4 2c             	add    $0x2c,%esp
  801289:	c3                   	ret    
  80128a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801290:	85 f6                	test   %esi,%esi
  801292:	89 f5                	mov    %esi,%ebp
  801294:	75 0b                	jne    8012a1 <__umoddi3+0xb1>
  801296:	b8 01 00 00 00       	mov    $0x1,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	f7 f6                	div    %esi
  80129f:	89 c5                	mov    %eax,%ebp
  8012a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012a5:	31 d2                	xor    %edx,%edx
  8012a7:	f7 f5                	div    %ebp
  8012a9:	89 c8                	mov    %ecx,%eax
  8012ab:	f7 f5                	div    %ebp
  8012ad:	eb 84                	jmp    801233 <__umoddi3+0x43>
  8012af:	90                   	nop
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 fa                	mov    %edi,%edx
  8012b4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012b8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012bc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012c0:	83 c4 2c             	add    $0x2c,%esp
  8012c3:	c3                   	ret    
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012cc:	be 20 00 00 00       	mov    $0x20,%esi
  8012d1:	89 e9                	mov    %ebp,%ecx
  8012d3:	29 ee                	sub    %ebp,%esi
  8012d5:	d3 e2                	shl    %cl,%edx
  8012d7:	89 f1                	mov    %esi,%ecx
  8012d9:	d3 e8                	shr    %cl,%eax
  8012db:	89 e9                	mov    %ebp,%ecx
  8012dd:	09 d0                	or     %edx,%eax
  8012df:	89 fa                	mov    %edi,%edx
  8012e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012e9:	d3 e0                	shl    %cl,%eax
  8012eb:	89 f1                	mov    %esi,%ecx
  8012ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012f5:	d3 ea                	shr    %cl,%edx
  8012f7:	89 e9                	mov    %ebp,%ecx
  8012f9:	d3 e7                	shl    %cl,%edi
  8012fb:	89 f1                	mov    %esi,%ecx
  8012fd:	d3 e8                	shr    %cl,%eax
  8012ff:	89 e9                	mov    %ebp,%ecx
  801301:	09 f8                	or     %edi,%eax
  801303:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801307:	f7 74 24 0c          	divl   0xc(%esp)
  80130b:	d3 e7                	shl    %cl,%edi
  80130d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801311:	89 d7                	mov    %edx,%edi
  801313:	f7 64 24 10          	mull   0x10(%esp)
  801317:	39 d7                	cmp    %edx,%edi
  801319:	89 c1                	mov    %eax,%ecx
  80131b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80131f:	72 3b                	jb     80135c <__umoddi3+0x16c>
  801321:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801325:	72 31                	jb     801358 <__umoddi3+0x168>
  801327:	8b 44 24 18          	mov    0x18(%esp),%eax
  80132b:	29 c8                	sub    %ecx,%eax
  80132d:	19 d7                	sbb    %edx,%edi
  80132f:	89 e9                	mov    %ebp,%ecx
  801331:	89 fa                	mov    %edi,%edx
  801333:	d3 e8                	shr    %cl,%eax
  801335:	89 f1                	mov    %esi,%ecx
  801337:	d3 e2                	shl    %cl,%edx
  801339:	89 e9                	mov    %ebp,%ecx
  80133b:	09 d0                	or     %edx,%eax
  80133d:	89 fa                	mov    %edi,%edx
  80133f:	d3 ea                	shr    %cl,%edx
  801341:	8b 74 24 20          	mov    0x20(%esp),%esi
  801345:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801349:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80134d:	83 c4 2c             	add    $0x2c,%esp
  801350:	c3                   	ret    
  801351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801358:	39 d7                	cmp    %edx,%edi
  80135a:	75 cb                	jne    801327 <__umoddi3+0x137>
  80135c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801360:	89 c1                	mov    %eax,%ecx
  801362:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801366:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80136a:	eb bb                	jmp    801327 <__umoddi3+0x137>
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801374:	0f 82 e8 fe ff ff    	jb     801262 <__umoddi3+0x72>
  80137a:	e9 f3 fe ff ff       	jmp    801272 <__umoddi3+0x82>
