
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 c0 11 00       	mov    $0x11c000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 c0 11 f0       	mov    $0xf011c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 e1 00 00 00       	call   f010011f <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d e0 0e 22 f0 00 	cmpl   $0x0,0xf0220ee0
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 e0 0e 22 f0    	mov    %esi,0xf0220ee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 28 4f 00 00       	call   f0104f8c <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 57 10 f0 	movl   $0xf0105700,(%esp)
f010007d:	e8 f8 30 00 00       	call   f010317a <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 b9 30 00 00       	call   f0103147 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 cc 57 10 f0 	movl   $0xf01057cc,(%esp)
f0100095:	e8 e0 30 00 00       	call   f010317a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 18 09 00 00       	call   f01009be <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 57 10 f0 	movl   $0xf010576b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 a5 4e 00 00       	call   f0104f8c <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 57 10 f0 	movl   $0xf0105777,(%esp)
f01000f2:	e8 83 30 00 00       	call   f010317a <cprintf>

	lapic_init();
f01000f7:	e8 ab 4e 00 00       	call   f0104fa7 <lapic_init>
	env_init_percpu();
f01000fc:	e8 8e 28 00 00       	call   f010298f <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 8e 30 00 00       	call   f0103194 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 81 4e 00 00       	call   f0104f8c <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 10 22 f0    	add    $0xf0221020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010011d:	eb fe                	jmp    f010011d <mp_main+0x75>

f010011f <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010011f:	55                   	push   %ebp
f0100120:	89 e5                	mov    %esp,%ebp
f0100122:	53                   	push   %ebx
f0100123:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100126:	b8 08 20 26 f0       	mov    $0xf0262008,%eax
f010012b:	2d 60 fc 21 f0       	sub    $0xf021fc60,%eax
f0100130:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100134:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010013b:	00 
f010013c:	c7 04 24 60 fc 21 f0 	movl   $0xf021fc60,(%esp)
f0100143:	e8 9d 47 00 00       	call   f01048e5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100148:	e8 2a 05 00 00       	call   f0100677 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010014d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100154:	00 
f0100155:	c7 04 24 8d 57 10 f0 	movl   $0xf010578d,(%esp)
f010015c:	e8 19 30 00 00       	call   f010317a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100161:	e8 76 0f 00 00       	call   f01010dc <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100166:	e8 4e 28 00 00       	call   f01029b9 <env_init>
	trap_init();
f010016b:	90                   	nop
f010016c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100170:	e8 7c 30 00 00       	call   f01031f1 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100175:	e8 2a 4b 00 00       	call   f0104ca4 <mp_init>
	lapic_init();
f010017a:	e8 28 4e 00 00       	call   f0104fa7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010017f:	90                   	nop
f0100180:	e8 22 2f 00 00       	call   f01030a7 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100185:	83 3d e8 0e 22 f0 07 	cmpl   $0x7,0xf0220ee8
f010018c:	77 24                	ja     f01001b2 <i386_init+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010018e:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100195:	00 
f0100196:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f010019d:	f0 
f010019e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01001a5:	00 
f01001a6:	c7 04 24 6b 57 10 f0 	movl   $0xf010576b,(%esp)
f01001ad:	e8 8e fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001b2:	b8 ba 4b 10 f0       	mov    $0xf0104bba,%eax
f01001b7:	2d 40 4b 10 f0       	sub    $0xf0104b40,%eax
f01001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001c0:	c7 44 24 04 40 4b 10 	movl   $0xf0104b40,0x4(%esp)
f01001c7:	f0 
f01001c8:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001cf:	e8 6f 47 00 00       	call   f0104943 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d4:	6b 05 c4 13 22 f0 74 	imul   $0x74,0xf02213c4,%eax
f01001db:	05 20 10 22 f0       	add    $0xf0221020,%eax
f01001e0:	3d 20 10 22 f0       	cmp    $0xf0221020,%eax
f01001e5:	76 62                	jbe    f0100249 <i386_init+0x12a>
f01001e7:	bb 20 10 22 f0       	mov    $0xf0221020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f01001ec:	e8 9b 4d 00 00       	call   f0104f8c <cpunum>
f01001f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01001f4:	05 20 10 22 f0       	add    $0xf0221020,%eax
f01001f9:	39 c3                	cmp    %eax,%ebx
f01001fb:	74 39                	je     f0100236 <i386_init+0x117>

static void boot_aps(void);


void
i386_init(void)
f01001fd:	89 d8                	mov    %ebx,%eax
f01001ff:	2d 20 10 22 f0       	sub    $0xf0221020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100204:	c1 f8 02             	sar    $0x2,%eax
f0100207:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010020d:	c1 e0 0f             	shl    $0xf,%eax
f0100210:	8d 80 00 a0 22 f0    	lea    -0xfdd6000(%eax),%eax
f0100216:	a3 e4 0e 22 f0       	mov    %eax,0xf0220ee4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100222:	00 
f0100223:	0f b6 03             	movzbl (%ebx),%eax
f0100226:	89 04 24             	mov    %eax,(%esp)
f0100229:	e8 c9 4e 00 00       	call   f01050f7 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010022e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100231:	83 f8 01             	cmp    $0x1,%eax
f0100234:	75 f8                	jne    f010022e <i386_init+0x10f>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100236:	83 c3 74             	add    $0x74,%ebx
f0100239:	6b 05 c4 13 22 f0 74 	imul   $0x74,0xf02213c4,%eax
f0100240:	05 20 10 22 f0       	add    $0xf0221020,%eax
f0100245:	39 c3                	cmp    %eax,%ebx
f0100247:	72 a3                	jb     f01001ec <i386_init+0xcd>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f0100249:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100250:	00 
f0100251:	c7 44 24 04 dd 89 00 	movl   $0x89dd,0x4(%esp)
f0100258:	00 
f0100259:	c7 04 24 83 72 21 f0 	movl   $0xf0217283,(%esp)
f0100260:	e8 43 29 00 00       	call   f0102ba8 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100265:	e8 16 38 00 00       	call   f0103a80 <sched_yield>

f010026a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100271:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100274:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100277:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027b:	8b 45 08             	mov    0x8(%ebp),%eax
f010027e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100282:	c7 04 24 a8 57 10 f0 	movl   $0xf01057a8,(%esp)
f0100289:	e8 ec 2e 00 00       	call   f010317a <cprintf>
	vcprintf(fmt, ap);
f010028e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100292:	8b 45 10             	mov    0x10(%ebp),%eax
f0100295:	89 04 24             	mov    %eax,(%esp)
f0100298:	e8 aa 2e 00 00       	call   f0103147 <vcprintf>
	cprintf("\n");
f010029d:	c7 04 24 cc 57 10 f0 	movl   $0xf01057cc,(%esp)
f01002a4:	e8 d1 2e 00 00       	call   f010317a <cprintf>
	va_end(ap);
}
f01002a9:	83 c4 14             	add    $0x14,%esp
f01002ac:	5b                   	pop    %ebx
f01002ad:	5d                   	pop    %ebp
f01002ae:	c3                   	ret    
	...

f01002b0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002b8:	ec                   	in     (%dx),%al
f01002b9:	ec                   	in     (%dx),%al
f01002ba:	ec                   	in     (%dx),%al
f01002bb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002be:	55                   	push   %ebp
f01002bf:	89 e5                	mov    %esp,%ebp
f01002c1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c7:	a8 01                	test   $0x1,%al
f01002c9:	74 08                	je     f01002d3 <serial_proc_data+0x15>
f01002cb:	b2 f8                	mov    $0xf8,%dl
f01002cd:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002ce:	0f b6 c0             	movzbl %al,%eax
f01002d1:	eb 05                	jmp    f01002d8 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002d8:	5d                   	pop    %ebp
f01002d9:	c3                   	ret    

f01002da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	53                   	push   %ebx
f01002de:	83 ec 04             	sub    $0x4,%esp
f01002e1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e3:	eb 26                	jmp    f010030b <cons_intr+0x31>
		if (c == 0)
f01002e5:	85 d2                	test   %edx,%edx
f01002e7:	74 22                	je     f010030b <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f01002e9:	a1 24 02 22 f0       	mov    0xf0220224,%eax
f01002ee:	88 90 20 00 22 f0    	mov    %dl,-0xfddffe0(%eax)
f01002f4:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.wpos == CONSBUFSIZE)
f01002f7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100302:	0f 44 d0             	cmove  %eax,%edx
f0100305:	89 15 24 02 22 f0    	mov    %edx,0xf0220224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010030b:	ff d3                	call   *%ebx
f010030d:	89 c2                	mov    %eax,%edx
f010030f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100312:	75 d1                	jne    f01002e5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100314:	83 c4 04             	add    $0x4,%esp
f0100317:	5b                   	pop    %ebx
f0100318:	5d                   	pop    %ebp
f0100319:	c3                   	ret    

f010031a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010031a:	55                   	push   %ebp
f010031b:	89 e5                	mov    %esp,%ebp
f010031d:	57                   	push   %edi
f010031e:	56                   	push   %esi
f010031f:	53                   	push   %ebx
f0100320:	83 ec 2c             	sub    $0x2c,%esp
f0100323:	89 c7                	mov    %eax,%edi
f0100325:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010032a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010032b:	a8 20                	test   $0x20,%al
f010032d:	75 1b                	jne    f010034a <cons_putc+0x30>
f010032f:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100334:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100339:	e8 72 ff ff ff       	call   f01002b0 <delay>
f010033e:	89 f2                	mov    %esi,%edx
f0100340:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100341:	a8 20                	test   $0x20,%al
f0100343:	75 05                	jne    f010034a <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100345:	83 eb 01             	sub    $0x1,%ebx
f0100348:	75 ef                	jne    f0100339 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	25 ff 00 00 00       	and    $0xff,%eax
f0100351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100354:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100359:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	b2 79                	mov    $0x79,%dl
f010035c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035d:	84 c0                	test   %al,%al
f010035f:	78 1b                	js     f010037c <cons_putc+0x62>
f0100361:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100366:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010036b:	e8 40 ff ff ff       	call   f01002b0 <delay>
f0100370:	89 f2                	mov    %esi,%edx
f0100372:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100373:	84 c0                	test   %al,%al
f0100375:	78 05                	js     f010037c <cons_putc+0x62>
f0100377:	83 eb 01             	sub    $0x1,%ebx
f010037a:	75 ef                	jne    f010036b <cons_putc+0x51>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100381:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100385:	ee                   	out    %al,(%dx)
f0100386:	b2 7a                	mov    $0x7a,%dl
f0100388:	b8 0d 00 00 00       	mov    $0xd,%eax
f010038d:	ee                   	out    %al,(%dx)
f010038e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100393:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100394:	89 fa                	mov    %edi,%edx
f0100396:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010039c:	89 f8                	mov    %edi,%eax
f010039e:	80 cc 07             	or     $0x7,%ah
f01003a1:	85 d2                	test   %edx,%edx
f01003a3:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003a6:	89 f8                	mov    %edi,%eax
f01003a8:	25 ff 00 00 00       	and    $0xff,%eax
f01003ad:	83 f8 09             	cmp    $0x9,%eax
f01003b0:	74 77                	je     f0100429 <cons_putc+0x10f>
f01003b2:	83 f8 09             	cmp    $0x9,%eax
f01003b5:	7f 0b                	jg     f01003c2 <cons_putc+0xa8>
f01003b7:	83 f8 08             	cmp    $0x8,%eax
f01003ba:	0f 85 9d 00 00 00    	jne    f010045d <cons_putc+0x143>
f01003c0:	eb 10                	jmp    f01003d2 <cons_putc+0xb8>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	74 3c                	je     f0100403 <cons_putc+0xe9>
f01003c7:	83 f8 0d             	cmp    $0xd,%eax
f01003ca:	0f 85 8d 00 00 00    	jne    f010045d <cons_putc+0x143>
f01003d0:	eb 39                	jmp    f010040b <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f01003d2:	0f b7 05 34 02 22 f0 	movzwl 0xf0220234,%eax
f01003d9:	66 85 c0             	test   %ax,%ax
f01003dc:	0f 84 e5 00 00 00    	je     f01004c7 <cons_putc+0x1ad>
			crt_pos--;
f01003e2:	83 e8 01             	sub    $0x1,%eax
f01003e5:	66 a3 34 02 22 f0    	mov    %ax,0xf0220234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003eb:	0f b7 c0             	movzwl %ax,%eax
f01003ee:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01003f4:	83 cf 20             	or     $0x20,%edi
f01003f7:	8b 15 30 02 22 f0    	mov    0xf0220230,%edx
f01003fd:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100401:	eb 77                	jmp    f010047a <cons_putc+0x160>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100403:	66 83 05 34 02 22 f0 	addw   $0x50,0xf0220234
f010040a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010040b:	0f b7 05 34 02 22 f0 	movzwl 0xf0220234,%eax
f0100412:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100418:	c1 e8 16             	shr    $0x16,%eax
f010041b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010041e:	c1 e0 04             	shl    $0x4,%eax
f0100421:	66 a3 34 02 22 f0    	mov    %ax,0xf0220234
f0100427:	eb 51                	jmp    f010047a <cons_putc+0x160>
		break;
	case '\t':
		cons_putc(' ');
f0100429:	b8 20 00 00 00       	mov    $0x20,%eax
f010042e:	e8 e7 fe ff ff       	call   f010031a <cons_putc>
		cons_putc(' ');
f0100433:	b8 20 00 00 00       	mov    $0x20,%eax
f0100438:	e8 dd fe ff ff       	call   f010031a <cons_putc>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 d3 fe ff ff       	call   f010031a <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 c9 fe ff ff       	call   f010031a <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 bf fe ff ff       	call   f010031a <cons_putc>
f010045b:	eb 1d                	jmp    f010047a <cons_putc+0x160>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010045d:	0f b7 05 34 02 22 f0 	movzwl 0xf0220234,%eax
f0100464:	0f b7 c8             	movzwl %ax,%ecx
f0100467:	8b 15 30 02 22 f0    	mov    0xf0220230,%edx
f010046d:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100471:	83 c0 01             	add    $0x1,%eax
f0100474:	66 a3 34 02 22 f0    	mov    %ax,0xf0220234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010047a:	66 81 3d 34 02 22 f0 	cmpw   $0x7cf,0xf0220234
f0100481:	cf 07 
f0100483:	76 42                	jbe    f01004c7 <cons_putc+0x1ad>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100485:	a1 30 02 22 f0       	mov    0xf0220230,%eax
f010048a:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100491:	00 
f0100492:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100498:	89 54 24 04          	mov    %edx,0x4(%esp)
f010049c:	89 04 24             	mov    %eax,(%esp)
f010049f:	e8 9f 44 00 00       	call   f0104943 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a4:	8b 15 30 02 22 f0    	mov    0xf0220230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004aa:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004af:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b5:	83 c0 01             	add    $0x1,%eax
f01004b8:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004bd:	75 f0                	jne    f01004af <cons_putc+0x195>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004bf:	66 83 2d 34 02 22 f0 	subw   $0x50,0xf0220234
f01004c6:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c7:	8b 0d 2c 02 22 f0    	mov    0xf022022c,%ecx
f01004cd:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d2:	89 ca                	mov    %ecx,%edx
f01004d4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d5:	0f b7 1d 34 02 22 f0 	movzwl 0xf0220234,%ebx
f01004dc:	8d 71 01             	lea    0x1(%ecx),%esi
f01004df:	89 d8                	mov    %ebx,%eax
f01004e1:	66 c1 e8 08          	shr    $0x8,%ax
f01004e5:	89 f2                	mov    %esi,%edx
f01004e7:	ee                   	out    %al,(%dx)
f01004e8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ed:	89 ca                	mov    %ecx,%edx
f01004ef:	ee                   	out    %al,(%dx)
f01004f0:	89 d8                	mov    %ebx,%eax
f01004f2:	89 f2                	mov    %esi,%edx
f01004f4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f5:	83 c4 2c             	add    $0x2c,%esp
f01004f8:	5b                   	pop    %ebx
f01004f9:	5e                   	pop    %esi
f01004fa:	5f                   	pop    %edi
f01004fb:	5d                   	pop    %ebp
f01004fc:	c3                   	ret    

f01004fd <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004fd:	55                   	push   %ebp
f01004fe:	89 e5                	mov    %esp,%ebp
f0100500:	53                   	push   %ebx
f0100501:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100504:	ba 64 00 00 00       	mov    $0x64,%edx
f0100509:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010050a:	a8 01                	test   $0x1,%al
f010050c:	0f 84 e5 00 00 00    	je     f01005f7 <kbd_proc_data+0xfa>
f0100512:	b2 60                	mov    $0x60,%dl
f0100514:	ec                   	in     (%dx),%al
f0100515:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100517:	3c e0                	cmp    $0xe0,%al
f0100519:	75 11                	jne    f010052c <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010051b:	83 0d 28 02 22 f0 40 	orl    $0x40,0xf0220228
		return 0;
f0100522:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100527:	e9 d0 00 00 00       	jmp    f01005fc <kbd_proc_data+0xff>
	} else if (data & 0x80) {
f010052c:	84 c0                	test   %al,%al
f010052e:	79 37                	jns    f0100567 <kbd_proc_data+0x6a>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100530:	8b 0d 28 02 22 f0    	mov    0xf0220228,%ecx
f0100536:	89 cb                	mov    %ecx,%ebx
f0100538:	83 e3 40             	and    $0x40,%ebx
f010053b:	83 e0 7f             	and    $0x7f,%eax
f010053e:	85 db                	test   %ebx,%ebx
f0100540:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100543:	0f b6 d2             	movzbl %dl,%edx
f0100546:	0f b6 82 00 58 10 f0 	movzbl -0xfefa800(%edx),%eax
f010054d:	83 c8 40             	or     $0x40,%eax
f0100550:	0f b6 c0             	movzbl %al,%eax
f0100553:	f7 d0                	not    %eax
f0100555:	21 c1                	and    %eax,%ecx
f0100557:	89 0d 28 02 22 f0    	mov    %ecx,0xf0220228
		return 0;
f010055d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100562:	e9 95 00 00 00       	jmp    f01005fc <kbd_proc_data+0xff>
	} else if (shift & E0ESC) {
f0100567:	8b 0d 28 02 22 f0    	mov    0xf0220228,%ecx
f010056d:	f6 c1 40             	test   $0x40,%cl
f0100570:	74 0e                	je     f0100580 <kbd_proc_data+0x83>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100572:	89 c2                	mov    %eax,%edx
f0100574:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100577:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057a:	89 0d 28 02 22 f0    	mov    %ecx,0xf0220228
	}

	shift |= shiftcode[data];
f0100580:	0f b6 d2             	movzbl %dl,%edx
f0100583:	0f b6 82 00 58 10 f0 	movzbl -0xfefa800(%edx),%eax
f010058a:	0b 05 28 02 22 f0    	or     0xf0220228,%eax
	shift ^= togglecode[data];
f0100590:	0f b6 8a 00 59 10 f0 	movzbl -0xfefa700(%edx),%ecx
f0100597:	31 c8                	xor    %ecx,%eax
f0100599:	a3 28 02 22 f0       	mov    %eax,0xf0220228

	c = charcode[shift & (CTL | SHIFT)][data];
f010059e:	89 c1                	mov    %eax,%ecx
f01005a0:	83 e1 03             	and    $0x3,%ecx
f01005a3:	8b 0c 8d 00 5a 10 f0 	mov    -0xfefa600(,%ecx,4),%ecx
f01005aa:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01005ae:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01005b1:	a8 08                	test   $0x8,%al
f01005b3:	74 1b                	je     f01005d0 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005b5:	89 da                	mov    %ebx,%edx
f01005b7:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01005ba:	83 f9 19             	cmp    $0x19,%ecx
f01005bd:	77 05                	ja     f01005c4 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005bf:	83 eb 20             	sub    $0x20,%ebx
f01005c2:	eb 0c                	jmp    f01005d0 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005c4:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01005c7:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01005ca:	83 fa 19             	cmp    $0x19,%edx
f01005cd:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005d0:	f7 d0                	not    %eax
f01005d2:	a8 06                	test   $0x6,%al
f01005d4:	75 26                	jne    f01005fc <kbd_proc_data+0xff>
f01005d6:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005dc:	75 1e                	jne    f01005fc <kbd_proc_data+0xff>
		cprintf("Rebooting!\n");
f01005de:	c7 04 24 c2 57 10 f0 	movl   $0xf01057c2,(%esp)
f01005e5:	e8 90 2b 00 00       	call   f010317a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ea:	ba 92 00 00 00       	mov    $0x92,%edx
f01005ef:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f4:	ee                   	out    %al,(%dx)
f01005f5:	eb 05                	jmp    f01005fc <kbd_proc_data+0xff>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005f7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005fc:	89 d8                	mov    %ebx,%eax
f01005fe:	83 c4 14             	add    $0x14,%esp
f0100601:	5b                   	pop    %ebx
f0100602:	5d                   	pop    %ebp
f0100603:	c3                   	ret    

f0100604 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100604:	80 3d 00 00 22 f0 00 	cmpb   $0x0,0xf0220000
f010060b:	74 11                	je     f010061e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100613:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f0100618:	e8 bd fc ff ff       	call   f01002da <cons_intr>
}
f010061d:	c9                   	leave  
f010061e:	f3 c3                	repz ret 

f0100620 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100626:	b8 fd 04 10 f0       	mov    $0xf01004fd,%eax
f010062b:	e8 aa fc ff ff       	call   f01002da <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100638:	e8 c7 ff ff ff       	call   f0100604 <serial_intr>
	kbd_intr();
f010063d:	e8 de ff ff ff       	call   f0100620 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100642:	8b 15 20 02 22 f0    	mov    0xf0220220,%edx
f0100648:	3b 15 24 02 22 f0    	cmp    0xf0220224,%edx
f010064e:	74 20                	je     f0100670 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100650:	0f b6 82 20 00 22 f0 	movzbl -0xfddffe0(%edx),%eax
f0100657:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010065a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
f0100660:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100665:	0f 44 d1             	cmove  %ecx,%edx
f0100668:	89 15 20 02 22 f0    	mov    %edx,0xf0220220
f010066e:	eb 05                	jmp    f0100675 <cons_getc+0x43>
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100670:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100675:	c9                   	leave  
f0100676:	c3                   	ret    

f0100677 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100677:	55                   	push   %ebp
f0100678:	89 e5                	mov    %esp,%ebp
f010067a:	57                   	push   %edi
f010067b:	56                   	push   %esi
f010067c:	53                   	push   %ebx
f010067d:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100680:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100687:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068e:	5a a5 
	if (*cp != 0xA55A) {
f0100690:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100697:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010069b:	74 11                	je     f01006ae <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010069d:	c7 05 2c 02 22 f0 b4 	movl   $0x3b4,0xf022022c
f01006a4:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a7:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006ac:	eb 16                	jmp    f01006c4 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ae:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b5:	c7 05 2c 02 22 f0 d4 	movl   $0x3d4,0xf022022c
f01006bc:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006bf:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c4:	8b 0d 2c 02 22 f0    	mov    0xf022022c,%ecx
f01006ca:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006cf:	89 ca                	mov    %ecx,%edx
f01006d1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006d2:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d5:	89 da                	mov    %ebx,%edx
f01006d7:	ec                   	in     (%dx),%al
f01006d8:	0f b6 f0             	movzbl %al,%esi
f01006db:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006de:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006e3:	89 ca                	mov    %ecx,%edx
f01006e5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e6:	89 da                	mov    %ebx,%edx
f01006e8:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e9:	89 3d 30 02 22 f0    	mov    %edi,0xf0220230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006ef:	0f b6 d8             	movzbl %al,%ebx
f01006f2:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006f4:	66 89 35 34 02 22 f0 	mov    %si,0xf0220234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01006fb:	e8 20 ff ff ff       	call   f0100620 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100700:	0f b7 05 88 e3 11 f0 	movzwl 0xf011e388,%eax
f0100707:	25 fd ff 00 00       	and    $0xfffd,%eax
f010070c:	89 04 24             	mov    %eax,(%esp)
f010070f:	e8 24 29 00 00       	call   f0103038 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100714:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100719:	b8 00 00 00 00       	mov    $0x0,%eax
f010071e:	89 f2                	mov    %esi,%edx
f0100720:	ee                   	out    %al,(%dx)
f0100721:	b2 fb                	mov    $0xfb,%dl
f0100723:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100728:	ee                   	out    %al,(%dx)
f0100729:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010072e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100733:	89 da                	mov    %ebx,%edx
f0100735:	ee                   	out    %al,(%dx)
f0100736:	b2 f9                	mov    $0xf9,%dl
f0100738:	b8 00 00 00 00       	mov    $0x0,%eax
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 fb                	mov    $0xfb,%dl
f0100740:	b8 03 00 00 00       	mov    $0x3,%eax
f0100745:	ee                   	out    %al,(%dx)
f0100746:	b2 fc                	mov    $0xfc,%dl
f0100748:	b8 00 00 00 00       	mov    $0x0,%eax
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 f9                	mov    $0xf9,%dl
f0100750:	b8 01 00 00 00       	mov    $0x1,%eax
f0100755:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100756:	b2 fd                	mov    $0xfd,%dl
f0100758:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100759:	3c ff                	cmp    $0xff,%al
f010075b:	0f 95 c1             	setne  %cl
f010075e:	88 0d 00 00 22 f0    	mov    %cl,0xf0220000
f0100764:	89 f2                	mov    %esi,%edx
f0100766:	ec                   	in     (%dx),%al
f0100767:	89 da                	mov    %ebx,%edx
f0100769:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076a:	84 c9                	test   %cl,%cl
f010076c:	75 0c                	jne    f010077a <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f010076e:	c7 04 24 ce 57 10 f0 	movl   $0xf01057ce,(%esp)
f0100775:	e8 00 2a 00 00       	call   f010317a <cprintf>
}
f010077a:	83 c4 1c             	add    $0x1c,%esp
f010077d:	5b                   	pop    %ebx
f010077e:	5e                   	pop    %esi
f010077f:	5f                   	pop    %edi
f0100780:	5d                   	pop    %ebp
f0100781:	c3                   	ret    

f0100782 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100782:	55                   	push   %ebp
f0100783:	89 e5                	mov    %esp,%ebp
f0100785:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100788:	8b 45 08             	mov    0x8(%ebp),%eax
f010078b:	e8 8a fb ff ff       	call   f010031a <cons_putc>
}
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <getchar>:

int
getchar(void)
{
f0100792:	55                   	push   %ebp
f0100793:	89 e5                	mov    %esp,%ebp
f0100795:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100798:	e8 95 fe ff ff       	call   f0100632 <cons_getc>
f010079d:	85 c0                	test   %eax,%eax
f010079f:	74 f7                	je     f0100798 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <iscons>:

int
iscons(int fdnum)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ab:	5d                   	pop    %ebp
f01007ac:	c3                   	ret    
f01007ad:	00 00                	add    %al,(%eax)
	...

f01007b0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b6:	c7 04 24 10 5a 10 f0 	movl   $0xf0105a10,(%esp)
f01007bd:	e8 b8 29 00 00       	call   f010317a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007c9:	00 
f01007ca:	c7 04 24 d0 5a 10 f0 	movl   $0xf0105ad0,(%esp)
f01007d1:	e8 a4 29 00 00       	call   f010317a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007dd:	00 
f01007de:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 f8 5a 10 f0 	movl   $0xf0105af8,(%esp)
f01007ed:	e8 88 29 00 00       	call   f010317a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f2:	c7 44 24 08 ff 56 10 	movl   $0x1056ff,0x8(%esp)
f01007f9:	00 
f01007fa:	c7 44 24 04 ff 56 10 	movl   $0xf01056ff,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 1c 5b 10 f0 	movl   $0xf0105b1c,(%esp)
f0100809:	e8 6c 29 00 00       	call   f010317a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080e:	c7 44 24 08 60 fc 21 	movl   $0x21fc60,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 60 fc 21 	movl   $0xf021fc60,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 40 5b 10 f0 	movl   $0xf0105b40,(%esp)
f0100825:	e8 50 29 00 00       	call   f010317a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082a:	c7 44 24 08 08 20 26 	movl   $0x262008,0x8(%esp)
f0100831:	00 
f0100832:	c7 44 24 04 08 20 26 	movl   $0xf0262008,0x4(%esp)
f0100839:	f0 
f010083a:	c7 04 24 64 5b 10 f0 	movl   $0xf0105b64,(%esp)
f0100841:	e8 34 29 00 00       	call   f010317a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100846:	b8 07 24 26 f0       	mov    $0xf0262407,%eax
f010084b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100850:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100855:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085b:	85 c0                	test   %eax,%eax
f010085d:	0f 48 c2             	cmovs  %edx,%eax
f0100860:	c1 f8 0a             	sar    $0xa,%eax
f0100863:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100867:	c7 04 24 88 5b 10 f0 	movl   $0xf0105b88,(%esp)
f010086e:	e8 07 29 00 00       	call   f010317a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100873:	b8 00 00 00 00       	mov    $0x0,%eax
f0100878:	c9                   	leave  
f0100879:	c3                   	ret    

f010087a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	56                   	push   %esi
f010087e:	53                   	push   %ebx
f010087f:	83 ec 10             	sub    $0x10,%esp
f0100882:	bb 64 5c 10 f0       	mov    $0xf0105c64,%ebx
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f0100887:	be 88 5c 10 f0       	mov    $0xf0105c88,%esi
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010088c:	8b 03                	mov    (%ebx),%eax
f010088e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100892:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100895:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100899:	c7 04 24 29 5a 10 f0 	movl   $0xf0105a29,(%esp)
f01008a0:	e8 d5 28 00 00       	call   f010317a <cprintf>
f01008a5:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008a8:	39 f3                	cmp    %esi,%ebx
f01008aa:	75 e0                	jne    f010088c <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	5b                   	pop    %ebx
f01008b5:	5e                   	pop    %esi
f01008b6:	5d                   	pop    %ebp
f01008b7:	c3                   	ret    

f01008b8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b8:	55                   	push   %ebp
f01008b9:	89 e5                	mov    %esp,%ebp
f01008bb:	57                   	push   %edi
f01008bc:	56                   	push   %esi
f01008bd:	53                   	push   %ebx
f01008be:	83 ec 5c             	sub    $0x5c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c1:	89 ef                	mov    %ebp,%edi
  uint32_t* ebp = (uint32_t*)read_ebp();
  //eip(reg) is return value.
	//ebp+0x4 is the eip's value. Study the calling convention when call test_backtrace and mon_backtrace, it is clear.
  uint32_t* temp;
  temp = ebp;
  temp++;
f01008c3:	8d 47 04             	lea    0x4(%edi),%eax
f01008c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
  uint32_t* eip = temp;
  debuginfo_eip((uintptr_t)*eip, &info);
f01008c9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d0:	8b 47 04             	mov    0x4(%edi),%eax
f01008d3:	89 04 24             	mov    %eax,(%esp)
f01008d6:	e8 ef 33 00 00       	call   f0103cca <debuginfo_eip>
  arg1 = *(++temp);
f01008db:	8b 47 08             	mov    0x8(%edi),%eax
f01008de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  arg2 = *(++temp);
f01008e1:	8b 47 0c             	mov    0xc(%edi),%eax
f01008e4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  arg3 = *(++temp);
f01008e7:	8b 47 10             	mov    0x10(%edi),%eax
  arg4 = *(++temp);
f01008ea:	8b 57 14             	mov    0x14(%edi),%edx
  arg5 = *(++temp);
f01008ed:	8b 4f 18             	mov    0x18(%edi),%ecx
  uint32_t bytes = (uint32_t)*eip - info.eip_fn_addr;
f01008f0:	8b 77 04             	mov    0x4(%edi),%esi
f01008f3:	2b 75 e0             	sub    -0x20(%ebp),%esi
  while( (ebp) != 0)
f01008f6:	85 ff                	test   %edi,%edi
f01008f8:	0f 84 b3 00 00 00    	je     f01009b1 <mon_backtrace+0xf9>
f01008fe:	89 fb                	mov    %edi,%ebx
  //eip(reg) is return value.
	//ebp+0x4 is the eip's value. Study the calling convention when call test_backtrace and mon_backtrace, it is clear.
  uint32_t* temp;
  temp = ebp;
  temp++;
  uint32_t* eip = temp;
f0100900:	8b 7d bc             	mov    -0x44(%ebp),%edi
  arg4 = *(++temp);
  arg5 = *(++temp);
  uint32_t bytes = (uint32_t)*eip - info.eip_fn_addr;
  while( (ebp) != 0)
	{
    cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n\t", ebp, *eip, arg1, arg2, arg3, arg4, arg5);  
f0100903:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0100907:	89 54 24 18          	mov    %edx,0x18(%esp)
f010090b:	89 44 24 14          	mov    %eax,0x14(%esp)
f010090f:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100912:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100916:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100919:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010091d:	8b 07                	mov    (%edi),%eax
f010091f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100927:	c7 04 24 b4 5b 10 f0 	movl   $0xf0105bb4,(%esp)
f010092e:	e8 47 28 00 00       	call   f010317a <cprintf>
  	//print source file, function name, and addr
    cprintf(" %s:%d:", info.eip_file, info.eip_line);
f0100933:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100936:	89 44 24 08          	mov    %eax,0x8(%esp)
f010093a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010093d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100941:	c7 04 24 32 5a 10 f0 	movl   $0xf0105a32,(%esp)
f0100948:	e8 2d 28 00 00       	call   f010317a <cprintf>
    cprintf(" %.*s", info.eip_fn_namelen, info.eip_fn_name);
f010094d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100950:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100954:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100957:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095b:	c7 04 24 3a 5a 10 f0 	movl   $0xf0105a3a,(%esp)
f0100962:	e8 13 28 00 00       	call   f010317a <cprintf>
    cprintf("+%d\n", bytes);
f0100967:	89 74 24 04          	mov    %esi,0x4(%esp)
f010096b:	c7 04 24 40 5a 10 f0 	movl   $0xf0105a40,(%esp)
f0100972:	e8 03 28 00 00       	call   f010317a <cprintf>
    ebp = (uint32_t*)(*ebp);
f0100977:	8b 1b                	mov    (%ebx),%ebx
    temp = ebp;
		temp++;
    eip = temp;
    debuginfo_eip((uintptr_t)*eip, &info);
f0100979:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010097c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100980:	8b 43 04             	mov    0x4(%ebx),%eax
f0100983:	89 04 24             	mov    %eax,(%esp)
f0100986:	e8 3f 33 00 00       	call   f0103cca <debuginfo_eip>
    bytes = (uint32_t)*eip - info.eip_fn_addr;
f010098b:	8b 73 04             	mov    0x4(%ebx),%esi
f010098e:	2b 75 e0             	sub    -0x20(%ebp),%esi
  	arg1 = *(++temp);
f0100991:	8b 43 08             	mov    0x8(%ebx),%eax
f0100994:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  	arg2 = *(++temp);
f0100997:	8b 43 0c             	mov    0xc(%ebx),%eax
f010099a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  	arg3 = *(++temp);
f010099d:	8b 43 10             	mov    0x10(%ebx),%eax
  	arg4 = *(++temp);
f01009a0:	8b 53 14             	mov    0x14(%ebx),%edx
  	arg5 = *(++temp);
f01009a3:	8b 4b 18             	mov    0x18(%ebx),%ecx
    cprintf(" %s:%d:", info.eip_file, info.eip_line);
    cprintf(" %.*s", info.eip_fn_namelen, info.eip_fn_name);
    cprintf("+%d\n", bytes);
    ebp = (uint32_t*)(*ebp);
    temp = ebp;
		temp++;
f01009a6:	8d 7b 04             	lea    0x4(%ebx),%edi
  arg2 = *(++temp);
  arg3 = *(++temp);
  arg4 = *(++temp);
  arg5 = *(++temp);
  uint32_t bytes = (uint32_t)*eip - info.eip_fn_addr;
  while( (ebp) != 0)
f01009a9:	85 db                	test   %ebx,%ebx
f01009ab:	0f 85 52 ff ff ff    	jne    f0100903 <mon_backtrace+0x4b>
  	arg3 = *(++temp);
  	arg4 = *(++temp);
  	arg5 = *(++temp);
	}
  return 0;
}
f01009b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b6:	83 c4 5c             	add    $0x5c,%esp
f01009b9:	5b                   	pop    %ebx
f01009ba:	5e                   	pop    %esi
f01009bb:	5f                   	pop    %edi
f01009bc:	5d                   	pop    %ebp
f01009bd:	c3                   	ret    

f01009be <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009be:	55                   	push   %ebp
f01009bf:	89 e5                	mov    %esp,%ebp
f01009c1:	57                   	push   %edi
f01009c2:	56                   	push   %esi
f01009c3:	53                   	push   %ebx
f01009c4:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009c7:	c7 04 24 e8 5b 10 f0 	movl   $0xf0105be8,(%esp)
f01009ce:	e8 a7 27 00 00       	call   f010317a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d3:	c7 04 24 0c 5c 10 f0 	movl   $0xf0105c0c,(%esp)
f01009da:	e8 9b 27 00 00       	call   f010317a <cprintf>

if (tf != NULL)
f01009df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009e3:	74 0b                	je     f01009f0 <monitor+0x32>
		print_trapframe(tf);
f01009e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01009e8:	89 04 24             	mov    %eax,(%esp)
f01009eb:	e8 62 2b 00 00       	call   f0103552 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009f0:	c7 04 24 45 5a 10 f0 	movl   $0xf0105a45,(%esp)
f01009f7:	e8 14 3c 00 00       	call   f0104610 <readline>
f01009fc:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	74 ee                	je     f01009f0 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a02:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a09:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a0e:	eb 06                	jmp    f0100a16 <monitor+0x58>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a10:	c6 06 00             	movb   $0x0,(%esi)
f0100a13:	83 c6 01             	add    $0x1,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	74 6a                	je     f0100a87 <monitor+0xc9>
f0100a1d:	0f be c0             	movsbl %al,%eax
f0100a20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a24:	c7 04 24 49 5a 10 f0 	movl   $0xf0105a49,(%esp)
f0100a2b:	e8 55 3e 00 00       	call   f0104885 <strchr>
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	75 dc                	jne    f0100a10 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a34:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a37:	74 4e                	je     f0100a87 <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a39:	83 fb 0f             	cmp    $0xf,%ebx
f0100a3c:	75 16                	jne    f0100a54 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a3e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a45:	00 
f0100a46:	c7 04 24 4e 5a 10 f0 	movl   $0xf0105a4e,(%esp)
f0100a4d:	e8 28 27 00 00       	call   f010317a <cprintf>
f0100a52:	eb 9c                	jmp    f01009f0 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a54:	89 74 9d a8          	mov    %esi,-0x58(%ebp,%ebx,4)
f0100a58:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a5b:	0f b6 06             	movzbl (%esi),%eax
f0100a5e:	84 c0                	test   %al,%al
f0100a60:	75 0c                	jne    f0100a6e <monitor+0xb0>
f0100a62:	eb b2                	jmp    f0100a16 <monitor+0x58>
			buf++;
