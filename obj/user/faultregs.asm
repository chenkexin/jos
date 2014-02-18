
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c6                	mov    %eax,%esi
  80003f:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 51 18 80 	movl   $0x801851,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 20 18 80 00 	movl   $0x801820,(%esp)
  80005b:	e8 97 06 00 00       	call   8006f7 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 03                	mov    (%ebx),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 06                	mov    (%esi),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 30 18 80 	movl   $0x801830,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  80007b:	e8 77 06 00 00       	call   8006f7 <cprintf>
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	39 06                	cmp    %eax,(%esi)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  80008d:	e8 65 06 00 00       	call   8006f7 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  8000a0:	e8 52 06 00 00       	call   8006f7 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 46 04             	mov    0x4(%esi),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 52 18 80 	movl   $0x801852,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  8000c7:	e8 2b 06 00 00       	call   8006f7 <cprintf>
  8000cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8000cf:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  8000db:	e8 17 06 00 00       	call   8006f7 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  8000e9:	e8 09 06 00 00       	call   8006f7 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 46 08             	mov    0x8(%esi),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 56 18 80 	movl   $0x801856,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  800110:	e8 e2 05 00 00       	call   8006f7 <cprintf>
  800115:	8b 43 08             	mov    0x8(%ebx),%eax
  800118:	39 46 08             	cmp    %eax,0x8(%esi)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  800124:	e8 ce 05 00 00       	call   8006f7 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800132:	e8 c0 05 00 00       	call   8006f7 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 43 10             	mov    0x10(%ebx),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 46 10             	mov    0x10(%esi),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 5a 18 80 	movl   $0x80185a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  800159:	e8 99 05 00 00       	call   8006f7 <cprintf>
  80015e:	8b 43 10             	mov    0x10(%ebx),%eax
  800161:	39 46 10             	cmp    %eax,0x10(%esi)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  80016d:	e8 85 05 00 00       	call   8006f7 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  80017b:	e8 77 05 00 00       	call   8006f7 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 43 14             	mov    0x14(%ebx),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 46 14             	mov    0x14(%esi),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 5e 18 80 	movl   $0x80185e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  8001a2:	e8 50 05 00 00       	call   8006f7 <cprintf>
  8001a7:	8b 43 14             	mov    0x14(%ebx),%eax
  8001aa:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  8001b6:	e8 3c 05 00 00       	call   8006f7 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  8001c4:	e8 2e 05 00 00       	call   8006f7 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 46 18             	mov    0x18(%esi),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 62 18 80 	movl   $0x801862,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  8001eb:	e8 07 05 00 00       	call   8006f7 <cprintf>
  8001f0:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f3:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  8001ff:	e8 f3 04 00 00       	call   8006f7 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  80020d:	e8 e5 04 00 00       	call   8006f7 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 46 1c             	mov    0x1c(%esi),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 66 18 80 	movl   $0x801866,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  800234:	e8 be 04 00 00       	call   8006f7 <cprintf>
  800239:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023c:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  800248:	e8 aa 04 00 00       	call   8006f7 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800256:	e8 9c 04 00 00       	call   8006f7 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 43 20             	mov    0x20(%ebx),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 46 20             	mov    0x20(%esi),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 6a 18 80 	movl   $0x80186a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  80027d:	e8 75 04 00 00       	call   8006f7 <cprintf>
  800282:	8b 43 20             	mov    0x20(%ebx),%eax
  800285:	39 46 20             	cmp    %eax,0x20(%esi)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  800291:	e8 61 04 00 00       	call   8006f7 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  80029f:	e8 53 04 00 00       	call   8006f7 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 46 24             	mov    0x24(%esi),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 6e 18 80 	movl   $0x80186e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  8002c6:	e8 2c 04 00 00       	call   8006f7 <cprintf>
  8002cb:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ce:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  8002da:	e8 18 04 00 00       	call   8006f7 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  8002e8:	e8 0a 04 00 00       	call   8006f7 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 46 28             	mov    0x28(%esi),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 75 18 80 	movl   $0x801875,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  80030f:	e8 e3 03 00 00       	call   8006f7 <cprintf>
  800314:	8b 43 28             	mov    0x28(%ebx),%eax
  800317:	39 46 28             	cmp    %eax,0x28(%esi)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  800323:	e8 cf 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 79 18 80 00 	movl   $0x801879,(%esp)
  800336:	e8 bc 03 00 00       	call   8006f7 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800348:	e8 aa 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 79 18 80 00 	movl   $0x801879,(%esp)
  80035b:	e8 97 03 00 00       	call   8006f7 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 44 18 80 00 	movl   $0x801844,(%esp)
  800369:	e8 89 03 00 00       	call   8006f7 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800377:	e8 7b 03 00 00       	call   8006f7 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 e0 18 80 	movl   $0x8018e0,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 87 18 80 00 	movl   $0x801887,(%esp)
  8003b9:	e8 3e 02 00 00       	call   8005fc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 a0 20 80 00    	mov    %edx,0x8020a0
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 a4 20 80 00    	mov    %edx,0x8020a4
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 a8 20 80 00    	mov    %edx,0x8020a8
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 ac 20 80 00    	mov    %edx,0x8020ac
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 b0 20 80 00    	mov    %edx,0x8020b0
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 b8 20 80 00    	mov    %edx,0x8020b8
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 bc 20 80 00    	mov    %edx,0x8020bc
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 c0 20 80 00    	mov    %edx,0x8020c0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 9f 18 80 	movl   $0x80189f,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 ad 18 80 00 	movl   $0x8018ad,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba 98 18 80 00       	mov    $0x801898,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 3d 0e 00 00       	call   80129c <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 b4 18 80 	movl   $0x8018b4,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 87 18 80 00 	movl   $0x801887,(%esp)
  80047e:	e8 79 01 00 00       	call   8005fc <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 6d 10 00 00       	call   801504 <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 44 20 80 00       	mov    %eax,0x802044
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 40 20 80 00       	mov    %eax,0x802040
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004b8:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004be:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c4:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004ca:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004db:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004f1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004f7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004fd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800503:	89 15 74 20 80 00    	mov    %edx,0x802074
  800509:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80050f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800514:	89 25 88 20 80 00    	mov    %esp,0x802088
  80051a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  800520:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800526:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80052c:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800532:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800538:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80053e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800543:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 84 20 80 00       	mov    %eax,0x802084
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 14 19 80 00 	movl   $0x801914,(%esp)
  800562:	e8 90 01 00 00       	call   8006f7 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 c7 18 80 	movl   $0x8018c7,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 d8 18 80 00 	movl   $0x8018d8,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba 98 18 80 00       	mov    $0x801898,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
	...

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8005aa:	e8 8d 0c 00 00       	call   80123c <sys_getenvid>
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 db                	test   %ebx,%ebx
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 06                	mov    (%esi),%eax
  8005c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d0:	89 1c 24             	mov    %ebx,(%esp)
  8005d3:	e8 ad fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
	...

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f5:	e8 e5 0b 00 00       	call   8011df <sys_env_destroy>
}
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800607:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80060d:	e8 2a 0c 00 00       	call   80123c <sys_getenvid>
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
  800615:	89 54 24 10          	mov    %edx,0x10(%esp)
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	89 74 24 08          	mov    %esi,0x8(%esp)
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  80062f:	e8 c3 00 00 00       	call   8006f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 53 00 00 00       	call   800696 <vcprintf>
	cprintf("\n");
  800643:	c7 04 24 50 18 80 00 	movl   $0x801850,(%esp)
  80064a:	e8 a8 00 00 00       	call   8006f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064f:	cc                   	int3   
  800650:	eb fd                	jmp    80064f <_panic+0x53>
	...

