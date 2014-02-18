
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 00 13 80 00 	movl   $0x801300,(%esp)
  80004e:	e8 54 01 00 00       	call   8001a7 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 bf 0c 00 00       	call   800d1c <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  800074:	e8 2e 01 00 00       	call   8001a7 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 4c 13 80 00 	movl   $0x80134c,(%esp)
  800094:	e8 0e 01 00 00       	call   8001a7 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000af:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000b2:	e8 35 0c 00 00       	call   800cec <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 db                	test   %ebx,%ebx
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 06                	mov    (%esi),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d8:	89 1c 24             	mov    %ebx,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 8d 0b 00 00       	call   800c8f <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 fa 0a 00 00       	call   800c30 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 bb 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 91 0a 00 00       	call   800c30 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ef:	39 d8                	cmp    %ebx,%eax
  8001f1:	72 17                	jb     80020a <printnum+0x3a>
  8001f3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001f6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001f9:	76 0f                	jbe    80020a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001fe:	83 ee 01             	sub    $0x1,%esi
  800201:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800204:	85 f6                	test   %esi,%esi
  800206:	7f 63                	jg     80026b <printnum+0x9b>
  800208:	eb 75                	jmp    80027f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80020d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800211:	8b 45 14             	mov    0x14(%ebp),%eax
  800214:	83 e8 01             	sub    $0x1,%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800222:	8b 44 24 08          	mov    0x8(%esp),%eax
  800226:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80022a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800230:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800237:	00 
  800238:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80023b:	89 1c 24             	mov    %ebx,(%esp)
  80023e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800241:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800245:	e8 c6 0d 00 00       	call   801010 <__udivdi3>
  80024a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80024d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800250:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	89 fa                	mov    %edi,%edx
  800261:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800264:	e8 67 ff ff ff       	call   8001d0 <printnum>
  800269:	eb 14                	jmp    80027f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026f:	8b 45 18             	mov    0x18(%ebp),%eax
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800277:	83 ee 01             	sub    $0x1,%esi
  80027a:	75 ef                	jne    80026b <printnum+0x9b>
  80027c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800283:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800287:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80028a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800295:	00 
  800296:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800299:	89 1c 24             	mov    %ebx,(%esp)
  80029c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80029f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002a3:	e8 b8 0e 00 00       	call   801160 <__umoddi3>
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	0f be 80 75 13 80 00 	movsbl 0x801375(%eax),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b9:	ff d0                	call   *%eax
}
  8002bb:	83 c4 4c             	add    $0x4c,%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800311:	88 0a                	mov    %cl,(%edx)
  800313:	83 c2 01             	add    $0x1,%edx
  800316:	89 10                	mov    %edx,(%eax)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 02 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 4c             	sub    $0x4c,%esp
  80034b:	8b 75 08             	mov    0x8(%ebp),%esi
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800351:	8b 7d 10             	mov    0x10(%ebp),%edi
  800354:	eb 11                	jmp    800367 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800356:	85 c0                	test   %eax,%eax
  800358:	0f 84 db 03 00 00    	je     800739 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80035e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800367:	0f b6 07             	movzbl (%edi),%eax
  80036a:	83 c7 01             	add    $0x1,%edi
  80036d:	83 f8 25             	cmp    $0x25,%eax
  800370:	75 e4                	jne    800356 <vprintfmt+0x14>
  800372:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800376:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80037d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800384:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 2b                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800395:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800399:	eb 22                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8003a2:	eb 19                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ae:	eb 0d                	jmp    8003bd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	0f b6 0f             	movzbl (%edi),%ecx
  8003c0:	8d 47 01             	lea    0x1(%edi),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	0f b6 07             	movzbl (%edi),%eax
  8003c9:	83 e8 23             	sub    $0x23,%eax
  8003cc:	3c 55                	cmp    $0x55,%al
  8003ce:	0f 87 40 03 00 00    	ja     800714 <vprintfmt+0x3d2>
  8003d4:	0f b6 c0             	movzbl %al,%eax
  8003d7:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	83 e9 30             	sub    $0x30,%ecx
  8003e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003e4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003e8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003eb:	83 f9 09             	cmp    $0x9,%ecx
  8003ee:	77 57                	ja     800447 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ff:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800403:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800406:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800409:	83 f9 09             	cmp    $0x9,%ecx
  80040c:	76 eb                	jbe    8003f9 <vprintfmt+0xb7>
  80040e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800411:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800414:	eb 34                	jmp    80044a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 48 04             	lea    0x4(%eax),%ecx
  80041c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800427:	eb 21                	jmp    80044a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800429:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042d:	0f 88 71 ff ff ff    	js     8003a4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800436:	eb 85                	jmp    8003bd <vprintfmt+0x7b>
  800438:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800442:	e9 76 ff ff ff       	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044e:	0f 89 69 ff ff ff    	jns    8003bd <vprintfmt+0x7b>
  800454:	e9 57 ff ff ff       	jmp    8003b0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045f:	e9 59 ff ff ff       	jmp    8003bd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047b:	e9 e7 fe ff ff       	jmp    800367 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	89 c2                	mov    %eax,%edx
  80048d:	c1 fa 1f             	sar    $0x1f,%edx
  800490:	31 d0                	xor    %edx,%eax
  800492:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800494:	83 f8 08             	cmp    $0x8,%eax
  800497:	7f 0b                	jg     8004a4 <vprintfmt+0x162>
  800499:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	75 20                	jne    8004c4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 8d 13 80 	movl   $0x80138d,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	89 34 24             	mov    %esi,(%esp)
  8004b7:	e8 5e fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bf:	e9 a3 fe ff ff       	jmp    800367 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c8:	c7 44 24 08 96 13 80 	movl   $0x801396,0x8(%esp)
  8004cf:	00 
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 34 24             	mov    %esi,(%esp)
  8004d7:	e8 3e fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004df:	e9 83 fe ff ff       	jmp    800367 <vprintfmt+0x25>
  8004e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	b8 86 13 80 00       	mov    $0x801386,%eax
  8004ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800502:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800506:	74 06                	je     80050e <vprintfmt+0x1cc>
  800508:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80050c:	7f 16                	jg     800524 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	0f b6 17             	movzbl (%edi),%edx
  800511:	0f be c2             	movsbl %dl,%eax
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	85 c0                	test   %eax,%eax
  800519:	0f 85 9f 00 00 00    	jne    8005be <vprintfmt+0x27c>
  80051f:	e9 8b 00 00 00       	jmp    8005af <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800528:	89 3c 24             	mov    %edi,(%esp)
  80052b:	e8 c2 02 00 00       	call   8007f2 <strnlen>
  800530:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800533:	29 c2                	sub    %eax,%edx
  800535:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800538:	85 d2                	test   %edx,%edx
  80053a:	7e d2                	jle    80050e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80053c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800540:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800543:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800546:	89 d7                	mov    %edx,%edi
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	83 ef 01             	sub    $0x1,%edi
  800557:	75 ef                	jne    800548 <vprintfmt+0x206>
  800559:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055f:	eb ad                	jmp    80050e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800565:	74 20                	je     800587 <vprintfmt+0x245>
  800567:	0f be d2             	movsbl %dl,%edx
  80056a:	83 ea 20             	sub    $0x20,%edx
  80056d:	83 fa 5e             	cmp    $0x5e,%edx
  800570:	76 15                	jbe    800587 <vprintfmt+0x245>
					putch('?', putdat);
  800572:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800575:	89 54 24 04          	mov    %edx,0x4(%esp)
  800579:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800580:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800583:	ff d1                	call   *%ecx
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800587:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800594:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	0f b6 17             	movzbl (%edi),%edx
  80059c:	0f be c2             	movsbl %dl,%eax
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	75 24                	jne    8005ca <vprintfmt+0x288>
  8005a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b6:	0f 8e ab fd ff ff    	jle    800367 <vprintfmt+0x25>
  8005bc:	eb 20                	jmp    8005de <vprintfmt+0x29c>
  8005be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005c7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	78 93                	js     800561 <vprintfmt+0x21f>
  8005ce:	83 ee 01             	sub    $0x1,%esi
  8005d1:	79 8e                	jns    800561 <vprintfmt+0x21f>
  8005d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005d6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005dc:	eb d1                	jmp    8005af <vprintfmt+0x26d>
  8005de:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ee:	83 ef 01             	sub    $0x1,%edi
  8005f1:	75 ee                	jne    8005e1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f6:	e9 6c fd ff ff       	jmp    800367 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 fa 01             	cmp    $0x1,%edx
  8005fe:	66 90                	xchg   %ax,%ax
  800600:	7e 16                	jle    800618 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 08             	lea    0x8(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800613:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800616:	eb 32                	jmp    80064a <vprintfmt+0x308>
	else if (lflag)
  800618:	85 d2                	test   %edx,%edx
  80061a:	74 18                	je     800634 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800632:	eb 16                	jmp    80064a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800642:	89 c7                	mov    %eax,%edi
  800644:	c1 ff 1f             	sar    $0x1f,%edi
  800647:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80064d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800650:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800655:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800659:	79 7d                	jns    8006d8 <vprintfmt+0x396>
				putch('-', putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80066e:	f7 d8                	neg    %eax
  800670:	83 d2 00             	adc    $0x0,%edx
  800673:	f7 da                	neg    %edx
			}
			base = 10;
  800675:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80067a:	eb 5c                	jmp    8006d8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 3f fc ff ff       	call   8002c3 <getuint>
			base = 10;
  800684:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800689:	eb 4d                	jmp    8006d8 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 30 fc ff ff       	call   8002c3 <getuint>
      base = 8;
  800693:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800698:	eb 3e                	jmp    8006d8 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c9:	eb 0d                	jmp    8006d8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 f0 fb ff ff       	call   8002c3 <getuint>
			base = 16;
  8006d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006dc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006e0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	e8 d5 fa ff ff       	call   8001d0 <printnum>
			break;
  8006fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006fe:	e9 64 fc ff ff       	jmp    800367 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800707:	89 0c 24             	mov    %ecx,(%esp)
  80070a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070f:	e9 53 fc ff ff       	jmp    800367 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800721:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800725:	0f 84 3c fc ff ff    	je     800367 <vprintfmt+0x25>
  80072b:	83 ef 01             	sub    $0x1,%edi
  80072e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800732:	75 f7                	jne    80072b <vprintfmt+0x3e9>
  800734:	e9 2e fc ff ff       	jmp    800367 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800739:	83 c4 4c             	add    $0x4c,%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 28             	sub    $0x28,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800750:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800754:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 30                	jle    800792 <vsnprintf+0x51>
  800762:	85 c0                	test   %eax,%eax
  800764:	74 2c                	je     800792 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 fd 02 80 00 	movl   $0x8002fd,(%esp)
  800782:	e8 bb fb ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800790:	eb 05                	jmp    800797 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 82 ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    
	...

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d9:	74 10                	je     8007eb <strlen+0x1b>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	75 f7                	jne    8007e0 <strlen+0x10>
  8007e9:	eb 05                	jmp    8007f0 <strlen+0x20>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	74 1c                	je     80081c <strnlen+0x2a>
  800800:	80 3b 00             	cmpb   $0x0,(%ebx)
  800803:	74 1e                	je     800823 <strnlen+0x31>
  800805:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80080a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080c:	39 ca                	cmp    %ecx,%edx
  80080e:	74 18                	je     800828 <strnlen+0x36>
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800818:	75 f0                	jne    80080a <strnlen+0x18>
  80081a:	eb 0c                	jmp    800828 <strnlen+0x36>
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
  800821:	eb 05                	jmp    800828 <strnlen+0x36>
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	89 c2                	mov    %eax,%edx
  800837:	0f b6 19             	movzbl (%ecx),%ebx
  80083a:	88 1a                	mov    %bl,(%edx)
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	84 db                	test   %bl,%bl
  800844:	75 f1                	jne    800837 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800846:	5b                   	pop    %ebx
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	89 1c 24             	mov    %ebx,(%esp)
  800856:	e8 75 ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800862:	01 d8                	add    %ebx,%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 bf ff ff ff       	call   80082b <strcpy>
	return dst;
}
  80086c:	89 d8                	mov    %ebx,%eax
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	5b                   	pop    %ebx
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	85 db                	test   %ebx,%ebx
  800884:	74 16                	je     80089c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	01 f3                	add    %esi,%ebx
  800888:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80088a:	0f b6 02             	movzbl (%edx),%eax
  80088d:	88 01                	mov    %al,(%ecx)
  80088f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800892:	80 3a 01             	cmpb   $0x1,(%edx)
  800895:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800898:	39 d9                	cmp    %ebx,%ecx
  80089a:	75 ee                	jne    80088a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	85 f6                	test   %esi,%esi
  8008b5:	74 33                	je     8008ea <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008b7:	83 fe 01             	cmp    $0x1,%esi
  8008ba:	74 25                	je     8008e1 <strlcpy+0x3f>
  8008bc:	0f b6 0b             	movzbl (%ebx),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 22                	je     8008e5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c3:	83 ee 02             	sub    $0x2,%esi
  8008c6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	88 08                	mov    %cl,(%eax)
  8008cd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d0:	39 f2                	cmp    %esi,%edx
  8008d2:	74 13                	je     8008e7 <strlcpy+0x45>
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x29>
  8008df:	eb 06                	jmp    8008e7 <strlcpy+0x45>
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	eb 02                	jmp    8008e7 <strlcpy+0x45>
  8008e5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ea:	29 f8                	sub    %edi,%eax
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fa:	0f b6 01             	movzbl (%ecx),%eax
  8008fd:	84 c0                	test   %al,%al
  8008ff:	74 15                	je     800916 <strcmp+0x25>
  800901:	3a 02                	cmp    (%edx),%al
  800903:	75 11                	jne    800916 <strcmp+0x25>
		p++, q++;
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090b:	0f b6 01             	movzbl (%ecx),%eax
  80090e:	84 c0                	test   %al,%al
  800910:	74 04                	je     800916 <strcmp+0x25>
  800912:	3a 02                	cmp    (%edx),%al
  800914:	74 ef                	je     800905 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 c0             	movzbl %al,%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80092e:	85 f6                	test   %esi,%esi
  800930:	74 29                	je     80095b <strncmp+0x3b>
  800932:	0f b6 03             	movzbl (%ebx),%eax
  800935:	84 c0                	test   %al,%al
  800937:	74 30                	je     800969 <strncmp+0x49>
  800939:	3a 02                	cmp    (%edx),%al
  80093b:	75 2c                	jne    800969 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80093d:	8d 43 01             	lea    0x1(%ebx),%eax
  800940:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800942:	89 c3                	mov    %eax,%ebx
  800944:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800947:	39 f0                	cmp    %esi,%eax
  800949:	74 17                	je     800962 <strncmp+0x42>
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	84 c9                	test   %cl,%cl
  800950:	74 17                	je     800969 <strncmp+0x49>
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	3a 0a                	cmp    (%edx),%cl
  800957:	74 e9                	je     800942 <strncmp+0x22>
  800959:	eb 0e                	jmp    800969 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
  800960:	eb 0f                	jmp    800971 <strncmp+0x51>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
  800967:	eb 08                	jmp    800971 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 03             	movzbl (%ebx),%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80097f:	0f b6 18             	movzbl (%eax),%ebx
  800982:	84 db                	test   %bl,%bl
  800984:	74 1d                	je     8009a3 <strchr+0x2e>
  800986:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800988:	38 d3                	cmp    %dl,%bl
  80098a:	75 06                	jne    800992 <strchr+0x1d>
  80098c:	eb 1a                	jmp    8009a8 <strchr+0x33>
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	74 16                	je     8009a8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f2                	jne    80098e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 05                	jmp    8009a8 <strchr+0x33>
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009b5:	0f b6 18             	movzbl (%eax),%ebx
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	74 16                	je     8009d2 <strfind+0x27>
  8009bc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009be:	38 d3                	cmp    %dl,%bl
  8009c0:	75 06                	jne    8009c8 <strfind+0x1d>
  8009c2:	eb 0e                	jmp    8009d2 <strfind+0x27>
  8009c4:	38 ca                	cmp    %cl,%dl
  8009c6:	74 0a                	je     8009d2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	84 d2                	test   %dl,%dl
  8009d0:	75 f2                	jne    8009c4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 0c             	sub    $0xc,%esp
  8009db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x49>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x49>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a2f:	89 ec                	mov    %ebp,%esp
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a48:	39 c6                	cmp    %eax,%esi
  800a4a:	73 36                	jae    800a82 <memmove+0x4f>
  800a4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	73 2f                	jae    800a82 <memmove+0x4f>
		s += n;
		d += n;
  800a53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f6 c2 03             	test   $0x3,%dl
  800a59:	75 1b                	jne    800a76 <memmove+0x43>
  800a5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a61:	75 13                	jne    800a76 <memmove+0x43>
  800a63:	f6 c1 03             	test   $0x3,%cl
  800a66:	75 0e                	jne    800a76 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a68:	83 ef 04             	sub    $0x4,%edi
  800a6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a71:	fd                   	std    
  800a72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a74:	eb 09                	jmp    800a7f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a76:	83 ef 01             	sub    $0x1,%edi
  800a79:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7f:	fc                   	cld    
  800a80:	eb 20                	jmp    800aa2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a88:	75 13                	jne    800a9d <memmove+0x6a>
  800a8a:	a8 03                	test   $0x3,%al
  800a8c:	75 0f                	jne    800a9d <memmove+0x6a>
  800a8e:	f6 c1 03             	test   $0x3,%cl
  800a91:	75 0a                	jne    800a9d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a93:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	fc                   	cld    
  800a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9b:	eb 05                	jmp    800aa2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9d:	89 c7                	mov    %eax,%edi
  800a9f:	fc                   	cld    
  800aa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aa8:	89 ec                	mov    %ebp,%esp
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 68 ff ff ff       	call   800a33 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	74 36                	je     800b19 <memcmp+0x4c>
		if (*s1 != *s2)
  800ae3:	0f b6 03             	movzbl (%ebx),%eax
  800ae6:	0f b6 0e             	movzbl (%esi),%ecx
  800ae9:	38 c8                	cmp    %cl,%al
  800aeb:	75 17                	jne    800b04 <memcmp+0x37>
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	eb 1a                	jmp    800b0e <memcmp+0x41>
  800af4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800af9:	83 c2 01             	add    $0x1,%edx
  800afc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b00:	38 c8                	cmp    %cl,%al
  800b02:	74 0a                	je     800b0e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b04:	0f b6 c0             	movzbl %al,%eax
  800b07:	0f b6 c9             	movzbl %cl,%ecx
  800b0a:	29 c8                	sub    %ecx,%eax
  800b0c:	eb 10                	jmp    800b1e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0e:	39 fa                	cmp    %edi,%edx
  800b10:	75 e2                	jne    800af4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	eb 05                	jmp    800b1e <memcmp+0x51>
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 13                	jae    800b49 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	89 d9                	mov    %ebx,%ecx
  800b38:	38 18                	cmp    %bl,(%eax)
  800b3a:	75 06                	jne    800b42 <memfind+0x1f>
  800b3c:	eb 0b                	jmp    800b49 <memfind+0x26>
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	74 07                	je     800b49 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 d0                	cmp    %edx,%eax
  800b47:	75 f5                	jne    800b3e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 04             	sub    $0x4,%esp
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	0f b6 02             	movzbl (%edx),%eax
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 04                	je     800b66 <strtol+0x1a>
  800b62:	3c 20                	cmp    $0x20,%al
  800b64:	75 0e                	jne    800b74 <strtol+0x28>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b69:	0f b6 02             	movzbl (%edx),%eax
  800b6c:	3c 09                	cmp    $0x9,%al
  800b6e:	74 f6                	je     800b66 <strtol+0x1a>
  800b70:	3c 20                	cmp    $0x20,%al
  800b72:	74 f2                	je     800b66 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b74:	3c 2b                	cmp    $0x2b,%al
  800b76:	75 0a                	jne    800b82 <strtol+0x36>
		s++;
  800b78:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b80:	eb 10                	jmp    800b92 <strtol+0x46>
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b87:	3c 2d                	cmp    $0x2d,%al
  800b89:	75 07                	jne    800b92 <strtol+0x46>
		s++, neg = 1;
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b98:	75 15                	jne    800baf <strtol+0x63>
  800b9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9d:	75 10                	jne    800baf <strtol+0x63>
  800b9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba3:	75 0a                	jne    800baf <strtol+0x63>
		s += 2, base = 16;
  800ba5:	83 c2 02             	add    $0x2,%edx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bad:	eb 10                	jmp    800bbf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	75 0c                	jne    800bbf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb5:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb8:	75 05                	jne    800bbf <strtol+0x73>
		s++, base = 8;
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc7:	0f b6 0a             	movzbl (%edx),%ecx
  800bca:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 09             	cmp    $0x9,%bl
  800bd2:	77 08                	ja     800bdc <strtol+0x90>
			dig = *s - '0';
  800bd4:	0f be c9             	movsbl %cl,%ecx
  800bd7:	83 e9 30             	sub    $0x30,%ecx
  800bda:	eb 22                	jmp    800bfe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bdc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xa2>
			dig = *s - 'a' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 57             	sub    $0x57,%ecx
  800bec:	eb 10                	jmp    800bfe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bee:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 16                	ja     800c0e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bf8:	0f be c9             	movsbl %cl,%ecx
  800bfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c01:	7d 0f                	jge    800c12 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c03:	83 c2 01             	add    $0x1,%edx
  800c06:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c0a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c0c:	eb b9                	jmp    800bc7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	89 c1                	mov    %eax,%ecx
  800c10:	eb 02                	jmp    800c14 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c12:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 05                	je     800c1f <strtol+0xd3>
		*endptr = (char *) s;
  800c1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c1f:	89 ca                	mov    %ecx,%edx
  800c21:	f7 da                	neg    %edx
  800c23:	85 ff                	test   %edi,%edi
  800c25:	0f 45 c2             	cmovne %edx,%eax
}
  800c28:	83 c4 04             	add    $0x4,%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 c3                	mov    %eax,%ebx
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	89 c6                	mov    %eax,%esi
  800c50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c5b:	89 ec                	mov    %ebp,%esp
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 01 00 00 00       	mov    $0x1,%eax
  800c78:	89 d1                	mov    %edx,%ecx
  800c7a:	89 d3                	mov    %edx,%ebx
  800c7c:	89 d7                	mov    %edx,%edi
  800c7e:	89 d6                	mov    %edx,%esi
  800c80:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8b:	89 ec                	mov    %ebp,%esp
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 38             	sub    $0x38,%esp
  800c95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	89 cb                	mov    %ecx,%ebx
  800cad:	89 cf                	mov    %ecx,%edi
  800caf:	89 ce                	mov    %ecx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800cda:	e8 d5 02 00 00       	call   800fb4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce8:	89 ec                	mov    %ebp,%esp
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 02 00 00 00       	mov    $0x2,%eax
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	89 d7                	mov    %edx,%edi
  800d0b:	89 d6                	mov    %edx,%esi
  800d0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_yield>:

