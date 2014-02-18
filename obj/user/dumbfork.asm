
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 2f 02 00 00       	call   800260 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 fa 0e 00 00       	call   800f5c <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 c0 14 80 	movl   $0x8014c0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800081:	e8 3e 02 00 00       	call   8002c4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 11 0f 00 00       	call   800fbb <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 e3 14 80 	movl   $0x8014e3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  8000c9:	e8 f6 01 00 00       	call   8002c4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 5d 0b 00 00       	call   800c43 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 1f 0f 00 00       	call   801019 <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800119:	e8 a6 01 00 00       	call   8002c4 <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	be 07 00 00 00       	mov    $0x7,%esi
  800132:	89 f0                	mov    %esi,%eax
  800134:	cd 30                	int    $0x30
  800136:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800138:	85 c0                	test   %eax,%eax
  80013a:	79 20                	jns    80015c <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  80013c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800140:	c7 44 24 08 07 15 80 	movl   $0x801507,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014f:	00 
  800150:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800157:	e8 68 01 00 00       	call   8002c4 <_panic>
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1c                	jne    80017c <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 97 0d 00 00       	call   800efc <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 20 80 00       	mov    %eax,0x802004
  800177:	e9 82 00 00 00       	jmp    8001fe <dumbfork+0xd9>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800183:	b8 08 20 80 00       	mov    $0x802008,%eax
  800188:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80018d:	76 27                	jbe    8001b6 <dumbfork+0x91>
  80018f:	89 f3                	mov    %esi,%ebx
  800191:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800196:	89 54 24 04          	mov    %edx,0x4(%esp)
  80019a:	89 1c 24             	mov    %ebx,(%esp)
  80019d:	e8 9e fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001a5:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8001ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8001ae:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001b4:	72 e0                	jb     800196 <dumbfork+0x71>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	89 34 24             	mov    %esi,(%esp)
  8001c5:	e8 76 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001d1:	00 
  8001d2:	89 34 24             	mov    %esi,(%esp)
  8001d5:	e8 9d 0e 00 00       	call   801077 <sys_env_set_status>
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	79 20                	jns    8001fe <dumbfork+0xd9>
		panic("sys_env_set_status: %e", r);
  8001de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e2:	c7 44 24 08 17 15 80 	movl   $0x801517,0x8(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001f1:	00 
  8001f2:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  8001f9:	e8 c6 00 00 00       	call   8002c4 <_panic>

	return envid;
}
  8001fe:	89 f0                	mov    %esi,%eax
  800200:	83 c4 20             	add    $0x20,%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80020f:	e8 11 ff ff ff       	call   800125 <dumbfork>
  800214:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	eb 28                	jmp    800245 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80021d:	b8 35 15 80 00       	mov    $0x801535,%eax
  800222:	eb 05                	jmp    800229 <umain+0x22>
  800224:	b8 2e 15 80 00       	mov    $0x80152e,%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800231:	c7 04 24 3b 15 80 00 	movl   $0x80153b,(%esp)
  800238:	e8 82 01 00 00       	call   8003bf <cprintf>
		sys_yield();
  80023d:	e8 ea 0c 00 00       	call   800f2c <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800242:	83 c3 01             	add    $0x1,%ebx
  800245:	85 f6                	test   %esi,%esi
  800247:	75 09                	jne    800252 <umain+0x4b>
  800249:	83 fb 13             	cmp    $0x13,%ebx
  80024c:	7e cf                	jle    80021d <umain+0x16>
  80024e:	66 90                	xchg   %ax,%ax
  800250:	eb 05                	jmp    800257 <umain+0x50>
  800252:	83 fb 09             	cmp    $0x9,%ebx
  800255:	7e cd                	jle    800224 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800257:	83 c4 10             	add    $0x10,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    
	...

00800260 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
  800266:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800269:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80026c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800272:	e8 85 0c 00 00       	call   800efc <sys_getenvid>
  800277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800284:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800289:	85 db                	test   %ebx,%ebx
  80028b:	7e 07                	jle    800294 <libmain+0x34>
		binaryname = argv[0];
  80028d:	8b 06                	mov    (%esi),%eax
  80028f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800294:	89 74 24 04          	mov    %esi,0x4(%esp)
  800298:	89 1c 24             	mov    %ebx,(%esp)
  80029b:	e8 67 ff ff ff       	call   800207 <umain>

	// exit gracefully
	exit();
  8002a0:	e8 0b 00 00 00       	call   8002b0 <exit>
}
  8002a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002ab:	89 ec                	mov    %ebp,%esp
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    
	...

008002b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002bd:	e8 dd 0b 00 00       	call   800e9f <sys_env_destroy>
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002d5:	e8 22 0c 00 00       	call   800efc <sys_getenvid>
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f0:	c7 04 24 58 15 80 00 	movl   $0x801558,(%esp)
  8002f7:	e8 c3 00 00 00       	call   8003bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	e8 53 00 00 00       	call   80035e <vcprintf>
	cprintf("\n");
  80030b:	c7 04 24 4b 15 80 00 	movl   $0x80154b,(%esp)
  800312:	e8 a8 00 00 00       	call   8003bf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800317:	cc                   	int3   
  800318:	eb fd                	jmp    800317 <_panic+0x53>
	...

0080031c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	53                   	push   %ebx
  800320:	83 ec 14             	sub    $0x14,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800326:	8b 03                	mov    (%ebx),%eax
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80032f:	83 c0 01             	add    $0x1,%eax
  800332:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800334:	3d ff 00 00 00       	cmp    $0xff,%eax
  800339:	75 19                	jne    800354 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80033b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800342:	00 
  800343:	8d 43 08             	lea    0x8(%ebx),%eax
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	e8 f2 0a 00 00       	call   800e40 <sys_cputs>
		b->idx = 0;
  80034e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800354:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800358:	83 c4 14             	add    $0x14,%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800367:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036e:	00 00 00 
	b.cnt = 0;
  800371:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800378:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800382:	8b 45 08             	mov    0x8(%ebp),%eax
  800385:	89 44 24 08          	mov    %eax,0x8(%esp)
  800389:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800393:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80039a:	e8 b3 01 00 00       	call   800552 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 89 0a 00 00       	call   800e40 <sys_cputs>

	return b.cnt;
}
  8003b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 87 ff ff ff       	call   80035e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d7:	c9                   	leave  
  8003d8:	c3                   	ret    
  8003d9:	00 00                	add    %al,(%eax)
  8003db:	00 00                	add    %al,(%eax)
  8003dd:	00 00                	add    %al,(%eax)
	...