f0100a64:	83 c6 01             	add    $0x1,%esi
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a67:	0f b6 06             	movzbl (%esi),%eax
f0100a6a:	84 c0                	test   %al,%al
f0100a6c:	74 a8                	je     f0100a16 <monitor+0x58>
f0100a6e:	0f be c0             	movsbl %al,%eax
f0100a71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a75:	c7 04 24 49 5a 10 f0 	movl   $0xf0105a49,(%esp)
f0100a7c:	e8 04 3e 00 00       	call   f0104885 <strchr>
f0100a81:	85 c0                	test   %eax,%eax
f0100a83:	74 df                	je     f0100a64 <monitor+0xa6>
f0100a85:	eb 8f                	jmp    f0100a16 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100a87:	c7 44 9d a8 00 00 00 	movl   $0x0,-0x58(%ebp,%ebx,4)
f0100a8e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a8f:	85 db                	test   %ebx,%ebx
f0100a91:	0f 84 59 ff ff ff    	je     f01009f0 <monitor+0x32>
f0100a97:	bf 60 5c 10 f0       	mov    $0xf0105c60,%edi
f0100a9c:	be 00 00 00 00       	mov    $0x0,%esi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa1:	8b 07                	mov    (%edi),%eax
f0100aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100aaa:	89 04 24             	mov    %eax,(%esp)
f0100aad:	e8 4f 3d 00 00       	call   f0104801 <strcmp>
f0100ab2:	85 c0                	test   %eax,%eax
f0100ab4:	75 24                	jne    f0100ada <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100ab6:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100ab9:	8b 55 08             	mov    0x8(%ebp),%edx
f0100abc:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ac0:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ac3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ac7:	89 1c 24             	mov    %ebx,(%esp)
f0100aca:	ff 14 85 68 5c 10 f0 	call   *-0xfefa398(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ad1:	85 c0                	test   %eax,%eax
f0100ad3:	78 28                	js     f0100afd <monitor+0x13f>
f0100ad5:	e9 16 ff ff ff       	jmp    f01009f0 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ada:	83 c6 01             	add    $0x1,%esi
f0100add:	83 c7 0c             	add    $0xc,%edi
f0100ae0:	83 fe 03             	cmp    $0x3,%esi
f0100ae3:	75 bc                	jne    f0100aa1 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ae5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aec:	c7 04 24 6b 5a 10 f0 	movl   $0xf0105a6b,(%esp)
f0100af3:	e8 82 26 00 00       	call   f010317a <cprintf>
f0100af8:	e9 f3 fe ff ff       	jmp    f01009f0 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100afd:	83 c4 5c             	add    $0x5c,%esp
f0100b00:	5b                   	pop    %ebx
f0100b01:	5e                   	pop    %esi
f0100b02:	5f                   	pop    %edi
f0100b03:	5d                   	pop    %ebp
f0100b04:	c3                   	ret    
	...

f0100b10 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	53                   	push   %ebx
f0100b14:	83 ec 14             	sub    $0x14,%esp
	if (PGNUM(pa) >= npages)
f0100b17:	89 cb                	mov    %ecx,%ebx
f0100b19:	c1 eb 0c             	shr    $0xc,%ebx
f0100b1c:	3b 1d e8 0e 22 f0    	cmp    0xf0220ee8,%ebx
f0100b22:	72 18                	jb     f0100b3c <_kaddr+0x2c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b24:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100b28:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0100b2f:	f0 
f0100b30:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100b34:	89 04 24             	mov    %eax,(%esp)
f0100b37:	e8 04 f5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100b3c:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100b42:	83 c4 14             	add    $0x14,%esp
f0100b45:	5b                   	pop    %ebx
f0100b46:	5d                   	pop    %ebp
f0100b47:	c3                   	ret    

f0100b48 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b48:	55                   	push   %ebp
f0100b49:	89 e5                	mov    %esp,%ebp
f0100b4b:	53                   	push   %ebx
f0100b4c:	83 ec 04             	sub    $0x4,%esp
f0100b4f:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b51:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b54:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
	{
		return ~0;
f0100b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b5c:	f6 c1 01             	test   $0x1,%cl
f0100b5f:	74 37                	je     f0100b98 <check_va2pa+0x50>
	{
		return ~0;
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b61:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b67:	ba a5 03 00 00       	mov    $0x3a5,%edx
f0100b6c:	b8 61 62 10 f0       	mov    $0xf0106261,%eax
f0100b71:	e8 9a ff ff ff       	call   f0100b10 <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100b76:	c1 eb 0c             	shr    $0xc,%ebx
f0100b79:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100b7f:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b82:	89 c2                	mov    %eax,%edx
f0100b84:	83 e2 01             	and    $0x1,%edx
 //   cprintf("check_va2pa:2\n");
		return ~0;
}

	//cprintf("check_va2pa:3   : %08x\n", PTE_ADDR(p[PTX(va)]));
	return PTE_ADDR(p[PTX(va)]);
f0100b87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b8c:	85 d2                	test   %edx,%edx
f0100b8e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b93:	0f 44 c2             	cmove  %edx,%eax
f0100b96:	eb 00                	jmp    f0100b98 <check_va2pa+0x50>
}
f0100b98:	83 c4 04             	add    $0x4,%esp
f0100b9b:	5b                   	pop    %ebx
f0100b9c:	5d                   	pop    %ebp
f0100b9d:	c3                   	ret    

f0100b9e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b9e:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ba0:	83 3d 3c 02 22 f0 00 	cmpl   $0x0,0xf022023c
f0100ba7:	75 1e                	jne    f0100bc7 <boot_alloc+0x29>
		extern char end[];
		page_num = 0;
f0100ba9:	c7 05 40 02 22 f0 00 	movl   $0x0,0xf0220240
f0100bb0:	00 00 00 
    //round up to the nearest multiple of PGSIZE
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100bb3:	b8 07 30 26 f0       	mov    $0xf0263007,%eax
f0100bb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bbd:	a3 3c 02 22 f0       	mov    %eax,0xf022023c
    initial_nextfree = nextfree;
f0100bc2:	a3 44 02 22 f0       	mov    %eax,0xf0220244
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
  if( n == 0 )
f0100bc7:	85 d2                	test   %edx,%edx
f0100bc9:	75 2d                	jne    f0100bf8 <boot_alloc+0x5a>
  {
		result = nextfree;
f0100bcb:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
f0100bd0:	c3                   	ret    
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bd1:	55                   	push   %ebp
f0100bd2:	89 e5                	mov    %esp,%ebp
f0100bd4:	83 ec 18             	sub    $0x18,%esp
    nextfree += n;
	  nextfree = ROUNDUP( nextfree, PGSIZE);	
    page_num = ((nextfree - initial_nextfree) / PGSIZE );
    if( page_num > npages )
    {
			nextfree = result;
f0100bd7:	a3 3c 02 22 f0       	mov    %eax,0xf022023c
		  panic("boot_alloc: out of memory");
f0100bdc:	c7 44 24 08 6d 62 10 	movl   $0xf010626d,0x8(%esp)
f0100be3:	f0 
f0100be4:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0100beb:	00 
f0100bec:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0100bf3:	e8 48 f4 ff ff       	call   f0100040 <_panic>
		result = nextfree;
  }
  if( n > 0 )
  {
		//check if it is out of memory
    result = nextfree;
f0100bf8:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
    nextfree += n;
	  nextfree = ROUNDUP( nextfree, PGSIZE);	
f0100bfd:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100c04:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c0a:	89 15 3c 02 22 f0    	mov    %edx,0xf022023c
    page_num = ((nextfree - initial_nextfree) / PGSIZE );
f0100c10:	2b 15 44 02 22 f0    	sub    0xf0220244,%edx
f0100c16:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
f0100c1c:	85 d2                	test   %edx,%edx
f0100c1e:	0f 48 d1             	cmovs  %ecx,%edx
f0100c21:	c1 fa 0c             	sar    $0xc,%edx
f0100c24:	89 15 40 02 22 f0    	mov    %edx,0xf0220240
    if( page_num > npages )
f0100c2a:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0100c30:	77 9f                	ja     f0100bd1 <boot_alloc+0x33>
			nextfree = result;
		  panic("boot_alloc: out of memory");
		}
  }
	return result;
}
f0100c32:	f3 c3                	repz ret 

f0100c34 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c34:	55                   	push   %ebp
f0100c35:	89 e5                	mov    %esp,%ebp
f0100c37:	56                   	push   %esi
f0100c38:	53                   	push   %ebx
f0100c39:	83 ec 10             	sub    $0x10,%esp
f0100c3c:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c3e:	89 04 24             	mov    %eax,(%esp)
f0100c41:	e8 c6 23 00 00       	call   f010300c <mc146818_read>
f0100c46:	89 c6                	mov    %eax,%esi
f0100c48:	83 c3 01             	add    $0x1,%ebx
f0100c4b:	89 1c 24             	mov    %ebx,(%esp)
f0100c4e:	e8 b9 23 00 00       	call   f010300c <mc146818_read>
f0100c53:	c1 e0 08             	shl    $0x8,%eax
f0100c56:	09 f0                	or     %esi,%eax
}
f0100c58:	83 c4 10             	add    $0x10,%esp
f0100c5b:	5b                   	pop    %ebx
f0100c5c:	5e                   	pop    %esi
f0100c5d:	5d                   	pop    %ebp
f0100c5e:	c3                   	ret    

f0100c5f <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c5f:	2b 05 f0 0e 22 f0    	sub    0xf0220ef0,%eax
f0100c65:	c1 f8 03             	sar    $0x3,%eax
f0100c68:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c6b:	89 c2                	mov    %eax,%edx
f0100c6d:	c1 ea 0c             	shr    $0xc,%edx
f0100c70:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0100c76:	72 26                	jb     f0100c9e <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100c78:	55                   	push   %ebp
f0100c79:	89 e5                	mov    %esp,%ebp
f0100c7b:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c82:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0100c89:	f0 
f0100c8a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c91:	00 
f0100c92:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0100c99:	e8 a2 f3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100c9e:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ca3:	c3                   	ret    

f0100ca4 <page_init>:
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100ca4:	83 3d e8 0e 22 f0 00 	cmpl   $0x0,0xf0220ee8
f0100cab:	0f 84 9a 00 00 00    	je     f0100d4b <page_init+0xa7>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cb1:	55                   	push   %ebp
f0100cb2:	89 e5                	mov    %esp,%ebp
f0100cb4:	57                   	push   %edi
f0100cb5:	56                   	push   %esi
f0100cb6:	53                   	push   %ebx
f0100cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  {
    if( i == 0 )
f0100cbf:	85 db                	test   %ebx,%ebx
f0100cc1:	75 13                	jne    f0100cd6 <page_init+0x32>
		{
			pages[i].pp_ref = 1;
f0100cc3:	a1 f0 0e 22 f0       	mov    0xf0220ef0,%eax
f0100cc8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
      pages[i].pp_link = NULL;
f0100cce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			continue;
f0100cd4:	eb 5f                	jmp    f0100d35 <page_init+0x91>
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f0100cd6:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cdd:	89 f7                	mov    %esi,%edi
f0100cdf:	c1 e7 09             	shl    $0x9,%edi
			pages[i].pp_ref = 1;
      pages[i].pp_link = NULL;
			continue;
		}
    physaddr_t temp_physaddr = page2pa(&pages[i]);
    uintptr_t temp_boot_alloc = (uintptr_t)boot_alloc(0);
f0100ce2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce7:	e8 b2 fe ff ff       	call   f0100b9e <boot_alloc>
    //because this is physical address.
    physaddr_t temp_addr = (physaddr_t)(temp_boot_alloc - KERNBASE);
    if( (temp_physaddr >0 && temp_physaddr < IOPHYSMEM) || temp_physaddr >= temp_addr )
f0100cec:	8d 57 ff             	lea    -0x1(%edi),%edx
f0100cef:	81 fa fe ff 09 00    	cmp    $0x9fffe,%edx
f0100cf5:	76 09                	jbe    f0100d00 <page_init+0x5c>
			continue;
		}
    physaddr_t temp_physaddr = page2pa(&pages[i]);
    uintptr_t temp_boot_alloc = (uintptr_t)boot_alloc(0);
    //because this is physical address.
    physaddr_t temp_addr = (physaddr_t)(temp_boot_alloc - KERNBASE);
f0100cf7:	05 00 00 00 10       	add    $0x10000000,%eax
    if( (temp_physaddr >0 && temp_physaddr < IOPHYSMEM) || temp_physaddr >= temp_addr )
f0100cfc:	39 f8                	cmp    %edi,%eax
f0100cfe:	77 23                	ja     f0100d23 <page_init+0x7f>
		{
		pages[i].pp_ref = 0;
f0100d00:	a1 f0 0e 22 f0       	mov    0xf0220ef0,%eax
f0100d05:	01 f0                	add    %esi,%eax
f0100d07:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f0100d0d:	8b 15 48 02 22 f0    	mov    0xf0220248,%edx
f0100d13:	89 10                	mov    %edx,(%eax)
		page_free_list = &pages[i];
f0100d15:	03 35 f0 0e 22 f0    	add    0xf0220ef0,%esi
f0100d1b:	89 35 48 02 22 f0    	mov    %esi,0xf0220248
f0100d21:	eb 12                	jmp    f0100d35 <page_init+0x91>
		}
		else
		{
			pages[i].pp_ref = 1;
f0100d23:	03 35 f0 0e 22 f0    	add    0xf0220ef0,%esi
f0100d29:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f0100d2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100d35:	83 c3 01             	add    $0x1,%ebx
f0100d38:	39 1d e8 0e 22 f0    	cmp    %ebx,0xf0220ee8
f0100d3e:	0f 87 7b ff ff ff    	ja     f0100cbf <page_init+0x1b>
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	}
}
f0100d44:	83 c4 0c             	add    $0xc,%esp
f0100d47:	5b                   	pop    %ebx
f0100d48:	5e                   	pop    %esi
f0100d49:	5f                   	pop    %edi
f0100d4a:	5d                   	pop    %ebp
f0100d4b:	f3 c3                	repz ret 

f0100d4d <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d4d:	55                   	push   %ebp
f0100d4e:	89 e5                	mov    %esp,%ebp
f0100d50:	53                   	push   %ebx
f0100d51:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
  struct PageInfo* temp;
	//returns NULL if there is no free memory
	if( page_free_list == NULL) 
f0100d54:	8b 1d 48 02 22 f0    	mov    0xf0220248,%ebx
f0100d5a:	85 db                	test   %ebx,%ebx
f0100d5c:	74 71                	je     f0100dcf <page_alloc+0x82>
		return NULL;
  else
	{
		temp = page_free_list;
    page_free_list = temp->pp_link;
f0100d5e:	8b 03                	mov    (%ebx),%eax
f0100d60:	a3 48 02 22 f0       	mov    %eax,0xf0220248
    temp->pp_link = NULL;
f0100d65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    temp->pp_ref = 0;
f0100d6b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	}
  if(alloc_flags & ALLOC_ZERO)
f0100d71:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d75:	74 58                	je     f0100dcf <page_alloc+0x82>
f0100d77:	89 d8                	mov    %ebx,%eax
f0100d79:	2b 05 f0 0e 22 f0    	sub    0xf0220ef0,%eax
f0100d7f:	c1 f8 03             	sar    $0x3,%eax
f0100d82:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d85:	89 c2                	mov    %eax,%edx
f0100d87:	c1 ea 0c             	shr    $0xc,%edx
f0100d8a:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0100d90:	72 20                	jb     f0100db2 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d96:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0100d9d:	f0 
f0100d9e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100da5:	00 
f0100da6:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0100dad:	e8 8e f2 ff ff       	call   f0100040 <_panic>
	{
		//do not use page2pa but page2kva
		memset(page2kva(temp), '\0', PGSIZE);
f0100db2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100db9:	00 
f0100dba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100dc1:	00 
	return (void *)(pa + KERNBASE);
f0100dc2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dc7:	89 04 24             	mov    %eax,(%esp)
f0100dca:	e8 16 3b 00 00       	call   f01048e5 <memset>
	}
	return temp;
}
f0100dcf:	89 d8                	mov    %ebx,%eax
f0100dd1:	83 c4 14             	add    $0x14,%esp
f0100dd4:	5b                   	pop    %ebx
f0100dd5:	5d                   	pop    %ebp
f0100dd6:	c3                   	ret    

f0100dd7 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100dd7:	55                   	push   %ebp
f0100dd8:	89 e5                	mov    %esp,%ebp
f0100dda:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
  if(pp->pp_ref <= 0)
f0100ddd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100de2:	75 0d                	jne    f0100df1 <page_free+0x1a>
  {
  pp->pp_link =page_free_list;
f0100de4:	8b 15 48 02 22 f0    	mov    0xf0220248,%edx
f0100dea:	89 10                	mov    %edx,(%eax)
  page_free_list = pp;
f0100dec:	a3 48 02 22 f0       	mov    %eax,0xf0220248
  }
}
f0100df1:	5d                   	pop    %ebp
f0100df2:	c3                   	ret    

f0100df3 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100df3:	55                   	push   %ebp
f0100df4:	89 e5                	mov    %esp,%ebp
f0100df6:	83 ec 04             	sub    $0x4,%esp
f0100df9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100dfc:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100e00:	83 ea 01             	sub    $0x1,%edx
f0100e03:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100e07:	66 85 d2             	test   %dx,%dx
f0100e0a:	75 08                	jne    f0100e14 <page_decref+0x21>
		page_free(pp);
f0100e0c:	89 04 24             	mov    %eax,(%esp)
f0100e0f:	e8 c3 ff ff ff       	call   f0100dd7 <page_free>
}
f0100e14:	c9                   	leave  
f0100e15:	c3                   	ret    

f0100e16 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e16:	55                   	push   %ebp
f0100e17:	89 e5                	mov    %esp,%ebp
f0100e19:	56                   	push   %esi
f0100e1a:	53                   	push   %ebx
f0100e1b:	83 ec 10             	sub    $0x10,%esp
f0100e1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
  pde_t* page_dir_entry = pgdir + PDX(va);
f0100e21:	89 de                	mov    %ebx,%esi
f0100e23:	c1 ee 16             	shr    $0x16,%esi
f0100e26:	c1 e6 02             	shl    $0x2,%esi
f0100e29:	03 75 08             	add    0x8(%ebp),%esi
  pte_t* page_table = (pte_t*)PTE_ADDR(*page_dir_entry);
  if( page_table== NULL)
f0100e2c:	8b 16                	mov    (%esi),%edx
f0100e2e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e34:	75 7c                	jne    f0100eb2 <pgdir_walk+0x9c>
  {
    //the va's page table does not exist
		if(create)
f0100e36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e3a:	0f 84 b2 00 00 00    	je     f0100ef2 <pgdir_walk+0xdc>
		{
			struct PageInfo* temp = page_alloc(ALLOC_ZERO);
f0100e40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100e47:	e8 01 ff ff ff       	call   f0100d4d <page_alloc>
  		if(temp != NULL)
f0100e4c:	85 c0                	test   %eax,%eax
f0100e4e:	0f 84 a5 00 00 00    	je     f0100ef9 <pgdir_walk+0xe3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e54:	89 c2                	mov    %eax,%edx
f0100e56:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0100e5c:	c1 fa 03             	sar    $0x3,%edx
f0100e5f:	c1 e2 0c             	shl    $0xc,%edx
			{
				pgdir[PDX(va)] = page2pa(temp)|PTE_P|PTE_W;
f0100e62:	83 ca 03             	or     $0x3,%edx
f0100e65:	89 16                	mov    %edx,(%esi)
				temp->pp_ref ++;
f0100e67:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				page_table = (pte_t*)PTE_ADDR(pgdir[PDX(va)]);
f0100e6c:	8b 06                	mov    (%esi),%eax
f0100e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
f0100e73:	c1 eb 0a             	shr    $0xa,%ebx
f0100e76:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100e7c:	01 d8                	add    %ebx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e7e:	89 c2                	mov    %eax,%edx
f0100e80:	c1 ea 0c             	shr    $0xc,%edx
f0100e83:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0100e89:	72 20                	jb     f0100eab <pgdir_walk+0x95>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e8f:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0100e96:	f0 
f0100e97:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f0100e9e:	00 
f0100e9f:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0100ea6:	e8 95 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100eab:	2d 00 00 00 10       	sub    $0x10000000,%eax
       return addr;
f0100eb0:	eb 4c                	jmp    f0100efe <pgdir_walk+0xe8>
			}
 			else return NULL;
		}
		else return NULL;
  }
  else return KADDR((uintptr_t)(page_table + PTX(va)));
f0100eb2:	c1 eb 0a             	shr    $0xa,%ebx
f0100eb5:	89 d8                	mov    %ebx,%eax
f0100eb7:	25 fc 0f 00 00       	and    $0xffc,%eax
f0100ebc:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ebe:	89 c2                	mov    %eax,%edx
f0100ec0:	c1 ea 0c             	shr    $0xc,%edx
f0100ec3:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0100ec9:	72 20                	jb     f0100eeb <pgdir_walk+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ecb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ecf:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0100ed6:	f0 
f0100ed7:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
f0100ede:	00 
f0100edf:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0100ee6:	e8 55 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100eeb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ef0:	eb 0c                	jmp    f0100efe <pgdir_walk+0xe8>
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
       return addr;
			}
 			else return NULL;
		}
		else return NULL;
f0100ef2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef7:	eb 05                	jmp    f0100efe <pgdir_walk+0xe8>
				temp->pp_ref ++;
				page_table = (pte_t*)PTE_ADDR(pgdir[PDX(va)]);
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
       return addr;
			}
 			else return NULL;
f0100ef9:	b8 00 00 00 00       	mov    $0x0,%eax
		}
		else return NULL;
  }
  else return KADDR((uintptr_t)(page_table + PTX(va)));
}
f0100efe:	83 c4 10             	add    $0x10,%esp
f0100f01:	5b                   	pop    %ebx
f0100f02:	5e                   	pop    %esi
f0100f03:	5d                   	pop    %ebp
f0100f04:	c3                   	ret    

f0100f05 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
f0100f08:	53                   	push   %ebx
f0100f09:	83 ec 14             	sub    $0x14,%esp
f0100f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// since it requires the page corresponding to 'va', it has no needs to use PGOFF(va) to get actual physical address.
	pte_t* page_entry_addr = pgdir_walk(pgdir, va, 0);
f0100f0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f16:	00 
f0100f17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f21:	89 04 24             	mov    %eax,(%esp)
f0100f24:	e8 ed fe ff ff       	call   f0100e16 <pgdir_walk>
f0100f29:	89 c2                	mov    %eax,%edx
	if(page_entry_addr != NULL)
f0100f2b:	85 c0                	test   %eax,%eax
f0100f2d:	74 41                	je     f0100f70 <page_lookup+0x6b>
{
	physaddr_t page_addr = PTE_ADDR(*(page_entry_addr));
  if(page_addr !=0)
f0100f2f:	8b 00                	mov    (%eax),%eax
f0100f31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f36:	74 3f                	je     f0100f77 <page_lookup+0x72>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f38:	c1 e8 0c             	shr    $0xc,%eax
f0100f3b:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f0100f41:	72 1c                	jb     f0100f5f <page_lookup+0x5a>
		panic("pa2page called with invalid pa");
f0100f43:	c7 44 24 08 84 5c 10 	movl   $0xf0105c84,0x8(%esp)
f0100f4a:	f0 
f0100f4b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0100f52:	00 
f0100f53:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0100f5a:	e8 e1 f0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100f5f:	8b 0d f0 0e 22 f0    	mov    0xf0220ef0,%ecx
f0100f65:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
	{
		//page
	  struct PageInfo* temp = pa2page(page_addr);
	  if(pte_store != 0) *pte_store = page_entry_addr;
f0100f68:	85 db                	test   %ebx,%ebx
f0100f6a:	74 10                	je     f0100f7c <page_lookup+0x77>
f0100f6c:	89 13                	mov    %edx,(%ebx)
f0100f6e:	eb 0c                	jmp    f0100f7c <page_lookup+0x77>
		return temp;	
	}	
}
	return NULL;
f0100f70:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f75:	eb 05                	jmp    f0100f7c <page_lookup+0x77>
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f7c:	83 c4 14             	add    $0x14,%esp
f0100f7f:	5b                   	pop    %ebx
f0100f80:	5d                   	pop    %ebp
f0100f81:	c3                   	ret    

f0100f82 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f82:	55                   	push   %ebp
f0100f83:	89 e5                	mov    %esp,%ebp
f0100f85:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
//<<<<<<< HEAD
	if (!curenv || curenv->env_pgdir == pgdir)
f0100f88:	e8 ff 3f 00 00       	call   f0104f8c <cpunum>
f0100f8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0100f90:	83 b8 28 10 22 f0 00 	cmpl   $0x0,-0xfddefd8(%eax)
f0100f97:	74 16                	je     f0100faf <tlb_invalidate+0x2d>
f0100f99:	e8 ee 3f 00 00       	call   f0104f8c <cpunum>
f0100f9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0100fa1:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0100fa7:	8b 55 08             	mov    0x8(%ebp),%edx
f0100faa:	39 50 60             	cmp    %edx,0x60(%eax)
f0100fad:	75 06                	jne    f0100fb5 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100faf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb2:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100fb5:	c9                   	leave  
f0100fb6:	c3                   	ret    

f0100fb7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100fb7:	55                   	push   %ebp
f0100fb8:	89 e5                	mov    %esp,%ebp
f0100fba:	83 ec 28             	sub    $0x28,%esp
f0100fbd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100fc0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100fc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100fc6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* page_table_entry;
	struct PageInfo* temp = page_lookup(pgdir, va, &page_table_entry);
f0100fc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fcc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fd0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fd4:	89 1c 24             	mov    %ebx,(%esp)
f0100fd7:	e8 29 ff ff ff       	call   f0100f05 <page_lookup>
	if(temp != NULL)
f0100fdc:	85 c0                	test   %eax,%eax
f0100fde:	74 1d                	je     f0100ffd <page_remove+0x46>
	{
		page_decref(temp);
f0100fe0:	89 04 24             	mov    %eax,(%esp)
f0100fe3:	e8 0b fe ff ff       	call   f0100df3 <page_decref>
		*page_table_entry = 0;
f0100fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100feb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);	
f0100ff1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ff5:	89 1c 24             	mov    %ebx,(%esp)
f0100ff8:	e8 85 ff ff ff       	call   f0100f82 <tlb_invalidate>
	}
}
f0100ffd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101000:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101003:	89 ec                	mov    %ebp,%esp
f0101005:	5d                   	pop    %ebp
f0101006:	c3                   	ret    

f0101007 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101007:	55                   	push   %ebp
f0101008:	89 e5                	mov    %esp,%ebp
f010100a:	83 ec 28             	sub    $0x28,%esp
f010100d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101010:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101013:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101016:	8b 75 08             	mov    0x8(%ebp),%esi
f0101019:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
  pte_t* page_addr_temp = (pte_t*)PTE_ADDR(pgdir_walk(pgdir, va, 1));
f010101c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101023:	00 
f0101024:	8b 45 10             	mov    0x10(%ebp),%eax
f0101027:	89 44 24 04          	mov    %eax,0x4(%esp)
f010102b:	89 34 24             	mov    %esi,(%esp)
f010102e:	e8 e3 fd ff ff       	call   f0100e16 <pgdir_walk>
  if(page_addr_temp == NULL)
f0101033:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101038:	74 6e                	je     f01010a8 <page_insert+0xa1>
	{
		return -E_NO_MEM;
	}
	
	//check if the page has exists
  if(PTE_ADDR(*(page_addr_temp+PTX(va))) == page2pa(pp))
f010103a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010103d:	c1 ef 0a             	shr    $0xa,%edi
f0101040:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0101046:	01 c7                	add    %eax,%edi
f0101048:	8b 07                	mov    (%edi),%eax
f010104a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010104f:	89 da                	mov    %ebx,%edx
f0101051:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0101057:	c1 fa 03             	sar    $0x3,%edx
f010105a:	c1 e2 0c             	shl    $0xc,%edx
f010105d:	39 d0                	cmp    %edx,%eax
f010105f:	75 07                	jne    f0101068 <page_insert+0x61>
	{
		pp->pp_ref --;
f0101061:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101066:	eb 13                	jmp    f010107b <page_insert+0x74>
	}
  //check if there is other page
  else if(PTE_ADDR(*(page_addr_temp+PTX(va))) != 0)
f0101068:	85 c0                	test   %eax,%eax
f010106a:	74 0f                	je     f010107b <page_insert+0x74>
	{
		page_remove(pgdir,va);
f010106c:	8b 45 10             	mov    0x10(%ebp),%eax
f010106f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101073:	89 34 24             	mov    %esi,(%esp)
f0101076:	e8 3c ff ff ff       	call   f0100fb7 <page_remove>
	}
  pgdir[PDX(va)] = pgdir[PDX(va)]|perm|PTE_P;
f010107b:	8b 55 10             	mov    0x10(%ebp),%edx
f010107e:	c1 ea 16             	shr    $0x16,%edx
f0101081:	8b 45 14             	mov    0x14(%ebp),%eax
f0101084:	83 c8 01             	or     $0x1,%eax
f0101087:	09 04 96             	or     %eax,(%esi,%edx,4)
f010108a:	89 da                	mov    %ebx,%edx
f010108c:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0101092:	c1 fa 03             	sar    $0x3,%edx
f0101095:	c1 e2 0c             	shl    $0xc,%edx
  //why should continue offset!!!! 	
	*(page_addr_temp+PTX(va)) = page2pa(pp)|perm|PTE_P;
f0101098:	09 d0                	or     %edx,%eax
f010109a:	89 07                	mov    %eax,(%edi)
	pp->pp_ref++;