void
sys_yield(void)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 38             	sub    $0x38,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	be 00 00 00 00       	mov    $0x0,%esi
  800d60:	b8 04 00 00 00       	mov    $0x4,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	89 f7                	mov    %esi,%edi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800d99:	e8 16 02 00 00       	call   800fb4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da7:	89 ec                	mov    %ebp,%esp
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 38             	sub    $0x38,%esp
  800db1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 28                	jle    800dfc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ddf:	00 
  800de0:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800de7:	00 
  800de8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800def:	00 
  800df0:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800df7:	e8 b8 01 00 00       	call   800fb4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dfc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e05:	89 ec                	mov    %ebp,%esp
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 38             	sub    $0x38,%esp
  800e0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 28                	jle    800e5a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e36:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800e45:	00 
  800e46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4d:	00 
  800e4e:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800e55:	e8 5a 01 00 00       	call   800fb4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e63:	89 ec                	mov    %ebp,%esp
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 38             	sub    $0x38,%esp
  800e6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e73:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	89 df                	mov    %ebx,%edi
  800e88:	89 de                	mov    %ebx,%esi
  800e8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	7e 28                	jle    800eb8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eab:	00 
  800eac:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800eb3:	e8 fc 00 00 00       	call   800fb4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec1:	89 ec                	mov    %ebp,%esp
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 38             	sub    $0x38,%esp
  800ecb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ece:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 28                	jle    800f16 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ef9:	00 
  800efa:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f01:	00 
  800f02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f09:	00 
  800f0a:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800f11:	e8 9e 00 00 00       	call   800fb4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1f:	89 ec                	mov    %ebp,%esp
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	be 00 00 00 00       	mov    $0x0,%esi
  800f37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f53:	89 ec                	mov    %ebp,%esp
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 38             	sub    $0x38,%esp
  800f5d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f60:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f63:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f70:	8b 55 08             	mov    0x8(%ebp),%edx
  800f73:	89 cb                	mov    %ecx,%ebx
  800f75:	89 cf                	mov    %ecx,%edi
  800f77:	89 ce                	mov    %ecx,%esi
  800f79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	7e 28                	jle    800fa7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f83:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f92:	00 
  800f93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9a:	00 
  800f9b:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800fa2:	e8 0d 00 00 00       	call   800fb4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800faa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb0:	89 ec                	mov    %ebp,%esp
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fbc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fbf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fc5:	e8 22 fd ff ff       	call   800cec <sys_getenvid>
  800fca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe0:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  800fe7:	e8 bb f1 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff3:	89 04 24             	mov    %eax,(%esp)
  800ff6:	e8 4b f1 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800ffb:	c7 04 24 14 16 80 00 	movl   $0x801614,(%esp)
  801002:	e8 a0 f1 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801007:	cc                   	int3   
  801008:	eb fd                	jmp    801007 <_panic+0x53>
  80100a:	00 00                	add    %al,(%eax)
  80100c:	00 00                	add    %al,(%eax)
	...

