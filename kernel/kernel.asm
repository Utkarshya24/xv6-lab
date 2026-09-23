
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8e010113          	addi	sp,sp,-1824 # 800078e0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd5ff>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	d7a78793          	addi	a5,a5,-646 # 80000dee <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	20a020ef          	jal	8000231e <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	0000f517          	auipc	a0,0xf
    80000192:	75250513          	addi	a0,a0,1874 # 8000f8e0 <cons>
    80000196:	1fb000ef          	jal	80000b90 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	0000f497          	auipc	s1,0xf
    8000019e:	74648493          	addi	s1,s1,1862 # 8000f8e0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	0000f917          	auipc	s2,0xf
    800001a6:	7d690913          	addi	s2,s2,2006 # 8000f978 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	6ea010ef          	jal	800018a4 <myproc>
    800001be:	7c3010ef          	jal	80002180 <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	55b010ef          	jal	80001f20 <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	251000ef          	jal	80000c1c <release>
      sleep();
    800001d0:	58d010ef          	jal	80001f5c <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	1bb000ef          	jal	80000b90 <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	0000f717          	auipc	a4,0xf
    800001ec:	6f870713          	addi	a4,a4,1784 # 8000f8e0 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	0b8020ef          	jal	800022d2 <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	0000f517          	auipc	a0,0xf
    80000236:	6ae50513          	addi	a0,a0,1710 # 8000f8e0 <cons>
    8000023a:	1e3000ef          	jal	80000c1c <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	0000f717          	auipc	a4,0xf
    80000260:	70f72e23          	sw	a5,1820(a4) # 8000f978 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	0000f517          	auipc	a0,0xf
    80000276:	66e50513          	addi	a0,a0,1646 # 8000f8e0 <cons>
    8000027a:	1a3000ef          	jal	80000c1c <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	0000f517          	auipc	a0,0xf
    800002ca:	61a50513          	addi	a0,a0,1562 # 8000f8e0 <cons>
    800002ce:	0c3000ef          	jal	80000b90 <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	082020ef          	jal	8000236a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	0000f517          	auipc	a0,0xf
    800002f0:	5f450513          	addi	a0,a0,1524 # 8000f8e0 <cons>
    800002f4:	129000ef          	jal	80000c1c <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	0000f717          	auipc	a4,0xf
    8000030e:	5d670713          	addi	a4,a4,1494 # 8000f8e0 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	0000f797          	auipc	a5,0xf
    80000334:	5b078793          	addi	a5,a5,1456 # 8000f8e0 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	0000f797          	auipc	a5,0xf
    80000362:	61a7a783          	lw	a5,1562(a5) # 8000f978 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	0000f717          	auipc	a4,0xf
    80000378:	56c70713          	addi	a4,a4,1388 # 8000f8e0 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	0000f497          	auipc	s1,0xf
    80000388:	55c48493          	addi	s1,s1,1372 # 8000f8e0 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	0000f717          	auipc	a4,0xf
    800003ca:	51a70713          	addi	a4,a4,1306 # 8000f8e0 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	0000f717          	auipc	a4,0xf
    800003e0:	5af72223          	sw	a5,1444(a4) # 8000f980 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	0000f797          	auipc	a5,0xf
    800003fe:	4e678793          	addi	a5,a5,1254 # 8000f8e0 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	0000f797          	auipc	a5,0xf
    80000422:	54c7af23          	sw	a2,1374(a5) # 8000f97c <cons+0x9c>
        wakeup(&cons.r);
    80000426:	0000f517          	auipc	a0,0xf
    8000042a:	55250513          	addi	a0,a0,1362 # 8000f978 <cons+0x98>
    8000042e:	35f010ef          	jal	80001f8c <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00007597          	auipc	a1,0x7
    80000440:	bc458593          	addi	a1,a1,-1084 # 80007000 <etext>
    80000444:	0000f517          	auipc	a0,0xf
    80000448:	49c50513          	addi	a0,a0,1180 # 8000f8e0 <cons>
    8000044c:	6ce000ef          	jal	80000b1a <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	00020797          	auipc	a5,0x20
    80000458:	c1478793          	addi	a5,a5,-1004 # 80020068 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007617          	auipc	a2,0x7
    80000492:	2c260613          	addi	a2,a2,706 # 80007750 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	00007797          	auipc	a5,0x7
    8000052c:	38c7a783          	lw	a5,908(a5) # 800078b4 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	0000f517          	auipc	a0,0xf
    80000574:	41850513          	addi	a0,a0,1048 # 8000f988 <pr>
    80000578:	618000ef          	jal	80000b90 <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00007b97          	auipc	s7,0x7
    8000073c:	018b8b93          	addi	s7,s7,24 # 80007750 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00007917          	auipc	s2,0x7
    8000079c:	87090913          	addi	s2,s2,-1936 # 80007008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	00007797          	auipc	a5,0x7
    800007d0:	0e87a783          	lw	a5,232(a5) # 800078b4 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	0000f517          	auipc	a0,0xf
    800007e6:	1a650513          	addi	a0,a0,422 # 8000f988 <pr>
    800007ea:	432000ef          	jal	80000c1c <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	00007797          	auipc	a5,0x7
    80000804:	0b27aa23          	sw	s2,180(a5) # 800078b4 <panicking>
  printk("panic: ");
    80000808:	00007517          	auipc	a0,0x7
    8000080c:	81050513          	addi	a0,a0,-2032 # 80007018 <etext+0x18>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00007517          	auipc	a0,0x7
    8000081a:	80a50513          	addi	a0,a0,-2038 # 80007020 <etext+0x20>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	00007797          	auipc	a5,0x7
    80000826:	0927a723          	sw	s2,142(a5) # 800078b0 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00006597          	auipc	a1,0x6
    80000838:	7f458593          	addi	a1,a1,2036 # 80007028 <etext+0x28>
    8000083c:	0000f517          	auipc	a0,0xf
    80000840:	14c50513          	addi	a0,a0,332 # 8000f988 <pr>
    80000844:	2d6000ef          	jal	80000b1a <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00006597          	auipc	a1,0x6
    80000890:	7a458593          	addi	a1,a1,1956 # 80007030 <etext+0x30>
    80000894:	0000f517          	auipc	a0,0xf
    80000898:	10c50513          	addi	a0,a0,268 # 8000f9a0 <tx_lock>
    8000089c:	009030ef          	jal	800040a4 <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	0000f517          	auipc	a0,0xf
    800008bc:	0e850513          	addi	a0,a0,232 # 8000f9a0 <tx_lock>
    800008c0:	01b030ef          	jal	800040da <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	00007a17          	auipc	s4,0x7
    800008d6:	fe6a0a13          	addi	s4,s4,-26 # 800078b8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	626010ef          	jal	80001f20 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	654010ef          	jal	80001f5c <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	0000f517          	auipc	a0,0xf
    8000091a:	08a50513          	addi	a0,a0,138 # 8000f9a0 <tx_lock>
    8000091e:	011030ef          	jal	8000412e <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	00007797          	auipc	a5,0x7
    8000093e:	f7a7a783          	lw	a5,-134(a5) # 800078b4 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	00007797          	auipc	a5,0x7
    80000948:	f6c7a783          	lw	a5,-148(a5) # 800078b0 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f4a7a783          	lw	a5,-182(a5) # 800078b4 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	1dc000ef          	jal	80000b5a <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	24a000ef          	jal	80000bd0 <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	00007517          	auipc	a0,0x7
    800009d2:	eea50513          	addi	a0,a0,-278 # 800078b8 <tx_chan>
    800009d6:	5b6010ef          	jal	80001f8c <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	80478793          	addi	a5,a5,-2044 # 80021200 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	240000ef          	jal	80000c54 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	0000f917          	auipc	s2,0xf
    80000a1c:	fb890913          	addi	s2,s2,-72 # 8000f9d0 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	16e000ef          	jal	80000b90 <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	1ea000ef          	jal	80000c1c <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00006517          	auipc	a0,0x6
    80000a46:	5f650513          	addi	a0,a0,1526 # 80007038 <etext+0x38>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00006597          	auipc	a1,0x6
    80000aa2:	5a258593          	addi	a1,a1,1442 # 80007040 <etext+0x40>
    80000aa6:	0000f517          	auipc	a0,0xf
    80000aaa:	f2a50513          	addi	a0,a0,-214 # 8000f9d0 <kmem>
    80000aae:	06c000ef          	jal	80000b1a <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00020517          	auipc	a0,0x20
    80000aba:	74a50513          	addi	a0,a0,1866 # 80021200 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	0000f497          	auipc	s1,0xf
    80000ad8:	efc48493          	addi	s1,s1,-260 # 8000f9d0 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0b2000ef          	jal	80000b90 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	0000f517          	auipc	a0,0xf
    80000aec:	ee850513          	addi	a0,a0,-280 # 8000f9d0 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	12a000ef          	jal	80000c1c <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	158000ef          	jal	80000c54 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	0000f517          	auipc	a0,0xf
    80000b10:	ec450513          	addi	a0,a0,-316 # 8000f9d0 <kmem>
    80000b14:	108000ef          	jal	80000c1c <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e422                	sd	s0,8(sp)
    80000b1e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b20:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b22:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b26:	00053823          	sd	zero,16(a0)
}
    80000b2a:	6422                	ld	s0,8(sp)
    80000b2c:	0141                	addi	sp,sp,16
    80000b2e:	8082                	ret

0000000080000b30 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b30:	411c                	lw	a5,0(a0)
    80000b32:	e399                	bnez	a5,80000b38 <holding+0x8>
    80000b34:	4501                	li	a0,0
  return r;
}
    80000b36:	8082                	ret
{
    80000b38:	1101                	addi	sp,sp,-32
    80000b3a:	ec06                	sd	ra,24(sp)
    80000b3c:	e822                	sd	s0,16(sp)
    80000b3e:	e426                	sd	s1,8(sp)
    80000b40:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b42:	6904                	ld	s1,16(a0)
    80000b44:	545000ef          	jal	80001888 <mycpu>
    80000b48:	40a48533          	sub	a0,s1,a0
    80000b4c:	00153513          	seqz	a0,a0
}
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret

0000000080000b5a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b5a:	1101                	addi	sp,sp,-32
    80000b5c:	ec06                	sd	ra,24(sp)
    80000b5e:	e822                	sd	s0,16(sp)
    80000b60:	e426                	sd	s1,8(sp)
    80000b62:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000b64:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000b68:	521000ef          	jal	80001888 <mycpu>
    80000b6c:	5d3c                	lw	a5,120(a0)
    80000b6e:	cb99                	beqz	a5,80000b84 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b70:	519000ef          	jal	80001888 <mycpu>
    80000b74:	5d3c                	lw	a5,120(a0)
    80000b76:	2785                	addiw	a5,a5,1
    80000b78:	dd3c                	sw	a5,120(a0)
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret
    mycpu()->intena = old;
    80000b84:	505000ef          	jal	80001888 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000b88:	8085                	srli	s1,s1,0x1
    80000b8a:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000b8c:	dd64                	sw	s1,124(a0)
    80000b8e:	b7cd                	j	80000b70 <push_off+0x16>

0000000080000b90 <acquire>:
{
    80000b90:	1101                	addi	sp,sp,-32
    80000b92:	ec06                	sd	ra,24(sp)
    80000b94:	e822                	sd	s0,16(sp)
    80000b96:	e426                	sd	s1,8(sp)
    80000b98:	1000                	addi	s0,sp,32
    80000b9a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b9c:	fbfff0ef          	jal	80000b5a <push_off>
  if (holding(lk))
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	f8fff0ef          	jal	80000b30 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000ba6:	4705                	li	a4,1
  if (holding(lk))
    80000ba8:	ed11                	bnez	a0,80000bc4 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000baa:	87ba                	mv	a5,a4
    80000bac:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bb0:	2781                	sext.w	a5,a5
    80000bb2:	ffe5                	bnez	a5,80000baa <acquire+0x1a>
  lk->cpu = mycpu();
    80000bb4:	4d5000ef          	jal	80001888 <mycpu>
    80000bb8:	e888                	sd	a0,16(s1)
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret
    panic("acquire");
    80000bc4:	00006517          	auipc	a0,0x6
    80000bc8:	48450513          	addi	a0,a0,1156 # 80007048 <etext+0x48>
    80000bcc:	c25ff0ef          	jal	800007f0 <panic>

0000000080000bd0 <pop_off>:

void
pop_off(void)
{
    80000bd0:	1141                	addi	sp,sp,-16
    80000bd2:	e406                	sd	ra,8(sp)
    80000bd4:	e022                	sd	s0,0(sp)
    80000bd6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bd8:	4b1000ef          	jal	80001888 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bdc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000be0:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000be2:	e38d                	bnez	a5,80000c04 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	02f05563          	blez	a5,80000c10 <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000bea:	37fd                	addiw	a5,a5,-1
    80000bec:	0007871b          	sext.w	a4,a5
    80000bf0:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000bf2:	e709                	bnez	a4,80000bfc <pop_off+0x2c>
    80000bf4:	5d7c                	lw	a5,124(a0)
    80000bf6:	c399                	beqz	a5,80000bfc <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000bf8:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000bfc:	60a2                	ld	ra,8(sp)
    80000bfe:	6402                	ld	s0,0(sp)
    80000c00:	0141                	addi	sp,sp,16
    80000c02:	8082                	ret
    panic("pop_off - interruptible");
    80000c04:	00006517          	auipc	a0,0x6
    80000c08:	44c50513          	addi	a0,a0,1100 # 80007050 <etext+0x50>
    80000c0c:	be5ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000c10:	00006517          	auipc	a0,0x6
    80000c14:	45850513          	addi	a0,a0,1112 # 80007068 <etext+0x68>
    80000c18:	bd9ff0ef          	jal	800007f0 <panic>

0000000080000c1c <release>:
{
    80000c1c:	1101                	addi	sp,sp,-32
    80000c1e:	ec06                	sd	ra,24(sp)
    80000c20:	e822                	sd	s0,16(sp)
    80000c22:	e426                	sd	s1,8(sp)
    80000c24:	1000                	addi	s0,sp,32
    80000c26:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c28:	f09ff0ef          	jal	80000b30 <holding>
    80000c2c:	cd11                	beqz	a0,80000c48 <release+0x2c>
  lk->cpu = 0;
    80000c2e:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c32:	0f50000f          	fence	iorw,ow
    80000c36:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c3a:	f97ff0ef          	jal	80000bd0 <pop_off>
}
    80000c3e:	60e2                	ld	ra,24(sp)
    80000c40:	6442                	ld	s0,16(sp)
    80000c42:	64a2                	ld	s1,8(sp)
    80000c44:	6105                	addi	sp,sp,32
    80000c46:	8082                	ret
    panic("release");
    80000c48:	00006517          	auipc	a0,0x6
    80000c4c:	42850513          	addi	a0,a0,1064 # 80007070 <etext+0x70>
    80000c50:	ba1ff0ef          	jal	800007f0 <panic>

0000000080000c54 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c54:	1141                	addi	sp,sp,-16
    80000c56:	e422                	sd	s0,8(sp)
    80000c58:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c5a:	ca19                	beqz	a2,80000c70 <memset+0x1c>
    80000c5c:	87aa                	mv	a5,a0
    80000c5e:	1602                	slli	a2,a2,0x20
    80000c60:	9201                	srli	a2,a2,0x20
    80000c62:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c66:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000c6a:	0785                	addi	a5,a5,1
    80000c6c:	fee79de3          	bne	a5,a4,80000c66 <memset+0x12>
  }
  return dst;
}
    80000c70:	6422                	ld	s0,8(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret

0000000080000c76 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c76:	1141                	addi	sp,sp,-16
    80000c78:	e422                	sd	s0,8(sp)
    80000c7a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000c7c:	ca05                	beqz	a2,80000cac <memcmp+0x36>
    80000c7e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c82:	1682                	slli	a3,a3,0x20
    80000c84:	9281                	srli	a3,a3,0x20
    80000c86:	0685                	addi	a3,a3,1
    80000c88:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000c8a:	00054783          	lbu	a5,0(a0)
    80000c8e:	0005c703          	lbu	a4,0(a1)
    80000c92:	00e79863          	bne	a5,a4,80000ca2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c96:	0505                	addi	a0,a0,1
    80000c98:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000c9a:	fed518e3          	bne	a0,a3,80000c8a <memcmp+0x14>
  }

  return 0;
    80000c9e:	4501                	li	a0,0
    80000ca0:	a019                	j	80000ca6 <memcmp+0x30>
      return *s1 - *s2;
    80000ca2:	40e7853b          	subw	a0,a5,a4
}
    80000ca6:	6422                	ld	s0,8(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
  return 0;
    80000cac:	4501                	li	a0,0
    80000cae:	bfe5                	j	80000ca6 <memcmp+0x30>

0000000080000cb0 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e422                	sd	s0,8(sp)
    80000cb4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cb6:	c205                	beqz	a2,80000cd6 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cb8:	02a5e263          	bltu	a1,a0,80000cdc <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cbc:	1602                	slli	a2,a2,0x20
    80000cbe:	9201                	srli	a2,a2,0x20
    80000cc0:	00c587b3          	add	a5,a1,a2
{
    80000cc4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cc6:	0585                	addi	a1,a1,1
    80000cc8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdde01>
    80000cca:	fff5c683          	lbu	a3,-1(a1)
    80000cce:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000cd2:	feb79ae3          	bne	a5,a1,80000cc6 <memmove+0x16>

  return dst;
}
    80000cd6:	6422                	ld	s0,8(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
  if (s < d && s + n > d) {
    80000cdc:	02061693          	slli	a3,a2,0x20
    80000ce0:	9281                	srli	a3,a3,0x20
    80000ce2:	00d58733          	add	a4,a1,a3
    80000ce6:	fce57be3          	bgeu	a0,a4,80000cbc <memmove+0xc>
    d += n;
    80000cea:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000cec:	fff6079b          	addiw	a5,a2,-1
    80000cf0:	1782                	slli	a5,a5,0x20
    80000cf2:	9381                	srli	a5,a5,0x20
    80000cf4:	fff7c793          	not	a5,a5
    80000cf8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cfa:	177d                	addi	a4,a4,-1
    80000cfc:	16fd                	addi	a3,a3,-1
    80000cfe:	00074603          	lbu	a2,0(a4)
    80000d02:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d06:	fef71ae3          	bne	a4,a5,80000cfa <memmove+0x4a>
    80000d0a:	b7f1                	j	80000cd6 <memmove+0x26>

0000000080000d0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e406                	sd	ra,8(sp)
    80000d10:	e022                	sd	s0,0(sp)
    80000d12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d14:	f9dff0ef          	jal	80000cb0 <memmove>
}
    80000d18:	60a2                	ld	ra,8(sp)
    80000d1a:	6402                	ld	s0,0(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret

0000000080000d20 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d20:	1141                	addi	sp,sp,-16
    80000d22:	e422                	sd	s0,8(sp)
    80000d24:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d26:	ce11                	beqz	a2,80000d42 <strncmp+0x22>
    80000d28:	00054783          	lbu	a5,0(a0)
    80000d2c:	cf89                	beqz	a5,80000d46 <strncmp+0x26>
    80000d2e:	0005c703          	lbu	a4,0(a1)
    80000d32:	00f71a63          	bne	a4,a5,80000d46 <strncmp+0x26>
    n--, p++, q++;
    80000d36:	367d                	addiw	a2,a2,-1
    80000d38:	0505                	addi	a0,a0,1
    80000d3a:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d3c:	f675                	bnez	a2,80000d28 <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d3e:	4501                	li	a0,0
    80000d40:	a801                	j	80000d50 <strncmp+0x30>
    80000d42:	4501                	li	a0,0
    80000d44:	a031                	j	80000d50 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d46:	00054503          	lbu	a0,0(a0)
    80000d4a:	0005c783          	lbu	a5,0(a1)
    80000d4e:	9d1d                	subw	a0,a0,a5
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d5c:	87aa                	mv	a5,a0
    80000d5e:	86b2                	mv	a3,a2
    80000d60:	367d                	addiw	a2,a2,-1
    80000d62:	02d05563          	blez	a3,80000d8c <strncpy+0x36>
    80000d66:	0785                	addi	a5,a5,1
    80000d68:	0005c703          	lbu	a4,0(a1)
    80000d6c:	fee78fa3          	sb	a4,-1(a5)
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	f775                	bnez	a4,80000d5e <strncpy+0x8>
    ;
  while (n-- > 0)
    80000d74:	873e                	mv	a4,a5
    80000d76:	9fb5                	addw	a5,a5,a3
    80000d78:	37fd                	addiw	a5,a5,-1
    80000d7a:	00c05963          	blez	a2,80000d8c <strncpy+0x36>
    *s++ = 0;
    80000d7e:	0705                	addi	a4,a4,1
    80000d80:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000d84:	40e786bb          	subw	a3,a5,a4
    80000d88:	fed04be3          	bgtz	a3,80000d7e <strncpy+0x28>
  return os;
}
    80000d8c:	6422                	ld	s0,8(sp)
    80000d8e:	0141                	addi	sp,sp,16
    80000d90:	8082                	ret

0000000080000d92 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000d98:	02c05363          	blez	a2,80000dbe <safestrcpy+0x2c>
    80000d9c:	fff6069b          	addiw	a3,a2,-1
    80000da0:	1682                	slli	a3,a3,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	96ae                	add	a3,a3,a1
    80000da6:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000da8:	00d58963          	beq	a1,a3,80000dba <safestrcpy+0x28>
    80000dac:	0585                	addi	a1,a1,1
    80000dae:	0785                	addi	a5,a5,1
    80000db0:	fff5c703          	lbu	a4,-1(a1)
    80000db4:	fee78fa3          	sb	a4,-1(a5)
    80000db8:	fb65                	bnez	a4,80000da8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000dba:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dbe:	6422                	ld	s0,8(sp)
    80000dc0:	0141                	addi	sp,sp,16
    80000dc2:	8082                	ret

0000000080000dc4 <strlen>:

int
strlen(const char *s)
{
    80000dc4:	1141                	addi	sp,sp,-16
    80000dc6:	e422                	sd	s0,8(sp)
    80000dc8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000dca:	00054783          	lbu	a5,0(a0)
    80000dce:	cf91                	beqz	a5,80000dea <strlen+0x26>
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	87aa                	mv	a5,a0
    80000dd4:	86be                	mv	a3,a5
    80000dd6:	0785                	addi	a5,a5,1
    80000dd8:	fff7c703          	lbu	a4,-1(a5)
    80000ddc:	ff65                	bnez	a4,80000dd4 <strlen+0x10>
    80000dde:	40a6853b          	subw	a0,a3,a0
    80000de2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000de4:	6422                	ld	s0,8(sp)
    80000de6:	0141                	addi	sp,sp,16
    80000de8:	8082                	ret
  for (n = 0; s[n]; n++)
    80000dea:	4501                	li	a0,0
    80000dec:	bfe5                	j	80000de4 <strlen+0x20>

0000000080000dee <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000df6:	283000ef          	jal	80001878 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000dfa:	00007717          	auipc	a4,0x7
    80000dfe:	ac270713          	addi	a4,a4,-1342 # 800078bc <started>
  if (cpuid() == 0) {
    80000e02:	c51d                	beqz	a0,80000e30 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e04:	431c                	lw	a5,0(a4)
    80000e06:	0ff0000f          	fence
    80000e0a:	2781                	sext.w	a5,a5
    80000e0c:	dfe5                	beqz	a5,80000e04 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e0e:	26b000ef          	jal	80001878 <cpuid>
    80000e12:	85aa                	mv	a1,a0
    80000e14:	00006517          	auipc	a0,0x6
    80000e18:	28450513          	addi	a0,a0,644 # 80007098 <etext+0x98>
    80000e1c:	eeeff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e20:	084000ef          	jal	80000ea4 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e24:	6c6010ef          	jal	800024ea <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e28:	111040ef          	jal	80005738 <plicinithart>
  }

  scheduler();
    80000e2c:	715000ef          	jal	80001d40 <scheduler>
    consoleinit();
    80000e30:	e04ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000e34:	9f9ff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	24050513          	addi	a0,a0,576 # 80007078 <etext+0x78>
    80000e40:	ecaff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	23c50513          	addi	a0,a0,572 # 80007080 <etext+0x80>
    80000e4c:	ebeff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e50:	00006517          	auipc	a0,0x6
    80000e54:	22850513          	addi	a0,a0,552 # 80007078 <etext+0x78>
    80000e58:	eb2ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e5c:	c3bff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000e60:	2ce000ef          	jal	8000112e <kvminit>
    kvminithart();      // turn on paging
    80000e64:	040000ef          	jal	80000ea4 <kvminithart>
    procinit();         // process table
    80000e68:	15b000ef          	jal	800017c2 <procinit>
    trapinit();         // trap vectors
    80000e6c:	65a010ef          	jal	800024c6 <trapinit>
    trapinithart();     // install kernel trap vector
    80000e70:	67a010ef          	jal	800024ea <trapinithart>
    plicinit();         // set up interrupt controller
    80000e74:	0ab040ef          	jal	8000571e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e78:	0c1040ef          	jal	80005738 <plicinithart>
    binit();            // buffer cache
    80000e7c:	5b7010ef          	jal	80002c32 <binit>
    iinit();            // inode table
    80000e80:	33c020ef          	jal	800031bc <iinit>
    fileinit();         // file table
    80000e84:	32c030ef          	jal	800041b0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e88:	1a1040ef          	jal	80005828 <virtio_disk_init>
    userinit();         // first user process
    80000e8c:	509000ef          	jal	80001b94 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000e90:	00007797          	auipc	a5,0x7
    80000e94:	a2c78793          	addi	a5,a5,-1492 # 800078bc <started>
    80000e98:	4705                	li	a4,1
    80000e9a:	0f50000f          	fence	iorw,ow
    80000e9e:	08e7a02f          	amoswap.w	zero,a4,(a5)
    80000ea2:	b769                	j	80000e2c <main+0x3e>

0000000080000ea4 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000eaa:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eae:	00007797          	auipc	a5,0x7
    80000eb2:	a127b783          	ld	a5,-1518(a5) # 800078c0 <kernel_pagetable>
    80000eb6:	83b1                	srli	a5,a5,0xc
    80000eb8:	577d                	li	a4,-1
    80000eba:	177e                	slli	a4,a4,0x3f
    80000ebc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000ebe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000ec2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ec6:	6422                	ld	s0,8(sp)
    80000ec8:	0141                	addi	sp,sp,16
    80000eca:	8082                	ret

0000000080000ecc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ecc:	7139                	addi	sp,sp,-64
    80000ece:	fc06                	sd	ra,56(sp)
    80000ed0:	f822                	sd	s0,48(sp)
    80000ed2:	f426                	sd	s1,40(sp)
    80000ed4:	f04a                	sd	s2,32(sp)
    80000ed6:	ec4e                	sd	s3,24(sp)
    80000ed8:	e852                	sd	s4,16(sp)
    80000eda:	e456                	sd	s5,8(sp)
    80000edc:	e05a                	sd	s6,0(sp)
    80000ede:	0080                	addi	s0,sp,64
    80000ee0:	84aa                	mv	s1,a0
    80000ee2:	89ae                	mv	s3,a1
    80000ee4:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000ee6:	57fd                	li	a5,-1
    80000ee8:	83e9                	srli	a5,a5,0x1a
    80000eea:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000eec:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000eee:	02b7fc63          	bgeu	a5,a1,80000f26 <walk+0x5a>
    panic("walk");
    80000ef2:	00006517          	auipc	a0,0x6
    80000ef6:	1be50513          	addi	a0,a0,446 # 800070b0 <etext+0xb0>
    80000efa:	8f7ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000efe:	060a8263          	beqz	s5,80000f62 <walk+0x96>
    80000f02:	bc9ff0ef          	jal	80000aca <kalloc>
    80000f06:	84aa                	mv	s1,a0
    80000f08:	c139                	beqz	a0,80000f4e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f0a:	6605                	lui	a2,0x1
    80000f0c:	4581                	li	a1,0
    80000f0e:	d47ff0ef          	jal	80000c54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f12:	00c4d793          	srli	a5,s1,0xc
    80000f16:	07aa                	slli	a5,a5,0xa
    80000f18:	0017e793          	ori	a5,a5,1
    80000f1c:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f20:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdddf7>
    80000f22:	036a0063          	beq	s4,s6,80000f42 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f26:	0149d933          	srl	s2,s3,s4
    80000f2a:	1ff97913          	andi	s2,s2,511
    80000f2e:	090e                	slli	s2,s2,0x3
    80000f30:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f32:	00093483          	ld	s1,0(s2)
    80000f36:	0014f793          	andi	a5,s1,1
    80000f3a:	d3f1                	beqz	a5,80000efe <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f3c:	80a9                	srli	s1,s1,0xa
    80000f3e:	04b2                	slli	s1,s1,0xc
    80000f40:	b7c5                	j	80000f20 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f42:	00c9d513          	srli	a0,s3,0xc
    80000f46:	1ff57513          	andi	a0,a0,511
    80000f4a:	050e                	slli	a0,a0,0x3
    80000f4c:	9526                	add	a0,a0,s1
}
    80000f4e:	70e2                	ld	ra,56(sp)
    80000f50:	7442                	ld	s0,48(sp)
    80000f52:	74a2                	ld	s1,40(sp)
    80000f54:	7902                	ld	s2,32(sp)
    80000f56:	69e2                	ld	s3,24(sp)
    80000f58:	6a42                	ld	s4,16(sp)
    80000f5a:	6aa2                	ld	s5,8(sp)
    80000f5c:	6b02                	ld	s6,0(sp)
    80000f5e:	6121                	addi	sp,sp,64
    80000f60:	8082                	ret
        return 0;
    80000f62:	4501                	li	a0,0
    80000f64:	b7ed                	j	80000f4e <walk+0x82>

0000000080000f66 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000f66:	57fd                	li	a5,-1
    80000f68:	83e9                	srli	a5,a5,0x1a
    80000f6a:	00b7f463          	bgeu	a5,a1,80000f72 <walkaddr+0xc>
    return 0;
    80000f6e:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f70:	8082                	ret
{
    80000f72:	1141                	addi	sp,sp,-16
    80000f74:	e406                	sd	ra,8(sp)
    80000f76:	e022                	sd	s0,0(sp)
    80000f78:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f7a:	4601                	li	a2,0
    80000f7c:	f51ff0ef          	jal	80000ecc <walk>
  if (pte == 0)
    80000f80:	c105                	beqz	a0,80000fa0 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000f82:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000f84:	0117f693          	andi	a3,a5,17
    80000f88:	4745                	li	a4,17
    return 0;
    80000f8a:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000f8c:	00e68663          	beq	a3,a4,80000f98 <walkaddr+0x32>
}
    80000f90:	60a2                	ld	ra,8(sp)
    80000f92:	6402                	ld	s0,0(sp)
    80000f94:	0141                	addi	sp,sp,16
    80000f96:	8082                	ret
  pa = PTE2PA(*pte);
    80000f98:	83a9                	srli	a5,a5,0xa
    80000f9a:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000f9e:	bfcd                	j	80000f90 <walkaddr+0x2a>
    return 0;
    80000fa0:	4501                	li	a0,0
    80000fa2:	b7fd                	j	80000f90 <walkaddr+0x2a>

0000000080000fa4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fa4:	715d                	addi	sp,sp,-80
    80000fa6:	e486                	sd	ra,72(sp)
    80000fa8:	e0a2                	sd	s0,64(sp)
    80000faa:	fc26                	sd	s1,56(sp)
    80000fac:	f84a                	sd	s2,48(sp)
    80000fae:	f44e                	sd	s3,40(sp)
    80000fb0:	f052                	sd	s4,32(sp)
    80000fb2:	ec56                	sd	s5,24(sp)
    80000fb4:	e85a                	sd	s6,16(sp)
    80000fb6:	e45e                	sd	s7,8(sp)
    80000fb8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000fba:	03459793          	slli	a5,a1,0x34
    80000fbe:	e7a9                	bnez	a5,80001008 <mappages+0x64>
    80000fc0:	8aaa                	mv	s5,a0
    80000fc2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80000fc4:	03461793          	slli	a5,a2,0x34
    80000fc8:	e7b1                	bnez	a5,80001014 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000fca:	ca39                	beqz	a2,80001020 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000fcc:	77fd                	lui	a5,0xfffff
    80000fce:	963e                	add	a2,a2,a5
    80000fd0:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fd4:	892e                	mv	s2,a1
    80000fd6:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000fda:	6b85                	lui	s7,0x1
    80000fdc:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80000fe0:	4605                	li	a2,1
    80000fe2:	85ca                	mv	a1,s2
    80000fe4:	8556                	mv	a0,s5
    80000fe6:	ee7ff0ef          	jal	80000ecc <walk>
    80000fea:	c539                	beqz	a0,80001038 <mappages+0x94>
    if (*pte & PTE_V)
    80000fec:	611c                	ld	a5,0(a0)
    80000fee:	8b85                	andi	a5,a5,1
    80000ff0:	ef95                	bnez	a5,8000102c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000ff2:	80b1                	srli	s1,s1,0xc
    80000ff4:	04aa                	slli	s1,s1,0xa
    80000ff6:	0164e4b3          	or	s1,s1,s6
    80000ffa:	0014e493          	ori	s1,s1,1
    80000ffe:	e104                	sd	s1,0(a0)
    if (a == last)
    80001000:	05390863          	beq	s2,s3,80001050 <mappages+0xac>
    a += PGSIZE;
    80001004:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001006:	bfd9                	j	80000fdc <mappages+0x38>
    panic("mappages: va not aligned");
    80001008:	00006517          	auipc	a0,0x6
    8000100c:	0b050513          	addi	a0,a0,176 # 800070b8 <etext+0xb8>
    80001010:	fe0ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    80001014:	00006517          	auipc	a0,0x6
    80001018:	0c450513          	addi	a0,a0,196 # 800070d8 <etext+0xd8>
    8000101c:	fd4ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    80001020:	00006517          	auipc	a0,0x6
    80001024:	0d850513          	addi	a0,a0,216 # 800070f8 <etext+0xf8>
    80001028:	fc8ff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    8000102c:	00006517          	auipc	a0,0x6
    80001030:	0dc50513          	addi	a0,a0,220 # 80007108 <etext+0x108>
    80001034:	fbcff0ef          	jal	800007f0 <panic>
      return -1;
    80001038:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000103a:	60a6                	ld	ra,72(sp)
    8000103c:	6406                	ld	s0,64(sp)
    8000103e:	74e2                	ld	s1,56(sp)
    80001040:	7942                	ld	s2,48(sp)
    80001042:	79a2                	ld	s3,40(sp)
    80001044:	7a02                	ld	s4,32(sp)
    80001046:	6ae2                	ld	s5,24(sp)
    80001048:	6b42                	ld	s6,16(sp)
    8000104a:	6ba2                	ld	s7,8(sp)
    8000104c:	6161                	addi	sp,sp,80
    8000104e:	8082                	ret
  return 0;
    80001050:	4501                	li	a0,0
    80001052:	b7e5                	j	8000103a <mappages+0x96>

0000000080001054 <kvmmap>:
{
    80001054:	1141                	addi	sp,sp,-16
    80001056:	e406                	sd	ra,8(sp)
    80001058:	e022                	sd	s0,0(sp)
    8000105a:	0800                	addi	s0,sp,16
    8000105c:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000105e:	86b2                	mv	a3,a2
    80001060:	863e                	mv	a2,a5
    80001062:	f43ff0ef          	jal	80000fa4 <mappages>
    80001066:	e509                	bnez	a0,80001070 <kvmmap+0x1c>
}
    80001068:	60a2                	ld	ra,8(sp)
    8000106a:	6402                	ld	s0,0(sp)
    8000106c:	0141                	addi	sp,sp,16
    8000106e:	8082                	ret
    panic("kvmmap");
    80001070:	00006517          	auipc	a0,0x6
    80001074:	0a850513          	addi	a0,a0,168 # 80007118 <etext+0x118>
    80001078:	f78ff0ef          	jal	800007f0 <panic>

000000008000107c <kvmmake>:
{
    8000107c:	1101                	addi	sp,sp,-32
    8000107e:	ec06                	sd	ra,24(sp)
    80001080:	e822                	sd	s0,16(sp)
    80001082:	e426                	sd	s1,8(sp)
    80001084:	e04a                	sd	s2,0(sp)
    80001086:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001088:	a43ff0ef          	jal	80000aca <kalloc>
    8000108c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000108e:	6605                	lui	a2,0x1
    80001090:	4581                	li	a1,0
    80001092:	bc3ff0ef          	jal	80000c54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001096:	4719                	li	a4,6
    80001098:	6685                	lui	a3,0x1
    8000109a:	10000637          	lui	a2,0x10000
    8000109e:	100005b7          	lui	a1,0x10000
    800010a2:	8526                	mv	a0,s1
    800010a4:	fb1ff0ef          	jal	80001054 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010a8:	4719                	li	a4,6
    800010aa:	6685                	lui	a3,0x1
    800010ac:	10001637          	lui	a2,0x10001
    800010b0:	100015b7          	lui	a1,0x10001
    800010b4:	8526                	mv	a0,s1
    800010b6:	f9fff0ef          	jal	80001054 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010ba:	4719                	li	a4,6
    800010bc:	040006b7          	lui	a3,0x4000
    800010c0:	0c000637          	lui	a2,0xc000
    800010c4:	0c0005b7          	lui	a1,0xc000
    800010c8:	8526                	mv	a0,s1
    800010ca:	f8bff0ef          	jal	80001054 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800010ce:	00006917          	auipc	s2,0x6
    800010d2:	f3290913          	addi	s2,s2,-206 # 80007000 <etext>
    800010d6:	4729                	li	a4,10
    800010d8:	80006697          	auipc	a3,0x80006
    800010dc:	f2868693          	addi	a3,a3,-216 # 7000 <_entry-0x7fff9000>
    800010e0:	4605                	li	a2,1
    800010e2:	067e                	slli	a2,a2,0x1f
    800010e4:	85b2                	mv	a1,a2
    800010e6:	8526                	mv	a0,s1
    800010e8:	f6dff0ef          	jal	80001054 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800010ec:	46c5                	li	a3,17
    800010ee:	06ee                	slli	a3,a3,0x1b
    800010f0:	4719                	li	a4,6
    800010f2:	412686b3          	sub	a3,a3,s2
    800010f6:	864a                	mv	a2,s2
    800010f8:	85ca                	mv	a1,s2
    800010fa:	8526                	mv	a0,s1
    800010fc:	f59ff0ef          	jal	80001054 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001100:	4729                	li	a4,10
    80001102:	6685                	lui	a3,0x1
    80001104:	00005617          	auipc	a2,0x5
    80001108:	efc60613          	addi	a2,a2,-260 # 80006000 <_trampoline>
    8000110c:	040005b7          	lui	a1,0x4000
    80001110:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001112:	05b2                	slli	a1,a1,0xc
    80001114:	8526                	mv	a0,s1
    80001116:	f3fff0ef          	jal	80001054 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000111a:	8526                	mv	a0,s1
    8000111c:	60e000ef          	jal	8000172a <proc_mapstacks>
}
    80001120:	8526                	mv	a0,s1
    80001122:	60e2                	ld	ra,24(sp)
    80001124:	6442                	ld	s0,16(sp)
    80001126:	64a2                	ld	s1,8(sp)
    80001128:	6902                	ld	s2,0(sp)
    8000112a:	6105                	addi	sp,sp,32
    8000112c:	8082                	ret

000000008000112e <kvminit>:
{
    8000112e:	1141                	addi	sp,sp,-16
    80001130:	e406                	sd	ra,8(sp)
    80001132:	e022                	sd	s0,0(sp)
    80001134:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001136:	f47ff0ef          	jal	8000107c <kvmmake>
    8000113a:	00006797          	auipc	a5,0x6
    8000113e:	78a7b323          	sd	a0,1926(a5) # 800078c0 <kernel_pagetable>
}
    80001142:	60a2                	ld	ra,8(sp)
    80001144:	6402                	ld	s0,0(sp)
    80001146:	0141                	addi	sp,sp,16
    80001148:	8082                	ret

000000008000114a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000114a:	1101                	addi	sp,sp,-32
    8000114c:	ec06                	sd	ra,24(sp)
    8000114e:	e822                	sd	s0,16(sp)
    80001150:	e426                	sd	s1,8(sp)
    80001152:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001154:	977ff0ef          	jal	80000aca <kalloc>
    80001158:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000115a:	c509                	beqz	a0,80001164 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000115c:	6605                	lui	a2,0x1
    8000115e:	4581                	li	a1,0
    80001160:	af5ff0ef          	jal	80000c54 <memset>
  return pagetable;
}
    80001164:	8526                	mv	a0,s1
    80001166:	60e2                	ld	ra,24(sp)
    80001168:	6442                	ld	s0,16(sp)
    8000116a:	64a2                	ld	s1,8(sp)
    8000116c:	6105                	addi	sp,sp,32
    8000116e:	8082                	ret

0000000080001170 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001170:	7139                	addi	sp,sp,-64
    80001172:	fc06                	sd	ra,56(sp)
    80001174:	f822                	sd	s0,48(sp)
    80001176:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001178:	03459793          	slli	a5,a1,0x34
    8000117c:	e38d                	bnez	a5,8000119e <uvmunmap+0x2e>
    8000117e:	f04a                	sd	s2,32(sp)
    80001180:	ec4e                	sd	s3,24(sp)
    80001182:	e852                	sd	s4,16(sp)
    80001184:	e456                	sd	s5,8(sp)
    80001186:	e05a                	sd	s6,0(sp)
    80001188:	8a2a                	mv	s4,a0
    8000118a:	892e                	mv	s2,a1
    8000118c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000118e:	0632                	slli	a2,a2,0xc
    80001190:	00b609b3          	add	s3,a2,a1
    80001194:	6b05                	lui	s6,0x1
    80001196:	0535f963          	bgeu	a1,s3,800011e8 <uvmunmap+0x78>
    8000119a:	f426                	sd	s1,40(sp)
    8000119c:	a015                	j	800011c0 <uvmunmap+0x50>
    8000119e:	f426                	sd	s1,40(sp)
    800011a0:	f04a                	sd	s2,32(sp)
    800011a2:	ec4e                	sd	s3,24(sp)
    800011a4:	e852                	sd	s4,16(sp)
    800011a6:	e456                	sd	s5,8(sp)
    800011a8:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011aa:	00006517          	auipc	a0,0x6
    800011ae:	f7650513          	addi	a0,a0,-138 # 80007120 <etext+0x120>
    800011b2:	e3eff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011b6:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011ba:	995a                	add	s2,s2,s6
    800011bc:	03397563          	bgeu	s2,s3,800011e6 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011c0:	4601                	li	a2,0
    800011c2:	85ca                	mv	a1,s2
    800011c4:	8552                	mv	a0,s4
    800011c6:	d07ff0ef          	jal	80000ecc <walk>
    800011ca:	84aa                	mv	s1,a0
    800011cc:	d57d                	beqz	a0,800011ba <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800011ce:	611c                	ld	a5,0(a0)
    800011d0:	0017f713          	andi	a4,a5,1
    800011d4:	d37d                	beqz	a4,800011ba <uvmunmap+0x4a>
    if (do_free) {
    800011d6:	fe0a80e3          	beqz	s5,800011b6 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800011da:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800011dc:	00c79513          	slli	a0,a5,0xc
    800011e0:	809ff0ef          	jal	800009e8 <kfree>
    800011e4:	bfc9                	j	800011b6 <uvmunmap+0x46>
    800011e6:	74a2                	ld	s1,40(sp)
    800011e8:	7902                	ld	s2,32(sp)
    800011ea:	69e2                	ld	s3,24(sp)
    800011ec:	6a42                	ld	s4,16(sp)
    800011ee:	6aa2                	ld	s5,8(sp)
    800011f0:	6b02                	ld	s6,0(sp)
  }
}
    800011f2:	70e2                	ld	ra,56(sp)
    800011f4:	7442                	ld	s0,48(sp)
    800011f6:	6121                	addi	sp,sp,64
    800011f8:	8082                	ret

00000000800011fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001204:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001206:	00b67d63          	bgeu	a2,a1,80001220 <uvmdealloc+0x26>
    8000120a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000120c:	6785                	lui	a5,0x1
    8000120e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001210:	00f60733          	add	a4,a2,a5
    80001214:	76fd                	lui	a3,0xfffff
    80001216:	8f75                	and	a4,a4,a3
    80001218:	97ae                	add	a5,a5,a1
    8000121a:	8ff5                	and	a5,a5,a3
    8000121c:	00f76863          	bltu	a4,a5,8000122c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001220:	8526                	mv	a0,s1
    80001222:	60e2                	ld	ra,24(sp)
    80001224:	6442                	ld	s0,16(sp)
    80001226:	64a2                	ld	s1,8(sp)
    80001228:	6105                	addi	sp,sp,32
    8000122a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000122c:	8f99                	sub	a5,a5,a4
    8000122e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001230:	4685                	li	a3,1
    80001232:	0007861b          	sext.w	a2,a5
    80001236:	85ba                	mv	a1,a4
    80001238:	f39ff0ef          	jal	80001170 <uvmunmap>
    8000123c:	b7d5                	j	80001220 <uvmdealloc+0x26>

000000008000123e <uvmalloc>:
  if (newsz < oldsz)
    8000123e:	08b66f63          	bltu	a2,a1,800012dc <uvmalloc+0x9e>
{
    80001242:	7139                	addi	sp,sp,-64
    80001244:	fc06                	sd	ra,56(sp)
    80001246:	f822                	sd	s0,48(sp)
    80001248:	ec4e                	sd	s3,24(sp)
    8000124a:	e852                	sd	s4,16(sp)
    8000124c:	e456                	sd	s5,8(sp)
    8000124e:	0080                	addi	s0,sp,64
    80001250:	8aaa                	mv	s5,a0
    80001252:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001254:	6785                	lui	a5,0x1
    80001256:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001258:	95be                	add	a1,a1,a5
    8000125a:	77fd                	lui	a5,0xfffff
    8000125c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001260:	08c9f063          	bgeu	s3,a2,800012e0 <uvmalloc+0xa2>
    80001264:	f426                	sd	s1,40(sp)
    80001266:	f04a                	sd	s2,32(sp)
    80001268:	e05a                	sd	s6,0(sp)
    8000126a:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000126c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001270:	85bff0ef          	jal	80000aca <kalloc>
    80001274:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001276:	c515                	beqz	a0,800012a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001278:	6605                	lui	a2,0x1
    8000127a:	4581                	li	a1,0
    8000127c:	9d9ff0ef          	jal	80000c54 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001280:	875a                	mv	a4,s6
    80001282:	86a6                	mv	a3,s1
    80001284:	6605                	lui	a2,0x1
    80001286:	85ca                	mv	a1,s2
    80001288:	8556                	mv	a0,s5
    8000128a:	d1bff0ef          	jal	80000fa4 <mappages>
    8000128e:	e915                	bnez	a0,800012c2 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001290:	6785                	lui	a5,0x1
    80001292:	993e                	add	s2,s2,a5
    80001294:	fd496ee3          	bltu	s2,s4,80001270 <uvmalloc+0x32>
  return newsz;
    80001298:	8552                	mv	a0,s4
    8000129a:	74a2                	ld	s1,40(sp)
    8000129c:	7902                	ld	s2,32(sp)
    8000129e:	6b02                	ld	s6,0(sp)
    800012a0:	a811                	j	800012b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012a2:	864e                	mv	a2,s3
    800012a4:	85ca                	mv	a1,s2
    800012a6:	8556                	mv	a0,s5
    800012a8:	f53ff0ef          	jal	800011fa <uvmdealloc>
      return 0;
    800012ac:	4501                	li	a0,0
    800012ae:	74a2                	ld	s1,40(sp)
    800012b0:	7902                	ld	s2,32(sp)
    800012b2:	6b02                	ld	s6,0(sp)
}
    800012b4:	70e2                	ld	ra,56(sp)
    800012b6:	7442                	ld	s0,48(sp)
    800012b8:	69e2                	ld	s3,24(sp)
    800012ba:	6a42                	ld	s4,16(sp)
    800012bc:	6aa2                	ld	s5,8(sp)
    800012be:	6121                	addi	sp,sp,64
    800012c0:	8082                	ret
      kfree(mem);
    800012c2:	8526                	mv	a0,s1
    800012c4:	f24ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012c8:	864e                	mv	a2,s3
    800012ca:	85ca                	mv	a1,s2
    800012cc:	8556                	mv	a0,s5
    800012ce:	f2dff0ef          	jal	800011fa <uvmdealloc>
      return 0;
    800012d2:	4501                	li	a0,0
    800012d4:	74a2                	ld	s1,40(sp)
    800012d6:	7902                	ld	s2,32(sp)
    800012d8:	6b02                	ld	s6,0(sp)
    800012da:	bfe9                	j	800012b4 <uvmalloc+0x76>
    return oldsz;
    800012dc:	852e                	mv	a0,a1
}
    800012de:	8082                	ret
  return newsz;
    800012e0:	8532                	mv	a0,a2
    800012e2:	bfc9                	j	800012b4 <uvmalloc+0x76>

00000000800012e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012e4:	7179                	addi	sp,sp,-48
    800012e6:	f406                	sd	ra,40(sp)
    800012e8:	f022                	sd	s0,32(sp)
    800012ea:	ec26                	sd	s1,24(sp)
    800012ec:	e84a                	sd	s2,16(sp)
    800012ee:	e44e                	sd	s3,8(sp)
    800012f0:	e052                	sd	s4,0(sp)
    800012f2:	1800                	addi	s0,sp,48
    800012f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800012f6:	84aa                	mv	s1,a0
    800012f8:	6905                	lui	s2,0x1
    800012fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800012fc:	4985                	li	s3,1
    800012fe:	a819                	j	80001314 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001300:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001302:	00c79513          	slli	a0,a5,0xc
    80001306:	fdfff0ef          	jal	800012e4 <freewalk>
      pagetable[i] = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000130e:	04a1                	addi	s1,s1,8
    80001310:	01248f63          	beq	s1,s2,8000132e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001314:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001316:	00f7f713          	andi	a4,a5,15
    8000131a:	ff3703e3          	beq	a4,s3,80001300 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000131e:	8b85                	andi	a5,a5,1
    80001320:	d7fd                	beqz	a5,8000130e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001322:	00006517          	auipc	a0,0x6
    80001326:	e1650513          	addi	a0,a0,-490 # 80007138 <etext+0x138>
    8000132a:	cc6ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    8000132e:	8552                	mv	a0,s4
    80001330:	eb8ff0ef          	jal	800009e8 <kfree>
}
    80001334:	70a2                	ld	ra,40(sp)
    80001336:	7402                	ld	s0,32(sp)
    80001338:	64e2                	ld	s1,24(sp)
    8000133a:	6942                	ld	s2,16(sp)
    8000133c:	69a2                	ld	s3,8(sp)
    8000133e:	6a02                	ld	s4,0(sp)
    80001340:	6145                	addi	sp,sp,48
    80001342:	8082                	ret

0000000080001344 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
    8000134e:	84aa                	mv	s1,a0
  if (sz > 0)
    80001350:	e989                	bnez	a1,80001362 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001352:	8526                	mv	a0,s1
    80001354:	f91ff0ef          	jal	800012e4 <freewalk>
}
    80001358:	60e2                	ld	ra,24(sp)
    8000135a:	6442                	ld	s0,16(sp)
    8000135c:	64a2                	ld	s1,8(sp)
    8000135e:	6105                	addi	sp,sp,32
    80001360:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001362:	6785                	lui	a5,0x1
    80001364:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001366:	95be                	add	a1,a1,a5
    80001368:	4685                	li	a3,1
    8000136a:	00c5d613          	srli	a2,a1,0xc
    8000136e:	4581                	li	a1,0
    80001370:	e01ff0ef          	jal	80001170 <uvmunmap>
    80001374:	bff9                	j	80001352 <uvmfree+0xe>

0000000080001376 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001376:	ce49                	beqz	a2,80001410 <uvmcopy+0x9a>
{
    80001378:	715d                	addi	sp,sp,-80
    8000137a:	e486                	sd	ra,72(sp)
    8000137c:	e0a2                	sd	s0,64(sp)
    8000137e:	fc26                	sd	s1,56(sp)
    80001380:	f84a                	sd	s2,48(sp)
    80001382:	f44e                	sd	s3,40(sp)
    80001384:	f052                	sd	s4,32(sp)
    80001386:	ec56                	sd	s5,24(sp)
    80001388:	e85a                	sd	s6,16(sp)
    8000138a:	e45e                	sd	s7,8(sp)
    8000138c:	0880                	addi	s0,sp,80
    8000138e:	8aaa                	mv	s5,a0
    80001390:	8b2e                	mv	s6,a1
    80001392:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001394:	4481                	li	s1,0
    80001396:	a029                	j	800013a0 <uvmcopy+0x2a>
    80001398:	6785                	lui	a5,0x1
    8000139a:	94be                	add	s1,s1,a5
    8000139c:	0544fe63          	bgeu	s1,s4,800013f8 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    800013a0:	4601                	li	a2,0
    800013a2:	85a6                	mv	a1,s1
    800013a4:	8556                	mv	a0,s5
    800013a6:	b27ff0ef          	jal	80000ecc <walk>
    800013aa:	d57d                	beqz	a0,80001398 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013ac:	6118                	ld	a4,0(a0)
    800013ae:	00177793          	andi	a5,a4,1
    800013b2:	d3fd                	beqz	a5,80001398 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013b4:	00a75593          	srli	a1,a4,0xa
    800013b8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013bc:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    800013c0:	f0aff0ef          	jal	80000aca <kalloc>
    800013c4:	89aa                	mv	s3,a0
    800013c6:	c105                	beqz	a0,800013e6 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800013c8:	6605                	lui	a2,0x1
    800013ca:	85de                	mv	a1,s7
    800013cc:	8e5ff0ef          	jal	80000cb0 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800013d0:	874a                	mv	a4,s2
    800013d2:	86ce                	mv	a3,s3
    800013d4:	6605                	lui	a2,0x1
    800013d6:	85a6                	mv	a1,s1
    800013d8:	855a                	mv	a0,s6
    800013da:	bcbff0ef          	jal	80000fa4 <mappages>
    800013de:	dd4d                	beqz	a0,80001398 <uvmcopy+0x22>
      kfree(mem);
    800013e0:	854e                	mv	a0,s3
    800013e2:	e06ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013e6:	4685                	li	a3,1
    800013e8:	00c4d613          	srli	a2,s1,0xc
    800013ec:	4581                	li	a1,0
    800013ee:	855a                	mv	a0,s6
    800013f0:	d81ff0ef          	jal	80001170 <uvmunmap>
  return -1;
    800013f4:	557d                	li	a0,-1
    800013f6:	a011                	j	800013fa <uvmcopy+0x84>
  return 0;
    800013f8:	4501                	li	a0,0
}
    800013fa:	60a6                	ld	ra,72(sp)
    800013fc:	6406                	ld	s0,64(sp)
    800013fe:	74e2                	ld	s1,56(sp)
    80001400:	7942                	ld	s2,48(sp)
    80001402:	79a2                	ld	s3,40(sp)
    80001404:	7a02                	ld	s4,32(sp)
    80001406:	6ae2                	ld	s5,24(sp)
    80001408:	6b42                	ld	s6,16(sp)
    8000140a:	6ba2                	ld	s7,8(sp)
    8000140c:	6161                	addi	sp,sp,80
    8000140e:	8082                	ret
  return 0;
    80001410:	4501                	li	a0,0
}
    80001412:	8082                	ret

0000000080001414 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001414:	1141                	addi	sp,sp,-16
    80001416:	e406                	sd	ra,8(sp)
    80001418:	e022                	sd	s0,0(sp)
    8000141a:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000141c:	4601                	li	a2,0
    8000141e:	aafff0ef          	jal	80000ecc <walk>
  if (pte == 0)
    80001422:	c901                	beqz	a0,80001432 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001424:	611c                	ld	a5,0(a0)
    80001426:	9bbd                	andi	a5,a5,-17
    80001428:	e11c                	sd	a5,0(a0)
}
    8000142a:	60a2                	ld	ra,8(sp)
    8000142c:	6402                	ld	s0,0(sp)
    8000142e:	0141                	addi	sp,sp,16
    80001430:	8082                	ret
    panic("uvmclear");
    80001432:	00006517          	auipc	a0,0x6
    80001436:	d1650513          	addi	a0,a0,-746 # 80007148 <etext+0x148>
    8000143a:	bb6ff0ef          	jal	800007f0 <panic>

000000008000143e <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000143e:	1141                	addi	sp,sp,-16
    80001440:	e406                	sd	ra,8(sp)
    80001442:	e022                	sd	s0,0(sp)
    80001444:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001446:	4601                	li	a2,0
    80001448:	a85ff0ef          	jal	80000ecc <walk>
  if (pte == 0) {
    8000144c:	c519                	beqz	a0,8000145a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    8000144e:	6108                	ld	a0,0(a0)
    80001450:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001452:	60a2                	ld	ra,8(sp)
    80001454:	6402                	ld	s0,0(sp)
    80001456:	0141                	addi	sp,sp,16
    80001458:	8082                	ret
    return 0;
    8000145a:	4501                	li	a0,0
    8000145c:	bfdd                	j	80001452 <ismapped+0x14>

000000008000145e <vmfault>:
{
    8000145e:	7179                	addi	sp,sp,-48
    80001460:	f406                	sd	ra,40(sp)
    80001462:	f022                	sd	s0,32(sp)
    80001464:	e44e                	sd	s3,8(sp)
    80001466:	1800                	addi	s0,sp,48
    return 0;
    80001468:	4981                	li	s3,0
  if (va >= psz)
    8000146a:	00b66863          	bltu	a2,a1,8000147a <vmfault+0x1c>
}
    8000146e:	854e                	mv	a0,s3
    80001470:	70a2                	ld	ra,40(sp)
    80001472:	7402                	ld	s0,32(sp)
    80001474:	69a2                	ld	s3,8(sp)
    80001476:	6145                	addi	sp,sp,48
    80001478:	8082                	ret
    8000147a:	ec26                	sd	s1,24(sp)
    8000147c:	e84a                	sd	s2,16(sp)
    8000147e:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001480:	77fd                	lui	a5,0xfffff
    80001482:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    80001486:	85a6                	mv	a1,s1
    80001488:	fb7ff0ef          	jal	8000143e <ismapped>
    return 0;
    8000148c:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    8000148e:	c501                	beqz	a0,80001496 <vmfault+0x38>
    80001490:	64e2                	ld	s1,24(sp)
    80001492:	6942                	ld	s2,16(sp)
    80001494:	bfe9                	j	8000146e <vmfault+0x10>
    80001496:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    80001498:	e32ff0ef          	jal	80000aca <kalloc>
    8000149c:	8a2a                	mv	s4,a0
  if (mem == 0)
    8000149e:	c915                	beqz	a0,800014d2 <vmfault+0x74>
  mem = (uint64)kalloc();
    800014a0:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800014a2:	6605                	lui	a2,0x1
    800014a4:	4581                	li	a1,0
    800014a6:	faeff0ef          	jal	80000c54 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800014aa:	4759                	li	a4,22
    800014ac:	86d2                	mv	a3,s4
    800014ae:	6605                	lui	a2,0x1
    800014b0:	85a6                	mv	a1,s1
    800014b2:	854a                	mv	a0,s2
    800014b4:	af1ff0ef          	jal	80000fa4 <mappages>
    800014b8:	e509                	bnez	a0,800014c2 <vmfault+0x64>
    800014ba:	64e2                	ld	s1,24(sp)
    800014bc:	6942                	ld	s2,16(sp)
    800014be:	6a02                	ld	s4,0(sp)
    800014c0:	b77d                	j	8000146e <vmfault+0x10>
    kfree((void *)mem);
    800014c2:	8552                	mv	a0,s4
    800014c4:	d24ff0ef          	jal	800009e8 <kfree>
    return 0;
    800014c8:	4981                	li	s3,0
    800014ca:	64e2                	ld	s1,24(sp)
    800014cc:	6942                	ld	s2,16(sp)
    800014ce:	6a02                	ld	s4,0(sp)
    800014d0:	bf79                	j	8000146e <vmfault+0x10>
    800014d2:	64e2                	ld	s1,24(sp)
    800014d4:	6942                	ld	s2,16(sp)
    800014d6:	6a02                	ld	s4,0(sp)
    800014d8:	bf59                	j	8000146e <vmfault+0x10>

00000000800014da <copyout>:
  while (len > 0) {
    800014da:	c745                	beqz	a4,80001582 <copyout+0xa8>
{
    800014dc:	7159                	addi	sp,sp,-112
    800014de:	f486                	sd	ra,104(sp)
    800014e0:	f0a2                	sd	s0,96(sp)
    800014e2:	eca6                	sd	s1,88(sp)
    800014e4:	e0d2                	sd	s4,64(sp)
    800014e6:	f85a                	sd	s6,48(sp)
    800014e8:	f45e                	sd	s7,40(sp)
    800014ea:	f062                	sd	s8,32(sp)
    800014ec:	e46e                	sd	s11,8(sp)
    800014ee:	1880                	addi	s0,sp,112
    800014f0:	8c2a                	mv	s8,a0
    800014f2:	8dae                	mv	s11,a1
    800014f4:	8b32                	mv	s6,a2
    800014f6:	8bb6                	mv	s7,a3
    800014f8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    800014fa:	74fd                	lui	s1,0xfffff
    800014fc:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    800014fe:	57fd                	li	a5,-1
    80001500:	83e9                	srli	a5,a5,0x1a
    80001502:	0897e263          	bltu	a5,s1,80001586 <copyout+0xac>
    80001506:	e8ca                	sd	s2,80(sp)
    80001508:	e4ce                	sd	s3,72(sp)
    8000150a:	fc56                	sd	s5,56(sp)
    8000150c:	ec66                	sd	s9,24(sp)
    8000150e:	e86a                	sd	s10,16(sp)
    80001510:	6d05                	lui	s10,0x1
    80001512:	8cbe                	mv	s9,a5
    80001514:	a015                	j	80001538 <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001516:	409b0533          	sub	a0,s6,s1
    8000151a:	0009861b          	sext.w	a2,s3
    8000151e:	85de                	mv	a1,s7
    80001520:	954a                	add	a0,a0,s2
    80001522:	f8eff0ef          	jal	80000cb0 <memmove>
    len -= n;
    80001526:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000152a:	9bce                	add	s7,s7,s3
  while (len > 0) {
    8000152c:	040a0463          	beqz	s4,80001574 <copyout+0x9a>
    if (va0 >= MAXVA)
    80001530:	055ced63          	bltu	s9,s5,8000158a <copyout+0xb0>
    80001534:	84d6                	mv	s1,s5
    80001536:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001538:	85a6                	mv	a1,s1
    8000153a:	8562                	mv	a0,s8
    8000153c:	a2bff0ef          	jal	80000f66 <walkaddr>
    80001540:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001542:	e909                	bnez	a0,80001554 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001544:	4681                	li	a3,0
    80001546:	8626                	mv	a2,s1
    80001548:	85ee                	mv	a1,s11
    8000154a:	8562                	mv	a0,s8
    8000154c:	f13ff0ef          	jal	8000145e <vmfault>
    80001550:	892a                	mv	s2,a0
    80001552:	c139                	beqz	a0,80001598 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001554:	4601                	li	a2,0
    80001556:	85a6                	mv	a1,s1
    80001558:	8562                	mv	a0,s8
    8000155a:	973ff0ef          	jal	80000ecc <walk>
    if ((*pte & PTE_W) == 0)
    8000155e:	611c                	ld	a5,0(a0)
    80001560:	8b91                	andi	a5,a5,4
    80001562:	c3b1                	beqz	a5,800015a6 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    80001564:	01a48ab3          	add	s5,s1,s10
    80001568:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    8000156c:	fb3a75e3          	bgeu	s4,s3,80001516 <copyout+0x3c>
    80001570:	89d2                	mv	s3,s4
    80001572:	b755                	j	80001516 <copyout+0x3c>
  return 0;
    80001574:	4501                	li	a0,0
    80001576:	6946                	ld	s2,80(sp)
    80001578:	69a6                	ld	s3,72(sp)
    8000157a:	7ae2                	ld	s5,56(sp)
    8000157c:	6ce2                	ld	s9,24(sp)
    8000157e:	6d42                	ld	s10,16(sp)
    80001580:	a80d                	j	800015b2 <copyout+0xd8>
    80001582:	4501                	li	a0,0
}
    80001584:	8082                	ret
      return -1;
    80001586:	557d                	li	a0,-1
    80001588:	a02d                	j	800015b2 <copyout+0xd8>
    8000158a:	557d                	li	a0,-1
    8000158c:	6946                	ld	s2,80(sp)
    8000158e:	69a6                	ld	s3,72(sp)
    80001590:	7ae2                	ld	s5,56(sp)
    80001592:	6ce2                	ld	s9,24(sp)
    80001594:	6d42                	ld	s10,16(sp)
    80001596:	a831                	j	800015b2 <copyout+0xd8>
        return -1;
    80001598:	557d                	li	a0,-1
    8000159a:	6946                	ld	s2,80(sp)
    8000159c:	69a6                	ld	s3,72(sp)
    8000159e:	7ae2                	ld	s5,56(sp)
    800015a0:	6ce2                	ld	s9,24(sp)
    800015a2:	6d42                	ld	s10,16(sp)
    800015a4:	a039                	j	800015b2 <copyout+0xd8>
      return -1;
    800015a6:	557d                	li	a0,-1
    800015a8:	6946                	ld	s2,80(sp)
    800015aa:	69a6                	ld	s3,72(sp)
    800015ac:	7ae2                	ld	s5,56(sp)
    800015ae:	6ce2                	ld	s9,24(sp)
    800015b0:	6d42                	ld	s10,16(sp)
}
    800015b2:	70a6                	ld	ra,104(sp)
    800015b4:	7406                	ld	s0,96(sp)
    800015b6:	64e6                	ld	s1,88(sp)
    800015b8:	6a06                	ld	s4,64(sp)
    800015ba:	7b42                	ld	s6,48(sp)
    800015bc:	7ba2                	ld	s7,40(sp)
    800015be:	7c02                	ld	s8,32(sp)
    800015c0:	6da2                	ld	s11,8(sp)
    800015c2:	6165                	addi	sp,sp,112
    800015c4:	8082                	ret

00000000800015c6 <copyin>:
  while (len > 0) {
    800015c6:	cb49                	beqz	a4,80001658 <copyin+0x92>
{
    800015c8:	711d                	addi	sp,sp,-96
    800015ca:	ec86                	sd	ra,88(sp)
    800015cc:	e8a2                	sd	s0,80(sp)
    800015ce:	e4a6                	sd	s1,72(sp)
    800015d0:	e0ca                	sd	s2,64(sp)
    800015d2:	fc4e                	sd	s3,56(sp)
    800015d4:	f852                	sd	s4,48(sp)
    800015d6:	f456                	sd	s5,40(sp)
    800015d8:	f05a                	sd	s6,32(sp)
    800015da:	ec5e                	sd	s7,24(sp)
    800015dc:	e862                	sd	s8,16(sp)
    800015de:	e466                	sd	s9,8(sp)
    800015e0:	1080                	addi	s0,sp,96
    800015e2:	8baa                	mv	s7,a0
    800015e4:	8cae                	mv	s9,a1
    800015e6:	8ab2                	mv	s5,a2
    800015e8:	8936                	mv	s2,a3
    800015ea:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800015ec:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800015ee:	6b05                	lui	s6,0x1
    800015f0:	a035                	j	8000161c <copyin+0x56>
    800015f2:	412984b3          	sub	s1,s3,s2
    800015f6:	94da                	add	s1,s1,s6
    if (n > len)
    800015f8:	009a7363          	bgeu	s4,s1,800015fe <copyin+0x38>
    800015fc:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015fe:	413905b3          	sub	a1,s2,s3
    80001602:	0004861b          	sext.w	a2,s1
    80001606:	95aa                	add	a1,a1,a0
    80001608:	8556                	mv	a0,s5
    8000160a:	ea6ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    8000160e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001612:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001614:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001618:	020a0263          	beqz	s4,8000163c <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    8000161c:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001620:	85ce                	mv	a1,s3
    80001622:	855e                	mv	a0,s7
    80001624:	943ff0ef          	jal	80000f66 <walkaddr>
    if (pa0 == 0) {
    80001628:	f569                	bnez	a0,800015f2 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000162a:	4685                	li	a3,1
    8000162c:	864e                	mv	a2,s3
    8000162e:	85e6                	mv	a1,s9
    80001630:	855e                	mv	a0,s7
    80001632:	e2dff0ef          	jal	8000145e <vmfault>
    80001636:	fd55                	bnez	a0,800015f2 <copyin+0x2c>
        return -1;
    80001638:	557d                	li	a0,-1
    8000163a:	a011                	j	8000163e <copyin+0x78>
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	60e6                	ld	ra,88(sp)
    80001640:	6446                	ld	s0,80(sp)
    80001642:	64a6                	ld	s1,72(sp)
    80001644:	6906                	ld	s2,64(sp)
    80001646:	79e2                	ld	s3,56(sp)
    80001648:	7a42                	ld	s4,48(sp)
    8000164a:	7aa2                	ld	s5,40(sp)
    8000164c:	7b02                	ld	s6,32(sp)
    8000164e:	6be2                	ld	s7,24(sp)
    80001650:	6c42                	ld	s8,16(sp)
    80001652:	6ca2                	ld	s9,8(sp)
    80001654:	6125                	addi	sp,sp,96
    80001656:	8082                	ret
  return 0;
    80001658:	4501                	li	a0,0
}
    8000165a:	8082                	ret

000000008000165c <copyinstr>:
  while (got_null == 0 && max > 0) {
    8000165c:	c371                	beqz	a4,80001720 <copyinstr+0xc4>
{
    8000165e:	715d                	addi	sp,sp,-80
    80001660:	e486                	sd	ra,72(sp)
    80001662:	e0a2                	sd	s0,64(sp)
    80001664:	fc26                	sd	s1,56(sp)
    80001666:	f84a                	sd	s2,48(sp)
    80001668:	f44e                	sd	s3,40(sp)
    8000166a:	f052                	sd	s4,32(sp)
    8000166c:	ec56                	sd	s5,24(sp)
    8000166e:	e85a                	sd	s6,16(sp)
    80001670:	e45e                	sd	s7,8(sp)
    80001672:	e062                	sd	s8,0(sp)
    80001674:	0880                	addi	s0,sp,80
    80001676:	8a2a                	mv	s4,a0
    80001678:	8b2e                	mv	s6,a1
    8000167a:	8bb2                	mv	s7,a2
    8000167c:	8c36                	mv	s8,a3
    8000167e:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    80001680:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80001682:	6985                	lui	s3,0x1
    80001684:	a0b1                	j	800016d0 <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001686:	4685                	li	a3,1
    80001688:	8626                	mv	a2,s1
    8000168a:	85da                	mv	a1,s6
    8000168c:	8552                	mv	a0,s4
    8000168e:	dd1ff0ef          	jal	8000145e <vmfault>
    80001692:	e531                	bnez	a0,800016de <copyinstr+0x82>
        return -1;
    80001694:	557d                	li	a0,-1
    80001696:	a039                	j	800016a4 <copyinstr+0x48>
        *dst = '\0';
    80001698:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdde00>
    8000169c:	4785                	li	a5,1
  if (got_null) {
    8000169e:	37fd                	addiw	a5,a5,-1
    800016a0:	0007851b          	sext.w	a0,a5
}
    800016a4:	60a6                	ld	ra,72(sp)
    800016a6:	6406                	ld	s0,64(sp)
    800016a8:	74e2                	ld	s1,56(sp)
    800016aa:	7942                	ld	s2,48(sp)
    800016ac:	79a2                	ld	s3,40(sp)
    800016ae:	7a02                	ld	s4,32(sp)
    800016b0:	6ae2                	ld	s5,24(sp)
    800016b2:	6b42                	ld	s6,16(sp)
    800016b4:	6ba2                	ld	s7,8(sp)
    800016b6:	6c02                	ld	s8,0(sp)
    800016b8:	6161                	addi	sp,sp,80
    800016ba:	8082                	ret
    800016bc:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016c0:	972a                	add	a4,a4,a0
      --max;
    800016c2:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800016c6:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    800016ca:	04e58563          	beq	a1,a4,80001714 <copyinstr+0xb8>
{
    800016ce:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    800016d0:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    800016d4:	85a6                	mv	a1,s1
    800016d6:	8552                	mv	a0,s4
    800016d8:	88fff0ef          	jal	80000f66 <walkaddr>
    if (pa0 == 0) {
    800016dc:	d54d                	beqz	a0,80001686 <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    800016de:	41848633          	sub	a2,s1,s8
    800016e2:	964e                	add	a2,a2,s3
    if (n > max)
    800016e4:	00c97363          	bgeu	s2,a2,800016ea <copyinstr+0x8e>
    800016e8:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    800016ea:	409c0c33          	sub	s8,s8,s1
    800016ee:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    800016f0:	c605                	beqz	a2,80001718 <copyinstr+0xbc>
    800016f2:	87de                	mv	a5,s7
    800016f4:	855e                	mv	a0,s7
      if (*p == '\0') {
    800016f6:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    800016fa:	965e                	add	a2,a2,s7
    800016fc:	85be                	mv	a1,a5
      if (*p == '\0') {
    800016fe:	00f706b3          	add	a3,a4,a5
    80001702:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffdde00>
    80001706:	dac9                	beqz	a3,80001698 <copyinstr+0x3c>
        *dst = *p;
    80001708:	00d78023          	sb	a3,0(a5)
      dst++;
    8000170c:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000170e:	fec797e3          	bne	a5,a2,800016fc <copyinstr+0xa0>
    80001712:	b76d                	j	800016bc <copyinstr+0x60>
    80001714:	4781                	li	a5,0
    80001716:	b761                	j	8000169e <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    80001718:	6c05                	lui	s8,0x1
    8000171a:	9c26                	add	s8,s8,s1
    8000171c:	87de                	mv	a5,s7
    8000171e:	bf45                	j	800016ce <copyinstr+0x72>
  int got_null = 0;
    80001720:	4781                	li	a5,0
  if (got_null) {
    80001722:	37fd                	addiw	a5,a5,-1
    80001724:	0007851b          	sext.w	a0,a5
}
    80001728:	8082                	ret

000000008000172a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000172a:	7139                	addi	sp,sp,-64
    8000172c:	fc06                	sd	ra,56(sp)
    8000172e:	f822                	sd	s0,48(sp)
    80001730:	f426                	sd	s1,40(sp)
    80001732:	f04a                	sd	s2,32(sp)
    80001734:	ec4e                	sd	s3,24(sp)
    80001736:	e852                	sd	s4,16(sp)
    80001738:	e456                	sd	s5,8(sp)
    8000173a:	e05a                	sd	s6,0(sp)
    8000173c:	0080                	addi	s0,sp,64
    8000173e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001740:	0000e497          	auipc	s1,0xe
    80001744:	6e048493          	addi	s1,s1,1760 # 8000fe20 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001748:	8b26                	mv	s6,s1
    8000174a:	faaab937          	lui	s2,0xfaaab
    8000174e:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa898ab>
    80001752:	0932                	slli	s2,s2,0xc
    80001754:	aab90913          	addi	s2,s2,-1365
    80001758:	0932                	slli	s2,s2,0xc
    8000175a:	aab90913          	addi	s2,s2,-1365
    8000175e:	0932                	slli	s2,s2,0xc
    80001760:	aab90913          	addi	s2,s2,-1365
    80001764:	040009b7          	lui	s3,0x4000
    80001768:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000176a:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000176c:	00014a97          	auipc	s5,0x14
    80001770:	6b4a8a93          	addi	s5,s5,1716 # 80015e20 <tickslock>
    char *pa = kalloc();
    80001774:	b56ff0ef          	jal	80000aca <kalloc>
    80001778:	862a                	mv	a2,a0
    if (pa == 0)
    8000177a:	cd15                	beqz	a0,800017b6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    8000177c:	416485b3          	sub	a1,s1,s6
    80001780:	859d                	srai	a1,a1,0x7
    80001782:	032585b3          	mul	a1,a1,s2
    80001786:	2585                	addiw	a1,a1,1
    80001788:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000178c:	4719                	li	a4,6
    8000178e:	6685                	lui	a3,0x1
    80001790:	40b985b3          	sub	a1,s3,a1
    80001794:	8552                	mv	a0,s4
    80001796:	8bfff0ef          	jal	80001054 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000179a:	18048493          	addi	s1,s1,384
    8000179e:	fd549be3          	bne	s1,s5,80001774 <proc_mapstacks+0x4a>
  }
}
    800017a2:	70e2                	ld	ra,56(sp)
    800017a4:	7442                	ld	s0,48(sp)
    800017a6:	74a2                	ld	s1,40(sp)
    800017a8:	7902                	ld	s2,32(sp)
    800017aa:	69e2                	ld	s3,24(sp)
    800017ac:	6a42                	ld	s4,16(sp)
    800017ae:	6aa2                	ld	s5,8(sp)
    800017b0:	6b02                	ld	s6,0(sp)
    800017b2:	6121                	addi	sp,sp,64
    800017b4:	8082                	ret
      panic("kalloc");
    800017b6:	00006517          	auipc	a0,0x6
    800017ba:	9a250513          	addi	a0,a0,-1630 # 80007158 <etext+0x158>
    800017be:	832ff0ef          	jal	800007f0 <panic>

00000000800017c2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017c2:	7139                	addi	sp,sp,-64
    800017c4:	fc06                	sd	ra,56(sp)
    800017c6:	f822                	sd	s0,48(sp)
    800017c8:	f426                	sd	s1,40(sp)
    800017ca:	f04a                	sd	s2,32(sp)
    800017cc:	ec4e                	sd	s3,24(sp)
    800017ce:	e852                	sd	s4,16(sp)
    800017d0:	e456                	sd	s5,8(sp)
    800017d2:	e05a                	sd	s6,0(sp)
    800017d4:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800017d6:	00006597          	auipc	a1,0x6
    800017da:	98a58593          	addi	a1,a1,-1654 # 80007160 <etext+0x160>
    800017de:	0000e517          	auipc	a0,0xe
    800017e2:	21250513          	addi	a0,a0,530 # 8000f9f0 <pid_lock>
    800017e6:	b34ff0ef          	jal	80000b1a <initlock>
  initlock(&wait_lock, "wait_lock");
    800017ea:	00006597          	auipc	a1,0x6
    800017ee:	97e58593          	addi	a1,a1,-1666 # 80007168 <etext+0x168>
    800017f2:	0000e517          	auipc	a0,0xe
    800017f6:	21650513          	addi	a0,a0,534 # 8000fa08 <wait_lock>
    800017fa:	b20ff0ef          	jal	80000b1a <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fe:	0000e497          	auipc	s1,0xe
    80001802:	62248493          	addi	s1,s1,1570 # 8000fe20 <proc>
    initlock(&p->lock, "proc");
    80001806:	00006b17          	auipc	s6,0x6
    8000180a:	972b0b13          	addi	s6,s6,-1678 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000180e:	8aa6                	mv	s5,s1
    80001810:	faaab937          	lui	s2,0xfaaab
    80001814:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa898ab>
    80001818:	0932                	slli	s2,s2,0xc
    8000181a:	aab90913          	addi	s2,s2,-1365
    8000181e:	0932                	slli	s2,s2,0xc
    80001820:	aab90913          	addi	s2,s2,-1365
    80001824:	0932                	slli	s2,s2,0xc
    80001826:	aab90913          	addi	s2,s2,-1365
    8000182a:	040009b7          	lui	s3,0x4000
    8000182e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001830:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001832:	00014a17          	auipc	s4,0x14
    80001836:	5eea0a13          	addi	s4,s4,1518 # 80015e20 <tickslock>
    initlock(&p->lock, "proc");
    8000183a:	85da                	mv	a1,s6
    8000183c:	8526                	mv	a0,s1
    8000183e:	adcff0ef          	jal	80000b1a <initlock>
    p->state = UNUSED;
    80001842:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001846:	415487b3          	sub	a5,s1,s5
    8000184a:	879d                	srai	a5,a5,0x7
    8000184c:	032787b3          	mul	a5,a5,s2
    80001850:	2785                	addiw	a5,a5,1
    80001852:	00d7979b          	slliw	a5,a5,0xd
    80001856:	40f987b3          	sub	a5,s3,a5
    8000185a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185c:	18048493          	addi	s1,s1,384
    80001860:	fd449de3          	bne	s1,s4,8000183a <procinit+0x78>
  }
}
    80001864:	70e2                	ld	ra,56(sp)
    80001866:	7442                	ld	s0,48(sp)
    80001868:	74a2                	ld	s1,40(sp)
    8000186a:	7902                	ld	s2,32(sp)
    8000186c:	69e2                	ld	s3,24(sp)
    8000186e:	6a42                	ld	s4,16(sp)
    80001870:	6aa2                	ld	s5,8(sp)
    80001872:	6b02                	ld	s6,0(sp)
    80001874:	6121                	addi	sp,sp,64
    80001876:	8082                	ret

0000000080001878 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001878:	1141                	addi	sp,sp,-16
    8000187a:	e422                	sd	s0,8(sp)
    8000187c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000187e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001880:	2501                	sext.w	a0,a0
    80001882:	6422                	ld	s0,8(sp)
    80001884:	0141                	addi	sp,sp,16
    80001886:	8082                	ret

0000000080001888 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001888:	1141                	addi	sp,sp,-16
    8000188a:	e422                	sd	s0,8(sp)
    8000188c:	0800                	addi	s0,sp,16
    8000188e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001890:	2781                	sext.w	a5,a5
    80001892:	079e                	slli	a5,a5,0x7
  return c;
}
    80001894:	0000e517          	auipc	a0,0xe
    80001898:	18c50513          	addi	a0,a0,396 # 8000fa20 <cpus>
    8000189c:	953e                	add	a0,a0,a5
    8000189e:	6422                	ld	s0,8(sp)
    800018a0:	0141                	addi	sp,sp,16
    800018a2:	8082                	ret

00000000800018a4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018a4:	1101                	addi	sp,sp,-32
    800018a6:	ec06                	sd	ra,24(sp)
    800018a8:	e822                	sd	s0,16(sp)
    800018aa:	e426                	sd	s1,8(sp)
    800018ac:	1000                	addi	s0,sp,32
  push_off();
    800018ae:	aacff0ef          	jal	80000b5a <push_off>
    800018b2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018b4:	2781                	sext.w	a5,a5
    800018b6:	079e                	slli	a5,a5,0x7
    800018b8:	0000e717          	auipc	a4,0xe
    800018bc:	13870713          	addi	a4,a4,312 # 8000f9f0 <pid_lock>
    800018c0:	97ba                	add	a5,a5,a4
    800018c2:	7b84                	ld	s1,48(a5)
  pop_off();
    800018c4:	b0cff0ef          	jal	80000bd0 <pop_off>
  return p;
}
    800018c8:	8526                	mv	a0,s1
    800018ca:	60e2                	ld	ra,24(sp)
    800018cc:	6442                	ld	s0,16(sp)
    800018ce:	64a2                	ld	s1,8(sp)
    800018d0:	6105                	addi	sp,sp,32
    800018d2:	8082                	ret

00000000800018d4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018d4:	7179                	addi	sp,sp,-48
    800018d6:	f406                	sd	ra,40(sp)
    800018d8:	f022                	sd	s0,32(sp)
    800018da:	ec26                	sd	s1,24(sp)
    800018dc:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800018de:	fc7ff0ef          	jal	800018a4 <myproc>
    800018e2:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800018e4:	b38ff0ef          	jal	80000c1c <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    800018e8:	00006797          	auipc	a5,0x6
    800018ec:	fb87a783          	lw	a5,-72(a5) # 800078a0 <first.1>
    800018f0:	0ff0000f          	fence
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	cf9d                	beqz	a5,80001934 <forkret+0x60>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800018f8:	4505                	li	a0,1
    800018fa:	5c7010ef          	jal	800036c0 <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    800018fe:	00006797          	auipc	a5,0x6
    80001902:	fa278793          	addi	a5,a5,-94 # 800078a0 <first.1>
    80001906:	0f50000f          	fence	iorw,ow
    8000190a:	0807a02f          	amoswap.w	zero,zero,(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    8000190e:	00006517          	auipc	a0,0x6
    80001912:	87250513          	addi	a0,a0,-1934 # 80007180 <etext+0x180>
    80001916:	fca43823          	sd	a0,-48(s0)
    8000191a:	fc043c23          	sd	zero,-40(s0)
    8000191e:	fd040593          	addi	a1,s0,-48
    80001922:	7a7020ef          	jal	800048c8 <kexec>
    80001926:	6cbc                	ld	a5,88(s1)
    80001928:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000192a:	6cbc                	ld	a5,88(s1)
    8000192c:	7bb8                	ld	a4,112(a5)
    8000192e:	57fd                	li	a5,-1
    80001930:	02f70d63          	beq	a4,a5,8000196a <forkret+0x96>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001934:	3cf000ef          	jal	80002502 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001938:	68a8                	ld	a0,80(s1)
    8000193a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000193c:	04000737          	lui	a4,0x4000
    80001940:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001942:	0732                	slli	a4,a4,0xc
    80001944:	00004797          	auipc	a5,0x4
    80001948:	75878793          	addi	a5,a5,1880 # 8000609c <userret>
    8000194c:	00004697          	auipc	a3,0x4
    80001950:	6b468693          	addi	a3,a3,1716 # 80006000 <_trampoline>
    80001954:	8f95                	sub	a5,a5,a3
    80001956:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001958:	577d                	li	a4,-1
    8000195a:	177e                	slli	a4,a4,0x3f
    8000195c:	8d59                	or	a0,a0,a4
    8000195e:	9782                	jalr	a5
}
    80001960:	70a2                	ld	ra,40(sp)
    80001962:	7402                	ld	s0,32(sp)
    80001964:	64e2                	ld	s1,24(sp)
    80001966:	6145                	addi	sp,sp,48
    80001968:	8082                	ret
      panic("exec");
    8000196a:	00006517          	auipc	a0,0x6
    8000196e:	81e50513          	addi	a0,a0,-2018 # 80007188 <etext+0x188>
    80001972:	e7ffe0ef          	jal	800007f0 <panic>

0000000080001976 <allocpid>:
{
    80001976:	1101                	addi	sp,sp,-32
    80001978:	ec06                	sd	ra,24(sp)
    8000197a:	e822                	sd	s0,16(sp)
    8000197c:	e426                	sd	s1,8(sp)
    8000197e:	e04a                	sd	s2,0(sp)
    80001980:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001982:	0000e917          	auipc	s2,0xe
    80001986:	06e90913          	addi	s2,s2,110 # 8000f9f0 <pid_lock>
    8000198a:	854a                	mv	a0,s2
    8000198c:	a04ff0ef          	jal	80000b90 <acquire>
  pid = nextpid;
    80001990:	00006797          	auipc	a5,0x6
    80001994:	f1478793          	addi	a5,a5,-236 # 800078a4 <nextpid>
    80001998:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000199a:	0014871b          	addiw	a4,s1,1
    8000199e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019a0:	854a                	mv	a0,s2
    800019a2:	a7aff0ef          	jal	80000c1c <release>
}
    800019a6:	8526                	mv	a0,s1
    800019a8:	60e2                	ld	ra,24(sp)
    800019aa:	6442                	ld	s0,16(sp)
    800019ac:	64a2                	ld	s1,8(sp)
    800019ae:	6902                	ld	s2,0(sp)
    800019b0:	6105                	addi	sp,sp,32
    800019b2:	8082                	ret

00000000800019b4 <proc_pagetable>:
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	e04a                	sd	s2,0(sp)
    800019be:	1000                	addi	s0,sp,32
    800019c0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019c2:	f88ff0ef          	jal	8000114a <uvmcreate>
    800019c6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019c8:	cd05                	beqz	a0,80001a00 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019ca:	4729                	li	a4,10
    800019cc:	00004697          	auipc	a3,0x4
    800019d0:	63468693          	addi	a3,a3,1588 # 80006000 <_trampoline>
    800019d4:	6605                	lui	a2,0x1
    800019d6:	040005b7          	lui	a1,0x4000
    800019da:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	05b2                	slli	a1,a1,0xc
    800019de:	dc6ff0ef          	jal	80000fa4 <mappages>
    800019e2:	02054663          	bltz	a0,80001a0e <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    800019e6:	4719                	li	a4,6
    800019e8:	05893683          	ld	a3,88(s2)
    800019ec:	6605                	lui	a2,0x1
    800019ee:	020005b7          	lui	a1,0x2000
    800019f2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019f4:	05b6                	slli	a1,a1,0xd
    800019f6:	8526                	mv	a0,s1
    800019f8:	dacff0ef          	jal	80000fa4 <mappages>
    800019fc:	00054f63          	bltz	a0,80001a1a <proc_pagetable+0x66>
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6902                	ld	s2,0(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a0e:	4581                	li	a1,0
    80001a10:	8526                	mv	a0,s1
    80001a12:	933ff0ef          	jal	80001344 <uvmfree>
    return 0;
    80001a16:	4481                	li	s1,0
    80001a18:	b7e5                	j	80001a00 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1a:	4681                	li	a3,0
    80001a1c:	4605                	li	a2,1
    80001a1e:	040005b7          	lui	a1,0x4000
    80001a22:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a24:	05b2                	slli	a1,a1,0xc
    80001a26:	8526                	mv	a0,s1
    80001a28:	f48ff0ef          	jal	80001170 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a2c:	4581                	li	a1,0
    80001a2e:	8526                	mv	a0,s1
    80001a30:	915ff0ef          	jal	80001344 <uvmfree>
    return 0;
    80001a34:	4481                	li	s1,0
    80001a36:	b7e9                	j	80001a00 <proc_pagetable+0x4c>

0000000080001a38 <proc_freepagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	84aa                	mv	s1,a0
    80001a46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a48:	4681                	li	a3,0
    80001a4a:	4605                	li	a2,1
    80001a4c:	040005b7          	lui	a1,0x4000
    80001a50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a52:	05b2                	slli	a1,a1,0xc
    80001a54:	f1cff0ef          	jal	80001170 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a58:	4681                	li	a3,0
    80001a5a:	4605                	li	a2,1
    80001a5c:	020005b7          	lui	a1,0x2000
    80001a60:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a62:	05b6                	slli	a1,a1,0xd
    80001a64:	8526                	mv	a0,s1
    80001a66:	f0aff0ef          	jal	80001170 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a6a:	85ca                	mv	a1,s2
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	8d7ff0ef          	jal	80001344 <uvmfree>
}
    80001a72:	60e2                	ld	ra,24(sp)
    80001a74:	6442                	ld	s0,16(sp)
    80001a76:	64a2                	ld	s1,8(sp)
    80001a78:	6902                	ld	s2,0(sp)
    80001a7a:	6105                	addi	sp,sp,32
    80001a7c:	8082                	ret

0000000080001a7e <freeproc>:
{
    80001a7e:	1101                	addi	sp,sp,-32
    80001a80:	ec06                	sd	ra,24(sp)
    80001a82:	e822                	sd	s0,16(sp)
    80001a84:	e426                	sd	s1,8(sp)
    80001a86:	1000                	addi	s0,sp,32
    80001a88:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001a8a:	6d28                	ld	a0,88(a0)
    80001a8c:	c119                	beqz	a0,80001a92 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001a8e:	f5bfe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001a92:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001a96:	68a8                	ld	a0,80(s1)
    80001a98:	c501                	beqz	a0,80001aa0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a9a:	64ac                	ld	a1,72(s1)
    80001a9c:	f9dff0ef          	jal	80001a38 <proc_freepagetable>
  p->pagetable = 0;
    80001aa0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001aa4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001aa8:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001aac:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ab0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ab4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ab8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001abc:	0004ac23          	sw	zero,24(s1)
}
    80001ac0:	60e2                	ld	ra,24(sp)
    80001ac2:	6442                	ld	s0,16(sp)
    80001ac4:	64a2                	ld	s1,8(sp)
    80001ac6:	6105                	addi	sp,sp,32
    80001ac8:	8082                	ret

0000000080001aca <allocproc>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	e04a                	sd	s2,0(sp)
    80001ad4:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ad6:	0000e497          	auipc	s1,0xe
    80001ada:	34a48493          	addi	s1,s1,842 # 8000fe20 <proc>
    80001ade:	00014917          	auipc	s2,0x14
    80001ae2:	34290913          	addi	s2,s2,834 # 80015e20 <tickslock>
    acquire(&p->lock);
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	8a8ff0ef          	jal	80000b90 <acquire>
    if (p->state == UNUSED) {
    80001aec:	4c9c                	lw	a5,24(s1)
    80001aee:	cb91                	beqz	a5,80001b02 <allocproc+0x38>
      release(&p->lock);
    80001af0:	8526                	mv	a0,s1
    80001af2:	92aff0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001af6:	18048493          	addi	s1,s1,384
    80001afa:	ff2496e3          	bne	s1,s2,80001ae6 <allocproc+0x1c>
  return 0;
    80001afe:	4481                	li	s1,0
    80001b00:	a09d                	j	80001b66 <allocproc+0x9c>
  p->pid = allocpid();
    80001b02:	e75ff0ef          	jal	80001976 <allocpid>
    80001b06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b08:	4785                	li	a5,1
    80001b0a:	cc9c                	sw	a5,24(s1)
  p->priority = 1;
    80001b0c:	16f4a423          	sw	a5,360(s1)
  p->queue = 0;
    80001b10:	1604a623          	sw	zero,364(s1)
  p->quantum_used = 0;
    80001b14:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001b18:	00006797          	auipc	a5,0x6
    80001b1c:	db87a783          	lw	a5,-584(a5) # 800078d0 <ticks>
    80001b20:	16f4aa23          	sw	a5,372(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b24:	fa7fe0ef          	jal	80000aca <kalloc>
    80001b28:	892a                	mv	s2,a0
    80001b2a:	eca8                	sd	a0,88(s1)
    80001b2c:	c521                	beqz	a0,80001b74 <allocproc+0xaa>
  p->pagetable = proc_pagetable(p);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	e85ff0ef          	jal	800019b4 <proc_pagetable>
    80001b34:	892a                	mv	s2,a0
    80001b36:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b38:	c531                	beqz	a0,80001b84 <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001b3a:	07000613          	li	a2,112
    80001b3e:	4581                	li	a1,0
    80001b40:	06048513          	addi	a0,s1,96
    80001b44:	910ff0ef          	jal	80000c54 <memset>
  p->context.ra = (uint64)forkret;
    80001b48:	00000797          	auipc	a5,0x0
    80001b4c:	d8c78793          	addi	a5,a5,-628 # 800018d4 <forkret>
    80001b50:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b52:	60bc                	ld	a5,64(s1)
    80001b54:	6705                	lui	a4,0x1
    80001b56:	97ba                	add	a5,a5,a4
    80001b58:	f4bc                	sd	a5,104(s1)
  p->ctime = ticks;
    80001b5a:	00006797          	auipc	a5,0x6
    80001b5e:	d767a783          	lw	a5,-650(a5) # 800078d0 <ticks>
    80001b62:	16f4aa23          	sw	a5,372(s1)
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f09ff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8a0ff0ef          	jal	80000c1c <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	b7d5                	j	80001b66 <allocproc+0x9c>
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	ef9ff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	890ff0ef          	jal	80000c1c <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	bfd1                	j	80001b66 <allocproc+0x9c>

0000000080001b94 <userinit>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b9e:	f2dff0ef          	jal	80001aca <allocproc>
    80001ba2:	84aa                	mv	s1,a0
  initproc = p;
    80001ba4:	00006797          	auipc	a5,0x6
    80001ba8:	d2a7b223          	sd	a0,-732(a5) # 800078c8 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5e450513          	addi	a0,a0,1508 # 80007190 <etext+0x190>
    80001bb4:	044020ef          	jal	80003bf8 <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	85aff0ef          	jal	80000c1c <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bde:	cc7ff0ef          	jal	800018a4 <myproc>
    80001be2:	892a                	mv	s2,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001be6:	02905963          	blez	s1,80001c18 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001bea:	00b48633          	add	a2,s1,a1
    80001bee:	020007b7          	lui	a5,0x2000
    80001bf2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bf4:	07b6                	slli	a5,a5,0xd
    80001bf6:	02c7ea63          	bltu	a5,a2,80001c2a <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfa:	4691                	li	a3,4
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	e40ff0ef          	jal	8000123e <uvmalloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	c50d                	beqz	a0,80001c2e <growproc+0x5e>
  p->sz = sz;
    80001c06:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c0a:	4501                	li	a0,0
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6902                	ld	s2,0(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
  } else if (n < 0) {
    80001c18:	fe04d7e3          	bgez	s1,80001c06 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c1c:	00b48633          	add	a2,s1,a1
    80001c20:	6928                	ld	a0,80(a0)
    80001c22:	dd8ff0ef          	jal	800011fa <uvmdealloc>
    80001c26:	85aa                	mv	a1,a0
    80001c28:	bff9                	j	80001c06 <growproc+0x36>
      return -1;
    80001c2a:	557d                	li	a0,-1
    80001c2c:	b7c5                	j	80001c0c <growproc+0x3c>
      return -1;
    80001c2e:	557d                	li	a0,-1
    80001c30:	bff1                	j	80001c0c <growproc+0x3c>

0000000080001c32 <kfork>:
{
    80001c32:	7139                	addi	sp,sp,-64
    80001c34:	fc06                	sd	ra,56(sp)
    80001c36:	f822                	sd	s0,48(sp)
    80001c38:	f04a                	sd	s2,32(sp)
    80001c3a:	e456                	sd	s5,8(sp)
    80001c3c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c3e:	c67ff0ef          	jal	800018a4 <myproc>
    80001c42:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c44:	e87ff0ef          	jal	80001aca <allocproc>
    80001c48:	0e050a63          	beqz	a0,80001d3c <kfork+0x10a>
    80001c4c:	e852                	sd	s4,16(sp)
    80001c4e:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c50:	048ab603          	ld	a2,72(s5)
    80001c54:	692c                	ld	a1,80(a0)
    80001c56:	050ab503          	ld	a0,80(s5)
    80001c5a:	f1cff0ef          	jal	80001376 <uvmcopy>
    80001c5e:	04054a63          	bltz	a0,80001cb2 <kfork+0x80>
    80001c62:	f426                	sd	s1,40(sp)
    80001c64:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c66:	048ab783          	ld	a5,72(s5)
    80001c6a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c6e:	058ab683          	ld	a3,88(s5)
    80001c72:	87b6                	mv	a5,a3
    80001c74:	058a3703          	ld	a4,88(s4)
    80001c78:	12068693          	addi	a3,a3,288
    80001c7c:	0007b803          	ld	a6,0(a5)
    80001c80:	6788                	ld	a0,8(a5)
    80001c82:	6b8c                	ld	a1,16(a5)
    80001c84:	6f90                	ld	a2,24(a5)
    80001c86:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c8a:	e708                	sd	a0,8(a4)
    80001c8c:	eb0c                	sd	a1,16(a4)
    80001c8e:	ef10                	sd	a2,24(a4)
    80001c90:	02078793          	addi	a5,a5,32
    80001c94:	02070713          	addi	a4,a4,32
    80001c98:	fed792e3          	bne	a5,a3,80001c7c <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c9c:	058a3783          	ld	a5,88(s4)
    80001ca0:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ca4:	0d0a8493          	addi	s1,s5,208
    80001ca8:	0d0a0913          	addi	s2,s4,208
    80001cac:	150a8993          	addi	s3,s5,336
    80001cb0:	a831                	j	80001ccc <kfork+0x9a>
    freeproc(np);
    80001cb2:	8552                	mv	a0,s4
    80001cb4:	dcbff0ef          	jal	80001a7e <freeproc>
    release(&np->lock);
    80001cb8:	8552                	mv	a0,s4
    80001cba:	f63fe0ef          	jal	80000c1c <release>
    return -1;
    80001cbe:	597d                	li	s2,-1
    80001cc0:	6a42                	ld	s4,16(sp)
    80001cc2:	a0b5                	j	80001d2e <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001cc4:	04a1                	addi	s1,s1,8
    80001cc6:	0921                	addi	s2,s2,8
    80001cc8:	01348963          	beq	s1,s3,80001cda <kfork+0xa8>
    if (p->ofile[i])
    80001ccc:	6088                	ld	a0,0(s1)
    80001cce:	d97d                	beqz	a0,80001cc4 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cd0:	562020ef          	jal	80004232 <filedup>
    80001cd4:	00a93023          	sd	a0,0(s2)
    80001cd8:	b7f5                	j	80001cc4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cda:	150ab503          	ld	a0,336(s5)
    80001cde:	670010ef          	jal	8000334e <idup>
    80001ce2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce6:	4641                	li	a2,16
    80001ce8:	158a8593          	addi	a1,s5,344
    80001cec:	158a0513          	addi	a0,s4,344
    80001cf0:	8a2ff0ef          	jal	80000d92 <safestrcpy>
  pid = np->pid;
    80001cf4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cf8:	8552                	mv	a0,s4
    80001cfa:	f23fe0ef          	jal	80000c1c <release>
  acquire(&wait_lock);
    80001cfe:	0000e497          	auipc	s1,0xe
    80001d02:	d0a48493          	addi	s1,s1,-758 # 8000fa08 <wait_lock>
    80001d06:	8526                	mv	a0,s1
    80001d08:	e89fe0ef          	jal	80000b90 <acquire>
  np->parent = p;
    80001d0c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	f0bfe0ef          	jal	80000c1c <release>
  acquire(&np->lock);
    80001d16:	8552                	mv	a0,s4
    80001d18:	e79fe0ef          	jal	80000b90 <acquire>
  np->state = RUNNABLE;
    80001d1c:	478d                	li	a5,3
    80001d1e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d22:	8552                	mv	a0,s4
    80001d24:	ef9fe0ef          	jal	80000c1c <release>
  return pid;
    80001d28:	74a2                	ld	s1,40(sp)
    80001d2a:	69e2                	ld	s3,24(sp)
    80001d2c:	6a42                	ld	s4,16(sp)
}
    80001d2e:	854a                	mv	a0,s2
    80001d30:	70e2                	ld	ra,56(sp)
    80001d32:	7442                	ld	s0,48(sp)
    80001d34:	7902                	ld	s2,32(sp)
    80001d36:	6aa2                	ld	s5,8(sp)
    80001d38:	6121                	addi	sp,sp,64
    80001d3a:	8082                	ret
    return -1;
    80001d3c:	597d                	li	s2,-1
    80001d3e:	bfc5                	j	80001d2e <kfork+0xfc>

0000000080001d40 <scheduler>:
{
    80001d40:	711d                	addi	sp,sp,-96
    80001d42:	ec86                	sd	ra,88(sp)
    80001d44:	e8a2                	sd	s0,80(sp)
    80001d46:	e4a6                	sd	s1,72(sp)
    80001d48:	e0ca                	sd	s2,64(sp)
    80001d4a:	fc4e                	sd	s3,56(sp)
    80001d4c:	f852                	sd	s4,48(sp)
    80001d4e:	f456                	sd	s5,40(sp)
    80001d50:	f05a                	sd	s6,32(sp)
    80001d52:	ec5e                	sd	s7,24(sp)
    80001d54:	e862                	sd	s8,16(sp)
    80001d56:	e466                	sd	s9,8(sp)
    80001d58:	1080                	addi	s0,sp,96
    80001d5a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d5c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d5e:	00779b93          	slli	s7,a5,0x7
    80001d62:	0000e717          	auipc	a4,0xe
    80001d66:	c8e70713          	addi	a4,a4,-882 # 8000f9f0 <pid_lock>
    80001d6a:	975e                	add	a4,a4,s7
    80001d6c:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001d70:	0000e717          	auipc	a4,0xe
    80001d74:	cb870713          	addi	a4,a4,-840 # 8000fa28 <cpus+0x8>
    80001d78:	9bba                	add	s7,s7,a4
      for (p = proc; p < &proc[NPROC]; p++) {
    80001d7a:	00014997          	auipc	s3,0x14
    80001d7e:	0a698993          	addi	s3,s3,166 # 80015e20 <tickslock>
          c->proc = p;
    80001d82:	0000ec17          	auipc	s8,0xe
    80001d86:	c6ec0c13          	addi	s8,s8,-914 # 8000f9f0 <pid_lock>
    80001d8a:	079e                	slli	a5,a5,0x7
    80001d8c:	00fc0b33          	add	s6,s8,a5
          if (p->quantum_used >= quantum[q] && p->queue < NQUEUE - 1) {
    80001d90:	00006c97          	auipc	s9,0x6
    80001d94:	9d8c8c93          	addi	s9,s9,-1576 # 80007768 <quantum>
    80001d98:	a871                	j	80001e34 <scheduler+0xf4>
            p->queue++;         // Demote to next lower queue band[cite: 1]
    80001d9a:	2785                	addiw	a5,a5,1
    80001d9c:	16f4a623          	sw	a5,364(s1)
            p->quantum_used = 0; // Reset quantum counter for the new queue
    80001da0:	1604a823          	sw	zero,368(s1)
    80001da4:	a0ad                	j	80001e0e <scheduler+0xce>
        release(&p->lock);
    80001da6:	8526                	mv	a0,s1
    80001da8:	e75fe0ef          	jal	80000c1c <release>
      for (p = proc; p < &proc[NPROC]; p++) {
    80001dac:	18048493          	addi	s1,s1,384
    80001db0:	07348c63          	beq	s1,s3,80001e28 <scheduler+0xe8>
        acquire(&p->lock);
    80001db4:	8526                	mv	a0,s1
    80001db6:	ddbfe0ef          	jal	80000b90 <acquire>
        if (p->state == RUNNABLE && p->queue == q) {
    80001dba:	4c9c                	lw	a5,24(s1)
    80001dbc:	ff2795e3          	bne	a5,s2,80001da6 <scheduler+0x66>
    80001dc0:	16c4a783          	lw	a5,364(s1)
    80001dc4:	ff4791e3          	bne	a5,s4,80001da6 <scheduler+0x66>
          p->state = RUNNING;
    80001dc8:	4791                	li	a5,4
    80001dca:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001dcc:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &p->context);
    80001dd0:	06048593          	addi	a1,s1,96
    80001dd4:	855e                	mv	a0,s7
    80001dd6:	686000ef          	jal	8000245c <swtch>
    80001dda:	8792                	mv	a5,tp
          mycpu()->intena = 0;
    80001ddc:	2781                	sext.w	a5,a5
    80001dde:	079e                	slli	a5,a5,0x7
    80001de0:	97e2                	add	a5,a5,s8
    80001de2:	0a07a623          	sw	zero,172(a5)
          c->proc = 0;
    80001de6:	020b3823          	sd	zero,48(s6)
          p->quantum_used++;
    80001dea:	1704a783          	lw	a5,368(s1)
    80001dee:	2785                	addiw	a5,a5,1
    80001df0:	0007871b          	sext.w	a4,a5
    80001df4:	16f4a823          	sw	a5,368(s1)
          if (p->quantum_used >= quantum[q] && p->queue < NQUEUE - 1) {
    80001df8:	0a0a                	slli	s4,s4,0x2
    80001dfa:	9a66                	add	s4,s4,s9
    80001dfc:	000a2783          	lw	a5,0(s4)
    80001e00:	00f74763          	blt	a4,a5,80001e0e <scheduler+0xce>
    80001e04:	16c4a783          	lw	a5,364(s1)
    80001e08:	4705                	li	a4,1
    80001e0a:	f8f758e3          	bge	a4,a5,80001d9a <scheduler+0x5a>
          release(&p->lock);
    80001e0e:	8526                	mv	a0,s1
    80001e10:	e0dfe0ef          	jal	80000c1c <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e14:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e18:	10017073          	csrci	sstatus,2
    for (q = 0; q < NQUEUE; q++) {
    80001e1c:	8a56                	mv	s4,s5
      for (p = proc; p < &proc[NPROC]; p++) {
    80001e1e:	0000e497          	auipc	s1,0xe
    80001e22:	00248493          	addi	s1,s1,2 # 8000fe20 <proc>
    80001e26:	b779                	j	80001db4 <scheduler+0x74>
    for (q = 0; q < NQUEUE; q++) {
    80001e28:	2a05                	addiw	s4,s4,1
    80001e2a:	478d                	li	a5,3
    80001e2c:	fefa19e3          	bne	s4,a5,80001e1e <scheduler+0xde>
      asm volatile("wfi");
    80001e30:	10500073          	wfi
    for (q = 0; q < NQUEUE; q++) {
    80001e34:	4a81                	li	s5,0
        if (p->state == RUNNABLE && p->queue == q) {
    80001e36:	490d                	li	s2,3
    80001e38:	bff1                	j	80001e14 <scheduler+0xd4>

0000000080001e3a <sched>:
{
    80001e3a:	7179                	addi	sp,sp,-48
    80001e3c:	f406                	sd	ra,40(sp)
    80001e3e:	f022                	sd	s0,32(sp)
    80001e40:	ec26                	sd	s1,24(sp)
    80001e42:	e84a                	sd	s2,16(sp)
    80001e44:	e44e                	sd	s3,8(sp)
    80001e46:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e48:	a5dff0ef          	jal	800018a4 <myproc>
    80001e4c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e4e:	ce3fe0ef          	jal	80000b30 <holding>
    80001e52:	c92d                	beqz	a0,80001ec4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e54:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e56:	2781                	sext.w	a5,a5
    80001e58:	079e                	slli	a5,a5,0x7
    80001e5a:	0000e717          	auipc	a4,0xe
    80001e5e:	b9670713          	addi	a4,a4,-1130 # 8000f9f0 <pid_lock>
    80001e62:	97ba                	add	a5,a5,a4
    80001e64:	0a87a703          	lw	a4,168(a5)
    80001e68:	4785                	li	a5,1
    80001e6a:	06f71363          	bne	a4,a5,80001ed0 <sched+0x96>
  if (p->state == RUNNING)
    80001e6e:	4c98                	lw	a4,24(s1)
    80001e70:	4791                	li	a5,4
    80001e72:	06f70563          	beq	a4,a5,80001edc <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e7a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e7c:	e7b5                	bnez	a5,80001ee8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e7e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e80:	0000e917          	auipc	s2,0xe
    80001e84:	b7090913          	addi	s2,s2,-1168 # 8000f9f0 <pid_lock>
    80001e88:	2781                	sext.w	a5,a5
    80001e8a:	079e                	slli	a5,a5,0x7
    80001e8c:	97ca                	add	a5,a5,s2
    80001e8e:	0ac7a983          	lw	s3,172(a5)
    80001e92:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e94:	2781                	sext.w	a5,a5
    80001e96:	079e                	slli	a5,a5,0x7
    80001e98:	0000e597          	auipc	a1,0xe
    80001e9c:	b9058593          	addi	a1,a1,-1136 # 8000fa28 <cpus+0x8>
    80001ea0:	95be                	add	a1,a1,a5
    80001ea2:	06048513          	addi	a0,s1,96
    80001ea6:	5b6000ef          	jal	8000245c <swtch>
    80001eaa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eac:	2781                	sext.w	a5,a5
    80001eae:	079e                	slli	a5,a5,0x7
    80001eb0:	993e                	add	s2,s2,a5
    80001eb2:	0b392623          	sw	s3,172(s2)
}
    80001eb6:	70a2                	ld	ra,40(sp)
    80001eb8:	7402                	ld	s0,32(sp)
    80001eba:	64e2                	ld	s1,24(sp)
    80001ebc:	6942                	ld	s2,16(sp)
    80001ebe:	69a2                	ld	s3,8(sp)
    80001ec0:	6145                	addi	sp,sp,48
    80001ec2:	8082                	ret
    panic("sched p->lock");
    80001ec4:	00005517          	auipc	a0,0x5
    80001ec8:	2d450513          	addi	a0,a0,724 # 80007198 <etext+0x198>
    80001ecc:	925fe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001ed0:	00005517          	auipc	a0,0x5
    80001ed4:	2d850513          	addi	a0,a0,728 # 800071a8 <etext+0x1a8>
    80001ed8:	919fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001edc:	00005517          	auipc	a0,0x5
    80001ee0:	2dc50513          	addi	a0,a0,732 # 800071b8 <etext+0x1b8>
    80001ee4:	90dfe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001ee8:	00005517          	auipc	a0,0x5
    80001eec:	2e050513          	addi	a0,a0,736 # 800071c8 <etext+0x1c8>
    80001ef0:	901fe0ef          	jal	800007f0 <panic>

0000000080001ef4 <yield>:
{
    80001ef4:	1101                	addi	sp,sp,-32
    80001ef6:	ec06                	sd	ra,24(sp)
    80001ef8:	e822                	sd	s0,16(sp)
    80001efa:	e426                	sd	s1,8(sp)
    80001efc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001efe:	9a7ff0ef          	jal	800018a4 <myproc>
    80001f02:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f04:	c8dfe0ef          	jal	80000b90 <acquire>
  p->state = RUNNABLE;
    80001f08:	478d                	li	a5,3
    80001f0a:	cc9c                	sw	a5,24(s1)
  sched();
    80001f0c:	f2fff0ef          	jal	80001e3a <sched>
  release(&p->lock);
    80001f10:	8526                	mv	a0,s1
    80001f12:	d0bfe0ef          	jal	80000c1c <release>
}
    80001f16:	60e2                	ld	ra,24(sp)
    80001f18:	6442                	ld	s0,16(sp)
    80001f1a:	64a2                	ld	s1,8(sp)
    80001f1c:	6105                	addi	sp,sp,32
    80001f1e:	8082                	ret

0000000080001f20 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f20:	1101                	addi	sp,sp,-32
    80001f22:	ec06                	sd	ra,24(sp)
    80001f24:	e822                	sd	s0,16(sp)
    80001f26:	e426                	sd	s1,8(sp)
    80001f28:	e04a                	sd	s2,0(sp)
    80001f2a:	1000                	addi	s0,sp,32
    80001f2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f2e:	977ff0ef          	jal	800018a4 <myproc>
    80001f32:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f34:	c5dfe0ef          	jal	80000b90 <acquire>
  if (chan == 0)
    80001f38:	cc81                	beqz	s1,80001f50 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f3a:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f3e:	854a                	mv	a0,s2
    80001f40:	cddfe0ef          	jal	80000c1c <release>
}
    80001f44:	60e2                	ld	ra,24(sp)
    80001f46:	6442                	ld	s0,16(sp)
    80001f48:	64a2                	ld	s1,8(sp)
    80001f4a:	6902                	ld	s2,0(sp)
    80001f4c:	6105                	addi	sp,sp,32
    80001f4e:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f50:	00005517          	auipc	a0,0x5
    80001f54:	29050513          	addi	a0,a0,656 # 800071e0 <etext+0x1e0>
    80001f58:	899fe0ef          	jal	800007f0 <panic>

0000000080001f5c <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f5c:	1101                	addi	sp,sp,-32
    80001f5e:	ec06                	sd	ra,24(sp)
    80001f60:	e822                	sd	s0,16(sp)
    80001f62:	e426                	sd	s1,8(sp)
    80001f64:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f66:	93fff0ef          	jal	800018a4 <myproc>
    80001f6a:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f6c:	c25fe0ef          	jal	80000b90 <acquire>
  if (p->chan != 0) {
    80001f70:	709c                	ld	a5,32(s1)
    80001f72:	c789                	beqz	a5,80001f7c <sleep+0x20>
    p->state = SLEEPING;
    80001f74:	4789                	li	a5,2
    80001f76:	cc9c                	sw	a5,24(s1)
    sched();
    80001f78:	ec3ff0ef          	jal	80001e3a <sched>
  }
  release(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	c9ffe0ef          	jal	80000c1c <release>
}
    80001f82:	60e2                	ld	ra,24(sp)
    80001f84:	6442                	ld	s0,16(sp)
    80001f86:	64a2                	ld	s1,8(sp)
    80001f88:	6105                	addi	sp,sp,32
    80001f8a:	8082                	ret

0000000080001f8c <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f8c:	7139                	addi	sp,sp,-64
    80001f8e:	fc06                	sd	ra,56(sp)
    80001f90:	f822                	sd	s0,48(sp)
    80001f92:	f426                	sd	s1,40(sp)
    80001f94:	f04a                	sd	s2,32(sp)
    80001f96:	ec4e                	sd	s3,24(sp)
    80001f98:	e852                	sd	s4,16(sp)
    80001f9a:	e456                	sd	s5,8(sp)
    80001f9c:	0080                	addi	s0,sp,64
    80001f9e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fa0:	0000e497          	auipc	s1,0xe
    80001fa4:	e8048493          	addi	s1,s1,-384 # 8000fe20 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001fa8:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001faa:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fac:	00014997          	auipc	s3,0x14
    80001fb0:	e7498993          	addi	s3,s3,-396 # 80015e20 <tickslock>
    80001fb4:	a801                	j	80001fc4 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	c65fe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fbc:	18048493          	addi	s1,s1,384
    80001fc0:	03348063          	beq	s1,s3,80001fe0 <wakeup+0x54>
    acquire(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	bcbfe0ef          	jal	80000b90 <acquire>
    if (p->chan == chan) {
    80001fca:	709c                	ld	a5,32(s1)
    80001fcc:	ff2795e3          	bne	a5,s2,80001fb6 <wakeup+0x2a>
      p->chan = 0;
    80001fd0:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001fd4:	4c9c                	lw	a5,24(s1)
    80001fd6:	ff4790e3          	bne	a5,s4,80001fb6 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fda:	0154ac23          	sw	s5,24(s1)
    80001fde:	bfe1                	j	80001fb6 <wakeup+0x2a>
  }
}
    80001fe0:	70e2                	ld	ra,56(sp)
    80001fe2:	7442                	ld	s0,48(sp)
    80001fe4:	74a2                	ld	s1,40(sp)
    80001fe6:	7902                	ld	s2,32(sp)
    80001fe8:	69e2                	ld	s3,24(sp)
    80001fea:	6a42                	ld	s4,16(sp)
    80001fec:	6aa2                	ld	s5,8(sp)
    80001fee:	6121                	addi	sp,sp,64
    80001ff0:	8082                	ret

0000000080001ff2 <reparent>:
{
    80001ff2:	7179                	addi	sp,sp,-48
    80001ff4:	f406                	sd	ra,40(sp)
    80001ff6:	f022                	sd	s0,32(sp)
    80001ff8:	ec26                	sd	s1,24(sp)
    80001ffa:	e84a                	sd	s2,16(sp)
    80001ffc:	e44e                	sd	s3,8(sp)
    80001ffe:	e052                	sd	s4,0(sp)
    80002000:	1800                	addi	s0,sp,48
    80002002:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002004:	0000e497          	auipc	s1,0xe
    80002008:	e1c48493          	addi	s1,s1,-484 # 8000fe20 <proc>
      pp->parent = initproc;
    8000200c:	00006a17          	auipc	s4,0x6
    80002010:	8bca0a13          	addi	s4,s4,-1860 # 800078c8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002014:	00014997          	auipc	s3,0x14
    80002018:	e0c98993          	addi	s3,s3,-500 # 80015e20 <tickslock>
    8000201c:	a029                	j	80002026 <reparent+0x34>
    8000201e:	18048493          	addi	s1,s1,384
    80002022:	01348b63          	beq	s1,s3,80002038 <reparent+0x46>
    if (pp->parent == p) {
    80002026:	7c9c                	ld	a5,56(s1)
    80002028:	ff279be3          	bne	a5,s2,8000201e <reparent+0x2c>
      pp->parent = initproc;
    8000202c:	000a3503          	ld	a0,0(s4)
    80002030:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002032:	f5bff0ef          	jal	80001f8c <wakeup>
    80002036:	b7e5                	j	8000201e <reparent+0x2c>
}
    80002038:	70a2                	ld	ra,40(sp)
    8000203a:	7402                	ld	s0,32(sp)
    8000203c:	64e2                	ld	s1,24(sp)
    8000203e:	6942                	ld	s2,16(sp)
    80002040:	69a2                	ld	s3,8(sp)
    80002042:	6a02                	ld	s4,0(sp)
    80002044:	6145                	addi	sp,sp,48
    80002046:	8082                	ret

0000000080002048 <kexit>:
{
    80002048:	7179                	addi	sp,sp,-48
    8000204a:	f406                	sd	ra,40(sp)
    8000204c:	f022                	sd	s0,32(sp)
    8000204e:	ec26                	sd	s1,24(sp)
    80002050:	e84a                	sd	s2,16(sp)
    80002052:	e44e                	sd	s3,8(sp)
    80002054:	e052                	sd	s4,0(sp)
    80002056:	1800                	addi	s0,sp,48
    80002058:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000205a:	84bff0ef          	jal	800018a4 <myproc>
    8000205e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002060:	00006797          	auipc	a5,0x6
    80002064:	8687b783          	ld	a5,-1944(a5) # 800078c8 <initproc>
    80002068:	0d050493          	addi	s1,a0,208
    8000206c:	15050913          	addi	s2,a0,336
    80002070:	00a79f63          	bne	a5,a0,8000208e <kexit+0x46>
    panic("init exiting");
    80002074:	00005517          	auipc	a0,0x5
    80002078:	18c50513          	addi	a0,a0,396 # 80007200 <etext+0x200>
    8000207c:	f74fe0ef          	jal	800007f0 <panic>
      fileclose(f);
    80002080:	1f8020ef          	jal	80004278 <fileclose>
      p->ofile[fd] = 0;
    80002084:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    80002088:	04a1                	addi	s1,s1,8
    8000208a:	01248563          	beq	s1,s2,80002094 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000208e:	6088                	ld	a0,0(s1)
    80002090:	f965                	bnez	a0,80002080 <kexit+0x38>
    80002092:	bfdd                	j	80002088 <kexit+0x40>
  begin_op();
    80002094:	539010ef          	jal	80003dcc <begin_op>
  iput(p->cwd);
    80002098:	1509b503          	ld	a0,336(s3)
    8000209c:	46a010ef          	jal	80003506 <iput>
  end_op();
    800020a0:	5b3010ef          	jal	80003e52 <end_op>
  p->cwd = 0;
    800020a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020a8:	0000e497          	auipc	s1,0xe
    800020ac:	96048493          	addi	s1,s1,-1696 # 8000fa08 <wait_lock>
    800020b0:	8526                	mv	a0,s1
    800020b2:	adffe0ef          	jal	80000b90 <acquire>
  reparent(p);
    800020b6:	854e                	mv	a0,s3
    800020b8:	f3bff0ef          	jal	80001ff2 <reparent>
  wakeup(p->parent);
    800020bc:	0389b503          	ld	a0,56(s3)
    800020c0:	ecdff0ef          	jal	80001f8c <wakeup>
  acquire(&p->lock);
    800020c4:	854e                	mv	a0,s3
    800020c6:	acbfe0ef          	jal	80000b90 <acquire>
  p->etime = ticks;
    800020ca:	00006797          	auipc	a5,0x6
    800020ce:	8067a783          	lw	a5,-2042(a5) # 800078d0 <ticks>
    800020d2:	16f9ac23          	sw	a5,376(s3)
  p->xstate = status;
    800020d6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020da:	4795                	li	a5,5
    800020dc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	b3bfe0ef          	jal	80000c1c <release>
  sched();
    800020e6:	d55ff0ef          	jal	80001e3a <sched>
  panic("zombie exit");
    800020ea:	00005517          	auipc	a0,0x5
    800020ee:	12650513          	addi	a0,a0,294 # 80007210 <etext+0x210>
    800020f2:	efefe0ef          	jal	800007f0 <panic>

00000000800020f6 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020f6:	7179                	addi	sp,sp,-48
    800020f8:	f406                	sd	ra,40(sp)
    800020fa:	f022                	sd	s0,32(sp)
    800020fc:	ec26                	sd	s1,24(sp)
    800020fe:	e84a                	sd	s2,16(sp)
    80002100:	e44e                	sd	s3,8(sp)
    80002102:	1800                	addi	s0,sp,48
    80002104:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002106:	0000e497          	auipc	s1,0xe
    8000210a:	d1a48493          	addi	s1,s1,-742 # 8000fe20 <proc>
    8000210e:	00014997          	auipc	s3,0x14
    80002112:	d1298993          	addi	s3,s3,-750 # 80015e20 <tickslock>
    acquire(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	a79fe0ef          	jal	80000b90 <acquire>
    if (p->pid == pid) {
    8000211c:	589c                	lw	a5,48(s1)
    8000211e:	01278b63          	beq	a5,s2,80002134 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	af9fe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002128:	18048493          	addi	s1,s1,384
    8000212c:	ff3495e3          	bne	s1,s3,80002116 <kkill+0x20>
  }
  return -1;
    80002130:	557d                	li	a0,-1
    80002132:	a819                	j	80002148 <kkill+0x52>
      p->killed = 1;
    80002134:	4785                	li	a5,1
    80002136:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002138:	4c98                	lw	a4,24(s1)
    8000213a:	4789                	li	a5,2
    8000213c:	00f70d63          	beq	a4,a5,80002156 <kkill+0x60>
      release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	adbfe0ef          	jal	80000c1c <release>
      return 0;
    80002146:	4501                	li	a0,0
}
    80002148:	70a2                	ld	ra,40(sp)
    8000214a:	7402                	ld	s0,32(sp)
    8000214c:	64e2                	ld	s1,24(sp)
    8000214e:	6942                	ld	s2,16(sp)
    80002150:	69a2                	ld	s3,8(sp)
    80002152:	6145                	addi	sp,sp,48
    80002154:	8082                	ret
        p->state = RUNNABLE;
    80002156:	478d                	li	a5,3
    80002158:	cc9c                	sw	a5,24(s1)
    8000215a:	b7dd                	j	80002140 <kkill+0x4a>

000000008000215c <setkilled>:

void
setkilled(struct proc *p)
{
    8000215c:	1101                	addi	sp,sp,-32
    8000215e:	ec06                	sd	ra,24(sp)
    80002160:	e822                	sd	s0,16(sp)
    80002162:	e426                	sd	s1,8(sp)
    80002164:	1000                	addi	s0,sp,32
    80002166:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002168:	a29fe0ef          	jal	80000b90 <acquire>
  p->killed = 1;
    8000216c:	4785                	li	a5,1
    8000216e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	aabfe0ef          	jal	80000c1c <release>
}
    80002176:	60e2                	ld	ra,24(sp)
    80002178:	6442                	ld	s0,16(sp)
    8000217a:	64a2                	ld	s1,8(sp)
    8000217c:	6105                	addi	sp,sp,32
    8000217e:	8082                	ret

0000000080002180 <killed>:

int
killed(struct proc *p)
{
    80002180:	1101                	addi	sp,sp,-32
    80002182:	ec06                	sd	ra,24(sp)
    80002184:	e822                	sd	s0,16(sp)
    80002186:	e426                	sd	s1,8(sp)
    80002188:	e04a                	sd	s2,0(sp)
    8000218a:	1000                	addi	s0,sp,32
    8000218c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000218e:	a03fe0ef          	jal	80000b90 <acquire>
  k = p->killed;
    80002192:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002196:	8526                	mv	a0,s1
    80002198:	a85fe0ef          	jal	80000c1c <release>
  return k;
}
    8000219c:	854a                	mv	a0,s2
    8000219e:	60e2                	ld	ra,24(sp)
    800021a0:	6442                	ld	s0,16(sp)
    800021a2:	64a2                	ld	s1,8(sp)
    800021a4:	6902                	ld	s2,0(sp)
    800021a6:	6105                	addi	sp,sp,32
    800021a8:	8082                	ret

00000000800021aa <kwait>:
{
    800021aa:	715d                	addi	sp,sp,-80
    800021ac:	e486                	sd	ra,72(sp)
    800021ae:	e0a2                	sd	s0,64(sp)
    800021b0:	fc26                	sd	s1,56(sp)
    800021b2:	f84a                	sd	s2,48(sp)
    800021b4:	f44e                	sd	s3,40(sp)
    800021b6:	f052                	sd	s4,32(sp)
    800021b8:	ec56                	sd	s5,24(sp)
    800021ba:	e85a                	sd	s6,16(sp)
    800021bc:	e45e                	sd	s7,8(sp)
    800021be:	e062                	sd	s8,0(sp)
    800021c0:	0880                	addi	s0,sp,80
    800021c2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021c4:	ee0ff0ef          	jal	800018a4 <myproc>
    800021c8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021ca:	0000e517          	auipc	a0,0xe
    800021ce:	83e50513          	addi	a0,a0,-1986 # 8000fa08 <wait_lock>
    800021d2:	9bffe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    800021d6:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    800021d8:	4a15                	li	s4,5
        havekids = 1;
    800021da:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021dc:	00014997          	auipc	s3,0x14
    800021e0:	c4498993          	addi	s3,s3,-956 # 80015e20 <tickslock>
    release(&wait_lock);
    800021e4:	0000eb97          	auipc	s7,0xe
    800021e8:	824b8b93          	addi	s7,s7,-2012 # 8000fa08 <wait_lock>
    800021ec:	a0e9                	j	800022b6 <kwait+0x10c>
          pid = pp->pid;
    800021ee:	0304a983          	lw	s3,48(s1)
          int turnaround = pp->etime - pp->ctime;
    800021f2:	1784a603          	lw	a2,376(s1)
    800021f6:	1744a783          	lw	a5,372(s1)
          printk("pid %d turnaround %d ticks\n", pp->pid, turnaround);
    800021fa:	9e1d                	subw	a2,a2,a5
    800021fc:	85ce                	mv	a1,s3
    800021fe:	00005517          	auipc	a0,0x5
    80002202:	02250513          	addi	a0,a0,34 # 80007220 <etext+0x220>
    80002206:	b04fe0ef          	jal	8000050a <printk>
          if (addr != 0 &&
    8000220a:	000b0e63          	beqz	s6,80002226 <kwait+0x7c>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    8000220e:	4711                	li	a4,4
    80002210:	02c48693          	addi	a3,s1,44
    80002214:	865a                	mv	a2,s6
    80002216:	04893583          	ld	a1,72(s2)
    8000221a:	05093503          	ld	a0,80(s2)
    8000221e:	abcff0ef          	jal	800014da <copyout>
          if (addr != 0 &&
    80002222:	02054d63          	bltz	a0,8000225c <kwait+0xb2>
          pp->parent = 0;
    80002226:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000222a:	8526                	mv	a0,s1
    8000222c:	853ff0ef          	jal	80001a7e <freeproc>
          release(&pp->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	9ebfe0ef          	jal	80000c1c <release>
          release(&wait_lock);
    80002236:	0000d517          	auipc	a0,0xd
    8000223a:	7d250513          	addi	a0,a0,2002 # 8000fa08 <wait_lock>
    8000223e:	9dffe0ef          	jal	80000c1c <release>
}
    80002242:	854e                	mv	a0,s3
    80002244:	60a6                	ld	ra,72(sp)
    80002246:	6406                	ld	s0,64(sp)
    80002248:	74e2                	ld	s1,56(sp)
    8000224a:	7942                	ld	s2,48(sp)
    8000224c:	79a2                	ld	s3,40(sp)
    8000224e:	7a02                	ld	s4,32(sp)
    80002250:	6ae2                	ld	s5,24(sp)
    80002252:	6b42                	ld	s6,16(sp)
    80002254:	6ba2                	ld	s7,8(sp)
    80002256:	6c02                	ld	s8,0(sp)
    80002258:	6161                	addi	sp,sp,80
    8000225a:	8082                	ret
            release(&pp->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	9bffe0ef          	jal	80000c1c <release>
            release(&wait_lock);
    80002262:	0000d517          	auipc	a0,0xd
    80002266:	7a650513          	addi	a0,a0,1958 # 8000fa08 <wait_lock>
    8000226a:	9b3fe0ef          	jal	80000c1c <release>
            return -1;
    8000226e:	59fd                	li	s3,-1
    80002270:	bfc9                	j	80002242 <kwait+0x98>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002272:	18048493          	addi	s1,s1,384
    80002276:	03348063          	beq	s1,s3,80002296 <kwait+0xec>
      if (pp->parent == p) {
    8000227a:	7c9c                	ld	a5,56(s1)
    8000227c:	ff279be3          	bne	a5,s2,80002272 <kwait+0xc8>
        acquire(&pp->lock);
    80002280:	8526                	mv	a0,s1
    80002282:	90ffe0ef          	jal	80000b90 <acquire>
        if (pp->state == ZOMBIE) {
    80002286:	4c9c                	lw	a5,24(s1)
    80002288:	f74783e3          	beq	a5,s4,800021ee <kwait+0x44>
        release(&pp->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	98ffe0ef          	jal	80000c1c <release>
        havekids = 1;
    80002292:	8756                	mv	a4,s5
    80002294:	bff9                	j	80002272 <kwait+0xc8>
    if (!havekids || killed(p)) {
    80002296:	c715                	beqz	a4,800022c2 <kwait+0x118>
    80002298:	854a                	mv	a0,s2
    8000229a:	ee7ff0ef          	jal	80002180 <killed>
    8000229e:	e115                	bnez	a0,800022c2 <kwait+0x118>
    sleep_prepare(p); //DOC: wait-sleep
    800022a0:	854a                	mv	a0,s2
    800022a2:	c7fff0ef          	jal	80001f20 <sleep_prepare>
    release(&wait_lock);
    800022a6:	855e                	mv	a0,s7
    800022a8:	975fe0ef          	jal	80000c1c <release>
    sleep();
    800022ac:	cb1ff0ef          	jal	80001f5c <sleep>
    acquire(&wait_lock);
    800022b0:	855e                	mv	a0,s7
    800022b2:	8dffe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    800022b6:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022b8:	0000e497          	auipc	s1,0xe
    800022bc:	b6848493          	addi	s1,s1,-1176 # 8000fe20 <proc>
    800022c0:	bf6d                	j	8000227a <kwait+0xd0>
      release(&wait_lock);
    800022c2:	0000d517          	auipc	a0,0xd
    800022c6:	74650513          	addi	a0,a0,1862 # 8000fa08 <wait_lock>
    800022ca:	953fe0ef          	jal	80000c1c <release>
      return -1;
    800022ce:	59fd                	li	s3,-1
    800022d0:	bf8d                	j	80002242 <kwait+0x98>

00000000800022d2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022d2:	7179                	addi	sp,sp,-48
    800022d4:	f406                	sd	ra,40(sp)
    800022d6:	f022                	sd	s0,32(sp)
    800022d8:	ec26                	sd	s1,24(sp)
    800022da:	e84a                	sd	s2,16(sp)
    800022dc:	e44e                	sd	s3,8(sp)
    800022de:	e052                	sd	s4,0(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	84aa                	mv	s1,a0
    800022e4:	892e                	mv	s2,a1
    800022e6:	89b2                	mv	s3,a2
    800022e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ea:	dbaff0ef          	jal	800018a4 <myproc>
  if (user_dst) {
    800022ee:	c085                	beqz	s1,8000230e <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800022f0:	8752                	mv	a4,s4
    800022f2:	86ce                	mv	a3,s3
    800022f4:	864a                	mv	a2,s2
    800022f6:	652c                	ld	a1,72(a0)
    800022f8:	6928                	ld	a0,80(a0)
    800022fa:	9e0ff0ef          	jal	800014da <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022fe:	70a2                	ld	ra,40(sp)
    80002300:	7402                	ld	s0,32(sp)
    80002302:	64e2                	ld	s1,24(sp)
    80002304:	6942                	ld	s2,16(sp)
    80002306:	69a2                	ld	s3,8(sp)
    80002308:	6a02                	ld	s4,0(sp)
    8000230a:	6145                	addi	sp,sp,48
    8000230c:	8082                	ret
    memmove((char *)dst, src, len);
    8000230e:	000a061b          	sext.w	a2,s4
    80002312:	85ce                	mv	a1,s3
    80002314:	854a                	mv	a0,s2
    80002316:	99bfe0ef          	jal	80000cb0 <memmove>
    return 0;
    8000231a:	8526                	mv	a0,s1
    8000231c:	b7cd                	j	800022fe <either_copyout+0x2c>

000000008000231e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000231e:	7179                	addi	sp,sp,-48
    80002320:	f406                	sd	ra,40(sp)
    80002322:	f022                	sd	s0,32(sp)
    80002324:	ec26                	sd	s1,24(sp)
    80002326:	e84a                	sd	s2,16(sp)
    80002328:	e44e                	sd	s3,8(sp)
    8000232a:	e052                	sd	s4,0(sp)
    8000232c:	1800                	addi	s0,sp,48
    8000232e:	892a                	mv	s2,a0
    80002330:	84ae                	mv	s1,a1
    80002332:	89b2                	mv	s3,a2
    80002334:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002336:	d6eff0ef          	jal	800018a4 <myproc>
  if (user_src) {
    8000233a:	c085                	beqz	s1,8000235a <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000233c:	8752                	mv	a4,s4
    8000233e:	86ce                	mv	a3,s3
    80002340:	864a                	mv	a2,s2
    80002342:	652c                	ld	a1,72(a0)
    80002344:	6928                	ld	a0,80(a0)
    80002346:	a80ff0ef          	jal	800015c6 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000234a:	70a2                	ld	ra,40(sp)
    8000234c:	7402                	ld	s0,32(sp)
    8000234e:	64e2                	ld	s1,24(sp)
    80002350:	6942                	ld	s2,16(sp)
    80002352:	69a2                	ld	s3,8(sp)
    80002354:	6a02                	ld	s4,0(sp)
    80002356:	6145                	addi	sp,sp,48
    80002358:	8082                	ret
    memmove(dst, (char *)src, len);
    8000235a:	000a061b          	sext.w	a2,s4
    8000235e:	85ce                	mv	a1,s3
    80002360:	854a                	mv	a0,s2
    80002362:	94ffe0ef          	jal	80000cb0 <memmove>
    return 0;
    80002366:	8526                	mv	a0,s1
    80002368:	b7cd                	j	8000234a <either_copyin+0x2c>

000000008000236a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000236a:	715d                	addi	sp,sp,-80
    8000236c:	e486                	sd	ra,72(sp)
    8000236e:	e0a2                	sd	s0,64(sp)
    80002370:	fc26                	sd	s1,56(sp)
    80002372:	f84a                	sd	s2,48(sp)
    80002374:	f44e                	sd	s3,40(sp)
    80002376:	f052                	sd	s4,32(sp)
    80002378:	ec56                	sd	s5,24(sp)
    8000237a:	e85a                	sd	s6,16(sp)
    8000237c:	e45e                	sd	s7,8(sp)
    8000237e:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002380:	00005517          	auipc	a0,0x5
    80002384:	cf850513          	addi	a0,a0,-776 # 80007078 <etext+0x78>
    80002388:	982fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000238c:	0000e497          	auipc	s1,0xe
    80002390:	bec48493          	addi	s1,s1,-1044 # 8000ff78 <proc+0x158>
    80002394:	00014917          	auipc	s2,0x14
    80002398:	be490913          	addi	s2,s2,-1052 # 80015f78 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000239c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000239e:	00005997          	auipc	s3,0x5
    800023a2:	ea298993          	addi	s3,s3,-350 # 80007240 <etext+0x240>
    printk("%d %s %s", p->pid, state, p->name);
    800023a6:	00005a97          	auipc	s5,0x5
    800023aa:	ea2a8a93          	addi	s5,s5,-350 # 80007248 <etext+0x248>
    printk("\n");
    800023ae:	00005a17          	auipc	s4,0x5
    800023b2:	ccaa0a13          	addi	s4,s4,-822 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b6:	00005b97          	auipc	s7,0x5
    800023ba:	3b2b8b93          	addi	s7,s7,946 # 80007768 <quantum>
    800023be:	a829                	j	800023d8 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800023c0:	ed86a583          	lw	a1,-296(a3)
    800023c4:	8556                	mv	a0,s5
    800023c6:	944fe0ef          	jal	8000050a <printk>
    printk("\n");
    800023ca:	8552                	mv	a0,s4
    800023cc:	93efe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023d0:	18048493          	addi	s1,s1,384
    800023d4:	03248263          	beq	s1,s2,800023f8 <procdump+0x8e>
    if (p->state == UNUSED)
    800023d8:	86a6                	mv	a3,s1
    800023da:	ec04a783          	lw	a5,-320(s1)
    800023de:	dbed                	beqz	a5,800023d0 <procdump+0x66>
      state = "???";
    800023e0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023e2:	fcfb6fe3          	bltu	s6,a5,800023c0 <procdump+0x56>
    800023e6:	02079713          	slli	a4,a5,0x20
    800023ea:	01d75793          	srli	a5,a4,0x1d
    800023ee:	97de                	add	a5,a5,s7
    800023f0:	6b90                	ld	a2,16(a5)
    800023f2:	f679                	bnez	a2,800023c0 <procdump+0x56>
      state = "???";
    800023f4:	864e                	mv	a2,s3
    800023f6:	b7e9                	j	800023c0 <procdump+0x56>
  }
}
    800023f8:	60a6                	ld	ra,72(sp)
    800023fa:	6406                	ld	s0,64(sp)
    800023fc:	74e2                	ld	s1,56(sp)
    800023fe:	7942                	ld	s2,48(sp)
    80002400:	79a2                	ld	s3,40(sp)
    80002402:	7a02                	ld	s4,32(sp)
    80002404:	6ae2                	ld	s5,24(sp)
    80002406:	6b42                	ld	s6,16(sp)
    80002408:	6ba2                	ld	s7,8(sp)
    8000240a:	6161                	addi	sp,sp,80
    8000240c:	8082                	ret

000000008000240e <count_active_procs>:


int
count_active_procs(void)
{
    8000240e:	7179                	addi	sp,sp,-48
    80002410:	f406                	sd	ra,40(sp)
    80002412:	f022                	sd	s0,32(sp)
    80002414:	ec26                	sd	s1,24(sp)
    80002416:	e84a                	sd	s2,16(sp)
    80002418:	e44e                	sd	s3,8(sp)
    8000241a:	1800                	addi	s0,sp,48
  struct proc *p;
  int count = 0;
    8000241c:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000241e:	0000e497          	auipc	s1,0xe
    80002422:	a0248493          	addi	s1,s1,-1534 # 8000fe20 <proc>
    80002426:	00014997          	auipc	s3,0x14
    8000242a:	9fa98993          	addi	s3,s3,-1542 # 80015e20 <tickslock>
    8000242e:	a801                	j	8000243e <count_active_procs+0x30>
    acquire(&p->lock);
    if(p->state != UNUSED) {
      count++;
    }
    release(&p->lock);
    80002430:	8526                	mv	a0,s1
    80002432:	feafe0ef          	jal	80000c1c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002436:	18048493          	addi	s1,s1,384
    8000243a:	01348963          	beq	s1,s3,8000244c <count_active_procs+0x3e>
    acquire(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	f50fe0ef          	jal	80000b90 <acquire>
    if(p->state != UNUSED) {
    80002444:	4c9c                	lw	a5,24(s1)
    80002446:	d7ed                	beqz	a5,80002430 <count_active_procs+0x22>
      count++;
    80002448:	2905                	addiw	s2,s2,1
    8000244a:	b7dd                	j	80002430 <count_active_procs+0x22>
  }
  return count;
    8000244c:	854a                	mv	a0,s2
    8000244e:	70a2                	ld	ra,40(sp)
    80002450:	7402                	ld	s0,32(sp)
    80002452:	64e2                	ld	s1,24(sp)
    80002454:	6942                	ld	s2,16(sp)
    80002456:	69a2                	ld	s3,8(sp)
    80002458:	6145                	addi	sp,sp,48
    8000245a:	8082                	ret

000000008000245c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000245c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002460:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002464:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002466:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002468:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000246c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002470:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002474:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002478:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000247c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002480:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002484:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002488:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000248c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002490:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002494:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002498:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000249a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000249c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024a0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024a4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024a8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024ac:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024b0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024b4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024b8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024bc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024c0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024c4:	8082                	ret

00000000800024c6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024c6:	1141                	addi	sp,sp,-16
    800024c8:	e406                	sd	ra,8(sp)
    800024ca:	e022                	sd	s0,0(sp)
    800024cc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024ce:	00005597          	auipc	a1,0x5
    800024d2:	dba58593          	addi	a1,a1,-582 # 80007288 <etext+0x288>
    800024d6:	00014517          	auipc	a0,0x14
    800024da:	94a50513          	addi	a0,a0,-1718 # 80015e20 <tickslock>
    800024de:	e3cfe0ef          	jal	80000b1a <initlock>
}
    800024e2:	60a2                	ld	ra,8(sp)
    800024e4:	6402                	ld	s0,0(sp)
    800024e6:	0141                	addi	sp,sp,16
    800024e8:	8082                	ret

00000000800024ea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024ea:	1141                	addi	sp,sp,-16
    800024ec:	e422                	sd	s0,8(sp)
    800024ee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024f0:	00003797          	auipc	a5,0x3
    800024f4:	1d078793          	addi	a5,a5,464 # 800056c0 <kernelvec>
    800024f8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024fc:	6422                	ld	s0,8(sp)
    800024fe:	0141                	addi	sp,sp,16
    80002500:	8082                	ret

0000000080002502 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002502:	1141                	addi	sp,sp,-16
    80002504:	e406                	sd	ra,8(sp)
    80002506:	e022                	sd	s0,0(sp)
    80002508:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000250a:	b9aff0ef          	jal	800018a4 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000250e:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002512:	04000737          	lui	a4,0x4000
    80002516:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002518:	0732                	slli	a4,a4,0xc
    8000251a:	00004797          	auipc	a5,0x4
    8000251e:	ae678793          	addi	a5,a5,-1306 # 80006000 <_trampoline>
    80002522:	00004697          	auipc	a3,0x4
    80002526:	ade68693          	addi	a3,a3,-1314 # 80006000 <_trampoline>
    8000252a:	8f95                	sub	a5,a5,a3
    8000252c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000252e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002532:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002534:	18002773          	csrr	a4,satp
    80002538:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000253a:	6d38                	ld	a4,88(a0)
    8000253c:	613c                	ld	a5,64(a0)
    8000253e:	6685                	lui	a3,0x1
    80002540:	97b6                	add	a5,a5,a3
    80002542:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002544:	6d3c                	ld	a5,88(a0)
    80002546:	00000717          	auipc	a4,0x0
    8000254a:	0f870713          	addi	a4,a4,248 # 8000263e <usertrap>
    8000254e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002550:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002552:	8712                	mv	a4,tp
    80002554:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002556:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000255a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000255e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002562:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002566:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002568:	6f9c                	ld	a5,24(a5)
    8000256a:	14179073          	csrw	sepc,a5
}
    8000256e:	60a2                	ld	ra,8(sp)
    80002570:	6402                	ld	s0,0(sp)
    80002572:	0141                	addi	sp,sp,16
    80002574:	8082                	ret

0000000080002576 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002576:	1101                	addi	sp,sp,-32
    80002578:	ec06                	sd	ra,24(sp)
    8000257a:	e822                	sd	s0,16(sp)
    8000257c:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    8000257e:	afaff0ef          	jal	80001878 <cpuid>
    80002582:	cd11                	beqz	a0,8000259e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002584:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002588:	000f4737          	lui	a4,0xf4
    8000258c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002590:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002592:	14d79073          	csrw	stimecmp,a5
}
    80002596:	60e2                	ld	ra,24(sp)
    80002598:	6442                	ld	s0,16(sp)
    8000259a:	6105                	addi	sp,sp,32
    8000259c:	8082                	ret
    8000259e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800025a0:	00014497          	auipc	s1,0x14
    800025a4:	88048493          	addi	s1,s1,-1920 # 80015e20 <tickslock>
    800025a8:	8526                	mv	a0,s1
    800025aa:	de6fe0ef          	jal	80000b90 <acquire>
    ticks++;
    800025ae:	00005517          	auipc	a0,0x5
    800025b2:	32250513          	addi	a0,a0,802 # 800078d0 <ticks>
    800025b6:	411c                	lw	a5,0(a0)
    800025b8:	2785                	addiw	a5,a5,1
    800025ba:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800025bc:	9d1ff0ef          	jal	80001f8c <wakeup>
    release(&tickslock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	e5afe0ef          	jal	80000c1c <release>
    800025c6:	64a2                	ld	s1,8(sp)
    800025c8:	bf75                	j	80002584 <clockintr+0xe>

00000000800025ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025ca:	1101                	addi	sp,sp,-32
    800025cc:	ec06                	sd	ra,24(sp)
    800025ce:	e822                	sd	s0,16(sp)
    800025d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800025d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800025d6:	57fd                	li	a5,-1
    800025d8:	17fe                	slli	a5,a5,0x3f
    800025da:	07a5                	addi	a5,a5,9
    800025dc:	00f70c63          	beq	a4,a5,800025f4 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800025e0:	57fd                	li	a5,-1
    800025e2:	17fe                	slli	a5,a5,0x3f
    800025e4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025e6:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800025e8:	04f70763          	beq	a4,a5,80002636 <devintr+0x6c>
  }
}
    800025ec:	60e2                	ld	ra,24(sp)
    800025ee:	6442                	ld	s0,16(sp)
    800025f0:	6105                	addi	sp,sp,32
    800025f2:	8082                	ret
    800025f4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025f6:	176030ef          	jal	8000576c <plic_claim>
    800025fa:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800025fc:	47a9                	li	a5,10
    800025fe:	00f50963          	beq	a0,a5,80002610 <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    80002602:	4785                	li	a5,1
    80002604:	00f50963          	beq	a0,a5,80002616 <devintr+0x4c>
    return 1;
    80002608:	4505                	li	a0,1
    } else if (irq) {
    8000260a:	e889                	bnez	s1,8000261c <devintr+0x52>
    8000260c:	64a2                	ld	s1,8(sp)
    8000260e:	bff9                	j	800025ec <devintr+0x22>
      uartintr();
    80002610:	b7cfe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002614:	a819                	j	8000262a <devintr+0x60>
      virtio_disk_intr();
    80002616:	63a030ef          	jal	80005c50 <virtio_disk_intr>
    if (irq)
    8000261a:	a801                	j	8000262a <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    8000261c:	85a6                	mv	a1,s1
    8000261e:	00005517          	auipc	a0,0x5
    80002622:	c7250513          	addi	a0,a0,-910 # 80007290 <etext+0x290>
    80002626:	ee5fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000262a:	8526                	mv	a0,s1
    8000262c:	160030ef          	jal	8000578c <plic_complete>
    return 1;
    80002630:	4505                	li	a0,1
    80002632:	64a2                	ld	s1,8(sp)
    80002634:	bf65                	j	800025ec <devintr+0x22>
    clockintr();
    80002636:	f41ff0ef          	jal	80002576 <clockintr>
    return 2;
    8000263a:	4509                	li	a0,2
    8000263c:	bf45                	j	800025ec <devintr+0x22>

000000008000263e <usertrap>:
{
    8000263e:	1101                	addi	sp,sp,-32
    80002640:	ec06                	sd	ra,24(sp)
    80002642:	e822                	sd	s0,16(sp)
    80002644:	e426                	sd	s1,8(sp)
    80002646:	e04a                	sd	s2,0(sp)
    80002648:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000264a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000264e:	1007f793          	andi	a5,a5,256
    80002652:	eba5                	bnez	a5,800026c2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002654:	00003797          	auipc	a5,0x3
    80002658:	06c78793          	addi	a5,a5,108 # 800056c0 <kernelvec>
    8000265c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002660:	a44ff0ef          	jal	800018a4 <myproc>
    80002664:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002666:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002668:	14102773          	csrr	a4,sepc
    8000266c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000266e:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002672:	47a1                	li	a5,8
    80002674:	04f70d63          	beq	a4,a5,800026ce <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002678:	f53ff0ef          	jal	800025ca <devintr>
    8000267c:	892a                	mv	s2,a0
    8000267e:	e54d                	bnez	a0,80002728 <usertrap+0xea>
    80002680:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002684:	47bd                	li	a5,15
    80002686:	08f70463          	beq	a4,a5,8000270e <usertrap+0xd0>
    8000268a:	14202773          	csrr	a4,scause
    8000268e:	47b5                	li	a5,13
    80002690:	06f70f63          	beq	a4,a5,8000270e <usertrap+0xd0>
    80002694:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002698:	5890                	lw	a2,48(s1)
    8000269a:	00005517          	auipc	a0,0x5
    8000269e:	c3650513          	addi	a0,a0,-970 # 800072d0 <etext+0x2d0>
    800026a2:	e69fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026a6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026aa:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026ae:	00005517          	auipc	a0,0x5
    800026b2:	c5250513          	addi	a0,a0,-942 # 80007300 <etext+0x300>
    800026b6:	e55fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800026ba:	8526                	mv	a0,s1
    800026bc:	aa1ff0ef          	jal	8000215c <setkilled>
    800026c0:	a015                	j	800026e4 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800026c2:	00005517          	auipc	a0,0x5
    800026c6:	bee50513          	addi	a0,a0,-1042 # 800072b0 <etext+0x2b0>
    800026ca:	926fe0ef          	jal	800007f0 <panic>
    if (killed(p))
    800026ce:	ab3ff0ef          	jal	80002180 <killed>
    800026d2:	e915                	bnez	a0,80002706 <usertrap+0xc8>
    p->trapframe->epc += 4;
    800026d4:	6cb8                	ld	a4,88(s1)
    800026d6:	6f1c                	ld	a5,24(a4)
    800026d8:	0791                	addi	a5,a5,4
    800026da:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800026dc:	10016073          	csrsi	sstatus,2
    syscall();
    800026e0:	24a000ef          	jal	8000292a <syscall>
  if (killed(p))
    800026e4:	8526                	mv	a0,s1
    800026e6:	a9bff0ef          	jal	80002180 <killed>
    800026ea:	e521                	bnez	a0,80002732 <usertrap+0xf4>
  prepare_return();
    800026ec:	e17ff0ef          	jal	80002502 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026f0:	68a8                	ld	a0,80(s1)
    800026f2:	8131                	srli	a0,a0,0xc
    800026f4:	57fd                	li	a5,-1
    800026f6:	17fe                	slli	a5,a5,0x3f
    800026f8:	8d5d                	or	a0,a0,a5
}
    800026fa:	60e2                	ld	ra,24(sp)
    800026fc:	6442                	ld	s0,16(sp)
    800026fe:	64a2                	ld	s1,8(sp)
    80002700:	6902                	ld	s2,0(sp)
    80002702:	6105                	addi	sp,sp,32
    80002704:	8082                	ret
      kexit(-1);
    80002706:	557d                	li	a0,-1
    80002708:	941ff0ef          	jal	80002048 <kexit>
    8000270c:	b7e1                	j	800026d4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000270e:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002712:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002716:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002718:	0016b693          	seqz	a3,a3
    8000271c:	64ac                	ld	a1,72(s1)
    8000271e:	68a8                	ld	a0,80(s1)
    80002720:	d3ffe0ef          	jal	8000145e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002724:	f161                	bnez	a0,800026e4 <usertrap+0xa6>
    80002726:	b7bd                	j	80002694 <usertrap+0x56>
  if (killed(p))
    80002728:	8526                	mv	a0,s1
    8000272a:	a57ff0ef          	jal	80002180 <killed>
    8000272e:	c511                	beqz	a0,8000273a <usertrap+0xfc>
    80002730:	a011                	j	80002734 <usertrap+0xf6>
    80002732:	4901                	li	s2,0
    kexit(-1);
    80002734:	557d                	li	a0,-1
    80002736:	913ff0ef          	jal	80002048 <kexit>
  if (which_dev == 2)
    8000273a:	4789                	li	a5,2
    8000273c:	faf918e3          	bne	s2,a5,800026ec <usertrap+0xae>
    yield();
    80002740:	fb4ff0ef          	jal	80001ef4 <yield>
    80002744:	b765                	j	800026ec <usertrap+0xae>

0000000080002746 <kerneltrap>:
{
    80002746:	7179                	addi	sp,sp,-48
    80002748:	f406                	sd	ra,40(sp)
    8000274a:	f022                	sd	s0,32(sp)
    8000274c:	ec26                	sd	s1,24(sp)
    8000274e:	e84a                	sd	s2,16(sp)
    80002750:	e44e                	sd	s3,8(sp)
    80002752:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002754:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002758:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000275c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002760:	1004f793          	andi	a5,s1,256
    80002764:	c795                	beqz	a5,80002790 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002766:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000276a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000276c:	eb85                	bnez	a5,8000279c <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    8000276e:	e5dff0ef          	jal	800025ca <devintr>
    80002772:	c91d                	beqz	a0,800027a8 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002774:	4789                	li	a5,2
    80002776:	04f50a63          	beq	a0,a5,800027ca <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000277a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000277e:	10049073          	csrw	sstatus,s1
}
    80002782:	70a2                	ld	ra,40(sp)
    80002784:	7402                	ld	s0,32(sp)
    80002786:	64e2                	ld	s1,24(sp)
    80002788:	6942                	ld	s2,16(sp)
    8000278a:	69a2                	ld	s3,8(sp)
    8000278c:	6145                	addi	sp,sp,48
    8000278e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002790:	00005517          	auipc	a0,0x5
    80002794:	b9850513          	addi	a0,a0,-1128 # 80007328 <etext+0x328>
    80002798:	858fe0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000279c:	00005517          	auipc	a0,0x5
    800027a0:	bb450513          	addi	a0,a0,-1100 # 80007350 <etext+0x350>
    800027a4:	84cfe0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027a8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027ac:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027b0:	85ce                	mv	a1,s3
    800027b2:	00005517          	auipc	a0,0x5
    800027b6:	bbe50513          	addi	a0,a0,-1090 # 80007370 <etext+0x370>
    800027ba:	d51fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027be:	00005517          	auipc	a0,0x5
    800027c2:	bda50513          	addi	a0,a0,-1062 # 80007398 <etext+0x398>
    800027c6:	82afe0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    800027ca:	8daff0ef          	jal	800018a4 <myproc>
    800027ce:	d555                	beqz	a0,8000277a <kerneltrap+0x34>
    yield();
    800027d0:	f24ff0ef          	jal	80001ef4 <yield>
    800027d4:	b75d                	j	8000277a <kerneltrap+0x34>

00000000800027d6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027d6:	1101                	addi	sp,sp,-32
    800027d8:	ec06                	sd	ra,24(sp)
    800027da:	e822                	sd	s0,16(sp)
    800027dc:	e426                	sd	s1,8(sp)
    800027de:	1000                	addi	s0,sp,32
    800027e0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027e2:	8c2ff0ef          	jal	800018a4 <myproc>
  switch (n) {
    800027e6:	4795                	li	a5,5
    800027e8:	0497e163          	bltu	a5,s1,8000282a <argraw+0x54>
    800027ec:	048a                	slli	s1,s1,0x2
    800027ee:	00005717          	auipc	a4,0x5
    800027f2:	fba70713          	addi	a4,a4,-70 # 800077a8 <states.0+0x30>
    800027f6:	94ba                	add	s1,s1,a4
    800027f8:	409c                	lw	a5,0(s1)
    800027fa:	97ba                	add	a5,a5,a4
    800027fc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027fe:	6d3c                	ld	a5,88(a0)
    80002800:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002802:	60e2                	ld	ra,24(sp)
    80002804:	6442                	ld	s0,16(sp)
    80002806:	64a2                	ld	s1,8(sp)
    80002808:	6105                	addi	sp,sp,32
    8000280a:	8082                	ret
    return p->trapframe->a1;
    8000280c:	6d3c                	ld	a5,88(a0)
    8000280e:	7fa8                	ld	a0,120(a5)
    80002810:	bfcd                	j	80002802 <argraw+0x2c>
    return p->trapframe->a2;
    80002812:	6d3c                	ld	a5,88(a0)
    80002814:	63c8                	ld	a0,128(a5)
    80002816:	b7f5                	j	80002802 <argraw+0x2c>
    return p->trapframe->a3;
    80002818:	6d3c                	ld	a5,88(a0)
    8000281a:	67c8                	ld	a0,136(a5)
    8000281c:	b7dd                	j	80002802 <argraw+0x2c>
    return p->trapframe->a4;
    8000281e:	6d3c                	ld	a5,88(a0)
    80002820:	6bc8                	ld	a0,144(a5)
    80002822:	b7c5                	j	80002802 <argraw+0x2c>
    return p->trapframe->a5;
    80002824:	6d3c                	ld	a5,88(a0)
    80002826:	6fc8                	ld	a0,152(a5)
    80002828:	bfe9                	j	80002802 <argraw+0x2c>
  panic("argraw");
    8000282a:	00005517          	auipc	a0,0x5
    8000282e:	b7e50513          	addi	a0,a0,-1154 # 800073a8 <etext+0x3a8>
    80002832:	fbffd0ef          	jal	800007f0 <panic>

0000000080002836 <fetchaddr>:
{
    80002836:	1101                	addi	sp,sp,-32
    80002838:	ec06                	sd	ra,24(sp)
    8000283a:	e822                	sd	s0,16(sp)
    8000283c:	e426                	sd	s1,8(sp)
    8000283e:	e04a                	sd	s2,0(sp)
    80002840:	1000                	addi	s0,sp,32
    80002842:	84aa                	mv	s1,a0
    80002844:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002846:	85eff0ef          	jal	800018a4 <myproc>
  if (addr >= p->sz ||
    8000284a:	652c                	ld	a1,72(a0)
    8000284c:	02b4f663          	bgeu	s1,a1,80002878 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002850:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002854:	02f5e463          	bltu	a1,a5,8000287c <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002858:	4721                	li	a4,8
    8000285a:	86a6                	mv	a3,s1
    8000285c:	864a                	mv	a2,s2
    8000285e:	6928                	ld	a0,80(a0)
    80002860:	d67fe0ef          	jal	800015c6 <copyin>
    80002864:	00a03533          	snez	a0,a0
    80002868:	40a00533          	neg	a0,a0
}
    8000286c:	60e2                	ld	ra,24(sp)
    8000286e:	6442                	ld	s0,16(sp)
    80002870:	64a2                	ld	s1,8(sp)
    80002872:	6902                	ld	s2,0(sp)
    80002874:	6105                	addi	sp,sp,32
    80002876:	8082                	ret
    return -1;
    80002878:	557d                	li	a0,-1
    8000287a:	bfcd                	j	8000286c <fetchaddr+0x36>
    8000287c:	557d                	li	a0,-1
    8000287e:	b7fd                	j	8000286c <fetchaddr+0x36>

0000000080002880 <fetchstr>:
{
    80002880:	7179                	addi	sp,sp,-48
    80002882:	f406                	sd	ra,40(sp)
    80002884:	f022                	sd	s0,32(sp)
    80002886:	ec26                	sd	s1,24(sp)
    80002888:	e84a                	sd	s2,16(sp)
    8000288a:	e44e                	sd	s3,8(sp)
    8000288c:	1800                	addi	s0,sp,48
    8000288e:	892a                	mv	s2,a0
    80002890:	84ae                	mv	s1,a1
    80002892:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002894:	810ff0ef          	jal	800018a4 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002898:	874e                	mv	a4,s3
    8000289a:	86ca                	mv	a3,s2
    8000289c:	8626                	mv	a2,s1
    8000289e:	652c                	ld	a1,72(a0)
    800028a0:	6928                	ld	a0,80(a0)
    800028a2:	dbbfe0ef          	jal	8000165c <copyinstr>
    800028a6:	00054c63          	bltz	a0,800028be <fetchstr+0x3e>
  return strlen(buf);
    800028aa:	8526                	mv	a0,s1
    800028ac:	d18fe0ef          	jal	80000dc4 <strlen>
}
    800028b0:	70a2                	ld	ra,40(sp)
    800028b2:	7402                	ld	s0,32(sp)
    800028b4:	64e2                	ld	s1,24(sp)
    800028b6:	6942                	ld	s2,16(sp)
    800028b8:	69a2                	ld	s3,8(sp)
    800028ba:	6145                	addi	sp,sp,48
    800028bc:	8082                	ret
    return -1;
    800028be:	557d                	li	a0,-1
    800028c0:	bfc5                	j	800028b0 <fetchstr+0x30>

00000000800028c2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028c2:	1101                	addi	sp,sp,-32
    800028c4:	ec06                	sd	ra,24(sp)
    800028c6:	e822                	sd	s0,16(sp)
    800028c8:	e426                	sd	s1,8(sp)
    800028ca:	1000                	addi	s0,sp,32
    800028cc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028ce:	f09ff0ef          	jal	800027d6 <argraw>
    800028d2:	c088                	sw	a0,0(s1)
}
    800028d4:	60e2                	ld	ra,24(sp)
    800028d6:	6442                	ld	s0,16(sp)
    800028d8:	64a2                	ld	s1,8(sp)
    800028da:	6105                	addi	sp,sp,32
    800028dc:	8082                	ret

00000000800028de <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028de:	1101                	addi	sp,sp,-32
    800028e0:	ec06                	sd	ra,24(sp)
    800028e2:	e822                	sd	s0,16(sp)
    800028e4:	e426                	sd	s1,8(sp)
    800028e6:	1000                	addi	s0,sp,32
    800028e8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028ea:	eedff0ef          	jal	800027d6 <argraw>
    800028ee:	e088                	sd	a0,0(s1)
}
    800028f0:	60e2                	ld	ra,24(sp)
    800028f2:	6442                	ld	s0,16(sp)
    800028f4:	64a2                	ld	s1,8(sp)
    800028f6:	6105                	addi	sp,sp,32
    800028f8:	8082                	ret

00000000800028fa <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028fa:	7179                	addi	sp,sp,-48
    800028fc:	f406                	sd	ra,40(sp)
    800028fe:	f022                	sd	s0,32(sp)
    80002900:	ec26                	sd	s1,24(sp)
    80002902:	e84a                	sd	s2,16(sp)
    80002904:	1800                	addi	s0,sp,48
    80002906:	84ae                	mv	s1,a1
    80002908:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000290a:	fd840593          	addi	a1,s0,-40
    8000290e:	fd1ff0ef          	jal	800028de <argaddr>
  return fetchstr(addr, buf, max);
    80002912:	864a                	mv	a2,s2
    80002914:	85a6                	mv	a1,s1
    80002916:	fd843503          	ld	a0,-40(s0)
    8000291a:	f67ff0ef          	jal	80002880 <fetchstr>
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	6145                	addi	sp,sp,48
    80002928:	8082                	ret

000000008000292a <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	e426                	sd	s1,8(sp)
    80002932:	e04a                	sd	s2,0(sp)
    80002934:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002936:	f6ffe0ef          	jal	800018a4 <myproc>
    8000293a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000293c:	05853903          	ld	s2,88(a0)
    80002940:	0a893783          	ld	a5,168(s2)
    80002944:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002948:	37fd                	addiw	a5,a5,-1
    8000294a:	4765                	li	a4,25
    8000294c:	00f76f63          	bltu	a4,a5,8000296a <syscall+0x40>
    80002950:	00369713          	slli	a4,a3,0x3
    80002954:	00005797          	auipc	a5,0x5
    80002958:	e6c78793          	addi	a5,a5,-404 # 800077c0 <syscalls>
    8000295c:	97ba                	add	a5,a5,a4
    8000295e:	639c                	ld	a5,0(a5)
    80002960:	c789                	beqz	a5,8000296a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002962:	9782                	jalr	a5
    80002964:	06a93823          	sd	a0,112(s2)
    80002968:	a829                	j	80002982 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    8000296a:	15848613          	addi	a2,s1,344
    8000296e:	588c                	lw	a1,48(s1)
    80002970:	00005517          	auipc	a0,0x5
    80002974:	a4050513          	addi	a0,a0,-1472 # 800073b0 <etext+0x3b0>
    80002978:	b93fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    8000297c:	6cbc                	ld	a5,88(s1)
    8000297e:	577d                	li	a4,-1
    80002980:	fbb8                	sd	a4,112(a5)
  }
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6902                	ld	s2,0(sp)
    8000298a:	6105                	addi	sp,sp,32
    8000298c:	8082                	ret

000000008000298e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000298e:	1101                	addi	sp,sp,-32
    80002990:	ec06                	sd	ra,24(sp)
    80002992:	e822                	sd	s0,16(sp)
    80002994:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002996:	fec40593          	addi	a1,s0,-20
    8000299a:	4501                	li	a0,0
    8000299c:	f27ff0ef          	jal	800028c2 <argint>
  kexit(n);
    800029a0:	fec42503          	lw	a0,-20(s0)
    800029a4:	ea4ff0ef          	jal	80002048 <kexit>
  return 0; // not reached
}
    800029a8:	4501                	li	a0,0
    800029aa:	60e2                	ld	ra,24(sp)
    800029ac:	6442                	ld	s0,16(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret

00000000800029b2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029b2:	1141                	addi	sp,sp,-16
    800029b4:	e406                	sd	ra,8(sp)
    800029b6:	e022                	sd	s0,0(sp)
    800029b8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029ba:	eebfe0ef          	jal	800018a4 <myproc>
}
    800029be:	5908                	lw	a0,48(a0)
    800029c0:	60a2                	ld	ra,8(sp)
    800029c2:	6402                	ld	s0,0(sp)
    800029c4:	0141                	addi	sp,sp,16
    800029c6:	8082                	ret

00000000800029c8 <sys_fork>:

uint64
sys_fork(void)
{
    800029c8:	1141                	addi	sp,sp,-16
    800029ca:	e406                	sd	ra,8(sp)
    800029cc:	e022                	sd	s0,0(sp)
    800029ce:	0800                	addi	s0,sp,16
  return kfork();
    800029d0:	a62ff0ef          	jal	80001c32 <kfork>
}
    800029d4:	60a2                	ld	ra,8(sp)
    800029d6:	6402                	ld	s0,0(sp)
    800029d8:	0141                	addi	sp,sp,16
    800029da:	8082                	ret

00000000800029dc <sys_wait>:

uint64
sys_wait(void)
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029e4:	fe840593          	addi	a1,s0,-24
    800029e8:	4501                	li	a0,0
    800029ea:	ef5ff0ef          	jal	800028de <argaddr>
  return kwait(p);
    800029ee:	fe843503          	ld	a0,-24(s0)
    800029f2:	fb8ff0ef          	jal	800021aa <kwait>
}
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret

00000000800029fe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029fe:	7179                	addi	sp,sp,-48
    80002a00:	f406                	sd	ra,40(sp)
    80002a02:	f022                	sd	s0,32(sp)
    80002a04:	ec26                	sd	s1,24(sp)
    80002a06:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a08:	fd840593          	addi	a1,s0,-40
    80002a0c:	4501                	li	a0,0
    80002a0e:	eb5ff0ef          	jal	800028c2 <argint>
  argint(1, &t);
    80002a12:	fdc40593          	addi	a1,s0,-36
    80002a16:	4505                	li	a0,1
    80002a18:	eabff0ef          	jal	800028c2 <argint>
  addr = myproc()->sz;
    80002a1c:	e89fe0ef          	jal	800018a4 <myproc>
    80002a20:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a22:	fdc42703          	lw	a4,-36(s0)
    80002a26:	4785                	li	a5,1
    80002a28:	02f70763          	beq	a4,a5,80002a56 <sys_sbrk+0x58>
    80002a2c:	fd842783          	lw	a5,-40(s0)
    80002a30:	0207c363          	bltz	a5,80002a56 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a34:	97a6                	add	a5,a5,s1
    80002a36:	0297ee63          	bltu	a5,s1,80002a72 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    80002a3a:	02000737          	lui	a4,0x2000
    80002a3e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a40:	0736                	slli	a4,a4,0xd
    80002a42:	02f76a63          	bltu	a4,a5,80002a76 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002a46:	e5ffe0ef          	jal	800018a4 <myproc>
    80002a4a:	fd842703          	lw	a4,-40(s0)
    80002a4e:	653c                	ld	a5,72(a0)
    80002a50:	97ba                	add	a5,a5,a4
    80002a52:	e53c                	sd	a5,72(a0)
    80002a54:	a039                	j	80002a62 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a56:	fd842503          	lw	a0,-40(s0)
    80002a5a:	976ff0ef          	jal	80001bd0 <growproc>
    80002a5e:	00054863          	bltz	a0,80002a6e <sys_sbrk+0x70>
  }
  return addr;
}
    80002a62:	8526                	mv	a0,s1
    80002a64:	70a2                	ld	ra,40(sp)
    80002a66:	7402                	ld	s0,32(sp)
    80002a68:	64e2                	ld	s1,24(sp)
    80002a6a:	6145                	addi	sp,sp,48
    80002a6c:	8082                	ret
      return -1;
    80002a6e:	54fd                	li	s1,-1
    80002a70:	bfcd                	j	80002a62 <sys_sbrk+0x64>
      return -1;
    80002a72:	54fd                	li	s1,-1
    80002a74:	b7fd                	j	80002a62 <sys_sbrk+0x64>
      return -1;
    80002a76:	54fd                	li	s1,-1
    80002a78:	b7ed                	j	80002a62 <sys_sbrk+0x64>

0000000080002a7a <sys_pause>:

uint64
sys_pause(void)
{
    80002a7a:	7139                	addi	sp,sp,-64
    80002a7c:	fc06                	sd	ra,56(sp)
    80002a7e:	f822                	sd	s0,48(sp)
    80002a80:	ec4e                	sd	s3,24(sp)
    80002a82:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a84:	fcc40593          	addi	a1,s0,-52
    80002a88:	4501                	li	a0,0
    80002a8a:	e39ff0ef          	jal	800028c2 <argint>
  if (n < 0)
    80002a8e:	fcc42783          	lw	a5,-52(s0)
    80002a92:	0607cf63          	bltz	a5,80002b10 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a96:	00013517          	auipc	a0,0x13
    80002a9a:	38a50513          	addi	a0,a0,906 # 80015e20 <tickslock>
    80002a9e:	8f2fe0ef          	jal	80000b90 <acquire>
  ticks0 = ticks;
    80002aa2:	00005997          	auipc	s3,0x5
    80002aa6:	e2e9a983          	lw	s3,-466(s3) # 800078d0 <ticks>
  while (ticks - ticks0 < n) {
    80002aaa:	fcc42783          	lw	a5,-52(s0)
    80002aae:	c7a9                	beqz	a5,80002af8 <sys_pause+0x7e>
    80002ab0:	f426                	sd	s1,40(sp)
    80002ab2:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002ab4:	00005917          	auipc	s2,0x5
    80002ab8:	e1c90913          	addi	s2,s2,-484 # 800078d0 <ticks>
    release(&tickslock);
    80002abc:	00013497          	auipc	s1,0x13
    80002ac0:	36448493          	addi	s1,s1,868 # 80015e20 <tickslock>
    if (killed(myproc())) {
    80002ac4:	de1fe0ef          	jal	800018a4 <myproc>
    80002ac8:	eb8ff0ef          	jal	80002180 <killed>
    80002acc:	e529                	bnez	a0,80002b16 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002ace:	854a                	mv	a0,s2
    80002ad0:	c50ff0ef          	jal	80001f20 <sleep_prepare>
    release(&tickslock);
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	946fe0ef          	jal	80000c1c <release>
    sleep();
    80002ada:	c82ff0ef          	jal	80001f5c <sleep>
    acquire(&tickslock);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	8b0fe0ef          	jal	80000b90 <acquire>
  while (ticks - ticks0 < n) {
    80002ae4:	00092783          	lw	a5,0(s2)
    80002ae8:	413787bb          	subw	a5,a5,s3
    80002aec:	fcc42703          	lw	a4,-52(s0)
    80002af0:	fce7eae3          	bltu	a5,a4,80002ac4 <sys_pause+0x4a>
    80002af4:	74a2                	ld	s1,40(sp)
    80002af6:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002af8:	00013517          	auipc	a0,0x13
    80002afc:	32850513          	addi	a0,a0,808 # 80015e20 <tickslock>
    80002b00:	91cfe0ef          	jal	80000c1c <release>
  return 0;
    80002b04:	4501                	li	a0,0
}
    80002b06:	70e2                	ld	ra,56(sp)
    80002b08:	7442                	ld	s0,48(sp)
    80002b0a:	69e2                	ld	s3,24(sp)
    80002b0c:	6121                	addi	sp,sp,64
    80002b0e:	8082                	ret
    n = 0;
    80002b10:	fc042623          	sw	zero,-52(s0)
    80002b14:	b749                	j	80002a96 <sys_pause+0x1c>
      release(&tickslock);
    80002b16:	00013517          	auipc	a0,0x13
    80002b1a:	30a50513          	addi	a0,a0,778 # 80015e20 <tickslock>
    80002b1e:	8fefe0ef          	jal	80000c1c <release>
      return -1;
    80002b22:	557d                	li	a0,-1
    80002b24:	74a2                	ld	s1,40(sp)
    80002b26:	7902                	ld	s2,32(sp)
    80002b28:	bff9                	j	80002b06 <sys_pause+0x8c>

0000000080002b2a <sys_kill>:

uint64
sys_kill(void)
{
    80002b2a:	1101                	addi	sp,sp,-32
    80002b2c:	ec06                	sd	ra,24(sp)
    80002b2e:	e822                	sd	s0,16(sp)
    80002b30:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b32:	fec40593          	addi	a1,s0,-20
    80002b36:	4501                	li	a0,0
    80002b38:	d8bff0ef          	jal	800028c2 <argint>
  return kkill(pid);
    80002b3c:	fec42503          	lw	a0,-20(s0)
    80002b40:	db6ff0ef          	jal	800020f6 <kkill>
}
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b4c:	1101                	addi	sp,sp,-32
    80002b4e:	ec06                	sd	ra,24(sp)
    80002b50:	e822                	sd	s0,16(sp)
    80002b52:	e426                	sd	s1,8(sp)
    80002b54:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b56:	00013517          	auipc	a0,0x13
    80002b5a:	2ca50513          	addi	a0,a0,714 # 80015e20 <tickslock>
    80002b5e:	832fe0ef          	jal	80000b90 <acquire>
  xticks = ticks;
    80002b62:	00005497          	auipc	s1,0x5
    80002b66:	d6e4a483          	lw	s1,-658(s1) # 800078d0 <ticks>
  release(&tickslock);
    80002b6a:	00013517          	auipc	a0,0x13
    80002b6e:	2b650513          	addi	a0,a0,694 # 80015e20 <tickslock>
    80002b72:	8aafe0ef          	jal	80000c1c <release>
  return xticks;
}
    80002b76:	02049513          	slli	a0,s1,0x20
    80002b7a:	9101                	srli	a0,a0,0x20
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6105                	addi	sp,sp,32
    80002b84:	8082                	ret

0000000080002b86 <sys_cpustats>:

uint64
sys_cpustats(void)
{
    80002b86:	7179                	addi	sp,sp,-48
    80002b88:	f406                	sd	ra,40(sp)
    80002b8a:	f022                	sd	s0,32(sp)
    80002b8c:	ec26                	sd	s1,24(sp)
    80002b8e:	1800                	addi	s0,sp,48
  uint64 addr;
  struct cpustats st;
  struct proc *p = myproc();
    80002b90:	d15fe0ef          	jal	800018a4 <myproc>
    80002b94:	84aa                	mv	s1,a0

  argaddr(0, &addr);
    80002b96:	fd840593          	addi	a1,s0,-40
    80002b9a:	4501                	li	a0,0
    80002b9c:	d43ff0ef          	jal	800028de <argaddr>

  st.nproc = count_active_procs();
    80002ba0:	86fff0ef          	jal	8000240e <count_active_procs>
    80002ba4:	fca42823          	sw	a0,-48(s0)
  acquire(&tickslock);
    80002ba8:	00013517          	auipc	a0,0x13
    80002bac:	27850513          	addi	a0,a0,632 # 80015e20 <tickslock>
    80002bb0:	fe1fd0ef          	jal	80000b90 <acquire>
  st.ticks = ticks;
    80002bb4:	00005797          	auipc	a5,0x5
    80002bb8:	d1c7a783          	lw	a5,-740(a5) # 800078d0 <ticks>
    80002bbc:	fcf42a23          	sw	a5,-44(s0)
  release(&tickslock);
    80002bc0:	00013517          	auipc	a0,0x13
    80002bc4:	26050513          	addi	a0,a0,608 # 80015e20 <tickslock>
    80002bc8:	854fe0ef          	jal	80000c1c <release>

  if(copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80002bcc:	4721                	li	a4,8
    80002bce:	fd040693          	addi	a3,s0,-48
    80002bd2:	fd843603          	ld	a2,-40(s0)
    80002bd6:	64ac                	ld	a1,72(s1)
    80002bd8:	68a8                	ld	a0,80(s1)
    80002bda:	901fe0ef          	jal	800014da <copyout>
    return -1;
  return 0;
}
    80002bde:	957d                	srai	a0,a0,0x3f
    80002be0:	70a2                	ld	ra,40(sp)
    80002be2:	7402                	ld	s0,32(sp)
    80002be4:	64e2                	ld	s1,24(sp)
    80002be6:	6145                	addi	sp,sp,48
    80002be8:	8082                	ret

0000000080002bea <sys_setpriority>:

#define NQUEUE 3

uint64
sys_setpriority(void)
{
    80002bea:	7179                	addi	sp,sp,-48
    80002bec:	f406                	sd	ra,40(sp)
    80002bee:	f022                	sd	s0,32(sp)
    80002bf0:	1800                	addi	s0,sp,48
  int prio;
  
  // argint void return karta hai, isliye ise direct call karo
  argint(0, &prio);
    80002bf2:	fdc40593          	addi	a1,s0,-36
    80002bf6:	4501                	li	a0,0
    80002bf8:	ccbff0ef          	jal	800028c2 <argint>

  if(prio < 0 || prio >= NQUEUE)
    80002bfc:	fdc42703          	lw	a4,-36(s0)
    80002c00:	4789                	li	a5,2
    return -1;
    80002c02:	557d                	li	a0,-1
  if(prio < 0 || prio >= NQUEUE)
    80002c04:	02e7e363          	bltu	a5,a4,80002c2a <sys_setpriority+0x40>
    80002c08:	ec26                	sd	s1,24(sp)

  struct proc *p = myproc();
    80002c0a:	c9bfe0ef          	jal	800018a4 <myproc>
    80002c0e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002c10:	f81fd0ef          	jal	80000b90 <acquire>
  p->priority = prio;
    80002c14:	fdc42783          	lw	a5,-36(s0)
    80002c18:	16f4a423          	sw	a5,360(s1)
  p->queue = prio;
    80002c1c:	16f4a623          	sw	a5,364(s1)
  release(&p->lock);
    80002c20:	8526                	mv	a0,s1
    80002c22:	ffbfd0ef          	jal	80000c1c <release>

  return 0;
    80002c26:	4501                	li	a0,0
    80002c28:	64e2                	ld	s1,24(sp)
    80002c2a:	70a2                	ld	ra,40(sp)
    80002c2c:	7402                	ld	s0,32(sp)
    80002c2e:	6145                	addi	sp,sp,48
    80002c30:	8082                	ret

0000000080002c32 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c32:	7179                	addi	sp,sp,-48
    80002c34:	f406                	sd	ra,40(sp)
    80002c36:	f022                	sd	s0,32(sp)
    80002c38:	ec26                	sd	s1,24(sp)
    80002c3a:	e84a                	sd	s2,16(sp)
    80002c3c:	e44e                	sd	s3,8(sp)
    80002c3e:	e052                	sd	s4,0(sp)
    80002c40:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c42:	00004597          	auipc	a1,0x4
    80002c46:	78e58593          	addi	a1,a1,1934 # 800073d0 <etext+0x3d0>
    80002c4a:	00013517          	auipc	a0,0x13
    80002c4e:	1ee50513          	addi	a0,a0,494 # 80015e38 <bcache>
    80002c52:	ec9fd0ef          	jal	80000b1a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c56:	0001b797          	auipc	a5,0x1b
    80002c5a:	1e278793          	addi	a5,a5,482 # 8001de38 <bcache+0x8000>
    80002c5e:	0001b717          	auipc	a4,0x1b
    80002c62:	44270713          	addi	a4,a4,1090 # 8001e0a0 <bcache+0x8268>
    80002c66:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c6a:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c6e:	00013497          	auipc	s1,0x13
    80002c72:	1e248493          	addi	s1,s1,482 # 80015e50 <bcache+0x18>
    b->next = bcache.head.next;
    80002c76:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c78:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c7a:	00004a17          	auipc	s4,0x4
    80002c7e:	75ea0a13          	addi	s4,s4,1886 # 800073d8 <etext+0x3d8>
    b->next = bcache.head.next;
    80002c82:	2b893783          	ld	a5,696(s2)
    80002c86:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c88:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c8c:	85d2                	mv	a1,s4
    80002c8e:	01048513          	addi	a0,s1,16
    80002c92:	412010ef          	jal	800040a4 <initsleeplock>
    bcache.head.next->prev = b;
    80002c96:	2b893783          	ld	a5,696(s2)
    80002c9a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c9c:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ca0:	45848493          	addi	s1,s1,1112
    80002ca4:	fd349fe3          	bne	s1,s3,80002c82 <binit+0x50>
  }
}
    80002ca8:	70a2                	ld	ra,40(sp)
    80002caa:	7402                	ld	s0,32(sp)
    80002cac:	64e2                	ld	s1,24(sp)
    80002cae:	6942                	ld	s2,16(sp)
    80002cb0:	69a2                	ld	s3,8(sp)
    80002cb2:	6a02                	ld	s4,0(sp)
    80002cb4:	6145                	addi	sp,sp,48
    80002cb6:	8082                	ret

0000000080002cb8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002cb8:	7179                	addi	sp,sp,-48
    80002cba:	f406                	sd	ra,40(sp)
    80002cbc:	f022                	sd	s0,32(sp)
    80002cbe:	ec26                	sd	s1,24(sp)
    80002cc0:	e84a                	sd	s2,16(sp)
    80002cc2:	e44e                	sd	s3,8(sp)
    80002cc4:	1800                	addi	s0,sp,48
    80002cc6:	892a                	mv	s2,a0
    80002cc8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cca:	00013517          	auipc	a0,0x13
    80002cce:	16e50513          	addi	a0,a0,366 # 80015e38 <bcache>
    80002cd2:	ebffd0ef          	jal	80000b90 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002cd6:	0001b497          	auipc	s1,0x1b
    80002cda:	41a4b483          	ld	s1,1050(s1) # 8001e0f0 <bcache+0x82b8>
    80002cde:	0001b797          	auipc	a5,0x1b
    80002ce2:	3c278793          	addi	a5,a5,962 # 8001e0a0 <bcache+0x8268>
    80002ce6:	02f48b63          	beq	s1,a5,80002d1c <bread+0x64>
    80002cea:	873e                	mv	a4,a5
    80002cec:	a021                	j	80002cf4 <bread+0x3c>
    80002cee:	68a4                	ld	s1,80(s1)
    80002cf0:	02e48663          	beq	s1,a4,80002d1c <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002cf4:	449c                	lw	a5,8(s1)
    80002cf6:	ff279ce3          	bne	a5,s2,80002cee <bread+0x36>
    80002cfa:	44dc                	lw	a5,12(s1)
    80002cfc:	ff3799e3          	bne	a5,s3,80002cee <bread+0x36>
      b->refcnt++;
    80002d00:	40bc                	lw	a5,64(s1)
    80002d02:	2785                	addiw	a5,a5,1
    80002d04:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d06:	00013517          	auipc	a0,0x13
    80002d0a:	13250513          	addi	a0,a0,306 # 80015e38 <bcache>
    80002d0e:	f0ffd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002d12:	01048513          	addi	a0,s1,16
    80002d16:	3c4010ef          	jal	800040da <acquiresleep>
      return b;
    80002d1a:	a889                	j	80002d6c <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d1c:	0001b497          	auipc	s1,0x1b
    80002d20:	3cc4b483          	ld	s1,972(s1) # 8001e0e8 <bcache+0x82b0>
    80002d24:	0001b797          	auipc	a5,0x1b
    80002d28:	37c78793          	addi	a5,a5,892 # 8001e0a0 <bcache+0x8268>
    80002d2c:	00f48863          	beq	s1,a5,80002d3c <bread+0x84>
    80002d30:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d32:	40bc                	lw	a5,64(s1)
    80002d34:	cb91                	beqz	a5,80002d48 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d36:	64a4                	ld	s1,72(s1)
    80002d38:	fee49de3          	bne	s1,a4,80002d32 <bread+0x7a>
  panic("bget: no buffers");
    80002d3c:	00004517          	auipc	a0,0x4
    80002d40:	6a450513          	addi	a0,a0,1700 # 800073e0 <etext+0x3e0>
    80002d44:	aadfd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    80002d48:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d4c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d50:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d54:	4785                	li	a5,1
    80002d56:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d58:	00013517          	auipc	a0,0x13
    80002d5c:	0e050513          	addi	a0,a0,224 # 80015e38 <bcache>
    80002d60:	ebdfd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002d64:	01048513          	addi	a0,s1,16
    80002d68:	372010ef          	jal	800040da <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002d6c:	409c                	lw	a5,0(s1)
    80002d6e:	cb89                	beqz	a5,80002d80 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d70:	8526                	mv	a0,s1
    80002d72:	70a2                	ld	ra,40(sp)
    80002d74:	7402                	ld	s0,32(sp)
    80002d76:	64e2                	ld	s1,24(sp)
    80002d78:	6942                	ld	s2,16(sp)
    80002d7a:	69a2                	ld	s3,8(sp)
    80002d7c:	6145                	addi	sp,sp,48
    80002d7e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d80:	4581                	li	a1,0
    80002d82:	8526                	mv	a0,s1
    80002d84:	49d020ef          	jal	80005a20 <virtio_disk_rw>
    b->valid = 1;
    80002d88:	4785                	li	a5,1
    80002d8a:	c09c                	sw	a5,0(s1)
  return b;
    80002d8c:	b7d5                	j	80002d70 <bread+0xb8>

0000000080002d8e <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	1000                	addi	s0,sp,32
    80002d98:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d9a:	0541                	addi	a0,a0,16
    80002d9c:	3ca010ef          	jal	80004166 <holdingsleep>
    80002da0:	c911                	beqz	a0,80002db4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002da2:	4585                	li	a1,1
    80002da4:	8526                	mv	a0,s1
    80002da6:	47b020ef          	jal	80005a20 <virtio_disk_rw>
}
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	64a2                	ld	s1,8(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret
    panic("bwrite");
    80002db4:	00004517          	auipc	a0,0x4
    80002db8:	64450513          	addi	a0,a0,1604 # 800073f8 <etext+0x3f8>
    80002dbc:	a35fd0ef          	jal	800007f0 <panic>

0000000080002dc0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	e04a                	sd	s2,0(sp)
    80002dca:	1000                	addi	s0,sp,32
    80002dcc:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002dce:	01050913          	addi	s2,a0,16
    80002dd2:	854a                	mv	a0,s2
    80002dd4:	392010ef          	jal	80004166 <holdingsleep>
    80002dd8:	c135                	beqz	a0,80002e3c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002dda:	854a                	mv	a0,s2
    80002ddc:	352010ef          	jal	8000412e <releasesleep>

  acquire(&bcache.lock);
    80002de0:	00013517          	auipc	a0,0x13
    80002de4:	05850513          	addi	a0,a0,88 # 80015e38 <bcache>
    80002de8:	da9fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002dec:	40bc                	lw	a5,64(s1)
    80002dee:	37fd                	addiw	a5,a5,-1
    80002df0:	0007871b          	sext.w	a4,a5
    80002df4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002df6:	e71d                	bnez	a4,80002e24 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002df8:	68b8                	ld	a4,80(s1)
    80002dfa:	64bc                	ld	a5,72(s1)
    80002dfc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002dfe:	68b8                	ld	a4,80(s1)
    80002e00:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e02:	0001b797          	auipc	a5,0x1b
    80002e06:	03678793          	addi	a5,a5,54 # 8001de38 <bcache+0x8000>
    80002e0a:	2b87b703          	ld	a4,696(a5)
    80002e0e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e10:	0001b717          	auipc	a4,0x1b
    80002e14:	29070713          	addi	a4,a4,656 # 8001e0a0 <bcache+0x8268>
    80002e18:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e1a:	2b87b703          	ld	a4,696(a5)
    80002e1e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e20:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002e24:	00013517          	auipc	a0,0x13
    80002e28:	01450513          	addi	a0,a0,20 # 80015e38 <bcache>
    80002e2c:	df1fd0ef          	jal	80000c1c <release>
}
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6902                	ld	s2,0(sp)
    80002e38:	6105                	addi	sp,sp,32
    80002e3a:	8082                	ret
    panic("brelse");
    80002e3c:	00004517          	auipc	a0,0x4
    80002e40:	5c450513          	addi	a0,a0,1476 # 80007400 <etext+0x400>
    80002e44:	9adfd0ef          	jal	800007f0 <panic>

0000000080002e48 <bpin>:

void
bpin(struct buf *b)
{
    80002e48:	1101                	addi	sp,sp,-32
    80002e4a:	ec06                	sd	ra,24(sp)
    80002e4c:	e822                	sd	s0,16(sp)
    80002e4e:	e426                	sd	s1,8(sp)
    80002e50:	1000                	addi	s0,sp,32
    80002e52:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e54:	00013517          	auipc	a0,0x13
    80002e58:	fe450513          	addi	a0,a0,-28 # 80015e38 <bcache>
    80002e5c:	d35fd0ef          	jal	80000b90 <acquire>
  b->refcnt++;
    80002e60:	40bc                	lw	a5,64(s1)
    80002e62:	2785                	addiw	a5,a5,1
    80002e64:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e66:	00013517          	auipc	a0,0x13
    80002e6a:	fd250513          	addi	a0,a0,-46 # 80015e38 <bcache>
    80002e6e:	daffd0ef          	jal	80000c1c <release>
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	64a2                	ld	s1,8(sp)
    80002e78:	6105                	addi	sp,sp,32
    80002e7a:	8082                	ret

0000000080002e7c <bunpin>:

void
bunpin(struct buf *b)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	1000                	addi	s0,sp,32
    80002e86:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e88:	00013517          	auipc	a0,0x13
    80002e8c:	fb050513          	addi	a0,a0,-80 # 80015e38 <bcache>
    80002e90:	d01fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002e94:	40bc                	lw	a5,64(s1)
    80002e96:	37fd                	addiw	a5,a5,-1
    80002e98:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e9a:	00013517          	auipc	a0,0x13
    80002e9e:	f9e50513          	addi	a0,a0,-98 # 80015e38 <bcache>
    80002ea2:	d7bfd0ef          	jal	80000c1c <release>
}
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	64a2                	ld	s1,8(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret

0000000080002eb0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002eb0:	1101                	addi	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	e426                	sd	s1,8(sp)
    80002eb8:	e04a                	sd	s2,0(sp)
    80002eba:	1000                	addi	s0,sp,32
    80002ebc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ebe:	00d5d59b          	srliw	a1,a1,0xd
    80002ec2:	0001b797          	auipc	a5,0x1b
    80002ec6:	6527a783          	lw	a5,1618(a5) # 8001e514 <sb+0x1c>
    80002eca:	9dbd                	addw	a1,a1,a5
    80002ecc:	dedff0ef          	jal	80002cb8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ed0:	0074f713          	andi	a4,s1,7
    80002ed4:	4785                	li	a5,1
    80002ed6:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80002eda:	14ce                	slli	s1,s1,0x33
    80002edc:	90d9                	srli	s1,s1,0x36
    80002ede:	00950733          	add	a4,a0,s1
    80002ee2:	05874703          	lbu	a4,88(a4)
    80002ee6:	00e7f6b3          	and	a3,a5,a4
    80002eea:	c29d                	beqz	a3,80002f10 <bfree+0x60>
    80002eec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002eee:	94aa                	add	s1,s1,a0
    80002ef0:	fff7c793          	not	a5,a5
    80002ef4:	8f7d                	and	a4,a4,a5
    80002ef6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002efa:	078010ef          	jal	80003f72 <log_write>
  brelse(bp);
    80002efe:	854a                	mv	a0,s2
    80002f00:	ec1ff0ef          	jal	80002dc0 <brelse>
}
    80002f04:	60e2                	ld	ra,24(sp)
    80002f06:	6442                	ld	s0,16(sp)
    80002f08:	64a2                	ld	s1,8(sp)
    80002f0a:	6902                	ld	s2,0(sp)
    80002f0c:	6105                	addi	sp,sp,32
    80002f0e:	8082                	ret
    panic("freeing free block");
    80002f10:	00004517          	auipc	a0,0x4
    80002f14:	4f850513          	addi	a0,a0,1272 # 80007408 <etext+0x408>
    80002f18:	8d9fd0ef          	jal	800007f0 <panic>

0000000080002f1c <balloc>:
{
    80002f1c:	711d                	addi	sp,sp,-96
    80002f1e:	ec86                	sd	ra,88(sp)
    80002f20:	e8a2                	sd	s0,80(sp)
    80002f22:	e4a6                	sd	s1,72(sp)
    80002f24:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80002f26:	0001b797          	auipc	a5,0x1b
    80002f2a:	5d67a783          	lw	a5,1494(a5) # 8001e4fc <sb+0x4>
    80002f2e:	0e078f63          	beqz	a5,8000302c <balloc+0x110>
    80002f32:	e0ca                	sd	s2,64(sp)
    80002f34:	fc4e                	sd	s3,56(sp)
    80002f36:	f852                	sd	s4,48(sp)
    80002f38:	f456                	sd	s5,40(sp)
    80002f3a:	f05a                	sd	s6,32(sp)
    80002f3c:	ec5e                	sd	s7,24(sp)
    80002f3e:	e862                	sd	s8,16(sp)
    80002f40:	e466                	sd	s9,8(sp)
    80002f42:	8baa                	mv	s7,a0
    80002f44:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f46:	0001bb17          	auipc	s6,0x1b
    80002f4a:	5b2b0b13          	addi	s6,s6,1458 # 8001e4f8 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f4e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f50:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f52:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f54:	6c89                	lui	s9,0x2
    80002f56:	a0b5                	j	80002fc2 <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f58:	97ca                	add	a5,a5,s2
    80002f5a:	8e55                	or	a2,a2,a3
    80002f5c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f60:	854a                	mv	a0,s2
    80002f62:	010010ef          	jal	80003f72 <log_write>
        brelse(bp);
    80002f66:	854a                	mv	a0,s2
    80002f68:	e59ff0ef          	jal	80002dc0 <brelse>
  bp = bread(dev, bno);
    80002f6c:	85a6                	mv	a1,s1
    80002f6e:	855e                	mv	a0,s7
    80002f70:	d49ff0ef          	jal	80002cb8 <bread>
    80002f74:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f76:	40000613          	li	a2,1024
    80002f7a:	4581                	li	a1,0
    80002f7c:	05850513          	addi	a0,a0,88
    80002f80:	cd5fd0ef          	jal	80000c54 <memset>
  log_write(bp);
    80002f84:	854a                	mv	a0,s2
    80002f86:	7ed000ef          	jal	80003f72 <log_write>
  brelse(bp);
    80002f8a:	854a                	mv	a0,s2
    80002f8c:	e35ff0ef          	jal	80002dc0 <brelse>
}
    80002f90:	6906                	ld	s2,64(sp)
    80002f92:	79e2                	ld	s3,56(sp)
    80002f94:	7a42                	ld	s4,48(sp)
    80002f96:	7aa2                	ld	s5,40(sp)
    80002f98:	7b02                	ld	s6,32(sp)
    80002f9a:	6be2                	ld	s7,24(sp)
    80002f9c:	6c42                	ld	s8,16(sp)
    80002f9e:	6ca2                	ld	s9,8(sp)
}
    80002fa0:	8526                	mv	a0,s1
    80002fa2:	60e6                	ld	ra,88(sp)
    80002fa4:	6446                	ld	s0,80(sp)
    80002fa6:	64a6                	ld	s1,72(sp)
    80002fa8:	6125                	addi	sp,sp,96
    80002faa:	8082                	ret
    brelse(bp);
    80002fac:	854a                	mv	a0,s2
    80002fae:	e13ff0ef          	jal	80002dc0 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002fb2:	015c87bb          	addw	a5,s9,s5
    80002fb6:	00078a9b          	sext.w	s5,a5
    80002fba:	004b2703          	lw	a4,4(s6)
    80002fbe:	04eaff63          	bgeu	s5,a4,8000301c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002fc2:	41fad79b          	sraiw	a5,s5,0x1f
    80002fc6:	0137d79b          	srliw	a5,a5,0x13
    80002fca:	015787bb          	addw	a5,a5,s5
    80002fce:	40d7d79b          	sraiw	a5,a5,0xd
    80002fd2:	01cb2583          	lw	a1,28(s6)
    80002fd6:	9dbd                	addw	a1,a1,a5
    80002fd8:	855e                	mv	a0,s7
    80002fda:	cdfff0ef          	jal	80002cb8 <bread>
    80002fde:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fe0:	004b2503          	lw	a0,4(s6)
    80002fe4:	000a849b          	sext.w	s1,s5
    80002fe8:	8762                	mv	a4,s8
    80002fea:	fca4f1e3          	bgeu	s1,a0,80002fac <balloc+0x90>
      m = 1 << (bi % 8);
    80002fee:	00777693          	andi	a3,a4,7
    80002ff2:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002ff6:	41f7579b          	sraiw	a5,a4,0x1f
    80002ffa:	01d7d79b          	srliw	a5,a5,0x1d
    80002ffe:	9fb9                	addw	a5,a5,a4
    80003000:	4037d79b          	sraiw	a5,a5,0x3
    80003004:	00f90633          	add	a2,s2,a5
    80003008:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000300c:	00c6f5b3          	and	a1,a3,a2
    80003010:	d5a1                	beqz	a1,80002f58 <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003012:	2705                	addiw	a4,a4,1
    80003014:	2485                	addiw	s1,s1,1
    80003016:	fd471ae3          	bne	a4,s4,80002fea <balloc+0xce>
    8000301a:	bf49                	j	80002fac <balloc+0x90>
    8000301c:	6906                	ld	s2,64(sp)
    8000301e:	79e2                	ld	s3,56(sp)
    80003020:	7a42                	ld	s4,48(sp)
    80003022:	7aa2                	ld	s5,40(sp)
    80003024:	7b02                	ld	s6,32(sp)
    80003026:	6be2                	ld	s7,24(sp)
    80003028:	6c42                	ld	s8,16(sp)
    8000302a:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    8000302c:	00004517          	auipc	a0,0x4
    80003030:	3f450513          	addi	a0,a0,1012 # 80007420 <etext+0x420>
    80003034:	cd6fd0ef          	jal	8000050a <printk>
  return 0;
    80003038:	4481                	li	s1,0
    8000303a:	b79d                	j	80002fa0 <balloc+0x84>

000000008000303c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000303c:	7179                	addi	sp,sp,-48
    8000303e:	f406                	sd	ra,40(sp)
    80003040:	f022                	sd	s0,32(sp)
    80003042:	ec26                	sd	s1,24(sp)
    80003044:	e84a                	sd	s2,16(sp)
    80003046:	e44e                	sd	s3,8(sp)
    80003048:	1800                	addi	s0,sp,48
    8000304a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000304c:	47ad                	li	a5,11
    8000304e:	02b7e663          	bltu	a5,a1,8000307a <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80003052:	02059793          	slli	a5,a1,0x20
    80003056:	01e7d593          	srli	a1,a5,0x1e
    8000305a:	00b504b3          	add	s1,a0,a1
    8000305e:	0504a903          	lw	s2,80(s1)
    80003062:	06091a63          	bnez	s2,800030d6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003066:	4108                	lw	a0,0(a0)
    80003068:	eb5ff0ef          	jal	80002f1c <balloc>
    8000306c:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003070:	06090363          	beqz	s2,800030d6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003074:	0524a823          	sw	s2,80(s1)
    80003078:	a8b9                	j	800030d6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000307a:	ff45849b          	addiw	s1,a1,-12
    8000307e:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    80003082:	0ff00793          	li	a5,255
    80003086:	06e7ee63          	bltu	a5,a4,80003102 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    8000308a:	08052903          	lw	s2,128(a0)
    8000308e:	00091d63          	bnez	s2,800030a8 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003092:	4108                	lw	a0,0(a0)
    80003094:	e89ff0ef          	jal	80002f1c <balloc>
    80003098:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    8000309c:	02090d63          	beqz	s2,800030d6 <bmap+0x9a>
    800030a0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030a2:	0929a023          	sw	s2,128(s3)
    800030a6:	a011                	j	800030aa <bmap+0x6e>
    800030a8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030aa:	85ca                	mv	a1,s2
    800030ac:	0009a503          	lw	a0,0(s3)
    800030b0:	c09ff0ef          	jal	80002cb8 <bread>
    800030b4:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800030b6:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800030ba:	02049713          	slli	a4,s1,0x20
    800030be:	01e75593          	srli	a1,a4,0x1e
    800030c2:	00b784b3          	add	s1,a5,a1
    800030c6:	0004a903          	lw	s2,0(s1)
    800030ca:	00090e63          	beqz	s2,800030e6 <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030ce:	8552                	mv	a0,s4
    800030d0:	cf1ff0ef          	jal	80002dc0 <brelse>
    return addr;
    800030d4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030d6:	854a                	mv	a0,s2
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6145                	addi	sp,sp,48
    800030e4:	8082                	ret
      addr = balloc(ip->dev);
    800030e6:	0009a503          	lw	a0,0(s3)
    800030ea:	e33ff0ef          	jal	80002f1c <balloc>
    800030ee:	0005091b          	sext.w	s2,a0
      if (addr) {
    800030f2:	fc090ee3          	beqz	s2,800030ce <bmap+0x92>
        a[bn] = addr;
    800030f6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030fa:	8552                	mv	a0,s4
    800030fc:	677000ef          	jal	80003f72 <log_write>
    80003100:	b7f9                	j	800030ce <bmap+0x92>
    80003102:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003104:	00004517          	auipc	a0,0x4
    80003108:	33450513          	addi	a0,a0,820 # 80007438 <etext+0x438>
    8000310c:	ee4fd0ef          	jal	800007f0 <panic>

0000000080003110 <iget>:
{
    80003110:	7179                	addi	sp,sp,-48
    80003112:	f406                	sd	ra,40(sp)
    80003114:	f022                	sd	s0,32(sp)
    80003116:	ec26                	sd	s1,24(sp)
    80003118:	e84a                	sd	s2,16(sp)
    8000311a:	e44e                	sd	s3,8(sp)
    8000311c:	e052                	sd	s4,0(sp)
    8000311e:	1800                	addi	s0,sp,48
    80003120:	89aa                	mv	s3,a0
    80003122:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003124:	0001b517          	auipc	a0,0x1b
    80003128:	3f450513          	addi	a0,a0,1012 # 8001e518 <itable>
    8000312c:	a65fd0ef          	jal	80000b90 <acquire>
  empty = 0;
    80003130:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003132:	0001b497          	auipc	s1,0x1b
    80003136:	3fe48493          	addi	s1,s1,1022 # 8001e530 <itable+0x18>
    8000313a:	0001d697          	auipc	a3,0x1d
    8000313e:	e8668693          	addi	a3,a3,-378 # 8001ffc0 <log>
    80003142:	a039                	j	80003150 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003144:	02090963          	beqz	s2,80003176 <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003148:	08848493          	addi	s1,s1,136
    8000314c:	02d48863          	beq	s1,a3,8000317c <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003150:	449c                	lw	a5,8(s1)
    80003152:	fef059e3          	blez	a5,80003144 <iget+0x34>
    80003156:	4098                	lw	a4,0(s1)
    80003158:	ff3716e3          	bne	a4,s3,80003144 <iget+0x34>
    8000315c:	40d8                	lw	a4,4(s1)
    8000315e:	ff4713e3          	bne	a4,s4,80003144 <iget+0x34>
      ip->ref++;
    80003162:	2785                	addiw	a5,a5,1
    80003164:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003166:	0001b517          	auipc	a0,0x1b
    8000316a:	3b250513          	addi	a0,a0,946 # 8001e518 <itable>
    8000316e:	aaffd0ef          	jal	80000c1c <release>
      return ip;
    80003172:	8926                	mv	s2,s1
    80003174:	a02d                	j	8000319e <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003176:	fbe9                	bnez	a5,80003148 <iget+0x38>
      empty = ip;
    80003178:	8926                	mv	s2,s1
    8000317a:	b7f9                	j	80003148 <iget+0x38>
  if (empty == 0)
    8000317c:	02090a63          	beqz	s2,800031b0 <iget+0xa0>
  ip->dev = dev;
    80003180:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003184:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003188:	4785                	li	a5,1
    8000318a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000318e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003192:	0001b517          	auipc	a0,0x1b
    80003196:	38650513          	addi	a0,a0,902 # 8001e518 <itable>
    8000319a:	a83fd0ef          	jal	80000c1c <release>
}
    8000319e:	854a                	mv	a0,s2
    800031a0:	70a2                	ld	ra,40(sp)
    800031a2:	7402                	ld	s0,32(sp)
    800031a4:	64e2                	ld	s1,24(sp)
    800031a6:	6942                	ld	s2,16(sp)
    800031a8:	69a2                	ld	s3,8(sp)
    800031aa:	6a02                	ld	s4,0(sp)
    800031ac:	6145                	addi	sp,sp,48
    800031ae:	8082                	ret
    panic("iget: no inodes");
    800031b0:	00004517          	auipc	a0,0x4
    800031b4:	2a050513          	addi	a0,a0,672 # 80007450 <etext+0x450>
    800031b8:	e38fd0ef          	jal	800007f0 <panic>

00000000800031bc <iinit>:
{
    800031bc:	7179                	addi	sp,sp,-48
    800031be:	f406                	sd	ra,40(sp)
    800031c0:	f022                	sd	s0,32(sp)
    800031c2:	ec26                	sd	s1,24(sp)
    800031c4:	e84a                	sd	s2,16(sp)
    800031c6:	e44e                	sd	s3,8(sp)
    800031c8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031ca:	00004597          	auipc	a1,0x4
    800031ce:	29658593          	addi	a1,a1,662 # 80007460 <etext+0x460>
    800031d2:	0001b517          	auipc	a0,0x1b
    800031d6:	34650513          	addi	a0,a0,838 # 8001e518 <itable>
    800031da:	941fd0ef          	jal	80000b1a <initlock>
  for (i = 0; i < NINODE; i++) {
    800031de:	0001b497          	auipc	s1,0x1b
    800031e2:	36248493          	addi	s1,s1,866 # 8001e540 <itable+0x28>
    800031e6:	0001d997          	auipc	s3,0x1d
    800031ea:	dea98993          	addi	s3,s3,-534 # 8001ffd0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031ee:	00004917          	auipc	s2,0x4
    800031f2:	27a90913          	addi	s2,s2,634 # 80007468 <etext+0x468>
    800031f6:	85ca                	mv	a1,s2
    800031f8:	8526                	mv	a0,s1
    800031fa:	6ab000ef          	jal	800040a4 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800031fe:	08848493          	addi	s1,s1,136
    80003202:	ff349ae3          	bne	s1,s3,800031f6 <iinit+0x3a>
}
    80003206:	70a2                	ld	ra,40(sp)
    80003208:	7402                	ld	s0,32(sp)
    8000320a:	64e2                	ld	s1,24(sp)
    8000320c:	6942                	ld	s2,16(sp)
    8000320e:	69a2                	ld	s3,8(sp)
    80003210:	6145                	addi	sp,sp,48
    80003212:	8082                	ret

0000000080003214 <ialloc>:
{
    80003214:	7139                	addi	sp,sp,-64
    80003216:	fc06                	sd	ra,56(sp)
    80003218:	f822                	sd	s0,48(sp)
    8000321a:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000321c:	0001b717          	auipc	a4,0x1b
    80003220:	2e872703          	lw	a4,744(a4) # 8001e504 <sb+0xc>
    80003224:	4785                	li	a5,1
    80003226:	06e7f063          	bgeu	a5,a4,80003286 <ialloc+0x72>
    8000322a:	f426                	sd	s1,40(sp)
    8000322c:	f04a                	sd	s2,32(sp)
    8000322e:	ec4e                	sd	s3,24(sp)
    80003230:	e852                	sd	s4,16(sp)
    80003232:	e456                	sd	s5,8(sp)
    80003234:	e05a                	sd	s6,0(sp)
    80003236:	8aaa                	mv	s5,a0
    80003238:	8b2e                	mv	s6,a1
    8000323a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000323c:	0001ba17          	auipc	s4,0x1b
    80003240:	2bca0a13          	addi	s4,s4,700 # 8001e4f8 <sb>
    80003244:	00495593          	srli	a1,s2,0x4
    80003248:	018a2783          	lw	a5,24(s4)
    8000324c:	9dbd                	addw	a1,a1,a5
    8000324e:	8556                	mv	a0,s5
    80003250:	a69ff0ef          	jal	80002cb8 <bread>
    80003254:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003256:	05850993          	addi	s3,a0,88
    8000325a:	00f97793          	andi	a5,s2,15
    8000325e:	079a                	slli	a5,a5,0x6
    80003260:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003262:	00099783          	lh	a5,0(s3)
    80003266:	cb9d                	beqz	a5,8000329c <ialloc+0x88>
    brelse(bp);
    80003268:	b59ff0ef          	jal	80002dc0 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000326c:	0905                	addi	s2,s2,1
    8000326e:	00ca2703          	lw	a4,12(s4)
    80003272:	0009079b          	sext.w	a5,s2
    80003276:	fce7e7e3          	bltu	a5,a4,80003244 <ialloc+0x30>
    8000327a:	74a2                	ld	s1,40(sp)
    8000327c:	7902                	ld	s2,32(sp)
    8000327e:	69e2                	ld	s3,24(sp)
    80003280:	6a42                	ld	s4,16(sp)
    80003282:	6aa2                	ld	s5,8(sp)
    80003284:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003286:	00004517          	auipc	a0,0x4
    8000328a:	1ea50513          	addi	a0,a0,490 # 80007470 <etext+0x470>
    8000328e:	a7cfd0ef          	jal	8000050a <printk>
  return 0;
    80003292:	4501                	li	a0,0
}
    80003294:	70e2                	ld	ra,56(sp)
    80003296:	7442                	ld	s0,48(sp)
    80003298:	6121                	addi	sp,sp,64
    8000329a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000329c:	04000613          	li	a2,64
    800032a0:	4581                	li	a1,0
    800032a2:	854e                	mv	a0,s3
    800032a4:	9b1fd0ef          	jal	80000c54 <memset>
      dip->type = type;
    800032a8:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800032ac:	8526                	mv	a0,s1
    800032ae:	4c5000ef          	jal	80003f72 <log_write>
      brelse(bp);
    800032b2:	8526                	mv	a0,s1
    800032b4:	b0dff0ef          	jal	80002dc0 <brelse>
      return iget(dev, inum);
    800032b8:	0009059b          	sext.w	a1,s2
    800032bc:	8556                	mv	a0,s5
    800032be:	e53ff0ef          	jal	80003110 <iget>
    800032c2:	74a2                	ld	s1,40(sp)
    800032c4:	7902                	ld	s2,32(sp)
    800032c6:	69e2                	ld	s3,24(sp)
    800032c8:	6a42                	ld	s4,16(sp)
    800032ca:	6aa2                	ld	s5,8(sp)
    800032cc:	6b02                	ld	s6,0(sp)
    800032ce:	b7d9                	j	80003294 <ialloc+0x80>

00000000800032d0 <iupdate>:
{
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	e426                	sd	s1,8(sp)
    800032d8:	e04a                	sd	s2,0(sp)
    800032da:	1000                	addi	s0,sp,32
    800032dc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032de:	415c                	lw	a5,4(a0)
    800032e0:	0047d79b          	srliw	a5,a5,0x4
    800032e4:	0001b597          	auipc	a1,0x1b
    800032e8:	22c5a583          	lw	a1,556(a1) # 8001e510 <sb+0x18>
    800032ec:	9dbd                	addw	a1,a1,a5
    800032ee:	4108                	lw	a0,0(a0)
    800032f0:	9c9ff0ef          	jal	80002cb8 <bread>
    800032f4:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032f6:	05850793          	addi	a5,a0,88
    800032fa:	40d8                	lw	a4,4(s1)
    800032fc:	8b3d                	andi	a4,a4,15
    800032fe:	071a                	slli	a4,a4,0x6
    80003300:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003302:	04449703          	lh	a4,68(s1)
    80003306:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000330a:	04649703          	lh	a4,70(s1)
    8000330e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003312:	04849703          	lh	a4,72(s1)
    80003316:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000331a:	04a49703          	lh	a4,74(s1)
    8000331e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003322:	44f8                	lw	a4,76(s1)
    80003324:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003326:	03400613          	li	a2,52
    8000332a:	05048593          	addi	a1,s1,80
    8000332e:	00c78513          	addi	a0,a5,12
    80003332:	97ffd0ef          	jal	80000cb0 <memmove>
  log_write(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	43b000ef          	jal	80003f72 <log_write>
  brelse(bp);
    8000333c:	854a                	mv	a0,s2
    8000333e:	a83ff0ef          	jal	80002dc0 <brelse>
}
    80003342:	60e2                	ld	ra,24(sp)
    80003344:	6442                	ld	s0,16(sp)
    80003346:	64a2                	ld	s1,8(sp)
    80003348:	6902                	ld	s2,0(sp)
    8000334a:	6105                	addi	sp,sp,32
    8000334c:	8082                	ret

000000008000334e <idup>:
{
    8000334e:	1101                	addi	sp,sp,-32
    80003350:	ec06                	sd	ra,24(sp)
    80003352:	e822                	sd	s0,16(sp)
    80003354:	e426                	sd	s1,8(sp)
    80003356:	1000                	addi	s0,sp,32
    80003358:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000335a:	0001b517          	auipc	a0,0x1b
    8000335e:	1be50513          	addi	a0,a0,446 # 8001e518 <itable>
    80003362:	82ffd0ef          	jal	80000b90 <acquire>
  ip->ref++;
    80003366:	449c                	lw	a5,8(s1)
    80003368:	2785                	addiw	a5,a5,1
    8000336a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000336c:	0001b517          	auipc	a0,0x1b
    80003370:	1ac50513          	addi	a0,a0,428 # 8001e518 <itable>
    80003374:	8a9fd0ef          	jal	80000c1c <release>
}
    80003378:	8526                	mv	a0,s1
    8000337a:	60e2                	ld	ra,24(sp)
    8000337c:	6442                	ld	s0,16(sp)
    8000337e:	64a2                	ld	s1,8(sp)
    80003380:	6105                	addi	sp,sp,32
    80003382:	8082                	ret

0000000080003384 <ilock>:
{
    80003384:	1101                	addi	sp,sp,-32
    80003386:	ec06                	sd	ra,24(sp)
    80003388:	e822                	sd	s0,16(sp)
    8000338a:	e426                	sd	s1,8(sp)
    8000338c:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000338e:	cd19                	beqz	a0,800033ac <ilock+0x28>
    80003390:	84aa                	mv	s1,a0
    80003392:	451c                	lw	a5,8(a0)
    80003394:	00f05c63          	blez	a5,800033ac <ilock+0x28>
  acquiresleep(&ip->lock);
    80003398:	0541                	addi	a0,a0,16
    8000339a:	541000ef          	jal	800040da <acquiresleep>
  if (ip->valid == 0) {
    8000339e:	40bc                	lw	a5,64(s1)
    800033a0:	cf89                	beqz	a5,800033ba <ilock+0x36>
}
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	64a2                	ld	s1,8(sp)
    800033a8:	6105                	addi	sp,sp,32
    800033aa:	8082                	ret
    800033ac:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033ae:	00004517          	auipc	a0,0x4
    800033b2:	0da50513          	addi	a0,a0,218 # 80007488 <etext+0x488>
    800033b6:	c3afd0ef          	jal	800007f0 <panic>
    800033ba:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033bc:	40dc                	lw	a5,4(s1)
    800033be:	0047d79b          	srliw	a5,a5,0x4
    800033c2:	0001b597          	auipc	a1,0x1b
    800033c6:	14e5a583          	lw	a1,334(a1) # 8001e510 <sb+0x18>
    800033ca:	9dbd                	addw	a1,a1,a5
    800033cc:	4088                	lw	a0,0(s1)
    800033ce:	8ebff0ef          	jal	80002cb8 <bread>
    800033d2:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800033d4:	05850593          	addi	a1,a0,88
    800033d8:	40dc                	lw	a5,4(s1)
    800033da:	8bbd                	andi	a5,a5,15
    800033dc:	079a                	slli	a5,a5,0x6
    800033de:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033e0:	00059783          	lh	a5,0(a1)
    800033e4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033e8:	00259783          	lh	a5,2(a1)
    800033ec:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033f0:	00459783          	lh	a5,4(a1)
    800033f4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033f8:	00659783          	lh	a5,6(a1)
    800033fc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003400:	459c                	lw	a5,8(a1)
    80003402:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003404:	03400613          	li	a2,52
    80003408:	05b1                	addi	a1,a1,12
    8000340a:	05048513          	addi	a0,s1,80
    8000340e:	8a3fd0ef          	jal	80000cb0 <memmove>
    brelse(bp);
    80003412:	854a                	mv	a0,s2
    80003414:	9adff0ef          	jal	80002dc0 <brelse>
    ip->valid = 1;
    80003418:	4785                	li	a5,1
    8000341a:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000341c:	04449783          	lh	a5,68(s1)
    80003420:	c399                	beqz	a5,80003426 <ilock+0xa2>
    80003422:	6902                	ld	s2,0(sp)
    80003424:	bfbd                	j	800033a2 <ilock+0x1e>
      panic("ilock: no type");
    80003426:	00004517          	auipc	a0,0x4
    8000342a:	06a50513          	addi	a0,a0,106 # 80007490 <etext+0x490>
    8000342e:	bc2fd0ef          	jal	800007f0 <panic>

0000000080003432 <iunlock>:
{
    80003432:	1101                	addi	sp,sp,-32
    80003434:	ec06                	sd	ra,24(sp)
    80003436:	e822                	sd	s0,16(sp)
    80003438:	e426                	sd	s1,8(sp)
    8000343a:	e04a                	sd	s2,0(sp)
    8000343c:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000343e:	c505                	beqz	a0,80003466 <iunlock+0x34>
    80003440:	84aa                	mv	s1,a0
    80003442:	01050913          	addi	s2,a0,16
    80003446:	854a                	mv	a0,s2
    80003448:	51f000ef          	jal	80004166 <holdingsleep>
    8000344c:	cd09                	beqz	a0,80003466 <iunlock+0x34>
    8000344e:	449c                	lw	a5,8(s1)
    80003450:	00f05b63          	blez	a5,80003466 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003454:	854a                	mv	a0,s2
    80003456:	4d9000ef          	jal	8000412e <releasesleep>
}
    8000345a:	60e2                	ld	ra,24(sp)
    8000345c:	6442                	ld	s0,16(sp)
    8000345e:	64a2                	ld	s1,8(sp)
    80003460:	6902                	ld	s2,0(sp)
    80003462:	6105                	addi	sp,sp,32
    80003464:	8082                	ret
    panic("iunlock");
    80003466:	00004517          	auipc	a0,0x4
    8000346a:	03a50513          	addi	a0,a0,58 # 800074a0 <etext+0x4a0>
    8000346e:	b82fd0ef          	jal	800007f0 <panic>

0000000080003472 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	1800                	addi	s0,sp,48
    80003480:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003482:	05050493          	addi	s1,a0,80
    80003486:	08050913          	addi	s2,a0,128
    8000348a:	a021                	j	80003492 <itrunc+0x20>
    8000348c:	0491                	addi	s1,s1,4
    8000348e:	01248b63          	beq	s1,s2,800034a4 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003492:	408c                	lw	a1,0(s1)
    80003494:	dde5                	beqz	a1,8000348c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003496:	0009a503          	lw	a0,0(s3)
    8000349a:	a17ff0ef          	jal	80002eb0 <bfree>
      ip->addrs[i] = 0;
    8000349e:	0004a023          	sw	zero,0(s1)
    800034a2:	b7ed                	j	8000348c <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800034a4:	0809a583          	lw	a1,128(s3)
    800034a8:	ed89                	bnez	a1,800034c2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034aa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034ae:	854e                	mv	a0,s3
    800034b0:	e21ff0ef          	jal	800032d0 <iupdate>
}
    800034b4:	70a2                	ld	ra,40(sp)
    800034b6:	7402                	ld	s0,32(sp)
    800034b8:	64e2                	ld	s1,24(sp)
    800034ba:	6942                	ld	s2,16(sp)
    800034bc:	69a2                	ld	s3,8(sp)
    800034be:	6145                	addi	sp,sp,48
    800034c0:	8082                	ret
    800034c2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034c4:	0009a503          	lw	a0,0(s3)
    800034c8:	ff0ff0ef          	jal	80002cb8 <bread>
    800034cc:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800034ce:	05850493          	addi	s1,a0,88
    800034d2:	45850913          	addi	s2,a0,1112
    800034d6:	a021                	j	800034de <itrunc+0x6c>
    800034d8:	0491                	addi	s1,s1,4
    800034da:	01248963          	beq	s1,s2,800034ec <itrunc+0x7a>
      if (a[j])
    800034de:	408c                	lw	a1,0(s1)
    800034e0:	dde5                	beqz	a1,800034d8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034e2:	0009a503          	lw	a0,0(s3)
    800034e6:	9cbff0ef          	jal	80002eb0 <bfree>
    800034ea:	b7fd                	j	800034d8 <itrunc+0x66>
    brelse(bp);
    800034ec:	8552                	mv	a0,s4
    800034ee:	8d3ff0ef          	jal	80002dc0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034f2:	0809a583          	lw	a1,128(s3)
    800034f6:	0009a503          	lw	a0,0(s3)
    800034fa:	9b7ff0ef          	jal	80002eb0 <bfree>
    ip->addrs[NDIRECT] = 0;
    800034fe:	0809a023          	sw	zero,128(s3)
    80003502:	6a02                	ld	s4,0(sp)
    80003504:	b75d                	j	800034aa <itrunc+0x38>

0000000080003506 <iput>:
{
    80003506:	7179                	addi	sp,sp,-48
    80003508:	f406                	sd	ra,40(sp)
    8000350a:	f022                	sd	s0,32(sp)
    8000350c:	ec26                	sd	s1,24(sp)
    8000350e:	1800                	addi	s0,sp,48
    80003510:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003512:	0001b517          	auipc	a0,0x1b
    80003516:	00650513          	addi	a0,a0,6 # 8001e518 <itable>
    8000351a:	e76fd0ef          	jal	80000b90 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000351e:	449c                	lw	a5,8(s1)
    80003520:	4705                	li	a4,1
    80003522:	00e78f63          	beq	a5,a4,80003540 <iput+0x3a>
  ip->ref--;
    80003526:	37fd                	addiw	a5,a5,-1
    80003528:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000352a:	0001b517          	auipc	a0,0x1b
    8000352e:	fee50513          	addi	a0,a0,-18 # 8001e518 <itable>
    80003532:	eeafd0ef          	jal	80000c1c <release>
}
    80003536:	70a2                	ld	ra,40(sp)
    80003538:	7402                	ld	s0,32(sp)
    8000353a:	64e2                	ld	s1,24(sp)
    8000353c:	6145                	addi	sp,sp,48
    8000353e:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003540:	40b8                	lw	a4,64(s1)
    80003542:	d375                	beqz	a4,80003526 <iput+0x20>
    80003544:	e84a                	sd	s2,16(sp)
    80003546:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003548:	0004aa03          	lw	s4,0(s1)
    8000354c:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003550:	04a49703          	lh	a4,74(s1)
    80003554:	ef35                	bnez	a4,800035d0 <iput+0xca>
    80003556:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003558:	01048993          	addi	s3,s1,16
    8000355c:	854e                	mv	a0,s3
    8000355e:	37d000ef          	jal	800040da <acquiresleep>
    release(&itable.lock);
    80003562:	0001b517          	auipc	a0,0x1b
    80003566:	fb650513          	addi	a0,a0,-74 # 8001e518 <itable>
    8000356a:	eb2fd0ef          	jal	80000c1c <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000356e:	8526                	mv	a0,s1
    80003570:	f03ff0ef          	jal	80003472 <itrunc>
    ip->valid = 0;
    80003574:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003578:	854e                	mv	a0,s3
    8000357a:	3b5000ef          	jal	8000412e <releasesleep>
    acquire(&itable.lock);
    8000357e:	0001b517          	auipc	a0,0x1b
    80003582:	f9a50513          	addi	a0,a0,-102 # 8001e518 <itable>
    80003586:	e0afd0ef          	jal	80000b90 <acquire>
  ip->ref--;
    8000358a:	449c                	lw	a5,8(s1)
    8000358c:	37fd                	addiw	a5,a5,-1
    8000358e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003590:	0001b517          	auipc	a0,0x1b
    80003594:	f8850513          	addi	a0,a0,-120 # 8001e518 <itable>
    80003598:	e84fd0ef          	jal	80000c1c <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000359c:	0049559b          	srliw	a1,s2,0x4
    800035a0:	0001b797          	auipc	a5,0x1b
    800035a4:	f707a783          	lw	a5,-144(a5) # 8001e510 <sb+0x18>
    800035a8:	9dbd                	addw	a1,a1,a5
    800035aa:	8552                	mv	a0,s4
    800035ac:	f0cff0ef          	jal	80002cb8 <bread>
    800035b0:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035b2:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    800035b6:	091a                	slli	s2,s2,0x6
    800035b8:	992a                	add	s2,s2,a0
    800035ba:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    800035be:	1b5000ef          	jal	80003f72 <log_write>
  brelse(bp);
    800035c2:	8526                	mv	a0,s1
    800035c4:	ffcff0ef          	jal	80002dc0 <brelse>
}
    800035c8:	6942                	ld	s2,16(sp)
    800035ca:	69a2                	ld	s3,8(sp)
    800035cc:	6a02                	ld	s4,0(sp)
    800035ce:	b7a5                	j	80003536 <iput+0x30>
    800035d0:	6942                	ld	s2,16(sp)
    800035d2:	6a02                	ld	s4,0(sp)
    800035d4:	bf89                	j	80003526 <iput+0x20>

00000000800035d6 <iunlockput>:
{
    800035d6:	1101                	addi	sp,sp,-32
    800035d8:	ec06                	sd	ra,24(sp)
    800035da:	e822                	sd	s0,16(sp)
    800035dc:	e426                	sd	s1,8(sp)
    800035de:	1000                	addi	s0,sp,32
    800035e0:	84aa                	mv	s1,a0
  iunlock(ip);
    800035e2:	e51ff0ef          	jal	80003432 <iunlock>
  iput(ip);
    800035e6:	8526                	mv	a0,s1
    800035e8:	f1fff0ef          	jal	80003506 <iput>
}
    800035ec:	60e2                	ld	ra,24(sp)
    800035ee:	6442                	ld	s0,16(sp)
    800035f0:	64a2                	ld	s1,8(sp)
    800035f2:	6105                	addi	sp,sp,32
    800035f4:	8082                	ret

00000000800035f6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035f6:	0001b717          	auipc	a4,0x1b
    800035fa:	f0e72703          	lw	a4,-242(a4) # 8001e504 <sb+0xc>
    800035fe:	4785                	li	a5,1
    80003600:	0ae7ff63          	bgeu	a5,a4,800036be <ireclaim+0xc8>
{
    80003604:	7139                	addi	sp,sp,-64
    80003606:	fc06                	sd	ra,56(sp)
    80003608:	f822                	sd	s0,48(sp)
    8000360a:	f426                	sd	s1,40(sp)
    8000360c:	f04a                	sd	s2,32(sp)
    8000360e:	ec4e                	sd	s3,24(sp)
    80003610:	e852                	sd	s4,16(sp)
    80003612:	e456                	sd	s5,8(sp)
    80003614:	e05a                	sd	s6,0(sp)
    80003616:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003618:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000361a:	00050a1b          	sext.w	s4,a0
    8000361e:	0001ba97          	auipc	s5,0x1b
    80003622:	edaa8a93          	addi	s5,s5,-294 # 8001e4f8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003626:	00004b17          	auipc	s6,0x4
    8000362a:	e82b0b13          	addi	s6,s6,-382 # 800074a8 <etext+0x4a8>
    8000362e:	a099                	j	80003674 <ireclaim+0x7e>
    80003630:	85ce                	mv	a1,s3
    80003632:	855a                	mv	a0,s6
    80003634:	ed7fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003638:	85ce                	mv	a1,s3
    8000363a:	8552                	mv	a0,s4
    8000363c:	ad5ff0ef          	jal	80003110 <iget>
    80003640:	89aa                	mv	s3,a0
    brelse(bp);
    80003642:	854a                	mv	a0,s2
    80003644:	f7cff0ef          	jal	80002dc0 <brelse>
    if (ip) {
    80003648:	00098f63          	beqz	s3,80003666 <ireclaim+0x70>
      begin_op();
    8000364c:	780000ef          	jal	80003dcc <begin_op>
      ilock(ip);
    80003650:	854e                	mv	a0,s3
    80003652:	d33ff0ef          	jal	80003384 <ilock>
      iunlock(ip);
    80003656:	854e                	mv	a0,s3
    80003658:	ddbff0ef          	jal	80003432 <iunlock>
      iput(ip);
    8000365c:	854e                	mv	a0,s3
    8000365e:	ea9ff0ef          	jal	80003506 <iput>
      end_op();
    80003662:	7f0000ef          	jal	80003e52 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003666:	0485                	addi	s1,s1,1
    80003668:	00caa703          	lw	a4,12(s5)
    8000366c:	0004879b          	sext.w	a5,s1
    80003670:	02e7fd63          	bgeu	a5,a4,800036aa <ireclaim+0xb4>
    80003674:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003678:	0044d593          	srli	a1,s1,0x4
    8000367c:	018aa783          	lw	a5,24(s5)
    80003680:	9dbd                	addw	a1,a1,a5
    80003682:	8552                	mv	a0,s4
    80003684:	e34ff0ef          	jal	80002cb8 <bread>
    80003688:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000368a:	05850793          	addi	a5,a0,88
    8000368e:	00f9f713          	andi	a4,s3,15
    80003692:	071a                	slli	a4,a4,0x6
    80003694:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003696:	00079703          	lh	a4,0(a5)
    8000369a:	c701                	beqz	a4,800036a2 <ireclaim+0xac>
    8000369c:	00679783          	lh	a5,6(a5)
    800036a0:	dbc1                	beqz	a5,80003630 <ireclaim+0x3a>
    brelse(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	f1cff0ef          	jal	80002dc0 <brelse>
    if (ip) {
    800036a8:	bf7d                	j	80003666 <ireclaim+0x70>
}
    800036aa:	70e2                	ld	ra,56(sp)
    800036ac:	7442                	ld	s0,48(sp)
    800036ae:	74a2                	ld	s1,40(sp)
    800036b0:	7902                	ld	s2,32(sp)
    800036b2:	69e2                	ld	s3,24(sp)
    800036b4:	6a42                	ld	s4,16(sp)
    800036b6:	6aa2                	ld	s5,8(sp)
    800036b8:	6b02                	ld	s6,0(sp)
    800036ba:	6121                	addi	sp,sp,64
    800036bc:	8082                	ret
    800036be:	8082                	ret

00000000800036c0 <fsinit>:
{
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	1800                	addi	s0,sp,48
    800036ce:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036d0:	4585                	li	a1,1
    800036d2:	de6ff0ef          	jal	80002cb8 <bread>
    800036d6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036d8:	0001b997          	auipc	s3,0x1b
    800036dc:	e2098993          	addi	s3,s3,-480 # 8001e4f8 <sb>
    800036e0:	02000613          	li	a2,32
    800036e4:	05850593          	addi	a1,a0,88
    800036e8:	854e                	mv	a0,s3
    800036ea:	dc6fd0ef          	jal	80000cb0 <memmove>
  brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	ed0ff0ef          	jal	80002dc0 <brelse>
  if (sb.magic != FSMAGIC)
    800036f4:	0009a703          	lw	a4,0(s3)
    800036f8:	102037b7          	lui	a5,0x10203
    800036fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003700:	02f71363          	bne	a4,a5,80003726 <fsinit+0x66>
  initlog(dev, &sb);
    80003704:	0001b597          	auipc	a1,0x1b
    80003708:	df458593          	addi	a1,a1,-524 # 8001e4f8 <sb>
    8000370c:	8526                	mv	a0,s1
    8000370e:	640000ef          	jal	80003d4e <initlog>
  ireclaim(dev);
    80003712:	8526                	mv	a0,s1
    80003714:	ee3ff0ef          	jal	800035f6 <ireclaim>
}
    80003718:	70a2                	ld	ra,40(sp)
    8000371a:	7402                	ld	s0,32(sp)
    8000371c:	64e2                	ld	s1,24(sp)
    8000371e:	6942                	ld	s2,16(sp)
    80003720:	69a2                	ld	s3,8(sp)
    80003722:	6145                	addi	sp,sp,48
    80003724:	8082                	ret
    panic("invalid file system");
    80003726:	00004517          	auipc	a0,0x4
    8000372a:	da250513          	addi	a0,a0,-606 # 800074c8 <etext+0x4c8>
    8000372e:	8c2fd0ef          	jal	800007f0 <panic>

0000000080003732 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003732:	1141                	addi	sp,sp,-16
    80003734:	e422                	sd	s0,8(sp)
    80003736:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003738:	411c                	lw	a5,0(a0)
    8000373a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000373c:	415c                	lw	a5,4(a0)
    8000373e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003740:	04451783          	lh	a5,68(a0)
    80003744:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003748:	04a51783          	lh	a5,74(a0)
    8000374c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003750:	04c56783          	lwu	a5,76(a0)
    80003754:	e99c                	sd	a5,16(a1)
}
    80003756:	6422                	ld	s0,8(sp)
    80003758:	0141                	addi	sp,sp,16
    8000375a:	8082                	ret

000000008000375c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000375c:	457c                	lw	a5,76(a0)
    8000375e:	0ed7eb63          	bltu	a5,a3,80003854 <readi+0xf8>
{
    80003762:	7159                	addi	sp,sp,-112
    80003764:	f486                	sd	ra,104(sp)
    80003766:	f0a2                	sd	s0,96(sp)
    80003768:	eca6                	sd	s1,88(sp)
    8000376a:	e0d2                	sd	s4,64(sp)
    8000376c:	fc56                	sd	s5,56(sp)
    8000376e:	f85a                	sd	s6,48(sp)
    80003770:	f45e                	sd	s7,40(sp)
    80003772:	1880                	addi	s0,sp,112
    80003774:	8b2a                	mv	s6,a0
    80003776:	8bae                	mv	s7,a1
    80003778:	8a32                	mv	s4,a2
    8000377a:	84b6                	mv	s1,a3
    8000377c:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000377e:	9f35                	addw	a4,a4,a3
    return 0;
    80003780:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003782:	0cd76063          	bltu	a4,a3,80003842 <readi+0xe6>
    80003786:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003788:	00e7f463          	bgeu	a5,a4,80003790 <readi+0x34>
    n = ip->size - off;
    8000378c:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003790:	080a8f63          	beqz	s5,8000382e <readi+0xd2>
    80003794:	e8ca                	sd	s2,80(sp)
    80003796:	f062                	sd	s8,32(sp)
    80003798:	ec66                	sd	s9,24(sp)
    8000379a:	e86a                	sd	s10,16(sp)
    8000379c:	e46e                	sd	s11,8(sp)
    8000379e:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037a0:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037a4:	5c7d                	li	s8,-1
    800037a6:	a80d                	j	800037d8 <readi+0x7c>
    800037a8:	020d1d93          	slli	s11,s10,0x20
    800037ac:	020ddd93          	srli	s11,s11,0x20
    800037b0:	05890613          	addi	a2,s2,88
    800037b4:	86ee                	mv	a3,s11
    800037b6:	963a                	add	a2,a2,a4
    800037b8:	85d2                	mv	a1,s4
    800037ba:	855e                	mv	a0,s7
    800037bc:	b17fe0ef          	jal	800022d2 <either_copyout>
    800037c0:	05850763          	beq	a0,s8,8000380e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037c4:	854a                	mv	a0,s2
    800037c6:	dfaff0ef          	jal	80002dc0 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037ca:	013d09bb          	addw	s3,s10,s3
    800037ce:	009d04bb          	addw	s1,s10,s1
    800037d2:	9a6e                	add	s4,s4,s11
    800037d4:	0559f763          	bgeu	s3,s5,80003822 <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    800037d8:	00a4d59b          	srliw	a1,s1,0xa
    800037dc:	855a                	mv	a0,s6
    800037de:	85fff0ef          	jal	8000303c <bmap>
    800037e2:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800037e6:	c5b1                	beqz	a1,80003832 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800037e8:	000b2503          	lw	a0,0(s6)
    800037ec:	cccff0ef          	jal	80002cb8 <bread>
    800037f0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037f2:	3ff4f713          	andi	a4,s1,1023
    800037f6:	40ec87bb          	subw	a5,s9,a4
    800037fa:	413a86bb          	subw	a3,s5,s3
    800037fe:	8d3e                	mv	s10,a5
    80003800:	2781                	sext.w	a5,a5
    80003802:	0006861b          	sext.w	a2,a3
    80003806:	faf671e3          	bgeu	a2,a5,800037a8 <readi+0x4c>
    8000380a:	8d36                	mv	s10,a3
    8000380c:	bf71                	j	800037a8 <readi+0x4c>
      brelse(bp);
    8000380e:	854a                	mv	a0,s2
    80003810:	db0ff0ef          	jal	80002dc0 <brelse>
      tot = -1;
    80003814:	59fd                	li	s3,-1
      break;
    80003816:	6946                	ld	s2,80(sp)
    80003818:	7c02                	ld	s8,32(sp)
    8000381a:	6ce2                	ld	s9,24(sp)
    8000381c:	6d42                	ld	s10,16(sp)
    8000381e:	6da2                	ld	s11,8(sp)
    80003820:	a831                	j	8000383c <readi+0xe0>
    80003822:	6946                	ld	s2,80(sp)
    80003824:	7c02                	ld	s8,32(sp)
    80003826:	6ce2                	ld	s9,24(sp)
    80003828:	6d42                	ld	s10,16(sp)
    8000382a:	6da2                	ld	s11,8(sp)
    8000382c:	a801                	j	8000383c <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000382e:	89d6                	mv	s3,s5
    80003830:	a031                	j	8000383c <readi+0xe0>
    80003832:	6946                	ld	s2,80(sp)
    80003834:	7c02                	ld	s8,32(sp)
    80003836:	6ce2                	ld	s9,24(sp)
    80003838:	6d42                	ld	s10,16(sp)
    8000383a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000383c:	0009851b          	sext.w	a0,s3
    80003840:	69a6                	ld	s3,72(sp)
}
    80003842:	70a6                	ld	ra,104(sp)
    80003844:	7406                	ld	s0,96(sp)
    80003846:	64e6                	ld	s1,88(sp)
    80003848:	6a06                	ld	s4,64(sp)
    8000384a:	7ae2                	ld	s5,56(sp)
    8000384c:	7b42                	ld	s6,48(sp)
    8000384e:	7ba2                	ld	s7,40(sp)
    80003850:	6165                	addi	sp,sp,112
    80003852:	8082                	ret
    return 0;
    80003854:	4501                	li	a0,0
}
    80003856:	8082                	ret

0000000080003858 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003858:	457c                	lw	a5,76(a0)
    8000385a:	10d7e363          	bltu	a5,a3,80003960 <writei+0x108>
{
    8000385e:	7159                	addi	sp,sp,-112
    80003860:	f486                	sd	ra,104(sp)
    80003862:	f0a2                	sd	s0,96(sp)
    80003864:	e8ca                	sd	s2,80(sp)
    80003866:	e0d2                	sd	s4,64(sp)
    80003868:	fc56                	sd	s5,56(sp)
    8000386a:	f85a                	sd	s6,48(sp)
    8000386c:	f45e                	sd	s7,40(sp)
    8000386e:	1880                	addi	s0,sp,112
    80003870:	8aaa                	mv	s5,a0
    80003872:	8bae                	mv	s7,a1
    80003874:	8a32                	mv	s4,a2
    80003876:	8936                	mv	s2,a3
    80003878:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000387a:	00e687bb          	addw	a5,a3,a4
    8000387e:	0ed7e363          	bltu	a5,a3,80003964 <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003882:	00043737          	lui	a4,0x43
    80003886:	0ef76163          	bltu	a4,a5,80003968 <writei+0x110>
    8000388a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000388c:	0c0b0263          	beqz	s6,80003950 <writei+0xf8>
    80003890:	eca6                	sd	s1,88(sp)
    80003892:	f062                	sd	s8,32(sp)
    80003894:	ec66                	sd	s9,24(sp)
    80003896:	e86a                	sd	s10,16(sp)
    80003898:	e46e                	sd	s11,8(sp)
    8000389a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000389c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038a0:	5c7d                	li	s8,-1
    800038a2:	a825                	j	800038da <writei+0x82>
    800038a4:	020d1d93          	slli	s11,s10,0x20
    800038a8:	020ddd93          	srli	s11,s11,0x20
    800038ac:	05848513          	addi	a0,s1,88
    800038b0:	86ee                	mv	a3,s11
    800038b2:	8652                	mv	a2,s4
    800038b4:	85de                	mv	a1,s7
    800038b6:	953a                	add	a0,a0,a4
    800038b8:	a67fe0ef          	jal	8000231e <either_copyin>
    800038bc:	05850a63          	beq	a0,s8,80003910 <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800038c0:	8526                	mv	a0,s1
    800038c2:	6b0000ef          	jal	80003f72 <log_write>
    brelse(bp);
    800038c6:	8526                	mv	a0,s1
    800038c8:	cf8ff0ef          	jal	80002dc0 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038cc:	013d09bb          	addw	s3,s10,s3
    800038d0:	012d093b          	addw	s2,s10,s2
    800038d4:	9a6e                	add	s4,s4,s11
    800038d6:	0569f363          	bgeu	s3,s6,8000391c <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    800038da:	00a9559b          	srliw	a1,s2,0xa
    800038de:	8556                	mv	a0,s5
    800038e0:	f5cff0ef          	jal	8000303c <bmap>
    800038e4:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800038e8:	c995                	beqz	a1,8000391c <writei+0xc4>
    bp = bread(ip->dev, addr);
    800038ea:	000aa503          	lw	a0,0(s5)
    800038ee:	bcaff0ef          	jal	80002cb8 <bread>
    800038f2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800038f4:	3ff97713          	andi	a4,s2,1023
    800038f8:	40ec87bb          	subw	a5,s9,a4
    800038fc:	413b06bb          	subw	a3,s6,s3
    80003900:	8d3e                	mv	s10,a5
    80003902:	2781                	sext.w	a5,a5
    80003904:	0006861b          	sext.w	a2,a3
    80003908:	f8f67ee3          	bgeu	a2,a5,800038a4 <writei+0x4c>
    8000390c:	8d36                	mv	s10,a3
    8000390e:	bf59                	j	800038a4 <writei+0x4c>
      log_write(bp);
    80003910:	8526                	mv	a0,s1
    80003912:	660000ef          	jal	80003f72 <log_write>
      brelse(bp);
    80003916:	8526                	mv	a0,s1
    80003918:	ca8ff0ef          	jal	80002dc0 <brelse>
  }

  if (off > ip->size)
    8000391c:	04caa783          	lw	a5,76(s5)
    80003920:	0327fa63          	bgeu	a5,s2,80003954 <writei+0xfc>
    ip->size = off;
    80003924:	052aa623          	sw	s2,76(s5)
    80003928:	64e6                	ld	s1,88(sp)
    8000392a:	7c02                	ld	s8,32(sp)
    8000392c:	6ce2                	ld	s9,24(sp)
    8000392e:	6d42                	ld	s10,16(sp)
    80003930:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003932:	8556                	mv	a0,s5
    80003934:	99dff0ef          	jal	800032d0 <iupdate>

  return tot;
    80003938:	0009851b          	sext.w	a0,s3
    8000393c:	69a6                	ld	s3,72(sp)
}
    8000393e:	70a6                	ld	ra,104(sp)
    80003940:	7406                	ld	s0,96(sp)
    80003942:	6946                	ld	s2,80(sp)
    80003944:	6a06                	ld	s4,64(sp)
    80003946:	7ae2                	ld	s5,56(sp)
    80003948:	7b42                	ld	s6,48(sp)
    8000394a:	7ba2                	ld	s7,40(sp)
    8000394c:	6165                	addi	sp,sp,112
    8000394e:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003950:	89da                	mv	s3,s6
    80003952:	b7c5                	j	80003932 <writei+0xda>
    80003954:	64e6                	ld	s1,88(sp)
    80003956:	7c02                	ld	s8,32(sp)
    80003958:	6ce2                	ld	s9,24(sp)
    8000395a:	6d42                	ld	s10,16(sp)
    8000395c:	6da2                	ld	s11,8(sp)
    8000395e:	bfd1                	j	80003932 <writei+0xda>
    return -1;
    80003960:	557d                	li	a0,-1
}
    80003962:	8082                	ret
    return -1;
    80003964:	557d                	li	a0,-1
    80003966:	bfe1                	j	8000393e <writei+0xe6>
    return -1;
    80003968:	557d                	li	a0,-1
    8000396a:	bfd1                	j	8000393e <writei+0xe6>

000000008000396c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000396c:	1141                	addi	sp,sp,-16
    8000396e:	e406                	sd	ra,8(sp)
    80003970:	e022                	sd	s0,0(sp)
    80003972:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003974:	4639                	li	a2,14
    80003976:	baafd0ef          	jal	80000d20 <strncmp>
}
    8000397a:	60a2                	ld	ra,8(sp)
    8000397c:	6402                	ld	s0,0(sp)
    8000397e:	0141                	addi	sp,sp,16
    80003980:	8082                	ret

0000000080003982 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003982:	7139                	addi	sp,sp,-64
    80003984:	fc06                	sd	ra,56(sp)
    80003986:	f822                	sd	s0,48(sp)
    80003988:	f426                	sd	s1,40(sp)
    8000398a:	f04a                	sd	s2,32(sp)
    8000398c:	ec4e                	sd	s3,24(sp)
    8000398e:	e852                	sd	s4,16(sp)
    80003990:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003992:	04451703          	lh	a4,68(a0)
    80003996:	4785                	li	a5,1
    80003998:	00f71a63          	bne	a4,a5,800039ac <dirlookup+0x2a>
    8000399c:	892a                	mv	s2,a0
    8000399e:	89ae                	mv	s3,a1
    800039a0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039a2:	457c                	lw	a5,76(a0)
    800039a4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039a6:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039a8:	e39d                	bnez	a5,800039ce <dirlookup+0x4c>
    800039aa:	a095                	j	80003a0e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800039ac:	00004517          	auipc	a0,0x4
    800039b0:	b3450513          	addi	a0,a0,-1228 # 800074e0 <etext+0x4e0>
    800039b4:	e3dfc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    800039b8:	00004517          	auipc	a0,0x4
    800039bc:	b4050513          	addi	a0,a0,-1216 # 800074f8 <etext+0x4f8>
    800039c0:	e31fc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039c4:	24c1                	addiw	s1,s1,16
    800039c6:	04c92783          	lw	a5,76(s2)
    800039ca:	04f4f163          	bgeu	s1,a5,80003a0c <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ce:	4741                	li	a4,16
    800039d0:	86a6                	mv	a3,s1
    800039d2:	fc040613          	addi	a2,s0,-64
    800039d6:	4581                	li	a1,0
    800039d8:	854a                	mv	a0,s2
    800039da:	d83ff0ef          	jal	8000375c <readi>
    800039de:	47c1                	li	a5,16
    800039e0:	fcf51ce3          	bne	a0,a5,800039b8 <dirlookup+0x36>
    if (de.inum == 0)
    800039e4:	fc045783          	lhu	a5,-64(s0)
    800039e8:	dff1                	beqz	a5,800039c4 <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    800039ea:	fc240593          	addi	a1,s0,-62
    800039ee:	854e                	mv	a0,s3
    800039f0:	f7dff0ef          	jal	8000396c <namecmp>
    800039f4:	f961                	bnez	a0,800039c4 <dirlookup+0x42>
      if (poff)
    800039f6:	000a0463          	beqz	s4,800039fe <dirlookup+0x7c>
        *poff = off;
    800039fa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039fe:	fc045583          	lhu	a1,-64(s0)
    80003a02:	00092503          	lw	a0,0(s2)
    80003a06:	f0aff0ef          	jal	80003110 <iget>
    80003a0a:	a011                	j	80003a0e <dirlookup+0x8c>
  return 0;
    80003a0c:	4501                	li	a0,0
}
    80003a0e:	70e2                	ld	ra,56(sp)
    80003a10:	7442                	ld	s0,48(sp)
    80003a12:	74a2                	ld	s1,40(sp)
    80003a14:	7902                	ld	s2,32(sp)
    80003a16:	69e2                	ld	s3,24(sp)
    80003a18:	6a42                	ld	s4,16(sp)
    80003a1a:	6121                	addi	sp,sp,64
    80003a1c:	8082                	ret

0000000080003a1e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a1e:	711d                	addi	sp,sp,-96
    80003a20:	ec86                	sd	ra,88(sp)
    80003a22:	e8a2                	sd	s0,80(sp)
    80003a24:	e4a6                	sd	s1,72(sp)
    80003a26:	e0ca                	sd	s2,64(sp)
    80003a28:	fc4e                	sd	s3,56(sp)
    80003a2a:	f852                	sd	s4,48(sp)
    80003a2c:	f456                	sd	s5,40(sp)
    80003a2e:	f05a                	sd	s6,32(sp)
    80003a30:	ec5e                	sd	s7,24(sp)
    80003a32:	e862                	sd	s8,16(sp)
    80003a34:	e466                	sd	s9,8(sp)
    80003a36:	1080                	addi	s0,sp,96
    80003a38:	84aa                	mv	s1,a0
    80003a3a:	8b2e                	mv	s6,a1
    80003a3c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a3e:	00054703          	lbu	a4,0(a0)
    80003a42:	02f00793          	li	a5,47
    80003a46:	00f70e63          	beq	a4,a5,80003a62 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a4a:	e5bfd0ef          	jal	800018a4 <myproc>
    80003a4e:	15053503          	ld	a0,336(a0)
    80003a52:	8fdff0ef          	jal	8000334e <idup>
    80003a56:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003a58:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003a5c:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003a5e:	4b85                	li	s7,1
    80003a60:	a075                	j	80003b0c <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    80003a62:	4585                	li	a1,1
    80003a64:	4505                	li	a0,1
    80003a66:	eaaff0ef          	jal	80003110 <iget>
    80003a6a:	8a2a                	mv	s4,a0
    80003a6c:	b7f5                	j	80003a58 <namex+0x3a>
      iunlockput(ip);
    80003a6e:	8552                	mv	a0,s4
    80003a70:	b67ff0ef          	jal	800035d6 <iunlockput>
      return 0;
    80003a74:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a76:	8552                	mv	a0,s4
    80003a78:	60e6                	ld	ra,88(sp)
    80003a7a:	6446                	ld	s0,80(sp)
    80003a7c:	64a6                	ld	s1,72(sp)
    80003a7e:	6906                	ld	s2,64(sp)
    80003a80:	79e2                	ld	s3,56(sp)
    80003a82:	7a42                	ld	s4,48(sp)
    80003a84:	7aa2                	ld	s5,40(sp)
    80003a86:	7b02                	ld	s6,32(sp)
    80003a88:	6be2                	ld	s7,24(sp)
    80003a8a:	6c42                	ld	s8,16(sp)
    80003a8c:	6ca2                	ld	s9,8(sp)
    80003a8e:	6125                	addi	sp,sp,96
    80003a90:	8082                	ret
      iunlockput(ip);
    80003a92:	8552                	mv	a0,s4
    80003a94:	b43ff0ef          	jal	800035d6 <iunlockput>
      return 0;
    80003a98:	4a01                	li	s4,0
    80003a9a:	bff1                	j	80003a76 <namex+0x58>
      iunlock(ip);
    80003a9c:	8552                	mv	a0,s4
    80003a9e:	995ff0ef          	jal	80003432 <iunlock>
      return ip;
    80003aa2:	bfd1                	j	80003a76 <namex+0x58>
      iunlockput(ip);
    80003aa4:	8552                	mv	a0,s4
    80003aa6:	b31ff0ef          	jal	800035d6 <iunlockput>
      return 0;
    80003aaa:	8a4e                	mv	s4,s3
    80003aac:	b7e9                	j	80003a76 <namex+0x58>
  len = path - s;
    80003aae:	40998633          	sub	a2,s3,s1
    80003ab2:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    80003ab6:	099c5363          	bge	s8,s9,80003b3c <namex+0x11e>
    memmove(name, s, DIRSIZ);
    80003aba:	4639                	li	a2,14
    80003abc:	85a6                	mv	a1,s1
    80003abe:	8556                	mv	a0,s5
    80003ac0:	9f0fd0ef          	jal	80000cb0 <memmove>
    80003ac4:	84ce                	mv	s1,s3
  while (*path == '/')
    80003ac6:	0004c783          	lbu	a5,0(s1)
    80003aca:	01279763          	bne	a5,s2,80003ad8 <namex+0xba>
    path++;
    80003ace:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ad0:	0004c783          	lbu	a5,0(s1)
    80003ad4:	ff278de3          	beq	a5,s2,80003ace <namex+0xb0>
    ilock(ip);
    80003ad8:	8552                	mv	a0,s4
    80003ada:	8abff0ef          	jal	80003384 <ilock>
    if (ip->type != T_DIR) {
    80003ade:	044a1783          	lh	a5,68(s4)
    80003ae2:	f97796e3          	bne	a5,s7,80003a6e <namex+0x50>
    if (ip->nlink == 0) {
    80003ae6:	04aa1783          	lh	a5,74(s4)
    80003aea:	d7c5                	beqz	a5,80003a92 <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003aec:	000b0563          	beqz	s6,80003af6 <namex+0xd8>
    80003af0:	0004c783          	lbu	a5,0(s1)
    80003af4:	d7c5                	beqz	a5,80003a9c <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003af6:	4601                	li	a2,0
    80003af8:	85d6                	mv	a1,s5
    80003afa:	8552                	mv	a0,s4
    80003afc:	e87ff0ef          	jal	80003982 <dirlookup>
    80003b00:	89aa                	mv	s3,a0
    80003b02:	d14d                	beqz	a0,80003aa4 <namex+0x86>
    iunlockput(ip);
    80003b04:	8552                	mv	a0,s4
    80003b06:	ad1ff0ef          	jal	800035d6 <iunlockput>
    ip = next;
    80003b0a:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003b0c:	0004c783          	lbu	a5,0(s1)
    80003b10:	01279763          	bne	a5,s2,80003b1e <namex+0x100>
    path++;
    80003b14:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b16:	0004c783          	lbu	a5,0(s1)
    80003b1a:	ff278de3          	beq	a5,s2,80003b14 <namex+0xf6>
  if (*path == 0)
    80003b1e:	cb8d                	beqz	a5,80003b50 <namex+0x132>
  while (*path != '/' && *path != 0)
    80003b20:	0004c783          	lbu	a5,0(s1)
    80003b24:	89a6                	mv	s3,s1
  len = path - s;
    80003b26:	4c81                	li	s9,0
    80003b28:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003b2a:	01278963          	beq	a5,s2,80003b3c <namex+0x11e>
    80003b2e:	d3c1                	beqz	a5,80003aae <namex+0x90>
    path++;
    80003b30:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003b32:	0009c783          	lbu	a5,0(s3)
    80003b36:	ff279ce3          	bne	a5,s2,80003b2e <namex+0x110>
    80003b3a:	bf95                	j	80003aae <namex+0x90>
    memmove(name, s, len);
    80003b3c:	2601                	sext.w	a2,a2
    80003b3e:	85a6                	mv	a1,s1
    80003b40:	8556                	mv	a0,s5
    80003b42:	96efd0ef          	jal	80000cb0 <memmove>
    name[len] = 0;
    80003b46:	9cd6                	add	s9,s9,s5
    80003b48:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b4c:	84ce                	mv	s1,s3
    80003b4e:	bfa5                	j	80003ac6 <namex+0xa8>
  if (nameiparent) {
    80003b50:	f20b03e3          	beqz	s6,80003a76 <namex+0x58>
    iput(ip);
    80003b54:	8552                	mv	a0,s4
    80003b56:	9b1ff0ef          	jal	80003506 <iput>
    return 0;
    80003b5a:	4a01                	li	s4,0
    80003b5c:	bf29                	j	80003a76 <namex+0x58>

0000000080003b5e <dirlink>:
{
    80003b5e:	7139                	addi	sp,sp,-64
    80003b60:	fc06                	sd	ra,56(sp)
    80003b62:	f822                	sd	s0,48(sp)
    80003b64:	f04a                	sd	s2,32(sp)
    80003b66:	ec4e                	sd	s3,24(sp)
    80003b68:	e852                	sd	s4,16(sp)
    80003b6a:	0080                	addi	s0,sp,64
    80003b6c:	892a                	mv	s2,a0
    80003b6e:	8a2e                	mv	s4,a1
    80003b70:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b72:	4601                	li	a2,0
    80003b74:	e0fff0ef          	jal	80003982 <dirlookup>
    80003b78:	e535                	bnez	a0,80003be4 <dirlink+0x86>
    80003b7a:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b7c:	04c92483          	lw	s1,76(s2)
    80003b80:	c48d                	beqz	s1,80003baa <dirlink+0x4c>
    80003b82:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b84:	4741                	li	a4,16
    80003b86:	86a6                	mv	a3,s1
    80003b88:	fc040613          	addi	a2,s0,-64
    80003b8c:	4581                	li	a1,0
    80003b8e:	854a                	mv	a0,s2
    80003b90:	bcdff0ef          	jal	8000375c <readi>
    80003b94:	47c1                	li	a5,16
    80003b96:	04f51b63          	bne	a0,a5,80003bec <dirlink+0x8e>
    if (de.inum == 0)
    80003b9a:	fc045783          	lhu	a5,-64(s0)
    80003b9e:	c791                	beqz	a5,80003baa <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ba0:	24c1                	addiw	s1,s1,16
    80003ba2:	04c92783          	lw	a5,76(s2)
    80003ba6:	fcf4efe3          	bltu	s1,a5,80003b84 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003baa:	4639                	li	a2,14
    80003bac:	85d2                	mv	a1,s4
    80003bae:	fc240513          	addi	a0,s0,-62
    80003bb2:	9a4fd0ef          	jal	80000d56 <strncpy>
  de.inum = inum;
    80003bb6:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bba:	4741                	li	a4,16
    80003bbc:	86a6                	mv	a3,s1
    80003bbe:	fc040613          	addi	a2,s0,-64
    80003bc2:	4581                	li	a1,0
    80003bc4:	854a                	mv	a0,s2
    80003bc6:	c93ff0ef          	jal	80003858 <writei>
    80003bca:	1541                	addi	a0,a0,-16
    80003bcc:	00a03533          	snez	a0,a0
    80003bd0:	40a00533          	neg	a0,a0
    80003bd4:	74a2                	ld	s1,40(sp)
}
    80003bd6:	70e2                	ld	ra,56(sp)
    80003bd8:	7442                	ld	s0,48(sp)
    80003bda:	7902                	ld	s2,32(sp)
    80003bdc:	69e2                	ld	s3,24(sp)
    80003bde:	6a42                	ld	s4,16(sp)
    80003be0:	6121                	addi	sp,sp,64
    80003be2:	8082                	ret
    iput(ip);
    80003be4:	923ff0ef          	jal	80003506 <iput>
    return -1;
    80003be8:	557d                	li	a0,-1
    80003bea:	b7f5                	j	80003bd6 <dirlink+0x78>
      panic("dirlink read");
    80003bec:	00004517          	auipc	a0,0x4
    80003bf0:	91c50513          	addi	a0,a0,-1764 # 80007508 <etext+0x508>
    80003bf4:	bfdfc0ef          	jal	800007f0 <panic>

0000000080003bf8 <namei>:

struct inode *
namei(char *path)
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c00:	fe040613          	addi	a2,s0,-32
    80003c04:	4581                	li	a1,0
    80003c06:	e19ff0ef          	jal	80003a1e <namex>
}
    80003c0a:	60e2                	ld	ra,24(sp)
    80003c0c:	6442                	ld	s0,16(sp)
    80003c0e:	6105                	addi	sp,sp,32
    80003c10:	8082                	ret

0000000080003c12 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c12:	1141                	addi	sp,sp,-16
    80003c14:	e406                	sd	ra,8(sp)
    80003c16:	e022                	sd	s0,0(sp)
    80003c18:	0800                	addi	s0,sp,16
    80003c1a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c1c:	4585                	li	a1,1
    80003c1e:	e01ff0ef          	jal	80003a1e <namex>
}
    80003c22:	60a2                	ld	ra,8(sp)
    80003c24:	6402                	ld	s0,0(sp)
    80003c26:	0141                	addi	sp,sp,16
    80003c28:	8082                	ret

0000000080003c2a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c2a:	1101                	addi	sp,sp,-32
    80003c2c:	ec06                	sd	ra,24(sp)
    80003c2e:	e822                	sd	s0,16(sp)
    80003c30:	e426                	sd	s1,8(sp)
    80003c32:	e04a                	sd	s2,0(sp)
    80003c34:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c36:	0001c917          	auipc	s2,0x1c
    80003c3a:	38a90913          	addi	s2,s2,906 # 8001ffc0 <log>
    80003c3e:	01892583          	lw	a1,24(s2)
    80003c42:	02492503          	lw	a0,36(s2)
    80003c46:	872ff0ef          	jal	80002cb8 <bread>
    80003c4a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c4c:	02c92603          	lw	a2,44(s2)
    80003c50:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c52:	00c05f63          	blez	a2,80003c70 <write_head+0x46>
    80003c56:	0001c717          	auipc	a4,0x1c
    80003c5a:	39a70713          	addi	a4,a4,922 # 8001fff0 <log+0x30>
    80003c5e:	87aa                	mv	a5,a0
    80003c60:	060a                	slli	a2,a2,0x2
    80003c62:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c64:	4314                	lw	a3,0(a4)
    80003c66:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c68:	0711                	addi	a4,a4,4
    80003c6a:	0791                	addi	a5,a5,4
    80003c6c:	fec79ce3          	bne	a5,a2,80003c64 <write_head+0x3a>
  }
  bwrite(buf);
    80003c70:	8526                	mv	a0,s1
    80003c72:	91cff0ef          	jal	80002d8e <bwrite>
  brelse(buf);
    80003c76:	8526                	mv	a0,s1
    80003c78:	948ff0ef          	jal	80002dc0 <brelse>
}
    80003c7c:	60e2                	ld	ra,24(sp)
    80003c7e:	6442                	ld	s0,16(sp)
    80003c80:	64a2                	ld	s1,8(sp)
    80003c82:	6902                	ld	s2,0(sp)
    80003c84:	6105                	addi	sp,sp,32
    80003c86:	8082                	ret

0000000080003c88 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c88:	0001c797          	auipc	a5,0x1c
    80003c8c:	3647a783          	lw	a5,868(a5) # 8001ffec <log+0x2c>
    80003c90:	0af05e63          	blez	a5,80003d4c <install_trans+0xc4>
{
    80003c94:	715d                	addi	sp,sp,-80
    80003c96:	e486                	sd	ra,72(sp)
    80003c98:	e0a2                	sd	s0,64(sp)
    80003c9a:	fc26                	sd	s1,56(sp)
    80003c9c:	f84a                	sd	s2,48(sp)
    80003c9e:	f44e                	sd	s3,40(sp)
    80003ca0:	f052                	sd	s4,32(sp)
    80003ca2:	ec56                	sd	s5,24(sp)
    80003ca4:	e85a                	sd	s6,16(sp)
    80003ca6:	e45e                	sd	s7,8(sp)
    80003ca8:	0880                	addi	s0,sp,80
    80003caa:	8b2a                	mv	s6,a0
    80003cac:	0001ca97          	auipc	s5,0x1c
    80003cb0:	344a8a93          	addi	s5,s5,836 # 8001fff0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cb4:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cb6:	00004b97          	auipc	s7,0x4
    80003cba:	862b8b93          	addi	s7,s7,-1950 # 80007518 <etext+0x518>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cbe:	0001ca17          	auipc	s4,0x1c
    80003cc2:	302a0a13          	addi	s4,s4,770 # 8001ffc0 <log>
    80003cc6:	a025                	j	80003cee <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cc8:	000aa603          	lw	a2,0(s5)
    80003ccc:	85ce                	mv	a1,s3
    80003cce:	855e                	mv	a0,s7
    80003cd0:	83bfc0ef          	jal	8000050a <printk>
    80003cd4:	a839                	j	80003cf2 <install_trans+0x6a>
    brelse(lbuf);
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	8e8ff0ef          	jal	80002dc0 <brelse>
    brelse(dbuf);
    80003cdc:	8526                	mv	a0,s1
    80003cde:	8e2ff0ef          	jal	80002dc0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ce2:	2985                	addiw	s3,s3,1
    80003ce4:	0a91                	addi	s5,s5,4
    80003ce6:	02ca2783          	lw	a5,44(s4)
    80003cea:	04f9d663          	bge	s3,a5,80003d36 <install_trans+0xae>
    if (recovering) {
    80003cee:	fc0b1de3          	bnez	s6,80003cc8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cf2:	018a2583          	lw	a1,24(s4)
    80003cf6:	013585bb          	addw	a1,a1,s3
    80003cfa:	2585                	addiw	a1,a1,1
    80003cfc:	024a2503          	lw	a0,36(s4)
    80003d00:	fb9fe0ef          	jal	80002cb8 <bread>
    80003d04:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d06:	000aa583          	lw	a1,0(s5)
    80003d0a:	024a2503          	lw	a0,36(s4)
    80003d0e:	fabfe0ef          	jal	80002cb8 <bread>
    80003d12:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d14:	40000613          	li	a2,1024
    80003d18:	05890593          	addi	a1,s2,88
    80003d1c:	05850513          	addi	a0,a0,88
    80003d20:	f91fc0ef          	jal	80000cb0 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003d24:	8526                	mv	a0,s1
    80003d26:	868ff0ef          	jal	80002d8e <bwrite>
    if (recovering == 0)
    80003d2a:	fa0b16e3          	bnez	s6,80003cd6 <install_trans+0x4e>
      bunpin(dbuf);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	94cff0ef          	jal	80002e7c <bunpin>
    80003d34:	b74d                	j	80003cd6 <install_trans+0x4e>
}
    80003d36:	60a6                	ld	ra,72(sp)
    80003d38:	6406                	ld	s0,64(sp)
    80003d3a:	74e2                	ld	s1,56(sp)
    80003d3c:	7942                	ld	s2,48(sp)
    80003d3e:	79a2                	ld	s3,40(sp)
    80003d40:	7a02                	ld	s4,32(sp)
    80003d42:	6ae2                	ld	s5,24(sp)
    80003d44:	6b42                	ld	s6,16(sp)
    80003d46:	6ba2                	ld	s7,8(sp)
    80003d48:	6161                	addi	sp,sp,80
    80003d4a:	8082                	ret
    80003d4c:	8082                	ret

0000000080003d4e <initlog>:
{
    80003d4e:	7179                	addi	sp,sp,-48
    80003d50:	f406                	sd	ra,40(sp)
    80003d52:	f022                	sd	s0,32(sp)
    80003d54:	ec26                	sd	s1,24(sp)
    80003d56:	e84a                	sd	s2,16(sp)
    80003d58:	e44e                	sd	s3,8(sp)
    80003d5a:	1800                	addi	s0,sp,48
    80003d5c:	892a                	mv	s2,a0
    80003d5e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d60:	0001c497          	auipc	s1,0x1c
    80003d64:	26048493          	addi	s1,s1,608 # 8001ffc0 <log>
    80003d68:	00003597          	auipc	a1,0x3
    80003d6c:	7d058593          	addi	a1,a1,2000 # 80007538 <etext+0x538>
    80003d70:	8526                	mv	a0,s1
    80003d72:	da9fc0ef          	jal	80000b1a <initlock>
  log.start = sb->logstart;
    80003d76:	0149a583          	lw	a1,20(s3)
    80003d7a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d7c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d80:	854a                	mv	a0,s2
    80003d82:	f37fe0ef          	jal	80002cb8 <bread>
  log.lh.n = lh->n;
    80003d86:	4d30                	lw	a2,88(a0)
    80003d88:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d8a:	00c05f63          	blez	a2,80003da8 <initlog+0x5a>
    80003d8e:	87aa                	mv	a5,a0
    80003d90:	0001c717          	auipc	a4,0x1c
    80003d94:	26070713          	addi	a4,a4,608 # 8001fff0 <log+0x30>
    80003d98:	060a                	slli	a2,a2,0x2
    80003d9a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d9c:	4ff4                	lw	a3,92(a5)
    80003d9e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003da0:	0791                	addi	a5,a5,4
    80003da2:	0711                	addi	a4,a4,4
    80003da4:	fec79ce3          	bne	a5,a2,80003d9c <initlog+0x4e>
  brelse(buf);
    80003da8:	818ff0ef          	jal	80002dc0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003dac:	4505                	li	a0,1
    80003dae:	edbff0ef          	jal	80003c88 <install_trans>
  log.lh.n = 0;
    80003db2:	0001c797          	auipc	a5,0x1c
    80003db6:	2207ad23          	sw	zero,570(a5) # 8001ffec <log+0x2c>
  write_head(); // clear the log
    80003dba:	e71ff0ef          	jal	80003c2a <write_head>
}
    80003dbe:	70a2                	ld	ra,40(sp)
    80003dc0:	7402                	ld	s0,32(sp)
    80003dc2:	64e2                	ld	s1,24(sp)
    80003dc4:	6942                	ld	s2,16(sp)
    80003dc6:	69a2                	ld	s3,8(sp)
    80003dc8:	6145                	addi	sp,sp,48
    80003dca:	8082                	ret

0000000080003dcc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dd8:	0001c517          	auipc	a0,0x1c
    80003ddc:	1e850513          	addi	a0,a0,488 # 8001ffc0 <log>
    80003de0:	db1fc0ef          	jal	80000b90 <acquire>
  while (1) {
    if (log.committing) {
    80003de4:	0001c497          	auipc	s1,0x1c
    80003de8:	1dc48493          	addi	s1,s1,476 # 8001ffc0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003dec:	4979                	li	s2,30
    80003dee:	a821                	j	80003e06 <begin_op+0x3a>
      sleep_prepare(&log);
    80003df0:	8526                	mv	a0,s1
    80003df2:	92efe0ef          	jal	80001f20 <sleep_prepare>
      release(&log.lock);
    80003df6:	8526                	mv	a0,s1
    80003df8:	e25fc0ef          	jal	80000c1c <release>
      sleep();
    80003dfc:	960fe0ef          	jal	80001f5c <sleep>
      acquire(&log.lock);
    80003e00:	8526                	mv	a0,s1
    80003e02:	d8ffc0ef          	jal	80000b90 <acquire>
    if (log.committing) {
    80003e06:	509c                	lw	a5,32(s1)
    80003e08:	f7e5                	bnez	a5,80003df0 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e0a:	4cd8                	lw	a4,28(s1)
    80003e0c:	2705                	addiw	a4,a4,1
    80003e0e:	0027179b          	slliw	a5,a4,0x2
    80003e12:	9fb9                	addw	a5,a5,a4
    80003e14:	0017979b          	slliw	a5,a5,0x1
    80003e18:	54d4                	lw	a3,44(s1)
    80003e1a:	9fb5                	addw	a5,a5,a3
    80003e1c:	00f95e63          	bge	s2,a5,80003e38 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003e20:	8526                	mv	a0,s1
    80003e22:	8fefe0ef          	jal	80001f20 <sleep_prepare>
      release(&log.lock);
    80003e26:	8526                	mv	a0,s1
    80003e28:	df5fc0ef          	jal	80000c1c <release>
      sleep();
    80003e2c:	930fe0ef          	jal	80001f5c <sleep>
      acquire(&log.lock);
    80003e30:	8526                	mv	a0,s1
    80003e32:	d5ffc0ef          	jal	80000b90 <acquire>
    80003e36:	bfc1                	j	80003e06 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e38:	0001c517          	auipc	a0,0x1c
    80003e3c:	18850513          	addi	a0,a0,392 # 8001ffc0 <log>
    80003e40:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003e42:	ddbfc0ef          	jal	80000c1c <release>
      break;
    }
  }
}
    80003e46:	60e2                	ld	ra,24(sp)
    80003e48:	6442                	ld	s0,16(sp)
    80003e4a:	64a2                	ld	s1,8(sp)
    80003e4c:	6902                	ld	s2,0(sp)
    80003e4e:	6105                	addi	sp,sp,32
    80003e50:	8082                	ret

0000000080003e52 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e52:	7139                	addi	sp,sp,-64
    80003e54:	fc06                	sd	ra,56(sp)
    80003e56:	f822                	sd	s0,48(sp)
    80003e58:	f426                	sd	s1,40(sp)
    80003e5a:	f04a                	sd	s2,32(sp)
    80003e5c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e5e:	0001c497          	auipc	s1,0x1c
    80003e62:	16248493          	addi	s1,s1,354 # 8001ffc0 <log>
    80003e66:	8526                	mv	a0,s1
    80003e68:	d29fc0ef          	jal	80000b90 <acquire>
  log.outstanding -= 1;
    80003e6c:	4cdc                	lw	a5,28(s1)
    80003e6e:	37fd                	addiw	a5,a5,-1
    80003e70:	0007891b          	sext.w	s2,a5
    80003e74:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003e76:	509c                	lw	a5,32(s1)
    80003e78:	e3b1                	bnez	a5,80003ebc <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003e7a:	04091a63          	bnez	s2,80003ece <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003e7e:	0001c497          	auipc	s1,0x1c
    80003e82:	14248493          	addi	s1,s1,322 # 8001ffc0 <log>
    80003e86:	4785                	li	a5,1
    80003e88:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	d91fc0ef          	jal	80000c1c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e90:	54dc                	lw	a5,44(s1)
    80003e92:	04f04e63          	bgtz	a5,80003eee <end_op+0x9c>
    acquire(&log.lock);
    80003e96:	0001c497          	auipc	s1,0x1c
    80003e9a:	12a48493          	addi	s1,s1,298 # 8001ffc0 <log>
    80003e9e:	8526                	mv	a0,s1
    80003ea0:	cf1fc0ef          	jal	80000b90 <acquire>
    log.committing = 0;
    80003ea4:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003ea8:	549c                	lw	a5,40(s1)
    80003eaa:	2785                	addiw	a5,a5,1
    80003eac:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	8dcfe0ef          	jal	80001f8c <wakeup>
    release(&log.lock);
    80003eb4:	8526                	mv	a0,s1
    80003eb6:	d67fc0ef          	jal	80000c1c <release>
}
    80003eba:	a025                	j	80003ee2 <end_op+0x90>
    80003ebc:	ec4e                	sd	s3,24(sp)
    80003ebe:	e852                	sd	s4,16(sp)
    80003ec0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ec2:	00003517          	auipc	a0,0x3
    80003ec6:	67e50513          	addi	a0,a0,1662 # 80007540 <etext+0x540>
    80003eca:	927fc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80003ece:	0001c497          	auipc	s1,0x1c
    80003ed2:	0f248493          	addi	s1,s1,242 # 8001ffc0 <log>
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	8b4fe0ef          	jal	80001f8c <wakeup>
  release(&log.lock);
    80003edc:	8526                	mv	a0,s1
    80003ede:	d3ffc0ef          	jal	80000c1c <release>
}
    80003ee2:	70e2                	ld	ra,56(sp)
    80003ee4:	7442                	ld	s0,48(sp)
    80003ee6:	74a2                	ld	s1,40(sp)
    80003ee8:	7902                	ld	s2,32(sp)
    80003eea:	6121                	addi	sp,sp,64
    80003eec:	8082                	ret
    80003eee:	ec4e                	sd	s3,24(sp)
    80003ef0:	e852                	sd	s4,16(sp)
    80003ef2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef4:	0001ca97          	auipc	s5,0x1c
    80003ef8:	0fca8a93          	addi	s5,s5,252 # 8001fff0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003efc:	0001ca17          	auipc	s4,0x1c
    80003f00:	0c4a0a13          	addi	s4,s4,196 # 8001ffc0 <log>
    80003f04:	018a2583          	lw	a1,24(s4)
    80003f08:	012585bb          	addw	a1,a1,s2
    80003f0c:	2585                	addiw	a1,a1,1
    80003f0e:	024a2503          	lw	a0,36(s4)
    80003f12:	da7fe0ef          	jal	80002cb8 <bread>
    80003f16:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f18:	000aa583          	lw	a1,0(s5)
    80003f1c:	024a2503          	lw	a0,36(s4)
    80003f20:	d99fe0ef          	jal	80002cb8 <bread>
    80003f24:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f26:	40000613          	li	a2,1024
    80003f2a:	05850593          	addi	a1,a0,88
    80003f2e:	05848513          	addi	a0,s1,88
    80003f32:	d7ffc0ef          	jal	80000cb0 <memmove>
    bwrite(to); // write the log
    80003f36:	8526                	mv	a0,s1
    80003f38:	e57fe0ef          	jal	80002d8e <bwrite>
    brelse(from);
    80003f3c:	854e                	mv	a0,s3
    80003f3e:	e83fe0ef          	jal	80002dc0 <brelse>
    brelse(to);
    80003f42:	8526                	mv	a0,s1
    80003f44:	e7dfe0ef          	jal	80002dc0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f48:	2905                	addiw	s2,s2,1
    80003f4a:	0a91                	addi	s5,s5,4
    80003f4c:	02ca2783          	lw	a5,44(s4)
    80003f50:	faf94ae3          	blt	s2,a5,80003f04 <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f54:	cd7ff0ef          	jal	80003c2a <write_head>
    install_trans(0); // Now install writes to home locations
    80003f58:	4501                	li	a0,0
    80003f5a:	d2fff0ef          	jal	80003c88 <install_trans>
    log.lh.n = 0;
    80003f5e:	0001c797          	auipc	a5,0x1c
    80003f62:	0807a723          	sw	zero,142(a5) # 8001ffec <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f66:	cc5ff0ef          	jal	80003c2a <write_head>
    80003f6a:	69e2                	ld	s3,24(sp)
    80003f6c:	6a42                	ld	s4,16(sp)
    80003f6e:	6aa2                	ld	s5,8(sp)
    80003f70:	b71d                	j	80003e96 <end_op+0x44>

0000000080003f72 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f72:	1101                	addi	sp,sp,-32
    80003f74:	ec06                	sd	ra,24(sp)
    80003f76:	e822                	sd	s0,16(sp)
    80003f78:	e426                	sd	s1,8(sp)
    80003f7a:	e04a                	sd	s2,0(sp)
    80003f7c:	1000                	addi	s0,sp,32
    80003f7e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f80:	0001c917          	auipc	s2,0x1c
    80003f84:	04090913          	addi	s2,s2,64 # 8001ffc0 <log>
    80003f88:	854a                	mv	a0,s2
    80003f8a:	c07fc0ef          	jal	80000b90 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f8e:	02c92603          	lw	a2,44(s2)
    80003f92:	47f5                	li	a5,29
    80003f94:	04c7cc63          	blt	a5,a2,80003fec <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f98:	0001c797          	auipc	a5,0x1c
    80003f9c:	0447a783          	lw	a5,68(a5) # 8001ffdc <log+0x1c>
    80003fa0:	04f05c63          	blez	a5,80003ff8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fa4:	4781                	li	a5,0
    80003fa6:	04c05f63          	blez	a2,80004004 <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003faa:	44cc                	lw	a1,12(s1)
    80003fac:	0001c717          	auipc	a4,0x1c
    80003fb0:	04470713          	addi	a4,a4,68 # 8001fff0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003fb4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fb6:	4314                	lw	a3,0(a4)
    80003fb8:	04b68663          	beq	a3,a1,80004004 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003fbc:	2785                	addiw	a5,a5,1
    80003fbe:	0711                	addi	a4,a4,4
    80003fc0:	fef61be3          	bne	a2,a5,80003fb6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fc4:	0621                	addi	a2,a2,8
    80003fc6:	060a                	slli	a2,a2,0x2
    80003fc8:	0001c797          	auipc	a5,0x1c
    80003fcc:	ff878793          	addi	a5,a5,-8 # 8001ffc0 <log>
    80003fd0:	97b2                	add	a5,a5,a2
    80003fd2:	44d8                	lw	a4,12(s1)
    80003fd4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	e71fe0ef          	jal	80002e48 <bpin>
    log.lh.n++;
    80003fdc:	0001c717          	auipc	a4,0x1c
    80003fe0:	fe470713          	addi	a4,a4,-28 # 8001ffc0 <log>
    80003fe4:	575c                	lw	a5,44(a4)
    80003fe6:	2785                	addiw	a5,a5,1
    80003fe8:	d75c                	sw	a5,44(a4)
    80003fea:	a80d                	j	8000401c <log_write+0xaa>
    panic("too big a transaction");
    80003fec:	00003517          	auipc	a0,0x3
    80003ff0:	56450513          	addi	a0,a0,1380 # 80007550 <etext+0x550>
    80003ff4:	ffcfc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    80003ff8:	00003517          	auipc	a0,0x3
    80003ffc:	57050513          	addi	a0,a0,1392 # 80007568 <etext+0x568>
    80004000:	ff0fc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    80004004:	00878693          	addi	a3,a5,8
    80004008:	068a                	slli	a3,a3,0x2
    8000400a:	0001c717          	auipc	a4,0x1c
    8000400e:	fb670713          	addi	a4,a4,-74 # 8001ffc0 <log>
    80004012:	9736                	add	a4,a4,a3
    80004014:	44d4                	lw	a3,12(s1)
    80004016:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004018:	faf60fe3          	beq	a2,a5,80003fd6 <log_write+0x64>
  }
  release(&log.lock);
    8000401c:	0001c517          	auipc	a0,0x1c
    80004020:	fa450513          	addi	a0,a0,-92 # 8001ffc0 <log>
    80004024:	bf9fc0ef          	jal	80000c1c <release>
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret

0000000080004034 <sys_sync>:

uint64
sys_sync(void)
{
    80004034:	1101                	addi	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	e426                	sd	s1,8(sp)
    8000403c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000403e:	0001c497          	auipc	s1,0x1c
    80004042:	f8248493          	addi	s1,s1,-126 # 8001ffc0 <log>
    80004046:	8526                	mv	a0,s1
    80004048:	b49fc0ef          	jal	80000b90 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000404c:	509c                	lw	a5,32(s1)
    8000404e:	e799                	bnez	a5,8000405c <sys_sync+0x28>
    80004050:	0001c797          	auipc	a5,0x1c
    80004054:	f8c7a783          	lw	a5,-116(a5) # 8001ffdc <log+0x1c>
    80004058:	02f05a63          	blez	a5,8000408c <sys_sync+0x58>
    8000405c:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    8000405e:	0001c917          	auipc	s2,0x1c
    80004062:	f8a92903          	lw	s2,-118(s2) # 8001ffe8 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004066:	0001c497          	auipc	s1,0x1c
    8000406a:	f5a48493          	addi	s1,s1,-166 # 8001ffc0 <log>
    8000406e:	8526                	mv	a0,s1
    80004070:	eb1fd0ef          	jal	80001f20 <sleep_prepare>
      release(&log.lock);
    80004074:	8526                	mv	a0,s1
    80004076:	ba7fc0ef          	jal	80000c1c <release>
      sleep();
    8000407a:	ee3fd0ef          	jal	80001f5c <sleep>
      acquire(&log.lock);
    8000407e:	8526                	mv	a0,s1
    80004080:	b11fc0ef          	jal	80000b90 <acquire>
    while (log.ncommit < n) {
    80004084:	549c                	lw	a5,40(s1)
    80004086:	fef954e3          	bge	s2,a5,8000406e <sys_sync+0x3a>
    8000408a:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    8000408c:	0001c517          	auipc	a0,0x1c
    80004090:	f3450513          	addi	a0,a0,-204 # 8001ffc0 <log>
    80004094:	b89fc0ef          	jal	80000c1c <release>
  return 0;
}
    80004098:	4501                	li	a0,0
    8000409a:	60e2                	ld	ra,24(sp)
    8000409c:	6442                	ld	s0,16(sp)
    8000409e:	64a2                	ld	s1,8(sp)
    800040a0:	6105                	addi	sp,sp,32
    800040a2:	8082                	ret

00000000800040a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040a4:	1101                	addi	sp,sp,-32
    800040a6:	ec06                	sd	ra,24(sp)
    800040a8:	e822                	sd	s0,16(sp)
    800040aa:	e426                	sd	s1,8(sp)
    800040ac:	e04a                	sd	s2,0(sp)
    800040ae:	1000                	addi	s0,sp,32
    800040b0:	84aa                	mv	s1,a0
    800040b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040b4:	00003597          	auipc	a1,0x3
    800040b8:	4d458593          	addi	a1,a1,1236 # 80007588 <etext+0x588>
    800040bc:	0521                	addi	a0,a0,8
    800040be:	a5dfc0ef          	jal	80000b1a <initlock>
  lk->name = name;
    800040c2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040ca:	0204a423          	sw	zero,40(s1)
}
    800040ce:	60e2                	ld	ra,24(sp)
    800040d0:	6442                	ld	s0,16(sp)
    800040d2:	64a2                	ld	s1,8(sp)
    800040d4:	6902                	ld	s2,0(sp)
    800040d6:	6105                	addi	sp,sp,32
    800040d8:	8082                	ret

00000000800040da <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    800040e4:	1000                	addi	s0,sp,32
    800040e6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e8:	00850913          	addi	s2,a0,8
    800040ec:	854a                	mv	a0,s2
    800040ee:	aa3fc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    800040f2:	409c                	lw	a5,0(s1)
    800040f4:	cf91                	beqz	a5,80004110 <acquiresleep+0x36>
    sleep_prepare(lk);
    800040f6:	8526                	mv	a0,s1
    800040f8:	e29fd0ef          	jal	80001f20 <sleep_prepare>
    release(&lk->lk);
    800040fc:	854a                	mv	a0,s2
    800040fe:	b1ffc0ef          	jal	80000c1c <release>
    sleep();
    80004102:	e5bfd0ef          	jal	80001f5c <sleep>
    acquire(&lk->lk);
    80004106:	854a                	mv	a0,s2
    80004108:	a89fc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    8000410c:	409c                	lw	a5,0(s1)
    8000410e:	f7e5                	bnez	a5,800040f6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004110:	4785                	li	a5,1
    80004112:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004114:	f90fd0ef          	jal	800018a4 <myproc>
    80004118:	591c                	lw	a5,48(a0)
    8000411a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000411c:	854a                	mv	a0,s2
    8000411e:	afffc0ef          	jal	80000c1c <release>
}
    80004122:	60e2                	ld	ra,24(sp)
    80004124:	6442                	ld	s0,16(sp)
    80004126:	64a2                	ld	s1,8(sp)
    80004128:	6902                	ld	s2,0(sp)
    8000412a:	6105                	addi	sp,sp,32
    8000412c:	8082                	ret

000000008000412e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000412e:	1101                	addi	sp,sp,-32
    80004130:	ec06                	sd	ra,24(sp)
    80004132:	e822                	sd	s0,16(sp)
    80004134:	e426                	sd	s1,8(sp)
    80004136:	e04a                	sd	s2,0(sp)
    80004138:	1000                	addi	s0,sp,32
    8000413a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000413c:	00850913          	addi	s2,a0,8
    80004140:	854a                	mv	a0,s2
    80004142:	a4ffc0ef          	jal	80000b90 <acquire>
  lk->locked = 0;
    80004146:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000414a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000414e:	8526                	mv	a0,s1
    80004150:	e3dfd0ef          	jal	80001f8c <wakeup>
  release(&lk->lk);
    80004154:	854a                	mv	a0,s2
    80004156:	ac7fc0ef          	jal	80000c1c <release>
}
    8000415a:	60e2                	ld	ra,24(sp)
    8000415c:	6442                	ld	s0,16(sp)
    8000415e:	64a2                	ld	s1,8(sp)
    80004160:	6902                	ld	s2,0(sp)
    80004162:	6105                	addi	sp,sp,32
    80004164:	8082                	ret

0000000080004166 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004166:	7179                	addi	sp,sp,-48
    80004168:	f406                	sd	ra,40(sp)
    8000416a:	f022                	sd	s0,32(sp)
    8000416c:	ec26                	sd	s1,24(sp)
    8000416e:	e84a                	sd	s2,16(sp)
    80004170:	1800                	addi	s0,sp,48
    80004172:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004174:	00850913          	addi	s2,a0,8
    80004178:	854a                	mv	a0,s2
    8000417a:	a17fc0ef          	jal	80000b90 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000417e:	409c                	lw	a5,0(s1)
    80004180:	ef81                	bnez	a5,80004198 <holdingsleep+0x32>
    80004182:	4481                	li	s1,0
  release(&lk->lk);
    80004184:	854a                	mv	a0,s2
    80004186:	a97fc0ef          	jal	80000c1c <release>
  return r;
}
    8000418a:	8526                	mv	a0,s1
    8000418c:	70a2                	ld	ra,40(sp)
    8000418e:	7402                	ld	s0,32(sp)
    80004190:	64e2                	ld	s1,24(sp)
    80004192:	6942                	ld	s2,16(sp)
    80004194:	6145                	addi	sp,sp,48
    80004196:	8082                	ret
    80004198:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000419a:	0284a983          	lw	s3,40(s1)
    8000419e:	f06fd0ef          	jal	800018a4 <myproc>
    800041a2:	5904                	lw	s1,48(a0)
    800041a4:	413484b3          	sub	s1,s1,s3
    800041a8:	0014b493          	seqz	s1,s1
    800041ac:	69a2                	ld	s3,8(sp)
    800041ae:	bfd9                	j	80004184 <holdingsleep+0x1e>

00000000800041b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041b0:	1141                	addi	sp,sp,-16
    800041b2:	e406                	sd	ra,8(sp)
    800041b4:	e022                	sd	s0,0(sp)
    800041b6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041b8:	00003597          	auipc	a1,0x3
    800041bc:	3e058593          	addi	a1,a1,992 # 80007598 <etext+0x598>
    800041c0:	0001c517          	auipc	a0,0x1c
    800041c4:	f4850513          	addi	a0,a0,-184 # 80020108 <ftable>
    800041c8:	953fc0ef          	jal	80000b1a <initlock>
}
    800041cc:	60a2                	ld	ra,8(sp)
    800041ce:	6402                	ld	s0,0(sp)
    800041d0:	0141                	addi	sp,sp,16
    800041d2:	8082                	ret

00000000800041d4 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800041d4:	1101                	addi	sp,sp,-32
    800041d6:	ec06                	sd	ra,24(sp)
    800041d8:	e822                	sd	s0,16(sp)
    800041da:	e426                	sd	s1,8(sp)
    800041dc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041de:	0001c517          	auipc	a0,0x1c
    800041e2:	f2a50513          	addi	a0,a0,-214 # 80020108 <ftable>
    800041e6:	9abfc0ef          	jal	80000b90 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041ea:	0001c497          	auipc	s1,0x1c
    800041ee:	f3648493          	addi	s1,s1,-202 # 80020120 <ftable+0x18>
    800041f2:	0001d717          	auipc	a4,0x1d
    800041f6:	ece70713          	addi	a4,a4,-306 # 800210c0 <disk>
    if (f->ref == 0) {
    800041fa:	40dc                	lw	a5,4(s1)
    800041fc:	cf89                	beqz	a5,80004216 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041fe:	02848493          	addi	s1,s1,40
    80004202:	fee49ce3          	bne	s1,a4,800041fa <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004206:	0001c517          	auipc	a0,0x1c
    8000420a:	f0250513          	addi	a0,a0,-254 # 80020108 <ftable>
    8000420e:	a0ffc0ef          	jal	80000c1c <release>
  return 0;
    80004212:	4481                	li	s1,0
    80004214:	a809                	j	80004226 <filealloc+0x52>
      f->ref = 1;
    80004216:	4785                	li	a5,1
    80004218:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000421a:	0001c517          	auipc	a0,0x1c
    8000421e:	eee50513          	addi	a0,a0,-274 # 80020108 <ftable>
    80004222:	9fbfc0ef          	jal	80000c1c <release>
}
    80004226:	8526                	mv	a0,s1
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6105                	addi	sp,sp,32
    80004230:	8082                	ret

0000000080004232 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004232:	1101                	addi	sp,sp,-32
    80004234:	ec06                	sd	ra,24(sp)
    80004236:	e822                	sd	s0,16(sp)
    80004238:	e426                	sd	s1,8(sp)
    8000423a:	1000                	addi	s0,sp,32
    8000423c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000423e:	0001c517          	auipc	a0,0x1c
    80004242:	eca50513          	addi	a0,a0,-310 # 80020108 <ftable>
    80004246:	94bfc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    8000424a:	40dc                	lw	a5,4(s1)
    8000424c:	02f05063          	blez	a5,8000426c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004250:	2785                	addiw	a5,a5,1
    80004252:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004254:	0001c517          	auipc	a0,0x1c
    80004258:	eb450513          	addi	a0,a0,-332 # 80020108 <ftable>
    8000425c:	9c1fc0ef          	jal	80000c1c <release>
  return f;
}
    80004260:	8526                	mv	a0,s1
    80004262:	60e2                	ld	ra,24(sp)
    80004264:	6442                	ld	s0,16(sp)
    80004266:	64a2                	ld	s1,8(sp)
    80004268:	6105                	addi	sp,sp,32
    8000426a:	8082                	ret
    panic("filedup");
    8000426c:	00003517          	auipc	a0,0x3
    80004270:	33450513          	addi	a0,a0,820 # 800075a0 <etext+0x5a0>
    80004274:	d7cfc0ef          	jal	800007f0 <panic>

0000000080004278 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004278:	7139                	addi	sp,sp,-64
    8000427a:	fc06                	sd	ra,56(sp)
    8000427c:	f822                	sd	s0,48(sp)
    8000427e:	f426                	sd	s1,40(sp)
    80004280:	0080                	addi	s0,sp,64
    80004282:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004284:	0001c517          	auipc	a0,0x1c
    80004288:	e8450513          	addi	a0,a0,-380 # 80020108 <ftable>
    8000428c:	905fc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    80004290:	40dc                	lw	a5,4(s1)
    80004292:	04f05a63          	blez	a5,800042e6 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004296:	37fd                	addiw	a5,a5,-1
    80004298:	0007871b          	sext.w	a4,a5
    8000429c:	c0dc                	sw	a5,4(s1)
    8000429e:	04e04e63          	bgtz	a4,800042fa <fileclose+0x82>
    800042a2:	f04a                	sd	s2,32(sp)
    800042a4:	ec4e                	sd	s3,24(sp)
    800042a6:	e852                	sd	s4,16(sp)
    800042a8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042aa:	0004a903          	lw	s2,0(s1)
    800042ae:	0094ca83          	lbu	s5,9(s1)
    800042b2:	0104ba03          	ld	s4,16(s1)
    800042b6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042ba:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042be:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042c2:	0001c517          	auipc	a0,0x1c
    800042c6:	e4650513          	addi	a0,a0,-442 # 80020108 <ftable>
    800042ca:	953fc0ef          	jal	80000c1c <release>

  if (ff.type == FD_PIPE) {
    800042ce:	4785                	li	a5,1
    800042d0:	04f90063          	beq	s2,a5,80004310 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800042d4:	3979                	addiw	s2,s2,-2
    800042d6:	4785                	li	a5,1
    800042d8:	0527f563          	bgeu	a5,s2,80004322 <fileclose+0xaa>
    800042dc:	7902                	ld	s2,32(sp)
    800042de:	69e2                	ld	s3,24(sp)
    800042e0:	6a42                	ld	s4,16(sp)
    800042e2:	6aa2                	ld	s5,8(sp)
    800042e4:	a00d                	j	80004306 <fileclose+0x8e>
    800042e6:	f04a                	sd	s2,32(sp)
    800042e8:	ec4e                	sd	s3,24(sp)
    800042ea:	e852                	sd	s4,16(sp)
    800042ec:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042ee:	00003517          	auipc	a0,0x3
    800042f2:	2ba50513          	addi	a0,a0,698 # 800075a8 <etext+0x5a8>
    800042f6:	cfafc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    800042fa:	0001c517          	auipc	a0,0x1c
    800042fe:	e0e50513          	addi	a0,a0,-498 # 80020108 <ftable>
    80004302:	91bfc0ef          	jal	80000c1c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004306:	70e2                	ld	ra,56(sp)
    80004308:	7442                	ld	s0,48(sp)
    8000430a:	74a2                	ld	s1,40(sp)
    8000430c:	6121                	addi	sp,sp,64
    8000430e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004310:	85d6                	mv	a1,s5
    80004312:	8552                	mv	a0,s4
    80004314:	34c000ef          	jal	80004660 <pipeclose>
    80004318:	7902                	ld	s2,32(sp)
    8000431a:	69e2                	ld	s3,24(sp)
    8000431c:	6a42                	ld	s4,16(sp)
    8000431e:	6aa2                	ld	s5,8(sp)
    80004320:	b7dd                	j	80004306 <fileclose+0x8e>
    begin_op();
    80004322:	aabff0ef          	jal	80003dcc <begin_op>
    iput(ff.ip);
    80004326:	854e                	mv	a0,s3
    80004328:	9deff0ef          	jal	80003506 <iput>
    end_op();
    8000432c:	b27ff0ef          	jal	80003e52 <end_op>
    80004330:	7902                	ld	s2,32(sp)
    80004332:	69e2                	ld	s3,24(sp)
    80004334:	6a42                	ld	s4,16(sp)
    80004336:	6aa2                	ld	s5,8(sp)
    80004338:	b7f9                	j	80004306 <fileclose+0x8e>

000000008000433a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000433a:	715d                	addi	sp,sp,-80
    8000433c:	e486                	sd	ra,72(sp)
    8000433e:	e0a2                	sd	s0,64(sp)
    80004340:	fc26                	sd	s1,56(sp)
    80004342:	f44e                	sd	s3,40(sp)
    80004344:	0880                	addi	s0,sp,80
    80004346:	84aa                	mv	s1,a0
    80004348:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000434a:	d5afd0ef          	jal	800018a4 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000434e:	409c                	lw	a5,0(s1)
    80004350:	37f9                	addiw	a5,a5,-2
    80004352:	4705                	li	a4,1
    80004354:	04f76263          	bltu	a4,a5,80004398 <filestat+0x5e>
    80004358:	f84a                	sd	s2,48(sp)
    8000435a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000435c:	6c88                	ld	a0,24(s1)
    8000435e:	826ff0ef          	jal	80003384 <ilock>
    stati(f->ip, &st);
    80004362:	fb840593          	addi	a1,s0,-72
    80004366:	6c88                	ld	a0,24(s1)
    80004368:	bcaff0ef          	jal	80003732 <stati>
    iunlock(f->ip);
    8000436c:	6c88                	ld	a0,24(s1)
    8000436e:	8c4ff0ef          	jal	80003432 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004372:	4761                	li	a4,24
    80004374:	fb840693          	addi	a3,s0,-72
    80004378:	864e                	mv	a2,s3
    8000437a:	04893583          	ld	a1,72(s2)
    8000437e:	05093503          	ld	a0,80(s2)
    80004382:	958fd0ef          	jal	800014da <copyout>
    80004386:	41f5551b          	sraiw	a0,a0,0x1f
    8000438a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000438c:	60a6                	ld	ra,72(sp)
    8000438e:	6406                	ld	s0,64(sp)
    80004390:	74e2                	ld	s1,56(sp)
    80004392:	79a2                	ld	s3,40(sp)
    80004394:	6161                	addi	sp,sp,80
    80004396:	8082                	ret
  return -1;
    80004398:	557d                	li	a0,-1
    8000439a:	bfcd                	j	8000438c <filestat+0x52>

000000008000439c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000439c:	7179                	addi	sp,sp,-48
    8000439e:	f406                	sd	ra,40(sp)
    800043a0:	f022                	sd	s0,32(sp)
    800043a2:	e84a                	sd	s2,16(sp)
    800043a4:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800043a6:	00854783          	lbu	a5,8(a0)
    800043aa:	c3c5                	beqz	a5,8000444a <fileread+0xae>
    800043ac:	ec26                	sd	s1,24(sp)
    800043ae:	e44e                	sd	s3,8(sp)
    800043b0:	84aa                	mv	s1,a0
    800043b2:	89ae                	mv	s3,a1
    800043b4:	8932                	mv	s2,a2
    800043b6:	08064c63          	bltz	a2,8000444e <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    800043ba:	411c                	lw	a5,0(a0)
    800043bc:	4705                	li	a4,1
    800043be:	04e78363          	beq	a5,a4,80004404 <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043c2:	470d                	li	a4,3
    800043c4:	04e78763          	beq	a5,a4,80004412 <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043c8:	4709                	li	a4,2
    800043ca:	06e79a63          	bne	a5,a4,8000443e <fileread+0xa2>
    ilock(f->ip);
    800043ce:	6d08                	ld	a0,24(a0)
    800043d0:	fb5fe0ef          	jal	80003384 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043d4:	874a                	mv	a4,s2
    800043d6:	5094                	lw	a3,32(s1)
    800043d8:	864e                	mv	a2,s3
    800043da:	4585                	li	a1,1
    800043dc:	6c88                	ld	a0,24(s1)
    800043de:	b7eff0ef          	jal	8000375c <readi>
    800043e2:	892a                	mv	s2,a0
    800043e4:	00a05563          	blez	a0,800043ee <fileread+0x52>
      f->off += r;
    800043e8:	509c                	lw	a5,32(s1)
    800043ea:	9fa9                	addw	a5,a5,a0
    800043ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043ee:	6c88                	ld	a0,24(s1)
    800043f0:	842ff0ef          	jal	80003432 <iunlock>
    800043f4:	64e2                	ld	s1,24(sp)
    800043f6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043f8:	854a                	mv	a0,s2
    800043fa:	70a2                	ld	ra,40(sp)
    800043fc:	7402                	ld	s0,32(sp)
    800043fe:	6942                	ld	s2,16(sp)
    80004400:	6145                	addi	sp,sp,48
    80004402:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004404:	6908                	ld	a0,16(a0)
    80004406:	3b6000ef          	jal	800047bc <piperead>
    8000440a:	892a                	mv	s2,a0
    8000440c:	64e2                	ld	s1,24(sp)
    8000440e:	69a2                	ld	s3,8(sp)
    80004410:	b7e5                	j	800043f8 <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004412:	02451783          	lh	a5,36(a0)
    80004416:	03079693          	slli	a3,a5,0x30
    8000441a:	92c1                	srli	a3,a3,0x30
    8000441c:	4725                	li	a4,9
    8000441e:	02d76c63          	bltu	a4,a3,80004456 <fileread+0xba>
    80004422:	0792                	slli	a5,a5,0x4
    80004424:	0001c717          	auipc	a4,0x1c
    80004428:	c4470713          	addi	a4,a4,-956 # 80020068 <devsw>
    8000442c:	97ba                	add	a5,a5,a4
    8000442e:	639c                	ld	a5,0(a5)
    80004430:	c79d                	beqz	a5,8000445e <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    80004432:	4505                	li	a0,1
    80004434:	9782                	jalr	a5
    80004436:	892a                	mv	s2,a0
    80004438:	64e2                	ld	s1,24(sp)
    8000443a:	69a2                	ld	s3,8(sp)
    8000443c:	bf75                	j	800043f8 <fileread+0x5c>
    panic("fileread");
    8000443e:	00003517          	auipc	a0,0x3
    80004442:	17a50513          	addi	a0,a0,378 # 800075b8 <etext+0x5b8>
    80004446:	baafc0ef          	jal	800007f0 <panic>
    return -1;
    8000444a:	597d                	li	s2,-1
    8000444c:	b775                	j	800043f8 <fileread+0x5c>
    8000444e:	597d                	li	s2,-1
    80004450:	64e2                	ld	s1,24(sp)
    80004452:	69a2                	ld	s3,8(sp)
    80004454:	b755                	j	800043f8 <fileread+0x5c>
      return -1;
    80004456:	597d                	li	s2,-1
    80004458:	64e2                	ld	s1,24(sp)
    8000445a:	69a2                	ld	s3,8(sp)
    8000445c:	bf71                	j	800043f8 <fileread+0x5c>
    8000445e:	597d                	li	s2,-1
    80004460:	64e2                	ld	s1,24(sp)
    80004462:	69a2                	ld	s3,8(sp)
    80004464:	bf51                	j	800043f8 <fileread+0x5c>

0000000080004466 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004466:	00954783          	lbu	a5,9(a0)
    8000446a:	10078663          	beqz	a5,80004576 <filewrite+0x110>
{
    8000446e:	715d                	addi	sp,sp,-80
    80004470:	e486                	sd	ra,72(sp)
    80004472:	e0a2                	sd	s0,64(sp)
    80004474:	f84a                	sd	s2,48(sp)
    80004476:	f052                	sd	s4,32(sp)
    80004478:	e85a                	sd	s6,16(sp)
    8000447a:	0880                	addi	s0,sp,80
    8000447c:	892a                	mv	s2,a0
    8000447e:	8b2e                	mv	s6,a1
    80004480:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    80004482:	0e064c63          	bltz	a2,8000457a <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    80004486:	411c                	lw	a5,0(a0)
    80004488:	4705                	li	a4,1
    8000448a:	02e78763          	beq	a5,a4,800044b8 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000448e:	470d                	li	a4,3
    80004490:	02e78863          	beq	a5,a4,800044c0 <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004494:	4709                	li	a4,2
    80004496:	0ce79563          	bne	a5,a4,80004560 <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000449a:	0ec05663          	blez	a2,80004586 <filewrite+0x120>
    8000449e:	fc26                	sd	s1,56(sp)
    800044a0:	f44e                	sd	s3,40(sp)
    800044a2:	ec56                	sd	s5,24(sp)
    800044a4:	e45e                	sd	s7,8(sp)
    800044a6:	e062                	sd	s8,0(sp)
    int i = 0;
    800044a8:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    800044aa:	6b85                	lui	s7,0x1
    800044ac:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044b0:	6c05                	lui	s8,0x1
    800044b2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800044b6:	a8b5                	j	80004532 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800044b8:	6908                	ld	a0,16(a0)
    800044ba:	1fe000ef          	jal	800046b8 <pipewrite>
    800044be:	a851                	j	80004552 <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044c0:	02451783          	lh	a5,36(a0)
    800044c4:	03079693          	slli	a3,a5,0x30
    800044c8:	92c1                	srli	a3,a3,0x30
    800044ca:	4725                	li	a4,9
    800044cc:	0ad76963          	bltu	a4,a3,8000457e <filewrite+0x118>
    800044d0:	0792                	slli	a5,a5,0x4
    800044d2:	0001c717          	auipc	a4,0x1c
    800044d6:	b9670713          	addi	a4,a4,-1130 # 80020068 <devsw>
    800044da:	97ba                	add	a5,a5,a4
    800044dc:	679c                	ld	a5,8(a5)
    800044de:	c3d5                	beqz	a5,80004582 <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    800044e0:	4505                	li	a0,1
    800044e2:	9782                	jalr	a5
    800044e4:	a0bd                	j	80004552 <filewrite+0xec>
      if (n1 > max)
    800044e6:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800044ea:	8e3ff0ef          	jal	80003dcc <begin_op>
      ilock(f->ip);
    800044ee:	01893503          	ld	a0,24(s2)
    800044f2:	e93fe0ef          	jal	80003384 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044f6:	8756                	mv	a4,s5
    800044f8:	02092683          	lw	a3,32(s2)
    800044fc:	01698633          	add	a2,s3,s6
    80004500:	4585                	li	a1,1
    80004502:	01893503          	ld	a0,24(s2)
    80004506:	b52ff0ef          	jal	80003858 <writei>
    8000450a:	84aa                	mv	s1,a0
    8000450c:	00a05763          	blez	a0,8000451a <filewrite+0xb4>
        f->off += r;
    80004510:	02092783          	lw	a5,32(s2)
    80004514:	9fa9                	addw	a5,a5,a0
    80004516:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000451a:	01893503          	ld	a0,24(s2)
    8000451e:	f15fe0ef          	jal	80003432 <iunlock>
      end_op();
    80004522:	931ff0ef          	jal	80003e52 <end_op>

      if (r != n1) {
    80004526:	009a9e63          	bne	s5,s1,80004542 <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    8000452a:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    8000452e:	0149da63          	bge	s3,s4,80004542 <filewrite+0xdc>
      int n1 = n - i;
    80004532:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    80004536:	0004879b          	sext.w	a5,s1
    8000453a:	fafbd6e3          	bge	s7,a5,800044e6 <filewrite+0x80>
    8000453e:	84e2                	mv	s1,s8
    80004540:	b75d                	j	800044e6 <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    80004542:	053a1463          	bne	s4,s3,8000458a <filewrite+0x124>
    80004546:	8552                	mv	a0,s4
    80004548:	74e2                	ld	s1,56(sp)
    8000454a:	79a2                	ld	s3,40(sp)
    8000454c:	6ae2                	ld	s5,24(sp)
    8000454e:	6ba2                	ld	s7,8(sp)
    80004550:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004552:	60a6                	ld	ra,72(sp)
    80004554:	6406                	ld	s0,64(sp)
    80004556:	7942                	ld	s2,48(sp)
    80004558:	7a02                	ld	s4,32(sp)
    8000455a:	6b42                	ld	s6,16(sp)
    8000455c:	6161                	addi	sp,sp,80
    8000455e:	8082                	ret
    80004560:	fc26                	sd	s1,56(sp)
    80004562:	f44e                	sd	s3,40(sp)
    80004564:	ec56                	sd	s5,24(sp)
    80004566:	e45e                	sd	s7,8(sp)
    80004568:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000456a:	00003517          	auipc	a0,0x3
    8000456e:	05e50513          	addi	a0,a0,94 # 800075c8 <etext+0x5c8>
    80004572:	a7efc0ef          	jal	800007f0 <panic>
    return -1;
    80004576:	557d                	li	a0,-1
}
    80004578:	8082                	ret
    return -1;
    8000457a:	557d                	li	a0,-1
    8000457c:	bfd9                	j	80004552 <filewrite+0xec>
      return -1;
    8000457e:	557d                	li	a0,-1
    80004580:	bfc9                	j	80004552 <filewrite+0xec>
    80004582:	557d                	li	a0,-1
    80004584:	b7f9                	j	80004552 <filewrite+0xec>
    ret = (i == n ? n : -1);
    80004586:	8532                	mv	a0,a2
    80004588:	b7e9                	j	80004552 <filewrite+0xec>
    8000458a:	557d                	li	a0,-1
    8000458c:	74e2                	ld	s1,56(sp)
    8000458e:	79a2                	ld	s3,40(sp)
    80004590:	6ae2                	ld	s5,24(sp)
    80004592:	6ba2                	ld	s7,8(sp)
    80004594:	6c02                	ld	s8,0(sp)
    80004596:	bf75                	j	80004552 <filewrite+0xec>

0000000080004598 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004598:	7179                	addi	sp,sp,-48
    8000459a:	f406                	sd	ra,40(sp)
    8000459c:	f022                	sd	s0,32(sp)
    8000459e:	ec26                	sd	s1,24(sp)
    800045a0:	e052                	sd	s4,0(sp)
    800045a2:	1800                	addi	s0,sp,48
    800045a4:	84aa                	mv	s1,a0
    800045a6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045a8:	0005b023          	sd	zero,0(a1)
    800045ac:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045b0:	c25ff0ef          	jal	800041d4 <filealloc>
    800045b4:	e088                	sd	a0,0(s1)
    800045b6:	c549                	beqz	a0,80004640 <pipealloc+0xa8>
    800045b8:	c1dff0ef          	jal	800041d4 <filealloc>
    800045bc:	00aa3023          	sd	a0,0(s4)
    800045c0:	cd25                	beqz	a0,80004638 <pipealloc+0xa0>
    800045c2:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800045c4:	d06fc0ef          	jal	80000aca <kalloc>
    800045c8:	892a                	mv	s2,a0
    800045ca:	c12d                	beqz	a0,8000462c <pipealloc+0x94>
    800045cc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045ce:	4985                	li	s3,1
    800045d0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045d4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045d8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045dc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045e0:	00003597          	auipc	a1,0x3
    800045e4:	ff858593          	addi	a1,a1,-8 # 800075d8 <etext+0x5d8>
    800045e8:	d32fc0ef          	jal	80000b1a <initlock>
  (*f0)->type = FD_PIPE;
    800045ec:	609c                	ld	a5,0(s1)
    800045ee:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045f2:	609c                	ld	a5,0(s1)
    800045f4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045f8:	609c                	ld	a5,0(s1)
    800045fa:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045fe:	609c                	ld	a5,0(s1)
    80004600:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004604:	000a3783          	ld	a5,0(s4)
    80004608:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000460c:	000a3783          	ld	a5,0(s4)
    80004610:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004614:	000a3783          	ld	a5,0(s4)
    80004618:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000461c:	000a3783          	ld	a5,0(s4)
    80004620:	0127b823          	sd	s2,16(a5)
  return 0;
    80004624:	4501                	li	a0,0
    80004626:	6942                	ld	s2,16(sp)
    80004628:	69a2                	ld	s3,8(sp)
    8000462a:	a01d                	j	80004650 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    8000462c:	6088                	ld	a0,0(s1)
    8000462e:	c119                	beqz	a0,80004634 <pipealloc+0x9c>
    80004630:	6942                	ld	s2,16(sp)
    80004632:	a029                	j	8000463c <pipealloc+0xa4>
    80004634:	6942                	ld	s2,16(sp)
    80004636:	a029                	j	80004640 <pipealloc+0xa8>
    80004638:	6088                	ld	a0,0(s1)
    8000463a:	c10d                	beqz	a0,8000465c <pipealloc+0xc4>
    fileclose(*f0);
    8000463c:	c3dff0ef          	jal	80004278 <fileclose>
  if (*f1)
    80004640:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004644:	557d                	li	a0,-1
  if (*f1)
    80004646:	c789                	beqz	a5,80004650 <pipealloc+0xb8>
    fileclose(*f1);
    80004648:	853e                	mv	a0,a5
    8000464a:	c2fff0ef          	jal	80004278 <fileclose>
  return -1;
    8000464e:	557d                	li	a0,-1
}
    80004650:	70a2                	ld	ra,40(sp)
    80004652:	7402                	ld	s0,32(sp)
    80004654:	64e2                	ld	s1,24(sp)
    80004656:	6a02                	ld	s4,0(sp)
    80004658:	6145                	addi	sp,sp,48
    8000465a:	8082                	ret
  return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	bfcd                	j	80004650 <pipealloc+0xb8>

0000000080004660 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004660:	1101                	addi	sp,sp,-32
    80004662:	ec06                	sd	ra,24(sp)
    80004664:	e822                	sd	s0,16(sp)
    80004666:	e426                	sd	s1,8(sp)
    80004668:	e04a                	sd	s2,0(sp)
    8000466a:	1000                	addi	s0,sp,32
    8000466c:	84aa                	mv	s1,a0
    8000466e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004670:	d20fc0ef          	jal	80000b90 <acquire>
  if (writable) {
    80004674:	02090763          	beqz	s2,800046a2 <pipeclose+0x42>
    pi->writeopen = 0;
    80004678:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000467c:	21848513          	addi	a0,s1,536
    80004680:	90dfd0ef          	jal	80001f8c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004684:	2204b783          	ld	a5,544(s1)
    80004688:	e785                	bnez	a5,800046b0 <pipeclose+0x50>
    release(&pi->lock);
    8000468a:	8526                	mv	a0,s1
    8000468c:	d90fc0ef          	jal	80000c1c <release>
    kfree((char *)pi);
    80004690:	8526                	mv	a0,s1
    80004692:	b56fc0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004696:	60e2                	ld	ra,24(sp)
    80004698:	6442                	ld	s0,16(sp)
    8000469a:	64a2                	ld	s1,8(sp)
    8000469c:	6902                	ld	s2,0(sp)
    8000469e:	6105                	addi	sp,sp,32
    800046a0:	8082                	ret
    pi->readopen = 0;
    800046a2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046a6:	21c48513          	addi	a0,s1,540
    800046aa:	8e3fd0ef          	jal	80001f8c <wakeup>
    800046ae:	bfd9                	j	80004684 <pipeclose+0x24>
    release(&pi->lock);
    800046b0:	8526                	mv	a0,s1
    800046b2:	d6afc0ef          	jal	80000c1c <release>
}
    800046b6:	b7c5                	j	80004696 <pipeclose+0x36>

00000000800046b8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046b8:	711d                	addi	sp,sp,-96
    800046ba:	ec86                	sd	ra,88(sp)
    800046bc:	e8a2                	sd	s0,80(sp)
    800046be:	e4a6                	sd	s1,72(sp)
    800046c0:	e0ca                	sd	s2,64(sp)
    800046c2:	fc4e                	sd	s3,56(sp)
    800046c4:	f852                	sd	s4,48(sp)
    800046c6:	f456                	sd	s5,40(sp)
    800046c8:	1080                	addi	s0,sp,96
    800046ca:	84aa                	mv	s1,a0
    800046cc:	8aae                	mv	s5,a1
    800046ce:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046d0:	9d4fd0ef          	jal	800018a4 <myproc>
    800046d4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046d6:	8526                	mv	a0,s1
    800046d8:	cb8fc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    800046dc:	0d405e63          	blez	s4,800047b8 <pipewrite+0x100>
    800046e0:	f05a                	sd	s6,32(sp)
    800046e2:	ec5e                	sd	s7,24(sp)
    800046e4:	e862                	sd	s8,16(sp)
  int i = 0;
    800046e6:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046e8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046ea:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    800046ee:	21c48b93          	addi	s7,s1,540
    800046f2:	a091                	j	80004736 <pipewrite+0x7e>
      release(&pi->lock);
    800046f4:	8526                	mv	a0,s1
    800046f6:	d26fc0ef          	jal	80000c1c <release>
      return -1;
    800046fa:	597d                	li	s2,-1
    800046fc:	7b02                	ld	s6,32(sp)
    800046fe:	6be2                	ld	s7,24(sp)
    80004700:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004702:	854a                	mv	a0,s2
    80004704:	60e6                	ld	ra,88(sp)
    80004706:	6446                	ld	s0,80(sp)
    80004708:	64a6                	ld	s1,72(sp)
    8000470a:	6906                	ld	s2,64(sp)
    8000470c:	79e2                	ld	s3,56(sp)
    8000470e:	7a42                	ld	s4,48(sp)
    80004710:	7aa2                	ld	s5,40(sp)
    80004712:	6125                	addi	sp,sp,96
    80004714:	8082                	ret
      wakeup(&pi->nread);
    80004716:	8562                	mv	a0,s8
    80004718:	875fd0ef          	jal	80001f8c <wakeup>
      sleep_prepare(&pi->nwrite);
    8000471c:	855e                	mv	a0,s7
    8000471e:	803fd0ef          	jal	80001f20 <sleep_prepare>
      release(&pi->lock);
    80004722:	8526                	mv	a0,s1
    80004724:	cf8fc0ef          	jal	80000c1c <release>
      sleep();
    80004728:	835fd0ef          	jal	80001f5c <sleep>
      acquire(&pi->lock);
    8000472c:	8526                	mv	a0,s1
    8000472e:	c62fc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    80004732:	07495863          	bge	s2,s4,800047a2 <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    80004736:	2204a783          	lw	a5,544(s1)
    8000473a:	dfcd                	beqz	a5,800046f4 <pipewrite+0x3c>
    8000473c:	854e                	mv	a0,s3
    8000473e:	a43fd0ef          	jal	80002180 <killed>
    80004742:	f94d                	bnez	a0,800046f4 <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004744:	2184a783          	lw	a5,536(s1)
    80004748:	21c4a703          	lw	a4,540(s1)
    8000474c:	2007879b          	addiw	a5,a5,512
    80004750:	fcf703e3          	beq	a4,a5,80004716 <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004754:	4705                	li	a4,1
    80004756:	015906b3          	add	a3,s2,s5
    8000475a:	faf40613          	addi	a2,s0,-81
    8000475e:	0489b583          	ld	a1,72(s3)
    80004762:	0509b503          	ld	a0,80(s3)
    80004766:	e61fc0ef          	jal	800015c6 <copyin>
    8000476a:	03650163          	beq	a0,s6,8000478c <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000476e:	21c4a783          	lw	a5,540(s1)
    80004772:	0017871b          	addiw	a4,a5,1
    80004776:	20e4ae23          	sw	a4,540(s1)
    8000477a:	1ff7f793          	andi	a5,a5,511
    8000477e:	97a6                	add	a5,a5,s1
    80004780:	faf44703          	lbu	a4,-81(s0)
    80004784:	00e78c23          	sb	a4,24(a5)
      i++;
    80004788:	2905                	addiw	s2,s2,1
    8000478a:	b765                	j	80004732 <pipewrite+0x7a>
        if (i == 0)
    8000478c:	00090663          	beqz	s2,80004798 <pipewrite+0xe0>
    80004790:	7b02                	ld	s6,32(sp)
    80004792:	6be2                	ld	s7,24(sp)
    80004794:	6c42                	ld	s8,16(sp)
    80004796:	a809                	j	800047a8 <pipewrite+0xf0>
          i = -1;
    80004798:	892a                	mv	s2,a0
        break;
    8000479a:	7b02                	ld	s6,32(sp)
    8000479c:	6be2                	ld	s7,24(sp)
    8000479e:	6c42                	ld	s8,16(sp)
    800047a0:	a021                	j	800047a8 <pipewrite+0xf0>
    800047a2:	7b02                	ld	s6,32(sp)
    800047a4:	6be2                	ld	s7,24(sp)
    800047a6:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800047a8:	21848513          	addi	a0,s1,536
    800047ac:	fe0fd0ef          	jal	80001f8c <wakeup>
  release(&pi->lock);
    800047b0:	8526                	mv	a0,s1
    800047b2:	c6afc0ef          	jal	80000c1c <release>
  return i;
    800047b6:	b7b1                	j	80004702 <pipewrite+0x4a>
  int i = 0;
    800047b8:	4901                	li	s2,0
    800047ba:	b7fd                	j	800047a8 <pipewrite+0xf0>

00000000800047bc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047bc:	715d                	addi	sp,sp,-80
    800047be:	e486                	sd	ra,72(sp)
    800047c0:	e0a2                	sd	s0,64(sp)
    800047c2:	fc26                	sd	s1,56(sp)
    800047c4:	f84a                	sd	s2,48(sp)
    800047c6:	f44e                	sd	s3,40(sp)
    800047c8:	f052                	sd	s4,32(sp)
    800047ca:	ec56                	sd	s5,24(sp)
    800047cc:	0880                	addi	s0,sp,80
    800047ce:	84aa                	mv	s1,a0
    800047d0:	89ae                	mv	s3,a1
    800047d2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047d4:	8d0fd0ef          	jal	800018a4 <myproc>
    800047d8:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800047da:	8526                	mv	a0,s1
    800047dc:	bb4fc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047e0:	2184a703          	lw	a4,536(s1)
    800047e4:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800047e8:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047ec:	02f71c63          	bne	a4,a5,80004824 <piperead+0x68>
    800047f0:	2244a783          	lw	a5,548(s1)
    800047f4:	cf9d                	beqz	a5,80004832 <piperead+0x76>
    if (killed(pr)) {
    800047f6:	854a                	mv	a0,s2
    800047f8:	989fd0ef          	jal	80002180 <killed>
    800047fc:	e515                	bnez	a0,80004828 <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800047fe:	8552                	mv	a0,s4
    80004800:	f20fd0ef          	jal	80001f20 <sleep_prepare>
    release(&pi->lock);
    80004804:	8526                	mv	a0,s1
    80004806:	c16fc0ef          	jal	80000c1c <release>
    sleep();
    8000480a:	f52fd0ef          	jal	80001f5c <sleep>
    acquire(&pi->lock);
    8000480e:	8526                	mv	a0,s1
    80004810:	b80fc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004814:	2184a703          	lw	a4,536(s1)
    80004818:	21c4a783          	lw	a5,540(s1)
    8000481c:	fcf70ae3          	beq	a4,a5,800047f0 <piperead+0x34>
    80004820:	e85a                	sd	s6,16(sp)
    80004822:	a809                	j	80004834 <piperead+0x78>
    80004824:	e85a                	sd	s6,16(sp)
    80004826:	a039                	j	80004834 <piperead+0x78>
      release(&pi->lock);
    80004828:	8526                	mv	a0,s1
    8000482a:	bf2fc0ef          	jal	80000c1c <release>
      return -1;
    8000482e:	5a7d                	li	s4,-1
    80004830:	a08d                	j	80004892 <piperead+0xd6>
    80004832:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004834:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004836:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004838:	05505563          	blez	s5,80004882 <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    8000483c:	2184a783          	lw	a5,536(s1)
    80004840:	21c4a703          	lw	a4,540(s1)
    80004844:	02f70f63          	beq	a4,a5,80004882 <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004848:	1ff7f793          	andi	a5,a5,511
    8000484c:	97a6                	add	a5,a5,s1
    8000484e:	0187c783          	lbu	a5,24(a5)
    80004852:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004856:	4705                	li	a4,1
    80004858:	fbf40693          	addi	a3,s0,-65
    8000485c:	864e                	mv	a2,s3
    8000485e:	04893583          	ld	a1,72(s2)
    80004862:	05093503          	ld	a0,80(s2)
    80004866:	c75fc0ef          	jal	800014da <copyout>
    8000486a:	03650e63          	beq	a0,s6,800048a6 <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000486e:	2184a783          	lw	a5,536(s1)
    80004872:	2785                	addiw	a5,a5,1
    80004874:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004878:	2a05                	addiw	s4,s4,1
    8000487a:	0985                	addi	s3,s3,1
    8000487c:	fd4a90e3          	bne	s5,s4,8000483c <piperead+0x80>
    80004880:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004882:	21c48513          	addi	a0,s1,540
    80004886:	f06fd0ef          	jal	80001f8c <wakeup>
  release(&pi->lock);
    8000488a:	8526                	mv	a0,s1
    8000488c:	b90fc0ef          	jal	80000c1c <release>
    80004890:	6b42                	ld	s6,16(sp)
  return i;
}
    80004892:	8552                	mv	a0,s4
    80004894:	60a6                	ld	ra,72(sp)
    80004896:	6406                	ld	s0,64(sp)
    80004898:	74e2                	ld	s1,56(sp)
    8000489a:	7942                	ld	s2,48(sp)
    8000489c:	79a2                	ld	s3,40(sp)
    8000489e:	7a02                	ld	s4,32(sp)
    800048a0:	6ae2                	ld	s5,24(sp)
    800048a2:	6161                	addi	sp,sp,80
    800048a4:	8082                	ret
      if (i == 0)
    800048a6:	fc0a1ee3          	bnez	s4,80004882 <piperead+0xc6>
        i = -1;
    800048aa:	8a2a                	mv	s4,a0
    800048ac:	bfd9                	j	80004882 <piperead+0xc6>

00000000800048ae <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800048ae:	1141                	addi	sp,sp,-16
    800048b0:	e422                	sd	s0,8(sp)
    800048b2:	0800                	addi	s0,sp,16
    800048b4:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800048b6:	8905                	andi	a0,a0,1
    800048b8:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    800048ba:	8b89                	andi	a5,a5,2
    800048bc:	c399                	beqz	a5,800048c2 <flags2perm+0x14>
    perm |= PTE_W;
    800048be:	00456513          	ori	a0,a0,4
  return perm;
}
    800048c2:	6422                	ld	s0,8(sp)
    800048c4:	0141                	addi	sp,sp,16
    800048c6:	8082                	ret

00000000800048c8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048c8:	df010113          	addi	sp,sp,-528
    800048cc:	20113423          	sd	ra,520(sp)
    800048d0:	20813023          	sd	s0,512(sp)
    800048d4:	ffa6                	sd	s1,504(sp)
    800048d6:	fbca                	sd	s2,496(sp)
    800048d8:	0c00                	addi	s0,sp,528
    800048da:	892a                	mv	s2,a0
    800048dc:	dea43c23          	sd	a0,-520(s0)
    800048e0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048e4:	fc1fc0ef          	jal	800018a4 <myproc>
    800048e8:	84aa                	mv	s1,a0

  begin_op();
    800048ea:	ce2ff0ef          	jal	80003dcc <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800048ee:	854a                	mv	a0,s2
    800048f0:	b08ff0ef          	jal	80003bf8 <namei>
    800048f4:	c931                	beqz	a0,80004948 <kexec+0x80>
    800048f6:	f3d2                	sd	s4,480(sp)
    800048f8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048fa:	a8bfe0ef          	jal	80003384 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048fe:	04000713          	li	a4,64
    80004902:	4681                	li	a3,0
    80004904:	e5040613          	addi	a2,s0,-432
    80004908:	4581                	li	a1,0
    8000490a:	8552                	mv	a0,s4
    8000490c:	e51fe0ef          	jal	8000375c <readi>
    80004910:	04000793          	li	a5,64
    80004914:	00f51a63          	bne	a0,a5,80004928 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004918:	e5042703          	lw	a4,-432(s0)
    8000491c:	464c47b7          	lui	a5,0x464c4
    80004920:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004924:	02f70663          	beq	a4,a5,80004950 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004928:	8552                	mv	a0,s4
    8000492a:	cadfe0ef          	jal	800035d6 <iunlockput>
    end_op();
    8000492e:	d24ff0ef          	jal	80003e52 <end_op>
  }
  return -1;
    80004932:	557d                	li	a0,-1
    80004934:	7a1e                	ld	s4,480(sp)
}
    80004936:	20813083          	ld	ra,520(sp)
    8000493a:	20013403          	ld	s0,512(sp)
    8000493e:	74fe                	ld	s1,504(sp)
    80004940:	795e                	ld	s2,496(sp)
    80004942:	21010113          	addi	sp,sp,528
    80004946:	8082                	ret
    end_op();
    80004948:	d0aff0ef          	jal	80003e52 <end_op>
    return -1;
    8000494c:	557d                	li	a0,-1
    8000494e:	b7e5                	j	80004936 <kexec+0x6e>
    80004950:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004952:	8526                	mv	a0,s1
    80004954:	860fd0ef          	jal	800019b4 <proc_pagetable>
    80004958:	8b2a                	mv	s6,a0
    8000495a:	2c050963          	beqz	a0,80004c2c <kexec+0x364>
    8000495e:	f7ce                	sd	s3,488(sp)
    80004960:	efd6                	sd	s5,472(sp)
    80004962:	e7de                	sd	s7,456(sp)
    80004964:	e3e2                	sd	s8,448(sp)
    80004966:	ff66                	sd	s9,440(sp)
    80004968:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000496a:	e7042d03          	lw	s10,-400(s0)
    8000496e:	e8845783          	lhu	a5,-376(s0)
    80004972:	12078863          	beqz	a5,80004aa2 <kexec+0x1da>
    80004976:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004978:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000497a:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    8000497c:	6c85                	lui	s9,0x1
    8000497e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004982:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004986:	6a85                	lui	s5,0x1
    80004988:	a085                	j	800049e8 <kexec+0x120>
      panic("loadseg: address should exist");
    8000498a:	00003517          	auipc	a0,0x3
    8000498e:	c5650513          	addi	a0,a0,-938 # 800075e0 <etext+0x5e0>
    80004992:	e5ffb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    80004996:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004998:	8726                	mv	a4,s1
    8000499a:	012c06bb          	addw	a3,s8,s2
    8000499e:	4581                	li	a1,0
    800049a0:	8552                	mv	a0,s4
    800049a2:	dbbfe0ef          	jal	8000375c <readi>
    800049a6:	2501                	sext.w	a0,a0
    800049a8:	24a49863          	bne	s1,a0,80004bf8 <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    800049ac:	012a893b          	addw	s2,s5,s2
    800049b0:	03397363          	bgeu	s2,s3,800049d6 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800049b4:	02091593          	slli	a1,s2,0x20
    800049b8:	9181                	srli	a1,a1,0x20
    800049ba:	95de                	add	a1,a1,s7
    800049bc:	855a                	mv	a0,s6
    800049be:	da8fc0ef          	jal	80000f66 <walkaddr>
    800049c2:	862a                	mv	a2,a0
    if (pa == 0)
    800049c4:	d179                	beqz	a0,8000498a <kexec+0xc2>
    if (sz - i < PGSIZE)
    800049c6:	412984bb          	subw	s1,s3,s2
    800049ca:	0004879b          	sext.w	a5,s1
    800049ce:	fcfcf4e3          	bgeu	s9,a5,80004996 <kexec+0xce>
    800049d2:	84d6                	mv	s1,s5
    800049d4:	b7c9                	j	80004996 <kexec+0xce>
    sz = sz1;
    800049d6:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049da:	2d85                	addiw	s11,s11,1
    800049dc:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800049e0:	e8845783          	lhu	a5,-376(s0)
    800049e4:	08fdd063          	bge	s11,a5,80004a64 <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049e8:	2d01                	sext.w	s10,s10
    800049ea:	03800713          	li	a4,56
    800049ee:	86ea                	mv	a3,s10
    800049f0:	e1840613          	addi	a2,s0,-488
    800049f4:	4581                	li	a1,0
    800049f6:	8552                	mv	a0,s4
    800049f8:	d65fe0ef          	jal	8000375c <readi>
    800049fc:	03800793          	li	a5,56
    80004a00:	1cf51463          	bne	a0,a5,80004bc8 <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    80004a04:	e1842783          	lw	a5,-488(s0)
    80004a08:	4705                	li	a4,1
    80004a0a:	fce798e3          	bne	a5,a4,800049da <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004a0e:	e4043483          	ld	s1,-448(s0)
    80004a12:	e3843783          	ld	a5,-456(s0)
    80004a16:	1af4ed63          	bltu	s1,a5,80004bd0 <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004a1a:	e2843783          	ld	a5,-472(s0)
    80004a1e:	94be                	add	s1,s1,a5
    80004a20:	1af4ec63          	bltu	s1,a5,80004bd8 <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80004a24:	df043703          	ld	a4,-528(s0)
    80004a28:	8ff9                	and	a5,a5,a4
    80004a2a:	1a079b63          	bnez	a5,80004be0 <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004a2e:	e1c42503          	lw	a0,-484(s0)
    80004a32:	e7dff0ef          	jal	800048ae <flags2perm>
    80004a36:	86aa                	mv	a3,a0
    80004a38:	8626                	mv	a2,s1
    80004a3a:	85ca                	mv	a1,s2
    80004a3c:	855a                	mv	a0,s6
    80004a3e:	801fc0ef          	jal	8000123e <uvmalloc>
    80004a42:	e0a43423          	sd	a0,-504(s0)
    80004a46:	1a050163          	beqz	a0,80004be8 <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a4a:	e2843b83          	ld	s7,-472(s0)
    80004a4e:	e2042c03          	lw	s8,-480(s0)
    80004a52:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a56:	00098463          	beqz	s3,80004a5e <kexec+0x196>
    80004a5a:	4901                	li	s2,0
    80004a5c:	bfa1                	j	800049b4 <kexec+0xec>
    sz = sz1;
    80004a5e:	e0843903          	ld	s2,-504(s0)
    80004a62:	bfa5                	j	800049da <kexec+0x112>
    80004a64:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a66:	8552                	mv	a0,s4
    80004a68:	b6ffe0ef          	jal	800035d6 <iunlockput>
  end_op();
    80004a6c:	be6ff0ef          	jal	80003e52 <end_op>
  p = myproc();
    80004a70:	e35fc0ef          	jal	800018a4 <myproc>
    80004a74:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004a76:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    80004a7a:	6b85                	lui	s7,0x1
    80004a7c:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    80004a7e:	9bca                	add	s7,s7,s2
    80004a80:	77fd                	lui	a5,0xfffff
    80004a82:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004a86:	4691                	li	a3,4
    80004a88:	6609                	lui	a2,0x2
    80004a8a:	965e                	add	a2,a2,s7
    80004a8c:	85de                	mv	a1,s7
    80004a8e:	855a                	mv	a0,s6
    80004a90:	faefc0ef          	jal	8000123e <uvmalloc>
    80004a94:	e0a43423          	sd	a0,-504(s0)
    80004a98:	e519                	bnez	a0,80004aa6 <kexec+0x1de>
  if (pagetable)
    80004a9a:	e1743423          	sd	s7,-504(s0)
    80004a9e:	4a01                	li	s4,0
    80004aa0:	aaa9                	j	80004bfa <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004aa2:	4901                	li	s2,0
    80004aa4:	b7c9                	j	80004a66 <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004aa6:	75f9                	lui	a1,0xffffe
    80004aa8:	8baa                	mv	s7,a0
    80004aaa:	95aa                	add	a1,a1,a0
    80004aac:	855a                	mv	a0,s6
    80004aae:	967fc0ef          	jal	80001414 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004ab2:	7afd                	lui	s5,0xfffff
    80004ab4:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    80004ab6:	e0043783          	ld	a5,-512(s0)
    80004aba:	6388                	ld	a0,0(a5)
    80004abc:	c15d                	beqz	a0,80004b62 <kexec+0x29a>
    80004abe:	e9040913          	addi	s2,s0,-368
    80004ac2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ac4:	b00fc0ef          	jal	80000dc4 <strlen>
    80004ac8:	0015079b          	addiw	a5,a0,1
    80004acc:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ad0:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    80004ad4:	115bee63          	bltu	s7,s5,80004bf0 <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ad8:	e0043c83          	ld	s9,-512(s0)
    80004adc:	000cbc03          	ld	s8,0(s9)
    80004ae0:	8562                	mv	a0,s8
    80004ae2:	ae2fc0ef          	jal	80000dc4 <strlen>
    80004ae6:	0015071b          	addiw	a4,a0,1
    80004aea:	86e2                	mv	a3,s8
    80004aec:	865e                	mv	a2,s7
    80004aee:	e0843583          	ld	a1,-504(s0)
    80004af2:	855a                	mv	a0,s6
    80004af4:	9e7fc0ef          	jal	800014da <copyout>
    80004af8:	0e054e63          	bltz	a0,80004bf4 <kexec+0x32c>
    ustack[argc] = sp;
    80004afc:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004b00:	0485                	addi	s1,s1,1
    80004b02:	008c8793          	addi	a5,s9,8
    80004b06:	e0f43023          	sd	a5,-512(s0)
    80004b0a:	008cb503          	ld	a0,8(s9)
    80004b0e:	0921                	addi	s2,s2,8
    80004b10:	f955                	bnez	a0,80004ac4 <kexec+0x1fc>
  ustack[argc] = 0;
    80004b12:	00349793          	slli	a5,s1,0x3
    80004b16:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffddd90>
    80004b1a:	97a2                	add	a5,a5,s0
    80004b1c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004b20:	00148713          	addi	a4,s1,1
    80004b24:	070e                	slli	a4,a4,0x3
    80004b26:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    80004b2a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b2e:	e0843583          	ld	a1,-504(s0)
    80004b32:	8bae                	mv	s7,a1
  if (sp < stackbase)
    80004b34:	f75963e3          	bltu	s2,s5,80004a9a <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004b38:	e9040693          	addi	a3,s0,-368
    80004b3c:	864a                	mv	a2,s2
    80004b3e:	855a                	mv	a0,s6
    80004b40:	99bfc0ef          	jal	800014da <copyout>
    80004b44:	0e054663          	bltz	a0,80004c30 <kexec+0x368>
  p->trapframe->a1 = sp;
    80004b48:	0589b783          	ld	a5,88(s3)
    80004b4c:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004b50:	df843783          	ld	a5,-520(s0)
    80004b54:	0007c703          	lbu	a4,0(a5)
    80004b58:	c315                	beqz	a4,80004b7c <kexec+0x2b4>
    80004b5a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004b5c:	02f00693          	li	a3,47
    80004b60:	a809                	j	80004b72 <kexec+0x2aa>
  sp = sz;
    80004b62:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004b66:	4481                	li	s1,0
    80004b68:	b76d                	j	80004b12 <kexec+0x24a>
  for (last = s = path; *s; s++)
    80004b6a:	0785                	addi	a5,a5,1
    80004b6c:	fff7c703          	lbu	a4,-1(a5)
    80004b70:	c711                	beqz	a4,80004b7c <kexec+0x2b4>
    if (*s == '/')
    80004b72:	fed71ce3          	bne	a4,a3,80004b6a <kexec+0x2a2>
      last = s + 1;
    80004b76:	def43c23          	sd	a5,-520(s0)
    80004b7a:	bfc5                	j	80004b6a <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b7c:	4641                	li	a2,16
    80004b7e:	df843583          	ld	a1,-520(s0)
    80004b82:	15898513          	addi	a0,s3,344
    80004b86:	a0cfc0ef          	jal	80000d92 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b8a:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004b8e:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004b92:	e0843783          	ld	a5,-504(s0)
    80004b96:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004b9a:	0589b783          	ld	a5,88(s3)
    80004b9e:	e6843703          	ld	a4,-408(s0)
    80004ba2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004ba4:	0589b783          	ld	a5,88(s3)
    80004ba8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004bac:	85d2                	mv	a1,s4
    80004bae:	e8bfc0ef          	jal	80001a38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004bb2:	0004851b          	sext.w	a0,s1
    80004bb6:	79be                	ld	s3,488(sp)
    80004bb8:	7a1e                	ld	s4,480(sp)
    80004bba:	6afe                	ld	s5,472(sp)
    80004bbc:	6b5e                	ld	s6,464(sp)
    80004bbe:	6bbe                	ld	s7,456(sp)
    80004bc0:	6c1e                	ld	s8,448(sp)
    80004bc2:	7cfa                	ld	s9,440(sp)
    80004bc4:	7d5a                	ld	s10,432(sp)
    80004bc6:	bb85                	j	80004936 <kexec+0x6e>
    80004bc8:	e1243423          	sd	s2,-504(s0)
    80004bcc:	7dba                	ld	s11,424(sp)
    80004bce:	a035                	j	80004bfa <kexec+0x332>
    80004bd0:	e1243423          	sd	s2,-504(s0)
    80004bd4:	7dba                	ld	s11,424(sp)
    80004bd6:	a015                	j	80004bfa <kexec+0x332>
    80004bd8:	e1243423          	sd	s2,-504(s0)
    80004bdc:	7dba                	ld	s11,424(sp)
    80004bde:	a831                	j	80004bfa <kexec+0x332>
    80004be0:	e1243423          	sd	s2,-504(s0)
    80004be4:	7dba                	ld	s11,424(sp)
    80004be6:	a811                	j	80004bfa <kexec+0x332>
    80004be8:	e1243423          	sd	s2,-504(s0)
    80004bec:	7dba                	ld	s11,424(sp)
    80004bee:	a031                	j	80004bfa <kexec+0x332>
  ip = 0;
    80004bf0:	4a01                	li	s4,0
    80004bf2:	a021                	j	80004bfa <kexec+0x332>
    80004bf4:	4a01                	li	s4,0
  if (pagetable)
    80004bf6:	a011                	j	80004bfa <kexec+0x332>
    80004bf8:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004bfa:	e0843583          	ld	a1,-504(s0)
    80004bfe:	855a                	mv	a0,s6
    80004c00:	e39fc0ef          	jal	80001a38 <proc_freepagetable>
  return -1;
    80004c04:	557d                	li	a0,-1
  if (ip) {
    80004c06:	000a1b63          	bnez	s4,80004c1c <kexec+0x354>
    80004c0a:	79be                	ld	s3,488(sp)
    80004c0c:	7a1e                	ld	s4,480(sp)
    80004c0e:	6afe                	ld	s5,472(sp)
    80004c10:	6b5e                	ld	s6,464(sp)
    80004c12:	6bbe                	ld	s7,456(sp)
    80004c14:	6c1e                	ld	s8,448(sp)
    80004c16:	7cfa                	ld	s9,440(sp)
    80004c18:	7d5a                	ld	s10,432(sp)
    80004c1a:	bb31                	j	80004936 <kexec+0x6e>
    80004c1c:	79be                	ld	s3,488(sp)
    80004c1e:	6afe                	ld	s5,472(sp)
    80004c20:	6b5e                	ld	s6,464(sp)
    80004c22:	6bbe                	ld	s7,456(sp)
    80004c24:	6c1e                	ld	s8,448(sp)
    80004c26:	7cfa                	ld	s9,440(sp)
    80004c28:	7d5a                	ld	s10,432(sp)
    80004c2a:	b9fd                	j	80004928 <kexec+0x60>
    80004c2c:	6b5e                	ld	s6,464(sp)
    80004c2e:	b9ed                	j	80004928 <kexec+0x60>
  sz = sz1;
    80004c30:	e0843b83          	ld	s7,-504(s0)
    80004c34:	b59d                	j	80004a9a <kexec+0x1d2>

0000000080004c36 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c36:	7179                	addi	sp,sp,-48
    80004c38:	f406                	sd	ra,40(sp)
    80004c3a:	f022                	sd	s0,32(sp)
    80004c3c:	ec26                	sd	s1,24(sp)
    80004c3e:	e84a                	sd	s2,16(sp)
    80004c40:	1800                	addi	s0,sp,48
    80004c42:	892e                	mv	s2,a1
    80004c44:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c46:	fdc40593          	addi	a1,s0,-36
    80004c4a:	c79fd0ef          	jal	800028c2 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004c4e:	fdc42703          	lw	a4,-36(s0)
    80004c52:	47bd                	li	a5,15
    80004c54:	02e7e963          	bltu	a5,a4,80004c86 <argfd+0x50>
    80004c58:	c4dfc0ef          	jal	800018a4 <myproc>
    80004c5c:	fdc42703          	lw	a4,-36(s0)
    80004c60:	01a70793          	addi	a5,a4,26
    80004c64:	078e                	slli	a5,a5,0x3
    80004c66:	953e                	add	a0,a0,a5
    80004c68:	611c                	ld	a5,0(a0)
    80004c6a:	c385                	beqz	a5,80004c8a <argfd+0x54>
    return -1;
  if (pfd)
    80004c6c:	00090463          	beqz	s2,80004c74 <argfd+0x3e>
    *pfd = fd;
    80004c70:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004c74:	4501                	li	a0,0
  if (pf)
    80004c76:	c091                	beqz	s1,80004c7a <argfd+0x44>
    *pf = f;
    80004c78:	e09c                	sd	a5,0(s1)
}
    80004c7a:	70a2                	ld	ra,40(sp)
    80004c7c:	7402                	ld	s0,32(sp)
    80004c7e:	64e2                	ld	s1,24(sp)
    80004c80:	6942                	ld	s2,16(sp)
    80004c82:	6145                	addi	sp,sp,48
    80004c84:	8082                	ret
    return -1;
    80004c86:	557d                	li	a0,-1
    80004c88:	bfcd                	j	80004c7a <argfd+0x44>
    80004c8a:	557d                	li	a0,-1
    80004c8c:	b7fd                	j	80004c7a <argfd+0x44>

0000000080004c8e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c8e:	1101                	addi	sp,sp,-32
    80004c90:	ec06                	sd	ra,24(sp)
    80004c92:	e822                	sd	s0,16(sp)
    80004c94:	e426                	sd	s1,8(sp)
    80004c96:	1000                	addi	s0,sp,32
    80004c98:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c9a:	c0bfc0ef          	jal	800018a4 <myproc>
    80004c9e:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004ca0:	0d050793          	addi	a5,a0,208
    80004ca4:	4501                	li	a0,0
    80004ca6:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004ca8:	6398                	ld	a4,0(a5)
    80004caa:	cb19                	beqz	a4,80004cc0 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004cac:	2505                	addiw	a0,a0,1
    80004cae:	07a1                	addi	a5,a5,8
    80004cb0:	fed51ce3          	bne	a0,a3,80004ca8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cb4:	557d                	li	a0,-1
}
    80004cb6:	60e2                	ld	ra,24(sp)
    80004cb8:	6442                	ld	s0,16(sp)
    80004cba:	64a2                	ld	s1,8(sp)
    80004cbc:	6105                	addi	sp,sp,32
    80004cbe:	8082                	ret
      p->ofile[fd] = f;
    80004cc0:	01a50793          	addi	a5,a0,26
    80004cc4:	078e                	slli	a5,a5,0x3
    80004cc6:	963e                	add	a2,a2,a5
    80004cc8:	e204                	sd	s1,0(a2)
      return fd;
    80004cca:	b7f5                	j	80004cb6 <fdalloc+0x28>

0000000080004ccc <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004ccc:	715d                	addi	sp,sp,-80
    80004cce:	e486                	sd	ra,72(sp)
    80004cd0:	e0a2                	sd	s0,64(sp)
    80004cd2:	fc26                	sd	s1,56(sp)
    80004cd4:	f84a                	sd	s2,48(sp)
    80004cd6:	f44e                	sd	s3,40(sp)
    80004cd8:	f052                	sd	s4,32(sp)
    80004cda:	ec56                	sd	s5,24(sp)
    80004cdc:	0880                	addi	s0,sp,80
    80004cde:	892e                	mv	s2,a1
    80004ce0:	89b2                	mv	s3,a2
    80004ce2:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004ce4:	fb040593          	addi	a1,s0,-80
    80004ce8:	f2bfe0ef          	jal	80003c12 <nameiparent>
    80004cec:	8aaa                	mv	s5,a0
    80004cee:	cd45                	beqz	a0,80004da6 <create+0xda>
    return 0;

  ilock(dp);
    80004cf0:	e94fe0ef          	jal	80003384 <ilock>

  if (dp->nlink == 0) {
    80004cf4:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffdde4a>
    80004cf8:	cf8d                	beqz	a5,80004d32 <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004cfa:	4705                	li	a4,1
    80004cfc:	04e91563          	bne	s2,a4,80004d46 <create+0x7a>
    80004d00:	6721                	lui	a4,0x8
    80004d02:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004d04:	02e78c63          	beq	a5,a4,80004d3c <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d08:	4601                	li	a2,0
    80004d0a:	fb040593          	addi	a1,s0,-80
    80004d0e:	8556                	mv	a0,s5
    80004d10:	c73fe0ef          	jal	80003982 <dirlookup>
    80004d14:	84aa                	mv	s1,a0
    80004d16:	e951                	bnez	a0,80004daa <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004d18:	85ca                	mv	a1,s2
    80004d1a:	000aa503          	lw	a0,0(s5)
    80004d1e:	cf6fe0ef          	jal	80003214 <ialloc>
    80004d22:	84aa                	mv	s1,a0
    80004d24:	0c051e63          	bnez	a0,80004e00 <create+0x134>
    iunlockput(dp);
    80004d28:	8556                	mv	a0,s5
    80004d2a:	8adfe0ef          	jal	800035d6 <iunlockput>
    return 0;
    80004d2e:	4481                	li	s1,0
    80004d30:	a0a1                	j	80004d78 <create+0xac>
    iunlockput(dp);
    80004d32:	8556                	mv	a0,s5
    80004d34:	8a3fe0ef          	jal	800035d6 <iunlockput>
    return 0;
    80004d38:	4481                	li	s1,0
    80004d3a:	a83d                	j	80004d78 <create+0xac>
    iunlockput(dp);
    80004d3c:	8556                	mv	a0,s5
    80004d3e:	899fe0ef          	jal	800035d6 <iunlockput>
    return 0;
    80004d42:	4481                	li	s1,0
    80004d44:	a815                	j	80004d78 <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d46:	4601                	li	a2,0
    80004d48:	fb040593          	addi	a1,s0,-80
    80004d4c:	8556                	mv	a0,s5
    80004d4e:	c35fe0ef          	jal	80003982 <dirlookup>
    80004d52:	84aa                	mv	s1,a0
    80004d54:	c535                	beqz	a0,80004dc0 <create+0xf4>
    iunlockput(dp);
    80004d56:	8556                	mv	a0,s5
    80004d58:	87ffe0ef          	jal	800035d6 <iunlockput>
    ilock(ip);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	e26fe0ef          	jal	80003384 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d62:	4789                	li	a5,2
    80004d64:	04f91963          	bne	s2,a5,80004db6 <create+0xea>
    80004d68:	0444d783          	lhu	a5,68(s1)
    80004d6c:	37f9                	addiw	a5,a5,-2
    80004d6e:	17c2                	slli	a5,a5,0x30
    80004d70:	93c1                	srli	a5,a5,0x30
    80004d72:	4705                	li	a4,1
    80004d74:	04f76163          	bltu	a4,a5,80004db6 <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d78:	8526                	mv	a0,s1
    80004d7a:	60a6                	ld	ra,72(sp)
    80004d7c:	6406                	ld	s0,64(sp)
    80004d7e:	74e2                	ld	s1,56(sp)
    80004d80:	7942                	ld	s2,48(sp)
    80004d82:	79a2                	ld	s3,40(sp)
    80004d84:	7a02                	ld	s4,32(sp)
    80004d86:	6ae2                	ld	s5,24(sp)
    80004d88:	6161                	addi	sp,sp,80
    80004d8a:	8082                	ret
  ip->nlink = 0;
    80004d8c:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80004d90:	8526                	mv	a0,s1
    80004d92:	d3efe0ef          	jal	800032d0 <iupdate>
  iunlockput(ip);
    80004d96:	8526                	mv	a0,s1
    80004d98:	83ffe0ef          	jal	800035d6 <iunlockput>
  iunlockput(dp);
    80004d9c:	8556                	mv	a0,s5
    80004d9e:	839fe0ef          	jal	800035d6 <iunlockput>
  return 0;
    80004da2:	4481                	li	s1,0
    80004da4:	bfd1                	j	80004d78 <create+0xac>
    return 0;
    80004da6:	84aa                	mv	s1,a0
    80004da8:	bfc1                	j	80004d78 <create+0xac>
    iunlockput(dp);
    80004daa:	8556                	mv	a0,s5
    80004dac:	82bfe0ef          	jal	800035d6 <iunlockput>
    ilock(ip);
    80004db0:	8526                	mv	a0,s1
    80004db2:	dd2fe0ef          	jal	80003384 <ilock>
    iunlockput(ip);
    80004db6:	8526                	mv	a0,s1
    80004db8:	81ffe0ef          	jal	800035d6 <iunlockput>
    return 0;
    80004dbc:	4481                	li	s1,0
    80004dbe:	bf6d                	j	80004d78 <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004dc0:	85ca                	mv	a1,s2
    80004dc2:	000aa503          	lw	a0,0(s5)
    80004dc6:	c4efe0ef          	jal	80003214 <ialloc>
    80004dca:	84aa                	mv	s1,a0
    80004dcc:	dd31                	beqz	a0,80004d28 <create+0x5c>
  ilock(ip);
    80004dce:	8526                	mv	a0,s1
    80004dd0:	db4fe0ef          	jal	80003384 <ilock>
  ip->major = major;
    80004dd4:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004dd8:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004ddc:	4785                	li	a5,1
    80004dde:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004de2:	8526                	mv	a0,s1
    80004de4:	cecfe0ef          	jal	800032d0 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80004de8:	40d0                	lw	a2,4(s1)
    80004dea:	fb040593          	addi	a1,s0,-80
    80004dee:	8556                	mv	a0,s5
    80004df0:	d6ffe0ef          	jal	80003b5e <dirlink>
    80004df4:	f8054ce3          	bltz	a0,80004d8c <create+0xc0>
  iunlockput(dp);
    80004df8:	8556                	mv	a0,s5
    80004dfa:	fdcfe0ef          	jal	800035d6 <iunlockput>
  return ip;
    80004dfe:	bfad                	j	80004d78 <create+0xac>
  ilock(ip);
    80004e00:	8526                	mv	a0,s1
    80004e02:	d82fe0ef          	jal	80003384 <ilock>
  ip->major = major;
    80004e06:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004e0a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004e0e:	4785                	li	a5,1
    80004e10:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e14:	8526                	mv	a0,s1
    80004e16:	cbafe0ef          	jal	800032d0 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e1a:	40d0                	lw	a2,4(s1)
    80004e1c:	00002597          	auipc	a1,0x2
    80004e20:	7ec58593          	addi	a1,a1,2028 # 80007608 <etext+0x608>
    80004e24:	8526                	mv	a0,s1
    80004e26:	d39fe0ef          	jal	80003b5e <dirlink>
    80004e2a:	f60541e3          	bltz	a0,80004d8c <create+0xc0>
    80004e2e:	004aa603          	lw	a2,4(s5)
    80004e32:	00002597          	auipc	a1,0x2
    80004e36:	7ce58593          	addi	a1,a1,1998 # 80007600 <etext+0x600>
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	d23fe0ef          	jal	80003b5e <dirlink>
    80004e40:	f40546e3          	bltz	a0,80004d8c <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e44:	40d0                	lw	a2,4(s1)
    80004e46:	fb040593          	addi	a1,s0,-80
    80004e4a:	8556                	mv	a0,s5
    80004e4c:	d13fe0ef          	jal	80003b5e <dirlink>
    80004e50:	f2054ee3          	bltz	a0,80004d8c <create+0xc0>
    dp->nlink++; // for ".."
    80004e54:	04aad783          	lhu	a5,74(s5)
    80004e58:	2785                	addiw	a5,a5,1
    80004e5a:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    80004e5e:	8556                	mv	a0,s5
    80004e60:	c70fe0ef          	jal	800032d0 <iupdate>
    80004e64:	bf51                	j	80004df8 <create+0x12c>

0000000080004e66 <sys_dup>:
{
    80004e66:	7179                	addi	sp,sp,-48
    80004e68:	f406                	sd	ra,40(sp)
    80004e6a:	f022                	sd	s0,32(sp)
    80004e6c:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004e6e:	fd840613          	addi	a2,s0,-40
    80004e72:	4581                	li	a1,0
    80004e74:	4501                	li	a0,0
    80004e76:	dc1ff0ef          	jal	80004c36 <argfd>
    return -1;
    80004e7a:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004e7c:	02054363          	bltz	a0,80004ea2 <sys_dup+0x3c>
    80004e80:	ec26                	sd	s1,24(sp)
    80004e82:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004e84:	fd843903          	ld	s2,-40(s0)
    80004e88:	854a                	mv	a0,s2
    80004e8a:	e05ff0ef          	jal	80004c8e <fdalloc>
    80004e8e:	84aa                	mv	s1,a0
    return -1;
    80004e90:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004e92:	00054d63          	bltz	a0,80004eac <sys_dup+0x46>
  filedup(f);
    80004e96:	854a                	mv	a0,s2
    80004e98:	b9aff0ef          	jal	80004232 <filedup>
  return fd;
    80004e9c:	87a6                	mv	a5,s1
    80004e9e:	64e2                	ld	s1,24(sp)
    80004ea0:	6942                	ld	s2,16(sp)
}
    80004ea2:	853e                	mv	a0,a5
    80004ea4:	70a2                	ld	ra,40(sp)
    80004ea6:	7402                	ld	s0,32(sp)
    80004ea8:	6145                	addi	sp,sp,48
    80004eaa:	8082                	ret
    80004eac:	64e2                	ld	s1,24(sp)
    80004eae:	6942                	ld	s2,16(sp)
    80004eb0:	bfcd                	j	80004ea2 <sys_dup+0x3c>

0000000080004eb2 <sys_read>:
{
    80004eb2:	7179                	addi	sp,sp,-48
    80004eb4:	f406                	sd	ra,40(sp)
    80004eb6:	f022                	sd	s0,32(sp)
    80004eb8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004eba:	fd840593          	addi	a1,s0,-40
    80004ebe:	4505                	li	a0,1
    80004ec0:	a1ffd0ef          	jal	800028de <argaddr>
  argint(2, &n);
    80004ec4:	fe440593          	addi	a1,s0,-28
    80004ec8:	4509                	li	a0,2
    80004eca:	9f9fd0ef          	jal	800028c2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004ece:	fe840613          	addi	a2,s0,-24
    80004ed2:	4581                	li	a1,0
    80004ed4:	4501                	li	a0,0
    80004ed6:	d61ff0ef          	jal	80004c36 <argfd>
    80004eda:	87aa                	mv	a5,a0
    return -1;
    80004edc:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ede:	0007ca63          	bltz	a5,80004ef2 <sys_read+0x40>
  return fileread(f, p, n);
    80004ee2:	fe442603          	lw	a2,-28(s0)
    80004ee6:	fd843583          	ld	a1,-40(s0)
    80004eea:	fe843503          	ld	a0,-24(s0)
    80004eee:	caeff0ef          	jal	8000439c <fileread>
}
    80004ef2:	70a2                	ld	ra,40(sp)
    80004ef4:	7402                	ld	s0,32(sp)
    80004ef6:	6145                	addi	sp,sp,48
    80004ef8:	8082                	ret

0000000080004efa <sys_write>:
{
    80004efa:	7179                	addi	sp,sp,-48
    80004efc:	f406                	sd	ra,40(sp)
    80004efe:	f022                	sd	s0,32(sp)
    80004f00:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f02:	fd840593          	addi	a1,s0,-40
    80004f06:	4505                	li	a0,1
    80004f08:	9d7fd0ef          	jal	800028de <argaddr>
  argint(2, &n);
    80004f0c:	fe440593          	addi	a1,s0,-28
    80004f10:	4509                	li	a0,2
    80004f12:	9b1fd0ef          	jal	800028c2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f16:	fe840613          	addi	a2,s0,-24
    80004f1a:	4581                	li	a1,0
    80004f1c:	4501                	li	a0,0
    80004f1e:	d19ff0ef          	jal	80004c36 <argfd>
    80004f22:	87aa                	mv	a5,a0
    return -1;
    80004f24:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f26:	0007ca63          	bltz	a5,80004f3a <sys_write+0x40>
  return filewrite(f, p, n);
    80004f2a:	fe442603          	lw	a2,-28(s0)
    80004f2e:	fd843583          	ld	a1,-40(s0)
    80004f32:	fe843503          	ld	a0,-24(s0)
    80004f36:	d30ff0ef          	jal	80004466 <filewrite>
}
    80004f3a:	70a2                	ld	ra,40(sp)
    80004f3c:	7402                	ld	s0,32(sp)
    80004f3e:	6145                	addi	sp,sp,48
    80004f40:	8082                	ret

0000000080004f42 <sys_close>:
{
    80004f42:	1101                	addi	sp,sp,-32
    80004f44:	ec06                	sd	ra,24(sp)
    80004f46:	e822                	sd	s0,16(sp)
    80004f48:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004f4a:	fe040613          	addi	a2,s0,-32
    80004f4e:	fec40593          	addi	a1,s0,-20
    80004f52:	4501                	li	a0,0
    80004f54:	ce3ff0ef          	jal	80004c36 <argfd>
    return -1;
    80004f58:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004f5a:	02054063          	bltz	a0,80004f7a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f5e:	947fc0ef          	jal	800018a4 <myproc>
    80004f62:	fec42783          	lw	a5,-20(s0)
    80004f66:	07e9                	addi	a5,a5,26
    80004f68:	078e                	slli	a5,a5,0x3
    80004f6a:	953e                	add	a0,a0,a5
    80004f6c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f70:	fe043503          	ld	a0,-32(s0)
    80004f74:	b04ff0ef          	jal	80004278 <fileclose>
  return 0;
    80004f78:	4781                	li	a5,0
}
    80004f7a:	853e                	mv	a0,a5
    80004f7c:	60e2                	ld	ra,24(sp)
    80004f7e:	6442                	ld	s0,16(sp)
    80004f80:	6105                	addi	sp,sp,32
    80004f82:	8082                	ret

0000000080004f84 <sys_fstat>:
{
    80004f84:	1101                	addi	sp,sp,-32
    80004f86:	ec06                	sd	ra,24(sp)
    80004f88:	e822                	sd	s0,16(sp)
    80004f8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f8c:	fe040593          	addi	a1,s0,-32
    80004f90:	4505                	li	a0,1
    80004f92:	94dfd0ef          	jal	800028de <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004f96:	fe840613          	addi	a2,s0,-24
    80004f9a:	4581                	li	a1,0
    80004f9c:	4501                	li	a0,0
    80004f9e:	c99ff0ef          	jal	80004c36 <argfd>
    80004fa2:	87aa                	mv	a5,a0
    return -1;
    80004fa4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fa6:	0007c863          	bltz	a5,80004fb6 <sys_fstat+0x32>
  return filestat(f, st);
    80004faa:	fe043583          	ld	a1,-32(s0)
    80004fae:	fe843503          	ld	a0,-24(s0)
    80004fb2:	b88ff0ef          	jal	8000433a <filestat>
}
    80004fb6:	60e2                	ld	ra,24(sp)
    80004fb8:	6442                	ld	s0,16(sp)
    80004fba:	6105                	addi	sp,sp,32
    80004fbc:	8082                	ret

0000000080004fbe <sys_link>:
{
    80004fbe:	7169                	addi	sp,sp,-304
    80004fc0:	f606                	sd	ra,296(sp)
    80004fc2:	f222                	sd	s0,288(sp)
    80004fc4:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fc6:	08000613          	li	a2,128
    80004fca:	ed040593          	addi	a1,s0,-304
    80004fce:	4501                	li	a0,0
    80004fd0:	92bfd0ef          	jal	800028fa <argstr>
    return -1;
    80004fd4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd6:	10054163          	bltz	a0,800050d8 <sys_link+0x11a>
    80004fda:	08000613          	li	a2,128
    80004fde:	f5040593          	addi	a1,s0,-176
    80004fe2:	4505                	li	a0,1
    80004fe4:	917fd0ef          	jal	800028fa <argstr>
    return -1;
    80004fe8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fea:	0e054763          	bltz	a0,800050d8 <sys_link+0x11a>
    80004fee:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ff0:	dddfe0ef          	jal	80003dcc <begin_op>
  if ((ip = namei(old)) == 0) {
    80004ff4:	ed040513          	addi	a0,s0,-304
    80004ff8:	c01fe0ef          	jal	80003bf8 <namei>
    80004ffc:	84aa                	mv	s1,a0
    80004ffe:	cd35                	beqz	a0,8000507a <sys_link+0xbc>
  ilock(ip);
    80005000:	b84fe0ef          	jal	80003384 <ilock>
  if (ip->type == T_DIR) {
    80005004:	04449703          	lh	a4,68(s1)
    80005008:	4785                	li	a5,1
    8000500a:	06f70d63          	beq	a4,a5,80005084 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    8000500e:	04a49783          	lh	a5,74(s1)
    80005012:	6721                	lui	a4,0x8
    80005014:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005016:	06e78f63          	beq	a5,a4,80005094 <sys_link+0xd6>
    8000501a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000501c:	2785                	addiw	a5,a5,1
    8000501e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005022:	8526                	mv	a0,s1
    80005024:	aacfe0ef          	jal	800032d0 <iupdate>
  iunlock(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	c08fe0ef          	jal	80003432 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000502e:	fd040593          	addi	a1,s0,-48
    80005032:	f5040513          	addi	a0,s0,-176
    80005036:	bddfe0ef          	jal	80003c12 <nameiparent>
    8000503a:	892a                	mv	s2,a0
    8000503c:	c93d                	beqz	a0,800050b2 <sys_link+0xf4>
  ilock(dp);
    8000503e:	b46fe0ef          	jal	80003384 <ilock>
  if (dp->nlink == 0) {
    80005042:	04a91783          	lh	a5,74(s2)
    80005046:	cfb9                	beqz	a5,800050a4 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005048:	00092703          	lw	a4,0(s2)
    8000504c:	409c                	lw	a5,0(s1)
    8000504e:	04f71f63          	bne	a4,a5,800050ac <sys_link+0xee>
    80005052:	40d0                	lw	a2,4(s1)
    80005054:	fd040593          	addi	a1,s0,-48
    80005058:	854a                	mv	a0,s2
    8000505a:	b05fe0ef          	jal	80003b5e <dirlink>
    8000505e:	04054763          	bltz	a0,800050ac <sys_link+0xee>
  iunlockput(dp);
    80005062:	854a                	mv	a0,s2
    80005064:	d72fe0ef          	jal	800035d6 <iunlockput>
  iput(ip);
    80005068:	8526                	mv	a0,s1
    8000506a:	c9cfe0ef          	jal	80003506 <iput>
  end_op();
    8000506e:	de5fe0ef          	jal	80003e52 <end_op>
  return 0;
    80005072:	4781                	li	a5,0
    80005074:	64f2                	ld	s1,280(sp)
    80005076:	6952                	ld	s2,272(sp)
    80005078:	a085                	j	800050d8 <sys_link+0x11a>
    end_op();
    8000507a:	dd9fe0ef          	jal	80003e52 <end_op>
    return -1;
    8000507e:	57fd                	li	a5,-1
    80005080:	64f2                	ld	s1,280(sp)
    80005082:	a899                	j	800050d8 <sys_link+0x11a>
    iunlockput(ip);
    80005084:	8526                	mv	a0,s1
    80005086:	d50fe0ef          	jal	800035d6 <iunlockput>
    end_op();
    8000508a:	dc9fe0ef          	jal	80003e52 <end_op>
    return -1;
    8000508e:	57fd                	li	a5,-1
    80005090:	64f2                	ld	s1,280(sp)
    80005092:	a099                	j	800050d8 <sys_link+0x11a>
    iunlockput(ip);
    80005094:	8526                	mv	a0,s1
    80005096:	d40fe0ef          	jal	800035d6 <iunlockput>
    end_op();
    8000509a:	db9fe0ef          	jal	80003e52 <end_op>
    return -1;
    8000509e:	57fd                	li	a5,-1
    800050a0:	64f2                	ld	s1,280(sp)
    800050a2:	a81d                	j	800050d8 <sys_link+0x11a>
    iunlockput(dp);
    800050a4:	854a                	mv	a0,s2
    800050a6:	d30fe0ef          	jal	800035d6 <iunlockput>
    goto bad;
    800050aa:	a021                	j	800050b2 <sys_link+0xf4>
    iunlockput(dp);
    800050ac:	854a                	mv	a0,s2
    800050ae:	d28fe0ef          	jal	800035d6 <iunlockput>
  ilock(ip);
    800050b2:	8526                	mv	a0,s1
    800050b4:	ad0fe0ef          	jal	80003384 <ilock>
  ip->nlink--;
    800050b8:	04a4d783          	lhu	a5,74(s1)
    800050bc:	37fd                	addiw	a5,a5,-1
    800050be:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050c2:	8526                	mv	a0,s1
    800050c4:	a0cfe0ef          	jal	800032d0 <iupdate>
  iunlockput(ip);
    800050c8:	8526                	mv	a0,s1
    800050ca:	d0cfe0ef          	jal	800035d6 <iunlockput>
  end_op();
    800050ce:	d85fe0ef          	jal	80003e52 <end_op>
  return -1;
    800050d2:	57fd                	li	a5,-1
    800050d4:	64f2                	ld	s1,280(sp)
    800050d6:	6952                	ld	s2,272(sp)
}
    800050d8:	853e                	mv	a0,a5
    800050da:	70b2                	ld	ra,296(sp)
    800050dc:	7412                	ld	s0,288(sp)
    800050de:	6155                	addi	sp,sp,304
    800050e0:	8082                	ret

00000000800050e2 <sys_unlink>:
{
    800050e2:	7151                	addi	sp,sp,-240
    800050e4:	f586                	sd	ra,232(sp)
    800050e6:	f1a2                	sd	s0,224(sp)
    800050e8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800050ea:	08000613          	li	a2,128
    800050ee:	f3040593          	addi	a1,s0,-208
    800050f2:	4501                	li	a0,0
    800050f4:	807fd0ef          	jal	800028fa <argstr>
    800050f8:	16054063          	bltz	a0,80005258 <sys_unlink+0x176>
    800050fc:	eda6                	sd	s1,216(sp)
  begin_op();
    800050fe:	ccffe0ef          	jal	80003dcc <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005102:	fb040593          	addi	a1,s0,-80
    80005106:	f3040513          	addi	a0,s0,-208
    8000510a:	b09fe0ef          	jal	80003c12 <nameiparent>
    8000510e:	84aa                	mv	s1,a0
    80005110:	c945                	beqz	a0,800051c0 <sys_unlink+0xde>
  ilock(dp);
    80005112:	a72fe0ef          	jal	80003384 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005116:	00002597          	auipc	a1,0x2
    8000511a:	4f258593          	addi	a1,a1,1266 # 80007608 <etext+0x608>
    8000511e:	fb040513          	addi	a0,s0,-80
    80005122:	84bfe0ef          	jal	8000396c <namecmp>
    80005126:	10050e63          	beqz	a0,80005242 <sys_unlink+0x160>
    8000512a:	00002597          	auipc	a1,0x2
    8000512e:	4d658593          	addi	a1,a1,1238 # 80007600 <etext+0x600>
    80005132:	fb040513          	addi	a0,s0,-80
    80005136:	837fe0ef          	jal	8000396c <namecmp>
    8000513a:	10050463          	beqz	a0,80005242 <sys_unlink+0x160>
    8000513e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005140:	f2c40613          	addi	a2,s0,-212
    80005144:	fb040593          	addi	a1,s0,-80
    80005148:	8526                	mv	a0,s1
    8000514a:	839fe0ef          	jal	80003982 <dirlookup>
    8000514e:	892a                	mv	s2,a0
    80005150:	0e050863          	beqz	a0,80005240 <sys_unlink+0x15e>
  ilock(ip);
    80005154:	a30fe0ef          	jal	80003384 <ilock>
  if (ip->nlink < 1)
    80005158:	04a91783          	lh	a5,74(s2)
    8000515c:	06f05763          	blez	a5,800051ca <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005160:	04491703          	lh	a4,68(s2)
    80005164:	4785                	li	a5,1
    80005166:	06f70963          	beq	a4,a5,800051d8 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    8000516a:	4641                	li	a2,16
    8000516c:	4581                	li	a1,0
    8000516e:	fc040513          	addi	a0,s0,-64
    80005172:	ae3fb0ef          	jal	80000c54 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005176:	4741                	li	a4,16
    80005178:	f2c42683          	lw	a3,-212(s0)
    8000517c:	fc040613          	addi	a2,s0,-64
    80005180:	4581                	li	a1,0
    80005182:	8526                	mv	a0,s1
    80005184:	ed4fe0ef          	jal	80003858 <writei>
    80005188:	47c1                	li	a5,16
    8000518a:	08f51b63          	bne	a0,a5,80005220 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    8000518e:	04491703          	lh	a4,68(s2)
    80005192:	4785                	li	a5,1
    80005194:	08f70d63          	beq	a4,a5,8000522e <sys_unlink+0x14c>
  iunlockput(dp);
    80005198:	8526                	mv	a0,s1
    8000519a:	c3cfe0ef          	jal	800035d6 <iunlockput>
  ip->nlink--;
    8000519e:	04a95783          	lhu	a5,74(s2)
    800051a2:	37fd                	addiw	a5,a5,-1
    800051a4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051a8:	854a                	mv	a0,s2
    800051aa:	926fe0ef          	jal	800032d0 <iupdate>
  iunlockput(ip);
    800051ae:	854a                	mv	a0,s2
    800051b0:	c26fe0ef          	jal	800035d6 <iunlockput>
  end_op();
    800051b4:	c9ffe0ef          	jal	80003e52 <end_op>
  return 0;
    800051b8:	4501                	li	a0,0
    800051ba:	64ee                	ld	s1,216(sp)
    800051bc:	694e                	ld	s2,208(sp)
    800051be:	a849                	j	80005250 <sys_unlink+0x16e>
    end_op();
    800051c0:	c93fe0ef          	jal	80003e52 <end_op>
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	64ee                	ld	s1,216(sp)
    800051c8:	a061                	j	80005250 <sys_unlink+0x16e>
    800051ca:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800051cc:	00002517          	auipc	a0,0x2
    800051d0:	44450513          	addi	a0,a0,1092 # 80007610 <etext+0x610>
    800051d4:	e1cfb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800051d8:	04c92703          	lw	a4,76(s2)
    800051dc:	02000793          	li	a5,32
    800051e0:	f8e7f5e3          	bgeu	a5,a4,8000516a <sys_unlink+0x88>
    800051e4:	e5ce                	sd	s3,200(sp)
    800051e6:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051ea:	4741                	li	a4,16
    800051ec:	86ce                	mv	a3,s3
    800051ee:	f1840613          	addi	a2,s0,-232
    800051f2:	4581                	li	a1,0
    800051f4:	854a                	mv	a0,s2
    800051f6:	d66fe0ef          	jal	8000375c <readi>
    800051fa:	47c1                	li	a5,16
    800051fc:	00f51c63          	bne	a0,a5,80005214 <sys_unlink+0x132>
    if (de.inum != 0)
    80005200:	f1845783          	lhu	a5,-232(s0)
    80005204:	efa1                	bnez	a5,8000525c <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005206:	29c1                	addiw	s3,s3,16
    80005208:	04c92783          	lw	a5,76(s2)
    8000520c:	fcf9efe3          	bltu	s3,a5,800051ea <sys_unlink+0x108>
    80005210:	69ae                	ld	s3,200(sp)
    80005212:	bfa1                	j	8000516a <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005214:	00002517          	auipc	a0,0x2
    80005218:	41450513          	addi	a0,a0,1044 # 80007628 <etext+0x628>
    8000521c:	dd4fb0ef          	jal	800007f0 <panic>
    80005220:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005222:	00002517          	auipc	a0,0x2
    80005226:	41e50513          	addi	a0,a0,1054 # 80007640 <etext+0x640>
    8000522a:	dc6fb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    8000522e:	04a4d783          	lhu	a5,74(s1)
    80005232:	37fd                	addiw	a5,a5,-1
    80005234:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005238:	8526                	mv	a0,s1
    8000523a:	896fe0ef          	jal	800032d0 <iupdate>
    8000523e:	bfa9                	j	80005198 <sys_unlink+0xb6>
    80005240:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005242:	8526                	mv	a0,s1
    80005244:	b92fe0ef          	jal	800035d6 <iunlockput>
  end_op();
    80005248:	c0bfe0ef          	jal	80003e52 <end_op>
  return -1;
    8000524c:	557d                	li	a0,-1
    8000524e:	64ee                	ld	s1,216(sp)
}
    80005250:	70ae                	ld	ra,232(sp)
    80005252:	740e                	ld	s0,224(sp)
    80005254:	616d                	addi	sp,sp,240
    80005256:	8082                	ret
    return -1;
    80005258:	557d                	li	a0,-1
    8000525a:	bfdd                	j	80005250 <sys_unlink+0x16e>
    iunlockput(ip);
    8000525c:	854a                	mv	a0,s2
    8000525e:	b78fe0ef          	jal	800035d6 <iunlockput>
    goto bad;
    80005262:	694e                	ld	s2,208(sp)
    80005264:	69ae                	ld	s3,200(sp)
    80005266:	bff1                	j	80005242 <sys_unlink+0x160>

0000000080005268 <sys_open>:

uint64
sys_open(void)
{
    80005268:	7131                	addi	sp,sp,-192
    8000526a:	fd06                	sd	ra,184(sp)
    8000526c:	f922                	sd	s0,176(sp)
    8000526e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005270:	f4c40593          	addi	a1,s0,-180
    80005274:	4505                	li	a0,1
    80005276:	e4cfd0ef          	jal	800028c2 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000527a:	08000613          	li	a2,128
    8000527e:	f5040593          	addi	a1,s0,-176
    80005282:	4501                	li	a0,0
    80005284:	e76fd0ef          	jal	800028fa <argstr>
    80005288:	87aa                	mv	a5,a0
    return -1;
    8000528a:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000528c:	0a07c263          	bltz	a5,80005330 <sys_open+0xc8>
    80005290:	f526                	sd	s1,168(sp)

  begin_op();
    80005292:	b3bfe0ef          	jal	80003dcc <begin_op>

  if (omode & O_CREATE) {
    80005296:	f4c42783          	lw	a5,-180(s0)
    8000529a:	2007f793          	andi	a5,a5,512
    8000529e:	c3d5                	beqz	a5,80005342 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800052a0:	4681                	li	a3,0
    800052a2:	4601                	li	a2,0
    800052a4:	4589                	li	a1,2
    800052a6:	f5040513          	addi	a0,s0,-176
    800052aa:	a23ff0ef          	jal	80004ccc <create>
    800052ae:	84aa                	mv	s1,a0
    if (ip == 0) {
    800052b0:	c541                	beqz	a0,80005338 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800052b2:	04449703          	lh	a4,68(s1)
    800052b6:	478d                	li	a5,3
    800052b8:	00f71763          	bne	a4,a5,800052c6 <sys_open+0x5e>
    800052bc:	0464d703          	lhu	a4,70(s1)
    800052c0:	47a5                	li	a5,9
    800052c2:	0ae7ed63          	bltu	a5,a4,8000537c <sys_open+0x114>
    800052c6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800052c8:	f0dfe0ef          	jal	800041d4 <filealloc>
    800052cc:	892a                	mv	s2,a0
    800052ce:	c179                	beqz	a0,80005394 <sys_open+0x12c>
    800052d0:	ed4e                	sd	s3,152(sp)
    800052d2:	9bdff0ef          	jal	80004c8e <fdalloc>
    800052d6:	89aa                	mv	s3,a0
    800052d8:	0a054a63          	bltz	a0,8000538c <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800052dc:	04449703          	lh	a4,68(s1)
    800052e0:	478d                	li	a5,3
    800052e2:	0cf70263          	beq	a4,a5,800053a6 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052e6:	4789                	li	a5,2
    800052e8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052ec:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052f0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052f4:	f4c42783          	lw	a5,-180(s0)
    800052f8:	0017c713          	xori	a4,a5,1
    800052fc:	8b05                	andi	a4,a4,1
    800052fe:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005302:	0037f713          	andi	a4,a5,3
    80005306:	00e03733          	snez	a4,a4
    8000530a:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000530e:	4007f793          	andi	a5,a5,1024
    80005312:	c791                	beqz	a5,8000531e <sys_open+0xb6>
    80005314:	04449703          	lh	a4,68(s1)
    80005318:	4789                	li	a5,2
    8000531a:	08f70d63          	beq	a4,a5,800053b4 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000531e:	8526                	mv	a0,s1
    80005320:	912fe0ef          	jal	80003432 <iunlock>
  end_op();
    80005324:	b2ffe0ef          	jal	80003e52 <end_op>

  return fd;
    80005328:	854e                	mv	a0,s3
    8000532a:	74aa                	ld	s1,168(sp)
    8000532c:	790a                	ld	s2,160(sp)
    8000532e:	69ea                	ld	s3,152(sp)
}
    80005330:	70ea                	ld	ra,184(sp)
    80005332:	744a                	ld	s0,176(sp)
    80005334:	6129                	addi	sp,sp,192
    80005336:	8082                	ret
      end_op();
    80005338:	b1bfe0ef          	jal	80003e52 <end_op>
      return -1;
    8000533c:	557d                	li	a0,-1
    8000533e:	74aa                	ld	s1,168(sp)
    80005340:	bfc5                	j	80005330 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    80005342:	f5040513          	addi	a0,s0,-176
    80005346:	8b3fe0ef          	jal	80003bf8 <namei>
    8000534a:	84aa                	mv	s1,a0
    8000534c:	c11d                	beqz	a0,80005372 <sys_open+0x10a>
    ilock(ip);
    8000534e:	836fe0ef          	jal	80003384 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005352:	04449703          	lh	a4,68(s1)
    80005356:	4785                	li	a5,1
    80005358:	f4f71de3          	bne	a4,a5,800052b2 <sys_open+0x4a>
    8000535c:	f4c42783          	lw	a5,-180(s0)
    80005360:	d3bd                	beqz	a5,800052c6 <sys_open+0x5e>
      iunlockput(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	a72fe0ef          	jal	800035d6 <iunlockput>
      end_op();
    80005368:	aebfe0ef          	jal	80003e52 <end_op>
      return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	74aa                	ld	s1,168(sp)
    80005370:	b7c1                	j	80005330 <sys_open+0xc8>
      end_op();
    80005372:	ae1fe0ef          	jal	80003e52 <end_op>
      return -1;
    80005376:	557d                	li	a0,-1
    80005378:	74aa                	ld	s1,168(sp)
    8000537a:	bf5d                	j	80005330 <sys_open+0xc8>
    iunlockput(ip);
    8000537c:	8526                	mv	a0,s1
    8000537e:	a58fe0ef          	jal	800035d6 <iunlockput>
    end_op();
    80005382:	ad1fe0ef          	jal	80003e52 <end_op>
    return -1;
    80005386:	557d                	li	a0,-1
    80005388:	74aa                	ld	s1,168(sp)
    8000538a:	b75d                	j	80005330 <sys_open+0xc8>
      fileclose(f);
    8000538c:	854a                	mv	a0,s2
    8000538e:	eebfe0ef          	jal	80004278 <fileclose>
    80005392:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	a40fe0ef          	jal	800035d6 <iunlockput>
    end_op();
    8000539a:	ab9fe0ef          	jal	80003e52 <end_op>
    return -1;
    8000539e:	557d                	li	a0,-1
    800053a0:	74aa                	ld	s1,168(sp)
    800053a2:	790a                	ld	s2,160(sp)
    800053a4:	b771                	j	80005330 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800053a6:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800053aa:	04649783          	lh	a5,70(s1)
    800053ae:	02f91223          	sh	a5,36(s2)
    800053b2:	bf3d                	j	800052f0 <sys_open+0x88>
    itrunc(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	8bcfe0ef          	jal	80003472 <itrunc>
    800053ba:	b795                	j	8000531e <sys_open+0xb6>

00000000800053bc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053bc:	7175                	addi	sp,sp,-144
    800053be:	e506                	sd	ra,136(sp)
    800053c0:	e122                	sd	s0,128(sp)
    800053c2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053c4:	a09fe0ef          	jal	80003dcc <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800053c8:	08000613          	li	a2,128
    800053cc:	f7040593          	addi	a1,s0,-144
    800053d0:	4501                	li	a0,0
    800053d2:	d28fd0ef          	jal	800028fa <argstr>
    800053d6:	02054363          	bltz	a0,800053fc <sys_mkdir+0x40>
    800053da:	4681                	li	a3,0
    800053dc:	4601                	li	a2,0
    800053de:	4585                	li	a1,1
    800053e0:	f7040513          	addi	a0,s0,-144
    800053e4:	8e9ff0ef          	jal	80004ccc <create>
    800053e8:	c911                	beqz	a0,800053fc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ea:	9ecfe0ef          	jal	800035d6 <iunlockput>
  end_op();
    800053ee:	a65fe0ef          	jal	80003e52 <end_op>
  return 0;
    800053f2:	4501                	li	a0,0
}
    800053f4:	60aa                	ld	ra,136(sp)
    800053f6:	640a                	ld	s0,128(sp)
    800053f8:	6149                	addi	sp,sp,144
    800053fa:	8082                	ret
    end_op();
    800053fc:	a57fe0ef          	jal	80003e52 <end_op>
    return -1;
    80005400:	557d                	li	a0,-1
    80005402:	bfcd                	j	800053f4 <sys_mkdir+0x38>

0000000080005404 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005404:	7135                	addi	sp,sp,-160
    80005406:	ed06                	sd	ra,152(sp)
    80005408:	e922                	sd	s0,144(sp)
    8000540a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000540c:	9c1fe0ef          	jal	80003dcc <begin_op>
  argint(1, &major);
    80005410:	f6c40593          	addi	a1,s0,-148
    80005414:	4505                	li	a0,1
    80005416:	cacfd0ef          	jal	800028c2 <argint>
  argint(2, &minor);
    8000541a:	f6840593          	addi	a1,s0,-152
    8000541e:	4509                	li	a0,2
    80005420:	ca2fd0ef          	jal	800028c2 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005424:	08000613          	li	a2,128
    80005428:	f7040593          	addi	a1,s0,-144
    8000542c:	4501                	li	a0,0
    8000542e:	cccfd0ef          	jal	800028fa <argstr>
    80005432:	02054563          	bltz	a0,8000545c <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005436:	f6841683          	lh	a3,-152(s0)
    8000543a:	f6c41603          	lh	a2,-148(s0)
    8000543e:	458d                	li	a1,3
    80005440:	f7040513          	addi	a0,s0,-144
    80005444:	889ff0ef          	jal	80004ccc <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005448:	c911                	beqz	a0,8000545c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000544a:	98cfe0ef          	jal	800035d6 <iunlockput>
  end_op();
    8000544e:	a05fe0ef          	jal	80003e52 <end_op>
  return 0;
    80005452:	4501                	li	a0,0
}
    80005454:	60ea                	ld	ra,152(sp)
    80005456:	644a                	ld	s0,144(sp)
    80005458:	610d                	addi	sp,sp,160
    8000545a:	8082                	ret
    end_op();
    8000545c:	9f7fe0ef          	jal	80003e52 <end_op>
    return -1;
    80005460:	557d                	li	a0,-1
    80005462:	bfcd                	j	80005454 <sys_mknod+0x50>

0000000080005464 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005464:	7135                	addi	sp,sp,-160
    80005466:	ed06                	sd	ra,152(sp)
    80005468:	e922                	sd	s0,144(sp)
    8000546a:	e14a                	sd	s2,128(sp)
    8000546c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000546e:	c36fc0ef          	jal	800018a4 <myproc>
    80005472:	892a                	mv	s2,a0

  begin_op();
    80005474:	959fe0ef          	jal	80003dcc <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005478:	08000613          	li	a2,128
    8000547c:	f6040593          	addi	a1,s0,-160
    80005480:	4501                	li	a0,0
    80005482:	c78fd0ef          	jal	800028fa <argstr>
    80005486:	04054363          	bltz	a0,800054cc <sys_chdir+0x68>
    8000548a:	e526                	sd	s1,136(sp)
    8000548c:	f6040513          	addi	a0,s0,-160
    80005490:	f68fe0ef          	jal	80003bf8 <namei>
    80005494:	84aa                	mv	s1,a0
    80005496:	c915                	beqz	a0,800054ca <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005498:	eedfd0ef          	jal	80003384 <ilock>
  if (ip->type != T_DIR) {
    8000549c:	04449703          	lh	a4,68(s1)
    800054a0:	4785                	li	a5,1
    800054a2:	02f71963          	bne	a4,a5,800054d4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	f8bfd0ef          	jal	80003432 <iunlock>
  iput(p->cwd);
    800054ac:	15093503          	ld	a0,336(s2)
    800054b0:	856fe0ef          	jal	80003506 <iput>
  end_op();
    800054b4:	99ffe0ef          	jal	80003e52 <end_op>
  p->cwd = ip;
    800054b8:	14993823          	sd	s1,336(s2)
  return 0;
    800054bc:	4501                	li	a0,0
    800054be:	64aa                	ld	s1,136(sp)
}
    800054c0:	60ea                	ld	ra,152(sp)
    800054c2:	644a                	ld	s0,144(sp)
    800054c4:	690a                	ld	s2,128(sp)
    800054c6:	610d                	addi	sp,sp,160
    800054c8:	8082                	ret
    800054ca:	64aa                	ld	s1,136(sp)
    end_op();
    800054cc:	987fe0ef          	jal	80003e52 <end_op>
    return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	b7fd                	j	800054c0 <sys_chdir+0x5c>
    iunlockput(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	900fe0ef          	jal	800035d6 <iunlockput>
    end_op();
    800054da:	979fe0ef          	jal	80003e52 <end_op>
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	64aa                	ld	s1,136(sp)
    800054e2:	bff9                	j	800054c0 <sys_chdir+0x5c>

00000000800054e4 <sys_exec>:

uint64
sys_exec(void)
{
    800054e4:	7121                	addi	sp,sp,-448
    800054e6:	ff06                	sd	ra,440(sp)
    800054e8:	fb22                	sd	s0,432(sp)
    800054ea:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054ec:	e4840593          	addi	a1,s0,-440
    800054f0:	4505                	li	a0,1
    800054f2:	becfd0ef          	jal	800028de <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800054f6:	08000613          	li	a2,128
    800054fa:	f5040593          	addi	a1,s0,-176
    800054fe:	4501                	li	a0,0
    80005500:	bfafd0ef          	jal	800028fa <argstr>
    80005504:	87aa                	mv	a5,a0
    return -1;
    80005506:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005508:	0c07c463          	bltz	a5,800055d0 <sys_exec+0xec>
    8000550c:	f726                	sd	s1,424(sp)
    8000550e:	f34a                	sd	s2,416(sp)
    80005510:	ef4e                	sd	s3,408(sp)
    80005512:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005514:	10000613          	li	a2,256
    80005518:	4581                	li	a1,0
    8000551a:	e5040513          	addi	a0,s0,-432
    8000551e:	f36fb0ef          	jal	80000c54 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005522:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005526:	89a6                	mv	s3,s1
    80005528:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    8000552a:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000552e:	00391513          	slli	a0,s2,0x3
    80005532:	e4040593          	addi	a1,s0,-448
    80005536:	e4843783          	ld	a5,-440(s0)
    8000553a:	953e                	add	a0,a0,a5
    8000553c:	afafd0ef          	jal	80002836 <fetchaddr>
    80005540:	02054663          	bltz	a0,8000556c <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    80005544:	e4043783          	ld	a5,-448(s0)
    80005548:	c3a9                	beqz	a5,8000558a <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000554a:	d80fb0ef          	jal	80000aca <kalloc>
    8000554e:	85aa                	mv	a1,a0
    80005550:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005554:	cd01                	beqz	a0,8000556c <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005556:	6605                	lui	a2,0x1
    80005558:	e4043503          	ld	a0,-448(s0)
    8000555c:	b24fd0ef          	jal	80002880 <fetchstr>
    80005560:	00054663          	bltz	a0,8000556c <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    80005564:	0905                	addi	s2,s2,1
    80005566:	09a1                	addi	s3,s3,8
    80005568:	fd4913e3          	bne	s2,s4,8000552e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000556c:	f5040913          	addi	s2,s0,-176
    80005570:	6088                	ld	a0,0(s1)
    80005572:	c931                	beqz	a0,800055c6 <sys_exec+0xe2>
    kfree(argv[i]);
    80005574:	c74fb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005578:	04a1                	addi	s1,s1,8
    8000557a:	ff249be3          	bne	s1,s2,80005570 <sys_exec+0x8c>
  return -1;
    8000557e:	557d                	li	a0,-1
    80005580:	74ba                	ld	s1,424(sp)
    80005582:	791a                	ld	s2,416(sp)
    80005584:	69fa                	ld	s3,408(sp)
    80005586:	6a5a                	ld	s4,400(sp)
    80005588:	a0a1                	j	800055d0 <sys_exec+0xec>
      argv[i] = 0;
    8000558a:	0009079b          	sext.w	a5,s2
    8000558e:	078e                	slli	a5,a5,0x3
    80005590:	fd078793          	addi	a5,a5,-48
    80005594:	97a2                	add	a5,a5,s0
    80005596:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000559a:	e5040593          	addi	a1,s0,-432
    8000559e:	f5040513          	addi	a0,s0,-176
    800055a2:	b26ff0ef          	jal	800048c8 <kexec>
    800055a6:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055a8:	f5040993          	addi	s3,s0,-176
    800055ac:	6088                	ld	a0,0(s1)
    800055ae:	c511                	beqz	a0,800055ba <sys_exec+0xd6>
    kfree(argv[i]);
    800055b0:	c38fb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b4:	04a1                	addi	s1,s1,8
    800055b6:	ff349be3          	bne	s1,s3,800055ac <sys_exec+0xc8>
  return ret;
    800055ba:	854a                	mv	a0,s2
    800055bc:	74ba                	ld	s1,424(sp)
    800055be:	791a                	ld	s2,416(sp)
    800055c0:	69fa                	ld	s3,408(sp)
    800055c2:	6a5a                	ld	s4,400(sp)
    800055c4:	a031                	j	800055d0 <sys_exec+0xec>
  return -1;
    800055c6:	557d                	li	a0,-1
    800055c8:	74ba                	ld	s1,424(sp)
    800055ca:	791a                	ld	s2,416(sp)
    800055cc:	69fa                	ld	s3,408(sp)
    800055ce:	6a5a                	ld	s4,400(sp)
}
    800055d0:	70fa                	ld	ra,440(sp)
    800055d2:	745a                	ld	s0,432(sp)
    800055d4:	6139                	addi	sp,sp,448
    800055d6:	8082                	ret

00000000800055d8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055d8:	7139                	addi	sp,sp,-64
    800055da:	fc06                	sd	ra,56(sp)
    800055dc:	f822                	sd	s0,48(sp)
    800055de:	f426                	sd	s1,40(sp)
    800055e0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055e2:	ac2fc0ef          	jal	800018a4 <myproc>
    800055e6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055e8:	fd840593          	addi	a1,s0,-40
    800055ec:	4501                	li	a0,0
    800055ee:	af0fd0ef          	jal	800028de <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800055f2:	fc840593          	addi	a1,s0,-56
    800055f6:	fd040513          	addi	a0,s0,-48
    800055fa:	f9ffe0ef          	jal	80004598 <pipealloc>
    return -1;
    800055fe:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005600:	0a054663          	bltz	a0,800056ac <sys_pipe+0xd4>
  fd0 = -1;
    80005604:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005608:	fd043503          	ld	a0,-48(s0)
    8000560c:	e82ff0ef          	jal	80004c8e <fdalloc>
    80005610:	fca42223          	sw	a0,-60(s0)
    80005614:	08054363          	bltz	a0,8000569a <sys_pipe+0xc2>
    80005618:	fc843503          	ld	a0,-56(s0)
    8000561c:	e72ff0ef          	jal	80004c8e <fdalloc>
    80005620:	fca42023          	sw	a0,-64(s0)
    80005624:	06054263          	bltz	a0,80005688 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005628:	4711                	li	a4,4
    8000562a:	fc440693          	addi	a3,s0,-60
    8000562e:	fd843603          	ld	a2,-40(s0)
    80005632:	64ac                	ld	a1,72(s1)
    80005634:	68a8                	ld	a0,80(s1)
    80005636:	ea5fb0ef          	jal	800014da <copyout>
    8000563a:	00054f63          	bltz	a0,80005658 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    8000563e:	4711                	li	a4,4
    80005640:	fc040693          	addi	a3,s0,-64
    80005644:	fd843603          	ld	a2,-40(s0)
    80005648:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000564a:	64ac                	ld	a1,72(s1)
    8000564c:	68a8                	ld	a0,80(s1)
    8000564e:	e8dfb0ef          	jal	800014da <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005652:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005654:	04055c63          	bgez	a0,800056ac <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    80005658:	fc442783          	lw	a5,-60(s0)
    8000565c:	07e9                	addi	a5,a5,26
    8000565e:	078e                	slli	a5,a5,0x3
    80005660:	97a6                	add	a5,a5,s1
    80005662:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005666:	fc042783          	lw	a5,-64(s0)
    8000566a:	07e9                	addi	a5,a5,26
    8000566c:	078e                	slli	a5,a5,0x3
    8000566e:	94be                	add	s1,s1,a5
    80005670:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005674:	fd043503          	ld	a0,-48(s0)
    80005678:	c01fe0ef          	jal	80004278 <fileclose>
    fileclose(wf);
    8000567c:	fc843503          	ld	a0,-56(s0)
    80005680:	bf9fe0ef          	jal	80004278 <fileclose>
    return -1;
    80005684:	57fd                	li	a5,-1
    80005686:	a01d                	j	800056ac <sys_pipe+0xd4>
    if (fd0 >= 0)
    80005688:	fc442783          	lw	a5,-60(s0)
    8000568c:	0007c763          	bltz	a5,8000569a <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    80005690:	07e9                	addi	a5,a5,26
    80005692:	078e                	slli	a5,a5,0x3
    80005694:	97a6                	add	a5,a5,s1
    80005696:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000569a:	fd043503          	ld	a0,-48(s0)
    8000569e:	bdbfe0ef          	jal	80004278 <fileclose>
    fileclose(wf);
    800056a2:	fc843503          	ld	a0,-56(s0)
    800056a6:	bd3fe0ef          	jal	80004278 <fileclose>
    return -1;
    800056aa:	57fd                	li	a5,-1
}
    800056ac:	853e                	mv	a0,a5
    800056ae:	70e2                	ld	ra,56(sp)
    800056b0:	7442                	ld	s0,48(sp)
    800056b2:	74a2                	ld	s1,40(sp)
    800056b4:	6121                	addi	sp,sp,64
    800056b6:	8082                	ret
	...

00000000800056c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056c4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800056c6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056c8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056ca:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056cc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056ce:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056d0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056d2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056d4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056d6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056d8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056da:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056dc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800056de:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800056e0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800056e2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800056e4:	862fd0ef          	jal	80002746 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800056e8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800056ea:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800056ec:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800056ee:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056f0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056f2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056f4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056f6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056f8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056fa:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056fc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800056fe:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005700:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005702:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005704:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005706:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005708:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000570a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000570c:	10200073          	sret
	...

000000008000571e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000571e:	1141                	addi	sp,sp,-16
    80005720:	e422                	sd	s0,8(sp)
    80005722:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005724:	0c0007b7          	lui	a5,0xc000
    80005728:	4705                	li	a4,1
    8000572a:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000572c:	0c0007b7          	lui	a5,0xc000
    80005730:	c3d8                	sw	a4,4(a5)
}
    80005732:	6422                	ld	s0,8(sp)
    80005734:	0141                	addi	sp,sp,16
    80005736:	8082                	ret

0000000080005738 <plicinithart>:

void
plicinithart(void)
{
    80005738:	1141                	addi	sp,sp,-16
    8000573a:	e406                	sd	ra,8(sp)
    8000573c:	e022                	sd	s0,0(sp)
    8000573e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005740:	938fc0ef          	jal	80001878 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005744:	0085171b          	slliw	a4,a0,0x8
    80005748:	0c0027b7          	lui	a5,0xc002
    8000574c:	97ba                	add	a5,a5,a4
    8000574e:	40200713          	li	a4,1026
    80005752:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005756:	00d5151b          	slliw	a0,a0,0xd
    8000575a:	0c2017b7          	lui	a5,0xc201
    8000575e:	97aa                	add	a5,a5,a0
    80005760:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005764:	60a2                	ld	ra,8(sp)
    80005766:	6402                	ld	s0,0(sp)
    80005768:	0141                	addi	sp,sp,16
    8000576a:	8082                	ret

000000008000576c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000576c:	1141                	addi	sp,sp,-16
    8000576e:	e406                	sd	ra,8(sp)
    80005770:	e022                	sd	s0,0(sp)
    80005772:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005774:	904fc0ef          	jal	80001878 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005778:	00d5151b          	slliw	a0,a0,0xd
    8000577c:	0c2017b7          	lui	a5,0xc201
    80005780:	97aa                	add	a5,a5,a0
  return irq;
}
    80005782:	43c8                	lw	a0,4(a5)
    80005784:	60a2                	ld	ra,8(sp)
    80005786:	6402                	ld	s0,0(sp)
    80005788:	0141                	addi	sp,sp,16
    8000578a:	8082                	ret

000000008000578c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000578c:	1101                	addi	sp,sp,-32
    8000578e:	ec06                	sd	ra,24(sp)
    80005790:	e822                	sd	s0,16(sp)
    80005792:	e426                	sd	s1,8(sp)
    80005794:	1000                	addi	s0,sp,32
    80005796:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005798:	8e0fc0ef          	jal	80001878 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000579c:	00d5151b          	slliw	a0,a0,0xd
    800057a0:	0c2017b7          	lui	a5,0xc201
    800057a4:	97aa                	add	a5,a5,a0
    800057a6:	c3c4                	sw	s1,4(a5)
}
    800057a8:	60e2                	ld	ra,24(sp)
    800057aa:	6442                	ld	s0,16(sp)
    800057ac:	64a2                	ld	s1,8(sp)
    800057ae:	6105                	addi	sp,sp,32
    800057b0:	8082                	ret

00000000800057b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057b2:	1141                	addi	sp,sp,-16
    800057b4:	e406                	sd	ra,8(sp)
    800057b6:	e022                	sd	s0,0(sp)
    800057b8:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800057ba:	479d                	li	a5,7
    800057bc:	04a7ca63          	blt	a5,a0,80005810 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800057c0:	0001c797          	auipc	a5,0x1c
    800057c4:	90078793          	addi	a5,a5,-1792 # 800210c0 <disk>
    800057c8:	97aa                	add	a5,a5,a0
    800057ca:	0187c783          	lbu	a5,24(a5)
    800057ce:	e7b9                	bnez	a5,8000581c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057d0:	00451693          	slli	a3,a0,0x4
    800057d4:	0001c797          	auipc	a5,0x1c
    800057d8:	8ec78793          	addi	a5,a5,-1812 # 800210c0 <disk>
    800057dc:	6398                	ld	a4,0(a5)
    800057de:	9736                	add	a4,a4,a3
    800057e0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800057e4:	6398                	ld	a4,0(a5)
    800057e6:	9736                	add	a4,a4,a3
    800057e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057f4:	97aa                	add	a5,a5,a0
    800057f6:	4705                	li	a4,1
    800057f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057fc:	0001c517          	auipc	a0,0x1c
    80005800:	8dc50513          	addi	a0,a0,-1828 # 800210d8 <disk+0x18>
    80005804:	f88fc0ef          	jal	80001f8c <wakeup>
}
    80005808:	60a2                	ld	ra,8(sp)
    8000580a:	6402                	ld	s0,0(sp)
    8000580c:	0141                	addi	sp,sp,16
    8000580e:	8082                	ret
    panic("free_desc 1");
    80005810:	00002517          	auipc	a0,0x2
    80005814:	e4050513          	addi	a0,a0,-448 # 80007650 <etext+0x650>
    80005818:	fd9fa0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    8000581c:	00002517          	auipc	a0,0x2
    80005820:	e4450513          	addi	a0,a0,-444 # 80007660 <etext+0x660>
    80005824:	fcdfa0ef          	jal	800007f0 <panic>

0000000080005828 <virtio_disk_init>:
{
    80005828:	1101                	addi	sp,sp,-32
    8000582a:	ec06                	sd	ra,24(sp)
    8000582c:	e822                	sd	s0,16(sp)
    8000582e:	e426                	sd	s1,8(sp)
    80005830:	e04a                	sd	s2,0(sp)
    80005832:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005834:	00002597          	auipc	a1,0x2
    80005838:	e3c58593          	addi	a1,a1,-452 # 80007670 <etext+0x670>
    8000583c:	0001c517          	auipc	a0,0x1c
    80005840:	9ac50513          	addi	a0,a0,-1620 # 800211e8 <disk+0x128>
    80005844:	ad6fb0ef          	jal	80000b1a <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005848:	100017b7          	lui	a5,0x10001
    8000584c:	4398                	lw	a4,0(a5)
    8000584e:	2701                	sext.w	a4,a4
    80005850:	747277b7          	lui	a5,0x74727
    80005854:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005858:	18f71063          	bne	a4,a5,800059d8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000585c:	100017b7          	lui	a5,0x10001
    80005860:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005862:	439c                	lw	a5,0(a5)
    80005864:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005866:	4709                	li	a4,2
    80005868:	16e79863          	bne	a5,a4,800059d8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000586c:	100017b7          	lui	a5,0x10001
    80005870:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005872:	439c                	lw	a5,0(a5)
    80005874:	2781                	sext.w	a5,a5
    80005876:	16e79163          	bne	a5,a4,800059d8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000587a:	100017b7          	lui	a5,0x10001
    8000587e:	47d8                	lw	a4,12(a5)
    80005880:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005882:	554d47b7          	lui	a5,0x554d4
    80005886:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000588a:	14f71763          	bne	a4,a5,800059d8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000588e:	100017b7          	lui	a5,0x10001
    80005892:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005896:	4705                	li	a4,1
    80005898:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000589a:	470d                	li	a4,3
    8000589c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000589e:	10001737          	lui	a4,0x10001
    800058a2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058a4:	c7ffe737          	lui	a4,0xc7ffe
    800058a8:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fdd35f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058ac:	8ef9                	and	a3,a3,a4
    800058ae:	10001737          	lui	a4,0x10001
    800058b2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b4:	472d                	li	a4,11
    800058b6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058bc:	439c                	lw	a5,0(a5)
    800058be:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058c2:	8ba1                	andi	a5,a5,8
    800058c4:	12078063          	beqz	a5,800059e4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058c8:	100017b7          	lui	a5,0x10001
    800058cc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800058d0:	100017b7          	lui	a5,0x10001
    800058d4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800058d8:	439c                	lw	a5,0(a5)
    800058da:	2781                	sext.w	a5,a5
    800058dc:	10079a63          	bnez	a5,800059f0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058e0:	100017b7          	lui	a5,0x10001
    800058e4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800058e8:	439c                	lw	a5,0(a5)
    800058ea:	2781                	sext.w	a5,a5
  if (max == 0)
    800058ec:	10078863          	beqz	a5,800059fc <virtio_disk_init+0x1d4>
  if (max < NUM)
    800058f0:	471d                	li	a4,7
    800058f2:	10f77b63          	bgeu	a4,a5,80005a08 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800058f6:	9d4fb0ef          	jal	80000aca <kalloc>
    800058fa:	0001b497          	auipc	s1,0x1b
    800058fe:	7c648493          	addi	s1,s1,1990 # 800210c0 <disk>
    80005902:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005904:	9c6fb0ef          	jal	80000aca <kalloc>
    80005908:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000590a:	9c0fb0ef          	jal	80000aca <kalloc>
    8000590e:	87aa                	mv	a5,a0
    80005910:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005912:	6088                	ld	a0,0(s1)
    80005914:	10050063          	beqz	a0,80005a14 <virtio_disk_init+0x1ec>
    80005918:	0001b717          	auipc	a4,0x1b
    8000591c:	7b073703          	ld	a4,1968(a4) # 800210c8 <disk+0x8>
    80005920:	0e070a63          	beqz	a4,80005a14 <virtio_disk_init+0x1ec>
    80005924:	0e078863          	beqz	a5,80005a14 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005928:	6605                	lui	a2,0x1
    8000592a:	4581                	li	a1,0
    8000592c:	b28fb0ef          	jal	80000c54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005930:	0001b497          	auipc	s1,0x1b
    80005934:	79048493          	addi	s1,s1,1936 # 800210c0 <disk>
    80005938:	6605                	lui	a2,0x1
    8000593a:	4581                	li	a1,0
    8000593c:	6488                	ld	a0,8(s1)
    8000593e:	b16fb0ef          	jal	80000c54 <memset>
  memset(disk.used, 0, PGSIZE);
    80005942:	6605                	lui	a2,0x1
    80005944:	4581                	li	a1,0
    80005946:	6888                	ld	a0,16(s1)
    80005948:	b0cfb0ef          	jal	80000c54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000594c:	100017b7          	lui	a5,0x10001
    80005950:	4721                	li	a4,8
    80005952:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005954:	4098                	lw	a4,0(s1)
    80005956:	100017b7          	lui	a5,0x10001
    8000595a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000595e:	40d8                	lw	a4,4(s1)
    80005960:	100017b7          	lui	a5,0x10001
    80005964:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005968:	649c                	ld	a5,8(s1)
    8000596a:	0007869b          	sext.w	a3,a5
    8000596e:	10001737          	lui	a4,0x10001
    80005972:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005976:	9781                	srai	a5,a5,0x20
    80005978:	10001737          	lui	a4,0x10001
    8000597c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005980:	689c                	ld	a5,16(s1)
    80005982:	0007869b          	sext.w	a3,a5
    80005986:	10001737          	lui	a4,0x10001
    8000598a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000598e:	9781                	srai	a5,a5,0x20
    80005990:	10001737          	lui	a4,0x10001
    80005994:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005998:	10001737          	lui	a4,0x10001
    8000599c:	4785                	li	a5,1
    8000599e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059a0:	00f48c23          	sb	a5,24(s1)
    800059a4:	00f48ca3          	sb	a5,25(s1)
    800059a8:	00f48d23          	sb	a5,26(s1)
    800059ac:	00f48da3          	sb	a5,27(s1)
    800059b0:	00f48e23          	sb	a5,28(s1)
    800059b4:	00f48ea3          	sb	a5,29(s1)
    800059b8:	00f48f23          	sb	a5,30(s1)
    800059bc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059c0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c4:	100017b7          	lui	a5,0x10001
    800059c8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800059cc:	60e2                	ld	ra,24(sp)
    800059ce:	6442                	ld	s0,16(sp)
    800059d0:	64a2                	ld	s1,8(sp)
    800059d2:	6902                	ld	s2,0(sp)
    800059d4:	6105                	addi	sp,sp,32
    800059d6:	8082                	ret
    panic("could not find virtio disk");
    800059d8:	00002517          	auipc	a0,0x2
    800059dc:	ca850513          	addi	a0,a0,-856 # 80007680 <etext+0x680>
    800059e0:	e11fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059e4:	00002517          	auipc	a0,0x2
    800059e8:	cbc50513          	addi	a0,a0,-836 # 800076a0 <etext+0x6a0>
    800059ec:	e05fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    800059f0:	00002517          	auipc	a0,0x2
    800059f4:	cd050513          	addi	a0,a0,-816 # 800076c0 <etext+0x6c0>
    800059f8:	df9fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    800059fc:	00002517          	auipc	a0,0x2
    80005a00:	ce450513          	addi	a0,a0,-796 # 800076e0 <etext+0x6e0>
    80005a04:	dedfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005a08:	00002517          	auipc	a0,0x2
    80005a0c:	cf850513          	addi	a0,a0,-776 # 80007700 <etext+0x700>
    80005a10:	de1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005a14:	00002517          	auipc	a0,0x2
    80005a18:	d0c50513          	addi	a0,a0,-756 # 80007720 <etext+0x720>
    80005a1c:	dd5fa0ef          	jal	800007f0 <panic>

0000000080005a20 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a20:	7159                	addi	sp,sp,-112
    80005a22:	f486                	sd	ra,104(sp)
    80005a24:	f0a2                	sd	s0,96(sp)
    80005a26:	eca6                	sd	s1,88(sp)
    80005a28:	e8ca                	sd	s2,80(sp)
    80005a2a:	e4ce                	sd	s3,72(sp)
    80005a2c:	e0d2                	sd	s4,64(sp)
    80005a2e:	fc56                	sd	s5,56(sp)
    80005a30:	f85a                	sd	s6,48(sp)
    80005a32:	f45e                	sd	s7,40(sp)
    80005a34:	f062                	sd	s8,32(sp)
    80005a36:	ec66                	sd	s9,24(sp)
    80005a38:	1880                	addi	s0,sp,112
    80005a3a:	8a2a                	mv	s4,a0
    80005a3c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a3e:	00c52c83          	lw	s9,12(a0)
    80005a42:	001c9c9b          	slliw	s9,s9,0x1
    80005a46:	1c82                	slli	s9,s9,0x20
    80005a48:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005a4c:	0001b517          	auipc	a0,0x1b
    80005a50:	79c50513          	addi	a0,a0,1948 # 800211e8 <disk+0x128>
    80005a54:	93cfb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005a58:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    80005a5a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a5c:	0001bb17          	auipc	s6,0x1b
    80005a60:	664b0b13          	addi	s6,s6,1636 # 800210c0 <disk>
  for (int i = 0; i < 3; i++) {
    80005a64:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005a66:	0001bc17          	auipc	s8,0x1b
    80005a6a:	672c0c13          	addi	s8,s8,1650 # 800210d8 <disk+0x18>
    80005a6e:	a0bd                	j	80005adc <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005a70:	00fb0733          	add	a4,s6,a5
    80005a74:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005a78:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005a7a:	0207c563          	bltz	a5,80005aa4 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    80005a7e:	2905                	addiw	s2,s2,1
    80005a80:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a82:	07590163          	beq	s2,s5,80005ae4 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a86:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a88:	0001b717          	auipc	a4,0x1b
    80005a8c:	63870713          	addi	a4,a4,1592 # 800210c0 <disk>
    80005a90:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80005a92:	01874683          	lbu	a3,24(a4)
    80005a96:	fee9                	bnez	a3,80005a70 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80005a98:	2785                	addiw	a5,a5,1
    80005a9a:	0705                	addi	a4,a4,1
    80005a9c:	fe979be3          	bne	a5,s1,80005a92 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005aa0:	57fd                	li	a5,-1
    80005aa2:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80005aa4:	01205d63          	blez	s2,80005abe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005aa8:	f9042503          	lw	a0,-112(s0)
    80005aac:	d07ff0ef          	jal	800057b2 <free_desc>
      for (int j = 0; j < i; j++)
    80005ab0:	4785                	li	a5,1
    80005ab2:	0127d663          	bge	a5,s2,80005abe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005ab6:	f9442503          	lw	a0,-108(s0)
    80005aba:	cf9ff0ef          	jal	800057b2 <free_desc>
    sleep_prepare(&disk.free[0]);
    80005abe:	8562                	mv	a0,s8
    80005ac0:	c60fc0ef          	jal	80001f20 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ac4:	0001b917          	auipc	s2,0x1b
    80005ac8:	72490913          	addi	s2,s2,1828 # 800211e8 <disk+0x128>
    80005acc:	854a                	mv	a0,s2
    80005ace:	94efb0ef          	jal	80000c1c <release>
    sleep();
    80005ad2:	c8afc0ef          	jal	80001f5c <sleep>
    acquire(&disk.vdisk_lock);
    80005ad6:	854a                	mv	a0,s2
    80005ad8:	8b8fb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005adc:	f9040613          	addi	a2,s0,-112
    80005ae0:	894e                	mv	s2,s3
    80005ae2:	b755                	j	80005a86 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ae4:	f9042503          	lw	a0,-112(s0)
    80005ae8:	00451693          	slli	a3,a0,0x4

  if (write)
    80005aec:	0001b797          	auipc	a5,0x1b
    80005af0:	5d478793          	addi	a5,a5,1492 # 800210c0 <disk>
    80005af4:	00a50713          	addi	a4,a0,10
    80005af8:	0712                	slli	a4,a4,0x4
    80005afa:	973e                	add	a4,a4,a5
    80005afc:	01703633          	snez	a2,s7
    80005b00:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b02:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b06:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b0a:	6398                	ld	a4,0(a5)
    80005b0c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b0e:	0a868613          	addi	a2,a3,168
    80005b12:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b14:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b16:	6390                	ld	a2,0(a5)
    80005b18:	00d605b3          	add	a1,a2,a3
    80005b1c:	4741                	li	a4,16
    80005b1e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b20:	4805                	li	a6,1
    80005b22:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005b26:	f9442703          	lw	a4,-108(s0)
    80005b2a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b2e:	0712                	slli	a4,a4,0x4
    80005b30:	963a                	add	a2,a2,a4
    80005b32:	058a0593          	addi	a1,s4,88
    80005b36:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b38:	0007b883          	ld	a7,0(a5)
    80005b3c:	9746                	add	a4,a4,a7
    80005b3e:	40000613          	li	a2,1024
    80005b42:	c710                	sw	a2,8(a4)
  if (write)
    80005b44:	001bb613          	seqz	a2,s7
    80005b48:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b4c:	00166613          	ori	a2,a2,1
    80005b50:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b54:	f9842583          	lw	a1,-104(s0)
    80005b58:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b5c:	00250613          	addi	a2,a0,2
    80005b60:	0612                	slli	a2,a2,0x4
    80005b62:	963e                	add	a2,a2,a5
    80005b64:	577d                	li	a4,-1
    80005b66:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005b6a:	0592                	slli	a1,a1,0x4
    80005b6c:	98ae                	add	a7,a7,a1
    80005b6e:	03068713          	addi	a4,a3,48
    80005b72:	973e                	add	a4,a4,a5
    80005b74:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b78:	6398                	ld	a4,0(a5)
    80005b7a:	972e                	add	a4,a4,a1
    80005b7c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b80:	4689                	li	a3,2
    80005b82:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b86:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b8a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005b8e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b92:	6794                	ld	a3,8(a5)
    80005b94:	0026d703          	lhu	a4,2(a3)
    80005b98:	8b1d                	andi	a4,a4,7
    80005b9a:	0706                	slli	a4,a4,0x1
    80005b9c:	96ba                	add	a3,a3,a4
    80005b9e:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005ba2:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ba6:	6798                	ld	a4,8(a5)
    80005ba8:	00275783          	lhu	a5,2(a4)
    80005bac:	2785                	addiw	a5,a5,1
    80005bae:	00f71123          	sh	a5,2(a4)
    80005bb2:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bb6:	100017b7          	lui	a5,0x10001
    80005bba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005bbe:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005bc2:	0001b497          	auipc	s1,0x1b
    80005bc6:	62648493          	addi	s1,s1,1574 # 800211e8 <disk+0x128>
  while (b->disk == 1) {
    80005bca:	4905                	li	s2,1
    80005bcc:	03079163          	bne	a5,a6,80005bee <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80005bd0:	8552                	mv	a0,s4
    80005bd2:	b4efc0ef          	jal	80001f20 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005bd6:	8526                	mv	a0,s1
    80005bd8:	844fb0ef          	jal	80000c1c <release>
    sleep();
    80005bdc:	b80fc0ef          	jal	80001f5c <sleep>
    acquire(&disk.vdisk_lock);
    80005be0:	8526                	mv	a0,s1
    80005be2:	faffa0ef          	jal	80000b90 <acquire>
  while (b->disk == 1) {
    80005be6:	004a2783          	lw	a5,4(s4)
    80005bea:	ff2783e3          	beq	a5,s2,80005bd0 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005bee:	f9042903          	lw	s2,-112(s0)
    80005bf2:	00290713          	addi	a4,s2,2
    80005bf6:	0712                	slli	a4,a4,0x4
    80005bf8:	0001b797          	auipc	a5,0x1b
    80005bfc:	4c878793          	addi	a5,a5,1224 # 800210c0 <disk>
    80005c00:	97ba                	add	a5,a5,a4
    80005c02:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c06:	0001b997          	auipc	s3,0x1b
    80005c0a:	4ba98993          	addi	s3,s3,1210 # 800210c0 <disk>
    80005c0e:	00491713          	slli	a4,s2,0x4
    80005c12:	0009b783          	ld	a5,0(s3)
    80005c16:	97ba                	add	a5,a5,a4
    80005c18:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c1c:	854a                	mv	a0,s2
    80005c1e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c22:	b91ff0ef          	jal	800057b2 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c26:	8885                	andi	s1,s1,1
    80005c28:	f0fd                	bnez	s1,80005c0e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c2a:	0001b517          	auipc	a0,0x1b
    80005c2e:	5be50513          	addi	a0,a0,1470 # 800211e8 <disk+0x128>
    80005c32:	febfa0ef          	jal	80000c1c <release>
}
    80005c36:	70a6                	ld	ra,104(sp)
    80005c38:	7406                	ld	s0,96(sp)
    80005c3a:	64e6                	ld	s1,88(sp)
    80005c3c:	6946                	ld	s2,80(sp)
    80005c3e:	69a6                	ld	s3,72(sp)
    80005c40:	6a06                	ld	s4,64(sp)
    80005c42:	7ae2                	ld	s5,56(sp)
    80005c44:	7b42                	ld	s6,48(sp)
    80005c46:	7ba2                	ld	s7,40(sp)
    80005c48:	7c02                	ld	s8,32(sp)
    80005c4a:	6ce2                	ld	s9,24(sp)
    80005c4c:	6165                	addi	sp,sp,112
    80005c4e:	8082                	ret

0000000080005c50 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c50:	1101                	addi	sp,sp,-32
    80005c52:	ec06                	sd	ra,24(sp)
    80005c54:	e822                	sd	s0,16(sp)
    80005c56:	e426                	sd	s1,8(sp)
    80005c58:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c5a:	0001b497          	auipc	s1,0x1b
    80005c5e:	46648493          	addi	s1,s1,1126 # 800210c0 <disk>
    80005c62:	0001b517          	auipc	a0,0x1b
    80005c66:	58650513          	addi	a0,a0,1414 # 800211e8 <disk+0x128>
    80005c6a:	f27fa0ef          	jal	80000b90 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c6e:	100017b7          	lui	a5,0x10001
    80005c72:	53b8                	lw	a4,96(a5)
    80005c74:	8b0d                	andi	a4,a4,3
    80005c76:	100017b7          	lui	a5,0x10001
    80005c7a:	d3f8                	sw	a4,100(a5)
    80005c7c:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005c80:	689c                	ld	a5,16(s1)
    80005c82:	0204d703          	lhu	a4,32(s1)
    80005c86:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c8a:	04f70663          	beq	a4,a5,80005cd6 <virtio_disk_intr+0x86>
    80005c8e:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c92:	6898                	ld	a4,16(s1)
    80005c94:	0204d783          	lhu	a5,32(s1)
    80005c98:	8b9d                	andi	a5,a5,7
    80005c9a:	078e                	slli	a5,a5,0x3
    80005c9c:	97ba                	add	a5,a5,a4
    80005c9e:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005ca0:	00278713          	addi	a4,a5,2
    80005ca4:	0712                	slli	a4,a4,0x4
    80005ca6:	9726                	add	a4,a4,s1
    80005ca8:	01074703          	lbu	a4,16(a4)
    80005cac:	e321                	bnez	a4,80005cec <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cae:	0789                	addi	a5,a5,2
    80005cb0:	0792                	slli	a5,a5,0x4
    80005cb2:	97a6                	add	a5,a5,s1
    80005cb4:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005cb6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cba:	ad2fc0ef          	jal	80001f8c <wakeup>

    disk.used_idx += 1;
    80005cbe:	0204d783          	lhu	a5,32(s1)
    80005cc2:	2785                	addiw	a5,a5,1
    80005cc4:	17c2                	slli	a5,a5,0x30
    80005cc6:	93c1                	srli	a5,a5,0x30
    80005cc8:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005ccc:	6898                	ld	a4,16(s1)
    80005cce:	00275703          	lhu	a4,2(a4)
    80005cd2:	faf71ee3          	bne	a4,a5,80005c8e <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cd6:	0001b517          	auipc	a0,0x1b
    80005cda:	51250513          	addi	a0,a0,1298 # 800211e8 <disk+0x128>
    80005cde:	f3ffa0ef          	jal	80000c1c <release>
}
    80005ce2:	60e2                	ld	ra,24(sp)
    80005ce4:	6442                	ld	s0,16(sp)
    80005ce6:	64a2                	ld	s1,8(sp)
    80005ce8:	6105                	addi	sp,sp,32
    80005cea:	8082                	ret
      panic("virtio_disk_intr status");
    80005cec:	00002517          	auipc	a0,0x2
    80005cf0:	a4c50513          	addi	a0,a0,-1460 # 80007738 <etext+0x738>
    80005cf4:	afdfa0ef          	jal	800007f0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