f010109c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01010a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a6:	eb 05                	jmp    f01010ad <page_insert+0xa6>
{
	// Fill this function in
  pte_t* page_addr_temp = (pte_t*)PTE_ADDR(pgdir_walk(pgdir, va, 1));
  if(page_addr_temp == NULL)
	{
		return -E_NO_MEM;
f01010a8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  pgdir[PDX(va)] = pgdir[PDX(va)]|perm|PTE_P;
  //why should continue offset!!!! 	
	*(page_addr_temp+PTX(va)) = page2pa(pp)|perm|PTE_P;
	pp->pp_ref++;
	return 0;
}
f01010ad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01010b0:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01010b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01010b6:	89 ec                	mov    %ebp,%esp
f01010b8:	5d                   	pop    %ebp
f01010b9:	c3                   	ret    

f01010ba <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01010ba:	55                   	push   %ebp
f01010bb:	89 e5                	mov    %esp,%ebp
f01010bd:	83 ec 18             	sub    $0x18,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	panic("mmio_map_region not implemented");
f01010c0:	c7 44 24 08 a4 5c 10 	movl   $0xf0105ca4,0x8(%esp)
f01010c7:	f0 
f01010c8:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f01010cf:	00 
f01010d0:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01010d7:	e8 64 ef ff ff       	call   f0100040 <_panic>

f01010dc <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010dc:	55                   	push   %ebp
f01010dd:	89 e5                	mov    %esp,%ebp
f01010df:	57                   	push   %edi
f01010e0:	56                   	push   %esi
f01010e1:	53                   	push   %ebx
f01010e2:	83 ec 5c             	sub    $0x5c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010e5:	b8 15 00 00 00       	mov    $0x15,%eax
f01010ea:	e8 45 fb ff ff       	call   f0100c34 <nvram_read>
f01010ef:	c1 e0 0a             	shl    $0xa,%eax
f01010f2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010f8:	85 c0                	test   %eax,%eax
f01010fa:	0f 48 c2             	cmovs  %edx,%eax
f01010fd:	c1 f8 0c             	sar    $0xc,%eax
f0101100:	a3 38 02 22 f0       	mov    %eax,0xf0220238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101105:	b8 17 00 00 00       	mov    $0x17,%eax
f010110a:	e8 25 fb ff ff       	call   f0100c34 <nvram_read>
f010110f:	c1 e0 0a             	shl    $0xa,%eax
f0101112:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101118:	85 c0                	test   %eax,%eax
f010111a:	0f 48 c2             	cmovs  %edx,%eax
f010111d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101120:	85 c0                	test   %eax,%eax
f0101122:	74 0e                	je     f0101132 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101124:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010112a:	89 15 e8 0e 22 f0    	mov    %edx,0xf0220ee8
f0101130:	eb 0c                	jmp    f010113e <mem_init+0x62>
	else
		npages = npages_basemem;
f0101132:	8b 15 38 02 22 f0    	mov    0xf0220238,%edx
f0101138:	89 15 e8 0e 22 f0    	mov    %edx,0xf0220ee8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010113e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101141:	c1 e8 0a             	shr    $0xa,%eax
f0101144:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101148:	a1 38 02 22 f0       	mov    0xf0220238,%eax
f010114d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101150:	c1 e8 0a             	shr    $0xa,%eax
f0101153:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101157:	a1 e8 0e 22 f0       	mov    0xf0220ee8,%eax
f010115c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010115f:	c1 e8 0a             	shr    $0xa,%eax
f0101162:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101166:	c7 04 24 c4 5c 10 f0 	movl   $0xf0105cc4,(%esp)
f010116d:	e8 08 20 00 00       	call   f010317a <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101172:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101177:	e8 22 fa ff ff       	call   f0100b9e <boot_alloc>
f010117c:	a3 ec 0e 22 f0       	mov    %eax,0xf0220eec
	memset(kern_pgdir, 0, PGSIZE);
f0101181:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101188:	00 
f0101189:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101190:	00 
f0101191:	89 04 24             	mov    %eax,(%esp)
f0101194:	e8 4c 37 00 00       	call   f01048e5 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101199:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010119e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011a3:	77 20                	ja     f01011c5 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011a9:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f01011b0:	f0 
f01011b1:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
f01011b8:	00 
f01011b9:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01011c0:	e8 7b ee ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01011c5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011cb:	83 ca 05             	or     $0x5,%edx
f01011ce:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
  pages = (struct PageInfo*)boot_alloc( npages * sizeof(struct PageInfo));
f01011d4:	a1 e8 0e 22 f0       	mov    0xf0220ee8,%eax
f01011d9:	c1 e0 03             	shl    $0x3,%eax
f01011dc:	e8 bd f9 ff ff       	call   f0100b9e <boot_alloc>
f01011e1:	a3 f0 0e 22 f0       	mov    %eax,0xf0220ef0
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
  envs = (struct Env*)boot_alloc( NENV * sizeof(struct Env));
f01011e6:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01011eb:	e8 ae f9 ff ff       	call   f0100b9e <boot_alloc>
f01011f0:	a3 50 02 22 f0       	mov    %eax,0xf0220250
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01011f5:	e8 aa fa ff ff       	call   f0100ca4 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01011fa:	a1 48 02 22 f0       	mov    0xf0220248,%eax
f01011ff:	85 c0                	test   %eax,%eax
f0101201:	75 1c                	jne    f010121f <mem_init+0x143>
		panic("'page_free_list' is a null pointer!");
f0101203:	c7 44 24 08 00 5d 10 	movl   $0xf0105d00,0x8(%esp)
f010120a:	f0 
f010120b:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0101212:	00 
f0101213:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010121a:	e8 21 ee ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010121f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101222:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101225:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101228:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010122b:	89 c2                	mov    %eax,%edx
f010122d:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101233:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101239:	0f 95 c2             	setne  %dl
f010123c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f010123f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101243:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101245:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101249:	8b 00                	mov    (%eax),%eax
f010124b:	85 c0                	test   %eax,%eax
f010124d:	75 dc                	jne    f010122b <mem_init+0x14f>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010124f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101252:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101258:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010125b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010125e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101260:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0101263:	89 1d 48 02 22 f0    	mov    %ebx,0xf0220248
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101269:	85 db                	test   %ebx,%ebx
f010126b:	74 68                	je     f01012d5 <mem_init+0x1f9>
f010126d:	89 d8                	mov    %ebx,%eax
f010126f:	2b 05 f0 0e 22 f0    	sub    0xf0220ef0,%eax
f0101275:	c1 f8 03             	sar    $0x3,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101278:	89 c2                	mov    %eax,%edx
f010127a:	c1 e2 0c             	shl    $0xc,%edx
f010127d:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0101282:	75 4b                	jne    f01012cf <mem_init+0x1f3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101284:	89 d0                	mov    %edx,%eax
f0101286:	c1 e8 0c             	shr    $0xc,%eax
f0101289:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f010128f:	72 20                	jb     f01012b1 <mem_init+0x1d5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101291:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101295:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f010129c:	f0 
f010129d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012a4:	00 
f01012a5:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f01012ac:	e8 8f ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01012b1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01012b8:	00 
f01012b9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01012c0:	00 
	return (void *)(pa + KERNBASE);
f01012c1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01012c7:	89 14 24             	mov    %edx,(%esp)
f01012ca:	e8 16 36 00 00       	call   f01048e5 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012cf:	8b 1b                	mov    (%ebx),%ebx
f01012d1:	85 db                	test   %ebx,%ebx
f01012d3:	75 98                	jne    f010126d <mem_init+0x191>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01012d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01012da:	e8 bf f8 ff ff       	call   f0100b9e <boot_alloc>
f01012df:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012e2:	a1 48 02 22 f0       	mov    0xf0220248,%eax
f01012e7:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01012ea:	85 c0                	test   %eax,%eax
f01012ec:	0f 84 2d 02 00 00    	je     f010151f <mem_init+0x443>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012f2:	8b 3d f0 0e 22 f0    	mov    0xf0220ef0,%edi
f01012f8:	39 f8                	cmp    %edi,%eax
f01012fa:	72 53                	jb     f010134f <mem_init+0x273>
		assert(pp < pages + npages);
f01012fc:	8b 15 e8 0e 22 f0    	mov    0xf0220ee8,%edx
f0101302:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0101305:	8d 0c d7             	lea    (%edi,%edx,8),%ecx
f0101308:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010130b:	39 c8                	cmp    %ecx,%eax
f010130d:	73 69                	jae    f0101378 <mem_init+0x29c>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010130f:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0101312:	29 f8                	sub    %edi,%eax
f0101314:	a8 07                	test   $0x7,%al
f0101316:	0f 85 89 00 00 00    	jne    f01013a5 <mem_init+0x2c9>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010131c:	c1 f8 03             	sar    $0x3,%eax
f010131f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101322:	85 c0                	test   %eax,%eax
f0101324:	0f 84 a9 00 00 00    	je     f01013d3 <mem_init+0x2f7>
		assert(page2pa(pp) != IOPHYSMEM);
f010132a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010132f:	0f 84 c9 00 00 00    	je     f01013fe <mem_init+0x322>
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101335:	8b 55 c0             	mov    -0x40(%ebp),%edx
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101338:	bb 00 00 00 00       	mov    $0x0,%ebx
f010133d:	be 00 00 00 00       	mov    $0x0,%esi
f0101342:	89 7d b0             	mov    %edi,-0x50(%ebp)
f0101345:	e9 d8 00 00 00       	jmp    f0101422 <mem_init+0x346>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010134a:	3b 55 b0             	cmp    -0x50(%ebp),%edx
f010134d:	73 24                	jae    f0101373 <mem_init+0x297>
f010134f:	c7 44 24 0c 95 62 10 	movl   $0xf0106295,0xc(%esp)
f0101356:	f0 
f0101357:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010135e:	f0 
f010135f:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101366:	00 
f0101367:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010136e:	e8 cd ec ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101373:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101376:	72 24                	jb     f010139c <mem_init+0x2c0>
f0101378:	c7 44 24 0c b6 62 10 	movl   $0xf01062b6,0xc(%esp)
f010137f:	f0 
f0101380:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101387:	f0 
f0101388:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f010138f:	00 
f0101390:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101397:	e8 a4 ec ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010139c:	89 d0                	mov    %edx,%eax
f010139e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01013a1:	a8 07                	test   $0x7,%al
f01013a3:	74 24                	je     f01013c9 <mem_init+0x2ed>
f01013a5:	c7 44 24 0c 24 5d 10 	movl   $0xf0105d24,0xc(%esp)
f01013ac:	f0 
f01013ad:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01013b4:	f0 
f01013b5:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f01013bc:	00 
f01013bd:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01013c4:	e8 77 ec ff ff       	call   f0100040 <_panic>
f01013c9:	c1 f8 03             	sar    $0x3,%eax
f01013cc:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01013cf:	85 c0                	test   %eax,%eax
f01013d1:	75 24                	jne    f01013f7 <mem_init+0x31b>
f01013d3:	c7 44 24 0c ca 62 10 	movl   $0xf01062ca,0xc(%esp)
f01013da:	f0 
f01013db:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01013e2:	f0 
f01013e3:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f01013ea:	00 
f01013eb:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01013f2:	e8 49 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013f7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01013fc:	75 24                	jne    f0101422 <mem_init+0x346>
f01013fe:	c7 44 24 0c db 62 10 	movl   $0xf01062db,0xc(%esp)
f0101405:	f0 
f0101406:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010140d:	f0 
f010140e:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0101415:	00 
f0101416:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010141d:	e8 1e ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101422:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101427:	75 24                	jne    f010144d <mem_init+0x371>
f0101429:	c7 44 24 0c 58 5d 10 	movl   $0xf0105d58,0xc(%esp)
f0101430:	f0 
f0101431:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101438:	f0 
f0101439:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0101440:	00 
f0101441:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101448:	e8 f3 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010144d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101452:	75 24                	jne    f0101478 <mem_init+0x39c>
f0101454:	c7 44 24 0c f4 62 10 	movl   $0xf01062f4,0xc(%esp)
f010145b:	f0 
f010145c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101463:	f0 
f0101464:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f010146b:	00 
f010146c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101473:	e8 c8 eb ff ff       	call   f0100040 <_panic>
f0101478:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010147a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010147f:	0f 86 a9 12 00 00    	jbe    f010272e <mem_init+0x1652>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101485:	89 c7                	mov    %eax,%edi
f0101487:	c1 ef 0c             	shr    $0xc,%edi
f010148a:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f010148d:	77 20                	ja     f01014af <mem_init+0x3d3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010148f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101493:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f010149a:	f0 
f010149b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01014a2:	00 
f01014a3:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f01014aa:	e8 91 eb ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01014af:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01014b5:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f01014b8:	0f 86 80 12 00 00    	jbe    f010273e <mem_init+0x1662>
f01014be:	c7 44 24 0c 7c 5d 10 	movl   $0xf0105d7c,0xc(%esp)
f01014c5:	f0 
f01014c6:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01014cd:	f0 
f01014ce:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f01014d5:	00 
f01014d6:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01014dd:	e8 5e eb ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014e2:	c7 44 24 0c 0e 63 10 	movl   $0xf010630e,0xc(%esp)
f01014e9:	f0 
f01014ea:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01014f1:	f0 
f01014f2:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01014f9:	00 
f01014fa:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101501:	e8 3a eb ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101506:	83 c6 01             	add    $0x1,%esi
f0101509:	eb 03                	jmp    f010150e <mem_init+0x432>
		else
			++nfree_extmem;
f010150b:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010150e:	8b 12                	mov    (%edx),%edx
f0101510:	85 d2                	test   %edx,%edx
f0101512:	0f 85 32 fe ff ff    	jne    f010134a <mem_init+0x26e>
f0101518:	8b 7d b0             	mov    -0x50(%ebp),%edi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010151b:	85 f6                	test   %esi,%esi
f010151d:	7f 24                	jg     f0101543 <mem_init+0x467>
f010151f:	c7 44 24 0c 2b 63 10 	movl   $0xf010632b,0xc(%esp)
f0101526:	f0 
f0101527:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010152e:	f0 
f010152f:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101536:	00 
f0101537:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010153e:	e8 fd ea ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101543:	85 db                	test   %ebx,%ebx
f0101545:	7f 24                	jg     f010156b <mem_init+0x48f>
f0101547:	c7 44 24 0c 3d 63 10 	movl   $0xf010633d,0xc(%esp)
f010154e:	f0 
f010154f:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101556:	f0 
f0101557:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010155e:	00 
f010155f:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101566:	e8 d5 ea ff ff       	call   f0100040 <_panic>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010156b:	85 ff                	test   %edi,%edi
f010156d:	75 1c                	jne    f010158b <mem_init+0x4af>
		panic("'pages' is a null pointer!");
f010156f:	c7 44 24 08 4e 63 10 	movl   $0xf010634e,0x8(%esp)
f0101576:	f0 
f0101577:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f010157e:	00 
f010157f:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101586:	e8 b5 ea ff ff       	call   f0100040 <_panic>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010158b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101590:	8b 45 c0             	mov    -0x40(%ebp),%eax
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;
f0101593:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101596:	8b 00                	mov    (%eax),%eax
f0101598:	85 c0                	test   %eax,%eax
f010159a:	75 f7                	jne    f0101593 <mem_init+0x4b7>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010159c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a3:	e8 a5 f7 ff ff       	call   f0100d4d <page_alloc>
f01015a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ab:	85 c0                	test   %eax,%eax
f01015ad:	75 24                	jne    f01015d3 <mem_init+0x4f7>
f01015af:	c7 44 24 0c 69 63 10 	movl   $0xf0106369,0xc(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01015c6:	00 
f01015c7:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01015ce:	e8 6d ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015da:	e8 6e f7 ff ff       	call   f0100d4d <page_alloc>
f01015df:	89 c7                	mov    %eax,%edi
f01015e1:	85 c0                	test   %eax,%eax
f01015e3:	75 24                	jne    f0101609 <mem_init+0x52d>
f01015e5:	c7 44 24 0c 7f 63 10 	movl   $0xf010637f,0xc(%esp)
f01015ec:	f0 
f01015ed:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01015f4:	f0 
f01015f5:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01015fc:	00 
f01015fd:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101604:	e8 37 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101609:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101610:	e8 38 f7 ff ff       	call   f0100d4d <page_alloc>
f0101615:	89 c6                	mov    %eax,%esi
f0101617:	85 c0                	test   %eax,%eax
f0101619:	75 24                	jne    f010163f <mem_init+0x563>
f010161b:	c7 44 24 0c 95 63 10 	movl   $0xf0106395,0xc(%esp)
f0101622:	f0 
f0101623:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010162a:	f0 
f010162b:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101632:	00 
f0101633:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010163a:	e8 01 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010163f:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101642:	75 24                	jne    f0101668 <mem_init+0x58c>
f0101644:	c7 44 24 0c ab 63 10 	movl   $0xf01063ab,0xc(%esp)
f010164b:	f0 
f010164c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101653:	f0 
f0101654:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010165b:	00 
f010165c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101663:	e8 d8 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101668:	39 c7                	cmp    %eax,%edi
f010166a:	74 05                	je     f0101671 <mem_init+0x595>
f010166c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010166f:	75 24                	jne    f0101695 <mem_init+0x5b9>
f0101671:	c7 44 24 0c c4 5d 10 	movl   $0xf0105dc4,0xc(%esp)
f0101678:	f0 
f0101679:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101680:	f0 
f0101681:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101688:	00 
f0101689:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101690:	e8 ab e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101695:	8b 15 f0 0e 22 f0    	mov    0xf0220ef0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010169b:	a1 e8 0e 22 f0       	mov    0xf0220ee8,%eax
f01016a0:	c1 e0 0c             	shl    $0xc,%eax
f01016a3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016a6:	29 d1                	sub    %edx,%ecx
f01016a8:	c1 f9 03             	sar    $0x3,%ecx
f01016ab:	c1 e1 0c             	shl    $0xc,%ecx
f01016ae:	39 c1                	cmp    %eax,%ecx
f01016b0:	72 24                	jb     f01016d6 <mem_init+0x5fa>
f01016b2:	c7 44 24 0c bd 63 10 	movl   $0xf01063bd,0xc(%esp)
f01016b9:	f0 
f01016ba:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01016c1:	f0 
f01016c2:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01016c9:	00 
f01016ca:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01016d1:	e8 6a e9 ff ff       	call   f0100040 <_panic>
f01016d6:	89 f9                	mov    %edi,%ecx
f01016d8:	29 d1                	sub    %edx,%ecx
f01016da:	c1 f9 03             	sar    $0x3,%ecx
f01016dd:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016e0:	39 c8                	cmp    %ecx,%eax
f01016e2:	77 24                	ja     f0101708 <mem_init+0x62c>
f01016e4:	c7 44 24 0c da 63 10 	movl   $0xf01063da,0xc(%esp)
f01016eb:	f0 
f01016ec:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01016f3:	f0 
f01016f4:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f01016fb:	00 
f01016fc:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101703:	e8 38 e9 ff ff       	call   f0100040 <_panic>
f0101708:	89 f1                	mov    %esi,%ecx
f010170a:	29 d1                	sub    %edx,%ecx
f010170c:	89 ca                	mov    %ecx,%edx
f010170e:	c1 fa 03             	sar    $0x3,%edx
f0101711:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101714:	39 d0                	cmp    %edx,%eax
f0101716:	77 24                	ja     f010173c <mem_init+0x660>
f0101718:	c7 44 24 0c f7 63 10 	movl   $0xf01063f7,0xc(%esp)
f010171f:	f0 
f0101720:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101727:	f0 
f0101728:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f010172f:	00 
f0101730:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101737:	e8 04 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010173c:	a1 48 02 22 f0       	mov    0xf0220248,%eax
f0101741:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101744:	c7 05 48 02 22 f0 00 	movl   $0x0,0xf0220248
f010174b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010174e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101755:	e8 f3 f5 ff ff       	call   f0100d4d <page_alloc>
f010175a:	85 c0                	test   %eax,%eax
f010175c:	74 24                	je     f0101782 <mem_init+0x6a6>
f010175e:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f0101765:	f0 
f0101766:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010176d:	f0 
f010176e:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101775:	00 
f0101776:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010177d:	e8 be e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101782:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101785:	89 04 24             	mov    %eax,(%esp)
f0101788:	e8 4a f6 ff ff       	call   f0100dd7 <page_free>
	page_free(pp1);
f010178d:	89 3c 24             	mov    %edi,(%esp)
f0101790:	e8 42 f6 ff ff       	call   f0100dd7 <page_free>
	page_free(pp2);
f0101795:	89 34 24             	mov    %esi,(%esp)
f0101798:	e8 3a f6 ff ff       	call   f0100dd7 <page_free>
  pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010179d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a4:	e8 a4 f5 ff ff       	call   f0100d4d <page_alloc>
f01017a9:	89 c6                	mov    %eax,%esi
f01017ab:	85 c0                	test   %eax,%eax
f01017ad:	75 24                	jne    f01017d3 <mem_init+0x6f7>
f01017af:	c7 44 24 0c 69 63 10 	movl   $0xf0106369,0xc(%esp)
f01017b6:	f0 
f01017b7:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01017be:	f0 
f01017bf:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01017c6:	00 
f01017c7:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01017ce:	e8 6d e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017da:	e8 6e f5 ff ff       	call   f0100d4d <page_alloc>
f01017df:	89 c7                	mov    %eax,%edi
f01017e1:	85 c0                	test   %eax,%eax
f01017e3:	75 24                	jne    f0101809 <mem_init+0x72d>
f01017e5:	c7 44 24 0c 7f 63 10 	movl   $0xf010637f,0xc(%esp)
f01017ec:	f0 
f01017ed:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101804:	e8 37 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101809:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101810:	e8 38 f5 ff ff       	call   f0100d4d <page_alloc>
f0101815:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101818:	85 c0                	test   %eax,%eax
f010181a:	75 24                	jne    f0101840 <mem_init+0x764>
f010181c:	c7 44 24 0c 95 63 10 	movl   $0xf0106395,0xc(%esp)
f0101823:	f0 
f0101824:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010182b:	f0 
f010182c:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101833:	00 
f0101834:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101840:	39 fe                	cmp    %edi,%esi
f0101842:	75 24                	jne    f0101868 <mem_init+0x78c>
f0101844:	c7 44 24 0c ab 63 10 	movl   $0xf01063ab,0xc(%esp)
f010184b:	f0 
f010184c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101853:	f0 
f0101854:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f010185b:	00 
f010185c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101868:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010186b:	74 05                	je     f0101872 <mem_init+0x796>
f010186d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101870:	75 24                	jne    f0101896 <mem_init+0x7ba>
f0101872:	c7 44 24 0c c4 5d 10 	movl   $0xf0105dc4,0xc(%esp)
f0101879:	f0 
f010187a:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101881:	f0 
f0101882:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101889:	00 
f010188a:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101891:	e8 aa e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101896:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189d:	e8 ab f4 ff ff       	call   f0100d4d <page_alloc>
f01018a2:	85 c0                	test   %eax,%eax
f01018a4:	74 24                	je     f01018ca <mem_init+0x7ee>
f01018a6:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f01018ad:	f0 
f01018ae:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01018b5:	f0 
f01018b6:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f01018bd:	00 
f01018be:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01018c5:	e8 76 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018ca:	89 f0                	mov    %esi,%eax
f01018cc:	e8 8e f3 ff ff       	call   f0100c5f <page2kva>
f01018d1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018d8:	00 
f01018d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01018e0:	00 
f01018e1:	89 04 24             	mov    %eax,(%esp)
f01018e4:	e8 fc 2f 00 00       	call   f01048e5 <memset>
	page_free(pp0);
f01018e9:	89 34 24             	mov    %esi,(%esp)
f01018ec:	e8 e6 f4 ff ff       	call   f0100dd7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018f8:	e8 50 f4 ff ff       	call   f0100d4d <page_alloc>
f01018fd:	85 c0                	test   %eax,%eax
f01018ff:	75 24                	jne    f0101925 <mem_init+0x849>
f0101901:	c7 44 24 0c 23 64 10 	movl   $0xf0106423,0xc(%esp)
f0101908:	f0 
f0101909:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101910:	f0 
f0101911:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0101918:	00 
f0101919:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101920:	e8 1b e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101925:	39 c6                	cmp    %eax,%esi
f0101927:	74 24                	je     f010194d <mem_init+0x871>
f0101929:	c7 44 24 0c 41 64 10 	movl   $0xf0106441,0xc(%esp)
f0101930:	f0 
f0101931:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101938:	f0 
f0101939:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101940:	00 
f0101941:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101948:	e8 f3 e6 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
f010194d:	89 f0                	mov    %esi,%eax
f010194f:	e8 0b f3 ff ff       	call   f0100c5f <page2kva>
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101954:	80 38 00             	cmpb   $0x0,(%eax)
f0101957:	75 0b                	jne    f0101964 <mem_init+0x888>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101959:	ba 01 00 00 00       	mov    $0x1,%edx
		assert(c[i] == 0);
f010195e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f0101962:	74 24                	je     f0101988 <mem_init+0x8ac>
f0101964:	c7 44 24 0c 51 64 10 	movl   $0xf0106451,0xc(%esp)
f010196b:	f0 
f010196c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101973:	f0 
f0101974:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f010197b:	00 
f010197c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101983:	e8 b8 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101988:	83 c2 01             	add    $0x1,%edx
f010198b:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0101991:	75 cb                	jne    f010195e <mem_init+0x882>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101993:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101996:	89 15 48 02 22 f0    	mov    %edx,0xf0220248

	// free the pages we took
	page_free(pp0);
f010199c:	89 34 24             	mov    %esi,(%esp)
f010199f:	e8 33 f4 ff ff       	call   f0100dd7 <page_free>
	page_free(pp1);
f01019a4:	89 3c 24             	mov    %edi,(%esp)
f01019a7:	e8 2b f4 ff ff       	call   f0100dd7 <page_free>
	page_free(pp2);
f01019ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019af:	89 04 24             	mov    %eax,(%esp)
f01019b2:	e8 20 f4 ff ff       	call   f0100dd7 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019b7:	a1 48 02 22 f0       	mov    0xf0220248,%eax
f01019bc:	85 c0                	test   %eax,%eax
f01019be:	74 09                	je     f01019c9 <mem_init+0x8ed>
		--nfree;
f01019c0:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019c3:	8b 00                	mov    (%eax),%eax
f01019c5:	85 c0                	test   %eax,%eax
f01019c7:	75 f7                	jne    f01019c0 <mem_init+0x8e4>
		--nfree;
	assert(nfree == 0);
f01019c9:	85 db                	test   %ebx,%ebx
f01019cb:	74 24                	je     f01019f1 <mem_init+0x915>
f01019cd:	c7 44 24 0c 5b 64 10 	movl   $0xf010645b,0xc(%esp)
f01019d4:	f0 
f01019d5:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01019dc:	f0 
f01019dd:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01019e4:	00 
f01019e5:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01019ec:	e8 4f e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019f1:	c7 04 24 e4 5d 10 f0 	movl   $0xf0105de4,(%esp)
f01019f8:	e8 7d 17 00 00       	call   f010317a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a04:	e8 44 f3 ff ff       	call   f0100d4d <page_alloc>
f0101a09:	89 c3                	mov    %eax,%ebx
f0101a0b:	85 c0                	test   %eax,%eax
f0101a0d:	75 24                	jne    f0101a33 <mem_init+0x957>
f0101a0f:	c7 44 24 0c 69 63 10 	movl   $0xf0106369,0xc(%esp)
f0101a16:	f0 
f0101a17:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101a1e:	f0 
f0101a1f:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101a26:	00 
f0101a27:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101a2e:	e8 0d e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a3a:	e8 0e f3 ff ff       	call   f0100d4d <page_alloc>
f0101a3f:	89 c6                	mov    %eax,%esi
f0101a41:	85 c0                	test   %eax,%eax
f0101a43:	75 24                	jne    f0101a69 <mem_init+0x98d>
f0101a45:	c7 44 24 0c 7f 63 10 	movl   $0xf010637f,0xc(%esp)
f0101a4c:	f0 
f0101a4d:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101a54:	f0 
f0101a55:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101a5c:	00 
f0101a5d:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101a64:	e8 d7 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a70:	e8 d8 f2 ff ff       	call   f0100d4d <page_alloc>
f0101a75:	89 c7                	mov    %eax,%edi
f0101a77:	85 c0                	test   %eax,%eax
f0101a79:	75 24                	jne    f0101a9f <mem_init+0x9c3>
f0101a7b:	c7 44 24 0c 95 63 10 	movl   $0xf0106395,0xc(%esp)
f0101a82:	f0 
f0101a83:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101a8a:	f0 
f0101a8b:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101a92:	00 
f0101a93:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101a9a:	e8 a1 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a9f:	39 f3                	cmp    %esi,%ebx
f0101aa1:	75 24                	jne    f0101ac7 <mem_init+0x9eb>
f0101aa3:	c7 44 24 0c ab 63 10 	movl   $0xf01063ab,0xc(%esp)
f0101aaa:	f0 
f0101aab:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101aba:	00 
f0101abb:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ac7:	39 c6                	cmp    %eax,%esi
f0101ac9:	74 04                	je     f0101acf <mem_init+0x9f3>
f0101acb:	39 c3                	cmp    %eax,%ebx
f0101acd:	75 24                	jne    f0101af3 <mem_init+0xa17>
f0101acf:	c7 44 24 0c c4 5d 10 	movl   $0xf0105dc4,0xc(%esp)
f0101ad6:	f0 
f0101ad7:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101ade:	f0 
f0101adf:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101ae6:	00 
f0101ae7:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101aee:	e8 4d e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101af3:	8b 15 48 02 22 f0    	mov    0xf0220248,%edx
f0101af9:	89 55 d0             	mov    %edx,-0x30(%ebp)
	page_free_list = 0;
f0101afc:	c7 05 48 02 22 f0 00 	movl   $0x0,0xf0220248
f0101b03:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b0d:	e8 3b f2 ff ff       	call   f0100d4d <page_alloc>
f0101b12:	85 c0                	test   %eax,%eax
f0101b14:	74 24                	je     f0101b3a <mem_init+0xa5e>
f0101b16:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101b25:	f0 
f0101b26:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101b2d:	00 
f0101b2e:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101b35:	e8 06 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b3a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101b3d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b48:	00 
f0101b49:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101b4e:	89 04 24             	mov    %eax,(%esp)
f0101b51:	e8 af f3 ff ff       	call   f0100f05 <page_lookup>
f0101b56:	85 c0                	test   %eax,%eax
f0101b58:	74 24                	je     f0101b7e <mem_init+0xaa2>
f0101b5a:	c7 44 24 0c 04 5e 10 	movl   $0xf0105e04,0xc(%esp)
f0101b61:	f0 
f0101b62:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101b69:	f0 
f0101b6a:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101b71:	00 
f0101b72:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101b79:	e8 c2 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b7e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b85:	00 
f0101b86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b8d:	00 
f0101b8e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b92:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101b97:	89 04 24             	mov    %eax,(%esp)
f0101b9a:	e8 68 f4 ff ff       	call   f0101007 <page_insert>
f0101b9f:	85 c0                	test   %eax,%eax
f0101ba1:	78 24                	js     f0101bc7 <mem_init+0xaeb>
f0101ba3:	c7 44 24 0c 3c 5e 10 	movl   $0xf0105e3c,0xc(%esp)
f0101baa:	f0 
f0101bab:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101bb2:	f0 
f0101bb3:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101bba:	00 
f0101bbb:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101bc2:	e8 79 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101bc7:	89 1c 24             	mov    %ebx,(%esp)
f0101bca:	e8 08 f2 ff ff       	call   f0100dd7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101bcf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bd6:	00 
f0101bd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bde:	00 
f0101bdf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101be3:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101be8:	89 04 24             	mov    %eax,(%esp)
f0101beb:	e8 17 f4 ff ff       	call   f0101007 <page_insert>
f0101bf0:	85 c0                	test   %eax,%eax
f0101bf2:	74 24                	je     f0101c18 <mem_init+0xb3c>
f0101bf4:	c7 44 24 0c 6c 5e 10 	movl   $0xf0105e6c,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101c13:	e8 28 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c18:	8b 0d ec 0e 22 f0    	mov    0xf0220eec,%ecx
f0101c1e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101c21:	a1 f0 0e 22 f0       	mov    0xf0220ef0,%eax
f0101c26:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c29:	8b 11                	mov    (%ecx),%edx
f0101c2b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101c2e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c34:	89 d8                	mov    %ebx,%eax
f0101c36:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101c39:	c1 f8 03             	sar    $0x3,%eax
f0101c3c:	c1 e0 0c             	shl    $0xc,%eax
f0101c3f:	39 c2                	cmp    %eax,%edx
f0101c41:	74 24                	je     f0101c67 <mem_init+0xb8b>
f0101c43:	c7 44 24 0c 9c 5e 10 	movl   $0xf0105e9c,0xc(%esp)
f0101c4a:	f0 
f0101c4b:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101c52:	f0 
f0101c53:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0101c5a:	00 
f0101c5b:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101c62:	e8 d9 e3 ff ff       	call   f0100040 <_panic>

	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c67:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c6f:	e8 d4 ee ff ff       	call   f0100b48 <check_va2pa>
f0101c74:	89 f2                	mov    %esi,%edx
f0101c76:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101c79:	c1 fa 03             	sar    $0x3,%edx
f0101c7c:	c1 e2 0c             	shl    $0xc,%edx
f0101c7f:	39 d0                	cmp    %edx,%eax
f0101c81:	74 24                	je     f0101ca7 <mem_init+0xbcb>
f0101c83:	c7 44 24 0c c4 5e 10 	movl   $0xf0105ec4,0xc(%esp)
f0101c8a:	f0 
f0101c8b:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101c92:	f0 
f0101c93:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101c9a:	00 
f0101c9b:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101ca2:	e8 99 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ca7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cac:	74 24                	je     f0101cd2 <mem_init+0xbf6>
f0101cae:	c7 44 24 0c 66 64 10 	movl   $0xf0106466,0xc(%esp)
f0101cb5:	f0 
f0101cb6:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101cbd:	f0 
f0101cbe:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101cc5:	00 
f0101cc6:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101ccd:	e8 6e e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101cd2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cd7:	74 24                	je     f0101cfd <mem_init+0xc21>
f0101cd9:	c7 44 24 0c 77 64 10 	movl   $0xf0106477,0xc(%esp)
f0101ce0:	f0 
f0101ce1:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101ce8:	f0 
f0101ce9:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101cf0:	00 
f0101cf1:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101cf8:	e8 43 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cfd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d04:	00 
f0101d05:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d0c:	00 
f0101d0d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d11:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d14:	89 0c 24             	mov    %ecx,(%esp)
f0101d17:	e8 eb f2 ff ff       	call   f0101007 <page_insert>
f0101d1c:	85 c0                	test   %eax,%eax
f0101d1e:	74 24                	je     f0101d44 <mem_init+0xc68>
f0101d20:	c7 44 24 0c f4 5e 10 	movl   $0xf0105ef4,0xc(%esp)
f0101d27:	f0 
f0101d28:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101d37:	00 
f0101d38:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101d3f:	e8 fc e2 ff ff       	call   f0100040 <_panic>
	//cprintf("page2pa: %08x", page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d44:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d49:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101d4e:	e8 f5 ed ff ff       	call   f0100b48 <check_va2pa>
f0101d53:	89 fa                	mov    %edi,%edx
f0101d55:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0101d5b:	c1 fa 03             	sar    $0x3,%edx
f0101d5e:	c1 e2 0c             	shl    $0xc,%edx
f0101d61:	39 d0                	cmp    %edx,%eax
f0101d63:	74 24                	je     f0101d89 <mem_init+0xcad>
f0101d65:	c7 44 24 0c 30 5f 10 	movl   $0xf0105f30,0xc(%esp)
f0101d6c:	f0 
f0101d6d:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101d74:	f0 
f0101d75:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101d7c:	00 
f0101d7d:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101d84:	e8 b7 e2 ff ff       	call   f0100040 <_panic>

	assert(pp2->pp_ref == 1);
f0101d89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d8e:	74 24                	je     f0101db4 <mem_init+0xcd8>
f0101d90:	c7 44 24 0c 88 64 10 	movl   $0xf0106488,0xc(%esp)
f0101d97:	f0 
f0101d98:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101d9f:	f0 
f0101da0:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101da7:	00 
f0101da8:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101daf:	e8 8c e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101db4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dbb:	e8 8d ef ff ff       	call   f0100d4d <page_alloc>
f0101dc0:	85 c0                	test   %eax,%eax
f0101dc2:	74 24                	je     f0101de8 <mem_init+0xd0c>
f0101dc4:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f0101dcb:	f0 
f0101dcc:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101dd3:	f0 
f0101dd4:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101ddb:	00 
f0101ddc:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101de3:	e8 58 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101de8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101def:	00 
f0101df0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101df7:	00 
f0101df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101dfc:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101e01:	89 04 24             	mov    %eax,(%esp)
f0101e04:	e8 fe f1 ff ff       	call   f0101007 <page_insert>
f0101e09:	85 c0                	test   %eax,%eax
f0101e0b:	74 24                	je     f0101e31 <mem_init+0xd55>
f0101e0d:	c7 44 24 0c f4 5e 10 	movl   $0xf0105ef4,0xc(%esp)
f0101e14:	f0 
f0101e15:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101e1c:	f0 
f0101e1d:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101e24:	00 
f0101e25:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101e2c:	e8 0f e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e31:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e36:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101e3b:	e8 08 ed ff ff       	call   f0100b48 <check_va2pa>
f0101e40:	89 fa                	mov    %edi,%edx
f0101e42:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0101e48:	c1 fa 03             	sar    $0x3,%edx
f0101e4b:	c1 e2 0c             	shl    $0xc,%edx
f0101e4e:	39 d0                	cmp    %edx,%eax
f0101e50:	74 24                	je     f0101e76 <mem_init+0xd9a>
f0101e52:	c7 44 24 0c 30 5f 10 	movl   $0xf0105f30,0xc(%esp)
f0101e59:	f0 
f0101e5a:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101e69:	00 
f0101e6a:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101e71:	e8 ca e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e76:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e7b:	74 24                	je     f0101ea1 <mem_init+0xdc5>
f0101e7d:	c7 44 24 0c 88 64 10 	movl   $0xf0106488,0xc(%esp)
f0101e84:	f0 
f0101e85:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101e8c:	f0 
f0101e8d:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101e94:	00 
f0101e95:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101e9c:	e8 9f e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ea1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ea8:	e8 a0 ee ff ff       	call   f0100d4d <page_alloc>
f0101ead:	85 c0                	test   %eax,%eax
f0101eaf:	74 24                	je     f0101ed5 <mem_init+0xdf9>
f0101eb1:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f0101eb8:	f0 
f0101eb9:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101ec0:	f0 
f0101ec1:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101ec8:	00 
f0101ec9:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101ed0:	e8 6b e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ed5:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101eda:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101edd:	8b 10                	mov    (%eax),%edx
f0101edf:	89 d1                	mov    %edx,%ecx
f0101ee1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101ee7:	ba f1 03 00 00       	mov    $0x3f1,%edx
f0101eec:	b8 61 62 10 f0       	mov    $0xf0106261,%eax
f0101ef1:	e8 1a ec ff ff       	call   f0100b10 <_kaddr>
f0101ef6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ef9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f00:	00 
f0101f01:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f08:	00 
f0101f09:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f0c:	89 0c 24             	mov    %ecx,(%esp)
f0101f0f:	e8 02 ef ff ff       	call   f0100e16 <pgdir_walk>
f0101f14:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101f17:	83 c2 04             	add    $0x4,%edx
f0101f1a:	39 d0                	cmp    %edx,%eax
f0101f1c:	74 24                	je     f0101f42 <mem_init+0xe66>
f0101f1e:	c7 44 24 0c 60 5f 10 	movl   $0xf0105f60,0xc(%esp)
f0101f25:	f0 
f0101f26:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101f2d:	f0 
f0101f2e:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101f35:	00 
f0101f36:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101f3d:	e8 fe e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f42:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f49:	00 
f0101f4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f51:	00 
f0101f52:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f56:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101f5b:	89 04 24             	mov    %eax,(%esp)
f0101f5e:	e8 a4 f0 ff ff       	call   f0101007 <page_insert>
f0101f63:	85 c0                	test   %eax,%eax
f0101f65:	74 24                	je     f0101f8b <mem_init+0xeaf>
f0101f67:	c7 44 24 0c a0 5f 10 	movl   $0xf0105fa0,0xc(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101f76:	f0 
f0101f77:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101f7e:	00 
f0101f7f:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101f86:	e8 b5 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8b:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0101f90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f98:	e8 ab eb ff ff       	call   f0100b48 <check_va2pa>
f0101f9d:	89 fa                	mov    %edi,%edx
f0101f9f:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0101fa5:	c1 fa 03             	sar    $0x3,%edx
f0101fa8:	c1 e2 0c             	shl    $0xc,%edx
f0101fab:	39 d0                	cmp    %edx,%eax
f0101fad:	74 24                	je     f0101fd3 <mem_init+0xef7>
f0101faf:	c7 44 24 0c 30 5f 10 	movl   $0xf0105f30,0xc(%esp)
f0101fb6:	f0 
f0101fb7:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101fbe:	f0 
f0101fbf:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0101fc6:	00 
f0101fc7:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101fce:	e8 6d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fd3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101fd8:	74 24                	je     f0101ffe <mem_init+0xf22>
f0101fda:	c7 44 24 0c 88 64 10 	movl   $0xf0106488,0xc(%esp)
f0101fe1:	f0 
f0101fe2:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0101fe9:	f0 
f0101fea:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101ff1:	00 
f0101ff2:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0101ff9:	e8 42 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ffe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102005:	00 
f0102006:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010200d:	00 
f010200e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102011:	89 14 24             	mov    %edx,(%esp)
f0102014:	e8 fd ed ff ff       	call   f0100e16 <pgdir_walk>
f0102019:	f6 00 04             	testb  $0x4,(%eax)
f010201c:	75 24                	jne    f0102042 <mem_init+0xf66>
f010201e:	c7 44 24 0c e0 5f 10 	movl   $0xf0105fe0,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010203d:	e8 fe df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102042:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0102047:	f6 00 04             	testb  $0x4,(%eax)
f010204a:	75 24                	jne    f0102070 <mem_init+0xf94>
f010204c:	c7 44 24 0c 99 64 10 	movl   $0xf0106499,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010206b:	e8 d0 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102070:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102077:	00 
f0102078:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010207f:	00 
f0102080:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102084:	89 04 24             	mov    %eax,(%esp)
f0102087:	e8 7b ef ff ff       	call   f0101007 <page_insert>
f010208c:	85 c0                	test   %eax,%eax
f010208e:	74 24                	je     f01020b4 <mem_init+0xfd8>
f0102090:	c7 44 24 0c f4 5e 10 	movl   $0xf0105ef4,0xc(%esp)
f0102097:	f0 
f0102098:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01020a7:	00 
f01020a8:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01020af:	e8 8c df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020bb:	00 
f01020bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020c3:	00 
f01020c4:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f01020c9:	89 04 24             	mov    %eax,(%esp)
f01020cc:	e8 45 ed ff ff       	call   f0100e16 <pgdir_walk>
f01020d1:	f6 00 02             	testb  $0x2,(%eax)
f01020d4:	75 24                	jne    f01020fa <mem_init+0x101e>
f01020d6:	c7 44 24 0c 14 60 10 	movl   $0xf0106014,0xc(%esp)
f01020dd:	f0 
f01020de:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01020ed:	00 
f01020ee:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01020f5:	e8 46 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102101:	00 
f0102102:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102109:	00 
f010210a:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f010210f:	89 04 24             	mov    %eax,(%esp)
f0102112:	e8 ff ec ff ff       	call   f0100e16 <pgdir_walk>
f0102117:	f6 00 04             	testb  $0x4,(%eax)
f010211a:	74 24                	je     f0102140 <mem_init+0x1064>
f010211c:	c7 44 24 0c 48 60 10 	movl   $0xf0106048,0xc(%esp)
f0102123:	f0 
f0102124:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010212b:	f0 
f010212c:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102133:	00 
f0102134:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010213b:	e8 00 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102140:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102147:	00 
f0102148:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010214f:	00 
f0102150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102154:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0102159:	89 04 24             	mov    %eax,(%esp)
f010215c:	e8 a6 ee ff ff       	call   f0101007 <page_insert>
f0102161:	85 c0                	test   %eax,%eax
f0102163:	78 24                	js     f0102189 <mem_init+0x10ad>
f0102165:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102184:	e8 b7 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102189:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102190:	00 
f0102191:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102198:	00 
f0102199:	89 74 24 04          	mov    %esi,0x4(%esp)
f010219d:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f01021a2:	89 04 24             	mov    %eax,(%esp)
f01021a5:	e8 5d ee ff ff       	call   f0101007 <page_insert>
f01021aa:	85 c0                	test   %eax,%eax
f01021ac:	74 24                	je     f01021d2 <mem_init+0x10f6>
f01021ae:	c7 44 24 0c b8 60 10 	movl   $0xf01060b8,0xc(%esp)
f01021b5:	f0 
f01021b6:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01021bd:	f0 
f01021be:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01021c5:	00 
f01021c6:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01021cd:	e8 6e de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021d9:	00 
f01021da:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021e1:	00 
f01021e2:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f01021e7:	89 04 24             	mov    %eax,(%esp)
f01021ea:	e8 27 ec ff ff       	call   f0100e16 <pgdir_walk>
f01021ef:	f6 00 04             	testb  $0x4,(%eax)
f01021f2:	74 24                	je     f0102218 <mem_init+0x113c>
f01021f4:	c7 44 24 0c 48 60 10 	movl   $0xf0106048,0xc(%esp)
f01021fb:	f0 
f01021fc:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102203:	f0 
f0102204:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f010220b:	00 
f010220c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102213:	e8 28 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102218:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f010221d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102220:	ba 00 00 00 00       	mov    $0x0,%edx
f0102225:	e8 1e e9 ff ff       	call   f0100b48 <check_va2pa>
f010222a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010222d:	89 f0                	mov    %esi,%eax
f010222f:	2b 05 f0 0e 22 f0    	sub    0xf0220ef0,%eax
f0102235:	c1 f8 03             	sar    $0x3,%eax
f0102238:	c1 e0 0c             	shl    $0xc,%eax
f010223b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010223e:	74 24                	je     f0102264 <mem_init+0x1188>
f0102240:	c7 44 24 0c f4 60 10 	movl   $0xf01060f4,0xc(%esp)
f0102247:	f0 
f0102248:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010224f:	f0 
f0102250:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102257:	00 
f0102258:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010225f:	e8 dc dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102264:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102269:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010226c:	e8 d7 e8 ff ff       	call   f0100b48 <check_va2pa>
f0102271:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102274:	74 24                	je     f010229a <mem_init+0x11be>
f0102276:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f010227d:	f0 
f010227e:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102285:	f0 
f0102286:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010228d:	00 
f010228e:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102295:	e8 a6 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010229a:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010229f:	74 24                	je     f01022c5 <mem_init+0x11e9>
f01022a1:	c7 44 24 0c af 64 10 	movl   $0xf01064af,0xc(%esp)
f01022a8:	f0 
f01022a9:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01022b0:	f0 
f01022b1:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01022b8:	00 
f01022b9:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01022c0:	e8 7b dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022c5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01022ca:	74 24                	je     f01022f0 <mem_init+0x1214>
f01022cc:	c7 44 24 0c c0 64 10 	movl   $0xf01064c0,0xc(%esp)
f01022d3:	f0 
f01022d4:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01022db:	f0 
f01022dc:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01022e3:	00 
f01022e4:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01022eb:	e8 50 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022f7:	e8 51 ea ff ff       	call   f0100d4d <page_alloc>
f01022fc:	85 c0                	test   %eax,%eax
f01022fe:	74 04                	je     f0102304 <mem_init+0x1228>
f0102300:	39 c7                	cmp    %eax,%edi
f0102302:	74 24                	je     f0102328 <mem_init+0x124c>
f0102304:	c7 44 24 0c 50 61 10 	movl   $0xf0106150,0xc(%esp)
f010230b:	f0 
f010230c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102313:	f0 
f0102314:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f010231b:	00 
f010231c:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102323:	e8 18 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102328:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010232f:	00 
f0102330:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0102335:	89 04 24             	mov    %eax,(%esp)
f0102338:	e8 7a ec ff ff       	call   f0100fb7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010233d:	8b 15 ec 0e 22 f0    	mov    0xf0220eec,%edx
f0102343:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102346:	ba 00 00 00 00       	mov    $0x0,%edx
f010234b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010234e:	e8 f5 e7 ff ff       	call   f0100b48 <check_va2pa>
f0102353:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102356:	74 24                	je     f010237c <mem_init+0x12a0>
f0102358:	c7 44 24 0c 74 61 10 	movl   $0xf0106174,0xc(%esp)
f010235f:	f0 
f0102360:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102367:	f0 
f0102368:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010236f:	00 
f0102370:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102377:	e8 c4 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010237c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102381:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102384:	e8 bf e7 ff ff       	call   f0100b48 <check_va2pa>
f0102389:	89 f2                	mov    %esi,%edx
f010238b:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0102391:	c1 fa 03             	sar    $0x3,%edx
f0102394:	c1 e2 0c             	shl    $0xc,%edx
f0102397:	39 d0                	cmp    %edx,%eax
f0102399:	74 24                	je     f01023bf <mem_init+0x12e3>
f010239b:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f01023a2:	f0 
f01023a3:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01023aa:	f0 
f01023ab:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01023b2:	00 
f01023b3:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01023ba:	e8 81 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023bf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023c4:	74 24                	je     f01023ea <mem_init+0x130e>
f01023c6:	c7 44 24 0c 66 64 10 	movl   $0xf0106466,0xc(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01023d5:	f0 
f01023d6:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01023dd:	00 
f01023de:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01023e5:	e8 56 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023ea:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01023ef:	74 24                	je     f0102415 <mem_init+0x1339>
f01023f1:	c7 44 24 0c c0 64 10 	movl   $0xf01064c0,0xc(%esp)
f01023f8:	f0 
f01023f9:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102400:	f0 
f0102401:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102408:	00 
f0102409:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102410:	e8 2b dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102415:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010241c:	00 
f010241d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102420:	89 0c 24             	mov    %ecx,(%esp)
f0102423:	e8 8f eb ff ff       	call   f0100fb7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102428:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f010242d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102430:	ba 00 00 00 00       	mov    $0x0,%edx
f0102435:	e8 0e e7 ff ff       	call   f0100b48 <check_va2pa>
f010243a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010243d:	74 24                	je     f0102463 <mem_init+0x1387>
f010243f:	c7 44 24 0c 74 61 10 	movl   $0xf0106174,0xc(%esp)
f0102446:	f0 
f0102447:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010244e:	f0 
f010244f:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0102456:	00 
f0102457:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010245e:	e8 dd db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102463:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246b:	e8 d8 e6 ff ff       	call   f0100b48 <check_va2pa>
f0102470:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102473:	74 24                	je     f0102499 <mem_init+0x13bd>
f0102475:	c7 44 24 0c 98 61 10 	movl   $0xf0106198,0xc(%esp)
f010247c:	f0 
f010247d:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102484:	f0 
f0102485:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f010248c:	00 
f010248d:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102494:	e8 a7 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102499:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010249e:	74 24                	je     f01024c4 <mem_init+0x13e8>
f01024a0:	c7 44 24 0c d1 64 10 	movl   $0xf01064d1,0xc(%esp)
f01024a7:	f0 
f01024a8:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01024af:	f0 
f01024b0:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f01024b7:	00 
f01024b8:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01024bf:	e8 7c db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024c4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01024c9:	74 24                	je     f01024ef <mem_init+0x1413>
f01024cb:	c7 44 24 0c c0 64 10 	movl   $0xf01064c0,0xc(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01024da:	f0 
f01024db:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01024e2:	00 
f01024e3:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01024ea:	e8 51 db ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024f6:	e8 52 e8 ff ff       	call   f0100d4d <page_alloc>
f01024fb:	85 c0                	test   %eax,%eax
f01024fd:	74 04                	je     f0102503 <mem_init+0x1427>
f01024ff:	39 c6                	cmp    %eax,%esi
f0102501:	74 24                	je     f0102527 <mem_init+0x144b>
f0102503:	c7 44 24 0c c0 61 10 	movl   $0xf01061c0,0xc(%esp)
f010250a:	f0 
f010250b:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102512:	f0 
f0102513:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f010251a:	00 
f010251b:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102522:	e8 19 db ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102527:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010252e:	e8 1a e8 ff ff       	call   f0100d4d <page_alloc>
f0102533:	85 c0                	test   %eax,%eax
f0102535:	74 24                	je     f010255b <mem_init+0x147f>
f0102537:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f010253e:	f0 
f010253f:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102546:	f0 
f0102547:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010254e:	00 
f010254f:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102556:	e8 e5 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010255b:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f0102560:	8b 08                	mov    (%eax),%ecx
f0102562:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102568:	89 da                	mov    %ebx,%edx
f010256a:	2b 15 f0 0e 22 f0    	sub    0xf0220ef0,%edx
f0102570:	c1 fa 03             	sar    $0x3,%edx
f0102573:	c1 e2 0c             	shl    $0xc,%edx
f0102576:	39 d1                	cmp    %edx,%ecx
f0102578:	74 24                	je     f010259e <mem_init+0x14c2>
f010257a:	c7 44 24 0c 9c 5e 10 	movl   $0xf0105e9c,0xc(%esp)
f0102581:	f0 
f0102582:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0102589:	f0 
f010258a:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102591:	00 
f0102592:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f0102599:	e8 a2 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010259e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025a4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025a9:	74 24                	je     f01025cf <mem_init+0x14f3>
f01025ab:	c7 44 24 0c 77 64 10 	movl   $0xf0106477,0xc(%esp)
f01025b2:	f0 
f01025b3:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01025ba:	f0 
f01025bb:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01025c2:	00 
f01025c3:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01025ca:	e8 71 da ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01025cf:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025d5:	89 1c 24             	mov    %ebx,(%esp)
f01025d8:	e8 fa e7 ff ff       	call   f0100dd7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025dd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025e4:	00 
f01025e5:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01025ec:	00 
f01025ed:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f01025f2:	89 04 24             	mov    %eax,(%esp)
f01025f5:	e8 1c e8 ff ff       	call   f0100e16 <pgdir_walk>
f01025fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102600:	8b 15 ec 0e 22 f0    	mov    0xf0220eec,%edx
f0102606:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0102609:	8b 4a 04             	mov    0x4(%edx),%ecx
f010260c:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f010260f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102615:	ba 2f 04 00 00       	mov    $0x42f,%edx
f010261a:	b8 61 62 10 f0       	mov    $0xf0106261,%eax
f010261f:	e8 ec e4 ff ff       	call   f0100b10 <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0102624:	83 c0 04             	add    $0x4,%eax
f0102627:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010262a:	74 24                	je     f0102650 <mem_init+0x1574>
f010262c:	c7 44 24 0c e2 64 10 	movl   $0xf01064e2,0xc(%esp)
f0102633:	f0 
f0102634:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f010263b:	f0 
f010263c:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0102643:	00 
f0102644:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f010264b:	e8 f0 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102650:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102653:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010265a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102660:	89 d8                	mov    %ebx,%eax
f0102662:	e8 f8 e5 ff ff       	call   f0100c5f <page2kva>
f0102667:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010266e:	00 
f010266f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102676:	00 
f0102677:	89 04 24             	mov    %eax,(%esp)
f010267a:	e8 66 22 00 00       	call   f01048e5 <memset>
	page_free(pp0);
f010267f:	89 1c 24             	mov    %ebx,(%esp)
f0102682:	e8 50 e7 ff ff       	call   f0100dd7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102687:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010268e:	00 
f010268f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102696:	00 
f0102697:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f010269c:	89 04 24             	mov    %eax,(%esp)
f010269f:	e8 72 e7 ff ff       	call   f0100e16 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f01026a4:	89 d8                	mov    %ebx,%eax
f01026a6:	e8 b4 e5 ff ff       	call   f0100c5f <page2kva>
f01026ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(i=0; i<NPTENTRIES; i++)
f01026ae:	ba 00 00 00 00       	mov    $0x0,%edx
		assert((ptep[i] & PTE_P) == 0);
f01026b3:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f01026b7:	74 24                	je     f01026dd <mem_init+0x1601>
f01026b9:	c7 44 24 0c fa 64 10 	movl   $0xf01064fa,0xc(%esp)
f01026c0:	f0 
f01026c1:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f01026d0:	00 
f01026d1:	c7 04 24 61 62 10 f0 	movl   $0xf0106261,(%esp)
f01026d8:	e8 63 d9 ff ff       	call   f0100040 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01026dd:	83 c2 01             	add    $0x1,%edx
f01026e0:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01026e6:	75 cb                	jne    f01026b3 <mem_init+0x15d7>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01026e8:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
f01026ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01026f3:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f01026f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01026fc:	89 15 48 02 22 f0    	mov    %edx,0xf0220248

	// free the pages we took
	page_free(pp0);
f0102702:	89 1c 24             	mov    %ebx,(%esp)
f0102705:	e8 cd e6 ff ff       	call   f0100dd7 <page_free>
	page_free(pp1);
f010270a:	89 34 24             	mov    %esi,(%esp)
f010270d:	e8 c5 e6 ff ff       	call   f0100dd7 <page_free>
	page_free(pp2);
f0102712:	89 3c 24             	mov    %edi,(%esp)
f0102715:	e8 bd e6 ff ff       	call   f0100dd7 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010271a:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102721:	00 
f0102722:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102729:	e8 8c e9 ff ff       	call   f01010ba <mmio_map_region>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010272e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102733:	0f 85 cd ed ff ff    	jne    f0101506 <mem_init+0x42a>
f0102739:	e9 a4 ed ff ff       	jmp    f01014e2 <mem_init+0x406>
f010273e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102743:	0f 85 c2 ed ff ff    	jne    f010150b <mem_init+0x42f>
f0102749:	e9 94 ed ff ff       	jmp    f01014e2 <mem_init+0x406>

f010274e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010274e:	55                   	push   %ebp
f010274f:	89 e5                	mov    %esp,%ebp
f0102751:	57                   	push   %edi
f0102752:	56                   	push   %esi
f0102753:	53                   	push   %ebx
f0102754:	83 ec 2c             	sub    $0x2c,%esp
f0102757:	8b 7d 08             	mov    0x8(%ebp),%edi
f010275a:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	/* if( va < ULIM )
	{}
	else return -E_FAULT;	
  */
    cprintf("user_mem_check va: %x, len: %x\n", va, len);
f010275d:	8b 45 10             	mov    0x10(%ebp),%eax
f0102760:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102764:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102767:	89 54 24 04          	mov    %edx,0x4(%esp)
f010276b:	c7 04 24 e4 61 10 f0 	movl   $0xf01061e4,(%esp)
f0102772:	e8 03 0a 00 00       	call   f010317a <cprintf>
    uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010277a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102780:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102783:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102786:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010278d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint32_t i;
    for (i = (uint32_t)begin; i < end; i+=PGSIZE) 
f0102795:	39 c3                	cmp    %eax,%ebx
f0102797:	73 4e                	jae    f01027e7 <user_mem_check+0x99>
    {
      pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102799:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027a0:	00 
f01027a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01027a5:	8b 47 60             	mov    0x60(%edi),%eax
f01027a8:	89 04 24             	mov    %eax,(%esp)
f01027ab:	e8 66 e6 ff ff       	call   f0100e16 <pgdir_walk>
      //pprint(pte);
      if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm))
f01027b0:	85 c0                	test   %eax,%eax
f01027b2:	74 14                	je     f01027c8 <user_mem_check+0x7a>
f01027b4:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027ba:	77 0c                	ja     f01027c8 <user_mem_check+0x7a>
f01027bc:	8b 00                	mov    (%eax),%eax
f01027be:	a8 01                	test   $0x1,%al
f01027c0:	74 06                	je     f01027c8 <user_mem_check+0x7a>
f01027c2:	21 f0                	and    %esi,%eax
f01027c4:	39 c6                	cmp    %eax,%esi
f01027c6:	74 14                	je     f01027dc <user_mem_check+0x8e>
		 {
         user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f01027c8:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01027cb:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f01027cf:	89 1d 4c 02 22 f0    	mov    %ebx,0xf022024c
         return -E_FAULT;
f01027d5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01027da:	eb 2a                	jmp    f0102806 <user_mem_check+0xb8>
  */
    cprintf("user_mem_check va: %x, len: %x\n", va, len);
    uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
    uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
    uint32_t i;
    for (i = (uint32_t)begin; i < end; i+=PGSIZE) 
f01027dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027e2:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01027e5:	77 b2                	ja     f0102799 <user_mem_check+0x4b>
		 {
         user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
         return -E_FAULT;
     }
   }
   cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f01027e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01027ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01027ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027f5:	c7 04 24 04 62 10 f0 	movl   $0xf0106204,(%esp)
f01027fc:	e8 79 09 00 00       	call   f010317a <cprintf>
   return 0;
f0102801:	b8 00 00 00 00       	mov    $0x0,%eax

}
f0102806:	83 c4 2c             	add    $0x2c,%esp
f0102809:	5b                   	pop    %ebx
f010280a:	5e                   	pop    %esi
f010280b:	5f                   	pop    %edi
f010280c:	5d                   	pop    %ebp
f010280d:	c3                   	ret    

f010280e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010280e:	55                   	push   %ebp
f010280f:	89 e5                	mov    %esp,%ebp
f0102811:	53                   	push   %ebx
f0102812:	83 ec 14             	sub    $0x14,%esp
f0102815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102818:	8b 45 14             	mov    0x14(%ebp),%eax
f010281b:	83 c8 04             	or     $0x4,%eax
f010281e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102822:	8b 45 10             	mov    0x10(%ebp),%eax
f0102825:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102829:	8b 45 0c             	mov    0xc(%ebp),%eax
f010282c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102830:	89 1c 24             	mov    %ebx,(%esp)
f0102833:	e8 16 ff ff ff       	call   f010274e <user_mem_check>
f0102838:	85 c0                	test   %eax,%eax
f010283a:	79 24                	jns    f0102860 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010283c:	a1 4c 02 22 f0       	mov    0xf022024c,%eax
f0102841:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102845:	8b 43 48             	mov    0x48(%ebx),%eax
f0102848:	89 44 24 04          	mov    %eax,0x4(%esp)
f010284c:	c7 04 24 2c 62 10 f0 	movl   $0xf010622c,(%esp)
f0102853:	e8 22 09 00 00       	call   f010317a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102858:	89 1c 24             	mov    %ebx,(%esp)
f010285b:	e8 9e 06 00 00       	call   f0102efe <env_destroy>
	}
}
f0102860:	83 c4 14             	add    $0x14,%esp
f0102863:	5b                   	pop    %ebx
f0102864:	5d                   	pop    %ebp
f0102865:	c3                   	ret    
	...

f0102868 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102868:	55                   	push   %ebp
f0102869:	89 e5                	mov    %esp,%ebp
f010286b:	57                   	push   %edi
f010286c:	56                   	push   %esi
f010286d:	53                   	push   %ebx
f010286e:	83 ec 1c             	sub    $0x1c,%esp
f0102871:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102873:	89 d3                	mov    %edx,%ebx
f0102875:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010287b:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102882:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102888:	39 f3                	cmp    %esi,%ebx
f010288a:	73 51                	jae    f01028dd <region_alloc+0x75>
		struct PageInfo *pg = page_alloc(0);
f010288c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102893:	e8 b5 e4 ff ff       	call   f0100d4d <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102898:	85 c0                	test   %eax,%eax
f010289a:	75 1c                	jne    f01028b8 <region_alloc+0x50>
f010289c:	c7 44 24 08 11 65 10 	movl   $0xf0106511,0x8(%esp)
f01028a3:	f0 
f01028a4:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f01028ab:	00 
f01028ac:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f01028b3:	e8 88 d7 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f01028b8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01028bf:	00 
f01028c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01028c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028c8:	8b 47 60             	mov    0x60(%edi),%eax
f01028cb:	89 04 24             	mov    %eax,(%esp)
f01028ce:	e8 34 e7 ff ff       	call   f0101007 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f01028d3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028d9:	39 de                	cmp    %ebx,%esi
f01028db:	77 af                	ja     f010288c <region_alloc+0x24>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01028dd:	83 c4 1c             	add    $0x1c,%esp
f01028e0:	5b                   	pop    %ebx
f01028e1:	5e                   	pop    %esi
f01028e2:	5f                   	pop    %edi
f01028e3:	5d                   	pop    %ebp
f01028e4:	c3                   	ret    

f01028e5 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01028e5:	55                   	push   %ebp
f01028e6:	89 e5                	mov    %esp,%ebp
f01028e8:	83 ec 08             	sub    $0x8,%esp
f01028eb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01028ee:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01028f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01028f4:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01028f7:	85 c0                	test   %eax,%eax
f01028f9:	75 1a                	jne    f0102915 <envid2env+0x30>
		*env_store = curenv;
f01028fb:	e8 8c 26 00 00       	call   f0104f8c <cpunum>
f0102900:	6b c0 74             	imul   $0x74,%eax,%eax
f0102903:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0102909:	8b 55 0c             	mov    0xc(%ebp),%edx
f010290c:	89 02                	mov    %eax,(%edx)
		return 0;
f010290e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102913:	eb 70                	jmp    f0102985 <envid2env+0xa0>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102915:	89 c3                	mov    %eax,%ebx
f0102917:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010291d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102920:	03 1d 50 02 22 f0    	add    0xf0220250,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102926:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010292a:	74 05                	je     f0102931 <envid2env+0x4c>
f010292c:	39 43 48             	cmp    %eax,0x48(%ebx)
f010292f:	74 10                	je     f0102941 <envid2env+0x5c>
		*env_store = 0;
f0102931:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102934:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010293a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010293f:	eb 44                	jmp    f0102985 <envid2env+0xa0>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102941:	84 d2                	test   %dl,%dl
f0102943:	74 36                	je     f010297b <envid2env+0x96>
f0102945:	e8 42 26 00 00       	call   f0104f8c <cpunum>
f010294a:	6b c0 74             	imul   $0x74,%eax,%eax
f010294d:	39 98 28 10 22 f0    	cmp    %ebx,-0xfddefd8(%eax)
f0102953:	74 26                	je     f010297b <envid2env+0x96>
f0102955:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102958:	e8 2f 26 00 00       	call   f0104f8c <cpunum>
f010295d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102960:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0102966:	3b 70 48             	cmp    0x48(%eax),%esi
f0102969:	74 10                	je     f010297b <envid2env+0x96>
		*env_store = 0;
f010296b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010296e:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		return -E_BAD_ENV;
f0102974:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102979:	eb 0a                	jmp    f0102985 <envid2env+0xa0>
	}

	*env_store = e;