008003e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 4c             	sub    $0x4c,%esp
  8003e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ec:	89 d7                	mov    %edx,%edi
  8003ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	39 d8                	cmp    %ebx,%eax
  800401:	72 17                	jb     80041a <printnum+0x3a>
  800403:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800406:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800409:	76 0f                	jbe    80041a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040b:	8b 75 14             	mov    0x14(%ebp),%esi
  80040e:	83 ee 01             	sub    $0x1,%esi
  800411:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800414:	85 f6                	test   %esi,%esi
  800416:	7f 63                	jg     80047b <printnum+0x9b>
  800418:	eb 75                	jmp    80048f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80041d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	83 e8 01             	sub    $0x1,%eax
  800427:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80042e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800432:	8b 44 24 08          	mov    0x8(%esp),%eax
  800436:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800440:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800447:	00 
  800448:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80044b:	89 1c 24             	mov    %ebx,(%esp)
  80044e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	e8 76 0d 00 00       	call   8011d0 <__udivdi3>
  80045a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800460:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046f:	89 fa                	mov    %edi,%edx
  800471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800474:	e8 67 ff ff ff       	call   8003e0 <printnum>
  800479:	eb 14                	jmp    80048f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047f:	8b 45 18             	mov    0x18(%ebp),%eax
  800482:	89 04 24             	mov    %eax,(%esp)
  800485:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800487:	83 ee 01             	sub    $0x1,%esi
  80048a:	75 ef                	jne    80047b <printnum+0x9b>
  80048c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800493:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800497:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80049a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80049e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004a5:	00 
  8004a6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8004a9:	89 1c 24             	mov    %ebx,(%esp)
  8004ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b3:	e8 68 0e 00 00       	call   801320 <__umoddi3>
  8004b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bc:	0f be 80 7c 15 80 00 	movsbl 0x80157c(%eax),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004c9:	ff d0                	call   *%eax
}
  8004cb:	83 c4 4c             	add    $0x4c,%esp
  8004ce:	5b                   	pop    %ebx
  8004cf:	5e                   	pop    %esi
  8004d0:	5f                   	pop    %edi
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d6:	83 fa 01             	cmp    $0x1,%edx
  8004d9:	7e 0e                	jle    8004e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004db:	8b 10                	mov    (%eax),%edx
  8004dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e0:	89 08                	mov    %ecx,(%eax)
  8004e2:	8b 02                	mov    (%edx),%eax
  8004e4:	8b 52 04             	mov    0x4(%edx),%edx
  8004e7:	eb 22                	jmp    80050b <getuint+0x38>
	else if (lflag)
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	74 10                	je     8004fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 02                	mov    (%edx),%eax
  8004f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fb:	eb 0e                	jmp    80050b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050b:	5d                   	pop    %ebp
  80050c:	c3                   	ret    

0080050d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800513:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800517:	8b 10                	mov    (%eax),%edx
  800519:	3b 50 04             	cmp    0x4(%eax),%edx
  80051c:	73 0a                	jae    800528 <sprintputch+0x1b>
		*b->buf++ = ch;
  80051e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800521:	88 0a                	mov    %cl,(%edx)
  800523:	83 c2 01             	add    $0x1,%edx
  800526:	89 10                	mov    %edx,(%eax)
}
  800528:	5d                   	pop    %ebp
  800529:	c3                   	ret    

