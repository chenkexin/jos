
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 30 cc 17 f0       	mov    $0xf017cc30,%eax
f010004b:	2d 2f bd 17 f0       	sub    $0xf017bd2f,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 2f bd 17 f0 	movl   $0xf017bd2f,(%esp)
f0100063:	e8 bd 42 00 00       	call   f0104325 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 ca 04 00 00       	call   f0100537 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 48 10 f0 	movl   $0xf0104860,(%esp)
f010007c:	e8 f9 31 00 00       	call   f010327a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 57 11 00 00       	call   f01011dd <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 dd 2d 00 00       	call   f0102e68 <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 5c 32 00 00       	call   f01032f1 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010009c:	00 
f010009d:	c7 44 24 04 1a 78 00 	movl   $0x781a,0x4(%esp)
f01000a4:	00 
f01000a5:	c7 04 24 58 a3 11 f0 	movl   $0xf011a358,(%esp)
f01000ac:	e8 f0 2e 00 00       	call   f0102fa1 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000b1:	a1 90 bf 17 f0       	mov    0xf017bf90,%eax
f01000b6:	89 04 24             	mov    %eax,(%esp)
f01000b9:	e8 28 31 00 00       	call   f01031e6 <env_run>

f01000be <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000be:	55                   	push   %ebp
f01000bf:	89 e5                	mov    %esp,%ebp
f01000c1:	56                   	push   %esi
f01000c2:	53                   	push   %ebx
f01000c3:	83 ec 10             	sub    $0x10,%esp
f01000c6:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c9:	83 3d 20 cc 17 f0 00 	cmpl   $0x0,0xf017cc20
f01000d0:	75 3d                	jne    f010010f <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000d2:	89 35 20 cc 17 f0    	mov    %esi,0xf017cc20

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d8:	fa                   	cli    
f01000d9:	fc                   	cld    

	va_start(ap, fmt);
f01000da:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 7b 48 10 f0 	movl   $0xf010487b,(%esp)
f01000f2:	e8 83 31 00 00       	call   f010327a <cprintf>
	vcprintf(fmt, ap);
f01000f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000fb:	89 34 24             	mov    %esi,(%esp)
f01000fe:	e8 44 31 00 00       	call   f0103247 <vcprintf>
	cprintf("\n");
f0100103:	c7 04 24 e7 56 10 f0 	movl   $0xf01056e7,(%esp)
f010010a:	e8 6b 31 00 00       	call   f010327a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100116:	e8 5e 06 00 00       	call   f0100779 <monitor>
f010011b:	eb f2                	jmp    f010010f <_panic+0x51>

f010011d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011d:	55                   	push   %ebp
f010011e:	89 e5                	mov    %esp,%ebp
f0100120:	53                   	push   %ebx
f0100121:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100124:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100127:	8b 45 0c             	mov    0xc(%ebp),%eax
f010012a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010012e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100131:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100135:	c7 04 24 93 48 10 f0 	movl   $0xf0104893,(%esp)
f010013c:	e8 39 31 00 00       	call   f010327a <cprintf>
	vcprintf(fmt, ap);
f0100141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100145:	8b 45 10             	mov    0x10(%ebp),%eax
f0100148:	89 04 24             	mov    %eax,(%esp)
f010014b:	e8 f7 30 00 00       	call   f0103247 <vcprintf>
	cprintf("\n");
f0100150:	c7 04 24 e7 56 10 f0 	movl   $0xf01056e7,(%esp)
f0100157:	e8 1e 31 00 00       	call   f010327a <cprintf>
	va_end(ap);
}
f010015c:	83 c4 14             	add    $0x14,%esp
f010015f:	5b                   	pop    %ebx
f0100160:	5d                   	pop    %ebp
f0100161:	c3                   	ret    
	...

f0100170 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100173:	ba 84 00 00 00       	mov    $0x84,%edx
f0100178:	ec                   	in     (%dx),%al
f0100179:	ec                   	in     (%dx),%al
f010017a:	ec                   	in     (%dx),%al
f010017b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010017e:	55                   	push   %ebp
f010017f:	89 e5                	mov    %esp,%ebp
f0100181:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100186:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100187:	a8 01                	test   $0x1,%al
f0100189:	74 08                	je     f0100193 <serial_proc_data+0x15>
f010018b:	b2 f8                	mov    $0xf8,%dl
f010018d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018e:	0f b6 c0             	movzbl %al,%eax
f0100191:	eb 05                	jmp    f0100198 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100193:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100198:	5d                   	pop    %ebp
f0100199:	c3                   	ret    

f010019a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019a:	55                   	push   %ebp
f010019b:	89 e5                	mov    %esp,%ebp
f010019d:	53                   	push   %ebx
f010019e:	83 ec 04             	sub    $0x4,%esp
f01001a1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a3:	eb 26                	jmp    f01001cb <cons_intr+0x31>
		if (c == 0)
f01001a5:	85 d2                	test   %edx,%edx
f01001a7:	74 22                	je     f01001cb <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a9:	a1 64 bf 17 f0       	mov    0xf017bf64,%eax
f01001ae:	88 90 60 bd 17 f0    	mov    %dl,-0xfe842a0(%eax)
f01001b4:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.wpos == CONSBUFSIZE)
f01001b7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c2:	0f 44 d0             	cmove  %eax,%edx
f01001c5:	89 15 64 bf 17 f0    	mov    %edx,0xf017bf64
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cb:	ff d3                	call   *%ebx
f01001cd:	89 c2                	mov    %eax,%edx
f01001cf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d2:	75 d1                	jne    f01001a5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d4:	83 c4 04             	add    $0x4,%esp
f01001d7:	5b                   	pop    %ebx
f01001d8:	5d                   	pop    %ebp
f01001d9:	c3                   	ret    

f01001da <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 2c             	sub    $0x2c,%esp
f01001e3:	89 c7                	mov    %eax,%edi
f01001e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001ea:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001eb:	a8 20                	test   $0x20,%al
f01001ed:	75 1b                	jne    f010020a <cons_putc+0x30>
f01001ef:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001f4:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001f9:	e8 72 ff ff ff       	call   f0100170 <delay>
f01001fe:	89 f2                	mov    %esi,%edx
f0100200:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100201:	a8 20                	test   $0x20,%al
f0100203:	75 05                	jne    f010020a <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100205:	83 eb 01             	sub    $0x1,%ebx
f0100208:	75 ef                	jne    f01001f9 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010020a:	89 f8                	mov    %edi,%eax
f010020c:	25 ff 00 00 00       	and    $0xff,%eax
f0100211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100214:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100219:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010021a:	b2 79                	mov    $0x79,%dl
f010021c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010021d:	84 c0                	test   %al,%al
f010021f:	78 1b                	js     f010023c <cons_putc+0x62>
f0100221:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100226:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010022b:	e8 40 ff ff ff       	call   f0100170 <delay>
f0100230:	89 f2                	mov    %esi,%edx
f0100232:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100233:	84 c0                	test   %al,%al
f0100235:	78 05                	js     f010023c <cons_putc+0x62>
f0100237:	83 eb 01             	sub    $0x1,%ebx
f010023a:	75 ef                	jne    f010022b <cons_putc+0x51>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010023c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100241:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100245:	ee                   	out    %al,(%dx)
f0100246:	b2 7a                	mov    $0x7a,%dl
f0100248:	b8 0d 00 00 00       	mov    $0xd,%eax
f010024d:	ee                   	out    %al,(%dx)
f010024e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100253:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100254:	89 fa                	mov    %edi,%edx
f0100256:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010025c:	89 f8                	mov    %edi,%eax
f010025e:	80 cc 07             	or     $0x7,%ah
f0100261:	85 d2                	test   %edx,%edx
f0100263:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100266:	89 f8                	mov    %edi,%eax
f0100268:	25 ff 00 00 00       	and    $0xff,%eax
f010026d:	83 f8 09             	cmp    $0x9,%eax
f0100270:	74 77                	je     f01002e9 <cons_putc+0x10f>
f0100272:	83 f8 09             	cmp    $0x9,%eax
f0100275:	7f 0b                	jg     f0100282 <cons_putc+0xa8>
f0100277:	83 f8 08             	cmp    $0x8,%eax
f010027a:	0f 85 9d 00 00 00    	jne    f010031d <cons_putc+0x143>
f0100280:	eb 10                	jmp    f0100292 <cons_putc+0xb8>
f0100282:	83 f8 0a             	cmp    $0xa,%eax
f0100285:	74 3c                	je     f01002c3 <cons_putc+0xe9>
f0100287:	83 f8 0d             	cmp    $0xd,%eax
f010028a:	0f 85 8d 00 00 00    	jne    f010031d <cons_putc+0x143>
f0100290:	eb 39                	jmp    f01002cb <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f0100292:	0f b7 05 74 bf 17 f0 	movzwl 0xf017bf74,%eax
f0100299:	66 85 c0             	test   %ax,%ax
f010029c:	0f 84 e5 00 00 00    	je     f0100387 <cons_putc+0x1ad>
			crt_pos--;
f01002a2:	83 e8 01             	sub    $0x1,%eax
f01002a5:	66 a3 74 bf 17 f0    	mov    %ax,0xf017bf74
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002ab:	0f b7 c0             	movzwl %ax,%eax
f01002ae:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01002b4:	83 cf 20             	or     $0x20,%edi
f01002b7:	8b 15 70 bf 17 f0    	mov    0xf017bf70,%edx
f01002bd:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01002c1:	eb 77                	jmp    f010033a <cons_putc+0x160>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002c3:	66 83 05 74 bf 17 f0 	addw   $0x50,0xf017bf74
f01002ca:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002cb:	0f b7 05 74 bf 17 f0 	movzwl 0xf017bf74,%eax
f01002d2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002d8:	c1 e8 16             	shr    $0x16,%eax
f01002db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002de:	c1 e0 04             	shl    $0x4,%eax
f01002e1:	66 a3 74 bf 17 f0    	mov    %ax,0xf017bf74
f01002e7:	eb 51                	jmp    f010033a <cons_putc+0x160>
		break;
	case '\t':
		cons_putc(' ');
f01002e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ee:	e8 e7 fe ff ff       	call   f01001da <cons_putc>
		cons_putc(' ');
f01002f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f8:	e8 dd fe ff ff       	call   f01001da <cons_putc>
		cons_putc(' ');
f01002fd:	b8 20 00 00 00       	mov    $0x20,%eax
f0100302:	e8 d3 fe ff ff       	call   f01001da <cons_putc>
		cons_putc(' ');
f0100307:	b8 20 00 00 00       	mov    $0x20,%eax
f010030c:	e8 c9 fe ff ff       	call   f01001da <cons_putc>
		cons_putc(' ');
f0100311:	b8 20 00 00 00       	mov    $0x20,%eax
f0100316:	e8 bf fe ff ff       	call   f01001da <cons_putc>
f010031b:	eb 1d                	jmp    f010033a <cons_putc+0x160>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010031d:	0f b7 05 74 bf 17 f0 	movzwl 0xf017bf74,%eax
f0100324:	0f b7 c8             	movzwl %ax,%ecx
f0100327:	8b 15 70 bf 17 f0    	mov    0xf017bf70,%edx
f010032d:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100331:	83 c0 01             	add    $0x1,%eax
f0100334:	66 a3 74 bf 17 f0    	mov    %ax,0xf017bf74
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010033a:	66 81 3d 74 bf 17 f0 	cmpw   $0x7cf,0xf017bf74
f0100341:	cf 07 
f0100343:	76 42                	jbe    f0100387 <cons_putc+0x1ad>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100345:	a1 70 bf 17 f0       	mov    0xf017bf70,%eax
f010034a:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100351:	00 
f0100352:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100358:	89 54 24 04          	mov    %edx,0x4(%esp)
f010035c:	89 04 24             	mov    %eax,(%esp)
f010035f:	e8 1f 40 00 00       	call   f0104383 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100364:	8b 15 70 bf 17 f0    	mov    0xf017bf70,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010036a:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010036f:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100375:	83 c0 01             	add    $0x1,%eax
f0100378:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010037d:	75 f0                	jne    f010036f <cons_putc+0x195>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010037f:	66 83 2d 74 bf 17 f0 	subw   $0x50,0xf017bf74
f0100386:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100387:	8b 0d 6c bf 17 f0    	mov    0xf017bf6c,%ecx
f010038d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100392:	89 ca                	mov    %ecx,%edx
f0100394:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100395:	0f b7 1d 74 bf 17 f0 	movzwl 0xf017bf74,%ebx
f010039c:	8d 71 01             	lea    0x1(%ecx),%esi
f010039f:	89 d8                	mov    %ebx,%eax
f01003a1:	66 c1 e8 08          	shr    $0x8,%ax
f01003a5:	89 f2                	mov    %esi,%edx
f01003a7:	ee                   	out    %al,(%dx)
f01003a8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003ad:	89 ca                	mov    %ecx,%edx
f01003af:	ee                   	out    %al,(%dx)
f01003b0:	89 d8                	mov    %ebx,%eax
f01003b2:	89 f2                	mov    %esi,%edx
f01003b4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b5:	83 c4 2c             	add    $0x2c,%esp
f01003b8:	5b                   	pop    %ebx
f01003b9:	5e                   	pop    %esi
f01003ba:	5f                   	pop    %edi
f01003bb:	5d                   	pop    %ebp
f01003bc:	c3                   	ret    

f01003bd <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003bd:	55                   	push   %ebp
f01003be:	89 e5                	mov    %esp,%ebp
f01003c0:	53                   	push   %ebx
f01003c1:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c4:	ba 64 00 00 00       	mov    $0x64,%edx
f01003c9:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003ca:	a8 01                	test   $0x1,%al
f01003cc:	0f 84 e5 00 00 00    	je     f01004b7 <kbd_proc_data+0xfa>
f01003d2:	b2 60                	mov    $0x60,%dl
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003d7:	3c e0                	cmp    $0xe0,%al
f01003d9:	75 11                	jne    f01003ec <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003db:	83 0d 68 bf 17 f0 40 	orl    $0x40,0xf017bf68
		return 0;
f01003e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e7:	e9 d0 00 00 00       	jmp    f01004bc <kbd_proc_data+0xff>
	} else if (data & 0x80) {
f01003ec:	84 c0                	test   %al,%al
f01003ee:	79 37                	jns    f0100427 <kbd_proc_data+0x6a>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003f0:	8b 0d 68 bf 17 f0    	mov    0xf017bf68,%ecx
f01003f6:	89 cb                	mov    %ecx,%ebx
f01003f8:	83 e3 40             	and    $0x40,%ebx
f01003fb:	83 e0 7f             	and    $0x7f,%eax
f01003fe:	85 db                	test   %ebx,%ebx
f0100400:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100403:	0f b6 d2             	movzbl %dl,%edx
f0100406:	0f b6 82 e0 48 10 f0 	movzbl -0xfefb720(%edx),%eax
f010040d:	83 c8 40             	or     $0x40,%eax
f0100410:	0f b6 c0             	movzbl %al,%eax
f0100413:	f7 d0                	not    %eax
f0100415:	21 c1                	and    %eax,%ecx
f0100417:	89 0d 68 bf 17 f0    	mov    %ecx,0xf017bf68
		return 0;
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100422:	e9 95 00 00 00       	jmp    f01004bc <kbd_proc_data+0xff>
	} else if (shift & E0ESC) {
f0100427:	8b 0d 68 bf 17 f0    	mov    0xf017bf68,%ecx
f010042d:	f6 c1 40             	test   $0x40,%cl
f0100430:	74 0e                	je     f0100440 <kbd_proc_data+0x83>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100432:	89 c2                	mov    %eax,%edx
f0100434:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100437:	83 e1 bf             	and    $0xffffffbf,%ecx
f010043a:	89 0d 68 bf 17 f0    	mov    %ecx,0xf017bf68
	}

	shift |= shiftcode[data];
f0100440:	0f b6 d2             	movzbl %dl,%edx
f0100443:	0f b6 82 e0 48 10 f0 	movzbl -0xfefb720(%edx),%eax
f010044a:	0b 05 68 bf 17 f0    	or     0xf017bf68,%eax
	shift ^= togglecode[data];
f0100450:	0f b6 8a e0 49 10 f0 	movzbl -0xfefb620(%edx),%ecx
f0100457:	31 c8                	xor    %ecx,%eax
f0100459:	a3 68 bf 17 f0       	mov    %eax,0xf017bf68

	c = charcode[shift & (CTL | SHIFT)][data];
f010045e:	89 c1                	mov    %eax,%ecx
f0100460:	83 e1 03             	and    $0x3,%ecx
f0100463:	8b 0c 8d e0 4a 10 f0 	mov    -0xfefb520(,%ecx,4),%ecx
f010046a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010046e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100471:	a8 08                	test   $0x8,%al
f0100473:	74 1b                	je     f0100490 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100475:	89 da                	mov    %ebx,%edx
f0100477:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010047a:	83 f9 19             	cmp    $0x19,%ecx
f010047d:	77 05                	ja     f0100484 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010047f:	83 eb 20             	sub    $0x20,%ebx
f0100482:	eb 0c                	jmp    f0100490 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100484:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100487:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010048a:	83 fa 19             	cmp    $0x19,%edx
f010048d:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100490:	f7 d0                	not    %eax
f0100492:	a8 06                	test   $0x6,%al
f0100494:	75 26                	jne    f01004bc <kbd_proc_data+0xff>
f0100496:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010049c:	75 1e                	jne    f01004bc <kbd_proc_data+0xff>
		cprintf("Rebooting!\n");
f010049e:	c7 04 24 ad 48 10 f0 	movl   $0xf01048ad,(%esp)
f01004a5:	e8 d0 2d 00 00       	call   f010327a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004aa:	ba 92 00 00 00       	mov    $0x92,%edx
f01004af:	b8 03 00 00 00       	mov    $0x3,%eax
f01004b4:	ee                   	out    %al,(%dx)
f01004b5:	eb 05                	jmp    f01004bc <kbd_proc_data+0xff>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004b7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004bc:	89 d8                	mov    %ebx,%eax
f01004be:	83 c4 14             	add    $0x14,%esp
f01004c1:	5b                   	pop    %ebx
f01004c2:	5d                   	pop    %ebp
f01004c3:	c3                   	ret    

f01004c4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004c4:	80 3d 40 bd 17 f0 00 	cmpb   $0x0,0xf017bd40
f01004cb:	74 11                	je     f01004de <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004cd:	55                   	push   %ebp
f01004ce:	89 e5                	mov    %esp,%ebp
f01004d0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d3:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004d8:	e8 bd fc ff ff       	call   f010019a <cons_intr>
}
f01004dd:	c9                   	leave  
f01004de:	f3 c3                	repz ret 

f01004e0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e0:	55                   	push   %ebp
f01004e1:	89 e5                	mov    %esp,%ebp
f01004e3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004e6:	b8 bd 03 10 f0       	mov    $0xf01003bd,%eax
f01004eb:	e8 aa fc ff ff       	call   f010019a <cons_intr>
}
f01004f0:	c9                   	leave  
f01004f1:	c3                   	ret    

f01004f2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f2:	55                   	push   %ebp
f01004f3:	89 e5                	mov    %esp,%ebp
f01004f5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004f8:	e8 c7 ff ff ff       	call   f01004c4 <serial_intr>
	kbd_intr();
f01004fd:	e8 de ff ff ff       	call   f01004e0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100502:	8b 15 60 bf 17 f0    	mov    0xf017bf60,%edx
f0100508:	3b 15 64 bf 17 f0    	cmp    0xf017bf64,%edx
f010050e:	74 20                	je     f0100530 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100510:	0f b6 82 60 bd 17 f0 	movzbl -0xfe842a0(%edx),%eax
f0100517:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010051a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
f0100520:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100525:	0f 44 d1             	cmove  %ecx,%edx
f0100528:	89 15 60 bf 17 f0    	mov    %edx,0xf017bf60
f010052e:	eb 05                	jmp    f0100535 <cons_getc+0x43>
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100530:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100535:	c9                   	leave  
f0100536:	c3                   	ret    

f0100537 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100537:	55                   	push   %ebp
f0100538:	89 e5                	mov    %esp,%ebp
f010053a:	57                   	push   %edi
f010053b:	56                   	push   %esi
f010053c:	53                   	push   %ebx
f010053d:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100540:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100547:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010054e:	5a a5 
	if (*cp != 0xA55A) {
f0100550:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100557:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010055b:	74 11                	je     f010056e <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010055d:	c7 05 6c bf 17 f0 b4 	movl   $0x3b4,0xf017bf6c
f0100564:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100567:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f010056c:	eb 16                	jmp    f0100584 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010056e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100575:	c7 05 6c bf 17 f0 d4 	movl   $0x3d4,0xf017bf6c
f010057c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010057f:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100584:	8b 0d 6c bf 17 f0    	mov    0xf017bf6c,%ecx
f010058a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058f:	89 ca                	mov    %ecx,%edx
f0100591:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100592:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100595:	89 da                	mov    %ebx,%edx
f0100597:	ec                   	in     (%dx),%al
f0100598:	0f b6 f0             	movzbl %al,%esi
f010059b:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059e:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a3:	89 ca                	mov    %ecx,%edx
f01005a5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a6:	89 da                	mov    %ebx,%edx
f01005a8:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005a9:	89 3d 70 bf 17 f0    	mov    %edi,0xf017bf70

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005af:	0f b6 d8             	movzbl %al,%ebx
f01005b2:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005b4:	66 89 35 74 bf 17 f0 	mov    %si,0xf017bf74
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bb:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c5:	89 f2                	mov    %esi,%edx
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	b2 fb                	mov    $0xfb,%dl
f01005ca:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005cf:	ee                   	out    %al,(%dx)
f01005d0:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005d5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005da:	89 da                	mov    %ebx,%edx
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	b2 f9                	mov    $0xf9,%dl
f01005df:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e4:	ee                   	out    %al,(%dx)
f01005e5:	b2 fb                	mov    $0xfb,%dl
f01005e7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	b2 fc                	mov    $0xfc,%dl
f01005ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f4:	ee                   	out    %al,(%dx)
f01005f5:	b2 f9                	mov    $0xf9,%dl
f01005f7:	b8 01 00 00 00       	mov    $0x1,%eax
f01005fc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fd:	b2 fd                	mov    $0xfd,%dl
f01005ff:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100600:	3c ff                	cmp    $0xff,%al
f0100602:	0f 95 c1             	setne  %cl
f0100605:	88 0d 40 bd 17 f0    	mov    %cl,0xf017bd40
f010060b:	89 f2                	mov    %esi,%edx
f010060d:	ec                   	in     (%dx),%al
f010060e:	89 da                	mov    %ebx,%edx
f0100610:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100611:	84 c9                	test   %cl,%cl
f0100613:	75 0c                	jne    f0100621 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f0100615:	c7 04 24 b9 48 10 f0 	movl   $0xf01048b9,(%esp)
f010061c:	e8 59 2c 00 00       	call   f010327a <cprintf>
}
f0100621:	83 c4 1c             	add    $0x1c,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5e                   	pop    %esi
f0100626:	5f                   	pop    %edi
f0100627:	5d                   	pop    %ebp
f0100628:	c3                   	ret    

f0100629 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100629:	55                   	push   %ebp
f010062a:	89 e5                	mov    %esp,%ebp
f010062c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010062f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100632:	e8 a3 fb ff ff       	call   f01001da <cons_putc>
}
f0100637:	c9                   	leave  
f0100638:	c3                   	ret    

f0100639 <getchar>:

int
getchar(void)
{
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010063f:	e8 ae fe ff ff       	call   f01004f2 <cons_getc>
f0100644:	85 c0                	test   %eax,%eax
f0100646:	74 f7                	je     f010063f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100648:	c9                   	leave  
f0100649:	c3                   	ret    

f010064a <iscons>:

int
iscons(int fdnum)
{
f010064a:	55                   	push   %ebp
f010064b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010064d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100652:	5d                   	pop    %ebp
f0100653:	c3                   	ret    
	...

f0100660 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100666:	c7 04 24 f0 4a 10 f0 	movl   $0xf0104af0,(%esp)
f010066d:	e8 08 2c 00 00       	call   f010327a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100672:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100679:	00 
f010067a:	c7 04 24 7c 4b 10 f0 	movl   $0xf0104b7c,(%esp)
f0100681:	e8 f4 2b 00 00       	call   f010327a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100686:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010068d:	00 
f010068e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100695:	f0 
f0100696:	c7 04 24 a4 4b 10 f0 	movl   $0xf0104ba4,(%esp)
f010069d:	e8 d8 2b 00 00       	call   f010327a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a2:	c7 44 24 08 5f 48 10 	movl   $0x10485f,0x8(%esp)
f01006a9:	00 
f01006aa:	c7 44 24 04 5f 48 10 	movl   $0xf010485f,0x4(%esp)
f01006b1:	f0 
f01006b2:	c7 04 24 c8 4b 10 f0 	movl   $0xf0104bc8,(%esp)
f01006b9:	e8 bc 2b 00 00       	call   f010327a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006be:	c7 44 24 08 2f bd 17 	movl   $0x17bd2f,0x8(%esp)
f01006c5:	00 
f01006c6:	c7 44 24 04 2f bd 17 	movl   $0xf017bd2f,0x4(%esp)
f01006cd:	f0 
f01006ce:	c7 04 24 ec 4b 10 f0 	movl   $0xf0104bec,(%esp)
f01006d5:	e8 a0 2b 00 00       	call   f010327a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006da:	c7 44 24 08 30 cc 17 	movl   $0x17cc30,0x8(%esp)
f01006e1:	00 
f01006e2:	c7 44 24 04 30 cc 17 	movl   $0xf017cc30,0x4(%esp)
f01006e9:	f0 
f01006ea:	c7 04 24 10 4c 10 f0 	movl   $0xf0104c10,(%esp)
f01006f1:	e8 84 2b 00 00       	call   f010327a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f6:	b8 2f d0 17 f0       	mov    $0xf017d02f,%eax
f01006fb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100700:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100705:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010070b:	85 c0                	test   %eax,%eax
f010070d:	0f 48 c2             	cmovs  %edx,%eax
f0100710:	c1 f8 0a             	sar    $0xa,%eax
f0100713:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100717:	c7 04 24 34 4c 10 f0 	movl   $0xf0104c34,(%esp)
f010071e:	e8 57 2b 00 00       	call   f010327a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	c9                   	leave  
f0100729:	c3                   	ret    

f010072a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100730:	c7 44 24 08 09 4b 10 	movl   $0xf0104b09,0x8(%esp)
f0100737:	f0 
f0100738:	c7 44 24 04 27 4b 10 	movl   $0xf0104b27,0x4(%esp)
f010073f:	f0 
f0100740:	c7 04 24 2c 4b 10 f0 	movl   $0xf0104b2c,(%esp)
f0100747:	e8 2e 2b 00 00       	call   f010327a <cprintf>
f010074c:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0100753:	f0 
f0100754:	c7 44 24 04 35 4b 10 	movl   $0xf0104b35,0x4(%esp)
f010075b:	f0 
f010075c:	c7 04 24 2c 4b 10 f0 	movl   $0xf0104b2c,(%esp)
f0100763:	e8 12 2b 00 00       	call   f010327a <cprintf>
	return 0;
}
f0100768:	b8 00 00 00 00       	mov    $0x0,%eax
f010076d:	c9                   	leave  
f010076e:	c3                   	ret    

f010076f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076f:	55                   	push   %ebp
f0100770:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100772:	b8 00 00 00 00       	mov    $0x0,%eax
f0100777:	5d                   	pop    %ebp
f0100778:	c3                   	ret    

f0100779 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	57                   	push   %edi
f010077d:	56                   	push   %esi
f010077e:	53                   	push   %ebx
f010077f:	83 ec 5c             	sub    $0x5c,%esp
f0100782:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100785:	c7 04 24 88 4c 10 f0 	movl   $0xf0104c88,(%esp)
f010078c:	e8 e9 2a 00 00       	call   f010327a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100791:	c7 04 24 ac 4c 10 f0 	movl   $0xf0104cac,(%esp)
f0100798:	e8 dd 2a 00 00       	call   f010327a <cprintf>

	if (tf != NULL)
f010079d:	85 ff                	test   %edi,%edi
f010079f:	74 08                	je     f01007a9 <monitor+0x30>
		print_trapframe(tf);
f01007a1:	89 3c 24             	mov    %edi,(%esp)
f01007a4:	e8 f9 2b 00 00       	call   f01033a2 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01007a9:	c7 04 24 3e 4b 10 f0 	movl   $0xf0104b3e,(%esp)
f01007b0:	e8 9b 38 00 00       	call   f0104050 <readline>
f01007b5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007b7:	85 c0                	test   %eax,%eax
f01007b9:	74 ee                	je     f01007a9 <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007bb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007c2:	be 00 00 00 00       	mov    $0x0,%esi
f01007c7:	eb 06                	jmp    f01007cf <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007c9:	c6 03 00             	movb   $0x0,(%ebx)
f01007cc:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007cf:	0f b6 03             	movzbl (%ebx),%eax
f01007d2:	84 c0                	test   %al,%al
f01007d4:	74 6a                	je     f0100840 <monitor+0xc7>
f01007d6:	0f be c0             	movsbl %al,%eax
f01007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007dd:	c7 04 24 42 4b 10 f0 	movl   $0xf0104b42,(%esp)
f01007e4:	e8 dc 3a 00 00       	call   f01042c5 <strchr>
f01007e9:	85 c0                	test   %eax,%eax
f01007eb:	75 dc                	jne    f01007c9 <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f01007ed:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007f0:	74 4e                	je     f0100840 <monitor+0xc7>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007f2:	83 fe 0f             	cmp    $0xf,%esi
f01007f5:	75 16                	jne    f010080d <monitor+0x94>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007f7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007fe:	00 
f01007ff:	c7 04 24 47 4b 10 f0 	movl   $0xf0104b47,(%esp)
f0100806:	e8 6f 2a 00 00       	call   f010327a <cprintf>
f010080b:	eb 9c                	jmp    f01007a9 <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f010080d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100811:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100814:	0f b6 03             	movzbl (%ebx),%eax
f0100817:	84 c0                	test   %al,%al
f0100819:	75 0c                	jne    f0100827 <monitor+0xae>
f010081b:	eb b2                	jmp    f01007cf <monitor+0x56>
			buf++;
f010081d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100820:	0f b6 03             	movzbl (%ebx),%eax
f0100823:	84 c0                	test   %al,%al
f0100825:	74 a8                	je     f01007cf <monitor+0x56>
f0100827:	0f be c0             	movsbl %al,%eax
f010082a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082e:	c7 04 24 42 4b 10 f0 	movl   $0xf0104b42,(%esp)
f0100835:	e8 8b 3a 00 00       	call   f01042c5 <strchr>
f010083a:	85 c0                	test   %eax,%eax
f010083c:	74 df                	je     f010081d <monitor+0xa4>
f010083e:	eb 8f                	jmp    f01007cf <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100840:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100847:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100848:	85 f6                	test   %esi,%esi
f010084a:	0f 84 59 ff ff ff    	je     f01007a9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100850:	c7 44 24 04 27 4b 10 	movl   $0xf0104b27,0x4(%esp)
f0100857:	f0 
f0100858:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010085b:	89 04 24             	mov    %eax,(%esp)
f010085e:	e8 de 39 00 00       	call   f0104241 <strcmp>
f0100863:	85 c0                	test   %eax,%eax
f0100865:	74 1b                	je     f0100882 <monitor+0x109>
f0100867:	c7 44 24 04 35 4b 10 	movl   $0xf0104b35,0x4(%esp)
f010086e:	f0 
f010086f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100872:	89 04 24             	mov    %eax,(%esp)
f0100875:	e8 c7 39 00 00       	call   f0104241 <strcmp>
f010087a:	85 c0                	test   %eax,%eax
f010087c:	75 2c                	jne    f01008aa <monitor+0x131>
f010087e:	b0 01                	mov    $0x1,%al
f0100880:	eb 05                	jmp    f0100887 <monitor+0x10e>
f0100882:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100887:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010088a:	01 d0                	add    %edx,%eax
f010088c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100890:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100893:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100897:	89 34 24             	mov    %esi,(%esp)
f010089a:	ff 14 85 dc 4c 10 f0 	call   *-0xfefb324(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008a1:	85 c0                	test   %eax,%eax
f01008a3:	78 1d                	js     f01008c2 <monitor+0x149>
f01008a5:	e9 ff fe ff ff       	jmp    f01007a9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008aa:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b1:	c7 04 24 64 4b 10 f0 	movl   $0xf0104b64,(%esp)
f01008b8:	e8 bd 29 00 00       	call   f010327a <cprintf>
f01008bd:	e9 e7 fe ff ff       	jmp    f01007a9 <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008c2:	83 c4 5c             	add    $0x5c,%esp
f01008c5:	5b                   	pop    %ebx
f01008c6:	5e                   	pop    %esi
f01008c7:	5f                   	pop    %edi
f01008c8:	5d                   	pop    %ebp
f01008c9:	c3                   	ret    
f01008ca:	00 00                	add    %al,(%eax)
f01008cc:	00 00                	add    %al,(%eax)
	...

f01008d0 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008d0:	89 d1                	mov    %edx,%ecx
f01008d2:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01008d5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01008d8:	a8 01                	test   $0x1,%al
f01008da:	74 5d                	je     f0100939 <check_va2pa+0x69>
	{
		return ~0;
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008e1:	89 c1                	mov    %eax,%ecx
f01008e3:	c1 e9 0c             	shr    $0xc,%ecx
f01008e6:	3b 0d 24 cc 17 f0    	cmp    0xf017cc24,%ecx
f01008ec:	72 26                	jb     f0100914 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008ee:	55                   	push   %ebp
f01008ef:	89 e5                	mov    %esp,%ebp
f01008f1:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008f8:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f01008ff:	f0 
f0100900:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0100907:	00 
f0100908:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010090f:	e8 aa f7 ff ff       	call   f01000be <_panic>
	if (!(*pgdir & PTE_P))
	{
		return ~0;
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100914:	c1 ea 0c             	shr    $0xc,%edx
f0100917:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010091d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100924:	89 c2                	mov    %eax,%edx
f0100926:	83 e2 01             	and    $0x1,%edx
 //   cprintf("check_va2pa:2\n");
		return ~0;
}

	//cprintf("check_va2pa:3   : %08x\n", PTE_ADDR(p[PTX(va)]));
	return PTE_ADDR(p[PTX(va)]);
f0100929:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010092e:	85 d2                	test   %edx,%edx
f0100930:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100935:	0f 44 c2             	cmove  %edx,%eax
f0100938:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
	{
		return ~0;
f0100939:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return ~0;
}

	//cprintf("check_va2pa:3   : %08x\n", PTE_ADDR(p[PTX(va)]));
	return PTE_ADDR(p[PTX(va)]);
}
f010093e:	c3                   	ret    

f010093f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010093f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100941:	83 3d 7c bf 17 f0 00 	cmpl   $0x0,0xf017bf7c
f0100948:	75 1e                	jne    f0100968 <boot_alloc+0x29>
		extern char end[];
		page_num = 0;
f010094a:	c7 05 80 bf 17 f0 00 	movl   $0x0,0xf017bf80
f0100951:	00 00 00 
    //round up to the nearest multiple of PGSIZE
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100954:	b8 2f dc 17 f0       	mov    $0xf017dc2f,%eax
f0100959:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010095e:	a3 7c bf 17 f0       	mov    %eax,0xf017bf7c
    initial_nextfree = nextfree;
f0100963:	a3 84 bf 17 f0       	mov    %eax,0xf017bf84
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
  if( n == 0 )
f0100968:	85 d2                	test   %edx,%edx
f010096a:	75 2d                	jne    f0100999 <boot_alloc+0x5a>
  {
		result = nextfree;
f010096c:	a1 7c bf 17 f0       	mov    0xf017bf7c,%eax
f0100971:	c3                   	ret    
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100972:	55                   	push   %ebp
f0100973:	89 e5                	mov    %esp,%ebp
f0100975:	83 ec 18             	sub    $0x18,%esp
    nextfree += n;
	  nextfree = ROUNDUP( nextfree, PGSIZE);	
    page_num = ((nextfree - initial_nextfree) / PGSIZE );
    if( page_num > npages )
    {
			nextfree = result;
f0100978:	a3 7c bf 17 f0       	mov    %eax,0xf017bf7c
		  panic("boot_alloc: out of memory");
f010097d:	c7 44 24 08 49 54 10 	movl   $0xf0105449,0x8(%esp)
f0100984:	f0 
f0100985:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f010098c:	00 
f010098d:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100994:	e8 25 f7 ff ff       	call   f01000be <_panic>
		result = nextfree;
  }
  if( n > 0 )
  {
		//check if it is out of memory
    result = nextfree;
f0100999:	a1 7c bf 17 f0       	mov    0xf017bf7c,%eax
    nextfree += n;
	  nextfree = ROUNDUP( nextfree, PGSIZE);	
f010099e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01009a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009ab:	89 15 7c bf 17 f0    	mov    %edx,0xf017bf7c
    page_num = ((nextfree - initial_nextfree) / PGSIZE );
f01009b1:	2b 15 84 bf 17 f0    	sub    0xf017bf84,%edx
f01009b7:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
f01009bd:	85 d2                	test   %edx,%edx
f01009bf:	0f 48 d1             	cmovs  %ecx,%edx
f01009c2:	c1 fa 0c             	sar    $0xc,%edx
f01009c5:	89 15 80 bf 17 f0    	mov    %edx,0xf017bf80
    if( page_num > npages )
f01009cb:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f01009d1:	77 9f                	ja     f0100972 <boot_alloc+0x33>
			nextfree = result;
		  panic("boot_alloc: out of memory");
		}
  }
	return result;
}
f01009d3:	f3 c3                	repz ret 

f01009d5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009d5:	55                   	push   %ebp
f01009d6:	89 e5                	mov    %esp,%ebp
f01009d8:	83 ec 18             	sub    $0x18,%esp
f01009db:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009de:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01009e1:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009e3:	89 04 24             	mov    %eax,(%esp)
f01009e6:	e8 1d 28 00 00       	call   f0103208 <mc146818_read>
f01009eb:	89 c6                	mov    %eax,%esi
f01009ed:	83 c3 01             	add    $0x1,%ebx
f01009f0:	89 1c 24             	mov    %ebx,(%esp)
f01009f3:	e8 10 28 00 00       	call   f0103208 <mc146818_read>
f01009f8:	c1 e0 08             	shl    $0x8,%eax
f01009fb:	09 f0                	or     %esi,%eax
}
f01009fd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a00:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a03:	89 ec                	mov    %ebp,%esp
f0100a05:	5d                   	pop    %ebp
f0100a06:	c3                   	ret    

f0100a07 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a07:	55                   	push   %ebp
f0100a08:	89 e5                	mov    %esp,%ebp
f0100a0a:	57                   	push   %edi
f0100a0b:	56                   	push   %esi
f0100a0c:	53                   	push   %ebx
f0100a0d:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a10:	84 c0                	test   %al,%al
f0100a12:	0f 85 39 03 00 00    	jne    f0100d51 <check_page_free_list+0x34a>
f0100a18:	e9 46 03 00 00       	jmp    f0100d63 <check_page_free_list+0x35c>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a1d:	c7 44 24 08 10 4d 10 	movl   $0xf0104d10,0x8(%esp)
f0100a24:	f0 
f0100a25:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100a2c:	00 
f0100a2d:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100a34:	e8 85 f6 ff ff       	call   f01000be <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a39:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a3f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a42:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a45:	89 c2                	mov    %eax,%edx
f0100a47:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a4d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a53:	0f 95 c2             	setne  %dl
f0100a56:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a59:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a5d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a5f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a63:	8b 00                	mov    (%eax),%eax
f0100a65:	85 c0                	test   %eax,%eax
f0100a67:	75 dc                	jne    f0100a45 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a75:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a78:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a7d:	a3 88 bf 17 f0       	mov    %eax,0xf017bf88
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a82:	89 c3                	mov    %eax,%ebx
f0100a84:	85 c0                	test   %eax,%eax
f0100a86:	74 6c                	je     f0100af4 <check_page_free_list+0xed>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a88:	be 01 00 00 00       	mov    $0x1,%esi
f0100a8d:	89 d8                	mov    %ebx,%eax
f0100a8f:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0100a95:	c1 f8 03             	sar    $0x3,%eax
f0100a98:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a9b:	89 c2                	mov    %eax,%edx
f0100a9d:	c1 ea 16             	shr    $0x16,%edx
f0100aa0:	39 f2                	cmp    %esi,%edx
f0100aa2:	73 4a                	jae    f0100aee <check_page_free_list+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aa4:	89 c2                	mov    %eax,%edx
f0100aa6:	c1 ea 0c             	shr    $0xc,%edx
f0100aa9:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0100aaf:	72 20                	jb     f0100ad1 <check_page_free_list+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ab1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ab5:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0100abc:	f0 
f0100abd:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ac4:	00 
f0100ac5:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0100acc:	e8 ed f5 ff ff       	call   f01000be <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ad1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ad8:	00 
f0100ad9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ae0:	00 
	return (void *)(pa + KERNBASE);
f0100ae1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ae6:	89 04 24             	mov    %eax,(%esp)
f0100ae9:	e8 37 38 00 00       	call   f0104325 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aee:	8b 1b                	mov    (%ebx),%ebx
f0100af0:	85 db                	test   %ebx,%ebx
f0100af2:	75 99                	jne    f0100a8d <check_page_free_list+0x86>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100af4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af9:	e8 41 fe ff ff       	call   f010093f <boot_alloc>
f0100afe:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b01:	8b 15 88 bf 17 f0    	mov    0xf017bf88,%edx
f0100b07:	85 d2                	test   %edx,%edx
f0100b09:	0f 84 f6 01 00 00    	je     f0100d05 <check_page_free_list+0x2fe>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0f:	8b 1d 2c cc 17 f0    	mov    0xf017cc2c,%ebx
f0100b15:	39 da                	cmp    %ebx,%edx
f0100b17:	72 4d                	jb     f0100b66 <check_page_free_list+0x15f>
		assert(pp < pages + npages);
f0100b19:	a1 24 cc 17 f0       	mov    0xf017cc24,%eax
f0100b1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100b21:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100b24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100b27:	39 c2                	cmp    %eax,%edx
f0100b29:	73 64                	jae    f0100b8f <check_page_free_list+0x188>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b2b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100b2e:	89 d0                	mov    %edx,%eax
f0100b30:	29 d8                	sub    %ebx,%eax
f0100b32:	a8 07                	test   $0x7,%al
f0100b34:	0f 85 82 00 00 00    	jne    f0100bbc <check_page_free_list+0x1b5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b3a:	c1 f8 03             	sar    $0x3,%eax
f0100b3d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b40:	85 c0                	test   %eax,%eax
f0100b42:	0f 84 a2 00 00 00    	je     f0100bea <check_page_free_list+0x1e3>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b48:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b4d:	0f 84 c2 00 00 00    	je     f0100c15 <check_page_free_list+0x20e>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b53:	be 00 00 00 00       	mov    $0x0,%esi
f0100b58:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b5d:	e9 d7 00 00 00       	jmp    f0100c39 <check_page_free_list+0x232>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b62:	39 da                	cmp    %ebx,%edx
f0100b64:	73 24                	jae    f0100b8a <check_page_free_list+0x183>
f0100b66:	c7 44 24 0c 71 54 10 	movl   $0xf0105471,0xc(%esp)
f0100b6d:	f0 
f0100b6e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100b75:	f0 
f0100b76:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100b7d:	00 
f0100b7e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100b85:	e8 34 f5 ff ff       	call   f01000be <_panic>
		assert(pp < pages + npages);
f0100b8a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b8d:	72 24                	jb     f0100bb3 <check_page_free_list+0x1ac>
f0100b8f:	c7 44 24 0c 92 54 10 	movl   $0xf0105492,0xc(%esp)
f0100b96:	f0 
f0100b97:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100b9e:	f0 
f0100b9f:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100ba6:	00 
f0100ba7:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100bae:	e8 0b f5 ff ff       	call   f01000be <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bb3:	89 d0                	mov    %edx,%eax
f0100bb5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bb8:	a8 07                	test   $0x7,%al
f0100bba:	74 24                	je     f0100be0 <check_page_free_list+0x1d9>
f0100bbc:	c7 44 24 0c 34 4d 10 	movl   $0xf0104d34,0xc(%esp)
f0100bc3:	f0 
f0100bc4:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100bcb:	f0 
f0100bcc:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f0100bd3:	00 
f0100bd4:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100bdb:	e8 de f4 ff ff       	call   f01000be <_panic>
f0100be0:	c1 f8 03             	sar    $0x3,%eax
f0100be3:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100be6:	85 c0                	test   %eax,%eax
f0100be8:	75 24                	jne    f0100c0e <check_page_free_list+0x207>
f0100bea:	c7 44 24 0c a6 54 10 	movl   $0xf01054a6,0xc(%esp)
f0100bf1:	f0 
f0100bf2:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100bf9:	f0 
f0100bfa:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f0100c01:	00 
f0100c02:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100c09:	e8 b0 f4 ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c0e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c13:	75 24                	jne    f0100c39 <check_page_free_list+0x232>
f0100c15:	c7 44 24 0c b7 54 10 	movl   $0xf01054b7,0xc(%esp)
f0100c1c:	f0 
f0100c1d:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100c24:	f0 
f0100c25:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f0100c2c:	00 
f0100c2d:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100c34:	e8 85 f4 ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c39:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c3e:	75 24                	jne    f0100c64 <check_page_free_list+0x25d>
f0100c40:	c7 44 24 0c 68 4d 10 	movl   $0xf0104d68,0xc(%esp)
f0100c47:	f0 
f0100c48:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100c4f:	f0 
f0100c50:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0100c57:	00 
f0100c58:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100c5f:	e8 5a f4 ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c64:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c69:	75 24                	jne    f0100c8f <check_page_free_list+0x288>
f0100c6b:	c7 44 24 0c d0 54 10 	movl   $0xf01054d0,0xc(%esp)
f0100c72:	f0 
f0100c73:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100c82:	00 
f0100c83:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100c8a:	e8 2f f4 ff ff       	call   f01000be <_panic>
f0100c8f:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c91:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c96:	76 57                	jbe    f0100cef <check_page_free_list+0x2e8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c98:	c1 e8 0c             	shr    $0xc,%eax
f0100c9b:	3b 45 cc             	cmp    -0x34(%ebp),%eax
f0100c9e:	72 20                	jb     f0100cc0 <check_page_free_list+0x2b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ca4:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0100cab:	f0 
f0100cac:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100cb3:	00 
f0100cb4:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0100cbb:	e8 fe f3 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0100cc0:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100cc6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100cc9:	76 29                	jbe    f0100cf4 <check_page_free_list+0x2ed>
f0100ccb:	c7 44 24 0c 8c 4d 10 	movl   $0xf0104d8c,0xc(%esp)
f0100cd2:	f0 
f0100cd3:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100cda:	f0 
f0100cdb:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100ce2:	00 
f0100ce3:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100cea:	e8 cf f3 ff ff       	call   f01000be <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cef:	83 c7 01             	add    $0x1,%edi
f0100cf2:	eb 03                	jmp    f0100cf7 <check_page_free_list+0x2f0>
		else
			++nfree_extmem;
f0100cf4:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf7:	8b 12                	mov    (%edx),%edx
f0100cf9:	85 d2                	test   %edx,%edx
f0100cfb:	0f 85 61 fe ff ff    	jne    f0100b62 <check_page_free_list+0x15b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d01:	85 ff                	test   %edi,%edi
f0100d03:	7f 24                	jg     f0100d29 <check_page_free_list+0x322>
f0100d05:	c7 44 24 0c ea 54 10 	movl   $0xf01054ea,0xc(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100d14:	f0 
f0100d15:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f0100d1c:	00 
f0100d1d:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100d24:	e8 95 f3 ff ff       	call   f01000be <_panic>
	assert(nfree_extmem > 0);
f0100d29:	85 f6                	test   %esi,%esi
f0100d2b:	7f 53                	jg     f0100d80 <check_page_free_list+0x379>
f0100d2d:	c7 44 24 0c fc 54 10 	movl   $0xf01054fc,0xc(%esp)
f0100d34:	f0 
f0100d35:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0100d3c:	f0 
f0100d3d:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f0100d44:	00 
f0100d45:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100d4c:	e8 6d f3 ff ff       	call   f01000be <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d51:	a1 88 bf 17 f0       	mov    0xf017bf88,%eax
f0100d56:	85 c0                	test   %eax,%eax
f0100d58:	0f 85 db fc ff ff    	jne    f0100a39 <check_page_free_list+0x32>
f0100d5e:	e9 ba fc ff ff       	jmp    f0100a1d <check_page_free_list+0x16>
f0100d63:	83 3d 88 bf 17 f0 00 	cmpl   $0x0,0xf017bf88
f0100d6a:	0f 84 ad fc ff ff    	je     f0100a1d <check_page_free_list+0x16>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d70:	8b 1d 88 bf 17 f0    	mov    0xf017bf88,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d76:	be 00 04 00 00       	mov    $0x400,%esi
f0100d7b:	e9 0d fd ff ff       	jmp    f0100a8d <check_page_free_list+0x86>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d80:	83 c4 3c             	add    $0x3c,%esp
f0100d83:	5b                   	pop    %ebx
f0100d84:	5e                   	pop    %esi
f0100d85:	5f                   	pop    %edi
f0100d86:	5d                   	pop    %ebp
f0100d87:	c3                   	ret    

f0100d88 <page_init>:
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100d88:	83 3d 24 cc 17 f0 00 	cmpl   $0x0,0xf017cc24
f0100d8f:	0f 84 9a 00 00 00    	je     f0100e2f <page_init+0xa7>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d95:	55                   	push   %ebp
f0100d96:	89 e5                	mov    %esp,%ebp
f0100d98:	57                   	push   %edi
f0100d99:	56                   	push   %esi
f0100d9a:	53                   	push   %ebx
f0100d9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  {
    if( i == 0 )
f0100da3:	85 db                	test   %ebx,%ebx
f0100da5:	75 13                	jne    f0100dba <page_init+0x32>
		{
			pages[i].pp_ref = 1;
f0100da7:	a1 2c cc 17 f0       	mov    0xf017cc2c,%eax
f0100dac:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
      pages[i].pp_link = NULL;
f0100db2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			continue;
f0100db8:	eb 5f                	jmp    f0100e19 <page_init+0x91>
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f0100dba:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc1:	89 f7                	mov    %esi,%edi
f0100dc3:	c1 e7 09             	shl    $0x9,%edi
			pages[i].pp_ref = 1;
      pages[i].pp_link = NULL;
			continue;
		}
    physaddr_t temp_physaddr = page2pa(&pages[i]);
    uintptr_t temp_boot_alloc = (uintptr_t)boot_alloc(0);
f0100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dcb:	e8 6f fb ff ff       	call   f010093f <boot_alloc>
    //because this is physical address.
    physaddr_t temp_addr = (physaddr_t)(temp_boot_alloc - KERNBASE);
    if( (temp_physaddr >0 && temp_physaddr < IOPHYSMEM) || temp_physaddr >= temp_addr )
f0100dd0:	8d 57 ff             	lea    -0x1(%edi),%edx
f0100dd3:	81 fa fe ff 09 00    	cmp    $0x9fffe,%edx
f0100dd9:	76 09                	jbe    f0100de4 <page_init+0x5c>
			continue;
		}
    physaddr_t temp_physaddr = page2pa(&pages[i]);
    uintptr_t temp_boot_alloc = (uintptr_t)boot_alloc(0);
    //because this is physical address.
    physaddr_t temp_addr = (physaddr_t)(temp_boot_alloc - KERNBASE);
f0100ddb:	05 00 00 00 10       	add    $0x10000000,%eax
    if( (temp_physaddr >0 && temp_physaddr < IOPHYSMEM) || temp_physaddr >= temp_addr )
f0100de0:	39 f8                	cmp    %edi,%eax
f0100de2:	77 23                	ja     f0100e07 <page_init+0x7f>
		{
		pages[i].pp_ref = 0;
f0100de4:	a1 2c cc 17 f0       	mov    0xf017cc2c,%eax
f0100de9:	01 f0                	add    %esi,%eax
f0100deb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f0100df1:	8b 15 88 bf 17 f0    	mov    0xf017bf88,%edx
f0100df7:	89 10                	mov    %edx,(%eax)
		page_free_list = &pages[i];
f0100df9:	03 35 2c cc 17 f0    	add    0xf017cc2c,%esi
f0100dff:	89 35 88 bf 17 f0    	mov    %esi,0xf017bf88
f0100e05:	eb 12                	jmp    f0100e19 <page_init+0x91>
		}
		else
		{
			pages[i].pp_ref = 1;
f0100e07:	03 35 2c cc 17 f0    	add    0xf017cc2c,%esi
f0100e0d:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f0100e13:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100e19:	83 c3 01             	add    $0x1,%ebx
f0100e1c:	39 1d 24 cc 17 f0    	cmp    %ebx,0xf017cc24
f0100e22:	0f 87 7b ff ff ff    	ja     f0100da3 <page_init+0x1b>
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	}
}
f0100e28:	83 c4 0c             	add    $0xc,%esp
f0100e2b:	5b                   	pop    %ebx
f0100e2c:	5e                   	pop    %esi
f0100e2d:	5f                   	pop    %edi
f0100e2e:	5d                   	pop    %ebp
f0100e2f:	f3 c3                	repz ret 

f0100e31 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e31:	55                   	push   %ebp
f0100e32:	89 e5                	mov    %esp,%ebp
f0100e34:	53                   	push   %ebx
f0100e35:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
  struct PageInfo* temp;
	//returns NULL if there is no free memory
	if( page_free_list == NULL) 
f0100e38:	8b 1d 88 bf 17 f0    	mov    0xf017bf88,%ebx
f0100e3e:	85 db                	test   %ebx,%ebx
f0100e40:	74 71                	je     f0100eb3 <page_alloc+0x82>
		return NULL;
  else
	{
		temp = page_free_list;
    page_free_list = temp->pp_link;
f0100e42:	8b 03                	mov    (%ebx),%eax
f0100e44:	a3 88 bf 17 f0       	mov    %eax,0xf017bf88
    temp->pp_link = NULL;
f0100e49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    temp->pp_ref = 0;
f0100e4f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	}
  if(alloc_flags & ALLOC_ZERO)
f0100e55:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e59:	74 58                	je     f0100eb3 <page_alloc+0x82>
f0100e5b:	89 d8                	mov    %ebx,%eax
f0100e5d:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0100e63:	c1 f8 03             	sar    $0x3,%eax
f0100e66:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e69:	89 c2                	mov    %eax,%edx
f0100e6b:	c1 ea 0c             	shr    $0xc,%edx
f0100e6e:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0100e74:	72 20                	jb     f0100e96 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e76:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7a:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0100e81:	f0 
f0100e82:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e89:	00 
f0100e8a:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0100e91:	e8 28 f2 ff ff       	call   f01000be <_panic>
	{
		//do not use page2pa but page2kva
		memset(page2kva(temp), '\0', PGSIZE);
f0100e96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e9d:	00 
f0100e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea5:	00 
	return (void *)(pa + KERNBASE);
f0100ea6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eab:	89 04 24             	mov    %eax,(%esp)
f0100eae:	e8 72 34 00 00       	call   f0104325 <memset>
	}
	return temp;
}
f0100eb3:	89 d8                	mov    %ebx,%eax
f0100eb5:	83 c4 14             	add    $0x14,%esp
f0100eb8:	5b                   	pop    %ebx
f0100eb9:	5d                   	pop    %ebp
f0100eba:	c3                   	ret    

f0100ebb <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ebb:	55                   	push   %ebp
f0100ebc:	89 e5                	mov    %esp,%ebp
f0100ebe:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
  if(pp->pp_ref <= 0)
f0100ec1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ec6:	75 0d                	jne    f0100ed5 <page_free+0x1a>
  {
  pp->pp_link =page_free_list;
f0100ec8:	8b 15 88 bf 17 f0    	mov    0xf017bf88,%edx
f0100ece:	89 10                	mov    %edx,(%eax)
  page_free_list = pp;
f0100ed0:	a3 88 bf 17 f0       	mov    %eax,0xf017bf88
  }
}
f0100ed5:	5d                   	pop    %ebp
f0100ed6:	c3                   	ret    

f0100ed7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ed7:	55                   	push   %ebp
f0100ed8:	89 e5                	mov    %esp,%ebp
f0100eda:	83 ec 04             	sub    $0x4,%esp
f0100edd:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100ee0:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100ee4:	83 ea 01             	sub    $0x1,%edx
f0100ee7:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100eeb:	66 85 d2             	test   %dx,%dx
f0100eee:	75 08                	jne    f0100ef8 <page_decref+0x21>
		page_free(pp);
f0100ef0:	89 04 24             	mov    %eax,(%esp)
f0100ef3:	e8 c3 ff ff ff       	call   f0100ebb <page_free>
}
f0100ef8:	c9                   	leave  
f0100ef9:	c3                   	ret    

f0100efa <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100efa:	55                   	push   %ebp
f0100efb:	89 e5                	mov    %esp,%ebp
f0100efd:	56                   	push   %esi
f0100efe:	53                   	push   %ebx
f0100eff:	83 ec 10             	sub    $0x10,%esp
f0100f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
  pde_t* page_dir_entry = pgdir + PDX(va);
f0100f05:	89 de                	mov    %ebx,%esi
f0100f07:	c1 ee 16             	shr    $0x16,%esi
f0100f0a:	c1 e6 02             	shl    $0x2,%esi
f0100f0d:	03 75 08             	add    0x8(%ebp),%esi
  pte_t* page_table = (pte_t*)PTE_ADDR(*page_dir_entry);
  if( page_table== NULL)
f0100f10:	8b 16                	mov    (%esi),%edx
f0100f12:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f18:	75 7c                	jne    f0100f96 <pgdir_walk+0x9c>
  {
    //the va's page table does not exist
		if(create)
f0100f1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f1e:	0f 84 b2 00 00 00    	je     f0100fd6 <pgdir_walk+0xdc>
		{
			struct PageInfo* temp = page_alloc(ALLOC_ZERO);
f0100f24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f2b:	e8 01 ff ff ff       	call   f0100e31 <page_alloc>
  		if(temp != NULL)
f0100f30:	85 c0                	test   %eax,%eax
f0100f32:	0f 84 a5 00 00 00    	je     f0100fdd <pgdir_walk+0xe3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f38:	89 c2                	mov    %eax,%edx
f0100f3a:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0100f40:	c1 fa 03             	sar    $0x3,%edx
f0100f43:	c1 e2 0c             	shl    $0xc,%edx
			{
				pgdir[PDX(va)] = page2pa(temp)|PTE_P|PTE_W;
f0100f46:	83 ca 03             	or     $0x3,%edx
f0100f49:	89 16                	mov    %edx,(%esi)
				temp->pp_ref ++;
f0100f4b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				page_table = (pte_t*)PTE_ADDR(pgdir[PDX(va)]);
f0100f50:	8b 06                	mov    (%esi),%eax
f0100f52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
f0100f57:	c1 eb 0a             	shr    $0xa,%ebx
f0100f5a:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f60:	01 d8                	add    %ebx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f62:	89 c2                	mov    %eax,%edx
f0100f64:	c1 ea 0c             	shr    $0xc,%edx
f0100f67:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0100f6d:	72 20                	jb     f0100f8f <pgdir_walk+0x95>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f73:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0100f7a:	f0 
f0100f7b:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0100f82:	00 
f0100f83:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100f8a:	e8 2f f1 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0100f8f:	2d 00 00 00 10       	sub    $0x10000000,%eax
       return addr;
f0100f94:	eb 4c                	jmp    f0100fe2 <pgdir_walk+0xe8>
			}
 			else return NULL;
		}
		else return NULL;
  }
  else return KADDR((uintptr_t)(page_table + PTX(va)));
f0100f96:	c1 eb 0a             	shr    $0xa,%ebx
f0100f99:	89 d8                	mov    %ebx,%eax
f0100f9b:	25 fc 0f 00 00       	and    $0xffc,%eax
f0100fa0:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa2:	89 c2                	mov    %eax,%edx
f0100fa4:	c1 ea 0c             	shr    $0xc,%edx
f0100fa7:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0100fad:	72 20                	jb     f0100fcf <pgdir_walk+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb3:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0100fba:	f0 
f0100fbb:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0100fc2:	00 
f0100fc3:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0100fca:	e8 ef f0 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0100fcf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fd4:	eb 0c                	jmp    f0100fe2 <pgdir_walk+0xe8>
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
       return addr;
			}
 			else return NULL;
		}
		else return NULL;
f0100fd6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdb:	eb 05                	jmp    f0100fe2 <pgdir_walk+0xe8>
				temp->pp_ref ++;
				page_table = (pte_t*)PTE_ADDR(pgdir[PDX(va)]);
				pte_t* addr = KADDR((uintptr_t)(page_table + PTX(va)));
       return addr;
			}
 			else return NULL;
f0100fdd:	b8 00 00 00 00       	mov    $0x0,%eax
		}
		else return NULL;
  }
  else return KADDR((uintptr_t)(page_table + PTX(va)));
}
f0100fe2:	83 c4 10             	add    $0x10,%esp
f0100fe5:	5b                   	pop    %ebx
f0100fe6:	5e                   	pop    %esi
f0100fe7:	5d                   	pop    %ebp
f0100fe8:	c3                   	ret    