00800654 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	83 ec 14             	sub    $0x14,%esp
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065e:	8b 03                	mov    (%ebx),%eax
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800667:	83 c0 01             	add    $0x1,%eax
  80066a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80066c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800671:	75 19                	jne    80068c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800673:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80067a:	00 
  80067b:	8d 43 08             	lea    0x8(%ebx),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 fa 0a 00 00       	call   801180 <sys_cputs>
		b->idx = 0;
  800686:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800690:	83 c4 14             	add    $0x14,%esp
  800693:	5b                   	pop    %ebx
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a6:	00 00 00 
	b.cnt = 0;
  8006a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 54 06 80 00 	movl   $0x800654,(%esp)
  8006d2:	e8 bb 01 00 00       	call   800892 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 91 0a 00 00       	call   801180 <sys_cputs>

	return b.cnt;
}
  8006ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 87 ff ff ff       	call   800696 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
	...

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 4c             	sub    $0x4c,%esp
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	89 d7                	mov    %edx,%edi
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800731:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800737:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	39 d8                	cmp    %ebx,%eax
  800741:	72 17                	jb     80075a <printnum+0x3a>
  800743:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800746:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800749:	76 0f                	jbe    80075a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074b:	8b 75 14             	mov    0x14(%ebp),%esi
  80074e:	83 ee 01             	sub    $0x1,%esi
  800751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800754:	85 f6                	test   %esi,%esi
  800756:	7f 63                	jg     8007bb <printnum+0x9b>
  800758:	eb 75                	jmp    8007cf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80075d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	83 e8 01             	sub    $0x1,%eax
  800767:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80076e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800772:	8b 44 24 08          	mov    0x8(%esp),%eax
  800776:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80077a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800780:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800787:	00 
  800788:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80078b:	89 1c 24             	mov    %ebx,(%esp)
  80078e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800795:	e8 a6 0d 00 00       	call   801540 <__udivdi3>
  80079a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80079d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007af:	89 fa                	mov    %edi,%edx
  8007b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007b4:	e8 67 ff ff ff       	call   800720 <printnum>
  8007b9:	eb 14                	jmp    8007cf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c7:	83 ee 01             	sub    $0x1,%esi
  8007ca:	75 ef                	jne    8007bb <printnum+0x9b>
  8007cc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007e5:	00 
  8007e6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e9:	89 1c 24             	mov    %ebx,(%esp)
  8007ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	e8 98 0e 00 00       	call   801690 <__umoddi3>
  8007f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fc:	0f be 80 63 19 80 00 	movsbl 0x801963(%eax),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800809:	ff d0                	call   *%eax
}
  80080b:	83 c4 4c             	add    $0x4c,%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5f                   	pop    %edi
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800816:	83 fa 01             	cmp    $0x1,%edx
  800819:	7e 0e                	jle    800829 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800820:	89 08                	mov    %ecx,(%eax)
  800822:	8b 02                	mov    (%edx),%eax
  800824:	8b 52 04             	mov    0x4(%edx),%edx
  800827:	eb 22                	jmp    80084b <getuint+0x38>
	else if (lflag)
  800829:	85 d2                	test   %edx,%edx
  80082b:	74 10                	je     80083d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800832:	89 08                	mov    %ecx,(%eax)
  800834:	8b 02                	mov    (%edx),%eax
  800836:	ba 00 00 00 00       	mov    $0x0,%edx
  80083b:	eb 0e                	jmp    80084b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800842:	89 08                	mov    %ecx,(%eax)
  800844:	8b 02                	mov    (%edx),%eax
  800846:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800853:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800857:	8b 10                	mov    (%eax),%edx
  800859:	3b 50 04             	cmp    0x4(%eax),%edx
  80085c:	73 0a                	jae    800868 <sprintputch+0x1b>
		*b->buf++ = ch;
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	88 0a                	mov    %cl,(%edx)
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	89 10                	mov    %edx,(%eax)
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800870:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800877:	8b 45 10             	mov    0x10(%ebp),%eax
  80087a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 02 00 00 00       	call   800892 <vprintfmt>
	va_end(ap);
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 4c             	sub    $0x4c,%esp
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008a4:	eb 11                	jmp    8008b7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	0f 84 db 03 00 00    	je     800c89 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8008ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b7:	0f b6 07             	movzbl (%edi),%eax
  8008ba:	83 c7 01             	add    $0x1,%edi
  8008bd:	83 f8 25             	cmp    $0x25,%eax
  8008c0:	75 e4                	jne    8008a6 <vprintfmt+0x14>
  8008c2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8008c6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008cd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008db:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e0:	eb 2b                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008e5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8008e9:	eb 22                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008ee:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8008f2:	eb 19                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8008f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008fe:	eb 0d                	jmp    80090d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800900:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800903:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800906:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	0f b6 0f             	movzbl (%edi),%ecx
  800910:	8d 47 01             	lea    0x1(%edi),%eax
  800913:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800916:	0f b6 07             	movzbl (%edi),%eax
  800919:	83 e8 23             	sub    $0x23,%eax
  80091c:	3c 55                	cmp    $0x55,%al
  80091e:	0f 87 40 03 00 00    	ja     800c64 <vprintfmt+0x3d2>
  800924:	0f b6 c0             	movzbl %al,%eax
  800927:	ff 24 85 20 1a 80 00 	jmp    *0x801a20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80092e:	83 e9 30             	sub    $0x30,%ecx
  800931:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800934:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800938:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80093b:	83 f9 09             	cmp    $0x9,%ecx
  80093e:	77 57                	ja     800997 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800943:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800946:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800949:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80094c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80094f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800953:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800956:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800959:	83 f9 09             	cmp    $0x9,%ecx
  80095c:	76 eb                	jbe    800949 <vprintfmt+0xb7>
  80095e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800961:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800964:	eb 34                	jmp    80099a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 48 04             	lea    0x4(%eax),%ecx
  80096c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800974:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800977:	eb 21                	jmp    80099a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800979:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80097d:	0f 88 71 ff ff ff    	js     8008f4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800986:	eb 85                	jmp    80090d <vprintfmt+0x7b>
  800988:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80098b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800992:	e9 76 ff ff ff       	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800997:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80099a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80099e:	0f 89 69 ff ff ff    	jns    80090d <vprintfmt+0x7b>
  8009a4:	e9 57 ff ff ff       	jmp    800900 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009af:	e9 59 ff ff ff       	jmp    80090d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c1:	8b 00                	mov    (%eax),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009cb:	e9 e7 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 04             	lea    0x4(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 00                	mov    (%eax),%eax
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	c1 fa 1f             	sar    $0x1f,%edx
  8009e0:	31 d0                	xor    %edx,%eax
  8009e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009e4:	83 f8 08             	cmp    $0x8,%eax
  8009e7:	7f 0b                	jg     8009f4 <vprintfmt+0x162>
  8009e9:	8b 14 85 80 1b 80 00 	mov    0x801b80(,%eax,4),%edx
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	75 20                	jne    800a14 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8009f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f8:	c7 44 24 08 7b 19 80 	movl   $0x80197b,0x8(%esp)
  8009ff:	00 
  800a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a04:	89 34 24             	mov    %esi,(%esp)
  800a07:	e8 5e fe ff ff       	call   80086a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a0f:	e9 a3 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800a14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a18:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800a1f:	00 
  800a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a24:	89 34 24             	mov    %esi,(%esp)
  800a27:	e8 3e fe ff ff       	call   80086a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a2f:	e9 83 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>
  800a34:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a37:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a3a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a40:	8d 50 04             	lea    0x4(%eax),%edx
  800a43:	89 55 14             	mov    %edx,0x14(%ebp)
  800a46:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a48:	85 ff                	test   %edi,%edi
  800a4a:	b8 74 19 80 00       	mov    $0x801974,%eax
  800a4f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a52:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800a56:	74 06                	je     800a5e <vprintfmt+0x1cc>
  800a58:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a5c:	7f 16                	jg     800a74 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5e:	0f b6 17             	movzbl (%edi),%edx
  800a61:	0f be c2             	movsbl %dl,%eax
  800a64:	83 c7 01             	add    $0x1,%edi
  800a67:	85 c0                	test   %eax,%eax
  800a69:	0f 85 9f 00 00 00    	jne    800b0e <vprintfmt+0x27c>
  800a6f:	e9 8b 00 00 00       	jmp    800aff <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a78:	89 3c 24             	mov    %edi,(%esp)
  800a7b:	e8 c2 02 00 00       	call   800d42 <strnlen>
  800a80:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a83:	29 c2                	sub    %eax,%edx
  800a85:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a88:	85 d2                	test   %edx,%edx
  800a8a:	7e d2                	jle    800a5e <vprintfmt+0x1cc>
					putch(padc, putdat);
  800a8c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800a90:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800a93:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aa4:	83 ef 01             	sub    $0x1,%edi
  800aa7:	75 ef                	jne    800a98 <vprintfmt+0x206>
  800aa9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800aaf:	eb ad                	jmp    800a5e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ab1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800ab5:	74 20                	je     800ad7 <vprintfmt+0x245>
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 20             	sub    $0x20,%edx
  800abd:	83 fa 5e             	cmp    $0x5e,%edx
  800ac0:	76 15                	jbe    800ad7 <vprintfmt+0x245>
					putch('?', putdat);
  800ac2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ad0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ad3:	ff d1                	call   *%ecx
  800ad5:	eb 0f                	jmp    800ae6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800ad7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ada:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ade:	89 04 24             	mov    %eax,(%esp)
  800ae1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ae4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae6:	83 eb 01             	sub    $0x1,%ebx
  800ae9:	0f b6 17             	movzbl (%edi),%edx
  800aec:	0f be c2             	movsbl %dl,%eax
  800aef:	83 c7 01             	add    $0x1,%edi
  800af2:	85 c0                	test   %eax,%eax
  800af4:	75 24                	jne    800b1a <vprintfmt+0x288>
  800af6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800af9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800afc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aff:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b06:	0f 8e ab fd ff ff    	jle    8008b7 <vprintfmt+0x25>
  800b0c:	eb 20                	jmp    800b2e <vprintfmt+0x29c>
  800b0e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800b11:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b14:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800b17:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1a:	85 f6                	test   %esi,%esi
  800b1c:	78 93                	js     800ab1 <vprintfmt+0x21f>
  800b1e:	83 ee 01             	sub    $0x1,%esi
  800b21:	79 8e                	jns    800ab1 <vprintfmt+0x21f>
  800b23:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b26:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b29:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b2c:	eb d1                	jmp    800aff <vprintfmt+0x26d>
  800b2e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b35:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b3c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b3e:	83 ef 01             	sub    $0x1,%edi
  800b41:	75 ee                	jne    800b31 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b43:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b46:	e9 6c fd ff ff       	jmp    8008b7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b4b:	83 fa 01             	cmp    $0x1,%edx
  800b4e:	66 90                	xchg   %ax,%ax
  800b50:	7e 16                	jle    800b68 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800b52:	8b 45 14             	mov    0x14(%ebp),%eax
  800b55:	8d 50 08             	lea    0x8(%eax),%edx
  800b58:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5b:	8b 10                	mov    (%eax),%edx
  800b5d:	8b 48 04             	mov    0x4(%eax),%ecx
  800b60:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b63:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b66:	eb 32                	jmp    800b9a <vprintfmt+0x308>
	else if (lflag)
  800b68:	85 d2                	test   %edx,%edx
  800b6a:	74 18                	je     800b84 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8d 50 04             	lea    0x4(%eax),%edx
  800b72:	89 55 14             	mov    %edx,0x14(%ebp)
  800b75:	8b 00                	mov    (%eax),%eax
  800b77:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b7a:	89 c1                	mov    %eax,%ecx
  800b7c:	c1 f9 1f             	sar    $0x1f,%ecx
  800b7f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b82:	eb 16                	jmp    800b9a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800b84:	8b 45 14             	mov    0x14(%ebp),%eax
  800b87:	8d 50 04             	lea    0x4(%eax),%edx
  800b8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8d:	8b 00                	mov    (%eax),%eax
  800b8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	c1 ff 1f             	sar    $0x1f,%edi
  800b97:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ba0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ba5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ba9:	79 7d                	jns    800c28 <vprintfmt+0x396>
				putch('-', putdat);
  800bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800baf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bb6:	ff d6                	call   *%esi
				num = -(long long) num;
  800bb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800bbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bbe:	f7 d8                	neg    %eax
  800bc0:	83 d2 00             	adc    $0x0,%edx
  800bc3:	f7 da                	neg    %edx
			}
			base = 10;
  800bc5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bca:	eb 5c                	jmp    800c28 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bcc:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcf:	e8 3f fc ff ff       	call   800813 <getuint>
			base = 10;
  800bd4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bd9:	eb 4d                	jmp    800c28 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
  800bdb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bde:	e8 30 fc ff ff       	call   800813 <getuint>
      base = 8;
  800be3:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800be8:	eb 3e                	jmp    800c28 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bf5:	ff d6                	call   *%esi
			putch('x', putdat);
  800bf7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bfb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c02:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	8d 50 04             	lea    0x4(%eax),%edx
  800c0a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c0d:	8b 00                	mov    (%eax),%eax
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c19:	eb 0d                	jmp    800c28 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1e:	e8 f0 fb ff ff       	call   800813 <getuint>
			base = 16;
  800c23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c28:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800c2c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800c30:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800c33:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c42:	89 da                	mov    %ebx,%edx
  800c44:	89 f0                	mov    %esi,%eax
  800c46:	e8 d5 fa ff ff       	call   800720 <printnum>
			break;
  800c4b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800c4e:	e9 64 fc ff ff       	jmp    8008b7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c57:	89 0c 24             	mov    %ecx,(%esp)
  800c5a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c5f:	e9 53 fc ff ff       	jmp    8008b7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c68:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c6f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c71:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c75:	0f 84 3c fc ff ff    	je     8008b7 <vprintfmt+0x25>
  800c7b:	83 ef 01             	sub    $0x1,%edi
  800c7e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c82:	75 f7                	jne    800c7b <vprintfmt+0x3e9>
  800c84:	e9 2e fc ff ff       	jmp    8008b7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c89:	83 c4 4c             	add    $0x4c,%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 28             	sub    $0x28,%esp
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cae:	85 d2                	test   %edx,%edx
  800cb0:	7e 30                	jle    800ce2 <vsnprintf+0x51>
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	74 2c                	je     800ce2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccb:	c7 04 24 4d 08 80 00 	movl   $0x80084d,(%esp)
  800cd2:	e8 bb fb ff ff       	call   800892 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cda:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce0:	eb 05                	jmp    800ce7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ce2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	89 04 24             	mov    %eax,(%esp)
  800d0a:	e8 82 ff ff ff       	call   800c91 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    
	...