00801010 <__udivdi3>:
  801010:	83 ec 1c             	sub    $0x1c,%esp
  801013:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801017:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80101b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80101f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801023:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801027:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801031:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801035:	89 ea                	mov    %ebp,%edx
  801037:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80103b:	75 33                	jne    801070 <__udivdi3+0x60>
  80103d:	39 e9                	cmp    %ebp,%ecx
  80103f:	77 6f                	ja     8010b0 <__udivdi3+0xa0>
  801041:	85 c9                	test   %ecx,%ecx
  801043:	89 ce                	mov    %ecx,%esi
  801045:	75 0b                	jne    801052 <__udivdi3+0x42>
  801047:	b8 01 00 00 00       	mov    $0x1,%eax
  80104c:	31 d2                	xor    %edx,%edx
  80104e:	f7 f1                	div    %ecx
  801050:	89 c6                	mov    %eax,%esi
  801052:	31 d2                	xor    %edx,%edx
  801054:	89 e8                	mov    %ebp,%eax
  801056:	f7 f6                	div    %esi
  801058:	89 c5                	mov    %eax,%ebp
  80105a:	89 f8                	mov    %edi,%eax
  80105c:	f7 f6                	div    %esi
  80105e:	89 ea                	mov    %ebp,%edx
  801060:	8b 74 24 10          	mov    0x10(%esp),%esi
  801064:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801068:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80106c:	83 c4 1c             	add    $0x1c,%esp
  80106f:	c3                   	ret    
  801070:	39 e8                	cmp    %ebp,%eax
  801072:	77 24                	ja     801098 <__udivdi3+0x88>
  801074:	0f bd c8             	bsr    %eax,%ecx
  801077:	83 f1 1f             	xor    $0x1f,%ecx
  80107a:	89 0c 24             	mov    %ecx,(%esp)
  80107d:	75 49                	jne    8010c8 <__udivdi3+0xb8>
  80107f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801083:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801087:	0f 86 ab 00 00 00    	jbe    801138 <__udivdi3+0x128>
  80108d:	39 e8                	cmp    %ebp,%eax
  80108f:	0f 82 a3 00 00 00    	jb     801138 <__udivdi3+0x128>
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	31 d2                	xor    %edx,%edx
  80109a:	31 c0                	xor    %eax,%eax
  80109c:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010a8:	83 c4 1c             	add    $0x1c,%esp
  8010ab:	c3                   	ret    
  8010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	89 f8                	mov    %edi,%eax
  8010b2:	f7 f1                	div    %ecx
  8010b4:	31 d2                	xor    %edx,%edx
  8010b6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ba:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010be:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c2:	83 c4 1c             	add    $0x1c,%esp
  8010c5:	c3                   	ret    
  8010c6:	66 90                	xchg   %ax,%ax
  8010c8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010cc:	89 c6                	mov    %eax,%esi
  8010ce:	b8 20 00 00 00       	mov    $0x20,%eax
  8010d3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8010d7:	2b 04 24             	sub    (%esp),%eax
  8010da:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010de:	d3 e6                	shl    %cl,%esi
  8010e0:	89 c1                	mov    %eax,%ecx
  8010e2:	d3 ed                	shr    %cl,%ebp
  8010e4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010e8:	09 f5                	or     %esi,%ebp
  8010ea:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010ee:	d3 e6                	shl    %cl,%esi
  8010f0:	89 c1                	mov    %eax,%ecx
  8010f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f6:	89 d6                	mov    %edx,%esi
  8010f8:	d3 ee                	shr    %cl,%esi
  8010fa:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010fe:	d3 e2                	shl    %cl,%edx
  801100:	89 c1                	mov    %eax,%ecx
  801102:	d3 ef                	shr    %cl,%edi
  801104:	09 d7                	or     %edx,%edi
  801106:	89 f2                	mov    %esi,%edx
  801108:	89 f8                	mov    %edi,%eax
  80110a:	f7 f5                	div    %ebp
  80110c:	89 d6                	mov    %edx,%esi
  80110e:	89 c7                	mov    %eax,%edi
  801110:	f7 64 24 04          	mull   0x4(%esp)
  801114:	39 d6                	cmp    %edx,%esi
  801116:	72 30                	jb     801148 <__udivdi3+0x138>
  801118:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80111c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801120:	d3 e5                	shl    %cl,%ebp
  801122:	39 c5                	cmp    %eax,%ebp
  801124:	73 04                	jae    80112a <__udivdi3+0x11a>
  801126:	39 d6                	cmp    %edx,%esi
  801128:	74 1e                	je     801148 <__udivdi3+0x138>
  80112a:	89 f8                	mov    %edi,%eax
  80112c:	31 d2                	xor    %edx,%edx
  80112e:	e9 69 ff ff ff       	jmp    80109c <__udivdi3+0x8c>
  801133:	90                   	nop
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	31 d2                	xor    %edx,%edx
  80113a:	b8 01 00 00 00       	mov    $0x1,%eax
  80113f:	e9 58 ff ff ff       	jmp    80109c <__udivdi3+0x8c>
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	8d 47 ff             	lea    -0x1(%edi),%eax
  80114b:	31 d2                	xor    %edx,%edx
  80114d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801151:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801155:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801159:	83 c4 1c             	add    $0x1c,%esp
  80115c:	c3                   	ret    
  80115d:	00 00                	add    %al,(%eax)
	...