f0100fe9 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fe9:	55                   	push   %ebp
f0100fea:	89 e5                	mov    %esp,%ebp
f0100fec:	57                   	push   %edi
f0100fed:	56                   	push   %esi
f0100fee:	53                   	push   %ebx
f0100fef:	83 ec 2c             	sub    $0x2c,%esp
f0100ff2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// Fill this function in
  	
	int i = 0;
	for(i = 0; i <size; i++)
f0100ff5:	85 c9                	test   %ecx,%ecx
f0100ff7:	74 51                	je     f010104a <boot_map_region+0x61>
f0100ff9:	89 c3                	mov    %eax,%ebx
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100ffb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
{
	// Fill this function in
  	
	int i = 0;
	for(i = 0; i <size; i++)
f0100ffe:	be 00 00 00 00       	mov    $0x0,%esi
f0101003:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	{
		pte_t* page_table_entry = pgdir_walk(pgdir, (void*)(va+i), 1);
	  pgdir[PDX(va+i)] |= perm|PTE_P;
f010100a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100d:	83 c8 01             	or     $0x1,%eax
f0101010:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Fill this function in
  	
	int i = 0;
	for(i = 0; i <size; i++)
	{
		pte_t* page_table_entry = pgdir_walk(pgdir, (void*)(va+i), 1);
f0101013:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101016:	01 f7                	add    %esi,%edi
f0101018:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010101f:	00 
f0101020:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101024:	89 1c 24             	mov    %ebx,(%esp)
f0101027:	e8 ce fe ff ff       	call   f0100efa <pgdir_walk>
	  pgdir[PDX(va+i)] |= perm|PTE_P;
f010102c:	c1 ef 16             	shr    $0x16,%edi
f010102f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101032:	09 14 bb             	or     %edx,(%ebx,%edi,4)
		*page_table_entry = (pa + i)|perm|PTE_P;	
f0101035:	03 75 08             	add    0x8(%ebp),%esi
f0101038:	09 d6                	or     %edx,%esi
f010103a:	89 30                	mov    %esi,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
  	
	int i = 0;
	for(i = 0; i <size; i++)
f010103c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f0101040:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101043:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101046:	39 c6                	cmp    %eax,%esi
f0101048:	75 c9                	jne    f0101013 <boot_map_region+0x2a>
		pte_t* page_table_entry = pgdir_walk(pgdir, (void*)(va+i), 1);
	  pgdir[PDX(va+i)] |= perm|PTE_P;
		*page_table_entry = (pa + i)|perm|PTE_P;	
	}
	
}
f010104a:	83 c4 2c             	add    $0x2c,%esp
f010104d:	5b                   	pop    %ebx
f010104e:	5e                   	pop    %esi
f010104f:	5f                   	pop    %edi
f0101050:	5d                   	pop    %ebp
f0101051:	c3                   	ret    

f0101052 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101052:	55                   	push   %ebp
f0101053:	89 e5                	mov    %esp,%ebp
f0101055:	53                   	push   %ebx
f0101056:	83 ec 14             	sub    $0x14,%esp
f0101059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// since it requires the page corresponding to 'va', it has no needs to use PGOFF(va) to get actual physical address.
	pte_t* page_entry_addr = pgdir_walk(pgdir, va, 0);
f010105c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101063:	00 
f0101064:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101067:	89 44 24 04          	mov    %eax,0x4(%esp)
f010106b:	8b 45 08             	mov    0x8(%ebp),%eax
f010106e:	89 04 24             	mov    %eax,(%esp)
f0101071:	e8 84 fe ff ff       	call   f0100efa <pgdir_walk>
f0101076:	89 c2                	mov    %eax,%edx
	if(page_entry_addr != NULL)
f0101078:	85 c0                	test   %eax,%eax
f010107a:	74 41                	je     f01010bd <page_lookup+0x6b>
{
	physaddr_t page_addr = PTE_ADDR(*(page_entry_addr));
  if(page_addr !=0)
f010107c:	8b 00                	mov    (%eax),%eax
f010107e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101083:	74 3f                	je     f01010c4 <page_lookup+0x72>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101085:	c1 e8 0c             	shr    $0xc,%eax
f0101088:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f010108e:	72 1c                	jb     f01010ac <page_lookup+0x5a>
		panic("pa2page called with invalid pa");
f0101090:	c7 44 24 08 d4 4d 10 	movl   $0xf0104dd4,0x8(%esp)
f0101097:	f0 
f0101098:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010109f:	00 
f01010a0:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f01010a7:	e8 12 f0 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f01010ac:	8b 0d 2c cc 17 f0    	mov    0xf017cc2c,%ecx
f01010b2:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
	{
		//page
	  struct PageInfo* temp = pa2page(page_addr);
	  if(pte_store != 0) *pte_store = page_entry_addr;
f01010b5:	85 db                	test   %ebx,%ebx
f01010b7:	74 10                	je     f01010c9 <page_lookup+0x77>
f01010b9:	89 13                	mov    %edx,(%ebx)
f01010bb:	eb 0c                	jmp    f01010c9 <page_lookup+0x77>
		return temp;	
	}	
}
	return NULL;
f01010bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c2:	eb 05                	jmp    f01010c9 <page_lookup+0x77>
f01010c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01010c9:	83 c4 14             	add    $0x14,%esp
f01010cc:	5b                   	pop    %ebx
f01010cd:	5d                   	pop    %ebp
f01010ce:	c3                   	ret    

f01010cf <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010cf:	55                   	push   %ebp
f01010d0:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010d5:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	
  invlpg(va);
}
f01010d8:	5d                   	pop    %ebp
f01010d9:	c3                   	ret    

f01010da <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010da:	55                   	push   %ebp
f01010db:	89 e5                	mov    %esp,%ebp
f01010dd:	83 ec 28             	sub    $0x28,%esp
f01010e0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01010e3:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01010e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* page_table_entry;
	struct PageInfo* temp = page_lookup(pgdir, va, &page_table_entry);
f01010ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010f7:	89 1c 24             	mov    %ebx,(%esp)
f01010fa:	e8 53 ff ff ff       	call   f0101052 <page_lookup>
	if(temp != NULL)
f01010ff:	85 c0                	test   %eax,%eax
f0101101:	74 1d                	je     f0101120 <page_remove+0x46>
	{
		page_decref(temp);
f0101103:	89 04 24             	mov    %eax,(%esp)
f0101106:	e8 cc fd ff ff       	call   f0100ed7 <page_decref>
		*page_table_entry = 0;
f010110b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010110e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);	
f0101114:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101118:	89 1c 24             	mov    %ebx,(%esp)
f010111b:	e8 af ff ff ff       	call   f01010cf <tlb_invalidate>
	}
}
f0101120:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101123:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101126:	89 ec                	mov    %ebp,%esp
f0101128:	5d                   	pop    %ebp
f0101129:	c3                   	ret    

f010112a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010112a:	55                   	push   %ebp
f010112b:	89 e5                	mov    %esp,%ebp
f010112d:	83 ec 28             	sub    $0x28,%esp
f0101130:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101133:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101136:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101139:	8b 75 08             	mov    0x8(%ebp),%esi
f010113c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
  pte_t* page_addr_temp = (pte_t*)PTE_ADDR(pgdir_walk(pgdir, va, 1));
f010113f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101146:	00 
f0101147:	8b 45 10             	mov    0x10(%ebp),%eax
f010114a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010114e:	89 34 24             	mov    %esi,(%esp)
f0101151:	e8 a4 fd ff ff       	call   f0100efa <pgdir_walk>
  if(page_addr_temp == NULL)
f0101156:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010115b:	74 6e                	je     f01011cb <page_insert+0xa1>
	{
		return -E_NO_MEM;
	}
	
	//check if the page has exists
  if(PTE_ADDR(*(page_addr_temp+PTX(va))) == page2pa(pp))
f010115d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101160:	c1 ef 0a             	shr    $0xa,%edi
f0101163:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0101169:	01 c7                	add    %eax,%edi
f010116b:	8b 07                	mov    (%edi),%eax
f010116d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101172:	89 da                	mov    %ebx,%edx
f0101174:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f010117a:	c1 fa 03             	sar    $0x3,%edx
f010117d:	c1 e2 0c             	shl    $0xc,%edx
f0101180:	39 d0                	cmp    %edx,%eax
f0101182:	75 07                	jne    f010118b <page_insert+0x61>
	{
		pp->pp_ref --;
f0101184:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101189:	eb 13                	jmp    f010119e <page_insert+0x74>
	}
  //check if there is other page
  else if(PTE_ADDR(*(page_addr_temp+PTX(va))) != 0)
f010118b:	85 c0                	test   %eax,%eax
f010118d:	74 0f                	je     f010119e <page_insert+0x74>
	{
		page_remove(pgdir,va);
f010118f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101192:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101196:	89 34 24             	mov    %esi,(%esp)
f0101199:	e8 3c ff ff ff       	call   f01010da <page_remove>
	}
  pgdir[PDX(va)] = pgdir[PDX(va)]|perm|PTE_P;
f010119e:	8b 55 10             	mov    0x10(%ebp),%edx
f01011a1:	c1 ea 16             	shr    $0x16,%edx
f01011a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a7:	83 c8 01             	or     $0x1,%eax
f01011aa:	09 04 96             	or     %eax,(%esi,%edx,4)
f01011ad:	89 da                	mov    %ebx,%edx
f01011af:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f01011b5:	c1 fa 03             	sar    $0x3,%edx
f01011b8:	c1 e2 0c             	shl    $0xc,%edx
  //why should continue offset!!!! 	
	*(page_addr_temp+PTX(va)) = page2pa(pp)|perm|PTE_P;
f01011bb:	09 d0                	or     %edx,%eax
f01011bd:	89 07                	mov    %eax,(%edi)
	pp->pp_ref++;
