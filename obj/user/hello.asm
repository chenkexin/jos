
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  800041:	e8 21 01 00 00       	call   800167 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ce 12 80 00 	movl   $0x8012ce,(%esp)
  800059:	e8 09 01 00 00       	call   800167 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800072:	e8 35 0c 00 00       	call   800cac <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 db                	test   %ebx,%ebx
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 06                	mov    (%esi),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 74 24 04          	mov    %esi,0x4(%esp)
  800098:	89 1c 24             	mov    %ebx,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 8d 0b 00 00       	call   800c4f <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e1:	75 19                	jne    8000fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ea:	00 
  8000eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 fa 0a 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800100:	83 c4 14             	add    $0x14,%esp
  800103:	5b                   	pop    %ebx
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012a:	8b 45 08             	mov    0x8(%ebp),%eax
  80012d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  800142:	e8 bb 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	89 04 24             	mov    %eax,(%esp)
  80015a:	e8 91 0a 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 87 ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001a7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8001af:	39 d8                	cmp    %ebx,%eax
  8001b1:	72 17                	jb     8001ca <printnum+0x3a>
  8001b3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001b6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001b9:	76 0f                	jbe    8001ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001bb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001be:	83 ee 01             	sub    $0x1,%esi
  8001c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001c4:	85 f6                	test   %esi,%esi
  8001c6:	7f 63                	jg     80022b <printnum+0x9b>
  8001c8:	eb 75                	jmp    80023f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ca:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001cd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8001d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d4:	83 e8 01             	sub    $0x1,%eax
  8001d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f7:	00 
  8001f8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001fb:	89 1c 24             	mov    %ebx,(%esp)
  8001fe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800201:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800205:	e8 c6 0d 00 00       	call   800fd0 <__udivdi3>
  80020a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80020d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800210:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021f:	89 fa                	mov    %edi,%edx
  800221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800224:	e8 67 ff ff ff       	call   800190 <printnum>
  800229:	eb 14                	jmp    80023f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022f:	8b 45 18             	mov    0x18(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	83 ee 01             	sub    $0x1,%esi
  80023a:	75 ef                	jne    80022b <printnum+0x9b>
  80023c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800243:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800247:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800255:	00 
  800256:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800259:	89 1c 24             	mov    %ebx,(%esp)
  80025c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80025f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800263:	e8 b8 0e 00 00       	call   801120 <__umoddi3>
  800268:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026c:	0f be 80 ef 12 80 00 	movsbl 0x8012ef(%eax),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800279:	ff d0                	call   *%eax
}
  80027b:	83 c4 4c             	add    $0x4c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7e 0e                	jle    800299 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	8b 52 04             	mov    0x4(%edx),%edx
  800297:	eb 22                	jmp    8002bb <getuint+0x38>
	else if (lflag)
  800299:	85 d2                	test   %edx,%edx
  80029b:	74 10                	je     8002ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	eb 0e                	jmp    8002bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cc:	73 0a                	jae    8002d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	88 0a                	mov    %cl,(%edx)
  8002d3:	83 c2 01             	add    $0x1,%edx
  8002d6:	89 10                	mov    %edx,(%eax)
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 02 00 00 00       	call   800302 <vprintfmt>
	va_end(ap);
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 4c             	sub    $0x4c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	eb 11                	jmp    800327 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	0f 84 db 03 00 00    	je     8006f9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80031e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800327:	0f b6 07             	movzbl (%edi),%eax
  80032a:	83 c7 01             	add    $0x1,%edi
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e4                	jne    800316 <vprintfmt+0x14>
  800332:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800336:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80033d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800344:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	eb 2b                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800359:	eb 22                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800362:	eb 19                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800367:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036e:	eb 0d                	jmp    80037d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800373:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800376:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	0f b6 0f             	movzbl (%edi),%ecx
  800380:	8d 47 01             	lea    0x1(%edi),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	0f b6 07             	movzbl (%edi),%eax
  800389:	83 e8 23             	sub    $0x23,%eax
  80038c:	3c 55                	cmp    $0x55,%al
  80038e:	0f 87 40 03 00 00    	ja     8006d4 <vprintfmt+0x3d2>
  800394:	0f b6 c0             	movzbl %al,%eax
  800397:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039e:	83 e9 30             	sub    $0x30,%ecx
  8003a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003a4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ab:	83 f9 09             	cmp    $0x9,%ecx
  8003ae:	77 57                	ja     800407 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003bf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003c6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003c9:	83 f9 09             	cmp    $0x9,%ecx
  8003cc:	76 eb                	jbe    8003b9 <vprintfmt+0xb7>
  8003ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d4:	eb 34                	jmp    80040a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e7:	eb 21                	jmp    80040a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8003e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ed:	0f 88 71 ff ff ff    	js     800364 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003f6:	eb 85                	jmp    80037d <vprintfmt+0x7b>
  8003f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800402:	e9 76 ff ff ff       	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80040e:	0f 89 69 ff ff ff    	jns    80037d <vprintfmt+0x7b>
  800414:	e9 57 ff ff ff       	jmp    800370 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800419:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041f:	e9 59 ff ff ff       	jmp    80037d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043b:	e9 e7 fe ff ff       	jmp    800327 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	c1 fa 1f             	sar    $0x1f,%edx
  800450:	31 d0                	xor    %edx,%eax
  800452:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 f8 08             	cmp    $0x8,%eax
  800457:	7f 0b                	jg     800464 <vprintfmt+0x162>
  800459:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	75 20                	jne    800484 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800464:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800468:	c7 44 24 08 07 13 80 	movl   $0x801307,0x8(%esp)
  80046f:	00 
  800470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800474:	89 34 24             	mov    %esi,(%esp)
  800477:	e8 5e fe ff ff       	call   8002da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047f:	e9 a3 fe ff ff       	jmp    800327 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	c7 44 24 08 10 13 80 	movl   $0x801310,0x8(%esp)
  80048f:	00 
  800490:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800494:	89 34 24             	mov    %esi,(%esp)
  800497:	e8 3e fe ff ff       	call   8002da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049f:	e9 83 fe ff ff       	jmp    800327 <vprintfmt+0x25>
  8004a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004a7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	b8 00 13 80 00       	mov    $0x801300,%eax
  8004bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004c6:	74 06                	je     8004ce <vprintfmt+0x1cc>
  8004c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004cc:	7f 16                	jg     8004e4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	0f b6 17             	movzbl (%edi),%edx
  8004d1:	0f be c2             	movsbl %dl,%eax
  8004d4:	83 c7 01             	add    $0x1,%edi
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	0f 85 9f 00 00 00    	jne    80057e <vprintfmt+0x27c>
  8004df:	e9 8b 00 00 00       	jmp    80056f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e8:	89 3c 24             	mov    %edi,(%esp)
  8004eb:	e8 c2 02 00 00       	call   8007b2 <strnlen>
  8004f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	7e d2                	jle    8004ce <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004fc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800500:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800503:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800506:	89 d7                	mov    %edx,%edi
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	75 ef                	jne    800508 <vprintfmt+0x206>
  800519:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80051c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80051f:	eb ad                	jmp    8004ce <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800525:	74 20                	je     800547 <vprintfmt+0x245>
  800527:	0f be d2             	movsbl %dl,%edx
  80052a:	83 ea 20             	sub    $0x20,%edx
  80052d:	83 fa 5e             	cmp    $0x5e,%edx
  800530:	76 15                	jbe    800547 <vprintfmt+0x245>
					putch('?', putdat);
  800532:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800540:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800543:	ff d1                	call   *%ecx
  800545:	eb 0f                	jmp    800556 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800554:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	83 eb 01             	sub    $0x1,%ebx
  800559:	0f b6 17             	movzbl (%edi),%edx
  80055c:	0f be c2             	movsbl %dl,%eax
  80055f:	83 c7 01             	add    $0x1,%edi
  800562:	85 c0                	test   %eax,%eax
  800564:	75 24                	jne    80058a <vprintfmt+0x288>
  800566:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800569:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80056c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800576:	0f 8e ab fd ff ff    	jle    800327 <vprintfmt+0x25>
  80057c:	eb 20                	jmp    80059e <vprintfmt+0x29c>
  80057e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800581:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800584:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800587:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	85 f6                	test   %esi,%esi
  80058c:	78 93                	js     800521 <vprintfmt+0x21f>
  80058e:	83 ee 01             	sub    $0x1,%esi
  800591:	79 8e                	jns    800521 <vprintfmt+0x21f>
  800593:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800596:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800599:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80059c:	eb d1                	jmp    80056f <vprintfmt+0x26d>
  80059e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ae:	83 ef 01             	sub    $0x1,%edi
  8005b1:	75 ee                	jne    8005a1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b6:	e9 6c fd ff ff       	jmp    800327 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	66 90                	xchg   %ax,%ax
  8005c0:	7e 16                	jle    8005d8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 08             	lea    0x8(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005d3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d6:	eb 32                	jmp    80060a <vprintfmt+0x308>
	else if (lflag)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 18                	je     8005f4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005f2:	eb 16                	jmp    80060a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800602:	89 c7                	mov    %eax,%edi
  800604:	c1 ff 1f             	sar    $0x1f,%edi
  800607:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800610:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800615:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800619:	79 7d                	jns    800698 <vprintfmt+0x396>
				putch('-', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063a:	eb 5c                	jmp    800698 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 3f fc ff ff       	call   800283 <getuint>
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800649:	eb 4d                	jmp    800698 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 30 fc ff ff       	call   800283 <getuint>
      base = 8;
  800653:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800658:	eb 3e                	jmp    800698 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800665:	ff d6                	call   *%esi
			putch('x', putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800672:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800684:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800689:	eb 0d                	jmp    800698 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f0 fb ff ff       	call   800283 <getuint>
			base = 16;
  800693:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80069c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006a0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	e8 d5 fa ff ff       	call   800190 <printnum>
			break;
  8006bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006be:	e9 64 fc ff ff       	jmp    800327 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	89 0c 24             	mov    %ecx,(%esp)
  8006ca:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 53 fc ff ff       	jmp    800327 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e5:	0f 84 3c fc ff ff    	je     800327 <vprintfmt+0x25>
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f2:	75 f7                	jne    8006eb <vprintfmt+0x3e9>
  8006f4:	e9 2e fc ff ff       	jmp    800327 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006f9:	83 c4 4c             	add    $0x4c,%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 28             	sub    $0x28,%esp
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800710:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800714:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800717:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071e:	85 d2                	test   %edx,%edx
  800720:	7e 30                	jle    800752 <vsnprintf+0x51>
  800722:	85 c0                	test   %eax,%eax
  800724:	74 2c                	je     800752 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	89 44 24 08          	mov    %eax,0x8(%esp)
  800734:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	c7 04 24 bd 02 80 00 	movl   $0x8002bd,(%esp)
  800742:	e8 bb fb ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800747:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800750:	eb 05                	jmp    800757 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 82 ff ff ff       	call   800701 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
	...

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3a 00             	cmpb   $0x0,(%edx)
  800799:	74 10                	je     8007ab <strlen+0x1b>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0x10>
  8007a9:	eb 05                	jmp    8007b0 <strlen+0x20>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	74 1c                	je     8007dc <strnlen+0x2a>
  8007c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007c3:	74 1e                	je     8007e3 <strnlen+0x31>
  8007c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007ca:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 ca                	cmp    %ecx,%edx
  8007ce:	74 18                	je     8007e8 <strnlen+0x36>
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007d8:	75 f0                	jne    8007ca <strnlen+0x18>
  8007da:	eb 0c                	jmp    8007e8 <strnlen+0x36>
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 05                	jmp    8007e8 <strnlen+0x36>
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	0f b6 19             	movzbl (%ecx),%ebx
  8007fa:	88 1a                	mov    %bl,(%edx)
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	83 c1 01             	add    $0x1,%ecx
  800802:	84 db                	test   %bl,%bl
  800804:	75 f1                	jne    8007f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	e8 75 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800822:	01 d8                	add    %ebx,%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 bf ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	83 c4 08             	add    $0x8,%esp
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	85 db                	test   %ebx,%ebx
  800844:	74 16                	je     80085c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	01 f3                	add    %esi,%ebx
  800848:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80084a:	0f b6 02             	movzbl (%edx),%eax
  80084d:	88 01                	mov    %al,(%ecx)
  80084f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800852:	80 3a 01             	cmpb   $0x1,(%edx)
  800855:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	39 d9                	cmp    %ebx,%ecx
  80085a:	75 ee                	jne    80084a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	89 f8                	mov    %edi,%eax
  800873:	85 f6                	test   %esi,%esi
  800875:	74 33                	je     8008aa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800877:	83 fe 01             	cmp    $0x1,%esi
  80087a:	74 25                	je     8008a1 <strlcpy+0x3f>
  80087c:	0f b6 0b             	movzbl (%ebx),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 22                	je     8008a5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800883:	83 ee 02             	sub    $0x2,%esi
  800886:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088b:	88 08                	mov    %cl,(%eax)
  80088d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800890:	39 f2                	cmp    %esi,%edx
  800892:	74 13                	je     8008a7 <strlcpy+0x45>
  800894:	83 c2 01             	add    $0x1,%edx
  800897:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089b:	84 c9                	test   %cl,%cl
  80089d:	75 ec                	jne    80088b <strlcpy+0x29>
  80089f:	eb 06                	jmp    8008a7 <strlcpy+0x45>
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	eb 02                	jmp    8008a7 <strlcpy+0x45>
  8008a5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008aa:	29 f8                	sub    %edi,%eax
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5f                   	pop    %edi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 15                	je     8008d6 <strcmp+0x25>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	75 11                	jne    8008d6 <strcmp+0x25>
		p++, q++;
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x25>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 ef                	je     8008c5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008ee:	85 f6                	test   %esi,%esi
  8008f0:	74 29                	je     80091b <strncmp+0x3b>
  8008f2:	0f b6 03             	movzbl (%ebx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 30                	je     800929 <strncmp+0x49>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	75 2c                	jne    800929 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8008fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800900:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800902:	89 c3                	mov    %eax,%ebx
  800904:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800907:	39 f0                	cmp    %esi,%eax
  800909:	74 17                	je     800922 <strncmp+0x42>
  80090b:	0f b6 08             	movzbl (%eax),%ecx
  80090e:	84 c9                	test   %cl,%cl
  800910:	74 17                	je     800929 <strncmp+0x49>
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	3a 0a                	cmp    (%edx),%cl
  800917:	74 e9                	je     800902 <strncmp+0x22>
  800919:	eb 0e                	jmp    800929 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	eb 0f                	jmp    800931 <strncmp+0x51>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 08                	jmp    800931 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 03             	movzbl (%ebx),%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80093f:	0f b6 18             	movzbl (%eax),%ebx
  800942:	84 db                	test   %bl,%bl
  800944:	74 1d                	je     800963 <strchr+0x2e>
  800946:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800948:	38 d3                	cmp    %dl,%bl
  80094a:	75 06                	jne    800952 <strchr+0x1d>
  80094c:	eb 1a                	jmp    800968 <strchr+0x33>
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 16                	je     800968 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f2                	jne    80094e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb 05                	jmp    800968 <strchr+0x33>
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800975:	0f b6 18             	movzbl (%eax),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	74 16                	je     800992 <strfind+0x27>
  80097c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80097e:	38 d3                	cmp    %dl,%bl
  800980:	75 06                	jne    800988 <strfind+0x1d>
  800982:	eb 0e                	jmp    800992 <strfind+0x27>
  800984:	38 ca                	cmp    %cl,%dl
  800986:	74 0a                	je     800992 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	84 d2                	test   %dl,%dl
  800990:	75 f2                	jne    800984 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80099e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	74 36                	je     8009e4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b4:	75 28                	jne    8009de <memset+0x49>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 23                	jne    8009de <memset+0x49>
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	c1 e6 18             	shl    $0x18,%esi
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 10             	shl    $0x10,%eax
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 06                	jmp    8009e4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009ef:	89 ec                	mov    %ebp,%esp
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a08:	39 c6                	cmp    %eax,%esi
  800a0a:	73 36                	jae    800a42 <memmove+0x4f>
  800a0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0f:	39 d0                	cmp    %edx,%eax
  800a11:	73 2f                	jae    800a42 <memmove+0x4f>
		s += n;
		d += n;
  800a13:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f6 c2 03             	test   $0x3,%dl
  800a19:	75 1b                	jne    800a36 <memmove+0x43>
  800a1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a21:	75 13                	jne    800a36 <memmove+0x43>
  800a23:	f6 c1 03             	test   $0x3,%cl
  800a26:	75 0e                	jne    800a36 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a28:	83 ef 04             	sub    $0x4,%edi
  800a2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a31:	fd                   	std    
  800a32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a34:	eb 09                	jmp    800a3f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a36:	83 ef 01             	sub    $0x1,%edi
  800a39:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3c:	fd                   	std    
  800a3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3f:	fc                   	cld    
  800a40:	eb 20                	jmp    800a62 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x6a>
  800a4a:	a8 03                	test   $0x3,%al
  800a4c:	75 0f                	jne    800a5d <memmove+0x6a>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0a                	jne    800a5d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a53:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 05                	jmp    800a62 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	fc                   	cld    
  800a60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a68:	89 ec                	mov    %ebp,%esp
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 68 ff ff ff       	call   8009f3 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a99:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	74 36                	je     800ad9 <memcmp+0x4c>
		if (*s1 != *s2)
  800aa3:	0f b6 03             	movzbl (%ebx),%eax
  800aa6:	0f b6 0e             	movzbl (%esi),%ecx
  800aa9:	38 c8                	cmp    %cl,%al
  800aab:	75 17                	jne    800ac4 <memcmp+0x37>
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	eb 1a                	jmp    800ace <memcmp+0x41>
  800ab4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ac0:	38 c8                	cmp    %cl,%al
  800ac2:	74 0a                	je     800ace <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ac4:	0f b6 c0             	movzbl %al,%eax
  800ac7:	0f b6 c9             	movzbl %cl,%ecx
  800aca:	29 c8                	sub    %ecx,%eax
  800acc:	eb 10                	jmp    800ade <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ace:	39 fa                	cmp    %edi,%edx
  800ad0:	75 e2                	jne    800ab4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	eb 05                	jmp    800ade <memcmp+0x51>
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	53                   	push   %ebx
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af2:	39 d0                	cmp    %edx,%eax
  800af4:	73 13                	jae    800b09 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	89 d9                	mov    %ebx,%ecx
  800af8:	38 18                	cmp    %bl,(%eax)
  800afa:	75 06                	jne    800b02 <memfind+0x1f>
  800afc:	eb 0b                	jmp    800b09 <memfind+0x26>
  800afe:	38 08                	cmp    %cl,(%eax)
  800b00:	74 07                	je     800b09 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 d0                	cmp    %edx,%eax
  800b07:	75 f5                	jne    800afe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 04             	sub    $0x4,%esp
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	0f b6 02             	movzbl (%edx),%eax
  800b1e:	3c 09                	cmp    $0x9,%al
  800b20:	74 04                	je     800b26 <strtol+0x1a>
  800b22:	3c 20                	cmp    $0x20,%al
  800b24:	75 0e                	jne    800b34 <strtol+0x28>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	0f b6 02             	movzbl (%edx),%eax
  800b2c:	3c 09                	cmp    $0x9,%al
  800b2e:	74 f6                	je     800b26 <strtol+0x1a>
  800b30:	3c 20                	cmp    $0x20,%al
  800b32:	74 f2                	je     800b26 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b34:	3c 2b                	cmp    $0x2b,%al
  800b36:	75 0a                	jne    800b42 <strtol+0x36>
		s++;
  800b38:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b40:	eb 10                	jmp    800b52 <strtol+0x46>
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b47:	3c 2d                	cmp    $0x2d,%al
  800b49:	75 07                	jne    800b52 <strtol+0x46>
		s++, neg = 1;
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b58:	75 15                	jne    800b6f <strtol+0x63>
  800b5a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5d:	75 10                	jne    800b6f <strtol+0x63>
  800b5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b63:	75 0a                	jne    800b6f <strtol+0x63>
		s += 2, base = 16;
  800b65:	83 c2 02             	add    $0x2,%edx
  800b68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6d:	eb 10                	jmp    800b7f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 0c                	jne    800b7f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b73:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b75:	80 3a 30             	cmpb   $0x30,(%edx)
  800b78:	75 05                	jne    800b7f <strtol+0x73>
		s++, base = 8;
  800b7a:	83 c2 01             	add    $0x1,%edx
  800b7d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b87:	0f b6 0a             	movzbl (%edx),%ecx
  800b8a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 09             	cmp    $0x9,%bl
  800b92:	77 08                	ja     800b9c <strtol+0x90>
			dig = *s - '0';
  800b94:	0f be c9             	movsbl %cl,%ecx
  800b97:	83 e9 30             	sub    $0x30,%ecx
  800b9a:	eb 22                	jmp    800bbe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800b9c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 08                	ja     800bae <strtol+0xa2>
			dig = *s - 'a' + 10;
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 57             	sub    $0x57,%ecx
  800bac:	eb 10                	jmp    800bbe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bae:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bb1:	89 f3                	mov    %esi,%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 16                	ja     800bce <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bb8:	0f be c9             	movsbl %cl,%ecx
  800bbb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bc1:	7d 0f                	jge    800bd2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bca:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bcc:	eb b9                	jmp    800b87 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bce:	89 c1                	mov    %eax,%ecx
  800bd0:	eb 02                	jmp    800bd4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd8:	74 05                	je     800bdf <strtol+0xd3>
		*endptr = (char *) s;
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bdd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bdf:	89 ca                	mov    %ecx,%edx
  800be1:	f7 da                	neg    %edx
  800be3:	85 ff                	test   %edi,%edi
  800be5:	0f 45 c2             	cmovne %edx,%eax
}
  800be8:	83 c4 04             	add    $0x4,%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	89 c7                	mov    %eax,%edi
  800c0e:	89 c6                	mov    %eax,%esi
  800c10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c1b:	89 ec                	mov    %ebp,%esp
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c33:	b8 01 00 00 00       	mov    $0x1,%eax
  800c38:	89 d1                	mov    %edx,%ecx
  800c3a:	89 d3                	mov    %edx,%ebx
  800c3c:	89 d7                	mov    %edx,%edi
  800c3e:	89 d6                	mov    %edx,%esi
  800c40:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4b:	89 ec                	mov    %ebp,%esp
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 38             	sub    $0x38,%esp
  800c55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	b8 03 00 00 00       	mov    $0x3,%eax
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800c9a:	e8 d5 02 00 00       	call   800f74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca8:	89 ec                	mov    %ebp,%esp
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd8:	89 ec                	mov    %ebp,%esp
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_yield>:

void
sys_yield(void)
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
  800cf0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d08:	89 ec                	mov    %ebp,%esp
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 38             	sub    $0x38,%esp
  800d12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	be 00 00 00 00       	mov    $0x0,%esi
  800d20:	b8 04 00 00 00       	mov    $0x4,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	89 f7                	mov    %esi,%edi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 28                	jle    800d5e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d41:	00 
  800d42:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d49:	00 
  800d4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d51:	00 
  800d52:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d59:	e8 16 02 00 00       	call   800f74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d67:	89 ec                	mov    %ebp,%esp
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 38             	sub    $0x38,%esp
  800d71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7e 28                	jle    800dbc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d9f:	00 
  800da0:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800da7:	00 
  800da8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daf:	00 
  800db0:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800db7:	e8 b8 01 00 00       	call   800f74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dbc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dbf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc5:	89 ec                	mov    %ebp,%esp
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	83 ec 38             	sub    $0x38,%esp
  800dcf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddd:	b8 06 00 00 00       	mov    $0x6,%eax
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	89 df                	mov    %ebx,%edi
  800dea:	89 de                	mov    %ebx,%esi
  800dec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 28                	jle    800e1a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e05:	00 
  800e06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0d:	00 
  800e0e:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e15:	e8 5a 01 00 00       	call   800f74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e23:	89 ec                	mov    %ebp,%esp
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	83 ec 38             	sub    $0x38,%esp
  800e2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e33:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 28                	jle    800e78 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e63:	00 
  800e64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6b:	00 
  800e6c:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e73:	e8 fc 00 00 00       	call   800f74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e78:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e81:	89 ec                	mov    %ebp,%esp
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 38             	sub    $0x38,%esp
  800e8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e91:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e99:	b8 09 00 00 00       	mov    $0x9,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 df                	mov    %ebx,%edi
  800ea6:	89 de                	mov    %ebx,%esi
  800ea8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	7e 28                	jle    800ed6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb9:	00 
  800eba:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800ed1:	e8 9e 00 00 00       	call   800f74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edf:	89 ec                	mov    %ebp,%esp
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
  800ef7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f08:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f13:	89 ec                	mov    %ebp,%esp
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800f26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	89 cb                	mov    %ecx,%ebx
  800f35:	89 cf                	mov    %ecx,%edi
  800f37:	89 ce                	mov    %ecx,%esi
  800f39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	7e 28                	jle    800f67 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f43:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800f52:	00 
  800f53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800f62:	e8 0d 00 00 00       	call   800f74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f70:	89 ec                	mov    %ebp,%esp
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f7c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f7f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f85:	e8 22 fd ff ff       	call   800cac <sys_getenvid>
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f98:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa0:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  800fa7:	e8 bb f1 ff ff       	call   800167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb3:	89 04 24             	mov    %eax,(%esp)
  800fb6:	e8 4b f1 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  800fbb:	c7 04 24 cc 12 80 00 	movl   $0x8012cc,(%esp)
  800fc2:	e8 a0 f1 ff ff       	call   800167 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fc7:	cc                   	int3   
  800fc8:	eb fd                	jmp    800fc7 <_panic+0x53>
  800fca:	00 00                	add    %al,(%eax)
  800fcc:	00 00                	add    %al,(%eax)
	...

00800fd0 <__udivdi3>:
  800fd0:	83 ec 1c             	sub    $0x1c,%esp
  800fd3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800fd7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fdb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fdf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fe3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800fe7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ff1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff5:	89 ea                	mov    %ebp,%edx
  800ff7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ffb:	75 33                	jne    801030 <__udivdi3+0x60>
  800ffd:	39 e9                	cmp    %ebp,%ecx
  800fff:	77 6f                	ja     801070 <__udivdi3+0xa0>
  801001:	85 c9                	test   %ecx,%ecx
  801003:	89 ce                	mov    %ecx,%esi
  801005:	75 0b                	jne    801012 <__udivdi3+0x42>
  801007:	b8 01 00 00 00       	mov    $0x1,%eax
  80100c:	31 d2                	xor    %edx,%edx
  80100e:	f7 f1                	div    %ecx
  801010:	89 c6                	mov    %eax,%esi
  801012:	31 d2                	xor    %edx,%edx
  801014:	89 e8                	mov    %ebp,%eax
  801016:	f7 f6                	div    %esi
  801018:	89 c5                	mov    %eax,%ebp
  80101a:	89 f8                	mov    %edi,%eax
  80101c:	f7 f6                	div    %esi
  80101e:	89 ea                	mov    %ebp,%edx
  801020:	8b 74 24 10          	mov    0x10(%esp),%esi
  801024:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801028:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80102c:	83 c4 1c             	add    $0x1c,%esp
  80102f:	c3                   	ret    
  801030:	39 e8                	cmp    %ebp,%eax
  801032:	77 24                	ja     801058 <__udivdi3+0x88>
  801034:	0f bd c8             	bsr    %eax,%ecx
  801037:	83 f1 1f             	xor    $0x1f,%ecx
  80103a:	89 0c 24             	mov    %ecx,(%esp)
  80103d:	75 49                	jne    801088 <__udivdi3+0xb8>
  80103f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801043:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801047:	0f 86 ab 00 00 00    	jbe    8010f8 <__udivdi3+0x128>
  80104d:	39 e8                	cmp    %ebp,%eax
  80104f:	0f 82 a3 00 00 00    	jb     8010f8 <__udivdi3+0x128>
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	31 d2                	xor    %edx,%edx
  80105a:	31 c0                	xor    %eax,%eax
  80105c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801060:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801064:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801068:	83 c4 1c             	add    $0x1c,%esp
  80106b:	c3                   	ret    
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	89 f8                	mov    %edi,%eax
  801072:	f7 f1                	div    %ecx
  801074:	31 d2                	xor    %edx,%edx
  801076:	8b 74 24 10          	mov    0x10(%esp),%esi
  80107a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80107e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801082:	83 c4 1c             	add    $0x1c,%esp
  801085:	c3                   	ret    
  801086:	66 90                	xchg   %ax,%ax
  801088:	0f b6 0c 24          	movzbl (%esp),%ecx
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	b8 20 00 00 00       	mov    $0x20,%eax
  801093:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801097:	2b 04 24             	sub    (%esp),%eax
  80109a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80109e:	d3 e6                	shl    %cl,%esi
  8010a0:	89 c1                	mov    %eax,%ecx
  8010a2:	d3 ed                	shr    %cl,%ebp
  8010a4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010a8:	09 f5                	or     %esi,%ebp
  8010aa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010ae:	d3 e6                	shl    %cl,%esi
  8010b0:	89 c1                	mov    %eax,%ecx
  8010b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b6:	89 d6                	mov    %edx,%esi
  8010b8:	d3 ee                	shr    %cl,%esi
  8010ba:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010be:	d3 e2                	shl    %cl,%edx
  8010c0:	89 c1                	mov    %eax,%ecx
  8010c2:	d3 ef                	shr    %cl,%edi
  8010c4:	09 d7                	or     %edx,%edi
  8010c6:	89 f2                	mov    %esi,%edx
  8010c8:	89 f8                	mov    %edi,%eax
  8010ca:	f7 f5                	div    %ebp
  8010cc:	89 d6                	mov    %edx,%esi
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	f7 64 24 04          	mull   0x4(%esp)
  8010d4:	39 d6                	cmp    %edx,%esi
  8010d6:	72 30                	jb     801108 <__udivdi3+0x138>
  8010d8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010dc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010e0:	d3 e5                	shl    %cl,%ebp
  8010e2:	39 c5                	cmp    %eax,%ebp
  8010e4:	73 04                	jae    8010ea <__udivdi3+0x11a>
  8010e6:	39 d6                	cmp    %edx,%esi
  8010e8:	74 1e                	je     801108 <__udivdi3+0x138>
  8010ea:	89 f8                	mov    %edi,%eax
  8010ec:	31 d2                	xor    %edx,%edx
  8010ee:	e9 69 ff ff ff       	jmp    80105c <__udivdi3+0x8c>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	31 d2                	xor    %edx,%edx
  8010fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ff:	e9 58 ff ff ff       	jmp    80105c <__udivdi3+0x8c>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 47 ff             	lea    -0x1(%edi),%eax
  80110b:	31 d2                	xor    %edx,%edx
  80110d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801111:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801115:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801119:	83 c4 1c             	add    $0x1c,%esp
  80111c:	c3                   	ret    
  80111d:	00 00                	add    %al,(%eax)
	...

00801120 <__umoddi3>:
  801120:	83 ec 2c             	sub    $0x2c,%esp
  801123:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801127:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80112b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80112f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801133:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801137:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80113b:	85 c0                	test   %eax,%eax
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801143:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801147:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80114f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801153:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801157:	75 1f                	jne    801178 <__umoddi3+0x58>
  801159:	39 fe                	cmp    %edi,%esi
  80115b:	76 63                	jbe    8011c0 <__umoddi3+0xa0>
  80115d:	89 c8                	mov    %ecx,%eax
  80115f:	89 fa                	mov    %edi,%edx
  801161:	f7 f6                	div    %esi
  801163:	89 d0                	mov    %edx,%eax
  801165:	31 d2                	xor    %edx,%edx
  801167:	8b 74 24 20          	mov    0x20(%esp),%esi
  80116b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80116f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801173:	83 c4 2c             	add    $0x2c,%esp
  801176:	c3                   	ret    
  801177:	90                   	nop
  801178:	39 f8                	cmp    %edi,%eax
  80117a:	77 64                	ja     8011e0 <__umoddi3+0xc0>
  80117c:	0f bd e8             	bsr    %eax,%ebp
  80117f:	83 f5 1f             	xor    $0x1f,%ebp
  801182:	75 74                	jne    8011f8 <__umoddi3+0xd8>
  801184:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801188:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80118c:	0f 87 0e 01 00 00    	ja     8012a0 <__umoddi3+0x180>
  801192:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801196:	29 f1                	sub    %esi,%ecx
  801198:	19 c7                	sbb    %eax,%edi
  80119a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80119e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8011a2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8011a6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8011aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011b2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011b6:	83 c4 2c             	add    $0x2c,%esp
  8011b9:	c3                   	ret    
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	85 f6                	test   %esi,%esi
  8011c2:	89 f5                	mov    %esi,%ebp
  8011c4:	75 0b                	jne    8011d1 <__umoddi3+0xb1>
  8011c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cb:	31 d2                	xor    %edx,%edx
  8011cd:	f7 f6                	div    %esi
  8011cf:	89 c5                	mov    %eax,%ebp
  8011d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011d5:	31 d2                	xor    %edx,%edx
  8011d7:	f7 f5                	div    %ebp
  8011d9:	89 c8                	mov    %ecx,%eax
  8011db:	f7 f5                	div    %ebp
  8011dd:	eb 84                	jmp    801163 <__umoddi3+0x43>
  8011df:	90                   	nop
  8011e0:	89 c8                	mov    %ecx,%eax
  8011e2:	89 fa                	mov    %edi,%edx
  8011e4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011e8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011ec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011f0:	83 c4 2c             	add    $0x2c,%esp
  8011f3:	c3                   	ret    
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011fc:	be 20 00 00 00       	mov    $0x20,%esi
  801201:	89 e9                	mov    %ebp,%ecx
  801203:	29 ee                	sub    %ebp,%esi
  801205:	d3 e2                	shl    %cl,%edx
  801207:	89 f1                	mov    %esi,%ecx
  801209:	d3 e8                	shr    %cl,%eax
  80120b:	89 e9                	mov    %ebp,%ecx
  80120d:	09 d0                	or     %edx,%eax
  80120f:	89 fa                	mov    %edi,%edx
  801211:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801215:	8b 44 24 10          	mov    0x10(%esp),%eax
  801219:	d3 e0                	shl    %cl,%eax
  80121b:	89 f1                	mov    %esi,%ecx
  80121d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801221:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801225:	d3 ea                	shr    %cl,%edx
  801227:	89 e9                	mov    %ebp,%ecx
  801229:	d3 e7                	shl    %cl,%edi
  80122b:	89 f1                	mov    %esi,%ecx
  80122d:	d3 e8                	shr    %cl,%eax
  80122f:	89 e9                	mov    %ebp,%ecx
  801231:	09 f8                	or     %edi,%eax
  801233:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801237:	f7 74 24 0c          	divl   0xc(%esp)
  80123b:	d3 e7                	shl    %cl,%edi
  80123d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801241:	89 d7                	mov    %edx,%edi
  801243:	f7 64 24 10          	mull   0x10(%esp)
  801247:	39 d7                	cmp    %edx,%edi
  801249:	89 c1                	mov    %eax,%ecx
  80124b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80124f:	72 3b                	jb     80128c <__umoddi3+0x16c>
  801251:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801255:	72 31                	jb     801288 <__umoddi3+0x168>
  801257:	8b 44 24 18          	mov    0x18(%esp),%eax
  80125b:	29 c8                	sub    %ecx,%eax
  80125d:	19 d7                	sbb    %edx,%edi
  80125f:	89 e9                	mov    %ebp,%ecx
  801261:	89 fa                	mov    %edi,%edx
  801263:	d3 e8                	shr    %cl,%eax
  801265:	89 f1                	mov    %esi,%ecx
  801267:	d3 e2                	shl    %cl,%edx
  801269:	89 e9                	mov    %ebp,%ecx
  80126b:	09 d0                	or     %edx,%eax
  80126d:	89 fa                	mov    %edi,%edx
  80126f:	d3 ea                	shr    %cl,%edx
  801271:	8b 74 24 20          	mov    0x20(%esp),%esi
  801275:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801279:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80127d:	83 c4 2c             	add    $0x2c,%esp
  801280:	c3                   	ret    
  801281:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801288:	39 d7                	cmp    %edx,%edi
  80128a:	75 cb                	jne    801257 <__umoddi3+0x137>
  80128c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801290:	89 c1                	mov    %eax,%ecx
  801292:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801296:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80129a:	eb bb                	jmp    801257 <__umoddi3+0x137>
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8012a4:	0f 82 e8 fe ff ff    	jb     801192 <__umoddi3+0x72>
  8012aa:	e9 f3 fe ff ff       	jmp    8011a2 <__umoddi3+0x82>