0080052a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800530:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800533:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800537:	8b 45 10             	mov    0x10(%ebp),%eax
  80053a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 02 00 00 00       	call   800552 <vprintfmt>
	va_end(ap);
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 4c             	sub    $0x4c,%esp
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	8b 7d 10             	mov    0x10(%ebp),%edi
  800564:	eb 11                	jmp    800577 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 84 db 03 00 00    	je     800949 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80056e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800577:	0f b6 07             	movzbl (%edi),%eax
  80057a:	83 c7 01             	add    $0x1,%edi
  80057d:	83 f8 25             	cmp    $0x25,%eax
  800580:	75 e4                	jne    800566 <vprintfmt+0x14>
  800582:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800586:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80058d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800594:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	eb 2b                	jmp    8005cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8005a9:	eb 22                	jmp    8005cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ae:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8005b2:	eb 19                	jmp    8005cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005be:	eb 0d                	jmp    8005cd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	0f b6 0f             	movzbl (%edi),%ecx
  8005d0:	8d 47 01             	lea    0x1(%edi),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	0f b6 07             	movzbl (%edi),%eax
  8005d9:	83 e8 23             	sub    $0x23,%eax
  8005dc:	3c 55                	cmp    $0x55,%al
  8005de:	0f 87 40 03 00 00    	ja     800924 <vprintfmt+0x3d2>
  8005e4:	0f b6 c0             	movzbl %al,%eax
  8005e7:	ff 24 85 40 16 80 00 	jmp    *0x801640(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ee:	83 e9 30             	sub    $0x30,%ecx
  8005f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8005f4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8005f8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005fb:	83 f9 09             	cmp    $0x9,%ecx
  8005fe:	77 57                	ja     800657 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800603:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800606:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800609:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80060c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80060f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800613:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800616:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800619:	83 f9 09             	cmp    $0x9,%ecx
  80061c:	76 eb                	jbe    800609 <vprintfmt+0xb7>
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800621:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800624:	eb 34                	jmp    80065a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 48 04             	lea    0x4(%eax),%ecx
  80062c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800637:	eb 21                	jmp    80065a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800639:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063d:	0f 88 71 ff ff ff    	js     8005b4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800646:	eb 85                	jmp    8005cd <vprintfmt+0x7b>
  800648:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80064b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800652:	e9 76 ff ff ff       	jmp    8005cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80065a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80065e:	0f 89 69 ff ff ff    	jns    8005cd <vprintfmt+0x7b>
  800664:	e9 57 ff ff ff       	jmp    8005c0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800669:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066f:	e9 59 ff ff ff       	jmp    8005cd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80068b:	e9 e7 fe ff ff       	jmp    800577 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	89 c2                	mov    %eax,%edx
  80069d:	c1 fa 1f             	sar    $0x1f,%edx
  8006a0:	31 d0                	xor    %edx,%eax
  8006a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a4:	83 f8 08             	cmp    $0x8,%eax
  8006a7:	7f 0b                	jg     8006b4 <vprintfmt+0x162>
  8006a9:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	75 20                	jne    8006d4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b8:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  8006bf:	00 
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	89 34 24             	mov    %esi,(%esp)
  8006c7:	e8 5e fe ff ff       	call   80052a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cf:	e9 a3 fe ff ff       	jmp    800577 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d8:	c7 44 24 08 9d 15 80 	movl   $0x80159d,0x8(%esp)
  8006df:	00 
  8006e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e4:	89 34 24             	mov    %esi,(%esp)
  8006e7:	e8 3e fe ff ff       	call   80052a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ef:	e9 83 fe ff ff       	jmp    800577 <vprintfmt+0x25>
  8006f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006f7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)
  800706:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800708:	85 ff                	test   %edi,%edi
  80070a:	b8 8d 15 80 00       	mov    $0x80158d,%eax
  80070f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800712:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800716:	74 06                	je     80071e <vprintfmt+0x1cc>
  800718:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80071c:	7f 16                	jg     800734 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071e:	0f b6 17             	movzbl (%edi),%edx
  800721:	0f be c2             	movsbl %dl,%eax
  800724:	83 c7 01             	add    $0x1,%edi
  800727:	85 c0                	test   %eax,%eax
  800729:	0f 85 9f 00 00 00    	jne    8007ce <vprintfmt+0x27c>
  80072f:	e9 8b 00 00 00       	jmp    8007bf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800738:	89 3c 24             	mov    %edi,(%esp)
  80073b:	e8 c2 02 00 00       	call   800a02 <strnlen>
  800740:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800743:	29 c2                	sub    %eax,%edx
  800745:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e d2                	jle    80071e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80074c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800750:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800753:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800756:	89 d7                	mov    %edx,%edi
  800758:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800764:	83 ef 01             	sub    $0x1,%edi
  800767:	75 ef                	jne    800758 <vprintfmt+0x206>
  800769:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80076c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80076f:	eb ad                	jmp    80071e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800771:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800775:	74 20                	je     800797 <vprintfmt+0x245>
  800777:	0f be d2             	movsbl %dl,%edx
  80077a:	83 ea 20             	sub    $0x20,%edx
  80077d:	83 fa 5e             	cmp    $0x5e,%edx
  800780:	76 15                	jbe    800797 <vprintfmt+0x245>
					putch('?', putdat);
  800782:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800785:	89 54 24 04          	mov    %edx,0x4(%esp)
  800789:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800790:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800793:	ff d1                	call   *%ecx
  800795:	eb 0f                	jmp    8007a6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800797:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80079a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a6:	83 eb 01             	sub    $0x1,%ebx
  8007a9:	0f b6 17             	movzbl (%edi),%edx
  8007ac:	0f be c2             	movsbl %dl,%eax
  8007af:	83 c7 01             	add    $0x1,%edi
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	75 24                	jne    8007da <vprintfmt+0x288>
  8007b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007c6:	0f 8e ab fd ff ff    	jle    800577 <vprintfmt+0x25>
  8007cc:	eb 20                	jmp    8007ee <vprintfmt+0x29c>
  8007ce:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007d1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007d4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007d7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007da:	85 f6                	test   %esi,%esi
  8007dc:	78 93                	js     800771 <vprintfmt+0x21f>
  8007de:	83 ee 01             	sub    $0x1,%esi
  8007e1:	79 8e                	jns    800771 <vprintfmt+0x21f>
  8007e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007e6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007ec:	eb d1                	jmp    8007bf <vprintfmt+0x26d>
  8007ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007fe:	83 ef 01             	sub    $0x1,%edi
  800801:	75 ee                	jne    8007f1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800803:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800806:	e9 6c fd ff ff       	jmp    800577 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 fa 01             	cmp    $0x1,%edx
  80080e:	66 90                	xchg   %ax,%ax
  800810:	7e 16                	jle    800828 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 08             	lea    0x8(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8b 48 04             	mov    0x4(%eax),%ecx
  800820:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800823:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800826:	eb 32                	jmp    80085a <vprintfmt+0x308>
	else if (lflag)
  800828:	85 d2                	test   %edx,%edx
  80082a:	74 18                	je     800844 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8d 50 04             	lea    0x4(%eax),%edx
  800832:	89 55 14             	mov    %edx,0x14(%ebp)
  800835:	8b 00                	mov    (%eax),%eax
  800837:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80083a:	89 c1                	mov    %eax,%ecx
  80083c:	c1 f9 1f             	sar    $0x1f,%ecx
  80083f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800842:	eb 16                	jmp    80085a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 04             	lea    0x4(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800852:	89 c7                	mov    %eax,%edi
  800854:	c1 ff 1f             	sar    $0x1f,%edi
  800857:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80085a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80085d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800860:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800865:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800869:	79 7d                	jns    8008e8 <vprintfmt+0x396>
				putch('-', putdat);
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800876:	ff d6                	call   *%esi
				num = -(long long) num;
  800878:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80087b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80087e:	f7 d8                	neg    %eax
  800880:	83 d2 00             	adc    $0x0,%edx
  800883:	f7 da                	neg    %edx
			}
			base = 10;
  800885:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80088a:	eb 5c                	jmp    8008e8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
  80088f:	e8 3f fc ff ff       	call   8004d3 <getuint>
			base = 10;
  800894:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800899:	eb 4d                	jmp    8008e8 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
  80089e:	e8 30 fc ff ff       	call   8004d3 <getuint>
      base = 8;
  8008a3:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8008a8:	eb 3e                	jmp    8008e8 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008c2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008cd:	8b 00                	mov    (%eax),%eax
  8008cf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008d9:	eb 0d                	jmp    8008e8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
  8008de:	e8 f0 fb ff ff       	call   8004d3 <getuint>
			base = 16;
  8008e3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8008ec:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8008f0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008f3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008fb:	89 04 24             	mov    %eax,(%esp)
  8008fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800902:	89 da                	mov    %ebx,%edx
  800904:	89 f0                	mov    %esi,%eax
  800906:	e8 d5 fa ff ff       	call   8003e0 <printnum>
			break;
  80090b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80090e:	e9 64 fc ff ff       	jmp    800577 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800913:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800917:	89 0c 24             	mov    %ecx,(%esp)
  80091a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80091f:	e9 53 fc ff ff       	jmp    800577 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800924:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800928:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80092f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800931:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800935:	0f 84 3c fc ff ff    	je     800577 <vprintfmt+0x25>
  80093b:	83 ef 01             	sub    $0x1,%edi
  80093e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800942:	75 f7                	jne    80093b <vprintfmt+0x3e9>
  800944:	e9 2e fc ff ff       	jmp    800577 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800949:	83 c4 4c             	add    $0x4c,%esp
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 28             	sub    $0x28,%esp
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800960:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800964:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096e:	85 d2                	test   %edx,%edx
  800970:	7e 30                	jle    8009a2 <vsnprintf+0x51>
  800972:	85 c0                	test   %eax,%eax
  800974:	74 2c                	je     8009a2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800976:	8b 45 14             	mov    0x14(%ebp),%eax
  800979:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097d:	8b 45 10             	mov    0x10(%ebp),%eax
  800980:	89 44 24 08          	mov    %eax,0x8(%esp)
  800984:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098b:	c7 04 24 0d 05 80 00 	movl   $0x80050d,(%esp)
  800992:	e8 bb fb ff ff       	call   800552 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800997:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80099a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a0:	eb 05                	jmp    8009a7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	89 04 24             	mov    %eax,(%esp)
  8009ca:	e8 82 ff ff ff       	call   800951 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    
	...

008009e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e9:	74 10                	je     8009fb <strlen+0x1b>
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f7:	75 f7                	jne    8009f0 <strlen+0x10>
  8009f9:	eb 05                	jmp    800a00 <strlen+0x20>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0c:	85 c9                	test   %ecx,%ecx
  800a0e:	74 1c                	je     800a2c <strnlen+0x2a>
  800a10:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a13:	74 1e                	je     800a33 <strnlen+0x31>
  800a15:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a1a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1c:	39 ca                	cmp    %ecx,%edx
  800a1e:	74 18                	je     800a38 <strnlen+0x36>
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a28:	75 f0                	jne    800a1a <strnlen+0x18>
  800a2a:	eb 0c                	jmp    800a38 <strnlen+0x36>
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 05                	jmp    800a38 <strnlen+0x36>
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a38:	5b                   	pop    %ebx
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a45:	89 c2                	mov    %eax,%edx
  800a47:	0f b6 19             	movzbl (%ecx),%ebx
  800a4a:	88 1a                	mov    %bl,(%edx)
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	84 db                	test   %bl,%bl
  800a54:	75 f1                	jne    800a47 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a63:	89 1c 24             	mov    %ebx,(%esp)
  800a66:	e8 75 ff ff ff       	call   8009e0 <strlen>
	strcpy(dst + len, src);
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a72:	01 d8                	add    %ebx,%eax
  800a74:	89 04 24             	mov    %eax,(%esp)
  800a77:	e8 bf ff ff ff       	call   800a3b <strcpy>
	return dst;
}
  800a7c:	89 d8                	mov    %ebx,%eax
  800a7e:	83 c4 08             	add    $0x8,%esp
  800a81:	5b                   	pop    %ebx
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	74 16                	je     800aac <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800a96:	01 f3                	add    %esi,%ebx
  800a98:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800a9a:	0f b6 02             	movzbl (%edx),%eax
  800a9d:	88 01                	mov    %al,(%ecx)
  800a9f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa2:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa8:	39 d9                	cmp    %ebx,%ecx
  800aaa:	75 ee                	jne    800a9a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aac:	89 f0                	mov    %esi,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	85 f6                	test   %esi,%esi
  800ac5:	74 33                	je     800afa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800ac7:	83 fe 01             	cmp    $0x1,%esi
  800aca:	74 25                	je     800af1 <strlcpy+0x3f>
  800acc:	0f b6 0b             	movzbl (%ebx),%ecx
  800acf:	84 c9                	test   %cl,%cl
  800ad1:	74 22                	je     800af5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ad3:	83 ee 02             	sub    $0x2,%esi
  800ad6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800adb:	88 08                	mov    %cl,(%eax)
  800add:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae0:	39 f2                	cmp    %esi,%edx
  800ae2:	74 13                	je     800af7 <strlcpy+0x45>
  800ae4:	83 c2 01             	add    $0x1,%edx
  800ae7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aeb:	84 c9                	test   %cl,%cl
  800aed:	75 ec                	jne    800adb <strlcpy+0x29>
  800aef:	eb 06                	jmp    800af7 <strlcpy+0x45>
  800af1:	89 f8                	mov    %edi,%eax
  800af3:	eb 02                	jmp    800af7 <strlcpy+0x45>
  800af5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800af7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800afa:	29 f8                	sub    %edi,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	84 c0                	test   %al,%al
  800b0f:	74 15                	je     800b26 <strcmp+0x25>
  800b11:	3a 02                	cmp    (%edx),%al
  800b13:	75 11                	jne    800b26 <strcmp+0x25>
		p++, q++;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b1b:	0f b6 01             	movzbl (%ecx),%eax
  800b1e:	84 c0                	test   %al,%al
  800b20:	74 04                	je     800b26 <strcmp+0x25>
  800b22:	3a 02                	cmp    (%edx),%al
  800b24:	74 ef                	je     800b15 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b26:	0f b6 c0             	movzbl %al,%eax
  800b29:	0f b6 12             	movzbl (%edx),%edx
  800b2c:	29 d0                	sub    %edx,%eax
}
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b3e:	85 f6                	test   %esi,%esi
  800b40:	74 29                	je     800b6b <strncmp+0x3b>
  800b42:	0f b6 03             	movzbl (%ebx),%eax
  800b45:	84 c0                	test   %al,%al
  800b47:	74 30                	je     800b79 <strncmp+0x49>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	75 2c                	jne    800b79 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800b4d:	8d 43 01             	lea    0x1(%ebx),%eax
  800b50:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b57:	39 f0                	cmp    %esi,%eax
  800b59:	74 17                	je     800b72 <strncmp+0x42>
  800b5b:	0f b6 08             	movzbl (%eax),%ecx
  800b5e:	84 c9                	test   %cl,%cl
  800b60:	74 17                	je     800b79 <strncmp+0x49>
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	3a 0a                	cmp    (%edx),%cl
  800b67:	74 e9                	je     800b52 <strncmp+0x22>
  800b69:	eb 0e                	jmp    800b79 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	eb 0f                	jmp    800b81 <strncmp+0x51>
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	eb 08                	jmp    800b81 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b79:	0f b6 03             	movzbl (%ebx),%eax
  800b7c:	0f b6 12             	movzbl (%edx),%edx
  800b7f:	29 d0                	sub    %edx,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	53                   	push   %ebx
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b8f:	0f b6 18             	movzbl (%eax),%ebx
  800b92:	84 db                	test   %bl,%bl
  800b94:	74 1d                	je     800bb3 <strchr+0x2e>
  800b96:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800b98:	38 d3                	cmp    %dl,%bl
  800b9a:	75 06                	jne    800ba2 <strchr+0x1d>
  800b9c:	eb 1a                	jmp    800bb8 <strchr+0x33>
  800b9e:	38 ca                	cmp    %cl,%dl
  800ba0:	74 16                	je     800bb8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	0f b6 10             	movzbl (%eax),%edx
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	75 f2                	jne    800b9e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	eb 05                	jmp    800bb8 <strchr+0x33>
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bc5:	0f b6 18             	movzbl (%eax),%ebx
  800bc8:	84 db                	test   %bl,%bl
  800bca:	74 16                	je     800be2 <strfind+0x27>
  800bcc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800bce:	38 d3                	cmp    %dl,%bl
  800bd0:	75 06                	jne    800bd8 <strfind+0x1d>
  800bd2:	eb 0e                	jmp    800be2 <strfind+0x27>
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 0a                	je     800be2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bd8:	83 c0 01             	add    $0x1,%eax
  800bdb:	0f b6 10             	movzbl (%eax),%edx
  800bde:	84 d2                	test   %dl,%dl
  800be0:	75 f2                	jne    800bd4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800be2:	5b                   	pop    %ebx
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bf4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bfa:	85 c9                	test   %ecx,%ecx
  800bfc:	74 36                	je     800c34 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c04:	75 28                	jne    800c2e <memset+0x49>
  800c06:	f6 c1 03             	test   $0x3,%cl
  800c09:	75 23                	jne    800c2e <memset+0x49>
		c &= 0xFF;
  800c0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	c1 e3 08             	shl    $0x8,%ebx
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	c1 e6 18             	shl    $0x18,%esi
  800c19:	89 d0                	mov    %edx,%eax
  800c1b:	c1 e0 10             	shl    $0x10,%eax
  800c1e:	09 f0                	or     %esi,%eax
  800c20:	09 c2                	or     %eax,%edx
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c26:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c29:	fc                   	cld    
  800c2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2c:	eb 06                	jmp    800c34 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c3f:	89 ec                	mov    %ebp,%esp
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
  800c49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c58:	39 c6                	cmp    %eax,%esi
  800c5a:	73 36                	jae    800c92 <memmove+0x4f>
  800c5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c5f:	39 d0                	cmp    %edx,%eax
  800c61:	73 2f                	jae    800c92 <memmove+0x4f>
		s += n;
		d += n;
  800c63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c66:	f6 c2 03             	test   $0x3,%dl
  800c69:	75 1b                	jne    800c86 <memmove+0x43>
  800c6b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c71:	75 13                	jne    800c86 <memmove+0x43>
  800c73:	f6 c1 03             	test   $0x3,%cl
  800c76:	75 0e                	jne    800c86 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c78:	83 ef 04             	sub    $0x4,%edi
  800c7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c7e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c81:	fd                   	std    
  800c82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c84:	eb 09                	jmp    800c8f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c86:	83 ef 01             	sub    $0x1,%edi
  800c89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8c:	fd                   	std    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8f:	fc                   	cld    
  800c90:	eb 20                	jmp    800cb2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c98:	75 13                	jne    800cad <memmove+0x6a>
  800c9a:	a8 03                	test   $0x3,%al
  800c9c:	75 0f                	jne    800cad <memmove+0x6a>
  800c9e:	f6 c1 03             	test   $0x3,%cl
  800ca1:	75 0a                	jne    800cad <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ca3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ca6:	89 c7                	mov    %eax,%edi
  800ca8:	fc                   	cld    
  800ca9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cab:	eb 05                	jmp    800cb2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cad:	89 c7                	mov    %eax,%edi
  800caf:	fc                   	cld    
  800cb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb8:	89 ec                	mov    %ebp,%esp
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	89 04 24             	mov    %eax,(%esp)
  800cd6:	e8 68 ff ff ff       	call   800c43 <memmove>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cec:	8d 78 ff             	lea    -0x1(%eax),%edi
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	74 36                	je     800d29 <memcmp+0x4c>
		if (*s1 != *s2)
  800cf3:	0f b6 03             	movzbl (%ebx),%eax
  800cf6:	0f b6 0e             	movzbl (%esi),%ecx
  800cf9:	38 c8                	cmp    %cl,%al
  800cfb:	75 17                	jne    800d14 <memcmp+0x37>
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	eb 1a                	jmp    800d1e <memcmp+0x41>
  800d04:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d09:	83 c2 01             	add    $0x1,%edx
  800d0c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d10:	38 c8                	cmp    %cl,%al
  800d12:	74 0a                	je     800d1e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d14:	0f b6 c0             	movzbl %al,%eax
  800d17:	0f b6 c9             	movzbl %cl,%ecx
  800d1a:	29 c8                	sub    %ecx,%eax
  800d1c:	eb 10                	jmp    800d2e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1e:	39 fa                	cmp    %edi,%edx
  800d20:	75 e2                	jne    800d04 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
  800d27:	eb 05                	jmp    800d2e <memcmp+0x51>
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	53                   	push   %ebx
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800d3d:	89 c2                	mov    %eax,%edx
  800d3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d42:	39 d0                	cmp    %edx,%eax
  800d44:	73 13                	jae    800d59 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d46:	89 d9                	mov    %ebx,%ecx
  800d48:	38 18                	cmp    %bl,(%eax)
  800d4a:	75 06                	jne    800d52 <memfind+0x1f>
  800d4c:	eb 0b                	jmp    800d59 <memfind+0x26>
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 07                	je     800d59 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	39 d0                	cmp    %edx,%eax
  800d57:	75 f5                	jne    800d4e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6b:	0f b6 02             	movzbl (%edx),%eax
  800d6e:	3c 09                	cmp    $0x9,%al
  800d70:	74 04                	je     800d76 <strtol+0x1a>
  800d72:	3c 20                	cmp    $0x20,%al
  800d74:	75 0e                	jne    800d84 <strtol+0x28>
		s++;
  800d76:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d79:	0f b6 02             	movzbl (%edx),%eax
  800d7c:	3c 09                	cmp    $0x9,%al
  800d7e:	74 f6                	je     800d76 <strtol+0x1a>
  800d80:	3c 20                	cmp    $0x20,%al
  800d82:	74 f2                	je     800d76 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d84:	3c 2b                	cmp    $0x2b,%al
  800d86:	75 0a                	jne    800d92 <strtol+0x36>
		s++;
  800d88:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d90:	eb 10                	jmp    800da2 <strtol+0x46>
  800d92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d97:	3c 2d                	cmp    $0x2d,%al
  800d99:	75 07                	jne    800da2 <strtol+0x46>
		s++, neg = 1;
  800d9b:	83 c2 01             	add    $0x1,%edx
  800d9e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800da8:	75 15                	jne    800dbf <strtol+0x63>
  800daa:	80 3a 30             	cmpb   $0x30,(%edx)
  800dad:	75 10                	jne    800dbf <strtol+0x63>
  800daf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800db3:	75 0a                	jne    800dbf <strtol+0x63>
		s += 2, base = 16;
  800db5:	83 c2 02             	add    $0x2,%edx
  800db8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dbd:	eb 10                	jmp    800dcf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800dbf:	85 db                	test   %ebx,%ebx
  800dc1:	75 0c                	jne    800dcf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dc5:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc8:	75 05                	jne    800dcf <strtol+0x73>
		s++, base = 8;
  800dca:	83 c2 01             	add    $0x1,%edx
  800dcd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd7:	0f b6 0a             	movzbl (%edx),%ecx
  800dda:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ddd:	89 f3                	mov    %esi,%ebx
  800ddf:	80 fb 09             	cmp    $0x9,%bl
  800de2:	77 08                	ja     800dec <strtol+0x90>
			dig = *s - '0';
  800de4:	0f be c9             	movsbl %cl,%ecx
  800de7:	83 e9 30             	sub    $0x30,%ecx
  800dea:	eb 22                	jmp    800e0e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800dec:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800def:	89 f3                	mov    %esi,%ebx
  800df1:	80 fb 19             	cmp    $0x19,%bl
  800df4:	77 08                	ja     800dfe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800df6:	0f be c9             	movsbl %cl,%ecx
  800df9:	83 e9 57             	sub    $0x57,%ecx
  800dfc:	eb 10                	jmp    800e0e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800dfe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e01:	89 f3                	mov    %esi,%ebx
  800e03:	80 fb 19             	cmp    $0x19,%bl
  800e06:	77 16                	ja     800e1e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800e08:	0f be c9             	movsbl %cl,%ecx
  800e0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e11:	7d 0f                	jge    800e22 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e13:	83 c2 01             	add    $0x1,%edx
  800e16:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800e1a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e1c:	eb b9                	jmp    800dd7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e1e:	89 c1                	mov    %eax,%ecx
  800e20:	eb 02                	jmp    800e24 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e22:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e28:	74 05                	je     800e2f <strtol+0xd3>
		*endptr = (char *) s;
  800e2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e2d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e2f:	89 ca                	mov    %ecx,%edx
  800e31:	f7 da                	neg    %edx
  800e33:	85 ff                	test   %edi,%edi
  800e35:	0f 45 c2             	cmovne %edx,%eax
}
  800e38:	83 c4 04             	add    $0x4,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 c7                	mov    %eax,%edi
  800e5e:	89 c6                	mov    %eax,%esi
  800e60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6b:	89 ec                	mov    %ebp,%esp
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e83:	b8 01 00 00 00       	mov    $0x1,%eax
  800e88:	89 d1                	mov    %edx,%ecx
  800e8a:	89 d3                	mov    %edx,%ebx
  800e8c:	89 d7                	mov    %edx,%edi
  800e8e:	89 d6                	mov    %edx,%esi
  800e90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 38             	sub    $0x38,%esp
  800ea5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	89 cb                	mov    %ecx,%ebx
  800ebd:	89 cf                	mov    %ecx,%edi
  800ebf:	89 ce                	mov    %ecx,%esi
  800ec1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 28                	jle    800eef <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800eea:	e8 d5 f3 ff ff       	call   8002c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f10:	b8 02 00 00 00       	mov    $0x2,%eax
  800f15:	89 d1                	mov    %edx,%ecx
  800f17:	89 d3                	mov    %edx,%ebx
  800f19:	89 d7                	mov    %edx,%edi
  800f1b:	89 d6                	mov    %edx,%esi
  800f1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f28:	89 ec                	mov    %ebp,%esp
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_yield>:

void
sys_yield(void)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f45:	89 d1                	mov    %edx,%ecx
  800f47:	89 d3                	mov    %edx,%ebx
  800f49:	89 d7                	mov    %edx,%edi
  800f4b:	89 d6                	mov    %edx,%esi
  800f4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f58:	89 ec                	mov    %ebp,%esp
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 38             	sub    $0x38,%esp
  800f62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6b:	be 00 00 00 00       	mov    $0x0,%esi
  800f70:	b8 04 00 00 00       	mov    $0x4,%eax
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7e:	89 f7                	mov    %esi,%edi
  800f80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 28                	jle    800fae <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f91:	00 
  800f92:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800fa9:	e8 16 f3 ff ff       	call   8002c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb7:	89 ec                	mov    %ebp,%esp
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 38             	sub    $0x38,%esp
  800fc1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fca:	b8 05 00 00 00       	mov    $0x5,%eax
  800fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800fde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	7e 28                	jle    80100c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fef:	00 
  800ff0:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fff:	00 
  801000:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801007:	e8 b8 f2 ff ff       	call   8002c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80100c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801012:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801015:	89 ec                	mov    %ebp,%esp
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	83 ec 38             	sub    $0x38,%esp
  80101f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801022:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801025:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801028:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102d:	b8 06 00 00 00       	mov    $0x6,%eax
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	8b 55 08             	mov    0x8(%ebp),%edx
  801038:	89 df                	mov    %ebx,%edi
  80103a:	89 de                	mov    %ebx,%esi
  80103c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103e:	85 c0                	test   %eax,%eax
  801040:	7e 28                	jle    80106a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801042:	89 44 24 10          	mov    %eax,0x10(%esp)
  801046:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80104d:	00 
  80104e:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80105d:	00 
  80105e:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801065:	e8 5a f2 ff ff       	call   8002c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80106a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80106d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801070:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801073:	89 ec                	mov    %ebp,%esp
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 38             	sub    $0x38,%esp
  80107d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801080:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801083:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801086:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108b:	b8 08 00 00 00       	mov    $0x8,%eax
  801090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801093:	8b 55 08             	mov    0x8(%ebp),%edx
  801096:	89 df                	mov    %ebx,%edi
  801098:	89 de                	mov    %ebx,%esi
  80109a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	7e 28                	jle    8010c8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010ab:	00 
  8010ac:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8010b3:	00 
  8010b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010bb:	00 
  8010bc:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  8010c3:	e8 fc f1 ff ff       	call   8002c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d1:	89 ec                	mov    %ebp,%esp
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 38             	sub    $0x38,%esp
  8010db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e9:	b8 09 00 00 00       	mov    $0x9,%eax
  8010ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f4:	89 df                	mov    %ebx,%edi
  8010f6:	89 de                	mov    %ebx,%esi
  8010f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	7e 28                	jle    801126 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801102:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801109:	00 
  80110a:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801121:	e8 9e f1 ff ff       	call   8002c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801126:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801129:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80112c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80112f:	89 ec                	mov    %ebp,%esp
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80113c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80113f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801142:	be 00 00 00 00       	mov    $0x0,%esi
  801147:	b8 0b 00 00 00       	mov    $0xb,%eax
  80114c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114f:	8b 55 08             	mov    0x8(%ebp),%edx
  801152:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801155:	8b 7d 14             	mov    0x14(%ebp),%edi
  801158:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80115a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80115d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801160:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801163:	89 ec                	mov    %ebp,%esp
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 38             	sub    $0x38,%esp
  80116d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801170:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801173:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801176:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801180:	8b 55 08             	mov    0x8(%ebp),%edx
  801183:	89 cb                	mov    %ecx,%ebx
  801185:	89 cf                	mov    %ecx,%edi
  801187:	89 ce                	mov    %ecx,%esi
  801189:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80118b:	85 c0                	test   %eax,%eax
  80118d:	7e 28                	jle    8011b7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801193:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80119a:	00 
  80119b:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011aa:	00 
  8011ab:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  8011b2:	e8 0d f1 ff ff       	call   8002c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c0:	89 ec                	mov    %ebp,%esp
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    
	...

