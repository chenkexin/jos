
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80004e:	e8 09 01 00 00       	call   80015c <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 74 24 04          	mov    %esi,0x4(%esp)
  800074:	89 1c 24             	mov    %ebx,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 61 00 00 00       	call   8000ff <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cb:	89 ec                	mov    %ebp,%esp
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 38             	sub    $0x38,%esp
  800105:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800108:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 28                	jle    80014f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  80014a:	e8 d5 02 00 00       	call   800424 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800152:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800158:	89 ec                	mov    %ebp,%esp
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800165:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800168:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800182:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800185:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_yield>:

void
sys_yield(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800195:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800198:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019b:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a5:	89 d1                	mov    %edx,%ecx
  8001a7:	89 d3                	mov    %edx,%ebx
  8001a9:	89 d7                	mov    %edx,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b8:	89 ec                	mov    %ebp,%esp
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 38             	sub    $0x38,%esp
  8001c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cb:	be 00 00 00 00       	mov    $0x0,%esi
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	89 f7                	mov    %esi,%edi
  8001e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7e 28                	jle    80020e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800201:	00 
  800202:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800209:	e8 16 02 00 00       	call   800424 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80020e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800211:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800214:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800217:	89 ec                	mov    %ebp,%esp
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 38             	sub    $0x38,%esp
  800221:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800224:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800227:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	b8 05 00 00 00       	mov    $0x5,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800238:	8b 7d 14             	mov    0x14(%ebp),%edi
  80023b:	8b 75 18             	mov    0x18(%ebp),%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 28                	jle    80026c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	89 44 24 10          	mov    %eax,0x10(%esp)
  800248:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80024f:	00 
  800250:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800257:	00 
  800258:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025f:	00 
  800260:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800267:	e8 b8 01 00 00       	call   800424 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80026c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80026f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800275:	89 ec                	mov    %ebp,%esp
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 38             	sub    $0x38,%esp
  80027f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800282:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800285:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 06 00 00 00       	mov    $0x6,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  8002c5:	e8 5a 01 00 00       	call   800424 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d3:	89 ec                	mov    %ebp,%esp
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 38             	sub    $0x38,%esp
  8002dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 df                	mov    %ebx,%edi
  8002f8:	89 de                	mov    %ebx,%esi
  8002fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	7e 28                	jle    800328 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	89 44 24 10          	mov    %eax,0x10(%esp)
  800304:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80030b:	00 
  80030c:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800313:	00 
  800314:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031b:	00 
  80031c:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800323:	e8 fc 00 00 00       	call   800424 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800328:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80032e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800331:	89 ec                	mov    %ebp,%esp
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 38             	sub    $0x38,%esp
  80033b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80033e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800341:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	b8 09 00 00 00       	mov    $0x9,%eax
  80034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	89 df                	mov    %ebx,%edi
  800356:	89 de                	mov    %ebx,%esi
  800358:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800381:	e8 9e 00 00 00       	call   800424 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800386:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800389:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80038c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038f:	89 ec                	mov    %ebp,%esp
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80039c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80039f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a2:	be 00 00 00 00       	mov    $0x0,%esi
  8003a7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003af:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c3:	89 ec                	mov    %ebp,%esp
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 38             	sub    $0x38,%esp
  8003cd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e3:	89 cb                	mov    %ecx,%ebx
  8003e5:	89 cf                	mov    %ecx,%edi
  8003e7:	89 ce                	mov    %ecx,%esi
  8003e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	7e 28                	jle    800417 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800402:	00 
  800403:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040a:	00 
  80040b:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800412:	e8 0d 00 00 00       	call   800424 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800417:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80041a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80041d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800420:	89 ec                	mov    %ebp,%esp
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80042c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800435:	e8 22 fd ff ff       	call   80015c <sys_getenvid>
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800441:	8b 55 08             	mov    0x8(%ebp),%edx
  800444:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800448:	89 74 24 08          	mov    %esi,0x8(%esp)
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	c7 04 24 b8 12 80 00 	movl   $0x8012b8,(%esp)
  800457:	e8 c3 00 00 00       	call   80051f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80045c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800460:	8b 45 10             	mov    0x10(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 53 00 00 00       	call   8004be <vcprintf>
	cprintf("\n");
  80046b:	c7 04 24 dc 12 80 00 	movl   $0x8012dc,(%esp)
  800472:	e8 a8 00 00 00       	call   80051f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800477:	cc                   	int3   
  800478:	eb fd                	jmp    800477 <_panic+0x53>
	...

0080047c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	53                   	push   %ebx
  800480:	83 ec 14             	sub    $0x14,%esp
  800483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800486:	8b 03                	mov    (%ebx),%eax
  800488:	8b 55 08             	mov    0x8(%ebp),%edx
  80048b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80048f:	83 c0 01             	add    $0x1,%eax
  800492:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800494:	3d ff 00 00 00       	cmp    $0xff,%eax
  800499:	75 19                	jne    8004b4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80049b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004a2:	00 
  8004a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 f2 fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004b8:	83 c4 14             	add    $0x14,%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ce:	00 00 00 
	b.cnt = 0;
  8004d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f3:	c7 04 24 7c 04 80 00 	movl   $0x80047c,(%esp)
  8004fa:	e8 b3 01 00 00       	call   8006b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ff:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 89 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800517:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800525:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 87 ff ff ff       	call   8004be <vcprintf>
	va_end(ap);

	return cnt;
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    
  800539:	00 00                	add    %al,(%eax)
  80053b:	00 00                	add    %al,(%eax)
  80053d:	00 00                	add    %al,(%eax)
	...

00800540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 4c             	sub    $0x4c,%esp
  800549:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80054c:	89 d7                	mov    %edx,%edi
  80054e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800551:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	39 d8                	cmp    %ebx,%eax
  800561:	72 17                	jb     80057a <printnum+0x3a>
  800563:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800566:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800569:	76 0f                	jbe    80057a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80056b:	8b 75 14             	mov    0x14(%ebp),%esi
  80056e:	83 ee 01             	sub    $0x1,%esi
  800571:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800574:	85 f6                	test   %esi,%esi
  800576:	7f 63                	jg     8005db <printnum+0x9b>
  800578:	eb 75                	jmp    8005ef <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80057a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80057d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	83 e8 01             	sub    $0x1,%eax
  800587:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80058e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800592:	8b 44 24 08          	mov    0x8(%esp),%eax
  800596:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80059a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005a7:	00 
  8005a8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005ab:	89 1c 24             	mov    %ebx,(%esp)
  8005ae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b5:	e8 e6 09 00 00       	call   800fa0 <__udivdi3>
  8005ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005c4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005cf:	89 fa                	mov    %edi,%edx
  8005d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005d4:	e8 67 ff ff ff       	call   800540 <printnum>
  8005d9:	eb 14                	jmp    8005ef <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005df:	8b 45 18             	mov    0x18(%ebp),%eax
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e7:	83 ee 01             	sub    $0x1,%esi
  8005ea:	75 ef                	jne    8005db <printnum+0x9b>
  8005ec:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800605:	00 
  800606:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800609:	89 1c 24             	mov    %ebx,(%esp)
  80060c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	e8 d8 0a 00 00       	call   8010f0 <__umoddi3>
  800618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061c:	0f be 80 de 12 80 00 	movsbl 0x8012de(%eax),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800629:	ff d0                	call   *%eax
}
  80062b:	83 c4 4c             	add    $0x4c,%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800636:	83 fa 01             	cmp    $0x1,%edx
  800639:	7e 0e                	jle    800649 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800640:	89 08                	mov    %ecx,(%eax)
  800642:	8b 02                	mov    (%edx),%eax
  800644:	8b 52 04             	mov    0x4(%edx),%edx
  800647:	eb 22                	jmp    80066b <getuint+0x38>
	else if (lflag)
  800649:	85 d2                	test   %edx,%edx
  80064b:	74 10                	je     80065d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800652:	89 08                	mov    %ecx,(%eax)
  800654:	8b 02                	mov    (%edx),%eax
  800656:	ba 00 00 00 00       	mov    $0x0,%edx
  80065b:	eb 0e                	jmp    80066b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800662:	89 08                	mov    %ecx,(%eax)
  800664:	8b 02                	mov    (%edx),%eax
  800666:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800673:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800677:	8b 10                	mov    (%eax),%edx
  800679:	3b 50 04             	cmp    0x4(%eax),%edx
  80067c:	73 0a                	jae    800688 <sprintputch+0x1b>
		*b->buf++ = ch;
  80067e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800681:	88 0a                	mov    %cl,(%edx)
  800683:	83 c2 01             	add    $0x1,%edx
  800686:	89 10                	mov    %edx,(%eax)
}
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800693:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800697:	8b 45 10             	mov    0x10(%ebp),%eax
  80069a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	e8 02 00 00 00       	call   8006b2 <vprintfmt>
	va_end(ap);
}
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	57                   	push   %edi
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 4c             	sub    $0x4c,%esp
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006c4:	eb 11                	jmp    8006d7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	0f 84 db 03 00 00    	je     800aa9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	89 04 24             	mov    %eax,(%esp)
  8006d5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d7:	0f b6 07             	movzbl (%edi),%eax
  8006da:	83 c7 01             	add    $0x1,%edi
  8006dd:	83 f8 25             	cmp    $0x25,%eax
  8006e0:	75 e4                	jne    8006c6 <vprintfmt+0x14>
  8006e2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8006e6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8006ed:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8006f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8006fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800700:	eb 2b                	jmp    80072d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800705:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800709:	eb 22                	jmp    80072d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80070e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800712:	eb 19                	jmp    80072d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800714:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800717:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80071e:	eb 0d                	jmp    80072d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800720:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800723:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800726:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	0f b6 0f             	movzbl (%edi),%ecx
  800730:	8d 47 01             	lea    0x1(%edi),%eax
  800733:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800736:	0f b6 07             	movzbl (%edi),%eax
  800739:	83 e8 23             	sub    $0x23,%eax
  80073c:	3c 55                	cmp    $0x55,%al
  80073e:	0f 87 40 03 00 00    	ja     800a84 <vprintfmt+0x3d2>
  800744:	0f b6 c0             	movzbl %al,%eax
  800747:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80074e:	83 e9 30             	sub    $0x30,%ecx
  800751:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800754:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800758:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80075b:	83 f9 09             	cmp    $0x9,%ecx
  80075e:	77 57                	ja     8007b7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800760:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800763:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800766:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800769:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80076c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80076f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800773:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800776:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800779:	83 f9 09             	cmp    $0x9,%ecx
  80077c:	76 eb                	jbe    800769 <vprintfmt+0xb7>
  80077e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800781:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800784:	eb 34                	jmp    8007ba <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 48 04             	lea    0x4(%eax),%ecx
  80078c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800794:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800797:	eb 21                	jmp    8007ba <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800799:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80079d:	0f 88 71 ff ff ff    	js     800714 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007a6:	eb 85                	jmp    80072d <vprintfmt+0x7b>
  8007a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007ab:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8007b2:	e9 76 ff ff ff       	jmp    80072d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007be:	0f 89 69 ff ff ff    	jns    80072d <vprintfmt+0x7b>
  8007c4:	e9 57 ff ff ff       	jmp    800720 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007cf:	e9 59 ff ff ff       	jmp    80072d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007eb:	e9 e7 fe ff ff       	jmp    8006d7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 04             	lea    0x4(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f9:	8b 00                	mov    (%eax),%eax
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	c1 fa 1f             	sar    $0x1f,%edx
  800800:	31 d0                	xor    %edx,%eax
  800802:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800804:	83 f8 08             	cmp    $0x8,%eax
  800807:	7f 0b                	jg     800814 <vprintfmt+0x162>
  800809:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  800810:	85 d2                	test   %edx,%edx
  800812:	75 20                	jne    800834 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800814:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800818:	c7 44 24 08 f6 12 80 	movl   $0x8012f6,0x8(%esp)
  80081f:	00 
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	89 34 24             	mov    %esi,(%esp)
  800827:	e8 5e fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80082f:	e9 a3 fe ff ff       	jmp    8006d7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800834:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800838:	c7 44 24 08 ff 12 80 	movl   $0x8012ff,0x8(%esp)
  80083f:	00 
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	89 34 24             	mov    %esi,(%esp)
  800847:	e8 3e fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80084f:	e9 83 fe ff ff       	jmp    8006d7 <vprintfmt+0x25>
  800854:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800857:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80085a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	8d 50 04             	lea    0x4(%eax),%edx
  800863:	89 55 14             	mov    %edx,0x14(%ebp)
  800866:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800868:	85 ff                	test   %edi,%edi
  80086a:	b8 ef 12 80 00       	mov    $0x8012ef,%eax
  80086f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800872:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800876:	74 06                	je     80087e <vprintfmt+0x1cc>
  800878:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80087c:	7f 16                	jg     800894 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80087e:	0f b6 17             	movzbl (%edi),%edx
  800881:	0f be c2             	movsbl %dl,%eax
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	85 c0                	test   %eax,%eax
  800889:	0f 85 9f 00 00 00    	jne    80092e <vprintfmt+0x27c>
  80088f:	e9 8b 00 00 00       	jmp    80091f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800894:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800898:	89 3c 24             	mov    %edi,(%esp)
  80089b:	e8 c2 02 00 00       	call   800b62 <strnlen>
  8008a0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008a3:	29 c2                	sub    %eax,%edx
  8008a5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e d2                	jle    80087e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008ac:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8008b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008b3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008b6:	89 d7                	mov    %edx,%edi
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c4:	83 ef 01             	sub    $0x1,%edi
  8008c7:	75 ef                	jne    8008b8 <vprintfmt+0x206>
  8008c9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008cf:	eb ad                	jmp    80087e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008d5:	74 20                	je     8008f7 <vprintfmt+0x245>
  8008d7:	0f be d2             	movsbl %dl,%edx
  8008da:	83 ea 20             	sub    $0x20,%edx
  8008dd:	83 fa 5e             	cmp    $0x5e,%edx
  8008e0:	76 15                	jbe    8008f7 <vprintfmt+0x245>
					putch('?', putdat);
  8008e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008f3:	ff d1                	call   *%ecx
  8008f5:	eb 0f                	jmp    800906 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8008f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800904:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800906:	83 eb 01             	sub    $0x1,%ebx
  800909:	0f b6 17             	movzbl (%edi),%edx
  80090c:	0f be c2             	movsbl %dl,%eax
  80090f:	83 c7 01             	add    $0x1,%edi
  800912:	85 c0                	test   %eax,%eax
  800914:	75 24                	jne    80093a <vprintfmt+0x288>
  800916:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800919:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80091c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800922:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800926:	0f 8e ab fd ff ff    	jle    8006d7 <vprintfmt+0x25>
  80092c:	eb 20                	jmp    80094e <vprintfmt+0x29c>
  80092e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800931:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800934:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800937:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093a:	85 f6                	test   %esi,%esi
  80093c:	78 93                	js     8008d1 <vprintfmt+0x21f>
  80093e:	83 ee 01             	sub    $0x1,%esi
  800941:	79 8e                	jns    8008d1 <vprintfmt+0x21f>
  800943:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800946:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800949:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80094c:	eb d1                	jmp    80091f <vprintfmt+0x26d>
  80094e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80095c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	75 ee                	jne    800951 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800963:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800966:	e9 6c fd ff ff       	jmp    8006d7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80096b:	83 fa 01             	cmp    $0x1,%edx
  80096e:	66 90                	xchg   %ax,%ax
  800970:	7e 16                	jle    800988 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 08             	lea    0x8(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	8b 48 04             	mov    0x4(%eax),%ecx
  800980:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800983:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800986:	eb 32                	jmp    8009ba <vprintfmt+0x308>
	else if (lflag)
  800988:	85 d2                	test   %edx,%edx
  80098a:	74 18                	je     8009a4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80098c:	8b 45 14             	mov    0x14(%ebp),%eax
  80098f:	8d 50 04             	lea    0x4(%eax),%edx
  800992:	89 55 14             	mov    %edx,0x14(%ebp)
  800995:	8b 00                	mov    (%eax),%eax
  800997:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80099a:	89 c1                	mov    %eax,%ecx
  80099c:	c1 f9 1f             	sar    $0x1f,%ecx
  80099f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009a2:	eb 16                	jmp    8009ba <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	8b 00                	mov    (%eax),%eax
  8009af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	c1 ff 1f             	sar    $0x1f,%edi
  8009b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009c9:	79 7d                	jns    800a48 <vprintfmt+0x396>
				putch('-', putdat);
  8009cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009de:	f7 d8                	neg    %eax
  8009e0:	83 d2 00             	adc    $0x0,%edx
  8009e3:	f7 da                	neg    %edx
			}
			base = 10;
  8009e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ea:	eb 5c                	jmp    800a48 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ef:	e8 3f fc ff ff       	call   800633 <getuint>
			base = 10;
  8009f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009f9:	eb 4d                	jmp    800a48 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  8009fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fe:	e8 30 fc ff ff       	call   800633 <getuint>
      base = 8;
  800a03:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800a08:	eb 3e                	jmp    800a48 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a15:	ff d6                	call   *%esi
			putch('x', putdat);
  800a17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a22:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a24:	8b 45 14             	mov    0x14(%ebp),%eax
  800a27:	8d 50 04             	lea    0x4(%eax),%edx
  800a2a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2d:	8b 00                	mov    (%eax),%eax
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a34:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a39:	eb 0d                	jmp    800a48 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3e:	e8 f0 fb ff ff       	call   800633 <getuint>
			base = 16;
  800a43:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a48:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800a4c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a50:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a53:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a62:	89 da                	mov    %ebx,%edx
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	e8 d5 fa ff ff       	call   800540 <printnum>
			break;
  800a6b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a6e:	e9 64 fc ff ff       	jmp    8006d7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a77:	89 0c 24             	mov    %ecx,(%esp)
  800a7a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a7f:	e9 53 fc ff ff       	jmp    8006d7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a88:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a8f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a91:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a95:	0f 84 3c fc ff ff    	je     8006d7 <vprintfmt+0x25>
  800a9b:	83 ef 01             	sub    $0x1,%edi
  800a9e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800aa2:	75 f7                	jne    800a9b <vprintfmt+0x3e9>
  800aa4:	e9 2e fc ff ff       	jmp    8006d7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800aa9:	83 c4 4c             	add    $0x4c,%esp
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 28             	sub    $0x28,%esp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800abd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ac4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	7e 30                	jle    800b02 <vsnprintf+0x51>
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	74 2c                	je     800b02 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800add:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aeb:	c7 04 24 6d 06 80 00 	movl   $0x80066d,(%esp)
  800af2:	e8 bb fb ff ff       	call   8006b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b00:	eb 05                	jmp    800b07 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b0f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b16:	8b 45 10             	mov    0x10(%ebp),%eax
  800b19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	89 04 24             	mov    %eax,(%esp)
  800b2a:	e8 82 ff ff ff       	call   800ab1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    
	...

00800b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b46:	80 3a 00             	cmpb   $0x0,(%edx)
  800b49:	74 10                	je     800b5b <strlen+0x1b>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b57:	75 f7                	jne    800b50 <strlen+0x10>
  800b59:	eb 05                	jmp    800b60 <strlen+0x20>
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6c:	85 c9                	test   %ecx,%ecx
  800b6e:	74 1c                	je     800b8c <strnlen+0x2a>
  800b70:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b73:	74 1e                	je     800b93 <strnlen+0x31>
  800b75:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b7a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7c:	39 ca                	cmp    %ecx,%edx
  800b7e:	74 18                	je     800b98 <strnlen+0x36>
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b88:	75 f0                	jne    800b7a <strnlen+0x18>
  800b8a:	eb 0c                	jmp    800b98 <strnlen+0x36>
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	eb 05                	jmp    800b98 <strnlen+0x36>
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	0f b6 19             	movzbl (%ecx),%ebx
  800baa:	88 1a                	mov    %bl,(%edx)
  800bac:	83 c2 01             	add    $0x1,%edx
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	84 db                	test   %bl,%bl
  800bb4:	75 f1                	jne    800ba7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 08             	sub    $0x8,%esp
  800bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc3:	89 1c 24             	mov    %ebx,(%esp)
  800bc6:	e8 75 ff ff ff       	call   800b40 <strlen>
	strcpy(dst + len, src);
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bce:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd2:	01 d8                	add    %ebx,%eax
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	e8 bf ff ff ff       	call   800b9b <strcpy>
	return dst;
}
  800bdc:	89 d8                	mov    %ebx,%eax
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf2:	85 db                	test   %ebx,%ebx
  800bf4:	74 16                	je     800c0c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf6:	01 f3                	add    %esi,%ebx
  800bf8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800bfa:	0f b6 02             	movzbl (%edx),%eax
  800bfd:	88 01                	mov    %al,(%ecx)
  800bff:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c02:	80 3a 01             	cmpb   $0x1,(%edx)
  800c05:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c08:	39 d9                	cmp    %ebx,%ecx
  800c0a:	75 ee                	jne    800bfa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c0c:	89 f0                	mov    %esi,%eax
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c21:	89 f8                	mov    %edi,%eax
  800c23:	85 f6                	test   %esi,%esi
  800c25:	74 33                	je     800c5a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800c27:	83 fe 01             	cmp    $0x1,%esi
  800c2a:	74 25                	je     800c51 <strlcpy+0x3f>
  800c2c:	0f b6 0b             	movzbl (%ebx),%ecx
  800c2f:	84 c9                	test   %cl,%cl
  800c31:	74 22                	je     800c55 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c33:	83 ee 02             	sub    $0x2,%esi
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c3b:	88 08                	mov    %cl,(%eax)
  800c3d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c40:	39 f2                	cmp    %esi,%edx
  800c42:	74 13                	je     800c57 <strlcpy+0x45>
  800c44:	83 c2 01             	add    $0x1,%edx
  800c47:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c4b:	84 c9                	test   %cl,%cl
  800c4d:	75 ec                	jne    800c3b <strlcpy+0x29>
  800c4f:	eb 06                	jmp    800c57 <strlcpy+0x45>
  800c51:	89 f8                	mov    %edi,%eax
  800c53:	eb 02                	jmp    800c57 <strlcpy+0x45>
  800c55:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c57:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c5a:	29 f8                	sub    %edi,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c67:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6a:	0f b6 01             	movzbl (%ecx),%eax
  800c6d:	84 c0                	test   %al,%al
  800c6f:	74 15                	je     800c86 <strcmp+0x25>
  800c71:	3a 02                	cmp    (%edx),%al
  800c73:	75 11                	jne    800c86 <strcmp+0x25>
		p++, q++;
  800c75:	83 c1 01             	add    $0x1,%ecx
  800c78:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7b:	0f b6 01             	movzbl (%ecx),%eax
  800c7e:	84 c0                	test   %al,%al
  800c80:	74 04                	je     800c86 <strcmp+0x25>
  800c82:	3a 02                	cmp    (%edx),%al
  800c84:	74 ef                	je     800c75 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c86:	0f b6 c0             	movzbl %al,%eax
  800c89:	0f b6 12             	movzbl (%edx),%edx
  800c8c:	29 d0                	sub    %edx,%eax
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c9e:	85 f6                	test   %esi,%esi
  800ca0:	74 29                	je     800ccb <strncmp+0x3b>
  800ca2:	0f b6 03             	movzbl (%ebx),%eax
  800ca5:	84 c0                	test   %al,%al
  800ca7:	74 30                	je     800cd9 <strncmp+0x49>
  800ca9:	3a 02                	cmp    (%edx),%al
  800cab:	75 2c                	jne    800cd9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800cad:	8d 43 01             	lea    0x1(%ebx),%eax
  800cb0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800cb2:	89 c3                	mov    %eax,%ebx
  800cb4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cb7:	39 f0                	cmp    %esi,%eax
  800cb9:	74 17                	je     800cd2 <strncmp+0x42>
  800cbb:	0f b6 08             	movzbl (%eax),%ecx
  800cbe:	84 c9                	test   %cl,%cl
  800cc0:	74 17                	je     800cd9 <strncmp+0x49>
  800cc2:	83 c0 01             	add    $0x1,%eax
  800cc5:	3a 0a                	cmp    (%edx),%cl
  800cc7:	74 e9                	je     800cb2 <strncmp+0x22>
  800cc9:	eb 0e                	jmp    800cd9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd0:	eb 0f                	jmp    800ce1 <strncmp+0x51>
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	eb 08                	jmp    800ce1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd9:	0f b6 03             	movzbl (%ebx),%eax
  800cdc:	0f b6 12             	movzbl (%edx),%edx
  800cdf:	29 d0                	sub    %edx,%eax
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	53                   	push   %ebx
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800cef:	0f b6 18             	movzbl (%eax),%ebx
  800cf2:	84 db                	test   %bl,%bl
  800cf4:	74 1d                	je     800d13 <strchr+0x2e>
  800cf6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800cf8:	38 d3                	cmp    %dl,%bl
  800cfa:	75 06                	jne    800d02 <strchr+0x1d>
  800cfc:	eb 1a                	jmp    800d18 <strchr+0x33>
  800cfe:	38 ca                	cmp    %cl,%dl
  800d00:	74 16                	je     800d18 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	0f b6 10             	movzbl (%eax),%edx
  800d08:	84 d2                	test   %dl,%dl
  800d0a:	75 f2                	jne    800cfe <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d11:	eb 05                	jmp    800d18 <strchr+0x33>
  800d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d18:	5b                   	pop    %ebx
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	53                   	push   %ebx
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d25:	0f b6 18             	movzbl (%eax),%ebx
  800d28:	84 db                	test   %bl,%bl
  800d2a:	74 16                	je     800d42 <strfind+0x27>
  800d2c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d2e:	38 d3                	cmp    %dl,%bl
  800d30:	75 06                	jne    800d38 <strfind+0x1d>
  800d32:	eb 0e                	jmp    800d42 <strfind+0x27>
  800d34:	38 ca                	cmp    %cl,%dl
  800d36:	74 0a                	je     800d42 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d38:	83 c0 01             	add    $0x1,%eax
  800d3b:	0f b6 10             	movzbl (%eax),%edx
  800d3e:	84 d2                	test   %dl,%dl
  800d40:	75 f2                	jne    800d34 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800d42:	5b                   	pop    %ebx
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d51:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d5a:	85 c9                	test   %ecx,%ecx
  800d5c:	74 36                	je     800d94 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d64:	75 28                	jne    800d8e <memset+0x49>
  800d66:	f6 c1 03             	test   $0x3,%cl
  800d69:	75 23                	jne    800d8e <memset+0x49>
		c &= 0xFF;
  800d6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d6f:	89 d3                	mov    %edx,%ebx
  800d71:	c1 e3 08             	shl    $0x8,%ebx
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	c1 e6 18             	shl    $0x18,%esi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	c1 e0 10             	shl    $0x10,%eax
  800d7e:	09 f0                	or     %esi,%eax
  800d80:	09 c2                	or     %eax,%edx
  800d82:	89 d0                	mov    %edx,%eax
  800d84:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d86:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d89:	fc                   	cld    
  800d8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d8c:	eb 06                	jmp    800d94 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d91:	fc                   	cld    
  800d92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9f:	89 ec                	mov    %ebp,%esp
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 08             	sub    $0x8,%esp
  800da9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800db8:	39 c6                	cmp    %eax,%esi
  800dba:	73 36                	jae    800df2 <memmove+0x4f>
  800dbc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dbf:	39 d0                	cmp    %edx,%eax
  800dc1:	73 2f                	jae    800df2 <memmove+0x4f>
		s += n;
		d += n;
  800dc3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc6:	f6 c2 03             	test   $0x3,%dl
  800dc9:	75 1b                	jne    800de6 <memmove+0x43>
  800dcb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd1:	75 13                	jne    800de6 <memmove+0x43>
  800dd3:	f6 c1 03             	test   $0x3,%cl
  800dd6:	75 0e                	jne    800de6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800dd8:	83 ef 04             	sub    $0x4,%edi
  800ddb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dde:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800de1:	fd                   	std    
  800de2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de4:	eb 09                	jmp    800def <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800de6:	83 ef 01             	sub    $0x1,%edi
  800de9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dec:	fd                   	std    
  800ded:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800def:	fc                   	cld    
  800df0:	eb 20                	jmp    800e12 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800df8:	75 13                	jne    800e0d <memmove+0x6a>
  800dfa:	a8 03                	test   $0x3,%al
  800dfc:	75 0f                	jne    800e0d <memmove+0x6a>
  800dfe:	f6 c1 03             	test   $0x3,%cl
  800e01:	75 0a                	jne    800e0d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e06:	89 c7                	mov    %eax,%edi
  800e08:	fc                   	cld    
  800e09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e0b:	eb 05                	jmp    800e12 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e0d:	89 c7                	mov    %eax,%edi
  800e0f:	fc                   	cld    
  800e10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e22:	8b 45 10             	mov    0x10(%ebp),%eax
  800e25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	89 04 24             	mov    %eax,(%esp)
  800e36:	e8 68 ff ff ff       	call   800da3 <memmove>
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    