00800d20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d26:	80 3a 00             	cmpb   $0x0,(%edx)
  800d29:	74 10                	je     800d3b <strlen+0x1b>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d37:	75 f7                	jne    800d30 <strlen+0x10>
  800d39:	eb 05                	jmp    800d40 <strlen+0x20>
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	53                   	push   %ebx
  800d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4c:	85 c9                	test   %ecx,%ecx
  800d4e:	74 1c                	je     800d6c <strnlen+0x2a>
  800d50:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d53:	74 1e                	je     800d73 <strnlen+0x31>
  800d55:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d5a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5c:	39 ca                	cmp    %ecx,%edx
  800d5e:	74 18                	je     800d78 <strnlen+0x36>
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d68:	75 f0                	jne    800d5a <strnlen+0x18>
  800d6a:	eb 0c                	jmp    800d78 <strnlen+0x36>
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 05                	jmp    800d78 <strnlen+0x36>
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	53                   	push   %ebx
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	0f b6 19             	movzbl (%ecx),%ebx
  800d8a:	88 1a                	mov    %bl,(%edx)
  800d8c:	83 c2 01             	add    $0x1,%edx
  800d8f:	83 c1 01             	add    $0x1,%ecx
  800d92:	84 db                	test   %bl,%bl
  800d94:	75 f1                	jne    800d87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d96:	5b                   	pop    %ebx
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 08             	sub    $0x8,%esp
  800da0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800da3:	89 1c 24             	mov    %ebx,(%esp)
  800da6:	e8 75 ff ff ff       	call   800d20 <strlen>
	strcpy(dst + len, src);
  800dab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800db2:	01 d8                	add    %ebx,%eax
  800db4:	89 04 24             	mov    %eax,(%esp)
  800db7:	e8 bf ff ff ff       	call   800d7b <strcpy>
	return dst;
}
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	83 c4 08             	add    $0x8,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd2:	85 db                	test   %ebx,%ebx
  800dd4:	74 16                	je     800dec <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd6:	01 f3                	add    %esi,%ebx
  800dd8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800dda:	0f b6 02             	movzbl (%edx),%eax
  800ddd:	88 01                	mov    %al,(%ecx)
  800ddf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800de2:	80 3a 01             	cmpb   $0x1,(%edx)
  800de5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de8:	39 d9                	cmp    %ebx,%ecx
  800dea:	75 ee                	jne    800dda <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dfe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e01:	89 f8                	mov    %edi,%eax
  800e03:	85 f6                	test   %esi,%esi
  800e05:	74 33                	je     800e3a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800e07:	83 fe 01             	cmp    $0x1,%esi
  800e0a:	74 25                	je     800e31 <strlcpy+0x3f>
  800e0c:	0f b6 0b             	movzbl (%ebx),%ecx
  800e0f:	84 c9                	test   %cl,%cl
  800e11:	74 22                	je     800e35 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800e13:	83 ee 02             	sub    $0x2,%esi
  800e16:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e1b:	88 08                	mov    %cl,(%eax)
  800e1d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e20:	39 f2                	cmp    %esi,%edx
  800e22:	74 13                	je     800e37 <strlcpy+0x45>
  800e24:	83 c2 01             	add    $0x1,%edx
  800e27:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e2b:	84 c9                	test   %cl,%cl
  800e2d:	75 ec                	jne    800e1b <strlcpy+0x29>
  800e2f:	eb 06                	jmp    800e37 <strlcpy+0x45>
  800e31:	89 f8                	mov    %edi,%eax
  800e33:	eb 02                	jmp    800e37 <strlcpy+0x45>
  800e35:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e37:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e3a:	29 f8                	sub    %edi,%eax
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e47:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e4a:	0f b6 01             	movzbl (%ecx),%eax
  800e4d:	84 c0                	test   %al,%al
  800e4f:	74 15                	je     800e66 <strcmp+0x25>
  800e51:	3a 02                	cmp    (%edx),%al
  800e53:	75 11                	jne    800e66 <strcmp+0x25>
		p++, q++;
  800e55:	83 c1 01             	add    $0x1,%ecx
  800e58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e5b:	0f b6 01             	movzbl (%ecx),%eax
  800e5e:	84 c0                	test   %al,%al
  800e60:	74 04                	je     800e66 <strcmp+0x25>
  800e62:	3a 02                	cmp    (%edx),%al
  800e64:	74 ef                	je     800e55 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e66:	0f b6 c0             	movzbl %al,%eax
  800e69:	0f b6 12             	movzbl (%edx),%edx
  800e6c:	29 d0                	sub    %edx,%eax
}
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e7e:	85 f6                	test   %esi,%esi
  800e80:	74 29                	je     800eab <strncmp+0x3b>
  800e82:	0f b6 03             	movzbl (%ebx),%eax
  800e85:	84 c0                	test   %al,%al
  800e87:	74 30                	je     800eb9 <strncmp+0x49>
  800e89:	3a 02                	cmp    (%edx),%al
  800e8b:	75 2c                	jne    800eb9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800e8d:	8d 43 01             	lea    0x1(%ebx),%eax
  800e90:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e97:	39 f0                	cmp    %esi,%eax
  800e99:	74 17                	je     800eb2 <strncmp+0x42>
  800e9b:	0f b6 08             	movzbl (%eax),%ecx
  800e9e:	84 c9                	test   %cl,%cl
  800ea0:	74 17                	je     800eb9 <strncmp+0x49>
  800ea2:	83 c0 01             	add    $0x1,%eax
  800ea5:	3a 0a                	cmp    (%edx),%cl
  800ea7:	74 e9                	je     800e92 <strncmp+0x22>
  800ea9:	eb 0e                	jmp    800eb9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 0f                	jmp    800ec1 <strncmp+0x51>
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 08                	jmp    800ec1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb9:	0f b6 03             	movzbl (%ebx),%eax
  800ebc:	0f b6 12             	movzbl (%edx),%edx
  800ebf:	29 d0                	sub    %edx,%eax
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	53                   	push   %ebx
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ecf:	0f b6 18             	movzbl (%eax),%ebx
  800ed2:	84 db                	test   %bl,%bl
  800ed4:	74 1d                	je     800ef3 <strchr+0x2e>
  800ed6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ed8:	38 d3                	cmp    %dl,%bl
  800eda:	75 06                	jne    800ee2 <strchr+0x1d>
  800edc:	eb 1a                	jmp    800ef8 <strchr+0x33>
  800ede:	38 ca                	cmp    %cl,%dl
  800ee0:	74 16                	je     800ef8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ee2:	83 c0 01             	add    $0x1,%eax
  800ee5:	0f b6 10             	movzbl (%eax),%edx
  800ee8:	84 d2                	test   %dl,%dl
  800eea:	75 f2                	jne    800ede <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 05                	jmp    800ef8 <strchr+0x33>
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef8:	5b                   	pop    %ebx
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f05:	0f b6 18             	movzbl (%eax),%ebx
  800f08:	84 db                	test   %bl,%bl
  800f0a:	74 16                	je     800f22 <strfind+0x27>
  800f0c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800f0e:	38 d3                	cmp    %dl,%bl
  800f10:	75 06                	jne    800f18 <strfind+0x1d>
  800f12:	eb 0e                	jmp    800f22 <strfind+0x27>
  800f14:	38 ca                	cmp    %cl,%dl
  800f16:	74 0a                	je     800f22 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f18:	83 c0 01             	add    $0x1,%eax
  800f1b:	0f b6 10             	movzbl (%eax),%edx
  800f1e:	84 d2                	test   %dl,%dl
  800f20:	75 f2                	jne    800f14 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800f22:	5b                   	pop    %ebx
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f31:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f3a:	85 c9                	test   %ecx,%ecx
  800f3c:	74 36                	je     800f74 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f44:	75 28                	jne    800f6e <memset+0x49>
  800f46:	f6 c1 03             	test   $0x3,%cl
  800f49:	75 23                	jne    800f6e <memset+0x49>
		c &= 0xFF;
  800f4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f4f:	89 d3                	mov    %edx,%ebx
  800f51:	c1 e3 08             	shl    $0x8,%ebx
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	c1 e6 18             	shl    $0x18,%esi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	c1 e0 10             	shl    $0x10,%eax
  800f5e:	09 f0                	or     %esi,%eax
  800f60:	09 c2                	or     %eax,%edx
  800f62:	89 d0                	mov    %edx,%eax
  800f64:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f66:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f69:	fc                   	cld    
  800f6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800f6c:	eb 06                	jmp    800f74 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	fc                   	cld    
  800f72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f98:	39 c6                	cmp    %eax,%esi
  800f9a:	73 36                	jae    800fd2 <memmove+0x4f>
  800f9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f9f:	39 d0                	cmp    %edx,%eax
  800fa1:	73 2f                	jae    800fd2 <memmove+0x4f>
		s += n;
		d += n;
  800fa3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa6:	f6 c2 03             	test   $0x3,%dl
  800fa9:	75 1b                	jne    800fc6 <memmove+0x43>
  800fab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fb1:	75 13                	jne    800fc6 <memmove+0x43>
  800fb3:	f6 c1 03             	test   $0x3,%cl
  800fb6:	75 0e                	jne    800fc6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fb8:	83 ef 04             	sub    $0x4,%edi
  800fbb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fbe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800fc1:	fd                   	std    
  800fc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc4:	eb 09                	jmp    800fcf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fc6:	83 ef 01             	sub    $0x1,%edi
  800fc9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fcc:	fd                   	std    
  800fcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fcf:	fc                   	cld    
  800fd0:	eb 20                	jmp    800ff2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fd2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fd8:	75 13                	jne    800fed <memmove+0x6a>
  800fda:	a8 03                	test   $0x3,%al
  800fdc:	75 0f                	jne    800fed <memmove+0x6a>
  800fde:	f6 c1 03             	test   $0x3,%cl
  800fe1:	75 0a                	jne    800fed <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fe3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fe6:	89 c7                	mov    %eax,%edi
  800fe8:	fc                   	cld    
  800fe9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800feb:	eb 05                	jmp    800ff2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	fc                   	cld    
  800ff0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801002:	8b 45 10             	mov    0x10(%ebp),%eax
  801005:	89 44 24 08          	mov    %eax,0x8(%esp)
  801009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	89 04 24             	mov    %eax,(%esp)
  801016:	e8 68 ff ff ff       	call   800f83 <memmove>
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801026:	8b 75 0c             	mov    0xc(%ebp),%esi
  801029:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80102f:	85 c0                	test   %eax,%eax
  801031:	74 36                	je     801069 <memcmp+0x4c>
		if (*s1 != *s2)
  801033:	0f b6 03             	movzbl (%ebx),%eax
  801036:	0f b6 0e             	movzbl (%esi),%ecx
  801039:	38 c8                	cmp    %cl,%al
  80103b:	75 17                	jne    801054 <memcmp+0x37>
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	eb 1a                	jmp    80105e <memcmp+0x41>
  801044:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801049:	83 c2 01             	add    $0x1,%edx
  80104c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801050:	38 c8                	cmp    %cl,%al
  801052:	74 0a                	je     80105e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801054:	0f b6 c0             	movzbl %al,%eax
  801057:	0f b6 c9             	movzbl %cl,%ecx
  80105a:	29 c8                	sub    %ecx,%eax
  80105c:	eb 10                	jmp    80106e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80105e:	39 fa                	cmp    %edi,%edx
  801060:	75 e2                	jne    801044 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	eb 05                	jmp    80106e <memcmp+0x51>
  801069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801082:	39 d0                	cmp    %edx,%eax
  801084:	73 13                	jae    801099 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801086:	89 d9                	mov    %ebx,%ecx
  801088:	38 18                	cmp    %bl,(%eax)
  80108a:	75 06                	jne    801092 <memfind+0x1f>
  80108c:	eb 0b                	jmp    801099 <memfind+0x26>
  80108e:	38 08                	cmp    %cl,(%eax)
  801090:	74 07                	je     801099 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801092:	83 c0 01             	add    $0x1,%eax
  801095:	39 d0                	cmp    %edx,%eax
  801097:	75 f5                	jne    80108e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801099:	5b                   	pop    %ebx
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ab:	0f b6 02             	movzbl (%edx),%eax
  8010ae:	3c 09                	cmp    $0x9,%al
  8010b0:	74 04                	je     8010b6 <strtol+0x1a>
  8010b2:	3c 20                	cmp    $0x20,%al
  8010b4:	75 0e                	jne    8010c4 <strtol+0x28>
		s++;
  8010b6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b9:	0f b6 02             	movzbl (%edx),%eax
  8010bc:	3c 09                	cmp    $0x9,%al
  8010be:	74 f6                	je     8010b6 <strtol+0x1a>
  8010c0:	3c 20                	cmp    $0x20,%al
  8010c2:	74 f2                	je     8010b6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010c4:	3c 2b                	cmp    $0x2b,%al
  8010c6:	75 0a                	jne    8010d2 <strtol+0x36>
		s++;
  8010c8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d0:	eb 10                	jmp    8010e2 <strtol+0x46>
  8010d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010d7:	3c 2d                	cmp    $0x2d,%al
  8010d9:	75 07                	jne    8010e2 <strtol+0x46>
		s++, neg = 1;
  8010db:	83 c2 01             	add    $0x1,%edx
  8010de:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010e8:	75 15                	jne    8010ff <strtol+0x63>
  8010ea:	80 3a 30             	cmpb   $0x30,(%edx)
  8010ed:	75 10                	jne    8010ff <strtol+0x63>
  8010ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8010f3:	75 0a                	jne    8010ff <strtol+0x63>
		s += 2, base = 16;
  8010f5:	83 c2 02             	add    $0x2,%edx
  8010f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010fd:	eb 10                	jmp    80110f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	75 0c                	jne    80110f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801103:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801105:	80 3a 30             	cmpb   $0x30,(%edx)
  801108:	75 05                	jne    80110f <strtol+0x73>
		s++, base = 8;
  80110a:	83 c2 01             	add    $0x1,%edx
  80110d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801117:	0f b6 0a             	movzbl (%edx),%ecx
  80111a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80111d:	89 f3                	mov    %esi,%ebx
  80111f:	80 fb 09             	cmp    $0x9,%bl
  801122:	77 08                	ja     80112c <strtol+0x90>
			dig = *s - '0';
  801124:	0f be c9             	movsbl %cl,%ecx
  801127:	83 e9 30             	sub    $0x30,%ecx
  80112a:	eb 22                	jmp    80114e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80112c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80112f:	89 f3                	mov    %esi,%ebx
  801131:	80 fb 19             	cmp    $0x19,%bl
  801134:	77 08                	ja     80113e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801136:	0f be c9             	movsbl %cl,%ecx
  801139:	83 e9 57             	sub    $0x57,%ecx
  80113c:	eb 10                	jmp    80114e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80113e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801141:	89 f3                	mov    %esi,%ebx
  801143:	80 fb 19             	cmp    $0x19,%bl
  801146:	77 16                	ja     80115e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801148:	0f be c9             	movsbl %cl,%ecx
  80114b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80114e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801151:	7d 0f                	jge    801162 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801153:	83 c2 01             	add    $0x1,%edx
  801156:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80115a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80115c:	eb b9                	jmp    801117 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80115e:	89 c1                	mov    %eax,%ecx
  801160:	eb 02                	jmp    801164 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801162:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801164:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801168:	74 05                	je     80116f <strtol+0xd3>
		*endptr = (char *) s;
  80116a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80116d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80116f:	89 ca                	mov    %ecx,%edx
  801171:	f7 da                	neg    %edx
  801173:	85 ff                	test   %edi,%edi
  801175:	0f 45 c2             	cmovne %edx,%eax
}
  801178:	83 c4 04             	add    $0x4,%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801189:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80118c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
  801194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
  80119a:	89 c3                	mov    %eax,%ebx
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	89 c6                	mov    %eax,%esi
  8011a0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011a2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011a8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ab:	89 ec                	mov    %ebp,%esp
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <sys_cgetc>:

int
sys_cgetc(void)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 0c             	sub    $0xc,%esp
  8011b5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011b8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011bb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011be:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c8:	89 d1                	mov    %edx,%ecx
  8011ca:	89 d3                	mov    %edx,%ebx
  8011cc:	89 d7                	mov    %edx,%edi
  8011ce:	89 d6                	mov    %edx,%esi
  8011d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011db:	89 ec                	mov    %ebp,%esp
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 38             	sub    $0x38,%esp
  8011e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	89 cb                	mov    %ecx,%ebx
  8011fd:	89 cf                	mov    %ecx,%edi
  8011ff:	89 ce                	mov    %ecx,%esi
  801201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  80122a:	e8 cd f3 ff ff       	call   8005fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80122f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801232:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801235:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801238:	89 ec                	mov    %ebp,%esp
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801245:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801248:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124b:	ba 00 00 00 00       	mov    $0x0,%edx
  801250:	b8 02 00 00 00       	mov    $0x2,%eax
  801255:	89 d1                	mov    %edx,%ecx
  801257:	89 d3                	mov    %edx,%ebx
  801259:	89 d7                	mov    %edx,%edi
  80125b:	89 d6                	mov    %edx,%esi
  80125d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80125f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801262:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801265:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801268:	89 ec                	mov    %ebp,%esp
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <sys_yield>:

void
sys_yield(void)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801275:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801278:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127b:	ba 00 00 00 00       	mov    $0x0,%edx
  801280:	b8 0a 00 00 00       	mov    $0xa,%eax
  801285:	89 d1                	mov    %edx,%ecx
  801287:	89 d3                	mov    %edx,%ebx
  801289:	89 d7                	mov    %edx,%edi
  80128b:	89 d6                	mov    %edx,%esi
  80128d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80128f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801292:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801295:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801298:	89 ec                	mov    %ebp,%esp
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 38             	sub    $0x38,%esp
  8012a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ab:	be 00 00 00 00       	mov    $0x0,%esi
  8012b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8012b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012be:	89 f7                	mov    %esi,%edi
  8012c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	7e 28                	jle    8012ee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8012d1:	00 
  8012d2:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  8012d9:	00 
  8012da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012e1:	00 
  8012e2:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  8012e9:	e8 0e f3 ff ff       	call   8005fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012f7:	89 ec                	mov    %ebp,%esp
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 38             	sub    $0x38,%esp
  801301:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801304:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801307:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80130a:	b8 05 00 00 00       	mov    $0x5,%eax
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	8b 55 08             	mov    0x8(%ebp),%edx
  801315:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801318:	8b 7d 14             	mov    0x14(%ebp),%edi
  80131b:	8b 75 18             	mov    0x18(%ebp),%esi
  80131e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801320:	85 c0                	test   %eax,%eax
  801322:	7e 28                	jle    80134c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801324:	89 44 24 10          	mov    %eax,0x10(%esp)
  801328:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80132f:	00 
  801330:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80133f:	00 
  801340:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  801347:	e8 b0 f2 ff ff       	call   8005fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80134c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80134f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801352:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801355:	89 ec                	mov    %ebp,%esp
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 38             	sub    $0x38,%esp
  80135f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801362:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801365:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801368:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136d:	b8 06 00 00 00       	mov    $0x6,%eax
  801372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801375:	8b 55 08             	mov    0x8(%ebp),%edx
  801378:	89 df                	mov    %ebx,%edi
  80137a:	89 de                	mov    %ebx,%esi
  80137c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80137e:	85 c0                	test   %eax,%eax
  801380:	7e 28                	jle    8013aa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801382:	89 44 24 10          	mov    %eax,0x10(%esp)
  801386:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80138d:	00 
  80138e:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  801395:	00 
  801396:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80139d:	00 
  80139e:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  8013a5:	e8 52 f2 ff ff       	call   8005fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013ad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013b3:	89 ec                	mov    %ebp,%esp
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 38             	sub    $0x38,%esp
  8013bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013c0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013c3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8013d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	89 df                	mov    %ebx,%edi
  8013d8:	89 de                	mov    %ebx,%esi
  8013da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	7e 28                	jle    801408 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013eb:	00 
  8013ec:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  8013f3:	00 
  8013f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013fb:	00 
  8013fc:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  801403:	e8 f4 f1 ff ff       	call   8005fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801408:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80140b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80140e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801411:	89 ec                	mov    %ebp,%esp
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 38             	sub    $0x38,%esp
  80141b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80141e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801421:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801424:	bb 00 00 00 00       	mov    $0x0,%ebx
  801429:	b8 09 00 00 00       	mov    $0x9,%eax
  80142e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801431:	8b 55 08             	mov    0x8(%ebp),%edx
  801434:	89 df                	mov    %ebx,%edi
  801436:	89 de                	mov    %ebx,%esi
  801438:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80143a:	85 c0                	test   %eax,%eax
  80143c:	7e 28                	jle    801466 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80143e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801442:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801449:	00 
  80144a:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  801451:	00 
  801452:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801459:	00 
  80145a:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  801461:	e8 96 f1 ff ff       	call   8005fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801466:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801469:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80146c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80146f:	89 ec                	mov    %ebp,%esp
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80147c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80147f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801482:	be 00 00 00 00       	mov    $0x0,%esi
  801487:	b8 0b 00 00 00       	mov    $0xb,%eax
  80148c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148f:	8b 55 08             	mov    0x8(%ebp),%edx
  801492:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801495:	8b 7d 14             	mov    0x14(%ebp),%edi
  801498:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80149a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80149d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014a3:	89 ec                	mov    %ebp,%esp
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	83 ec 38             	sub    $0x38,%esp
  8014ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c3:	89 cb                	mov    %ecx,%ebx
  8014c5:	89 cf                	mov    %ecx,%edi
  8014c7:	89 ce                	mov    %ecx,%esi
  8014c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	7e 28                	jle    8014f7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8014da:	00 
  8014db:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  8014e2:	00 
  8014e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ea:	00 
  8014eb:	c7 04 24 c1 1b 80 00 	movl   $0x801bc1,(%esp)
  8014f2:	e8 05 f1 ff ff       	call   8005fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801500:	89 ec                	mov    %ebp,%esp
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80150a:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801511:	75 1c                	jne    80152f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801513:	c7 44 24 08 d0 1b 80 	movl   $0x801bd0,0x8(%esp)
  80151a:	00 
  80151b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801522:	00 
  801523:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  80152a:	e8 cd f0 ff ff       	call   8005fc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    
  801539:	00 00                	add    %al,(%eax)
  80153b:	00 00                	add    %al,(%eax)
  80153d:	00 00                	add    %al,(%eax)
	...

