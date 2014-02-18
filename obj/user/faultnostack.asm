
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 44 04 80 	movl   $0x800444,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 07 03 00 00       	call   800355 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80006e:	e8 09 01 00 00       	call   80017c <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 74 24 04          	mov    %esi,0x4(%esp)
  800094:	89 1c 24             	mov    %ebx,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 61 00 00 00       	call   80011f <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 38             	sub    $0x38,%esp
  800125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  80016a:	e8 e1 02 00 00       	call   800450 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c5:	89 d1                	mov    %edx,%ecx
  8001c7:	89 d3                	mov    %edx,%ebx
  8001c9:	89 d7                	mov    %edx,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 38             	sub    $0x38,%esp
  8001e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001eb:	be 00 00 00 00       	mov    $0x0,%esi
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fe:	89 f7                	mov    %esi,%edi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 28                	jle    80022e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800211:	00 
  800212:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800229:	e8 22 02 00 00       	call   800450 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 38             	sub    $0x38,%esp
  800241:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800244:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800247:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	b8 05 00 00 00       	mov    $0x5,%eax
  80024f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 7d 14             	mov    0x14(%ebp),%edi
  80025b:	8b 75 18             	mov    0x18(%ebp),%esi
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 28                	jle    80028c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	89 44 24 10          	mov    %eax,0x10(%esp)
  800268:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026f:	00 
  800270:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800287:	e8 c4 01 00 00       	call   800450 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800295:	89 ec                	mov    %ebp,%esp
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 38             	sub    $0x38,%esp
  80029f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 28                	jle    8002ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  8002e5:	e8 66 01 00 00       	call   800450 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f3:	89 ec                	mov    %ebp,%esp
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 38             	sub    $0x38,%esp
  8002fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800300:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800303:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 08 00 00 00       	mov    $0x8,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 28                	jle    800348 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	89 44 24 10          	mov    %eax,0x10(%esp)
  800324:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032b:	00 
  80032c:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800343:	e8 08 01 00 00       	call   800450 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800351:	89 ec                	mov    %ebp,%esp
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 38             	sub    $0x38,%esp
  80035b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	bb 00 00 00 00       	mov    $0x0,%ebx
  800369:	b8 09 00 00 00       	mov    $0x9,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 df                	mov    %ebx,%edi
  800376:	89 de                	mov    %ebx,%esi
  800378:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7e 28                	jle    8003a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  8003a1:	e8 aa 00 00 00       	call   800450 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
  8003c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003e3:	89 ec                	mov    %ebp,%esp
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 38             	sub    $0x38,%esp
  8003ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	89 cb                	mov    %ecx,%ebx
  800405:	89 cf                	mov    %ecx,%edi
  800407:	89 ce                	mov    %ecx,%esi
  800409:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040b:	85 c0                	test   %eax,%eax
  80040d:	7e 28                	jle    800437 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800413:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80041a:	00 
  80041b:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800432:	e8 19 00 00 00       	call   800450 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800437:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800440:	89 ec                	mov    %ebp,%esp
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800444:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800445:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80044a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80044c:	83 c4 04             	add    $0x4,%esp
	...