00800e3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e49:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e4c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	74 36                	je     800e89 <memcmp+0x4c>
		if (*s1 != *s2)
  800e53:	0f b6 03             	movzbl (%ebx),%eax
  800e56:	0f b6 0e             	movzbl (%esi),%ecx
  800e59:	38 c8                	cmp    %cl,%al
  800e5b:	75 17                	jne    800e74 <memcmp+0x37>
  800e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e62:	eb 1a                	jmp    800e7e <memcmp+0x41>
  800e64:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e69:	83 c2 01             	add    $0x1,%edx
  800e6c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e70:	38 c8                	cmp    %cl,%al
  800e72:	74 0a                	je     800e7e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800e74:	0f b6 c0             	movzbl %al,%eax
  800e77:	0f b6 c9             	movzbl %cl,%ecx
  800e7a:	29 c8                	sub    %ecx,%eax
  800e7c:	eb 10                	jmp    800e8e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7e:	39 fa                	cmp    %edi,%edx
  800e80:	75 e2                	jne    800e64 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	eb 05                	jmp    800e8e <memcmp+0x51>
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	53                   	push   %ebx
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea2:	39 d0                	cmp    %edx,%eax
  800ea4:	73 13                	jae    800eb9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea6:	89 d9                	mov    %ebx,%ecx
  800ea8:	38 18                	cmp    %bl,(%eax)
  800eaa:	75 06                	jne    800eb2 <memfind+0x1f>
  800eac:	eb 0b                	jmp    800eb9 <memfind+0x26>
  800eae:	38 08                	cmp    %cl,(%eax)
  800eb0:	74 07                	je     800eb9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb2:	83 c0 01             	add    $0x1,%eax
  800eb5:	39 d0                	cmp    %edx,%eax
  800eb7:	75 f5                	jne    800eae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ecb:	0f b6 02             	movzbl (%edx),%eax
  800ece:	3c 09                	cmp    $0x9,%al
  800ed0:	74 04                	je     800ed6 <strtol+0x1a>
  800ed2:	3c 20                	cmp    $0x20,%al
  800ed4:	75 0e                	jne    800ee4 <strtol+0x28>
		s++;
  800ed6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed9:	0f b6 02             	movzbl (%edx),%eax
  800edc:	3c 09                	cmp    $0x9,%al
  800ede:	74 f6                	je     800ed6 <strtol+0x1a>
  800ee0:	3c 20                	cmp    $0x20,%al
  800ee2:	74 f2                	je     800ed6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee4:	3c 2b                	cmp    $0x2b,%al
  800ee6:	75 0a                	jne    800ef2 <strtol+0x36>
		s++;
  800ee8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eeb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef0:	eb 10                	jmp    800f02 <strtol+0x46>
  800ef2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ef7:	3c 2d                	cmp    $0x2d,%al
  800ef9:	75 07                	jne    800f02 <strtol+0x46>
		s++, neg = 1;
  800efb:	83 c2 01             	add    $0x1,%edx
  800efe:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f08:	75 15                	jne    800f1f <strtol+0x63>
  800f0a:	80 3a 30             	cmpb   $0x30,(%edx)
  800f0d:	75 10                	jne    800f1f <strtol+0x63>
  800f0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f13:	75 0a                	jne    800f1f <strtol+0x63>
		s += 2, base = 16;
  800f15:	83 c2 02             	add    $0x2,%edx
  800f18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f1d:	eb 10                	jmp    800f2f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f1f:	85 db                	test   %ebx,%ebx
  800f21:	75 0c                	jne    800f2f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f23:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f25:	80 3a 30             	cmpb   $0x30,(%edx)
  800f28:	75 05                	jne    800f2f <strtol+0x73>
		s++, base = 8;
  800f2a:	83 c2 01             	add    $0x1,%edx
  800f2d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f37:	0f b6 0a             	movzbl (%edx),%ecx
  800f3a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f3d:	89 f3                	mov    %esi,%ebx
  800f3f:	80 fb 09             	cmp    $0x9,%bl
  800f42:	77 08                	ja     800f4c <strtol+0x90>
			dig = *s - '0';
  800f44:	0f be c9             	movsbl %cl,%ecx
  800f47:	83 e9 30             	sub    $0x30,%ecx
  800f4a:	eb 22                	jmp    800f6e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800f4c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f4f:	89 f3                	mov    %esi,%ebx
  800f51:	80 fb 19             	cmp    $0x19,%bl
  800f54:	77 08                	ja     800f5e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800f56:	0f be c9             	movsbl %cl,%ecx
  800f59:	83 e9 57             	sub    $0x57,%ecx
  800f5c:	eb 10                	jmp    800f6e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800f5e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	80 fb 19             	cmp    $0x19,%bl
  800f66:	77 16                	ja     800f7e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800f68:	0f be c9             	movsbl %cl,%ecx
  800f6b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f6e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f71:	7d 0f                	jge    800f82 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800f73:	83 c2 01             	add    $0x1,%edx
  800f76:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800f7a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f7c:	eb b9                	jmp    800f37 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f7e:	89 c1                	mov    %eax,%ecx
  800f80:	eb 02                	jmp    800f84 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f82:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f88:	74 05                	je     800f8f <strtol+0xd3>
		*endptr = (char *) s;
  800f8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f8d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f8f:	89 ca                	mov    %ecx,%edx
  800f91:	f7 da                	neg    %edx
  800f93:	85 ff                	test   %edi,%edi
  800f95:	0f 45 c2             	cmovne %edx,%eax
}
  800f98:	83 c4 04             	add    $0x4,%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <__udivdi3>:
  800fa0:	83 ec 1c             	sub    $0x1c,%esp
  800fa3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800fa7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fab:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800faf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fb3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800fb7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fc1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fc5:	89 ea                	mov    %ebp,%edx
  800fc7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fcb:	75 33                	jne    801000 <__udivdi3+0x60>
  800fcd:	39 e9                	cmp    %ebp,%ecx
  800fcf:	77 6f                	ja     801040 <__udivdi3+0xa0>
  800fd1:	85 c9                	test   %ecx,%ecx
  800fd3:	89 ce                	mov    %ecx,%esi
  800fd5:	75 0b                	jne    800fe2 <__udivdi3+0x42>
  800fd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdc:	31 d2                	xor    %edx,%edx
  800fde:	f7 f1                	div    %ecx
  800fe0:	89 c6                	mov    %eax,%esi
  800fe2:	31 d2                	xor    %edx,%edx
  800fe4:	89 e8                	mov    %ebp,%eax
  800fe6:	f7 f6                	div    %esi
  800fe8:	89 c5                	mov    %eax,%ebp
  800fea:	89 f8                	mov    %edi,%eax
  800fec:	f7 f6                	div    %esi
  800fee:	89 ea                	mov    %ebp,%edx
  800ff0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ffc:	83 c4 1c             	add    $0x1c,%esp
  800fff:	c3                   	ret    
  801000:	39 e8                	cmp    %ebp,%eax
  801002:	77 24                	ja     801028 <__udivdi3+0x88>
  801004:	0f bd c8             	bsr    %eax,%ecx
  801007:	83 f1 1f             	xor    $0x1f,%ecx
  80100a:	89 0c 24             	mov    %ecx,(%esp)
  80100d:	75 49                	jne    801058 <__udivdi3+0xb8>
  80100f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801013:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801017:	0f 86 ab 00 00 00    	jbe    8010c8 <__udivdi3+0x128>
  80101d:	39 e8                	cmp    %ebp,%eax
  80101f:	0f 82 a3 00 00 00    	jb     8010c8 <__udivdi3+0x128>
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	31 d2                	xor    %edx,%edx
  80102a:	31 c0                	xor    %eax,%eax
  80102c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801030:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801034:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801038:	83 c4 1c             	add    $0x1c,%esp
  80103b:	c3                   	ret    
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	89 f8                	mov    %edi,%eax
  801042:	f7 f1                	div    %ecx
  801044:	31 d2                	xor    %edx,%edx
  801046:	8b 74 24 10          	mov    0x10(%esp),%esi
  80104a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80104e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801052:	83 c4 1c             	add    $0x1c,%esp
  801055:	c3                   	ret    
  801056:	66 90                	xchg   %ax,%ax
  801058:	0f b6 0c 24          	movzbl (%esp),%ecx
  80105c:	89 c6                	mov    %eax,%esi
  80105e:	b8 20 00 00 00       	mov    $0x20,%eax
  801063:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801067:	2b 04 24             	sub    (%esp),%eax
  80106a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80106e:	d3 e6                	shl    %cl,%esi
  801070:	89 c1                	mov    %eax,%ecx
  801072:	d3 ed                	shr    %cl,%ebp
  801074:	0f b6 0c 24          	movzbl (%esp),%ecx
  801078:	09 f5                	or     %esi,%ebp
  80107a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80107e:	d3 e6                	shl    %cl,%esi
  801080:	89 c1                	mov    %eax,%ecx
  801082:	89 74 24 04          	mov    %esi,0x4(%esp)
  801086:	89 d6                	mov    %edx,%esi
  801088:	d3 ee                	shr    %cl,%esi
  80108a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80108e:	d3 e2                	shl    %cl,%edx
  801090:	89 c1                	mov    %eax,%ecx
  801092:	d3 ef                	shr    %cl,%edi
  801094:	09 d7                	or     %edx,%edi
  801096:	89 f2                	mov    %esi,%edx
  801098:	89 f8                	mov    %edi,%eax
  80109a:	f7 f5                	div    %ebp
  80109c:	89 d6                	mov    %edx,%esi
  80109e:	89 c7                	mov    %eax,%edi
  8010a0:	f7 64 24 04          	mull   0x4(%esp)
  8010a4:	39 d6                	cmp    %edx,%esi
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x138>
  8010a8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010ac:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010b0:	d3 e5                	shl    %cl,%ebp
  8010b2:	39 c5                	cmp    %eax,%ebp
  8010b4:	73 04                	jae    8010ba <__udivdi3+0x11a>
  8010b6:	39 d6                	cmp    %edx,%esi
  8010b8:	74 1e                	je     8010d8 <__udivdi3+0x138>
  8010ba:	89 f8                	mov    %edi,%eax
  8010bc:	31 d2                	xor    %edx,%edx
  8010be:	e9 69 ff ff ff       	jmp    80102c <__udivdi3+0x8c>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cf:	e9 58 ff ff ff       	jmp    80102c <__udivdi3+0x8c>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010e9:	83 c4 1c             	add    $0x1c,%esp
  8010ec:	c3                   	ret    
  8010ed:	00 00                	add    %al,(%eax)
	...