00801540 <__udivdi3>:
  801540:	83 ec 1c             	sub    $0x1c,%esp
  801543:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801547:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80154b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80154f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801553:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801557:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801561:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801565:	89 ea                	mov    %ebp,%edx
  801567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80156b:	75 33                	jne    8015a0 <__udivdi3+0x60>
  80156d:	39 e9                	cmp    %ebp,%ecx
  80156f:	77 6f                	ja     8015e0 <__udivdi3+0xa0>
  801571:	85 c9                	test   %ecx,%ecx
  801573:	89 ce                	mov    %ecx,%esi
  801575:	75 0b                	jne    801582 <__udivdi3+0x42>
  801577:	b8 01 00 00 00       	mov    $0x1,%eax
  80157c:	31 d2                	xor    %edx,%edx
  80157e:	f7 f1                	div    %ecx
  801580:	89 c6                	mov    %eax,%esi
  801582:	31 d2                	xor    %edx,%edx
  801584:	89 e8                	mov    %ebp,%eax
  801586:	f7 f6                	div    %esi
  801588:	89 c5                	mov    %eax,%ebp
  80158a:	89 f8                	mov    %edi,%eax
  80158c:	f7 f6                	div    %esi
  80158e:	89 ea                	mov    %ebp,%edx
  801590:	8b 74 24 10          	mov    0x10(%esp),%esi
  801594:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801598:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80159c:	83 c4 1c             	add    $0x1c,%esp
  80159f:	c3                   	ret    
  8015a0:	39 e8                	cmp    %ebp,%eax
  8015a2:	77 24                	ja     8015c8 <__udivdi3+0x88>
  8015a4:	0f bd c8             	bsr    %eax,%ecx
  8015a7:	83 f1 1f             	xor    $0x1f,%ecx
  8015aa:	89 0c 24             	mov    %ecx,(%esp)
  8015ad:	75 49                	jne    8015f8 <__udivdi3+0xb8>
  8015af:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015b3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8015b7:	0f 86 ab 00 00 00    	jbe    801668 <__udivdi3+0x128>
  8015bd:	39 e8                	cmp    %ebp,%eax
  8015bf:	0f 82 a3 00 00 00    	jb     801668 <__udivdi3+0x128>
  8015c5:	8d 76 00             	lea    0x0(%esi),%esi
  8015c8:	31 d2                	xor    %edx,%edx
  8015ca:	31 c0                	xor    %eax,%eax
  8015cc:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015d0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015d4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015d8:	83 c4 1c             	add    $0x1c,%esp
  8015db:	c3                   	ret    
  8015dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e0:	89 f8                	mov    %edi,%eax
  8015e2:	f7 f1                	div    %ecx
  8015e4:	31 d2                	xor    %edx,%edx
  8015e6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015ea:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015ee:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015f2:	83 c4 1c             	add    $0x1c,%esp
  8015f5:	c3                   	ret    
  8015f6:	66 90                	xchg   %ax,%ax
  8015f8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8015fc:	89 c6                	mov    %eax,%esi
  8015fe:	b8 20 00 00 00       	mov    $0x20,%eax
  801603:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801607:	2b 04 24             	sub    (%esp),%eax
  80160a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80160e:	d3 e6                	shl    %cl,%esi
  801610:	89 c1                	mov    %eax,%ecx
  801612:	d3 ed                	shr    %cl,%ebp
  801614:	0f b6 0c 24          	movzbl (%esp),%ecx
  801618:	09 f5                	or     %esi,%ebp
  80161a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80161e:	d3 e6                	shl    %cl,%esi
  801620:	89 c1                	mov    %eax,%ecx
  801622:	89 74 24 04          	mov    %esi,0x4(%esp)
  801626:	89 d6                	mov    %edx,%esi
  801628:	d3 ee                	shr    %cl,%esi
  80162a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80162e:	d3 e2                	shl    %cl,%edx
  801630:	89 c1                	mov    %eax,%ecx
  801632:	d3 ef                	shr    %cl,%edi
  801634:	09 d7                	or     %edx,%edi
  801636:	89 f2                	mov    %esi,%edx
  801638:	89 f8                	mov    %edi,%eax
  80163a:	f7 f5                	div    %ebp
  80163c:	89 d6                	mov    %edx,%esi
  80163e:	89 c7                	mov    %eax,%edi
  801640:	f7 64 24 04          	mull   0x4(%esp)
  801644:	39 d6                	cmp    %edx,%esi
  801646:	72 30                	jb     801678 <__udivdi3+0x138>
  801648:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80164c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801650:	d3 e5                	shl    %cl,%ebp
  801652:	39 c5                	cmp    %eax,%ebp
  801654:	73 04                	jae    80165a <__udivdi3+0x11a>
  801656:	39 d6                	cmp    %edx,%esi
  801658:	74 1e                	je     801678 <__udivdi3+0x138>
  80165a:	89 f8                	mov    %edi,%eax
  80165c:	31 d2                	xor    %edx,%edx
  80165e:	e9 69 ff ff ff       	jmp    8015cc <__udivdi3+0x8c>
  801663:	90                   	nop
  801664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801668:	31 d2                	xor    %edx,%edx
  80166a:	b8 01 00 00 00       	mov    $0x1,%eax
  80166f:	e9 58 ff ff ff       	jmp    8015cc <__udivdi3+0x8c>
  801674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801678:	8d 47 ff             	lea    -0x1(%edi),%eax
  80167b:	31 d2                	xor    %edx,%edx
  80167d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801681:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801685:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801689:	83 c4 1c             	add    $0x1c,%esp
  80168c:	c3                   	ret    
  80168d:	00 00                	add    %al,(%eax)
	...