00801160 <__umoddi3>:
  801160:	83 ec 2c             	sub    $0x2c,%esp
  801163:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801167:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80116b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80116f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801173:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801177:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80117b:	85 c0                	test   %eax,%eax
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801183:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801187:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80118f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801193:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801197:	75 1f                	jne    8011b8 <__umoddi3+0x58>
  801199:	39 fe                	cmp    %edi,%esi
  80119b:	76 63                	jbe    801200 <__umoddi3+0xa0>
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	89 fa                	mov    %edi,%edx
  8011a1:	f7 f6                	div    %esi
  8011a3:	89 d0                	mov    %edx,%eax
  8011a5:	31 d2                	xor    %edx,%edx
  8011a7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011ab:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011af:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011b3:	83 c4 2c             	add    $0x2c,%esp
  8011b6:	c3                   	ret    
  8011b7:	90                   	nop
  8011b8:	39 f8                	cmp    %edi,%eax
  8011ba:	77 64                	ja     801220 <__umoddi3+0xc0>
  8011bc:	0f bd e8             	bsr    %eax,%ebp
  8011bf:	83 f5 1f             	xor    $0x1f,%ebp
  8011c2:	75 74                	jne    801238 <__umoddi3+0xd8>
  8011c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8011cc:	0f 87 0e 01 00 00    	ja     8012e0 <__umoddi3+0x180>
  8011d2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8011d6:	29 f1                	sub    %esi,%ecx
  8011d8:	19 c7                	sbb    %eax,%edi
  8011da:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011de:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8011e2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8011e6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8011ea:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011f2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011f6:	83 c4 2c             	add    $0x2c,%esp
  8011f9:	c3                   	ret    
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	85 f6                	test   %esi,%esi
  801202:	89 f5                	mov    %esi,%ebp
  801204:	75 0b                	jne    801211 <__umoddi3+0xb1>
  801206:	b8 01 00 00 00       	mov    $0x1,%eax
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	f7 f6                	div    %esi
  80120f:	89 c5                	mov    %eax,%ebp
  801211:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801215:	31 d2                	xor    %edx,%edx
  801217:	f7 f5                	div    %ebp
  801219:	89 c8                	mov    %ecx,%eax
  80121b:	f7 f5                	div    %ebp
  80121d:	eb 84                	jmp    8011a3 <__umoddi3+0x43>
  80121f:	90                   	nop
  801220:	89 c8                	mov    %ecx,%eax
  801222:	89 fa                	mov    %edi,%edx
  801224:	8b 74 24 20          	mov    0x20(%esp),%esi
  801228:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80122c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801230:	83 c4 2c             	add    $0x2c,%esp
  801233:	c3                   	ret    
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	8b 44 24 10          	mov    0x10(%esp),%eax
  80123c:	be 20 00 00 00       	mov    $0x20,%esi
  801241:	89 e9                	mov    %ebp,%ecx
  801243:	29 ee                	sub    %ebp,%esi
  801245:	d3 e2                	shl    %cl,%edx
  801247:	89 f1                	mov    %esi,%ecx
  801249:	d3 e8                	shr    %cl,%eax
  80124b:	89 e9                	mov    %ebp,%ecx
  80124d:	09 d0                	or     %edx,%eax
  80124f:	89 fa                	mov    %edi,%edx
  801251:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801255:	8b 44 24 10          	mov    0x10(%esp),%eax
  801259:	d3 e0                	shl    %cl,%eax
  80125b:	89 f1                	mov    %esi,%ecx
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801265:	d3 ea                	shr    %cl,%edx
  801267:	89 e9                	mov    %ebp,%ecx
  801269:	d3 e7                	shl    %cl,%edi
  80126b:	89 f1                	mov    %esi,%ecx
  80126d:	d3 e8                	shr    %cl,%eax
  80126f:	89 e9                	mov    %ebp,%ecx
  801271:	09 f8                	or     %edi,%eax
  801273:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801277:	f7 74 24 0c          	divl   0xc(%esp)
  80127b:	d3 e7                	shl    %cl,%edi
  80127d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801281:	89 d7                	mov    %edx,%edi
  801283:	f7 64 24 10          	mull   0x10(%esp)
  801287:	39 d7                	cmp    %edx,%edi
  801289:	89 c1                	mov    %eax,%ecx
  80128b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80128f:	72 3b                	jb     8012cc <__umoddi3+0x16c>
  801291:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801295:	72 31                	jb     8012c8 <__umoddi3+0x168>
  801297:	8b 44 24 18          	mov    0x18(%esp),%eax
  80129b:	29 c8                	sub    %ecx,%eax
  80129d:	19 d7                	sbb    %edx,%edi
  80129f:	89 e9                	mov    %ebp,%ecx
  8012a1:	89 fa                	mov    %edi,%edx
  8012a3:	d3 e8                	shr    %cl,%eax
  8012a5:	89 f1                	mov    %esi,%ecx
  8012a7:	d3 e2                	shl    %cl,%edx
  8012a9:	89 e9                	mov    %ebp,%ecx
  8012ab:	09 d0                	or     %edx,%eax
  8012ad:	89 fa                	mov    %edi,%edx
  8012af:	d3 ea                	shr    %cl,%edx
  8012b1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012b5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012b9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012bd:	83 c4 2c             	add    $0x2c,%esp
  8012c0:	c3                   	ret    
  8012c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	39 d7                	cmp    %edx,%edi
  8012ca:	75 cb                	jne    801297 <__umoddi3+0x137>
  8012cc:	8b 54 24 14          	mov    0x14(%esp),%edx
  8012d0:	89 c1                	mov    %eax,%ecx
  8012d2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8012d6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8012da:	eb bb                	jmp    801297 <__umoddi3+0x137>
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8012e4:	0f 82 e8 fe ff ff    	jb     8011d2 <__umoddi3+0x72>
  8012ea:	e9 f3 fe ff ff       	jmp    8011e2 <__umoddi3+0x82>