008010f0 <__umoddi3>:
  8010f0:	83 ec 2c             	sub    $0x2c,%esp
  8010f3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010f7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8010fb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8010ff:	8b 74 24 38          	mov    0x38(%esp),%esi
  801103:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801107:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80110b:	85 c0                	test   %eax,%eax
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801113:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801117:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80111f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801123:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801127:	75 1f                	jne    801148 <__umoddi3+0x58>
  801129:	39 fe                	cmp    %edi,%esi
  80112b:	76 63                	jbe    801190 <__umoddi3+0xa0>
  80112d:	89 c8                	mov    %ecx,%eax
  80112f:	89 fa                	mov    %edi,%edx
  801131:	f7 f6                	div    %esi
  801133:	89 d0                	mov    %edx,%eax
  801135:	31 d2                	xor    %edx,%edx
  801137:	8b 74 24 20          	mov    0x20(%esp),%esi
  80113b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80113f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801143:	83 c4 2c             	add    $0x2c,%esp
  801146:	c3                   	ret    
  801147:	90                   	nop
  801148:	39 f8                	cmp    %edi,%eax
  80114a:	77 64                	ja     8011b0 <__umoddi3+0xc0>
  80114c:	0f bd e8             	bsr    %eax,%ebp
  80114f:	83 f5 1f             	xor    $0x1f,%ebp
  801152:	75 74                	jne    8011c8 <__umoddi3+0xd8>
  801154:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801158:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80115c:	0f 87 0e 01 00 00    	ja     801270 <__umoddi3+0x180>
  801162:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801166:	29 f1                	sub    %esi,%ecx
  801168:	19 c7                	sbb    %eax,%edi
  80116a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80116e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801172:	8b 44 24 14          	mov    0x14(%esp),%eax
  801176:	8b 54 24 18          	mov    0x18(%esp),%edx
  80117a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80117e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801182:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801186:	83 c4 2c             	add    $0x2c,%esp
  801189:	c3                   	ret    
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	85 f6                	test   %esi,%esi
  801192:	89 f5                	mov    %esi,%ebp
  801194:	75 0b                	jne    8011a1 <__umoddi3+0xb1>
  801196:	b8 01 00 00 00       	mov    $0x1,%eax
  80119b:	31 d2                	xor    %edx,%edx
  80119d:	f7 f6                	div    %esi
  80119f:	89 c5                	mov    %eax,%ebp
  8011a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011a5:	31 d2                	xor    %edx,%edx
  8011a7:	f7 f5                	div    %ebp
  8011a9:	89 c8                	mov    %ecx,%eax
  8011ab:	f7 f5                	div    %ebp
  8011ad:	eb 84                	jmp    801133 <__umoddi3+0x43>
  8011af:	90                   	nop
  8011b0:	89 c8                	mov    %ecx,%eax
  8011b2:	89 fa                	mov    %edi,%edx
  8011b4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011b8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011bc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011c0:	83 c4 2c             	add    $0x2c,%esp
  8011c3:	c3                   	ret    
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011cc:	be 20 00 00 00       	mov    $0x20,%esi
  8011d1:	89 e9                	mov    %ebp,%ecx
  8011d3:	29 ee                	sub    %ebp,%esi
  8011d5:	d3 e2                	shl    %cl,%edx
  8011d7:	89 f1                	mov    %esi,%ecx
  8011d9:	d3 e8                	shr    %cl,%eax
  8011db:	89 e9                	mov    %ebp,%ecx
  8011dd:	09 d0                	or     %edx,%eax
  8011df:	89 fa                	mov    %edi,%edx
  8011e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011e9:	d3 e0                	shl    %cl,%eax
  8011eb:	89 f1                	mov    %esi,%ecx
  8011ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8011f5:	d3 ea                	shr    %cl,%edx
  8011f7:	89 e9                	mov    %ebp,%ecx
  8011f9:	d3 e7                	shl    %cl,%edi
  8011fb:	89 f1                	mov    %esi,%ecx
  8011fd:	d3 e8                	shr    %cl,%eax
  8011ff:	89 e9                	mov    %ebp,%ecx
  801201:	09 f8                	or     %edi,%eax
  801203:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801207:	f7 74 24 0c          	divl   0xc(%esp)
  80120b:	d3 e7                	shl    %cl,%edi
  80120d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801211:	89 d7                	mov    %edx,%edi
  801213:	f7 64 24 10          	mull   0x10(%esp)
  801217:	39 d7                	cmp    %edx,%edi
  801219:	89 c1                	mov    %eax,%ecx
  80121b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80121f:	72 3b                	jb     80125c <__umoddi3+0x16c>
  801221:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801225:	72 31                	jb     801258 <__umoddi3+0x168>
  801227:	8b 44 24 18          	mov    0x18(%esp),%eax
  80122b:	29 c8                	sub    %ecx,%eax
  80122d:	19 d7                	sbb    %edx,%edi
  80122f:	89 e9                	mov    %ebp,%ecx
  801231:	89 fa                	mov    %edi,%edx
  801233:	d3 e8                	shr    %cl,%eax
  801235:	89 f1                	mov    %esi,%ecx
  801237:	d3 e2                	shl    %cl,%edx
  801239:	89 e9                	mov    %ebp,%ecx
  80123b:	09 d0                	or     %edx,%eax
  80123d:	89 fa                	mov    %edi,%edx
  80123f:	d3 ea                	shr    %cl,%edx
  801241:	8b 74 24 20          	mov    0x20(%esp),%esi
  801245:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801249:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80124d:	83 c4 2c             	add    $0x2c,%esp
  801250:	c3                   	ret    
  801251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801258:	39 d7                	cmp    %edx,%edi
  80125a:	75 cb                	jne    801227 <__umoddi3+0x137>
  80125c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801260:	89 c1                	mov    %eax,%ecx
  801262:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801266:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80126a:	eb bb                	jmp    801227 <__umoddi3+0x137>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801274:	0f 82 e8 fe ff ff    	jb     801162 <__umoddi3+0x72>
  80127a:	e9 f3 fe ff ff       	jmp    801172 <__umoddi3+0x82>
