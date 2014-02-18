
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800063:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800066:	e8 09 01 00 00       	call   800174 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800088:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008c:	89 1c 24             	mov    %ebx,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 61 00 00 00       	call   800117 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 38             	sub    $0x38,%esp
  80011d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  800162:	e8 d5 02 00 00       	call   80043c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80016d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80017d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800180:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 02 00 00 00       	mov    $0x2,%eax
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 d3                	mov    %edx,%ebx
  800191:	89 d7                	mov    %edx,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800197:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a0:	89 ec                	mov    %ebp,%esp
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_yield>:

void
sys_yield(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	89 d3                	mov    %edx,%ebx
  8001c1:	89 d7                	mov    %edx,%edi
  8001c3:	89 d6                	mov    %edx,%esi
  8001c5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d0:	89 ec                	mov    %ebp,%esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 38             	sub    $0x38,%esp
  8001da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	be 00 00 00 00       	mov    $0x0,%esi
  8001e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f6:	89 f7                	mov    %esi,%edi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  800221:	e8 16 02 00 00       	call   80043c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800226:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800229:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80022c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 38             	sub    $0x38,%esp
  800239:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80023c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	b8 05 00 00 00       	mov    $0x5,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800250:	8b 7d 14             	mov    0x14(%ebp),%edi
  800253:	8b 75 18             	mov    0x18(%ebp),%esi
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 28                	jle    800284 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800260:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800267:	00 
  800268:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  80026f:	00 
  800270:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800277:	00 
  800278:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  80027f:	e8 b8 01 00 00       	call   80043c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800284:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800287:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80028a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80028d:	89 ec                	mov    %ebp,%esp
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 38             	sub    $0x38,%esp
  800297:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80029a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80029d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 df                	mov    %ebx,%edi
  8002b2:	89 de                	mov    %ebx,%esi
  8002b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 28                	jle    8002e2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002be:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  8002dd:	e8 5a 01 00 00       	call   80043c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002eb:	89 ec                	mov    %ebp,%esp
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 38             	sub    $0x38,%esp
  8002f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	b8 08 00 00 00       	mov    $0x8,%eax
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	89 df                	mov    %ebx,%edi
  800310:	89 de                	mov    %ebx,%esi
  800312:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7e 28                	jle    800340 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800323:	00 
  800324:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  80032b:	00 
  80032c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800333:	00 
  800334:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  80033b:	e8 fc 00 00 00       	call   80043c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800340:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800343:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800346:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800349:	89 ec                	mov    %ebp,%esp
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 38             	sub    $0x38,%esp
  800353:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800356:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800359:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800361:	b8 09 00 00 00       	mov    $0x9,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 df                	mov    %ebx,%edi
  80036e:	89 de                	mov    %ebx,%esi
  800370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  800399:	e8 9e 00 00 00       	call   80043c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a7:	89 ec                	mov    %ebp,%esp
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 0c             	sub    $0xc,%esp
  8003b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ba:	be 00 00 00 00       	mov    $0x0,%esi
  8003bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003db:	89 ec                	mov    %ebp,%esp
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 38             	sub    $0x38,%esp
  8003e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	89 cb                	mov    %ecx,%ebx
  8003fd:	89 cf                	mov    %ecx,%edi
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	7e 28                	jle    80042f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800412:	00 
  800413:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  80042a:	e8 0d 00 00 00       	call   80043c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800432:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800438:	89 ec                	mov    %ebp,%esp
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800444:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800447:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80044d:	e8 22 fd ff ff       	call   800174 <sys_getenvid>
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 54 24 10          	mov    %edx,0x10(%esp)
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800460:	89 74 24 08          	mov    %esi,0x8(%esp)
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 e4 12 80 00 	movl   $0x8012e4,(%esp)
  80046f:	e8 c3 00 00 00       	call   800537 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 45 10             	mov    0x10(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 53 00 00 00       	call   8004d6 <vcprintf>
	cprintf("\n");
  800483:	c7 04 24 ac 12 80 00 	movl   $0x8012ac,(%esp)
  80048a:	e8 a8 00 00 00       	call   800537 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048f:	cc                   	int3   
  800490:	eb fd                	jmp    80048f <_panic+0x53>
	...

00800494 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	53                   	push   %ebx
  800498:	83 ec 14             	sub    $0x14,%esp
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049e:	8b 03                	mov    (%ebx),%eax
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a7:	83 c0 01             	add    $0x1,%eax
  8004aa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b1:	75 19                	jne    8004cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ba:	00 
  8004bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	e8 f2 fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8004c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d0:	83 c4 14             	add    $0x14,%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e6:	00 00 00 
	b.cnt = 0;
  8004e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800501:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 94 04 80 00 	movl   $0x800494,(%esp)
  800512:	e8 bb 01 00 00       	call   8006d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 89 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  80052f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	8b 45 08             	mov    0x8(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 87 ff ff ff       	call   8004d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    
	...

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 4c             	sub    $0x4c,%esp
  800569:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80056c:	89 d7                	mov    %edx,%edi
  80056e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800571:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800577:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	39 d8                	cmp    %ebx,%eax
  800581:	72 17                	jb     80059a <printnum+0x3a>
  800583:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800586:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800589:	76 0f                	jbe    80059a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80058b:	8b 75 14             	mov    0x14(%ebp),%esi
  80058e:	83 ee 01             	sub    $0x1,%esi
  800591:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800594:	85 f6                	test   %esi,%esi
  800596:	7f 63                	jg     8005fb <printnum+0x9b>
  800598:	eb 75                	jmp    80060f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80059d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	83 e8 01             	sub    $0x1,%eax
  8005a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005b6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005c7:	00 
  8005c8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005cb:	89 1c 24             	mov    %ebx,(%esp)
  8005ce:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d5:	e8 e6 09 00 00       	call   800fc0 <__udivdi3>
  8005da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005e4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	89 fa                	mov    %edi,%edx
  8005f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005f4:	e8 67 ff ff ff       	call   800560 <printnum>
  8005f9:	eb 14                	jmp    80060f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ff:	8b 45 18             	mov    0x18(%ebp),%eax
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800607:	83 ee 01             	sub    $0x1,%esi
  80060a:	75 ef                	jne    8005fb <printnum+0x9b>
  80060c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800613:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800617:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80061e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800625:	00 
  800626:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800629:	89 1c 24             	mov    %ebx,(%esp)
  80062c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	e8 d8 0a 00 00       	call   801110 <__umoddi3>
  800638:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063c:	0f be 80 08 13 80 00 	movsbl 0x801308(%eax),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800649:	ff d0                	call   *%eax
}
  80064b:	83 c4 4c             	add    $0x4c,%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800656:	83 fa 01             	cmp    $0x1,%edx
  800659:	7e 0e                	jle    800669 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800660:	89 08                	mov    %ecx,(%eax)
  800662:	8b 02                	mov    (%edx),%eax
  800664:	8b 52 04             	mov    0x4(%edx),%edx
  800667:	eb 22                	jmp    80068b <getuint+0x38>
	else if (lflag)
  800669:	85 d2                	test   %edx,%edx
  80066b:	74 10                	je     80067d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800672:	89 08                	mov    %ecx,(%eax)
  800674:	8b 02                	mov    (%edx),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
  80067b:	eb 0e                	jmp    80068b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800682:	89 08                	mov    %ecx,(%eax)
  800684:	8b 02                	mov    (%edx),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800693:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800697:	8b 10                	mov    (%eax),%edx
  800699:	3b 50 04             	cmp    0x4(%eax),%edx
  80069c:	73 0a                	jae    8006a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80069e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a1:	88 0a                	mov    %cl,(%edx)
  8006a3:	83 c2 01             	add    $0x1,%edx
  8006a6:	89 10                	mov    %edx,(%eax)
}
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 02 00 00 00       	call   8006d2 <vprintfmt>
	va_end(ap);
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 4c             	sub    $0x4c,%esp
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e4:	eb 11                	jmp    8006f7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	0f 84 db 03 00 00    	je     800ac9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f7:	0f b6 07             	movzbl (%edi),%eax
  8006fa:	83 c7 01             	add    $0x1,%edi
  8006fd:	83 f8 25             	cmp    $0x25,%eax
  800700:	75 e4                	jne    8006e6 <vprintfmt+0x14>
  800702:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800706:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80070d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800714:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80071b:	ba 00 00 00 00       	mov    $0x0,%edx
  800720:	eb 2b                	jmp    80074d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800725:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800729:	eb 22                	jmp    80074d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80072e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800732:	eb 19                	jmp    80074d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800734:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800737:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80073e:	eb 0d                	jmp    80074d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800740:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	0f b6 0f             	movzbl (%edi),%ecx
  800750:	8d 47 01             	lea    0x1(%edi),%eax
  800753:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800756:	0f b6 07             	movzbl (%edi),%eax
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 40 03 00 00    	ja     800aa4 <vprintfmt+0x3d2>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80076e:	83 e9 30             	sub    $0x30,%ecx
  800771:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800774:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800778:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80077b:	83 f9 09             	cmp    $0x9,%ecx
  80077e:	77 57                	ja     8007d7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800780:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800783:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800786:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800789:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80078c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80078f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800793:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800796:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800799:	83 f9 09             	cmp    $0x9,%ecx
  80079c:	76 eb                	jbe    800789 <vprintfmt+0xb7>
  80079e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a4:	eb 34                	jmp    8007da <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b7:	eb 21                	jmp    8007da <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8007b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007bd:	0f 88 71 ff ff ff    	js     800734 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007c6:	eb 85                	jmp    80074d <vprintfmt+0x7b>
  8007c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007cb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8007d2:	e9 76 ff ff ff       	jmp    80074d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007de:	0f 89 69 ff ff ff    	jns    80074d <vprintfmt+0x7b>
  8007e4:	e9 57 ff ff ff       	jmp    800740 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ef:	e9 59 ff ff ff       	jmp    80074d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800801:	8b 00                	mov    (%eax),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800808:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80080b:	e9 e7 fe ff ff       	jmp    8006f7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	c1 fa 1f             	sar    $0x1f,%edx
  800820:	31 d0                	xor    %edx,%eax
  800822:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800824:	83 f8 08             	cmp    $0x8,%eax
  800827:	7f 0b                	jg     800834 <vprintfmt+0x162>
  800829:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800830:	85 d2                	test   %edx,%edx
  800832:	75 20                	jne    800854 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	c7 44 24 08 20 13 80 	movl   $0x801320,0x8(%esp)
  80083f:	00 
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	89 34 24             	mov    %esi,(%esp)
  800847:	e8 5e fe ff ff       	call   8006aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80084f:	e9 a3 fe ff ff       	jmp    8006f7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800854:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800858:	c7 44 24 08 29 13 80 	movl   $0x801329,0x8(%esp)
  80085f:	00 
  800860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800864:	89 34 24             	mov    %esi,(%esp)
  800867:	e8 3e fe ff ff       	call   8006aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80086f:	e9 83 fe ff ff       	jmp    8006f7 <vprintfmt+0x25>
  800874:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800877:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80087a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)
  800886:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800888:	85 ff                	test   %edi,%edi
  80088a:	b8 19 13 80 00       	mov    $0x801319,%eax
  80088f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800892:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800896:	74 06                	je     80089e <vprintfmt+0x1cc>
  800898:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80089c:	7f 16                	jg     8008b4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80089e:	0f b6 17             	movzbl (%edi),%edx
  8008a1:	0f be c2             	movsbl %dl,%eax
  8008a4:	83 c7 01             	add    $0x1,%edi
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	0f 85 9f 00 00 00    	jne    80094e <vprintfmt+0x27c>
  8008af:	e9 8b 00 00 00       	jmp    80093f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b8:	89 3c 24             	mov    %edi,(%esp)
  8008bb:	e8 c2 02 00 00       	call   800b82 <strnlen>
  8008c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008c3:	29 c2                	sub    %eax,%edx
  8008c5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	7e d2                	jle    80089e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008cc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8008d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008d3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008d6:	89 d7                	mov    %edx,%edi
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e4:	83 ef 01             	sub    $0x1,%edi
  8008e7:	75 ef                	jne    8008d8 <vprintfmt+0x206>
  8008e9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ef:	eb ad                	jmp    80089e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008f5:	74 20                	je     800917 <vprintfmt+0x245>
  8008f7:	0f be d2             	movsbl %dl,%edx
  8008fa:	83 ea 20             	sub    $0x20,%edx
  8008fd:	83 fa 5e             	cmp    $0x5e,%edx
  800900:	76 15                	jbe    800917 <vprintfmt+0x245>
					putch('?', putdat);
  800902:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800905:	89 54 24 04          	mov    %edx,0x4(%esp)
  800909:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800910:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800913:	ff d1                	call   *%ecx
  800915:	eb 0f                	jmp    800926 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800917:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80091a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800924:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800926:	83 eb 01             	sub    $0x1,%ebx
  800929:	0f b6 17             	movzbl (%edi),%edx
  80092c:	0f be c2             	movsbl %dl,%eax
  80092f:	83 c7 01             	add    $0x1,%edi
  800932:	85 c0                	test   %eax,%eax
  800934:	75 24                	jne    80095a <vprintfmt+0x288>
  800936:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800939:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80093c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800942:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800946:	0f 8e ab fd ff ff    	jle    8006f7 <vprintfmt+0x25>
  80094c:	eb 20                	jmp    80096e <vprintfmt+0x29c>
  80094e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800951:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800954:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800957:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80095a:	85 f6                	test   %esi,%esi
  80095c:	78 93                	js     8008f1 <vprintfmt+0x21f>
  80095e:	83 ee 01             	sub    $0x1,%esi
  800961:	79 8e                	jns    8008f1 <vprintfmt+0x21f>
  800963:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800966:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800969:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80096c:	eb d1                	jmp    80093f <vprintfmt+0x26d>
  80096e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800971:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800975:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80097c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80097e:	83 ef 01             	sub    $0x1,%edi
  800981:	75 ee                	jne    800971 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800986:	e9 6c fd ff ff       	jmp    8006f7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80098b:	83 fa 01             	cmp    $0x1,%edx
  80098e:	66 90                	xchg   %ax,%ax
  800990:	7e 16                	jle    8009a8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8d 50 08             	lea    0x8(%eax),%edx
  800998:	89 55 14             	mov    %edx,0x14(%ebp)
  80099b:	8b 10                	mov    (%eax),%edx
  80099d:	8b 48 04             	mov    0x4(%eax),%ecx
  8009a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009a6:	eb 32                	jmp    8009da <vprintfmt+0x308>
	else if (lflag)
  8009a8:	85 d2                	test   %edx,%edx
  8009aa:	74 18                	je     8009c4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8009ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8009af:	8d 50 04             	lea    0x4(%eax),%edx
  8009b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b5:	8b 00                	mov    (%eax),%eax
  8009b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ba:	89 c1                	mov    %eax,%ecx
  8009bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8009bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009c2:	eb 16                	jmp    8009da <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cd:	8b 00                	mov    (%eax),%eax
  8009cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	c1 ff 1f             	sar    $0x1f,%edi
  8009d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009e9:	79 7d                	jns    800a68 <vprintfmt+0x396>
				putch('-', putdat);
  8009eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009fe:	f7 d8                	neg    %eax
  800a00:	83 d2 00             	adc    $0x0,%edx
  800a03:	f7 da                	neg    %edx
			}
			base = 10;
  800a05:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a0a:	eb 5c                	jmp    800a68 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a0c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0f:	e8 3f fc ff ff       	call   800653 <getuint>
			base = 10;
  800a14:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a19:	eb 4d                	jmp    800a68 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  800a1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1e:	e8 30 fc ff ff       	call   800653 <getuint>
      base = 8;
  800a23:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800a28:	eb 3e                	jmp    800a68 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a35:	ff d6                	call   *%esi
			putch('x', putdat);
  800a37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a42:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8d 50 04             	lea    0x4(%eax),%edx
  800a4a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4d:	8b 00                	mov    (%eax),%eax
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a54:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a59:	eb 0d                	jmp    800a68 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5e:	e8 f0 fb ff ff       	call   800653 <getuint>
			base = 16;
  800a63:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a68:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800a6c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a70:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a73:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a82:	89 da                	mov    %ebx,%edx
  800a84:	89 f0                	mov    %esi,%eax
  800a86:	e8 d5 fa ff ff       	call   800560 <printnum>
			break;
  800a8b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a8e:	e9 64 fc ff ff       	jmp    8006f7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a97:	89 0c 24             	mov    %ecx,(%esp)
  800a9a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a9f:	e9 53 fc ff ff       	jmp    8006f7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aaf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ab5:	0f 84 3c fc ff ff    	je     8006f7 <vprintfmt+0x25>
  800abb:	83 ef 01             	sub    $0x1,%edi
  800abe:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ac2:	75 f7                	jne    800abb <vprintfmt+0x3e9>
  800ac4:	e9 2e fc ff ff       	jmp    8006f7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800ac9:	83 c4 4c             	add    $0x4c,%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 28             	sub    $0x28,%esp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800add:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ae0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ae4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ae7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aee:	85 d2                	test   %edx,%edx
  800af0:	7e 30                	jle    800b22 <vsnprintf+0x51>
  800af2:	85 c0                	test   %eax,%eax
  800af4:	74 2c                	je     800b22 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800afd:	8b 45 10             	mov    0x10(%ebp),%eax
  800b00:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b04:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0b:	c7 04 24 8d 06 80 00 	movl   $0x80068d,(%esp)
  800b12:	e8 bb fb ff ff       	call   8006d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b20:	eb 05                	jmp    800b27 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b2f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b36:	8b 45 10             	mov    0x10(%ebp),%eax
  800b39:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	89 04 24             	mov    %eax,(%esp)
  800b4a:	e8 82 ff ff ff       	call   800ad1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    
	...

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	80 3a 00             	cmpb   $0x0,(%edx)
  800b69:	74 10                	je     800b7b <strlen+0x1b>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b77:	75 f7                	jne    800b70 <strlen+0x10>
  800b79:	eb 05                	jmp    800b80 <strlen+0x20>
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8c:	85 c9                	test   %ecx,%ecx
  800b8e:	74 1c                	je     800bac <strnlen+0x2a>
  800b90:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b93:	74 1e                	je     800bb3 <strnlen+0x31>
  800b95:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b9a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9c:	39 ca                	cmp    %ecx,%edx
  800b9e:	74 18                	je     800bb8 <strnlen+0x36>
  800ba0:	83 c2 01             	add    $0x1,%edx
  800ba3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ba8:	75 f0                	jne    800b9a <strnlen+0x18>
  800baa:	eb 0c                	jmp    800bb8 <strnlen+0x36>
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	eb 05                	jmp    800bb8 <strnlen+0x36>
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	0f b6 19             	movzbl (%ecx),%ebx
  800bca:	88 1a                	mov    %bl,(%edx)
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	83 c1 01             	add    $0x1,%ecx
  800bd2:	84 db                	test   %bl,%bl
  800bd4:	75 f1                	jne    800bc7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 75 ff ff ff       	call   800b60 <strlen>
	strcpy(dst + len, src);
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bee:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf2:	01 d8                	add    %ebx,%eax
  800bf4:	89 04 24             	mov    %eax,(%esp)
  800bf7:	e8 bf ff ff ff       	call   800bbb <strcpy>
	return dst;
}
  800bfc:	89 d8                	mov    %ebx,%eax
  800bfe:	83 c4 08             	add    $0x8,%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c12:	85 db                	test   %ebx,%ebx
  800c14:	74 16                	je     800c2c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800c16:	01 f3                	add    %esi,%ebx
  800c18:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800c1a:	0f b6 02             	movzbl (%edx),%eax
  800c1d:	88 01                	mov    %al,(%ecx)
  800c1f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c22:	80 3a 01             	cmpb   $0x1,(%edx)
  800c25:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c28:	39 d9                	cmp    %ebx,%ecx
  800c2a:	75 ee                	jne    800c1a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c2c:	89 f0                	mov    %esi,%eax
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c41:	89 f8                	mov    %edi,%eax
  800c43:	85 f6                	test   %esi,%esi
  800c45:	74 33                	je     800c7a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800c47:	83 fe 01             	cmp    $0x1,%esi
  800c4a:	74 25                	je     800c71 <strlcpy+0x3f>
  800c4c:	0f b6 0b             	movzbl (%ebx),%ecx
  800c4f:	84 c9                	test   %cl,%cl
  800c51:	74 22                	je     800c75 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c53:	83 ee 02             	sub    $0x2,%esi
  800c56:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c5b:	88 08                	mov    %cl,(%eax)
  800c5d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c60:	39 f2                	cmp    %esi,%edx
  800c62:	74 13                	je     800c77 <strlcpy+0x45>
  800c64:	83 c2 01             	add    $0x1,%edx
  800c67:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c6b:	84 c9                	test   %cl,%cl
  800c6d:	75 ec                	jne    800c5b <strlcpy+0x29>
  800c6f:	eb 06                	jmp    800c77 <strlcpy+0x45>
  800c71:	89 f8                	mov    %edi,%eax
  800c73:	eb 02                	jmp    800c77 <strlcpy+0x45>
  800c75:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c77:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c7a:	29 f8                	sub    %edi,%eax
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c8a:	0f b6 01             	movzbl (%ecx),%eax
  800c8d:	84 c0                	test   %al,%al
  800c8f:	74 15                	je     800ca6 <strcmp+0x25>
  800c91:	3a 02                	cmp    (%edx),%al
  800c93:	75 11                	jne    800ca6 <strcmp+0x25>
		p++, q++;
  800c95:	83 c1 01             	add    $0x1,%ecx
  800c98:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c9b:	0f b6 01             	movzbl (%ecx),%eax
  800c9e:	84 c0                	test   %al,%al
  800ca0:	74 04                	je     800ca6 <strcmp+0x25>
  800ca2:	3a 02                	cmp    (%edx),%al
  800ca4:	74 ef                	je     800c95 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca6:	0f b6 c0             	movzbl %al,%eax
  800ca9:	0f b6 12             	movzbl (%edx),%edx
  800cac:	29 d0                	sub    %edx,%eax
}
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	74 29                	je     800ceb <strncmp+0x3b>
  800cc2:	0f b6 03             	movzbl (%ebx),%eax
  800cc5:	84 c0                	test   %al,%al
  800cc7:	74 30                	je     800cf9 <strncmp+0x49>
  800cc9:	3a 02                	cmp    (%edx),%al
  800ccb:	75 2c                	jne    800cf9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800ccd:	8d 43 01             	lea    0x1(%ebx),%eax
  800cd0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800cd2:	89 c3                	mov    %eax,%ebx
  800cd4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cd7:	39 f0                	cmp    %esi,%eax
  800cd9:	74 17                	je     800cf2 <strncmp+0x42>
  800cdb:	0f b6 08             	movzbl (%eax),%ecx
  800cde:	84 c9                	test   %cl,%cl
  800ce0:	74 17                	je     800cf9 <strncmp+0x49>
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	3a 0a                	cmp    (%edx),%cl
  800ce7:	74 e9                	je     800cd2 <strncmp+0x22>
  800ce9:	eb 0e                	jmp    800cf9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf0:	eb 0f                	jmp    800d01 <strncmp+0x51>
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	eb 08                	jmp    800d01 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cf9:	0f b6 03             	movzbl (%ebx),%eax
  800cfc:	0f b6 12             	movzbl (%edx),%edx
  800cff:	29 d0                	sub    %edx,%eax
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	53                   	push   %ebx
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d0f:	0f b6 18             	movzbl (%eax),%ebx
  800d12:	84 db                	test   %bl,%bl
  800d14:	74 1d                	je     800d33 <strchr+0x2e>
  800d16:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d18:	38 d3                	cmp    %dl,%bl
  800d1a:	75 06                	jne    800d22 <strchr+0x1d>
  800d1c:	eb 1a                	jmp    800d38 <strchr+0x33>
  800d1e:	38 ca                	cmp    %cl,%dl
  800d20:	74 16                	je     800d38 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d22:	83 c0 01             	add    $0x1,%eax
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	75 f2                	jne    800d1e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	eb 05                	jmp    800d38 <strchr+0x33>
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d38:	5b                   	pop    %ebx
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	53                   	push   %ebx
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d45:	0f b6 18             	movzbl (%eax),%ebx
  800d48:	84 db                	test   %bl,%bl
  800d4a:	74 16                	je     800d62 <strfind+0x27>
  800d4c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d4e:	38 d3                	cmp    %dl,%bl
  800d50:	75 06                	jne    800d58 <strfind+0x1d>
  800d52:	eb 0e                	jmp    800d62 <strfind+0x27>
  800d54:	38 ca                	cmp    %cl,%dl
  800d56:	74 0a                	je     800d62 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d58:	83 c0 01             	add    $0x1,%eax
  800d5b:	0f b6 10             	movzbl (%eax),%edx
  800d5e:	84 d2                	test   %dl,%dl
  800d60:	75 f2                	jne    800d54 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800d62:	5b                   	pop    %ebx
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d71:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d7a:	85 c9                	test   %ecx,%ecx
  800d7c:	74 36                	je     800db4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d84:	75 28                	jne    800dae <memset+0x49>
  800d86:	f6 c1 03             	test   $0x3,%cl
  800d89:	75 23                	jne    800dae <memset+0x49>
		c &= 0xFF;
  800d8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d8f:	89 d3                	mov    %edx,%ebx
  800d91:	c1 e3 08             	shl    $0x8,%ebx
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	c1 e6 18             	shl    $0x18,%esi
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	c1 e0 10             	shl    $0x10,%eax
  800d9e:	09 f0                	or     %esi,%eax
  800da0:	09 c2                	or     %eax,%edx
  800da2:	89 d0                	mov    %edx,%eax
  800da4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800da6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800da9:	fc                   	cld    
  800daa:	f3 ab                	rep stos %eax,%es:(%edi)
  800dac:	eb 06                	jmp    800db4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db1:	fc                   	cld    
  800db2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800db4:	89 f8                	mov    %edi,%eax
  800db6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbf:	89 ec                	mov    %ebp,%esp
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd8:	39 c6                	cmp    %eax,%esi
  800dda:	73 36                	jae    800e12 <memmove+0x4f>
  800ddc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ddf:	39 d0                	cmp    %edx,%eax
  800de1:	73 2f                	jae    800e12 <memmove+0x4f>
		s += n;
		d += n;
  800de3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de6:	f6 c2 03             	test   $0x3,%dl
  800de9:	75 1b                	jne    800e06 <memmove+0x43>
  800deb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df1:	75 13                	jne    800e06 <memmove+0x43>
  800df3:	f6 c1 03             	test   $0x3,%cl
  800df6:	75 0e                	jne    800e06 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800df8:	83 ef 04             	sub    $0x4,%edi
  800dfb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dfe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e01:	fd                   	std    
  800e02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e04:	eb 09                	jmp    800e0f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e06:	83 ef 01             	sub    $0x1,%edi
  800e09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e0c:	fd                   	std    
  800e0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e0f:	fc                   	cld    
  800e10:	eb 20                	jmp    800e32 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e18:	75 13                	jne    800e2d <memmove+0x6a>
  800e1a:	a8 03                	test   $0x3,%al
  800e1c:	75 0f                	jne    800e2d <memmove+0x6a>
  800e1e:	f6 c1 03             	test   $0x3,%cl
  800e21:	75 0a                	jne    800e2d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	fc                   	cld    
  800e29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2b:	eb 05                	jmp    800e32 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e2d:	89 c7                	mov    %eax,%edi
  800e2f:	fc                   	cld    
  800e30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e42:	8b 45 10             	mov    0x10(%ebp),%eax
  800e45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	89 04 24             	mov    %eax,(%esp)
  800e56:	e8 68 ff ff ff       	call   800dc3 <memmove>
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e69:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	74 36                	je     800ea9 <memcmp+0x4c>
		if (*s1 != *s2)
  800e73:	0f b6 03             	movzbl (%ebx),%eax
  800e76:	0f b6 0e             	movzbl (%esi),%ecx
  800e79:	38 c8                	cmp    %cl,%al
  800e7b:	75 17                	jne    800e94 <memcmp+0x37>
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	eb 1a                	jmp    800e9e <memcmp+0x41>
  800e84:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e89:	83 c2 01             	add    $0x1,%edx
  800e8c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e90:	38 c8                	cmp    %cl,%al
  800e92:	74 0a                	je     800e9e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800e94:	0f b6 c0             	movzbl %al,%eax
  800e97:	0f b6 c9             	movzbl %cl,%ecx
  800e9a:	29 c8                	sub    %ecx,%eax
  800e9c:	eb 10                	jmp    800eae <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e9e:	39 fa                	cmp    %edi,%edx
  800ea0:	75 e2                	jne    800e84 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 05                	jmp    800eae <memcmp+0x51>
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	53                   	push   %ebx
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ec2:	39 d0                	cmp    %edx,%eax
  800ec4:	73 13                	jae    800ed9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec6:	89 d9                	mov    %ebx,%ecx
  800ec8:	38 18                	cmp    %bl,(%eax)
  800eca:	75 06                	jne    800ed2 <memfind+0x1f>
  800ecc:	eb 0b                	jmp    800ed9 <memfind+0x26>
  800ece:	38 08                	cmp    %cl,(%eax)
  800ed0:	74 07                	je     800ed9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed2:	83 c0 01             	add    $0x1,%eax
  800ed5:	39 d0                	cmp    %edx,%eax
  800ed7:	75 f5                	jne    800ece <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eeb:	0f b6 02             	movzbl (%edx),%eax
  800eee:	3c 09                	cmp    $0x9,%al
  800ef0:	74 04                	je     800ef6 <strtol+0x1a>
  800ef2:	3c 20                	cmp    $0x20,%al
  800ef4:	75 0e                	jne    800f04 <strtol+0x28>
		s++;
  800ef6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ef9:	0f b6 02             	movzbl (%edx),%eax
  800efc:	3c 09                	cmp    $0x9,%al
  800efe:	74 f6                	je     800ef6 <strtol+0x1a>
  800f00:	3c 20                	cmp    $0x20,%al
  800f02:	74 f2                	je     800ef6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f04:	3c 2b                	cmp    $0x2b,%al
  800f06:	75 0a                	jne    800f12 <strtol+0x36>
		s++;
  800f08:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f10:	eb 10                	jmp    800f22 <strtol+0x46>
  800f12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f17:	3c 2d                	cmp    $0x2d,%al
  800f19:	75 07                	jne    800f22 <strtol+0x46>
		s++, neg = 1;
  800f1b:	83 c2 01             	add    $0x1,%edx
  800f1e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f28:	75 15                	jne    800f3f <strtol+0x63>
  800f2a:	80 3a 30             	cmpb   $0x30,(%edx)
  800f2d:	75 10                	jne    800f3f <strtol+0x63>
  800f2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f33:	75 0a                	jne    800f3f <strtol+0x63>
		s += 2, base = 16;
  800f35:	83 c2 02             	add    $0x2,%edx
  800f38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f3d:	eb 10                	jmp    800f4f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f3f:	85 db                	test   %ebx,%ebx
  800f41:	75 0c                	jne    800f4f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f43:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f45:	80 3a 30             	cmpb   $0x30,(%edx)
  800f48:	75 05                	jne    800f4f <strtol+0x73>
		s++, base = 8;
  800f4a:	83 c2 01             	add    $0x1,%edx
  800f4d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f54:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f57:	0f b6 0a             	movzbl (%edx),%ecx
  800f5a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f5d:	89 f3                	mov    %esi,%ebx
  800f5f:	80 fb 09             	cmp    $0x9,%bl
  800f62:	77 08                	ja     800f6c <strtol+0x90>
			dig = *s - '0';
  800f64:	0f be c9             	movsbl %cl,%ecx
  800f67:	83 e9 30             	sub    $0x30,%ecx
  800f6a:	eb 22                	jmp    800f8e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800f6c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f6f:	89 f3                	mov    %esi,%ebx
  800f71:	80 fb 19             	cmp    $0x19,%bl
  800f74:	77 08                	ja     800f7e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800f76:	0f be c9             	movsbl %cl,%ecx
  800f79:	83 e9 57             	sub    $0x57,%ecx
  800f7c:	eb 10                	jmp    800f8e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800f7e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	80 fb 19             	cmp    $0x19,%bl
  800f86:	77 16                	ja     800f9e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800f88:	0f be c9             	movsbl %cl,%ecx
  800f8b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f8e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f91:	7d 0f                	jge    800fa2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800f93:	83 c2 01             	add    $0x1,%edx
  800f96:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800f9a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f9c:	eb b9                	jmp    800f57 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f9e:	89 c1                	mov    %eax,%ecx
  800fa0:	eb 02                	jmp    800fa4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fa2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fa4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fa8:	74 05                	je     800faf <strtol+0xd3>
		*endptr = (char *) s;
  800faa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fad:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800faf:	89 ca                	mov    %ecx,%edx
  800fb1:	f7 da                	neg    %edx
  800fb3:	85 ff                	test   %edi,%edi
  800fb5:	0f 45 c2             	cmovne %edx,%eax
}
  800fb8:	83 c4 04             	add    $0x4,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <__udivdi3>:
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
  800fc3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800fc7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fcb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fcf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fd3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800fd7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fe1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe5:	89 ea                	mov    %ebp,%edx
  800fe7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800feb:	75 33                	jne    801020 <__udivdi3+0x60>
  800fed:	39 e9                	cmp    %ebp,%ecx
  800fef:	77 6f                	ja     801060 <__udivdi3+0xa0>
  800ff1:	85 c9                	test   %ecx,%ecx
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	75 0b                	jne    801002 <__udivdi3+0x42>
  800ff7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	f7 f1                	div    %ecx
  801000:	89 c6                	mov    %eax,%esi
  801002:	31 d2                	xor    %edx,%edx
  801004:	89 e8                	mov    %ebp,%eax
  801006:	f7 f6                	div    %esi
  801008:	89 c5                	mov    %eax,%ebp
  80100a:	89 f8                	mov    %edi,%eax
  80100c:	f7 f6                	div    %esi
  80100e:	89 ea                	mov    %ebp,%edx
  801010:	8b 74 24 10          	mov    0x10(%esp),%esi
  801014:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801018:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80101c:	83 c4 1c             	add    $0x1c,%esp
  80101f:	c3                   	ret    
  801020:	39 e8                	cmp    %ebp,%eax
  801022:	77 24                	ja     801048 <__udivdi3+0x88>
  801024:	0f bd c8             	bsr    %eax,%ecx
  801027:	83 f1 1f             	xor    $0x1f,%ecx
  80102a:	89 0c 24             	mov    %ecx,(%esp)
  80102d:	75 49                	jne    801078 <__udivdi3+0xb8>
  80102f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801033:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801037:	0f 86 ab 00 00 00    	jbe    8010e8 <__udivdi3+0x128>
  80103d:	39 e8                	cmp    %ebp,%eax
  80103f:	0f 82 a3 00 00 00    	jb     8010e8 <__udivdi3+0x128>
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	31 d2                	xor    %edx,%edx
  80104a:	31 c0                	xor    %eax,%eax
  80104c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801050:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801054:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801058:	83 c4 1c             	add    $0x1c,%esp
  80105b:	c3                   	ret    
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	89 f8                	mov    %edi,%eax
  801062:	f7 f1                	div    %ecx
  801064:	31 d2                	xor    %edx,%edx
  801066:	8b 74 24 10          	mov    0x10(%esp),%esi
  80106a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80106e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801072:	83 c4 1c             	add    $0x1c,%esp
  801075:	c3                   	ret    
  801076:	66 90                	xchg   %ax,%ax
  801078:	0f b6 0c 24          	movzbl (%esp),%ecx
  80107c:	89 c6                	mov    %eax,%esi
  80107e:	b8 20 00 00 00       	mov    $0x20,%eax
  801083:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801087:	2b 04 24             	sub    (%esp),%eax
  80108a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80108e:	d3 e6                	shl    %cl,%esi
  801090:	89 c1                	mov    %eax,%ecx
  801092:	d3 ed                	shr    %cl,%ebp
  801094:	0f b6 0c 24          	movzbl (%esp),%ecx
  801098:	09 f5                	or     %esi,%ebp
  80109a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80109e:	d3 e6                	shl    %cl,%esi
  8010a0:	89 c1                	mov    %eax,%ecx
  8010a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a6:	89 d6                	mov    %edx,%esi
  8010a8:	d3 ee                	shr    %cl,%esi
  8010aa:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	89 c1                	mov    %eax,%ecx
  8010b2:	d3 ef                	shr    %cl,%edi
  8010b4:	09 d7                	or     %edx,%edi
  8010b6:	89 f2                	mov    %esi,%edx
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	f7 f5                	div    %ebp
  8010bc:	89 d6                	mov    %edx,%esi
  8010be:	89 c7                	mov    %eax,%edi
  8010c0:	f7 64 24 04          	mull   0x4(%esp)
  8010c4:	39 d6                	cmp    %edx,%esi
  8010c6:	72 30                	jb     8010f8 <__udivdi3+0x138>
  8010c8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010cc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010d0:	d3 e5                	shl    %cl,%ebp
  8010d2:	39 c5                	cmp    %eax,%ebp
  8010d4:	73 04                	jae    8010da <__udivdi3+0x11a>
  8010d6:	39 d6                	cmp    %edx,%esi
  8010d8:	74 1e                	je     8010f8 <__udivdi3+0x138>
  8010da:	89 f8                	mov    %edi,%eax
  8010dc:	31 d2                	xor    %edx,%edx
  8010de:	e9 69 ff ff ff       	jmp    80104c <__udivdi3+0x8c>
  8010e3:	90                   	nop
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	31 d2                	xor    %edx,%edx
  8010ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ef:	e9 58 ff ff ff       	jmp    80104c <__udivdi3+0x8c>
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801101:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801105:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801109:	83 c4 1c             	add    $0x1c,%esp
  80110c:	c3                   	ret    
  80110d:	00 00                	add    %al,(%eax)
	...