f01011bf:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01011c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c9:	eb 05                	jmp    f01011d0 <page_insert+0xa6>
{
	// Fill this function in
  pte_t* page_addr_temp = (pte_t*)PTE_ADDR(pgdir_walk(pgdir, va, 1));
  if(page_addr_temp == NULL)
	{
		return -E_NO_MEM;
f01011cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  pgdir[PDX(va)] = pgdir[PDX(va)]|perm|PTE_P;
  //why should continue offset!!!! 	
	*(page_addr_temp+PTX(va)) = page2pa(pp)|perm|PTE_P;
	pp->pp_ref++;
	return 0;
}
f01011d0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01011d3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01011d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01011d9:	89 ec                	mov    %ebp,%esp
f01011db:	5d                   	pop    %ebp
f01011dc:	c3                   	ret    

f01011dd <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011dd:	55                   	push   %ebp
f01011de:	89 e5                	mov    %esp,%ebp
f01011e0:	57                   	push   %edi
f01011e1:	56                   	push   %esi
f01011e2:	53                   	push   %ebx
f01011e3:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01011e6:	b8 15 00 00 00       	mov    $0x15,%eax
f01011eb:	e8 e5 f7 ff ff       	call   f01009d5 <nvram_read>
f01011f0:	c1 e0 0a             	shl    $0xa,%eax
f01011f3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011f9:	85 c0                	test   %eax,%eax
f01011fb:	0f 48 c2             	cmovs  %edx,%eax
f01011fe:	c1 f8 0c             	sar    $0xc,%eax
f0101201:	a3 78 bf 17 f0       	mov    %eax,0xf017bf78
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101206:	b8 17 00 00 00       	mov    $0x17,%eax
f010120b:	e8 c5 f7 ff ff       	call   f01009d5 <nvram_read>
f0101210:	c1 e0 0a             	shl    $0xa,%eax
f0101213:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101219:	85 c0                	test   %eax,%eax
f010121b:	0f 48 c2             	cmovs  %edx,%eax
f010121e:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101221:	85 c0                	test   %eax,%eax
f0101223:	74 0e                	je     f0101233 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101225:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010122b:	89 15 24 cc 17 f0    	mov    %edx,0xf017cc24
f0101231:	eb 0c                	jmp    f010123f <mem_init+0x62>
	else
		npages = npages_basemem;
f0101233:	8b 15 78 bf 17 f0    	mov    0xf017bf78,%edx
f0101239:	89 15 24 cc 17 f0    	mov    %edx,0xf017cc24

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010123f:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101242:	c1 e8 0a             	shr    $0xa,%eax
f0101245:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101249:	a1 78 bf 17 f0       	mov    0xf017bf78,%eax
f010124e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101251:	c1 e8 0a             	shr    $0xa,%eax
f0101254:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101258:	a1 24 cc 17 f0       	mov    0xf017cc24,%eax
f010125d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101260:	c1 e8 0a             	shr    $0xa,%eax
f0101263:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101267:	c7 04 24 f4 4d 10 f0 	movl   $0xf0104df4,(%esp)
f010126e:	e8 07 20 00 00       	call   f010327a <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101273:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101278:	e8 c2 f6 ff ff       	call   f010093f <boot_alloc>
f010127d:	a3 28 cc 17 f0       	mov    %eax,0xf017cc28
	memset(kern_pgdir, 0, PGSIZE);
f0101282:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101289:	00 
f010128a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101291:	00 
f0101292:	89 04 24             	mov    %eax,(%esp)
f0101295:	e8 8b 30 00 00       	call   f0104325 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010129a:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010129f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012a4:	77 20                	ja     f01012c6 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012aa:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f01012b1:	f0 
f01012b2:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f01012b9:	00 
f01012ba:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01012c1:	e8 f8 ed ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012c6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012cc:	83 ca 05             	or     $0x5,%edx
f01012cf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
  pages = (struct PageInfo*)boot_alloc( npages * sizeof(struct PageInfo));
f01012d5:	a1 24 cc 17 f0       	mov    0xf017cc24,%eax
f01012da:	c1 e0 03             	shl    $0x3,%eax
f01012dd:	e8 5d f6 ff ff       	call   f010093f <boot_alloc>
f01012e2:	a3 2c cc 17 f0       	mov    %eax,0xf017cc2c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01012e7:	e8 9c fa ff ff       	call   f0100d88 <page_init>
	check_page_free_list(1);
f01012ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01012f1:	e8 11 f7 ff ff       	call   f0100a07 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012f6:	83 3d 2c cc 17 f0 00 	cmpl   $0x0,0xf017cc2c
f01012fd:	75 1c                	jne    f010131b <mem_init+0x13e>
		panic("'pages' is a null pointer!");
f01012ff:	c7 44 24 08 0d 55 10 	movl   $0xf010550d,0x8(%esp)
f0101306:	f0 
f0101307:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f010130e:	00 
f010130f:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101316:	e8 a3 ed ff ff       	call   f01000be <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010131b:	a1 88 bf 17 f0       	mov    0xf017bf88,%eax
f0101320:	85 c0                	test   %eax,%eax
f0101322:	74 10                	je     f0101334 <mem_init+0x157>
f0101324:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101329:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010132c:	8b 00                	mov    (%eax),%eax
f010132e:	85 c0                	test   %eax,%eax
f0101330:	75 f7                	jne    f0101329 <mem_init+0x14c>
f0101332:	eb 05                	jmp    f0101339 <mem_init+0x15c>
f0101334:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101340:	e8 ec fa ff ff       	call   f0100e31 <page_alloc>
f0101345:	89 c7                	mov    %eax,%edi
f0101347:	85 c0                	test   %eax,%eax
f0101349:	75 24                	jne    f010136f <mem_init+0x192>
f010134b:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0101352:	f0 
f0101353:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010135a:	f0 
f010135b:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101362:	00 
f0101363:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010136a:	e8 4f ed ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f010136f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101376:	e8 b6 fa ff ff       	call   f0100e31 <page_alloc>
f010137b:	89 c6                	mov    %eax,%esi
f010137d:	85 c0                	test   %eax,%eax
f010137f:	75 24                	jne    f01013a5 <mem_init+0x1c8>
f0101381:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f0101388:	f0 
f0101389:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101390:	f0 
f0101391:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101398:	00 
f0101399:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01013a0:	e8 19 ed ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f01013a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013ac:	e8 80 fa ff ff       	call   f0100e31 <page_alloc>
f01013b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013b4:	85 c0                	test   %eax,%eax
f01013b6:	75 24                	jne    f01013dc <mem_init+0x1ff>
f01013b8:	c7 44 24 0c 54 55 10 	movl   $0xf0105554,0xc(%esp)
f01013bf:	f0 
f01013c0:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01013c7:	f0 
f01013c8:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01013cf:	00 
f01013d0:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01013d7:	e8 e2 ec ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013dc:	39 f7                	cmp    %esi,%edi
f01013de:	75 24                	jne    f0101404 <mem_init+0x227>
f01013e0:	c7 44 24 0c 6a 55 10 	movl   $0xf010556a,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01013ff:	e8 ba ec ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101404:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101407:	74 05                	je     f010140e <mem_init+0x231>
f0101409:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010140c:	75 24                	jne    f0101432 <mem_init+0x255>
f010140e:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f0101415:	f0 
f0101416:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010141d:	f0 
f010141e:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f0101425:	00 
f0101426:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010142d:	e8 8c ec ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101432:	8b 15 2c cc 17 f0    	mov    0xf017cc2c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101438:	a1 24 cc 17 f0       	mov    0xf017cc24,%eax
f010143d:	c1 e0 0c             	shl    $0xc,%eax
f0101440:	89 f9                	mov    %edi,%ecx
f0101442:	29 d1                	sub    %edx,%ecx
f0101444:	c1 f9 03             	sar    $0x3,%ecx
f0101447:	c1 e1 0c             	shl    $0xc,%ecx
f010144a:	39 c1                	cmp    %eax,%ecx
f010144c:	72 24                	jb     f0101472 <mem_init+0x295>
f010144e:	c7 44 24 0c 7c 55 10 	movl   $0xf010557c,0xc(%esp)
f0101455:	f0 
f0101456:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010145d:	f0 
f010145e:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f0101465:	00 
f0101466:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010146d:	e8 4c ec ff ff       	call   f01000be <_panic>
f0101472:	89 f1                	mov    %esi,%ecx
f0101474:	29 d1                	sub    %edx,%ecx
f0101476:	c1 f9 03             	sar    $0x3,%ecx
f0101479:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010147c:	39 c8                	cmp    %ecx,%eax
f010147e:	77 24                	ja     f01014a4 <mem_init+0x2c7>
f0101480:	c7 44 24 0c 99 55 10 	movl   $0xf0105599,0xc(%esp)
f0101487:	f0 
f0101488:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010148f:	f0 
f0101490:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f0101497:	00 
f0101498:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010149f:	e8 1a ec ff ff       	call   f01000be <_panic>
f01014a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01014a7:	29 d1                	sub    %edx,%ecx
f01014a9:	89 ca                	mov    %ecx,%edx
f01014ab:	c1 fa 03             	sar    $0x3,%edx
f01014ae:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01014b1:	39 d0                	cmp    %edx,%eax
f01014b3:	77 24                	ja     f01014d9 <mem_init+0x2fc>
f01014b5:	c7 44 24 0c b6 55 10 	movl   $0xf01055b6,0xc(%esp)
f01014bc:	f0 
f01014bd:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01014c4:	f0 
f01014c5:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f01014cc:	00 
f01014cd:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01014d4:	e8 e5 eb ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014d9:	a1 88 bf 17 f0       	mov    0xf017bf88,%eax
f01014de:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014e1:	c7 05 88 bf 17 f0 00 	movl   $0x0,0xf017bf88
f01014e8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f2:	e8 3a f9 ff ff       	call   f0100e31 <page_alloc>
f01014f7:	85 c0                	test   %eax,%eax
f01014f9:	74 24                	je     f010151f <mem_init+0x342>
f01014fb:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f0101502:	f0 
f0101503:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010150a:	f0 
f010150b:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101512:	00 
f0101513:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010151a:	e8 9f eb ff ff       	call   f01000be <_panic>

	// free and re-allocate?
	page_free(pp0);
f010151f:	89 3c 24             	mov    %edi,(%esp)
f0101522:	e8 94 f9 ff ff       	call   f0100ebb <page_free>
	page_free(pp1);
f0101527:	89 34 24             	mov    %esi,(%esp)
f010152a:	e8 8c f9 ff ff       	call   f0100ebb <page_free>
	page_free(pp2);
f010152f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101532:	89 04 24             	mov    %eax,(%esp)
f0101535:	e8 81 f9 ff ff       	call   f0100ebb <page_free>
  pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010153a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101541:	e8 eb f8 ff ff       	call   f0100e31 <page_alloc>
f0101546:	89 c6                	mov    %eax,%esi
f0101548:	85 c0                	test   %eax,%eax
f010154a:	75 24                	jne    f0101570 <mem_init+0x393>
f010154c:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0101553:	f0 
f0101554:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010155b:	f0 
f010155c:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101563:	00 
f0101564:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010156b:	e8 4e eb ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101577:	e8 b5 f8 ff ff       	call   f0100e31 <page_alloc>
f010157c:	89 c7                	mov    %eax,%edi
f010157e:	85 c0                	test   %eax,%eax
f0101580:	75 24                	jne    f01015a6 <mem_init+0x3c9>
f0101582:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f0101589:	f0 
f010158a:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101591:	f0 
f0101592:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0101599:	00 
f010159a:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01015a1:	e8 18 eb ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f01015a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ad:	e8 7f f8 ff ff       	call   f0100e31 <page_alloc>
f01015b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	75 24                	jne    f01015dd <mem_init+0x400>
f01015b9:	c7 44 24 0c 54 55 10 	movl   $0xf0105554,0xc(%esp)
f01015c0:	f0 
f01015c1:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01015c8:	f0 
f01015c9:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01015d0:	00 
f01015d1:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01015d8:	e8 e1 ea ff ff       	call   f01000be <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015dd:	39 fe                	cmp    %edi,%esi
f01015df:	75 24                	jne    f0101605 <mem_init+0x428>
f01015e1:	c7 44 24 0c 6a 55 10 	movl   $0xf010556a,0xc(%esp)
f01015e8:	f0 
f01015e9:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01015f0:	f0 
f01015f1:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f01015f8:	00 
f01015f9:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101600:	e8 b9 ea ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101605:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101608:	74 05                	je     f010160f <mem_init+0x432>
f010160a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010160d:	75 24                	jne    f0101633 <mem_init+0x456>
f010160f:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f0101616:	f0 
f0101617:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010161e:	f0 
f010161f:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0101626:	00 
f0101627:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010162e:	e8 8b ea ff ff       	call   f01000be <_panic>
	assert(!page_alloc(0));
f0101633:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010163a:	e8 f2 f7 ff ff       	call   f0100e31 <page_alloc>
f010163f:	85 c0                	test   %eax,%eax
f0101641:	74 24                	je     f0101667 <mem_init+0x48a>
f0101643:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f010164a:	f0 
f010164b:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101652:	f0 
f0101653:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f010165a:	00 
f010165b:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101662:	e8 57 ea ff ff       	call   f01000be <_panic>
f0101667:	89 f0                	mov    %esi,%eax
f0101669:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f010166f:	c1 f8 03             	sar    $0x3,%eax
f0101672:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101675:	89 c2                	mov    %eax,%edx
f0101677:	c1 ea 0c             	shr    $0xc,%edx
f010167a:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0101680:	72 20                	jb     f01016a2 <mem_init+0x4c5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101682:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101686:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f010168d:	f0 
f010168e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101695:	00 
f0101696:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f010169d:	e8 1c ea ff ff       	call   f01000be <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01016a9:	00 
f01016aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01016b1:	00 
	return (void *)(pa + KERNBASE);
f01016b2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016b7:	89 04 24             	mov    %eax,(%esp)
f01016ba:	e8 66 2c 00 00       	call   f0104325 <memset>
	page_free(pp0);
f01016bf:	89 34 24             	mov    %esi,(%esp)
f01016c2:	e8 f4 f7 ff ff       	call   f0100ebb <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016ce:	e8 5e f7 ff ff       	call   f0100e31 <page_alloc>
f01016d3:	85 c0                	test   %eax,%eax
f01016d5:	75 24                	jne    f01016fb <mem_init+0x51e>
f01016d7:	c7 44 24 0c e2 55 10 	movl   $0xf01055e2,0xc(%esp)
f01016de:	f0 
f01016df:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01016e6:	f0 
f01016e7:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f01016ee:	00 
f01016ef:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01016f6:	e8 c3 e9 ff ff       	call   f01000be <_panic>
	assert(pp && pp0 == pp);
f01016fb:	39 c6                	cmp    %eax,%esi
f01016fd:	74 24                	je     f0101723 <mem_init+0x546>
f01016ff:	c7 44 24 0c 00 56 10 	movl   $0xf0105600,0xc(%esp)
f0101706:	f0 
f0101707:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010170e:	f0 
f010170f:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0101716:	00 
f0101717:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010171e:	e8 9b e9 ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101723:	89 f2                	mov    %esi,%edx
f0101725:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f010172b:	c1 fa 03             	sar    $0x3,%edx
f010172e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101731:	89 d0                	mov    %edx,%eax
f0101733:	c1 e8 0c             	shr    $0xc,%eax
f0101736:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f010173c:	72 20                	jb     f010175e <mem_init+0x581>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010173e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101742:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0101749:	f0 
f010174a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101751:	00 
f0101752:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0101759:	e8 60 e9 ff ff       	call   f01000be <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010175e:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101765:	75 11                	jne    f0101778 <mem_init+0x59b>
f0101767:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010176d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101773:	80 38 00             	cmpb   $0x0,(%eax)
f0101776:	74 24                	je     f010179c <mem_init+0x5bf>
f0101778:	c7 44 24 0c 10 56 10 	movl   $0xf0105610,0xc(%esp)
f010177f:	f0 
f0101780:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101787:	f0 
f0101788:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f010178f:	00 
f0101790:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101797:	e8 22 e9 ff ff       	call   f01000be <_panic>
f010179c:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010179f:	39 d0                	cmp    %edx,%eax
f01017a1:	75 d0                	jne    f0101773 <mem_init+0x596>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01017a6:	89 15 88 bf 17 f0    	mov    %edx,0xf017bf88

	// free the pages we took
	page_free(pp0);
f01017ac:	89 34 24             	mov    %esi,(%esp)
f01017af:	e8 07 f7 ff ff       	call   f0100ebb <page_free>
	page_free(pp1);
f01017b4:	89 3c 24             	mov    %edi,(%esp)
f01017b7:	e8 ff f6 ff ff       	call   f0100ebb <page_free>
	page_free(pp2);
f01017bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017bf:	89 04 24             	mov    %eax,(%esp)
f01017c2:	e8 f4 f6 ff ff       	call   f0100ebb <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017c7:	a1 88 bf 17 f0       	mov    0xf017bf88,%eax
f01017cc:	85 c0                	test   %eax,%eax
f01017ce:	74 09                	je     f01017d9 <mem_init+0x5fc>
		--nfree;
f01017d0:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017d3:	8b 00                	mov    (%eax),%eax
f01017d5:	85 c0                	test   %eax,%eax
f01017d7:	75 f7                	jne    f01017d0 <mem_init+0x5f3>
		--nfree;
	assert(nfree == 0);
f01017d9:	85 db                	test   %ebx,%ebx
f01017db:	74 24                	je     f0101801 <mem_init+0x624>
f01017dd:	c7 44 24 0c 1a 56 10 	movl   $0xf010561a,0xc(%esp)
f01017e4:	f0 
f01017e5:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01017ec:	f0 
f01017ed:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f01017f4:	00 
f01017f5:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01017fc:	e8 bd e8 ff ff       	call   f01000be <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101801:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101808:	e8 6d 1a 00 00       	call   f010327a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010180d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101814:	e8 18 f6 ff ff       	call   f0100e31 <page_alloc>
f0101819:	89 c6                	mov    %eax,%esi
f010181b:	85 c0                	test   %eax,%eax
f010181d:	75 24                	jne    f0101843 <mem_init+0x666>
f010181f:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0101826:	f0 
f0101827:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010182e:	f0 
f010182f:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101836:	00 
f0101837:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010183e:	e8 7b e8 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010184a:	e8 e2 f5 ff ff       	call   f0100e31 <page_alloc>
f010184f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101852:	85 c0                	test   %eax,%eax
f0101854:	75 24                	jne    f010187a <mem_init+0x69d>
f0101856:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f010185d:	f0 
f010185e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101865:	f0 
f0101866:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f010186d:	00 
f010186e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101875:	e8 44 e8 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f010187a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101881:	e8 ab f5 ff ff       	call   f0100e31 <page_alloc>
f0101886:	89 c3                	mov    %eax,%ebx
f0101888:	85 c0                	test   %eax,%eax
f010188a:	75 24                	jne    f01018b0 <mem_init+0x6d3>
f010188c:	c7 44 24 0c 54 55 10 	movl   $0xf0105554,0xc(%esp)
f0101893:	f0 
f0101894:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010189b:	f0 
f010189c:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f01018a3:	00 
f01018a4:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01018ab:	e8 0e e8 ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018b0:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018b3:	75 24                	jne    f01018d9 <mem_init+0x6fc>
f01018b5:	c7 44 24 0c 6a 55 10 	movl   $0xf010556a,0xc(%esp)
f01018bc:	f0 
f01018bd:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01018c4:	f0 
f01018c5:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01018cc:	00 
f01018cd:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01018d4:	e8 e5 e7 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018d9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018dc:	74 04                	je     f01018e2 <mem_init+0x705>
f01018de:	39 c6                	cmp    %eax,%esi
f01018e0:	75 24                	jne    f0101906 <mem_init+0x729>
f01018e2:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f01018e9:	f0 
f01018ea:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01018f1:	f0 
f01018f2:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01018f9:	00 
f01018fa:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101901:	e8 b8 e7 ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101906:	8b 3d 88 bf 17 f0    	mov    0xf017bf88,%edi
f010190c:	89 7d cc             	mov    %edi,-0x34(%ebp)
	page_free_list = 0;
f010190f:	c7 05 88 bf 17 f0 00 	movl   $0x0,0xf017bf88
f0101916:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101920:	e8 0c f5 ff ff       	call   f0100e31 <page_alloc>
f0101925:	85 c0                	test   %eax,%eax
f0101927:	74 24                	je     f010194d <mem_init+0x770>
f0101929:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f0101930:	f0 
f0101931:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101938:	f0 
f0101939:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101940:	00 
f0101941:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101948:	e8 71 e7 ff ff       	call   f01000be <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010194d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101950:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101954:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010195b:	00 
f010195c:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101961:	89 04 24             	mov    %eax,(%esp)
f0101964:	e8 e9 f6 ff ff       	call   f0101052 <page_lookup>
f0101969:	85 c0                	test   %eax,%eax
f010196b:	74 24                	je     f0101991 <mem_init+0x7b4>
f010196d:	c7 44 24 0c 94 4e 10 	movl   $0xf0104e94,0xc(%esp)
f0101974:	f0 
f0101975:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010197c:	f0 
f010197d:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101984:	00 
f0101985:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010198c:	e8 2d e7 ff ff       	call   f01000be <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101991:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101998:	00 
f0101999:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019a0:	00 
f01019a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019a8:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f01019ad:	89 04 24             	mov    %eax,(%esp)
f01019b0:	e8 75 f7 ff ff       	call   f010112a <page_insert>
f01019b5:	85 c0                	test   %eax,%eax
f01019b7:	78 24                	js     f01019dd <mem_init+0x800>
f01019b9:	c7 44 24 0c cc 4e 10 	movl   $0xf0104ecc,0xc(%esp)
f01019c0:	f0 
f01019c1:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01019c8:	f0 
f01019c9:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01019d0:	00 
f01019d1:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01019d8:	e8 e1 e6 ff ff       	call   f01000be <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019dd:	89 34 24             	mov    %esi,(%esp)
f01019e0:	e8 d6 f4 ff ff       	call   f0100ebb <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019e5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019ec:	00 
f01019ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019f4:	00 
f01019f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019fc:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101a01:	89 04 24             	mov    %eax,(%esp)
f0101a04:	e8 21 f7 ff ff       	call   f010112a <page_insert>
f0101a09:	85 c0                	test   %eax,%eax
f0101a0b:	74 24                	je     f0101a31 <mem_init+0x854>
f0101a0d:	c7 44 24 0c fc 4e 10 	movl   $0xf0104efc,0xc(%esp)
f0101a14:	f0 
f0101a15:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101a1c:	f0 
f0101a1d:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101a24:	00 
f0101a25:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101a2c:	e8 8d e6 ff ff       	call   f01000be <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a31:	8b 3d 28 cc 17 f0    	mov    0xf017cc28,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a37:	8b 15 2c cc 17 f0    	mov    0xf017cc2c,%edx
f0101a3d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101a40:	8b 17                	mov    (%edi),%edx
f0101a42:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a48:	89 f0                	mov    %esi,%eax
f0101a4a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101a4d:	c1 f8 03             	sar    $0x3,%eax
f0101a50:	c1 e0 0c             	shl    $0xc,%eax
f0101a53:	39 c2                	cmp    %eax,%edx
f0101a55:	74 24                	je     f0101a7b <mem_init+0x89e>
f0101a57:	c7 44 24 0c 2c 4f 10 	movl   $0xf0104f2c,0xc(%esp)
f0101a5e:	f0 
f0101a5f:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101a66:	f0 
f0101a67:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101a6e:	00 
f0101a6f:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101a76:	e8 43 e6 ff ff       	call   f01000be <_panic>

	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a7b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a80:	89 f8                	mov    %edi,%eax
f0101a82:	e8 49 ee ff ff       	call   f01008d0 <check_va2pa>
f0101a87:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a8a:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101a8d:	c1 fa 03             	sar    $0x3,%edx
f0101a90:	c1 e2 0c             	shl    $0xc,%edx
f0101a93:	39 d0                	cmp    %edx,%eax
f0101a95:	74 24                	je     f0101abb <mem_init+0x8de>
f0101a97:	c7 44 24 0c 54 4f 10 	movl   $0xf0104f54,0xc(%esp)
f0101a9e:	f0 
f0101a9f:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101aae:	00 
f0101aaf:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101ab6:	e8 03 e6 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f0101abb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101abe:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ac3:	74 24                	je     f0101ae9 <mem_init+0x90c>
f0101ac5:	c7 44 24 0c 25 56 10 	movl   $0xf0105625,0xc(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101ad4:	f0 
f0101ad5:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101adc:	00 
f0101add:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101ae4:	e8 d5 e5 ff ff       	call   f01000be <_panic>
	assert(pp0->pp_ref == 1);
f0101ae9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aee:	74 24                	je     f0101b14 <mem_init+0x937>
f0101af0:	c7 44 24 0c 36 56 10 	movl   $0xf0105636,0xc(%esp)
f0101af7:	f0 
f0101af8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101aff:	f0 
f0101b00:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101b07:	00 
f0101b08:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101b0f:	e8 aa e5 ff ff       	call   f01000be <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b14:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b1b:	00 
f0101b1c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b23:	00 
f0101b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b28:	89 3c 24             	mov    %edi,(%esp)
f0101b2b:	e8 fa f5 ff ff       	call   f010112a <page_insert>
f0101b30:	85 c0                	test   %eax,%eax
f0101b32:	74 24                	je     f0101b58 <mem_init+0x97b>
f0101b34:	c7 44 24 0c 84 4f 10 	movl   $0xf0104f84,0xc(%esp)
f0101b3b:	f0 
f0101b3c:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101b43:	f0 
f0101b44:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101b4b:	00 
f0101b4c:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101b53:	e8 66 e5 ff ff       	call   f01000be <_panic>
	//cprintf("page2pa: %08x", page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b5d:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101b62:	e8 69 ed ff ff       	call   f01008d0 <check_va2pa>
f0101b67:	89 da                	mov    %ebx,%edx
f0101b69:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0101b6f:	c1 fa 03             	sar    $0x3,%edx
f0101b72:	c1 e2 0c             	shl    $0xc,%edx
f0101b75:	39 d0                	cmp    %edx,%eax
f0101b77:	74 24                	je     f0101b9d <mem_init+0x9c0>
f0101b79:	c7 44 24 0c c0 4f 10 	movl   $0xf0104fc0,0xc(%esp)
f0101b80:	f0 
f0101b81:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101b88:	f0 
f0101b89:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101b90:	00 
f0101b91:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101b98:	e8 21 e5 ff ff       	call   f01000be <_panic>

	assert(pp2->pp_ref == 1);
f0101b9d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ba2:	74 24                	je     f0101bc8 <mem_init+0x9eb>
f0101ba4:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f0101bab:	f0 
f0101bac:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101bb3:	f0 
f0101bb4:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101bbb:	00 
f0101bbc:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101bc3:	e8 f6 e4 ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101bc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bcf:	e8 5d f2 ff ff       	call   f0100e31 <page_alloc>
f0101bd4:	85 c0                	test   %eax,%eax
f0101bd6:	74 24                	je     f0101bfc <mem_init+0xa1f>
f0101bd8:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f0101bdf:	f0 
f0101be0:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101be7:	f0 
f0101be8:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101bef:	00 
f0101bf0:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101bf7:	e8 c2 e4 ff ff       	call   f01000be <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bfc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c03:	00 
f0101c04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c0b:	00 
f0101c0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c10:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101c15:	89 04 24             	mov    %eax,(%esp)
f0101c18:	e8 0d f5 ff ff       	call   f010112a <page_insert>
f0101c1d:	85 c0                	test   %eax,%eax
f0101c1f:	74 24                	je     f0101c45 <mem_init+0xa68>
f0101c21:	c7 44 24 0c 84 4f 10 	movl   $0xf0104f84,0xc(%esp)
f0101c28:	f0 
f0101c29:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101c30:	f0 
f0101c31:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101c38:	00 
f0101c39:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101c40:	e8 79 e4 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c45:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c4a:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101c4f:	e8 7c ec ff ff       	call   f01008d0 <check_va2pa>
f0101c54:	89 da                	mov    %ebx,%edx
f0101c56:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0101c5c:	c1 fa 03             	sar    $0x3,%edx
f0101c5f:	c1 e2 0c             	shl    $0xc,%edx
f0101c62:	39 d0                	cmp    %edx,%eax
f0101c64:	74 24                	je     f0101c8a <mem_init+0xaad>
f0101c66:	c7 44 24 0c c0 4f 10 	movl   $0xf0104fc0,0xc(%esp)
f0101c6d:	f0 
f0101c6e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101c75:	f0 
f0101c76:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101c7d:	00 
f0101c7e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101c85:	e8 34 e4 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f0101c8a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c8f:	74 24                	je     f0101cb5 <mem_init+0xad8>
f0101c91:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f0101c98:	f0 
f0101c99:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101ca0:	f0 
f0101ca1:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101ca8:	00 
f0101ca9:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101cb0:	e8 09 e4 ff ff       	call   f01000be <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbc:	e8 70 f1 ff ff       	call   f0100e31 <page_alloc>
f0101cc1:	85 c0                	test   %eax,%eax
f0101cc3:	74 24                	je     f0101ce9 <mem_init+0xb0c>
f0101cc5:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f0101ccc:	f0 
f0101ccd:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101cd4:	f0 
f0101cd5:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101cdc:	00 
f0101cdd:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101ce4:	e8 d5 e3 ff ff       	call   f01000be <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ce9:	8b 15 28 cc 17 f0    	mov    0xf017cc28,%edx
f0101cef:	8b 02                	mov    (%edx),%eax
f0101cf1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cf6:	89 c1                	mov    %eax,%ecx
f0101cf8:	c1 e9 0c             	shr    $0xc,%ecx
f0101cfb:	3b 0d 24 cc 17 f0    	cmp    0xf017cc24,%ecx
f0101d01:	72 20                	jb     f0101d23 <mem_init+0xb46>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d07:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0101d0e:	f0 
f0101d0f:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101d16:	00 
f0101d17:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101d1e:	e8 9b e3 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0101d23:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d32:	00 
f0101d33:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d3a:	00 
f0101d3b:	89 14 24             	mov    %edx,(%esp)
f0101d3e:	e8 b7 f1 ff ff       	call   f0100efa <pgdir_walk>
f0101d43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101d46:	83 c2 04             	add    $0x4,%edx
f0101d49:	39 d0                	cmp    %edx,%eax
f0101d4b:	74 24                	je     f0101d71 <mem_init+0xb94>
f0101d4d:	c7 44 24 0c f0 4f 10 	movl   $0xf0104ff0,0xc(%esp)
f0101d54:	f0 
f0101d55:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101d5c:	f0 
f0101d5d:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101d64:	00 
f0101d65:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101d6c:	e8 4d e3 ff ff       	call   f01000be <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d78:	00 
f0101d79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d80:	00 
f0101d81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d85:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101d8a:	89 04 24             	mov    %eax,(%esp)
f0101d8d:	e8 98 f3 ff ff       	call   f010112a <page_insert>
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	74 24                	je     f0101dba <mem_init+0xbdd>
f0101d96:	c7 44 24 0c 30 50 10 	movl   $0xf0105030,0xc(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101dad:	00 
f0101dae:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101db5:	e8 04 e3 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dba:	8b 3d 28 cc 17 f0    	mov    0xf017cc28,%edi
f0101dc0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc5:	89 f8                	mov    %edi,%eax
f0101dc7:	e8 04 eb ff ff       	call   f01008d0 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dcc:	89 da                	mov    %ebx,%edx
f0101dce:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0101dd4:	c1 fa 03             	sar    $0x3,%edx
f0101dd7:	c1 e2 0c             	shl    $0xc,%edx
f0101dda:	39 d0                	cmp    %edx,%eax
f0101ddc:	74 24                	je     f0101e02 <mem_init+0xc25>
f0101dde:	c7 44 24 0c c0 4f 10 	movl   $0xf0104fc0,0xc(%esp)
f0101de5:	f0 
f0101de6:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101df5:	00 
f0101df6:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101dfd:	e8 bc e2 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f0101e02:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e07:	74 24                	je     f0101e2d <mem_init+0xc50>
f0101e09:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f0101e10:	f0 
f0101e11:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101e18:	f0 
f0101e19:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101e20:	00 
f0101e21:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101e28:	e8 91 e2 ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e2d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e34:	00 
f0101e35:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e3c:	00 
f0101e3d:	89 3c 24             	mov    %edi,(%esp)
f0101e40:	e8 b5 f0 ff ff       	call   f0100efa <pgdir_walk>
f0101e45:	f6 00 04             	testb  $0x4,(%eax)
f0101e48:	75 24                	jne    f0101e6e <mem_init+0xc91>
f0101e4a:	c7 44 24 0c 70 50 10 	movl   $0xf0105070,0xc(%esp)
f0101e51:	f0 
f0101e52:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101e59:	f0 
f0101e5a:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101e61:	00 
f0101e62:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101e69:	e8 50 e2 ff ff       	call   f01000be <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e6e:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101e73:	f6 00 04             	testb  $0x4,(%eax)
f0101e76:	75 24                	jne    f0101e9c <mem_init+0xcbf>
f0101e78:	c7 44 24 0c 58 56 10 	movl   $0xf0105658,0xc(%esp)
f0101e7f:	f0 
f0101e80:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101e87:	f0 
f0101e88:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101e8f:	00 
f0101e90:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101e97:	e8 22 e2 ff ff       	call   f01000be <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e9c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ea3:	00 
f0101ea4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eab:	00 
f0101eac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101eb0:	89 04 24             	mov    %eax,(%esp)
f0101eb3:	e8 72 f2 ff ff       	call   f010112a <page_insert>
f0101eb8:	85 c0                	test   %eax,%eax
f0101eba:	74 24                	je     f0101ee0 <mem_init+0xd03>
f0101ebc:	c7 44 24 0c 84 4f 10 	movl   $0xf0104f84,0xc(%esp)
f0101ec3:	f0 
f0101ec4:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101ecb:	f0 
f0101ecc:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101ed3:	00 
f0101ed4:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101edb:	e8 de e1 ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ee0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ee7:	00 
f0101ee8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101eef:	00 
f0101ef0:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101ef5:	89 04 24             	mov    %eax,(%esp)
f0101ef8:	e8 fd ef ff ff       	call   f0100efa <pgdir_walk>
f0101efd:	f6 00 02             	testb  $0x2,(%eax)
f0101f00:	75 24                	jne    f0101f26 <mem_init+0xd49>
f0101f02:	c7 44 24 0c a4 50 10 	movl   $0xf01050a4,0xc(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101f19:	00 
f0101f1a:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101f21:	e8 98 e1 ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f2d:	00 
f0101f2e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f35:	00 
f0101f36:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101f3b:	89 04 24             	mov    %eax,(%esp)
f0101f3e:	e8 b7 ef ff ff       	call   f0100efa <pgdir_walk>
f0101f43:	f6 00 04             	testb  $0x4,(%eax)
f0101f46:	74 24                	je     f0101f6c <mem_init+0xd8f>
f0101f48:	c7 44 24 0c d8 50 10 	movl   $0xf01050d8,0xc(%esp)
f0101f4f:	f0 
f0101f50:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101f57:	f0 
f0101f58:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101f5f:	00 
f0101f60:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101f67:	e8 52 e1 ff ff       	call   f01000be <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f6c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f73:	00 
f0101f74:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f7b:	00 
f0101f7c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f80:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101f85:	89 04 24             	mov    %eax,(%esp)
f0101f88:	e8 9d f1 ff ff       	call   f010112a <page_insert>
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	78 24                	js     f0101fb5 <mem_init+0xdd8>
f0101f91:	c7 44 24 0c 10 51 10 	movl   $0xf0105110,0xc(%esp)
f0101f98:	f0 
f0101f99:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101fa0:	f0 
f0101fa1:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101fa8:	00 
f0101fa9:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101fb0:	e8 09 e1 ff ff       	call   f01000be <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fb5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fbc:	00 
f0101fbd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fc4:	00 
f0101fc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fcc:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0101fd1:	89 04 24             	mov    %eax,(%esp)
f0101fd4:	e8 51 f1 ff ff       	call   f010112a <page_insert>
f0101fd9:	85 c0                	test   %eax,%eax
f0101fdb:	74 24                	je     f0102001 <mem_init+0xe24>
f0101fdd:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0101fec:	f0 
f0101fed:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0101ff4:	00 
f0101ff5:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0101ffc:	e8 bd e0 ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102008:	00 
f0102009:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102010:	00 
f0102011:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102016:	89 04 24             	mov    %eax,(%esp)
f0102019:	e8 dc ee ff ff       	call   f0100efa <pgdir_walk>
f010201e:	f6 00 04             	testb  $0x4,(%eax)
f0102021:	74 24                	je     f0102047 <mem_init+0xe6a>
f0102023:	c7 44 24 0c d8 50 10 	movl   $0xf01050d8,0xc(%esp)
f010202a:	f0 
f010202b:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102032:	f0 
f0102033:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f010203a:	00 
f010203b:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102042:	e8 77 e0 ff ff       	call   f01000be <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102047:	8b 3d 28 cc 17 f0    	mov    0xf017cc28,%edi
f010204d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102052:	89 f8                	mov    %edi,%eax
f0102054:	e8 77 e8 ff ff       	call   f01008d0 <check_va2pa>
f0102059:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010205c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010205f:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0102065:	c1 f8 03             	sar    $0x3,%eax
f0102068:	c1 e0 0c             	shl    $0xc,%eax
f010206b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010206e:	74 24                	je     f0102094 <mem_init+0xeb7>
f0102070:	c7 44 24 0c 84 51 10 	movl   $0xf0105184,0xc(%esp)
f0102077:	f0 
f0102078:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010207f:	f0 
f0102080:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102087:	00 
f0102088:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010208f:	e8 2a e0 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102094:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102099:	89 f8                	mov    %edi,%eax
f010209b:	e8 30 e8 ff ff       	call   f01008d0 <check_va2pa>
f01020a0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01020a3:	74 24                	je     f01020c9 <mem_init+0xeec>
f01020a5:	c7 44 24 0c b0 51 10 	movl   $0xf01051b0,0xc(%esp)
f01020ac:	f0 
f01020ad:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01020b4:	f0 
f01020b5:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01020bc:	00 
f01020bd:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01020c4:	e8 f5 df ff ff       	call   f01000be <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01020c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020cc:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01020d1:	74 24                	je     f01020f7 <mem_init+0xf1a>
f01020d3:	c7 44 24 0c 6e 56 10 	movl   $0xf010566e,0xc(%esp)
f01020da:	f0 
f01020db:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01020ea:	00 
f01020eb:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01020f2:	e8 c7 df ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f01020f7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020fc:	74 24                	je     f0102122 <mem_init+0xf45>
f01020fe:	c7 44 24 0c 7f 56 10 	movl   $0xf010567f,0xc(%esp)
f0102105:	f0 
f0102106:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010210d:	f0 
f010210e:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102115:	00 
f0102116:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010211d:	e8 9c df ff ff       	call   f01000be <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102129:	e8 03 ed ff ff       	call   f0100e31 <page_alloc>
f010212e:	85 c0                	test   %eax,%eax
f0102130:	74 04                	je     f0102136 <mem_init+0xf59>
f0102132:	39 c3                	cmp    %eax,%ebx
f0102134:	74 24                	je     f010215a <mem_init+0xf7d>
f0102136:	c7 44 24 0c e0 51 10 	movl   $0xf01051e0,0xc(%esp)
f010213d:	f0 
f010213e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102145:	f0 
f0102146:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010214d:	00 
f010214e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102155:	e8 64 df ff ff       	call   f01000be <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010215a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102161:	00 
f0102162:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102167:	89 04 24             	mov    %eax,(%esp)
f010216a:	e8 6b ef ff ff       	call   f01010da <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010216f:	8b 3d 28 cc 17 f0    	mov    0xf017cc28,%edi
f0102175:	ba 00 00 00 00       	mov    $0x0,%edx
f010217a:	89 f8                	mov    %edi,%eax
f010217c:	e8 4f e7 ff ff       	call   f01008d0 <check_va2pa>
f0102181:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102184:	74 24                	je     f01021aa <mem_init+0xfcd>
f0102186:	c7 44 24 0c 04 52 10 	movl   $0xf0105204,0xc(%esp)
f010218d:	f0 
f010218e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102195:	f0 
f0102196:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f010219d:	00 
f010219e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01021a5:	e8 14 df ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021aa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021af:	89 f8                	mov    %edi,%eax
f01021b1:	e8 1a e7 ff ff       	call   f01008d0 <check_va2pa>
f01021b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01021b9:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f01021bf:	c1 fa 03             	sar    $0x3,%edx
f01021c2:	c1 e2 0c             	shl    $0xc,%edx
f01021c5:	39 d0                	cmp    %edx,%eax
f01021c7:	74 24                	je     f01021ed <mem_init+0x1010>
f01021c9:	c7 44 24 0c b0 51 10 	movl   $0xf01051b0,0xc(%esp)
f01021d0:	f0 
f01021d1:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01021d8:	f0 
f01021d9:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01021e0:	00 
f01021e1:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01021e8:	e8 d1 de ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f01021ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021f5:	74 24                	je     f010221b <mem_init+0x103e>
f01021f7:	c7 44 24 0c 25 56 10 	movl   $0xf0105625,0xc(%esp)
f01021fe:	f0 
f01021ff:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102206:	f0 
f0102207:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f010220e:	00 
f010220f:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102216:	e8 a3 de ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f010221b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102220:	74 24                	je     f0102246 <mem_init+0x1069>
f0102222:	c7 44 24 0c 7f 56 10 	movl   $0xf010567f,0xc(%esp)
f0102229:	f0 
f010222a:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102231:	f0 
f0102232:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102239:	00 
f010223a:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102241:	e8 78 de ff ff       	call   f01000be <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102246:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010224d:	00 
f010224e:	89 3c 24             	mov    %edi,(%esp)
f0102251:	e8 84 ee ff ff       	call   f01010da <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102256:	8b 3d 28 cc 17 f0    	mov    0xf017cc28,%edi
f010225c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102261:	89 f8                	mov    %edi,%eax
f0102263:	e8 68 e6 ff ff       	call   f01008d0 <check_va2pa>
f0102268:	83 f8 ff             	cmp    $0xffffffff,%eax
f010226b:	74 24                	je     f0102291 <mem_init+0x10b4>
f010226d:	c7 44 24 0c 04 52 10 	movl   $0xf0105204,0xc(%esp)
f0102274:	f0 
f0102275:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010227c:	f0 
f010227d:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102284:	00 
f0102285:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010228c:	e8 2d de ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102291:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102296:	89 f8                	mov    %edi,%eax
f0102298:	e8 33 e6 ff ff       	call   f01008d0 <check_va2pa>
f010229d:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a0:	74 24                	je     f01022c6 <mem_init+0x10e9>
f01022a2:	c7 44 24 0c 28 52 10 	movl   $0xf0105228,0xc(%esp)
f01022a9:	f0 
f01022aa:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01022b1:	f0 
f01022b2:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f01022b9:	00 
f01022ba:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01022c1:	e8 f8 dd ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f01022c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01022ce:	74 24                	je     f01022f4 <mem_init+0x1117>
f01022d0:	c7 44 24 0c 90 56 10 	movl   $0xf0105690,0xc(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01022e7:	00 
f01022e8:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01022ef:	e8 ca dd ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f01022f4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022f9:	74 24                	je     f010231f <mem_init+0x1142>
f01022fb:	c7 44 24 0c 7f 56 10 	movl   $0xf010567f,0xc(%esp)
f0102302:	f0 
f0102303:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010230a:	f0 
f010230b:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102312:	00 
f0102313:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010231a:	e8 9f dd ff ff       	call   f01000be <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010231f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102326:	e8 06 eb ff ff       	call   f0100e31 <page_alloc>
f010232b:	85 c0                	test   %eax,%eax
f010232d:	74 05                	je     f0102334 <mem_init+0x1157>
f010232f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102332:	74 24                	je     f0102358 <mem_init+0x117b>
f0102334:	c7 44 24 0c 50 52 10 	movl   $0xf0105250,0xc(%esp)
f010233b:	f0 
f010233c:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102343:	f0 
f0102344:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f010234b:	00 
f010234c:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102353:	e8 66 dd ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102358:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010235f:	e8 cd ea ff ff       	call   f0100e31 <page_alloc>
f0102364:	85 c0                	test   %eax,%eax
f0102366:	74 24                	je     f010238c <mem_init+0x11af>
f0102368:	c7 44 24 0c d3 55 10 	movl   $0xf01055d3,0xc(%esp)
f010236f:	f0 
f0102370:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102377:	f0 
f0102378:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f010237f:	00 
f0102380:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102387:	e8 32 dd ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010238c:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102391:	8b 08                	mov    (%eax),%ecx
f0102393:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102399:	89 f2                	mov    %esi,%edx
f010239b:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f01023a1:	c1 fa 03             	sar    $0x3,%edx
f01023a4:	c1 e2 0c             	shl    $0xc,%edx
f01023a7:	39 d1                	cmp    %edx,%ecx
f01023a9:	74 24                	je     f01023cf <mem_init+0x11f2>
f01023ab:	c7 44 24 0c 2c 4f 10 	movl   $0xf0104f2c,0xc(%esp)
f01023b2:	f0 
f01023b3:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01023ba:	f0 
f01023bb:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f01023c2:	00 
f01023c3:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01023ca:	e8 ef dc ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f01023cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023d5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023da:	74 24                	je     f0102400 <mem_init+0x1223>
f01023dc:	c7 44 24 0c 36 56 10 	movl   $0xf0105636,0xc(%esp)
f01023e3:	f0 
f01023e4:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01023eb:	f0 
f01023ec:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01023f3:	00 
f01023f4:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01023fb:	e8 be dc ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0102400:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102406:	89 34 24             	mov    %esi,(%esp)
f0102409:	e8 ad ea ff ff       	call   f0100ebb <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010240e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102415:	00 
f0102416:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010241d:	00 
f010241e:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102423:	89 04 24             	mov    %eax,(%esp)
f0102426:	e8 cf ea ff ff       	call   f0100efa <pgdir_walk>
f010242b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010242e:	8b 15 28 cc 17 f0    	mov    0xf017cc28,%edx
f0102434:	8b 4a 04             	mov    0x4(%edx),%ecx
f0102437:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010243d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102440:	8b 0d 24 cc 17 f0    	mov    0xf017cc24,%ecx
f0102446:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102449:	c1 ef 0c             	shr    $0xc,%edi
f010244c:	39 cf                	cmp    %ecx,%edi
f010244e:	72 23                	jb     f0102473 <mem_init+0x1296>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102450:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102453:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102457:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f010245e:	f0 
f010245f:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102466:	00 
f0102467:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010246e:	e8 4b dc ff ff       	call   f01000be <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102473:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102476:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010247c:	39 f8                	cmp    %edi,%eax
f010247e:	74 24                	je     f01024a4 <mem_init+0x12c7>
f0102480:	c7 44 24 0c a1 56 10 	movl   $0xf01056a1,0xc(%esp)
f0102487:	f0 
f0102488:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010248f:	f0 
f0102490:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102497:	00 
f0102498:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010249f:	e8 1a dc ff ff       	call   f01000be <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024a4:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f01024ab:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024b1:	89 f0                	mov    %esi,%eax
f01024b3:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f01024b9:	c1 f8 03             	sar    $0x3,%eax
f01024bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024bf:	89 c2                	mov    %eax,%edx
f01024c1:	c1 ea 0c             	shr    $0xc,%edx
f01024c4:	39 d1                	cmp    %edx,%ecx
f01024c6:	77 20                	ja     f01024e8 <mem_init+0x130b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024cc:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f01024d3:	f0 
f01024d4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01024db:	00 
f01024dc:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f01024e3:	e8 d6 db ff ff       	call   f01000be <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ef:	00 
f01024f0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024f7:	00 
	return (void *)(pa + KERNBASE);
f01024f8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024fd:	89 04 24             	mov    %eax,(%esp)
f0102500:	e8 20 1e 00 00       	call   f0104325 <memset>
	page_free(pp0);
f0102505:	89 34 24             	mov    %esi,(%esp)
f0102508:	e8 ae e9 ff ff       	call   f0100ebb <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010250d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102514:	00 
f0102515:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010251c:	00 
f010251d:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102522:	89 04 24             	mov    %eax,(%esp)
f0102525:	e8 d0 e9 ff ff       	call   f0100efa <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010252a:	89 f2                	mov    %esi,%edx
f010252c:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0102532:	c1 fa 03             	sar    $0x3,%edx
f0102535:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102538:	89 d0                	mov    %edx,%eax
f010253a:	c1 e8 0c             	shr    $0xc,%eax
f010253d:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f0102543:	72 20                	jb     f0102565 <mem_init+0x1388>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102545:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102549:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0102550:	f0 
f0102551:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102558:	00 
f0102559:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0102560:	e8 59 db ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0102565:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010256b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010256e:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102575:	75 11                	jne    f0102588 <mem_init+0x13ab>
f0102577:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010257d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102583:	f6 00 01             	testb  $0x1,(%eax)
f0102586:	74 24                	je     f01025ac <mem_init+0x13cf>
f0102588:	c7 44 24 0c b9 56 10 	movl   $0xf01056b9,0xc(%esp)
f010258f:	f0 
f0102590:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102597:	f0 
f0102598:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f010259f:	00 
f01025a0:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01025a7:	e8 12 db ff ff       	call   f01000be <_panic>
f01025ac:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025af:	39 d0                	cmp    %edx,%eax
f01025b1:	75 d0                	jne    f0102583 <mem_init+0x13a6>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025b3:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f01025b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025be:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01025c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01025c7:	89 3d 88 bf 17 f0    	mov    %edi,0xf017bf88

	// free the pages we took
	page_free(pp0);
f01025cd:	89 34 24             	mov    %esi,(%esp)
f01025d0:	e8 e6 e8 ff ff       	call   f0100ebb <page_free>
	page_free(pp1);
f01025d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025d8:	89 04 24             	mov    %eax,(%esp)
f01025db:	e8 db e8 ff ff       	call   f0100ebb <page_free>
	page_free(pp2);
f01025e0:	89 1c 24             	mov    %ebx,(%esp)
f01025e3:	e8 d3 e8 ff ff       	call   f0100ebb <page_free>

	cprintf("check_page() succeeded!\n");
f01025e8:	c7 04 24 d0 56 10 f0 	movl   $0xf01056d0,(%esp)
f01025ef:	e8 86 0c 00 00       	call   f010327a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
 boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f01025f4:	a1 2c cc 17 f0       	mov    0xf017cc2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025fe:	77 20                	ja     f0102620 <mem_init+0x1443>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102600:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102604:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f010260b:	f0 
f010260c:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102613:	00 
f0102614:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010261b:	e8 9e da ff ff       	call   f01000be <_panic>
f0102620:	8b 0d 24 cc 17 f0    	mov    0xf017cc24,%ecx
f0102626:	c1 e1 03             	shl    $0x3,%ecx
f0102629:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102630:	00 
	return (physaddr_t)kva - KERNBASE;
f0102631:	05 00 00 00 10       	add    $0x10000000,%eax
f0102636:	89 04 24             	mov    %eax,(%esp)
f0102639:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010263e:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102643:	e8 a1 e9 ff ff       	call   f0100fe9 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102648:	ba 00 00 11 f0       	mov    $0xf0110000,%edx
f010264d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102653:	77 20                	ja     f0102675 <mem_init+0x1498>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102655:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102659:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f0102660:	f0 
f0102661:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102668:	00 
f0102669:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102670:	e8 49 da ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102675:	c7 45 d0 00 00 11 00 	movl   $0x110000,-0x30(%ebp)
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
  boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010267c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102683:	00 
f0102684:	c7 04 24 00 00 11 00 	movl   $0x110000,(%esp)
f010268b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102690:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102695:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f010269a:	e8 4a e9 ff ff       	call   f0100fe9 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region (kern_pgdir, (uintptr_t) KERNBASE, (uint32_t) (0xffffffff - KERNBASE), (physaddr_t) (0),PTE_W);
f010269f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01026a6:	00 
f01026a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ae:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01026b3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026b8:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f01026bd:	e8 27 e9 ff ff       	call   f0100fe9 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026c2:	8b 1d 28 cc 17 f0    	mov    0xf017cc28,%ebx
<<<<<<< HEAD
*/
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01026c8:	8b 35 90 bf 17 f0    	mov    0xf017bf90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026ce:	89 f7                	mov    %esi,%edi
f01026d0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026d5:	89 d8                	mov    %ebx,%eax
f01026d7:	e8 f4 e1 ff ff       	call   f01008d0 <check_va2pa>
f01026dc:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01026e2:	77 20                	ja     f0102704 <mem_init+0x1527>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01026e8:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f01026ef:	f0 
f01026f0:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f01026f7:	00 
f01026f8:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01026ff:	e8 ba d9 ff ff       	call   f01000be <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102704:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102709:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f010270f:	8d 14 37             	lea    (%edi,%esi,1),%edx
<<<<<<< HEAD
*/
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102712:	39 c2                	cmp    %eax,%edx
f0102714:	74 24                	je     f010273a <mem_init+0x155d>
f0102716:	c7 44 24 0c 74 52 10 	movl   $0xf0105274,0xc(%esp)
f010271d:	f0 
f010271e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102725:	f0 
f0102726:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010272d:	00 
f010272e:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102735:	e8 84 d9 ff ff       	call   f01000be <_panic>
f010273a:	81 c6 00 10 00 00    	add    $0x1000,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
<<<<<<< HEAD
*/
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102740:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102746:	0f 85 fb 05 00 00    	jne    f0102d47 <mem_init+0x1b6a>
/*=======
}
>>>>>>> lab2
*/
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010274c:	8b 3d 24 cc 17 f0    	mov    0xf017cc24,%edi
f0102752:	c1 e7 0c             	shl    $0xc,%edi
f0102755:	85 ff                	test   %edi,%edi
f0102757:	0f 84 c3 05 00 00    	je     f0102d20 <mem_init+0x1b43>
f010275d:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102762:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
}
>>>>>>> lab2
*/
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102768:	89 d8                	mov    %ebx,%eax
f010276a:	e8 61 e1 ff ff       	call   f01008d0 <check_va2pa>
f010276f:	39 c6                	cmp    %eax,%esi
f0102771:	74 24                	je     f0102797 <mem_init+0x15ba>
f0102773:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f010277a:	f0 
f010277b:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102782:	f0 
f0102783:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f010278a:	00 
f010278b:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102792:	e8 27 d9 ff ff       	call   f01000be <_panic>
/*=======
}
>>>>>>> lab2
*/
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102797:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010279d:	39 fe                	cmp    %edi,%esi
f010279f:	72 c1                	jb     f0102762 <mem_init+0x1585>
f01027a1:	e9 7a 05 00 00       	jmp    f0102d20 <mem_init+0x1b43>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027a6:	39 d8                	cmp    %ebx,%eax
f01027a8:	74 24                	je     f01027ce <mem_init+0x15f1>
f01027aa:	c7 44 24 0c d0 52 10 	movl   $0xf01052d0,0xc(%esp)
f01027b1:	f0 
f01027b2:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01027b9:	f0 
f01027ba:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01027c1:	00 
f01027c2:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01027c9:	e8 f0 d8 ff ff       	call   f01000be <_panic>
f01027ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01027d4:	39 f3                	cmp    %esi,%ebx
f01027d6:	0f 85 34 05 00 00    	jne    f0102d10 <mem_init+0x1b33>
f01027dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01027df:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01027e4:	89 d8                	mov    %ebx,%eax
f01027e6:	e8 e5 e0 ff ff       	call   f01008d0 <check_va2pa>
f01027eb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027ee:	74 24                	je     f0102814 <mem_init+0x1637>
f01027f0:	c7 44 24 0c 18 53 10 	movl   $0xf0105318,0xc(%esp)
f01027f7:	f0 
f01027f8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01027ff:	f0 
f0102800:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0102807:	00 
f0102808:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010280f:	e8 aa d8 ff ff       	call   f01000be <_panic>
f0102814:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102819:	ba 01 00 00 00       	mov    $0x1,%edx
f010281e:	8d 88 45 fc ff ff    	lea    -0x3bb(%eax),%ecx
f0102824:	83 f9 04             	cmp    $0x4,%ecx
f0102827:	77 39                	ja     f0102862 <mem_init+0x1685>
f0102829:	89 d6                	mov    %edx,%esi
f010282b:	d3 e6                	shl    %cl,%esi
f010282d:	89 f1                	mov    %esi,%ecx
f010282f:	f6 c1 17             	test   $0x17,%cl
f0102832:	74 2e                	je     f0102862 <mem_init+0x1685>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102834:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102838:	0f 85 aa 00 00 00    	jne    f01028e8 <mem_init+0x170b>
f010283e:	c7 44 24 0c e9 56 10 	movl   $0xf01056e9,0xc(%esp)
f0102845:	f0 
f0102846:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010284d:	f0 
f010284e:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0102855:	00 
f0102856:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010285d:	e8 5c d8 ff ff       	call   f01000be <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102862:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102867:	76 55                	jbe    f01028be <mem_init+0x16e1>
				assert(pgdir[i] & PTE_P);
f0102869:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f010286c:	f6 c1 01             	test   $0x1,%cl
f010286f:	75 24                	jne    f0102895 <mem_init+0x16b8>
f0102871:	c7 44 24 0c e9 56 10 	movl   $0xf01056e9,0xc(%esp)
f0102878:	f0 
f0102879:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102880:	f0 
f0102881:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102888:	00 
f0102889:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102890:	e8 29 d8 ff ff       	call   f01000be <_panic>
				assert(pgdir[i] & PTE_W);
f0102895:	f6 c1 02             	test   $0x2,%cl
f0102898:	75 4e                	jne    f01028e8 <mem_init+0x170b>
f010289a:	c7 44 24 0c fa 56 10 	movl   $0xf01056fa,0xc(%esp)
f01028a1:	f0 
f01028a2:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01028a9:	f0 
f01028aa:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f01028b1:	00 
f01028b2:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01028b9:	e8 00 d8 ff ff       	call   f01000be <_panic>
			} else
				assert(pgdir[i] == 0);
f01028be:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028c2:	74 24                	je     f01028e8 <mem_init+0x170b>
f01028c4:	c7 44 24 0c 0b 57 10 	movl   $0xf010570b,0xc(%esp)
f01028cb:	f0 
f01028cc:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01028d3:	f0 
f01028d4:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01028db:	00 
f01028dc:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01028e3:	e8 d6 d7 ff ff       	call   f01000be <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028e8:	83 c0 01             	add    $0x1,%eax
f01028eb:	3d 00 04 00 00       	cmp    $0x400,%eax
f01028f0:	0f 85 28 ff ff ff    	jne    f010281e <mem_init+0x1641>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01028f6:	c7 04 24 48 53 10 f0 	movl   $0xf0105348,(%esp)
f01028fd:	e8 78 09 00 00       	call   f010327a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102902:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102907:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010290c:	77 20                	ja     f010292e <mem_init+0x1751>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102912:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f0102919:	f0 
f010291a:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f0102921:	00 
f0102922:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102929:	e8 90 d7 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f010292e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102933:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102936:	b8 00 00 00 00       	mov    $0x0,%eax
f010293b:	e8 c7 e0 ff ff       	call   f0100a07 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102940:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102943:	83 e0 f3             	and    $0xfffffff3,%eax
f0102946:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010294b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010294e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102955:	e8 d7 e4 ff ff       	call   f0100e31 <page_alloc>
f010295a:	89 c3                	mov    %eax,%ebx
f010295c:	85 c0                	test   %eax,%eax
f010295e:	75 24                	jne    f0102984 <mem_init+0x17a7>
f0102960:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0102967:	f0 
f0102968:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f010296f:	f0 
f0102970:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102977:	00 
f0102978:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f010297f:	e8 3a d7 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0102984:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010298b:	e8 a1 e4 ff ff       	call   f0100e31 <page_alloc>
f0102990:	89 c7                	mov    %eax,%edi
f0102992:	85 c0                	test   %eax,%eax
f0102994:	75 24                	jne    f01029ba <mem_init+0x17dd>
f0102996:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f010299d:	f0 
f010299e:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01029a5:	f0 
f01029a6:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f01029ad:	00 
f01029ae:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01029b5:	e8 04 d7 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f01029ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029c1:	e8 6b e4 ff ff       	call   f0100e31 <page_alloc>
f01029c6:	89 c6                	mov    %eax,%esi
f01029c8:	85 c0                	test   %eax,%eax
f01029ca:	75 24                	jne    f01029f0 <mem_init+0x1813>
f01029cc:	c7 44 24 0c 54 55 10 	movl   $0xf0105554,0xc(%esp)
f01029d3:	f0 
f01029d4:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f01029db:	f0 
f01029dc:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01029e3:	00 
f01029e4:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f01029eb:	e8 ce d6 ff ff       	call   f01000be <_panic>
	page_free(pp0);
f01029f0:	89 1c 24             	mov    %ebx,(%esp)
f01029f3:	e8 c3 e4 ff ff       	call   f0100ebb <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029f8:	89 f8                	mov    %edi,%eax
f01029fa:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0102a00:	c1 f8 03             	sar    $0x3,%eax
f0102a03:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a06:	89 c2                	mov    %eax,%edx
f0102a08:	c1 ea 0c             	shr    $0xc,%edx
f0102a0b:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0102a11:	72 20                	jb     f0102a33 <mem_init+0x1856>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a17:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0102a1e:	f0 
f0102a1f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102a26:	00 
f0102a27:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0102a2e:	e8 8b d6 ff ff       	call   f01000be <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a3a:	00 
f0102a3b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102a42:	00 
	return (void *)(pa + KERNBASE);
f0102a43:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a48:	89 04 24             	mov    %eax,(%esp)
f0102a4b:	e8 d5 18 00 00       	call   f0104325 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a50:	89 f0                	mov    %esi,%eax
f0102a52:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0102a58:	c1 f8 03             	sar    $0x3,%eax
f0102a5b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a5e:	89 c2                	mov    %eax,%edx
f0102a60:	c1 ea 0c             	shr    $0xc,%edx
f0102a63:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0102a69:	72 20                	jb     f0102a8b <mem_init+0x18ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a6f:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0102a76:	f0 
f0102a77:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102a7e:	00 
f0102a7f:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0102a86:	e8 33 d6 ff ff       	call   f01000be <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a8b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a92:	00 
f0102a93:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102a9a:	00 
	return (void *)(pa + KERNBASE);
f0102a9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aa0:	89 04 24             	mov    %eax,(%esp)
f0102aa3:	e8 7d 18 00 00       	call   f0104325 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102aa8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102aaf:	00 
f0102ab0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ab7:	00 
f0102ab8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102abc:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102ac1:	89 04 24             	mov    %eax,(%esp)
f0102ac4:	e8 61 e6 ff ff       	call   f010112a <page_insert>
	assert(pp1->pp_ref == 1);
f0102ac9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ace:	74 24                	je     f0102af4 <mem_init+0x1917>
f0102ad0:	c7 44 24 0c 25 56 10 	movl   $0xf0105625,0xc(%esp)
f0102ad7:	f0 
f0102ad8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102adf:	f0 
f0102ae0:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102ae7:	00 
f0102ae8:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102aef:	e8 ca d5 ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102af4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102afb:	01 01 01 
f0102afe:	74 24                	je     f0102b24 <mem_init+0x1947>
f0102b00:	c7 44 24 0c 68 53 10 	movl   $0xf0105368,0xc(%esp)
f0102b07:	f0 
f0102b08:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102b0f:	f0 
f0102b10:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102b17:	00 
f0102b18:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102b1f:	e8 9a d5 ff ff       	call   f01000be <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b24:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b2b:	00 
f0102b2c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b33:	00 
f0102b34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b38:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102b3d:	89 04 24             	mov    %eax,(%esp)
f0102b40:	e8 e5 e5 ff ff       	call   f010112a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b45:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b4c:	02 02 02 
f0102b4f:	74 24                	je     f0102b75 <mem_init+0x1998>
f0102b51:	c7 44 24 0c 8c 53 10 	movl   $0xf010538c,0xc(%esp)
f0102b58:	f0 
f0102b59:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102b60:	f0 
f0102b61:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102b68:	00 
f0102b69:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102b70:	e8 49 d5 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f0102b75:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b7a:	74 24                	je     f0102ba0 <mem_init+0x19c3>
f0102b7c:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f0102b83:	f0 
f0102b84:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102b8b:	f0 
f0102b8c:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102b93:	00 
f0102b94:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102b9b:	e8 1e d5 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f0102ba0:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ba5:	74 24                	je     f0102bcb <mem_init+0x19ee>
f0102ba7:	c7 44 24 0c 90 56 10 	movl   $0xf0105690,0xc(%esp)
f0102bae:	f0 
f0102baf:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102bb6:	f0 
f0102bb7:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102bbe:	00 
f0102bbf:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102bc6:	e8 f3 d4 ff ff       	call   f01000be <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bcb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bd2:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd5:	89 f0                	mov    %esi,%eax
f0102bd7:	2b 05 2c cc 17 f0    	sub    0xf017cc2c,%eax
f0102bdd:	c1 f8 03             	sar    $0x3,%eax
f0102be0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be3:	89 c2                	mov    %eax,%edx
f0102be5:	c1 ea 0c             	shr    $0xc,%edx
f0102be8:	3b 15 24 cc 17 f0    	cmp    0xf017cc24,%edx
f0102bee:	72 20                	jb     f0102c10 <mem_init+0x1a33>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bf4:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f0102bfb:	f0 
f0102bfc:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c03:	00 
f0102c04:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0102c0b:	e8 ae d4 ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c10:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c17:	03 03 03 
f0102c1a:	74 24                	je     f0102c40 <mem_init+0x1a63>
f0102c1c:	c7 44 24 0c b0 53 10 	movl   $0xf01053b0,0xc(%esp)
f0102c23:	f0 
f0102c24:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102c2b:	f0 
f0102c2c:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102c33:	00 
f0102c34:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102c3b:	e8 7e d4 ff ff       	call   f01000be <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c47:	00 
f0102c48:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102c4d:	89 04 24             	mov    %eax,(%esp)
f0102c50:	e8 85 e4 ff ff       	call   f01010da <page_remove>
	assert(pp2->pp_ref == 0);
f0102c55:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c5a:	74 24                	je     f0102c80 <mem_init+0x1aa3>
f0102c5c:	c7 44 24 0c 7f 56 10 	movl   $0xf010567f,0xc(%esp)
f0102c63:	f0 
f0102c64:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102c6b:	f0 
f0102c6c:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102c73:	00 
f0102c74:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102c7b:	e8 3e d4 ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c80:	a1 28 cc 17 f0       	mov    0xf017cc28,%eax
f0102c85:	8b 08                	mov    (%eax),%ecx
f0102c87:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c8d:	89 da                	mov    %ebx,%edx
f0102c8f:	2b 15 2c cc 17 f0    	sub    0xf017cc2c,%edx
f0102c95:	c1 fa 03             	sar    $0x3,%edx
f0102c98:	c1 e2 0c             	shl    $0xc,%edx
f0102c9b:	39 d1                	cmp    %edx,%ecx
f0102c9d:	74 24                	je     f0102cc3 <mem_init+0x1ae6>
f0102c9f:	c7 44 24 0c 2c 4f 10 	movl   $0xf0104f2c,0xc(%esp)
f0102ca6:	f0 
f0102ca7:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102cae:	f0 
f0102caf:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102cb6:	00 
f0102cb7:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102cbe:	e8 fb d3 ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f0102cc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cc9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cce:	74 24                	je     f0102cf4 <mem_init+0x1b17>
f0102cd0:	c7 44 24 0c 36 56 10 	movl   $0xf0105636,0xc(%esp)
f0102cd7:	f0 
f0102cd8:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0102cdf:	f0 
f0102ce0:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102ce7:	00 
f0102ce8:	c7 04 24 3d 54 10 f0 	movl   $0xf010543d,(%esp)
f0102cef:	e8 ca d3 ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0102cf4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cfa:	89 1c 24             	mov    %ebx,(%esp)
f0102cfd:	e8 b9 e1 ff ff       	call   f0100ebb <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d02:	c7 04 24 dc 53 10 f0 	movl   $0xf01053dc,(%esp)
f0102d09:	e8 6c 05 00 00       	call   f010327a <cprintf>
f0102d0e:	eb 45                	jmp    f0102d55 <mem_init+0x1b78>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d10:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d16:	e8 b5 db ff ff       	call   f01008d0 <check_va2pa>
f0102d1b:	e9 86 fa ff ff       	jmp    f01027a6 <mem_init+0x15c9>
f0102d20:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d25:	89 d8                	mov    %ebx,%eax
f0102d27:	e8 a4 db ff ff       	call   f01008d0 <check_va2pa>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d2c:	be 00 80 11 00       	mov    $0x118000,%esi
f0102d31:	bf 00 80 ff df       	mov    $0xdfff8000,%edi
f0102d36:	81 ef 00 00 11 f0    	sub    $0xf0110000,%edi
f0102d3c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0102d3f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102d42:	e9 5f fa ff ff       	jmp    f01027a6 <mem_init+0x15c9>
<<<<<<< HEAD
*/
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d47:	89 f2                	mov    %esi,%edx
f0102d49:	89 d8                	mov    %ebx,%eax
f0102d4b:	e8 80 db ff ff       	call   f01008d0 <check_va2pa>
f0102d50:	e9 ba f9 ff ff       	jmp    f010270f <mem_init+0x1532>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d55:	83 c4 3c             	add    $0x3c,%esp
f0102d58:	5b                   	pop    %ebx
f0102d59:	5e                   	pop    %esi
f0102d5a:	5f                   	pop    %edi
f0102d5b:	5d                   	pop    %ebp
f0102d5c:	c3                   	ret    

f0102d5d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d5d:	55                   	push   %ebp
f0102d5e:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102d60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d65:	5d                   	pop    %ebp
f0102d66:	c3                   	ret    

f0102d67 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d67:	55                   	push   %ebp
f0102d68:	89 e5                	mov    %esp,%ebp
f0102d6a:	53                   	push   %ebx
f0102d6b:	83 ec 14             	sub    $0x14,%esp
f0102d6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d71:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d74:	83 c8 04             	or     $0x4,%eax
f0102d77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d7b:	8b 45 10             	mov    0x10(%ebp),%eax
f0102d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d89:	89 1c 24             	mov    %ebx,(%esp)
f0102d8c:	e8 cc ff ff ff       	call   f0102d5d <user_mem_check>
f0102d91:	85 c0                	test   %eax,%eax
f0102d93:	79 23                	jns    f0102db8 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d9c:	00 
f0102d9d:	8b 43 48             	mov    0x48(%ebx),%eax
f0102da0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102da4:	c7 04 24 08 54 10 f0 	movl   $0xf0105408,(%esp)
f0102dab:	e8 ca 04 00 00       	call   f010327a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102db0:	89 1c 24             	mov    %ebx,(%esp)
f0102db3:	e8 d7 03 00 00       	call   f010318f <env_destroy>
	}
}
f0102db8:	83 c4 14             	add    $0x14,%esp
f0102dbb:	5b                   	pop    %ebx
f0102dbc:	5d                   	pop    %ebp
f0102dbd:	c3                   	ret    
	...

f0102dc0 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102dc0:	55                   	push   %ebp
f0102dc1:	89 e5                	mov    %esp,%ebp
f0102dc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102dc9:	85 c0                	test   %eax,%eax
f0102dcb:	75 11                	jne    f0102dde <envid2env+0x1e>
		*env_store = curenv;
f0102dcd:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f0102dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102dd5:	89 02                	mov    %eax,(%edx)
		return 0;
f0102dd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ddc:	eb 5e                	jmp    f0102e3c <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102dde:	89 c2                	mov    %eax,%edx
f0102de0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102de6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102de9:	c1 e2 05             	shl    $0x5,%edx
f0102dec:	03 15 90 bf 17 f0    	add    0xf017bf90,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102df2:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102df6:	74 05                	je     f0102dfd <envid2env+0x3d>
f0102df8:	39 42 48             	cmp    %eax,0x48(%edx)
f0102dfb:	74 10                	je     f0102e0d <envid2env+0x4d>
		*env_store = 0;
f0102dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e00:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102e06:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e0b:	eb 2f                	jmp    f0102e3c <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e0d:	84 c9                	test   %cl,%cl
f0102e0f:	74 21                	je     f0102e32 <envid2env+0x72>
f0102e11:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f0102e16:	39 c2                	cmp    %eax,%edx
f0102e18:	74 18                	je     f0102e32 <envid2env+0x72>
f0102e1a:	8b 48 48             	mov    0x48(%eax),%ecx
f0102e1d:	39 4a 4c             	cmp    %ecx,0x4c(%edx)
f0102e20:	74 10                	je     f0102e32 <envid2env+0x72>
		*env_store = 0;
f0102e22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e2b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e30:	eb 0a                	jmp    f0102e3c <envid2env+0x7c>
	}

	*env_store = e;