00801690 <__umoddi3>:
  801690:	83 ec 2c             	sub    $0x2c,%esp
  801693:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801697:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80169b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80169f:	8b 74 24 38          	mov    0x38(%esp),%esi
  8016a3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8016a7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8016b3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8016b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016bf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8016c3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8016c7:	75 1f                	jne    8016e8 <__umoddi3+0x58>
  8016c9:	39 fe                	cmp    %edi,%esi
  8016cb:	76 63                	jbe    801730 <__umoddi3+0xa0>
  8016cd:	89 c8                	mov    %ecx,%eax
  8016cf:	89 fa                	mov    %edi,%edx
  8016d1:	f7 f6                	div    %esi
  8016d3:	89 d0                	mov    %edx,%eax
  8016d5:	31 d2                	xor    %edx,%edx
  8016d7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8016db:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8016df:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8016e3:	83 c4 2c             	add    $0x2c,%esp
  8016e6:	c3                   	ret    
  8016e7:	90                   	nop
  8016e8:	39 f8                	cmp    %edi,%eax
  8016ea:	77 64                	ja     801750 <__umoddi3+0xc0>
  8016ec:	0f bd e8             	bsr    %eax,%ebp
  8016ef:	83 f5 1f             	xor    $0x1f,%ebp
  8016f2:	75 74                	jne    801768 <__umoddi3+0xd8>
  8016f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016f8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8016fc:	0f 87 0e 01 00 00    	ja     801810 <__umoddi3+0x180>
  801702:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801706:	29 f1                	sub    %esi,%ecx
  801708:	19 c7                	sbb    %eax,%edi
  80170a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80170e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801712:	8b 44 24 14          	mov    0x14(%esp),%eax
  801716:	8b 54 24 18          	mov    0x18(%esp),%edx
  80171a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80171e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801722:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801726:	83 c4 2c             	add    $0x2c,%esp
  801729:	c3                   	ret    
  80172a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801730:	85 f6                	test   %esi,%esi
  801732:	89 f5                	mov    %esi,%ebp
  801734:	75 0b                	jne    801741 <__umoddi3+0xb1>
  801736:	b8 01 00 00 00       	mov    $0x1,%eax
  80173b:	31 d2                	xor    %edx,%edx
  80173d:	f7 f6                	div    %esi
  80173f:	89 c5                	mov    %eax,%ebp
  801741:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801745:	31 d2                	xor    %edx,%edx
  801747:	f7 f5                	div    %ebp
  801749:	89 c8                	mov    %ecx,%eax
  80174b:	f7 f5                	div    %ebp
  80174d:	eb 84                	jmp    8016d3 <__umoddi3+0x43>
  80174f:	90                   	nop
  801750:	89 c8                	mov    %ecx,%eax
  801752:	89 fa                	mov    %edi,%edx
  801754:	8b 74 24 20          	mov    0x20(%esp),%esi
  801758:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80175c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801760:	83 c4 2c             	add    $0x2c,%esp
  801763:	c3                   	ret    
  801764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801768:	8b 44 24 10          	mov    0x10(%esp),%eax
  80176c:	be 20 00 00 00       	mov    $0x20,%esi
  801771:	89 e9                	mov    %ebp,%ecx
  801773:	29 ee                	sub    %ebp,%esi
  801775:	d3 e2                	shl    %cl,%edx
  801777:	89 f1                	mov    %esi,%ecx
  801779:	d3 e8                	shr    %cl,%eax
  80177b:	89 e9                	mov    %ebp,%ecx
  80177d:	09 d0                	or     %edx,%eax
  80177f:	89 fa                	mov    %edi,%edx
  801781:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801785:	8b 44 24 10          	mov    0x10(%esp),%eax
  801789:	d3 e0                	shl    %cl,%eax
  80178b:	89 f1                	mov    %esi,%ecx
  80178d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801791:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801795:	d3 ea                	shr    %cl,%edx
  801797:	89 e9                	mov    %ebp,%ecx
  801799:	d3 e7                	shl    %cl,%edi
  80179b:	89 f1                	mov    %esi,%ecx
  80179d:	d3 e8                	shr    %cl,%eax
  80179f:	89 e9                	mov    %ebp,%ecx
  8017a1:	09 f8                	or     %edi,%eax
  8017a3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8017a7:	f7 74 24 0c          	divl   0xc(%esp)
  8017ab:	d3 e7                	shl    %cl,%edi
  8017ad:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8017b1:	89 d7                	mov    %edx,%edi
  8017b3:	f7 64 24 10          	mull   0x10(%esp)
  8017b7:	39 d7                	cmp    %edx,%edi
  8017b9:	89 c1                	mov    %eax,%ecx
  8017bb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8017bf:	72 3b                	jb     8017fc <__umoddi3+0x16c>
  8017c1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8017c5:	72 31                	jb     8017f8 <__umoddi3+0x168>
  8017c7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8017cb:	29 c8                	sub    %ecx,%eax
  8017cd:	19 d7                	sbb    %edx,%edi
  8017cf:	89 e9                	mov    %ebp,%ecx
  8017d1:	89 fa                	mov    %edi,%edx
  8017d3:	d3 e8                	shr    %cl,%eax
  8017d5:	89 f1                	mov    %esi,%ecx
  8017d7:	d3 e2                	shl    %cl,%edx
  8017d9:	89 e9                	mov    %ebp,%ecx
  8017db:	09 d0                	or     %edx,%eax
  8017dd:	89 fa                	mov    %edi,%edx
  8017df:	d3 ea                	shr    %cl,%edx
  8017e1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8017e5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8017e9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8017ed:	83 c4 2c             	add    $0x2c,%esp
  8017f0:	c3                   	ret    
  8017f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017f8:	39 d7                	cmp    %edx,%edi
  8017fa:	75 cb                	jne    8017c7 <__umoddi3+0x137>
  8017fc:	8b 54 24 14          	mov    0x14(%esp),%edx
  801800:	89 c1                	mov    %eax,%ecx
  801802:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801806:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80180a:	eb bb                	jmp    8017c7 <__umoddi3+0x137>
  80180c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801810:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801814:	0f 82 e8 fe ff ff    	jb     801702 <__umoddi3+0x72>
  80181a:	e9 f3 fe ff ff       	jmp    801712 <__umoddi3+0x82>