f010297b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010297e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102980:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102985:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0102988:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010298b:	89 ec                	mov    %ebp,%esp
f010298d:	5d                   	pop    %ebp
f010298e:	c3                   	ret    

f010298f <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010298f:	55                   	push   %ebp
f0102990:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102992:	b8 00 e3 11 f0       	mov    $0xf011e300,%eax
f0102997:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010299a:	b8 23 00 00 00       	mov    $0x23,%eax
f010299f:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01029a1:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01029a3:	b0 10                	mov    $0x10,%al
f01029a5:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01029a7:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01029a9:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01029ab:	ea b2 29 10 f0 08 00 	ljmp   $0x8,$0xf01029b2
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01029b2:	b0 00                	mov    $0x0,%al
f01029b4:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01029b7:	5d                   	pop    %ebp
f01029b8:	c3                   	ret    

f01029b9 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01029b9:	55                   	push   %ebp
f01029ba:	89 e5                	mov    %esp,%ebp
f01029bc:	56                   	push   %esi
f01029bd:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
		envs[i].env_id = 0;
f01029be:	8b 35 50 02 22 f0    	mov    0xf0220250,%esi
f01029c4:	8b 0d 54 02 22 f0    	mov    0xf0220254,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01029ca:	8d 86 00 f0 01 00    	lea    0x1f000(%esi),%eax
f01029d0:	ba 01 04 00 00       	mov    $0x401,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
		envs[i].env_id = 0;
f01029d5:	89 c3                	mov    %eax,%ebx
f01029d7:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01029de:	89 48 44             	mov    %ecx,0x44(%eax)
f01029e1:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f01029e4:	89 d9                	mov    %ebx,%ecx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
f01029e6:	83 ea 01             	sub    $0x1,%edx
f01029e9:	75 ea                	jne    f01029d5 <env_init+0x1c>
f01029eb:	89 35 54 02 22 f0    	mov    %esi,0xf0220254
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01029f1:	e8 99 ff ff ff       	call   f010298f <env_init_percpu>
}
f01029f6:	5b                   	pop    %ebx
f01029f7:	5e                   	pop    %esi
f01029f8:	5d                   	pop    %ebp
f01029f9:	c3                   	ret    

f01029fa <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01029fa:	55                   	push   %ebp
f01029fb:	89 e5                	mov    %esp,%ebp
f01029fd:	53                   	push   %ebx
f01029fe:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102a01:	8b 1d 54 02 22 f0    	mov    0xf0220254,%ebx
f0102a07:	85 db                	test   %ebx,%ebx
f0102a09:	0f 84 87 01 00 00    	je     f0102b96 <env_alloc+0x19c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102a0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102a16:	e8 32 e3 ff ff       	call   f0100d4d <page_alloc>
f0102a1b:	85 c0                	test   %eax,%eax
f0102a1d:	0f 84 7a 01 00 00    	je     f0102b9d <env_alloc+0x1a3>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102a23:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102a28:	2b 05 f0 0e 22 f0    	sub    0xf0220ef0,%eax
f0102a2e:	c1 f8 03             	sar    $0x3,%eax
f0102a31:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a34:	89 c2                	mov    %eax,%edx
f0102a36:	c1 ea 0c             	shr    $0xc,%edx
f0102a39:	3b 15 e8 0e 22 f0    	cmp    0xf0220ee8,%edx
f0102a3f:	72 20                	jb     f0102a61 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a45:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102a54:	00 
f0102a55:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0102a5c:	e8 df d5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102a61:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0102a66:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102a69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a70:	00 
f0102a71:	8b 15 ec 0e 22 f0    	mov    0xf0220eec,%edx
f0102a77:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102a7b:	89 04 24             	mov    %eax,(%esp)
f0102a7e:	e8 39 1f 00 00       	call   f01049bc <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a83:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a8b:	77 20                	ja     f0102aad <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a91:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102aad:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ab3:	83 ca 05             	or     $0x5,%edx
f0102ab6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102abc:	8b 43 48             	mov    0x48(%ebx),%eax
f0102abf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ac4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ac9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ace:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ad1:	89 da                	mov    %ebx,%edx
f0102ad3:	2b 15 50 02 22 f0    	sub    0xf0220250,%edx
f0102ad9:	c1 fa 02             	sar    $0x2,%edx
f0102adc:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102ae2:	09 d0                	or     %edx,%eax
f0102ae4:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102aea:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102aed:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102af4:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102afb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b02:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102b09:	00 
f0102b0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b11:	00 
f0102b12:	89 1c 24             	mov    %ebx,(%esp)
f0102b15:	e8 cb 1d 00 00       	call   f01048e5 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b1a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102b20:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b26:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102b2c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b33:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102b39:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102b40:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102b44:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b47:	a3 54 02 22 f0       	mov    %eax,0xf0220254
	*newenv_store = e;
f0102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b4f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b51:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102b54:	e8 33 24 00 00       	call   f0104f8c <cpunum>
f0102b59:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b61:	83 b8 28 10 22 f0 00 	cmpl   $0x0,-0xfddefd8(%eax)
f0102b68:	74 11                	je     f0102b7b <env_alloc+0x181>
f0102b6a:	e8 1d 24 00 00       	call   f0104f8c <cpunum>
f0102b6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b72:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0102b78:	8b 50 48             	mov    0x48(%eax),%edx
f0102b7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102b83:	c7 04 24 31 65 10 f0 	movl   $0xf0106531,(%esp)
f0102b8a:	e8 eb 05 00 00       	call   f010317a <cprintf>
	return 0;
f0102b8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b94:	eb 0c                	jmp    f0102ba2 <env_alloc+0x1a8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102b96:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102b9b:	eb 05                	jmp    f0102ba2 <env_alloc+0x1a8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102b9d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102ba2:	83 c4 14             	add    $0x14,%esp
f0102ba5:	5b                   	pop    %ebx
f0102ba6:	5d                   	pop    %ebp
f0102ba7:	c3                   	ret    

f0102ba8 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102ba8:	55                   	push   %ebp
f0102ba9:	89 e5                	mov    %esp,%ebp
f0102bab:	57                   	push   %edi
f0102bac:	56                   	push   %esi
f0102bad:	53                   	push   %ebx
f0102bae:	83 ec 3c             	sub    $0x3c,%esp
f0102bb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0102bb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102bbb:	00 
f0102bbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102bbf:	89 04 24             	mov    %eax,(%esp)
f0102bc2:	e8 33 fe ff ff       	call   f01029fa <env_alloc>
	load_icode(penv, binary, size);
f0102bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0102bcd:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102bd3:	74 1c                	je     f0102bf1 <env_create+0x49>
		panic("Not executable!");
f0102bd5:	c7 44 24 08 46 65 10 	movl   $0xf0106546,0x8(%esp)
f0102bdc:	f0 
f0102bdd:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f0102be4:	00 
f0102be5:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102bec:	e8 4f d4 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102bf1:	89 fb                	mov    %edi,%ebx
f0102bf3:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102bf6:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102bfa:	c1 e6 05             	shl    $0x5,%esi
f0102bfd:	01 de                	add    %ebx,%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0102bff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c02:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c05:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c0a:	77 20                	ja     f0102c2c <env_create+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c10:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0102c1f:	00 
f0102c20:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102c27:	e8 14 d4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102c2c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c31:	0f 22 d8             	mov    %eax,%cr3
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0102c34:	39 f3                	cmp    %esi,%ebx
f0102c36:	73 69                	jae    f0102ca1 <env_create+0xf9>
		if (ph->p_type == ELF_PROG_LOAD) {
f0102c38:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c3b:	75 5d                	jne    f0102c9a <env_create+0xf2>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c3d:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c40:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c46:	e8 1d fc ff ff       	call   f0102868 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0102c4b:	8b 43 14             	mov    0x14(%ebx),%eax
f0102c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c59:	00 
f0102c5a:	8b 43 08             	mov    0x8(%ebx),%eax
f0102c5d:	89 04 24             	mov    %eax,(%esp)
f0102c60:	e8 80 1c 00 00       	call   f01048e5 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102c65:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c68:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c6c:	89 f8                	mov    %edi,%eax
f0102c6e:	03 43 04             	add    0x4(%ebx),%eax
f0102c71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c75:	8b 43 08             	mov    0x8(%ebx),%eax
f0102c78:	89 04 24             	mov    %eax,(%esp)
f0102c7b:	e8 3c 1d 00 00       	call   f01049bc <memcpy>
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
f0102c80:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c83:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c87:	8b 43 14             	mov    0x14(%ebx),%eax
f0102c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c8e:	c7 04 24 56 65 10 f0 	movl   $0xf0106556,(%esp)
f0102c95:	e8 e0 04 00 00       	call   f010317a <cprintf>
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0102c9a:	83 c3 20             	add    $0x20,%ebx
f0102c9d:	39 de                	cmp    %ebx,%esi
f0102c9f:	77 97                	ja     f0102c38 <env_create+0x90>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f0102ca1:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ca6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cab:	77 20                	ja     f0102ccd <env_create+0x125>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cb1:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102cb8:	f0 
f0102cb9:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0102cc0:	00 
f0102cc1:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102cc8:	e8 73 d3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ccd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cd2:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102cd5:	8b 47 18             	mov    0x18(%edi),%eax
f0102cd8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102cdb:	89 42 30             	mov    %eax,0x30(%edx)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0102cde:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102ce3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102ce8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ceb:	e8 78 fb ff ff       	call   f0102868 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f0102cf0:	83 c4 3c             	add    $0x3c,%esp
f0102cf3:	5b                   	pop    %ebx
f0102cf4:	5e                   	pop    %esi
f0102cf5:	5f                   	pop    %edi
f0102cf6:	5d                   	pop    %ebp
f0102cf7:	c3                   	ret    

f0102cf8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102cf8:	55                   	push   %ebp
f0102cf9:	89 e5                	mov    %esp,%ebp
f0102cfb:	57                   	push   %edi
f0102cfc:	56                   	push   %esi
f0102cfd:	53                   	push   %ebx
f0102cfe:	83 ec 2c             	sub    $0x2c,%esp
f0102d01:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d04:	e8 83 22 00 00       	call   f0104f8c <cpunum>
f0102d09:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d0c:	39 b8 28 10 22 f0    	cmp    %edi,-0xfddefd8(%eax)
f0102d12:	75 34                	jne    f0102d48 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0102d14:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d1e:	77 20                	ja     f0102d40 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d24:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102d2b:	f0 
f0102d2c:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0102d33:	00 
f0102d34:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102d3b:	e8 00 d3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d40:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d45:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d48:	8b 5f 48             	mov    0x48(%edi),%ebx
f0102d4b:	e8 3c 22 00 00       	call   f0104f8c <cpunum>
f0102d50:	6b d0 74             	imul   $0x74,%eax,%edx
f0102d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d58:	83 ba 28 10 22 f0 00 	cmpl   $0x0,-0xfddefd8(%edx)
f0102d5f:	74 11                	je     f0102d72 <env_free+0x7a>
f0102d61:	e8 26 22 00 00       	call   f0104f8c <cpunum>
f0102d66:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d69:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0102d6f:	8b 40 48             	mov    0x48(%eax),%eax
f0102d72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102d76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d7a:	c7 04 24 71 65 10 f0 	movl   $0xf0106571,(%esp)
f0102d81:	e8 f4 03 00 00       	call   f010317a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
f0102d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d90:	c1 e0 02             	shl    $0x2,%eax
f0102d93:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d96:	8b 47 60             	mov    0x60(%edi),%eax
f0102d99:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d9c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d9f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102da5:	0f 84 b7 00 00 00    	je     f0102e62 <env_free+0x16a>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102dab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102db1:	89 f0                	mov    %esi,%eax
f0102db3:	c1 e8 0c             	shr    $0xc,%eax
f0102db6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102db9:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f0102dbf:	72 20                	jb     f0102de1 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dc1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dc5:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0102dcc:	f0 
f0102dcd:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0102dd4:	00 
f0102dd5:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102ddc:	e8 5f d2 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102de1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102de4:	c1 e2 16             	shl    $0x16,%edx
f0102de7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102dea:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102def:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102df6:	01 
f0102df7:	74 17                	je     f0102e10 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102df9:	89 d8                	mov    %ebx,%eax
f0102dfb:	c1 e0 0c             	shl    $0xc,%eax
f0102dfe:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102e01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e05:	8b 47 60             	mov    0x60(%edi),%eax
f0102e08:	89 04 24             	mov    %eax,(%esp)
f0102e0b:	e8 a7 e1 ff ff       	call   f0100fb7 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e10:	83 c3 01             	add    $0x1,%ebx
f0102e13:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e19:	75 d4                	jne    f0102def <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e1b:	8b 47 60             	mov    0x60(%edi),%eax
f0102e1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e21:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e28:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e2b:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f0102e31:	72 1c                	jb     f0102e4f <env_free+0x157>
		panic("pa2page called with invalid pa");
f0102e33:	c7 44 24 08 84 5c 10 	movl   $0xf0105c84,0x8(%esp)
f0102e3a:	f0 
f0102e3b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0102e42:	00 
f0102e43:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0102e4a:	e8 f1 d1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0102e4f:	a1 f0 0e 22 f0       	mov    0xf0220ef0,%eax
f0102e54:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e57:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0102e5a:	89 04 24             	mov    %eax,(%esp)
f0102e5d:	e8 91 df ff ff       	call   f0100df3 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e62:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102e66:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102e6d:	0f 85 1a ff ff ff    	jne    f0102d8d <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102e73:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e7b:	77 20                	ja     f0102e9d <env_free+0x1a5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e81:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102e88:	f0 
f0102e89:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f0102e90:	00 
f0102e91:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102e98:	e8 a3 d1 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0102e9d:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102ea4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ea9:	c1 e8 0c             	shr    $0xc,%eax
f0102eac:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f0102eb2:	72 1c                	jb     f0102ed0 <env_free+0x1d8>
		panic("pa2page called with invalid pa");
f0102eb4:	c7 44 24 08 84 5c 10 	movl   $0xf0105c84,0x8(%esp)
f0102ebb:	f0 
f0102ebc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0102ec3:	00 
f0102ec4:	c7 04 24 87 62 10 f0 	movl   $0xf0106287,(%esp)
f0102ecb:	e8 70 d1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0102ed0:	8b 15 f0 0e 22 f0    	mov    0xf0220ef0,%edx
f0102ed6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0102ed9:	89 04 24             	mov    %eax,(%esp)
f0102edc:	e8 12 df ff ff       	call   f0100df3 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ee1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102ee8:	a1 54 02 22 f0       	mov    0xf0220254,%eax
f0102eed:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102ef0:	89 3d 54 02 22 f0    	mov    %edi,0xf0220254
}
f0102ef6:	83 c4 2c             	add    $0x2c,%esp
f0102ef9:	5b                   	pop    %ebx
f0102efa:	5e                   	pop    %esi
f0102efb:	5f                   	pop    %edi
f0102efc:	5d                   	pop    %ebp
f0102efd:	c3                   	ret    

f0102efe <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0102efe:	55                   	push   %ebp
f0102eff:	89 e5                	mov    %esp,%ebp
f0102f01:	53                   	push   %ebx
f0102f02:	83 ec 14             	sub    $0x14,%esp
f0102f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0102f08:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0102f0c:	75 19                	jne    f0102f27 <env_destroy+0x29>
f0102f0e:	e8 79 20 00 00       	call   f0104f8c <cpunum>
f0102f13:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f16:	39 98 28 10 22 f0    	cmp    %ebx,-0xfddefd8(%eax)
f0102f1c:	74 09                	je     f0102f27 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0102f1e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0102f25:	eb 2f                	jmp    f0102f56 <env_destroy+0x58>
	}

	env_free(e);
f0102f27:	89 1c 24             	mov    %ebx,(%esp)
f0102f2a:	e8 c9 fd ff ff       	call   f0102cf8 <env_free>

	if (curenv == e) {
f0102f2f:	e8 58 20 00 00       	call   f0104f8c <cpunum>
f0102f34:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f37:	39 98 28 10 22 f0    	cmp    %ebx,-0xfddefd8(%eax)
f0102f3d:	75 17                	jne    f0102f56 <env_destroy+0x58>
		curenv = NULL;
f0102f3f:	e8 48 20 00 00       	call   f0104f8c <cpunum>
f0102f44:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f47:	c7 80 28 10 22 f0 00 	movl   $0x0,-0xfddefd8(%eax)
f0102f4e:	00 00 00 
		sched_yield();
f0102f51:	e8 2a 0b 00 00       	call   f0103a80 <sched_yield>
	}
}
f0102f56:	83 c4 14             	add    $0x14,%esp
f0102f59:	5b                   	pop    %ebx
f0102f5a:	5d                   	pop    %ebp
f0102f5b:	c3                   	ret    

f0102f5c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f5c:	55                   	push   %ebp
f0102f5d:	89 e5                	mov    %esp,%ebp
f0102f5f:	53                   	push   %ebx
f0102f60:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102f63:	e8 24 20 00 00       	call   f0104f8c <cpunum>
f0102f68:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f6b:	8b 98 28 10 22 f0    	mov    -0xfddefd8(%eax),%ebx
f0102f71:	e8 16 20 00 00       	call   f0104f8c <cpunum>
f0102f76:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0102f79:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f7c:	61                   	popa   
f0102f7d:	07                   	pop    %es
f0102f7e:	1f                   	pop    %ds
f0102f7f:	83 c4 08             	add    $0x8,%esp
f0102f82:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f83:	c7 44 24 08 87 65 10 	movl   $0xf0106587,0x8(%esp)
f0102f8a:	f0 
f0102f8b:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
f0102f92:	00 
f0102f93:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102f9a:	e8 a1 d0 ff ff       	call   f0100040 <_panic>

f0102f9f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f9f:	55                   	push   %ebp
f0102fa0:	89 e5                	mov    %esp,%ebp
f0102fa2:	53                   	push   %ebx
f0102fa3:	83 ec 14             	sub    $0x14,%esp
f0102fa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e->env_status == ENV_RUNNING)
f0102fa9:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0102fad:	75 07                	jne    f0102fb6 <env_run+0x17>
		e->env_status = ENV_RUNNABLE;
f0102faf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	curenv = e;
f0102fb6:	e8 d1 1f 00 00       	call   f0104f8c <cpunum>
f0102fbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fbe:	89 98 28 10 22 f0    	mov    %ebx,-0xfddefd8(%eax)
	e->env_status = ENV_RUNNING;
f0102fc4:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0102fcb:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0102fcf:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fd2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fd7:	77 20                	ja     f0102ff9 <env_run+0x5a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fdd:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0102fe4:	f0 
f0102fe5:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f0102fec:	00 
f0102fed:	c7 04 24 26 65 10 f0 	movl   $0xf0106526,(%esp)
f0102ff4:	e8 47 d0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ff9:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ffe:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&e->env_tf);
f0103001:	89 1c 24             	mov    %ebx,(%esp)
f0103004:	e8 53 ff ff ff       	call   f0102f5c <env_pop_tf>
f0103009:	00 00                	add    %al,(%eax)
	...

f010300c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010300c:	55                   	push   %ebp
f010300d:	89 e5                	mov    %esp,%ebp
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010300f:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103013:	ba 70 00 00 00       	mov    $0x70,%edx
f0103018:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103019:	b2 71                	mov    $0x71,%dl
f010301b:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010301c:	0f b6 c0             	movzbl %al,%eax
}
f010301f:	5d                   	pop    %ebp
f0103020:	c3                   	ret    

f0103021 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103021:	55                   	push   %ebp
f0103022:	89 e5                	mov    %esp,%ebp
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103024:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103028:	ba 70 00 00 00       	mov    $0x70,%edx
f010302d:	ee                   	out    %al,(%dx)
f010302e:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f0103032:	b2 71                	mov    $0x71,%dl
f0103034:	ee                   	out    %al,(%dx)
f0103035:	5d                   	pop    %ebp
f0103036:	c3                   	ret    
	...

f0103038 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103038:	55                   	push   %ebp
f0103039:	89 e5                	mov    %esp,%ebp
f010303b:	56                   	push   %esi
f010303c:	53                   	push   %ebx
f010303d:	83 ec 10             	sub    $0x10,%esp
f0103040:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103043:	66 a3 88 e3 11 f0    	mov    %ax,0xf011e388
	if (!didinit)