00800450 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800458:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800461:	e8 16 fd ff ff       	call   80017c <sys_getenvid>
  800466:	8b 55 0c             	mov    0xc(%ebp),%edx
  800469:	89 54 24 10          	mov    %edx,0x10(%esp)
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
  800470:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800474:	89 74 24 08          	mov    %esi,0x8(%esp)
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  800483:	e8 c3 00 00 00       	call   80054b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048c:	8b 45 10             	mov    0x10(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 53 00 00 00       	call   8004ea <vcprintf>
	cprintf("\n");
  800497:	c7 04 24 5b 13 80 00 	movl   $0x80135b,(%esp)
  80049e:	e8 a8 00 00 00       	call   80054b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a3:	cc                   	int3   
  8004a4:	eb fd                	jmp    8004a3 <_panic+0x53>
	...

008004a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 14             	sub    $0x14,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b2:	8b 03                	mov    (%ebx),%eax
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bb:	83 c0 01             	add    $0x1,%eax
  8004be:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c5:	75 19                	jne    8004e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ce:	00 
  8004cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	e8 e6 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e4:	83 c4 14             	add    $0x14,%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fa:	00 00 00 
	b.cnt = 0;
  8004fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800504:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 44 24 08          	mov    %eax,0x8(%esp)
  800515:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 a8 04 80 00 	movl   $0x8004a8,(%esp)
  800526:	e8 b7 01 00 00       	call   8006e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	e8 7d fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800543:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800551:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 87 ff ff ff       	call   8004ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    
	...

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 4c             	sub    $0x4c,%esp
  800579:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80057c:	89 d7                	mov    %edx,%edi
  80057e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800581:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800587:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80058a:	b8 00 00 00 00       	mov    $0x0,%eax
  80058f:	39 d8                	cmp    %ebx,%eax
  800591:	72 17                	jb     8005aa <printnum+0x3a>
  800593:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800596:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800599:	76 0f                	jbe    8005aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80059b:	8b 75 14             	mov    0x14(%ebp),%esi
  80059e:	83 ee 01             	sub    $0x1,%esi
  8005a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005a4:	85 f6                	test   %esi,%esi
  8005a6:	7f 63                	jg     80060b <printnum+0x9b>
  8005a8:	eb 75                	jmp    80061f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005aa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8005ad:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	83 e8 01             	sub    $0x1,%eax
  8005b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005c6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d7:	00 
  8005d8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005db:	89 1c 24             	mov    %ebx,(%esp)
  8005de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e5:	e8 26 0a 00 00       	call   801010 <__udivdi3>
  8005ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ff:	89 fa                	mov    %edi,%edx
  800601:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800604:	e8 67 ff ff ff       	call   800570 <printnum>
  800609:	eb 14                	jmp    80061f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80060b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060f:	8b 45 18             	mov    0x18(%ebp),%eax
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800617:	83 ee 01             	sub    $0x1,%esi
  80061a:	75 ef                	jne    80060b <printnum+0x9b>
  80061c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80061f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800623:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800627:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80062a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80062e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800635:	00 
  800636:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800639:	89 1c 24             	mov    %ebx,(%esp)
  80063c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	e8 18 0b 00 00       	call   801160 <__umoddi3>
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	0f be 80 5d 13 80 00 	movsbl 0x80135d(%eax),%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800659:	ff d0                	call   *%eax
}
  80065b:	83 c4 4c             	add    $0x4c,%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800666:	83 fa 01             	cmp    $0x1,%edx
  800669:	7e 0e                	jle    800679 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800670:	89 08                	mov    %ecx,(%eax)
  800672:	8b 02                	mov    (%edx),%eax
  800674:	8b 52 04             	mov    0x4(%edx),%edx
  800677:	eb 22                	jmp    80069b <getuint+0x38>
	else if (lflag)
  800679:	85 d2                	test   %edx,%edx
  80067b:	74 10                	je     80068d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800682:	89 08                	mov    %ecx,(%eax)
  800684:	8b 02                	mov    (%edx),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
  80068b:	eb 0e                	jmp    80069b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800692:	89 08                	mov    %ecx,(%eax)
  800694:	8b 02                	mov    (%edx),%eax
  800696:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8006ac:	73 0a                	jae    8006b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b1:	88 0a                	mov    %cl,(%edx)
  8006b3:	83 c2 01             	add    $0x1,%edx
  8006b6:	89 10                	mov    %edx,(%eax)
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	e8 02 00 00 00       	call   8006e2 <vprintfmt>
	va_end(ap);
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	57                   	push   %edi
  8006e6:	56                   	push   %esi
  8006e7:	53                   	push   %ebx
  8006e8:	83 ec 4c             	sub    $0x4c,%esp
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006f4:	eb 11                	jmp    800707 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	0f 84 db 03 00 00    	je     800ad9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8006fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800702:	89 04 24             	mov    %eax,(%esp)
  800705:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800707:	0f b6 07             	movzbl (%edi),%eax
  80070a:	83 c7 01             	add    $0x1,%edi
  80070d:	83 f8 25             	cmp    $0x25,%eax
  800710:	75 e4                	jne    8006f6 <vprintfmt+0x14>
  800712:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800716:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80071d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800724:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80072b:	ba 00 00 00 00       	mov    $0x0,%edx
  800730:	eb 2b                	jmp    80075d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800735:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800739:	eb 22                	jmp    80075d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80073e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800742:	eb 19                	jmp    80075d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800744:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800747:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80074e:	eb 0d                	jmp    80075d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800750:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800753:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800756:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075d:	0f b6 0f             	movzbl (%edi),%ecx
  800760:	8d 47 01             	lea    0x1(%edi),%eax
  800763:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800766:	0f b6 07             	movzbl (%edi),%eax
  800769:	83 e8 23             	sub    $0x23,%eax
  80076c:	3c 55                	cmp    $0x55,%al
  80076e:	0f 87 40 03 00 00    	ja     800ab4 <vprintfmt+0x3d2>
  800774:	0f b6 c0             	movzbl %al,%eax
  800777:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077e:	83 e9 30             	sub    $0x30,%ecx
  800781:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800784:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800788:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80078b:	83 f9 09             	cmp    $0x9,%ecx
  80078e:	77 57                	ja     8007e7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800790:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800793:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800796:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800799:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80079c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80079f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8007a3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007a6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007a9:	83 f9 09             	cmp    $0x9,%ecx
  8007ac:	76 eb                	jbe    800799 <vprintfmt+0xb7>
  8007ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b4:	eb 34                	jmp    8007ea <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8007bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007c7:	eb 21                	jmp    8007ea <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8007c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007cd:	0f 88 71 ff ff ff    	js     800744 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007d6:	eb 85                	jmp    80075d <vprintfmt+0x7b>
  8007d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8007e2:	e9 76 ff ff ff       	jmp    80075d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ee:	0f 89 69 ff ff ff    	jns    80075d <vprintfmt+0x7b>
  8007f4:	e9 57 ff ff ff       	jmp    800750 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ff:	e9 59 ff ff ff       	jmp    80075d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8d 50 04             	lea    0x4(%eax),%edx
  80080a:	89 55 14             	mov    %edx,0x14(%ebp)
  80080d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800811:	8b 00                	mov    (%eax),%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800818:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80081b:	e9 e7 fe ff ff       	jmp    800707 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8d 50 04             	lea    0x4(%eax),%edx
  800826:	89 55 14             	mov    %edx,0x14(%ebp)
  800829:	8b 00                	mov    (%eax),%eax
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	c1 fa 1f             	sar    $0x1f,%edx
  800830:	31 d0                	xor    %edx,%eax
  800832:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800834:	83 f8 08             	cmp    $0x8,%eax
  800837:	7f 0b                	jg     800844 <vprintfmt+0x162>
  800839:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  800840:	85 d2                	test   %edx,%edx
  800842:	75 20                	jne    800864 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800844:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800848:	c7 44 24 08 75 13 80 	movl   $0x801375,0x8(%esp)
  80084f:	00 
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 34 24             	mov    %esi,(%esp)
  800857:	e8 5e fe ff ff       	call   8006ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80085f:	e9 a3 fe ff ff       	jmp    800707 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800864:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800868:	c7 44 24 08 7e 13 80 	movl   $0x80137e,0x8(%esp)
  80086f:	00 
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	89 34 24             	mov    %esi,(%esp)
  800877:	e8 3e fe ff ff       	call   8006ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80087f:	e9 83 fe ff ff       	jmp    800707 <vprintfmt+0x25>
  800884:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800887:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80088a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8d 50 04             	lea    0x4(%eax),%edx
  800893:	89 55 14             	mov    %edx,0x14(%ebp)
  800896:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800898:	85 ff                	test   %edi,%edi
  80089a:	b8 6e 13 80 00       	mov    $0x80136e,%eax
  80089f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8008a2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8008a6:	74 06                	je     8008ae <vprintfmt+0x1cc>
  8008a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008ac:	7f 16                	jg     8008c4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ae:	0f b6 17             	movzbl (%edi),%edx
  8008b1:	0f be c2             	movsbl %dl,%eax
  8008b4:	83 c7 01             	add    $0x1,%edi
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	0f 85 9f 00 00 00    	jne    80095e <vprintfmt+0x27c>
  8008bf:	e9 8b 00 00 00       	jmp    80094f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c8:	89 3c 24             	mov    %edi,(%esp)
  8008cb:	e8 c2 02 00 00       	call   800b92 <strnlen>
  8008d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008d3:	29 c2                	sub    %eax,%edx
  8008d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8008d8:	85 d2                	test   %edx,%edx
  8008da:	7e d2                	jle    8008ae <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008dc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8008e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008e3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008e6:	89 d7                	mov    %edx,%edi
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f4:	83 ef 01             	sub    $0x1,%edi
  8008f7:	75 ef                	jne    8008e8 <vprintfmt+0x206>
  8008f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ff:	eb ad                	jmp    8008ae <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800901:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800905:	74 20                	je     800927 <vprintfmt+0x245>
  800907:	0f be d2             	movsbl %dl,%edx
  80090a:	83 ea 20             	sub    $0x20,%edx
  80090d:	83 fa 5e             	cmp    $0x5e,%edx
  800910:	76 15                	jbe    800927 <vprintfmt+0x245>
					putch('?', putdat);
  800912:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800915:	89 54 24 04          	mov    %edx,0x4(%esp)
  800919:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800920:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800923:	ff d1                	call   *%ecx
  800925:	eb 0f                	jmp    800936 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800927:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80092a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800934:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800936:	83 eb 01             	sub    $0x1,%ebx
  800939:	0f b6 17             	movzbl (%edi),%edx
  80093c:	0f be c2             	movsbl %dl,%eax
  80093f:	83 c7 01             	add    $0x1,%edi
  800942:	85 c0                	test   %eax,%eax
  800944:	75 24                	jne    80096a <vprintfmt+0x288>
  800946:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800949:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80094c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800952:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800956:	0f 8e ab fd ff ff    	jle    800707 <vprintfmt+0x25>
  80095c:	eb 20                	jmp    80097e <vprintfmt+0x29c>
  80095e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800961:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800964:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800967:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096a:	85 f6                	test   %esi,%esi
  80096c:	78 93                	js     800901 <vprintfmt+0x21f>
  80096e:	83 ee 01             	sub    $0x1,%esi
  800971:	79 8e                	jns    800901 <vprintfmt+0x21f>
  800973:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800976:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800979:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80097c:	eb d1                	jmp    80094f <vprintfmt+0x26d>
  80097e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800981:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800985:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80098c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80098e:	83 ef 01             	sub    $0x1,%edi
  800991:	75 ee                	jne    800981 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800996:	e9 6c fd ff ff       	jmp    800707 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099b:	83 fa 01             	cmp    $0x1,%edx
  80099e:	66 90                	xchg   %ax,%ax
  8009a0:	7e 16                	jle    8009b8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8d 50 08             	lea    0x8(%eax),%edx
  8009a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8009b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009b6:	eb 32                	jmp    8009ea <vprintfmt+0x308>
	else if (lflag)
  8009b8:	85 d2                	test   %edx,%edx
  8009ba:	74 18                	je     8009d4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8009bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bf:	8d 50 04             	lea    0x4(%eax),%edx
  8009c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8009cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009d2:	eb 16                	jmp    8009ea <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	8d 50 04             	lea    0x4(%eax),%edx
  8009da:	89 55 14             	mov    %edx,0x14(%ebp)
  8009dd:	8b 00                	mov    (%eax),%eax
  8009df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	c1 ff 1f             	sar    $0x1f,%edi
  8009e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009f9:	79 7d                	jns    800a78 <vprintfmt+0x396>
				putch('-', putdat);
  8009fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a06:	ff d6                	call   *%esi
				num = -(long long) num;
  800a08:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a0e:	f7 d8                	neg    %eax
  800a10:	83 d2 00             	adc    $0x0,%edx
  800a13:	f7 da                	neg    %edx
			}
			base = 10;
  800a15:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a1a:	eb 5c                	jmp    800a78 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a1c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1f:	e8 3f fc ff ff       	call   800663 <getuint>
			base = 10;
  800a24:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a29:	eb 4d                	jmp    800a78 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  800a2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2e:	e8 30 fc ff ff       	call   800663 <getuint>
      base = 8;
  800a33:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800a38:	eb 3e                	jmp    800a78 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a45:	ff d6                	call   *%esi
			putch('x', putdat);
  800a47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a52:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a54:	8b 45 14             	mov    0x14(%ebp),%eax
  800a57:	8d 50 04             	lea    0x4(%eax),%edx
  800a5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a5d:	8b 00                	mov    (%eax),%eax
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a64:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a69:	eb 0d                	jmp    800a78 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6e:	e8 f0 fb ff ff       	call   800663 <getuint>
			base = 16;
  800a73:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a78:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800a7c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a80:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a83:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a92:	89 da                	mov    %ebx,%edx
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	e8 d5 fa ff ff       	call   800570 <printnum>
			break;
  800a9b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a9e:	e9 64 fc ff ff       	jmp    800707 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aa3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa7:	89 0c 24             	mov    %ecx,(%esp)
  800aaa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aaf:	e9 53 fc ff ff       	jmp    800707 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ab4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800abf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ac1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ac5:	0f 84 3c fc ff ff    	je     800707 <vprintfmt+0x25>
  800acb:	83 ef 01             	sub    $0x1,%edi
  800ace:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ad2:	75 f7                	jne    800acb <vprintfmt+0x3e9>
  800ad4:	e9 2e fc ff ff       	jmp    800707 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800ad9:	83 c4 4c             	add    $0x4c,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 28             	sub    $0x28,%esp
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800af0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800af4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800afe:	85 d2                	test   %edx,%edx
  800b00:	7e 30                	jle    800b32 <vsnprintf+0x51>
  800b02:	85 c0                	test   %eax,%eax
  800b04:	74 2c                	je     800b32 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b06:	8b 45 14             	mov    0x14(%ebp),%eax
  800b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b10:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b14:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1b:	c7 04 24 9d 06 80 00 	movl   $0x80069d,(%esp)
  800b22:	e8 bb fb ff ff       	call   8006e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b27:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b2a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b30:	eb 05                	jmp    800b37 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b3f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b46:	8b 45 10             	mov    0x10(%ebp),%eax
  800b49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	89 04 24             	mov    %eax,(%esp)
  800b5a:	e8 82 ff ff ff       	call   800ae1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    
	...

