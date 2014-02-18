
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800062:	e8 09 01 00 00       	call   800170 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 74 24 04          	mov    %esi,0x4(%esp)
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 61 00 00 00       	call   800113 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 d1                	mov    %edx,%ecx
  8000fe:	89 d3                	mov    %edx,%ebx
  800100:	89 d7                	mov    %edx,%edi
  800102:	89 d6                	mov    %edx,%esi
  800104:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800106:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800109:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80010c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 38             	sub    $0x38,%esp
  800119:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80011c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	b9 00 00 00 00       	mov    $0x0,%ecx
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	89 cb                	mov    %ecx,%ebx
  800131:	89 cf                	mov    %ecx,%edi
  800133:	89 ce                	mov    %ecx,%esi
  800135:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800137:	85 c0                	test   %eax,%eax
  800139:	7e 28                	jle    800163 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800146:	00 
  800147:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  80014e:	00 
  80014f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800156:	00 
  800157:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80015e:	e8 d5 02 00 00       	call   800438 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800163:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800166:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800169:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80016c:	89 ec                	mov    %ebp,%esp
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800179:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80017c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017f:	ba 00 00 00 00       	mov    $0x0,%edx
  800184:	b8 02 00 00 00       	mov    $0x2,%eax
  800189:	89 d1                	mov    %edx,%ecx
  80018b:	89 d3                	mov    %edx,%ebx
  80018d:	89 d7                	mov    %edx,%edi
  80018f:	89 d6                	mov    %edx,%esi
  800191:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800193:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800196:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800199:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019c:	89 ec                	mov    %ebp,%esp
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <sys_yield>:

void
sys_yield(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b9:	89 d1                	mov    %edx,%ecx
  8001bb:	89 d3                	mov    %edx,%ebx
  8001bd:	89 d7                	mov    %edx,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 38             	sub    $0x38,%esp
  8001d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	be 00 00 00 00       	mov    $0x0,%esi
  8001e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f2:	89 f7                	mov    %esi,%edi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 28                	jle    800222 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800205:	00 
  800206:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80021d:	e8 16 02 00 00       	call   800438 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800222:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800225:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800228:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022b:	89 ec                	mov    %ebp,%esp
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 38             	sub    $0x38,%esp
  800235:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800238:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023e:	b8 05 00 00 00       	mov    $0x5,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024f:	8b 75 18             	mov    0x18(%ebp),%esi
  800252:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800254:	85 c0                	test   %eax,%eax
  800256:	7e 28                	jle    800280 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800263:	00 
  800264:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  80026b:	00 
  80026c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800273:	00 
  800274:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80027b:	e8 b8 01 00 00       	call   800438 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800280:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800283:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800286:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800289:	89 ec                	mov    %ebp,%esp
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 38             	sub    $0x38,%esp
  800293:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800296:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800299:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  8002d9:	e8 5a 01 00 00       	call   800438 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e7:	89 ec                	mov    %ebp,%esp
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 38             	sub    $0x38,%esp
  8002f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	89 df                	mov    %ebx,%edi
  80030c:	89 de                	mov    %ebx,%esi
  80030e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800310:	85 c0                	test   %eax,%eax
  800312:	7e 28                	jle    80033c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800314:	89 44 24 10          	mov    %eax,0x10(%esp)
  800318:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031f:	00 
  800320:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800327:	00 
  800328:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032f:	00 
  800330:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800337:	e8 fc 00 00 00       	call   800438 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80033c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800342:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800345:	89 ec                	mov    %ebp,%esp
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 38             	sub    $0x38,%esp
  80034f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800352:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800355:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800358:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035d:	b8 09 00 00 00       	mov    $0x9,%eax
  800362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800365:	8b 55 08             	mov    0x8(%ebp),%edx
  800368:	89 df                	mov    %ebx,%edi
  80036a:	89 de                	mov    %ebx,%esi
  80036c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036e:	85 c0                	test   %eax,%eax
  800370:	7e 28                	jle    80039a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800372:	89 44 24 10          	mov    %eax,0x10(%esp)
  800376:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80037d:	00 
  80037e:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800395:	e8 9e 00 00 00       	call   800438 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80039d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a3:	89 ec                	mov    %ebp,%esp
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b6:	be 00 00 00 00       	mov    $0x0,%esi
  8003bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003cc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d7:	89 ec                	mov    %ebp,%esp
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 38             	sub    $0x38,%esp
  8003e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	89 cb                	mov    %ecx,%ebx
  8003f9:	89 cf                	mov    %ecx,%edi
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ff:	85 c0                	test   %eax,%eax
  800401:	7e 28                	jle    80042b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800403:	89 44 24 10          	mov    %eax,0x10(%esp)
  800407:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040e:	00 
  80040f:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800416:	00 
  800417:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041e:	00 
  80041f:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800426:	e8 0d 00 00 00       	call   800438 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800431:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800434:	89 ec                	mov    %ebp,%esp
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	56                   	push   %esi
  80043c:	53                   	push   %ebx
  80043d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800440:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800443:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800449:	e8 22 fd ff ff       	call   800170 <sys_getenvid>
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 54 24 10          	mov    %edx,0x10(%esp)
  800455:	8b 55 08             	mov    0x8(%ebp),%edx
  800458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  80046b:	e8 c3 00 00 00       	call   800533 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 53 00 00 00       	call   8004d2 <vcprintf>
	cprintf("\n");
  80047f:	c7 04 24 fc 12 80 00 	movl   $0x8012fc,(%esp)
  800486:	e8 a8 00 00 00       	call   800533 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048b:	cc                   	int3   
  80048c:	eb fd                	jmp    80048b <_panic+0x53>
	...

00800490 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	53                   	push   %ebx
  800494:	83 ec 14             	sub    $0x14,%esp
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049a:	8b 03                	mov    (%ebx),%eax
  80049c:	8b 55 08             	mov    0x8(%ebp),%edx
  80049f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a3:	83 c0 01             	add    $0x1,%eax
  8004a6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ad:	75 19                	jne    8004c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b6:	00 
  8004b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ba:	89 04 24             	mov    %eax,(%esp)
  8004bd:	e8 f2 fb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8004c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	5b                   	pop    %ebx
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e2:	00 00 00 
	b.cnt = 0;
  8004e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  80050e:	e8 af 01 00 00       	call   8006c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800513:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	e8 89 fb ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80052b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800539:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80053c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800540:	8b 45 08             	mov    0x8(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	e8 87 ff ff ff       	call   8004d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    
  80054d:	00 00                	add    %al,(%eax)
	...

00800550 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 4c             	sub    $0x4c,%esp
  800559:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80055c:	89 d7                	mov    %edx,%edi
  80055e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800561:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80056a:	b8 00 00 00 00       	mov    $0x0,%eax
  80056f:	39 d8                	cmp    %ebx,%eax
  800571:	72 17                	jb     80058a <printnum+0x3a>
  800573:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800576:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800579:	76 0f                	jbe    80058a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80057b:	8b 75 14             	mov    0x14(%ebp),%esi
  80057e:	83 ee 01             	sub    $0x1,%esi
  800581:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800584:	85 f6                	test   %esi,%esi
  800586:	7f 63                	jg     8005eb <printnum+0x9b>
  800588:	eb 75                	jmp    8005ff <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80058d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	83 e8 01             	sub    $0x1,%eax
  800597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005a2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005a6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b7:	00 
  8005b8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005bb:	89 1c 24             	mov    %ebx,(%esp)
  8005be:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c5:	e8 e6 09 00 00       	call   800fb0 <__udivdi3>
  8005ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005d4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005df:	89 fa                	mov    %edi,%edx
  8005e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005e4:	e8 67 ff ff ff       	call   800550 <printnum>
  8005e9:	eb 14                	jmp    8005ff <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ef:	8b 45 18             	mov    0x18(%ebp),%eax
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f7:	83 ee 01             	sub    $0x1,%esi
  8005fa:	75 ef                	jne    8005eb <printnum+0x9b>
  8005fc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800603:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800607:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80060e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800615:	00 
  800616:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800619:	89 1c 24             	mov    %ebx,(%esp)
  80061c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	e8 d8 0a 00 00       	call   801100 <__umoddi3>
  800628:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062c:	0f be 80 fe 12 80 00 	movsbl 0x8012fe(%eax),%eax
  800633:	89 04 24             	mov    %eax,(%esp)
  800636:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800639:	ff d0                	call   *%eax
}
  80063b:	83 c4 4c             	add    $0x4c,%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	5d                   	pop    %ebp
  800642:	c3                   	ret    

00800643 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800646:	83 fa 01             	cmp    $0x1,%edx
  800649:	7e 0e                	jle    800659 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800650:	89 08                	mov    %ecx,(%eax)
  800652:	8b 02                	mov    (%edx),%eax
  800654:	8b 52 04             	mov    0x4(%edx),%edx
  800657:	eb 22                	jmp    80067b <getuint+0x38>
	else if (lflag)
  800659:	85 d2                	test   %edx,%edx
  80065b:	74 10                	je     80066d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800662:	89 08                	mov    %ecx,(%eax)
  800664:	8b 02                	mov    (%edx),%eax
  800666:	ba 00 00 00 00       	mov    $0x0,%edx
  80066b:	eb 0e                	jmp    80067b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800672:	89 08                	mov    %ecx,(%eax)
  800674:	8b 02                	mov    (%edx),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800683:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800687:	8b 10                	mov    (%eax),%edx
  800689:	3b 50 04             	cmp    0x4(%eax),%edx
  80068c:	73 0a                	jae    800698 <sprintputch+0x1b>
		*b->buf++ = ch;
  80068e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800691:	88 0a                	mov    %cl,(%edx)
  800693:	83 c2 01             	add    $0x1,%edx
  800696:	89 10                	mov    %edx,(%eax)
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	e8 02 00 00 00       	call   8006c2 <vprintfmt>
	va_end(ap);
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 4c             	sub    $0x4c,%esp
  8006cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006d4:	eb 11                	jmp    8006e7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	0f 84 db 03 00 00    	je     800ab9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	89 04 24             	mov    %eax,(%esp)
  8006e5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e7:	0f b6 07             	movzbl (%edi),%eax
  8006ea:	83 c7 01             	add    $0x1,%edi
  8006ed:	83 f8 25             	cmp    $0x25,%eax
  8006f0:	75 e4                	jne    8006d6 <vprintfmt+0x14>
  8006f2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8006f6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8006fd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800704:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80070b:	ba 00 00 00 00       	mov    $0x0,%edx
  800710:	eb 2b                	jmp    80073d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800715:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800719:	eb 22                	jmp    80073d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80071e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800722:	eb 19                	jmp    80073d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800727:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80072e:	eb 0d                	jmp    80073d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800730:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800733:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800736:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	0f b6 0f             	movzbl (%edi),%ecx
  800740:	8d 47 01             	lea    0x1(%edi),%eax
  800743:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800746:	0f b6 07             	movzbl (%edi),%eax
  800749:	83 e8 23             	sub    $0x23,%eax
  80074c:	3c 55                	cmp    $0x55,%al
  80074e:	0f 87 40 03 00 00    	ja     800a94 <vprintfmt+0x3d2>
  800754:	0f b6 c0             	movzbl %al,%eax
  800757:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80075e:	83 e9 30             	sub    $0x30,%ecx
  800761:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800764:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800768:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80076b:	83 f9 09             	cmp    $0x9,%ecx
  80076e:	77 57                	ja     8007c7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800773:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800776:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800779:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80077c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80077f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800783:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800786:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800789:	83 f9 09             	cmp    $0x9,%ecx
  80078c:	76 eb                	jbe    800779 <vprintfmt+0xb7>
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800794:	eb 34                	jmp    8007ca <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 48 04             	lea    0x4(%eax),%ecx
  80079c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a7:	eb 21                	jmp    8007ca <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8007a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ad:	0f 88 71 ff ff ff    	js     800724 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007b6:	eb 85                	jmp    80073d <vprintfmt+0x7b>
  8007b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8007c2:	e9 76 ff ff ff       	jmp    80073d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ce:	0f 89 69 ff ff ff    	jns    80073d <vprintfmt+0x7b>
  8007d4:	e9 57 ff ff ff       	jmp    800730 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007df:	e9 59 ff ff ff       	jmp    80073d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 04 24             	mov    %eax,(%esp)
  8007f6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007fb:	e9 e7 fe ff ff       	jmp    8006e7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 00                	mov    (%eax),%eax
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	c1 fa 1f             	sar    $0x1f,%edx
  800810:	31 d0                	xor    %edx,%eax
  800812:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800814:	83 f8 08             	cmp    $0x8,%eax
  800817:	7f 0b                	jg     800824 <vprintfmt+0x162>
  800819:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800820:	85 d2                	test   %edx,%edx
  800822:	75 20                	jne    800844 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800824:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800828:	c7 44 24 08 16 13 80 	movl   $0x801316,0x8(%esp)
  80082f:	00 
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	89 34 24             	mov    %esi,(%esp)
  800837:	e8 5e fe ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80083f:	e9 a3 fe ff ff       	jmp    8006e7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800844:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800848:	c7 44 24 08 1f 13 80 	movl   $0x80131f,0x8(%esp)
  80084f:	00 
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 34 24             	mov    %esi,(%esp)
  800857:	e8 3e fe ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80085f:	e9 83 fe ff ff       	jmp    8006e7 <vprintfmt+0x25>
  800864:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800867:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80086a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)
  800876:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800878:	85 ff                	test   %edi,%edi
  80087a:	b8 0f 13 80 00       	mov    $0x80130f,%eax
  80087f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800882:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800886:	74 06                	je     80088e <vprintfmt+0x1cc>
  800888:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80088c:	7f 16                	jg     8008a4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088e:	0f b6 17             	movzbl (%edi),%edx
  800891:	0f be c2             	movsbl %dl,%eax
  800894:	83 c7 01             	add    $0x1,%edi
  800897:	85 c0                	test   %eax,%eax
  800899:	0f 85 9f 00 00 00    	jne    80093e <vprintfmt+0x27c>
  80089f:	e9 8b 00 00 00       	jmp    80092f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a8:	89 3c 24             	mov    %edi,(%esp)
  8008ab:	e8 c2 02 00 00       	call   800b72 <strnlen>
  8008b0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008b3:	29 c2                	sub    %eax,%edx
  8008b5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	7e d2                	jle    80088e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008bc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8008c0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008c3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008c6:	89 d7                	mov    %edx,%edi
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008cf:	89 04 24             	mov    %eax,(%esp)
  8008d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d4:	83 ef 01             	sub    $0x1,%edi
  8008d7:	75 ef                	jne    8008c8 <vprintfmt+0x206>
  8008d9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008df:	eb ad                	jmp    80088e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008e5:	74 20                	je     800907 <vprintfmt+0x245>
  8008e7:	0f be d2             	movsbl %dl,%edx
  8008ea:	83 ea 20             	sub    $0x20,%edx
  8008ed:	83 fa 5e             	cmp    $0x5e,%edx
  8008f0:	76 15                	jbe    800907 <vprintfmt+0x245>
					putch('?', putdat);
  8008f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800900:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800903:	ff d1                	call   *%ecx
  800905:	eb 0f                	jmp    800916 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800907:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80090a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090e:	89 04 24             	mov    %eax,(%esp)
  800911:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800914:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800916:	83 eb 01             	sub    $0x1,%ebx
  800919:	0f b6 17             	movzbl (%edi),%edx
  80091c:	0f be c2             	movsbl %dl,%eax
  80091f:	83 c7 01             	add    $0x1,%edi
  800922:	85 c0                	test   %eax,%eax
  800924:	75 24                	jne    80094a <vprintfmt+0x288>
  800926:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800929:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80092c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800932:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800936:	0f 8e ab fd ff ff    	jle    8006e7 <vprintfmt+0x25>
  80093c:	eb 20                	jmp    80095e <vprintfmt+0x29c>
  80093e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800941:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800944:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800947:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094a:	85 f6                	test   %esi,%esi
  80094c:	78 93                	js     8008e1 <vprintfmt+0x21f>
  80094e:	83 ee 01             	sub    $0x1,%esi
  800951:	79 8e                	jns    8008e1 <vprintfmt+0x21f>
  800953:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800956:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800959:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80095c:	eb d1                	jmp    80092f <vprintfmt+0x26d>
  80095e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096e:	83 ef 01             	sub    $0x1,%edi
  800971:	75 ee                	jne    800961 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800973:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800976:	e9 6c fd ff ff       	jmp    8006e7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80097b:	83 fa 01             	cmp    $0x1,%edx
  80097e:	66 90                	xchg   %ax,%ax
  800980:	7e 16                	jle    800998 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 50 08             	lea    0x8(%eax),%edx
  800988:	89 55 14             	mov    %edx,0x14(%ebp)
  80098b:	8b 10                	mov    (%eax),%edx
  80098d:	8b 48 04             	mov    0x4(%eax),%ecx
  800990:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800993:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800996:	eb 32                	jmp    8009ca <vprintfmt+0x308>
	else if (lflag)
  800998:	85 d2                	test   %edx,%edx
  80099a:	74 18                	je     8009b4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8d 50 04             	lea    0x4(%eax),%edx
  8009a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009aa:	89 c1                	mov    %eax,%ecx
  8009ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8009af:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009b2:	eb 16                	jmp    8009ca <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bd:	8b 00                	mov    (%eax),%eax
  8009bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	c1 ff 1f             	sar    $0x1f,%edi
  8009c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009d9:	79 7d                	jns    800a58 <vprintfmt+0x396>
				putch('-', putdat);
  8009db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009ee:	f7 d8                	neg    %eax
  8009f0:	83 d2 00             	adc    $0x0,%edx
  8009f3:	f7 da                	neg    %edx
			}
			base = 10;
  8009f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009fa:	eb 5c                	jmp    800a58 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ff:	e8 3f fc ff ff       	call   800643 <getuint>
			base = 10;
  800a04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a09:	eb 4d                	jmp    800a58 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  800a0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0e:	e8 30 fc ff ff       	call   800643 <getuint>
      base = 8;
  800a13:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800a18:	eb 3e                	jmp    800a58 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a25:	ff d6                	call   *%esi
			putch('x', putdat);
  800a27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a32:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a34:	8b 45 14             	mov    0x14(%ebp),%eax
  800a37:	8d 50 04             	lea    0x4(%eax),%edx
  800a3a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a3d:	8b 00                	mov    (%eax),%eax
  800a3f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a44:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a49:	eb 0d                	jmp    800a58 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4e:	e8 f0 fb ff ff       	call   800643 <getuint>
			base = 16;
  800a53:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a58:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800a5c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a60:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a63:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a72:	89 da                	mov    %ebx,%edx
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	e8 d5 fa ff ff       	call   800550 <printnum>
			break;
  800a7b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a7e:	e9 64 fc ff ff       	jmp    8006e7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a87:	89 0c 24             	mov    %ecx,(%esp)
  800a8a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a8f:	e9 53 fc ff ff       	jmp    8006e7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a98:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a9f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800aa5:	0f 84 3c fc ff ff    	je     8006e7 <vprintfmt+0x25>
  800aab:	83 ef 01             	sub    $0x1,%edi
  800aae:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ab2:	75 f7                	jne    800aab <vprintfmt+0x3e9>
  800ab4:	e9 2e fc ff ff       	jmp    8006e7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800ab9:	83 c4 4c             	add    $0x4c,%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 28             	sub    $0x28,%esp
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ade:	85 d2                	test   %edx,%edx
  800ae0:	7e 30                	jle    800b12 <vsnprintf+0x51>
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	74 2c                	je     800b12 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aed:	8b 45 10             	mov    0x10(%ebp),%eax
  800af0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afb:	c7 04 24 7d 06 80 00 	movl   $0x80067d,(%esp)
  800b02:	e8 bb fb ff ff       	call   8006c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b10:	eb 05                	jmp    800b17 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    

