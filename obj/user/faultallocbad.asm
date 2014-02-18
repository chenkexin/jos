
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
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
  800044:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  80004b:	e8 f3 01 00 00       	call   800243 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 6d 0d 00 00       	call   800ddc <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 13 80 00 	movl   $0x80136a,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 13 80 	movl   $0x8013ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 76 07 00 00       	call   800829 <snprintf>
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
  8000c6:	e8 79 0f 00 00       	call   801044 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 e1 0b 00 00       	call   800cc0 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000f6:	e8 81 0c 00 00       	call   800d7c <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 74 24 04          	mov    %esi,0x4(%esp)
  80011c:	89 1c 24             	mov    %ebx,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 d9 0b 00 00       	call   800d1f <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800159:	e8 1e 0c 00 00       	call   800d7c <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 d8 13 80 00 	movl   $0x8013d8,(%esp)
  80017b:	e8 c3 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 53 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 68 13 80 00 	movl   $0x801368,(%esp)
  800196:	e8 a8 00 00 00       	call   800243 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	83 c0 01             	add    $0x1,%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 19                	jne    8001d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c6:	00 
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 ee 0a 00 00       	call   800cc0 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	83 c4 14             	add    $0x14,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800206:	8b 45 08             	mov    0x8(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021e:	e8 af 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800223:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 85 0a 00 00       	call   800cc0 <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 87 ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    
  80025d:	00 00                	add    %al,(%eax)
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 4c             	sub    $0x4c,%esp
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800271:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800277:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027a:	b8 00 00 00 00       	mov    $0x0,%eax
  80027f:	39 d8                	cmp    %ebx,%eax
  800281:	72 17                	jb     80029a <printnum+0x3a>
  800283:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800286:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800289:	76 0f                	jbe    80029a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028b:	8b 75 14             	mov    0x14(%ebp),%esi
  80028e:	83 ee 01             	sub    $0x1,%esi
  800291:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800294:	85 f6                	test   %esi,%esi
  800296:	7f 63                	jg     8002fb <printnum+0x9b>
  800298:	eb 75                	jmp    80030f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80029d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a4:	83 e8 01             	sub    $0x1,%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002cb:	89 1c 24             	mov    %ebx,(%esp)
  8002ce:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d5:	e8 a6 0d 00 00       	call   801080 <__udivdi3>
  8002da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002e0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ef:	89 fa                	mov    %edi,%edx
  8002f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002f4:	e8 67 ff ff ff       	call   800260 <printnum>
  8002f9:	eb 14                	jmp    80030f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ff:	8b 45 18             	mov    0x18(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	83 ee 01             	sub    $0x1,%esi
  80030a:	75 ef                	jne    8002fb <printnum+0x9b>
  80030c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800313:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800317:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800325:	00 
  800326:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800329:	89 1c 24             	mov    %ebx,(%esp)
  80032c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80032f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800333:	e8 98 0e 00 00       	call   8011d0 <__umoddi3>
  800338:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033c:	0f be 80 fb 13 80 00 	movsbl 0x8013fb(%eax),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800349:	ff d0                	call   *%eax
}
  80034b:	83 c4 4c             	add    $0x4c,%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800356:	83 fa 01             	cmp    $0x1,%edx
  800359:	7e 0e                	jle    800369 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	8b 52 04             	mov    0x4(%edx),%edx
  800367:	eb 22                	jmp    80038b <getuint+0x38>
	else if (lflag)
  800369:	85 d2                	test   %edx,%edx
  80036b:	74 10                	je     80037d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 0e                	jmp    80038b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800393:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 0a                	jae    8003a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a1:	88 0a                	mov    %cl,(%edx)
  8003a3:	83 c2 01             	add    $0x1,%edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 4c             	sub    $0x4c,%esp
  8003db:	8b 75 08             	mov    0x8(%ebp),%esi
  8003de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e4:	eb 11                	jmp    8003f7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	0f 84 db 03 00 00    	je     8007c9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f2:	89 04 24             	mov    %eax,(%esp)
  8003f5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f7:	0f b6 07             	movzbl (%edi),%eax
  8003fa:	83 c7 01             	add    $0x1,%edi
  8003fd:	83 f8 25             	cmp    $0x25,%eax
  800400:	75 e4                	jne    8003e6 <vprintfmt+0x14>
  800402:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800406:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80040d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80041b:	ba 00 00 00 00       	mov    $0x0,%edx
  800420:	eb 2b                	jmp    80044d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800425:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800429:	eb 22                	jmp    80044d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800432:	eb 19                	jmp    80044d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800437:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80043e:	eb 0d                	jmp    80044d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800440:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800443:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800446:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	0f b6 0f             	movzbl (%edi),%ecx
  800450:	8d 47 01             	lea    0x1(%edi),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	0f b6 07             	movzbl (%edi),%eax
  800459:	83 e8 23             	sub    $0x23,%eax
  80045c:	3c 55                	cmp    $0x55,%al
  80045e:	0f 87 40 03 00 00    	ja     8007a4 <vprintfmt+0x3d2>
  800464:	0f b6 c0             	movzbl %al,%eax
  800467:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046e:	83 e9 30             	sub    $0x30,%ecx
  800471:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800474:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800478:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80047b:	83 f9 09             	cmp    $0x9,%ecx
  80047e:	77 57                	ja     8004d7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800483:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800486:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80048c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80048f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800493:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800496:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800499:	83 f9 09             	cmp    $0x9,%ecx
  80049c:	76 eb                	jbe    800489 <vprintfmt+0xb7>
  80049e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a4:	eb 34                	jmp    8004da <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b7:	eb 21                	jmp    8004da <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bd:	0f 88 71 ff ff ff    	js     800434 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004c6:	eb 85                	jmp    80044d <vprintfmt+0x7b>
  8004c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004d2:	e9 76 ff ff ff       	jmp    80044d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	0f 89 69 ff ff ff    	jns    80044d <vprintfmt+0x7b>
  8004e4:	e9 57 ff ff ff       	jmp    800440 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ef:	e9 59 ff ff ff       	jmp    80044d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800501:	8b 00                	mov    (%eax),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050b:	e9 e7 fe ff ff       	jmp    8003f7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 c2                	mov    %eax,%edx
  80051d:	c1 fa 1f             	sar    $0x1f,%edx
  800520:	31 d0                	xor    %edx,%eax
  800522:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800524:	83 f8 08             	cmp    $0x8,%eax
  800527:	7f 0b                	jg     800534 <vprintfmt+0x162>
  800529:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800530:	85 d2                	test   %edx,%edx
  800532:	75 20                	jne    800554 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800534:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800538:	c7 44 24 08 13 14 80 	movl   $0x801413,0x8(%esp)
  80053f:	00 
  800540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800544:	89 34 24             	mov    %esi,(%esp)
  800547:	e8 5e fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054f:	e9 a3 fe ff ff       	jmp    8003f7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800554:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800558:	c7 44 24 08 1c 14 80 	movl   $0x80141c,0x8(%esp)
  80055f:	00 
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	89 34 24             	mov    %esi,(%esp)
  800567:	e8 3e fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80056f:	e9 83 fe ff ff       	jmp    8003f7 <vprintfmt+0x25>
  800574:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800577:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800588:	85 ff                	test   %edi,%edi
  80058a:	b8 0c 14 80 00       	mov    $0x80140c,%eax
  80058f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800592:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800596:	74 06                	je     80059e <vprintfmt+0x1cc>
  800598:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80059c:	7f 16                	jg     8005b4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	0f b6 17             	movzbl (%edi),%edx
  8005a1:	0f be c2             	movsbl %dl,%eax
  8005a4:	83 c7 01             	add    $0x1,%edi
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	0f 85 9f 00 00 00    	jne    80064e <vprintfmt+0x27c>
  8005af:	e9 8b 00 00 00       	jmp    80063f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b8:	89 3c 24             	mov    %edi,(%esp)
  8005bb:	e8 c2 02 00 00       	call   800882 <strnlen>
  8005c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c3:	29 c2                	sub    %eax,%edx
  8005c5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	7e d2                	jle    80059e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005cc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005d3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d6:	89 d7                	mov    %edx,%edi
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	83 ef 01             	sub    $0x1,%edi
  8005e7:	75 ef                	jne    8005d8 <vprintfmt+0x206>
  8005e9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ef:	eb ad                	jmp    80059e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f5:	74 20                	je     800617 <vprintfmt+0x245>
  8005f7:	0f be d2             	movsbl %dl,%edx
  8005fa:	83 ea 20             	sub    $0x20,%edx
  8005fd:	83 fa 5e             	cmp    $0x5e,%edx
  800600:	76 15                	jbe    800617 <vprintfmt+0x245>
					putch('?', putdat);
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800605:	89 54 24 04          	mov    %edx,0x4(%esp)
  800609:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800610:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800613:	ff d1                	call   *%ecx
  800615:	eb 0f                	jmp    800626 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800617:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061e:	89 04 24             	mov    %eax,(%esp)
  800621:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800624:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800626:	83 eb 01             	sub    $0x1,%ebx
  800629:	0f b6 17             	movzbl (%edi),%edx
  80062c:	0f be c2             	movsbl %dl,%eax
  80062f:	83 c7 01             	add    $0x1,%edi
  800632:	85 c0                	test   %eax,%eax
  800634:	75 24                	jne    80065a <vprintfmt+0x288>
  800636:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800639:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80063c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800642:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800646:	0f 8e ab fd ff ff    	jle    8003f7 <vprintfmt+0x25>
  80064c:	eb 20                	jmp    80066e <vprintfmt+0x29c>
  80064e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800651:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800654:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800657:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	85 f6                	test   %esi,%esi
  80065c:	78 93                	js     8005f1 <vprintfmt+0x21f>
  80065e:	83 ee 01             	sub    $0x1,%esi
  800661:	79 8e                	jns    8005f1 <vprintfmt+0x21f>
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800666:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800669:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066c:	eb d1                	jmp    80063f <vprintfmt+0x26d>
  80066e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800671:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800675:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067e:	83 ef 01             	sub    $0x1,%edi
  800681:	75 ee                	jne    800671 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800686:	e9 6c fd ff ff       	jmp    8003f7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068b:	83 fa 01             	cmp    $0x1,%edx
  80068e:	66 90                	xchg   %ax,%ax
  800690:	7e 16                	jle    8006a8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 08             	lea    0x8(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a6:	eb 32                	jmp    8006da <vprintfmt+0x308>
	else if (lflag)
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	74 18                	je     8006c4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ba:	89 c1                	mov    %eax,%ecx
  8006bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c2:	eb 16                	jmp    8006da <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d2:	89 c7                	mov    %eax,%edi
  8006d4:	c1 ff 1f             	sar    $0x1f,%edi
  8006d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006e9:	79 7d                	jns    800768 <vprintfmt+0x396>
				putch('-', putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006fe:	f7 d8                	neg    %eax
  800700:	83 d2 00             	adc    $0x0,%edx
  800703:	f7 da                	neg    %edx
			}
			base = 10;
  800705:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070a:	eb 5c                	jmp    800768 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 3f fc ff ff       	call   800353 <getuint>
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800719:	eb 4d                	jmp    800768 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 30 fc ff ff       	call   800353 <getuint>
      base = 8;
  800723:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800728:	eb 3e                	jmp    800768 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800735:	ff d6                	call   *%esi
			putch('x', putdat);
  800737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800742:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800754:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800759:	eb 0d                	jmp    800768 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 f0 fb ff ff       	call   800353 <getuint>
			base = 16;
  800763:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800768:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80076c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800770:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800773:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800777:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800782:	89 da                	mov    %ebx,%edx
  800784:	89 f0                	mov    %esi,%eax
  800786:	e8 d5 fa ff ff       	call   800260 <printnum>
			break;
  80078b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80078e:	e9 64 fc ff ff       	jmp    8003f7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	89 0c 24             	mov    %ecx,(%esp)
  80079a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079f:	e9 53 fc ff ff       	jmp    8003f7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b5:	0f 84 3c fc ff ff    	je     8003f7 <vprintfmt+0x25>
  8007bb:	83 ef 01             	sub    $0x1,%edi
  8007be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c2:	75 f7                	jne    8007bb <vprintfmt+0x3e9>
  8007c4:	e9 2e fc ff ff       	jmp    8003f7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007c9:	83 c4 4c             	add    $0x4c,%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 28             	sub    $0x28,%esp
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 30                	jle    800822 <vsnprintf+0x51>
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 2c                	je     800822 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	c7 04 24 8d 03 80 00 	movl   $0x80038d,(%esp)
  800812:	e8 bb fb ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800820:	eb 05                	jmp    800827 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800832:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800836:	8b 45 10             	mov    0x10(%ebp),%eax
  800839:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 82 ff ff ff       	call   8007d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	80 3a 00             	cmpb   $0x0,(%edx)
  800869:	74 10                	je     80087b <strlen+0x1b>
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
  800879:	eb 05                	jmp    800880 <strlen+0x20>
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	74 1c                	je     8008ac <strnlen+0x2a>
  800890:	80 3b 00             	cmpb   $0x0,(%ebx)
  800893:	74 1e                	je     8008b3 <strnlen+0x31>
  800895:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80089a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 ca                	cmp    %ecx,%edx
  80089e:	74 18                	je     8008b8 <strnlen+0x36>
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008a8:	75 f0                	jne    80089a <strnlen+0x18>
  8008aa:	eb 0c                	jmp    8008b8 <strnlen+0x36>
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb 05                	jmp    8008b8 <strnlen+0x36>
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ca:	88 1a                	mov    %bl,(%edx)
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	75 f1                	jne    8008c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e3:	89 1c 24             	mov    %ebx,(%esp)
  8008e6:	e8 75 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	01 d8                	add    %ebx,%eax
  8008f4:	89 04 24             	mov    %eax,(%esp)
  8008f7:	e8 bf ff ff ff       	call   8008bb <strcpy>
	return dst;
}
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	83 c4 08             	add    $0x8,%esp
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	85 db                	test   %ebx,%ebx
  800914:	74 16                	je     80092c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	01 f3                	add    %esi,%ebx
  800918:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80091a:	0f b6 02             	movzbl (%edx),%eax
  80091d:	88 01                	mov    %al,(%ecx)
  80091f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800922:	80 3a 01             	cmpb   $0x1,(%edx)
  800925:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800928:	39 d9                	cmp    %ebx,%ecx
  80092a:	75 ee                	jne    80091a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092c:	89 f0                	mov    %esi,%eax
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800941:	89 f8                	mov    %edi,%eax
  800943:	85 f6                	test   %esi,%esi
  800945:	74 33                	je     80097a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800947:	83 fe 01             	cmp    $0x1,%esi
  80094a:	74 25                	je     800971 <strlcpy+0x3f>
  80094c:	0f b6 0b             	movzbl (%ebx),%ecx
  80094f:	84 c9                	test   %cl,%cl
  800951:	74 22                	je     800975 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800953:	83 ee 02             	sub    $0x2,%esi
  800956:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095b:	88 08                	mov    %cl,(%eax)
  80095d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800960:	39 f2                	cmp    %esi,%edx
  800962:	74 13                	je     800977 <strlcpy+0x45>
  800964:	83 c2 01             	add    $0x1,%edx
  800967:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096b:	84 c9                	test   %cl,%cl
  80096d:	75 ec                	jne    80095b <strlcpy+0x29>
  80096f:	eb 06                	jmp    800977 <strlcpy+0x45>
  800971:	89 f8                	mov    %edi,%eax
  800973:	eb 02                	jmp    800977 <strlcpy+0x45>
  800975:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800977:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097a:	29 f8                	sub    %edi,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098a:	0f b6 01             	movzbl (%ecx),%eax
  80098d:	84 c0                	test   %al,%al
  80098f:	74 15                	je     8009a6 <strcmp+0x25>
  800991:	3a 02                	cmp    (%edx),%al
  800993:	75 11                	jne    8009a6 <strcmp+0x25>
		p++, q++;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	84 c0                	test   %al,%al
  8009a0:	74 04                	je     8009a6 <strcmp+0x25>
  8009a2:	3a 02                	cmp    (%edx),%al
  8009a4:	74 ef                	je     800995 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009be:	85 f6                	test   %esi,%esi
  8009c0:	74 29                	je     8009eb <strncmp+0x3b>
  8009c2:	0f b6 03             	movzbl (%ebx),%eax
  8009c5:	84 c0                	test   %al,%al
  8009c7:	74 30                	je     8009f9 <strncmp+0x49>
  8009c9:	3a 02                	cmp    (%edx),%al
  8009cb:	75 2c                	jne    8009f9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009cd:	8d 43 01             	lea    0x1(%ebx),%eax
  8009d0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d7:	39 f0                	cmp    %esi,%eax
  8009d9:	74 17                	je     8009f2 <strncmp+0x42>
  8009db:	0f b6 08             	movzbl (%eax),%ecx
  8009de:	84 c9                	test   %cl,%cl
  8009e0:	74 17                	je     8009f9 <strncmp+0x49>
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	3a 0a                	cmp    (%edx),%cl
  8009e7:	74 e9                	je     8009d2 <strncmp+0x22>
  8009e9:	eb 0e                	jmp    8009f9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f0:	eb 0f                	jmp    800a01 <strncmp+0x51>
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	eb 08                	jmp    800a01 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f9:	0f b6 03             	movzbl (%ebx),%eax
  8009fc:	0f b6 12             	movzbl (%edx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a0f:	0f b6 18             	movzbl (%eax),%ebx
  800a12:	84 db                	test   %bl,%bl
  800a14:	74 1d                	je     800a33 <strchr+0x2e>
  800a16:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a18:	38 d3                	cmp    %dl,%bl
  800a1a:	75 06                	jne    800a22 <strchr+0x1d>
  800a1c:	eb 1a                	jmp    800a38 <strchr+0x33>
  800a1e:	38 ca                	cmp    %cl,%dl
  800a20:	74 16                	je     800a38 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	75 f2                	jne    800a1e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 05                	jmp    800a38 <strchr+0x33>
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a45:	0f b6 18             	movzbl (%eax),%ebx
  800a48:	84 db                	test   %bl,%bl
  800a4a:	74 16                	je     800a62 <strfind+0x27>
  800a4c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a4e:	38 d3                	cmp    %dl,%bl
  800a50:	75 06                	jne    800a58 <strfind+0x1d>
  800a52:	eb 0e                	jmp    800a62 <strfind+0x27>
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0a                	je     800a62 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	0f b6 10             	movzbl (%eax),%edx
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	75 f2                	jne    800a54 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a62:	5b                   	pop    %ebx
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a71:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7a:	85 c9                	test   %ecx,%ecx
  800a7c:	74 36                	je     800ab4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a84:	75 28                	jne    800aae <memset+0x49>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 23                	jne    800aae <memset+0x49>
		c &= 0xFF;
  800a8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	c1 e3 08             	shl    $0x8,%ebx
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	c1 e6 18             	shl    $0x18,%esi
  800a99:	89 d0                	mov    %edx,%eax
  800a9b:	c1 e0 10             	shl    $0x10,%eax
  800a9e:	09 f0                	or     %esi,%eax
  800aa0:	09 c2                	or     %eax,%edx
  800aa2:	89 d0                	mov    %edx,%eax
  800aa4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa9:	fc                   	cld    
  800aaa:	f3 ab                	rep stos %eax,%es:(%edi)
  800aac:	eb 06                	jmp    800ab4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	fc                   	cld    
  800ab2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab4:	89 f8                	mov    %edi,%eax
  800ab6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ab9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800abc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800abf:	89 ec                	mov    %ebp,%esp
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	83 ec 08             	sub    $0x8,%esp
  800ac9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800acc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	73 36                	jae    800b12 <memmove+0x4f>
  800adc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adf:	39 d0                	cmp    %edx,%eax
  800ae1:	73 2f                	jae    800b12 <memmove+0x4f>
		s += n;
		d += n;
  800ae3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	f6 c2 03             	test   $0x3,%dl
  800ae9:	75 1b                	jne    800b06 <memmove+0x43>
  800aeb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af1:	75 13                	jne    800b06 <memmove+0x43>
  800af3:	f6 c1 03             	test   $0x3,%cl
  800af6:	75 0e                	jne    800b06 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af8:	83 ef 04             	sub    $0x4,%edi
  800afb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b01:	fd                   	std    
  800b02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b04:	eb 09                	jmp    800b0f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b06:	83 ef 01             	sub    $0x1,%edi
  800b09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0c:	fd                   	std    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0f:	fc                   	cld    
  800b10:	eb 20                	jmp    800b32 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b18:	75 13                	jne    800b2d <memmove+0x6a>
  800b1a:	a8 03                	test   $0x3,%al
  800b1c:	75 0f                	jne    800b2d <memmove+0x6a>
  800b1e:	f6 c1 03             	test   $0x3,%cl
  800b21:	75 0a                	jne    800b2d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b26:	89 c7                	mov    %eax,%edi
  800b28:	fc                   	cld    
  800b29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2b:	eb 05                	jmp    800b32 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	fc                   	cld    
  800b30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b38:	89 ec                	mov    %ebp,%esp
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 68 ff ff ff       	call   800ac3 <memmove>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	74 36                	je     800ba9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b73:	0f b6 03             	movzbl (%ebx),%eax
  800b76:	0f b6 0e             	movzbl (%esi),%ecx
  800b79:	38 c8                	cmp    %cl,%al
  800b7b:	75 17                	jne    800b94 <memcmp+0x37>
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	eb 1a                	jmp    800b9e <memcmp+0x41>
  800b84:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b89:	83 c2 01             	add    $0x1,%edx
  800b8c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b90:	38 c8                	cmp    %cl,%al
  800b92:	74 0a                	je     800b9e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b94:	0f b6 c0             	movzbl %al,%eax
  800b97:	0f b6 c9             	movzbl %cl,%ecx
  800b9a:	29 c8                	sub    %ecx,%eax
  800b9c:	eb 10                	jmp    800bae <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9e:	39 fa                	cmp    %edi,%edx
  800ba0:	75 e2                	jne    800b84 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	eb 05                	jmp    800bae <memcmp+0x51>
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc2:	39 d0                	cmp    %edx,%eax
  800bc4:	73 13                	jae    800bd9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc6:	89 d9                	mov    %ebx,%ecx
  800bc8:	38 18                	cmp    %bl,(%eax)
  800bca:	75 06                	jne    800bd2 <memfind+0x1f>
  800bcc:	eb 0b                	jmp    800bd9 <memfind+0x26>
  800bce:	38 08                	cmp    %cl,(%eax)
  800bd0:	74 07                	je     800bd9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	39 d0                	cmp    %edx,%eax
  800bd7:	75 f5                	jne    800bce <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 04             	sub    $0x4,%esp
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800beb:	0f b6 02             	movzbl (%edx),%eax
  800bee:	3c 09                	cmp    $0x9,%al
  800bf0:	74 04                	je     800bf6 <strtol+0x1a>
  800bf2:	3c 20                	cmp    $0x20,%al
  800bf4:	75 0e                	jne    800c04 <strtol+0x28>
		s++;
  800bf6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf9:	0f b6 02             	movzbl (%edx),%eax
  800bfc:	3c 09                	cmp    $0x9,%al
  800bfe:	74 f6                	je     800bf6 <strtol+0x1a>
  800c00:	3c 20                	cmp    $0x20,%al
  800c02:	74 f2                	je     800bf6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c04:	3c 2b                	cmp    $0x2b,%al
  800c06:	75 0a                	jne    800c12 <strtol+0x36>
		s++;
  800c08:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c10:	eb 10                	jmp    800c22 <strtol+0x46>
  800c12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c17:	3c 2d                	cmp    $0x2d,%al
  800c19:	75 07                	jne    800c22 <strtol+0x46>
		s++, neg = 1;
  800c1b:	83 c2 01             	add    $0x1,%edx
  800c1e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c28:	75 15                	jne    800c3f <strtol+0x63>
  800c2a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2d:	75 10                	jne    800c3f <strtol+0x63>
  800c2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c33:	75 0a                	jne    800c3f <strtol+0x63>
		s += 2, base = 16;
  800c35:	83 c2 02             	add    $0x2,%edx
  800c38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3d:	eb 10                	jmp    800c4f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c3f:	85 db                	test   %ebx,%ebx
  800c41:	75 0c                	jne    800c4f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c43:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c45:	80 3a 30             	cmpb   $0x30,(%edx)
  800c48:	75 05                	jne    800c4f <strtol+0x73>
		s++, base = 8;
  800c4a:	83 c2 01             	add    $0x1,%edx
  800c4d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c54:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c57:	0f b6 0a             	movzbl (%edx),%ecx
  800c5a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c5d:	89 f3                	mov    %esi,%ebx
  800c5f:	80 fb 09             	cmp    $0x9,%bl
  800c62:	77 08                	ja     800c6c <strtol+0x90>
			dig = *s - '0';
  800c64:	0f be c9             	movsbl %cl,%ecx
  800c67:	83 e9 30             	sub    $0x30,%ecx
  800c6a:	eb 22                	jmp    800c8e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c6c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c6f:	89 f3                	mov    %esi,%ebx
  800c71:	80 fb 19             	cmp    $0x19,%bl
  800c74:	77 08                	ja     800c7e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c76:	0f be c9             	movsbl %cl,%ecx
  800c79:	83 e9 57             	sub    $0x57,%ecx
  800c7c:	eb 10                	jmp    800c8e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c7e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c81:	89 f3                	mov    %esi,%ebx
  800c83:	80 fb 19             	cmp    $0x19,%bl
  800c86:	77 16                	ja     800c9e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c88:	0f be c9             	movsbl %cl,%ecx
  800c8b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c91:	7d 0f                	jge    800ca2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c93:	83 c2 01             	add    $0x1,%edx
  800c96:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c9a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c9c:	eb b9                	jmp    800c57 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	89 c1                	mov    %eax,%ecx
  800ca0:	eb 02                	jmp    800ca4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ca4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca8:	74 05                	je     800caf <strtol+0xd3>
		*endptr = (char *) s;
  800caa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cad:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800caf:	89 ca                	mov    %ecx,%edx
  800cb1:	f7 da                	neg    %edx
  800cb3:	85 ff                	test   %edi,%edi
  800cb5:	0f 45 c2             	cmovne %edx,%eax
}
  800cb8:	83 c4 04             	add    $0x4,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_cgetc>:

int
sys_cgetc(void)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 01 00 00 00       	mov    $0x1,%eax
  800d08:	89 d1                	mov    %edx,%ecx
  800d0a:	89 d3                	mov    %edx,%ebx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1b:	89 ec                	mov    %ebp,%esp
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 38             	sub    $0x38,%esp
  800d25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d33:	b8 03 00 00 00       	mov    $0x3,%eax
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 cb                	mov    %ecx,%ebx
  800d3d:	89 cf                	mov    %ecx,%edi
  800d3f:	89 ce                	mov    %ecx,%esi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 28                	jle    800d6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800d6a:	e8 d9 f3 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 02 00 00 00       	mov    $0x2,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_yield>:

void
sys_yield(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 38             	sub    $0x38,%esp
  800de2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	b8 04 00 00 00       	mov    $0x4,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfe:	89 f7                	mov    %esi,%edi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 28                	jle    800e2e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e11:	00 
  800e12:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e19:	00 
  800e1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e29:	e8 1a f3 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e37:	89 ec                	mov    %ebp,%esp
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 38             	sub    $0x38,%esp
  800e41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 28                	jle    800e8c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e6f:	00 
  800e70:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e77:	00 
  800e78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7f:	00 
  800e80:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e87:	e8 bc f2 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e95:	89 ec                	mov    %ebp,%esp
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 38             	sub    $0x38,%esp
  800e9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7e 28                	jle    800eea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ecd:	00 
  800ece:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800ee5:	e8 5e f2 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef3:	89 ec                	mov    %ebp,%esp
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 38             	sub    $0x38,%esp
  800efd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f00:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f03:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	89 df                	mov    %ebx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7e 28                	jle    800f48 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3b:	00 
  800f3c:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f43:	e8 00 f2 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f48:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f51:	89 ec                	mov    %ebp,%esp
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 38             	sub    $0x38,%esp
  800f5b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f61:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f69:	b8 09 00 00 00       	mov    $0x9,%eax
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	89 df                	mov    %ebx,%edi
  800f76:	89 de                	mov    %ebx,%esi
  800f78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	7e 28                	jle    800fa6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f82:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f89:	00 
  800f8a:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f99:	00 
  800f9a:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800fa1:	e8 a2 f1 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800faf:	89 ec                	mov    %ebp,%esp
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	be 00 00 00 00       	mov    $0x0,%esi
  800fc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe3:	89 ec                	mov    %ebp,%esp
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 38             	sub    $0x38,%esp
  800fed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 cb                	mov    %ecx,%ebx
  801005:	89 cf                	mov    %ecx,%edi
  801007:	89 ce                	mov    %ecx,%esi
  801009:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 28                	jle    801037 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801013:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80101a:	00 
  80101b:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  801022:	00 
  801023:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102a:	00 
  80102b:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  801032:	e8 11 f1 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801037:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801040:	89 ec                	mov    %ebp,%esp
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80104a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801051:	75 1c                	jne    80106f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801053:	c7 44 24 08 70 16 80 	movl   $0x801670,0x8(%esp)
  80105a:	00 
  80105b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801062:	00 
  801063:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  80106a:	e8 d9 f0 ff ff       	call   800148 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    
  801079:	00 00                	add    %al,(%eax)
  80107b:	00 00                	add    %al,(%eax)
  80107d:	00 00                	add    %al,(%eax)
	...

00801080 <__udivdi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801087:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80108b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80108f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801093:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801097:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010a5:	89 ea                	mov    %ebp,%edx
  8010a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010ab:	75 33                	jne    8010e0 <__udivdi3+0x60>
  8010ad:	39 e9                	cmp    %ebp,%ecx
  8010af:	77 6f                	ja     801120 <__udivdi3+0xa0>
  8010b1:	85 c9                	test   %ecx,%ecx
  8010b3:	89 ce                	mov    %ecx,%esi
  8010b5:	75 0b                	jne    8010c2 <__udivdi3+0x42>
  8010b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bc:	31 d2                	xor    %edx,%edx
  8010be:	f7 f1                	div    %ecx
  8010c0:	89 c6                	mov    %eax,%esi
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	89 e8                	mov    %ebp,%eax
  8010c6:	f7 f6                	div    %esi
  8010c8:	89 c5                	mov    %eax,%ebp
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	f7 f6                	div    %esi
  8010ce:	89 ea                	mov    %ebp,%edx
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	39 e8                	cmp    %ebp,%eax
  8010e2:	77 24                	ja     801108 <__udivdi3+0x88>
  8010e4:	0f bd c8             	bsr    %eax,%ecx
  8010e7:	83 f1 1f             	xor    $0x1f,%ecx
  8010ea:	89 0c 24             	mov    %ecx,(%esp)
  8010ed:	75 49                	jne    801138 <__udivdi3+0xb8>
  8010ef:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010f3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8010f7:	0f 86 ab 00 00 00    	jbe    8011a8 <__udivdi3+0x128>
  8010fd:	39 e8                	cmp    %ebp,%eax
  8010ff:	0f 82 a3 00 00 00    	jb     8011a8 <__udivdi3+0x128>
  801105:	8d 76 00             	lea    0x0(%esi),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	31 c0                	xor    %eax,%eax
  80110c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801110:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801114:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801118:	83 c4 1c             	add    $0x1c,%esp
  80111b:	c3                   	ret    
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f8                	mov    %edi,%eax
  801122:	f7 f1                	div    %ecx
  801124:	31 d2                	xor    %edx,%edx
  801126:	8b 74 24 10          	mov    0x10(%esp),%esi
  80112a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801132:	83 c4 1c             	add    $0x1c,%esp
  801135:	c3                   	ret    
  801136:	66 90                	xchg   %ax,%ax
  801138:	0f b6 0c 24          	movzbl (%esp),%ecx
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	b8 20 00 00 00       	mov    $0x20,%eax
  801143:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801147:	2b 04 24             	sub    (%esp),%eax
  80114a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80114e:	d3 e6                	shl    %cl,%esi
  801150:	89 c1                	mov    %eax,%ecx
  801152:	d3 ed                	shr    %cl,%ebp
  801154:	0f b6 0c 24          	movzbl (%esp),%ecx
  801158:	09 f5                	or     %esi,%ebp
  80115a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80115e:	d3 e6                	shl    %cl,%esi
  801160:	89 c1                	mov    %eax,%ecx
  801162:	89 74 24 04          	mov    %esi,0x4(%esp)
  801166:	89 d6                	mov    %edx,%esi
  801168:	d3 ee                	shr    %cl,%esi
  80116a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80116e:	d3 e2                	shl    %cl,%edx
  801170:	89 c1                	mov    %eax,%ecx
  801172:	d3 ef                	shr    %cl,%edi
  801174:	09 d7                	or     %edx,%edi
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	f7 f5                	div    %ebp
  80117c:	89 d6                	mov    %edx,%esi
  80117e:	89 c7                	mov    %eax,%edi
  801180:	f7 64 24 04          	mull   0x4(%esp)
  801184:	39 d6                	cmp    %edx,%esi
  801186:	72 30                	jb     8011b8 <__udivdi3+0x138>
  801188:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80118c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801190:	d3 e5                	shl    %cl,%ebp
  801192:	39 c5                	cmp    %eax,%ebp
  801194:	73 04                	jae    80119a <__udivdi3+0x11a>
  801196:	39 d6                	cmp    %edx,%esi
  801198:	74 1e                	je     8011b8 <__udivdi3+0x138>
  80119a:	89 f8                	mov    %edi,%eax
  80119c:	31 d2                	xor    %edx,%edx
  80119e:	e9 69 ff ff ff       	jmp    80110c <__udivdi3+0x8c>
  8011a3:	90                   	nop
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	31 d2                	xor    %edx,%edx
  8011aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8011af:	e9 58 ff ff ff       	jmp    80110c <__udivdi3+0x8c>
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c9:	83 c4 1c             	add    $0x1c,%esp
  8011cc:	c3                   	ret    
  8011cd:	00 00                	add    %al,(%eax)
	...

008011d0 <__umoddi3>:
  8011d0:	83 ec 2c             	sub    $0x2c,%esp
  8011d3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011d7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011db:	89 74 24 20          	mov    %esi,0x20(%esp)
  8011df:	8b 74 24 38          	mov    0x38(%esp),%esi
  8011e3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8011e7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8011f3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8011f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011ff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801203:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801207:	75 1f                	jne    801228 <__umoddi3+0x58>
  801209:	39 fe                	cmp    %edi,%esi
  80120b:	76 63                	jbe    801270 <__umoddi3+0xa0>
  80120d:	89 c8                	mov    %ecx,%eax
  80120f:	89 fa                	mov    %edi,%edx
  801211:	f7 f6                	div    %esi
  801213:	89 d0                	mov    %edx,%eax
  801215:	31 d2                	xor    %edx,%edx
  801217:	8b 74 24 20          	mov    0x20(%esp),%esi
  80121b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80121f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801223:	83 c4 2c             	add    $0x2c,%esp
  801226:	c3                   	ret    
  801227:	90                   	nop
  801228:	39 f8                	cmp    %edi,%eax
  80122a:	77 64                	ja     801290 <__umoddi3+0xc0>
  80122c:	0f bd e8             	bsr    %eax,%ebp
  80122f:	83 f5 1f             	xor    $0x1f,%ebp
  801232:	75 74                	jne    8012a8 <__umoddi3+0xd8>
  801234:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801238:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80123c:	0f 87 0e 01 00 00    	ja     801350 <__umoddi3+0x180>
  801242:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801246:	29 f1                	sub    %esi,%ecx
  801248:	19 c7                	sbb    %eax,%edi
  80124a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80124e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801252:	8b 44 24 14          	mov    0x14(%esp),%eax
  801256:	8b 54 24 18          	mov    0x18(%esp),%edx
  80125a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80125e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801262:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801266:	83 c4 2c             	add    $0x2c,%esp
  801269:	c3                   	ret    
  80126a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801270:	85 f6                	test   %esi,%esi
  801272:	89 f5                	mov    %esi,%ebp
  801274:	75 0b                	jne    801281 <__umoddi3+0xb1>
  801276:	b8 01 00 00 00       	mov    $0x1,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	f7 f6                	div    %esi
  80127f:	89 c5                	mov    %eax,%ebp
  801281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801285:	31 d2                	xor    %edx,%edx
  801287:	f7 f5                	div    %ebp
  801289:	89 c8                	mov    %ecx,%eax
  80128b:	f7 f5                	div    %ebp
  80128d:	eb 84                	jmp    801213 <__umoddi3+0x43>
  80128f:	90                   	nop
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 fa                	mov    %edi,%edx
  801294:	8b 74 24 20          	mov    0x20(%esp),%esi
  801298:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80129c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012a0:	83 c4 2c             	add    $0x2c,%esp
  8012a3:	c3                   	ret    
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012ac:	be 20 00 00 00       	mov    $0x20,%esi
  8012b1:	89 e9                	mov    %ebp,%ecx
  8012b3:	29 ee                	sub    %ebp,%esi
  8012b5:	d3 e2                	shl    %cl,%edx
  8012b7:	89 f1                	mov    %esi,%ecx
  8012b9:	d3 e8                	shr    %cl,%eax
  8012bb:	89 e9                	mov    %ebp,%ecx
  8012bd:	09 d0                	or     %edx,%eax
  8012bf:	89 fa                	mov    %edi,%edx
  8012c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012c9:	d3 e0                	shl    %cl,%eax
  8012cb:	89 f1                	mov    %esi,%ecx
  8012cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012d5:	d3 ea                	shr    %cl,%edx
  8012d7:	89 e9                	mov    %ebp,%ecx
  8012d9:	d3 e7                	shl    %cl,%edi
  8012db:	89 f1                	mov    %esi,%ecx
  8012dd:	d3 e8                	shr    %cl,%eax
  8012df:	89 e9                	mov    %ebp,%ecx
  8012e1:	09 f8                	or     %edi,%eax
  8012e3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012e7:	f7 74 24 0c          	divl   0xc(%esp)
  8012eb:	d3 e7                	shl    %cl,%edi
  8012ed:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012f1:	89 d7                	mov    %edx,%edi
  8012f3:	f7 64 24 10          	mull   0x10(%esp)
  8012f7:	39 d7                	cmp    %edx,%edi
  8012f9:	89 c1                	mov    %eax,%ecx
  8012fb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8012ff:	72 3b                	jb     80133c <__umoddi3+0x16c>
  801301:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801305:	72 31                	jb     801338 <__umoddi3+0x168>
  801307:	8b 44 24 18          	mov    0x18(%esp),%eax
  80130b:	29 c8                	sub    %ecx,%eax
  80130d:	19 d7                	sbb    %edx,%edi
  80130f:	89 e9                	mov    %ebp,%ecx
  801311:	89 fa                	mov    %edi,%edx
  801313:	d3 e8                	shr    %cl,%eax
  801315:	89 f1                	mov    %esi,%ecx
  801317:	d3 e2                	shl    %cl,%edx
  801319:	89 e9                	mov    %ebp,%ecx
  80131b:	09 d0                	or     %edx,%eax
  80131d:	89 fa                	mov    %edi,%edx
  80131f:	d3 ea                	shr    %cl,%edx
  801321:	8b 74 24 20          	mov    0x20(%esp),%esi
  801325:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801329:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80132d:	83 c4 2c             	add    $0x2c,%esp
  801330:	c3                   	ret    
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 d7                	cmp    %edx,%edi
  80133a:	75 cb                	jne    801307 <__umoddi3+0x137>
  80133c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801340:	89 c1                	mov    %eax,%ecx
  801342:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801346:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80134a:	eb bb                	jmp    801307 <__umoddi3+0x137>
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801354:	0f 82 e8 fe ff ff    	jb     801242 <__umoddi3+0x72>
  80135a:	e9 f3 fe ff ff       	jmp    801252 <__umoddi3+0x82>