f0103049:	80 3d 58 02 22 f0 00 	cmpb   $0x0,0xf0220258
f0103050:	74 4e                	je     f01030a0 <irq_setmask_8259A+0x68>
f0103052:	89 c6                	mov    %eax,%esi
f0103054:	ba 21 00 00 00       	mov    $0x21,%edx
f0103059:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f010305a:	66 c1 e8 08          	shr    $0x8,%ax
f010305e:	b2 a1                	mov    $0xa1,%dl
f0103060:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103061:	c7 04 24 93 65 10 f0 	movl   $0xf0106593,(%esp)
f0103068:	e8 0d 01 00 00       	call   f010317a <cprintf>
	for (i = 0; i < 16; i++)
f010306d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103072:	0f b7 f6             	movzwl %si,%esi
f0103075:	f7 d6                	not    %esi
f0103077:	0f a3 de             	bt     %ebx,%esi
f010307a:	73 10                	jae    f010308c <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f010307c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103080:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f0103087:	e8 ee 00 00 00       	call   f010317a <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010308c:	83 c3 01             	add    $0x1,%ebx
f010308f:	83 fb 10             	cmp    $0x10,%ebx
f0103092:	75 e3                	jne    f0103077 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103094:	c7 04 24 cc 57 10 f0 	movl   $0xf01057cc,(%esp)
f010309b:	e8 da 00 00 00       	call   f010317a <cprintf>
}
f01030a0:	83 c4 10             	add    $0x10,%esp
f01030a3:	5b                   	pop    %ebx
f01030a4:	5e                   	pop    %esi
f01030a5:	5d                   	pop    %ebp
f01030a6:	c3                   	ret    

f01030a7 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01030a7:	c6 05 58 02 22 f0 01 	movb   $0x1,0xf0220258
f01030ae:	ba 21 00 00 00       	mov    $0x21,%edx
f01030b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01030b8:	ee                   	out    %al,(%dx)
f01030b9:	b2 a1                	mov    $0xa1,%dl
f01030bb:	ee                   	out    %al,(%dx)
f01030bc:	b2 20                	mov    $0x20,%dl
f01030be:	b8 11 00 00 00       	mov    $0x11,%eax
f01030c3:	ee                   	out    %al,(%dx)
f01030c4:	b2 21                	mov    $0x21,%dl
f01030c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01030cb:	ee                   	out    %al,(%dx)
f01030cc:	b8 04 00 00 00       	mov    $0x4,%eax
f01030d1:	ee                   	out    %al,(%dx)
f01030d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01030d7:	ee                   	out    %al,(%dx)
f01030d8:	b2 a0                	mov    $0xa0,%dl
f01030da:	b8 11 00 00 00       	mov    $0x11,%eax
f01030df:	ee                   	out    %al,(%dx)
f01030e0:	b2 a1                	mov    $0xa1,%dl
f01030e2:	b8 28 00 00 00       	mov    $0x28,%eax
f01030e7:	ee                   	out    %al,(%dx)
f01030e8:	b8 02 00 00 00       	mov    $0x2,%eax
f01030ed:	ee                   	out    %al,(%dx)
f01030ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01030f3:	ee                   	out    %al,(%dx)
f01030f4:	b2 20                	mov    $0x20,%dl
f01030f6:	b8 68 00 00 00       	mov    $0x68,%eax
f01030fb:	ee                   	out    %al,(%dx)
f01030fc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103101:	ee                   	out    %al,(%dx)
f0103102:	b2 a0                	mov    $0xa0,%dl
f0103104:	b8 68 00 00 00       	mov    $0x68,%eax
f0103109:	ee                   	out    %al,(%dx)
f010310a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010310f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103110:	0f b7 05 88 e3 11 f0 	movzwl 0xf011e388,%eax
f0103117:	66 83 f8 ff          	cmp    $0xffff,%ax
f010311b:	74 12                	je     f010312f <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010311d:	55                   	push   %ebp
f010311e:	89 e5                	mov    %esp,%ebp
f0103120:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103123:	0f b7 c0             	movzwl %ax,%eax
f0103126:	89 04 24             	mov    %eax,(%esp)
f0103129:	e8 0a ff ff ff       	call   f0103038 <irq_setmask_8259A>
}
f010312e:	c9                   	leave  
f010312f:	f3 c3                	repz ret 
f0103131:	00 00                	add    %al,(%eax)
	...

f0103134 <putch>:
#include <inc/stdarg.h>

//print in kern/print.c is calling printfmt in lib/
static void
putch(int ch, int *cnt)
{
f0103134:	55                   	push   %ebp
f0103135:	89 e5                	mov    %esp,%ebp
f0103137:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010313a:	8b 45 08             	mov    0x8(%ebp),%eax
f010313d:	89 04 24             	mov    %eax,(%esp)
f0103140:	e8 3d d6 ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f0103145:	c9                   	leave  
f0103146:	c3                   	ret    

f0103147 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103147:	55                   	push   %ebp
f0103148:	89 e5                	mov    %esp,%ebp
f010314a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010314d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103154:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103157:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010315b:	8b 45 08             	mov    0x8(%ebp),%eax
f010315e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103162:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103165:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103169:	c7 04 24 34 31 10 f0 	movl   $0xf0103134,(%esp)
f0103170:	e8 0d 10 00 00       	call   f0104182 <vprintfmt>
	return cnt;
}
f0103175:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103178:	c9                   	leave  
f0103179:	c3                   	ret    

f010317a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010317a:	55                   	push   %ebp
f010317b:	89 e5                	mov    %esp,%ebp
f010317d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103180:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103183:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103187:	8b 45 08             	mov    0x8(%ebp),%eax
f010318a:	89 04 24             	mov    %eax,(%esp)
f010318d:	e8 b5 ff ff ff       	call   f0103147 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103192:	c9                   	leave  
f0103193:	c3                   	ret    

f0103194 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103194:	55                   	push   %ebp
f0103195:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103197:	c7 05 64 0a 22 f0 00 	movl   $0xf0000000,0xf0220a64
f010319e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01031a1:	66 c7 05 68 0a 22 f0 	movw   $0x10,0xf0220a68
f01031a8:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01031aa:	66 c7 05 48 e3 11 f0 	movw   $0x68,0xf011e348
f01031b1:	68 00 
f01031b3:	b8 60 0a 22 f0       	mov    $0xf0220a60,%eax
f01031b8:	66 a3 4a e3 11 f0    	mov    %ax,0xf011e34a
f01031be:	89 c2                	mov    %eax,%edx
f01031c0:	c1 ea 10             	shr    $0x10,%edx
f01031c3:	88 15 4c e3 11 f0    	mov    %dl,0xf011e34c
f01031c9:	c6 05 4e e3 11 f0 40 	movb   $0x40,0xf011e34e
f01031d0:	c1 e8 18             	shr    $0x18,%eax
f01031d3:	a2 4f e3 11 f0       	mov    %al,0xf011e34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01031d8:	c6 05 4d e3 11 f0 89 	movb   $0x89,0xf011e34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01031df:	b8 28 00 00 00       	mov    $0x28,%eax
f01031e4:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01031e7:	b8 8c e3 11 f0       	mov    $0xf011e38c,%eax
f01031ec:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01031ef:	5d                   	pop    %ebp
f01031f0:	c3                   	ret    

f01031f1 <trap_init>:
}


void
trap_init(void)
{
f01031f1:	55                   	push   %ebp
f01031f2:	89 e5                	mov    %esp,%ebp
  void th12();
  void th13();
  void th14();
  void th16();
	void th48();
  SETGATE(idt[0], 0, GD_KT, th0, 0);
f01031f4:	b8 38 39 10 f0       	mov    $0xf0103938,%eax
f01031f9:	66 a3 60 02 22 f0    	mov    %ax,0xf0220260
f01031ff:	66 c7 05 62 02 22 f0 	movw   $0x8,0xf0220262
f0103206:	08 00 
f0103208:	c6 05 64 02 22 f0 00 	movb   $0x0,0xf0220264
f010320f:	c6 05 65 02 22 f0 8e 	movb   $0x8e,0xf0220265
f0103216:	c1 e8 10             	shr    $0x10,%eax
f0103219:	66 a3 66 02 22 f0    	mov    %ax,0xf0220266
  SETGATE(idt[1], 0, GD_KT, th1, 0);
f010321f:	b8 3e 39 10 f0       	mov    $0xf010393e,%eax
f0103224:	66 a3 68 02 22 f0    	mov    %ax,0xf0220268
f010322a:	66 c7 05 6a 02 22 f0 	movw   $0x8,0xf022026a
f0103231:	08 00 
f0103233:	c6 05 6c 02 22 f0 00 	movb   $0x0,0xf022026c
f010323a:	c6 05 6d 02 22 f0 8e 	movb   $0x8e,0xf022026d
f0103241:	c1 e8 10             	shr    $0x10,%eax
f0103244:	66 a3 6e 02 22 f0    	mov    %ax,0xf022026e
  //modify 0 to 3 to pass breakpoint test.
	SETGATE(idt[3], 0, GD_KT, th3, 0);
f010324a:	b8 44 39 10 f0       	mov    $0xf0103944,%eax
f010324f:	66 a3 78 02 22 f0    	mov    %ax,0xf0220278
f0103255:	66 c7 05 7a 02 22 f0 	movw   $0x8,0xf022027a
f010325c:	08 00 
f010325e:	c6 05 7c 02 22 f0 00 	movb   $0x0,0xf022027c
f0103265:	c1 e8 10             	shr    $0x10,%eax
f0103268:	66 a3 7e 02 22 f0    	mov    %ax,0xf022027e
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f010326e:	c6 05 7d 02 22 f0 ee 	movb   $0xee,0xf022027d
  SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103275:	b8 4a 39 10 f0       	mov    $0xf010394a,%eax
f010327a:	66 a3 80 02 22 f0    	mov    %ax,0xf0220280
f0103280:	66 c7 05 82 02 22 f0 	movw   $0x8,0xf0220282
f0103287:	08 00 
f0103289:	c6 05 84 02 22 f0 00 	movb   $0x0,0xf0220284
f0103290:	c6 05 85 02 22 f0 8e 	movb   $0x8e,0xf0220285
f0103297:	c1 e8 10             	shr    $0x10,%eax
f010329a:	66 a3 86 02 22 f0    	mov    %ax,0xf0220286
  SETGATE(idt[5], 0, GD_KT, th5, 0);
f01032a0:	b8 50 39 10 f0       	mov    $0xf0103950,%eax
f01032a5:	66 a3 88 02 22 f0    	mov    %ax,0xf0220288
f01032ab:	66 c7 05 8a 02 22 f0 	movw   $0x8,0xf022028a
f01032b2:	08 00 
f01032b4:	c6 05 8c 02 22 f0 00 	movb   $0x0,0xf022028c
f01032bb:	c6 05 8d 02 22 f0 8e 	movb   $0x8e,0xf022028d
f01032c2:	c1 e8 10             	shr    $0x10,%eax
f01032c5:	66 a3 8e 02 22 f0    	mov    %ax,0xf022028e
  SETGATE(idt[6], 0, GD_KT, th6, 0);
f01032cb:	b8 56 39 10 f0       	mov    $0xf0103956,%eax
f01032d0:	66 a3 90 02 22 f0    	mov    %ax,0xf0220290
f01032d6:	66 c7 05 92 02 22 f0 	movw   $0x8,0xf0220292
f01032dd:	08 00 
f01032df:	c6 05 94 02 22 f0 00 	movb   $0x0,0xf0220294
f01032e6:	c6 05 95 02 22 f0 8e 	movb   $0x8e,0xf0220295
f01032ed:	c1 e8 10             	shr    $0x10,%eax
f01032f0:	66 a3 96 02 22 f0    	mov    %ax,0xf0220296
  SETGATE(idt[7], 0, GD_KT, th7, 0);
f01032f6:	b8 5c 39 10 f0       	mov    $0xf010395c,%eax
f01032fb:	66 a3 98 02 22 f0    	mov    %ax,0xf0220298
f0103301:	66 c7 05 9a 02 22 f0 	movw   $0x8,0xf022029a
f0103308:	08 00 
f010330a:	c6 05 9c 02 22 f0 00 	movb   $0x0,0xf022029c
f0103311:	c6 05 9d 02 22 f0 8e 	movb   $0x8e,0xf022029d
f0103318:	c1 e8 10             	shr    $0x10,%eax
f010331b:	66 a3 9e 02 22 f0    	mov    %ax,0xf022029e
  SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103321:	b8 62 39 10 f0       	mov    $0xf0103962,%eax
f0103326:	66 a3 a0 02 22 f0    	mov    %ax,0xf02202a0
f010332c:	66 c7 05 a2 02 22 f0 	movw   $0x8,0xf02202a2
f0103333:	08 00 
f0103335:	c6 05 a4 02 22 f0 00 	movb   $0x0,0xf02202a4
f010333c:	c6 05 a5 02 22 f0 8e 	movb   $0x8e,0xf02202a5
f0103343:	c1 e8 10             	shr    $0x10,%eax
f0103346:	66 a3 a6 02 22 f0    	mov    %ax,0xf02202a6
  SETGATE(idt[9], 0, GD_KT, th9, 0);
f010334c:	b8 66 39 10 f0       	mov    $0xf0103966,%eax
f0103351:	66 a3 a8 02 22 f0    	mov    %ax,0xf02202a8
f0103357:	66 c7 05 aa 02 22 f0 	movw   $0x8,0xf02202aa
f010335e:	08 00 
f0103360:	c6 05 ac 02 22 f0 00 	movb   $0x0,0xf02202ac
f0103367:	c6 05 ad 02 22 f0 8e 	movb   $0x8e,0xf02202ad
f010336e:	c1 e8 10             	shr    $0x10,%eax
f0103371:	66 a3 ae 02 22 f0    	mov    %ax,0xf02202ae
  SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103377:	b8 6c 39 10 f0       	mov    $0xf010396c,%eax
f010337c:	66 a3 b0 02 22 f0    	mov    %ax,0xf02202b0
f0103382:	66 c7 05 b2 02 22 f0 	movw   $0x8,0xf02202b2
f0103389:	08 00 
f010338b:	c6 05 b4 02 22 f0 00 	movb   $0x0,0xf02202b4
f0103392:	c6 05 b5 02 22 f0 8e 	movb   $0x8e,0xf02202b5
f0103399:	c1 e8 10             	shr    $0x10,%eax
f010339c:	66 a3 b6 02 22 f0    	mov    %ax,0xf02202b6
  SETGATE(idt[11], 0, GD_KT, th11, 0);
f01033a2:	b8 70 39 10 f0       	mov    $0xf0103970,%eax
f01033a7:	66 a3 b8 02 22 f0    	mov    %ax,0xf02202b8
f01033ad:	66 c7 05 ba 02 22 f0 	movw   $0x8,0xf02202ba
f01033b4:	08 00 
f01033b6:	c6 05 bc 02 22 f0 00 	movb   $0x0,0xf02202bc
f01033bd:	c6 05 bd 02 22 f0 8e 	movb   $0x8e,0xf02202bd
f01033c4:	c1 e8 10             	shr    $0x10,%eax
f01033c7:	66 a3 be 02 22 f0    	mov    %ax,0xf02202be
  SETGATE(idt[12], 0, GD_KT, th12, 0);
f01033cd:	b8 74 39 10 f0       	mov    $0xf0103974,%eax
f01033d2:	66 a3 c0 02 22 f0    	mov    %ax,0xf02202c0
f01033d8:	66 c7 05 c2 02 22 f0 	movw   $0x8,0xf02202c2
f01033df:	08 00 
f01033e1:	c6 05 c4 02 22 f0 00 	movb   $0x0,0xf02202c4
f01033e8:	c6 05 c5 02 22 f0 8e 	movb   $0x8e,0xf02202c5
f01033ef:	c1 e8 10             	shr    $0x10,%eax
f01033f2:	66 a3 c6 02 22 f0    	mov    %ax,0xf02202c6
  SETGATE(idt[13], 0, GD_KT, th13, 0);
f01033f8:	b8 78 39 10 f0       	mov    $0xf0103978,%eax
f01033fd:	66 a3 c8 02 22 f0    	mov    %ax,0xf02202c8
f0103403:	66 c7 05 ca 02 22 f0 	movw   $0x8,0xf02202ca
f010340a:	08 00 
f010340c:	c6 05 cc 02 22 f0 00 	movb   $0x0,0xf02202cc
f0103413:	c6 05 cd 02 22 f0 8e 	movb   $0x8e,0xf02202cd
f010341a:	c1 e8 10             	shr    $0x10,%eax
f010341d:	66 a3 ce 02 22 f0    	mov    %ax,0xf02202ce
  SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103423:	b8 7c 39 10 f0       	mov    $0xf010397c,%eax
f0103428:	66 a3 d0 02 22 f0    	mov    %ax,0xf02202d0
f010342e:	66 c7 05 d2 02 22 f0 	movw   $0x8,0xf02202d2
f0103435:	08 00 
f0103437:	c6 05 d4 02 22 f0 00 	movb   $0x0,0xf02202d4
f010343e:	c6 05 d5 02 22 f0 8e 	movb   $0x8e,0xf02202d5
f0103445:	c1 e8 10             	shr    $0x10,%eax
f0103448:	66 a3 d6 02 22 f0    	mov    %ax,0xf02202d6
  SETGATE(idt[16], 0, GD_KT, th16, 0);
f010344e:	b8 80 39 10 f0       	mov    $0xf0103980,%eax
f0103453:	66 a3 e0 02 22 f0    	mov    %ax,0xf02202e0
f0103459:	66 c7 05 e2 02 22 f0 	movw   $0x8,0xf02202e2
f0103460:	08 00 
f0103462:	c6 05 e4 02 22 f0 00 	movb   $0x0,0xf02202e4
f0103469:	c6 05 e5 02 22 f0 8e 	movb   $0x8e,0xf02202e5
f0103470:	c1 e8 10             	shr    $0x10,%eax
f0103473:	66 a3 e6 02 22 f0    	mov    %ax,0xf02202e6
	SETGATE(idt[48], 0, GD_KT, th48, 0);
f0103479:	b8 86 39 10 f0       	mov    $0xf0103986,%eax
f010347e:	66 a3 e0 03 22 f0    	mov    %ax,0xf02203e0
f0103484:	66 c7 05 e2 03 22 f0 	movw   $0x8,0xf02203e2
f010348b:	08 00 
f010348d:	c6 05 e4 03 22 f0 00 	movb   $0x0,0xf02203e4
f0103494:	c1 e8 10             	shr    $0x10,%eax
f0103497:	66 a3 e6 03 22 f0    	mov    %ax,0xf02203e6
	SETGATE(idt[48], 0, GD_KT, th48, 3);
f010349d:	c6 05 e5 03 22 f0 ee 	movb   $0xee,0xf02203e5
	// Per-CPU setup 
	trap_init_percpu();
f01034a4:	e8 eb fc ff ff       	call   f0103194 <trap_init_percpu>
}
f01034a9:	5d                   	pop    %ebp
f01034aa:	c3                   	ret    

f01034ab <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01034ab:	55                   	push   %ebp
f01034ac:	89 e5                	mov    %esp,%ebp
f01034ae:	53                   	push   %ebx
f01034af:	83 ec 14             	sub    $0x14,%esp
f01034b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01034b5:	8b 03                	mov    (%ebx),%eax
f01034b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034bb:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f01034c2:	e8 b3 fc ff ff       	call   f010317a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01034c7:	8b 43 04             	mov    0x4(%ebx),%eax
f01034ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034ce:	c7 04 24 b6 65 10 f0 	movl   $0xf01065b6,(%esp)
f01034d5:	e8 a0 fc ff ff       	call   f010317a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01034da:	8b 43 08             	mov    0x8(%ebx),%eax
f01034dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e1:	c7 04 24 c5 65 10 f0 	movl   $0xf01065c5,(%esp)
f01034e8:	e8 8d fc ff ff       	call   f010317a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01034ed:	8b 43 0c             	mov    0xc(%ebx),%eax
f01034f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034f4:	c7 04 24 d4 65 10 f0 	movl   $0xf01065d4,(%esp)
f01034fb:	e8 7a fc ff ff       	call   f010317a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103500:	8b 43 10             	mov    0x10(%ebx),%eax
f0103503:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103507:	c7 04 24 e3 65 10 f0 	movl   $0xf01065e3,(%esp)
f010350e:	e8 67 fc ff ff       	call   f010317a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103513:	8b 43 14             	mov    0x14(%ebx),%eax
f0103516:	89 44 24 04          	mov    %eax,0x4(%esp)
f010351a:	c7 04 24 f2 65 10 f0 	movl   $0xf01065f2,(%esp)
f0103521:	e8 54 fc ff ff       	call   f010317a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103526:	8b 43 18             	mov    0x18(%ebx),%eax
f0103529:	89 44 24 04          	mov    %eax,0x4(%esp)
f010352d:	c7 04 24 01 66 10 f0 	movl   $0xf0106601,(%esp)
f0103534:	e8 41 fc ff ff       	call   f010317a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103539:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010353c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103540:	c7 04 24 10 66 10 f0 	movl   $0xf0106610,(%esp)
f0103547:	e8 2e fc ff ff       	call   f010317a <cprintf>
}
f010354c:	83 c4 14             	add    $0x14,%esp
f010354f:	5b                   	pop    %ebx
f0103550:	5d                   	pop    %ebp
f0103551:	c3                   	ret    

f0103552 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103552:	55                   	push   %ebp
f0103553:	89 e5                	mov    %esp,%ebp
f0103555:	56                   	push   %esi
f0103556:	53                   	push   %ebx
f0103557:	83 ec 10             	sub    $0x10,%esp
f010355a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010355d:	e8 2a 1a 00 00       	call   f0104f8c <cpunum>
f0103562:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010356a:	c7 04 24 74 66 10 f0 	movl   $0xf0106674,(%esp)
f0103571:	e8 04 fc ff ff       	call   f010317a <cprintf>
	print_regs(&tf->tf_regs);
f0103576:	89 1c 24             	mov    %ebx,(%esp)
f0103579:	e8 2d ff ff ff       	call   f01034ab <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010357e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103582:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103586:	c7 04 24 92 66 10 f0 	movl   $0xf0106692,(%esp)
f010358d:	e8 e8 fb ff ff       	call   f010317a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103592:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103596:	89 44 24 04          	mov    %eax,0x4(%esp)
f010359a:	c7 04 24 a5 66 10 f0 	movl   $0xf01066a5,(%esp)
f01035a1:	e8 d4 fb ff ff       	call   f010317a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01035a6:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01035a9:	83 f8 13             	cmp    $0x13,%eax
f01035ac:	77 09                	ja     f01035b7 <print_trapframe+0x65>
		return excnames[trapno];
f01035ae:	8b 14 85 40 69 10 f0 	mov    -0xfef96c0(,%eax,4),%edx
f01035b5:	eb 1f                	jmp    f01035d6 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01035b7:	83 f8 30             	cmp    $0x30,%eax
f01035ba:	74 15                	je     f01035d1 <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01035bc:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01035bf:	83 fa 0f             	cmp    $0xf,%edx
f01035c2:	ba 2b 66 10 f0       	mov    $0xf010662b,%edx
f01035c7:	b9 3e 66 10 f0       	mov    $0xf010663e,%ecx
f01035cc:	0f 47 d1             	cmova  %ecx,%edx
f01035cf:	eb 05                	jmp    f01035d6 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01035d1:	ba 1f 66 10 f0       	mov    $0xf010661f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01035d6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01035da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035de:	c7 04 24 b8 66 10 f0 	movl   $0xf01066b8,(%esp)
f01035e5:	e8 90 fb ff ff       	call   f010317a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01035ea:	3b 1d c8 0a 22 f0    	cmp    0xf0220ac8,%ebx
f01035f0:	75 19                	jne    f010360b <print_trapframe+0xb9>
f01035f2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01035f6:	75 13                	jne    f010360b <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01035f8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01035fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ff:	c7 04 24 ca 66 10 f0 	movl   $0xf01066ca,(%esp)
f0103606:	e8 6f fb ff ff       	call   f010317a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010360b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010360e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103612:	c7 04 24 d9 66 10 f0 	movl   $0xf01066d9,(%esp)
f0103619:	e8 5c fb ff ff       	call   f010317a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010361e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103622:	75 51                	jne    f0103675 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103624:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103627:	89 c2                	mov    %eax,%edx
f0103629:	83 e2 01             	and    $0x1,%edx
f010362c:	ba 4d 66 10 f0       	mov    $0xf010664d,%edx
f0103631:	b9 58 66 10 f0       	mov    $0xf0106658,%ecx
f0103636:	0f 45 ca             	cmovne %edx,%ecx
f0103639:	89 c2                	mov    %eax,%edx
f010363b:	83 e2 02             	and    $0x2,%edx
f010363e:	ba 64 66 10 f0       	mov    $0xf0106664,%edx
f0103643:	be 6a 66 10 f0       	mov    $0xf010666a,%esi
f0103648:	0f 44 d6             	cmove  %esi,%edx
f010364b:	83 e0 04             	and    $0x4,%eax
f010364e:	b8 6f 66 10 f0       	mov    $0xf010666f,%eax
f0103653:	be a4 67 10 f0       	mov    $0xf01067a4,%esi
f0103658:	0f 44 c6             	cmove  %esi,%eax
f010365b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010365f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103663:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103667:	c7 04 24 e7 66 10 f0 	movl   $0xf01066e7,(%esp)
f010366e:	e8 07 fb ff ff       	call   f010317a <cprintf>
f0103673:	eb 0c                	jmp    f0103681 <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103675:	c7 04 24 cc 57 10 f0 	movl   $0xf01057cc,(%esp)
f010367c:	e8 f9 fa ff ff       	call   f010317a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103681:	8b 43 30             	mov    0x30(%ebx),%eax
f0103684:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103688:	c7 04 24 f6 66 10 f0 	movl   $0xf01066f6,(%esp)
f010368f:	e8 e6 fa ff ff       	call   f010317a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103694:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103698:	89 44 24 04          	mov    %eax,0x4(%esp)
f010369c:	c7 04 24 05 67 10 f0 	movl   $0xf0106705,(%esp)
f01036a3:	e8 d2 fa ff ff       	call   f010317a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01036a8:	8b 43 38             	mov    0x38(%ebx),%eax
f01036ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036af:	c7 04 24 18 67 10 f0 	movl   $0xf0106718,(%esp)
f01036b6:	e8 bf fa ff ff       	call   f010317a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01036bb:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01036bf:	74 27                	je     f01036e8 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01036c1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01036c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036c8:	c7 04 24 27 67 10 f0 	movl   $0xf0106727,(%esp)
f01036cf:	e8 a6 fa ff ff       	call   f010317a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01036d4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01036d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036dc:	c7 04 24 36 67 10 f0 	movl   $0xf0106736,(%esp)
f01036e3:	e8 92 fa ff ff       	call   f010317a <cprintf>
	}
}
f01036e8:	83 c4 10             	add    $0x10,%esp
f01036eb:	5b                   	pop    %ebx
f01036ec:	5e                   	pop    %esi
f01036ed:	5d                   	pop    %ebp
f01036ee:	c3                   	ret    

f01036ef <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01036ef:	55                   	push   %ebp
f01036f0:	89 e5                	mov    %esp,%ebp
f01036f2:	57                   	push   %edi
f01036f3:	56                   	push   %esi
f01036f4:	83 ec 10             	sub    $0x10,%esp
f01036f7:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01036fa:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01036fb:	83 3d e0 0e 22 f0 00 	cmpl   $0x0,0xf0220ee0
f0103702:	74 01                	je     f0103705 <trap+0x16>
		asm volatile("hlt");
f0103704:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103705:	e8 82 18 00 00       	call   f0104f8c <cpunum>
f010370a:	6b d0 74             	imul   $0x74,%eax,%edx
f010370d:	81 c2 20 10 22 f0    	add    $0xf0221020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103713:	b8 01 00 00 00       	mov    $0x1,%eax
f0103718:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010371c:	83 f8 02             	cmp    $0x2,%eax
f010371f:	75 0c                	jne    f010372d <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103721:	c7 04 24 a0 e3 11 f0 	movl   $0xf011e3a0,(%esp)
f0103728:	e8 10 1b 00 00       	call   f010523d <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010372d:	9c                   	pushf  
f010372e:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010372f:	f6 c4 02             	test   $0x2,%ah
f0103732:	74 24                	je     f0103758 <trap+0x69>
f0103734:	c7 44 24 0c 49 67 10 	movl   $0xf0106749,0xc(%esp)
f010373b:	f0 
f010373c:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0103743:	f0 
f0103744:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
f010374b:	00 
f010374c:	c7 04 24 62 67 10 f0 	movl   $0xf0106762,(%esp)
f0103753:	e8 e8 c8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103758:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010375c:	83 e0 03             	and    $0x3,%eax
f010375f:	66 83 f8 03          	cmp    $0x3,%ax
f0103763:	0f 85 9b 00 00 00    	jne    f0103804 <trap+0x115>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103769:	e8 1e 18 00 00       	call   f0104f8c <cpunum>
f010376e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103771:	83 b8 28 10 22 f0 00 	cmpl   $0x0,-0xfddefd8(%eax)
f0103778:	75 24                	jne    f010379e <trap+0xaf>
f010377a:	c7 44 24 0c 6e 67 10 	movl   $0xf010676e,0xc(%esp)
f0103781:	f0 
f0103782:	c7 44 24 08 a1 62 10 	movl   $0xf01062a1,0x8(%esp)
f0103789:	f0 
f010378a:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0103791:	00 
f0103792:	c7 04 24 62 67 10 f0 	movl   $0xf0106762,(%esp)
f0103799:	e8 a2 c8 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010379e:	e8 e9 17 00 00       	call   f0104f8c <cpunum>
f01037a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01037a6:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f01037ac:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01037b0:	75 2d                	jne    f01037df <trap+0xf0>
			env_free(curenv);
f01037b2:	e8 d5 17 00 00       	call   f0104f8c <cpunum>
f01037b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ba:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f01037c0:	89 04 24             	mov    %eax,(%esp)
f01037c3:	e8 30 f5 ff ff       	call   f0102cf8 <env_free>
			curenv = NULL;
f01037c8:	e8 bf 17 00 00       	call   f0104f8c <cpunum>
f01037cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d0:	c7 80 28 10 22 f0 00 	movl   $0x0,-0xfddefd8(%eax)
f01037d7:	00 00 00 
			sched_yield();
f01037da:	e8 a1 02 00 00       	call   f0103a80 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01037df:	e8 a8 17 00 00       	call   f0104f8c <cpunum>
f01037e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e7:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f01037ed:	b9 11 00 00 00       	mov    $0x11,%ecx
f01037f2:	89 c7                	mov    %eax,%edi
f01037f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01037f6:	e8 91 17 00 00       	call   f0104f8c <cpunum>
f01037fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01037fe:	8b b0 28 10 22 f0    	mov    -0xfddefd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103804:	89 35 c8 0a 22 f0    	mov    %esi,0xf0220ac8
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010380a:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f010380e:	75 16                	jne    f0103826 <trap+0x137>
		cprintf("Spurious interrupt on irq 7\n");
f0103810:	c7 04 24 75 67 10 f0 	movl   $0xf0106775,(%esp)
f0103817:	e8 5e f9 ff ff       	call   f010317a <cprintf>
		print_trapframe(tf);
f010381c:	89 34 24             	mov    %esi,(%esp)
f010381f:	e8 2e fd ff ff       	call   f0103552 <print_trapframe>
f0103824:	eb 41                	jmp    f0103867 <trap+0x178>
		}
	}
>>>>>>> lab3
	*/
  // Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103826:	89 34 24             	mov    %esi,(%esp)
f0103829:	e8 24 fd ff ff       	call   f0103552 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010382e:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103833:	75 1c                	jne    f0103851 <trap+0x162>
		panic("unhandled trap in kernel");
f0103835:	c7 44 24 08 92 67 10 	movl   $0xf0106792,0x8(%esp)
f010383c:	f0 
f010383d:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0103844:	00 
f0103845:	c7 04 24 62 67 10 f0 	movl   $0xf0106762,(%esp)
f010384c:	e8 ef c7 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103851:	e8 36 17 00 00       	call   f0104f8c <cpunum>
f0103856:	6b c0 74             	imul   $0x74,%eax,%eax
f0103859:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f010385f:	89 04 24             	mov    %eax,(%esp)
f0103862:	e8 97 f6 ff ff       	call   f0102efe <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103867:	e8 20 17 00 00       	call   f0104f8c <cpunum>
f010386c:	6b c0 74             	imul   $0x74,%eax,%eax
f010386f:	83 b8 28 10 22 f0 00 	cmpl   $0x0,-0xfddefd8(%eax)
f0103876:	74 2a                	je     f01038a2 <trap+0x1b3>
f0103878:	e8 0f 17 00 00       	call   f0104f8c <cpunum>
f010387d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103880:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103886:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010388a:	75 16                	jne    f01038a2 <trap+0x1b3>
		env_run(curenv);
f010388c:	e8 fb 16 00 00       	call   f0104f8c <cpunum>
f0103891:	6b c0 74             	imul   $0x74,%eax,%eax
f0103894:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f010389a:	89 04 24             	mov    %eax,(%esp)
f010389d:	e8 fd f6 ff ff       	call   f0102f9f <env_run>
	else
		sched_yield();
f01038a2:	e8 d9 01 00 00       	call   f0103a80 <sched_yield>

f01038a7 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01038a7:	55                   	push   %ebp
f01038a8:	89 e5                	mov    %esp,%ebp
f01038aa:	83 ec 28             	sub    $0x28,%esp
f01038ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01038b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01038b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01038b6:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01038b9:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
  	if ((tf->tf_cs&3) == 0)
f01038bc:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01038c0:	75 1c                	jne    f01038de <page_fault_handler+0x37>
		panic("Kernel page fault!");
f01038c2:	c7 44 24 08 ab 67 10 	movl   $0xf01067ab,0x8(%esp)
f01038c9:	f0 
f01038ca:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
f01038d1:	00 
f01038d2:	c7 04 24 62 67 10 f0 	movl   $0xf0106762,(%esp)
f01038d9:	e8 62 c7 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038de:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01038e1:	e8 a6 16 00 00       	call   f0104f8c <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038e6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01038ea:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01038ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f1:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038f7:	8b 40 48             	mov    0x48(%eax),%eax
f01038fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038fe:	c7 04 24 04 69 10 f0 	movl   $0xf0106904,(%esp)
f0103905:	e8 70 f8 ff ff       	call   f010317a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010390a:	89 1c 24             	mov    %ebx,(%esp)
f010390d:	e8 40 fc ff ff       	call   f0103552 <print_trapframe>
	env_destroy(curenv);
f0103912:	e8 75 16 00 00       	call   f0104f8c <cpunum>
f0103917:	6b c0 74             	imul   $0x74,%eax,%eax
f010391a:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103920:	89 04 24             	mov    %eax,(%esp)
f0103923:	e8 d6 f5 ff ff       	call   f0102efe <env_destroy>
}
f0103928:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010392b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010392e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103931:	89 ec                	mov    %ebp,%esp
f0103933:	5d                   	pop    %ebp
f0103934:	c3                   	ret    
f0103935:	00 00                	add    %al,(%eax)
	...

f0103938 <th0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
    TRAPHANDLER_NOEC(th0, 0)
f0103938:	6a 00                	push   $0x0
f010393a:	6a 00                	push   $0x0
f010393c:	eb 4e                	jmp    f010398c <_alltraps>

f010393e <th1>:
    TRAPHANDLER_NOEC(th1, 1)
f010393e:	6a 00                	push   $0x0
f0103940:	6a 01                	push   $0x1
f0103942:	eb 48                	jmp    f010398c <_alltraps>

f0103944 <th3>:
    TRAPHANDLER_NOEC(th3, 3)
f0103944:	6a 00                	push   $0x0
f0103946:	6a 03                	push   $0x3
f0103948:	eb 42                	jmp    f010398c <_alltraps>

f010394a <th4>:
    TRAPHANDLER_NOEC(th4, 4)
f010394a:	6a 00                	push   $0x0
f010394c:	6a 04                	push   $0x4
f010394e:	eb 3c                	jmp    f010398c <_alltraps>

f0103950 <th5>:
    TRAPHANDLER_NOEC(th5, 5)
f0103950:	6a 00                	push   $0x0
f0103952:	6a 05                	push   $0x5
f0103954:	eb 36                	jmp    f010398c <_alltraps>

f0103956 <th6>:
    TRAPHANDLER_NOEC(th6, 6)
f0103956:	6a 00                	push   $0x0
f0103958:	6a 06                	push   $0x6
f010395a:	eb 30                	jmp    f010398c <_alltraps>

f010395c <th7>:
    TRAPHANDLER_NOEC(th7, 7)
f010395c:	6a 00                	push   $0x0
f010395e:	6a 07                	push   $0x7
f0103960:	eb 2a                	jmp    f010398c <_alltraps>

f0103962 <th8>:
    TRAPHANDLER(th8, 8)
f0103962:	6a 08                	push   $0x8
f0103964:	eb 26                	jmp    f010398c <_alltraps>

f0103966 <th9>:
    TRAPHANDLER_NOEC(th9, 9)
f0103966:	6a 00                	push   $0x0
f0103968:	6a 09                	push   $0x9
f010396a:	eb 20                	jmp    f010398c <_alltraps>

f010396c <th10>:
    TRAPHANDLER(th10, 10)
f010396c:	6a 0a                	push   $0xa
f010396e:	eb 1c                	jmp    f010398c <_alltraps>

f0103970 <th11>:
    TRAPHANDLER(th11, 11)
f0103970:	6a 0b                	push   $0xb
f0103972:	eb 18                	jmp    f010398c <_alltraps>

f0103974 <th12>:
    TRAPHANDLER(th12, 12)
f0103974:	6a 0c                	push   $0xc
f0103976:	eb 14                	jmp    f010398c <_alltraps>

f0103978 <th13>:
    TRAPHANDLER(th13, 13)
f0103978:	6a 0d                	push   $0xd
f010397a:	eb 10                	jmp    f010398c <_alltraps>

f010397c <th14>:
    TRAPHANDLER(th14, 14)
f010397c:	6a 0e                	push   $0xe
f010397e:	eb 0c                	jmp    f010398c <_alltraps>

f0103980 <th16>:
    TRAPHANDLER_NOEC(th16, 16)
f0103980:	6a 00                	push   $0x0
f0103982:	6a 10                	push   $0x10
f0103984:	eb 06                	jmp    f010398c <_alltraps>

f0103986 <th48>:
   	TRAPHANDLER_NOEC(th48, 48)
f0103986:	6a 00                	push   $0x0
f0103988:	6a 30                	push   $0x30
f010398a:	eb 00                	jmp    f010398c <_alltraps>

f010398c <_alltraps>:
 /*
 * Lab 3: Your code here for _alltraps
 */
/* why directly mov? */
_alltraps:
    pushl %ds
