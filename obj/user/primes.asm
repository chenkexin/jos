
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 a0 10 00 00       	call   8010f8 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  800071:	e8 39 02 00 00       	call   8002af <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 39 10 00 00       	call   8010b4 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 8c 14 80 	movl   $0x80148c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 95 14 80 00 	movl   $0x801495,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 38 10 00 00       	call   8010f8 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 31 10 00 00       	call   80111a <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 bc 0f 00 00       	call   8010b4 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 8c 14 80 	movl   $0x80148c,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 95 14 80 00 	movl   $0x801495,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 d2 0f 00 00       	call   80111a <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80015f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800162:	e8 85 0c 00 00       	call   800dec <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 db                	test   %ebx,%ebx
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 06                	mov    (%esi),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 74 24 04          	mov    %esi,0x4(%esp)
  800188:	89 1c 24             	mov    %ebx,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 dd 0b 00 00       	call   800d8f <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001c5:	e8 22 0c 00 00       	call   800dec <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 b0 14 80 00 	movl   $0x8014b0,(%esp)
  8001e7:	e8 c3 00 00 00       	call   8002af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 53 00 00 00       	call   80024e <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  800202:	e8 a8 00 00 00       	call   8002af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>
	...

0080020c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 14             	sub    $0x14,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 03                	mov    (%ebx),%eax
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021f:	83 c0 01             	add    $0x1,%eax
  800222:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800224:	3d ff 00 00 00       	cmp    $0xff,%eax
  800229:	75 19                	jne    800244 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800232:	00 
  800233:	8d 43 08             	lea    0x8(%ebx),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 f2 0a 00 00       	call   800d30 <sys_cputs>
		b->idx = 0;
  80023e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800244:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800257:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025e:	00 00 00 
	b.cnt = 0;
  800261:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800268:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 44 24 08          	mov    %eax,0x8(%esp)
  800279:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800283:	c7 04 24 0c 02 80 00 	movl   $0x80020c,(%esp)
  80028a:	e8 b3 01 00 00       	call   800442 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 89 0a 00 00       	call   800d30 <sys_cputs>

	return b.cnt;
}
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	e8 87 ff ff ff       	call   80024e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
  8002cb:	00 00                	add    %al,(%eax)
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	89 d7                	mov    %edx,%edi
  8002de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ef:	39 d8                	cmp    %ebx,%eax
  8002f1:	72 17                	jb     80030a <printnum+0x3a>
  8002f3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002f6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002f9:	76 0f                	jbe    80030a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fb:	8b 75 14             	mov    0x14(%ebp),%esi
  8002fe:	83 ee 01             	sub    $0x1,%esi
  800301:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800304:	85 f6                	test   %esi,%esi
  800306:	7f 63                	jg     80036b <printnum+0x9b>
  800308:	eb 75                	jmp    80037f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80030d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800311:	8b 45 14             	mov    0x14(%ebp),%eax
  800314:	83 e8 01             	sub    $0x1,%eax
  800317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800322:	8b 44 24 08          	mov    0x8(%esp),%eax
  800326:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80032a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800330:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800337:	00 
  800338:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80033b:	89 1c 24             	mov    %ebx,(%esp)
  80033e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800341:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800345:	e8 46 0e 00 00       	call   801190 <__udivdi3>
  80034a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80034d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800350:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800354:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035f:	89 fa                	mov    %edi,%edx
  800361:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800364:	e8 67 ff ff ff       	call   8002d0 <printnum>
  800369:	eb 14                	jmp    80037f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036f:	8b 45 18             	mov    0x18(%ebp),%eax
  800372:	89 04 24             	mov    %eax,(%esp)
  800375:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800377:	83 ee 01             	sub    $0x1,%esi
  80037a:	75 ef                	jne    80036b <printnum+0x9b>
  80037c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800383:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80038e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800395:	00 
  800396:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800399:	89 1c 24             	mov    %ebx,(%esp)
  80039c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80039f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a3:	e8 38 0f 00 00       	call   8012e0 <__umoddi3>
  8003a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ac:	0f be 80 d6 14 80 00 	movsbl 0x8014d6(%eax),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b9:	ff d0                	call   *%eax
}
  8003bb:	83 c4 4c             	add    $0x4c,%esp
  8003be:	5b                   	pop    %ebx
  8003bf:	5e                   	pop    %esi
  8003c0:	5f                   	pop    %edi
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c6:	83 fa 01             	cmp    $0x1,%edx
  8003c9:	7e 0e                	jle    8003d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003cb:	8b 10                	mov    (%eax),%edx
  8003cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d0:	89 08                	mov    %ecx,(%eax)
  8003d2:	8b 02                	mov    (%edx),%eax
  8003d4:	8b 52 04             	mov    0x4(%edx),%edx
  8003d7:	eb 22                	jmp    8003fb <getuint+0x38>
	else if (lflag)
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	74 10                	je     8003ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 02                	mov    (%edx),%eax
  8003e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003eb:	eb 0e                	jmp    8003fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800403:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800407:	8b 10                	mov    (%eax),%edx
  800409:	3b 50 04             	cmp    0x4(%eax),%edx
  80040c:	73 0a                	jae    800418 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800411:	88 0a                	mov    %cl,(%edx)
  800413:	83 c2 01             	add    $0x1,%edx
  800416:	89 10                	mov    %edx,(%eax)
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800420:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800427:	8b 45 10             	mov    0x10(%ebp),%eax
  80042a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800431:	89 44 24 04          	mov    %eax,0x4(%esp)
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	e8 02 00 00 00       	call   800442 <vprintfmt>
	va_end(ap);
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	57                   	push   %edi
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
  800448:	83 ec 4c             	sub    $0x4c,%esp
  80044b:	8b 75 08             	mov    0x8(%ebp),%esi
  80044e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800451:	8b 7d 10             	mov    0x10(%ebp),%edi
  800454:	eb 11                	jmp    800467 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800456:	85 c0                	test   %eax,%eax
  800458:	0f 84 db 03 00 00    	je     800839 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80045e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800462:	89 04 24             	mov    %eax,(%esp)
  800465:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800467:	0f b6 07             	movzbl (%edi),%eax
  80046a:	83 c7 01             	add    $0x1,%edi
  80046d:	83 f8 25             	cmp    $0x25,%eax
  800470:	75 e4                	jne    800456 <vprintfmt+0x14>
  800472:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800476:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80047d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800484:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 2b                	jmp    8004bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800495:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800499:	eb 22                	jmp    8004bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8004a2:	eb 19                	jmp    8004bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	0f b6 0f             	movzbl (%edi),%ecx
  8004c0:	8d 47 01             	lea    0x1(%edi),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	0f b6 07             	movzbl (%edi),%eax
  8004c9:	83 e8 23             	sub    $0x23,%eax
  8004cc:	3c 55                	cmp    $0x55,%al
  8004ce:	0f 87 40 03 00 00    	ja     800814 <vprintfmt+0x3d2>
  8004d4:	0f b6 c0             	movzbl %al,%eax
  8004d7:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004de:	83 e9 30             	sub    $0x30,%ecx
  8004e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004e4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004e8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004eb:	83 f9 09             	cmp    $0x9,%ecx
  8004ee:	77 57                	ja     800547 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004ff:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800503:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800506:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800509:	83 f9 09             	cmp    $0x9,%ecx
  80050c:	76 eb                	jbe    8004f9 <vprintfmt+0xb7>
  80050e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800511:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800514:	eb 34                	jmp    80054a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 48 04             	lea    0x4(%eax),%ecx
  80051c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 21                	jmp    80054a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	0f 88 71 ff ff ff    	js     8004a4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800536:	eb 85                	jmp    8004bd <vprintfmt+0x7b>
  800538:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80053b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800542:	e9 76 ff ff ff       	jmp    8004bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80054a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054e:	0f 89 69 ff ff ff    	jns    8004bd <vprintfmt+0x7b>
  800554:	e9 57 ff ff ff       	jmp    8004b0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800559:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055f:	e9 59 ff ff ff       	jmp    8004bd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057b:	e9 e7 fe ff ff       	jmp    800467 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 c2                	mov    %eax,%edx
  80058d:	c1 fa 1f             	sar    $0x1f,%edx
  800590:	31 d0                	xor    %edx,%eax
  800592:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800594:	83 f8 08             	cmp    $0x8,%eax
  800597:	7f 0b                	jg     8005a4 <vprintfmt+0x162>
  800599:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	75 20                	jne    8005c4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8005a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a8:	c7 44 24 08 ee 14 80 	movl   $0x8014ee,0x8(%esp)
  8005af:	00 
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	89 34 24             	mov    %esi,(%esp)
  8005b7:	e8 5e fe ff ff       	call   80041a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005bf:	e9 a3 fe ff ff       	jmp    800467 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c8:	c7 44 24 08 f7 14 80 	movl   $0x8014f7,0x8(%esp)
  8005cf:	00 
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 34 24             	mov    %esi,(%esp)
  8005d7:	e8 3e fe ff ff       	call   80041a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005df:	e9 83 fe ff ff       	jmp    800467 <vprintfmt+0x25>
  8005e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f8:	85 ff                	test   %edi,%edi
  8005fa:	b8 e7 14 80 00       	mov    $0x8014e7,%eax
  8005ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800602:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800606:	74 06                	je     80060e <vprintfmt+0x1cc>
  800608:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80060c:	7f 16                	jg     800624 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	0f b6 17             	movzbl (%edi),%edx
  800611:	0f be c2             	movsbl %dl,%eax
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	85 c0                	test   %eax,%eax
  800619:	0f 85 9f 00 00 00    	jne    8006be <vprintfmt+0x27c>
  80061f:	e9 8b 00 00 00       	jmp    8006af <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800628:	89 3c 24             	mov    %edi,(%esp)
  80062b:	e8 c2 02 00 00       	call   8008f2 <strnlen>
  800630:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800638:	85 d2                	test   %edx,%edx
  80063a:	7e d2                	jle    80060e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80063c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800640:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800643:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800646:	89 d7                	mov    %edx,%edi
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800654:	83 ef 01             	sub    $0x1,%edi
  800657:	75 ef                	jne    800648 <vprintfmt+0x206>
  800659:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80065c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80065f:	eb ad                	jmp    80060e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800661:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800665:	74 20                	je     800687 <vprintfmt+0x245>
  800667:	0f be d2             	movsbl %dl,%edx
  80066a:	83 ea 20             	sub    $0x20,%edx
  80066d:	83 fa 5e             	cmp    $0x5e,%edx
  800670:	76 15                	jbe    800687 <vprintfmt+0x245>
					putch('?', putdat);
  800672:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800675:	89 54 24 04          	mov    %edx,0x4(%esp)
  800679:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800680:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800683:	ff d1                	call   *%ecx
  800685:	eb 0f                	jmp    800696 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800687:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068e:	89 04 24             	mov    %eax,(%esp)
  800691:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800694:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800696:	83 eb 01             	sub    $0x1,%ebx
  800699:	0f b6 17             	movzbl (%edi),%edx
  80069c:	0f be c2             	movsbl %dl,%eax
  80069f:	83 c7 01             	add    $0x1,%edi
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	75 24                	jne    8006ca <vprintfmt+0x288>
  8006a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b6:	0f 8e ab fd ff ff    	jle    800467 <vprintfmt+0x25>
  8006bc:	eb 20                	jmp    8006de <vprintfmt+0x29c>
  8006be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006c7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	85 f6                	test   %esi,%esi
  8006cc:	78 93                	js     800661 <vprintfmt+0x21f>
  8006ce:	83 ee 01             	sub    $0x1,%esi
  8006d1:	79 8e                	jns    800661 <vprintfmt+0x21f>
  8006d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006d6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006dc:	eb d1                	jmp    8006af <vprintfmt+0x26d>
  8006de:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	75 ee                	jne    8006e1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006f6:	e9 6c fd ff ff       	jmp    800467 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 fa 01             	cmp    $0x1,%edx
  8006fe:	66 90                	xchg   %ax,%ax
  800700:	7e 16                	jle    800718 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 08             	lea    0x8(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800713:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800716:	eb 32                	jmp    80074a <vprintfmt+0x308>
	else if (lflag)
  800718:	85 d2                	test   %edx,%edx
  80071a:	74 18                	je     800734 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 00                	mov    (%eax),%eax
  800727:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80072a:	89 c1                	mov    %eax,%ecx
  80072c:	c1 f9 1f             	sar    $0x1f,%ecx
  80072f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800732:	eb 16                	jmp    80074a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8d 50 04             	lea    0x4(%eax),%edx
  80073a:	89 55 14             	mov    %edx,0x14(%ebp)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800742:	89 c7                	mov    %eax,%edi
  800744:	c1 ff 1f             	sar    $0x1f,%edi
  800747:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80074d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800750:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800755:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800759:	79 7d                	jns    8007d8 <vprintfmt+0x396>
				putch('-', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800766:	ff d6                	call   *%esi
				num = -(long long) num;
  800768:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80076b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80076e:	f7 d8                	neg    %eax
  800770:	83 d2 00             	adc    $0x0,%edx
  800773:	f7 da                	neg    %edx
			}
			base = 10;
  800775:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077a:	eb 5c                	jmp    8007d8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
  80077f:	e8 3f fc ff ff       	call   8003c3 <getuint>
			base = 10;
  800784:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800789:	eb 4d                	jmp    8007d8 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 30 fc ff ff       	call   8003c3 <getuint>
      base = 8;
  800793:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800798:	eb 3e                	jmp    8007d8 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c9:	eb 0d                	jmp    8007d8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	e8 f0 fb ff ff       	call   8003c3 <getuint>
			base = 16;
  8007d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007dc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007e0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f2:	89 da                	mov    %ebx,%edx
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	e8 d5 fa ff ff       	call   8002d0 <printnum>
			break;
  8007fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007fe:	e9 64 fc ff ff       	jmp    800467 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800807:	89 0c 24             	mov    %ecx,(%esp)
  80080a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80080f:	e9 53 fc ff ff       	jmp    800467 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800814:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800818:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80081f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800821:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800825:	0f 84 3c fc ff ff    	je     800467 <vprintfmt+0x25>
  80082b:	83 ef 01             	sub    $0x1,%edi
  80082e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800832:	75 f7                	jne    80082b <vprintfmt+0x3e9>
  800834:	e9 2e fc ff ff       	jmp    800467 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800839:	83 c4 4c             	add    $0x4c,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5f                   	pop    %edi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 28             	sub    $0x28,%esp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800850:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800854:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800857:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 30                	jle    800892 <vsnprintf+0x51>
  800862:	85 c0                	test   %eax,%eax
  800864:	74 2c                	je     800892 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
  800870:	89 44 24 08          	mov    %eax,0x8(%esp)
  800874:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	c7 04 24 fd 03 80 00 	movl   $0x8003fd,(%esp)
  800882:	e8 bb fb ff ff       	call   800442 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800890:	eb 05                	jmp    800897 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	89 04 24             	mov    %eax,(%esp)
  8008ba:	e8 82 ff ff ff       	call   800841 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    
	...

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008d9:	74 10                	je     8008eb <strlen+0x1b>
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e7:	75 f7                	jne    8008e0 <strlen+0x10>
  8008e9:	eb 05                	jmp    8008f0 <strlen+0x20>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 1c                	je     80091c <strnlen+0x2a>
  800900:	80 3b 00             	cmpb   $0x0,(%ebx)
  800903:	74 1e                	je     800923 <strnlen+0x31>
  800905:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80090a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	39 ca                	cmp    %ecx,%edx
  80090e:	74 18                	je     800928 <strnlen+0x36>
  800910:	83 c2 01             	add    $0x1,%edx
  800913:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800918:	75 f0                	jne    80090a <strnlen+0x18>
  80091a:	eb 0c                	jmp    800928 <strnlen+0x36>
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 05                	jmp    800928 <strnlen+0x36>
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800928:	5b                   	pop    %ebx
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800935:	89 c2                	mov    %eax,%edx
  800937:	0f b6 19             	movzbl (%ecx),%ebx
  80093a:	88 1a                	mov    %bl,(%edx)
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	84 db                	test   %bl,%bl
  800944:	75 f1                	jne    800937 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800953:	89 1c 24             	mov    %ebx,(%esp)
  800956:	e8 75 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800962:	01 d8                	add    %ebx,%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 bf ff ff ff       	call   80092b <strcpy>
	return dst;
}
  80096c:	89 d8                	mov    %ebx,%eax
  80096e:	83 c4 08             	add    $0x8,%esp
  800971:	5b                   	pop    %ebx
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 75 08             	mov    0x8(%ebp),%esi
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800982:	85 db                	test   %ebx,%ebx
  800984:	74 16                	je     80099c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800986:	01 f3                	add    %esi,%ebx
  800988:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80098a:	0f b6 02             	movzbl (%edx),%eax
  80098d:	88 01                	mov    %al,(%ecx)
  80098f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800992:	80 3a 01             	cmpb   $0x1,(%edx)
  800995:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	39 d9                	cmp    %ebx,%ecx
  80099a:	75 ee                	jne    80098a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099c:	89 f0                	mov    %esi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ae:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b1:	89 f8                	mov    %edi,%eax
  8009b3:	85 f6                	test   %esi,%esi
  8009b5:	74 33                	je     8009ea <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8009b7:	83 fe 01             	cmp    $0x1,%esi
  8009ba:	74 25                	je     8009e1 <strlcpy+0x3f>
  8009bc:	0f b6 0b             	movzbl (%ebx),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	74 22                	je     8009e5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009c3:	83 ee 02             	sub    $0x2,%esi
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cb:	88 08                	mov    %cl,(%eax)
  8009cd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d0:	39 f2                	cmp    %esi,%edx
  8009d2:	74 13                	je     8009e7 <strlcpy+0x45>
  8009d4:	83 c2 01             	add    $0x1,%edx
  8009d7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009db:	84 c9                	test   %cl,%cl
  8009dd:	75 ec                	jne    8009cb <strlcpy+0x29>
  8009df:	eb 06                	jmp    8009e7 <strlcpy+0x45>
  8009e1:	89 f8                	mov    %edi,%eax
  8009e3:	eb 02                	jmp    8009e7 <strlcpy+0x45>
  8009e5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ea:	29 f8                	sub    %edi,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	84 c0                	test   %al,%al
  8009ff:	74 15                	je     800a16 <strcmp+0x25>
  800a01:	3a 02                	cmp    (%edx),%al
  800a03:	75 11                	jne    800a16 <strcmp+0x25>
		p++, q++;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	84 c0                	test   %al,%al
  800a10:	74 04                	je     800a16 <strcmp+0x25>
  800a12:	3a 02                	cmp    (%edx),%al
  800a14:	74 ef                	je     800a05 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 12             	movzbl (%edx),%edx
  800a1c:	29 d0                	sub    %edx,%eax
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a2e:	85 f6                	test   %esi,%esi
  800a30:	74 29                	je     800a5b <strncmp+0x3b>
  800a32:	0f b6 03             	movzbl (%ebx),%eax
  800a35:	84 c0                	test   %al,%al
  800a37:	74 30                	je     800a69 <strncmp+0x49>
  800a39:	3a 02                	cmp    (%edx),%al
  800a3b:	75 2c                	jne    800a69 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a3d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a40:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a42:	89 c3                	mov    %eax,%ebx
  800a44:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a47:	39 f0                	cmp    %esi,%eax
  800a49:	74 17                	je     800a62 <strncmp+0x42>
  800a4b:	0f b6 08             	movzbl (%eax),%ecx
  800a4e:	84 c9                	test   %cl,%cl
  800a50:	74 17                	je     800a69 <strncmp+0x49>
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	3a 0a                	cmp    (%edx),%cl
  800a57:	74 e9                	je     800a42 <strncmp+0x22>
  800a59:	eb 0e                	jmp    800a69 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	eb 0f                	jmp    800a71 <strncmp+0x51>
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	eb 08                	jmp    800a71 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a69:	0f b6 03             	movzbl (%ebx),%eax
  800a6c:	0f b6 12             	movzbl (%edx),%edx
  800a6f:	29 d0                	sub    %edx,%eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a7f:	0f b6 18             	movzbl (%eax),%ebx
  800a82:	84 db                	test   %bl,%bl
  800a84:	74 1d                	je     800aa3 <strchr+0x2e>
  800a86:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a88:	38 d3                	cmp    %dl,%bl
  800a8a:	75 06                	jne    800a92 <strchr+0x1d>
  800a8c:	eb 1a                	jmp    800aa8 <strchr+0x33>
  800a8e:	38 ca                	cmp    %cl,%dl
  800a90:	74 16                	je     800aa8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 f2                	jne    800a8e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa1:	eb 05                	jmp    800aa8 <strchr+0x33>
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ab5:	0f b6 18             	movzbl (%eax),%ebx
  800ab8:	84 db                	test   %bl,%bl
  800aba:	74 16                	je     800ad2 <strfind+0x27>
  800abc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800abe:	38 d3                	cmp    %dl,%bl
  800ac0:	75 06                	jne    800ac8 <strfind+0x1d>
  800ac2:	eb 0e                	jmp    800ad2 <strfind+0x27>
  800ac4:	38 ca                	cmp    %cl,%dl
  800ac6:	74 0a                	je     800ad2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	0f b6 10             	movzbl (%eax),%edx
  800ace:	84 d2                	test   %dl,%dl
  800ad0:	75 f2                	jne    800ac4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 0c             	sub    $0xc,%esp
  800adb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ade:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ae1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aea:	85 c9                	test   %ecx,%ecx
  800aec:	74 36                	je     800b24 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af4:	75 28                	jne    800b1e <memset+0x49>
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 23                	jne    800b1e <memset+0x49>
		c &= 0xFF;
  800afb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	c1 e3 08             	shl    $0x8,%ebx
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	c1 e6 18             	shl    $0x18,%esi
  800b09:	89 d0                	mov    %edx,%eax
  800b0b:	c1 e0 10             	shl    $0x10,%eax
  800b0e:	09 f0                	or     %esi,%eax
  800b10:	09 c2                	or     %eax,%edx
  800b12:	89 d0                	mov    %edx,%eax
  800b14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b19:	fc                   	cld    
  800b1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1c:	eb 06                	jmp    800b24 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	fc                   	cld    
  800b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b2f:	89 ec                	mov    %ebp,%esp
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b48:	39 c6                	cmp    %eax,%esi
  800b4a:	73 36                	jae    800b82 <memmove+0x4f>
  800b4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4f:	39 d0                	cmp    %edx,%eax
  800b51:	73 2f                	jae    800b82 <memmove+0x4f>
		s += n;
		d += n;
  800b53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b56:	f6 c2 03             	test   $0x3,%dl
  800b59:	75 1b                	jne    800b76 <memmove+0x43>
  800b5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b61:	75 13                	jne    800b76 <memmove+0x43>
  800b63:	f6 c1 03             	test   $0x3,%cl
  800b66:	75 0e                	jne    800b76 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b68:	83 ef 04             	sub    $0x4,%edi
  800b6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b71:	fd                   	std    
  800b72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b74:	eb 09                	jmp    800b7f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b76:	83 ef 01             	sub    $0x1,%edi
  800b79:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7c:	fd                   	std    
  800b7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7f:	fc                   	cld    
  800b80:	eb 20                	jmp    800ba2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b88:	75 13                	jne    800b9d <memmove+0x6a>
  800b8a:	a8 03                	test   $0x3,%al
  800b8c:	75 0f                	jne    800b9d <memmove+0x6a>
  800b8e:	f6 c1 03             	test   $0x3,%cl
  800b91:	75 0a                	jne    800b9d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b93:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	fc                   	cld    
  800b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9b:	eb 05                	jmp    800ba2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9d:	89 c7                	mov    %eax,%edi
  800b9f:	fc                   	cld    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba8:	89 ec                	mov    %ebp,%esp
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	89 04 24             	mov    %eax,(%esp)
  800bc6:	e8 68 ff ff ff       	call   800b33 <memmove>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	74 36                	je     800c19 <memcmp+0x4c>
		if (*s1 != *s2)
  800be3:	0f b6 03             	movzbl (%ebx),%eax
  800be6:	0f b6 0e             	movzbl (%esi),%ecx
  800be9:	38 c8                	cmp    %cl,%al
  800beb:	75 17                	jne    800c04 <memcmp+0x37>
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	eb 1a                	jmp    800c0e <memcmp+0x41>
  800bf4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bf9:	83 c2 01             	add    $0x1,%edx
  800bfc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c00:	38 c8                	cmp    %cl,%al
  800c02:	74 0a                	je     800c0e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c04:	0f b6 c0             	movzbl %al,%eax
  800c07:	0f b6 c9             	movzbl %cl,%ecx
  800c0a:	29 c8                	sub    %ecx,%eax
  800c0c:	eb 10                	jmp    800c1e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0e:	39 fa                	cmp    %edi,%edx
  800c10:	75 e2                	jne    800bf4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
  800c17:	eb 05                	jmp    800c1e <memcmp+0x51>
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	53                   	push   %ebx
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c32:	39 d0                	cmp    %edx,%eax
  800c34:	73 13                	jae    800c49 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c36:	89 d9                	mov    %ebx,%ecx
  800c38:	38 18                	cmp    %bl,(%eax)
  800c3a:	75 06                	jne    800c42 <memfind+0x1f>
  800c3c:	eb 0b                	jmp    800c49 <memfind+0x26>
  800c3e:	38 08                	cmp    %cl,(%eax)
  800c40:	74 07                	je     800c49 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c42:	83 c0 01             	add    $0x1,%eax
  800c45:	39 d0                	cmp    %edx,%eax
  800c47:	75 f5                	jne    800c3e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 04             	sub    $0x4,%esp
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5b:	0f b6 02             	movzbl (%edx),%eax
  800c5e:	3c 09                	cmp    $0x9,%al
  800c60:	74 04                	je     800c66 <strtol+0x1a>
  800c62:	3c 20                	cmp    $0x20,%al
  800c64:	75 0e                	jne    800c74 <strtol+0x28>
		s++;
  800c66:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	0f b6 02             	movzbl (%edx),%eax
  800c6c:	3c 09                	cmp    $0x9,%al
  800c6e:	74 f6                	je     800c66 <strtol+0x1a>
  800c70:	3c 20                	cmp    $0x20,%al
  800c72:	74 f2                	je     800c66 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c74:	3c 2b                	cmp    $0x2b,%al
  800c76:	75 0a                	jne    800c82 <strtol+0x36>
		s++;
  800c78:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 10                	jmp    800c92 <strtol+0x46>
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c87:	3c 2d                	cmp    $0x2d,%al
  800c89:	75 07                	jne    800c92 <strtol+0x46>
		s++, neg = 1;
  800c8b:	83 c2 01             	add    $0x1,%edx
  800c8e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c98:	75 15                	jne    800caf <strtol+0x63>
  800c9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c9d:	75 10                	jne    800caf <strtol+0x63>
  800c9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca3:	75 0a                	jne    800caf <strtol+0x63>
		s += 2, base = 16;
  800ca5:	83 c2 02             	add    $0x2,%edx
  800ca8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cad:	eb 10                	jmp    800cbf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800caf:	85 db                	test   %ebx,%ebx
  800cb1:	75 0c                	jne    800cbf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb8:	75 05                	jne    800cbf <strtol+0x73>
		s++, base = 8;
  800cba:	83 c2 01             	add    $0x1,%edx
  800cbd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc7:	0f b6 0a             	movzbl (%edx),%ecx
  800cca:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 09             	cmp    $0x9,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0x90>
			dig = *s - '0';
  800cd4:	0f be c9             	movsbl %cl,%ecx
  800cd7:	83 e9 30             	sub    $0x30,%ecx
  800cda:	eb 22                	jmp    800cfe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800cdc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	80 fb 19             	cmp    $0x19,%bl
  800ce4:	77 08                	ja     800cee <strtol+0xa2>
			dig = *s - 'a' + 10;
  800ce6:	0f be c9             	movsbl %cl,%ecx
  800ce9:	83 e9 57             	sub    $0x57,%ecx
  800cec:	eb 10                	jmp    800cfe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cee:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cf1:	89 f3                	mov    %esi,%ebx
  800cf3:	80 fb 19             	cmp    $0x19,%bl
  800cf6:	77 16                	ja     800d0e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800cf8:	0f be c9             	movsbl %cl,%ecx
  800cfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cfe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d01:	7d 0f                	jge    800d12 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d03:	83 c2 01             	add    $0x1,%edx
  800d06:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800d0a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d0c:	eb b9                	jmp    800cc7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d0e:	89 c1                	mov    %eax,%ecx
  800d10:	eb 02                	jmp    800d14 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d12:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d18:	74 05                	je     800d1f <strtol+0xd3>
		*endptr = (char *) s;
  800d1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d1d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d1f:	89 ca                	mov    %ecx,%edx
  800d21:	f7 da                	neg    %edx
  800d23:	85 ff                	test   %edi,%edi
  800d25:	0f 45 c2             	cmovne %edx,%eax
}
  800d28:	83 c4 04             	add    $0x4,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	89 c6                	mov    %eax,%esi
  800d50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d73:	b8 01 00 00 00       	mov    $0x1,%eax
  800d78:	89 d1                	mov    %edx,%ecx
  800d7a:	89 d3                	mov    %edx,%ebx
  800d7c:	89 d7                	mov    %edx,%edi
  800d7e:	89 d6                	mov    %edx,%esi
  800d80:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8b:	89 ec                	mov    %ebp,%esp
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 38             	sub    $0x38,%esp
  800d95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 03 00 00 00       	mov    $0x3,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 28                	jle    800ddf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800dda:	e8 d5 f3 ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 02 00 00 00       	mov    $0x2,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_yield>:

void
sys_yield(void)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 38             	sub    $0x38,%esp
  800e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	be 00 00 00 00       	mov    $0x0,%esi
  800e60:	b8 04 00 00 00       	mov    $0x4,%eax
  800e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6e:	89 f7                	mov    %esi,%edi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800e99:	e8 16 f3 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea7:	89 ec                	mov    %ebp,%esp
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 38             	sub    $0x38,%esp
  800eb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecb:	8b 75 18             	mov    0x18(%ebp),%esi
  800ece:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 28                	jle    800efc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800edf:	00 
  800ee0:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eef:	00 
  800ef0:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800ef7:	e8 b8 f2 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f05:	89 ec                	mov    %ebp,%esp
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 38             	sub    $0x38,%esp
  800f0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 28                	jle    800f5a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f36:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800f55:	e8 5a f2 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 38             	sub    $0x38,%esp
  800f6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f73:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800fb3:	e8 fc f1 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc1:	89 ec                	mov    %ebp,%esp
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 38             	sub    $0x38,%esp
  800fcb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 28                	jle    801016 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801009:	00 
  80100a:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  801011:	e8 9e f1 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801016:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801019:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101f:	89 ec                	mov    %ebp,%esp
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	be 00 00 00 00       	mov    $0x0,%esi
  801037:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801045:	8b 7d 14             	mov    0x14(%ebp),%edi
  801048:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801050:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801053:	89 ec                	mov    %ebp,%esp
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 38             	sub    $0x38,%esp
  80105d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801060:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801063:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	89 cb                	mov    %ecx,%ebx
  801075:	89 cf                	mov    %ecx,%edi
  801077:	89 ce                	mov    %ecx,%esi
  801079:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107b:	85 c0                	test   %eax,%eax
  80107d:	7e 28                	jle    8010a7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801083:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80108a:	00 
  80108b:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  8010a2:	e8 0d f1 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b0:	89 ec                	mov    %ebp,%esp
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  8010ba:	c7 44 24 08 5b 17 80 	movl   $0x80175b,0x8(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010c9:	00 
  8010ca:	c7 04 24 4f 17 80 00 	movl   $0x80174f,(%esp)
  8010d1:	e8 de f0 ff ff       	call   8001b4 <_panic>

008010d6 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010dc:	c7 44 24 08 5a 17 80 	movl   $0x80175a,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 4f 17 80 00 	movl   $0x80174f,(%esp)
  8010f3:	e8 bc f0 ff ff       	call   8001b4 <_panic>

008010f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8010fe:	c7 44 24 08 70 17 80 	movl   $0x801770,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 89 17 80 00 	movl   $0x801789,(%esp)
  801115:	e8 9a f0 ff ff       	call   8001b4 <_panic>

0080111a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801120:	c7 44 24 08 93 17 80 	movl   $0x801793,0x8(%esp)
  801127:	00 
  801128:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 89 17 80 00 	movl   $0x801789,(%esp)
  801137:	e8 78 f0 ff ff       	call   8001b4 <_panic>

0080113c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801142:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801147:	39 c8                	cmp    %ecx,%eax
  801149:	74 17                	je     801162 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80114b:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801150:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801153:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801159:	8b 52 50             	mov    0x50(%edx),%edx
  80115c:	39 ca                	cmp    %ecx,%edx
  80115e:	75 14                	jne    801174 <ipc_find_env+0x38>
  801160:	eb 05                	jmp    801167 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801167:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116a:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80116f:	8b 40 40             	mov    0x40(%eax),%eax
  801172:	eb 0e                	jmp    801182 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801174:	83 c0 01             	add    $0x1,%eax
  801177:	3d 00 04 00 00       	cmp    $0x400,%eax
  80117c:	75 d2                	jne    801150 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80117e:	66 b8 00 00          	mov    $0x0,%ax
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
	...

00801190 <__udivdi3>:
  801190:	83 ec 1c             	sub    $0x1c,%esp
  801193:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801197:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80119b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80119f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011a3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8011a7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011b5:	89 ea                	mov    %ebp,%edx
  8011b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011bb:	75 33                	jne    8011f0 <__udivdi3+0x60>
  8011bd:	39 e9                	cmp    %ebp,%ecx
  8011bf:	77 6f                	ja     801230 <__udivdi3+0xa0>
  8011c1:	85 c9                	test   %ecx,%ecx
  8011c3:	89 ce                	mov    %ecx,%esi
  8011c5:	75 0b                	jne    8011d2 <__udivdi3+0x42>
  8011c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cc:	31 d2                	xor    %edx,%edx
  8011ce:	f7 f1                	div    %ecx
  8011d0:	89 c6                	mov    %eax,%esi
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	89 e8                	mov    %ebp,%eax
  8011d6:	f7 f6                	div    %esi
  8011d8:	89 c5                	mov    %eax,%ebp
  8011da:	89 f8                	mov    %edi,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 ea                	mov    %ebp,%edx
  8011e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ec:	83 c4 1c             	add    $0x1c,%esp
  8011ef:	c3                   	ret    
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x88>
  8011f4:	0f bd c8             	bsr    %eax,%ecx
  8011f7:	83 f1 1f             	xor    $0x1f,%ecx
  8011fa:	89 0c 24             	mov    %ecx,(%esp)
  8011fd:	75 49                	jne    801248 <__udivdi3+0xb8>
  8011ff:	8b 74 24 08          	mov    0x8(%esp),%esi
  801203:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801207:	0f 86 ab 00 00 00    	jbe    8012b8 <__udivdi3+0x128>
  80120d:	39 e8                	cmp    %ebp,%eax
  80120f:	0f 82 a3 00 00 00    	jb     8012b8 <__udivdi3+0x128>
  801215:	8d 76 00             	lea    0x0(%esi),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801220:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801224:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801228:	83 c4 1c             	add    $0x1c,%esp
  80122b:	c3                   	ret    
  80122c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 f8                	mov    %edi,%eax
  801232:	f7 f1                	div    %ecx
  801234:	31 d2                	xor    %edx,%edx
  801236:	8b 74 24 10          	mov    0x10(%esp),%esi
  80123a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80123e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801242:	83 c4 1c             	add    $0x1c,%esp
  801245:	c3                   	ret    
  801246:	66 90                	xchg   %ax,%ax
  801248:	0f b6 0c 24          	movzbl (%esp),%ecx
  80124c:	89 c6                	mov    %eax,%esi
  80124e:	b8 20 00 00 00       	mov    $0x20,%eax
  801253:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801257:	2b 04 24             	sub    (%esp),%eax
  80125a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80125e:	d3 e6                	shl    %cl,%esi
  801260:	89 c1                	mov    %eax,%ecx
  801262:	d3 ed                	shr    %cl,%ebp
  801264:	0f b6 0c 24          	movzbl (%esp),%ecx
  801268:	09 f5                	or     %esi,%ebp
  80126a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80126e:	d3 e6                	shl    %cl,%esi
  801270:	89 c1                	mov    %eax,%ecx
  801272:	89 74 24 04          	mov    %esi,0x4(%esp)
  801276:	89 d6                	mov    %edx,%esi
  801278:	d3 ee                	shr    %cl,%esi
  80127a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	89 c1                	mov    %eax,%ecx
  801282:	d3 ef                	shr    %cl,%edi
  801284:	09 d7                	or     %edx,%edi
  801286:	89 f2                	mov    %esi,%edx
  801288:	89 f8                	mov    %edi,%eax
  80128a:	f7 f5                	div    %ebp
  80128c:	89 d6                	mov    %edx,%esi
  80128e:	89 c7                	mov    %eax,%edi
  801290:	f7 64 24 04          	mull   0x4(%esp)
  801294:	39 d6                	cmp    %edx,%esi
  801296:	72 30                	jb     8012c8 <__udivdi3+0x138>
  801298:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80129c:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012a0:	d3 e5                	shl    %cl,%ebp
  8012a2:	39 c5                	cmp    %eax,%ebp
  8012a4:	73 04                	jae    8012aa <__udivdi3+0x11a>
  8012a6:	39 d6                	cmp    %edx,%esi
  8012a8:	74 1e                	je     8012c8 <__udivdi3+0x138>
  8012aa:	89 f8                	mov    %edi,%eax
  8012ac:	31 d2                	xor    %edx,%edx
  8012ae:	e9 69 ff ff ff       	jmp    80121c <__udivdi3+0x8c>
  8012b3:	90                   	nop
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bf:	e9 58 ff ff ff       	jmp    80121c <__udivdi3+0x8c>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012d1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012d5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012d9:	83 c4 1c             	add    $0x1c,%esp
  8012dc:	c3                   	ret    
  8012dd:	00 00                	add    %al,(%eax)
	...

008012e0 <__umoddi3>:
  8012e0:	83 ec 2c             	sub    $0x2c,%esp
  8012e3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012e7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012eb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8012ef:	8b 74 24 38          	mov    0x38(%esp),%esi
  8012f3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8012f7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801303:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801307:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80130b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80130f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801313:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801317:	75 1f                	jne    801338 <__umoddi3+0x58>
  801319:	39 fe                	cmp    %edi,%esi
  80131b:	76 63                	jbe    801380 <__umoddi3+0xa0>
  80131d:	89 c8                	mov    %ecx,%eax
  80131f:	89 fa                	mov    %edi,%edx
  801321:	f7 f6                	div    %esi
  801323:	89 d0                	mov    %edx,%eax
  801325:	31 d2                	xor    %edx,%edx
  801327:	8b 74 24 20          	mov    0x20(%esp),%esi
  80132b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80132f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801333:	83 c4 2c             	add    $0x2c,%esp
  801336:	c3                   	ret    
  801337:	90                   	nop
  801338:	39 f8                	cmp    %edi,%eax
  80133a:	77 64                	ja     8013a0 <__umoddi3+0xc0>
  80133c:	0f bd e8             	bsr    %eax,%ebp
  80133f:	83 f5 1f             	xor    $0x1f,%ebp
  801342:	75 74                	jne    8013b8 <__umoddi3+0xd8>
  801344:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801348:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80134c:	0f 87 0e 01 00 00    	ja     801460 <__umoddi3+0x180>
  801352:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801356:	29 f1                	sub    %esi,%ecx
  801358:	19 c7                	sbb    %eax,%edi
  80135a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80135e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801362:	8b 44 24 14          	mov    0x14(%esp),%eax
  801366:	8b 54 24 18          	mov    0x18(%esp),%edx
  80136a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80136e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801372:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801376:	83 c4 2c             	add    $0x2c,%esp
  801379:	c3                   	ret    
  80137a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801380:	85 f6                	test   %esi,%esi
  801382:	89 f5                	mov    %esi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0xb1>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f6                	div    %esi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801395:	31 d2                	xor    %edx,%edx
  801397:	f7 f5                	div    %ebp
  801399:	89 c8                	mov    %ecx,%eax
  80139b:	f7 f5                	div    %ebp
  80139d:	eb 84                	jmp    801323 <__umoddi3+0x43>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013a8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013ac:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013b0:	83 c4 2c             	add    $0x2c,%esp
  8013b3:	c3                   	ret    
  8013b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013bc:	be 20 00 00 00       	mov    $0x20,%esi
  8013c1:	89 e9                	mov    %ebp,%ecx
  8013c3:	29 ee                	sub    %ebp,%esi
  8013c5:	d3 e2                	shl    %cl,%edx
  8013c7:	89 f1                	mov    %esi,%ecx
  8013c9:	d3 e8                	shr    %cl,%eax
  8013cb:	89 e9                	mov    %ebp,%ecx
  8013cd:	09 d0                	or     %edx,%eax
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013d9:	d3 e0                	shl    %cl,%eax
  8013db:	89 f1                	mov    %esi,%ecx
  8013dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013e5:	d3 ea                	shr    %cl,%edx
  8013e7:	89 e9                	mov    %ebp,%ecx
  8013e9:	d3 e7                	shl    %cl,%edi
  8013eb:	89 f1                	mov    %esi,%ecx
  8013ed:	d3 e8                	shr    %cl,%eax
  8013ef:	89 e9                	mov    %ebp,%ecx
  8013f1:	09 f8                	or     %edi,%eax
  8013f3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013f7:	f7 74 24 0c          	divl   0xc(%esp)
  8013fb:	d3 e7                	shl    %cl,%edi
  8013fd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801401:	89 d7                	mov    %edx,%edi
  801403:	f7 64 24 10          	mull   0x10(%esp)
  801407:	39 d7                	cmp    %edx,%edi
  801409:	89 c1                	mov    %eax,%ecx
  80140b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80140f:	72 3b                	jb     80144c <__umoddi3+0x16c>
  801411:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801415:	72 31                	jb     801448 <__umoddi3+0x168>
  801417:	8b 44 24 18          	mov    0x18(%esp),%eax
  80141b:	29 c8                	sub    %ecx,%eax
  80141d:	19 d7                	sbb    %edx,%edi
  80141f:	89 e9                	mov    %ebp,%ecx
  801421:	89 fa                	mov    %edi,%edx
  801423:	d3 e8                	shr    %cl,%eax
  801425:	89 f1                	mov    %esi,%ecx
  801427:	d3 e2                	shl    %cl,%edx
  801429:	89 e9                	mov    %ebp,%ecx
  80142b:	09 d0                	or     %edx,%eax
  80142d:	89 fa                	mov    %edi,%edx
  80142f:	d3 ea                	shr    %cl,%edx
  801431:	8b 74 24 20          	mov    0x20(%esp),%esi
  801435:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801439:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80143d:	83 c4 2c             	add    $0x2c,%esp
  801440:	c3                   	ret    
  801441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801448:	39 d7                	cmp    %edx,%edi
  80144a:	75 cb                	jne    801417 <__umoddi3+0x137>
  80144c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801450:	89 c1                	mov    %eax,%ecx
  801452:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801456:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80145a:	eb bb                	jmp    801417 <__umoddi3+0x137>
  80145c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801460:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801464:	0f 82 e8 fe ff ff    	jb     801352 <__umoddi3+0x72>
  80146a:	e9 f3 fe ff ff       	jmp    801362 <__umoddi3+0x82>