f0102e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e35:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e3c:	5d                   	pop    %ebp
f0102e3d:	c3                   	ret    

f0102e3e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102e3e:	55                   	push   %ebp
f0102e3f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102e41:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102e46:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102e49:	b8 23 00 00 00       	mov    $0x23,%eax
f0102e4e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102e50:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102e52:	b0 10                	mov    $0x10,%al
f0102e54:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102e56:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102e58:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102e5a:	ea 61 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102e61
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102e61:	b0 00                	mov    $0x0,%al
f0102e63:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102e66:	5d                   	pop    %ebp
f0102e67:	c3                   	ret    

f0102e68 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102e68:	55                   	push   %ebp
f0102e69:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102e6b:	e8 ce ff ff ff       	call   f0102e3e <env_init_percpu>
}
f0102e70:	5d                   	pop    %ebp
f0102e71:	c3                   	ret    

f0102e72 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e72:	55                   	push   %ebp
f0102e73:	89 e5                	mov    %esp,%ebp
f0102e75:	53                   	push   %ebx
f0102e76:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e79:	8b 1d 94 bf 17 f0    	mov    0xf017bf94,%ebx
f0102e7f:	85 db                	test   %ebx,%ebx
f0102e81:	0f 84 08 01 00 00    	je     f0102f8f <env_alloc+0x11d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102e8e:	e8 9e df ff ff       	call   f0100e31 <page_alloc>
f0102e93:	85 c0                	test   %eax,%eax
f0102e95:	0f 84 fb 00 00 00    	je     f0102f96 <env_alloc+0x124>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102e9b:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ea3:	77 20                	ja     f0102ec5 <env_alloc+0x53>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ea9:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f0102eb0:	f0 
f0102eb1:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102eb8:	00 
f0102eb9:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f0102ec0:	e8 f9 d1 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ec5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ecb:	83 ca 05             	or     $0x5,%edx
f0102ece:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ed4:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ed7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102edc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ee1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ee6:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ee9:	89 da                	mov    %ebx,%edx
f0102eeb:	2b 15 90 bf 17 f0    	sub    0xf017bf90,%edx
f0102ef1:	c1 fa 05             	sar    $0x5,%edx
f0102ef4:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102efa:	09 d0                	or     %edx,%eax
f0102efc:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102eff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f02:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102f05:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102f0c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f13:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f1a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102f21:	00 
f0102f22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f29:	00 
f0102f2a:	89 1c 24             	mov    %ebx,(%esp)
f0102f2d:	e8 f3 13 00 00       	call   f0104325 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f32:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f38:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f3e:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f44:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f4b:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102f51:	8b 43 44             	mov    0x44(%ebx),%eax
f0102f54:	a3 94 bf 17 f0       	mov    %eax,0xf017bf94
	*newenv_store = e;
f0102f59:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f5c:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102f5e:	8b 53 48             	mov    0x48(%ebx),%edx
f0102f61:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f0102f66:	85 c0                	test   %eax,%eax
f0102f68:	74 05                	je     f0102f6f <env_alloc+0xfd>
f0102f6a:	8b 40 48             	mov    0x48(%eax),%eax
f0102f6d:	eb 05                	jmp    f0102f74 <env_alloc+0x102>
f0102f6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f74:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102f78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f7c:	c7 04 24 5d 57 10 f0 	movl   $0xf010575d,(%esp)
f0102f83:	e8 f2 02 00 00       	call   f010327a <cprintf>
	return 0;
f0102f88:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8d:	eb 0c                	jmp    f0102f9b <env_alloc+0x129>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102f8f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102f94:	eb 05                	jmp    f0102f9b <env_alloc+0x129>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102f96:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102f9b:	83 c4 14             	add    $0x14,%esp
f0102f9e:	5b                   	pop    %ebx
f0102f9f:	5d                   	pop    %ebp
f0102fa0:	c3                   	ret    

f0102fa1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102fa1:	55                   	push   %ebp
f0102fa2:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102fa4:	5d                   	pop    %ebp
f0102fa5:	c3                   	ret    

f0102fa6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102fa6:	55                   	push   %ebp
f0102fa7:	89 e5                	mov    %esp,%ebp
f0102fa9:	57                   	push   %edi
f0102faa:	56                   	push   %esi
f0102fab:	53                   	push   %ebx
f0102fac:	83 ec 2c             	sub    $0x2c,%esp
f0102faf:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102fb2:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f0102fb7:	39 c7                	cmp    %eax,%edi
f0102fb9:	75 37                	jne    f0102ff2 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0102fbb:	8b 15 28 cc 17 f0    	mov    0xf017cc28,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fc7:	77 20                	ja     f0102fe9 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fcd:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0102fdc:	00 
f0102fdd:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f0102fe4:	e8 d5 d0 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102fe9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102fef:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ff2:	8b 57 48             	mov    0x48(%edi),%edx
f0102ff5:	85 c0                	test   %eax,%eax
f0102ff7:	74 05                	je     f0102ffe <env_free+0x58>
f0102ff9:	8b 40 48             	mov    0x48(%eax),%eax
f0102ffc:	eb 05                	jmp    f0103003 <env_free+0x5d>
f0102ffe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103003:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010300b:	c7 04 24 72 57 10 f0 	movl   $0xf0105772,(%esp)
f0103012:	e8 63 02 00 00       	call   f010327a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103017:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
f010301e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103021:	c1 e0 02             	shl    $0x2,%eax
f0103024:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103027:	8b 47 5c             	mov    0x5c(%edi),%eax
f010302a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010302d:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103030:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103036:	0f 84 b7 00 00 00    	je     f01030f3 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010303c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103042:	89 f0                	mov    %esi,%eax
f0103044:	c1 e8 0c             	shr    $0xc,%eax
f0103047:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010304a:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f0103050:	72 20                	jb     f0103072 <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103052:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103056:	c7 44 24 08 ec 4c 10 	movl   $0xf0104cec,0x8(%esp)
f010305d:	f0 
f010305e:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103065:	00 
f0103066:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f010306d:	e8 4c d0 ff ff       	call   f01000be <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103072:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103075:	c1 e2 16             	shl    $0x16,%edx
f0103078:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010307b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103080:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103087:	01 
f0103088:	74 17                	je     f01030a1 <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010308a:	89 d8                	mov    %ebx,%eax
f010308c:	c1 e0 0c             	shl    $0xc,%eax
f010308f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103092:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103096:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103099:	89 04 24             	mov    %eax,(%esp)
f010309c:	e8 39 e0 ff ff       	call   f01010da <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030a1:	83 c3 01             	add    $0x1,%ebx
f01030a4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01030aa:	75 d4                	jne    f0103080 <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01030ac:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030af:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01030b2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01030bc:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f01030c2:	72 1c                	jb     f01030e0 <env_free+0x13a>
		panic("pa2page called with invalid pa");
f01030c4:	c7 44 24 08 d4 4d 10 	movl   $0xf0104dd4,0x8(%esp)
f01030cb:	f0 
f01030cc:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01030d3:	00 
f01030d4:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f01030db:	e8 de cf ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f01030e0:	a1 2c cc 17 f0       	mov    0xf017cc2c,%eax
f01030e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01030e8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f01030eb:	89 04 24             	mov    %eax,(%esp)
f01030ee:	e8 e4 dd ff ff       	call   f0100ed7 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01030f3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01030f7:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01030fe:	0f 85 1a ff ff ff    	jne    f010301e <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103104:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103107:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010310c:	77 20                	ja     f010312e <env_free+0x188>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103112:	c7 44 24 08 30 4e 10 	movl   $0xf0104e30,0x8(%esp)
f0103119:	f0 
f010311a:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0103121:	00 
f0103122:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f0103129:	e8 90 cf ff ff       	call   f01000be <_panic>
	e->env_pgdir = 0;
f010312e:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103135:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010313a:	c1 e8 0c             	shr    $0xc,%eax
f010313d:	3b 05 24 cc 17 f0    	cmp    0xf017cc24,%eax
f0103143:	72 1c                	jb     f0103161 <env_free+0x1bb>
		panic("pa2page called with invalid pa");
f0103145:	c7 44 24 08 d4 4d 10 	movl   $0xf0104dd4,0x8(%esp)
f010314c:	f0 
f010314d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103154:	00 
f0103155:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f010315c:	e8 5d cf ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f0103161:	8b 15 2c cc 17 f0    	mov    0xf017cc2c,%edx
f0103167:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f010316a:	89 04 24             	mov    %eax,(%esp)
f010316d:	e8 65 dd ff ff       	call   f0100ed7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103172:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103179:	a1 94 bf 17 f0       	mov    0xf017bf94,%eax
f010317e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103181:	89 3d 94 bf 17 f0    	mov    %edi,0xf017bf94
}
f0103187:	83 c4 2c             	add    $0x2c,%esp
f010318a:	5b                   	pop    %ebx
f010318b:	5e                   	pop    %esi
f010318c:	5f                   	pop    %edi
f010318d:	5d                   	pop    %ebp
f010318e:	c3                   	ret    