00800b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b76:	80 3a 00             	cmpb   $0x0,(%edx)
  800b79:	74 10                	je     800b8b <strlen+0x1b>
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b87:	75 f7                	jne    800b80 <strlen+0x10>
  800b89:	eb 05                	jmp    800b90 <strlen+0x20>
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	53                   	push   %ebx
  800b96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9c:	85 c9                	test   %ecx,%ecx
  800b9e:	74 1c                	je     800bbc <strnlen+0x2a>
  800ba0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ba3:	74 1e                	je     800bc3 <strnlen+0x31>
  800ba5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800baa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bac:	39 ca                	cmp    %ecx,%edx
  800bae:	74 18                	je     800bc8 <strnlen+0x36>
  800bb0:	83 c2 01             	add    $0x1,%edx
  800bb3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800bb8:	75 f0                	jne    800baa <strnlen+0x18>
  800bba:	eb 0c                	jmp    800bc8 <strnlen+0x36>
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	eb 05                	jmp    800bc8 <strnlen+0x36>
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	0f b6 19             	movzbl (%ecx),%ebx
  800bda:	88 1a                	mov    %bl,(%edx)
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	83 c1 01             	add    $0x1,%ecx
  800be2:	84 db                	test   %bl,%bl
  800be4:	75 f1                	jne    800bd7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800be6:	5b                   	pop    %ebx
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	53                   	push   %ebx
  800bed:	83 ec 08             	sub    $0x8,%esp
  800bf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bf3:	89 1c 24             	mov    %ebx,(%esp)
  800bf6:	e8 75 ff ff ff       	call   800b70 <strlen>
	strcpy(dst + len, src);
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c02:	01 d8                	add    %ebx,%eax
  800c04:	89 04 24             	mov    %eax,(%esp)
  800c07:	e8 bf ff ff ff       	call   800bcb <strcpy>
	return dst;
}
  800c0c:	89 d8                	mov    %ebx,%eax
  800c0e:	83 c4 08             	add    $0x8,%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c22:	85 db                	test   %ebx,%ebx
  800c24:	74 16                	je     800c3c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800c26:	01 f3                	add    %esi,%ebx
  800c28:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800c2a:	0f b6 02             	movzbl (%edx),%eax
  800c2d:	88 01                	mov    %al,(%ecx)
  800c2f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c32:	80 3a 01             	cmpb   $0x1,(%edx)
  800c35:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c38:	39 d9                	cmp    %ebx,%ecx
  800c3a:	75 ee                	jne    800c2a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c3c:	89 f0                	mov    %esi,%eax
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c51:	89 f8                	mov    %edi,%eax
  800c53:	85 f6                	test   %esi,%esi
  800c55:	74 33                	je     800c8a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800c57:	83 fe 01             	cmp    $0x1,%esi
  800c5a:	74 25                	je     800c81 <strlcpy+0x3f>
  800c5c:	0f b6 0b             	movzbl (%ebx),%ecx
  800c5f:	84 c9                	test   %cl,%cl
  800c61:	74 22                	je     800c85 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c63:	83 ee 02             	sub    $0x2,%esi
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c6b:	88 08                	mov    %cl,(%eax)
  800c6d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	74 13                	je     800c87 <strlcpy+0x45>
  800c74:	83 c2 01             	add    $0x1,%edx
  800c77:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c7b:	84 c9                	test   %cl,%cl
  800c7d:	75 ec                	jne    800c6b <strlcpy+0x29>
  800c7f:	eb 06                	jmp    800c87 <strlcpy+0x45>
  800c81:	89 f8                	mov    %edi,%eax
  800c83:	eb 02                	jmp    800c87 <strlcpy+0x45>
  800c85:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c8a:	29 f8                	sub    %edi,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c9a:	0f b6 01             	movzbl (%ecx),%eax
  800c9d:	84 c0                	test   %al,%al
  800c9f:	74 15                	je     800cb6 <strcmp+0x25>
  800ca1:	3a 02                	cmp    (%edx),%al
  800ca3:	75 11                	jne    800cb6 <strcmp+0x25>
		p++, q++;
  800ca5:	83 c1 01             	add    $0x1,%ecx
  800ca8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cab:	0f b6 01             	movzbl (%ecx),%eax
  800cae:	84 c0                	test   %al,%al
  800cb0:	74 04                	je     800cb6 <strcmp+0x25>
  800cb2:	3a 02                	cmp    (%edx),%al
  800cb4:	74 ef                	je     800ca5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb6:	0f b6 c0             	movzbl %al,%eax
  800cb9:	0f b6 12             	movzbl (%edx),%edx
  800cbc:	29 d0                	sub    %edx,%eax
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800cce:	85 f6                	test   %esi,%esi
  800cd0:	74 29                	je     800cfb <strncmp+0x3b>
  800cd2:	0f b6 03             	movzbl (%ebx),%eax
  800cd5:	84 c0                	test   %al,%al
  800cd7:	74 30                	je     800d09 <strncmp+0x49>
  800cd9:	3a 02                	cmp    (%edx),%al
  800cdb:	75 2c                	jne    800d09 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800cdd:	8d 43 01             	lea    0x1(%ebx),%eax
  800ce0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ce7:	39 f0                	cmp    %esi,%eax
  800ce9:	74 17                	je     800d02 <strncmp+0x42>
  800ceb:	0f b6 08             	movzbl (%eax),%ecx
  800cee:	84 c9                	test   %cl,%cl
  800cf0:	74 17                	je     800d09 <strncmp+0x49>
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	3a 0a                	cmp    (%edx),%cl
  800cf7:	74 e9                	je     800ce2 <strncmp+0x22>
  800cf9:	eb 0e                	jmp    800d09 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800d00:	eb 0f                	jmp    800d11 <strncmp+0x51>
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
  800d07:	eb 08                	jmp    800d11 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d09:	0f b6 03             	movzbl (%ebx),%eax
  800d0c:	0f b6 12             	movzbl (%edx),%edx
  800d0f:	29 d0                	sub    %edx,%eax
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	53                   	push   %ebx
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d1f:	0f b6 18             	movzbl (%eax),%ebx
  800d22:	84 db                	test   %bl,%bl
  800d24:	74 1d                	je     800d43 <strchr+0x2e>
  800d26:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d28:	38 d3                	cmp    %dl,%bl
  800d2a:	75 06                	jne    800d32 <strchr+0x1d>
  800d2c:	eb 1a                	jmp    800d48 <strchr+0x33>
  800d2e:	38 ca                	cmp    %cl,%dl
  800d30:	74 16                	je     800d48 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d32:	83 c0 01             	add    $0x1,%eax
  800d35:	0f b6 10             	movzbl (%eax),%edx
  800d38:	84 d2                	test   %dl,%dl
  800d3a:	75 f2                	jne    800d2e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	eb 05                	jmp    800d48 <strchr+0x33>
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d48:	5b                   	pop    %ebx
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	53                   	push   %ebx
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d55:	0f b6 18             	movzbl (%eax),%ebx
  800d58:	84 db                	test   %bl,%bl
  800d5a:	74 16                	je     800d72 <strfind+0x27>
  800d5c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d5e:	38 d3                	cmp    %dl,%bl
  800d60:	75 06                	jne    800d68 <strfind+0x1d>
  800d62:	eb 0e                	jmp    800d72 <strfind+0x27>
  800d64:	38 ca                	cmp    %cl,%dl
  800d66:	74 0a                	je     800d72 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d68:	83 c0 01             	add    $0x1,%eax
  800d6b:	0f b6 10             	movzbl (%eax),%edx
  800d6e:	84 d2                	test   %dl,%dl
  800d70:	75 f2                	jne    800d64 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d81:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d8a:	85 c9                	test   %ecx,%ecx
  800d8c:	74 36                	je     800dc4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d94:	75 28                	jne    800dbe <memset+0x49>
  800d96:	f6 c1 03             	test   $0x3,%cl
  800d99:	75 23                	jne    800dbe <memset+0x49>
		c &= 0xFF;
  800d9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d9f:	89 d3                	mov    %edx,%ebx
  800da1:	c1 e3 08             	shl    $0x8,%ebx
  800da4:	89 d6                	mov    %edx,%esi
  800da6:	c1 e6 18             	shl    $0x18,%esi
  800da9:	89 d0                	mov    %edx,%eax
  800dab:	c1 e0 10             	shl    $0x10,%eax
  800dae:	09 f0                	or     %esi,%eax
  800db0:	09 c2                	or     %eax,%edx
  800db2:	89 d0                	mov    %edx,%eax
  800db4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800db6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800db9:	fc                   	cld    
  800dba:	f3 ab                	rep stos %eax,%es:(%edi)
  800dbc:	eb 06                	jmp    800dc4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	fc                   	cld    
  800dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dc4:	89 f8                	mov    %edi,%eax
  800dc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcf:	89 ec                	mov    %ebp,%esp
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de8:	39 c6                	cmp    %eax,%esi
  800dea:	73 36                	jae    800e22 <memmove+0x4f>
  800dec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800def:	39 d0                	cmp    %edx,%eax
  800df1:	73 2f                	jae    800e22 <memmove+0x4f>
		s += n;
		d += n;
  800df3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df6:	f6 c2 03             	test   $0x3,%dl
  800df9:	75 1b                	jne    800e16 <memmove+0x43>
  800dfb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e01:	75 13                	jne    800e16 <memmove+0x43>
  800e03:	f6 c1 03             	test   $0x3,%cl
  800e06:	75 0e                	jne    800e16 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e08:	83 ef 04             	sub    $0x4,%edi
  800e0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e11:	fd                   	std    
  800e12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e14:	eb 09                	jmp    800e1f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e16:	83 ef 01             	sub    $0x1,%edi
  800e19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1c:	fd                   	std    
  800e1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e1f:	fc                   	cld    
  800e20:	eb 20                	jmp    800e42 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e28:	75 13                	jne    800e3d <memmove+0x6a>
  800e2a:	a8 03                	test   $0x3,%al
  800e2c:	75 0f                	jne    800e3d <memmove+0x6a>
  800e2e:	f6 c1 03             	test   $0x3,%cl
  800e31:	75 0a                	jne    800e3d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e36:	89 c7                	mov    %eax,%edi
  800e38:	fc                   	cld    
  800e39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3b:	eb 05                	jmp    800e42 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3d:	89 c7                	mov    %eax,%edi
  800e3f:	fc                   	cld    
  800e40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e52:	8b 45 10             	mov    0x10(%ebp),%eax
  800e55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	89 04 24             	mov    %eax,(%esp)
  800e66:	e8 68 ff ff ff       	call   800dd3 <memmove>
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e79:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	74 36                	je     800eb9 <memcmp+0x4c>
		if (*s1 != *s2)
  800e83:	0f b6 03             	movzbl (%ebx),%eax
  800e86:	0f b6 0e             	movzbl (%esi),%ecx
  800e89:	38 c8                	cmp    %cl,%al
  800e8b:	75 17                	jne    800ea4 <memcmp+0x37>
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	eb 1a                	jmp    800eae <memcmp+0x41>
  800e94:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e99:	83 c2 01             	add    $0x1,%edx
  800e9c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ea0:	38 c8                	cmp    %cl,%al
  800ea2:	74 0a                	je     800eae <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ea4:	0f b6 c0             	movzbl %al,%eax
  800ea7:	0f b6 c9             	movzbl %cl,%ecx
  800eaa:	29 c8                	sub    %ecx,%eax
  800eac:	eb 10                	jmp    800ebe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eae:	39 fa                	cmp    %edi,%edx
  800eb0:	75 e2                	jne    800e94 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 05                	jmp    800ebe <memcmp+0x51>
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	53                   	push   %ebx
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed2:	39 d0                	cmp    %edx,%eax
  800ed4:	73 13                	jae    800ee9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed6:	89 d9                	mov    %ebx,%ecx
  800ed8:	38 18                	cmp    %bl,(%eax)
  800eda:	75 06                	jne    800ee2 <memfind+0x1f>
  800edc:	eb 0b                	jmp    800ee9 <memfind+0x26>
  800ede:	38 08                	cmp    %cl,(%eax)
  800ee0:	74 07                	je     800ee9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee2:	83 c0 01             	add    $0x1,%eax
  800ee5:	39 d0                	cmp    %edx,%eax
  800ee7:	75 f5                	jne    800ede <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ee9:	5b                   	pop    %ebx
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800efb:	0f b6 02             	movzbl (%edx),%eax
  800efe:	3c 09                	cmp    $0x9,%al
  800f00:	74 04                	je     800f06 <strtol+0x1a>
  800f02:	3c 20                	cmp    $0x20,%al
  800f04:	75 0e                	jne    800f14 <strtol+0x28>
		s++;
  800f06:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f09:	0f b6 02             	movzbl (%edx),%eax
  800f0c:	3c 09                	cmp    $0x9,%al
  800f0e:	74 f6                	je     800f06 <strtol+0x1a>
  800f10:	3c 20                	cmp    $0x20,%al
  800f12:	74 f2                	je     800f06 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f14:	3c 2b                	cmp    $0x2b,%al
  800f16:	75 0a                	jne    800f22 <strtol+0x36>
		s++;
  800f18:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f20:	eb 10                	jmp    800f32 <strtol+0x46>
  800f22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f27:	3c 2d                	cmp    $0x2d,%al
  800f29:	75 07                	jne    800f32 <strtol+0x46>
		s++, neg = 1;
  800f2b:	83 c2 01             	add    $0x1,%edx
  800f2e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f38:	75 15                	jne    800f4f <strtol+0x63>
  800f3a:	80 3a 30             	cmpb   $0x30,(%edx)
  800f3d:	75 10                	jne    800f4f <strtol+0x63>
  800f3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f43:	75 0a                	jne    800f4f <strtol+0x63>
		s += 2, base = 16;
  800f45:	83 c2 02             	add    $0x2,%edx
  800f48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f4d:	eb 10                	jmp    800f5f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f4f:	85 db                	test   %ebx,%ebx
  800f51:	75 0c                	jne    800f5f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f53:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f55:	80 3a 30             	cmpb   $0x30,(%edx)
  800f58:	75 05                	jne    800f5f <strtol+0x73>
		s++, base = 8;
  800f5a:	83 c2 01             	add    $0x1,%edx
  800f5d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f64:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f67:	0f b6 0a             	movzbl (%edx),%ecx
  800f6a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f6d:	89 f3                	mov    %esi,%ebx
  800f6f:	80 fb 09             	cmp    $0x9,%bl
  800f72:	77 08                	ja     800f7c <strtol+0x90>
			dig = *s - '0';
  800f74:	0f be c9             	movsbl %cl,%ecx
  800f77:	83 e9 30             	sub    $0x30,%ecx
  800f7a:	eb 22                	jmp    800f9e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800f7c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f7f:	89 f3                	mov    %esi,%ebx
  800f81:	80 fb 19             	cmp    $0x19,%bl
  800f84:	77 08                	ja     800f8e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800f86:	0f be c9             	movsbl %cl,%ecx
  800f89:	83 e9 57             	sub    $0x57,%ecx
  800f8c:	eb 10                	jmp    800f9e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800f8e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f91:	89 f3                	mov    %esi,%ebx
  800f93:	80 fb 19             	cmp    $0x19,%bl
  800f96:	77 16                	ja     800fae <strtol+0xc2>
			dig = *s - 'A' + 10;
  800f98:	0f be c9             	movsbl %cl,%ecx
  800f9b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f9e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800fa1:	7d 0f                	jge    800fb2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800faa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800fac:	eb b9                	jmp    800f67 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	eb 02                	jmp    800fb4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fb2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fb8:	74 05                	je     800fbf <strtol+0xd3>
		*endptr = (char *) s;
  800fba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fbd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fbf:	89 ca                	mov    %ecx,%edx
  800fc1:	f7 da                	neg    %edx
  800fc3:	85 ff                	test   %edi,%edi
  800fc5:	0f 45 c2             	cmovne %edx,%eax
}
  800fc8:	83 c4 04             	add    $0x4,%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fd6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fdd:	75 1c                	jne    800ffb <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800fdf:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800ff6:	e8 55 f4 ff ff       	call   800450 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    
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