f010398c:	1e                   	push   %ds
    pushl %es
f010398d:	06                   	push   %es
    pushal
f010398e:	60                   	pusha  
    pushl $GD_KD
f010398f:	6a 10                	push   $0x10
    popl %ds
f0103991:	1f                   	pop    %ds
    pushl $GD_KD
f0103992:	6a 10                	push   $0x10
    popl %es
f0103994:	07                   	pop    %es
    pushl %esp
f0103995:	54                   	push   %esp
    call trap
f0103996:	e8 54 fd ff ff       	call   f01036ef <trap>
	...

f010399c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010399c:	55                   	push   %ebp
f010399d:	89 e5                	mov    %esp,%ebp
f010399f:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01039a2:	8b 15 50 02 22 f0    	mov    0xf0220250,%edx
f01039a8:	8b 42 54             	mov    0x54(%edx),%eax
f01039ab:	83 e8 02             	sub    $0x2,%eax
f01039ae:	83 f8 01             	cmp    $0x1,%eax
f01039b1:	76 45                	jbe    f01039f8 <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f01039b3:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01039b9:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01039be:	8b 0a                	mov    (%edx),%ecx
f01039c0:	83 e9 02             	sub    $0x2,%ecx
f01039c3:	83 f9 01             	cmp    $0x1,%ecx
f01039c6:	76 0f                	jbe    f01039d7 <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01039c8:	83 c0 01             	add    $0x1,%eax
f01039cb:	83 c2 7c             	add    $0x7c,%edx
f01039ce:	3d 00 04 00 00       	cmp    $0x400,%eax
f01039d3:	75 e9                	jne    f01039be <sched_halt+0x22>
f01039d5:	eb 07                	jmp    f01039de <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f01039d7:	3d 00 04 00 00       	cmp    $0x400,%eax
f01039dc:	75 1a                	jne    f01039f8 <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f01039de:	c7 04 24 90 69 10 f0 	movl   $0xf0106990,(%esp)
f01039e5:	e8 90 f7 ff ff       	call   f010317a <cprintf>
		while (1)
			monitor(NULL);
f01039ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039f1:	e8 c8 cf ff ff       	call   f01009be <monitor>
f01039f6:	eb f2                	jmp    f01039ea <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01039f8:	e8 8f 15 00 00       	call   f0104f8c <cpunum>
f01039fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a00:	c7 80 28 10 22 f0 00 	movl   $0x0,-0xfddefd8(%eax)
f0103a07:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103a0a:	a1 ec 0e 22 f0       	mov    0xf0220eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a14:	77 20                	ja     f0103a36 <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a1a:	c7 44 24 08 24 57 10 	movl   $0xf0105724,0x8(%esp)
f0103a21:	f0 
f0103a22:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
f0103a29:	00 
f0103a2a:	c7 04 24 b9 69 10 f0 	movl   $0xf01069b9,(%esp)
f0103a31:	e8 0a c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a36:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a3b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103a3e:	e8 49 15 00 00       	call   f0104f8c <cpunum>
f0103a43:	6b d0 74             	imul   $0x74,%eax,%edx
f0103a46:	81 c2 20 10 22 f0    	add    $0xf0221020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103a4c:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a51:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103a55:	c7 04 24 a0 e3 11 f0 	movl   $0xf011e3a0,(%esp)
f0103a5c:	e8 9f 18 00 00       	call   f0105300 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103a61:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103a63:	e8 24 15 00 00       	call   f0104f8c <cpunum>
f0103a68:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103a6b:	8b 80 30 10 22 f0    	mov    -0xfddefd0(%eax),%eax
f0103a71:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103a76:	89 c4                	mov    %eax,%esp
f0103a78:	6a 00                	push   $0x0
f0103a7a:	6a 00                	push   $0x0
f0103a7c:	fb                   	sti    
f0103a7d:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103a7e:	c9                   	leave  
f0103a7f:	c3                   	ret    

f0103a80 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103a80:	55                   	push   %ebp
f0103a81:	89 e5                	mov    %esp,%ebp
f0103a83:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0103a86:	e8 11 ff ff ff       	call   f010399c <sched_halt>
}
f0103a8b:	c9                   	leave  
f0103a8c:	c3                   	ret    
f0103a8d:	00 00                	add    %al,(%eax)
	...

f0103a90 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103a90:	55                   	push   %ebp
f0103a91:	89 e5                	mov    %esp,%ebp
f0103a93:	53                   	push   %ebx
f0103a94:	83 ec 24             	sub    $0x24,%esp
f0103a97:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	
  int ret = 0;
  switch (syscallno) {
f0103a9a:	83 f8 01             	cmp    $0x1,%eax
f0103a9d:	74 39                	je     f0103ad8 <syscall+0x48>
f0103a9f:	83 f8 01             	cmp    $0x1,%eax
f0103aa2:	72 10                	jb     f0103ab4 <syscall+0x24>
f0103aa4:	83 f8 02             	cmp    $0x2,%eax
f0103aa7:	74 3c                	je     f0103ae5 <syscall+0x55>
f0103aa9:	83 f8 03             	cmp    $0x3,%eax
f0103aac:	0f 85 d7 00 00 00    	jne    f0103b89 <syscall+0xf9>
f0103ab2:	eb 47                	jmp    f0103afb <syscall+0x6b>
	// Destroy the environment if not.

	// LAB 3: Your code here.
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103abb:	8b 45 10             	mov    0x10(%ebp),%eax
f0103abe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ac2:	c7 04 24 3b 5a 10 f0 	movl   $0xf0105a3b,(%esp)
f0103ac9:	e8 ac f6 ff ff       	call   f010317a <cprintf>
	
  int ret = 0;
  switch (syscallno) {
        case SYS_cputs: 
            sys_cputs((char*)a1, a2);
            ret = 0;
f0103ace:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ad3:	e9 b6 00 00 00       	jmp    f0103b8e <syscall+0xfe>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103ad8:	e8 55 cb ff ff       	call   f0100632 <cons_getc>
            sys_cputs((char*)a1, a2);
            ret = 0;
            break;
        case SYS_cgetc:
            ret = sys_cgetc();
            break;
f0103add:	8d 76 00             	lea    0x0(%esi),%esi
f0103ae0:	e9 a9 00 00 00       	jmp    f0103b8e <syscall+0xfe>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103ae5:	e8 a2 14 00 00       	call   f0104f8c <cpunum>
f0103aea:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aed:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103af3:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            ret = sys_cgetc();
            break;
        case SYS_getenvid:
            ret = sys_getenvid();
            break;
f0103af6:	e9 93 00 00 00       	jmp    f0103b8e <syscall+0xfe>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103afb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103b02:	00 
f0103b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b0d:	89 14 24             	mov    %edx,(%esp)
f0103b10:	e8 d0 ed ff ff       	call   f01028e5 <envid2env>
f0103b15:	85 c0                	test   %eax,%eax
f0103b17:	78 69                	js     f0103b82 <syscall+0xf2>
		return r;
	if (e == curenv)
f0103b19:	e8 6e 14 00 00       	call   f0104f8c <cpunum>
f0103b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b24:	39 90 28 10 22 f0    	cmp    %edx,-0xfddefd8(%eax)
f0103b2a:	75 23                	jne    f0103b4f <syscall+0xbf>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103b2c:	e8 5b 14 00 00       	call   f0104f8c <cpunum>
f0103b31:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b34:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103b3a:	8b 40 48             	mov    0x48(%eax),%eax
f0103b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b41:	c7 04 24 c6 69 10 f0 	movl   $0xf01069c6,(%esp)
f0103b48:	e8 2d f6 ff ff       	call   f010317a <cprintf>
f0103b4d:	eb 28                	jmp    f0103b77 <syscall+0xe7>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103b4f:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103b52:	e8 35 14 00 00       	call   f0104f8c <cpunum>
f0103b57:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b5e:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103b64:	8b 40 48             	mov    0x48(%eax),%eax
f0103b67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b6b:	c7 04 24 e1 69 10 f0 	movl   $0xf01069e1,(%esp)
f0103b72:	e8 03 f6 ff ff       	call   f010317a <cprintf>
	env_destroy(e);
f0103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b7a:	89 04 24             	mov    %eax,(%esp)
f0103b7d:	e8 7c f3 ff ff       	call   f0102efe <env_destroy>
        case SYS_getenvid:
            ret = sys_getenvid();
            break;
        case SYS_env_destroy:
            sys_env_destroy(a1);
            ret = 0;
f0103b82:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b87:	eb 05                	jmp    f0103b8e <syscall+0xfe>
            break;
        default:
            ret = -E_INVAL;
f0103b89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    }
    return ret;
    panic("syscall not implemented");
}
f0103b8e:	83 c4 24             	add    $0x24,%esp
f0103b91:	5b                   	pop    %ebx
f0103b92:	5d                   	pop    %ebp
f0103b93:	c3                   	ret    

f0103b94 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103b94:	55                   	push   %ebp
f0103b95:	89 e5                	mov    %esp,%ebp
f0103b97:	57                   	push   %edi
f0103b98:	56                   	push   %esi
f0103b99:	53                   	push   %ebx
f0103b9a:	83 ec 14             	sub    $0x14,%esp
f0103b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ba0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103ba3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ba6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ba9:	8b 1a                	mov    (%edx),%ebx
f0103bab:	8b 01                	mov    (%ecx),%eax
f0103bad:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103bb0:	39 c3                	cmp    %eax,%ebx
f0103bb2:	0f 8f 9f 00 00 00    	jg     f0103c57 <stab_binsearch+0xc3>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103bbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103bc2:	01 d8                	add    %ebx,%eax
f0103bc4:	89 c7                	mov    %eax,%edi
f0103bc6:	c1 ef 1f             	shr    $0x1f,%edi
f0103bc9:	01 c7                	add    %eax,%edi
f0103bcb:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103bcd:	39 df                	cmp    %ebx,%edi
f0103bcf:	0f 8c ce 00 00 00    	jl     f0103ca3 <stab_binsearch+0x10f>
f0103bd5:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103bdb:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103be0:	39 f0                	cmp    %esi,%eax
f0103be2:	0f 84 c0 00 00 00    	je     f0103ca8 <stab_binsearch+0x114>
f0103be8:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103bec:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103bf0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103bf2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103bf5:	39 d8                	cmp    %ebx,%eax
f0103bf7:	0f 8c a6 00 00 00    	jl     f0103ca3 <stab_binsearch+0x10f>
f0103bfd:	0f b6 0a             	movzbl (%edx),%ecx
f0103c00:	83 ea 0c             	sub    $0xc,%edx
f0103c03:	39 f1                	cmp    %esi,%ecx
f0103c05:	75 eb                	jne    f0103bf2 <stab_binsearch+0x5e>
f0103c07:	e9 9e 00 00 00       	jmp    f0103caa <stab_binsearch+0x116>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103c0c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c0f:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0103c11:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c14:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c1b:	eb 2b                	jmp    f0103c48 <stab_binsearch+0xb4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103c1d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c20:	76 14                	jbe    f0103c36 <stab_binsearch+0xa2>
			*region_right = m - 1;
f0103c22:	83 e8 01             	sub    $0x1,%eax
f0103c25:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c28:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c2b:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c2d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c34:	eb 12                	jmp    f0103c48 <stab_binsearch+0xb4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c36:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c39:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103c3b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103c3f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c41:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103c48:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f0103c4b:	0f 8e 6e ff ff ff    	jle    f0103bbf <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103c51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c55:	75 0f                	jne    f0103c66 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0103c57:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c5a:	8b 02                	mov    (%edx),%eax
f0103c5c:	83 e8 01             	sub    $0x1,%eax
f0103c5f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c62:	89 01                	mov    %eax,(%ecx)
f0103c64:	eb 5c                	jmp    f0103cc2 <stab_binsearch+0x12e>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c66:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c69:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103c6b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c6e:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c70:	39 c8                	cmp    %ecx,%eax
f0103c72:	7e 28                	jle    f0103c9c <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f0103c74:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103c77:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103c7a:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103c7f:	39 f2                	cmp    %esi,%edx
f0103c81:	74 19                	je     f0103c9c <stab_binsearch+0x108>
f0103c83:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c87:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103c8b:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c8e:	39 c8                	cmp    %ecx,%eax
f0103c90:	7e 0a                	jle    f0103c9c <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f0103c92:	0f b6 1a             	movzbl (%edx),%ebx
f0103c95:	83 ea 0c             	sub    $0xc,%edx
f0103c98:	39 f3                	cmp    %esi,%ebx
f0103c9a:	75 ef                	jne    f0103c8b <stab_binsearch+0xf7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103c9c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c9f:	89 02                	mov    %eax,(%edx)
f0103ca1:	eb 1f                	jmp    f0103cc2 <stab_binsearch+0x12e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103ca3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103ca6:	eb a0                	jmp    f0103c48 <stab_binsearch+0xb4>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ca8:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103caa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103cb0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103cb4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103cb7:	0f 82 4f ff ff ff    	jb     f0103c0c <stab_binsearch+0x78>
f0103cbd:	e9 5b ff ff ff       	jmp    f0103c1d <stab_binsearch+0x89>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103cc2:	83 c4 14             	add    $0x14,%esp
f0103cc5:	5b                   	pop    %ebx
f0103cc6:	5e                   	pop    %esi
f0103cc7:	5f                   	pop    %edi
f0103cc8:	5d                   	pop    %ebp
f0103cc9:	c3                   	ret    

f0103cca <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103cca:	55                   	push   %ebp
f0103ccb:	89 e5                	mov    %esp,%ebp
f0103ccd:	57                   	push   %edi
f0103cce:	56                   	push   %esi
f0103ccf:	53                   	push   %ebx
f0103cd0:	83 ec 5c             	sub    $0x5c,%esp
f0103cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103cd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103cd9:	c7 03 f9 69 10 f0    	movl   $0xf01069f9,(%ebx)
	info->eip_line = 0;
f0103cdf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103ce6:	c7 43 08 f9 69 10 f0 	movl   $0xf01069f9,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103ced:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103cf4:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103cf7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103cfe:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103d04:	0f 87 c3 00 00 00    	ja     f0103dcd <debuginfo_eip+0x103>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
    if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103d0a:	e8 7d 12 00 00       	call   f0104f8c <cpunum>
f0103d0f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103d16:	00 
f0103d17:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0103d1e:	00 
f0103d1f:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0103d26:	00 
f0103d27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2a:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103d30:	89 04 24             	mov    %eax,(%esp)
f0103d33:	e8 16 ea ff ff       	call   f010274e <user_mem_check>
f0103d38:	85 c0                	test   %eax,%eax
f0103d3a:	0f 85 79 02 00 00    	jne    f0103fb9 <debuginfo_eip+0x2ef>
	   	return -1;

		stabs = usd->stabs;
f0103d40:	a1 00 00 20 00       	mov    0x200000,%eax
f0103d45:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103d48:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0103d4e:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103d54:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0103d57:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0103d5d:	89 4d c0             	mov    %ecx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	  if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0103d60:	e8 27 12 00 00       	call   f0104f8c <cpunum>
f0103d65:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103d6c:	00 
f0103d6d:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0103d74:	00 
f0103d75:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103d78:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7f:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103d85:	89 04 24             	mov    %eax,(%esp)
f0103d88:	e8 c1 e9 ff ff       	call   f010274e <user_mem_check>
f0103d8d:	85 c0                	test   %eax,%eax
f0103d8f:	0f 85 2b 02 00 00    	jne    f0103fc0 <debuginfo_eip+0x2f6>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0103d95:	e8 f2 11 00 00       	call   f0104f8c <cpunum>
f0103d9a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103da1:	00 
f0103da2:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103da5:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0103da8:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103dac:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103daf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103db3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db6:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0103dbc:	89 04 24             	mov    %eax,(%esp)
f0103dbf:	e8 8a e9 ff ff       	call   f010274e <user_mem_check>
f0103dc4:	85 c0                	test   %eax,%eax
f0103dc6:	74 1f                	je     f0103de7 <debuginfo_eip+0x11d>
f0103dc8:	e9 fa 01 00 00       	jmp    f0103fc7 <debuginfo_eip+0x2fd>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103dcd:	c7 45 c0 ad 3d 11 f0 	movl   $0xf0113dad,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103dd4:	c7 45 bc 3d 06 11 f0 	movl   $0xf011063d,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103ddb:	be 3c 06 11 f0       	mov    $0xf011063c,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103de0:	c7 45 c4 d4 6e 10 f0 	movl   $0xf0106ed4,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
  }

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103de7:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103dea:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0103ded:	0f 83 db 01 00 00    	jae    f0103fce <debuginfo_eip+0x304>
f0103df3:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103df7:	0f 85 d8 01 00 00    	jne    f0103fd5 <debuginfo_eip+0x30b>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103dfd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103e04:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0103e07:	c1 fe 02             	sar    $0x2,%esi
f0103e0a:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0103e10:	83 e8 01             	sub    $0x1,%eax
f0103e13:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103e16:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e1a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103e21:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103e24:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103e27:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103e2a:	e8 65 fd ff ff       	call   f0103b94 <stab_binsearch>
	if (lfile == 0)
f0103e2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e32:	85 c0                	test   %eax,%eax
f0103e34:	0f 84 a2 01 00 00    	je     f0103fdc <debuginfo_eip+0x312>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103e3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e40:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103e43:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e47:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103e4e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e51:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e54:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103e57:	e8 38 fd ff ff       	call   f0103b94 <stab_binsearch>

	if (lfun <= rfun) {
f0103e5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103e5f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103e62:	39 f0                	cmp    %esi,%eax
f0103e64:	7f 32                	jg     f0103e98 <debuginfo_eip+0x1ce>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e66:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e69:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103e6c:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103e6f:	8b 0a                	mov    (%edx),%ecx
f0103e71:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0103e74:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103e77:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0103e7a:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0103e7d:	73 09                	jae    f0103e88 <debuginfo_eip+0x1be>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103e7f:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0103e82:	03 4d bc             	add    -0x44(%ebp),%ecx
f0103e85:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e88:	8b 52 08             	mov    0x8(%edx),%edx
f0103e8b:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103e8e:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0103e90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103e93:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103e96:	eb 0f                	jmp    f0103ea7 <debuginfo_eip+0x1dd>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103e98:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0103e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103ea1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ea4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103ea7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103eae:	00 
f0103eaf:	8b 43 08             	mov    0x8(%ebx),%eax
f0103eb2:	89 04 24             	mov    %eax,(%esp)
f0103eb5:	e8 01 0a 00 00       	call   f01048bb <strfind>
f0103eba:	2b 43 08             	sub    0x8(%ebx),%eax
f0103ebd:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch( stabs, &lline, &rline, N_SLINE, addr); 
f0103ec0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ec4:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103ecb:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103ece:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103ed1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103ed4:	e8 bb fc ff ff       	call   f0103b94 <stab_binsearch>
  if(lline <= rline)
f0103ed9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103edc:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103edf:	0f 8f fe 00 00 00    	jg     f0103fe3 <debuginfo_eip+0x319>
  {
		info->eip_line = stabs[lline].n_desc;
f0103ee5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103ee8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103eeb:	0f b7 44 82 06       	movzwl 0x6(%edx,%eax,4),%eax
f0103ef0:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ef3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ef6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ef9:	39 fa                	cmp    %edi,%edx
f0103efb:	7c 6b                	jl     f0103f68 <debuginfo_eip+0x29e>
	       && stabs[lline].n_type != N_SOL
f0103efd:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103f00:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103f03:	8d 34 81             	lea    (%ecx,%eax,4),%esi
f0103f06:	0f b6 46 04          	movzbl 0x4(%esi),%eax
f0103f0a:	88 45 b4             	mov    %al,-0x4c(%ebp)
f0103f0d:	3c 84                	cmp    $0x84,%al
f0103f0f:	74 3f                	je     f0103f50 <debuginfo_eip+0x286>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f11:	8d 4c 52 fd          	lea    -0x3(%edx,%edx,2),%ecx
f0103f15:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103f18:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0103f1b:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0103f1e:	0f b6 4d b4          	movzbl -0x4c(%ebp),%ecx
f0103f22:	eb 1a                	jmp    f0103f3e <debuginfo_eip+0x274>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103f24:	83 ea 01             	sub    $0x1,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f27:	39 fa                	cmp    %edi,%edx
f0103f29:	7c 3d                	jl     f0103f68 <debuginfo_eip+0x29e>
	       && stabs[lline].n_type != N_SOL
f0103f2b:	89 c6                	mov    %eax,%esi
f0103f2d:	83 e8 0c             	sub    $0xc,%eax
f0103f30:	0f b6 48 10          	movzbl 0x10(%eax),%ecx
f0103f34:	80 f9 84             	cmp    $0x84,%cl
f0103f37:	75 05                	jne    f0103f3e <debuginfo_eip+0x274>
f0103f39:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103f3c:	eb 12                	jmp    f0103f50 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103f3e:	80 f9 64             	cmp    $0x64,%cl
f0103f41:	75 e1                	jne    f0103f24 <debuginfo_eip+0x25a>
f0103f43:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0103f47:	74 db                	je     f0103f24 <debuginfo_eip+0x25a>
f0103f49:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f4c:	39 d7                	cmp    %edx,%edi
f0103f4e:	7f 18                	jg     f0103f68 <debuginfo_eip+0x29e>
f0103f50:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103f53:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103f56:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0103f59:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103f5c:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0103f5f:	39 d0                	cmp    %edx,%eax
f0103f61:	73 05                	jae    f0103f68 <debuginfo_eip+0x29e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f63:	03 45 bc             	add    -0x44(%ebp),%eax
f0103f66:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f68:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f6b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f6e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f73:	39 f2                	cmp    %esi,%edx
f0103f75:	0f 8d 82 00 00 00    	jge    f0103ffd <debuginfo_eip+0x333>
		for (lline = lfun + 1;
f0103f7b:	8d 42 01             	lea    0x1(%edx),%eax
f0103f7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103f81:	39 c6                	cmp    %eax,%esi
f0103f83:	7e 65                	jle    f0103fea <debuginfo_eip+0x320>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f85:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103f88:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103f8b:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f0103f90:	75 5f                	jne    f0103ff1 <debuginfo_eip+0x327>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f92:	8d 42 02             	lea    0x2(%edx),%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f95:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f98:	8d 54 91 1c          	lea    0x1c(%ecx,%edx,4),%edx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f9c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103fa0:	39 f0                	cmp    %esi,%eax
f0103fa2:	74 54                	je     f0103ff8 <debuginfo_eip+0x32e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103fa4:	0f b6 0a             	movzbl (%edx),%ecx
f0103fa7:	83 c0 01             	add    $0x1,%eax
f0103faa:	83 c2 0c             	add    $0xc,%edx
f0103fad:	80 f9 a0             	cmp    $0xa0,%cl
f0103fb0:	74 ea                	je     f0103f9c <debuginfo_eip+0x2d2>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103fb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fb7:	eb 44                	jmp    f0103ffd <debuginfo_eip+0x333>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
    if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
	   	return -1;
f0103fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fbe:	eb 3d                	jmp    f0103ffd <debuginfo_eip+0x333>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	  if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0103fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fc5:	eb 36                	jmp    f0103ffd <debuginfo_eip+0x333>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0103fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fcc:	eb 2f                	jmp    f0103ffd <debuginfo_eip+0x333>
  }

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fd3:	eb 28                	jmp    f0103ffd <debuginfo_eip+0x333>
f0103fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fda:	eb 21                	jmp    f0103ffd <debuginfo_eip+0x333>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103fdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fe1:	eb 1a                	jmp    f0103ffd <debuginfo_eip+0x333>
	// Your code here.
	stab_binsearch( stabs, &lline, &rline, N_SLINE, addr); 
  if(lline <= rline)
  {
		info->eip_line = stabs[lline].n_desc;
	}else return -1;
f0103fe3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fe8:	eb 13                	jmp    f0103ffd <debuginfo_eip+0x333>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103fea:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fef:	eb 0c                	jmp    f0103ffd <debuginfo_eip+0x333>
f0103ff1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ff6:	eb 05                	jmp    f0103ffd <debuginfo_eip+0x333>
f0103ff8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ffd:	83 c4 5c             	add    $0x5c,%esp
f0104000:	5b                   	pop    %ebx
f0104001:	5e                   	pop    %esi
f0104002:	5f                   	pop    %edi
f0104003:	5d                   	pop    %ebp
f0104004:	c3                   	ret    
	...

f0104010 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104010:	55                   	push   %ebp
f0104011:	89 e5                	mov    %esp,%ebp
f0104013:	57                   	push   %edi
f0104014:	56                   	push   %esi
f0104015:	53                   	push   %ebx
f0104016:	83 ec 4c             	sub    $0x4c,%esp
f0104019:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010401c:	89 d7                	mov    %edx,%edi
f010401e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104021:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104024:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104027:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010402a:	b8 00 00 00 00       	mov    $0x0,%eax
f010402f:	39 d8                	cmp    %ebx,%eax
f0104031:	72 17                	jb     f010404a <printnum+0x3a>
f0104033:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104036:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f0104039:	76 0f                	jbe    f010404a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010403b:	8b 75 14             	mov    0x14(%ebp),%esi
f010403e:	83 ee 01             	sub    $0x1,%esi
f0104041:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104044:	85 f6                	test   %esi,%esi
f0104046:	7f 63                	jg     f01040ab <printnum+0x9b>
f0104048:	eb 75                	jmp    f01040bf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010404a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010404d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0104051:	8b 45 14             	mov    0x14(%ebp),%eax
f0104054:	83 e8 01             	sub    $0x1,%eax
f0104057:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010405b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010405e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104062:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104066:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010406a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010406d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104070:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104077:	00 
f0104078:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f010407b:	89 1c 24             	mov    %ebx,(%esp)
f010407e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104081:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104085:	e8 96 13 00 00       	call   f0105420 <__udivdi3>
f010408a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010408d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104090:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104094:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104098:	89 04 24             	mov    %eax,(%esp)
f010409b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010409f:	89 fa                	mov    %edi,%edx
f01040a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040a4:	e8 67 ff ff ff       	call   f0104010 <printnum>
f01040a9:	eb 14                	jmp    f01040bf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01040ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01040af:	8b 45 18             	mov    0x18(%ebp),%eax
f01040b2:	89 04 24             	mov    %eax,(%esp)
f01040b5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01040b7:	83 ee 01             	sub    $0x1,%esi
f01040ba:	75 ef                	jne    f01040ab <printnum+0x9b>
f01040bc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01040bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01040c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01040c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01040ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01040ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01040d5:	00 
f01040d6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01040d9:	89 1c 24             	mov    %ebx,(%esp)
f01040dc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01040df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040e3:	e8 88 14 00 00       	call   f0105570 <__umoddi3>
f01040e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01040ec:	0f be 80 03 6a 10 f0 	movsbl -0xfef95fd(%eax),%eax
f01040f3:	89 04 24             	mov    %eax,(%esp)
f01040f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040f9:	ff d0                	call   *%eax
}
f01040fb:	83 c4 4c             	add    $0x4c,%esp
f01040fe:	5b                   	pop    %ebx
f01040ff:	5e                   	pop    %esi
f0104100:	5f                   	pop    %edi
f0104101:	5d                   	pop    %ebp
f0104102:	c3                   	ret    

f0104103 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104103:	55                   	push   %ebp
f0104104:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104106:	83 fa 01             	cmp    $0x1,%edx
f0104109:	7e 0e                	jle    f0104119 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010410b:	8b 10                	mov    (%eax),%edx
f010410d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104110:	89 08                	mov    %ecx,(%eax)
f0104112:	8b 02                	mov    (%edx),%eax
f0104114:	8b 52 04             	mov    0x4(%edx),%edx
f0104117:	eb 22                	jmp    f010413b <getuint+0x38>
	else if (lflag)
f0104119:	85 d2                	test   %edx,%edx
f010411b:	74 10                	je     f010412d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010411d:	8b 10                	mov    (%eax),%edx
f010411f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104122:	89 08                	mov    %ecx,(%eax)
f0104124:	8b 02                	mov    (%edx),%eax
f0104126:	ba 00 00 00 00       	mov    $0x0,%edx
f010412b:	eb 0e                	jmp    f010413b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010412d:	8b 10                	mov    (%eax),%edx
f010412f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104132:	89 08                	mov    %ecx,(%eax)
f0104134:	8b 02                	mov    (%edx),%eax
f0104136:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010413b:	5d                   	pop    %ebp
f010413c:	c3                   	ret    

f010413d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010413d:	55                   	push   %ebp
f010413e:	89 e5                	mov    %esp,%ebp
f0104140:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104143:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104147:	8b 10                	mov    (%eax),%edx
f0104149:	3b 50 04             	cmp    0x4(%eax),%edx
f010414c:	73 0a                	jae    f0104158 <sprintputch+0x1b>
		*b->buf++ = ch;
f010414e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104151:	88 0a                	mov    %cl,(%edx)
f0104153:	83 c2 01             	add    $0x1,%edx
f0104156:	89 10                	mov    %edx,(%eax)
}
f0104158:	5d                   	pop    %ebp
f0104159:	c3                   	ret    

f010415a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010415a:	55                   	push   %ebp
f010415b:	89 e5                	mov    %esp,%ebp
f010415d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104160:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104163:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104167:	8b 45 10             	mov    0x10(%ebp),%eax
f010416a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010416e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104171:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104175:	8b 45 08             	mov    0x8(%ebp),%eax
f0104178:	89 04 24             	mov    %eax,(%esp)
f010417b:	e8 02 00 00 00       	call   f0104182 <vprintfmt>
	va_end(ap);
}
f0104180:	c9                   	leave  
f0104181:	c3                   	ret    

f0104182 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104182:	55                   	push   %ebp
f0104183:	89 e5                	mov    %esp,%ebp
f0104185:	57                   	push   %edi
f0104186:	56                   	push   %esi
f0104187:	53                   	push   %ebx
f0104188:	83 ec 4c             	sub    $0x4c,%esp
f010418b:	8b 75 08             	mov    0x8(%ebp),%esi
f010418e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104191:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104194:	eb 11                	jmp    f01041a7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104196:	85 c0                	test   %eax,%eax
f0104198:	0f 84 db 03 00 00    	je     f0104579 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
f010419e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041a2:	89 04 24             	mov    %eax,(%esp)
f01041a5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041a7:	0f b6 07             	movzbl (%edi),%eax
f01041aa:	83 c7 01             	add    $0x1,%edi
f01041ad:	83 f8 25             	cmp    $0x25,%eax
f01041b0:	75 e4                	jne    f0104196 <vprintfmt+0x14>
f01041b2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
f01041b6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01041bd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01041c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01041cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01041d0:	eb 2b                	jmp    f01041fd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041d2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01041d5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
f01041d9:	eb 22                	jmp    f01041fd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041db:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01041de:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
f01041e2:	eb 19                	jmp    f01041fd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01041e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01041ee:	eb 0d                	jmp    f01041fd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01041f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01041f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041f6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041fd:	0f b6 0f             	movzbl (%edi),%ecx
f0104200:	8d 47 01             	lea    0x1(%edi),%eax
f0104203:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104206:	0f b6 07             	movzbl (%edi),%eax
f0104209:	83 e8 23             	sub    $0x23,%eax
f010420c:	3c 55                	cmp    $0x55,%al
f010420e:	0f 87 40 03 00 00    	ja     f0104554 <vprintfmt+0x3d2>
f0104214:	0f b6 c0             	movzbl %al,%eax
f0104217:	ff 24 85 c0 6a 10 f0 	jmp    *-0xfef9540(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010421e:	83 e9 30             	sub    $0x30,%ecx
f0104221:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
f0104224:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
f0104228:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010422b:	83 f9 09             	cmp    $0x9,%ecx
f010422e:	77 57                	ja     f0104287 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104230:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104233:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104236:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104239:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010423c:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010423f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104243:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0104246:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104249:	83 f9 09             	cmp    $0x9,%ecx
f010424c:	76 eb                	jbe    f0104239 <vprintfmt+0xb7>
f010424e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104251:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104254:	eb 34                	jmp    f010428a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104256:	8b 45 14             	mov    0x14(%ebp),%eax
f0104259:	8d 48 04             	lea    0x4(%eax),%ecx
f010425c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010425f:	8b 00                	mov    (%eax),%eax
f0104261:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104264:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104267:	eb 21                	jmp    f010428a <vprintfmt+0x108>

		case '.':
			if (width < 0)
f0104269:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010426d:	0f 88 71 ff ff ff    	js     f01041e4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104273:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104276:	eb 85                	jmp    f01041fd <vprintfmt+0x7b>
f0104278:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010427b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0104282:	e9 76 ff ff ff       	jmp    f01041fd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104287:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010428a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010428e:	0f 89 69 ff ff ff    	jns    f01041fd <vprintfmt+0x7b>
f0104294:	e9 57 ff ff ff       	jmp    f01041f0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104299:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010429c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010429f:	e9 59 ff ff ff       	jmp    f01041fd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01042a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01042a7:	8d 50 04             	lea    0x4(%eax),%edx
f01042aa:	89 55 14             	mov    %edx,0x14(%ebp)
f01042ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042b1:	8b 00                	mov    (%eax),%eax
f01042b3:	89 04 24             	mov    %eax,(%esp)
f01042b6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01042bb:	e9 e7 fe ff ff       	jmp    f01041a7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01042c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01042c3:	8d 50 04             	lea    0x4(%eax),%edx
f01042c6:	89 55 14             	mov    %edx,0x14(%ebp)
f01042c9:	8b 00                	mov    (%eax),%eax
f01042cb:	89 c2                	mov    %eax,%edx
f01042cd:	c1 fa 1f             	sar    $0x1f,%edx
f01042d0:	31 d0                	xor    %edx,%eax
f01042d2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01042d4:	83 f8 08             	cmp    $0x8,%eax
f01042d7:	7f 0b                	jg     f01042e4 <vprintfmt+0x162>
f01042d9:	8b 14 85 20 6c 10 f0 	mov    -0xfef93e0(,%eax,4),%edx
f01042e0:	85 d2                	test   %edx,%edx
f01042e2:	75 20                	jne    f0104304 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
f01042e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042e8:	c7 44 24 08 1b 6a 10 	movl   $0xf0106a1b,0x8(%esp)
f01042ef:	f0 
f01042f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042f4:	89 34 24             	mov    %esi,(%esp)
f01042f7:	e8 5e fe ff ff       	call   f010415a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01042ff:	e9 a3 fe ff ff       	jmp    f01041a7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104304:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104308:	c7 44 24 08 b3 62 10 	movl   $0xf01062b3,0x8(%esp)
f010430f:	f0 
f0104310:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104314:	89 34 24             	mov    %esi,(%esp)
f0104317:	e8 3e fe ff ff       	call   f010415a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010431c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010431f:	e9 83 fe ff ff       	jmp    f01041a7 <vprintfmt+0x25>
f0104324:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104327:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010432a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010432d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104330:	8d 50 04             	lea    0x4(%eax),%edx
f0104333:	89 55 14             	mov    %edx,0x14(%ebp)
f0104336:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104338:	85 ff                	test   %edi,%edi
f010433a:	b8 14 6a 10 f0       	mov    $0xf0106a14,%eax
f010433f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104342:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
f0104346:	74 06                	je     f010434e <vprintfmt+0x1cc>
f0104348:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010434c:	7f 16                	jg     f0104364 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010434e:	0f b6 17             	movzbl (%edi),%edx
f0104351:	0f be c2             	movsbl %dl,%eax
f0104354:	83 c7 01             	add    $0x1,%edi
f0104357:	85 c0                	test   %eax,%eax
f0104359:	0f 85 9f 00 00 00    	jne    f01043fe <vprintfmt+0x27c>
f010435f:	e9 8b 00 00 00       	jmp    f01043ef <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104364:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104368:	89 3c 24             	mov    %edi,(%esp)
f010436b:	e8 92 03 00 00       	call   f0104702 <strnlen>
f0104370:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104373:	29 c2                	sub    %eax,%edx
f0104375:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0104378:	85 d2                	test   %edx,%edx
f010437a:	7e d2                	jle    f010434e <vprintfmt+0x1cc>
					putch(padc, putdat);
f010437c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
f0104380:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104383:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0104386:	89 d7                	mov    %edx,%edi
f0104388:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010438c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010438f:	89 04 24             	mov    %eax,(%esp)
f0104392:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104394:	83 ef 01             	sub    $0x1,%edi
f0104397:	75 ef                	jne    f0104388 <vprintfmt+0x206>
f0104399:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010439c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010439f:	eb ad                	jmp    f010434e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01043a1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01043a5:	74 20                	je     f01043c7 <vprintfmt+0x245>
f01043a7:	0f be d2             	movsbl %dl,%edx
f01043aa:	83 ea 20             	sub    $0x20,%edx
f01043ad:	83 fa 5e             	cmp    $0x5e,%edx
f01043b0:	76 15                	jbe    f01043c7 <vprintfmt+0x245>
					putch('?', putdat);
f01043b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01043b5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043b9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01043c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01043c3:	ff d1                	call   *%ecx
f01043c5:	eb 0f                	jmp    f01043d6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
f01043c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01043ca:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043ce:	89 04 24             	mov    %eax,(%esp)
f01043d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01043d4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043d6:	83 eb 01             	sub    $0x1,%ebx
f01043d9:	0f b6 17             	movzbl (%edi),%edx
f01043dc:	0f be c2             	movsbl %dl,%eax
f01043df:	83 c7 01             	add    $0x1,%edi
f01043e2:	85 c0                	test   %eax,%eax
f01043e4:	75 24                	jne    f010440a <vprintfmt+0x288>
f01043e6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01043e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01043ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01043ef:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01043f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043f6:	0f 8e ab fd ff ff    	jle    f01041a7 <vprintfmt+0x25>
f01043fc:	eb 20                	jmp    f010441e <vprintfmt+0x29c>
f01043fe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0104401:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104404:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0104407:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010440a:	85 f6                	test   %esi,%esi
f010440c:	78 93                	js     f01043a1 <vprintfmt+0x21f>
f010440e:	83 ee 01             	sub    $0x1,%esi
f0104411:	79 8e                	jns    f01043a1 <vprintfmt+0x21f>
f0104413:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104416:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104419:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010441c:	eb d1                	jmp    f01043ef <vprintfmt+0x26d>
f010441e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104425:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010442c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010442e:	83 ef 01             	sub    $0x1,%edi
f0104431:	75 ee                	jne    f0104421 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104433:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104436:	e9 6c fd ff ff       	jmp    f01041a7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010443b:	83 fa 01             	cmp    $0x1,%edx
f010443e:	66 90                	xchg   %ax,%ax
f0104440:	7e 16                	jle    f0104458 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
f0104442:	8b 45 14             	mov    0x14(%ebp),%eax
f0104445:	8d 50 08             	lea    0x8(%eax),%edx
f0104448:	89 55 14             	mov    %edx,0x14(%ebp)
f010444b:	8b 10                	mov    (%eax),%edx
f010444d:	8b 48 04             	mov    0x4(%eax),%ecx
f0104450:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104453:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104456:	eb 32                	jmp    f010448a <vprintfmt+0x308>
	else if (lflag)
f0104458:	85 d2                	test   %edx,%edx
f010445a:	74 18                	je     f0104474 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
f010445c:	8b 45 14             	mov    0x14(%ebp),%eax
f010445f:	8d 50 04             	lea    0x4(%eax),%edx
f0104462:	89 55 14             	mov    %edx,0x14(%ebp)
f0104465:	8b 00                	mov    (%eax),%eax
f0104467:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010446a:	89 c1                	mov    %eax,%ecx
f010446c:	c1 f9 1f             	sar    $0x1f,%ecx
f010446f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104472:	eb 16                	jmp    f010448a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
f0104474:	8b 45 14             	mov    0x14(%ebp),%eax
f0104477:	8d 50 04             	lea    0x4(%eax),%edx
f010447a:	89 55 14             	mov    %edx,0x14(%ebp)
f010447d:	8b 00                	mov    (%eax),%eax
f010447f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104482:	89 c7                	mov    %eax,%edi
f0104484:	c1 ff 1f             	sar    $0x1f,%edi
f0104487:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010448a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010448d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104490:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104495:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104499:	79 7d                	jns    f0104518 <vprintfmt+0x396>
				putch('-', putdat);
f010449b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010449f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01044a6:	ff d6                	call   *%esi
				num = -(long long) num;
f01044a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01044ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01044ae:	f7 d8                	neg    %eax
f01044b0:	83 d2 00             	adc    $0x0,%edx
f01044b3:	f7 da                	neg    %edx
			}
			base = 10;