f010318f <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010318f:	55                   	push   %ebp
f0103190:	89 e5                	mov    %esp,%ebp
f0103192:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103195:	8b 45 08             	mov    0x8(%ebp),%eax
f0103198:	89 04 24             	mov    %eax,(%esp)
f010319b:	e8 06 fe ff ff       	call   f0102fa6 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01031a0:	c7 04 24 1c 57 10 f0 	movl   $0xf010571c,(%esp)
f01031a7:	e8 ce 00 00 00       	call   f010327a <cprintf>
	while (1)
		monitor(NULL);
f01031ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031b3:	e8 c1 d5 ff ff       	call   f0100779 <monitor>
f01031b8:	eb f2                	jmp    f01031ac <env_destroy+0x1d>

f01031ba <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01031ba:	55                   	push   %ebp
f01031bb:	89 e5                	mov    %esp,%ebp
f01031bd:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01031c0:	8b 65 08             	mov    0x8(%ebp),%esp
f01031c3:	61                   	popa   
f01031c4:	07                   	pop    %es
f01031c5:	1f                   	pop    %ds
f01031c6:	83 c4 08             	add    $0x8,%esp
f01031c9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01031ca:	c7 44 24 08 88 57 10 	movl   $0xf0105788,0x8(%esp)
f01031d1:	f0 
f01031d2:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01031d9:	00 
f01031da:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f01031e1:	e8 d8 ce ff ff       	call   f01000be <_panic>

f01031e6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01031e6:	55                   	push   %ebp
f01031e7:	89 e5                	mov    %esp,%ebp
f01031e9:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01031ec:	c7 44 24 08 94 57 10 	movl   $0xf0105794,0x8(%esp)
f01031f3:	f0 
f01031f4:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f01031fb:	00 
f01031fc:	c7 04 24 52 57 10 f0 	movl   $0xf0105752,(%esp)
f0103203:	e8 b6 ce ff ff       	call   f01000be <_panic>

f0103208 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103208:	55                   	push   %ebp
f0103209:	89 e5                	mov    %esp,%ebp
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010320b:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010320f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103214:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103215:	b2 71                	mov    $0x71,%dl
f0103217:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103218:	0f b6 c0             	movzbl %al,%eax
}
f010321b:	5d                   	pop    %ebp
f010321c:	c3                   	ret    

f010321d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010321d:	55                   	push   %ebp
f010321e:	89 e5                	mov    %esp,%ebp
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103220:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103224:	ba 70 00 00 00       	mov    $0x70,%edx
f0103229:	ee                   	out    %al,(%dx)
f010322a:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f010322e:	b2 71                	mov    $0x71,%dl
f0103230:	ee                   	out    %al,(%dx)
f0103231:	5d                   	pop    %ebp
f0103232:	c3                   	ret    
	...

f0103234 <putch>:
#include <inc/stdarg.h>

//print in kern/print.c is calling printfmt in lib/
static void
putch(int ch, int *cnt)
{
f0103234:	55                   	push   %ebp
f0103235:	89 e5                	mov    %esp,%ebp
f0103237:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010323a:	8b 45 08             	mov    0x8(%ebp),%eax
f010323d:	89 04 24             	mov    %eax,(%esp)
f0103240:	e8 e4 d3 ff ff       	call   f0100629 <cputchar>
	*cnt++;
}
f0103245:	c9                   	leave  
f0103246:	c3                   	ret    

f0103247 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103247:	55                   	push   %ebp
f0103248:	89 e5                	mov    %esp,%ebp
f010324a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010324d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103254:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103257:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010325b:	8b 45 08             	mov    0x8(%ebp),%eax
f010325e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103262:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103265:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103269:	c7 04 24 34 32 10 f0 	movl   $0xf0103234,(%esp)
f0103270:	e8 4d 09 00 00       	call   f0103bc2 <vprintfmt>
	return cnt;
}
f0103275:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103278:	c9                   	leave  
f0103279:	c3                   	ret    

f010327a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010327a:	55                   	push   %ebp
f010327b:	89 e5                	mov    %esp,%ebp
f010327d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103280:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103283:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103287:	8b 45 08             	mov    0x8(%ebp),%eax
f010328a:	89 04 24             	mov    %eax,(%esp)
f010328d:	e8 b5 ff ff ff       	call   f0103247 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103292:	c9                   	leave  
f0103293:	c3                   	ret    

f0103294 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103294:	55                   	push   %ebp
f0103295:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103297:	c7 05 a4 c7 17 f0 00 	movl   $0xf0000000,0xf017c7a4
f010329e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01032a1:	66 c7 05 a8 c7 17 f0 	movw   $0x10,0xf017c7a8
f01032a8:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01032aa:	66 c7 05 48 a3 11 f0 	movw   $0x68,0xf011a348
f01032b1:	68 00 
f01032b3:	b8 a0 c7 17 f0       	mov    $0xf017c7a0,%eax
f01032b8:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f01032be:	89 c2                	mov    %eax,%edx
f01032c0:	c1 ea 10             	shr    $0x10,%edx
f01032c3:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f01032c9:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f01032d0:	c1 e8 18             	shr    $0x18,%eax
f01032d3:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01032d8:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01032df:	b8 28 00 00 00       	mov    $0x28,%eax
f01032e4:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01032e7:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f01032ec:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01032ef:	5d                   	pop    %ebp
f01032f0:	c3                   	ret    

f01032f1 <trap_init>:
}


void
trap_init(void)
{
f01032f1:	55                   	push   %ebp
f01032f2:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f01032f4:	e8 9b ff ff ff       	call   f0103294 <trap_init_percpu>
}
f01032f9:	5d                   	pop    %ebp
f01032fa:	c3                   	ret    

f01032fb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01032fb:	55                   	push   %ebp
f01032fc:	89 e5                	mov    %esp,%ebp
f01032fe:	53                   	push   %ebx
f01032ff:	83 ec 14             	sub    $0x14,%esp
f0103302:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103305:	8b 03                	mov    (%ebx),%eax
f0103307:	89 44 24 04          	mov    %eax,0x4(%esp)
f010330b:	c7 04 24 b0 57 10 f0 	movl   $0xf01057b0,(%esp)
f0103312:	e8 63 ff ff ff       	call   f010327a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103317:	8b 43 04             	mov    0x4(%ebx),%eax
f010331a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010331e:	c7 04 24 bf 57 10 f0 	movl   $0xf01057bf,(%esp)
f0103325:	e8 50 ff ff ff       	call   f010327a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010332a:	8b 43 08             	mov    0x8(%ebx),%eax
f010332d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103331:	c7 04 24 ce 57 10 f0 	movl   $0xf01057ce,(%esp)
f0103338:	e8 3d ff ff ff       	call   f010327a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010333d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103340:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103344:	c7 04 24 dd 57 10 f0 	movl   $0xf01057dd,(%esp)
f010334b:	e8 2a ff ff ff       	call   f010327a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103350:	8b 43 10             	mov    0x10(%ebx),%eax
f0103353:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103357:	c7 04 24 ec 57 10 f0 	movl   $0xf01057ec,(%esp)
f010335e:	e8 17 ff ff ff       	call   f010327a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103363:	8b 43 14             	mov    0x14(%ebx),%eax
f0103366:	89 44 24 04          	mov    %eax,0x4(%esp)
f010336a:	c7 04 24 fb 57 10 f0 	movl   $0xf01057fb,(%esp)
f0103371:	e8 04 ff ff ff       	call   f010327a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103376:	8b 43 18             	mov    0x18(%ebx),%eax
f0103379:	89 44 24 04          	mov    %eax,0x4(%esp)
f010337d:	c7 04 24 0a 58 10 f0 	movl   $0xf010580a,(%esp)
f0103384:	e8 f1 fe ff ff       	call   f010327a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103389:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010338c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103390:	c7 04 24 19 58 10 f0 	movl   $0xf0105819,(%esp)
f0103397:	e8 de fe ff ff       	call   f010327a <cprintf>
}
f010339c:	83 c4 14             	add    $0x14,%esp
f010339f:	5b                   	pop    %ebx
f01033a0:	5d                   	pop    %ebp
f01033a1:	c3                   	ret    

f01033a2 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01033a2:	55                   	push   %ebp
f01033a3:	89 e5                	mov    %esp,%ebp
f01033a5:	56                   	push   %esi
f01033a6:	53                   	push   %ebx
f01033a7:	83 ec 10             	sub    $0x10,%esp
f01033aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01033ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033b1:	c7 04 24 4f 59 10 f0 	movl   $0xf010594f,(%esp)
f01033b8:	e8 bd fe ff ff       	call   f010327a <cprintf>
	print_regs(&tf->tf_regs);
f01033bd:	89 1c 24             	mov    %ebx,(%esp)
f01033c0:	e8 36 ff ff ff       	call   f01032fb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033c5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033cd:	c7 04 24 6a 58 10 f0 	movl   $0xf010586a,(%esp)
f01033d4:	e8 a1 fe ff ff       	call   f010327a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033d9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033e1:	c7 04 24 7d 58 10 f0 	movl   $0xf010587d,(%esp)
f01033e8:	e8 8d fe ff ff       	call   f010327a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033ed:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01033f0:	83 f8 13             	cmp    $0x13,%eax
f01033f3:	77 09                	ja     f01033fe <print_trapframe+0x5c>
		return excnames[trapno];
f01033f5:	8b 14 85 20 5b 10 f0 	mov    -0xfefa4e0(,%eax,4),%edx
f01033fc:	eb 10                	jmp    f010340e <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f01033fe:	83 f8 30             	cmp    $0x30,%eax
f0103401:	ba 28 58 10 f0       	mov    $0xf0105828,%edx
f0103406:	b9 34 58 10 f0       	mov    $0xf0105834,%ecx
f010340b:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010340e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103412:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103416:	c7 04 24 90 58 10 f0 	movl   $0xf0105890,(%esp)
f010341d:	e8 58 fe ff ff       	call   f010327a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103422:	3b 1d 08 c8 17 f0    	cmp    0xf017c808,%ebx
f0103428:	75 19                	jne    f0103443 <print_trapframe+0xa1>
f010342a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010342e:	75 13                	jne    f0103443 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103430:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103433:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103437:	c7 04 24 a2 58 10 f0 	movl   $0xf01058a2,(%esp)
f010343e:	e8 37 fe ff ff       	call   f010327a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103443:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103446:	89 44 24 04          	mov    %eax,0x4(%esp)
f010344a:	c7 04 24 b1 58 10 f0 	movl   $0xf01058b1,(%esp)
f0103451:	e8 24 fe ff ff       	call   f010327a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103456:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010345a:	75 51                	jne    f01034ad <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010345c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010345f:	89 c2                	mov    %eax,%edx
f0103461:	83 e2 01             	and    $0x1,%edx
f0103464:	ba 43 58 10 f0       	mov    $0xf0105843,%edx
f0103469:	b9 4e 58 10 f0       	mov    $0xf010584e,%ecx
f010346e:	0f 45 ca             	cmovne %edx,%ecx
f0103471:	89 c2                	mov    %eax,%edx
f0103473:	83 e2 02             	and    $0x2,%edx
f0103476:	ba 5a 58 10 f0       	mov    $0xf010585a,%edx
f010347b:	be 60 58 10 f0       	mov    $0xf0105860,%esi
f0103480:	0f 44 d6             	cmove  %esi,%edx
f0103483:	83 e0 04             	and    $0x4,%eax
f0103486:	b8 65 58 10 f0       	mov    $0xf0105865,%eax
f010348b:	be 7a 59 10 f0       	mov    $0xf010597a,%esi
f0103490:	0f 44 c6             	cmove  %esi,%eax
f0103493:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103497:	89 54 24 08          	mov    %edx,0x8(%esp)
f010349b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010349f:	c7 04 24 bf 58 10 f0 	movl   $0xf01058bf,(%esp)
f01034a6:	e8 cf fd ff ff       	call   f010327a <cprintf>
f01034ab:	eb 0c                	jmp    f01034b9 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01034ad:	c7 04 24 e7 56 10 f0 	movl   $0xf01056e7,(%esp)
f01034b4:	e8 c1 fd ff ff       	call   f010327a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01034b9:	8b 43 30             	mov    0x30(%ebx),%eax
f01034bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034c0:	c7 04 24 ce 58 10 f0 	movl   $0xf01058ce,(%esp)
f01034c7:	e8 ae fd ff ff       	call   f010327a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01034cc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034d4:	c7 04 24 dd 58 10 f0 	movl   $0xf01058dd,(%esp)
f01034db:	e8 9a fd ff ff       	call   f010327a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01034e0:	8b 43 38             	mov    0x38(%ebx),%eax
f01034e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e7:	c7 04 24 f0 58 10 f0 	movl   $0xf01058f0,(%esp)
f01034ee:	e8 87 fd ff ff       	call   f010327a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01034f3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034f7:	74 27                	je     f0103520 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01034f9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01034fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103500:	c7 04 24 ff 58 10 f0 	movl   $0xf01058ff,(%esp)
f0103507:	e8 6e fd ff ff       	call   f010327a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010350c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103510:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103514:	c7 04 24 0e 59 10 f0 	movl   $0xf010590e,(%esp)
f010351b:	e8 5a fd ff ff       	call   f010327a <cprintf>
	}
}
f0103520:	83 c4 10             	add    $0x10,%esp
f0103523:	5b                   	pop    %ebx
f0103524:	5e                   	pop    %esi
f0103525:	5d                   	pop    %ebp
f0103526:	c3                   	ret    

f0103527 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103527:	55                   	push   %ebp
f0103528:	89 e5                	mov    %esp,%ebp
f010352a:	57                   	push   %edi
f010352b:	56                   	push   %esi
f010352c:	83 ec 10             	sub    $0x10,%esp
f010352f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103532:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103533:	9c                   	pushf  
f0103534:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103535:	f6 c4 02             	test   $0x2,%ah
f0103538:	74 24                	je     f010355e <trap+0x37>
f010353a:	c7 44 24 0c 21 59 10 	movl   $0xf0105921,0xc(%esp)
f0103541:	f0 
f0103542:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0103549:	f0 
f010354a:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f0103551:	00 
f0103552:	c7 04 24 3a 59 10 f0 	movl   $0xf010593a,(%esp)
f0103559:	e8 60 cb ff ff       	call   f01000be <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010355e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103562:	c7 04 24 46 59 10 f0 	movl   $0xf0105946,(%esp)
f0103569:	e8 0c fd ff ff       	call   f010327a <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010356e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103572:	83 e0 03             	and    $0x3,%eax
f0103575:	66 83 f8 03          	cmp    $0x3,%ax
f0103579:	75 3c                	jne    f01035b7 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f010357b:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f0103580:	85 c0                	test   %eax,%eax
f0103582:	75 24                	jne    f01035a8 <trap+0x81>
f0103584:	c7 44 24 0c 61 59 10 	movl   $0xf0105961,0xc(%esp)
f010358b:	f0 
f010358c:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0103593:	f0 
f0103594:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f010359b:	00 
f010359c:	c7 04 24 3a 59 10 f0 	movl   $0xf010593a,(%esp)
f01035a3:	e8 16 cb ff ff       	call   f01000be <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01035a8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01035ad:	89 c7                	mov    %eax,%edi
f01035af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01035b1:	8b 35 8c bf 17 f0    	mov    0xf017bf8c,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01035b7:	89 35 08 c8 17 f0    	mov    %esi,0xf017c808
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01035bd:	89 34 24             	mov    %esi,(%esp)
f01035c0:	e8 dd fd ff ff       	call   f01033a2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01035c5:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01035ca:	75 1c                	jne    f01035e8 <trap+0xc1>
		panic("unhandled trap in kernel");
f01035cc:	c7 44 24 08 68 59 10 	movl   $0xf0105968,0x8(%esp)
f01035d3:	f0 
f01035d4:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f01035db:	00 
f01035dc:	c7 04 24 3a 59 10 f0 	movl   $0xf010593a,(%esp)
f01035e3:	e8 d6 ca ff ff       	call   f01000be <_panic>
	else {
		env_destroy(curenv);
f01035e8:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f01035ed:	89 04 24             	mov    %eax,(%esp)
f01035f0:	e8 9a fb ff ff       	call   f010318f <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01035f5:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f01035fa:	85 c0                	test   %eax,%eax
f01035fc:	74 06                	je     f0103604 <trap+0xdd>
f01035fe:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103602:	74 24                	je     f0103628 <trap+0x101>
f0103604:	c7 44 24 0c c4 5a 10 	movl   $0xf0105ac4,0xc(%esp)
f010360b:	f0 
f010360c:	c7 44 24 08 7d 54 10 	movl   $0xf010547d,0x8(%esp)
f0103613:	f0 
f0103614:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f010361b:	00 
f010361c:	c7 04 24 3a 59 10 f0 	movl   $0xf010593a,(%esp)
f0103623:	e8 96 ca ff ff       	call   f01000be <_panic>
	env_run(curenv);
f0103628:	89 04 24             	mov    %eax,(%esp)
f010362b:	e8 b6 fb ff ff       	call   f01031e6 <env_run>

f0103630 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103630:	55                   	push   %ebp
f0103631:	89 e5                	mov    %esp,%ebp
f0103633:	53                   	push   %ebx
f0103634:	83 ec 14             	sub    $0x14,%esp
f0103637:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010363a:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010363d:	8b 53 30             	mov    0x30(%ebx),%edx
f0103640:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103644:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103648:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010364d:	8b 40 48             	mov    0x48(%eax),%eax
f0103650:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103654:	c7 04 24 f0 5a 10 f0 	movl   $0xf0105af0,(%esp)
f010365b:	e8 1a fc ff ff       	call   f010327a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103660:	89 1c 24             	mov    %ebx,(%esp)
f0103663:	e8 3a fd ff ff       	call   f01033a2 <print_trapframe>
	env_destroy(curenv);
f0103668:	a1 8c bf 17 f0       	mov    0xf017bf8c,%eax
f010366d:	89 04 24             	mov    %eax,(%esp)
f0103670:	e8 1a fb ff ff       	call   f010318f <env_destroy>
}
f0103675:	83 c4 14             	add    $0x14,%esp
f0103678:	5b                   	pop    %ebx
f0103679:	5d                   	pop    %ebp
f010367a:	c3                   	ret    
	...

f010367c <syscall>:
f010367c:	55                   	push   %ebp
f010367d:	89 e5                	mov    %esp,%ebp
f010367f:	83 ec 18             	sub    $0x18,%esp
f0103682:	c7 44 24 08 70 5b 10 	movl   $0xf0105b70,0x8(%esp)
f0103689:	f0 
f010368a:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0103691:	00 
f0103692:	c7 04 24 88 5b 10 f0 	movl   $0xf0105b88,(%esp)
f0103699:	e8 20 ca ff ff       	call   f01000be <_panic>
	...

f01036a0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01036a0:	55                   	push   %ebp
f01036a1:	89 e5                	mov    %esp,%ebp
f01036a3:	57                   	push   %edi
f01036a4:	56                   	push   %esi
f01036a5:	53                   	push   %ebx
f01036a6:	83 ec 14             	sub    $0x14,%esp
f01036a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01036ac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01036af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01036b2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01036b5:	8b 1a                	mov    (%edx),%ebx
f01036b7:	8b 01                	mov    (%ecx),%eax
f01036b9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01036bc:	39 c3                	cmp    %eax,%ebx
f01036be:	0f 8f 9f 00 00 00    	jg     f0103763 <stab_binsearch+0xc3>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01036c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01036ce:	01 d8                	add    %ebx,%eax
f01036d0:	89 c7                	mov    %eax,%edi
f01036d2:	c1 ef 1f             	shr    $0x1f,%edi
f01036d5:	01 c7                	add    %eax,%edi
f01036d7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01036d9:	39 df                	cmp    %ebx,%edi
f01036db:	0f 8c ce 00 00 00    	jl     f01037af <stab_binsearch+0x10f>
f01036e1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01036e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01036e7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01036ec:	39 f0                	cmp    %esi,%eax
f01036ee:	0f 84 c0 00 00 00    	je     f01037b4 <stab_binsearch+0x114>
f01036f4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01036f8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01036fc:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01036fe:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103701:	39 d8                	cmp    %ebx,%eax
f0103703:	0f 8c a6 00 00 00    	jl     f01037af <stab_binsearch+0x10f>
f0103709:	0f b6 0a             	movzbl (%edx),%ecx
f010370c:	83 ea 0c             	sub    $0xc,%edx
f010370f:	39 f1                	cmp    %esi,%ecx
f0103711:	75 eb                	jne    f01036fe <stab_binsearch+0x5e>
f0103713:	e9 9e 00 00 00       	jmp    f01037b6 <stab_binsearch+0x116>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103718:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010371b:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010371d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103720:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103727:	eb 2b                	jmp    f0103754 <stab_binsearch+0xb4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103729:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010372c:	76 14                	jbe    f0103742 <stab_binsearch+0xa2>
			*region_right = m - 1;
f010372e:	83 e8 01             	sub    $0x1,%eax
f0103731:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103734:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103737:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103739:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103740:	eb 12                	jmp    f0103754 <stab_binsearch+0xb4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103742:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103745:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103747:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010374b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010374d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103754:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f0103757:	0f 8e 6e ff ff ff    	jle    f01036cb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010375d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103761:	75 0f                	jne    f0103772 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0103763:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103766:	8b 02                	mov    (%edx),%eax
f0103768:	83 e8 01             	sub    $0x1,%eax
f010376b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010376e:	89 01                	mov    %eax,(%ecx)
f0103770:	eb 5c                	jmp    f01037ce <stab_binsearch+0x12e>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103772:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103775:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103777:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010377a:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010377c:	39 c8                	cmp    %ecx,%eax
f010377e:	7e 28                	jle    f01037a8 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f0103780:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103783:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103786:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f010378b:	39 f2                	cmp    %esi,%edx
f010378d:	74 19                	je     f01037a8 <stab_binsearch+0x108>
f010378f:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103793:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103797:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010379a:	39 c8                	cmp    %ecx,%eax
f010379c:	7e 0a                	jle    f01037a8 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f010379e:	0f b6 1a             	movzbl (%edx),%ebx
f01037a1:	83 ea 0c             	sub    $0xc,%edx
f01037a4:	39 f3                	cmp    %esi,%ebx
f01037a6:	75 ef                	jne    f0103797 <stab_binsearch+0xf7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01037a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01037ab:	89 02                	mov    %eax,(%edx)
f01037ad:	eb 1f                	jmp    f01037ce <stab_binsearch+0x12e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01037af:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01037b2:	eb a0                	jmp    f0103754 <stab_binsearch+0xb4>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01037b4:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01037b6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01037b9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01037bc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01037c0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01037c3:	0f 82 4f ff ff ff    	jb     f0103718 <stab_binsearch+0x78>
f01037c9:	e9 5b ff ff ff       	jmp    f0103729 <stab_binsearch+0x89>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01037ce:	83 c4 14             	add    $0x14,%esp
f01037d1:	5b                   	pop    %ebx
f01037d2:	5e                   	pop    %esi
f01037d3:	5f                   	pop    %edi
f01037d4:	5d                   	pop    %ebp
f01037d5:	c3                   	ret    

f01037d6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01037d6:	55                   	push   %ebp
f01037d7:	89 e5                	mov    %esp,%ebp
f01037d9:	57                   	push   %edi
f01037da:	56                   	push   %esi
f01037db:	53                   	push   %ebx
f01037dc:	83 ec 5c             	sub    $0x5c,%esp
f01037df:	8b 75 08             	mov    0x8(%ebp),%esi
f01037e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01037e5:	c7 03 97 5b 10 f0    	movl   $0xf0105b97,(%ebx)
	info->eip_line = 0;
f01037eb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01037f2:	c7 43 08 97 5b 10 f0 	movl   $0xf0105b97,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01037f9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103800:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103803:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010380a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103810:	77 21                	ja     f0103833 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103812:	a1 00 00 20 00       	mov    0x200000,%eax
f0103817:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010381a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010381f:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103825:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0103828:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f010382e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0103831:	eb 1a                	jmp    f010384d <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103833:	c7 45 c0 aa ff 10 f0 	movl   $0xf010ffaa,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010383a:	c7 45 bc 5d d5 10 f0 	movl   $0xf010d55d,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103841:	b8 5c d5 10 f0       	mov    $0xf010d55c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103846:	c7 45 c4 a4 5d 10 f0 	movl   $0xf0105da4,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010384d:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103850:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0103853:	0f 83 bf 01 00 00    	jae    f0103a18 <debuginfo_eip+0x242>
f0103859:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f010385d:	0f 85 bc 01 00 00    	jne    f0103a1f <debuginfo_eip+0x249>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103863:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010386a:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010386d:	c1 f8 02             	sar    $0x2,%eax
f0103870:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103876:	83 e8 01             	sub    $0x1,%eax
f0103879:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010387c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103880:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103887:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010388a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010388d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103890:	e8 0b fe ff ff       	call   f01036a0 <stab_binsearch>
	if (lfile == 0)