00801110 <__umoddi3>:
  801110:	83 ec 2c             	sub    $0x2c,%esp
  801113:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801117:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80111b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80111f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801123:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801127:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80112b:	85 c0                	test   %eax,%eax
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801133:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801137:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80113f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801143:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801147:	75 1f                	jne    801168 <__umoddi3+0x58>
  801149:	39 fe                	cmp    %edi,%esi
  80114b:	76 63                	jbe    8011b0 <__umoddi3+0xa0>
  80114d:	89 c8                	mov    %ecx,%eax
  80114f:	89 fa                	mov    %edi,%edx
  801151:	f7 f6                	div    %esi
  801153:	89 d0                	mov    %edx,%eax
  801155:	31 d2                	xor    %edx,%edx
  801157:	8b 74 24 20          	mov    0x20(%esp),%esi
  80115b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80115f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801163:	83 c4 2c             	add    $0x2c,%esp
  801166:	c3                   	ret    
  801167:	90                   	nop
  801168:	39 f8                	cmp    %edi,%eax
  80116a:	77 64                	ja     8011d0 <__umoddi3+0xc0>
  80116c:	0f bd e8             	bsr    %eax,%ebp
  80116f:	83 f5 1f             	xor    $0x1f,%ebp
  801172:	75 74                	jne    8011e8 <__umoddi3+0xd8>
  801174:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801178:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80117c:	0f 87 0e 01 00 00    	ja     801290 <__umoddi3+0x180>
  801182:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801186:	29 f1                	sub    %esi,%ecx
  801188:	19 c7                	sbb    %eax,%edi
  80118a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80118e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801192:	8b 44 24 14          	mov    0x14(%esp),%eax
  801196:	8b 54 24 18          	mov    0x18(%esp),%edx
  80119a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80119e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011a2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011a6:	83 c4 2c             	add    $0x2c,%esp
  8011a9:	c3                   	ret    
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	85 f6                	test   %esi,%esi
  8011b2:	89 f5                	mov    %esi,%ebp
  8011b4:	75 0b                	jne    8011c1 <__umoddi3+0xb1>
  8011b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	f7 f6                	div    %esi
  8011bf:	89 c5                	mov    %eax,%ebp
  8011c1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011c5:	31 d2                	xor    %edx,%edx
  8011c7:	f7 f5                	div    %ebp
  8011c9:	89 c8                	mov    %ecx,%eax
  8011cb:	f7 f5                	div    %ebp
  8011cd:	eb 84                	jmp    801153 <__umoddi3+0x43>
  8011cf:	90                   	nop
  8011d0:	89 c8                	mov    %ecx,%eax
  8011d2:	89 fa                	mov    %edi,%edx
  8011d4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011d8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011dc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011e0:	83 c4 2c             	add    $0x2c,%esp
  8011e3:	c3                   	ret    
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011ec:	be 20 00 00 00       	mov    $0x20,%esi
  8011f1:	89 e9                	mov    %ebp,%ecx
  8011f3:	29 ee                	sub    %ebp,%esi
  8011f5:	d3 e2                	shl    %cl,%edx
  8011f7:	89 f1                	mov    %esi,%ecx
  8011f9:	d3 e8                	shr    %cl,%eax
  8011fb:	89 e9                	mov    %ebp,%ecx
  8011fd:	09 d0                	or     %edx,%eax
  8011ff:	89 fa                	mov    %edi,%edx
  801201:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801205:	8b 44 24 10          	mov    0x10(%esp),%eax
  801209:	d3 e0                	shl    %cl,%eax
  80120b:	89 f1                	mov    %esi,%ecx
  80120d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801211:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801215:	d3 ea                	shr    %cl,%edx
  801217:	89 e9                	mov    %ebp,%ecx
  801219:	d3 e7                	shl    %cl,%edi
  80121b:	89 f1                	mov    %esi,%ecx
  80121d:	d3 e8                	shr    %cl,%eax
  80121f:	89 e9                	mov    %ebp,%ecx
  801221:	09 f8                	or     %edi,%eax
  801223:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801227:	f7 74 24 0c          	divl   0xc(%esp)
  80122b:	d3 e7                	shl    %cl,%edi
  80122d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801231:	89 d7                	mov    %edx,%edi
  801233:	f7 64 24 10          	mull   0x10(%esp)
  801237:	39 d7                	cmp    %edx,%edi
  801239:	89 c1                	mov    %eax,%ecx
  80123b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80123f:	72 3b                	jb     80127c <__umoddi3+0x16c>
  801241:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801245:	72 31                	jb     801278 <__umoddi3+0x168>
  801247:	8b 44 24 18          	mov    0x18(%esp),%eax
  80124b:	29 c8                	sub    %ecx,%eax
  80124d:	19 d7                	sbb    %edx,%edi
  80124f:	89 e9                	mov    %ebp,%ecx
  801251:	89 fa                	mov    %edi,%edx
  801253:	d3 e8                	shr    %cl,%eax
  801255:	89 f1                	mov    %esi,%ecx
  801257:	d3 e2                	shl    %cl,%edx
  801259:	89 e9                	mov    %ebp,%ecx
  80125b:	09 d0                	or     %edx,%eax
  80125d:	89 fa                	mov    %edi,%edx
  80125f:	d3 ea                	shr    %cl,%edx
  801261:	8b 74 24 20          	mov    0x20(%esp),%esi
  801265:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801269:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80126d:	83 c4 2c             	add    $0x2c,%esp
  801270:	c3                   	ret    
  801271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801278:	39 d7                	cmp    %edx,%edi
  80127a:	75 cb                	jne    801247 <__umoddi3+0x137>
  80127c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801280:	89 c1                	mov    %eax,%ecx
  801282:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801286:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80128a:	eb bb                	jmp    801247 <__umoddi3+0x137>
  80128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801290:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801294:	0f 82 e8 fe ff ff    	jb     801182 <__umoddi3+0x72>
  80129a:	e9 f3 fe ff ff       	jmp    801192 <__umoddi3+0x82>