f01044b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01044ba:	eb 5c                	jmp    f0104518 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01044bc:	8d 45 14             	lea    0x14(%ebp),%eax
f01044bf:	e8 3f fc ff ff       	call   f0104103 <getuint>
			base = 10;
f01044c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01044c9:	eb 4d                	jmp    f0104518 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
f01044cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01044ce:	e8 30 fc ff ff       	call   f0104103 <getuint>
      base = 8;
f01044d3:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f01044d8:	eb 3e                	jmp    f0104518 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
f01044da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01044e5:	ff d6                	call   *%esi
			putch('x', putdat);
f01044e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044eb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01044f2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01044f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01044f7:	8d 50 04             	lea    0x4(%eax),%edx
f01044fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01044fd:	8b 00                	mov    (%eax),%eax
f01044ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104504:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104509:	eb 0d                	jmp    f0104518 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010450b:	8d 45 14             	lea    0x14(%ebp),%eax
f010450e:	e8 f0 fb ff ff       	call   f0104103 <getuint>
			base = 16;
f0104513:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104518:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
f010451c:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104520:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104523:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104527:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010452b:	89 04 24             	mov    %eax,(%esp)
f010452e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104532:	89 da                	mov    %ebx,%edx
f0104534:	89 f0                	mov    %esi,%eax
f0104536:	e8 d5 fa ff ff       	call   f0104010 <printnum>
			break;
f010453b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010453e:	e9 64 fc ff ff       	jmp    f01041a7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104543:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104547:	89 0c 24             	mov    %ecx,(%esp)
f010454a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010454c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010454f:	e9 53 fc ff ff       	jmp    f01041a7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104558:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010455f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104561:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104565:	0f 84 3c fc ff ff    	je     f01041a7 <vprintfmt+0x25>
f010456b:	83 ef 01             	sub    $0x1,%edi
f010456e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104572:	75 f7                	jne    f010456b <vprintfmt+0x3e9>
f0104574:	e9 2e fc ff ff       	jmp    f01041a7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104579:	83 c4 4c             	add    $0x4c,%esp
f010457c:	5b                   	pop    %ebx
f010457d:	5e                   	pop    %esi
f010457e:	5f                   	pop    %edi
f010457f:	5d                   	pop    %ebp
f0104580:	c3                   	ret    

f0104581 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104581:	55                   	push   %ebp
f0104582:	89 e5                	mov    %esp,%ebp
f0104584:	83 ec 28             	sub    $0x28,%esp
f0104587:	8b 45 08             	mov    0x8(%ebp),%eax
f010458a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010458d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104590:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104594:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010459e:	85 d2                	test   %edx,%edx
f01045a0:	7e 30                	jle    f01045d2 <vsnprintf+0x51>
f01045a2:	85 c0                	test   %eax,%eax
f01045a4:	74 2c                	je     f01045d2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01045a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01045a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045ad:	8b 45 10             	mov    0x10(%ebp),%eax
f01045b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01045b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045bb:	c7 04 24 3d 41 10 f0 	movl   $0xf010413d,(%esp)
f01045c2:	e8 bb fb ff ff       	call   f0104182 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01045c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045d0:	eb 05                	jmp    f01045d7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01045d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01045d7:	c9                   	leave  
f01045d8:	c3                   	ret    

f01045d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01045d9:	55                   	push   %ebp
f01045da:	89 e5                	mov    %esp,%ebp
f01045dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01045df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01045e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045e6:	8b 45 10             	mov    0x10(%ebp),%eax
f01045e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01045f7:	89 04 24             	mov    %eax,(%esp)
f01045fa:	e8 82 ff ff ff       	call   f0104581 <vsnprintf>
	va_end(ap);

	return rc;
}
f01045ff:	c9                   	leave  
f0104600:	c3                   	ret    
	...

f0104610 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
f0104613:	57                   	push   %edi
f0104614:	56                   	push   %esi
f0104615:	53                   	push   %ebx
f0104616:	83 ec 1c             	sub    $0x1c,%esp
f0104619:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010461c:	85 c0                	test   %eax,%eax
f010461e:	74 10                	je     f0104630 <readline+0x20>
		cprintf("%s", prompt);
f0104620:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104624:	c7 04 24 b3 62 10 f0 	movl   $0xf01062b3,(%esp)
f010462b:	e8 4a eb ff ff       	call   f010317a <cprintf>

	i = 0;
	echoing = iscons(0);
f0104630:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104637:	e8 67 c1 ff ff       	call   f01007a3 <iscons>
f010463c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010463e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104643:	e8 4a c1 ff ff       	call   f0100792 <getchar>
f0104648:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010464a:	85 c0                	test   %eax,%eax
f010464c:	79 17                	jns    f0104665 <readline+0x55>
			cprintf("read error: %e\n", c);
f010464e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104652:	c7 04 24 44 6c 10 f0 	movl   $0xf0106c44,(%esp)
f0104659:	e8 1c eb ff ff       	call   f010317a <cprintf>
			return NULL;
f010465e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104663:	eb 6d                	jmp    f01046d2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104665:	83 f8 7f             	cmp    $0x7f,%eax
f0104668:	74 05                	je     f010466f <readline+0x5f>
f010466a:	83 f8 08             	cmp    $0x8,%eax
f010466d:	75 19                	jne    f0104688 <readline+0x78>
f010466f:	85 f6                	test   %esi,%esi
f0104671:	7e 15                	jle    f0104688 <readline+0x78>
			if (echoing)
f0104673:	85 ff                	test   %edi,%edi
f0104675:	74 0c                	je     f0104683 <readline+0x73>
				cputchar('\b');
f0104677:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010467e:	e8 ff c0 ff ff       	call   f0100782 <cputchar>
			i--;
f0104683:	83 ee 01             	sub    $0x1,%esi
f0104686:	eb bb                	jmp    f0104643 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104688:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010468e:	7f 1c                	jg     f01046ac <readline+0x9c>
f0104690:	83 fb 1f             	cmp    $0x1f,%ebx
f0104693:	7e 17                	jle    f01046ac <readline+0x9c>
			if (echoing)
f0104695:	85 ff                	test   %edi,%edi
f0104697:	74 08                	je     f01046a1 <readline+0x91>
				cputchar(c);
f0104699:	89 1c 24             	mov    %ebx,(%esp)
f010469c:	e8 e1 c0 ff ff       	call   f0100782 <cputchar>
			buf[i++] = c;
f01046a1:	88 9e e0 0a 22 f0    	mov    %bl,-0xfddf520(%esi)
f01046a7:	83 c6 01             	add    $0x1,%esi
f01046aa:	eb 97                	jmp    f0104643 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01046ac:	83 fb 0d             	cmp    $0xd,%ebx
f01046af:	74 05                	je     f01046b6 <readline+0xa6>
f01046b1:	83 fb 0a             	cmp    $0xa,%ebx
f01046b4:	75 8d                	jne    f0104643 <readline+0x33>
			if (echoing)
f01046b6:	85 ff                	test   %edi,%edi
f01046b8:	74 0c                	je     f01046c6 <readline+0xb6>
				cputchar('\n');
f01046ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01046c1:	e8 bc c0 ff ff       	call   f0100782 <cputchar>
			buf[i] = 0;
f01046c6:	c6 86 e0 0a 22 f0 00 	movb   $0x0,-0xfddf520(%esi)
			return buf;
f01046cd:	b8 e0 0a 22 f0       	mov    $0xf0220ae0,%eax
		}
	}
}
f01046d2:	83 c4 1c             	add    $0x1c,%esp
f01046d5:	5b                   	pop    %ebx
f01046d6:	5e                   	pop    %esi
f01046d7:	5f                   	pop    %edi
f01046d8:	5d                   	pop    %ebp
f01046d9:	c3                   	ret    
f01046da:	00 00                	add    %al,(%eax)
f01046dc:	00 00                	add    %al,(%eax)
	...

f01046e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01046e0:	55                   	push   %ebp
f01046e1:	89 e5                	mov    %esp,%ebp
f01046e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01046e6:	80 3a 00             	cmpb   $0x0,(%edx)
f01046e9:	74 10                	je     f01046fb <strlen+0x1b>
f01046eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01046f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01046f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01046f7:	75 f7                	jne    f01046f0 <strlen+0x10>
f01046f9:	eb 05                	jmp    f0104700 <strlen+0x20>
f01046fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104700:	5d                   	pop    %ebp
f0104701:	c3                   	ret    

f0104702 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104702:	55                   	push   %ebp
f0104703:	89 e5                	mov    %esp,%ebp
f0104705:	53                   	push   %ebx
f0104706:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010470c:	85 c9                	test   %ecx,%ecx
f010470e:	74 1c                	je     f010472c <strnlen+0x2a>
f0104710:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104713:	74 1e                	je     f0104733 <strnlen+0x31>
f0104715:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f010471a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010471c:	39 ca                	cmp    %ecx,%edx
f010471e:	74 18                	je     f0104738 <strnlen+0x36>
f0104720:	83 c2 01             	add    $0x1,%edx
f0104723:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104728:	75 f0                	jne    f010471a <strnlen+0x18>
f010472a:	eb 0c                	jmp    f0104738 <strnlen+0x36>
f010472c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104731:	eb 05                	jmp    f0104738 <strnlen+0x36>
f0104733:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104738:	5b                   	pop    %ebx
f0104739:	5d                   	pop    %ebp
f010473a:	c3                   	ret    

f010473b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010473b:	55                   	push   %ebp
f010473c:	89 e5                	mov    %esp,%ebp
f010473e:	53                   	push   %ebx
f010473f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104745:	89 c2                	mov    %eax,%edx
f0104747:	0f b6 19             	movzbl (%ecx),%ebx
f010474a:	88 1a                	mov    %bl,(%edx)
f010474c:	83 c2 01             	add    $0x1,%edx
f010474f:	83 c1 01             	add    $0x1,%ecx
f0104752:	84 db                	test   %bl,%bl
f0104754:	75 f1                	jne    f0104747 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104756:	5b                   	pop    %ebx
f0104757:	5d                   	pop    %ebp
f0104758:	c3                   	ret    

f0104759 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104759:	55                   	push   %ebp
f010475a:	89 e5                	mov    %esp,%ebp
f010475c:	53                   	push   %ebx
f010475d:	83 ec 08             	sub    $0x8,%esp
f0104760:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104763:	89 1c 24             	mov    %ebx,(%esp)
f0104766:	e8 75 ff ff ff       	call   f01046e0 <strlen>
	strcpy(dst + len, src);
f010476b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010476e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104772:	01 d8                	add    %ebx,%eax
f0104774:	89 04 24             	mov    %eax,(%esp)
f0104777:	e8 bf ff ff ff       	call   f010473b <strcpy>
	return dst;
}
f010477c:	89 d8                	mov    %ebx,%eax
f010477e:	83 c4 08             	add    $0x8,%esp
f0104781:	5b                   	pop    %ebx
f0104782:	5d                   	pop    %ebp
f0104783:	c3                   	ret    

f0104784 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104784:	55                   	push   %ebp
f0104785:	89 e5                	mov    %esp,%ebp
f0104787:	56                   	push   %esi
f0104788:	53                   	push   %ebx
f0104789:	8b 75 08             	mov    0x8(%ebp),%esi
f010478c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010478f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104792:	85 db                	test   %ebx,%ebx
f0104794:	74 16                	je     f01047ac <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
f0104796:	01 f3                	add    %esi,%ebx
f0104798:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f010479a:	0f b6 02             	movzbl (%edx),%eax
f010479d:	88 01                	mov    %al,(%ecx)
f010479f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01047a2:	80 3a 01             	cmpb   $0x1,(%edx)
f01047a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01047a8:	39 d9                	cmp    %ebx,%ecx
f01047aa:	75 ee                	jne    f010479a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01047ac:	89 f0                	mov    %esi,%eax
f01047ae:	5b                   	pop    %ebx
f01047af:	5e                   	pop    %esi
f01047b0:	5d                   	pop    %ebp
f01047b1:	c3                   	ret    

f01047b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01047b2:	55                   	push   %ebp
f01047b3:	89 e5                	mov    %esp,%ebp
f01047b5:	57                   	push   %edi
f01047b6:	56                   	push   %esi
f01047b7:	53                   	push   %ebx
f01047b8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01047bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01047be:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01047c1:	89 f8                	mov    %edi,%eax
f01047c3:	85 f6                	test   %esi,%esi
f01047c5:	74 33                	je     f01047fa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
f01047c7:	83 fe 01             	cmp    $0x1,%esi
f01047ca:	74 25                	je     f01047f1 <strlcpy+0x3f>
f01047cc:	0f b6 0b             	movzbl (%ebx),%ecx
f01047cf:	84 c9                	test   %cl,%cl
f01047d1:	74 22                	je     f01047f5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01047d3:	83 ee 02             	sub    $0x2,%esi
f01047d6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01047db:	88 08                	mov    %cl,(%eax)
f01047dd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01047e0:	39 f2                	cmp    %esi,%edx
f01047e2:	74 13                	je     f01047f7 <strlcpy+0x45>
f01047e4:	83 c2 01             	add    $0x1,%edx
f01047e7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01047eb:	84 c9                	test   %cl,%cl
f01047ed:	75 ec                	jne    f01047db <strlcpy+0x29>
f01047ef:	eb 06                	jmp    f01047f7 <strlcpy+0x45>
f01047f1:	89 f8                	mov    %edi,%eax
f01047f3:	eb 02                	jmp    f01047f7 <strlcpy+0x45>
f01047f5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01047f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01047fa:	29 f8                	sub    %edi,%eax
}
f01047fc:	5b                   	pop    %ebx
f01047fd:	5e                   	pop    %esi
f01047fe:	5f                   	pop    %edi
f01047ff:	5d                   	pop    %ebp
f0104800:	c3                   	ret    

f0104801 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104801:	55                   	push   %ebp
f0104802:	89 e5                	mov    %esp,%ebp
f0104804:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104807:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010480a:	0f b6 01             	movzbl (%ecx),%eax
f010480d:	84 c0                	test   %al,%al
f010480f:	74 15                	je     f0104826 <strcmp+0x25>
f0104811:	3a 02                	cmp    (%edx),%al
f0104813:	75 11                	jne    f0104826 <strcmp+0x25>
		p++, q++;
f0104815:	83 c1 01             	add    $0x1,%ecx
f0104818:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010481b:	0f b6 01             	movzbl (%ecx),%eax
f010481e:	84 c0                	test   %al,%al
f0104820:	74 04                	je     f0104826 <strcmp+0x25>
f0104822:	3a 02                	cmp    (%edx),%al
f0104824:	74 ef                	je     f0104815 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104826:	0f b6 c0             	movzbl %al,%eax
f0104829:	0f b6 12             	movzbl (%edx),%edx
f010482c:	29 d0                	sub    %edx,%eax
}
f010482e:	5d                   	pop    %ebp
f010482f:	c3                   	ret    

f0104830 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104830:	55                   	push   %ebp
f0104831:	89 e5                	mov    %esp,%ebp
f0104833:	56                   	push   %esi
f0104834:	53                   	push   %ebx
f0104835:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104838:	8b 55 0c             	mov    0xc(%ebp),%edx
f010483b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f010483e:	85 f6                	test   %esi,%esi
f0104840:	74 29                	je     f010486b <strncmp+0x3b>
f0104842:	0f b6 03             	movzbl (%ebx),%eax
f0104845:	84 c0                	test   %al,%al
f0104847:	74 30                	je     f0104879 <strncmp+0x49>
f0104849:	3a 02                	cmp    (%edx),%al
f010484b:	75 2c                	jne    f0104879 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
f010484d:	8d 43 01             	lea    0x1(%ebx),%eax
f0104850:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0104852:	89 c3                	mov    %eax,%ebx
f0104854:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104857:	39 f0                	cmp    %esi,%eax
f0104859:	74 17                	je     f0104872 <strncmp+0x42>
f010485b:	0f b6 08             	movzbl (%eax),%ecx
f010485e:	84 c9                	test   %cl,%cl
f0104860:	74 17                	je     f0104879 <strncmp+0x49>
f0104862:	83 c0 01             	add    $0x1,%eax
f0104865:	3a 0a                	cmp    (%edx),%cl
f0104867:	74 e9                	je     f0104852 <strncmp+0x22>
f0104869:	eb 0e                	jmp    f0104879 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010486b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104870:	eb 0f                	jmp    f0104881 <strncmp+0x51>
f0104872:	b8 00 00 00 00       	mov    $0x0,%eax
f0104877:	eb 08                	jmp    f0104881 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104879:	0f b6 03             	movzbl (%ebx),%eax
f010487c:	0f b6 12             	movzbl (%edx),%edx
f010487f:	29 d0                	sub    %edx,%eax
}
f0104881:	5b                   	pop    %ebx
f0104882:	5e                   	pop    %esi
f0104883:	5d                   	pop    %ebp
f0104884:	c3                   	ret    

f0104885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104885:	55                   	push   %ebp
f0104886:	89 e5                	mov    %esp,%ebp
f0104888:	53                   	push   %ebx
f0104889:	8b 45 08             	mov    0x8(%ebp),%eax
f010488c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010488f:	0f b6 18             	movzbl (%eax),%ebx
f0104892:	84 db                	test   %bl,%bl
f0104894:	74 1d                	je     f01048b3 <strchr+0x2e>
f0104896:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f0104898:	38 d3                	cmp    %dl,%bl
f010489a:	75 06                	jne    f01048a2 <strchr+0x1d>
f010489c:	eb 1a                	jmp    f01048b8 <strchr+0x33>
f010489e:	38 ca                	cmp    %cl,%dl
f01048a0:	74 16                	je     f01048b8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01048a2:	83 c0 01             	add    $0x1,%eax
f01048a5:	0f b6 10             	movzbl (%eax),%edx
f01048a8:	84 d2                	test   %dl,%dl
f01048aa:	75 f2                	jne    f010489e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f01048ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01048b1:	eb 05                	jmp    f01048b8 <strchr+0x33>
f01048b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048b8:	5b                   	pop    %ebx
f01048b9:	5d                   	pop    %ebp
f01048ba:	c3                   	ret    

f01048bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048bb:	55                   	push   %ebp
f01048bc:	89 e5                	mov    %esp,%ebp
f01048be:	53                   	push   %ebx
f01048bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01048c5:	0f b6 18             	movzbl (%eax),%ebx
f01048c8:	84 db                	test   %bl,%bl
f01048ca:	74 16                	je     f01048e2 <strfind+0x27>
f01048cc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01048ce:	38 d3                	cmp    %dl,%bl
f01048d0:	75 06                	jne    f01048d8 <strfind+0x1d>
f01048d2:	eb 0e                	jmp    f01048e2 <strfind+0x27>
f01048d4:	38 ca                	cmp    %cl,%dl
f01048d6:	74 0a                	je     f01048e2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01048d8:	83 c0 01             	add    $0x1,%eax
f01048db:	0f b6 10             	movzbl (%eax),%edx
f01048de:	84 d2                	test   %dl,%dl
f01048e0:	75 f2                	jne    f01048d4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
f01048e2:	5b                   	pop    %ebx
f01048e3:	5d                   	pop    %ebp
f01048e4:	c3                   	ret    

f01048e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01048e5:	55                   	push   %ebp
f01048e6:	89 e5                	mov    %esp,%ebp
f01048e8:	83 ec 0c             	sub    $0xc,%esp
f01048eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01048ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01048f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01048f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01048f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01048fa:	85 c9                	test   %ecx,%ecx
f01048fc:	74 36                	je     f0104934 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01048fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104904:	75 28                	jne    f010492e <memset+0x49>
f0104906:	f6 c1 03             	test   $0x3,%cl
f0104909:	75 23                	jne    f010492e <memset+0x49>
		c &= 0xFF;
f010490b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010490f:	89 d3                	mov    %edx,%ebx
f0104911:	c1 e3 08             	shl    $0x8,%ebx
f0104914:	89 d6                	mov    %edx,%esi
f0104916:	c1 e6 18             	shl    $0x18,%esi
f0104919:	89 d0                	mov    %edx,%eax
f010491b:	c1 e0 10             	shl    $0x10,%eax
f010491e:	09 f0                	or     %esi,%eax
f0104920:	09 c2                	or     %eax,%edx
f0104922:	89 d0                	mov    %edx,%eax
f0104924:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104926:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104929:	fc                   	cld    
f010492a:	f3 ab                	rep stos %eax,%es:(%edi)
f010492c:	eb 06                	jmp    f0104934 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010492e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104931:	fc                   	cld    
f0104932:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104934:	89 f8                	mov    %edi,%eax
f0104936:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104939:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010493c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010493f:	89 ec                	mov    %ebp,%esp
f0104941:	5d                   	pop    %ebp
f0104942:	c3                   	ret    

f0104943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104943:	55                   	push   %ebp
f0104944:	89 e5                	mov    %esp,%ebp
f0104946:	83 ec 08             	sub    $0x8,%esp
f0104949:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010494c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010494f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104952:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104958:	39 c6                	cmp    %eax,%esi
f010495a:	73 36                	jae    f0104992 <memmove+0x4f>
f010495c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010495f:	39 d0                	cmp    %edx,%eax
f0104961:	73 2f                	jae    f0104992 <memmove+0x4f>
		s += n;
		d += n;
f0104963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104966:	f6 c2 03             	test   $0x3,%dl
f0104969:	75 1b                	jne    f0104986 <memmove+0x43>
f010496b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104971:	75 13                	jne    f0104986 <memmove+0x43>
f0104973:	f6 c1 03             	test   $0x3,%cl
f0104976:	75 0e                	jne    f0104986 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104978:	83 ef 04             	sub    $0x4,%edi
f010497b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010497e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104981:	fd                   	std    
f0104982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104984:	eb 09                	jmp    f010498f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104986:	83 ef 01             	sub    $0x1,%edi
f0104989:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010498c:	fd                   	std    
f010498d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010498f:	fc                   	cld    
f0104990:	eb 20                	jmp    f01049b2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104992:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104998:	75 13                	jne    f01049ad <memmove+0x6a>
f010499a:	a8 03                	test   $0x3,%al
f010499c:	75 0f                	jne    f01049ad <memmove+0x6a>
f010499e:	f6 c1 03             	test   $0x3,%cl
f01049a1:	75 0a                	jne    f01049ad <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01049a3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01049a6:	89 c7                	mov    %eax,%edi
f01049a8:	fc                   	cld    
f01049a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01049ab:	eb 05                	jmp    f01049b2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01049ad:	89 c7                	mov    %eax,%edi
f01049af:	fc                   	cld    
f01049b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01049b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01049b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01049b8:	89 ec                	mov    %ebp,%esp
f01049ba:	5d                   	pop    %ebp
f01049bb:	c3                   	ret    

f01049bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01049bc:	55                   	push   %ebp
f01049bd:	89 e5                	mov    %esp,%ebp
f01049bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01049c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01049c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01049d3:	89 04 24             	mov    %eax,(%esp)
f01049d6:	e8 68 ff ff ff       	call   f0104943 <memmove>
}
f01049db:	c9                   	leave  
f01049dc:	c3                   	ret    

f01049dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01049dd:	55                   	push   %ebp
f01049de:	89 e5                	mov    %esp,%ebp
f01049e0:	57                   	push   %edi
f01049e1:	56                   	push   %esi
f01049e2:	53                   	push   %ebx
f01049e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01049e6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01049e9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01049ec:	8d 78 ff             	lea    -0x1(%eax),%edi
f01049ef:	85 c0                	test   %eax,%eax
f01049f1:	74 36                	je     f0104a29 <memcmp+0x4c>
		if (*s1 != *s2)
f01049f3:	0f b6 03             	movzbl (%ebx),%eax
f01049f6:	0f b6 0e             	movzbl (%esi),%ecx
f01049f9:	38 c8                	cmp    %cl,%al
f01049fb:	75 17                	jne    f0104a14 <memcmp+0x37>
f01049fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a02:	eb 1a                	jmp    f0104a1e <memcmp+0x41>
f0104a04:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104a09:	83 c2 01             	add    $0x1,%edx
f0104a0c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104a10:	38 c8                	cmp    %cl,%al
f0104a12:	74 0a                	je     f0104a1e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0104a14:	0f b6 c0             	movzbl %al,%eax
f0104a17:	0f b6 c9             	movzbl %cl,%ecx
f0104a1a:	29 c8                	sub    %ecx,%eax
f0104a1c:	eb 10                	jmp    f0104a2e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104a1e:	39 fa                	cmp    %edi,%edx
f0104a20:	75 e2                	jne    f0104a04 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104a22:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a27:	eb 05                	jmp    f0104a2e <memcmp+0x51>
f0104a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104a2e:	5b                   	pop    %ebx
f0104a2f:	5e                   	pop    %esi
f0104a30:	5f                   	pop    %edi
f0104a31:	5d                   	pop    %ebp
f0104a32:	c3                   	ret    

f0104a33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104a33:	55                   	push   %ebp
f0104a34:	89 e5                	mov    %esp,%ebp
f0104a36:	53                   	push   %ebx
f0104a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f0104a3d:	89 c2                	mov    %eax,%edx
f0104a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104a42:	39 d0                	cmp    %edx,%eax
f0104a44:	73 13                	jae    f0104a59 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104a46:	89 d9                	mov    %ebx,%ecx
f0104a48:	38 18                	cmp    %bl,(%eax)
f0104a4a:	75 06                	jne    f0104a52 <memfind+0x1f>
f0104a4c:	eb 0b                	jmp    f0104a59 <memfind+0x26>
f0104a4e:	38 08                	cmp    %cl,(%eax)
f0104a50:	74 07                	je     f0104a59 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104a52:	83 c0 01             	add    $0x1,%eax
f0104a55:	39 d0                	cmp    %edx,%eax
f0104a57:	75 f5                	jne    f0104a4e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104a59:	5b                   	pop    %ebx
f0104a5a:	5d                   	pop    %ebp
f0104a5b:	c3                   	ret    

f0104a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104a5c:	55                   	push   %ebp
f0104a5d:	89 e5                	mov    %esp,%ebp
f0104a5f:	57                   	push   %edi
f0104a60:	56                   	push   %esi
f0104a61:	53                   	push   %ebx
f0104a62:	83 ec 04             	sub    $0x4,%esp
f0104a65:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a6b:	0f b6 02             	movzbl (%edx),%eax
f0104a6e:	3c 09                	cmp    $0x9,%al
f0104a70:	74 04                	je     f0104a76 <strtol+0x1a>
f0104a72:	3c 20                	cmp    $0x20,%al
f0104a74:	75 0e                	jne    f0104a84 <strtol+0x28>
		s++;
f0104a76:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a79:	0f b6 02             	movzbl (%edx),%eax
f0104a7c:	3c 09                	cmp    $0x9,%al
f0104a7e:	74 f6                	je     f0104a76 <strtol+0x1a>
f0104a80:	3c 20                	cmp    $0x20,%al
f0104a82:	74 f2                	je     f0104a76 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104a84:	3c 2b                	cmp    $0x2b,%al
f0104a86:	75 0a                	jne    f0104a92 <strtol+0x36>
		s++;
f0104a88:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104a8b:	bf 00 00 00 00       	mov    $0x0,%edi
f0104a90:	eb 10                	jmp    f0104aa2 <strtol+0x46>
f0104a92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104a97:	3c 2d                	cmp    $0x2d,%al
f0104a99:	75 07                	jne    f0104aa2 <strtol+0x46>
		s++, neg = 1;
f0104a9b:	83 c2 01             	add    $0x1,%edx
f0104a9e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104aa2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104aa8:	75 15                	jne    f0104abf <strtol+0x63>
f0104aaa:	80 3a 30             	cmpb   $0x30,(%edx)
f0104aad:	75 10                	jne    f0104abf <strtol+0x63>
f0104aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104ab3:	75 0a                	jne    f0104abf <strtol+0x63>
		s += 2, base = 16;
f0104ab5:	83 c2 02             	add    $0x2,%edx
f0104ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104abd:	eb 10                	jmp    f0104acf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f0104abf:	85 db                	test   %ebx,%ebx
f0104ac1:	75 0c                	jne    f0104acf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104ac3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104ac5:	80 3a 30             	cmpb   $0x30,(%edx)
f0104ac8:	75 05                	jne    f0104acf <strtol+0x73>
		s++, base = 8;
f0104aca:	83 c2 01             	add    $0x1,%edx
f0104acd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104acf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ad4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104ad7:	0f b6 0a             	movzbl (%edx),%ecx
f0104ada:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0104add:	89 f3                	mov    %esi,%ebx
f0104adf:	80 fb 09             	cmp    $0x9,%bl
f0104ae2:	77 08                	ja     f0104aec <strtol+0x90>
			dig = *s - '0';
f0104ae4:	0f be c9             	movsbl %cl,%ecx
f0104ae7:	83 e9 30             	sub    $0x30,%ecx
f0104aea:	eb 22                	jmp    f0104b0e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f0104aec:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0104aef:	89 f3                	mov    %esi,%ebx
f0104af1:	80 fb 19             	cmp    $0x19,%bl
f0104af4:	77 08                	ja     f0104afe <strtol+0xa2>
			dig = *s - 'a' + 10;
f0104af6:	0f be c9             	movsbl %cl,%ecx
f0104af9:	83 e9 57             	sub    $0x57,%ecx
f0104afc:	eb 10                	jmp    f0104b0e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f0104afe:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104b01:	89 f3                	mov    %esi,%ebx
f0104b03:	80 fb 19             	cmp    $0x19,%bl
f0104b06:	77 16                	ja     f0104b1e <strtol+0xc2>
			dig = *s - 'A' + 10;
f0104b08:	0f be c9             	movsbl %cl,%ecx
f0104b0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104b0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104b11:	7d 0f                	jge    f0104b22 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0104b13:	83 c2 01             	add    $0x1,%edx
f0104b16:	0f af 45 f0          	imul   -0x10(%ebp),%eax
f0104b1a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104b1c:	eb b9                	jmp    f0104ad7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104b1e:	89 c1                	mov    %eax,%ecx
f0104b20:	eb 02                	jmp    f0104b24 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104b22:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104b24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104b28:	74 05                	je     f0104b2f <strtol+0xd3>
		*endptr = (char *) s;
f0104b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b2d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104b2f:	89 ca                	mov    %ecx,%edx
f0104b31:	f7 da                	neg    %edx
f0104b33:	85 ff                	test   %edi,%edi
f0104b35:	0f 45 c2             	cmovne %edx,%eax
}
f0104b38:	83 c4 04             	add    $0x4,%esp
f0104b3b:	5b                   	pop    %ebx
f0104b3c:	5e                   	pop    %esi
f0104b3d:	5f                   	pop    %edi
f0104b3e:	5d                   	pop    %ebp
f0104b3f:	c3                   	ret    

f0104b40 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104b40:	fa                   	cli    

	xorw    %ax, %ax
f0104b41:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104b43:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104b45:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104b47:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104b49:	0f 01 16             	lgdtl  (%esi)
f0104b4c:	74 70                	je     f0104bbe <mpentry_end+0x4>
	movl    %cr0, %eax
f0104b4e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104b51:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104b55:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104b58:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104b5e:	08 00                	or     %al,(%eax)

f0104b60 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104b60:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104b64:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104b66:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104b68:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104b6a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104b6e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104b70:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104b72:	b8 00 c0 11 00       	mov    $0x11c000,%eax
	movl    %eax, %cr3
f0104b77:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104b7a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104b7d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104b82:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104b85:	8b 25 e4 0e 22 f0    	mov    0xf0220ee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104b8b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104b90:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0104b95:	ff d0                	call   *%eax

f0104b97 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104b97:	eb fe                	jmp    f0104b97 <spin>
f0104b99:	8d 76 00             	lea    0x0(%esi),%esi

f0104b9c <gdt>:
	...
f0104ba4:	ff                   	(bad)  
f0104ba5:	ff 00                	incl   (%eax)
f0104ba7:	00 00                	add    %al,(%eax)
f0104ba9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104bb0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0104bb4 <gdtdesc>:
f0104bb4:	17                   	pop    %ss
f0104bb5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104bba <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104bba:	90                   	nop
f0104bbb:	00 00                	add    %al,(%eax)
f0104bbd:	00 00                	add    %al,(%eax)
	...