f0103895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103898:	85 c0                	test   %eax,%eax
f010389a:	0f 84 86 01 00 00    	je     f0103a26 <debuginfo_eip+0x250>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01038a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01038a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01038a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01038ad:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01038b4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01038b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01038ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01038bd:	e8 de fd ff ff       	call   f01036a0 <stab_binsearch>

	if (lfun <= rfun) {
f01038c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038c5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01038c8:	39 c8                	cmp    %ecx,%eax
f01038ca:	7f 32                	jg     f01038fe <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01038cc:	8d 3c 40             	lea    (%eax,%eax,2),%edi
f01038cf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01038d2:	8d 3c ba             	lea    (%edx,%edi,4),%edi
f01038d5:	8b 17                	mov    (%edi),%edx
f01038d7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01038da:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01038dd:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01038e0:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f01038e3:	73 09                	jae    f01038ee <debuginfo_eip+0x118>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01038e5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01038e8:	03 55 bc             	add    -0x44(%ebp),%edx
f01038eb:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01038ee:	8b 57 08             	mov    0x8(%edi),%edx
f01038f1:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01038f4:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01038f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01038f9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01038fc:	eb 0f                	jmp    f010390d <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01038fe:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103904:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103907:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010390a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010390d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103914:	00 
f0103915:	8b 43 08             	mov    0x8(%ebx),%eax
f0103918:	89 04 24             	mov    %eax,(%esp)
f010391b:	e8 db 09 00 00       	call   f01042fb <strfind>
f0103920:	2b 43 08             	sub    0x8(%ebx),%eax
f0103923:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch( stabs, &lline, &rline, N_SLINE, addr); 
f0103926:	89 74 24 04          	mov    %esi,0x4(%esp)
f010392a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103931:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103934:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103937:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010393a:	e8 61 fd ff ff       	call   f01036a0 <stab_binsearch>
  if(lline <= rline)
f010393f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103942:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103945:	0f 8f e2 00 00 00    	jg     f0103a2d <debuginfo_eip+0x257>
  {
		info->eip_line = stabs[lline].n_desc;
f010394b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010394e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103951:	0f b7 44 81 06       	movzwl 0x6(%ecx,%eax,4),%eax
f0103956:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103959:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010395c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010395f:	39 fa                	cmp    %edi,%edx
f0103961:	7c 68                	jl     f01039cb <debuginfo_eip+0x1f5>
	       && stabs[lline].n_type != N_SOL
f0103963:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103966:	8d 34 81             	lea    (%ecx,%eax,4),%esi
f0103969:	0f b6 46 04          	movzbl 0x4(%esi),%eax
f010396d:	88 45 b4             	mov    %al,-0x4c(%ebp)
f0103970:	3c 84                	cmp    $0x84,%al
f0103972:	74 3f                	je     f01039b3 <debuginfo_eip+0x1dd>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103974:	8d 4c 52 fd          	lea    -0x3(%edx,%edx,2),%ecx
f0103978:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010397b:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f010397e:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0103981:	0f b6 4d b4          	movzbl -0x4c(%ebp),%ecx
f0103985:	eb 1a                	jmp    f01039a1 <debuginfo_eip+0x1cb>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103987:	83 ea 01             	sub    $0x1,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010398a:	39 fa                	cmp    %edi,%edx
f010398c:	7c 3d                	jl     f01039cb <debuginfo_eip+0x1f5>
	       && stabs[lline].n_type != N_SOL
f010398e:	89 c6                	mov    %eax,%esi
f0103990:	83 e8 0c             	sub    $0xc,%eax
f0103993:	0f b6 48 10          	movzbl 0x10(%eax),%ecx
f0103997:	80 f9 84             	cmp    $0x84,%cl
f010399a:	75 05                	jne    f01039a1 <debuginfo_eip+0x1cb>
f010399c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010399f:	eb 12                	jmp    f01039b3 <debuginfo_eip+0x1dd>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01039a1:	80 f9 64             	cmp    $0x64,%cl
f01039a4:	75 e1                	jne    f0103987 <debuginfo_eip+0x1b1>
f01039a6:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f01039aa:	74 db                	je     f0103987 <debuginfo_eip+0x1b1>
f01039ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01039af:	39 d7                	cmp    %edx,%edi
f01039b1:	7f 18                	jg     f01039cb <debuginfo_eip+0x1f5>
f01039b3:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01039b6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01039b9:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01039bc:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01039bf:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01039c2:	39 d0                	cmp    %edx,%eax
f01039c4:	73 05                	jae    f01039cb <debuginfo_eip+0x1f5>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01039c6:	03 45 bc             	add    -0x44(%ebp),%eax
f01039c9:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01039cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039ce:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01039d1:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01039d6:	39 f2                	cmp    %esi,%edx
f01039d8:	7d 6d                	jge    f0103a47 <debuginfo_eip+0x271>
		for (lline = lfun + 1;
f01039da:	8d 42 01             	lea    0x1(%edx),%eax
f01039dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01039e0:	39 c6                	cmp    %eax,%esi
f01039e2:	7e 50                	jle    f0103a34 <debuginfo_eip+0x25e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01039e4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01039e7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01039ea:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f01039ef:	75 4a                	jne    f0103a3b <debuginfo_eip+0x265>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01039f1:	8d 42 02             	lea    0x2(%edx),%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01039f4:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01039f7:	8d 54 91 1c          	lea    0x1c(%ecx,%edx,4),%edx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01039fb:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01039ff:	39 f0                	cmp    %esi,%eax
f0103a01:	74 3f                	je     f0103a42 <debuginfo_eip+0x26c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103a03:	0f b6 0a             	movzbl (%edx),%ecx
f0103a06:	83 c0 01             	add    $0x1,%eax
f0103a09:	83 c2 0c             	add    $0xc,%edx
f0103a0c:	80 f9 a0             	cmp    $0xa0,%cl
f0103a0f:	74 ea                	je     f01039fb <debuginfo_eip+0x225>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a11:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a16:	eb 2f                	jmp    f0103a47 <debuginfo_eip+0x271>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a1d:	eb 28                	jmp    f0103a47 <debuginfo_eip+0x271>
f0103a1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a24:	eb 21                	jmp    f0103a47 <debuginfo_eip+0x271>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a2b:	eb 1a                	jmp    f0103a47 <debuginfo_eip+0x271>
	// Your code here.
	stab_binsearch( stabs, &lline, &rline, N_SLINE, addr); 
  if(lline <= rline)
  {
		info->eip_line = stabs[lline].n_desc;
	}else return -1;
f0103a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a32:	eb 13                	jmp    f0103a47 <debuginfo_eip+0x271>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a34:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a39:	eb 0c                	jmp    f0103a47 <debuginfo_eip+0x271>
f0103a3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a40:	eb 05                	jmp    f0103a47 <debuginfo_eip+0x271>
f0103a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a47:	83 c4 5c             	add    $0x5c,%esp
f0103a4a:	5b                   	pop    %ebx
f0103a4b:	5e                   	pop    %esi
f0103a4c:	5f                   	pop    %edi
f0103a4d:	5d                   	pop    %ebp
f0103a4e:	c3                   	ret    
	...

f0103a50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103a50:	55                   	push   %ebp
f0103a51:	89 e5                	mov    %esp,%ebp
f0103a53:	57                   	push   %edi
f0103a54:	56                   	push   %esi
f0103a55:	53                   	push   %ebx
f0103a56:	83 ec 4c             	sub    $0x4c,%esp
f0103a59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a5c:	89 d7                	mov    %edx,%edi
f0103a5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a61:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a67:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103a6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a6f:	39 d8                	cmp    %ebx,%eax
f0103a71:	72 17                	jb     f0103a8a <printnum+0x3a>
f0103a73:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103a76:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f0103a79:	76 0f                	jbe    f0103a8a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103a7b:	8b 75 14             	mov    0x14(%ebp),%esi
f0103a7e:	83 ee 01             	sub    $0x1,%esi
f0103a81:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103a84:	85 f6                	test   %esi,%esi
f0103a86:	7f 63                	jg     f0103aeb <printnum+0x9b>
f0103a88:	eb 75                	jmp    f0103aff <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103a8a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0103a8d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0103a91:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a94:	83 e8 01             	sub    $0x1,%eax
f0103a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103a9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103aa2:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103aa6:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103aaa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103aad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ab0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103ab7:	00 
f0103ab8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103abb:	89 1c 24             	mov    %ebx,(%esp)
f0103abe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103ac1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ac5:	e8 b6 0a 00 00       	call   f0104580 <__udivdi3>
f0103aca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103acd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103ad0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103ad4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103ad8:	89 04 24             	mov    %eax,(%esp)
f0103adb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103adf:	89 fa                	mov    %edi,%edx
f0103ae1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ae4:	e8 67 ff ff ff       	call   f0103a50 <printnum>
f0103ae9:	eb 14                	jmp    f0103aff <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103aeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103aef:	8b 45 18             	mov    0x18(%ebp),%eax
f0103af2:	89 04 24             	mov    %eax,(%esp)
f0103af5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103af7:	83 ee 01             	sub    $0x1,%esi
f0103afa:	75 ef                	jne    f0103aeb <printnum+0x9b>
f0103afc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103aff:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b03:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103b0a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b0e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103b15:	00 
f0103b16:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103b19:	89 1c 24             	mov    %ebx,(%esp)
f0103b1c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103b1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b23:	e8 a8 0b 00 00       	call   f01046d0 <__umoddi3>
f0103b28:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b2c:	0f be 80 a1 5b 10 f0 	movsbl -0xfefa45f(%eax),%eax
f0103b33:	89 04 24             	mov    %eax,(%esp)
f0103b36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b39:	ff d0                	call   *%eax
}
f0103b3b:	83 c4 4c             	add    $0x4c,%esp
f0103b3e:	5b                   	pop    %ebx
f0103b3f:	5e                   	pop    %esi
f0103b40:	5f                   	pop    %edi
f0103b41:	5d                   	pop    %ebp
f0103b42:	c3                   	ret    

f0103b43 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103b43:	55                   	push   %ebp
f0103b44:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103b46:	83 fa 01             	cmp    $0x1,%edx
f0103b49:	7e 0e                	jle    f0103b59 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103b4b:	8b 10                	mov    (%eax),%edx
f0103b4d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103b50:	89 08                	mov    %ecx,(%eax)
f0103b52:	8b 02                	mov    (%edx),%eax
f0103b54:	8b 52 04             	mov    0x4(%edx),%edx
f0103b57:	eb 22                	jmp    f0103b7b <getuint+0x38>
	else if (lflag)
f0103b59:	85 d2                	test   %edx,%edx
f0103b5b:	74 10                	je     f0103b6d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103b5d:	8b 10                	mov    (%eax),%edx
f0103b5f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103b62:	89 08                	mov    %ecx,(%eax)
f0103b64:	8b 02                	mov    (%edx),%eax
f0103b66:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b6b:	eb 0e                	jmp    f0103b7b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103b6d:	8b 10                	mov    (%eax),%edx
f0103b6f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103b72:	89 08                	mov    %ecx,(%eax)
f0103b74:	8b 02                	mov    (%edx),%eax
f0103b76:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103b7b:	5d                   	pop    %ebp
f0103b7c:	c3                   	ret    

f0103b7d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103b7d:	55                   	push   %ebp
f0103b7e:	89 e5                	mov    %esp,%ebp
f0103b80:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103b83:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103b87:	8b 10                	mov    (%eax),%edx
f0103b89:	3b 50 04             	cmp    0x4(%eax),%edx
f0103b8c:	73 0a                	jae    f0103b98 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b91:	88 0a                	mov    %cl,(%edx)
f0103b93:	83 c2 01             	add    $0x1,%edx
f0103b96:	89 10                	mov    %edx,(%eax)
}
f0103b98:	5d                   	pop    %ebp
f0103b99:	c3                   	ret    

f0103b9a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103b9a:	55                   	push   %ebp
f0103b9b:	89 e5                	mov    %esp,%ebp
f0103b9d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103ba0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103ba3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ba7:	8b 45 10             	mov    0x10(%ebp),%eax
f0103baa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bb8:	89 04 24             	mov    %eax,(%esp)
f0103bbb:	e8 02 00 00 00       	call   f0103bc2 <vprintfmt>
	va_end(ap);
}
f0103bc0:	c9                   	leave  
f0103bc1:	c3                   	ret    

f0103bc2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103bc2:	55                   	push   %ebp
f0103bc3:	89 e5                	mov    %esp,%ebp
f0103bc5:	57                   	push   %edi
f0103bc6:	56                   	push   %esi
f0103bc7:	53                   	push   %ebx
f0103bc8:	83 ec 4c             	sub    $0x4c,%esp
f0103bcb:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bd1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103bd4:	eb 11                	jmp    f0103be7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103bd6:	85 c0                	test   %eax,%eax
f0103bd8:	0f 84 db 03 00 00    	je     f0103fb9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
f0103bde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103be2:	89 04 24             	mov    %eax,(%esp)
f0103be5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103be7:	0f b6 07             	movzbl (%edi),%eax
f0103bea:	83 c7 01             	add    $0x1,%edi
f0103bed:	83 f8 25             	cmp    $0x25,%eax
f0103bf0:	75 e4                	jne    f0103bd6 <vprintfmt+0x14>
f0103bf2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
f0103bf6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0103bfd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0103c04:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103c0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c10:	eb 2b                	jmp    f0103c3d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c12:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103c15:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
f0103c19:	eb 22                	jmp    f0103c3d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c1b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103c1e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
f0103c22:	eb 19                	jmp    f0103c3d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c24:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103c27:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103c2e:	eb 0d                	jmp    f0103c3d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103c30:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c36:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c3d:	0f b6 0f             	movzbl (%edi),%ecx
f0103c40:	8d 47 01             	lea    0x1(%edi),%eax
f0103c43:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103c46:	0f b6 07             	movzbl (%edi),%eax
f0103c49:	83 e8 23             	sub    $0x23,%eax
f0103c4c:	3c 55                	cmp    $0x55,%al
f0103c4e:	0f 87 40 03 00 00    	ja     f0103f94 <vprintfmt+0x3d2>
f0103c54:	0f b6 c0             	movzbl %al,%eax
f0103c57:	ff 24 85 20 5c 10 f0 	jmp    *-0xfefa3e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103c5e:	83 e9 30             	sub    $0x30,%ecx
f0103c61:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
f0103c64:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
f0103c68:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103c6b:	83 f9 09             	cmp    $0x9,%ecx
f0103c6e:	77 57                	ja     f0103cc7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c70:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103c73:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103c76:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103c79:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103c7c:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103c7f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103c83:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103c86:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103c89:	83 f9 09             	cmp    $0x9,%ecx
f0103c8c:	76 eb                	jbe    f0103c79 <vprintfmt+0xb7>
f0103c8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103c91:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c94:	eb 34                	jmp    f0103cca <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103c96:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c99:	8d 48 04             	lea    0x4(%eax),%ecx
f0103c9c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103c9f:	8b 00                	mov    (%eax),%eax
f0103ca1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ca4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103ca7:	eb 21                	jmp    f0103cca <vprintfmt+0x108>

		case '.':
			if (width < 0)
f0103ca9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103cad:	0f 88 71 ff ff ff    	js     f0103c24 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103cb6:	eb 85                	jmp    f0103c3d <vprintfmt+0x7b>
f0103cb8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103cbb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0103cc2:	e9 76 ff ff ff       	jmp    f0103c3d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cc7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103cca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103cce:	0f 89 69 ff ff ff    	jns    f0103c3d <vprintfmt+0x7b>
f0103cd4:	e9 57 ff ff ff       	jmp    f0103c30 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103cd9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cdc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103cdf:	e9 59 ff ff ff       	jmp    f0103c3d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ce4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ce7:	8d 50 04             	lea    0x4(%eax),%edx
f0103cea:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cf1:	8b 00                	mov    (%eax),%eax
f0103cf3:	89 04 24             	mov    %eax,(%esp)
f0103cf6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cf8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103cfb:	e9 e7 fe ff ff       	jmp    f0103be7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d00:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d03:	8d 50 04             	lea    0x4(%eax),%edx
f0103d06:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d09:	8b 00                	mov    (%eax),%eax
f0103d0b:	89 c2                	mov    %eax,%edx
f0103d0d:	c1 fa 1f             	sar    $0x1f,%edx
f0103d10:	31 d0                	xor    %edx,%eax
f0103d12:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103d14:	83 f8 06             	cmp    $0x6,%eax
f0103d17:	7f 0b                	jg     f0103d24 <vprintfmt+0x162>
f0103d19:	8b 14 85 78 5d 10 f0 	mov    -0xfefa288(,%eax,4),%edx
f0103d20:	85 d2                	test   %edx,%edx
f0103d22:	75 20                	jne    f0103d44 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
f0103d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d28:	c7 44 24 08 b9 5b 10 	movl   $0xf0105bb9,0x8(%esp)
f0103d2f:	f0 
f0103d30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d34:	89 34 24             	mov    %esi,(%esp)
f0103d37:	e8 5e fe ff ff       	call   f0103b9a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d3c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103d3f:	e9 a3 fe ff ff       	jmp    f0103be7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103d44:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d48:	c7 44 24 08 8f 54 10 	movl   $0xf010548f,0x8(%esp)
f0103d4f:	f0 
f0103d50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d54:	89 34 24             	mov    %esi,(%esp)
f0103d57:	e8 3e fe ff ff       	call   f0103b9a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d5c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103d5f:	e9 83 fe ff ff       	jmp    f0103be7 <vprintfmt+0x25>
f0103d64:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d67:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0103d6a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d70:	8d 50 04             	lea    0x4(%eax),%edx
f0103d73:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d76:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103d78:	85 ff                	test   %edi,%edi
f0103d7a:	b8 b2 5b 10 f0       	mov    $0xf0105bb2,%eax
f0103d7f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103d82:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
f0103d86:	74 06                	je     f0103d8e <vprintfmt+0x1cc>
f0103d88:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103d8c:	7f 16                	jg     f0103da4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103d8e:	0f b6 17             	movzbl (%edi),%edx
f0103d91:	0f be c2             	movsbl %dl,%eax
f0103d94:	83 c7 01             	add    $0x1,%edi
f0103d97:	85 c0                	test   %eax,%eax
f0103d99:	0f 85 9f 00 00 00    	jne    f0103e3e <vprintfmt+0x27c>
f0103d9f:	e9 8b 00 00 00       	jmp    f0103e2f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103da4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103da8:	89 3c 24             	mov    %edi,(%esp)
f0103dab:	e8 92 03 00 00       	call   f0104142 <strnlen>
f0103db0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103db3:	29 c2                	sub    %eax,%edx
f0103db5:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103db8:	85 d2                	test   %edx,%edx
f0103dba:	7e d2                	jle    f0103d8e <vprintfmt+0x1cc>
					putch(padc, putdat);
f0103dbc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
f0103dc0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103dc3:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0103dc6:	89 d7                	mov    %edx,%edi
f0103dc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103dcf:	89 04 24             	mov    %eax,(%esp)
f0103dd2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103dd4:	83 ef 01             	sub    $0x1,%edi
f0103dd7:	75 ef                	jne    f0103dc8 <vprintfmt+0x206>
f0103dd9:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0103ddc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103ddf:	eb ad                	jmp    f0103d8e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103de1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0103de5:	74 20                	je     f0103e07 <vprintfmt+0x245>
f0103de7:	0f be d2             	movsbl %dl,%edx
f0103dea:	83 ea 20             	sub    $0x20,%edx
f0103ded:	83 fa 5e             	cmp    $0x5e,%edx
f0103df0:	76 15                	jbe    f0103e07 <vprintfmt+0x245>
					putch('?', putdat);
f0103df2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103df5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103df9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103e00:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e03:	ff d1                	call   *%ecx
f0103e05:	eb 0f                	jmp    f0103e16 <vprintfmt+0x254>
				else
					putch(ch, putdat);
f0103e07:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e0a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e0e:	89 04 24             	mov    %eax,(%esp)
f0103e11:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e14:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e16:	83 eb 01             	sub    $0x1,%ebx
f0103e19:	0f b6 17             	movzbl (%edi),%edx
f0103e1c:	0f be c2             	movsbl %dl,%eax
f0103e1f:	83 c7 01             	add    $0x1,%edi
f0103e22:	85 c0                	test   %eax,%eax
f0103e24:	75 24                	jne    f0103e4a <vprintfmt+0x288>
f0103e26:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103e29:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103e2c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e2f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e32:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103e36:	0f 8e ab fd ff ff    	jle    f0103be7 <vprintfmt+0x25>
f0103e3c:	eb 20                	jmp    f0103e5e <vprintfmt+0x29c>
f0103e3e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103e41:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103e44:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0103e47:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e4a:	85 f6                	test   %esi,%esi
f0103e4c:	78 93                	js     f0103de1 <vprintfmt+0x21f>
f0103e4e:	83 ee 01             	sub    $0x1,%esi
f0103e51:	79 8e                	jns    f0103de1 <vprintfmt+0x21f>
f0103e53:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103e56:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103e59:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103e5c:	eb d1                	jmp    f0103e2f <vprintfmt+0x26d>
f0103e5e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103e61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e65:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103e6c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e6e:	83 ef 01             	sub    $0x1,%edi
f0103e71:	75 ee                	jne    f0103e61 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e73:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e76:	e9 6c fd ff ff       	jmp    f0103be7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e7b:	83 fa 01             	cmp    $0x1,%edx
f0103e7e:	66 90                	xchg   %ax,%ax
f0103e80:	7e 16                	jle    f0103e98 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
f0103e82:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e85:	8d 50 08             	lea    0x8(%eax),%edx
f0103e88:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e8b:	8b 10                	mov    (%eax),%edx
f0103e8d:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e90:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103e93:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103e96:	eb 32                	jmp    f0103eca <vprintfmt+0x308>
	else if (lflag)
f0103e98:	85 d2                	test   %edx,%edx
f0103e9a:	74 18                	je     f0103eb4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
f0103e9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e9f:	8d 50 04             	lea    0x4(%eax),%edx
f0103ea2:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ea5:	8b 00                	mov    (%eax),%eax
f0103ea7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103eaa:	89 c1                	mov    %eax,%ecx
f0103eac:	c1 f9 1f             	sar    $0x1f,%ecx
f0103eaf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103eb2:	eb 16                	jmp    f0103eca <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
f0103eb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eb7:	8d 50 04             	lea    0x4(%eax),%edx
f0103eba:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ebd:	8b 00                	mov    (%eax),%eax
f0103ebf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ec2:	89 c7                	mov    %eax,%edi
f0103ec4:	c1 ff 1f             	sar    $0x1f,%edi
f0103ec7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ecd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103ed0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103ed5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103ed9:	79 7d                	jns    f0103f58 <vprintfmt+0x396>
				putch('-', putdat);
f0103edb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103edf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103ee6:	ff d6                	call   *%esi
				num = -(long long) num;
f0103ee8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103eeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103eee:	f7 d8                	neg    %eax
f0103ef0:	83 d2 00             	adc    $0x0,%edx
f0103ef3:	f7 da                	neg    %edx
			}
			base = 10;
f0103ef5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103efa:	eb 5c                	jmp    f0103f58 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103efc:	8d 45 14             	lea    0x14(%ebp),%eax
f0103eff:	e8 3f fc ff ff       	call   f0103b43 <getuint>
			base = 10;
f0103f04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103f09:	eb 4d                	jmp    f0103f58 <vprintfmt+0x396>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap, lflag);
f0103f0b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f0e:	e8 30 fc ff ff       	call   f0103b43 <getuint>
      base = 8;
f0103f13:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f0103f18:	eb 3e                	jmp    f0103f58 <vprintfmt+0x396>
      //break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103f1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103f25:	ff d6                	call   *%esi
			putch('x', putdat);
f0103f27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f2b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103f32:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103f34:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f37:	8d 50 04             	lea    0x4(%eax),%edx
f0103f3a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103f3d:	8b 00                	mov    (%eax),%eax
f0103f3f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103f44:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103f49:	eb 0d                	jmp    f0103f58 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103f4b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f4e:	e8 f0 fb ff ff       	call   f0103b43 <getuint>
			base = 16;
f0103f53:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103f58:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
f0103f5c:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0103f60:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0103f63:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103f67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f6b:	89 04 24             	mov    %eax,(%esp)
f0103f6e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f72:	89 da                	mov    %ebx,%edx
f0103f74:	89 f0                	mov    %esi,%eax
f0103f76:	e8 d5 fa ff ff       	call   f0103a50 <printnum>
			break;
f0103f7b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103f7e:	e9 64 fc ff ff       	jmp    f0103be7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103f83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f87:	89 0c 24             	mov    %ecx,(%esp)
f0103f8a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f8c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103f8f:	e9 53 fc ff ff       	jmp    f0103be7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103f94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f98:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103f9f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103fa1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103fa5:	0f 84 3c fc ff ff    	je     f0103be7 <vprintfmt+0x25>
f0103fab:	83 ef 01             	sub    $0x1,%edi
f0103fae:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103fb2:	75 f7                	jne    f0103fab <vprintfmt+0x3e9>
f0103fb4:	e9 2e fc ff ff       	jmp    f0103be7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103fb9:	83 c4 4c             	add    $0x4c,%esp
f0103fbc:	5b                   	pop    %ebx
f0103fbd:	5e                   	pop    %esi
f0103fbe:	5f                   	pop    %edi
f0103fbf:	5d                   	pop    %ebp
f0103fc0:	c3                   	ret    

f0103fc1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103fc1:	55                   	push   %ebp
f0103fc2:	89 e5                	mov    %esp,%ebp
f0103fc4:	83 ec 28             	sub    $0x28,%esp
f0103fc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103fd0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103fd4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103fd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103fde:	85 d2                	test   %edx,%edx
f0103fe0:	7e 30                	jle    f0104012 <vsnprintf+0x51>
f0103fe2:	85 c0                	test   %eax,%eax
f0103fe4:	74 2c                	je     f0104012 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103fe6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fed:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ff0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ff4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ffb:	c7 04 24 7d 3b 10 f0 	movl   $0xf0103b7d,(%esp)
f0104002:	e8 bb fb ff ff       	call   f0103bc2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104007:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010400a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104010:	eb 05                	jmp    f0104017 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104012:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104017:	c9                   	leave  
f0104018:	c3                   	ret    

f0104019 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104019:	55                   	push   %ebp
f010401a:	89 e5                	mov    %esp,%ebp
f010401c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010401f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104022:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104026:	8b 45 10             	mov    0x10(%ebp),%eax
f0104029:	89 44 24 08          	mov    %eax,0x8(%esp)
f010402d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104034:	8b 45 08             	mov    0x8(%ebp),%eax
f0104037:	89 04 24             	mov    %eax,(%esp)
f010403a:	e8 82 ff ff ff       	call   f0103fc1 <vsnprintf>
	va_end(ap);

	return rc;
}
f010403f:	c9                   	leave  
f0104040:	c3                   	ret    
	...

f0104050 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104050:	55                   	push   %ebp
f0104051:	89 e5                	mov    %esp,%ebp
f0104053:	57                   	push   %edi
f0104054:	56                   	push   %esi
f0104055:	53                   	push   %ebx
f0104056:	83 ec 1c             	sub    $0x1c,%esp
f0104059:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010405c:	85 c0                	test   %eax,%eax
f010405e:	74 10                	je     f0104070 <readline+0x20>
		cprintf("%s", prompt);
f0104060:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104064:	c7 04 24 8f 54 10 f0 	movl   $0xf010548f,(%esp)
f010406b:	e8 0a f2 ff ff       	call   f010327a <cprintf>

	i = 0;
	echoing = iscons(0);
f0104070:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104077:	e8 ce c5 ff ff       	call   f010064a <iscons>
f010407c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010407e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104083:	e8 b1 c5 ff ff       	call   f0100639 <getchar>
f0104088:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010408a:	85 c0                	test   %eax,%eax
f010408c:	79 17                	jns    f01040a5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010408e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104092:	c7 04 24 94 5d 10 f0 	movl   $0xf0105d94,(%esp)
f0104099:	e8 dc f1 ff ff       	call   f010327a <cprintf>
			return NULL;
f010409e:	b8 00 00 00 00       	mov    $0x0,%eax
f01040a3:	eb 6d                	jmp    f0104112 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01040a5:	83 f8 7f             	cmp    $0x7f,%eax
f01040a8:	74 05                	je     f01040af <readline+0x5f>
f01040aa:	83 f8 08             	cmp    $0x8,%eax
f01040ad:	75 19                	jne    f01040c8 <readline+0x78>
f01040af:	85 f6                	test   %esi,%esi
f01040b1:	7e 15                	jle    f01040c8 <readline+0x78>
			if (echoing)
f01040b3:	85 ff                	test   %edi,%edi
f01040b5:	74 0c                	je     f01040c3 <readline+0x73>
				cputchar('\b');
f01040b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01040be:	e8 66 c5 ff ff       	call   f0100629 <cputchar>
			i--;
f01040c3:	83 ee 01             	sub    $0x1,%esi
f01040c6:	eb bb                	jmp    f0104083 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01040c8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01040ce:	7f 1c                	jg     f01040ec <readline+0x9c>
f01040d0:	83 fb 1f             	cmp    $0x1f,%ebx
f01040d3:	7e 17                	jle    f01040ec <readline+0x9c>
			if (echoing)
f01040d5:	85 ff                	test   %edi,%edi
f01040d7:	74 08                	je     f01040e1 <readline+0x91>
				cputchar(c);
f01040d9:	89 1c 24             	mov    %ebx,(%esp)
f01040dc:	e8 48 c5 ff ff       	call   f0100629 <cputchar>
			buf[i++] = c;
f01040e1:	88 9e 20 c8 17 f0    	mov    %bl,-0xfe837e0(%esi)
f01040e7:	83 c6 01             	add    $0x1,%esi
f01040ea:	eb 97                	jmp    f0104083 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01040ec:	83 fb 0d             	cmp    $0xd,%ebx
f01040ef:	74 05                	je     f01040f6 <readline+0xa6>
f01040f1:	83 fb 0a             	cmp    $0xa,%ebx
f01040f4:	75 8d                	jne    f0104083 <readline+0x33>
			if (echoing)
f01040f6:	85 ff                	test   %edi,%edi
f01040f8:	74 0c                	je     f0104106 <readline+0xb6>
				cputchar('\n');
f01040fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104101:	e8 23 c5 ff ff       	call   f0100629 <cputchar>
			buf[i] = 0;
f0104106:	c6 86 20 c8 17 f0 00 	movb   $0x0,-0xfe837e0(%esi)
			return buf;
f010410d:	b8 20 c8 17 f0       	mov    $0xf017c820,%eax
		}
	}
}
f0104112:	83 c4 1c             	add    $0x1c,%esp
f0104115:	5b                   	pop    %ebx
f0104116:	5e                   	pop    %esi
f0104117:	5f                   	pop    %edi
f0104118:	5d                   	pop    %ebp
f0104119:	c3                   	ret    
f010411a:	00 00                	add    %al,(%eax)
f010411c:	00 00                	add    %al,(%eax)
	...

f0104120 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104120:	55                   	push   %ebp
f0104121:	89 e5                	mov    %esp,%ebp
f0104123:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104126:	80 3a 00             	cmpb   $0x0,(%edx)
f0104129:	74 10                	je     f010413b <strlen+0x1b>
f010412b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104130:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104133:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104137:	75 f7                	jne    f0104130 <strlen+0x10>
f0104139:	eb 05                	jmp    f0104140 <strlen+0x20>
f010413b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104140:	5d                   	pop    %ebp
f0104141:	c3                   	ret    

f0104142 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104142:	55                   	push   %ebp
f0104143:	89 e5                	mov    %esp,%ebp
f0104145:	53                   	push   %ebx
f0104146:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010414c:	85 c9                	test   %ecx,%ecx
f010414e:	74 1c                	je     f010416c <strnlen+0x2a>
f0104150:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104153:	74 1e                	je     f0104173 <strnlen+0x31>
f0104155:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f010415a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010415c:	39 ca                	cmp    %ecx,%edx
f010415e:	74 18                	je     f0104178 <strnlen+0x36>
f0104160:	83 c2 01             	add    $0x1,%edx
f0104163:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104168:	75 f0                	jne    f010415a <strnlen+0x18>
f010416a:	eb 0c                	jmp    f0104178 <strnlen+0x36>
f010416c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104171:	eb 05                	jmp    f0104178 <strnlen+0x36>
f0104173:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104178:	5b                   	pop    %ebx
f0104179:	5d                   	pop    %ebp
f010417a:	c3                   	ret    

f010417b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010417b:	55                   	push   %ebp
f010417c:	89 e5                	mov    %esp,%ebp
f010417e:	53                   	push   %ebx
f010417f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104185:	89 c2                	mov    %eax,%edx
f0104187:	0f b6 19             	movzbl (%ecx),%ebx
f010418a:	88 1a                	mov    %bl,(%edx)
f010418c:	83 c2 01             	add    $0x1,%edx
f010418f:	83 c1 01             	add    $0x1,%ecx
f0104192:	84 db                	test   %bl,%bl
f0104194:	75 f1                	jne    f0104187 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104196:	5b                   	pop    %ebx
f0104197:	5d                   	pop    %ebp
f0104198:	c3                   	ret    

f0104199 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104199:	55                   	push   %ebp
f010419a:	89 e5                	mov    %esp,%ebp
f010419c:	53                   	push   %ebx
f010419d:	83 ec 08             	sub    $0x8,%esp
f01041a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01041a3:	89 1c 24             	mov    %ebx,(%esp)
f01041a6:	e8 75 ff ff ff       	call   f0104120 <strlen>
	strcpy(dst + len, src);
f01041ab:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041ae:	89 54 24 04          	mov    %edx,0x4(%esp)
f01041b2:	01 d8                	add    %ebx,%eax
f01041b4:	89 04 24             	mov    %eax,(%esp)
f01041b7:	e8 bf ff ff ff       	call   f010417b <strcpy>
	return dst;
}
f01041bc:	89 d8                	mov    %ebx,%eax
f01041be:	83 c4 08             	add    $0x8,%esp
f01041c1:	5b                   	pop    %ebx
f01041c2:	5d                   	pop    %ebp
f01041c3:	c3                   	ret    

f01041c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01041c4:	55                   	push   %ebp
f01041c5:	89 e5                	mov    %esp,%ebp
f01041c7:	56                   	push   %esi
f01041c8:	53                   	push   %ebx
f01041c9:	8b 75 08             	mov    0x8(%ebp),%esi
f01041cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041d2:	85 db                	test   %ebx,%ebx
f01041d4:	74 16                	je     f01041ec <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
f01041d6:	01 f3                	add    %esi,%ebx
f01041d8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f01041da:	0f b6 02             	movzbl (%edx),%eax
f01041dd:	88 01                	mov    %al,(%ecx)
f01041df:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01041e2:	80 3a 01             	cmpb   $0x1,(%edx)
f01041e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041e8:	39 d9                	cmp    %ebx,%ecx
f01041ea:	75 ee                	jne    f01041da <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01041ec:	89 f0                	mov    %esi,%eax
f01041ee:	5b                   	pop    %ebx
f01041ef:	5e                   	pop    %esi
f01041f0:	5d                   	pop    %ebp
f01041f1:	c3                   	ret    

f01041f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01041f2:	55                   	push   %ebp
f01041f3:	89 e5                	mov    %esp,%ebp
f01041f5:	57                   	push   %edi
f01041f6:	56                   	push   %esi
f01041f7:	53                   	push   %ebx
f01041f8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01041fe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104201:	89 f8                	mov    %edi,%eax
f0104203:	85 f6                	test   %esi,%esi
f0104205:	74 33                	je     f010423a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
f0104207:	83 fe 01             	cmp    $0x1,%esi
f010420a:	74 25                	je     f0104231 <strlcpy+0x3f>
f010420c:	0f b6 0b             	movzbl (%ebx),%ecx
f010420f:	84 c9                	test   %cl,%cl
f0104211:	74 22                	je     f0104235 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0104213:	83 ee 02             	sub    $0x2,%esi
f0104216:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010421b:	88 08                	mov    %cl,(%eax)
f010421d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104220:	39 f2                	cmp    %esi,%edx
f0104222:	74 13                	je     f0104237 <strlcpy+0x45>
f0104224:	83 c2 01             	add    $0x1,%edx
f0104227:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010422b:	84 c9                	test   %cl,%cl
f010422d:	75 ec                	jne    f010421b <strlcpy+0x29>
f010422f:	eb 06                	jmp    f0104237 <strlcpy+0x45>
f0104231:	89 f8                	mov    %edi,%eax
f0104233:	eb 02                	jmp    f0104237 <strlcpy+0x45>
f0104235:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104237:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010423a:	29 f8                	sub    %edi,%eax
}
f010423c:	5b                   	pop    %ebx
f010423d:	5e                   	pop    %esi
f010423e:	5f                   	pop    %edi
f010423f:	5d                   	pop    %ebp
f0104240:	c3                   	ret    