008011d0 <__udivdi3>:
  8011d0:	83 ec 1c             	sub    $0x1c,%esp
  8011d3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8011d7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011db:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011df:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011e3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8011e7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011f5:	89 ea                	mov    %ebp,%edx
  8011f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011fb:	75 33                	jne    801230 <__udivdi3+0x60>
  8011fd:	39 e9                	cmp    %ebp,%ecx
  8011ff:	77 6f                	ja     801270 <__udivdi3+0xa0>
  801201:	85 c9                	test   %ecx,%ecx
  801203:	89 ce                	mov    %ecx,%esi
  801205:	75 0b                	jne    801212 <__udivdi3+0x42>
  801207:	b8 01 00 00 00       	mov    $0x1,%eax
  80120c:	31 d2                	xor    %edx,%edx
  80120e:	f7 f1                	div    %ecx
  801210:	89 c6                	mov    %eax,%esi
  801212:	31 d2                	xor    %edx,%edx
  801214:	89 e8                	mov    %ebp,%eax
  801216:	f7 f6                	div    %esi
  801218:	89 c5                	mov    %eax,%ebp
  80121a:	89 f8                	mov    %edi,%eax
  80121c:	f7 f6                	div    %esi
  80121e:	89 ea                	mov    %ebp,%edx
  801220:	8b 74 24 10          	mov    0x10(%esp),%esi
  801224:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801228:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	c3                   	ret    
  801230:	39 e8                	cmp    %ebp,%eax
  801232:	77 24                	ja     801258 <__udivdi3+0x88>
  801234:	0f bd c8             	bsr    %eax,%ecx
  801237:	83 f1 1f             	xor    $0x1f,%ecx
  80123a:	89 0c 24             	mov    %ecx,(%esp)
  80123d:	75 49                	jne    801288 <__udivdi3+0xb8>
  80123f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801243:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801247:	0f 86 ab 00 00 00    	jbe    8012f8 <__udivdi3+0x128>
  80124d:	39 e8                	cmp    %ebp,%eax
  80124f:	0f 82 a3 00 00 00    	jb     8012f8 <__udivdi3+0x128>
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	31 c0                	xor    %eax,%eax
  80125c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801260:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801264:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801268:	83 c4 1c             	add    $0x1c,%esp
  80126b:	c3                   	ret    
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 f8                	mov    %edi,%eax
  801272:	f7 f1                	div    %ecx
  801274:	31 d2                	xor    %edx,%edx
  801276:	8b 74 24 10          	mov    0x10(%esp),%esi
  80127a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801282:	83 c4 1c             	add    $0x1c,%esp
  801285:	c3                   	ret    
  801286:	66 90                	xchg   %ax,%ax
  801288:	0f b6 0c 24          	movzbl (%esp),%ecx
  80128c:	89 c6                	mov    %eax,%esi
  80128e:	b8 20 00 00 00       	mov    $0x20,%eax
  801293:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801297:	2b 04 24             	sub    (%esp),%eax
  80129a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80129e:	d3 e6                	shl    %cl,%esi
  8012a0:	89 c1                	mov    %eax,%ecx
  8012a2:	d3 ed                	shr    %cl,%ebp
  8012a4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012a8:	09 f5                	or     %esi,%ebp
  8012aa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012ae:	d3 e6                	shl    %cl,%esi
  8012b0:	89 c1                	mov    %eax,%ecx
  8012b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b6:	89 d6                	mov    %edx,%esi
  8012b8:	d3 ee                	shr    %cl,%esi
  8012ba:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012be:	d3 e2                	shl    %cl,%edx
  8012c0:	89 c1                	mov    %eax,%ecx
  8012c2:	d3 ef                	shr    %cl,%edi
  8012c4:	09 d7                	or     %edx,%edi
  8012c6:	89 f2                	mov    %esi,%edx
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	f7 f5                	div    %ebp
  8012cc:	89 d6                	mov    %edx,%esi
  8012ce:	89 c7                	mov    %eax,%edi
  8012d0:	f7 64 24 04          	mull   0x4(%esp)
  8012d4:	39 d6                	cmp    %edx,%esi
  8012d6:	72 30                	jb     801308 <__udivdi3+0x138>
  8012d8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8012dc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012e0:	d3 e5                	shl    %cl,%ebp
  8012e2:	39 c5                	cmp    %eax,%ebp
  8012e4:	73 04                	jae    8012ea <__udivdi3+0x11a>
  8012e6:	39 d6                	cmp    %edx,%esi
  8012e8:	74 1e                	je     801308 <__udivdi3+0x138>
  8012ea:	89 f8                	mov    %edi,%eax
  8012ec:	31 d2                	xor    %edx,%edx
  8012ee:	e9 69 ff ff ff       	jmp    80125c <__udivdi3+0x8c>
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ff:	e9 58 ff ff ff       	jmp    80125c <__udivdi3+0x8c>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	8d 47 ff             	lea    -0x1(%edi),%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801311:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801315:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801319:	83 c4 1c             	add    $0x1c,%esp
  80131c:	c3                   	ret    
  80131d:	00 00                	add    %al,(%eax)
	...