00800b19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	89 04 24             	mov    %eax,(%esp)
  800b3a:	e8 82 ff ff ff       	call   800ac1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    
	...

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	80 3a 00             	cmpb   $0x0,(%edx)
  800b59:	74 10                	je     800b6b <strlen+0x1b>
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b67:	75 f7                	jne    800b60 <strlen+0x10>
  800b69:	eb 05                	jmp    800b70 <strlen+0x20>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	53                   	push   %ebx
  800b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7c:	85 c9                	test   %ecx,%ecx
  800b7e:	74 1c                	je     800b9c <strnlen+0x2a>
  800b80:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b83:	74 1e                	je     800ba3 <strnlen+0x31>
  800b85:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b8a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8c:	39 ca                	cmp    %ecx,%edx
  800b8e:	74 18                	je     800ba8 <strnlen+0x36>
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b98:	75 f0                	jne    800b8a <strnlen+0x18>
  800b9a:	eb 0c                	jmp    800ba8 <strnlen+0x36>
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	eb 05                	jmp    800ba8 <strnlen+0x36>
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb5:	89 c2                	mov    %eax,%edx
  800bb7:	0f b6 19             	movzbl (%ecx),%ebx
  800bba:	88 1a                	mov    %bl,(%edx)
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	83 c1 01             	add    $0x1,%ecx
  800bc2:	84 db                	test   %bl,%bl
  800bc4:	75 f1                	jne    800bb7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 08             	sub    $0x8,%esp
  800bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd3:	89 1c 24             	mov    %ebx,(%esp)
  800bd6:	e8 75 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bde:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be2:	01 d8                	add    %ebx,%eax
  800be4:	89 04 24             	mov    %eax,(%esp)
  800be7:	e8 bf ff ff ff       	call   800bab <strcpy>
	return dst;
}
  800bec:	89 d8                	mov    %ebx,%eax
  800bee:	83 c4 08             	add    $0x8,%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c02:	85 db                	test   %ebx,%ebx
  800c04:	74 16                	je     800c1c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800c06:	01 f3                	add    %esi,%ebx
  800c08:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800c0a:	0f b6 02             	movzbl (%edx),%eax
  800c0d:	88 01                	mov    %al,(%ecx)
  800c0f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c12:	80 3a 01             	cmpb   $0x1,(%edx)
  800c15:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c18:	39 d9                	cmp    %ebx,%ecx
  800c1a:	75 ee                	jne    800c0a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c1c:	89 f0                	mov    %esi,%eax
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c2e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c31:	89 f8                	mov    %edi,%eax
  800c33:	85 f6                	test   %esi,%esi
  800c35:	74 33                	je     800c6a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800c37:	83 fe 01             	cmp    $0x1,%esi
  800c3a:	74 25                	je     800c61 <strlcpy+0x3f>
  800c3c:	0f b6 0b             	movzbl (%ebx),%ecx
  800c3f:	84 c9                	test   %cl,%cl
  800c41:	74 22                	je     800c65 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c43:	83 ee 02             	sub    $0x2,%esi
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c4b:	88 08                	mov    %cl,(%eax)
  800c4d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c50:	39 f2                	cmp    %esi,%edx
  800c52:	74 13                	je     800c67 <strlcpy+0x45>
  800c54:	83 c2 01             	add    $0x1,%edx
  800c57:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c5b:	84 c9                	test   %cl,%cl
  800c5d:	75 ec                	jne    800c4b <strlcpy+0x29>
  800c5f:	eb 06                	jmp    800c67 <strlcpy+0x45>
  800c61:	89 f8                	mov    %edi,%eax
  800c63:	eb 02                	jmp    800c67 <strlcpy+0x45>
  800c65:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c67:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c6a:	29 f8                	sub    %edi,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c7a:	0f b6 01             	movzbl (%ecx),%eax
  800c7d:	84 c0                	test   %al,%al
  800c7f:	74 15                	je     800c96 <strcmp+0x25>
  800c81:	3a 02                	cmp    (%edx),%al
  800c83:	75 11                	jne    800c96 <strcmp+0x25>
		p++, q++;
  800c85:	83 c1 01             	add    $0x1,%ecx
  800c88:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c8b:	0f b6 01             	movzbl (%ecx),%eax
  800c8e:	84 c0                	test   %al,%al
  800c90:	74 04                	je     800c96 <strcmp+0x25>
  800c92:	3a 02                	cmp    (%edx),%al
  800c94:	74 ef                	je     800c85 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c96:	0f b6 c0             	movzbl %al,%eax
  800c99:	0f b6 12             	movzbl (%edx),%edx
  800c9c:	29 d0                	sub    %edx,%eax
}
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cab:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800cae:	85 f6                	test   %esi,%esi
  800cb0:	74 29                	je     800cdb <strncmp+0x3b>
  800cb2:	0f b6 03             	movzbl (%ebx),%eax
  800cb5:	84 c0                	test   %al,%al
  800cb7:	74 30                	je     800ce9 <strncmp+0x49>
  800cb9:	3a 02                	cmp    (%edx),%al
  800cbb:	75 2c                	jne    800ce9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800cbd:	8d 43 01             	lea    0x1(%ebx),%eax
  800cc0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800cc2:	89 c3                	mov    %eax,%ebx
  800cc4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cc7:	39 f0                	cmp    %esi,%eax
  800cc9:	74 17                	je     800ce2 <strncmp+0x42>
  800ccb:	0f b6 08             	movzbl (%eax),%ecx
  800cce:	84 c9                	test   %cl,%cl
  800cd0:	74 17                	je     800ce9 <strncmp+0x49>
  800cd2:	83 c0 01             	add    $0x1,%eax
  800cd5:	3a 0a                	cmp    (%edx),%cl
  800cd7:	74 e9                	je     800cc2 <strncmp+0x22>
  800cd9:	eb 0e                	jmp    800ce9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	eb 0f                	jmp    800cf1 <strncmp+0x51>
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce7:	eb 08                	jmp    800cf1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce9:	0f b6 03             	movzbl (%ebx),%eax
  800cec:	0f b6 12             	movzbl (%edx),%edx
  800cef:	29 d0                	sub    %edx,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	53                   	push   %ebx
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800cff:	0f b6 18             	movzbl (%eax),%ebx
  800d02:	84 db                	test   %bl,%bl
  800d04:	74 1d                	je     800d23 <strchr+0x2e>
  800d06:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d08:	38 d3                	cmp    %dl,%bl
  800d0a:	75 06                	jne    800d12 <strchr+0x1d>
  800d0c:	eb 1a                	jmp    800d28 <strchr+0x33>
  800d0e:	38 ca                	cmp    %cl,%dl
  800d10:	74 16                	je     800d28 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d12:	83 c0 01             	add    $0x1,%eax
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	84 d2                	test   %dl,%dl
  800d1a:	75 f2                	jne    800d0e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d21:	eb 05                	jmp    800d28 <strchr+0x33>
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d28:	5b                   	pop    %ebx
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d35:	0f b6 18             	movzbl (%eax),%ebx
  800d38:	84 db                	test   %bl,%bl
  800d3a:	74 16                	je     800d52 <strfind+0x27>
  800d3c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800d3e:	38 d3                	cmp    %dl,%bl
  800d40:	75 06                	jne    800d48 <strfind+0x1d>
  800d42:	eb 0e                	jmp    800d52 <strfind+0x27>
  800d44:	38 ca                	cmp    %cl,%dl
  800d46:	74 0a                	je     800d52 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d48:	83 c0 01             	add    $0x1,%eax
  800d4b:	0f b6 10             	movzbl (%eax),%edx
  800d4e:	84 d2                	test   %dl,%dl
  800d50:	75 f2                	jne    800d44 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800d52:	5b                   	pop    %ebx
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d61:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d6a:	85 c9                	test   %ecx,%ecx
  800d6c:	74 36                	je     800da4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d74:	75 28                	jne    800d9e <memset+0x49>
  800d76:	f6 c1 03             	test   $0x3,%cl
  800d79:	75 23                	jne    800d9e <memset+0x49>
		c &= 0xFF;
  800d7b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d7f:	89 d3                	mov    %edx,%ebx
  800d81:	c1 e3 08             	shl    $0x8,%ebx
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	c1 e6 18             	shl    $0x18,%esi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	c1 e0 10             	shl    $0x10,%eax
  800d8e:	09 f0                	or     %esi,%eax
  800d90:	09 c2                	or     %eax,%edx
  800d92:	89 d0                	mov    %edx,%eax
  800d94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d99:	fc                   	cld    
  800d9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d9c:	eb 06                	jmp    800da4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da1:	fc                   	cld    
  800da2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800da4:	89 f8                	mov    %edi,%eax
  800da6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800daf:	89 ec                	mov    %ebp,%esp
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 08             	sub    $0x8,%esp
  800db9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dc8:	39 c6                	cmp    %eax,%esi
  800dca:	73 36                	jae    800e02 <memmove+0x4f>
  800dcc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dcf:	39 d0                	cmp    %edx,%eax
  800dd1:	73 2f                	jae    800e02 <memmove+0x4f>
		s += n;
		d += n;
  800dd3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd6:	f6 c2 03             	test   $0x3,%dl
  800dd9:	75 1b                	jne    800df6 <memmove+0x43>
  800ddb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de1:	75 13                	jne    800df6 <memmove+0x43>
  800de3:	f6 c1 03             	test   $0x3,%cl
  800de6:	75 0e                	jne    800df6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800de8:	83 ef 04             	sub    $0x4,%edi
  800deb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dee:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800df1:	fd                   	std    
  800df2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800df4:	eb 09                	jmp    800dff <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800df6:	83 ef 01             	sub    $0x1,%edi
  800df9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dfc:	fd                   	std    
  800dfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dff:	fc                   	cld    
  800e00:	eb 20                	jmp    800e22 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e08:	75 13                	jne    800e1d <memmove+0x6a>
  800e0a:	a8 03                	test   $0x3,%al
  800e0c:	75 0f                	jne    800e1d <memmove+0x6a>
  800e0e:	f6 c1 03             	test   $0x3,%cl
  800e11:	75 0a                	jne    800e1d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e13:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	fc                   	cld    
  800e19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1b:	eb 05                	jmp    800e22 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e1d:	89 c7                	mov    %eax,%edi
  800e1f:	fc                   	cld    
  800e20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e32:	8b 45 10             	mov    0x10(%ebp),%eax
  800e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	e8 68 ff ff ff       	call   800db3 <memmove>
}
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    