f0104241 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104241:	55                   	push   %ebp
f0104242:	89 e5                	mov    %esp,%ebp
f0104244:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104247:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010424a:	0f b6 01             	movzbl (%ecx),%eax
f010424d:	84 c0                	test   %al,%al
f010424f:	74 15                	je     f0104266 <strcmp+0x25>
f0104251:	3a 02                	cmp    (%edx),%al
f0104253:	75 11                	jne    f0104266 <strcmp+0x25>
		p++, q++;
f0104255:	83 c1 01             	add    $0x1,%ecx
f0104258:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010425b:	0f b6 01             	movzbl (%ecx),%eax
f010425e:	84 c0                	test   %al,%al
f0104260:	74 04                	je     f0104266 <strcmp+0x25>
f0104262:	3a 02                	cmp    (%edx),%al
f0104264:	74 ef                	je     f0104255 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104266:	0f b6 c0             	movzbl %al,%eax
f0104269:	0f b6 12             	movzbl (%edx),%edx
f010426c:	29 d0                	sub    %edx,%eax
}
f010426e:	5d                   	pop    %ebp
f010426f:	c3                   	ret    

f0104270 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104270:	55                   	push   %ebp
f0104271:	89 e5                	mov    %esp,%ebp
f0104273:	56                   	push   %esi
f0104274:	53                   	push   %ebx
f0104275:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104278:	8b 55 0c             	mov    0xc(%ebp),%edx
f010427b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f010427e:	85 f6                	test   %esi,%esi
f0104280:	74 29                	je     f01042ab <strncmp+0x3b>
f0104282:	0f b6 03             	movzbl (%ebx),%eax
f0104285:	84 c0                	test   %al,%al
f0104287:	74 30                	je     f01042b9 <strncmp+0x49>
f0104289:	3a 02                	cmp    (%edx),%al
f010428b:	75 2c                	jne    f01042b9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
f010428d:	8d 43 01             	lea    0x1(%ebx),%eax
f0104290:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0104292:	89 c3                	mov    %eax,%ebx
f0104294:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104297:	39 f0                	cmp    %esi,%eax
f0104299:	74 17                	je     f01042b2 <strncmp+0x42>
f010429b:	0f b6 08             	movzbl (%eax),%ecx
f010429e:	84 c9                	test   %cl,%cl
f01042a0:	74 17                	je     f01042b9 <strncmp+0x49>
f01042a2:	83 c0 01             	add    $0x1,%eax
f01042a5:	3a 0a                	cmp    (%edx),%cl
f01042a7:	74 e9                	je     f0104292 <strncmp+0x22>
f01042a9:	eb 0e                	jmp    f01042b9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01042ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b0:	eb 0f                	jmp    f01042c1 <strncmp+0x51>
f01042b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b7:	eb 08                	jmp    f01042c1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01042b9:	0f b6 03             	movzbl (%ebx),%eax
f01042bc:	0f b6 12             	movzbl (%edx),%edx
f01042bf:	29 d0                	sub    %edx,%eax
}
f01042c1:	5b                   	pop    %ebx
f01042c2:	5e                   	pop    %esi
f01042c3:	5d                   	pop    %ebp
f01042c4:	c3                   	ret    

f01042c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01042c5:	55                   	push   %ebp
f01042c6:	89 e5                	mov    %esp,%ebp
f01042c8:	53                   	push   %ebx
f01042c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01042cf:	0f b6 18             	movzbl (%eax),%ebx
f01042d2:	84 db                	test   %bl,%bl
f01042d4:	74 1d                	je     f01042f3 <strchr+0x2e>
f01042d6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01042d8:	38 d3                	cmp    %dl,%bl
f01042da:	75 06                	jne    f01042e2 <strchr+0x1d>
f01042dc:	eb 1a                	jmp    f01042f8 <strchr+0x33>
f01042de:	38 ca                	cmp    %cl,%dl
f01042e0:	74 16                	je     f01042f8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01042e2:	83 c0 01             	add    $0x1,%eax
f01042e5:	0f b6 10             	movzbl (%eax),%edx
f01042e8:	84 d2                	test   %dl,%dl
f01042ea:	75 f2                	jne    f01042de <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f01042ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01042f1:	eb 05                	jmp    f01042f8 <strchr+0x33>
f01042f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042f8:	5b                   	pop    %ebx
f01042f9:	5d                   	pop    %ebp
f01042fa:	c3                   	ret    

f01042fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01042fb:	55                   	push   %ebp
f01042fc:	89 e5                	mov    %esp,%ebp
f01042fe:	53                   	push   %ebx
f01042ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104302:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0104305:	0f b6 18             	movzbl (%eax),%ebx
f0104308:	84 db                	test   %bl,%bl
f010430a:	74 16                	je     f0104322 <strfind+0x27>
f010430c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f010430e:	38 d3                	cmp    %dl,%bl
f0104310:	75 06                	jne    f0104318 <strfind+0x1d>
f0104312:	eb 0e                	jmp    f0104322 <strfind+0x27>
f0104314:	38 ca                	cmp    %cl,%dl
f0104316:	74 0a                	je     f0104322 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104318:	83 c0 01             	add    $0x1,%eax
f010431b:	0f b6 10             	movzbl (%eax),%edx
f010431e:	84 d2                	test   %dl,%dl
f0104320:	75 f2                	jne    f0104314 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
f0104322:	5b                   	pop    %ebx
f0104323:	5d                   	pop    %ebp
f0104324:	c3                   	ret    

f0104325 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104325:	55                   	push   %ebp
f0104326:	89 e5                	mov    %esp,%ebp
f0104328:	83 ec 0c             	sub    $0xc,%esp
f010432b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010432e:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104331:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104334:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104337:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010433a:	85 c9                	test   %ecx,%ecx
f010433c:	74 36                	je     f0104374 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010433e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104344:	75 28                	jne    f010436e <memset+0x49>
f0104346:	f6 c1 03             	test   $0x3,%cl
f0104349:	75 23                	jne    f010436e <memset+0x49>
		c &= 0xFF;
f010434b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010434f:	89 d3                	mov    %edx,%ebx
f0104351:	c1 e3 08             	shl    $0x8,%ebx
f0104354:	89 d6                	mov    %edx,%esi
f0104356:	c1 e6 18             	shl    $0x18,%esi
f0104359:	89 d0                	mov    %edx,%eax
f010435b:	c1 e0 10             	shl    $0x10,%eax
f010435e:	09 f0                	or     %esi,%eax
f0104360:	09 c2                	or     %eax,%edx
f0104362:	89 d0                	mov    %edx,%eax
f0104364:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104366:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104369:	fc                   	cld    
f010436a:	f3 ab                	rep stos %eax,%es:(%edi)
f010436c:	eb 06                	jmp    f0104374 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010436e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104371:	fc                   	cld    
f0104372:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104374:	89 f8                	mov    %edi,%eax
f0104376:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104379:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010437c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010437f:	89 ec                	mov    %ebp,%esp
f0104381:	5d                   	pop    %ebp
f0104382:	c3                   	ret    

f0104383 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104383:	55                   	push   %ebp
f0104384:	89 e5                	mov    %esp,%ebp
f0104386:	83 ec 08             	sub    $0x8,%esp
f0104389:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010438c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010438f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104392:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104395:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104398:	39 c6                	cmp    %eax,%esi
f010439a:	73 36                	jae    f01043d2 <memmove+0x4f>
f010439c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010439f:	39 d0                	cmp    %edx,%eax
f01043a1:	73 2f                	jae    f01043d2 <memmove+0x4f>
		s += n;
		d += n;
f01043a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01043a6:	f6 c2 03             	test   $0x3,%dl
f01043a9:	75 1b                	jne    f01043c6 <memmove+0x43>
f01043ab:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01043b1:	75 13                	jne    f01043c6 <memmove+0x43>
f01043b3:	f6 c1 03             	test   $0x3,%cl
f01043b6:	75 0e                	jne    f01043c6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01043b8:	83 ef 04             	sub    $0x4,%edi
f01043bb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01043be:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01043c1:	fd                   	std    
f01043c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01043c4:	eb 09                	jmp    f01043cf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01043c6:	83 ef 01             	sub    $0x1,%edi
f01043c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01043cc:	fd                   	std    
f01043cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01043cf:	fc                   	cld    
f01043d0:	eb 20                	jmp    f01043f2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01043d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01043d8:	75 13                	jne    f01043ed <memmove+0x6a>
f01043da:	a8 03                	test   $0x3,%al
f01043dc:	75 0f                	jne    f01043ed <memmove+0x6a>
f01043de:	f6 c1 03             	test   $0x3,%cl
f01043e1:	75 0a                	jne    f01043ed <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01043e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01043e6:	89 c7                	mov    %eax,%edi
f01043e8:	fc                   	cld    
f01043e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01043eb:	eb 05                	jmp    f01043f2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01043ed:	89 c7                	mov    %eax,%edi
f01043ef:	fc                   	cld    
f01043f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01043f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01043f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01043f8:	89 ec                	mov    %ebp,%esp
f01043fa:	5d                   	pop    %ebp
f01043fb:	c3                   	ret    

f01043fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01043fc:	55                   	push   %ebp
f01043fd:	89 e5                	mov    %esp,%ebp
f01043ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104402:	8b 45 10             	mov    0x10(%ebp),%eax
f0104405:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104409:	8b 45 0c             	mov    0xc(%ebp),%eax
f010440c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104410:	8b 45 08             	mov    0x8(%ebp),%eax
f0104413:	89 04 24             	mov    %eax,(%esp)
f0104416:	e8 68 ff ff ff       	call   f0104383 <memmove>
}
f010441b:	c9                   	leave  
f010441c:	c3                   	ret    

f010441d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010441d:	55                   	push   %ebp
f010441e:	89 e5                	mov    %esp,%ebp
f0104420:	57                   	push   %edi
f0104421:	56                   	push   %esi
f0104422:	53                   	push   %ebx
f0104423:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104426:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104429:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010442c:	8d 78 ff             	lea    -0x1(%eax),%edi
f010442f:	85 c0                	test   %eax,%eax
f0104431:	74 36                	je     f0104469 <memcmp+0x4c>
		if (*s1 != *s2)
f0104433:	0f b6 03             	movzbl (%ebx),%eax
f0104436:	0f b6 0e             	movzbl (%esi),%ecx
f0104439:	38 c8                	cmp    %cl,%al
f010443b:	75 17                	jne    f0104454 <memcmp+0x37>
f010443d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104442:	eb 1a                	jmp    f010445e <memcmp+0x41>
f0104444:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104449:	83 c2 01             	add    $0x1,%edx
f010444c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104450:	38 c8                	cmp    %cl,%al
f0104452:	74 0a                	je     f010445e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0104454:	0f b6 c0             	movzbl %al,%eax
f0104457:	0f b6 c9             	movzbl %cl,%ecx
f010445a:	29 c8                	sub    %ecx,%eax
f010445c:	eb 10                	jmp    f010446e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010445e:	39 fa                	cmp    %edi,%edx
f0104460:	75 e2                	jne    f0104444 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104462:	b8 00 00 00 00       	mov    $0x0,%eax
f0104467:	eb 05                	jmp    f010446e <memcmp+0x51>
f0104469:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010446e:	5b                   	pop    %ebx
f010446f:	5e                   	pop    %esi
f0104470:	5f                   	pop    %edi
f0104471:	5d                   	pop    %ebp
f0104472:	c3                   	ret    

f0104473 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104473:	55                   	push   %ebp
f0104474:	89 e5                	mov    %esp,%ebp
f0104476:	53                   	push   %ebx
f0104477:	8b 45 08             	mov    0x8(%ebp),%eax
f010447a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f010447d:	89 c2                	mov    %eax,%edx
f010447f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104482:	39 d0                	cmp    %edx,%eax
f0104484:	73 13                	jae    f0104499 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104486:	89 d9                	mov    %ebx,%ecx
f0104488:	38 18                	cmp    %bl,(%eax)
f010448a:	75 06                	jne    f0104492 <memfind+0x1f>
f010448c:	eb 0b                	jmp    f0104499 <memfind+0x26>
f010448e:	38 08                	cmp    %cl,(%eax)
f0104490:	74 07                	je     f0104499 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104492:	83 c0 01             	add    $0x1,%eax
f0104495:	39 d0                	cmp    %edx,%eax
f0104497:	75 f5                	jne    f010448e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104499:	5b                   	pop    %ebx
f010449a:	5d                   	pop    %ebp
f010449b:	c3                   	ret    

f010449c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010449c:	55                   	push   %ebp
f010449d:	89 e5                	mov    %esp,%ebp
f010449f:	57                   	push   %edi
f01044a0:	56                   	push   %esi
f01044a1:	53                   	push   %ebx
f01044a2:	83 ec 04             	sub    $0x4,%esp
f01044a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01044a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01044ab:	0f b6 02             	movzbl (%edx),%eax
f01044ae:	3c 09                	cmp    $0x9,%al
f01044b0:	74 04                	je     f01044b6 <strtol+0x1a>
f01044b2:	3c 20                	cmp    $0x20,%al
f01044b4:	75 0e                	jne    f01044c4 <strtol+0x28>
		s++;
f01044b6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01044b9:	0f b6 02             	movzbl (%edx),%eax
f01044bc:	3c 09                	cmp    $0x9,%al
f01044be:	74 f6                	je     f01044b6 <strtol+0x1a>
f01044c0:	3c 20                	cmp    $0x20,%al
f01044c2:	74 f2                	je     f01044b6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01044c4:	3c 2b                	cmp    $0x2b,%al
f01044c6:	75 0a                	jne    f01044d2 <strtol+0x36>
		s++;
f01044c8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01044cb:	bf 00 00 00 00       	mov    $0x0,%edi
f01044d0:	eb 10                	jmp    f01044e2 <strtol+0x46>
f01044d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01044d7:	3c 2d                	cmp    $0x2d,%al
f01044d9:	75 07                	jne    f01044e2 <strtol+0x46>
		s++, neg = 1;
f01044db:	83 c2 01             	add    $0x1,%edx
f01044de:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01044e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01044e8:	75 15                	jne    f01044ff <strtol+0x63>
f01044ea:	80 3a 30             	cmpb   $0x30,(%edx)
f01044ed:	75 10                	jne    f01044ff <strtol+0x63>
f01044ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01044f3:	75 0a                	jne    f01044ff <strtol+0x63>
		s += 2, base = 16;
f01044f5:	83 c2 02             	add    $0x2,%edx
f01044f8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01044fd:	eb 10                	jmp    f010450f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f01044ff:	85 db                	test   %ebx,%ebx
f0104501:	75 0c                	jne    f010450f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104503:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104505:	80 3a 30             	cmpb   $0x30,(%edx)
f0104508:	75 05                	jne    f010450f <strtol+0x73>
		s++, base = 8;
f010450a:	83 c2 01             	add    $0x1,%edx
f010450d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010450f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104514:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104517:	0f b6 0a             	movzbl (%edx),%ecx
f010451a:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010451d:	89 f3                	mov    %esi,%ebx
f010451f:	80 fb 09             	cmp    $0x9,%bl
f0104522:	77 08                	ja     f010452c <strtol+0x90>
			dig = *s - '0';
f0104524:	0f be c9             	movsbl %cl,%ecx
f0104527:	83 e9 30             	sub    $0x30,%ecx
f010452a:	eb 22                	jmp    f010454e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f010452c:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010452f:	89 f3                	mov    %esi,%ebx
f0104531:	80 fb 19             	cmp    $0x19,%bl
f0104534:	77 08                	ja     f010453e <strtol+0xa2>
			dig = *s - 'a' + 10;
f0104536:	0f be c9             	movsbl %cl,%ecx
f0104539:	83 e9 57             	sub    $0x57,%ecx
f010453c:	eb 10                	jmp    f010454e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f010453e:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104541:	89 f3                	mov    %esi,%ebx
f0104543:	80 fb 19             	cmp    $0x19,%bl
f0104546:	77 16                	ja     f010455e <strtol+0xc2>
			dig = *s - 'A' + 10;
f0104548:	0f be c9             	movsbl %cl,%ecx
f010454b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010454e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104551:	7d 0f                	jge    f0104562 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0104553:	83 c2 01             	add    $0x1,%edx
f0104556:	0f af 45 f0          	imul   -0x10(%ebp),%eax
f010455a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010455c:	eb b9                	jmp    f0104517 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010455e:	89 c1                	mov    %eax,%ecx
f0104560:	eb 02                	jmp    f0104564 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104562:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104564:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104568:	74 05                	je     f010456f <strtol+0xd3>
		*endptr = (char *) s;
f010456a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010456d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010456f:	89 ca                	mov    %ecx,%edx
f0104571:	f7 da                	neg    %edx
f0104573:	85 ff                	test   %edi,%edi
f0104575:	0f 45 c2             	cmovne %edx,%eax
}
f0104578:	83 c4 04             	add    $0x4,%esp
f010457b:	5b                   	pop    %ebx
f010457c:	5e                   	pop    %esi
f010457d:	5f                   	pop    %edi
f010457e:	5d                   	pop    %ebp
f010457f:	c3                   	ret    

f0104580 <__udivdi3>:
f0104580:	83 ec 1c             	sub    $0x1c,%esp
f0104583:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0104587:	89 7c 24 14          	mov    %edi,0x14(%esp)
f010458b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010458f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104593:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0104597:	8b 6c 24 24          	mov    0x24(%esp),%ebp
f010459b:	85 c0                	test   %eax,%eax
f010459d:	89 74 24 10          	mov    %esi,0x10(%esp)
f01045a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01045a5:	89 ea                	mov    %ebp,%edx
f01045a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01045ab:	75 33                	jne    f01045e0 <__udivdi3+0x60>
f01045ad:	39 e9                	cmp    %ebp,%ecx
f01045af:	77 6f                	ja     f0104620 <__udivdi3+0xa0>
f01045b1:	85 c9                	test   %ecx,%ecx
f01045b3:	89 ce                	mov    %ecx,%esi
f01045b5:	75 0b                	jne    f01045c2 <__udivdi3+0x42>
f01045b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01045bc:	31 d2                	xor    %edx,%edx
f01045be:	f7 f1                	div    %ecx
f01045c0:	89 c6                	mov    %eax,%esi
f01045c2:	31 d2                	xor    %edx,%edx
f01045c4:	89 e8                	mov    %ebp,%eax
f01045c6:	f7 f6                	div    %esi
f01045c8:	89 c5                	mov    %eax,%ebp
f01045ca:	89 f8                	mov    %edi,%eax
f01045cc:	f7 f6                	div    %esi
f01045ce:	89 ea                	mov    %ebp,%edx
f01045d0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01045d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01045d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01045dc:	83 c4 1c             	add    $0x1c,%esp
f01045df:	c3                   	ret    
f01045e0:	39 e8                	cmp    %ebp,%eax
f01045e2:	77 24                	ja     f0104608 <__udivdi3+0x88>
f01045e4:	0f bd c8             	bsr    %eax,%ecx
f01045e7:	83 f1 1f             	xor    $0x1f,%ecx
f01045ea:	89 0c 24             	mov    %ecx,(%esp)
f01045ed:	75 49                	jne    f0104638 <__udivdi3+0xb8>
f01045ef:	8b 74 24 08          	mov    0x8(%esp),%esi
f01045f3:	39 74 24 04          	cmp    %esi,0x4(%esp)
f01045f7:	0f 86 ab 00 00 00    	jbe    f01046a8 <__udivdi3+0x128>
f01045fd:	39 e8                	cmp    %ebp,%eax
f01045ff:	0f 82 a3 00 00 00    	jb     f01046a8 <__udivdi3+0x128>
f0104605:	8d 76 00             	lea    0x0(%esi),%esi
f0104608:	31 d2                	xor    %edx,%edx
f010460a:	31 c0                	xor    %eax,%eax
f010460c:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104610:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104614:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104618:	83 c4 1c             	add    $0x1c,%esp
f010461b:	c3                   	ret    
f010461c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104620:	89 f8                	mov    %edi,%eax
f0104622:	f7 f1                	div    %ecx
f0104624:	31 d2                	xor    %edx,%edx
f0104626:	8b 74 24 10          	mov    0x10(%esp),%esi
f010462a:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010462e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104632:	83 c4 1c             	add    $0x1c,%esp
f0104635:	c3                   	ret    
f0104636:	66 90                	xchg   %ax,%ax
f0104638:	0f b6 0c 24          	movzbl (%esp),%ecx
f010463c:	89 c6                	mov    %eax,%esi
f010463e:	b8 20 00 00 00       	mov    $0x20,%eax
f0104643:	8b 6c 24 04          	mov    0x4(%esp),%ebp
f0104647:	2b 04 24             	sub    (%esp),%eax
f010464a:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010464e:	d3 e6                	shl    %cl,%esi
f0104650:	89 c1                	mov    %eax,%ecx
f0104652:	d3 ed                	shr    %cl,%ebp
f0104654:	0f b6 0c 24          	movzbl (%esp),%ecx
f0104658:	09 f5                	or     %esi,%ebp
f010465a:	8b 74 24 04          	mov    0x4(%esp),%esi
f010465e:	d3 e6                	shl    %cl,%esi
f0104660:	89 c1                	mov    %eax,%ecx
f0104662:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104666:	89 d6                	mov    %edx,%esi
f0104668:	d3 ee                	shr    %cl,%esi
f010466a:	0f b6 0c 24          	movzbl (%esp),%ecx
f010466e:	d3 e2                	shl    %cl,%edx
f0104670:	89 c1                	mov    %eax,%ecx
f0104672:	d3 ef                	shr    %cl,%edi
f0104674:	09 d7                	or     %edx,%edi
f0104676:	89 f2                	mov    %esi,%edx
f0104678:	89 f8                	mov    %edi,%eax
f010467a:	f7 f5                	div    %ebp
f010467c:	89 d6                	mov    %edx,%esi
f010467e:	89 c7                	mov    %eax,%edi
f0104680:	f7 64 24 04          	mull   0x4(%esp)
f0104684:	39 d6                	cmp    %edx,%esi
f0104686:	72 30                	jb     f01046b8 <__udivdi3+0x138>
f0104688:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f010468c:	0f b6 0c 24          	movzbl (%esp),%ecx
f0104690:	d3 e5                	shl    %cl,%ebp
f0104692:	39 c5                	cmp    %eax,%ebp
f0104694:	73 04                	jae    f010469a <__udivdi3+0x11a>
f0104696:	39 d6                	cmp    %edx,%esi
f0104698:	74 1e                	je     f01046b8 <__udivdi3+0x138>
f010469a:	89 f8                	mov    %edi,%eax
f010469c:	31 d2                	xor    %edx,%edx
f010469e:	e9 69 ff ff ff       	jmp    f010460c <__udivdi3+0x8c>
f01046a3:	90                   	nop
f01046a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046a8:	31 d2                	xor    %edx,%edx
f01046aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01046af:	e9 58 ff ff ff       	jmp    f010460c <__udivdi3+0x8c>
f01046b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046b8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01046bb:	31 d2                	xor    %edx,%edx
f01046bd:	8b 74 24 10          	mov    0x10(%esp),%esi
f01046c1:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01046c5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01046c9:	83 c4 1c             	add    $0x1c,%esp
f01046cc:	c3                   	ret    
f01046cd:	00 00                	add    %al,(%eax)
	...

f01046d0 <__umoddi3>:
f01046d0:	83 ec 2c             	sub    $0x2c,%esp
f01046d3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01046d7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01046db:	89 74 24 20          	mov    %esi,0x20(%esp)
f01046df:	8b 74 24 38          	mov    0x38(%esp),%esi
f01046e3:	89 7c 24 24          	mov    %edi,0x24(%esp)
f01046e7:	8b 7c 24 34          	mov    0x34(%esp),%edi
f01046eb:	85 c0                	test   %eax,%eax
f01046ed:	89 c2                	mov    %eax,%edx
f01046ef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f01046f3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01046f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01046fb:	89 74 24 10          	mov    %esi,0x10(%esp)
f01046ff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0104703:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0104707:	75 1f                	jne    f0104728 <__umoddi3+0x58>
f0104709:	39 fe                	cmp    %edi,%esi
f010470b:	76 63                	jbe    f0104770 <__umoddi3+0xa0>
f010470d:	89 c8                	mov    %ecx,%eax
f010470f:	89 fa                	mov    %edi,%edx
f0104711:	f7 f6                	div    %esi
f0104713:	89 d0                	mov    %edx,%eax
f0104715:	31 d2                	xor    %edx,%edx
f0104717:	8b 74 24 20          	mov    0x20(%esp),%esi
f010471b:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010471f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0104723:	83 c4 2c             	add    $0x2c,%esp
f0104726:	c3                   	ret    
f0104727:	90                   	nop
f0104728:	39 f8                	cmp    %edi,%eax
f010472a:	77 64                	ja     f0104790 <__umoddi3+0xc0>
f010472c:	0f bd e8             	bsr    %eax,%ebp
f010472f:	83 f5 1f             	xor    $0x1f,%ebp
f0104732:	75 74                	jne    f01047a8 <__umoddi3+0xd8>
f0104734:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104738:	39 7c 24 10          	cmp    %edi,0x10(%esp)
f010473c:	0f 87 0e 01 00 00    	ja     f0104850 <__umoddi3+0x180>
f0104742:	8b 7c 24 0c          	mov    0xc(%esp),%edi
f0104746:	29 f1                	sub    %esi,%ecx
f0104748:	19 c7                	sbb    %eax,%edi
f010474a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010474e:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0104752:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104756:	8b 54 24 18          	mov    0x18(%esp),%edx
f010475a:	8b 74 24 20          	mov    0x20(%esp),%esi
f010475e:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0104762:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0104766:	83 c4 2c             	add    $0x2c,%esp
f0104769:	c3                   	ret    
f010476a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104770:	85 f6                	test   %esi,%esi
f0104772:	89 f5                	mov    %esi,%ebp
f0104774:	75 0b                	jne    f0104781 <__umoddi3+0xb1>
f0104776:	b8 01 00 00 00       	mov    $0x1,%eax
f010477b:	31 d2                	xor    %edx,%edx
f010477d:	f7 f6                	div    %esi
f010477f:	89 c5                	mov    %eax,%ebp
f0104781:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104785:	31 d2                	xor    %edx,%edx
f0104787:	f7 f5                	div    %ebp
f0104789:	89 c8                	mov    %ecx,%eax
f010478b:	f7 f5                	div    %ebp
f010478d:	eb 84                	jmp    f0104713 <__umoddi3+0x43>
f010478f:	90                   	nop
f0104790:	89 c8                	mov    %ecx,%eax
f0104792:	89 fa                	mov    %edi,%edx
f0104794:	8b 74 24 20          	mov    0x20(%esp),%esi
f0104798:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010479c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01047a0:	83 c4 2c             	add    $0x2c,%esp
f01047a3:	c3                   	ret    
f01047a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047a8:	8b 44 24 10          	mov    0x10(%esp),%eax
f01047ac:	be 20 00 00 00       	mov    $0x20,%esi
f01047b1:	89 e9                	mov    %ebp,%ecx
f01047b3:	29 ee                	sub    %ebp,%esi
f01047b5:	d3 e2                	shl    %cl,%edx
f01047b7:	89 f1                	mov    %esi,%ecx
f01047b9:	d3 e8                	shr    %cl,%eax
f01047bb:	89 e9                	mov    %ebp,%ecx
f01047bd:	09 d0                	or     %edx,%eax
f01047bf:	89 fa                	mov    %edi,%edx
f01047c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047c5:	8b 44 24 10          	mov    0x10(%esp),%eax
f01047c9:	d3 e0                	shl    %cl,%eax
f01047cb:	89 f1                	mov    %esi,%ecx
f01047cd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01047d1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01047d5:	d3 ea                	shr    %cl,%edx
f01047d7:	89 e9                	mov    %ebp,%ecx
f01047d9:	d3 e7                	shl    %cl,%edi
f01047db:	89 f1                	mov    %esi,%ecx
f01047dd:	d3 e8                	shr    %cl,%eax
f01047df:	89 e9                	mov    %ebp,%ecx
f01047e1:	09 f8                	or     %edi,%eax
f01047e3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01047e7:	f7 74 24 0c          	divl   0xc(%esp)
f01047eb:	d3 e7                	shl    %cl,%edi
f01047ed:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01047f1:	89 d7                	mov    %edx,%edi
f01047f3:	f7 64 24 10          	mull   0x10(%esp)
f01047f7:	39 d7                	cmp    %edx,%edi
f01047f9:	89 c1                	mov    %eax,%ecx
f01047fb:	89 54 24 14          	mov    %edx,0x14(%esp)
f01047ff:	72 3b                	jb     f010483c <__umoddi3+0x16c>
f0104801:	39 44 24 18          	cmp    %eax,0x18(%esp)
f0104805:	72 31                	jb     f0104838 <__umoddi3+0x168>
f0104807:	8b 44 24 18          	mov    0x18(%esp),%eax
f010480b:	29 c8                	sub    %ecx,%eax
f010480d:	19 d7                	sbb    %edx,%edi
f010480f:	89 e9                	mov    %ebp,%ecx
f0104811:	89 fa                	mov    %edi,%edx
f0104813:	d3 e8                	shr    %cl,%eax
f0104815:	89 f1                	mov    %esi,%ecx
f0104817:	d3 e2                	shl    %cl,%edx
f0104819:	89 e9                	mov    %ebp,%ecx
f010481b:	09 d0                	or     %edx,%eax
f010481d:	89 fa                	mov    %edi,%edx
f010481f:	d3 ea                	shr    %cl,%edx
f0104821:	8b 74 24 20          	mov    0x20(%esp),%esi
f0104825:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0104829:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f010482d:	83 c4 2c             	add    $0x2c,%esp
f0104830:	c3                   	ret    
f0104831:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104838:	39 d7                	cmp    %edx,%edi
f010483a:	75 cb                	jne    f0104807 <__umoddi3+0x137>
f010483c:	8b 54 24 14          	mov    0x14(%esp),%edx
f0104840:	89 c1                	mov    %eax,%ecx
f0104842:	2b 4c 24 10          	sub    0x10(%esp),%ecx
f0104846:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f010484a:	eb bb                	jmp    f0104807 <__umoddi3+0x137>
f010484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104850:	3b 44 24 18          	cmp    0x18(%esp),%eax
f0104854:	0f 82 e8 fe ff ff    	jb     f0104742 <__umoddi3+0x72>
f010485a:	e9 f3 fe ff ff       	jmp    f0104752 <__umoddi3+0x82>
