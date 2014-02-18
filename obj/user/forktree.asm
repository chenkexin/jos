
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 f9 0c 00 00       	call   800d3c <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800052:	e8 ac 01 00 00       	call   800203 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008f:	89 1c 24             	mov    %ebx,(%esp)
  800092:	e8 89 07 00 00       	call   800820 <strlen>
  800097:	83 f8 02             	cmp    $0x2,%eax
  80009a:	7f 41                	jg     8000dd <forkchild+0x60>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009c:	89 f0                	mov    %esi,%eax
  80009e:	0f be f0             	movsbl %al,%esi
  8000a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a9:	c7 44 24 08 91 13 80 	movl   $0x801391,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b8:	00 
  8000b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bc:	89 04 24             	mov    %eax,(%esp)
  8000bf:	e8 25 07 00 00       	call   8007e9 <snprintf>
	if (fork() == 0) {
  8000c4:	e8 3b 0f 00 00       	call   801004 <fork>
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	75 10                	jne    8000dd <forkchild+0x60>
		forktree(nxt);
  8000cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d0:	89 04 24             	mov    %eax,(%esp)
  8000d3:	e8 5c ff ff ff       	call   800034 <forktree>
		exit();
  8000d8:	e8 6f 00 00 00       	call   80014c <exit>
	}
}
  8000dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ed:	c7 04 24 90 13 80 00 	movl   $0x801390,(%esp)
  8000f4:	e8 3b ff ff ff       	call   800034 <forktree>
}
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80010e:	e8 29 0c 00 00       	call   800d3c <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x34>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 74 24 04          	mov    %esi,0x4(%esp)
  800134:	89 1c 24             	mov    %ebx,(%esp)
  800137:	e8 ab ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 81 0b 00 00       	call   800cdf <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	83 c0 01             	add    $0x1,%eax
  800176:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 19                	jne    800198 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800186:	00 
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 ee 0a 00 00       	call   800c80 <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800198:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019c:	83 c4 14             	add    $0x14,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001de:	e8 af 01 00 00       	call   800392 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 85 0a 00 00       	call   800c80 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 87 ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800231:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800234:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800237:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023a:	b8 00 00 00 00       	mov    $0x0,%eax
  80023f:	39 d8                	cmp    %ebx,%eax
  800241:	72 17                	jb     80025a <printnum+0x3a>
  800243:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800246:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800249:	76 0f                	jbe    80025a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024b:	8b 75 14             	mov    0x14(%ebp),%esi
  80024e:	83 ee 01             	sub    $0x1,%esi
  800251:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800254:	85 f6                	test   %esi,%esi
  800256:	7f 63                	jg     8002bb <printnum+0x9b>
  800258:	eb 75                	jmp    8002cf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80025d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800261:	8b 45 14             	mov    0x14(%ebp),%eax
  800264:	83 e8 01             	sub    $0x1,%eax
  800267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80026e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800272:	8b 44 24 08          	mov    0x8(%esp),%eax
  800276:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80027a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800280:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800287:	00 
  800288:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80028b:	89 1c 24             	mov    %ebx,(%esp)
  80028e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800295:	e8 06 0e 00 00       	call   8010a0 <__udivdi3>
  80029a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80029d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002af:	89 fa                	mov    %edi,%edx
  8002b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b4:	e8 67 ff ff ff       	call   800220 <printnum>
  8002b9:	eb 14                	jmp    8002cf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c7:	83 ee 01             	sub    $0x1,%esi
  8002ca:	75 ef                	jne    8002bb <printnum+0x9b>
  8002cc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e5:	00 
  8002e6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002e9:	89 1c 24             	mov    %ebx,(%esp)
  8002ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f3:	e8 f8 0e 00 00       	call   8011f0 <__umoddi3>
  8002f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fc:	0f be 80 a0 13 80 00 	movsbl 0x8013a0(%eax),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800309:	ff d0                	call   *%eax
}
  80030b:	83 c4 4c             	add    $0x4c,%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800316:	83 fa 01             	cmp    $0x1,%edx
  800319:	7e 0e                	jle    800329 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 02                	mov    (%edx),%eax
  800324:	8b 52 04             	mov    0x4(%edx),%edx
  800327:	eb 22                	jmp    80034b <getuint+0x38>
	else if (lflag)
  800329:	85 d2                	test   %edx,%edx
  80032b:	74 10                	je     80033d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 02                	mov    (%edx),%eax
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 0e                	jmp    80034b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800353:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800357:	8b 10                	mov    (%eax),%edx
  800359:	3b 50 04             	cmp    0x4(%eax),%edx
  80035c:	73 0a                	jae    800368 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800361:	88 0a                	mov    %cl,(%edx)
  800363:	83 c2 01             	add    $0x1,%edx
  800366:	89 10                	mov    %edx,(%eax)
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800377:	8b 45 10             	mov    0x10(%ebp),%eax
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 02 00 00 00       	call   800392 <vprintfmt>
	va_end(ap);
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
  800398:	83 ec 4c             	sub    $0x4c,%esp
  80039b:	8b 75 08             	mov    0x8(%ebp),%esi
  80039e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a4:	eb 11                	jmp    8003b7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	0f 84 db 03 00 00    	je     800789 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b2:	89 04 24             	mov    %eax,(%esp)
  8003b5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b7:	0f b6 07             	movzbl (%edi),%eax
  8003ba:	83 c7 01             	add    $0x1,%edi
  8003bd:	83 f8 25             	cmp    $0x25,%eax
  8003c0:	75 e4                	jne    8003a6 <vprintfmt+0x14>
  8003c2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8003c6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003cd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003db:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e0:	eb 2b                	jmp    80040d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8003e9:	eb 22                	jmp    80040d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ee:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8003f2:	eb 19                	jmp    80040d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fe:	eb 0d                	jmp    80040d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800400:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	0f b6 0f             	movzbl (%edi),%ecx
  800410:	8d 47 01             	lea    0x1(%edi),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	0f b6 07             	movzbl (%edi),%eax
  800419:	83 e8 23             	sub    $0x23,%eax
  80041c:	3c 55                	cmp    $0x55,%al
  80041e:	0f 87 40 03 00 00    	ja     800764 <vprintfmt+0x3d2>
  800424:	0f b6 c0             	movzbl %al,%eax
  800427:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042e:	83 e9 30             	sub    $0x30,%ecx
  800431:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800434:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800438:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80043b:	83 f9 09             	cmp    $0x9,%ecx
  80043e:	77 57                	ja     800497 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800443:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800446:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800449:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80044c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80044f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800453:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800456:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800459:	83 f9 09             	cmp    $0x9,%ecx
  80045c:	76 eb                	jbe    800449 <vprintfmt+0xb7>
  80045e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800461:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800464:	eb 34                	jmp    80049a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 48 04             	lea    0x4(%eax),%ecx
  80046c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800477:	eb 21                	jmp    80049a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800479:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047d:	0f 88 71 ff ff ff    	js     8003f4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800486:	eb 85                	jmp    80040d <vprintfmt+0x7b>
  800488:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800492:	e9 76 ff ff ff       	jmp    80040d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80049a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049e:	0f 89 69 ff ff ff    	jns    80040d <vprintfmt+0x7b>
  8004a4:	e9 57 ff ff ff       	jmp    800400 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004af:	e9 59 ff ff ff       	jmp    80040d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c1:	8b 00                	mov    (%eax),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cb:	e9 e7 fe ff ff       	jmp    8003b7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 00                	mov    (%eax),%eax
  8004db:	89 c2                	mov    %eax,%edx
  8004dd:	c1 fa 1f             	sar    $0x1f,%edx
  8004e0:	31 d0                	xor    %edx,%eax
  8004e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e4:	83 f8 08             	cmp    $0x8,%eax
  8004e7:	7f 0b                	jg     8004f4 <vprintfmt+0x162>
  8004e9:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	75 20                	jne    800514 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 b8 13 80 	movl   $0x8013b8,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 34 24             	mov    %esi,(%esp)
  800507:	e8 5e fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050f:	e9 a3 fe ff ff       	jmp    8003b7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800514:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800518:	c7 44 24 08 c1 13 80 	movl   $0x8013c1,0x8(%esp)
  80051f:	00 
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 34 24             	mov    %esi,(%esp)
  800527:	e8 3e fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052f:	e9 83 fe ff ff       	jmp    8003b7 <vprintfmt+0x25>
  800534:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800537:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80053a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800548:	85 ff                	test   %edi,%edi
  80054a:	b8 b1 13 80 00       	mov    $0x8013b1,%eax
  80054f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800552:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800556:	74 06                	je     80055e <vprintfmt+0x1cc>
  800558:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80055c:	7f 16                	jg     800574 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055e:	0f b6 17             	movzbl (%edi),%edx
  800561:	0f be c2             	movsbl %dl,%eax
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	85 c0                	test   %eax,%eax
  800569:	0f 85 9f 00 00 00    	jne    80060e <vprintfmt+0x27c>
  80056f:	e9 8b 00 00 00       	jmp    8005ff <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800574:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800578:	89 3c 24             	mov    %edi,(%esp)
  80057b:	e8 c2 02 00 00       	call   800842 <strnlen>
  800580:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800583:	29 c2                	sub    %eax,%edx
  800585:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800588:	85 d2                	test   %edx,%edx
  80058a:	7e d2                	jle    80055e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80058c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800590:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800593:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800596:	89 d7                	mov    %edx,%edi
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	83 ef 01             	sub    $0x1,%edi
  8005a7:	75 ef                	jne    800598 <vprintfmt+0x206>
  8005a9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005af:	eb ad                	jmp    80055e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005b5:	74 20                	je     8005d7 <vprintfmt+0x245>
  8005b7:	0f be d2             	movsbl %dl,%edx
  8005ba:	83 ea 20             	sub    $0x20,%edx
  8005bd:	83 fa 5e             	cmp    $0x5e,%edx
  8005c0:	76 15                	jbe    8005d7 <vprintfmt+0x245>
					putch('?', putdat);
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d3:	ff d1                	call   *%ecx
  8005d5:	eb 0f                	jmp    8005e6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	0f b6 17             	movzbl (%edi),%edx
  8005ec:	0f be c2             	movsbl %dl,%eax
  8005ef:	83 c7 01             	add    $0x1,%edi
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	75 24                	jne    80061a <vprintfmt+0x288>
  8005f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005f9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800602:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800606:	0f 8e ab fd ff ff    	jle    8003b7 <vprintfmt+0x25>
  80060c:	eb 20                	jmp    80062e <vprintfmt+0x29c>
  80060e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800611:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800614:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800617:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	85 f6                	test   %esi,%esi
  80061c:	78 93                	js     8005b1 <vprintfmt+0x21f>
  80061e:	83 ee 01             	sub    $0x1,%esi
  800621:	79 8e                	jns    8005b1 <vprintfmt+0x21f>
  800623:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800626:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800629:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80062c:	eb d1                	jmp    8005ff <vprintfmt+0x26d>
  80062e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800631:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800635:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80063c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063e:	83 ef 01             	sub    $0x1,%edi
  800641:	75 ee                	jne    800631 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800646:	e9 6c fd ff ff       	jmp    8003b7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064b:	83 fa 01             	cmp    $0x1,%edx
  80064e:	66 90                	xchg   %ax,%ax
  800650:	7e 16                	jle    800668 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 08             	lea    0x8(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8b 48 04             	mov    0x4(%eax),%ecx
  800660:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800663:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800666:	eb 32                	jmp    80069a <vprintfmt+0x308>
	else if (lflag)
  800668:	85 d2                	test   %edx,%edx
  80066a:	74 18                	je     800684 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067a:	89 c1                	mov    %eax,%ecx
  80067c:	c1 f9 1f             	sar    $0x1f,%ecx
  80067f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800682:	eb 16                	jmp    80069a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800692:	89 c7                	mov    %eax,%edi
  800694:	c1 ff 1f             	sar    $0x1f,%edi
  800697:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80069d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006a9:	79 7d                	jns    800728 <vprintfmt+0x396>
				putch('-', putdat);
  8006ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006af:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006be:	f7 d8                	neg    %eax
  8006c0:	83 d2 00             	adc    $0x0,%edx
  8006c3:	f7 da                	neg    %edx
			}
			base = 10;
  8006c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ca:	eb 5c                	jmp    800728 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cf:	e8 3f fc ff ff       	call   800313 <getuint>
			base = 10;
  8006d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d9:	eb 4d                	jmp    800728 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 30 fc ff ff       	call   800313 <getuint>
      base = 8;
  8006e3:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8006e8:	eb 3e                	jmp    800728 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800702:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 50 04             	lea    0x4(%eax),%edx
  80070a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070d:	8b 00                	mov    (%eax),%eax
  80070f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800719:	eb 0d                	jmp    800728 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 f0 fb ff ff       	call   800313 <getuint>
			base = 16;
  800723:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800728:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80072c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800730:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800733:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800737:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800742:	89 da                	mov    %ebx,%edx
  800744:	89 f0                	mov    %esi,%eax
  800746:	e8 d5 fa ff ff       	call   800220 <printnum>
			break;
  80074b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80074e:	e9 64 fc ff ff       	jmp    8003b7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	89 0c 24             	mov    %ecx,(%esp)
  80075a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80075f:	e9 53 fc ff ff       	jmp    8003b7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800764:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800768:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80076f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800771:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800775:	0f 84 3c fc ff ff    	je     8003b7 <vprintfmt+0x25>
  80077b:	83 ef 01             	sub    $0x1,%edi
  80077e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800782:	75 f7                	jne    80077b <vprintfmt+0x3e9>
  800784:	e9 2e fc ff ff       	jmp    8003b7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800789:	83 c4 4c             	add    $0x4c,%esp
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5f                   	pop    %edi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 28             	sub    $0x28,%esp
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	7e 30                	jle    8007e2 <vsnprintf+0x51>
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 2c                	je     8007e2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	c7 04 24 4d 03 80 00 	movl   $0x80034d,(%esp)
  8007d2:	e8 bb fb ff ff       	call   800392 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e0:	eb 05                	jmp    8007e7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800800:	89 44 24 04          	mov    %eax,0x4(%esp)
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	e8 82 ff ff ff       	call   800791 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	80 3a 00             	cmpb   $0x0,(%edx)
  800829:	74 10                	je     80083b <strlen+0x1b>
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
  800839:	eb 05                	jmp    800840 <strlen+0x20>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 1c                	je     80086c <strnlen+0x2a>
  800850:	80 3b 00             	cmpb   $0x0,(%ebx)
  800853:	74 1e                	je     800873 <strnlen+0x31>
  800855:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80085a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	39 ca                	cmp    %ecx,%edx
  80085e:	74 18                	je     800878 <strnlen+0x36>
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800868:	75 f0                	jne    80085a <strnlen+0x18>
  80086a:	eb 0c                	jmp    800878 <strnlen+0x36>
  80086c:	b8 00 00 00 00       	mov    $0x0,%eax
  800871:	eb 05                	jmp    800878 <strnlen+0x36>
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800885:	89 c2                	mov    %eax,%edx
  800887:	0f b6 19             	movzbl (%ecx),%ebx
  80088a:	88 1a                	mov    %bl,(%edx)
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	84 db                	test   %bl,%bl
  800894:	75 f1                	jne    800887 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a3:	89 1c 24             	mov    %ebx,(%esp)
  8008a6:	e8 75 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b2:	01 d8                	add    %ebx,%eax
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	e8 bf ff ff ff       	call   80087b <strcpy>
	return dst;
}
  8008bc:	89 d8                	mov    %ebx,%eax
  8008be:	83 c4 08             	add    $0x8,%esp
  8008c1:	5b                   	pop    %ebx
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	85 db                	test   %ebx,%ebx
  8008d4:	74 16                	je     8008ec <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	01 f3                	add    %esi,%ebx
  8008d8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008da:	0f b6 02             	movzbl (%edx),%eax
  8008dd:	88 01                	mov    %al,(%ecx)
  8008df:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	39 d9                	cmp    %ebx,%ecx
  8008ea:	75 ee                	jne    8008da <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ec:	89 f0                	mov    %esi,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	57                   	push   %edi
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
  8008f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008fe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800901:	89 f8                	mov    %edi,%eax
  800903:	85 f6                	test   %esi,%esi
  800905:	74 33                	je     80093a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800907:	83 fe 01             	cmp    $0x1,%esi
  80090a:	74 25                	je     800931 <strlcpy+0x3f>
  80090c:	0f b6 0b             	movzbl (%ebx),%ecx
  80090f:	84 c9                	test   %cl,%cl
  800911:	74 22                	je     800935 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800913:	83 ee 02             	sub    $0x2,%esi
  800916:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091b:	88 08                	mov    %cl,(%eax)
  80091d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800920:	39 f2                	cmp    %esi,%edx
  800922:	74 13                	je     800937 <strlcpy+0x45>
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80092b:	84 c9                	test   %cl,%cl
  80092d:	75 ec                	jne    80091b <strlcpy+0x29>
  80092f:	eb 06                	jmp    800937 <strlcpy+0x45>
  800931:	89 f8                	mov    %edi,%eax
  800933:	eb 02                	jmp    800937 <strlcpy+0x45>
  800935:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800937:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093a:	29 f8                	sub    %edi,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094a:	0f b6 01             	movzbl (%ecx),%eax
  80094d:	84 c0                	test   %al,%al
  80094f:	74 15                	je     800966 <strcmp+0x25>
  800951:	3a 02                	cmp    (%edx),%al
  800953:	75 11                	jne    800966 <strcmp+0x25>
		p++, q++;
  800955:	83 c1 01             	add    $0x1,%ecx
  800958:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095b:	0f b6 01             	movzbl (%ecx),%eax
  80095e:	84 c0                	test   %al,%al
  800960:	74 04                	je     800966 <strcmp+0x25>
  800962:	3a 02                	cmp    (%edx),%al
  800964:	74 ef                	je     800955 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80097e:	85 f6                	test   %esi,%esi
  800980:	74 29                	je     8009ab <strncmp+0x3b>
  800982:	0f b6 03             	movzbl (%ebx),%eax
  800985:	84 c0                	test   %al,%al
  800987:	74 30                	je     8009b9 <strncmp+0x49>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	75 2c                	jne    8009b9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80098d:	8d 43 01             	lea    0x1(%ebx),%eax
  800990:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800992:	89 c3                	mov    %eax,%ebx
  800994:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800997:	39 f0                	cmp    %esi,%eax
  800999:	74 17                	je     8009b2 <strncmp+0x42>
  80099b:	0f b6 08             	movzbl (%eax),%ecx
  80099e:	84 c9                	test   %cl,%cl
  8009a0:	74 17                	je     8009b9 <strncmp+0x49>
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	3a 0a                	cmp    (%edx),%cl
  8009a7:	74 e9                	je     800992 <strncmp+0x22>
  8009a9:	eb 0e                	jmp    8009b9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	eb 0f                	jmp    8009c1 <strncmp+0x51>
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb 08                	jmp    8009c1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b9:	0f b6 03             	movzbl (%ebx),%eax
  8009bc:	0f b6 12             	movzbl (%edx),%edx
  8009bf:	29 d0                	sub    %edx,%eax
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009cf:	0f b6 18             	movzbl (%eax),%ebx
  8009d2:	84 db                	test   %bl,%bl
  8009d4:	74 1d                	je     8009f3 <strchr+0x2e>
  8009d6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009d8:	38 d3                	cmp    %dl,%bl
  8009da:	75 06                	jne    8009e2 <strchr+0x1d>
  8009dc:	eb 1a                	jmp    8009f8 <strchr+0x33>
  8009de:	38 ca                	cmp    %cl,%dl
  8009e0:	74 16                	je     8009f8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	75 f2                	jne    8009de <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <strchr+0x33>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a05:	0f b6 18             	movzbl (%eax),%ebx
  800a08:	84 db                	test   %bl,%bl
  800a0a:	74 16                	je     800a22 <strfind+0x27>
  800a0c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a0e:	38 d3                	cmp    %dl,%bl
  800a10:	75 06                	jne    800a18 <strfind+0x1d>
  800a12:	eb 0e                	jmp    800a22 <strfind+0x27>
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 0a                	je     800a22 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	0f b6 10             	movzbl (%eax),%edx
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	75 f2                	jne    800a14 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a22:	5b                   	pop    %ebx
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a31:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3a:	85 c9                	test   %ecx,%ecx
  800a3c:	74 36                	je     800a74 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a44:	75 28                	jne    800a6e <memset+0x49>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 23                	jne    800a6e <memset+0x49>
		c &= 0xFF;
  800a4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	c1 e3 08             	shl    $0x8,%ebx
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	c1 e6 18             	shl    $0x18,%esi
  800a59:	89 d0                	mov    %edx,%eax
  800a5b:	c1 e0 10             	shl    $0x10,%eax
  800a5e:	09 f0                	or     %esi,%eax
  800a60:	09 c2                	or     %eax,%edx
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a66:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a69:	fc                   	cld    
  800a6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6c:	eb 06                	jmp    800a74 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	fc                   	cld    
  800a72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a7f:	89 ec                	mov    %ebp,%esp
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	83 ec 08             	sub    $0x8,%esp
  800a89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 36                	jae    800ad2 <memmove+0x4f>
  800a9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	73 2f                	jae    800ad2 <memmove+0x4f>
		s += n;
		d += n;
  800aa3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f6 c2 03             	test   $0x3,%dl
  800aa9:	75 1b                	jne    800ac6 <memmove+0x43>
  800aab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab1:	75 13                	jne    800ac6 <memmove+0x43>
  800ab3:	f6 c1 03             	test   $0x3,%cl
  800ab6:	75 0e                	jne    800ac6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab8:	83 ef 04             	sub    $0x4,%edi
  800abb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ac1:	fd                   	std    
  800ac2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac4:	eb 09                	jmp    800acf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac6:	83 ef 01             	sub    $0x1,%edi
  800ac9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800acc:	fd                   	std    
  800acd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acf:	fc                   	cld    
  800ad0:	eb 20                	jmp    800af2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad8:	75 13                	jne    800aed <memmove+0x6a>
  800ada:	a8 03                	test   $0x3,%al
  800adc:	75 0f                	jne    800aed <memmove+0x6a>
  800ade:	f6 c1 03             	test   $0x3,%cl
  800ae1:	75 0a                	jne    800aed <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aeb:	eb 05                	jmp    800af2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	fc                   	cld    
  800af0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800af5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800af8:	89 ec                	mov    %ebp,%esp
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 68 ff ff ff       	call   800a83 <memmove>
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 36                	je     800b69 <memcmp+0x4c>
		if (*s1 != *s2)
  800b33:	0f b6 03             	movzbl (%ebx),%eax
  800b36:	0f b6 0e             	movzbl (%esi),%ecx
  800b39:	38 c8                	cmp    %cl,%al
  800b3b:	75 17                	jne    800b54 <memcmp+0x37>
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	eb 1a                	jmp    800b5e <memcmp+0x41>
  800b44:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b50:	38 c8                	cmp    %cl,%al
  800b52:	74 0a                	je     800b5e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b54:	0f b6 c0             	movzbl %al,%eax
  800b57:	0f b6 c9             	movzbl %cl,%ecx
  800b5a:	29 c8                	sub    %ecx,%eax
  800b5c:	eb 10                	jmp    800b6e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5e:	39 fa                	cmp    %edi,%edx
  800b60:	75 e2                	jne    800b44 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	eb 05                	jmp    800b6e <memcmp+0x51>
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b7d:	89 c2                	mov    %eax,%edx
  800b7f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b82:	39 d0                	cmp    %edx,%eax
  800b84:	73 13                	jae    800b99 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b86:	89 d9                	mov    %ebx,%ecx
  800b88:	38 18                	cmp    %bl,(%eax)
  800b8a:	75 06                	jne    800b92 <memfind+0x1f>
  800b8c:	eb 0b                	jmp    800b99 <memfind+0x26>
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 07                	je     800b99 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	39 d0                	cmp    %edx,%eax
  800b97:	75 f5                	jne    800b8e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 04             	sub    $0x4,%esp
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bab:	0f b6 02             	movzbl (%edx),%eax
  800bae:	3c 09                	cmp    $0x9,%al
  800bb0:	74 04                	je     800bb6 <strtol+0x1a>
  800bb2:	3c 20                	cmp    $0x20,%al
  800bb4:	75 0e                	jne    800bc4 <strtol+0x28>
		s++;
  800bb6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb9:	0f b6 02             	movzbl (%edx),%eax
  800bbc:	3c 09                	cmp    $0x9,%al
  800bbe:	74 f6                	je     800bb6 <strtol+0x1a>
  800bc0:	3c 20                	cmp    $0x20,%al
  800bc2:	74 f2                	je     800bb6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc4:	3c 2b                	cmp    $0x2b,%al
  800bc6:	75 0a                	jne    800bd2 <strtol+0x36>
		s++;
  800bc8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd0:	eb 10                	jmp    800be2 <strtol+0x46>
  800bd2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd7:	3c 2d                	cmp    $0x2d,%al
  800bd9:	75 07                	jne    800be2 <strtol+0x46>
		s++, neg = 1;
  800bdb:	83 c2 01             	add    $0x1,%edx
  800bde:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be8:	75 15                	jne    800bff <strtol+0x63>
  800bea:	80 3a 30             	cmpb   $0x30,(%edx)
  800bed:	75 10                	jne    800bff <strtol+0x63>
  800bef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf3:	75 0a                	jne    800bff <strtol+0x63>
		s += 2, base = 16;
  800bf5:	83 c2 02             	add    $0x2,%edx
  800bf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfd:	eb 10                	jmp    800c0f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800bff:	85 db                	test   %ebx,%ebx
  800c01:	75 0c                	jne    800c0f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c03:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c05:	80 3a 30             	cmpb   $0x30,(%edx)
  800c08:	75 05                	jne    800c0f <strtol+0x73>
		s++, base = 8;
  800c0a:	83 c2 01             	add    $0x1,%edx
  800c0d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c17:	0f b6 0a             	movzbl (%edx),%ecx
  800c1a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c1d:	89 f3                	mov    %esi,%ebx
  800c1f:	80 fb 09             	cmp    $0x9,%bl
  800c22:	77 08                	ja     800c2c <strtol+0x90>
			dig = *s - '0';
  800c24:	0f be c9             	movsbl %cl,%ecx
  800c27:	83 e9 30             	sub    $0x30,%ecx
  800c2a:	eb 22                	jmp    800c4e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c2c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c2f:	89 f3                	mov    %esi,%ebx
  800c31:	80 fb 19             	cmp    $0x19,%bl
  800c34:	77 08                	ja     800c3e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c36:	0f be c9             	movsbl %cl,%ecx
  800c39:	83 e9 57             	sub    $0x57,%ecx
  800c3c:	eb 10                	jmp    800c4e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 16                	ja     800c5e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c48:	0f be c9             	movsbl %cl,%ecx
  800c4b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c4e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c51:	7d 0f                	jge    800c62 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c53:	83 c2 01             	add    $0x1,%edx
  800c56:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c5a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c5c:	eb b9                	jmp    800c17 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c5e:	89 c1                	mov    %eax,%ecx
  800c60:	eb 02                	jmp    800c64 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c62:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c68:	74 05                	je     800c6f <strtol+0xd3>
		*endptr = (char *) s;
  800c6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c6f:	89 ca                	mov    %ecx,%edx
  800c71:	f7 da                	neg    %edx
  800c73:	85 ff                	test   %edi,%edi
  800c75:	0f 45 c2             	cmovne %edx,%eax
}
  800c78:	83 c4 04             	add    $0x4,%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	89 c6                	mov    %eax,%esi
  800ca0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cab:	89 ec                	mov    %ebp,%esp
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_cgetc>:

int
sys_cgetc(void)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	89 d3                	mov    %edx,%ebx
  800ccc:	89 d7                	mov    %edx,%edi
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cdb:	89 ec                	mov    %ebp,%esp
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 38             	sub    $0x38,%esp
  800ce5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ceb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 cb                	mov    %ecx,%ebx
  800cfd:	89 cf                	mov    %ecx,%edi
  800cff:	89 ce                	mov    %ecx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800d2a:	e8 19 03 00 00       	call   801048 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_yield>:

void
sys_yield(void)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 38             	sub    $0x38,%esp
  800da2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 04 00 00 00       	mov    $0x4,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	89 f7                	mov    %esi,%edi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800de9:	e8 5a 02 00 00       	call   801048 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df7:	89 ec                	mov    %ebp,%esp
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 38             	sub    $0x38,%esp
  800e01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 28                	jle    800e4c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3f:	00 
  800e40:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800e47:	e8 fc 01 00 00       	call   801048 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e55:	89 ec                	mov    %ebp,%esp
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 38             	sub    $0x38,%esp
  800e5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	89 df                	mov    %ebx,%edi
  800e7a:	89 de                	mov    %ebx,%esi
  800e7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	7e 28                	jle    800eaa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800ea5:	e8 9e 01 00 00       	call   801048 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eaa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ead:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb3:	89 ec                	mov    %ebp,%esp
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 38             	sub    $0x38,%esp
  800ebd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 df                	mov    %ebx,%edi
  800ed8:	89 de                	mov    %ebx,%esi
  800eda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	7e 28                	jle    800f08 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eeb:	00 
  800eec:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f03:	e8 40 01 00 00       	call   801048 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f08:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f11:	89 ec                	mov    %ebp,%esp
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 38             	sub    $0x38,%esp
  800f1b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f1e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f21:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f29:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f31:	8b 55 08             	mov    0x8(%ebp),%edx
  800f34:	89 df                	mov    %ebx,%edi
  800f36:	89 de                	mov    %ebx,%esi
  800f38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	7e 28                	jle    800f66 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f42:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f49:	00 
  800f4a:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800f51:	00 
  800f52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f59:	00 
  800f5a:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800f61:	e8 e2 00 00 00       	call   801048 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6f:	89 ec                	mov    %ebp,%esp
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f82:	be 00 00 00 00       	mov    $0x0,%esi
  800f87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa3:	89 ec                	mov    %ebp,%esp
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 38             	sub    $0x38,%esp
  800fad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 cb                	mov    %ecx,%ebx
  800fc5:	89 cf                	mov    %ecx,%edi
  800fc7:	89 ce                	mov    %ecx,%esi
  800fc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	7e 28                	jle    800ff7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fda:	00 
  800fdb:	c7 44 24 08 e4 15 80 	movl   $0x8015e4,0x8(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fea:	00 
  800feb:	c7 04 24 01 16 80 00 	movl   $0x801601,(%esp)
  800ff2:	e8 51 00 00 00       	call   801048 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ff7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801000:	89 ec                	mov    %ebp,%esp
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80100a:	c7 44 24 08 1b 16 80 	movl   $0x80161b,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 0f 16 80 00 	movl   $0x80160f,(%esp)
  801021:	e8 22 00 00 00       	call   801048 <_panic>

00801026 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80102c:	c7 44 24 08 1a 16 80 	movl   $0x80161a,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 0f 16 80 00 	movl   $0x80160f,(%esp)
  801043:	e8 00 00 00 00       	call   801048 <_panic>

00801048 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801050:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801053:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801059:	e8 de fc ff ff       	call   800d3c <sys_getenvid>
  80105e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801061:	89 54 24 10          	mov    %edx,0x10(%esp)
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801070:	89 44 24 04          	mov    %eax,0x4(%esp)
  801074:	c7 04 24 30 16 80 00 	movl   $0x801630,(%esp)
  80107b:	e8 83 f1 ff ff       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801084:	8b 45 10             	mov    0x10(%ebp),%eax
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 13 f1 ff ff       	call   8001a2 <vcprintf>
	cprintf("\n");
  80108f:	c7 04 24 8f 13 80 00 	movl   $0x80138f,(%esp)
  801096:	e8 68 f1 ff ff       	call   800203 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109b:	cc                   	int3   
  80109c:	eb fd                	jmp    80109b <_panic+0x53>
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