00800e4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e59:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	74 36                	je     800e99 <memcmp+0x4c>
		if (*s1 != *s2)
  800e63:	0f b6 03             	movzbl (%ebx),%eax
  800e66:	0f b6 0e             	movzbl (%esi),%ecx
  800e69:	38 c8                	cmp    %cl,%al
  800e6b:	75 17                	jne    800e84 <memcmp+0x37>
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	eb 1a                	jmp    800e8e <memcmp+0x41>
  800e74:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e79:	83 c2 01             	add    $0x1,%edx
  800e7c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e80:	38 c8                	cmp    %cl,%al
  800e82:	74 0a                	je     800e8e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800e84:	0f b6 c0             	movzbl %al,%eax
  800e87:	0f b6 c9             	movzbl %cl,%ecx
  800e8a:	29 c8                	sub    %ecx,%eax
  800e8c:	eb 10                	jmp    800e9e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8e:	39 fa                	cmp    %edi,%edx
  800e90:	75 e2                	jne    800e74 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 05                	jmp    800e9e <memcmp+0x51>
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	53                   	push   %ebx
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eb2:	39 d0                	cmp    %edx,%eax
  800eb4:	73 13                	jae    800ec9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb6:	89 d9                	mov    %ebx,%ecx
  800eb8:	38 18                	cmp    %bl,(%eax)
  800eba:	75 06                	jne    800ec2 <memfind+0x1f>
  800ebc:	eb 0b                	jmp    800ec9 <memfind+0x26>
  800ebe:	38 08                	cmp    %cl,(%eax)
  800ec0:	74 07                	je     800ec9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec2:	83 c0 01             	add    $0x1,%eax
  800ec5:	39 d0                	cmp    %edx,%eax
  800ec7:	75 f5                	jne    800ebe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800edb:	0f b6 02             	movzbl (%edx),%eax
  800ede:	3c 09                	cmp    $0x9,%al
  800ee0:	74 04                	je     800ee6 <strtol+0x1a>
  800ee2:	3c 20                	cmp    $0x20,%al
  800ee4:	75 0e                	jne    800ef4 <strtol+0x28>
		s++;
  800ee6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee9:	0f b6 02             	movzbl (%edx),%eax
  800eec:	3c 09                	cmp    $0x9,%al
  800eee:	74 f6                	je     800ee6 <strtol+0x1a>
  800ef0:	3c 20                	cmp    $0x20,%al
  800ef2:	74 f2                	je     800ee6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef4:	3c 2b                	cmp    $0x2b,%al
  800ef6:	75 0a                	jne    800f02 <strtol+0x36>
		s++;
  800ef8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800efb:	bf 00 00 00 00       	mov    $0x0,%edi
  800f00:	eb 10                	jmp    800f12 <strtol+0x46>
  800f02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f07:	3c 2d                	cmp    $0x2d,%al
  800f09:	75 07                	jne    800f12 <strtol+0x46>
		s++, neg = 1;
  800f0b:	83 c2 01             	add    $0x1,%edx
  800f0e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f12:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f18:	75 15                	jne    800f2f <strtol+0x63>
  800f1a:	80 3a 30             	cmpb   $0x30,(%edx)
  800f1d:	75 10                	jne    800f2f <strtol+0x63>
  800f1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f23:	75 0a                	jne    800f2f <strtol+0x63>
		s += 2, base = 16;
  800f25:	83 c2 02             	add    $0x2,%edx
  800f28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f2d:	eb 10                	jmp    800f3f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f2f:	85 db                	test   %ebx,%ebx
  800f31:	75 0c                	jne    800f3f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f33:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f35:	80 3a 30             	cmpb   $0x30,(%edx)
  800f38:	75 05                	jne    800f3f <strtol+0x73>
		s++, base = 8;
  800f3a:	83 c2 01             	add    $0x1,%edx
  800f3d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f44:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f47:	0f b6 0a             	movzbl (%edx),%ecx
  800f4a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f4d:	89 f3                	mov    %esi,%ebx
  800f4f:	80 fb 09             	cmp    $0x9,%bl
  800f52:	77 08                	ja     800f5c <strtol+0x90>
			dig = *s - '0';
  800f54:	0f be c9             	movsbl %cl,%ecx
  800f57:	83 e9 30             	sub    $0x30,%ecx
  800f5a:	eb 22                	jmp    800f7e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800f5c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f5f:	89 f3                	mov    %esi,%ebx
  800f61:	80 fb 19             	cmp    $0x19,%bl
  800f64:	77 08                	ja     800f6e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800f66:	0f be c9             	movsbl %cl,%ecx
  800f69:	83 e9 57             	sub    $0x57,%ecx
  800f6c:	eb 10                	jmp    800f7e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800f6e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f71:	89 f3                	mov    %esi,%ebx
  800f73:	80 fb 19             	cmp    $0x19,%bl
  800f76:	77 16                	ja     800f8e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800f78:	0f be c9             	movsbl %cl,%ecx
  800f7b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f7e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f81:	7d 0f                	jge    800f92 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800f83:	83 c2 01             	add    $0x1,%edx
  800f86:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800f8a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f8c:	eb b9                	jmp    800f47 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f8e:	89 c1                	mov    %eax,%ecx
  800f90:	eb 02                	jmp    800f94 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f92:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f98:	74 05                	je     800f9f <strtol+0xd3>
		*endptr = (char *) s;
  800f9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f9d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f9f:	89 ca                	mov    %ecx,%edx
  800fa1:	f7 da                	neg    %edx
  800fa3:	85 ff                	test   %edi,%edi
  800fa5:	0f 45 c2             	cmovne %edx,%eax
}
  800fa8:	83 c4 04             	add    $0x4,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <__udivdi3>:
  800fb0:	83 ec 1c             	sub    $0x1c,%esp
  800fb3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800fb7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fbb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fbf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fc3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800fc7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fd1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd5:	89 ea                	mov    %ebp,%edx
  800fd7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fdb:	75 33                	jne    801010 <__udivdi3+0x60>
  800fdd:	39 e9                	cmp    %ebp,%ecx
  800fdf:	77 6f                	ja     801050 <__udivdi3+0xa0>
  800fe1:	85 c9                	test   %ecx,%ecx
  800fe3:	89 ce                	mov    %ecx,%esi
  800fe5:	75 0b                	jne    800ff2 <__udivdi3+0x42>
  800fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fec:	31 d2                	xor    %edx,%edx
  800fee:	f7 f1                	div    %ecx
  800ff0:	89 c6                	mov    %eax,%esi
  800ff2:	31 d2                	xor    %edx,%edx
  800ff4:	89 e8                	mov    %ebp,%eax
  800ff6:	f7 f6                	div    %esi
  800ff8:	89 c5                	mov    %eax,%ebp
  800ffa:	89 f8                	mov    %edi,%eax
  800ffc:	f7 f6                	div    %esi
  800ffe:	89 ea                	mov    %ebp,%edx
  801000:	8b 74 24 10          	mov    0x10(%esp),%esi
  801004:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801008:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80100c:	83 c4 1c             	add    $0x1c,%esp
  80100f:	c3                   	ret    
  801010:	39 e8                	cmp    %ebp,%eax
  801012:	77 24                	ja     801038 <__udivdi3+0x88>
  801014:	0f bd c8             	bsr    %eax,%ecx
  801017:	83 f1 1f             	xor    $0x1f,%ecx
  80101a:	89 0c 24             	mov    %ecx,(%esp)
  80101d:	75 49                	jne    801068 <__udivdi3+0xb8>
  80101f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801023:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801027:	0f 86 ab 00 00 00    	jbe    8010d8 <__udivdi3+0x128>
  80102d:	39 e8                	cmp    %ebp,%eax
  80102f:	0f 82 a3 00 00 00    	jb     8010d8 <__udivdi3+0x128>
  801035:	8d 76 00             	lea    0x0(%esi),%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	31 c0                	xor    %eax,%eax
  80103c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801040:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801044:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801048:	83 c4 1c             	add    $0x1c,%esp
  80104b:	c3                   	ret    
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	89 f8                	mov    %edi,%eax
  801052:	f7 f1                	div    %ecx
  801054:	31 d2                	xor    %edx,%edx
  801056:	8b 74 24 10          	mov    0x10(%esp),%esi
  80105a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80105e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801062:	83 c4 1c             	add    $0x1c,%esp
  801065:	c3                   	ret    
  801066:	66 90                	xchg   %ax,%ax
  801068:	0f b6 0c 24          	movzbl (%esp),%ecx
  80106c:	89 c6                	mov    %eax,%esi
  80106e:	b8 20 00 00 00       	mov    $0x20,%eax
  801073:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801077:	2b 04 24             	sub    (%esp),%eax
  80107a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80107e:	d3 e6                	shl    %cl,%esi
  801080:	89 c1                	mov    %eax,%ecx
  801082:	d3 ed                	shr    %cl,%ebp
  801084:	0f b6 0c 24          	movzbl (%esp),%ecx
  801088:	09 f5                	or     %esi,%ebp
  80108a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80108e:	d3 e6                	shl    %cl,%esi
  801090:	89 c1                	mov    %eax,%ecx
  801092:	89 74 24 04          	mov    %esi,0x4(%esp)
  801096:	89 d6                	mov    %edx,%esi
  801098:	d3 ee                	shr    %cl,%esi
  80109a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80109e:	d3 e2                	shl    %cl,%edx
  8010a0:	89 c1                	mov    %eax,%ecx
  8010a2:	d3 ef                	shr    %cl,%edi
  8010a4:	09 d7                	or     %edx,%edi
  8010a6:	89 f2                	mov    %esi,%edx
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	f7 f5                	div    %ebp
  8010ac:	89 d6                	mov    %edx,%esi
  8010ae:	89 c7                	mov    %eax,%edi
  8010b0:	f7 64 24 04          	mull   0x4(%esp)
  8010b4:	39 d6                	cmp    %edx,%esi
  8010b6:	72 30                	jb     8010e8 <__udivdi3+0x138>
  8010b8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010bc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010c0:	d3 e5                	shl    %cl,%ebp
  8010c2:	39 c5                	cmp    %eax,%ebp
  8010c4:	73 04                	jae    8010ca <__udivdi3+0x11a>
  8010c6:	39 d6                	cmp    %edx,%esi
  8010c8:	74 1e                	je     8010e8 <__udivdi3+0x138>
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	31 d2                	xor    %edx,%edx
  8010ce:	e9 69 ff ff ff       	jmp    80103c <__udivdi3+0x8c>
  8010d3:	90                   	nop
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	31 d2                	xor    %edx,%edx
  8010da:	b8 01 00 00 00       	mov    $0x1,%eax
  8010df:	e9 58 ff ff ff       	jmp    80103c <__udivdi3+0x8c>
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010f9:	83 c4 1c             	add    $0x1c,%esp
  8010fc:	c3                   	ret    
  8010fd:	00 00                	add    %al,(%eax)
	...