f0104bc0 <sum>:
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104bc0:	85 d2                	test   %edx,%edx
f0104bc2:	7e 1c                	jle    f0104be0 <sum+0x20>
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0104bc4:	55                   	push   %ebp
f0104bc5:	89 e5                	mov    %esp,%ebp
f0104bc7:	53                   	push   %ebx
f0104bc8:	89 c1                	mov    %eax,%ecx
#define MPIOAPIC  0x02  // One per I/O APIC
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
f0104bca:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
{
	int i, sum;

	sum = 0;
f0104bcd:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0104bd2:	0f b6 11             	movzbl (%ecx),%edx
f0104bd5:	01 d0                	add    %edx,%eax
f0104bd7:	83 c1 01             	add    $0x1,%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104bda:	39 d9                	cmp    %ebx,%ecx
f0104bdc:	75 f4                	jne    f0104bd2 <sum+0x12>
f0104bde:	eb 06                	jmp    f0104be6 <sum+0x26>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0104be0:	b8 00 00 00 00       	mov    $0x0,%eax
f0104be5:	c3                   	ret    
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0104be6:	5b                   	pop    %ebx
f0104be7:	5d                   	pop    %ebp
f0104be8:	c3                   	ret    

f0104be9 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104be9:	55                   	push   %ebp
f0104bea:	89 e5                	mov    %esp,%ebp
f0104bec:	56                   	push   %esi
f0104bed:	53                   	push   %ebx
f0104bee:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104bf1:	8b 0d e8 0e 22 f0    	mov    0xf0220ee8,%ecx
f0104bf7:	89 c3                	mov    %eax,%ebx
f0104bf9:	c1 eb 0c             	shr    $0xc,%ebx
f0104bfc:	39 cb                	cmp    %ecx,%ebx
f0104bfe:	72 20                	jb     f0104c20 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104c00:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c04:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0104c0b:	f0 
f0104c0c:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104c13:	00 
f0104c14:	c7 04 24 e1 6d 10 f0 	movl   $0xf0106de1,(%esp)
f0104c1b:	e8 20 b4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104c20:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104c26:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104c29:	89 f0                	mov    %esi,%eax
f0104c2b:	c1 e8 0c             	shr    $0xc,%eax
f0104c2e:	39 c1                	cmp    %eax,%ecx
f0104c30:	77 20                	ja     f0104c52 <mpsearch1+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104c32:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c36:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0104c3d:	f0 
f0104c3e:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104c45:	00 
f0104c46:	c7 04 24 e1 6d 10 f0 	movl   $0xf0106de1,(%esp)
f0104c4d:	e8 ee b3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104c52:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0104c58:	39 f3                	cmp    %esi,%ebx
f0104c5a:	73 3a                	jae    f0104c96 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104c5c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104c63:	00 
f0104c64:	c7 44 24 04 f1 6d 10 	movl   $0xf0106df1,0x4(%esp)
f0104c6b:	f0 
f0104c6c:	89 1c 24             	mov    %ebx,(%esp)
f0104c6f:	e8 69 fd ff ff       	call   f01049dd <memcmp>
f0104c74:	85 c0                	test   %eax,%eax
f0104c76:	75 10                	jne    f0104c88 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0104c78:	ba 10 00 00 00       	mov    $0x10,%edx
f0104c7d:	89 d8                	mov    %ebx,%eax
f0104c7f:	e8 3c ff ff ff       	call   f0104bc0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104c84:	84 c0                	test   %al,%al
f0104c86:	74 13                	je     f0104c9b <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0104c88:	83 c3 10             	add    $0x10,%ebx
f0104c8b:	39 f3                	cmp    %esi,%ebx
f0104c8d:	72 cd                	jb     f0104c5c <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c94:	eb 05                	jmp    f0104c9b <mpsearch1+0xb2>
f0104c96:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104c9b:	89 d8                	mov    %ebx,%eax
f0104c9d:	83 c4 10             	add    $0x10,%esp
f0104ca0:	5b                   	pop    %ebx
f0104ca1:	5e                   	pop    %esi
f0104ca2:	5d                   	pop    %ebp
f0104ca3:	c3                   	ret    

f0104ca4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104ca4:	55                   	push   %ebp
f0104ca5:	89 e5                	mov    %esp,%ebp
f0104ca7:	57                   	push   %edi
f0104ca8:	56                   	push   %esi
f0104ca9:	53                   	push   %ebx
f0104caa:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104cad:	c7 05 c0 13 22 f0 20 	movl   $0xf0221020,0xf02213c0
f0104cb4:	10 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104cb7:	83 3d e8 0e 22 f0 00 	cmpl   $0x0,0xf0220ee8
f0104cbe:	75 24                	jne    f0104ce4 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104cc0:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0104cc7:	00 
f0104cc8:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0104ccf:	f0 
f0104cd0:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0104cd7:	00 
f0104cd8:	c7 04 24 e1 6d 10 f0 	movl   $0xf0106de1,(%esp)
f0104cdf:	e8 5c b3 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104ce4:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104ceb:	85 c0                	test   %eax,%eax
f0104ced:	74 16                	je     f0104d05 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0104cef:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104cf2:	ba 00 04 00 00       	mov    $0x400,%edx
f0104cf7:	e8 ed fe ff ff       	call   f0104be9 <mpsearch1>
f0104cfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cff:	85 c0                	test   %eax,%eax
f0104d01:	75 3c                	jne    f0104d3f <mp_init+0x9b>
f0104d03:	eb 20                	jmp    f0104d25 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0104d05:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104d0c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104d0f:	2d 00 04 00 00       	sub    $0x400,%eax
f0104d14:	ba 00 04 00 00       	mov    $0x400,%edx
f0104d19:	e8 cb fe ff ff       	call   f0104be9 <mpsearch1>
f0104d1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d21:	85 c0                	test   %eax,%eax
f0104d23:	75 1a                	jne    f0104d3f <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0104d25:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104d2a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104d2f:	e8 b5 fe ff ff       	call   f0104be9 <mpsearch1>
f0104d34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0104d37:	85 c0                	test   %eax,%eax
f0104d39:	0f 84 2a 02 00 00    	je     f0104f69 <mp_init+0x2c5>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0104d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d42:	8b 78 04             	mov    0x4(%eax),%edi
f0104d45:	85 ff                	test   %edi,%edi
f0104d47:	74 06                	je     f0104d4f <mp_init+0xab>
f0104d49:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104d4d:	74 11                	je     f0104d60 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0104d4f:	c7 04 24 54 6c 10 f0 	movl   $0xf0106c54,(%esp)
f0104d56:	e8 1f e4 ff ff       	call   f010317a <cprintf>
f0104d5b:	e9 09 02 00 00       	jmp    f0104f69 <mp_init+0x2c5>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104d60:	89 f8                	mov    %edi,%eax
f0104d62:	c1 e8 0c             	shr    $0xc,%eax
f0104d65:	3b 05 e8 0e 22 f0    	cmp    0xf0220ee8,%eax
f0104d6b:	72 20                	jb     f0104d8d <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104d6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104d71:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0104d78:	f0 
f0104d79:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0104d80:	00 
f0104d81:	c7 04 24 e1 6d 10 f0 	movl   $0xf0106de1,(%esp)
f0104d88:	e8 b3 b2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104d8d:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104d93:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104d9a:	00 
f0104d9b:	c7 44 24 04 f6 6d 10 	movl   $0xf0106df6,0x4(%esp)
f0104da2:	f0 
f0104da3:	89 3c 24             	mov    %edi,(%esp)
f0104da6:	e8 32 fc ff ff       	call   f01049dd <memcmp>
f0104dab:	85 c0                	test   %eax,%eax
f0104dad:	74 11                	je     f0104dc0 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104daf:	c7 04 24 84 6c 10 f0 	movl   $0xf0106c84,(%esp)
f0104db6:	e8 bf e3 ff ff       	call   f010317a <cprintf>
f0104dbb:	e9 a9 01 00 00       	jmp    f0104f69 <mp_init+0x2c5>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0104dc0:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0104dc4:	0f b7 d3             	movzwl %bx,%edx
f0104dc7:	89 f8                	mov    %edi,%eax
f0104dc9:	e8 f2 fd ff ff       	call   f0104bc0 <sum>
f0104dce:	84 c0                	test   %al,%al
f0104dd0:	74 11                	je     f0104de3 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104dd2:	c7 04 24 b8 6c 10 f0 	movl   $0xf0106cb8,(%esp)
f0104dd9:	e8 9c e3 ff ff       	call   f010317a <cprintf>
f0104dde:	e9 86 01 00 00       	jmp    f0104f69 <mp_init+0x2c5>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0104de3:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0104de7:	3c 04                	cmp    $0x4,%al
f0104de9:	74 1f                	je     f0104e0a <mp_init+0x166>
f0104deb:	3c 01                	cmp    $0x1,%al
f0104ded:	8d 76 00             	lea    0x0(%esi),%esi
f0104df0:	74 18                	je     f0104e0a <mp_init+0x166>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104df2:	0f b6 c0             	movzbl %al,%eax
f0104df5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104df9:	c7 04 24 dc 6c 10 f0 	movl   $0xf0106cdc,(%esp)
f0104e00:	e8 75 e3 ff ff       	call   f010317a <cprintf>
f0104e05:	e9 5f 01 00 00       	jmp    f0104f69 <mp_init+0x2c5>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0104e0a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0104e0e:	0f b7 db             	movzwl %bx,%ebx
f0104e11:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0104e14:	e8 a7 fd ff ff       	call   f0104bc0 <sum>
f0104e19:	3a 47 2a             	cmp    0x2a(%edi),%al
f0104e1c:	74 11                	je     f0104e2f <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104e1e:	c7 04 24 fc 6c 10 f0 	movl   $0xf0106cfc,(%esp)
f0104e25:	e8 50 e3 ff ff       	call   f010317a <cprintf>
f0104e2a:	e9 3a 01 00 00       	jmp    f0104f69 <mp_init+0x2c5>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0104e2f:	85 ff                	test   %edi,%edi
f0104e31:	0f 84 32 01 00 00    	je     f0104f69 <mp_init+0x2c5>
		return;
	ismp = 1;
f0104e37:	c7 05 00 10 22 f0 01 	movl   $0x1,0xf0221000
f0104e3e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0104e41:	8b 47 24             	mov    0x24(%edi),%eax
f0104e44:	a3 00 20 26 f0       	mov    %eax,0xf0262000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104e49:	8d 77 2c             	lea    0x2c(%edi),%esi
f0104e4c:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0104e51:	0f 84 97 00 00 00    	je     f0104eee <mp_init+0x24a>
f0104e57:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0104e5c:	0f b6 06             	movzbl (%esi),%eax
f0104e5f:	84 c0                	test   %al,%al
f0104e61:	74 06                	je     f0104e69 <mp_init+0x1c5>
f0104e63:	3c 04                	cmp    $0x4,%al
f0104e65:	77 57                	ja     f0104ebe <mp_init+0x21a>
f0104e67:	eb 50                	jmp    f0104eb9 <mp_init+0x215>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104e69:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0104e6d:	8d 76 00             	lea    0x0(%esi),%esi
f0104e70:	74 11                	je     f0104e83 <mp_init+0x1df>
				bootcpu = &cpus[ncpu];
f0104e72:	6b 05 c4 13 22 f0 74 	imul   $0x74,0xf02213c4,%eax
f0104e79:	05 20 10 22 f0       	add    $0xf0221020,%eax
f0104e7e:	a3 c0 13 22 f0       	mov    %eax,0xf02213c0
			if (ncpu < NCPU) {
f0104e83:	a1 c4 13 22 f0       	mov    0xf02213c4,%eax
f0104e88:	83 f8 07             	cmp    $0x7,%eax
f0104e8b:	7f 13                	jg     f0104ea0 <mp_init+0x1fc>
				cpus[ncpu].cpu_id = ncpu;
f0104e8d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104e90:	88 82 20 10 22 f0    	mov    %al,-0xfddefe0(%edx)
				ncpu++;
f0104e96:	83 c0 01             	add    $0x1,%eax
f0104e99:	a3 c4 13 22 f0       	mov    %eax,0xf02213c4
f0104e9e:	eb 14                	jmp    f0104eb4 <mp_init+0x210>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104ea0:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0104ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ea8:	c7 04 24 2c 6d 10 f0 	movl   $0xf0106d2c,(%esp)
f0104eaf:	e8 c6 e2 ff ff       	call   f010317a <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104eb4:	83 c6 14             	add    $0x14,%esi
			continue;
f0104eb7:	eb 26                	jmp    f0104edf <mp_init+0x23b>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104eb9:	83 c6 08             	add    $0x8,%esi
			continue;
f0104ebc:	eb 21                	jmp    f0104edf <mp_init+0x23b>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0104ebe:	0f b6 c0             	movzbl %al,%eax
f0104ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ec5:	c7 04 24 54 6d 10 f0 	movl   $0xf0106d54,(%esp)
f0104ecc:	e8 a9 e2 ff ff       	call   f010317a <cprintf>
			ismp = 0;
f0104ed1:	c7 05 00 10 22 f0 00 	movl   $0x0,0xf0221000
f0104ed8:	00 00 00 
			i = conf->entry;
f0104edb:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104edf:	83 c3 01             	add    $0x1,%ebx
f0104ee2:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0104ee6:	39 d8                	cmp    %ebx,%eax
f0104ee8:	0f 87 6e ff ff ff    	ja     f0104e5c <mp_init+0x1b8>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0104eee:	a1 c0 13 22 f0       	mov    0xf02213c0,%eax
f0104ef3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0104efa:	83 3d 00 10 22 f0 00 	cmpl   $0x0,0xf0221000
f0104f01:	75 22                	jne    f0104f25 <mp_init+0x281>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0104f03:	c7 05 c4 13 22 f0 01 	movl   $0x1,0xf02213c4
f0104f0a:	00 00 00 
		lapicaddr = 0;
f0104f0d:	c7 05 00 20 26 f0 00 	movl   $0x0,0xf0262000
f0104f14:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0104f17:	c7 04 24 74 6d 10 f0 	movl   $0xf0106d74,(%esp)
f0104f1e:	e8 57 e2 ff ff       	call   f010317a <cprintf>
f0104f23:	eb 44                	jmp    f0104f69 <mp_init+0x2c5>
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0104f25:	8b 15 c4 13 22 f0    	mov    0xf02213c4,%edx
f0104f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104f2f:	0f b6 00             	movzbl (%eax),%eax
f0104f32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f36:	c7 04 24 fb 6d 10 f0 	movl   $0xf0106dfb,(%esp)
f0104f3d:	e8 38 e2 ff ff       	call   f010317a <cprintf>

	if (mp->imcrp) {
f0104f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f45:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0104f49:	74 1e                	je     f0104f69 <mp_init+0x2c5>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0104f4b:	c7 04 24 a0 6d 10 f0 	movl   $0xf0106da0,(%esp)
f0104f52:	e8 23 e2 ff ff       	call   f010317a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104f57:	ba 22 00 00 00       	mov    $0x22,%edx
f0104f5c:	b8 70 00 00 00       	mov    $0x70,%eax
f0104f61:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104f62:	b2 23                	mov    $0x23,%dl
f0104f64:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0104f65:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104f68:	ee                   	out    %al,(%dx)
	}
}
f0104f69:	83 c4 2c             	add    $0x2c,%esp
f0104f6c:	5b                   	pop    %ebx
f0104f6d:	5e                   	pop    %esi
f0104f6e:	5f                   	pop    %edi
f0104f6f:	5d                   	pop    %ebp
f0104f70:	c3                   	ret    
f0104f71:	00 00                	add    %al,(%eax)
	...

f0104f74 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0104f74:	55                   	push   %ebp
f0104f75:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0104f77:	8b 0d 04 20 26 f0    	mov    0xf0262004,%ecx
f0104f7d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104f80:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0104f82:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f0104f87:	8b 40 20             	mov    0x20(%eax),%eax
}
f0104f8a:	5d                   	pop    %ebp
f0104f8b:	c3                   	ret    

f0104f8c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0104f8c:	55                   	push   %ebp
f0104f8d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0104f8f:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f0104f94:	85 c0                	test   %eax,%eax
f0104f96:	74 08                	je     f0104fa0 <cpunum+0x14>
		return lapic[ID] >> 24;
f0104f98:	8b 40 20             	mov    0x20(%eax),%eax
f0104f9b:	c1 e8 18             	shr    $0x18,%eax
f0104f9e:	eb 05                	jmp    f0104fa5 <cpunum+0x19>
	return 0;
f0104fa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fa5:	5d                   	pop    %ebp
f0104fa6:	c3                   	ret    

f0104fa7 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0104fa7:	a1 00 20 26 f0       	mov    0xf0262000,%eax
f0104fac:	85 c0                	test   %eax,%eax
f0104fae:	0f 84 23 01 00 00    	je     f01050d7 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0104fb4:	55                   	push   %ebp
f0104fb5:	89 e5                	mov    %esp,%ebp
f0104fb7:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0104fba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0104fc1:	00 
f0104fc2:	89 04 24             	mov    %eax,(%esp)
f0104fc5:	e8 f0 c0 ff ff       	call   f01010ba <mmio_map_region>
f0104fca:	a3 04 20 26 f0       	mov    %eax,0xf0262004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0104fcf:	ba 27 01 00 00       	mov    $0x127,%edx
f0104fd4:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104fd9:	e8 96 ff ff ff       	call   f0104f74 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0104fde:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104fe3:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104fe8:	e8 87 ff ff ff       	call   f0104f74 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0104fed:	ba 20 00 02 00       	mov    $0x20020,%edx
f0104ff2:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0104ff7:	e8 78 ff ff ff       	call   f0104f74 <lapicw>
	lapicw(TICR, 10000000); 
f0104ffc:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105001:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105006:	e8 69 ff ff ff       	call   f0104f74 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010500b:	e8 7c ff ff ff       	call   f0104f8c <cpunum>
f0105010:	6b c0 74             	imul   $0x74,%eax,%eax
f0105013:	05 20 10 22 f0       	add    $0xf0221020,%eax
f0105018:	39 05 c0 13 22 f0    	cmp    %eax,0xf02213c0
f010501e:	74 0f                	je     f010502f <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0105020:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105025:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010502a:	e8 45 ff ff ff       	call   f0104f74 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010502f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105034:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105039:	e8 36 ff ff ff       	call   f0104f74 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010503e:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f0105043:	8b 40 30             	mov    0x30(%eax),%eax
f0105046:	c1 e8 10             	shr    $0x10,%eax
f0105049:	3c 03                	cmp    $0x3,%al
f010504b:	76 0f                	jbe    f010505c <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010504d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105052:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105057:	e8 18 ff ff ff       	call   f0104f74 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010505c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105061:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105066:	e8 09 ff ff ff       	call   f0104f74 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010506b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105070:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105075:	e8 fa fe ff ff       	call   f0104f74 <lapicw>
	lapicw(ESR, 0);
f010507a:	ba 00 00 00 00       	mov    $0x0,%edx
f010507f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105084:	e8 eb fe ff ff       	call   f0104f74 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105089:	ba 00 00 00 00       	mov    $0x0,%edx
f010508e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105093:	e8 dc fe ff ff       	call   f0104f74 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105098:	ba 00 00 00 00       	mov    $0x0,%edx
f010509d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050a2:	e8 cd fe ff ff       	call   f0104f74 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01050a7:	ba 00 85 08 00       	mov    $0x88500,%edx
f01050ac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050b1:	e8 be fe ff ff       	call   f0104f74 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01050b6:	8b 15 04 20 26 f0    	mov    0xf0262004,%edx
f01050bc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01050c2:	f6 c4 10             	test   $0x10,%ah
f01050c5:	75 f5                	jne    f01050bc <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01050c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01050cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01050d1:	e8 9e fe ff ff       	call   f0104f74 <lapicw>
}
f01050d6:	c9                   	leave  
f01050d7:	f3 c3                	repz ret 

f01050d9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01050d9:	83 3d 04 20 26 f0 00 	cmpl   $0x0,0xf0262004
f01050e0:	74 13                	je     f01050f5 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01050e2:	55                   	push   %ebp
f01050e3:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01050e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01050ea:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01050ef:	e8 80 fe ff ff       	call   f0104f74 <lapicw>
}
f01050f4:	5d                   	pop    %ebp
f01050f5:	f3 c3                	repz ret 

f01050f7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01050f7:	55                   	push   %ebp
f01050f8:	89 e5                	mov    %esp,%ebp
f01050fa:	56                   	push   %esi
f01050fb:	53                   	push   %ebx
f01050fc:	83 ec 10             	sub    $0x10,%esp
f01050ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105102:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105105:	ba 70 00 00 00       	mov    $0x70,%edx
f010510a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010510f:	ee                   	out    %al,(%dx)
f0105110:	b2 71                	mov    $0x71,%dl
f0105112:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105117:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105118:	83 3d e8 0e 22 f0 00 	cmpl   $0x0,0xf0220ee8
f010511f:	75 24                	jne    f0105145 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105121:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0105128:	00 
f0105129:	c7 44 24 08 48 57 10 	movl   $0xf0105748,0x8(%esp)
f0105130:	f0 
f0105131:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0105138:	00 
f0105139:	c7 04 24 18 6e 10 f0 	movl   $0xf0106e18,(%esp)
f0105140:	e8 fb ae ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105145:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010514c:	00 00 
	wrv[1] = addr >> 4;
f010514e:	89 f0                	mov    %esi,%eax
f0105150:	c1 e8 04             	shr    $0x4,%eax
f0105153:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105159:	c1 e3 18             	shl    $0x18,%ebx
f010515c:	89 da                	mov    %ebx,%edx
f010515e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105163:	e8 0c fe ff ff       	call   f0104f74 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105168:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010516d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105172:	e8 fd fd ff ff       	call   f0104f74 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105177:	ba 00 85 00 00       	mov    $0x8500,%edx
f010517c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105181:	e8 ee fd ff ff       	call   f0104f74 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105186:	c1 ee 0c             	shr    $0xc,%esi
f0105189:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010518f:	89 da                	mov    %ebx,%edx
f0105191:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105196:	e8 d9 fd ff ff       	call   f0104f74 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010519b:	89 f2                	mov    %esi,%edx
f010519d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01051a2:	e8 cd fd ff ff       	call   f0104f74 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01051a7:	89 da                	mov    %ebx,%edx
f01051a9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01051ae:	e8 c1 fd ff ff       	call   f0104f74 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01051b3:	89 f2                	mov    %esi,%edx
f01051b5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01051ba:	e8 b5 fd ff ff       	call   f0104f74 <lapicw>
		microdelay(200);
	}
}
f01051bf:	83 c4 10             	add    $0x10,%esp
f01051c2:	5b                   	pop    %ebx
f01051c3:	5e                   	pop    %esi
f01051c4:	5d                   	pop    %ebp
f01051c5:	c3                   	ret    

f01051c6 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01051c6:	55                   	push   %ebp
f01051c7:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01051c9:	8b 55 08             	mov    0x8(%ebp),%edx
f01051cc:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01051d2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01051d7:	e8 98 fd ff ff       	call   f0104f74 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01051dc:	8b 15 04 20 26 f0    	mov    0xf0262004,%edx
f01051e2:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01051e8:	f6 c4 10             	test   $0x10,%ah
f01051eb:	75 f5                	jne    f01051e2 <lapic_ipi+0x1c>
		;
}
f01051ed:	5d                   	pop    %ebp
f01051ee:	c3                   	ret    
	...

f01051f0 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01051f0:	83 38 00             	cmpl   $0x0,(%eax)
f01051f3:	74 21                	je     f0105216 <holding+0x26>
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01051f5:	55                   	push   %ebp
f01051f6:	89 e5                	mov    %esp,%ebp
f01051f8:	53                   	push   %ebx
f01051f9:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01051fc:	8b 58 08             	mov    0x8(%eax),%ebx
f01051ff:	e8 88 fd ff ff       	call   f0104f8c <cpunum>
f0105204:	6b c0 74             	imul   $0x74,%eax,%eax
f0105207:	05 20 10 22 f0       	add    $0xf0221020,%eax
f010520c:	39 c3                	cmp    %eax,%ebx
f010520e:	0f 94 c0             	sete   %al
f0105211:	0f b6 c0             	movzbl %al,%eax
f0105214:	eb 06                	jmp    f010521c <holding+0x2c>
f0105216:	b8 00 00 00 00       	mov    $0x0,%eax
f010521b:	c3                   	ret    
}
f010521c:	83 c4 04             	add    $0x4,%esp
f010521f:	5b                   	pop    %ebx
f0105220:	5d                   	pop    %ebp
f0105221:	c3                   	ret    

f0105222 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105222:	55                   	push   %ebp
f0105223:	89 e5                	mov    %esp,%ebp
f0105225:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105228:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010522e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105231:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105234:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010523b:	5d                   	pop    %ebp
f010523c:	c3                   	ret    

f010523d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010523d:	55                   	push   %ebp
f010523e:	89 e5                	mov    %esp,%ebp
f0105240:	53                   	push   %ebx
f0105241:	83 ec 24             	sub    $0x24,%esp
f0105244:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105247:	89 d8                	mov    %ebx,%eax
f0105249:	e8 a2 ff ff ff       	call   f01051f0 <holding>
f010524e:	85 c0                	test   %eax,%eax
f0105250:	75 12                	jne    f0105264 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105252:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105254:	b0 01                	mov    $0x1,%al
f0105256:	f0 87 03             	lock xchg %eax,(%ebx)
f0105259:	b9 01 00 00 00       	mov    $0x1,%ecx
f010525e:	85 c0                	test   %eax,%eax
f0105260:	75 2e                	jne    f0105290 <spin_lock+0x53>
f0105262:	eb 37                	jmp    f010529b <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105264:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105267:	e8 20 fd ff ff       	call   f0104f8c <cpunum>
f010526c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105270:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105274:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010527b:	f0 
f010527c:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0105283:	00 
f0105284:	c7 04 24 8c 6e 10 f0 	movl   $0xf0106e8c,(%esp)
f010528b:	e8 b0 ad ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105290:	f3 90                	pause  
f0105292:	89 c8                	mov    %ecx,%eax
f0105294:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105297:	85 c0                	test   %eax,%eax
f0105299:	75 f5                	jne    f0105290 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010529b:	e8 ec fc ff ff       	call   f0104f8c <cpunum>
f01052a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01052a3:	05 20 10 22 f0       	add    $0xf0221020,%eax
f01052a8:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01052ab:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01052ae:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01052b0:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01052b5:	77 34                	ja     f01052eb <spin_lock+0xae>
f01052b7:	eb 2b                	jmp    f01052e4 <spin_lock+0xa7>
f01052b9:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01052bf:	76 12                	jbe    f01052d3 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01052c1:	8b 5a 04             	mov    0x4(%edx),%ebx
f01052c4:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01052c7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01052c9:	83 c0 01             	add    $0x1,%eax
f01052cc:	83 f8 0a             	cmp    $0xa,%eax
f01052cf:	75 e8                	jne    f01052b9 <spin_lock+0x7c>
f01052d1:	eb 27                	jmp    f01052fa <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01052d3:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01052da:	83 c0 01             	add    $0x1,%eax
f01052dd:	83 f8 09             	cmp    $0x9,%eax
f01052e0:	7e f1                	jle    f01052d3 <spin_lock+0x96>
f01052e2:	eb 16                	jmp    f01052fa <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01052e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01052e9:	eb e8                	jmp    f01052d3 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01052eb:	8b 50 04             	mov    0x4(%eax),%edx
f01052ee:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01052f1:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01052f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01052f8:	eb bf                	jmp    f01052b9 <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01052fa:	83 c4 24             	add    $0x24,%esp
f01052fd:	5b                   	pop    %ebx
f01052fe:	5d                   	pop    %ebp
f01052ff:	c3                   	ret    

f0105300 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105300:	55                   	push   %ebp
f0105301:	89 e5                	mov    %esp,%ebp
f0105303:	83 ec 78             	sub    $0x78,%esp
f0105306:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105309:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010530c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010530f:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105312:	89 d8                	mov    %ebx,%eax
f0105314:	e8 d7 fe ff ff       	call   f01051f0 <holding>
f0105319:	85 c0                	test   %eax,%eax
f010531b:	0f 85 d4 00 00 00    	jne    f01053f5 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105321:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0105328:	00 
f0105329:	8d 43 0c             	lea    0xc(%ebx),%eax
f010532c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105330:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0105333:	89 04 24             	mov    %eax,(%esp)
f0105336:	e8 08 f6 ff ff       	call   f0104943 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010533b:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010533e:	0f b6 30             	movzbl (%eax),%esi
f0105341:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105344:	e8 43 fc ff ff       	call   f0104f8c <cpunum>
f0105349:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010534d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105351:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105355:	c7 04 24 54 6e 10 f0 	movl   $0xf0106e54,(%esp)
f010535c:	e8 19 de ff ff       	call   f010317a <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105361:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105364:	85 c0                	test   %eax,%eax
f0105366:	74 71                	je     f01053d9 <spin_unlock+0xd9>
f0105368:	8d 5d c0             	lea    -0x40(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010536b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010536e:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0105371:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105375:	89 04 24             	mov    %eax,(%esp)
f0105378:	e8 4d e9 ff ff       	call   f0103cca <debuginfo_eip>
f010537d:	85 c0                	test   %eax,%eax
f010537f:	78 39                	js     f01053ba <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105381:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105383:	89 c2                	mov    %eax,%edx
f0105385:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105388:	89 54 24 18          	mov    %edx,0x18(%esp)
f010538c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010538f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0105393:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105396:	89 54 24 10          	mov    %edx,0x10(%esp)
f010539a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f010539d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01053a1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f01053a4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ac:	c7 04 24 9c 6e 10 f0 	movl   $0xf0106e9c,(%esp)
f01053b3:	e8 c2 dd ff ff       	call   f010317a <cprintf>
f01053b8:	eb 12                	jmp    f01053cc <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01053ba:	8b 03                	mov    (%ebx),%eax
f01053bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053c0:	c7 04 24 b3 6e 10 f0 	movl   $0xf0106eb3,(%esp)
f01053c7:	e8 ae dd ff ff       	call   f010317a <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01053cc:	39 fb                	cmp    %edi,%ebx
f01053ce:	74 09                	je     f01053d9 <spin_unlock+0xd9>
f01053d0:	83 c3 04             	add    $0x4,%ebx
f01053d3:	8b 03                	mov    (%ebx),%eax
f01053d5:	85 c0                	test   %eax,%eax
f01053d7:	75 98                	jne    f0105371 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01053d9:	c7 44 24 08 bb 6e 10 	movl   $0xf0106ebb,0x8(%esp)
f01053e0:	f0 
f01053e1:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01053e8:	00 
f01053e9:	c7 04 24 8c 6e 10 f0 	movl   $0xf0106e8c,(%esp)
f01053f0:	e8 4b ac ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01053f5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01053fc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105403:	b8 00 00 00 00       	mov    $0x0,%eax
f0105408:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010540b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010540e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105411:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105414:	89 ec                	mov    %ebp,%esp
f0105416:	5d                   	pop    %ebp
f0105417:	c3                   	ret    
	...

f0105420 <__udivdi3>:
f0105420:	83 ec 1c             	sub    $0x1c,%esp
f0105423:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0105427:	89 7c 24 14          	mov    %edi,0x14(%esp)
f010542b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010542f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0105433:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0105437:	8b 6c 24 24          	mov    0x24(%esp),%ebp
f010543b:	85 c0                	test   %eax,%eax
f010543d:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105441:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105445:	89 ea                	mov    %ebp,%edx
f0105447:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010544b:	75 33                	jne    f0105480 <__udivdi3+0x60>
f010544d:	39 e9                	cmp    %ebp,%ecx
f010544f:	77 6f                	ja     f01054c0 <__udivdi3+0xa0>
f0105451:	85 c9                	test   %ecx,%ecx
f0105453:	89 ce                	mov    %ecx,%esi
f0105455:	75 0b                	jne    f0105462 <__udivdi3+0x42>
f0105457:	b8 01 00 00 00       	mov    $0x1,%eax
f010545c:	31 d2                	xor    %edx,%edx
f010545e:	f7 f1                	div    %ecx
f0105460:	89 c6                	mov    %eax,%esi
f0105462:	31 d2                	xor    %edx,%edx
f0105464:	89 e8                	mov    %ebp,%eax
f0105466:	f7 f6                	div    %esi
f0105468:	89 c5                	mov    %eax,%ebp
f010546a:	89 f8                	mov    %edi,%eax
f010546c:	f7 f6                	div    %esi
f010546e:	89 ea                	mov    %ebp,%edx
f0105470:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105474:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105478:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010547c:	83 c4 1c             	add    $0x1c,%esp
f010547f:	c3                   	ret    
f0105480:	39 e8                	cmp    %ebp,%eax
f0105482:	77 24                	ja     f01054a8 <__udivdi3+0x88>
f0105484:	0f bd c8             	bsr    %eax,%ecx
f0105487:	83 f1 1f             	xor    $0x1f,%ecx
f010548a:	89 0c 24             	mov    %ecx,(%esp)
f010548d:	75 49                	jne    f01054d8 <__udivdi3+0xb8>
f010548f:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105493:	39 74 24 04          	cmp    %esi,0x4(%esp)
f0105497:	0f 86 ab 00 00 00    	jbe    f0105548 <__udivdi3+0x128>
f010549d:	39 e8                	cmp    %ebp,%eax
f010549f:	0f 82 a3 00 00 00    	jb     f0105548 <__udivdi3+0x128>
f01054a5:	8d 76 00             	lea    0x0(%esi),%esi
f01054a8:	31 d2                	xor    %edx,%edx
f01054aa:	31 c0                	xor    %eax,%eax
f01054ac:	8b 74 24 10          	mov    0x10(%esp),%esi
f01054b0:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01054b4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01054b8:	83 c4 1c             	add    $0x1c,%esp
f01054bb:	c3                   	ret    
f01054bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01054c0:	89 f8                	mov    %edi,%eax
f01054c2:	f7 f1                	div    %ecx
f01054c4:	31 d2                	xor    %edx,%edx
f01054c6:	8b 74 24 10          	mov    0x10(%esp),%esi
f01054ca:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01054ce:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01054d2:	83 c4 1c             	add    $0x1c,%esp
f01054d5:	c3                   	ret    
f01054d6:	66 90                	xchg   %ax,%ax
f01054d8:	0f b6 0c 24          	movzbl (%esp),%ecx
f01054dc:	89 c6                	mov    %eax,%esi
f01054de:	b8 20 00 00 00       	mov    $0x20,%eax
f01054e3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
f01054e7:	2b 04 24             	sub    (%esp),%eax
f01054ea:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01054ee:	d3 e6                	shl    %cl,%esi
f01054f0:	89 c1                	mov    %eax,%ecx
f01054f2:	d3 ed                	shr    %cl,%ebp
f01054f4:	0f b6 0c 24          	movzbl (%esp),%ecx
f01054f8:	09 f5                	or     %esi,%ebp
f01054fa:	8b 74 24 04          	mov    0x4(%esp),%esi
f01054fe:	d3 e6                	shl    %cl,%esi
f0105500:	89 c1                	mov    %eax,%ecx
f0105502:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105506:	89 d6                	mov    %edx,%esi
f0105508:	d3 ee                	shr    %cl,%esi
f010550a:	0f b6 0c 24          	movzbl (%esp),%ecx
f010550e:	d3 e2                	shl    %cl,%edx
f0105510:	89 c1                	mov    %eax,%ecx
f0105512:	d3 ef                	shr    %cl,%edi
f0105514:	09 d7                	or     %edx,%edi
f0105516:	89 f2                	mov    %esi,%edx
f0105518:	89 f8                	mov    %edi,%eax
f010551a:	f7 f5                	div    %ebp
f010551c:	89 d6                	mov    %edx,%esi
f010551e:	89 c7                	mov    %eax,%edi
f0105520:	f7 64 24 04          	mull   0x4(%esp)
f0105524:	39 d6                	cmp    %edx,%esi
f0105526:	72 30                	jb     f0105558 <__udivdi3+0x138>
f0105528:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f010552c:	0f b6 0c 24          	movzbl (%esp),%ecx
f0105530:	d3 e5                	shl    %cl,%ebp
f0105532:	39 c5                	cmp    %eax,%ebp
f0105534:	73 04                	jae    f010553a <__udivdi3+0x11a>
f0105536:	39 d6                	cmp    %edx,%esi
f0105538:	74 1e                	je     f0105558 <__udivdi3+0x138>
f010553a:	89 f8                	mov    %edi,%eax
f010553c:	31 d2                	xor    %edx,%edx
f010553e:	e9 69 ff ff ff       	jmp    f01054ac <__udivdi3+0x8c>
f0105543:	90                   	nop
f0105544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105548:	31 d2                	xor    %edx,%edx
f010554a:	b8 01 00 00 00       	mov    $0x1,%eax
f010554f:	e9 58 ff ff ff       	jmp    f01054ac <__udivdi3+0x8c>
f0105554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105558:	8d 47 ff             	lea    -0x1(%edi),%eax
f010555b:	31 d2                	xor    %edx,%edx
f010555d:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105561:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105565:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0105569:	83 c4 1c             	add    $0x1c,%esp
f010556c:	c3                   	ret    
f010556d:	00 00                	add    %al,(%eax)
	...

f0105570 <__umoddi3>:
f0105570:	83 ec 2c             	sub    $0x2c,%esp
f0105573:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105577:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010557b:	89 74 24 20          	mov    %esi,0x20(%esp)
f010557f:	8b 74 24 38          	mov    0x38(%esp),%esi
f0105583:	89 7c 24 24          	mov    %edi,0x24(%esp)
f0105587:	8b 7c 24 34          	mov    0x34(%esp),%edi
f010558b:	85 c0                	test   %eax,%eax
f010558d:	89 c2                	mov    %eax,%edx
f010558f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f0105593:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0105597:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010559b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010559f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01055a3:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01055a7:	75 1f                	jne    f01055c8 <__umoddi3+0x58>
f01055a9:	39 fe                	cmp    %edi,%esi
f01055ab:	76 63                	jbe    f0105610 <__umoddi3+0xa0>
f01055ad:	89 c8                	mov    %ecx,%eax
f01055af:	89 fa                	mov    %edi,%edx
f01055b1:	f7 f6                	div    %esi
f01055b3:	89 d0                	mov    %edx,%eax
f01055b5:	31 d2                	xor    %edx,%edx
f01055b7:	8b 74 24 20          	mov    0x20(%esp),%esi
f01055bb:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01055bf:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01055c3:	83 c4 2c             	add    $0x2c,%esp
f01055c6:	c3                   	ret    
f01055c7:	90                   	nop
f01055c8:	39 f8                	cmp    %edi,%eax
f01055ca:	77 64                	ja     f0105630 <__umoddi3+0xc0>
f01055cc:	0f bd e8             	bsr    %eax,%ebp
f01055cf:	83 f5 1f             	xor    $0x1f,%ebp
f01055d2:	75 74                	jne    f0105648 <__umoddi3+0xd8>
f01055d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01055d8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
f01055dc:	0f 87 0e 01 00 00    	ja     f01056f0 <__umoddi3+0x180>
f01055e2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
f01055e6:	29 f1                	sub    %esi,%ecx
f01055e8:	19 c7                	sbb    %eax,%edi
f01055ea:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01055ee:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01055f2:	8b 44 24 14          	mov    0x14(%esp),%eax
f01055f6:	8b 54 24 18          	mov    0x18(%esp),%edx
f01055fa:	8b 74 24 20          	mov    0x20(%esp),%esi
f01055fe:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0105602:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0105606:	83 c4 2c             	add    $0x2c,%esp
f0105609:	c3                   	ret    
f010560a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105610:	85 f6                	test   %esi,%esi
f0105612:	89 f5                	mov    %esi,%ebp
f0105614:	75 0b                	jne    f0105621 <__umoddi3+0xb1>
f0105616:	b8 01 00 00 00       	mov    $0x1,%eax
f010561b:	31 d2                	xor    %edx,%edx
f010561d:	f7 f6                	div    %esi
f010561f:	89 c5                	mov    %eax,%ebp
f0105621:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105625:	31 d2                	xor    %edx,%edx
f0105627:	f7 f5                	div    %ebp
f0105629:	89 c8                	mov    %ecx,%eax
f010562b:	f7 f5                	div    %ebp
f010562d:	eb 84                	jmp    f01055b3 <__umoddi3+0x43>
f010562f:	90                   	nop
f0105630:	89 c8                	mov    %ecx,%eax
f0105632:	89 fa                	mov    %edi,%edx
f0105634:	8b 74 24 20          	mov    0x20(%esp),%esi
f0105638:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010563c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0105640:	83 c4 2c             	add    $0x2c,%esp
f0105643:	c3                   	ret    
f0105644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105648:	8b 44 24 10          	mov    0x10(%esp),%eax
f010564c:	be 20 00 00 00       	mov    $0x20,%esi
f0105651:	89 e9                	mov    %ebp,%ecx
f0105653:	29 ee                	sub    %ebp,%esi
f0105655:	d3 e2                	shl    %cl,%edx
f0105657:	89 f1                	mov    %esi,%ecx
f0105659:	d3 e8                	shr    %cl,%eax
f010565b:	89 e9                	mov    %ebp,%ecx
f010565d:	09 d0                	or     %edx,%eax
f010565f:	89 fa                	mov    %edi,%edx
f0105661:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105665:	8b 44 24 10          	mov    0x10(%esp),%eax
f0105669:	d3 e0                	shl    %cl,%eax
f010566b:	89 f1                	mov    %esi,%ecx
f010566d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105671:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0105675:	d3 ea                	shr    %cl,%edx
f0105677:	89 e9                	mov    %ebp,%ecx
f0105679:	d3 e7                	shl    %cl,%edi
f010567b:	89 f1                	mov    %esi,%ecx
f010567d:	d3 e8                	shr    %cl,%eax
f010567f:	89 e9                	mov    %ebp,%ecx
f0105681:	09 f8                	or     %edi,%eax
f0105683:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0105687:	f7 74 24 0c          	divl   0xc(%esp)
f010568b:	d3 e7                	shl    %cl,%edi
f010568d:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0105691:	89 d7                	mov    %edx,%edi
f0105693:	f7 64 24 10          	mull   0x10(%esp)
f0105697:	39 d7                	cmp    %edx,%edi
f0105699:	89 c1                	mov    %eax,%ecx
f010569b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010569f:	72 3b                	jb     f01056dc <__umoddi3+0x16c>
f01056a1:	39 44 24 18          	cmp    %eax,0x18(%esp)
f01056a5:	72 31                	jb     f01056d8 <__umoddi3+0x168>
f01056a7:	8b 44 24 18          	mov    0x18(%esp),%eax
f01056ab:	29 c8                	sub    %ecx,%eax
f01056ad:	19 d7                	sbb    %edx,%edi
f01056af:	89 e9                	mov    %ebp,%ecx
f01056b1:	89 fa                	mov    %edi,%edx
f01056b3:	d3 e8                	shr    %cl,%eax
f01056b5:	89 f1                	mov    %esi,%ecx
f01056b7:	d3 e2                	shl    %cl,%edx
f01056b9:	89 e9                	mov    %ebp,%ecx
f01056bb:	09 d0                	or     %edx,%eax
f01056bd:	89 fa                	mov    %edi,%edx
f01056bf:	d3 ea                	shr    %cl,%edx
f01056c1:	8b 74 24 20          	mov    0x20(%esp),%esi
f01056c5:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01056c9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01056cd:	83 c4 2c             	add    $0x2c,%esp
f01056d0:	c3                   	ret    
f01056d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01056d8:	39 d7                	cmp    %edx,%edi
f01056da:	75 cb                	jne    f01056a7 <__umoddi3+0x137>
f01056dc:	8b 54 24 14          	mov    0x14(%esp),%edx
f01056e0:	89 c1                	mov    %eax,%ecx
f01056e2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
f01056e6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f01056ea:	eb bb                	jmp    f01056a7 <__umoddi3+0x137>
f01056ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01056f0:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01056f4:	0f 82 e8 fe ff ff    	jb     f01055e2 <__umoddi3+0x72>
f01056fa:	e9 f3 fe ff ff       	jmp    f01055f2 <__umoddi3+0x82>