00801320 <__umoddi3>:
  801320:	83 ec 2c             	sub    $0x2c,%esp
  801323:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801327:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80132b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80132f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801333:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801337:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80133b:	85 c0                	test   %eax,%eax
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801343:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801347:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80134f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801353:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801357:	75 1f                	jne    801378 <__umoddi3+0x58>
  801359:	39 fe                	cmp    %edi,%esi
  80135b:	76 63                	jbe    8013c0 <__umoddi3+0xa0>
  80135d:	89 c8                	mov    %ecx,%eax
  80135f:	89 fa                	mov    %edi,%edx
  801361:	f7 f6                	div    %esi
  801363:	89 d0                	mov    %edx,%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	8b 74 24 20          	mov    0x20(%esp),%esi
  80136b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80136f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801373:	83 c4 2c             	add    $0x2c,%esp
  801376:	c3                   	ret    
  801377:	90                   	nop
  801378:	39 f8                	cmp    %edi,%eax
  80137a:	77 64                	ja     8013e0 <__umoddi3+0xc0>
  80137c:	0f bd e8             	bsr    %eax,%ebp
  80137f:	83 f5 1f             	xor    $0x1f,%ebp
  801382:	75 74                	jne    8013f8 <__umoddi3+0xd8>
  801384:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801388:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80138c:	0f 87 0e 01 00 00    	ja     8014a0 <__umoddi3+0x180>
  801392:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801396:	29 f1                	sub    %esi,%ecx
  801398:	19 c7                	sbb    %eax,%edi
  80139a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80139e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8013a2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8013a6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8013aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013b2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013b6:	83 c4 2c             	add    $0x2c,%esp
  8013b9:	c3                   	ret    
  8013ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	89 f5                	mov    %esi,%ebp
  8013c4:	75 0b                	jne    8013d1 <__umoddi3+0xb1>
  8013c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	f7 f6                	div    %esi
  8013cf:	89 c5                	mov    %eax,%ebp
  8013d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013d5:	31 d2                	xor    %edx,%edx
  8013d7:	f7 f5                	div    %ebp
  8013d9:	89 c8                	mov    %ecx,%eax
  8013db:	f7 f5                	div    %ebp
  8013dd:	eb 84                	jmp    801363 <__umoddi3+0x43>
  8013df:	90                   	nop
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 fa                	mov    %edi,%edx
  8013e4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013e8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013ec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013f0:	83 c4 2c             	add    $0x2c,%esp
  8013f3:	c3                   	ret    
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013fc:	be 20 00 00 00       	mov    $0x20,%esi
  801401:	89 e9                	mov    %ebp,%ecx
  801403:	29 ee                	sub    %ebp,%esi
  801405:	d3 e2                	shl    %cl,%edx
  801407:	89 f1                	mov    %esi,%ecx
  801409:	d3 e8                	shr    %cl,%eax
  80140b:	89 e9                	mov    %ebp,%ecx
  80140d:	09 d0                	or     %edx,%eax
  80140f:	89 fa                	mov    %edi,%edx
  801411:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801415:	8b 44 24 10          	mov    0x10(%esp),%eax
  801419:	d3 e0                	shl    %cl,%eax
  80141b:	89 f1                	mov    %esi,%ecx
  80141d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801421:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801425:	d3 ea                	shr    %cl,%edx
  801427:	89 e9                	mov    %ebp,%ecx
  801429:	d3 e7                	shl    %cl,%edi
  80142b:	89 f1                	mov    %esi,%ecx
  80142d:	d3 e8                	shr    %cl,%eax
  80142f:	89 e9                	mov    %ebp,%ecx
  801431:	09 f8                	or     %edi,%eax
  801433:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801437:	f7 74 24 0c          	divl   0xc(%esp)
  80143b:	d3 e7                	shl    %cl,%edi
  80143d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801441:	89 d7                	mov    %edx,%edi
  801443:	f7 64 24 10          	mull   0x10(%esp)
  801447:	39 d7                	cmp    %edx,%edi
  801449:	89 c1                	mov    %eax,%ecx
  80144b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80144f:	72 3b                	jb     80148c <__umoddi3+0x16c>
  801451:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801455:	72 31                	jb     801488 <__umoddi3+0x168>
  801457:	8b 44 24 18          	mov    0x18(%esp),%eax
  80145b:	29 c8                	sub    %ecx,%eax
  80145d:	19 d7                	sbb    %edx,%edi
  80145f:	89 e9                	mov    %ebp,%ecx
  801461:	89 fa                	mov    %edi,%edx
  801463:	d3 e8                	shr    %cl,%eax
  801465:	89 f1                	mov    %esi,%ecx
  801467:	d3 e2                	shl    %cl,%edx
  801469:	89 e9                	mov    %ebp,%ecx
  80146b:	09 d0                	or     %edx,%eax
  80146d:	89 fa                	mov    %edi,%edx
  80146f:	d3 ea                	shr    %cl,%edx
  801471:	8b 74 24 20          	mov    0x20(%esp),%esi
  801475:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801479:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80147d:	83 c4 2c             	add    $0x2c,%esp
  801480:	c3                   	ret    
  801481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801488:	39 d7                	cmp    %edx,%edi
  80148a:	75 cb                	jne    801457 <__umoddi3+0x137>
  80148c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801490:	89 c1                	mov    %eax,%ecx
  801492:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801496:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80149a:	eb bb                	jmp    801457 <__umoddi3+0x137>
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8014a4:	0f 82 e8 fe ff ff    	jb     801392 <__umoddi3+0x72>
  8014aa:	e9 f3 fe ff ff       	jmp    8013a2 <__umoddi3+0x82>