00801100 <__umoddi3>:
  801100:	83 ec 2c             	sub    $0x2c,%esp
  801103:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801107:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80110b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80110f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801113:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801117:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80111b:	85 c0                	test   %eax,%eax
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801123:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801127:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80112f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801133:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801137:	75 1f                	jne    801158 <__umoddi3+0x58>
  801139:	39 fe                	cmp    %edi,%esi
  80113b:	76 63                	jbe    8011a0 <__umoddi3+0xa0>
  80113d:	89 c8                	mov    %ecx,%eax
  80113f:	89 fa                	mov    %edi,%edx
  801141:	f7 f6                	div    %esi
  801143:	89 d0                	mov    %edx,%eax
  801145:	31 d2                	xor    %edx,%edx
  801147:	8b 74 24 20          	mov    0x20(%esp),%esi
  80114b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80114f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801153:	83 c4 2c             	add    $0x2c,%esp
  801156:	c3                   	ret    
  801157:	90                   	nop
  801158:	39 f8                	cmp    %edi,%eax
  80115a:	77 64                	ja     8011c0 <__umoddi3+0xc0>
  80115c:	0f bd e8             	bsr    %eax,%ebp
  80115f:	83 f5 1f             	xor    $0x1f,%ebp
  801162:	75 74                	jne    8011d8 <__umoddi3+0xd8>
  801164:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801168:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80116c:	0f 87 0e 01 00 00    	ja     801280 <__umoddi3+0x180>
  801172:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801176:	29 f1                	sub    %esi,%ecx
  801178:	19 c7                	sbb    %eax,%edi
  80117a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80117e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801182:	8b 44 24 14          	mov    0x14(%esp),%eax
  801186:	8b 54 24 18          	mov    0x18(%esp),%edx
  80118a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80118e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801192:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801196:	83 c4 2c             	add    $0x2c,%esp
  801199:	c3                   	ret    
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	85 f6                	test   %esi,%esi
  8011a2:	89 f5                	mov    %esi,%ebp
  8011a4:	75 0b                	jne    8011b1 <__umoddi3+0xb1>
  8011a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	f7 f6                	div    %esi
  8011af:	89 c5                	mov    %eax,%ebp
  8011b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011b5:	31 d2                	xor    %edx,%edx
  8011b7:	f7 f5                	div    %ebp
  8011b9:	89 c8                	mov    %ecx,%eax
  8011bb:	f7 f5                	div    %ebp
  8011bd:	eb 84                	jmp    801143 <__umoddi3+0x43>
  8011bf:	90                   	nop
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 fa                	mov    %edi,%edx
  8011c4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011c8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011cc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011d0:	83 c4 2c             	add    $0x2c,%esp
  8011d3:	c3                   	ret    
  8011d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011dc:	be 20 00 00 00       	mov    $0x20,%esi
  8011e1:	89 e9                	mov    %ebp,%ecx
  8011e3:	29 ee                	sub    %ebp,%esi
  8011e5:	d3 e2                	shl    %cl,%edx
  8011e7:	89 f1                	mov    %esi,%ecx
  8011e9:	d3 e8                	shr    %cl,%eax
  8011eb:	89 e9                	mov    %ebp,%ecx
  8011ed:	09 d0                	or     %edx,%eax
  8011ef:	89 fa                	mov    %edi,%edx
  8011f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011f9:	d3 e0                	shl    %cl,%eax
  8011fb:	89 f1                	mov    %esi,%ecx
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801205:	d3 ea                	shr    %cl,%edx
  801207:	89 e9                	mov    %ebp,%ecx
  801209:	d3 e7                	shl    %cl,%edi
  80120b:	89 f1                	mov    %esi,%ecx
  80120d:	d3 e8                	shr    %cl,%eax
  80120f:	89 e9                	mov    %ebp,%ecx
  801211:	09 f8                	or     %edi,%eax
  801213:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801217:	f7 74 24 0c          	divl   0xc(%esp)
  80121b:	d3 e7                	shl    %cl,%edi
  80121d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801221:	89 d7                	mov    %edx,%edi
  801223:	f7 64 24 10          	mull   0x10(%esp)
  801227:	39 d7                	cmp    %edx,%edi
  801229:	89 c1                	mov    %eax,%ecx
  80122b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80122f:	72 3b                	jb     80126c <__umoddi3+0x16c>
  801231:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801235:	72 31                	jb     801268 <__umoddi3+0x168>
  801237:	8b 44 24 18          	mov    0x18(%esp),%eax
  80123b:	29 c8                	sub    %ecx,%eax
  80123d:	19 d7                	sbb    %edx,%edi
  80123f:	89 e9                	mov    %ebp,%ecx
  801241:	89 fa                	mov    %edi,%edx
  801243:	d3 e8                	shr    %cl,%eax
  801245:	89 f1                	mov    %esi,%ecx
  801247:	d3 e2                	shl    %cl,%edx
  801249:	89 e9                	mov    %ebp,%ecx
  80124b:	09 d0                	or     %edx,%eax
  80124d:	89 fa                	mov    %edi,%edx
  80124f:	d3 ea                	shr    %cl,%edx
  801251:	8b 74 24 20          	mov    0x20(%esp),%esi
  801255:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801259:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80125d:	83 c4 2c             	add    $0x2c,%esp
  801260:	c3                   	ret    
  801261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 d7                	cmp    %edx,%edi
  80126a:	75 cb                	jne    801237 <__umoddi3+0x137>
  80126c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801270:	89 c1                	mov    %eax,%ecx
  801272:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801276:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80127a:	eb bb                	jmp    801237 <__umoddi3+0x137>
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801284:	0f 82 e8 fe ff ff    	jb     801172 <__umoddi3+0x72>
  80128a:	e9 f3 fe ff ff       	jmp    801182 <__umoddi3+0x82>
