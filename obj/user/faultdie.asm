
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  800060:	e8 36 01 00 00       	call   80019b <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 72 0c 00 00       	call   800cdc <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 0d 0c 00 00       	call   800c7f <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 1e 0f 00 00       	call   800fa4 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000a6:	e8 31 0c 00 00       	call   800cdc <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 db                	test   %ebx,%ebx
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 06                	mov    (%esi),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000cc:	89 1c 24             	mov    %ebx,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 89 0b 00 00       	call   800c7f <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	83 c0 01             	add    $0x1,%eax
  80010e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	75 19                	jne    800130 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800117:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011e:	00 
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 f6 0a 00 00       	call   800c20 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	83 c4 14             	add    $0x14,%esp
  800137:	5b                   	pop    %ebx
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800176:	e8 b7 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 8d 0a 00 00       	call   800c20 <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 87 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001da:	b8 00 00 00 00       	mov    $0x0,%eax
  8001df:	39 d8                	cmp    %ebx,%eax
  8001e1:	72 17                	jb     8001fa <printnum+0x3a>
  8001e3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001e6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001e9:	76 0f                	jbe    8001fa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001eb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001ee:	83 ee 01             	sub    $0x1,%esi
  8001f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001f4:	85 f6                	test   %esi,%esi
  8001f6:	7f 63                	jg     80025b <printnum+0x9b>
  8001f8:	eb 75                	jmp    80026f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001fd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800201:	8b 45 14             	mov    0x14(%ebp),%eax
  800204:	83 e8 01             	sub    $0x1,%eax
  800207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800212:	8b 44 24 08          	mov    0x8(%esp),%eax
  800216:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80021a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800235:	e8 06 0e 00 00       	call   801040 <__udivdi3>
  80023a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80023d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800240:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800244:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024f:	89 fa                	mov    %edi,%edx
  800251:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800254:	e8 67 ff ff ff       	call   8001c0 <printnum>
  800259:	eb 14                	jmp    80026f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025f:	8b 45 18             	mov    0x18(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800267:	83 ee 01             	sub    $0x1,%esi
  80026a:	75 ef                	jne    80025b <printnum+0x9b>
  80026c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800273:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800285:	00 
  800286:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800289:	89 1c 24             	mov    %ebx,(%esp)
  80028c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80028f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800293:	e8 f8 0e 00 00       	call   801190 <__umoddi3>
  800298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029c:	0f be 80 46 13 80 00 	movsbl 0x801346(%eax),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002a9:	ff d0                	call   *%eax
}
  8002ab:	83 c4 4c             	add    $0x4c,%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b6:	83 fa 01             	cmp    $0x1,%edx
  8002b9:	7e 0e                	jle    8002c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	8b 52 04             	mov    0x4(%edx),%edx
  8002c7:	eb 22                	jmp    8002eb <getuint+0x38>
	else if (lflag)
  8002c9:	85 d2                	test   %edx,%edx
  8002cb:	74 10                	je     8002dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 02                	mov    (%edx),%eax
  8002d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002db:	eb 0e                	jmp    8002eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fc:	73 0a                	jae    800308 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800301:	88 0a                	mov    %cl,(%edx)
  800303:	83 c2 01             	add    $0x1,%edx
  800306:	89 10                	mov    %edx,(%eax)
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800313:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800317:	8b 45 10             	mov    0x10(%ebp),%eax
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	e8 02 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 4c             	sub    $0x4c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 11                	jmp    800357 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 db 03 00 00    	je     800729 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80034e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800357:	0f b6 07             	movzbl (%edi),%eax
  80035a:	83 c7 01             	add    $0x1,%edi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e4                	jne    800346 <vprintfmt+0x14>
  800362:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800366:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80036d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800374:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 2b                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800385:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800389:	eb 22                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800392:	eb 19                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800397:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039e:	eb 0d                	jmp    8003ad <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	0f b6 0f             	movzbl (%edi),%ecx
  8003b0:	8d 47 01             	lea    0x1(%edi),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	0f b6 07             	movzbl (%edi),%eax
  8003b9:	83 e8 23             	sub    $0x23,%eax
  8003bc:	3c 55                	cmp    $0x55,%al
  8003be:	0f 87 40 03 00 00    	ja     800704 <vprintfmt+0x3d2>
  8003c4:	0f b6 c0             	movzbl %al,%eax
  8003c7:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ce:	83 e9 30             	sub    $0x30,%ecx
  8003d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003d4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003db:	83 f9 09             	cmp    $0x9,%ecx
  8003de:	77 57                	ja     800437 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ec:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ef:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003f3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003f6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003f9:	83 f9 09             	cmp    $0x9,%ecx
  8003fc:	76 eb                	jbe    8003e9 <vprintfmt+0xb7>
  8003fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800401:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800404:	eb 34                	jmp    80043a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 48 04             	lea    0x4(%eax),%ecx
  80040c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800417:	eb 21                	jmp    80043a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800419:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041d:	0f 88 71 ff ff ff    	js     800394 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800426:	eb 85                	jmp    8003ad <vprintfmt+0x7b>
  800428:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800432:	e9 76 ff ff ff       	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80043a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043e:	0f 89 69 ff ff ff    	jns    8003ad <vprintfmt+0x7b>
  800444:	e9 57 ff ff ff       	jmp    8003a0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800449:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044f:	e9 59 ff ff ff       	jmp    8003ad <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	8b 00                	mov    (%eax),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046b:	e9 e7 fe ff ff       	jmp    800357 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	c1 fa 1f             	sar    $0x1f,%edx
  800480:	31 d0                	xor    %edx,%eax
  800482:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800484:	83 f8 08             	cmp    $0x8,%eax
  800487:	7f 0b                	jg     800494 <vprintfmt+0x162>
  800489:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800490:	85 d2                	test   %edx,%edx
  800492:	75 20                	jne    8004b4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800494:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800498:	c7 44 24 08 5e 13 80 	movl   $0x80135e,0x8(%esp)
  80049f:	00 
  8004a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a4:	89 34 24             	mov    %esi,(%esp)
  8004a7:	e8 5e fe ff ff       	call   80030a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004af:	e9 a3 fe ff ff       	jmp    800357 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b8:	c7 44 24 08 67 13 80 	movl   $0x801367,0x8(%esp)
  8004bf:	00 
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	89 34 24             	mov    %esi,(%esp)
  8004c7:	e8 3e fe ff ff       	call   80030a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004cf:	e9 83 fe ff ff       	jmp    800357 <vprintfmt+0x25>
  8004d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004da:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	b8 57 13 80 00       	mov    $0x801357,%eax
  8004ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004f6:	74 06                	je     8004fe <vprintfmt+0x1cc>
  8004f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004fc:	7f 16                	jg     800514 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	0f b6 17             	movzbl (%edi),%edx
  800501:	0f be c2             	movsbl %dl,%eax
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	85 c0                	test   %eax,%eax
  800509:	0f 85 9f 00 00 00    	jne    8005ae <vprintfmt+0x27c>
  80050f:	e9 8b 00 00 00       	jmp    80059f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800518:	89 3c 24             	mov    %edi,(%esp)
  80051b:	e8 c2 02 00 00       	call   8007e2 <strnlen>
  800520:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800523:	29 c2                	sub    %eax,%edx
  800525:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800528:	85 d2                	test   %edx,%edx
  80052a:	7e d2                	jle    8004fe <vprintfmt+0x1cc>
					putch(padc, putdat);
  80052c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800530:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800533:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800536:	89 d7                	mov    %edx,%edi
  800538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	83 ef 01             	sub    $0x1,%edi
  800547:	75 ef                	jne    800538 <vprintfmt+0x206>
  800549:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80054c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80054f:	eb ad                	jmp    8004fe <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800555:	74 20                	je     800577 <vprintfmt+0x245>
  800557:	0f be d2             	movsbl %dl,%edx
  80055a:	83 ea 20             	sub    $0x20,%edx
  80055d:	83 fa 5e             	cmp    $0x5e,%edx
  800560:	76 15                	jbe    800577 <vprintfmt+0x245>
					putch('?', putdat);
  800562:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800570:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800573:	ff d1                	call   *%ecx
  800575:	eb 0f                	jmp    800586 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80057e:	89 04 24             	mov    %eax,(%esp)
  800581:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800584:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	0f b6 17             	movzbl (%edi),%edx
  80058c:	0f be c2             	movsbl %dl,%eax
  80058f:	83 c7 01             	add    $0x1,%edi
  800592:	85 c0                	test   %eax,%eax
  800594:	75 24                	jne    8005ba <vprintfmt+0x288>
  800596:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800599:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80059c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a6:	0f 8e ab fd ff ff    	jle    800357 <vprintfmt+0x25>
  8005ac:	eb 20                	jmp    8005ce <vprintfmt+0x29c>
  8005ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005b1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005b7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	78 93                	js     800551 <vprintfmt+0x21f>
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	79 8e                	jns    800551 <vprintfmt+0x21f>
  8005c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005c9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005cc:	eb d1                	jmp    80059f <vprintfmt+0x26d>
  8005ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 ef 01             	sub    $0x1,%edi
  8005e1:	75 ee                	jne    8005d1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e6:	e9 6c fd ff ff       	jmp    800357 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005eb:	83 fa 01             	cmp    $0x1,%edx
  8005ee:	66 90                	xchg   %ax,%ax
  8005f0:	7e 16                	jle    800608 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800603:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800606:	eb 32                	jmp    80063a <vprintfmt+0x308>
	else if (lflag)
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 18                	je     800624 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800622:	eb 16                	jmp    80063a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800632:	89 c7                	mov    %eax,%edi
  800634:	c1 ff 1f             	sar    $0x1f,%edi
  800637:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800645:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800649:	79 7d                	jns    8006c8 <vprintfmt+0x396>
				putch('-', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800656:	ff d6                	call   *%esi
				num = -(long long) num;
  800658:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80065b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80065e:	f7 d8                	neg    %eax
  800660:	83 d2 00             	adc    $0x0,%edx
  800663:	f7 da                	neg    %edx
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066a:	eb 5c                	jmp    8006c8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 3f fc ff ff       	call   8002b3 <getuint>
			base = 10;
  800674:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800679:	eb 4d                	jmp    8006c8 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 30 fc ff ff       	call   8002b3 <getuint>
      base = 8;
  800683:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800688:	eb 3e                	jmp    8006c8 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff d6                	call   *%esi
			putch('x', putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 f0 fb ff ff       	call   8002b3 <getuint>
			base = 16;
  8006c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006cc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006d0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006d3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e2:	89 da                	mov    %ebx,%edx
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	e8 d5 fa ff ff       	call   8001c0 <printnum>
			break;
  8006eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ee:	e9 64 fc ff ff       	jmp    800357 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	89 0c 24             	mov    %ecx,(%esp)
  8006fa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ff:	e9 53 fc ff ff       	jmp    800357 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800711:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800715:	0f 84 3c fc ff ff    	je     800357 <vprintfmt+0x25>
  80071b:	83 ef 01             	sub    $0x1,%edi
  80071e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800722:	75 f7                	jne    80071b <vprintfmt+0x3e9>
  800724:	e9 2e fc ff ff       	jmp    800357 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800729:	83 c4 4c             	add    $0x4c,%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 28             	sub    $0x28,%esp
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800740:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800744:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 30                	jle    800782 <vsnprintf+0x51>
  800752:	85 c0                	test   %eax,%eax
  800754:	74 2c                	je     800782 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075d:	8b 45 10             	mov    0x10(%ebp),%eax
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 ed 02 80 00 	movl   $0x8002ed,(%esp)
  800772:	e8 bb fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800777:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800780:	eb 05                	jmp    800787 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 82 ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c9:	74 10                	je     8007db <strlen+0x1b>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
  8007d9:	eb 05                	jmp    8007e0 <strlen+0x20>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	74 1c                	je     80080c <strnlen+0x2a>
  8007f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f3:	74 1e                	je     800813 <strnlen+0x31>
  8007f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007fa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 ca                	cmp    %ecx,%edx
  8007fe:	74 18                	je     800818 <strnlen+0x36>
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800808:	75 f0                	jne    8007fa <strnlen+0x18>
  80080a:	eb 0c                	jmp    800818 <strnlen+0x36>
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strnlen+0x36>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	0f b6 19             	movzbl (%ecx),%ebx
  80082a:	88 1a                	mov    %bl,(%edx)
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	84 db                	test   %bl,%bl
  800834:	75 f1                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800836:	5b                   	pop    %ebx
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800843:	89 1c 24             	mov    %ebx,(%esp)
  800846:	e8 75 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800852:	01 d8                	add    %ebx,%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 bf ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085c:	89 d8                	mov    %ebx,%eax
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800872:	85 db                	test   %ebx,%ebx
  800874:	74 16                	je     80088c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	01 f3                	add    %esi,%ebx
  800878:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80087a:	0f b6 02             	movzbl (%edx),%eax
  80087d:	88 01                	mov    %al,(%ecx)
  80087f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800882:	80 3a 01             	cmpb   $0x1,(%edx)
  800885:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	39 d9                	cmp    %ebx,%ecx
  80088a:	75 ee                	jne    80087a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80089e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	85 f6                	test   %esi,%esi
  8008a5:	74 33                	je     8008da <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008a7:	83 fe 01             	cmp    $0x1,%esi
  8008aa:	74 25                	je     8008d1 <strlcpy+0x3f>
  8008ac:	0f b6 0b             	movzbl (%ebx),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 22                	je     8008d5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008b3:	83 ee 02             	sub    $0x2,%esi
  8008b6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bb:	88 08                	mov    %cl,(%eax)
  8008bd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c0:	39 f2                	cmp    %esi,%edx
  8008c2:	74 13                	je     8008d7 <strlcpy+0x45>
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008cb:	84 c9                	test   %cl,%cl
  8008cd:	75 ec                	jne    8008bb <strlcpy+0x29>
  8008cf:	eb 06                	jmp    8008d7 <strlcpy+0x45>
  8008d1:	89 f8                	mov    %edi,%eax
  8008d3:	eb 02                	jmp    8008d7 <strlcpy+0x45>
  8008d5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f8                	sub    %edi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ea:	0f b6 01             	movzbl (%ecx),%eax
  8008ed:	84 c0                	test   %al,%al
  8008ef:	74 15                	je     800906 <strcmp+0x25>
  8008f1:	3a 02                	cmp    (%edx),%al
  8008f3:	75 11                	jne    800906 <strcmp+0x25>
		p++, q++;
  8008f5:	83 c1 01             	add    $0x1,%ecx
  8008f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	84 c0                	test   %al,%al
  800900:	74 04                	je     800906 <strcmp+0x25>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	74 ef                	je     8008f5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80091e:	85 f6                	test   %esi,%esi
  800920:	74 29                	je     80094b <strncmp+0x3b>
  800922:	0f b6 03             	movzbl (%ebx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 30                	je     800959 <strncmp+0x49>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	75 2c                	jne    800959 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80092d:	8d 43 01             	lea    0x1(%ebx),%eax
  800930:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800932:	89 c3                	mov    %eax,%ebx
  800934:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800937:	39 f0                	cmp    %esi,%eax
  800939:	74 17                	je     800952 <strncmp+0x42>
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	84 c9                	test   %cl,%cl
  800940:	74 17                	je     800959 <strncmp+0x49>
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	3a 0a                	cmp    (%edx),%cl
  800947:	74 e9                	je     800932 <strncmp+0x22>
  800949:	eb 0e                	jmp    800959 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb 0f                	jmp    800961 <strncmp+0x51>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb 08                	jmp    800961 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 03             	movzbl (%ebx),%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80096f:	0f b6 18             	movzbl (%eax),%ebx
  800972:	84 db                	test   %bl,%bl
  800974:	74 1d                	je     800993 <strchr+0x2e>
  800976:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800978:	38 d3                	cmp    %dl,%bl
  80097a:	75 06                	jne    800982 <strchr+0x1d>
  80097c:	eb 1a                	jmp    800998 <strchr+0x33>
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 16                	je     800998 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	75 f2                	jne    80097e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	eb 05                	jmp    800998 <strchr+0x33>
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009a5:	0f b6 18             	movzbl (%eax),%ebx
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	74 16                	je     8009c2 <strfind+0x27>
  8009ac:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009ae:	38 d3                	cmp    %dl,%bl
  8009b0:	75 06                	jne    8009b8 <strfind+0x1d>
  8009b2:	eb 0e                	jmp    8009c2 <strfind+0x27>
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 0a                	je     8009c2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	75 f2                	jne    8009b4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 0c             	sub    $0xc,%esp
  8009cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	74 36                	je     800a14 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009de:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e4:	75 28                	jne    800a0e <memset+0x49>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 23                	jne    800a0e <memset+0x49>
		c &= 0xFF;
  8009eb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ef:	89 d3                	mov    %edx,%ebx
  8009f1:	c1 e3 08             	shl    $0x8,%ebx
  8009f4:	89 d6                	mov    %edx,%esi
  8009f6:	c1 e6 18             	shl    $0x18,%esi
  8009f9:	89 d0                	mov    %edx,%eax
  8009fb:	c1 e0 10             	shl    $0x10,%eax
  8009fe:	09 f0                	or     %esi,%eax
  800a00:	09 c2                	or     %eax,%edx
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a09:	fc                   	cld    
  800a0a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0c:	eb 06                	jmp    800a14 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	fc                   	cld    
  800a12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a1f:	89 ec                	mov    %ebp,%esp
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	83 ec 08             	sub    $0x8,%esp
  800a29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 36                	jae    800a72 <memmove+0x4f>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 2f                	jae    800a72 <memmove+0x4f>
		s += n;
		d += n;
  800a43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	f6 c2 03             	test   $0x3,%dl
  800a49:	75 1b                	jne    800a66 <memmove+0x43>
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 13                	jne    800a66 <memmove+0x43>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 20                	jmp    800a92 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x6a>
  800a7a:	a8 03                	test   $0x3,%al
  800a7c:	75 0f                	jne    800a8d <memmove+0x6a>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 0a                	jne    800a8d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 05                	jmp    800a92 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a98:	89 ec                	mov    %ebp,%esp
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 68 ff ff ff       	call   800a23 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	74 36                	je     800b09 <memcmp+0x4c>
		if (*s1 != *s2)
  800ad3:	0f b6 03             	movzbl (%ebx),%eax
  800ad6:	0f b6 0e             	movzbl (%esi),%ecx
  800ad9:	38 c8                	cmp    %cl,%al
  800adb:	75 17                	jne    800af4 <memcmp+0x37>
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	eb 1a                	jmp    800afe <memcmp+0x41>
  800ae4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800af0:	38 c8                	cmp    %cl,%al
  800af2:	74 0a                	je     800afe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800af4:	0f b6 c0             	movzbl %al,%eax
  800af7:	0f b6 c9             	movzbl %cl,%ecx
  800afa:	29 c8                	sub    %ecx,%eax
  800afc:	eb 10                	jmp    800b0e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	39 fa                	cmp    %edi,%edx
  800b00:	75 e2                	jne    800ae4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	eb 05                	jmp    800b0e <memcmp+0x51>
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 13                	jae    800b39 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	89 d9                	mov    %ebx,%ecx
  800b28:	38 18                	cmp    %bl,(%eax)
  800b2a:	75 06                	jne    800b32 <memfind+0x1f>
  800b2c:	eb 0b                	jmp    800b39 <memfind+0x26>
  800b2e:	38 08                	cmp    %cl,(%eax)
  800b30:	74 07                	je     800b39 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	39 d0                	cmp    %edx,%eax
  800b37:	75 f5                	jne    800b2e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 04             	sub    $0x4,%esp
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4b:	0f b6 02             	movzbl (%edx),%eax
  800b4e:	3c 09                	cmp    $0x9,%al
  800b50:	74 04                	je     800b56 <strtol+0x1a>
  800b52:	3c 20                	cmp    $0x20,%al
  800b54:	75 0e                	jne    800b64 <strtol+0x28>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b59:	0f b6 02             	movzbl (%edx),%eax
  800b5c:	3c 09                	cmp    $0x9,%al
  800b5e:	74 f6                	je     800b56 <strtol+0x1a>
  800b60:	3c 20                	cmp    $0x20,%al
  800b62:	74 f2                	je     800b56 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b64:	3c 2b                	cmp    $0x2b,%al
  800b66:	75 0a                	jne    800b72 <strtol+0x36>
		s++;
  800b68:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b70:	eb 10                	jmp    800b82 <strtol+0x46>
  800b72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b77:	3c 2d                	cmp    $0x2d,%al
  800b79:	75 07                	jne    800b82 <strtol+0x46>
		s++, neg = 1;
  800b7b:	83 c2 01             	add    $0x1,%edx
  800b7e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b88:	75 15                	jne    800b9f <strtol+0x63>
  800b8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8d:	75 10                	jne    800b9f <strtol+0x63>
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	75 0a                	jne    800b9f <strtol+0x63>
		s += 2, base = 16;
  800b95:	83 c2 02             	add    $0x2,%edx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 10                	jmp    800baf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 0c                	jne    800baf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba5:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba8:	75 05                	jne    800baf <strtol+0x73>
		s++, base = 8;
  800baa:	83 c2 01             	add    $0x1,%edx
  800bad:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb7:	0f b6 0a             	movzbl (%edx),%ecx
  800bba:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 09             	cmp    $0x9,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0x90>
			dig = *s - '0';
  800bc4:	0f be c9             	movsbl %cl,%ecx
  800bc7:	83 e9 30             	sub    $0x30,%ecx
  800bca:	eb 22                	jmp    800bee <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bcc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 57             	sub    $0x57,%ecx
  800bdc:	eb 10                	jmp    800bee <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800be1:	89 f3                	mov    %esi,%ebx
  800be3:	80 fb 19             	cmp    $0x19,%bl
  800be6:	77 16                	ja     800bfe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800be8:	0f be c9             	movsbl %cl,%ecx
  800beb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bee:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bf1:	7d 0f                	jge    800c02 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bfa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bfc:	eb b9                	jmp    800bb7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	89 c1                	mov    %eax,%ecx
  800c00:	eb 02                	jmp    800c04 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c02:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c08:	74 05                	je     800c0f <strtol+0xd3>
		*endptr = (char *) s;
  800c0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c0d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c0f:	89 ca                	mov    %ecx,%edx
  800c11:	f7 da                	neg    %edx
  800c13:	85 ff                	test   %edi,%edi
  800c15:	0f 45 c2             	cmovne %edx,%eax
}
  800c18:	83 c4 04             	add    $0x4,%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 c3                	mov    %eax,%ebx
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	89 c6                	mov    %eax,%esi
  800c40:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4b:	89 ec                	mov    %ebp,%esp
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	b8 01 00 00 00       	mov    $0x1,%eax
  800c68:	89 d1                	mov    %edx,%ecx
  800c6a:	89 d3                	mov    %edx,%ebx
  800c6c:	89 d7                	mov    %edx,%edi
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c7b:	89 ec                	mov    %ebp,%esp
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 38             	sub    $0x38,%esp
  800c85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c93:	b8 03 00 00 00       	mov    $0x3,%eax
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 cb                	mov    %ecx,%ebx
  800c9d:	89 cf                	mov    %ecx,%edi
  800c9f:	89 ce                	mov    %ecx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800cca:	e8 0d 03 00 00       	call   800fdc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ccf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd8:	89 ec                	mov    %ebp,%esp
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d08:	89 ec                	mov    %ebp,%esp
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_yield>:

void
sys_yield(void)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 38             	sub    $0x38,%esp
  800d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	b8 04 00 00 00       	mov    $0x4,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	89 f7                	mov    %esi,%edi
  800d60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 28                	jle    800d8e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d71:	00 
  800d72:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d79:	00 
  800d7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d81:	00 
  800d82:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d89:	e8 4e 02 00 00       	call   800fdc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d8e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d91:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d94:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 38             	sub    $0x38,%esp
  800da1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800de7:	e8 f0 01 00 00       	call   800fdc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dec:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800def:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df5:	89 ec                	mov    %ebp,%esp
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 38             	sub    $0x38,%esp
  800dff:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e05:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 df                	mov    %ebx,%edi
  800e1a:	89 de                	mov    %ebx,%esi
  800e1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	7e 28                	jle    800e4a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e26:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e2d:	00 
  800e2e:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e35:	00 
  800e36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3d:	00 
  800e3e:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e45:	e8 92 01 00 00       	call   800fdc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e53:	89 ec                	mov    %ebp,%esp
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 38             	sub    $0x38,%esp
  800e5d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e60:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e63:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ea3:	e8 34 01 00 00       	call   800fdc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb1:	89 ec                	mov    %ebp,%esp
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 38             	sub    $0x38,%esp
  800ebb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ebe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	89 df                	mov    %ebx,%edi
  800ed6:	89 de                	mov    %ebx,%esi
  800ed8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eda:	85 c0                	test   %eax,%eax
  800edc:	7e 28                	jle    800f06 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ede:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef9:	00 
  800efa:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f01:	e8 d6 00 00 00       	call   800fdc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f09:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0f:	89 ec                	mov    %ebp,%esp
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f1c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	be 00 00 00 00       	mov    $0x0,%esi
  800f27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f43:	89 ec                	mov    %ebp,%esp
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 38             	sub    $0x38,%esp
  800f4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	89 cb                	mov    %ecx,%ebx
  800f65:	89 cf                	mov    %ecx,%edi
  800f67:	89 ce                	mov    %ecx,%esi
  800f69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 28                	jle    800f97 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f73:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f92:	e8 45 00 00 00       	call   800fdc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa0:	89 ec                	mov    %ebp,%esp
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800faa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fb1:	75 1c                	jne    800fcf <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800fb3:	c7 44 24 08 b0 15 80 	movl   $0x8015b0,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  800fca:	e8 0d 00 00 00       	call   800fdc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    
  800fd9:	00 00                	add    %al,(%eax)
	...

00800fdc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fe4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fe7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fed:	e8 ea fc ff ff       	call   800cdc <sys_getenvid>
  800ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801000:	89 74 24 08          	mov    %esi,0x8(%esp)
  801004:	89 44 24 04          	mov    %eax,0x4(%esp)
  801008:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  80100f:	e8 87 f1 ff ff       	call   80019b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801014:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801018:	8b 45 10             	mov    0x10(%ebp),%eax
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 17 f1 ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  801023:	c7 04 24 3a 13 80 00 	movl   $0x80133a,(%esp)
  80102a:	e8 6c f1 ff ff       	call   80019b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102f:	cc                   	int3   
  801030:	eb fd                	jmp    80102f <_panic+0x53>
	...

00801040 <__udivdi3>:
  801040:	83 ec 1c             	sub    $0x1c,%esp
  801043:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801047:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80104b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80104f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801053:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801057:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801061:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801065:	89 ea                	mov    %ebp,%edx
  801067:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80106b:	75 33                	jne    8010a0 <__udivdi3+0x60>
  80106d:	39 e9                	cmp    %ebp,%ecx
  80106f:	77 6f                	ja     8010e0 <__udivdi3+0xa0>
  801071:	85 c9                	test   %ecx,%ecx
  801073:	89 ce                	mov    %ecx,%esi
  801075:	75 0b                	jne    801082 <__udivdi3+0x42>
  801077:	b8 01 00 00 00       	mov    $0x1,%eax
  80107c:	31 d2                	xor    %edx,%edx
  80107e:	f7 f1                	div    %ecx
  801080:	89 c6                	mov    %eax,%esi
  801082:	31 d2                	xor    %edx,%edx
  801084:	89 e8                	mov    %ebp,%eax
  801086:	f7 f6                	div    %esi
  801088:	89 c5                	mov    %eax,%ebp
  80108a:	89 f8                	mov    %edi,%eax
  80108c:	f7 f6                	div    %esi
  80108e:	89 ea                	mov    %ebp,%edx
  801090:	8b 74 24 10          	mov    0x10(%esp),%esi
  801094:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801098:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80109c:	83 c4 1c             	add    $0x1c,%esp
  80109f:	c3                   	ret    
  8010a0:	39 e8                	cmp    %ebp,%eax
  8010a2:	77 24                	ja     8010c8 <__udivdi3+0x88>
  8010a4:	0f bd c8             	bsr    %eax,%ecx
  8010a7:	83 f1 1f             	xor    $0x1f,%ecx
  8010aa:	89 0c 24             	mov    %ecx,(%esp)
  8010ad:	75 49                	jne    8010f8 <__udivdi3+0xb8>
  8010af:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010b3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8010b7:	0f 86 ab 00 00 00    	jbe    801168 <__udivdi3+0x128>
  8010bd:	39 e8                	cmp    %ebp,%eax
  8010bf:	0f 82 a3 00 00 00    	jb     801168 <__udivdi3+0x128>
  8010c5:	8d 76 00             	lea    0x0(%esi),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	31 c0                	xor    %eax,%eax
  8010cc:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010d8:	83 c4 1c             	add    $0x1c,%esp
  8010db:	c3                   	ret    
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	89 f8                	mov    %edi,%eax
  8010e2:	f7 f1                	div    %ecx
  8010e4:	31 d2                	xor    %edx,%edx
  8010e6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ea:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010ee:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010f2:	83 c4 1c             	add    $0x1c,%esp
  8010f5:	c3                   	ret    
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010fc:	89 c6                	mov    %eax,%esi
  8010fe:	b8 20 00 00 00       	mov    $0x20,%eax
  801103:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801107:	2b 04 24             	sub    (%esp),%eax
  80110a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80110e:	d3 e6                	shl    %cl,%esi
  801110:	89 c1                	mov    %eax,%ecx
  801112:	d3 ed                	shr    %cl,%ebp
  801114:	0f b6 0c 24          	movzbl (%esp),%ecx
  801118:	09 f5                	or     %esi,%ebp
  80111a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80111e:	d3 e6                	shl    %cl,%esi
  801120:	89 c1                	mov    %eax,%ecx
  801122:	89 74 24 04          	mov    %esi,0x4(%esp)
  801126:	89 d6                	mov    %edx,%esi
  801128:	d3 ee                	shr    %cl,%esi
  80112a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80112e:	d3 e2                	shl    %cl,%edx
  801130:	89 c1                	mov    %eax,%ecx
  801132:	d3 ef                	shr    %cl,%edi
  801134:	09 d7                	or     %edx,%edi
  801136:	89 f2                	mov    %esi,%edx
  801138:	89 f8                	mov    %edi,%eax
  80113a:	f7 f5                	div    %ebp
  80113c:	89 d6                	mov    %edx,%esi
  80113e:	89 c7                	mov    %eax,%edi
  801140:	f7 64 24 04          	mull   0x4(%esp)
  801144:	39 d6                	cmp    %edx,%esi
  801146:	72 30                	jb     801178 <__udivdi3+0x138>
  801148:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80114c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801150:	d3 e5                	shl    %cl,%ebp
  801152:	39 c5                	cmp    %eax,%ebp
  801154:	73 04                	jae    80115a <__udivdi3+0x11a>
  801156:	39 d6                	cmp    %edx,%esi
  801158:	74 1e                	je     801178 <__udivdi3+0x138>
  80115a:	89 f8                	mov    %edi,%eax
  80115c:	31 d2                	xor    %edx,%edx
  80115e:	e9 69 ff ff ff       	jmp    8010cc <__udivdi3+0x8c>
  801163:	90                   	nop
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	31 d2                	xor    %edx,%edx
  80116a:	b8 01 00 00 00       	mov    $0x1,%eax
  80116f:	e9 58 ff ff ff       	jmp    8010cc <__udivdi3+0x8c>
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	8d 47 ff             	lea    -0x1(%edi),%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801181:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801185:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801189:	83 c4 1c             	add    $0x1c,%esp
  80118c:	c3                   	ret    
  80118d:	00 00                	add    %al,(%eax)
	...

00801190 <__umoddi3>:
  801190:	83 ec 2c             	sub    $0x2c,%esp
  801193:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801197:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80119b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80119f:	8b 74 24 38          	mov    0x38(%esp),%esi
  8011a3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8011a7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8011b3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8011b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011bf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011c3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8011c7:	75 1f                	jne    8011e8 <__umoddi3+0x58>
  8011c9:	39 fe                	cmp    %edi,%esi
  8011cb:	76 63                	jbe    801230 <__umoddi3+0xa0>
  8011cd:	89 c8                	mov    %ecx,%eax
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	f7 f6                	div    %esi
  8011d3:	89 d0                	mov    %edx,%eax
  8011d5:	31 d2                	xor    %edx,%edx
  8011d7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011db:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011df:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011e3:	83 c4 2c             	add    $0x2c,%esp
  8011e6:	c3                   	ret    
  8011e7:	90                   	nop
  8011e8:	39 f8                	cmp    %edi,%eax
  8011ea:	77 64                	ja     801250 <__umoddi3+0xc0>
  8011ec:	0f bd e8             	bsr    %eax,%ebp
  8011ef:	83 f5 1f             	xor    $0x1f,%ebp
  8011f2:	75 74                	jne    801268 <__umoddi3+0xd8>
  8011f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8011fc:	0f 87 0e 01 00 00    	ja     801310 <__umoddi3+0x180>
  801202:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801206:	29 f1                	sub    %esi,%ecx
  801208:	19 c7                	sbb    %eax,%edi
  80120a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80120e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801212:	8b 44 24 14          	mov    0x14(%esp),%eax
  801216:	8b 54 24 18          	mov    0x18(%esp),%edx
  80121a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80121e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801222:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801226:	83 c4 2c             	add    $0x2c,%esp
  801229:	c3                   	ret    
  80122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801230:	85 f6                	test   %esi,%esi
  801232:	89 f5                	mov    %esi,%ebp
  801234:	75 0b                	jne    801241 <__umoddi3+0xb1>
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	f7 f6                	div    %esi
  80123f:	89 c5                	mov    %eax,%ebp
  801241:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801245:	31 d2                	xor    %edx,%edx
  801247:	f7 f5                	div    %ebp
  801249:	89 c8                	mov    %ecx,%eax
  80124b:	f7 f5                	div    %ebp
  80124d:	eb 84                	jmp    8011d3 <__umoddi3+0x43>
  80124f:	90                   	nop
  801250:	89 c8                	mov    %ecx,%eax
  801252:	89 fa                	mov    %edi,%edx
  801254:	8b 74 24 20          	mov    0x20(%esp),%esi
  801258:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80125c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801260:	83 c4 2c             	add    $0x2c,%esp
  801263:	c3                   	ret    
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	8b 44 24 10          	mov    0x10(%esp),%eax
  80126c:	be 20 00 00 00       	mov    $0x20,%esi
  801271:	89 e9                	mov    %ebp,%ecx
  801273:	29 ee                	sub    %ebp,%esi
  801275:	d3 e2                	shl    %cl,%edx
  801277:	89 f1                	mov    %esi,%ecx
  801279:	d3 e8                	shr    %cl,%eax
  80127b:	89 e9                	mov    %ebp,%ecx
  80127d:	09 d0                	or     %edx,%eax
  80127f:	89 fa                	mov    %edi,%edx
  801281:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801285:	8b 44 24 10          	mov    0x10(%esp),%eax
  801289:	d3 e0                	shl    %cl,%eax
  80128b:	89 f1                	mov    %esi,%ecx
  80128d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801291:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801295:	d3 ea                	shr    %cl,%edx
  801297:	89 e9                	mov    %ebp,%ecx
  801299:	d3 e7                	shl    %cl,%edi
  80129b:	89 f1                	mov    %esi,%ecx
  80129d:	d3 e8                	shr    %cl,%eax
  80129f:	89 e9                	mov    %ebp,%ecx
  8012a1:	09 f8                	or     %edi,%eax
  8012a3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012a7:	f7 74 24 0c          	divl   0xc(%esp)
  8012ab:	d3 e7                	shl    %cl,%edi
  8012ad:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012b1:	89 d7                	mov    %edx,%edi
  8012b3:	f7 64 24 10          	mull   0x10(%esp)
  8012b7:	39 d7                	cmp    %edx,%edi
  8012b9:	89 c1                	mov    %eax,%ecx
  8012bb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8012bf:	72 3b                	jb     8012fc <__umoddi3+0x16c>
  8012c1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8012c5:	72 31                	jb     8012f8 <__umoddi3+0x168>
  8012c7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8012cb:	29 c8                	sub    %ecx,%eax
  8012cd:	19 d7                	sbb    %edx,%edi
  8012cf:	89 e9                	mov    %ebp,%ecx
  8012d1:	89 fa                	mov    %edi,%edx
  8012d3:	d3 e8                	shr    %cl,%eax
  8012d5:	89 f1                	mov    %esi,%ecx
  8012d7:	d3 e2                	shl    %cl,%edx
  8012d9:	89 e9                	mov    %ebp,%ecx
  8012db:	09 d0                	or     %edx,%eax
  8012dd:	89 fa                	mov    %edi,%edx
  8012df:	d3 ea                	shr    %cl,%edx
  8012e1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012e5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012e9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012ed:	83 c4 2c             	add    $0x2c,%esp
  8012f0:	c3                   	ret    
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	39 d7                	cmp    %edx,%edi
  8012fa:	75 cb                	jne    8012c7 <__umoddi3+0x137>
  8012fc:	8b 54 24 14          	mov    0x14(%esp),%edx
  801300:	89 c1                	mov    %eax,%ecx
  801302:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801306:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80130a:	eb bb                	jmp    8012c7 <__umoddi3+0x137>
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801314:	0f 82 e8 fe ff ff    	jb     801202 <__umoddi3+0x72>
  80131a:	e9 f3 fe ff ff       	jmp    801212 <__umoddi3+0x82>
