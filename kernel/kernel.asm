
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
    80000004:	89010113          	addi	sp,sp,-1904 # 80007890 <stack0>
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
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc4f>
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
    80000114:	17c020ef          	jal	80002290 <either_copyin>
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
    80000192:	70250513          	addi	a0,a0,1794 # 8000f890 <cons>
    80000196:	1fb000ef          	jal	80000b90 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	0000f497          	auipc	s1,0xf
    8000019e:	6f648493          	addi	s1,s1,1782 # 8000f890 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	0000f917          	auipc	s2,0xf
    800001a6:	78690913          	addi	s2,s2,1926 # 8000f928 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	6ea010ef          	jal	800018a4 <myproc>
    800001be:	74d010ef          	jal	8000210a <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	4f1010ef          	jal	80001eb6 <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	251000ef          	jal	80000c1c <release>
      sleep();
    800001d0:	523010ef          	jal	80001ef2 <sleep>
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
    800001ec:	6a870713          	addi	a4,a4,1704 # 8000f890 <cons>
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
    8000021a:	02a020ef          	jal	80002244 <either_copyout>
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
    80000236:	65e50513          	addi	a0,a0,1630 # 8000f890 <cons>
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
    80000260:	6cf72623          	sw	a5,1740(a4) # 8000f928 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	0000f517          	auipc	a0,0xf
    80000276:	61e50513          	addi	a0,a0,1566 # 8000f890 <cons>
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
    800002ca:	5ca50513          	addi	a0,a0,1482 # 8000f890 <cons>
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
    800002e8:	7f5010ef          	jal	800022dc <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	0000f517          	auipc	a0,0xf
    800002f0:	5a450513          	addi	a0,a0,1444 # 8000f890 <cons>
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
    8000030e:	58670713          	addi	a4,a4,1414 # 8000f890 <cons>
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
    80000334:	56078793          	addi	a5,a5,1376 # 8000f890 <cons>
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
    80000362:	5ca7a783          	lw	a5,1482(a5) # 8000f928 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	0000f717          	auipc	a4,0xf
    80000378:	51c70713          	addi	a4,a4,1308 # 8000f890 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	0000f497          	auipc	s1,0xf
    80000388:	50c48493          	addi	s1,s1,1292 # 8000f890 <cons>
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
    800003ca:	4ca70713          	addi	a4,a4,1226 # 8000f890 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	0000f717          	auipc	a4,0xf
    800003e0:	54f72a23          	sw	a5,1364(a4) # 8000f930 <cons+0xa0>
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
    800003fe:	49678793          	addi	a5,a5,1174 # 8000f890 <cons>
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
    80000422:	50c7a723          	sw	a2,1294(a5) # 8000f92c <cons+0x9c>
        wakeup(&cons.r);
    80000426:	0000f517          	auipc	a0,0xf
    8000042a:	50250513          	addi	a0,a0,1282 # 8000f928 <cons+0x98>
    8000042e:	2f5010ef          	jal	80001f22 <wakeup>
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
    80000448:	44c50513          	addi	a0,a0,1100 # 8000f890 <cons>
    8000044c:	6ce000ef          	jal	80000b1a <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	0001f797          	auipc	a5,0x1f
    80000458:	5c478793          	addi	a5,a5,1476 # 8001fa18 <devsw>
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
    80000492:	2a260613          	addi	a2,a2,674 # 80007730 <digits>
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
    8000052c:	33c7a783          	lw	a5,828(a5) # 80007864 <panicking>
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
    80000574:	3c850513          	addi	a0,a0,968 # 8000f938 <pr>
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
    8000073c:	ff8b8b93          	addi	s7,s7,-8 # 80007730 <digits>
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
    800007d0:	0987a783          	lw	a5,152(a5) # 80007864 <panicking>
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
    800007e6:	15650513          	addi	a0,a0,342 # 8000f938 <pr>
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
    80000804:	0727a223          	sw	s2,100(a5) # 80007864 <panicking>
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
    80000826:	0327af23          	sw	s2,62(a5) # 80007860 <panicked>
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
    80000840:	0fc50513          	addi	a0,a0,252 # 8000f938 <pr>
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
    80000898:	0bc50513          	addi	a0,a0,188 # 8000f950 <tx_lock>
    8000089c:	732030ef          	jal	80003fce <initsleeplock>
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
    800008bc:	09850513          	addi	a0,a0,152 # 8000f950 <tx_lock>
    800008c0:	744030ef          	jal	80004004 <acquiresleep>

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
    800008d6:	f96a0a13          	addi	s4,s4,-106 # 80007868 <tx_chan>
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
    800008fa:	5bc010ef          	jal	80001eb6 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	5ea010ef          	jal	80001ef2 <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	0000f517          	auipc	a0,0xf
    8000091a:	03a50513          	addi	a0,a0,58 # 8000f950 <tx_lock>
    8000091e:	73a030ef          	jal	80004058 <releasesleep>
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
    8000093e:	f2a7a783          	lw	a5,-214(a5) # 80007864 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	00007797          	auipc	a5,0x7
    80000948:	f1c7a783          	lw	a5,-228(a5) # 80007860 <panicked>
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
    8000096e:	efa7a783          	lw	a5,-262(a5) # 80007864 <panicking>
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
    800009d2:	e9a50513          	addi	a0,a0,-358 # 80007868 <tx_chan>
    800009d6:	54c010ef          	jal	80001f22 <wakeup>
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
    800009fc:	00020797          	auipc	a5,0x20
    80000a00:	1b478793          	addi	a5,a5,436 # 80020bb0 <end>
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
    80000a1c:	f6890913          	addi	s2,s2,-152 # 8000f980 <kmem>
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
    80000aaa:	eda50513          	addi	a0,a0,-294 # 8000f980 <kmem>
    80000aae:	06c000ef          	jal	80000b1a <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00020517          	auipc	a0,0x20
    80000aba:	0fa50513          	addi	a0,a0,250 # 80020bb0 <end>
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
    80000ad8:	eac48493          	addi	s1,s1,-340 # 8000f980 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0b2000ef          	jal	80000b90 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	0000f517          	auipc	a0,0xf
    80000aec:	e9850513          	addi	a0,a0,-360 # 8000f980 <kmem>
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
    80000b10:	e7450513          	addi	a0,a0,-396 # 8000f980 <kmem>
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
    80000cc8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde451>
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
    80000dfe:	a7270713          	addi	a4,a4,-1422 # 8000786c <started>
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
    80000e24:	638010ef          	jal	8000245c <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e28:	041040ef          	jal	80005668 <plicinithart>
  }

  scheduler();
    80000e2c:	6f1000ef          	jal	80001d1c <scheduler>
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
    80000e6c:	5cc010ef          	jal	80002438 <trapinit>
    trapinithart();     // install kernel trap vector
    80000e70:	5ec010ef          	jal	8000245c <trapinithart>
    plicinit();         // set up interrupt controller
    80000e74:	7da040ef          	jal	8000564e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e78:	7f0040ef          	jal	80005668 <plicinithart>
    binit();            // buffer cache
    80000e7c:	4e1010ef          	jal	80002b5c <binit>
    iinit();            // inode table
    80000e80:	266020ef          	jal	800030e6 <iinit>
    fileinit();         // file table
    80000e84:	256030ef          	jal	800040da <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e88:	0d1040ef          	jal	80005758 <virtio_disk_init>
    userinit();         // first user process
    80000e8c:	4e5000ef          	jal	80001b70 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000e90:	00007797          	auipc	a5,0x7
    80000e94:	9dc78793          	addi	a5,a5,-1572 # 8000786c <started>
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
    80000eb2:	9c27b783          	ld	a5,-1598(a5) # 80007870 <kernel_pagetable>
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
    80000f20:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde447>
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
    8000113e:	72a7bb23          	sd	a0,1846(a5) # 80007870 <kernel_pagetable>
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
    80001698:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffde450>
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
    80001702:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffde450>
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
    80001744:	69048493          	addi	s1,s1,1680 # 8000fdd0 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001748:	8b26                	mv	s6,s1
    8000174a:	04fa5937          	lui	s2,0x4fa5
    8000174e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001752:	0932                	slli	s2,s2,0xc
    80001754:	fa590913          	addi	s2,s2,-91
    80001758:	0932                	slli	s2,s2,0xc
    8000175a:	fa590913          	addi	s2,s2,-91
    8000175e:	0932                	slli	s2,s2,0xc
    80001760:	fa590913          	addi	s2,s2,-91
    80001764:	040009b7          	lui	s3,0x4000
    80001768:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000176a:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000176c:	00014a97          	auipc	s5,0x14
    80001770:	064a8a93          	addi	s5,s5,100 # 800157d0 <tickslock>
    char *pa = kalloc();
    80001774:	b56ff0ef          	jal	80000aca <kalloc>
    80001778:	862a                	mv	a2,a0
    if (pa == 0)
    8000177a:	cd15                	beqz	a0,800017b6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    8000177c:	416485b3          	sub	a1,s1,s6
    80001780:	858d                	srai	a1,a1,0x3
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
    8000179a:	16848493          	addi	s1,s1,360
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
    800017e2:	1c250513          	addi	a0,a0,450 # 8000f9a0 <pid_lock>
    800017e6:	b34ff0ef          	jal	80000b1a <initlock>
  initlock(&wait_lock, "wait_lock");
    800017ea:	00006597          	auipc	a1,0x6
    800017ee:	97e58593          	addi	a1,a1,-1666 # 80007168 <etext+0x168>
    800017f2:	0000e517          	auipc	a0,0xe
    800017f6:	1c650513          	addi	a0,a0,454 # 8000f9b8 <wait_lock>
    800017fa:	b20ff0ef          	jal	80000b1a <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fe:	0000e497          	auipc	s1,0xe
    80001802:	5d248493          	addi	s1,s1,1490 # 8000fdd0 <proc>
    initlock(&p->lock, "proc");
    80001806:	00006b17          	auipc	s6,0x6
    8000180a:	972b0b13          	addi	s6,s6,-1678 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000180e:	8aa6                	mv	s5,s1
    80001810:	04fa5937          	lui	s2,0x4fa5
    80001814:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001818:	0932                	slli	s2,s2,0xc
    8000181a:	fa590913          	addi	s2,s2,-91
    8000181e:	0932                	slli	s2,s2,0xc
    80001820:	fa590913          	addi	s2,s2,-91
    80001824:	0932                	slli	s2,s2,0xc
    80001826:	fa590913          	addi	s2,s2,-91
    8000182a:	040009b7          	lui	s3,0x4000
    8000182e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001830:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001832:	00014a17          	auipc	s4,0x14
    80001836:	f9ea0a13          	addi	s4,s4,-98 # 800157d0 <tickslock>
    initlock(&p->lock, "proc");
    8000183a:	85da                	mv	a1,s6
    8000183c:	8526                	mv	a0,s1
    8000183e:	adcff0ef          	jal	80000b1a <initlock>
    p->state = UNUSED;
    80001842:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001846:	415487b3          	sub	a5,s1,s5
    8000184a:	878d                	srai	a5,a5,0x3
    8000184c:	032787b3          	mul	a5,a5,s2
    80001850:	2785                	addiw	a5,a5,1
    80001852:	00d7979b          	slliw	a5,a5,0xd
    80001856:	40f987b3          	sub	a5,s3,a5
    8000185a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185c:	16848493          	addi	s1,s1,360
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
    80001898:	13c50513          	addi	a0,a0,316 # 8000f9d0 <cpus>
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
    800018bc:	0e870713          	addi	a4,a4,232 # 8000f9a0 <pid_lock>
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
    800018ec:	f687a783          	lw	a5,-152(a5) # 80007850 <first.1>
    800018f0:	0ff0000f          	fence
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	cf9d                	beqz	a5,80001934 <forkret+0x60>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800018f8:	4505                	li	a0,1
    800018fa:	4f1010ef          	jal	800035ea <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    800018fe:	00006797          	auipc	a5,0x6
    80001902:	f5278793          	addi	a5,a5,-174 # 80007850 <first.1>
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
    80001922:	6d1020ef          	jal	800047f2 <kexec>
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
    80001934:	341000ef          	jal	80002474 <prepare_return>
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
    80001986:	01e90913          	addi	s2,s2,30 # 8000f9a0 <pid_lock>
    8000198a:	854a                	mv	a0,s2
    8000198c:	a04ff0ef          	jal	80000b90 <acquire>
  pid = nextpid;
    80001990:	00006797          	auipc	a5,0x6
    80001994:	ec478793          	addi	a5,a5,-316 # 80007854 <nextpid>
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
    80001ada:	2fa48493          	addi	s1,s1,762 # 8000fdd0 <proc>
    80001ade:	00014917          	auipc	s2,0x14
    80001ae2:	cf290913          	addi	s2,s2,-782 # 800157d0 <tickslock>
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
    80001af6:	16848493          	addi	s1,s1,360
    80001afa:	ff2496e3          	bne	s1,s2,80001ae6 <allocproc+0x1c>
  return 0;
    80001afe:	4481                	li	s1,0
    80001b00:	a089                	j	80001b42 <allocproc+0x78>
  p->pid = allocpid();
    80001b02:	e75ff0ef          	jal	80001976 <allocpid>
    80001b06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b08:	4785                	li	a5,1
    80001b0a:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b0c:	fbffe0ef          	jal	80000aca <kalloc>
    80001b10:	892a                	mv	s2,a0
    80001b12:	eca8                	sd	a0,88(s1)
    80001b14:	cd15                	beqz	a0,80001b50 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b16:	8526                	mv	a0,s1
    80001b18:	e9dff0ef          	jal	800019b4 <proc_pagetable>
    80001b1c:	892a                	mv	s2,a0
    80001b1e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b20:	c121                	beqz	a0,80001b60 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b22:	07000613          	li	a2,112
    80001b26:	4581                	li	a1,0
    80001b28:	06048513          	addi	a0,s1,96
    80001b2c:	928ff0ef          	jal	80000c54 <memset>
  p->context.ra = (uint64)forkret;
    80001b30:	00000797          	auipc	a5,0x0
    80001b34:	da478793          	addi	a5,a5,-604 # 800018d4 <forkret>
    80001b38:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b3a:	60bc                	ld	a5,64(s1)
    80001b3c:	6705                	lui	a4,0x1
    80001b3e:	97ba                	add	a5,a5,a4
    80001b40:	f4bc                	sd	a5,104(s1)
}
    80001b42:	8526                	mv	a0,s1
    80001b44:	60e2                	ld	ra,24(sp)
    80001b46:	6442                	ld	s0,16(sp)
    80001b48:	64a2                	ld	s1,8(sp)
    80001b4a:	6902                	ld	s2,0(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret
    freeproc(p);
    80001b50:	8526                	mv	a0,s1
    80001b52:	f2dff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b56:	8526                	mv	a0,s1
    80001b58:	8c4ff0ef          	jal	80000c1c <release>
    return 0;
    80001b5c:	84ca                	mv	s1,s2
    80001b5e:	b7d5                	j	80001b42 <allocproc+0x78>
    freeproc(p);
    80001b60:	8526                	mv	a0,s1
    80001b62:	f1dff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b66:	8526                	mv	a0,s1
    80001b68:	8b4ff0ef          	jal	80000c1c <release>
    return 0;
    80001b6c:	84ca                	mv	s1,s2
    80001b6e:	bfd1                	j	80001b42 <allocproc+0x78>

0000000080001b70 <userinit>:
{
    80001b70:	1101                	addi	sp,sp,-32
    80001b72:	ec06                	sd	ra,24(sp)
    80001b74:	e822                	sd	s0,16(sp)
    80001b76:	e426                	sd	s1,8(sp)
    80001b78:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b7a:	f51ff0ef          	jal	80001aca <allocproc>
    80001b7e:	84aa                	mv	s1,a0
  initproc = p;
    80001b80:	00006797          	auipc	a5,0x6
    80001b84:	cea7bc23          	sd	a0,-776(a5) # 80007878 <initproc>
  p->cwd = namei("/");
    80001b88:	00005517          	auipc	a0,0x5
    80001b8c:	60850513          	addi	a0,a0,1544 # 80007190 <etext+0x190>
    80001b90:	793010ef          	jal	80003b22 <namei>
    80001b94:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b98:	478d                	li	a5,3
    80001b9a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	87eff0ef          	jal	80000c1c <release>
}
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret

0000000080001bac <growproc>:
{
    80001bac:	1101                	addi	sp,sp,-32
    80001bae:	ec06                	sd	ra,24(sp)
    80001bb0:	e822                	sd	s0,16(sp)
    80001bb2:	e426                	sd	s1,8(sp)
    80001bb4:	e04a                	sd	s2,0(sp)
    80001bb6:	1000                	addi	s0,sp,32
    80001bb8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bba:	cebff0ef          	jal	800018a4 <myproc>
    80001bbe:	892a                	mv	s2,a0
  sz = p->sz;
    80001bc0:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001bc2:	02905963          	blez	s1,80001bf4 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001bc6:	00b48633          	add	a2,s1,a1
    80001bca:	020007b7          	lui	a5,0x2000
    80001bce:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bd0:	07b6                	slli	a5,a5,0xd
    80001bd2:	02c7ea63          	bltu	a5,a2,80001c06 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bd6:	4691                	li	a3,4
    80001bd8:	6928                	ld	a0,80(a0)
    80001bda:	e64ff0ef          	jal	8000123e <uvmalloc>
    80001bde:	85aa                	mv	a1,a0
    80001be0:	c50d                	beqz	a0,80001c0a <growproc+0x5e>
  p->sz = sz;
    80001be2:	04b93423          	sd	a1,72(s2)
  return 0;
    80001be6:	4501                	li	a0,0
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
  } else if (n < 0) {
    80001bf4:	fe04d7e3          	bgez	s1,80001be2 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b48633          	add	a2,s1,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	dfcff0ef          	jal	800011fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bff9                	j	80001be2 <growproc+0x36>
      return -1;
    80001c06:	557d                	li	a0,-1
    80001c08:	b7c5                	j	80001be8 <growproc+0x3c>
      return -1;
    80001c0a:	557d                	li	a0,-1
    80001c0c:	bff1                	j	80001be8 <growproc+0x3c>

0000000080001c0e <kfork>:
{
    80001c0e:	7139                	addi	sp,sp,-64
    80001c10:	fc06                	sd	ra,56(sp)
    80001c12:	f822                	sd	s0,48(sp)
    80001c14:	f04a                	sd	s2,32(sp)
    80001c16:	e456                	sd	s5,8(sp)
    80001c18:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c1a:	c8bff0ef          	jal	800018a4 <myproc>
    80001c1e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c20:	eabff0ef          	jal	80001aca <allocproc>
    80001c24:	0e050a63          	beqz	a0,80001d18 <kfork+0x10a>
    80001c28:	e852                	sd	s4,16(sp)
    80001c2a:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c2c:	048ab603          	ld	a2,72(s5)
    80001c30:	692c                	ld	a1,80(a0)
    80001c32:	050ab503          	ld	a0,80(s5)
    80001c36:	f40ff0ef          	jal	80001376 <uvmcopy>
    80001c3a:	04054a63          	bltz	a0,80001c8e <kfork+0x80>
    80001c3e:	f426                	sd	s1,40(sp)
    80001c40:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c42:	048ab783          	ld	a5,72(s5)
    80001c46:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c4a:	058ab683          	ld	a3,88(s5)
    80001c4e:	87b6                	mv	a5,a3
    80001c50:	058a3703          	ld	a4,88(s4)
    80001c54:	12068693          	addi	a3,a3,288
    80001c58:	0007b803          	ld	a6,0(a5)
    80001c5c:	6788                	ld	a0,8(a5)
    80001c5e:	6b8c                	ld	a1,16(a5)
    80001c60:	6f90                	ld	a2,24(a5)
    80001c62:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c66:	e708                	sd	a0,8(a4)
    80001c68:	eb0c                	sd	a1,16(a4)
    80001c6a:	ef10                	sd	a2,24(a4)
    80001c6c:	02078793          	addi	a5,a5,32
    80001c70:	02070713          	addi	a4,a4,32
    80001c74:	fed792e3          	bne	a5,a3,80001c58 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c78:	058a3783          	ld	a5,88(s4)
    80001c7c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001c80:	0d0a8493          	addi	s1,s5,208
    80001c84:	0d0a0913          	addi	s2,s4,208
    80001c88:	150a8993          	addi	s3,s5,336
    80001c8c:	a831                	j	80001ca8 <kfork+0x9a>
    freeproc(np);
    80001c8e:	8552                	mv	a0,s4
    80001c90:	defff0ef          	jal	80001a7e <freeproc>
    release(&np->lock);
    80001c94:	8552                	mv	a0,s4
    80001c96:	f87fe0ef          	jal	80000c1c <release>
    return -1;
    80001c9a:	597d                	li	s2,-1
    80001c9c:	6a42                	ld	s4,16(sp)
    80001c9e:	a0b5                	j	80001d0a <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001ca0:	04a1                	addi	s1,s1,8
    80001ca2:	0921                	addi	s2,s2,8
    80001ca4:	01348963          	beq	s1,s3,80001cb6 <kfork+0xa8>
    if (p->ofile[i])
    80001ca8:	6088                	ld	a0,0(s1)
    80001caa:	d97d                	beqz	a0,80001ca0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cac:	4b0020ef          	jal	8000415c <filedup>
    80001cb0:	00a93023          	sd	a0,0(s2)
    80001cb4:	b7f5                	j	80001ca0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cb6:	150ab503          	ld	a0,336(s5)
    80001cba:	5be010ef          	jal	80003278 <idup>
    80001cbe:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc2:	4641                	li	a2,16
    80001cc4:	158a8593          	addi	a1,s5,344
    80001cc8:	158a0513          	addi	a0,s4,344
    80001ccc:	8c6ff0ef          	jal	80000d92 <safestrcpy>
  pid = np->pid;
    80001cd0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd4:	8552                	mv	a0,s4
    80001cd6:	f47fe0ef          	jal	80000c1c <release>
  acquire(&wait_lock);
    80001cda:	0000e497          	auipc	s1,0xe
    80001cde:	cde48493          	addi	s1,s1,-802 # 8000f9b8 <wait_lock>
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	eadfe0ef          	jal	80000b90 <acquire>
  np->parent = p;
    80001ce8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cec:	8526                	mv	a0,s1
    80001cee:	f2ffe0ef          	jal	80000c1c <release>
  acquire(&np->lock);
    80001cf2:	8552                	mv	a0,s4
    80001cf4:	e9dfe0ef          	jal	80000b90 <acquire>
  np->state = RUNNABLE;
    80001cf8:	478d                	li	a5,3
    80001cfa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cfe:	8552                	mv	a0,s4
    80001d00:	f1dfe0ef          	jal	80000c1c <release>
  return pid;
    80001d04:	74a2                	ld	s1,40(sp)
    80001d06:	69e2                	ld	s3,24(sp)
    80001d08:	6a42                	ld	s4,16(sp)
}
    80001d0a:	854a                	mv	a0,s2
    80001d0c:	70e2                	ld	ra,56(sp)
    80001d0e:	7442                	ld	s0,48(sp)
    80001d10:	7902                	ld	s2,32(sp)
    80001d12:	6aa2                	ld	s5,8(sp)
    80001d14:	6121                	addi	sp,sp,64
    80001d16:	8082                	ret
    return -1;
    80001d18:	597d                	li	s2,-1
    80001d1a:	bfc5                	j	80001d0a <kfork+0xfc>

0000000080001d1c <scheduler>:
{
    80001d1c:	711d                	addi	sp,sp,-96
    80001d1e:	ec86                	sd	ra,88(sp)
    80001d20:	e8a2                	sd	s0,80(sp)
    80001d22:	e4a6                	sd	s1,72(sp)
    80001d24:	e0ca                	sd	s2,64(sp)
    80001d26:	fc4e                	sd	s3,56(sp)
    80001d28:	f852                	sd	s4,48(sp)
    80001d2a:	f456                	sd	s5,40(sp)
    80001d2c:	f05a                	sd	s6,32(sp)
    80001d2e:	ec5e                	sd	s7,24(sp)
    80001d30:	e862                	sd	s8,16(sp)
    80001d32:	e466                	sd	s9,8(sp)
    80001d34:	1080                	addi	s0,sp,96
    80001d36:	8792                	mv	a5,tp
  int id = r_tp();
    80001d38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3a:	00779a93          	slli	s5,a5,0x7
    80001d3e:	0000e717          	auipc	a4,0xe
    80001d42:	c6270713          	addi	a4,a4,-926 # 8000f9a0 <pid_lock>
    80001d46:	9756                	add	a4,a4,s5
    80001d48:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d4c:	0000e717          	auipc	a4,0xe
    80001d50:	c8c70713          	addi	a4,a4,-884 # 8000f9d8 <cpus+0x8>
    80001d54:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001d56:	4c11                	li	s8,4
        c->proc = p;
    80001d58:	0000eb17          	auipc	s6,0xe
    80001d5c:	c48b0b13          	addi	s6,s6,-952 # 8000f9a0 <pid_lock>
    80001d60:	079e                	slli	a5,a5,0x7
    80001d62:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001d66:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d68:	00014997          	auipc	s3,0x14
    80001d6c:	a6898993          	addi	s3,s3,-1432 # 800157d0 <tickslock>
    80001d70:	a0a9                	j	80001dba <scheduler+0x9e>
      release(&p->lock);
    80001d72:	8526                	mv	a0,s1
    80001d74:	ea9fe0ef          	jal	80000c1c <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d78:	16848493          	addi	s1,s1,360
    80001d7c:	03348b63          	beq	s1,s3,80001db2 <scheduler+0x96>
      acquire(&p->lock);
    80001d80:	8526                	mv	a0,s1
    80001d82:	e0ffe0ef          	jal	80000b90 <acquire>
      if (p->state == RUNNABLE) {
    80001d86:	4c9c                	lw	a5,24(s1)
    80001d88:	ff2795e3          	bne	a5,s2,80001d72 <scheduler+0x56>
        p->state = RUNNING;
    80001d8c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d90:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d94:	06048593          	addi	a1,s1,96
    80001d98:	8556                	mv	a0,s5
    80001d9a:	634000ef          	jal	800023ce <swtch>
    80001d9e:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001da0:	2781                	sext.w	a5,a5
    80001da2:	079e                	slli	a5,a5,0x7
    80001da4:	97da                	add	a5,a5,s6
    80001da6:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001daa:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dae:	8cde                	mv	s9,s7
    80001db0:	b7c9                	j	80001d72 <scheduler+0x56>
    if (found == 0) {
    80001db2:	000c9463          	bnez	s9,80001dba <scheduler+0x9e>
      asm volatile("wfi");
    80001db6:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001dba:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001dbe:	10017073          	csrci	sstatus,2
    int found = 0;
    80001dc2:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc4:	0000e497          	auipc	s1,0xe
    80001dc8:	00c48493          	addi	s1,s1,12 # 8000fdd0 <proc>
      if (p->state == RUNNABLE) {
    80001dcc:	490d                	li	s2,3
    80001dce:	bf4d                	j	80001d80 <scheduler+0x64>

0000000080001dd0 <sched>:
{
    80001dd0:	7179                	addi	sp,sp,-48
    80001dd2:	f406                	sd	ra,40(sp)
    80001dd4:	f022                	sd	s0,32(sp)
    80001dd6:	ec26                	sd	s1,24(sp)
    80001dd8:	e84a                	sd	s2,16(sp)
    80001dda:	e44e                	sd	s3,8(sp)
    80001ddc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dde:	ac7ff0ef          	jal	800018a4 <myproc>
    80001de2:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001de4:	d4dfe0ef          	jal	80000b30 <holding>
    80001de8:	c92d                	beqz	a0,80001e5a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001dea:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001dec:	2781                	sext.w	a5,a5
    80001dee:	079e                	slli	a5,a5,0x7
    80001df0:	0000e717          	auipc	a4,0xe
    80001df4:	bb070713          	addi	a4,a4,-1104 # 8000f9a0 <pid_lock>
    80001df8:	97ba                	add	a5,a5,a4
    80001dfa:	0a87a703          	lw	a4,168(a5)
    80001dfe:	4785                	li	a5,1
    80001e00:	06f71363          	bne	a4,a5,80001e66 <sched+0x96>
  if (p->state == RUNNING)
    80001e04:	4c98                	lw	a4,24(s1)
    80001e06:	4791                	li	a5,4
    80001e08:	06f70563          	beq	a4,a5,80001e72 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e10:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e12:	e7b5                	bnez	a5,80001e7e <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e14:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e16:	0000e917          	auipc	s2,0xe
    80001e1a:	b8a90913          	addi	s2,s2,-1142 # 8000f9a0 <pid_lock>
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	97ca                	add	a5,a5,s2
    80001e24:	0ac7a983          	lw	s3,172(a5)
    80001e28:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e2a:	2781                	sext.w	a5,a5
    80001e2c:	079e                	slli	a5,a5,0x7
    80001e2e:	0000e597          	auipc	a1,0xe
    80001e32:	baa58593          	addi	a1,a1,-1110 # 8000f9d8 <cpus+0x8>
    80001e36:	95be                	add	a1,a1,a5
    80001e38:	06048513          	addi	a0,s1,96
    80001e3c:	592000ef          	jal	800023ce <swtch>
    80001e40:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	993e                	add	s2,s2,a5
    80001e48:	0b392623          	sw	s3,172(s2)
}
    80001e4c:	70a2                	ld	ra,40(sp)
    80001e4e:	7402                	ld	s0,32(sp)
    80001e50:	64e2                	ld	s1,24(sp)
    80001e52:	6942                	ld	s2,16(sp)
    80001e54:	69a2                	ld	s3,8(sp)
    80001e56:	6145                	addi	sp,sp,48
    80001e58:	8082                	ret
    panic("sched p->lock");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	33e50513          	addi	a0,a0,830 # 80007198 <etext+0x198>
    80001e62:	98ffe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	34250513          	addi	a0,a0,834 # 800071a8 <etext+0x1a8>
    80001e6e:	983fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	34650513          	addi	a0,a0,838 # 800071b8 <etext+0x1b8>
    80001e7a:	977fe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001e7e:	00005517          	auipc	a0,0x5
    80001e82:	34a50513          	addi	a0,a0,842 # 800071c8 <etext+0x1c8>
    80001e86:	96bfe0ef          	jal	800007f0 <panic>

0000000080001e8a <yield>:
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e94:	a11ff0ef          	jal	800018a4 <myproc>
    80001e98:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e9a:	cf7fe0ef          	jal	80000b90 <acquire>
  p->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	cc9c                	sw	a5,24(s1)
  sched();
    80001ea2:	f2fff0ef          	jal	80001dd0 <sched>
  release(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	d75fe0ef          	jal	80000c1c <release>
}
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001eb6:	1101                	addi	sp,sp,-32
    80001eb8:	ec06                	sd	ra,24(sp)
    80001eba:	e822                	sd	s0,16(sp)
    80001ebc:	e426                	sd	s1,8(sp)
    80001ebe:	e04a                	sd	s2,0(sp)
    80001ec0:	1000                	addi	s0,sp,32
    80001ec2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ec4:	9e1ff0ef          	jal	800018a4 <myproc>
    80001ec8:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001eca:	cc7fe0ef          	jal	80000b90 <acquire>
  if (chan == 0)
    80001ece:	cc81                	beqz	s1,80001ee6 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001ed0:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001ed4:	854a                	mv	a0,s2
    80001ed6:	d47fe0ef          	jal	80000c1c <release>
}
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6902                	ld	s2,0(sp)
    80001ee2:	6105                	addi	sp,sp,32
    80001ee4:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001ee6:	00005517          	auipc	a0,0x5
    80001eea:	2fa50513          	addi	a0,a0,762 # 800071e0 <etext+0x1e0>
    80001eee:	903fe0ef          	jal	800007f0 <panic>

0000000080001ef2 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001efc:	9a9ff0ef          	jal	800018a4 <myproc>
    80001f00:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f02:	c8ffe0ef          	jal	80000b90 <acquire>
  if (p->chan != 0) {
    80001f06:	709c                	ld	a5,32(s1)
    80001f08:	c789                	beqz	a5,80001f12 <sleep+0x20>
    p->state = SLEEPING;
    80001f0a:	4789                	li	a5,2
    80001f0c:	cc9c                	sw	a5,24(s1)
    sched();
    80001f0e:	ec3ff0ef          	jal	80001dd0 <sched>
  }
  release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	d09fe0ef          	jal	80000c1c <release>
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6105                	addi	sp,sp,32
    80001f20:	8082                	ret

0000000080001f22 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f22:	7139                	addi	sp,sp,-64
    80001f24:	fc06                	sd	ra,56(sp)
    80001f26:	f822                	sd	s0,48(sp)
    80001f28:	f426                	sd	s1,40(sp)
    80001f2a:	f04a                	sd	s2,32(sp)
    80001f2c:	ec4e                	sd	s3,24(sp)
    80001f2e:	e852                	sd	s4,16(sp)
    80001f30:	e456                	sd	s5,8(sp)
    80001f32:	0080                	addi	s0,sp,64
    80001f34:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f36:	0000e497          	auipc	s1,0xe
    80001f3a:	e9a48493          	addi	s1,s1,-358 # 8000fdd0 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001f3e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001f40:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f42:	00014997          	auipc	s3,0x14
    80001f46:	88e98993          	addi	s3,s3,-1906 # 800157d0 <tickslock>
    80001f4a:	a801                	j	80001f5a <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	ccffe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f52:	16848493          	addi	s1,s1,360
    80001f56:	03348063          	beq	s1,s3,80001f76 <wakeup+0x54>
    acquire(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	c35fe0ef          	jal	80000b90 <acquire>
    if (p->chan == chan) {
    80001f60:	709c                	ld	a5,32(s1)
    80001f62:	ff2795e3          	bne	a5,s2,80001f4c <wakeup+0x2a>
      p->chan = 0;
    80001f66:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001f6a:	4c9c                	lw	a5,24(s1)
    80001f6c:	ff4790e3          	bne	a5,s4,80001f4c <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f70:	0154ac23          	sw	s5,24(s1)
    80001f74:	bfe1                	j	80001f4c <wakeup+0x2a>
  }
}
    80001f76:	70e2                	ld	ra,56(sp)
    80001f78:	7442                	ld	s0,48(sp)
    80001f7a:	74a2                	ld	s1,40(sp)
    80001f7c:	7902                	ld	s2,32(sp)
    80001f7e:	69e2                	ld	s3,24(sp)
    80001f80:	6a42                	ld	s4,16(sp)
    80001f82:	6aa2                	ld	s5,8(sp)
    80001f84:	6121                	addi	sp,sp,64
    80001f86:	8082                	ret

0000000080001f88 <reparent>:
{
    80001f88:	7179                	addi	sp,sp,-48
    80001f8a:	f406                	sd	ra,40(sp)
    80001f8c:	f022                	sd	s0,32(sp)
    80001f8e:	ec26                	sd	s1,24(sp)
    80001f90:	e84a                	sd	s2,16(sp)
    80001f92:	e44e                	sd	s3,8(sp)
    80001f94:	e052                	sd	s4,0(sp)
    80001f96:	1800                	addi	s0,sp,48
    80001f98:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001f9a:	0000e497          	auipc	s1,0xe
    80001f9e:	e3648493          	addi	s1,s1,-458 # 8000fdd0 <proc>
      pp->parent = initproc;
    80001fa2:	00006a17          	auipc	s4,0x6
    80001fa6:	8d6a0a13          	addi	s4,s4,-1834 # 80007878 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001faa:	00014997          	auipc	s3,0x14
    80001fae:	82698993          	addi	s3,s3,-2010 # 800157d0 <tickslock>
    80001fb2:	a029                	j	80001fbc <reparent+0x34>
    80001fb4:	16848493          	addi	s1,s1,360
    80001fb8:	01348b63          	beq	s1,s3,80001fce <reparent+0x46>
    if (pp->parent == p) {
    80001fbc:	7c9c                	ld	a5,56(s1)
    80001fbe:	ff279be3          	bne	a5,s2,80001fb4 <reparent+0x2c>
      pp->parent = initproc;
    80001fc2:	000a3503          	ld	a0,0(s4)
    80001fc6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fc8:	f5bff0ef          	jal	80001f22 <wakeup>
    80001fcc:	b7e5                	j	80001fb4 <reparent+0x2c>
}
    80001fce:	70a2                	ld	ra,40(sp)
    80001fd0:	7402                	ld	s0,32(sp)
    80001fd2:	64e2                	ld	s1,24(sp)
    80001fd4:	6942                	ld	s2,16(sp)
    80001fd6:	69a2                	ld	s3,8(sp)
    80001fd8:	6a02                	ld	s4,0(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret

0000000080001fde <kexit>:
{
    80001fde:	7179                	addi	sp,sp,-48
    80001fe0:	f406                	sd	ra,40(sp)
    80001fe2:	f022                	sd	s0,32(sp)
    80001fe4:	ec26                	sd	s1,24(sp)
    80001fe6:	e84a                	sd	s2,16(sp)
    80001fe8:	e44e                	sd	s3,8(sp)
    80001fea:	e052                	sd	s4,0(sp)
    80001fec:	1800                	addi	s0,sp,48
    80001fee:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff0:	8b5ff0ef          	jal	800018a4 <myproc>
    80001ff4:	89aa                	mv	s3,a0
  if (p == initproc)
    80001ff6:	00006797          	auipc	a5,0x6
    80001ffa:	8827b783          	ld	a5,-1918(a5) # 80007878 <initproc>
    80001ffe:	0d050493          	addi	s1,a0,208
    80002002:	15050913          	addi	s2,a0,336
    80002006:	00a79f63          	bne	a5,a0,80002024 <kexit+0x46>
    panic("init exiting");
    8000200a:	00005517          	auipc	a0,0x5
    8000200e:	1f650513          	addi	a0,a0,502 # 80007200 <etext+0x200>
    80002012:	fdefe0ef          	jal	800007f0 <panic>
      fileclose(f);
    80002016:	18c020ef          	jal	800041a2 <fileclose>
      p->ofile[fd] = 0;
    8000201a:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    8000201e:	04a1                	addi	s1,s1,8
    80002020:	01248563          	beq	s1,s2,8000202a <kexit+0x4c>
    if (p->ofile[fd]) {
    80002024:	6088                	ld	a0,0(s1)
    80002026:	f965                	bnez	a0,80002016 <kexit+0x38>
    80002028:	bfdd                	j	8000201e <kexit+0x40>
  begin_op();
    8000202a:	4cd010ef          	jal	80003cf6 <begin_op>
  iput(p->cwd);
    8000202e:	1509b503          	ld	a0,336(s3)
    80002032:	3fe010ef          	jal	80003430 <iput>
  end_op();
    80002036:	547010ef          	jal	80003d7c <end_op>
  p->cwd = 0;
    8000203a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000203e:	0000e497          	auipc	s1,0xe
    80002042:	97a48493          	addi	s1,s1,-1670 # 8000f9b8 <wait_lock>
    80002046:	8526                	mv	a0,s1
    80002048:	b49fe0ef          	jal	80000b90 <acquire>
  reparent(p);
    8000204c:	854e                	mv	a0,s3
    8000204e:	f3bff0ef          	jal	80001f88 <reparent>
  wakeup(p->parent);
    80002052:	0389b503          	ld	a0,56(s3)
    80002056:	ecdff0ef          	jal	80001f22 <wakeup>
  acquire(&p->lock);
    8000205a:	854e                	mv	a0,s3
    8000205c:	b35fe0ef          	jal	80000b90 <acquire>
  p->xstate = status;
    80002060:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002064:	4795                	li	a5,5
    80002066:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	bb1fe0ef          	jal	80000c1c <release>
  sched();
    80002070:	d61ff0ef          	jal	80001dd0 <sched>
  panic("zombie exit");
    80002074:	00005517          	auipc	a0,0x5
    80002078:	19c50513          	addi	a0,a0,412 # 80007210 <etext+0x210>
    8000207c:	f74fe0ef          	jal	800007f0 <panic>

0000000080002080 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002080:	7179                	addi	sp,sp,-48
    80002082:	f406                	sd	ra,40(sp)
    80002084:	f022                	sd	s0,32(sp)
    80002086:	ec26                	sd	s1,24(sp)
    80002088:	e84a                	sd	s2,16(sp)
    8000208a:	e44e                	sd	s3,8(sp)
    8000208c:	1800                	addi	s0,sp,48
    8000208e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002090:	0000e497          	auipc	s1,0xe
    80002094:	d4048493          	addi	s1,s1,-704 # 8000fdd0 <proc>
    80002098:	00013997          	auipc	s3,0x13
    8000209c:	73898993          	addi	s3,s3,1848 # 800157d0 <tickslock>
    acquire(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	aeffe0ef          	jal	80000b90 <acquire>
    if (p->pid == pid) {
    800020a6:	589c                	lw	a5,48(s1)
    800020a8:	01278b63          	beq	a5,s2,800020be <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	b6ffe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020b2:	16848493          	addi	s1,s1,360
    800020b6:	ff3495e3          	bne	s1,s3,800020a0 <kkill+0x20>
  }
  return -1;
    800020ba:	557d                	li	a0,-1
    800020bc:	a819                	j	800020d2 <kkill+0x52>
      p->killed = 1;
    800020be:	4785                	li	a5,1
    800020c0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800020c2:	4c98                	lw	a4,24(s1)
    800020c4:	4789                	li	a5,2
    800020c6:	00f70d63          	beq	a4,a5,800020e0 <kkill+0x60>
      release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	b51fe0ef          	jal	80000c1c <release>
      return 0;
    800020d0:	4501                	li	a0,0
}
    800020d2:	70a2                	ld	ra,40(sp)
    800020d4:	7402                	ld	s0,32(sp)
    800020d6:	64e2                	ld	s1,24(sp)
    800020d8:	6942                	ld	s2,16(sp)
    800020da:	69a2                	ld	s3,8(sp)
    800020dc:	6145                	addi	sp,sp,48
    800020de:	8082                	ret
        p->state = RUNNABLE;
    800020e0:	478d                	li	a5,3
    800020e2:	cc9c                	sw	a5,24(s1)
    800020e4:	b7dd                	j	800020ca <kkill+0x4a>

00000000800020e6 <setkilled>:

void
setkilled(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	1000                	addi	s0,sp,32
    800020f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f2:	a9ffe0ef          	jal	80000b90 <acquire>
  p->killed = 1;
    800020f6:	4785                	li	a5,1
    800020f8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	b21fe0ef          	jal	80000c1c <release>
}
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6105                	addi	sp,sp,32
    80002108:	8082                	ret

000000008000210a <killed>:

int
killed(struct proc *p)
{
    8000210a:	1101                	addi	sp,sp,-32
    8000210c:	ec06                	sd	ra,24(sp)
    8000210e:	e822                	sd	s0,16(sp)
    80002110:	e426                	sd	s1,8(sp)
    80002112:	e04a                	sd	s2,0(sp)
    80002114:	1000                	addi	s0,sp,32
    80002116:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002118:	a79fe0ef          	jal	80000b90 <acquire>
  k = p->killed;
    8000211c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	afbfe0ef          	jal	80000c1c <release>
  return k;
}
    80002126:	854a                	mv	a0,s2
    80002128:	60e2                	ld	ra,24(sp)
    8000212a:	6442                	ld	s0,16(sp)
    8000212c:	64a2                	ld	s1,8(sp)
    8000212e:	6902                	ld	s2,0(sp)
    80002130:	6105                	addi	sp,sp,32
    80002132:	8082                	ret

0000000080002134 <kwait>:
{
    80002134:	715d                	addi	sp,sp,-80
    80002136:	e486                	sd	ra,72(sp)
    80002138:	e0a2                	sd	s0,64(sp)
    8000213a:	fc26                	sd	s1,56(sp)
    8000213c:	f84a                	sd	s2,48(sp)
    8000213e:	f44e                	sd	s3,40(sp)
    80002140:	f052                	sd	s4,32(sp)
    80002142:	ec56                	sd	s5,24(sp)
    80002144:	e85a                	sd	s6,16(sp)
    80002146:	e45e                	sd	s7,8(sp)
    80002148:	e062                	sd	s8,0(sp)
    8000214a:	0880                	addi	s0,sp,80
    8000214c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000214e:	f56ff0ef          	jal	800018a4 <myproc>
    80002152:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002154:	0000e517          	auipc	a0,0xe
    80002158:	86450513          	addi	a0,a0,-1948 # 8000f9b8 <wait_lock>
    8000215c:	a35fe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    80002160:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    80002162:	4a15                	li	s4,5
        havekids = 1;
    80002164:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002166:	00013997          	auipc	s3,0x13
    8000216a:	66a98993          	addi	s3,s3,1642 # 800157d0 <tickslock>
    release(&wait_lock);
    8000216e:	0000eb97          	auipc	s7,0xe
    80002172:	84ab8b93          	addi	s7,s7,-1974 # 8000f9b8 <wait_lock>
    80002176:	a84d                	j	80002228 <kwait+0xf4>
          pid = pp->pid;
    80002178:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000217c:	000b0e63          	beqz	s6,80002198 <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002180:	4711                	li	a4,4
    80002182:	02c48693          	addi	a3,s1,44
    80002186:	865a                	mv	a2,s6
    80002188:	04893583          	ld	a1,72(s2)
    8000218c:	05093503          	ld	a0,80(s2)
    80002190:	b4aff0ef          	jal	800014da <copyout>
          if (addr != 0 &&
    80002194:	02054d63          	bltz	a0,800021ce <kwait+0x9a>
          pp->parent = 0;
    80002198:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000219c:	8526                	mv	a0,s1
    8000219e:	8e1ff0ef          	jal	80001a7e <freeproc>
          release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	a79fe0ef          	jal	80000c1c <release>
          release(&wait_lock);
    800021a8:	0000e517          	auipc	a0,0xe
    800021ac:	81050513          	addi	a0,a0,-2032 # 8000f9b8 <wait_lock>
    800021b0:	a6dfe0ef          	jal	80000c1c <release>
}
    800021b4:	854e                	mv	a0,s3
    800021b6:	60a6                	ld	ra,72(sp)
    800021b8:	6406                	ld	s0,64(sp)
    800021ba:	74e2                	ld	s1,56(sp)
    800021bc:	7942                	ld	s2,48(sp)
    800021be:	79a2                	ld	s3,40(sp)
    800021c0:	7a02                	ld	s4,32(sp)
    800021c2:	6ae2                	ld	s5,24(sp)
    800021c4:	6b42                	ld	s6,16(sp)
    800021c6:	6ba2                	ld	s7,8(sp)
    800021c8:	6c02                	ld	s8,0(sp)
    800021ca:	6161                	addi	sp,sp,80
    800021cc:	8082                	ret
            release(&pp->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	a4dfe0ef          	jal	80000c1c <release>
            release(&wait_lock);
    800021d4:	0000d517          	auipc	a0,0xd
    800021d8:	7e450513          	addi	a0,a0,2020 # 8000f9b8 <wait_lock>
    800021dc:	a41fe0ef          	jal	80000c1c <release>
            return -1;
    800021e0:	59fd                	li	s3,-1
    800021e2:	bfc9                	j	800021b4 <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021e4:	16848493          	addi	s1,s1,360
    800021e8:	03348063          	beq	s1,s3,80002208 <kwait+0xd4>
      if (pp->parent == p) {
    800021ec:	7c9c                	ld	a5,56(s1)
    800021ee:	ff279be3          	bne	a5,s2,800021e4 <kwait+0xb0>
        acquire(&pp->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	99dfe0ef          	jal	80000b90 <acquire>
        if (pp->state == ZOMBIE) {
    800021f8:	4c9c                	lw	a5,24(s1)
    800021fa:	f7478fe3          	beq	a5,s4,80002178 <kwait+0x44>
        release(&pp->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	a1dfe0ef          	jal	80000c1c <release>
        havekids = 1;
    80002204:	8756                	mv	a4,s5
    80002206:	bff9                	j	800021e4 <kwait+0xb0>
    if (!havekids || killed(p)) {
    80002208:	c715                	beqz	a4,80002234 <kwait+0x100>
    8000220a:	854a                	mv	a0,s2
    8000220c:	effff0ef          	jal	8000210a <killed>
    80002210:	e115                	bnez	a0,80002234 <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    80002212:	854a                	mv	a0,s2
    80002214:	ca3ff0ef          	jal	80001eb6 <sleep_prepare>
    release(&wait_lock);
    80002218:	855e                	mv	a0,s7
    8000221a:	a03fe0ef          	jal	80000c1c <release>
    sleep();
    8000221e:	cd5ff0ef          	jal	80001ef2 <sleep>
    acquire(&wait_lock);
    80002222:	855e                	mv	a0,s7
    80002224:	96dfe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    80002228:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000222a:	0000e497          	auipc	s1,0xe
    8000222e:	ba648493          	addi	s1,s1,-1114 # 8000fdd0 <proc>
    80002232:	bf6d                	j	800021ec <kwait+0xb8>
      release(&wait_lock);
    80002234:	0000d517          	auipc	a0,0xd
    80002238:	78450513          	addi	a0,a0,1924 # 8000f9b8 <wait_lock>
    8000223c:	9e1fe0ef          	jal	80000c1c <release>
      return -1;
    80002240:	59fd                	li	s3,-1
    80002242:	bf8d                	j	800021b4 <kwait+0x80>

0000000080002244 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002244:	7179                	addi	sp,sp,-48
    80002246:	f406                	sd	ra,40(sp)
    80002248:	f022                	sd	s0,32(sp)
    8000224a:	ec26                	sd	s1,24(sp)
    8000224c:	e84a                	sd	s2,16(sp)
    8000224e:	e44e                	sd	s3,8(sp)
    80002250:	e052                	sd	s4,0(sp)
    80002252:	1800                	addi	s0,sp,48
    80002254:	84aa                	mv	s1,a0
    80002256:	892e                	mv	s2,a1
    80002258:	89b2                	mv	s3,a2
    8000225a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000225c:	e48ff0ef          	jal	800018a4 <myproc>
  if (user_dst) {
    80002260:	c085                	beqz	s1,80002280 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002262:	8752                	mv	a4,s4
    80002264:	86ce                	mv	a3,s3
    80002266:	864a                	mv	a2,s2
    80002268:	652c                	ld	a1,72(a0)
    8000226a:	6928                	ld	a0,80(a0)
    8000226c:	a6eff0ef          	jal	800014da <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002270:	70a2                	ld	ra,40(sp)
    80002272:	7402                	ld	s0,32(sp)
    80002274:	64e2                	ld	s1,24(sp)
    80002276:	6942                	ld	s2,16(sp)
    80002278:	69a2                	ld	s3,8(sp)
    8000227a:	6a02                	ld	s4,0(sp)
    8000227c:	6145                	addi	sp,sp,48
    8000227e:	8082                	ret
    memmove((char *)dst, src, len);
    80002280:	000a061b          	sext.w	a2,s4
    80002284:	85ce                	mv	a1,s3
    80002286:	854a                	mv	a0,s2
    80002288:	a29fe0ef          	jal	80000cb0 <memmove>
    return 0;
    8000228c:	8526                	mv	a0,s1
    8000228e:	b7cd                	j	80002270 <either_copyout+0x2c>

0000000080002290 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002290:	7179                	addi	sp,sp,-48
    80002292:	f406                	sd	ra,40(sp)
    80002294:	f022                	sd	s0,32(sp)
    80002296:	ec26                	sd	s1,24(sp)
    80002298:	e84a                	sd	s2,16(sp)
    8000229a:	e44e                	sd	s3,8(sp)
    8000229c:	e052                	sd	s4,0(sp)
    8000229e:	1800                	addi	s0,sp,48
    800022a0:	892a                	mv	s2,a0
    800022a2:	84ae                	mv	s1,a1
    800022a4:	89b2                	mv	s3,a2
    800022a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a8:	dfcff0ef          	jal	800018a4 <myproc>
  if (user_src) {
    800022ac:	c085                	beqz	s1,800022cc <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800022ae:	8752                	mv	a4,s4
    800022b0:	86ce                	mv	a3,s3
    800022b2:	864a                	mv	a2,s2
    800022b4:	652c                	ld	a1,72(a0)
    800022b6:	6928                	ld	a0,80(a0)
    800022b8:	b0eff0ef          	jal	800015c6 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6a02                	ld	s4,0(sp)
    800022c8:	6145                	addi	sp,sp,48
    800022ca:	8082                	ret
    memmove(dst, (char *)src, len);
    800022cc:	000a061b          	sext.w	a2,s4
    800022d0:	85ce                	mv	a1,s3
    800022d2:	854a                	mv	a0,s2
    800022d4:	9ddfe0ef          	jal	80000cb0 <memmove>
    return 0;
    800022d8:	8526                	mv	a0,s1
    800022da:	b7cd                	j	800022bc <either_copyin+0x2c>

00000000800022dc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022dc:	715d                	addi	sp,sp,-80
    800022de:	e486                	sd	ra,72(sp)
    800022e0:	e0a2                	sd	s0,64(sp)
    800022e2:	fc26                	sd	s1,56(sp)
    800022e4:	f84a                	sd	s2,48(sp)
    800022e6:	f44e                	sd	s3,40(sp)
    800022e8:	f052                	sd	s4,32(sp)
    800022ea:	ec56                	sd	s5,24(sp)
    800022ec:	e85a                	sd	s6,16(sp)
    800022ee:	e45e                	sd	s7,8(sp)
    800022f0:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800022f2:	00005517          	auipc	a0,0x5
    800022f6:	d8650513          	addi	a0,a0,-634 # 80007078 <etext+0x78>
    800022fa:	a10fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022fe:	0000e497          	auipc	s1,0xe
    80002302:	c2a48493          	addi	s1,s1,-982 # 8000ff28 <proc+0x158>
    80002306:	00013917          	auipc	s2,0x13
    8000230a:	62290913          	addi	s2,s2,1570 # 80015928 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002310:	00005997          	auipc	s3,0x5
    80002314:	f1098993          	addi	s3,s3,-240 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002318:	00005a97          	auipc	s5,0x5
    8000231c:	f10a8a93          	addi	s5,s5,-240 # 80007228 <etext+0x228>
    printk("\n");
    80002320:	00005a17          	auipc	s4,0x5
    80002324:	d58a0a13          	addi	s4,s4,-680 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002328:	00005b97          	auipc	s7,0x5
    8000232c:	420b8b93          	addi	s7,s7,1056 # 80007748 <states.0>
    80002330:	a829                	j	8000234a <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002332:	ed86a583          	lw	a1,-296(a3)
    80002336:	8556                	mv	a0,s5
    80002338:	9d2fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000233c:	8552                	mv	a0,s4
    8000233e:	9ccfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002342:	16848493          	addi	s1,s1,360
    80002346:	03248263          	beq	s1,s2,8000236a <procdump+0x8e>
    if (p->state == UNUSED)
    8000234a:	86a6                	mv	a3,s1
    8000234c:	ec04a783          	lw	a5,-320(s1)
    80002350:	dbed                	beqz	a5,80002342 <procdump+0x66>
      state = "???";
    80002352:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002354:	fcfb6fe3          	bltu	s6,a5,80002332 <procdump+0x56>
    80002358:	02079713          	slli	a4,a5,0x20
    8000235c:	01d75793          	srli	a5,a4,0x1d
    80002360:	97de                	add	a5,a5,s7
    80002362:	6390                	ld	a2,0(a5)
    80002364:	f679                	bnez	a2,80002332 <procdump+0x56>
      state = "???";
    80002366:	864e                	mv	a2,s3
    80002368:	b7e9                	j	80002332 <procdump+0x56>
  }
}
    8000236a:	60a6                	ld	ra,72(sp)
    8000236c:	6406                	ld	s0,64(sp)
    8000236e:	74e2                	ld	s1,56(sp)
    80002370:	7942                	ld	s2,48(sp)
    80002372:	79a2                	ld	s3,40(sp)
    80002374:	7a02                	ld	s4,32(sp)
    80002376:	6ae2                	ld	s5,24(sp)
    80002378:	6b42                	ld	s6,16(sp)
    8000237a:	6ba2                	ld	s7,8(sp)
    8000237c:	6161                	addi	sp,sp,80
    8000237e:	8082                	ret

0000000080002380 <count_active_procs>:


int
count_active_procs(void)
{
    80002380:	7179                	addi	sp,sp,-48
    80002382:	f406                	sd	ra,40(sp)
    80002384:	f022                	sd	s0,32(sp)
    80002386:	ec26                	sd	s1,24(sp)
    80002388:	e84a                	sd	s2,16(sp)
    8000238a:	e44e                	sd	s3,8(sp)
    8000238c:	1800                	addi	s0,sp,48
  struct proc *p;
  int count = 0;
    8000238e:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002390:	0000e497          	auipc	s1,0xe
    80002394:	a4048493          	addi	s1,s1,-1472 # 8000fdd0 <proc>
    80002398:	00013997          	auipc	s3,0x13
    8000239c:	43898993          	addi	s3,s3,1080 # 800157d0 <tickslock>
    800023a0:	a801                	j	800023b0 <count_active_procs+0x30>
    acquire(&p->lock);
    if(p->state != UNUSED) {
      count++;
    }
    release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	879fe0ef          	jal	80000c1c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023a8:	16848493          	addi	s1,s1,360
    800023ac:	01348963          	beq	s1,s3,800023be <count_active_procs+0x3e>
    acquire(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fdefe0ef          	jal	80000b90 <acquire>
    if(p->state != UNUSED) {
    800023b6:	4c9c                	lw	a5,24(s1)
    800023b8:	d7ed                	beqz	a5,800023a2 <count_active_procs+0x22>
      count++;
    800023ba:	2905                	addiw	s2,s2,1
    800023bc:	b7dd                	j	800023a2 <count_active_procs+0x22>
  }
  return count;
    800023be:	854a                	mv	a0,s2
    800023c0:	70a2                	ld	ra,40(sp)
    800023c2:	7402                	ld	s0,32(sp)
    800023c4:	64e2                	ld	s1,24(sp)
    800023c6:	6942                	ld	s2,16(sp)
    800023c8:	69a2                	ld	s3,8(sp)
    800023ca:	6145                	addi	sp,sp,48
    800023cc:	8082                	ret

00000000800023ce <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023ce:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023d2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023d6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023d8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023da:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023de:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023e2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023e6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023ea:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023ee:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023f2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023f6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023fa:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023fe:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002402:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002406:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000240a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000240c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000240e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002412:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002416:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000241a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000241e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002422:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002426:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000242a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000242e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002432:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002436:	8082                	ret

0000000080002438 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002438:	1141                	addi	sp,sp,-16
    8000243a:	e406                	sd	ra,8(sp)
    8000243c:	e022                	sd	s0,0(sp)
    8000243e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002440:	00005597          	auipc	a1,0x5
    80002444:	e2858593          	addi	a1,a1,-472 # 80007268 <etext+0x268>
    80002448:	00013517          	auipc	a0,0x13
    8000244c:	38850513          	addi	a0,a0,904 # 800157d0 <tickslock>
    80002450:	ecafe0ef          	jal	80000b1a <initlock>
}
    80002454:	60a2                	ld	ra,8(sp)
    80002456:	6402                	ld	s0,0(sp)
    80002458:	0141                	addi	sp,sp,16
    8000245a:	8082                	ret

000000008000245c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000245c:	1141                	addi	sp,sp,-16
    8000245e:	e422                	sd	s0,8(sp)
    80002460:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002462:	00003797          	auipc	a5,0x3
    80002466:	18e78793          	addi	a5,a5,398 # 800055f0 <kernelvec>
    8000246a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000246e:	6422                	ld	s0,8(sp)
    80002470:	0141                	addi	sp,sp,16
    80002472:	8082                	ret

0000000080002474 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002474:	1141                	addi	sp,sp,-16
    80002476:	e406                	sd	ra,8(sp)
    80002478:	e022                	sd	s0,0(sp)
    8000247a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000247c:	c28ff0ef          	jal	800018a4 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002480:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002484:	04000737          	lui	a4,0x4000
    80002488:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000248a:	0732                	slli	a4,a4,0xc
    8000248c:	00004797          	auipc	a5,0x4
    80002490:	b7478793          	addi	a5,a5,-1164 # 80006000 <_trampoline>
    80002494:	00004697          	auipc	a3,0x4
    80002498:	b6c68693          	addi	a3,a3,-1172 # 80006000 <_trampoline>
    8000249c:	8f95                	sub	a5,a5,a3
    8000249e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024a0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024a4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800024a6:	18002773          	csrr	a4,satp
    800024aa:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024ac:	6d38                	ld	a4,88(a0)
    800024ae:	613c                	ld	a5,64(a0)
    800024b0:	6685                	lui	a3,0x1
    800024b2:	97b6                	add	a5,a5,a3
    800024b4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024b6:	6d3c                	ld	a5,88(a0)
    800024b8:	00000717          	auipc	a4,0x0
    800024bc:	0f870713          	addi	a4,a4,248 # 800025b0 <usertrap>
    800024c0:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800024c2:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800024c4:	8712                	mv	a4,tp
    800024c6:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800024c8:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024cc:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024d0:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800024d4:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024d8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800024da:	6f9c                	ld	a5,24(a5)
    800024dc:	14179073          	csrw	sepc,a5
}
    800024e0:	60a2                	ld	ra,8(sp)
    800024e2:	6402                	ld	s0,0(sp)
    800024e4:	0141                	addi	sp,sp,16
    800024e6:	8082                	ret

00000000800024e8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024e8:	1101                	addi	sp,sp,-32
    800024ea:	ec06                	sd	ra,24(sp)
    800024ec:	e822                	sd	s0,16(sp)
    800024ee:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    800024f0:	b88ff0ef          	jal	80001878 <cpuid>
    800024f4:	cd11                	beqz	a0,80002510 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800024f6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024fa:	000f4737          	lui	a4,0xf4
    800024fe:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002502:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002504:	14d79073          	csrw	stimecmp,a5
}
    80002508:	60e2                	ld	ra,24(sp)
    8000250a:	6442                	ld	s0,16(sp)
    8000250c:	6105                	addi	sp,sp,32
    8000250e:	8082                	ret
    80002510:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002512:	00013497          	auipc	s1,0x13
    80002516:	2be48493          	addi	s1,s1,702 # 800157d0 <tickslock>
    8000251a:	8526                	mv	a0,s1
    8000251c:	e74fe0ef          	jal	80000b90 <acquire>
    ticks++;
    80002520:	00005517          	auipc	a0,0x5
    80002524:	36050513          	addi	a0,a0,864 # 80007880 <ticks>
    80002528:	411c                	lw	a5,0(a0)
    8000252a:	2785                	addiw	a5,a5,1
    8000252c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000252e:	9f5ff0ef          	jal	80001f22 <wakeup>
    release(&tickslock);
    80002532:	8526                	mv	a0,s1
    80002534:	ee8fe0ef          	jal	80000c1c <release>
    80002538:	64a2                	ld	s1,8(sp)
    8000253a:	bf75                	j	800024f6 <clockintr+0xe>

000000008000253c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000253c:	1101                	addi	sp,sp,-32
    8000253e:	ec06                	sd	ra,24(sp)
    80002540:	e822                	sd	s0,16(sp)
    80002542:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002544:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002548:	57fd                	li	a5,-1
    8000254a:	17fe                	slli	a5,a5,0x3f
    8000254c:	07a5                	addi	a5,a5,9
    8000254e:	00f70c63          	beq	a4,a5,80002566 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002552:	57fd                	li	a5,-1
    80002554:	17fe                	slli	a5,a5,0x3f
    80002556:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002558:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    8000255a:	04f70763          	beq	a4,a5,800025a8 <devintr+0x6c>
  }
}
    8000255e:	60e2                	ld	ra,24(sp)
    80002560:	6442                	ld	s0,16(sp)
    80002562:	6105                	addi	sp,sp,32
    80002564:	8082                	ret
    80002566:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002568:	134030ef          	jal	8000569c <plic_claim>
    8000256c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000256e:	47a9                	li	a5,10
    80002570:	00f50963          	beq	a0,a5,80002582 <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    80002574:	4785                	li	a5,1
    80002576:	00f50963          	beq	a0,a5,80002588 <devintr+0x4c>
    return 1;
    8000257a:	4505                	li	a0,1
    } else if (irq) {
    8000257c:	e889                	bnez	s1,8000258e <devintr+0x52>
    8000257e:	64a2                	ld	s1,8(sp)
    80002580:	bff9                	j	8000255e <devintr+0x22>
      uartintr();
    80002582:	c0afe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002586:	a819                	j	8000259c <devintr+0x60>
      virtio_disk_intr();
    80002588:	5f8030ef          	jal	80005b80 <virtio_disk_intr>
    if (irq)
    8000258c:	a801                	j	8000259c <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    8000258e:	85a6                	mv	a1,s1
    80002590:	00005517          	auipc	a0,0x5
    80002594:	ce050513          	addi	a0,a0,-800 # 80007270 <etext+0x270>
    80002598:	f73fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000259c:	8526                	mv	a0,s1
    8000259e:	11e030ef          	jal	800056bc <plic_complete>
    return 1;
    800025a2:	4505                	li	a0,1
    800025a4:	64a2                	ld	s1,8(sp)
    800025a6:	bf65                	j	8000255e <devintr+0x22>
    clockintr();
    800025a8:	f41ff0ef          	jal	800024e8 <clockintr>
    return 2;
    800025ac:	4509                	li	a0,2
    800025ae:	bf45                	j	8000255e <devintr+0x22>

00000000800025b0 <usertrap>:
{
    800025b0:	1101                	addi	sp,sp,-32
    800025b2:	ec06                	sd	ra,24(sp)
    800025b4:	e822                	sd	s0,16(sp)
    800025b6:	e426                	sd	s1,8(sp)
    800025b8:	e04a                	sd	s2,0(sp)
    800025ba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025bc:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800025c0:	1007f793          	andi	a5,a5,256
    800025c4:	eba5                	bnez	a5,80002634 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025c6:	00003797          	auipc	a5,0x3
    800025ca:	02a78793          	addi	a5,a5,42 # 800055f0 <kernelvec>
    800025ce:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025d2:	ad2ff0ef          	jal	800018a4 <myproc>
    800025d6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025d8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025da:	14102773          	csrr	a4,sepc
    800025de:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800025e0:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800025e4:	47a1                	li	a5,8
    800025e6:	04f70d63          	beq	a4,a5,80002640 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800025ea:	f53ff0ef          	jal	8000253c <devintr>
    800025ee:	892a                	mv	s2,a0
    800025f0:	e54d                	bnez	a0,8000269a <usertrap+0xea>
    800025f2:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800025f6:	47bd                	li	a5,15
    800025f8:	08f70463          	beq	a4,a5,80002680 <usertrap+0xd0>
    800025fc:	14202773          	csrr	a4,scause
    80002600:	47b5                	li	a5,13
    80002602:	06f70f63          	beq	a4,a5,80002680 <usertrap+0xd0>
    80002606:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000260a:	5890                	lw	a2,48(s1)
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	ca450513          	addi	a0,a0,-860 # 800072b0 <etext+0x2b0>
    80002614:	ef7fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002618:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000261c:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002620:	00005517          	auipc	a0,0x5
    80002624:	cc050513          	addi	a0,a0,-832 # 800072e0 <etext+0x2e0>
    80002628:	ee3fd0ef          	jal	8000050a <printk>
    setkilled(p);
    8000262c:	8526                	mv	a0,s1
    8000262e:	ab9ff0ef          	jal	800020e6 <setkilled>
    80002632:	a015                	j	80002656 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002634:	00005517          	auipc	a0,0x5
    80002638:	c5c50513          	addi	a0,a0,-932 # 80007290 <etext+0x290>
    8000263c:	9b4fe0ef          	jal	800007f0 <panic>
    if (killed(p))
    80002640:	acbff0ef          	jal	8000210a <killed>
    80002644:	e915                	bnez	a0,80002678 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002646:	6cb8                	ld	a4,88(s1)
    80002648:	6f1c                	ld	a5,24(a4)
    8000264a:	0791                	addi	a5,a5,4
    8000264c:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000264e:	10016073          	csrsi	sstatus,2
    syscall();
    80002652:	24a000ef          	jal	8000289c <syscall>
  if (killed(p))
    80002656:	8526                	mv	a0,s1
    80002658:	ab3ff0ef          	jal	8000210a <killed>
    8000265c:	e521                	bnez	a0,800026a4 <usertrap+0xf4>
  prepare_return();
    8000265e:	e17ff0ef          	jal	80002474 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002662:	68a8                	ld	a0,80(s1)
    80002664:	8131                	srli	a0,a0,0xc
    80002666:	57fd                	li	a5,-1
    80002668:	17fe                	slli	a5,a5,0x3f
    8000266a:	8d5d                	or	a0,a0,a5
}
    8000266c:	60e2                	ld	ra,24(sp)
    8000266e:	6442                	ld	s0,16(sp)
    80002670:	64a2                	ld	s1,8(sp)
    80002672:	6902                	ld	s2,0(sp)
    80002674:	6105                	addi	sp,sp,32
    80002676:	8082                	ret
      kexit(-1);
    80002678:	557d                	li	a0,-1
    8000267a:	965ff0ef          	jal	80001fde <kexit>
    8000267e:	b7e1                	j	80002646 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002680:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002684:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002688:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    8000268a:	0016b693          	seqz	a3,a3
    8000268e:	64ac                	ld	a1,72(s1)
    80002690:	68a8                	ld	a0,80(s1)
    80002692:	dcdfe0ef          	jal	8000145e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002696:	f161                	bnez	a0,80002656 <usertrap+0xa6>
    80002698:	b7bd                	j	80002606 <usertrap+0x56>
  if (killed(p))
    8000269a:	8526                	mv	a0,s1
    8000269c:	a6fff0ef          	jal	8000210a <killed>
    800026a0:	c511                	beqz	a0,800026ac <usertrap+0xfc>
    800026a2:	a011                	j	800026a6 <usertrap+0xf6>
    800026a4:	4901                	li	s2,0
    kexit(-1);
    800026a6:	557d                	li	a0,-1
    800026a8:	937ff0ef          	jal	80001fde <kexit>
  if (which_dev == 2)
    800026ac:	4789                	li	a5,2
    800026ae:	faf918e3          	bne	s2,a5,8000265e <usertrap+0xae>
    yield();
    800026b2:	fd8ff0ef          	jal	80001e8a <yield>
    800026b6:	b765                	j	8000265e <usertrap+0xae>

00000000800026b8 <kerneltrap>:
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026c6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026ca:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800026ce:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800026d2:	1004f793          	andi	a5,s1,256
    800026d6:	c795                	beqz	a5,80002702 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026d8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026dc:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800026de:	eb85                	bnez	a5,8000270e <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    800026e0:	e5dff0ef          	jal	8000253c <devintr>
    800026e4:	c91d                	beqz	a0,8000271a <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    800026e6:	4789                	li	a5,2
    800026e8:	04f50a63          	beq	a0,a5,8000273c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026ec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026f0:	10049073          	csrw	sstatus,s1
}
    800026f4:	70a2                	ld	ra,40(sp)
    800026f6:	7402                	ld	s0,32(sp)
    800026f8:	64e2                	ld	s1,24(sp)
    800026fa:	6942                	ld	s2,16(sp)
    800026fc:	69a2                	ld	s3,8(sp)
    800026fe:	6145                	addi	sp,sp,48
    80002700:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002702:	00005517          	auipc	a0,0x5
    80002706:	c0650513          	addi	a0,a0,-1018 # 80007308 <etext+0x308>
    8000270a:	8e6fe0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000270e:	00005517          	auipc	a0,0x5
    80002712:	c2250513          	addi	a0,a0,-990 # 80007330 <etext+0x330>
    80002716:	8dafe0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000271a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000271e:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002722:	85ce                	mv	a1,s3
    80002724:	00005517          	auipc	a0,0x5
    80002728:	c2c50513          	addi	a0,a0,-980 # 80007350 <etext+0x350>
    8000272c:	ddffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002730:	00005517          	auipc	a0,0x5
    80002734:	c4850513          	addi	a0,a0,-952 # 80007378 <etext+0x378>
    80002738:	8b8fe0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    8000273c:	968ff0ef          	jal	800018a4 <myproc>
    80002740:	d555                	beqz	a0,800026ec <kerneltrap+0x34>
    yield();
    80002742:	f48ff0ef          	jal	80001e8a <yield>
    80002746:	b75d                	j	800026ec <kerneltrap+0x34>

0000000080002748 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002748:	1101                	addi	sp,sp,-32
    8000274a:	ec06                	sd	ra,24(sp)
    8000274c:	e822                	sd	s0,16(sp)
    8000274e:	e426                	sd	s1,8(sp)
    80002750:	1000                	addi	s0,sp,32
    80002752:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002754:	950ff0ef          	jal	800018a4 <myproc>
  switch (n) {
    80002758:	4795                	li	a5,5
    8000275a:	0497e163          	bltu	a5,s1,8000279c <argraw+0x54>
    8000275e:	048a                	slli	s1,s1,0x2
    80002760:	00005717          	auipc	a4,0x5
    80002764:	01870713          	addi	a4,a4,24 # 80007778 <states.0+0x30>
    80002768:	94ba                	add	s1,s1,a4
    8000276a:	409c                	lw	a5,0(s1)
    8000276c:	97ba                	add	a5,a5,a4
    8000276e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002770:	6d3c                	ld	a5,88(a0)
    80002772:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002774:	60e2                	ld	ra,24(sp)
    80002776:	6442                	ld	s0,16(sp)
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	6105                	addi	sp,sp,32
    8000277c:	8082                	ret
    return p->trapframe->a1;
    8000277e:	6d3c                	ld	a5,88(a0)
    80002780:	7fa8                	ld	a0,120(a5)
    80002782:	bfcd                	j	80002774 <argraw+0x2c>
    return p->trapframe->a2;
    80002784:	6d3c                	ld	a5,88(a0)
    80002786:	63c8                	ld	a0,128(a5)
    80002788:	b7f5                	j	80002774 <argraw+0x2c>
    return p->trapframe->a3;
    8000278a:	6d3c                	ld	a5,88(a0)
    8000278c:	67c8                	ld	a0,136(a5)
    8000278e:	b7dd                	j	80002774 <argraw+0x2c>
    return p->trapframe->a4;
    80002790:	6d3c                	ld	a5,88(a0)
    80002792:	6bc8                	ld	a0,144(a5)
    80002794:	b7c5                	j	80002774 <argraw+0x2c>
    return p->trapframe->a5;
    80002796:	6d3c                	ld	a5,88(a0)
    80002798:	6fc8                	ld	a0,152(a5)
    8000279a:	bfe9                	j	80002774 <argraw+0x2c>
  panic("argraw");
    8000279c:	00005517          	auipc	a0,0x5
    800027a0:	bec50513          	addi	a0,a0,-1044 # 80007388 <etext+0x388>
    800027a4:	84cfe0ef          	jal	800007f0 <panic>

00000000800027a8 <fetchaddr>:
{
    800027a8:	1101                	addi	sp,sp,-32
    800027aa:	ec06                	sd	ra,24(sp)
    800027ac:	e822                	sd	s0,16(sp)
    800027ae:	e426                	sd	s1,8(sp)
    800027b0:	e04a                	sd	s2,0(sp)
    800027b2:	1000                	addi	s0,sp,32
    800027b4:	84aa                	mv	s1,a0
    800027b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027b8:	8ecff0ef          	jal	800018a4 <myproc>
  if (addr >= p->sz ||
    800027bc:	652c                	ld	a1,72(a0)
    800027be:	02b4f663          	bgeu	s1,a1,800027ea <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027c2:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800027c6:	02f5e463          	bltu	a1,a5,800027ee <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800027ca:	4721                	li	a4,8
    800027cc:	86a6                	mv	a3,s1
    800027ce:	864a                	mv	a2,s2
    800027d0:	6928                	ld	a0,80(a0)
    800027d2:	df5fe0ef          	jal	800015c6 <copyin>
    800027d6:	00a03533          	snez	a0,a0
    800027da:	40a00533          	neg	a0,a0
}
    800027de:	60e2                	ld	ra,24(sp)
    800027e0:	6442                	ld	s0,16(sp)
    800027e2:	64a2                	ld	s1,8(sp)
    800027e4:	6902                	ld	s2,0(sp)
    800027e6:	6105                	addi	sp,sp,32
    800027e8:	8082                	ret
    return -1;
    800027ea:	557d                	li	a0,-1
    800027ec:	bfcd                	j	800027de <fetchaddr+0x36>
    800027ee:	557d                	li	a0,-1
    800027f0:	b7fd                	j	800027de <fetchaddr+0x36>

00000000800027f2 <fetchstr>:
{
    800027f2:	7179                	addi	sp,sp,-48
    800027f4:	f406                	sd	ra,40(sp)
    800027f6:	f022                	sd	s0,32(sp)
    800027f8:	ec26                	sd	s1,24(sp)
    800027fa:	e84a                	sd	s2,16(sp)
    800027fc:	e44e                	sd	s3,8(sp)
    800027fe:	1800                	addi	s0,sp,48
    80002800:	892a                	mv	s2,a0
    80002802:	84ae                	mv	s1,a1
    80002804:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002806:	89eff0ef          	jal	800018a4 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    8000280a:	874e                	mv	a4,s3
    8000280c:	86ca                	mv	a3,s2
    8000280e:	8626                	mv	a2,s1
    80002810:	652c                	ld	a1,72(a0)
    80002812:	6928                	ld	a0,80(a0)
    80002814:	e49fe0ef          	jal	8000165c <copyinstr>
    80002818:	00054c63          	bltz	a0,80002830 <fetchstr+0x3e>
  return strlen(buf);
    8000281c:	8526                	mv	a0,s1
    8000281e:	da6fe0ef          	jal	80000dc4 <strlen>
}
    80002822:	70a2                	ld	ra,40(sp)
    80002824:	7402                	ld	s0,32(sp)
    80002826:	64e2                	ld	s1,24(sp)
    80002828:	6942                	ld	s2,16(sp)
    8000282a:	69a2                	ld	s3,8(sp)
    8000282c:	6145                	addi	sp,sp,48
    8000282e:	8082                	ret
    return -1;
    80002830:	557d                	li	a0,-1
    80002832:	bfc5                	j	80002822 <fetchstr+0x30>

0000000080002834 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002834:	1101                	addi	sp,sp,-32
    80002836:	ec06                	sd	ra,24(sp)
    80002838:	e822                	sd	s0,16(sp)
    8000283a:	e426                	sd	s1,8(sp)
    8000283c:	1000                	addi	s0,sp,32
    8000283e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002840:	f09ff0ef          	jal	80002748 <argraw>
    80002844:	c088                	sw	a0,0(s1)
}
    80002846:	60e2                	ld	ra,24(sp)
    80002848:	6442                	ld	s0,16(sp)
    8000284a:	64a2                	ld	s1,8(sp)
    8000284c:	6105                	addi	sp,sp,32
    8000284e:	8082                	ret

0000000080002850 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	1000                	addi	s0,sp,32
    8000285a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000285c:	eedff0ef          	jal	80002748 <argraw>
    80002860:	e088                	sd	a0,0(s1)
}
    80002862:	60e2                	ld	ra,24(sp)
    80002864:	6442                	ld	s0,16(sp)
    80002866:	64a2                	ld	s1,8(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret

000000008000286c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000286c:	7179                	addi	sp,sp,-48
    8000286e:	f406                	sd	ra,40(sp)
    80002870:	f022                	sd	s0,32(sp)
    80002872:	ec26                	sd	s1,24(sp)
    80002874:	e84a                	sd	s2,16(sp)
    80002876:	1800                	addi	s0,sp,48
    80002878:	84ae                	mv	s1,a1
    8000287a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000287c:	fd840593          	addi	a1,s0,-40
    80002880:	fd1ff0ef          	jal	80002850 <argaddr>
  return fetchstr(addr, buf, max);
    80002884:	864a                	mv	a2,s2
    80002886:	85a6                	mv	a1,s1
    80002888:	fd843503          	ld	a0,-40(s0)
    8000288c:	f67ff0ef          	jal	800027f2 <fetchstr>
}
    80002890:	70a2                	ld	ra,40(sp)
    80002892:	7402                	ld	s0,32(sp)
    80002894:	64e2                	ld	s1,24(sp)
    80002896:	6942                	ld	s2,16(sp)
    80002898:	6145                	addi	sp,sp,48
    8000289a:	8082                	ret

000000008000289c <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000289c:	1101                	addi	sp,sp,-32
    8000289e:	ec06                	sd	ra,24(sp)
    800028a0:	e822                	sd	s0,16(sp)
    800028a2:	e426                	sd	s1,8(sp)
    800028a4:	e04a                	sd	s2,0(sp)
    800028a6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028a8:	ffdfe0ef          	jal	800018a4 <myproc>
    800028ac:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028ae:	05853903          	ld	s2,88(a0)
    800028b2:	0a893783          	ld	a5,168(s2)
    800028b6:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028ba:	37fd                	addiw	a5,a5,-1
    800028bc:	4755                	li	a4,21
    800028be:	00f76f63          	bltu	a4,a5,800028dc <syscall+0x40>
    800028c2:	00369713          	slli	a4,a3,0x3
    800028c6:	00005797          	auipc	a5,0x5
    800028ca:	eca78793          	addi	a5,a5,-310 # 80007790 <syscalls>
    800028ce:	97ba                	add	a5,a5,a4
    800028d0:	639c                	ld	a5,0(a5)
    800028d2:	c789                	beqz	a5,800028dc <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028d4:	9782                	jalr	a5
    800028d6:	06a93823          	sd	a0,112(s2)
    800028da:	a829                	j	800028f4 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800028dc:	15848613          	addi	a2,s1,344
    800028e0:	588c                	lw	a1,48(s1)
    800028e2:	00005517          	auipc	a0,0x5
    800028e6:	aae50513          	addi	a0,a0,-1362 # 80007390 <etext+0x390>
    800028ea:	c21fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800028ee:	6cbc                	ld	a5,88(s1)
    800028f0:	577d                	li	a4,-1
    800028f2:	fbb8                	sd	a4,112(a5)
  }
}
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	64a2                	ld	s1,8(sp)
    800028fa:	6902                	ld	s2,0(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret

0000000080002900 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002900:	1101                	addi	sp,sp,-32
    80002902:	ec06                	sd	ra,24(sp)
    80002904:	e822                	sd	s0,16(sp)
    80002906:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002908:	fec40593          	addi	a1,s0,-20
    8000290c:	4501                	li	a0,0
    8000290e:	f27ff0ef          	jal	80002834 <argint>
  kexit(n);
    80002912:	fec42503          	lw	a0,-20(s0)
    80002916:	ec8ff0ef          	jal	80001fde <kexit>
  return 0; // not reached
}
    8000291a:	4501                	li	a0,0
    8000291c:	60e2                	ld	ra,24(sp)
    8000291e:	6442                	ld	s0,16(sp)
    80002920:	6105                	addi	sp,sp,32
    80002922:	8082                	ret

0000000080002924 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002924:	1141                	addi	sp,sp,-16
    80002926:	e406                	sd	ra,8(sp)
    80002928:	e022                	sd	s0,0(sp)
    8000292a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000292c:	f79fe0ef          	jal	800018a4 <myproc>
}
    80002930:	5908                	lw	a0,48(a0)
    80002932:	60a2                	ld	ra,8(sp)
    80002934:	6402                	ld	s0,0(sp)
    80002936:	0141                	addi	sp,sp,16
    80002938:	8082                	ret

000000008000293a <sys_fork>:

uint64
sys_fork(void)
{
    8000293a:	1141                	addi	sp,sp,-16
    8000293c:	e406                	sd	ra,8(sp)
    8000293e:	e022                	sd	s0,0(sp)
    80002940:	0800                	addi	s0,sp,16
  return kfork();
    80002942:	accff0ef          	jal	80001c0e <kfork>
}
    80002946:	60a2                	ld	ra,8(sp)
    80002948:	6402                	ld	s0,0(sp)
    8000294a:	0141                	addi	sp,sp,16
    8000294c:	8082                	ret

000000008000294e <sys_wait>:

uint64
sys_wait(void)
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002956:	fe840593          	addi	a1,s0,-24
    8000295a:	4501                	li	a0,0
    8000295c:	ef5ff0ef          	jal	80002850 <argaddr>
  return kwait(p);
    80002960:	fe843503          	ld	a0,-24(s0)
    80002964:	fd0ff0ef          	jal	80002134 <kwait>
}
    80002968:	60e2                	ld	ra,24(sp)
    8000296a:	6442                	ld	s0,16(sp)
    8000296c:	6105                	addi	sp,sp,32
    8000296e:	8082                	ret

0000000080002970 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002970:	7179                	addi	sp,sp,-48
    80002972:	f406                	sd	ra,40(sp)
    80002974:	f022                	sd	s0,32(sp)
    80002976:	ec26                	sd	s1,24(sp)
    80002978:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000297a:	fd840593          	addi	a1,s0,-40
    8000297e:	4501                	li	a0,0
    80002980:	eb5ff0ef          	jal	80002834 <argint>
  argint(1, &t);
    80002984:	fdc40593          	addi	a1,s0,-36
    80002988:	4505                	li	a0,1
    8000298a:	eabff0ef          	jal	80002834 <argint>
  addr = myproc()->sz;
    8000298e:	f17fe0ef          	jal	800018a4 <myproc>
    80002992:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002994:	fdc42703          	lw	a4,-36(s0)
    80002998:	4785                	li	a5,1
    8000299a:	02f70763          	beq	a4,a5,800029c8 <sys_sbrk+0x58>
    8000299e:	fd842783          	lw	a5,-40(s0)
    800029a2:	0207c363          	bltz	a5,800029c8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    800029a6:	97a6                	add	a5,a5,s1
    800029a8:	0297ee63          	bltu	a5,s1,800029e4 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    800029ac:	02000737          	lui	a4,0x2000
    800029b0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029b2:	0736                	slli	a4,a4,0xd
    800029b4:	02f76a63          	bltu	a4,a5,800029e8 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    800029b8:	eedfe0ef          	jal	800018a4 <myproc>
    800029bc:	fd842703          	lw	a4,-40(s0)
    800029c0:	653c                	ld	a5,72(a0)
    800029c2:	97ba                	add	a5,a5,a4
    800029c4:	e53c                	sd	a5,72(a0)
    800029c6:	a039                	j	800029d4 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    800029c8:	fd842503          	lw	a0,-40(s0)
    800029cc:	9e0ff0ef          	jal	80001bac <growproc>
    800029d0:	00054863          	bltz	a0,800029e0 <sys_sbrk+0x70>
  }
  return addr;
}
    800029d4:	8526                	mv	a0,s1
    800029d6:	70a2                	ld	ra,40(sp)
    800029d8:	7402                	ld	s0,32(sp)
    800029da:	64e2                	ld	s1,24(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret
      return -1;
    800029e0:	54fd                	li	s1,-1
    800029e2:	bfcd                	j	800029d4 <sys_sbrk+0x64>
      return -1;
    800029e4:	54fd                	li	s1,-1
    800029e6:	b7fd                	j	800029d4 <sys_sbrk+0x64>
      return -1;
    800029e8:	54fd                	li	s1,-1
    800029ea:	b7ed                	j	800029d4 <sys_sbrk+0x64>

00000000800029ec <sys_pause>:

uint64
sys_pause(void)
{
    800029ec:	7139                	addi	sp,sp,-64
    800029ee:	fc06                	sd	ra,56(sp)
    800029f0:	f822                	sd	s0,48(sp)
    800029f2:	ec4e                	sd	s3,24(sp)
    800029f4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029f6:	fcc40593          	addi	a1,s0,-52
    800029fa:	4501                	li	a0,0
    800029fc:	e39ff0ef          	jal	80002834 <argint>
  if (n < 0)
    80002a00:	fcc42783          	lw	a5,-52(s0)
    80002a04:	0607cf63          	bltz	a5,80002a82 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a08:	00013517          	auipc	a0,0x13
    80002a0c:	dc850513          	addi	a0,a0,-568 # 800157d0 <tickslock>
    80002a10:	980fe0ef          	jal	80000b90 <acquire>
  ticks0 = ticks;
    80002a14:	00005997          	auipc	s3,0x5
    80002a18:	e6c9a983          	lw	s3,-404(s3) # 80007880 <ticks>
  while (ticks - ticks0 < n) {
    80002a1c:	fcc42783          	lw	a5,-52(s0)
    80002a20:	c7a9                	beqz	a5,80002a6a <sys_pause+0x7e>
    80002a22:	f426                	sd	s1,40(sp)
    80002a24:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002a26:	00005917          	auipc	s2,0x5
    80002a2a:	e5a90913          	addi	s2,s2,-422 # 80007880 <ticks>
    release(&tickslock);
    80002a2e:	00013497          	auipc	s1,0x13
    80002a32:	da248493          	addi	s1,s1,-606 # 800157d0 <tickslock>
    if (killed(myproc())) {
    80002a36:	e6ffe0ef          	jal	800018a4 <myproc>
    80002a3a:	ed0ff0ef          	jal	8000210a <killed>
    80002a3e:	e529                	bnez	a0,80002a88 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002a40:	854a                	mv	a0,s2
    80002a42:	c74ff0ef          	jal	80001eb6 <sleep_prepare>
    release(&tickslock);
    80002a46:	8526                	mv	a0,s1
    80002a48:	9d4fe0ef          	jal	80000c1c <release>
    sleep();
    80002a4c:	ca6ff0ef          	jal	80001ef2 <sleep>
    acquire(&tickslock);
    80002a50:	8526                	mv	a0,s1
    80002a52:	93efe0ef          	jal	80000b90 <acquire>
  while (ticks - ticks0 < n) {
    80002a56:	00092783          	lw	a5,0(s2)
    80002a5a:	413787bb          	subw	a5,a5,s3
    80002a5e:	fcc42703          	lw	a4,-52(s0)
    80002a62:	fce7eae3          	bltu	a5,a4,80002a36 <sys_pause+0x4a>
    80002a66:	74a2                	ld	s1,40(sp)
    80002a68:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002a6a:	00013517          	auipc	a0,0x13
    80002a6e:	d6650513          	addi	a0,a0,-666 # 800157d0 <tickslock>
    80002a72:	9aafe0ef          	jal	80000c1c <release>
  return 0;
    80002a76:	4501                	li	a0,0
}
    80002a78:	70e2                	ld	ra,56(sp)
    80002a7a:	7442                	ld	s0,48(sp)
    80002a7c:	69e2                	ld	s3,24(sp)
    80002a7e:	6121                	addi	sp,sp,64
    80002a80:	8082                	ret
    n = 0;
    80002a82:	fc042623          	sw	zero,-52(s0)
    80002a86:	b749                	j	80002a08 <sys_pause+0x1c>
      release(&tickslock);
    80002a88:	00013517          	auipc	a0,0x13
    80002a8c:	d4850513          	addi	a0,a0,-696 # 800157d0 <tickslock>
    80002a90:	98cfe0ef          	jal	80000c1c <release>
      return -1;
    80002a94:	557d                	li	a0,-1
    80002a96:	74a2                	ld	s1,40(sp)
    80002a98:	7902                	ld	s2,32(sp)
    80002a9a:	bff9                	j	80002a78 <sys_pause+0x8c>

0000000080002a9c <sys_kill>:

uint64
sys_kill(void)
{
    80002a9c:	1101                	addi	sp,sp,-32
    80002a9e:	ec06                	sd	ra,24(sp)
    80002aa0:	e822                	sd	s0,16(sp)
    80002aa2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002aa4:	fec40593          	addi	a1,s0,-20
    80002aa8:	4501                	li	a0,0
    80002aaa:	d8bff0ef          	jal	80002834 <argint>
  return kkill(pid);
    80002aae:	fec42503          	lw	a0,-20(s0)
    80002ab2:	dceff0ef          	jal	80002080 <kkill>
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	6105                	addi	sp,sp,32
    80002abc:	8082                	ret

0000000080002abe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ac8:	00013517          	auipc	a0,0x13
    80002acc:	d0850513          	addi	a0,a0,-760 # 800157d0 <tickslock>
    80002ad0:	8c0fe0ef          	jal	80000b90 <acquire>
  xticks = ticks;
    80002ad4:	00005497          	auipc	s1,0x5
    80002ad8:	dac4a483          	lw	s1,-596(s1) # 80007880 <ticks>
  release(&tickslock);
    80002adc:	00013517          	auipc	a0,0x13
    80002ae0:	cf450513          	addi	a0,a0,-780 # 800157d0 <tickslock>
    80002ae4:	938fe0ef          	jal	80000c1c <release>
  return xticks;
}
    80002ae8:	02049513          	slli	a0,s1,0x20
    80002aec:	9101                	srli	a0,a0,0x20
    80002aee:	60e2                	ld	ra,24(sp)
    80002af0:	6442                	ld	s0,16(sp)
    80002af2:	64a2                	ld	s1,8(sp)
    80002af4:	6105                	addi	sp,sp,32
    80002af6:	8082                	ret

0000000080002af8 <sys_cpustats>:

uint64
sys_cpustats(void)
{
    80002af8:	7179                	addi	sp,sp,-48
    80002afa:	f406                	sd	ra,40(sp)
    80002afc:	f022                	sd	s0,32(sp)
    80002afe:	ec26                	sd	s1,24(sp)
    80002b00:	1800                	addi	s0,sp,48
  uint64 addr;
  struct cpustats st;
  struct proc *p = myproc();
    80002b02:	da3fe0ef          	jal	800018a4 <myproc>
    80002b06:	84aa                	mv	s1,a0

  argaddr(0, &addr);
    80002b08:	fd840593          	addi	a1,s0,-40
    80002b0c:	4501                	li	a0,0
    80002b0e:	d43ff0ef          	jal	80002850 <argaddr>

  st.nproc = count_active_procs();
    80002b12:	86fff0ef          	jal	80002380 <count_active_procs>
    80002b16:	fca42823          	sw	a0,-48(s0)
  acquire(&tickslock);
    80002b1a:	00013517          	auipc	a0,0x13
    80002b1e:	cb650513          	addi	a0,a0,-842 # 800157d0 <tickslock>
    80002b22:	86efe0ef          	jal	80000b90 <acquire>
  st.ticks = ticks;
    80002b26:	00005797          	auipc	a5,0x5
    80002b2a:	d5a7a783          	lw	a5,-678(a5) # 80007880 <ticks>
    80002b2e:	fcf42a23          	sw	a5,-44(s0)
  release(&tickslock);
    80002b32:	00013517          	auipc	a0,0x13
    80002b36:	c9e50513          	addi	a0,a0,-866 # 800157d0 <tickslock>
    80002b3a:	8e2fe0ef          	jal	80000c1c <release>

  if(copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80002b3e:	4721                	li	a4,8
    80002b40:	fd040693          	addi	a3,s0,-48
    80002b44:	fd843603          	ld	a2,-40(s0)
    80002b48:	64ac                	ld	a1,72(s1)
    80002b4a:	68a8                	ld	a0,80(s1)
    80002b4c:	98ffe0ef          	jal	800014da <copyout>
    return -1;
  return 0;
}
    80002b50:	957d                	srai	a0,a0,0x3f
    80002b52:	70a2                	ld	ra,40(sp)
    80002b54:	7402                	ld	s0,32(sp)
    80002b56:	64e2                	ld	s1,24(sp)
    80002b58:	6145                	addi	sp,sp,48
    80002b5a:	8082                	ret

0000000080002b5c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b5c:	7179                	addi	sp,sp,-48
    80002b5e:	f406                	sd	ra,40(sp)
    80002b60:	f022                	sd	s0,32(sp)
    80002b62:	ec26                	sd	s1,24(sp)
    80002b64:	e84a                	sd	s2,16(sp)
    80002b66:	e44e                	sd	s3,8(sp)
    80002b68:	e052                	sd	s4,0(sp)
    80002b6a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b6c:	00005597          	auipc	a1,0x5
    80002b70:	84458593          	addi	a1,a1,-1980 # 800073b0 <etext+0x3b0>
    80002b74:	00013517          	auipc	a0,0x13
    80002b78:	c7450513          	addi	a0,a0,-908 # 800157e8 <bcache>
    80002b7c:	f9ffd0ef          	jal	80000b1a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b80:	0001b797          	auipc	a5,0x1b
    80002b84:	c6878793          	addi	a5,a5,-920 # 8001d7e8 <bcache+0x8000>
    80002b88:	0001b717          	auipc	a4,0x1b
    80002b8c:	ec870713          	addi	a4,a4,-312 # 8001da50 <bcache+0x8268>
    80002b90:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b94:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b98:	00013497          	auipc	s1,0x13
    80002b9c:	c6848493          	addi	s1,s1,-920 # 80015800 <bcache+0x18>
    b->next = bcache.head.next;
    80002ba0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ba2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ba4:	00005a17          	auipc	s4,0x5
    80002ba8:	814a0a13          	addi	s4,s4,-2028 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002bac:	2b893783          	ld	a5,696(s2)
    80002bb0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bb2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bb6:	85d2                	mv	a1,s4
    80002bb8:	01048513          	addi	a0,s1,16
    80002bbc:	412010ef          	jal	80003fce <initsleeplock>
    bcache.head.next->prev = b;
    80002bc0:	2b893783          	ld	a5,696(s2)
    80002bc4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bc6:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002bca:	45848493          	addi	s1,s1,1112
    80002bce:	fd349fe3          	bne	s1,s3,80002bac <binit+0x50>
  }
}
    80002bd2:	70a2                	ld	ra,40(sp)
    80002bd4:	7402                	ld	s0,32(sp)
    80002bd6:	64e2                	ld	s1,24(sp)
    80002bd8:	6942                	ld	s2,16(sp)
    80002bda:	69a2                	ld	s3,8(sp)
    80002bdc:	6a02                	ld	s4,0(sp)
    80002bde:	6145                	addi	sp,sp,48
    80002be0:	8082                	ret

0000000080002be2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002be2:	7179                	addi	sp,sp,-48
    80002be4:	f406                	sd	ra,40(sp)
    80002be6:	f022                	sd	s0,32(sp)
    80002be8:	ec26                	sd	s1,24(sp)
    80002bea:	e84a                	sd	s2,16(sp)
    80002bec:	e44e                	sd	s3,8(sp)
    80002bee:	1800                	addi	s0,sp,48
    80002bf0:	892a                	mv	s2,a0
    80002bf2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bf4:	00013517          	auipc	a0,0x13
    80002bf8:	bf450513          	addi	a0,a0,-1036 # 800157e8 <bcache>
    80002bfc:	f95fd0ef          	jal	80000b90 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002c00:	0001b497          	auipc	s1,0x1b
    80002c04:	ea04b483          	ld	s1,-352(s1) # 8001daa0 <bcache+0x82b8>
    80002c08:	0001b797          	auipc	a5,0x1b
    80002c0c:	e4878793          	addi	a5,a5,-440 # 8001da50 <bcache+0x8268>
    80002c10:	02f48b63          	beq	s1,a5,80002c46 <bread+0x64>
    80002c14:	873e                	mv	a4,a5
    80002c16:	a021                	j	80002c1e <bread+0x3c>
    80002c18:	68a4                	ld	s1,80(s1)
    80002c1a:	02e48663          	beq	s1,a4,80002c46 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c1e:	449c                	lw	a5,8(s1)
    80002c20:	ff279ce3          	bne	a5,s2,80002c18 <bread+0x36>
    80002c24:	44dc                	lw	a5,12(s1)
    80002c26:	ff3799e3          	bne	a5,s3,80002c18 <bread+0x36>
      b->refcnt++;
    80002c2a:	40bc                	lw	a5,64(s1)
    80002c2c:	2785                	addiw	a5,a5,1
    80002c2e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c30:	00013517          	auipc	a0,0x13
    80002c34:	bb850513          	addi	a0,a0,-1096 # 800157e8 <bcache>
    80002c38:	fe5fd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002c3c:	01048513          	addi	a0,s1,16
    80002c40:	3c4010ef          	jal	80004004 <acquiresleep>
      return b;
    80002c44:	a889                	j	80002c96 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c46:	0001b497          	auipc	s1,0x1b
    80002c4a:	e524b483          	ld	s1,-430(s1) # 8001da98 <bcache+0x82b0>
    80002c4e:	0001b797          	auipc	a5,0x1b
    80002c52:	e0278793          	addi	a5,a5,-510 # 8001da50 <bcache+0x8268>
    80002c56:	00f48863          	beq	s1,a5,80002c66 <bread+0x84>
    80002c5a:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c5c:	40bc                	lw	a5,64(s1)
    80002c5e:	cb91                	beqz	a5,80002c72 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c60:	64a4                	ld	s1,72(s1)
    80002c62:	fee49de3          	bne	s1,a4,80002c5c <bread+0x7a>
  panic("bget: no buffers");
    80002c66:	00004517          	auipc	a0,0x4
    80002c6a:	75a50513          	addi	a0,a0,1882 # 800073c0 <etext+0x3c0>
    80002c6e:	b83fd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    80002c72:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c76:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c7a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c7e:	4785                	li	a5,1
    80002c80:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c82:	00013517          	auipc	a0,0x13
    80002c86:	b6650513          	addi	a0,a0,-1178 # 800157e8 <bcache>
    80002c8a:	f93fd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002c8e:	01048513          	addi	a0,s1,16
    80002c92:	372010ef          	jal	80004004 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c96:	409c                	lw	a5,0(s1)
    80002c98:	cb89                	beqz	a5,80002caa <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c9a:	8526                	mv	a0,s1
    80002c9c:	70a2                	ld	ra,40(sp)
    80002c9e:	7402                	ld	s0,32(sp)
    80002ca0:	64e2                	ld	s1,24(sp)
    80002ca2:	6942                	ld	s2,16(sp)
    80002ca4:	69a2                	ld	s3,8(sp)
    80002ca6:	6145                	addi	sp,sp,48
    80002ca8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002caa:	4581                	li	a1,0
    80002cac:	8526                	mv	a0,s1
    80002cae:	4a3020ef          	jal	80005950 <virtio_disk_rw>
    b->valid = 1;
    80002cb2:	4785                	li	a5,1
    80002cb4:	c09c                	sw	a5,0(s1)
  return b;
    80002cb6:	b7d5                	j	80002c9a <bread+0xb8>

0000000080002cb8 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cc4:	0541                	addi	a0,a0,16
    80002cc6:	3ca010ef          	jal	80004090 <holdingsleep>
    80002cca:	c911                	beqz	a0,80002cde <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ccc:	4585                	li	a1,1
    80002cce:	8526                	mv	a0,s1
    80002cd0:	481020ef          	jal	80005950 <virtio_disk_rw>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret
    panic("bwrite");
    80002cde:	00004517          	auipc	a0,0x4
    80002ce2:	6fa50513          	addi	a0,a0,1786 # 800073d8 <etext+0x3d8>
    80002ce6:	b0bfd0ef          	jal	800007f0 <panic>

0000000080002cea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cea:	1101                	addi	sp,sp,-32
    80002cec:	ec06                	sd	ra,24(sp)
    80002cee:	e822                	sd	s0,16(sp)
    80002cf0:	e426                	sd	s1,8(sp)
    80002cf2:	e04a                	sd	s2,0(sp)
    80002cf4:	1000                	addi	s0,sp,32
    80002cf6:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cf8:	01050913          	addi	s2,a0,16
    80002cfc:	854a                	mv	a0,s2
    80002cfe:	392010ef          	jal	80004090 <holdingsleep>
    80002d02:	c135                	beqz	a0,80002d66 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002d04:	854a                	mv	a0,s2
    80002d06:	352010ef          	jal	80004058 <releasesleep>

  acquire(&bcache.lock);
    80002d0a:	00013517          	auipc	a0,0x13
    80002d0e:	ade50513          	addi	a0,a0,-1314 # 800157e8 <bcache>
    80002d12:	e7ffd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002d16:	40bc                	lw	a5,64(s1)
    80002d18:	37fd                	addiw	a5,a5,-1
    80002d1a:	0007871b          	sext.w	a4,a5
    80002d1e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d20:	e71d                	bnez	a4,80002d4e <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d22:	68b8                	ld	a4,80(s1)
    80002d24:	64bc                	ld	a5,72(s1)
    80002d26:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d28:	68b8                	ld	a4,80(s1)
    80002d2a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d2c:	0001b797          	auipc	a5,0x1b
    80002d30:	abc78793          	addi	a5,a5,-1348 # 8001d7e8 <bcache+0x8000>
    80002d34:	2b87b703          	ld	a4,696(a5)
    80002d38:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d3a:	0001b717          	auipc	a4,0x1b
    80002d3e:	d1670713          	addi	a4,a4,-746 # 8001da50 <bcache+0x8268>
    80002d42:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d44:	2b87b703          	ld	a4,696(a5)
    80002d48:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d4a:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d4e:	00013517          	auipc	a0,0x13
    80002d52:	a9a50513          	addi	a0,a0,-1382 # 800157e8 <bcache>
    80002d56:	ec7fd0ef          	jal	80000c1c <release>
}
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	64a2                	ld	s1,8(sp)
    80002d60:	6902                	ld	s2,0(sp)
    80002d62:	6105                	addi	sp,sp,32
    80002d64:	8082                	ret
    panic("brelse");
    80002d66:	00004517          	auipc	a0,0x4
    80002d6a:	67a50513          	addi	a0,a0,1658 # 800073e0 <etext+0x3e0>
    80002d6e:	a83fd0ef          	jal	800007f0 <panic>

0000000080002d72 <bpin>:

void
bpin(struct buf *b)
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	e426                	sd	s1,8(sp)
    80002d7a:	1000                	addi	s0,sp,32
    80002d7c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d7e:	00013517          	auipc	a0,0x13
    80002d82:	a6a50513          	addi	a0,a0,-1430 # 800157e8 <bcache>
    80002d86:	e0bfd0ef          	jal	80000b90 <acquire>
  b->refcnt++;
    80002d8a:	40bc                	lw	a5,64(s1)
    80002d8c:	2785                	addiw	a5,a5,1
    80002d8e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d90:	00013517          	auipc	a0,0x13
    80002d94:	a5850513          	addi	a0,a0,-1448 # 800157e8 <bcache>
    80002d98:	e85fd0ef          	jal	80000c1c <release>
}
    80002d9c:	60e2                	ld	ra,24(sp)
    80002d9e:	6442                	ld	s0,16(sp)
    80002da0:	64a2                	ld	s1,8(sp)
    80002da2:	6105                	addi	sp,sp,32
    80002da4:	8082                	ret

0000000080002da6 <bunpin>:

void
bunpin(struct buf *b)
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	e426                	sd	s1,8(sp)
    80002dae:	1000                	addi	s0,sp,32
    80002db0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002db2:	00013517          	auipc	a0,0x13
    80002db6:	a3650513          	addi	a0,a0,-1482 # 800157e8 <bcache>
    80002dba:	dd7fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002dbe:	40bc                	lw	a5,64(s1)
    80002dc0:	37fd                	addiw	a5,a5,-1
    80002dc2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dc4:	00013517          	auipc	a0,0x13
    80002dc8:	a2450513          	addi	a0,a0,-1500 # 800157e8 <bcache>
    80002dcc:	e51fd0ef          	jal	80000c1c <release>
}
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	64a2                	ld	s1,8(sp)
    80002dd6:	6105                	addi	sp,sp,32
    80002dd8:	8082                	ret

0000000080002dda <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dda:	1101                	addi	sp,sp,-32
    80002ddc:	ec06                	sd	ra,24(sp)
    80002dde:	e822                	sd	s0,16(sp)
    80002de0:	e426                	sd	s1,8(sp)
    80002de2:	e04a                	sd	s2,0(sp)
    80002de4:	1000                	addi	s0,sp,32
    80002de6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002de8:	00d5d59b          	srliw	a1,a1,0xd
    80002dec:	0001b797          	auipc	a5,0x1b
    80002df0:	0d87a783          	lw	a5,216(a5) # 8001dec4 <sb+0x1c>
    80002df4:	9dbd                	addw	a1,a1,a5
    80002df6:	dedff0ef          	jal	80002be2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dfa:	0074f713          	andi	a4,s1,7
    80002dfe:	4785                	li	a5,1
    80002e00:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80002e04:	14ce                	slli	s1,s1,0x33
    80002e06:	90d9                	srli	s1,s1,0x36
    80002e08:	00950733          	add	a4,a0,s1
    80002e0c:	05874703          	lbu	a4,88(a4)
    80002e10:	00e7f6b3          	and	a3,a5,a4
    80002e14:	c29d                	beqz	a3,80002e3a <bfree+0x60>
    80002e16:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e18:	94aa                	add	s1,s1,a0
    80002e1a:	fff7c793          	not	a5,a5
    80002e1e:	8f7d                	and	a4,a4,a5
    80002e20:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e24:	078010ef          	jal	80003e9c <log_write>
  brelse(bp);
    80002e28:	854a                	mv	a0,s2
    80002e2a:	ec1ff0ef          	jal	80002cea <brelse>
}
    80002e2e:	60e2                	ld	ra,24(sp)
    80002e30:	6442                	ld	s0,16(sp)
    80002e32:	64a2                	ld	s1,8(sp)
    80002e34:	6902                	ld	s2,0(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret
    panic("freeing free block");
    80002e3a:	00004517          	auipc	a0,0x4
    80002e3e:	5ae50513          	addi	a0,a0,1454 # 800073e8 <etext+0x3e8>
    80002e42:	9affd0ef          	jal	800007f0 <panic>

0000000080002e46 <balloc>:
{
    80002e46:	711d                	addi	sp,sp,-96
    80002e48:	ec86                	sd	ra,88(sp)
    80002e4a:	e8a2                	sd	s0,80(sp)
    80002e4c:	e4a6                	sd	s1,72(sp)
    80002e4e:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80002e50:	0001b797          	auipc	a5,0x1b
    80002e54:	05c7a783          	lw	a5,92(a5) # 8001deac <sb+0x4>
    80002e58:	0e078f63          	beqz	a5,80002f56 <balloc+0x110>
    80002e5c:	e0ca                	sd	s2,64(sp)
    80002e5e:	fc4e                	sd	s3,56(sp)
    80002e60:	f852                	sd	s4,48(sp)
    80002e62:	f456                	sd	s5,40(sp)
    80002e64:	f05a                	sd	s6,32(sp)
    80002e66:	ec5e                	sd	s7,24(sp)
    80002e68:	e862                	sd	s8,16(sp)
    80002e6a:	e466                	sd	s9,8(sp)
    80002e6c:	8baa                	mv	s7,a0
    80002e6e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e70:	0001bb17          	auipc	s6,0x1b
    80002e74:	038b0b13          	addi	s6,s6,56 # 8001dea8 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e78:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e7a:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e7c:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e7e:	6c89                	lui	s9,0x2
    80002e80:	a0b5                	j	80002eec <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e82:	97ca                	add	a5,a5,s2
    80002e84:	8e55                	or	a2,a2,a3
    80002e86:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	010010ef          	jal	80003e9c <log_write>
        brelse(bp);
    80002e90:	854a                	mv	a0,s2
    80002e92:	e59ff0ef          	jal	80002cea <brelse>
  bp = bread(dev, bno);
    80002e96:	85a6                	mv	a1,s1
    80002e98:	855e                	mv	a0,s7
    80002e9a:	d49ff0ef          	jal	80002be2 <bread>
    80002e9e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ea0:	40000613          	li	a2,1024
    80002ea4:	4581                	li	a1,0
    80002ea6:	05850513          	addi	a0,a0,88
    80002eaa:	dabfd0ef          	jal	80000c54 <memset>
  log_write(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	7ed000ef          	jal	80003e9c <log_write>
  brelse(bp);
    80002eb4:	854a                	mv	a0,s2
    80002eb6:	e35ff0ef          	jal	80002cea <brelse>
}
    80002eba:	6906                	ld	s2,64(sp)
    80002ebc:	79e2                	ld	s3,56(sp)
    80002ebe:	7a42                	ld	s4,48(sp)
    80002ec0:	7aa2                	ld	s5,40(sp)
    80002ec2:	7b02                	ld	s6,32(sp)
    80002ec4:	6be2                	ld	s7,24(sp)
    80002ec6:	6c42                	ld	s8,16(sp)
    80002ec8:	6ca2                	ld	s9,8(sp)
}
    80002eca:	8526                	mv	a0,s1
    80002ecc:	60e6                	ld	ra,88(sp)
    80002ece:	6446                	ld	s0,80(sp)
    80002ed0:	64a6                	ld	s1,72(sp)
    80002ed2:	6125                	addi	sp,sp,96
    80002ed4:	8082                	ret
    brelse(bp);
    80002ed6:	854a                	mv	a0,s2
    80002ed8:	e13ff0ef          	jal	80002cea <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002edc:	015c87bb          	addw	a5,s9,s5
    80002ee0:	00078a9b          	sext.w	s5,a5
    80002ee4:	004b2703          	lw	a4,4(s6)
    80002ee8:	04eaff63          	bgeu	s5,a4,80002f46 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002eec:	41fad79b          	sraiw	a5,s5,0x1f
    80002ef0:	0137d79b          	srliw	a5,a5,0x13
    80002ef4:	015787bb          	addw	a5,a5,s5
    80002ef8:	40d7d79b          	sraiw	a5,a5,0xd
    80002efc:	01cb2583          	lw	a1,28(s6)
    80002f00:	9dbd                	addw	a1,a1,a5
    80002f02:	855e                	mv	a0,s7
    80002f04:	cdfff0ef          	jal	80002be2 <bread>
    80002f08:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f0a:	004b2503          	lw	a0,4(s6)
    80002f0e:	000a849b          	sext.w	s1,s5
    80002f12:	8762                	mv	a4,s8
    80002f14:	fca4f1e3          	bgeu	s1,a0,80002ed6 <balloc+0x90>
      m = 1 << (bi % 8);
    80002f18:	00777693          	andi	a3,a4,7
    80002f1c:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002f20:	41f7579b          	sraiw	a5,a4,0x1f
    80002f24:	01d7d79b          	srliw	a5,a5,0x1d
    80002f28:	9fb9                	addw	a5,a5,a4
    80002f2a:	4037d79b          	sraiw	a5,a5,0x3
    80002f2e:	00f90633          	add	a2,s2,a5
    80002f32:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f36:	00c6f5b3          	and	a1,a3,a2
    80002f3a:	d5a1                	beqz	a1,80002e82 <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f3c:	2705                	addiw	a4,a4,1
    80002f3e:	2485                	addiw	s1,s1,1
    80002f40:	fd471ae3          	bne	a4,s4,80002f14 <balloc+0xce>
    80002f44:	bf49                	j	80002ed6 <balloc+0x90>
    80002f46:	6906                	ld	s2,64(sp)
    80002f48:	79e2                	ld	s3,56(sp)
    80002f4a:	7a42                	ld	s4,48(sp)
    80002f4c:	7aa2                	ld	s5,40(sp)
    80002f4e:	7b02                	ld	s6,32(sp)
    80002f50:	6be2                	ld	s7,24(sp)
    80002f52:	6c42                	ld	s8,16(sp)
    80002f54:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80002f56:	00004517          	auipc	a0,0x4
    80002f5a:	4aa50513          	addi	a0,a0,1194 # 80007400 <etext+0x400>
    80002f5e:	dacfd0ef          	jal	8000050a <printk>
  return 0;
    80002f62:	4481                	li	s1,0
    80002f64:	b79d                	j	80002eca <balloc+0x84>

0000000080002f66 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f66:	7179                	addi	sp,sp,-48
    80002f68:	f406                	sd	ra,40(sp)
    80002f6a:	f022                	sd	s0,32(sp)
    80002f6c:	ec26                	sd	s1,24(sp)
    80002f6e:	e84a                	sd	s2,16(sp)
    80002f70:	e44e                	sd	s3,8(sp)
    80002f72:	1800                	addi	s0,sp,48
    80002f74:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f76:	47ad                	li	a5,11
    80002f78:	02b7e663          	bltu	a5,a1,80002fa4 <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f7c:	02059793          	slli	a5,a1,0x20
    80002f80:	01e7d593          	srli	a1,a5,0x1e
    80002f84:	00b504b3          	add	s1,a0,a1
    80002f88:	0504a903          	lw	s2,80(s1)
    80002f8c:	06091a63          	bnez	s2,80003000 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f90:	4108                	lw	a0,0(a0)
    80002f92:	eb5ff0ef          	jal	80002e46 <balloc>
    80002f96:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002f9a:	06090363          	beqz	s2,80003000 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f9e:	0524a823          	sw	s2,80(s1)
    80002fa2:	a8b9                	j	80003000 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fa4:	ff45849b          	addiw	s1,a1,-12
    80002fa8:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    80002fac:	0ff00793          	li	a5,255
    80002fb0:	06e7ee63          	bltu	a5,a4,8000302c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002fb4:	08052903          	lw	s2,128(a0)
    80002fb8:	00091d63          	bnez	s2,80002fd2 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002fbc:	4108                	lw	a0,0(a0)
    80002fbe:	e89ff0ef          	jal	80002e46 <balloc>
    80002fc2:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002fc6:	02090d63          	beqz	s2,80003000 <bmap+0x9a>
    80002fca:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fcc:	0929a023          	sw	s2,128(s3)
    80002fd0:	a011                	j	80002fd4 <bmap+0x6e>
    80002fd2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fd4:	85ca                	mv	a1,s2
    80002fd6:	0009a503          	lw	a0,0(s3)
    80002fda:	c09ff0ef          	jal	80002be2 <bread>
    80002fde:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002fe0:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002fe4:	02049713          	slli	a4,s1,0x20
    80002fe8:	01e75593          	srli	a1,a4,0x1e
    80002fec:	00b784b3          	add	s1,a5,a1
    80002ff0:	0004a903          	lw	s2,0(s1)
    80002ff4:	00090e63          	beqz	s2,80003010 <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ff8:	8552                	mv	a0,s4
    80002ffa:	cf1ff0ef          	jal	80002cea <brelse>
    return addr;
    80002ffe:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003000:	854a                	mv	a0,s2
    80003002:	70a2                	ld	ra,40(sp)
    80003004:	7402                	ld	s0,32(sp)
    80003006:	64e2                	ld	s1,24(sp)
    80003008:	6942                	ld	s2,16(sp)
    8000300a:	69a2                	ld	s3,8(sp)
    8000300c:	6145                	addi	sp,sp,48
    8000300e:	8082                	ret
      addr = balloc(ip->dev);
    80003010:	0009a503          	lw	a0,0(s3)
    80003014:	e33ff0ef          	jal	80002e46 <balloc>
    80003018:	0005091b          	sext.w	s2,a0
      if (addr) {
    8000301c:	fc090ee3          	beqz	s2,80002ff8 <bmap+0x92>
        a[bn] = addr;
    80003020:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003024:	8552                	mv	a0,s4
    80003026:	677000ef          	jal	80003e9c <log_write>
    8000302a:	b7f9                	j	80002ff8 <bmap+0x92>
    8000302c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000302e:	00004517          	auipc	a0,0x4
    80003032:	3ea50513          	addi	a0,a0,1002 # 80007418 <etext+0x418>
    80003036:	fbafd0ef          	jal	800007f0 <panic>

000000008000303a <iget>:
{
    8000303a:	7179                	addi	sp,sp,-48
    8000303c:	f406                	sd	ra,40(sp)
    8000303e:	f022                	sd	s0,32(sp)
    80003040:	ec26                	sd	s1,24(sp)
    80003042:	e84a                	sd	s2,16(sp)
    80003044:	e44e                	sd	s3,8(sp)
    80003046:	e052                	sd	s4,0(sp)
    80003048:	1800                	addi	s0,sp,48
    8000304a:	89aa                	mv	s3,a0
    8000304c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000304e:	0001b517          	auipc	a0,0x1b
    80003052:	e7a50513          	addi	a0,a0,-390 # 8001dec8 <itable>
    80003056:	b3bfd0ef          	jal	80000b90 <acquire>
  empty = 0;
    8000305a:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000305c:	0001b497          	auipc	s1,0x1b
    80003060:	e8448493          	addi	s1,s1,-380 # 8001dee0 <itable+0x18>
    80003064:	0001d697          	auipc	a3,0x1d
    80003068:	90c68693          	addi	a3,a3,-1780 # 8001f970 <log>
    8000306c:	a039                	j	8000307a <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000306e:	02090963          	beqz	s2,800030a0 <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003072:	08848493          	addi	s1,s1,136
    80003076:	02d48863          	beq	s1,a3,800030a6 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000307a:	449c                	lw	a5,8(s1)
    8000307c:	fef059e3          	blez	a5,8000306e <iget+0x34>
    80003080:	4098                	lw	a4,0(s1)
    80003082:	ff3716e3          	bne	a4,s3,8000306e <iget+0x34>
    80003086:	40d8                	lw	a4,4(s1)
    80003088:	ff4713e3          	bne	a4,s4,8000306e <iget+0x34>
      ip->ref++;
    8000308c:	2785                	addiw	a5,a5,1
    8000308e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003090:	0001b517          	auipc	a0,0x1b
    80003094:	e3850513          	addi	a0,a0,-456 # 8001dec8 <itable>
    80003098:	b85fd0ef          	jal	80000c1c <release>
      return ip;
    8000309c:	8926                	mv	s2,s1
    8000309e:	a02d                	j	800030c8 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800030a0:	fbe9                	bnez	a5,80003072 <iget+0x38>
      empty = ip;
    800030a2:	8926                	mv	s2,s1
    800030a4:	b7f9                	j	80003072 <iget+0x38>
  if (empty == 0)
    800030a6:	02090a63          	beqz	s2,800030da <iget+0xa0>
  ip->dev = dev;
    800030aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030b2:	4785                	li	a5,1
    800030b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030bc:	0001b517          	auipc	a0,0x1b
    800030c0:	e0c50513          	addi	a0,a0,-500 # 8001dec8 <itable>
    800030c4:	b59fd0ef          	jal	80000c1c <release>
}
    800030c8:	854a                	mv	a0,s2
    800030ca:	70a2                	ld	ra,40(sp)
    800030cc:	7402                	ld	s0,32(sp)
    800030ce:	64e2                	ld	s1,24(sp)
    800030d0:	6942                	ld	s2,16(sp)
    800030d2:	69a2                	ld	s3,8(sp)
    800030d4:	6a02                	ld	s4,0(sp)
    800030d6:	6145                	addi	sp,sp,48
    800030d8:	8082                	ret
    panic("iget: no inodes");
    800030da:	00004517          	auipc	a0,0x4
    800030de:	35650513          	addi	a0,a0,854 # 80007430 <etext+0x430>
    800030e2:	f0efd0ef          	jal	800007f0 <panic>

00000000800030e6 <iinit>:
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	e44e                	sd	s3,8(sp)
    800030f2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030f4:	00004597          	auipc	a1,0x4
    800030f8:	34c58593          	addi	a1,a1,844 # 80007440 <etext+0x440>
    800030fc:	0001b517          	auipc	a0,0x1b
    80003100:	dcc50513          	addi	a0,a0,-564 # 8001dec8 <itable>
    80003104:	a17fd0ef          	jal	80000b1a <initlock>
  for (i = 0; i < NINODE; i++) {
    80003108:	0001b497          	auipc	s1,0x1b
    8000310c:	de848493          	addi	s1,s1,-536 # 8001def0 <itable+0x28>
    80003110:	0001d997          	auipc	s3,0x1d
    80003114:	87098993          	addi	s3,s3,-1936 # 8001f980 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003118:	00004917          	auipc	s2,0x4
    8000311c:	33090913          	addi	s2,s2,816 # 80007448 <etext+0x448>
    80003120:	85ca                	mv	a1,s2
    80003122:	8526                	mv	a0,s1
    80003124:	6ab000ef          	jal	80003fce <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003128:	08848493          	addi	s1,s1,136
    8000312c:	ff349ae3          	bne	s1,s3,80003120 <iinit+0x3a>
}
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6145                	addi	sp,sp,48
    8000313c:	8082                	ret

000000008000313e <ialloc>:
{
    8000313e:	7139                	addi	sp,sp,-64
    80003140:	fc06                	sd	ra,56(sp)
    80003142:	f822                	sd	s0,48(sp)
    80003144:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003146:	0001b717          	auipc	a4,0x1b
    8000314a:	d6e72703          	lw	a4,-658(a4) # 8001deb4 <sb+0xc>
    8000314e:	4785                	li	a5,1
    80003150:	06e7f063          	bgeu	a5,a4,800031b0 <ialloc+0x72>
    80003154:	f426                	sd	s1,40(sp)
    80003156:	f04a                	sd	s2,32(sp)
    80003158:	ec4e                	sd	s3,24(sp)
    8000315a:	e852                	sd	s4,16(sp)
    8000315c:	e456                	sd	s5,8(sp)
    8000315e:	e05a                	sd	s6,0(sp)
    80003160:	8aaa                	mv	s5,a0
    80003162:	8b2e                	mv	s6,a1
    80003164:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003166:	0001ba17          	auipc	s4,0x1b
    8000316a:	d42a0a13          	addi	s4,s4,-702 # 8001dea8 <sb>
    8000316e:	00495593          	srli	a1,s2,0x4
    80003172:	018a2783          	lw	a5,24(s4)
    80003176:	9dbd                	addw	a1,a1,a5
    80003178:	8556                	mv	a0,s5
    8000317a:	a69ff0ef          	jal	80002be2 <bread>
    8000317e:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003180:	05850993          	addi	s3,a0,88
    80003184:	00f97793          	andi	a5,s2,15
    80003188:	079a                	slli	a5,a5,0x6
    8000318a:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000318c:	00099783          	lh	a5,0(s3)
    80003190:	cb9d                	beqz	a5,800031c6 <ialloc+0x88>
    brelse(bp);
    80003192:	b59ff0ef          	jal	80002cea <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003196:	0905                	addi	s2,s2,1
    80003198:	00ca2703          	lw	a4,12(s4)
    8000319c:	0009079b          	sext.w	a5,s2
    800031a0:	fce7e7e3          	bltu	a5,a4,8000316e <ialloc+0x30>
    800031a4:	74a2                	ld	s1,40(sp)
    800031a6:	7902                	ld	s2,32(sp)
    800031a8:	69e2                	ld	s3,24(sp)
    800031aa:	6a42                	ld	s4,16(sp)
    800031ac:	6aa2                	ld	s5,8(sp)
    800031ae:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800031b0:	00004517          	auipc	a0,0x4
    800031b4:	2a050513          	addi	a0,a0,672 # 80007450 <etext+0x450>
    800031b8:	b52fd0ef          	jal	8000050a <printk>
  return 0;
    800031bc:	4501                	li	a0,0
}
    800031be:	70e2                	ld	ra,56(sp)
    800031c0:	7442                	ld	s0,48(sp)
    800031c2:	6121                	addi	sp,sp,64
    800031c4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031c6:	04000613          	li	a2,64
    800031ca:	4581                	li	a1,0
    800031cc:	854e                	mv	a0,s3
    800031ce:	a87fd0ef          	jal	80000c54 <memset>
      dip->type = type;
    800031d2:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800031d6:	8526                	mv	a0,s1
    800031d8:	4c5000ef          	jal	80003e9c <log_write>
      brelse(bp);
    800031dc:	8526                	mv	a0,s1
    800031de:	b0dff0ef          	jal	80002cea <brelse>
      return iget(dev, inum);
    800031e2:	0009059b          	sext.w	a1,s2
    800031e6:	8556                	mv	a0,s5
    800031e8:	e53ff0ef          	jal	8000303a <iget>
    800031ec:	74a2                	ld	s1,40(sp)
    800031ee:	7902                	ld	s2,32(sp)
    800031f0:	69e2                	ld	s3,24(sp)
    800031f2:	6a42                	ld	s4,16(sp)
    800031f4:	6aa2                	ld	s5,8(sp)
    800031f6:	6b02                	ld	s6,0(sp)
    800031f8:	b7d9                	j	800031be <ialloc+0x80>

00000000800031fa <iupdate>:
{
    800031fa:	1101                	addi	sp,sp,-32
    800031fc:	ec06                	sd	ra,24(sp)
    800031fe:	e822                	sd	s0,16(sp)
    80003200:	e426                	sd	s1,8(sp)
    80003202:	e04a                	sd	s2,0(sp)
    80003204:	1000                	addi	s0,sp,32
    80003206:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003208:	415c                	lw	a5,4(a0)
    8000320a:	0047d79b          	srliw	a5,a5,0x4
    8000320e:	0001b597          	auipc	a1,0x1b
    80003212:	cb25a583          	lw	a1,-846(a1) # 8001dec0 <sb+0x18>
    80003216:	9dbd                	addw	a1,a1,a5
    80003218:	4108                	lw	a0,0(a0)
    8000321a:	9c9ff0ef          	jal	80002be2 <bread>
    8000321e:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003220:	05850793          	addi	a5,a0,88
    80003224:	40d8                	lw	a4,4(s1)
    80003226:	8b3d                	andi	a4,a4,15
    80003228:	071a                	slli	a4,a4,0x6
    8000322a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000322c:	04449703          	lh	a4,68(s1)
    80003230:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003234:	04649703          	lh	a4,70(s1)
    80003238:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000323c:	04849703          	lh	a4,72(s1)
    80003240:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003244:	04a49703          	lh	a4,74(s1)
    80003248:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000324c:	44f8                	lw	a4,76(s1)
    8000324e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003250:	03400613          	li	a2,52
    80003254:	05048593          	addi	a1,s1,80
    80003258:	00c78513          	addi	a0,a5,12
    8000325c:	a55fd0ef          	jal	80000cb0 <memmove>
  log_write(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	43b000ef          	jal	80003e9c <log_write>
  brelse(bp);
    80003266:	854a                	mv	a0,s2
    80003268:	a83ff0ef          	jal	80002cea <brelse>
}
    8000326c:	60e2                	ld	ra,24(sp)
    8000326e:	6442                	ld	s0,16(sp)
    80003270:	64a2                	ld	s1,8(sp)
    80003272:	6902                	ld	s2,0(sp)
    80003274:	6105                	addi	sp,sp,32
    80003276:	8082                	ret

0000000080003278 <idup>:
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	e426                	sd	s1,8(sp)
    80003280:	1000                	addi	s0,sp,32
    80003282:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003284:	0001b517          	auipc	a0,0x1b
    80003288:	c4450513          	addi	a0,a0,-956 # 8001dec8 <itable>
    8000328c:	905fd0ef          	jal	80000b90 <acquire>
  ip->ref++;
    80003290:	449c                	lw	a5,8(s1)
    80003292:	2785                	addiw	a5,a5,1
    80003294:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003296:	0001b517          	auipc	a0,0x1b
    8000329a:	c3250513          	addi	a0,a0,-974 # 8001dec8 <itable>
    8000329e:	97ffd0ef          	jal	80000c1c <release>
}
    800032a2:	8526                	mv	a0,s1
    800032a4:	60e2                	ld	ra,24(sp)
    800032a6:	6442                	ld	s0,16(sp)
    800032a8:	64a2                	ld	s1,8(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret

00000000800032ae <ilock>:
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800032b8:	cd19                	beqz	a0,800032d6 <ilock+0x28>
    800032ba:	84aa                	mv	s1,a0
    800032bc:	451c                	lw	a5,8(a0)
    800032be:	00f05c63          	blez	a5,800032d6 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032c2:	0541                	addi	a0,a0,16
    800032c4:	541000ef          	jal	80004004 <acquiresleep>
  if (ip->valid == 0) {
    800032c8:	40bc                	lw	a5,64(s1)
    800032ca:	cf89                	beqz	a5,800032e4 <ilock+0x36>
}
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    800032d6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032d8:	00004517          	auipc	a0,0x4
    800032dc:	19050513          	addi	a0,a0,400 # 80007468 <etext+0x468>
    800032e0:	d10fd0ef          	jal	800007f0 <panic>
    800032e4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e6:	40dc                	lw	a5,4(s1)
    800032e8:	0047d79b          	srliw	a5,a5,0x4
    800032ec:	0001b597          	auipc	a1,0x1b
    800032f0:	bd45a583          	lw	a1,-1068(a1) # 8001dec0 <sb+0x18>
    800032f4:	9dbd                	addw	a1,a1,a5
    800032f6:	4088                	lw	a0,0(s1)
    800032f8:	8ebff0ef          	jal	80002be2 <bread>
    800032fc:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032fe:	05850593          	addi	a1,a0,88
    80003302:	40dc                	lw	a5,4(s1)
    80003304:	8bbd                	andi	a5,a5,15
    80003306:	079a                	slli	a5,a5,0x6
    80003308:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000330a:	00059783          	lh	a5,0(a1)
    8000330e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003312:	00259783          	lh	a5,2(a1)
    80003316:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000331a:	00459783          	lh	a5,4(a1)
    8000331e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003322:	00659783          	lh	a5,6(a1)
    80003326:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000332a:	459c                	lw	a5,8(a1)
    8000332c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000332e:	03400613          	li	a2,52
    80003332:	05b1                	addi	a1,a1,12
    80003334:	05048513          	addi	a0,s1,80
    80003338:	979fd0ef          	jal	80000cb0 <memmove>
    brelse(bp);
    8000333c:	854a                	mv	a0,s2
    8000333e:	9adff0ef          	jal	80002cea <brelse>
    ip->valid = 1;
    80003342:	4785                	li	a5,1
    80003344:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003346:	04449783          	lh	a5,68(s1)
    8000334a:	c399                	beqz	a5,80003350 <ilock+0xa2>
    8000334c:	6902                	ld	s2,0(sp)
    8000334e:	bfbd                	j	800032cc <ilock+0x1e>
      panic("ilock: no type");
    80003350:	00004517          	auipc	a0,0x4
    80003354:	12050513          	addi	a0,a0,288 # 80007470 <etext+0x470>
    80003358:	c98fd0ef          	jal	800007f0 <panic>

000000008000335c <iunlock>:
{
    8000335c:	1101                	addi	sp,sp,-32
    8000335e:	ec06                	sd	ra,24(sp)
    80003360:	e822                	sd	s0,16(sp)
    80003362:	e426                	sd	s1,8(sp)
    80003364:	e04a                	sd	s2,0(sp)
    80003366:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003368:	c505                	beqz	a0,80003390 <iunlock+0x34>
    8000336a:	84aa                	mv	s1,a0
    8000336c:	01050913          	addi	s2,a0,16
    80003370:	854a                	mv	a0,s2
    80003372:	51f000ef          	jal	80004090 <holdingsleep>
    80003376:	cd09                	beqz	a0,80003390 <iunlock+0x34>
    80003378:	449c                	lw	a5,8(s1)
    8000337a:	00f05b63          	blez	a5,80003390 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000337e:	854a                	mv	a0,s2
    80003380:	4d9000ef          	jal	80004058 <releasesleep>
}
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	64a2                	ld	s1,8(sp)
    8000338a:	6902                	ld	s2,0(sp)
    8000338c:	6105                	addi	sp,sp,32
    8000338e:	8082                	ret
    panic("iunlock");
    80003390:	00004517          	auipc	a0,0x4
    80003394:	0f050513          	addi	a0,a0,240 # 80007480 <etext+0x480>
    80003398:	c58fd0ef          	jal	800007f0 <panic>

000000008000339c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	1800                	addi	s0,sp,48
    800033aa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800033ac:	05050493          	addi	s1,a0,80
    800033b0:	08050913          	addi	s2,a0,128
    800033b4:	a021                	j	800033bc <itrunc+0x20>
    800033b6:	0491                	addi	s1,s1,4
    800033b8:	01248b63          	beq	s1,s2,800033ce <itrunc+0x32>
    if (ip->addrs[i]) {
    800033bc:	408c                	lw	a1,0(s1)
    800033be:	dde5                	beqz	a1,800033b6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033c0:	0009a503          	lw	a0,0(s3)
    800033c4:	a17ff0ef          	jal	80002dda <bfree>
      ip->addrs[i] = 0;
    800033c8:	0004a023          	sw	zero,0(s1)
    800033cc:	b7ed                	j	800033b6 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800033ce:	0809a583          	lw	a1,128(s3)
    800033d2:	ed89                	bnez	a1,800033ec <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033d4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033d8:	854e                	mv	a0,s3
    800033da:	e21ff0ef          	jal	800031fa <iupdate>
}
    800033de:	70a2                	ld	ra,40(sp)
    800033e0:	7402                	ld	s0,32(sp)
    800033e2:	64e2                	ld	s1,24(sp)
    800033e4:	6942                	ld	s2,16(sp)
    800033e6:	69a2                	ld	s3,8(sp)
    800033e8:	6145                	addi	sp,sp,48
    800033ea:	8082                	ret
    800033ec:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033ee:	0009a503          	lw	a0,0(s3)
    800033f2:	ff0ff0ef          	jal	80002be2 <bread>
    800033f6:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800033f8:	05850493          	addi	s1,a0,88
    800033fc:	45850913          	addi	s2,a0,1112
    80003400:	a021                	j	80003408 <itrunc+0x6c>
    80003402:	0491                	addi	s1,s1,4
    80003404:	01248963          	beq	s1,s2,80003416 <itrunc+0x7a>
      if (a[j])
    80003408:	408c                	lw	a1,0(s1)
    8000340a:	dde5                	beqz	a1,80003402 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000340c:	0009a503          	lw	a0,0(s3)
    80003410:	9cbff0ef          	jal	80002dda <bfree>
    80003414:	b7fd                	j	80003402 <itrunc+0x66>
    brelse(bp);
    80003416:	8552                	mv	a0,s4
    80003418:	8d3ff0ef          	jal	80002cea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000341c:	0809a583          	lw	a1,128(s3)
    80003420:	0009a503          	lw	a0,0(s3)
    80003424:	9b7ff0ef          	jal	80002dda <bfree>
    ip->addrs[NDIRECT] = 0;
    80003428:	0809a023          	sw	zero,128(s3)
    8000342c:	6a02                	ld	s4,0(sp)
    8000342e:	b75d                	j	800033d4 <itrunc+0x38>

0000000080003430 <iput>:
{
    80003430:	7179                	addi	sp,sp,-48
    80003432:	f406                	sd	ra,40(sp)
    80003434:	f022                	sd	s0,32(sp)
    80003436:	ec26                	sd	s1,24(sp)
    80003438:	1800                	addi	s0,sp,48
    8000343a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000343c:	0001b517          	auipc	a0,0x1b
    80003440:	a8c50513          	addi	a0,a0,-1396 # 8001dec8 <itable>
    80003444:	f4cfd0ef          	jal	80000b90 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003448:	449c                	lw	a5,8(s1)
    8000344a:	4705                	li	a4,1
    8000344c:	00e78f63          	beq	a5,a4,8000346a <iput+0x3a>
  ip->ref--;
    80003450:	37fd                	addiw	a5,a5,-1
    80003452:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003454:	0001b517          	auipc	a0,0x1b
    80003458:	a7450513          	addi	a0,a0,-1420 # 8001dec8 <itable>
    8000345c:	fc0fd0ef          	jal	80000c1c <release>
}
    80003460:	70a2                	ld	ra,40(sp)
    80003462:	7402                	ld	s0,32(sp)
    80003464:	64e2                	ld	s1,24(sp)
    80003466:	6145                	addi	sp,sp,48
    80003468:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000346a:	40b8                	lw	a4,64(s1)
    8000346c:	d375                	beqz	a4,80003450 <iput+0x20>
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003472:	0004aa03          	lw	s4,0(s1)
    80003476:	0044a903          	lw	s2,4(s1)
  if (last) {
    8000347a:	04a49703          	lh	a4,74(s1)
    8000347e:	ef35                	bnez	a4,800034fa <iput+0xca>
    80003480:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003482:	01048993          	addi	s3,s1,16
    80003486:	854e                	mv	a0,s3
    80003488:	37d000ef          	jal	80004004 <acquiresleep>
    release(&itable.lock);
    8000348c:	0001b517          	auipc	a0,0x1b
    80003490:	a3c50513          	addi	a0,a0,-1476 # 8001dec8 <itable>
    80003494:	f88fd0ef          	jal	80000c1c <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003498:	8526                	mv	a0,s1
    8000349a:	f03ff0ef          	jal	8000339c <itrunc>
    ip->valid = 0;
    8000349e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034a2:	854e                	mv	a0,s3
    800034a4:	3b5000ef          	jal	80004058 <releasesleep>
    acquire(&itable.lock);
    800034a8:	0001b517          	auipc	a0,0x1b
    800034ac:	a2050513          	addi	a0,a0,-1504 # 8001dec8 <itable>
    800034b0:	ee0fd0ef          	jal	80000b90 <acquire>
  ip->ref--;
    800034b4:	449c                	lw	a5,8(s1)
    800034b6:	37fd                	addiw	a5,a5,-1
    800034b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034ba:	0001b517          	auipc	a0,0x1b
    800034be:	a0e50513          	addi	a0,a0,-1522 # 8001dec8 <itable>
    800034c2:	f5afd0ef          	jal	80000c1c <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034c6:	0049559b          	srliw	a1,s2,0x4
    800034ca:	0001b797          	auipc	a5,0x1b
    800034ce:	9f67a783          	lw	a5,-1546(a5) # 8001dec0 <sb+0x18>
    800034d2:	9dbd                	addw	a1,a1,a5
    800034d4:	8552                	mv	a0,s4
    800034d6:	f0cff0ef          	jal	80002be2 <bread>
    800034da:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034dc:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    800034e0:	091a                	slli	s2,s2,0x6
    800034e2:	992a                	add	s2,s2,a0
    800034e4:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    800034e8:	1b5000ef          	jal	80003e9c <log_write>
  brelse(bp);
    800034ec:	8526                	mv	a0,s1
    800034ee:	ffcff0ef          	jal	80002cea <brelse>
}
    800034f2:	6942                	ld	s2,16(sp)
    800034f4:	69a2                	ld	s3,8(sp)
    800034f6:	6a02                	ld	s4,0(sp)
    800034f8:	b7a5                	j	80003460 <iput+0x30>
    800034fa:	6942                	ld	s2,16(sp)
    800034fc:	6a02                	ld	s4,0(sp)
    800034fe:	bf89                	j	80003450 <iput+0x20>

0000000080003500 <iunlockput>:
{
    80003500:	1101                	addi	sp,sp,-32
    80003502:	ec06                	sd	ra,24(sp)
    80003504:	e822                	sd	s0,16(sp)
    80003506:	e426                	sd	s1,8(sp)
    80003508:	1000                	addi	s0,sp,32
    8000350a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000350c:	e51ff0ef          	jal	8000335c <iunlock>
  iput(ip);
    80003510:	8526                	mv	a0,s1
    80003512:	f1fff0ef          	jal	80003430 <iput>
}
    80003516:	60e2                	ld	ra,24(sp)
    80003518:	6442                	ld	s0,16(sp)
    8000351a:	64a2                	ld	s1,8(sp)
    8000351c:	6105                	addi	sp,sp,32
    8000351e:	8082                	ret

0000000080003520 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003520:	0001b717          	auipc	a4,0x1b
    80003524:	99472703          	lw	a4,-1644(a4) # 8001deb4 <sb+0xc>
    80003528:	4785                	li	a5,1
    8000352a:	0ae7ff63          	bgeu	a5,a4,800035e8 <ireclaim+0xc8>
{
    8000352e:	7139                	addi	sp,sp,-64
    80003530:	fc06                	sd	ra,56(sp)
    80003532:	f822                	sd	s0,48(sp)
    80003534:	f426                	sd	s1,40(sp)
    80003536:	f04a                	sd	s2,32(sp)
    80003538:	ec4e                	sd	s3,24(sp)
    8000353a:	e852                	sd	s4,16(sp)
    8000353c:	e456                	sd	s5,8(sp)
    8000353e:	e05a                	sd	s6,0(sp)
    80003540:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003542:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003544:	00050a1b          	sext.w	s4,a0
    80003548:	0001ba97          	auipc	s5,0x1b
    8000354c:	960a8a93          	addi	s5,s5,-1696 # 8001dea8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003550:	00004b17          	auipc	s6,0x4
    80003554:	f38b0b13          	addi	s6,s6,-200 # 80007488 <etext+0x488>
    80003558:	a099                	j	8000359e <ireclaim+0x7e>
    8000355a:	85ce                	mv	a1,s3
    8000355c:	855a                	mv	a0,s6
    8000355e:	fadfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003562:	85ce                	mv	a1,s3
    80003564:	8552                	mv	a0,s4
    80003566:	ad5ff0ef          	jal	8000303a <iget>
    8000356a:	89aa                	mv	s3,a0
    brelse(bp);
    8000356c:	854a                	mv	a0,s2
    8000356e:	f7cff0ef          	jal	80002cea <brelse>
    if (ip) {
    80003572:	00098f63          	beqz	s3,80003590 <ireclaim+0x70>
      begin_op();
    80003576:	780000ef          	jal	80003cf6 <begin_op>
      ilock(ip);
    8000357a:	854e                	mv	a0,s3
    8000357c:	d33ff0ef          	jal	800032ae <ilock>
      iunlock(ip);
    80003580:	854e                	mv	a0,s3
    80003582:	ddbff0ef          	jal	8000335c <iunlock>
      iput(ip);
    80003586:	854e                	mv	a0,s3
    80003588:	ea9ff0ef          	jal	80003430 <iput>
      end_op();
    8000358c:	7f0000ef          	jal	80003d7c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003590:	0485                	addi	s1,s1,1
    80003592:	00caa703          	lw	a4,12(s5)
    80003596:	0004879b          	sext.w	a5,s1
    8000359a:	02e7fd63          	bgeu	a5,a4,800035d4 <ireclaim+0xb4>
    8000359e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035a2:	0044d593          	srli	a1,s1,0x4
    800035a6:	018aa783          	lw	a5,24(s5)
    800035aa:	9dbd                	addw	a1,a1,a5
    800035ac:	8552                	mv	a0,s4
    800035ae:	e34ff0ef          	jal	80002be2 <bread>
    800035b2:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035b4:	05850793          	addi	a5,a0,88
    800035b8:	00f9f713          	andi	a4,s3,15
    800035bc:	071a                	slli	a4,a4,0x6
    800035be:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800035c0:	00079703          	lh	a4,0(a5)
    800035c4:	c701                	beqz	a4,800035cc <ireclaim+0xac>
    800035c6:	00679783          	lh	a5,6(a5)
    800035ca:	dbc1                	beqz	a5,8000355a <ireclaim+0x3a>
    brelse(bp);
    800035cc:	854a                	mv	a0,s2
    800035ce:	f1cff0ef          	jal	80002cea <brelse>
    if (ip) {
    800035d2:	bf7d                	j	80003590 <ireclaim+0x70>
}
    800035d4:	70e2                	ld	ra,56(sp)
    800035d6:	7442                	ld	s0,48(sp)
    800035d8:	74a2                	ld	s1,40(sp)
    800035da:	7902                	ld	s2,32(sp)
    800035dc:	69e2                	ld	s3,24(sp)
    800035de:	6a42                	ld	s4,16(sp)
    800035e0:	6aa2                	ld	s5,8(sp)
    800035e2:	6b02                	ld	s6,0(sp)
    800035e4:	6121                	addi	sp,sp,64
    800035e6:	8082                	ret
    800035e8:	8082                	ret

00000000800035ea <fsinit>:
{
    800035ea:	7179                	addi	sp,sp,-48
    800035ec:	f406                	sd	ra,40(sp)
    800035ee:	f022                	sd	s0,32(sp)
    800035f0:	ec26                	sd	s1,24(sp)
    800035f2:	e84a                	sd	s2,16(sp)
    800035f4:	e44e                	sd	s3,8(sp)
    800035f6:	1800                	addi	s0,sp,48
    800035f8:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800035fa:	4585                	li	a1,1
    800035fc:	de6ff0ef          	jal	80002be2 <bread>
    80003600:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003602:	0001b997          	auipc	s3,0x1b
    80003606:	8a698993          	addi	s3,s3,-1882 # 8001dea8 <sb>
    8000360a:	02000613          	li	a2,32
    8000360e:	05850593          	addi	a1,a0,88
    80003612:	854e                	mv	a0,s3
    80003614:	e9cfd0ef          	jal	80000cb0 <memmove>
  brelse(bp);
    80003618:	854a                	mv	a0,s2
    8000361a:	ed0ff0ef          	jal	80002cea <brelse>
  if (sb.magic != FSMAGIC)
    8000361e:	0009a703          	lw	a4,0(s3)
    80003622:	102037b7          	lui	a5,0x10203
    80003626:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000362a:	02f71363          	bne	a4,a5,80003650 <fsinit+0x66>
  initlog(dev, &sb);
    8000362e:	0001b597          	auipc	a1,0x1b
    80003632:	87a58593          	addi	a1,a1,-1926 # 8001dea8 <sb>
    80003636:	8526                	mv	a0,s1
    80003638:	640000ef          	jal	80003c78 <initlog>
  ireclaim(dev);
    8000363c:	8526                	mv	a0,s1
    8000363e:	ee3ff0ef          	jal	80003520 <ireclaim>
}
    80003642:	70a2                	ld	ra,40(sp)
    80003644:	7402                	ld	s0,32(sp)
    80003646:	64e2                	ld	s1,24(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	69a2                	ld	s3,8(sp)
    8000364c:	6145                	addi	sp,sp,48
    8000364e:	8082                	ret
    panic("invalid file system");
    80003650:	00004517          	auipc	a0,0x4
    80003654:	e5850513          	addi	a0,a0,-424 # 800074a8 <etext+0x4a8>
    80003658:	998fd0ef          	jal	800007f0 <panic>

000000008000365c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000365c:	1141                	addi	sp,sp,-16
    8000365e:	e422                	sd	s0,8(sp)
    80003660:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003662:	411c                	lw	a5,0(a0)
    80003664:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003666:	415c                	lw	a5,4(a0)
    80003668:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000366a:	04451783          	lh	a5,68(a0)
    8000366e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003672:	04a51783          	lh	a5,74(a0)
    80003676:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000367a:	04c56783          	lwu	a5,76(a0)
    8000367e:	e99c                	sd	a5,16(a1)
}
    80003680:	6422                	ld	s0,8(sp)
    80003682:	0141                	addi	sp,sp,16
    80003684:	8082                	ret

0000000080003686 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003686:	457c                	lw	a5,76(a0)
    80003688:	0ed7eb63          	bltu	a5,a3,8000377e <readi+0xf8>
{
    8000368c:	7159                	addi	sp,sp,-112
    8000368e:	f486                	sd	ra,104(sp)
    80003690:	f0a2                	sd	s0,96(sp)
    80003692:	eca6                	sd	s1,88(sp)
    80003694:	e0d2                	sd	s4,64(sp)
    80003696:	fc56                	sd	s5,56(sp)
    80003698:	f85a                	sd	s6,48(sp)
    8000369a:	f45e                	sd	s7,40(sp)
    8000369c:	1880                	addi	s0,sp,112
    8000369e:	8b2a                	mv	s6,a0
    800036a0:	8bae                	mv	s7,a1
    800036a2:	8a32                	mv	s4,a2
    800036a4:	84b6                	mv	s1,a3
    800036a6:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800036a8:	9f35                	addw	a4,a4,a3
    return 0;
    800036aa:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800036ac:	0cd76063          	bltu	a4,a3,8000376c <readi+0xe6>
    800036b0:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800036b2:	00e7f463          	bgeu	a5,a4,800036ba <readi+0x34>
    n = ip->size - off;
    800036b6:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036ba:	080a8f63          	beqz	s5,80003758 <readi+0xd2>
    800036be:	e8ca                	sd	s2,80(sp)
    800036c0:	f062                	sd	s8,32(sp)
    800036c2:	ec66                	sd	s9,24(sp)
    800036c4:	e86a                	sd	s10,16(sp)
    800036c6:	e46e                	sd	s11,8(sp)
    800036c8:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800036ca:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036ce:	5c7d                	li	s8,-1
    800036d0:	a80d                	j	80003702 <readi+0x7c>
    800036d2:	020d1d93          	slli	s11,s10,0x20
    800036d6:	020ddd93          	srli	s11,s11,0x20
    800036da:	05890613          	addi	a2,s2,88
    800036de:	86ee                	mv	a3,s11
    800036e0:	963a                	add	a2,a2,a4
    800036e2:	85d2                	mv	a1,s4
    800036e4:	855e                	mv	a0,s7
    800036e6:	b5ffe0ef          	jal	80002244 <either_copyout>
    800036ea:	05850763          	beq	a0,s8,80003738 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	dfaff0ef          	jal	80002cea <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036f4:	013d09bb          	addw	s3,s10,s3
    800036f8:	009d04bb          	addw	s1,s10,s1
    800036fc:	9a6e                	add	s4,s4,s11
    800036fe:	0559f763          	bgeu	s3,s5,8000374c <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    80003702:	00a4d59b          	srliw	a1,s1,0xa
    80003706:	855a                	mv	a0,s6
    80003708:	85fff0ef          	jal	80002f66 <bmap>
    8000370c:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003710:	c5b1                	beqz	a1,8000375c <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003712:	000b2503          	lw	a0,0(s6)
    80003716:	cccff0ef          	jal	80002be2 <bread>
    8000371a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000371c:	3ff4f713          	andi	a4,s1,1023
    80003720:	40ec87bb          	subw	a5,s9,a4
    80003724:	413a86bb          	subw	a3,s5,s3
    80003728:	8d3e                	mv	s10,a5
    8000372a:	2781                	sext.w	a5,a5
    8000372c:	0006861b          	sext.w	a2,a3
    80003730:	faf671e3          	bgeu	a2,a5,800036d2 <readi+0x4c>
    80003734:	8d36                	mv	s10,a3
    80003736:	bf71                	j	800036d2 <readi+0x4c>
      brelse(bp);
    80003738:	854a                	mv	a0,s2
    8000373a:	db0ff0ef          	jal	80002cea <brelse>
      tot = -1;
    8000373e:	59fd                	li	s3,-1
      break;
    80003740:	6946                	ld	s2,80(sp)
    80003742:	7c02                	ld	s8,32(sp)
    80003744:	6ce2                	ld	s9,24(sp)
    80003746:	6d42                	ld	s10,16(sp)
    80003748:	6da2                	ld	s11,8(sp)
    8000374a:	a831                	j	80003766 <readi+0xe0>
    8000374c:	6946                	ld	s2,80(sp)
    8000374e:	7c02                	ld	s8,32(sp)
    80003750:	6ce2                	ld	s9,24(sp)
    80003752:	6d42                	ld	s10,16(sp)
    80003754:	6da2                	ld	s11,8(sp)
    80003756:	a801                	j	80003766 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003758:	89d6                	mv	s3,s5
    8000375a:	a031                	j	80003766 <readi+0xe0>
    8000375c:	6946                	ld	s2,80(sp)
    8000375e:	7c02                	ld	s8,32(sp)
    80003760:	6ce2                	ld	s9,24(sp)
    80003762:	6d42                	ld	s10,16(sp)
    80003764:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003766:	0009851b          	sext.w	a0,s3
    8000376a:	69a6                	ld	s3,72(sp)
}
    8000376c:	70a6                	ld	ra,104(sp)
    8000376e:	7406                	ld	s0,96(sp)
    80003770:	64e6                	ld	s1,88(sp)
    80003772:	6a06                	ld	s4,64(sp)
    80003774:	7ae2                	ld	s5,56(sp)
    80003776:	7b42                	ld	s6,48(sp)
    80003778:	7ba2                	ld	s7,40(sp)
    8000377a:	6165                	addi	sp,sp,112
    8000377c:	8082                	ret
    return 0;
    8000377e:	4501                	li	a0,0
}
    80003780:	8082                	ret

0000000080003782 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003782:	457c                	lw	a5,76(a0)
    80003784:	10d7e363          	bltu	a5,a3,8000388a <writei+0x108>
{
    80003788:	7159                	addi	sp,sp,-112
    8000378a:	f486                	sd	ra,104(sp)
    8000378c:	f0a2                	sd	s0,96(sp)
    8000378e:	e8ca                	sd	s2,80(sp)
    80003790:	e0d2                	sd	s4,64(sp)
    80003792:	fc56                	sd	s5,56(sp)
    80003794:	f85a                	sd	s6,48(sp)
    80003796:	f45e                	sd	s7,40(sp)
    80003798:	1880                	addi	s0,sp,112
    8000379a:	8aaa                	mv	s5,a0
    8000379c:	8bae                	mv	s7,a1
    8000379e:	8a32                	mv	s4,a2
    800037a0:	8936                	mv	s2,a3
    800037a2:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800037a4:	00e687bb          	addw	a5,a3,a4
    800037a8:	0ed7e363          	bltu	a5,a3,8000388e <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800037ac:	00043737          	lui	a4,0x43
    800037b0:	0ef76163          	bltu	a4,a5,80003892 <writei+0x110>
    800037b4:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037b6:	0c0b0263          	beqz	s6,8000387a <writei+0xf8>
    800037ba:	eca6                	sd	s1,88(sp)
    800037bc:	f062                	sd	s8,32(sp)
    800037be:	ec66                	sd	s9,24(sp)
    800037c0:	e86a                	sd	s10,16(sp)
    800037c2:	e46e                	sd	s11,8(sp)
    800037c4:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037c6:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037ca:	5c7d                	li	s8,-1
    800037cc:	a825                	j	80003804 <writei+0x82>
    800037ce:	020d1d93          	slli	s11,s10,0x20
    800037d2:	020ddd93          	srli	s11,s11,0x20
    800037d6:	05848513          	addi	a0,s1,88
    800037da:	86ee                	mv	a3,s11
    800037dc:	8652                	mv	a2,s4
    800037de:	85de                	mv	a1,s7
    800037e0:	953a                	add	a0,a0,a4
    800037e2:	aaffe0ef          	jal	80002290 <either_copyin>
    800037e6:	05850a63          	beq	a0,s8,8000383a <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800037ea:	8526                	mv	a0,s1
    800037ec:	6b0000ef          	jal	80003e9c <log_write>
    brelse(bp);
    800037f0:	8526                	mv	a0,s1
    800037f2:	cf8ff0ef          	jal	80002cea <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037f6:	013d09bb          	addw	s3,s10,s3
    800037fa:	012d093b          	addw	s2,s10,s2
    800037fe:	9a6e                	add	s4,s4,s11
    80003800:	0569f363          	bgeu	s3,s6,80003846 <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    80003804:	00a9559b          	srliw	a1,s2,0xa
    80003808:	8556                	mv	a0,s5
    8000380a:	f5cff0ef          	jal	80002f66 <bmap>
    8000380e:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003812:	c995                	beqz	a1,80003846 <writei+0xc4>
    bp = bread(ip->dev, addr);
    80003814:	000aa503          	lw	a0,0(s5)
    80003818:	bcaff0ef          	jal	80002be2 <bread>
    8000381c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000381e:	3ff97713          	andi	a4,s2,1023
    80003822:	40ec87bb          	subw	a5,s9,a4
    80003826:	413b06bb          	subw	a3,s6,s3
    8000382a:	8d3e                	mv	s10,a5
    8000382c:	2781                	sext.w	a5,a5
    8000382e:	0006861b          	sext.w	a2,a3
    80003832:	f8f67ee3          	bgeu	a2,a5,800037ce <writei+0x4c>
    80003836:	8d36                	mv	s10,a3
    80003838:	bf59                	j	800037ce <writei+0x4c>
      log_write(bp);
    8000383a:	8526                	mv	a0,s1
    8000383c:	660000ef          	jal	80003e9c <log_write>
      brelse(bp);
    80003840:	8526                	mv	a0,s1
    80003842:	ca8ff0ef          	jal	80002cea <brelse>
  }

  if (off > ip->size)
    80003846:	04caa783          	lw	a5,76(s5)
    8000384a:	0327fa63          	bgeu	a5,s2,8000387e <writei+0xfc>
    ip->size = off;
    8000384e:	052aa623          	sw	s2,76(s5)
    80003852:	64e6                	ld	s1,88(sp)
    80003854:	7c02                	ld	s8,32(sp)
    80003856:	6ce2                	ld	s9,24(sp)
    80003858:	6d42                	ld	s10,16(sp)
    8000385a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000385c:	8556                	mv	a0,s5
    8000385e:	99dff0ef          	jal	800031fa <iupdate>

  return tot;
    80003862:	0009851b          	sext.w	a0,s3
    80003866:	69a6                	ld	s3,72(sp)
}
    80003868:	70a6                	ld	ra,104(sp)
    8000386a:	7406                	ld	s0,96(sp)
    8000386c:	6946                	ld	s2,80(sp)
    8000386e:	6a06                	ld	s4,64(sp)
    80003870:	7ae2                	ld	s5,56(sp)
    80003872:	7b42                	ld	s6,48(sp)
    80003874:	7ba2                	ld	s7,40(sp)
    80003876:	6165                	addi	sp,sp,112
    80003878:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000387a:	89da                	mv	s3,s6
    8000387c:	b7c5                	j	8000385c <writei+0xda>
    8000387e:	64e6                	ld	s1,88(sp)
    80003880:	7c02                	ld	s8,32(sp)
    80003882:	6ce2                	ld	s9,24(sp)
    80003884:	6d42                	ld	s10,16(sp)
    80003886:	6da2                	ld	s11,8(sp)
    80003888:	bfd1                	j	8000385c <writei+0xda>
    return -1;
    8000388a:	557d                	li	a0,-1
}
    8000388c:	8082                	ret
    return -1;
    8000388e:	557d                	li	a0,-1
    80003890:	bfe1                	j	80003868 <writei+0xe6>
    return -1;
    80003892:	557d                	li	a0,-1
    80003894:	bfd1                	j	80003868 <writei+0xe6>

0000000080003896 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003896:	1141                	addi	sp,sp,-16
    80003898:	e406                	sd	ra,8(sp)
    8000389a:	e022                	sd	s0,0(sp)
    8000389c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000389e:	4639                	li	a2,14
    800038a0:	c80fd0ef          	jal	80000d20 <strncmp>
}
    800038a4:	60a2                	ld	ra,8(sp)
    800038a6:	6402                	ld	s0,0(sp)
    800038a8:	0141                	addi	sp,sp,16
    800038aa:	8082                	ret

00000000800038ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038ac:	7139                	addi	sp,sp,-64
    800038ae:	fc06                	sd	ra,56(sp)
    800038b0:	f822                	sd	s0,48(sp)
    800038b2:	f426                	sd	s1,40(sp)
    800038b4:	f04a                	sd	s2,32(sp)
    800038b6:	ec4e                	sd	s3,24(sp)
    800038b8:	e852                	sd	s4,16(sp)
    800038ba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800038bc:	04451703          	lh	a4,68(a0)
    800038c0:	4785                	li	a5,1
    800038c2:	00f71a63          	bne	a4,a5,800038d6 <dirlookup+0x2a>
    800038c6:	892a                	mv	s2,a0
    800038c8:	89ae                	mv	s3,a1
    800038ca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038cc:	457c                	lw	a5,76(a0)
    800038ce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038d0:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038d2:	e39d                	bnez	a5,800038f8 <dirlookup+0x4c>
    800038d4:	a095                	j	80003938 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800038d6:	00004517          	auipc	a0,0x4
    800038da:	bea50513          	addi	a0,a0,-1046 # 800074c0 <etext+0x4c0>
    800038de:	f13fc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    800038e2:	00004517          	auipc	a0,0x4
    800038e6:	bf650513          	addi	a0,a0,-1034 # 800074d8 <etext+0x4d8>
    800038ea:	f07fc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038ee:	24c1                	addiw	s1,s1,16
    800038f0:	04c92783          	lw	a5,76(s2)
    800038f4:	04f4f163          	bgeu	s1,a5,80003936 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038f8:	4741                	li	a4,16
    800038fa:	86a6                	mv	a3,s1
    800038fc:	fc040613          	addi	a2,s0,-64
    80003900:	4581                	li	a1,0
    80003902:	854a                	mv	a0,s2
    80003904:	d83ff0ef          	jal	80003686 <readi>
    80003908:	47c1                	li	a5,16
    8000390a:	fcf51ce3          	bne	a0,a5,800038e2 <dirlookup+0x36>
    if (de.inum == 0)
    8000390e:	fc045783          	lhu	a5,-64(s0)
    80003912:	dff1                	beqz	a5,800038ee <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    80003914:	fc240593          	addi	a1,s0,-62
    80003918:	854e                	mv	a0,s3
    8000391a:	f7dff0ef          	jal	80003896 <namecmp>
    8000391e:	f961                	bnez	a0,800038ee <dirlookup+0x42>
      if (poff)
    80003920:	000a0463          	beqz	s4,80003928 <dirlookup+0x7c>
        *poff = off;
    80003924:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003928:	fc045583          	lhu	a1,-64(s0)
    8000392c:	00092503          	lw	a0,0(s2)
    80003930:	f0aff0ef          	jal	8000303a <iget>
    80003934:	a011                	j	80003938 <dirlookup+0x8c>
  return 0;
    80003936:	4501                	li	a0,0
}
    80003938:	70e2                	ld	ra,56(sp)
    8000393a:	7442                	ld	s0,48(sp)
    8000393c:	74a2                	ld	s1,40(sp)
    8000393e:	7902                	ld	s2,32(sp)
    80003940:	69e2                	ld	s3,24(sp)
    80003942:	6a42                	ld	s4,16(sp)
    80003944:	6121                	addi	sp,sp,64
    80003946:	8082                	ret

0000000080003948 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003948:	711d                	addi	sp,sp,-96
    8000394a:	ec86                	sd	ra,88(sp)
    8000394c:	e8a2                	sd	s0,80(sp)
    8000394e:	e4a6                	sd	s1,72(sp)
    80003950:	e0ca                	sd	s2,64(sp)
    80003952:	fc4e                	sd	s3,56(sp)
    80003954:	f852                	sd	s4,48(sp)
    80003956:	f456                	sd	s5,40(sp)
    80003958:	f05a                	sd	s6,32(sp)
    8000395a:	ec5e                	sd	s7,24(sp)
    8000395c:	e862                	sd	s8,16(sp)
    8000395e:	e466                	sd	s9,8(sp)
    80003960:	1080                	addi	s0,sp,96
    80003962:	84aa                	mv	s1,a0
    80003964:	8b2e                	mv	s6,a1
    80003966:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003968:	00054703          	lbu	a4,0(a0)
    8000396c:	02f00793          	li	a5,47
    80003970:	00f70e63          	beq	a4,a5,8000398c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003974:	f31fd0ef          	jal	800018a4 <myproc>
    80003978:	15053503          	ld	a0,336(a0)
    8000397c:	8fdff0ef          	jal	80003278 <idup>
    80003980:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003982:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003986:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003988:	4b85                	li	s7,1
    8000398a:	a075                	j	80003a36 <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    8000398c:	4585                	li	a1,1
    8000398e:	4505                	li	a0,1
    80003990:	eaaff0ef          	jal	8000303a <iget>
    80003994:	8a2a                	mv	s4,a0
    80003996:	b7f5                	j	80003982 <namex+0x3a>
      iunlockput(ip);
    80003998:	8552                	mv	a0,s4
    8000399a:	b67ff0ef          	jal	80003500 <iunlockput>
      return 0;
    8000399e:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800039a0:	8552                	mv	a0,s4
    800039a2:	60e6                	ld	ra,88(sp)
    800039a4:	6446                	ld	s0,80(sp)
    800039a6:	64a6                	ld	s1,72(sp)
    800039a8:	6906                	ld	s2,64(sp)
    800039aa:	79e2                	ld	s3,56(sp)
    800039ac:	7a42                	ld	s4,48(sp)
    800039ae:	7aa2                	ld	s5,40(sp)
    800039b0:	7b02                	ld	s6,32(sp)
    800039b2:	6be2                	ld	s7,24(sp)
    800039b4:	6c42                	ld	s8,16(sp)
    800039b6:	6ca2                	ld	s9,8(sp)
    800039b8:	6125                	addi	sp,sp,96
    800039ba:	8082                	ret
      iunlockput(ip);
    800039bc:	8552                	mv	a0,s4
    800039be:	b43ff0ef          	jal	80003500 <iunlockput>
      return 0;
    800039c2:	4a01                	li	s4,0
    800039c4:	bff1                	j	800039a0 <namex+0x58>
      iunlock(ip);
    800039c6:	8552                	mv	a0,s4
    800039c8:	995ff0ef          	jal	8000335c <iunlock>
      return ip;
    800039cc:	bfd1                	j	800039a0 <namex+0x58>
      iunlockput(ip);
    800039ce:	8552                	mv	a0,s4
    800039d0:	b31ff0ef          	jal	80003500 <iunlockput>
      return 0;
    800039d4:	8a4e                	mv	s4,s3
    800039d6:	b7e9                	j	800039a0 <namex+0x58>
  len = path - s;
    800039d8:	40998633          	sub	a2,s3,s1
    800039dc:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    800039e0:	099c5363          	bge	s8,s9,80003a66 <namex+0x11e>
    memmove(name, s, DIRSIZ);
    800039e4:	4639                	li	a2,14
    800039e6:	85a6                	mv	a1,s1
    800039e8:	8556                	mv	a0,s5
    800039ea:	ac6fd0ef          	jal	80000cb0 <memmove>
    800039ee:	84ce                	mv	s1,s3
  while (*path == '/')
    800039f0:	0004c783          	lbu	a5,0(s1)
    800039f4:	01279763          	bne	a5,s2,80003a02 <namex+0xba>
    path++;
    800039f8:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039fa:	0004c783          	lbu	a5,0(s1)
    800039fe:	ff278de3          	beq	a5,s2,800039f8 <namex+0xb0>
    ilock(ip);
    80003a02:	8552                	mv	a0,s4
    80003a04:	8abff0ef          	jal	800032ae <ilock>
    if (ip->type != T_DIR) {
    80003a08:	044a1783          	lh	a5,68(s4)
    80003a0c:	f97796e3          	bne	a5,s7,80003998 <namex+0x50>
    if (ip->nlink == 0) {
    80003a10:	04aa1783          	lh	a5,74(s4)
    80003a14:	d7c5                	beqz	a5,800039bc <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003a16:	000b0563          	beqz	s6,80003a20 <namex+0xd8>
    80003a1a:	0004c783          	lbu	a5,0(s1)
    80003a1e:	d7c5                	beqz	a5,800039c6 <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a20:	4601                	li	a2,0
    80003a22:	85d6                	mv	a1,s5
    80003a24:	8552                	mv	a0,s4
    80003a26:	e87ff0ef          	jal	800038ac <dirlookup>
    80003a2a:	89aa                	mv	s3,a0
    80003a2c:	d14d                	beqz	a0,800039ce <namex+0x86>
    iunlockput(ip);
    80003a2e:	8552                	mv	a0,s4
    80003a30:	ad1ff0ef          	jal	80003500 <iunlockput>
    ip = next;
    80003a34:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003a36:	0004c783          	lbu	a5,0(s1)
    80003a3a:	01279763          	bne	a5,s2,80003a48 <namex+0x100>
    path++;
    80003a3e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a40:	0004c783          	lbu	a5,0(s1)
    80003a44:	ff278de3          	beq	a5,s2,80003a3e <namex+0xf6>
  if (*path == 0)
    80003a48:	cb8d                	beqz	a5,80003a7a <namex+0x132>
  while (*path != '/' && *path != 0)
    80003a4a:	0004c783          	lbu	a5,0(s1)
    80003a4e:	89a6                	mv	s3,s1
  len = path - s;
    80003a50:	4c81                	li	s9,0
    80003a52:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003a54:	01278963          	beq	a5,s2,80003a66 <namex+0x11e>
    80003a58:	d3c1                	beqz	a5,800039d8 <namex+0x90>
    path++;
    80003a5a:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003a5c:	0009c783          	lbu	a5,0(s3)
    80003a60:	ff279ce3          	bne	a5,s2,80003a58 <namex+0x110>
    80003a64:	bf95                	j	800039d8 <namex+0x90>
    memmove(name, s, len);
    80003a66:	2601                	sext.w	a2,a2
    80003a68:	85a6                	mv	a1,s1
    80003a6a:	8556                	mv	a0,s5
    80003a6c:	a44fd0ef          	jal	80000cb0 <memmove>
    name[len] = 0;
    80003a70:	9cd6                	add	s9,s9,s5
    80003a72:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a76:	84ce                	mv	s1,s3
    80003a78:	bfa5                	j	800039f0 <namex+0xa8>
  if (nameiparent) {
    80003a7a:	f20b03e3          	beqz	s6,800039a0 <namex+0x58>
    iput(ip);
    80003a7e:	8552                	mv	a0,s4
    80003a80:	9b1ff0ef          	jal	80003430 <iput>
    return 0;
    80003a84:	4a01                	li	s4,0
    80003a86:	bf29                	j	800039a0 <namex+0x58>

0000000080003a88 <dirlink>:
{
    80003a88:	7139                	addi	sp,sp,-64
    80003a8a:	fc06                	sd	ra,56(sp)
    80003a8c:	f822                	sd	s0,48(sp)
    80003a8e:	f04a                	sd	s2,32(sp)
    80003a90:	ec4e                	sd	s3,24(sp)
    80003a92:	e852                	sd	s4,16(sp)
    80003a94:	0080                	addi	s0,sp,64
    80003a96:	892a                	mv	s2,a0
    80003a98:	8a2e                	mv	s4,a1
    80003a9a:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003a9c:	4601                	li	a2,0
    80003a9e:	e0fff0ef          	jal	800038ac <dirlookup>
    80003aa2:	e535                	bnez	a0,80003b0e <dirlink+0x86>
    80003aa4:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003aa6:	04c92483          	lw	s1,76(s2)
    80003aaa:	c48d                	beqz	s1,80003ad4 <dirlink+0x4c>
    80003aac:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aae:	4741                	li	a4,16
    80003ab0:	86a6                	mv	a3,s1
    80003ab2:	fc040613          	addi	a2,s0,-64
    80003ab6:	4581                	li	a1,0
    80003ab8:	854a                	mv	a0,s2
    80003aba:	bcdff0ef          	jal	80003686 <readi>
    80003abe:	47c1                	li	a5,16
    80003ac0:	04f51b63          	bne	a0,a5,80003b16 <dirlink+0x8e>
    if (de.inum == 0)
    80003ac4:	fc045783          	lhu	a5,-64(s0)
    80003ac8:	c791                	beqz	a5,80003ad4 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003aca:	24c1                	addiw	s1,s1,16
    80003acc:	04c92783          	lw	a5,76(s2)
    80003ad0:	fcf4efe3          	bltu	s1,a5,80003aae <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003ad4:	4639                	li	a2,14
    80003ad6:	85d2                	mv	a1,s4
    80003ad8:	fc240513          	addi	a0,s0,-62
    80003adc:	a7afd0ef          	jal	80000d56 <strncpy>
  de.inum = inum;
    80003ae0:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ae4:	4741                	li	a4,16
    80003ae6:	86a6                	mv	a3,s1
    80003ae8:	fc040613          	addi	a2,s0,-64
    80003aec:	4581                	li	a1,0
    80003aee:	854a                	mv	a0,s2
    80003af0:	c93ff0ef          	jal	80003782 <writei>
    80003af4:	1541                	addi	a0,a0,-16
    80003af6:	00a03533          	snez	a0,a0
    80003afa:	40a00533          	neg	a0,a0
    80003afe:	74a2                	ld	s1,40(sp)
}
    80003b00:	70e2                	ld	ra,56(sp)
    80003b02:	7442                	ld	s0,48(sp)
    80003b04:	7902                	ld	s2,32(sp)
    80003b06:	69e2                	ld	s3,24(sp)
    80003b08:	6a42                	ld	s4,16(sp)
    80003b0a:	6121                	addi	sp,sp,64
    80003b0c:	8082                	ret
    iput(ip);
    80003b0e:	923ff0ef          	jal	80003430 <iput>
    return -1;
    80003b12:	557d                	li	a0,-1
    80003b14:	b7f5                	j	80003b00 <dirlink+0x78>
      panic("dirlink read");
    80003b16:	00004517          	auipc	a0,0x4
    80003b1a:	9d250513          	addi	a0,a0,-1582 # 800074e8 <etext+0x4e8>
    80003b1e:	cd3fc0ef          	jal	800007f0 <panic>

0000000080003b22 <namei>:

struct inode *
namei(char *path)
{
    80003b22:	1101                	addi	sp,sp,-32
    80003b24:	ec06                	sd	ra,24(sp)
    80003b26:	e822                	sd	s0,16(sp)
    80003b28:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b2a:	fe040613          	addi	a2,s0,-32
    80003b2e:	4581                	li	a1,0
    80003b30:	e19ff0ef          	jal	80003948 <namex>
}
    80003b34:	60e2                	ld	ra,24(sp)
    80003b36:	6442                	ld	s0,16(sp)
    80003b38:	6105                	addi	sp,sp,32
    80003b3a:	8082                	ret

0000000080003b3c <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003b3c:	1141                	addi	sp,sp,-16
    80003b3e:	e406                	sd	ra,8(sp)
    80003b40:	e022                	sd	s0,0(sp)
    80003b42:	0800                	addi	s0,sp,16
    80003b44:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b46:	4585                	li	a1,1
    80003b48:	e01ff0ef          	jal	80003948 <namex>
}
    80003b4c:	60a2                	ld	ra,8(sp)
    80003b4e:	6402                	ld	s0,0(sp)
    80003b50:	0141                	addi	sp,sp,16
    80003b52:	8082                	ret

0000000080003b54 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b54:	1101                	addi	sp,sp,-32
    80003b56:	ec06                	sd	ra,24(sp)
    80003b58:	e822                	sd	s0,16(sp)
    80003b5a:	e426                	sd	s1,8(sp)
    80003b5c:	e04a                	sd	s2,0(sp)
    80003b5e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b60:	0001c917          	auipc	s2,0x1c
    80003b64:	e1090913          	addi	s2,s2,-496 # 8001f970 <log>
    80003b68:	01892583          	lw	a1,24(s2)
    80003b6c:	02492503          	lw	a0,36(s2)
    80003b70:	872ff0ef          	jal	80002be2 <bread>
    80003b74:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b76:	02c92603          	lw	a2,44(s2)
    80003b7a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b7c:	00c05f63          	blez	a2,80003b9a <write_head+0x46>
    80003b80:	0001c717          	auipc	a4,0x1c
    80003b84:	e2070713          	addi	a4,a4,-480 # 8001f9a0 <log+0x30>
    80003b88:	87aa                	mv	a5,a0
    80003b8a:	060a                	slli	a2,a2,0x2
    80003b8c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b8e:	4314                	lw	a3,0(a4)
    80003b90:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b92:	0711                	addi	a4,a4,4
    80003b94:	0791                	addi	a5,a5,4
    80003b96:	fec79ce3          	bne	a5,a2,80003b8e <write_head+0x3a>
  }
  bwrite(buf);
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	91cff0ef          	jal	80002cb8 <bwrite>
  brelse(buf);
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	948ff0ef          	jal	80002cea <brelse>
}
    80003ba6:	60e2                	ld	ra,24(sp)
    80003ba8:	6442                	ld	s0,16(sp)
    80003baa:	64a2                	ld	s1,8(sp)
    80003bac:	6902                	ld	s2,0(sp)
    80003bae:	6105                	addi	sp,sp,32
    80003bb0:	8082                	ret

0000000080003bb2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bb2:	0001c797          	auipc	a5,0x1c
    80003bb6:	dea7a783          	lw	a5,-534(a5) # 8001f99c <log+0x2c>
    80003bba:	0af05e63          	blez	a5,80003c76 <install_trans+0xc4>
{
    80003bbe:	715d                	addi	sp,sp,-80
    80003bc0:	e486                	sd	ra,72(sp)
    80003bc2:	e0a2                	sd	s0,64(sp)
    80003bc4:	fc26                	sd	s1,56(sp)
    80003bc6:	f84a                	sd	s2,48(sp)
    80003bc8:	f44e                	sd	s3,40(sp)
    80003bca:	f052                	sd	s4,32(sp)
    80003bcc:	ec56                	sd	s5,24(sp)
    80003bce:	e85a                	sd	s6,16(sp)
    80003bd0:	e45e                	sd	s7,8(sp)
    80003bd2:	0880                	addi	s0,sp,80
    80003bd4:	8b2a                	mv	s6,a0
    80003bd6:	0001ca97          	auipc	s5,0x1c
    80003bda:	dcaa8a93          	addi	s5,s5,-566 # 8001f9a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bde:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003be0:	00004b97          	auipc	s7,0x4
    80003be4:	918b8b93          	addi	s7,s7,-1768 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003be8:	0001ca17          	auipc	s4,0x1c
    80003bec:	d88a0a13          	addi	s4,s4,-632 # 8001f970 <log>
    80003bf0:	a025                	j	80003c18 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bf2:	000aa603          	lw	a2,0(s5)
    80003bf6:	85ce                	mv	a1,s3
    80003bf8:	855e                	mv	a0,s7
    80003bfa:	911fc0ef          	jal	8000050a <printk>
    80003bfe:	a839                	j	80003c1c <install_trans+0x6a>
    brelse(lbuf);
    80003c00:	854a                	mv	a0,s2
    80003c02:	8e8ff0ef          	jal	80002cea <brelse>
    brelse(dbuf);
    80003c06:	8526                	mv	a0,s1
    80003c08:	8e2ff0ef          	jal	80002cea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c0c:	2985                	addiw	s3,s3,1
    80003c0e:	0a91                	addi	s5,s5,4
    80003c10:	02ca2783          	lw	a5,44(s4)
    80003c14:	04f9d663          	bge	s3,a5,80003c60 <install_trans+0xae>
    if (recovering) {
    80003c18:	fc0b1de3          	bnez	s6,80003bf2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c1c:	018a2583          	lw	a1,24(s4)
    80003c20:	013585bb          	addw	a1,a1,s3
    80003c24:	2585                	addiw	a1,a1,1
    80003c26:	024a2503          	lw	a0,36(s4)
    80003c2a:	fb9fe0ef          	jal	80002be2 <bread>
    80003c2e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c30:	000aa583          	lw	a1,0(s5)
    80003c34:	024a2503          	lw	a0,36(s4)
    80003c38:	fabfe0ef          	jal	80002be2 <bread>
    80003c3c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c3e:	40000613          	li	a2,1024
    80003c42:	05890593          	addi	a1,s2,88
    80003c46:	05850513          	addi	a0,a0,88
    80003c4a:	866fd0ef          	jal	80000cb0 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003c4e:	8526                	mv	a0,s1
    80003c50:	868ff0ef          	jal	80002cb8 <bwrite>
    if (recovering == 0)
    80003c54:	fa0b16e3          	bnez	s6,80003c00 <install_trans+0x4e>
      bunpin(dbuf);
    80003c58:	8526                	mv	a0,s1
    80003c5a:	94cff0ef          	jal	80002da6 <bunpin>
    80003c5e:	b74d                	j	80003c00 <install_trans+0x4e>
}
    80003c60:	60a6                	ld	ra,72(sp)
    80003c62:	6406                	ld	s0,64(sp)
    80003c64:	74e2                	ld	s1,56(sp)
    80003c66:	7942                	ld	s2,48(sp)
    80003c68:	79a2                	ld	s3,40(sp)
    80003c6a:	7a02                	ld	s4,32(sp)
    80003c6c:	6ae2                	ld	s5,24(sp)
    80003c6e:	6b42                	ld	s6,16(sp)
    80003c70:	6ba2                	ld	s7,8(sp)
    80003c72:	6161                	addi	sp,sp,80
    80003c74:	8082                	ret
    80003c76:	8082                	ret

0000000080003c78 <initlog>:
{
    80003c78:	7179                	addi	sp,sp,-48
    80003c7a:	f406                	sd	ra,40(sp)
    80003c7c:	f022                	sd	s0,32(sp)
    80003c7e:	ec26                	sd	s1,24(sp)
    80003c80:	e84a                	sd	s2,16(sp)
    80003c82:	e44e                	sd	s3,8(sp)
    80003c84:	1800                	addi	s0,sp,48
    80003c86:	892a                	mv	s2,a0
    80003c88:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c8a:	0001c497          	auipc	s1,0x1c
    80003c8e:	ce648493          	addi	s1,s1,-794 # 8001f970 <log>
    80003c92:	00004597          	auipc	a1,0x4
    80003c96:	88658593          	addi	a1,a1,-1914 # 80007518 <etext+0x518>
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	e7ffc0ef          	jal	80000b1a <initlock>
  log.start = sb->logstart;
    80003ca0:	0149a583          	lw	a1,20(s3)
    80003ca4:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003ca6:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003caa:	854a                	mv	a0,s2
    80003cac:	f37fe0ef          	jal	80002be2 <bread>
  log.lh.n = lh->n;
    80003cb0:	4d30                	lw	a2,88(a0)
    80003cb2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003cb4:	00c05f63          	blez	a2,80003cd2 <initlog+0x5a>
    80003cb8:	87aa                	mv	a5,a0
    80003cba:	0001c717          	auipc	a4,0x1c
    80003cbe:	ce670713          	addi	a4,a4,-794 # 8001f9a0 <log+0x30>
    80003cc2:	060a                	slli	a2,a2,0x2
    80003cc4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cc6:	4ff4                	lw	a3,92(a5)
    80003cc8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cca:	0791                	addi	a5,a5,4
    80003ccc:	0711                	addi	a4,a4,4
    80003cce:	fec79ce3          	bne	a5,a2,80003cc6 <initlog+0x4e>
  brelse(buf);
    80003cd2:	818ff0ef          	jal	80002cea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cd6:	4505                	li	a0,1
    80003cd8:	edbff0ef          	jal	80003bb2 <install_trans>
  log.lh.n = 0;
    80003cdc:	0001c797          	auipc	a5,0x1c
    80003ce0:	cc07a023          	sw	zero,-832(a5) # 8001f99c <log+0x2c>
  write_head(); // clear the log
    80003ce4:	e71ff0ef          	jal	80003b54 <write_head>
}
    80003ce8:	70a2                	ld	ra,40(sp)
    80003cea:	7402                	ld	s0,32(sp)
    80003cec:	64e2                	ld	s1,24(sp)
    80003cee:	6942                	ld	s2,16(sp)
    80003cf0:	69a2                	ld	s3,8(sp)
    80003cf2:	6145                	addi	sp,sp,48
    80003cf4:	8082                	ret

0000000080003cf6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003cf6:	1101                	addi	sp,sp,-32
    80003cf8:	ec06                	sd	ra,24(sp)
    80003cfa:	e822                	sd	s0,16(sp)
    80003cfc:	e426                	sd	s1,8(sp)
    80003cfe:	e04a                	sd	s2,0(sp)
    80003d00:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d02:	0001c517          	auipc	a0,0x1c
    80003d06:	c6e50513          	addi	a0,a0,-914 # 8001f970 <log>
    80003d0a:	e87fc0ef          	jal	80000b90 <acquire>
  while (1) {
    if (log.committing) {
    80003d0e:	0001c497          	auipc	s1,0x1c
    80003d12:	c6248493          	addi	s1,s1,-926 # 8001f970 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d16:	4979                	li	s2,30
    80003d18:	a821                	j	80003d30 <begin_op+0x3a>
      sleep_prepare(&log);
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	99afe0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003d20:	8526                	mv	a0,s1
    80003d22:	efbfc0ef          	jal	80000c1c <release>
      sleep();
    80003d26:	9ccfe0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	e65fc0ef          	jal	80000b90 <acquire>
    if (log.committing) {
    80003d30:	509c                	lw	a5,32(s1)
    80003d32:	f7e5                	bnez	a5,80003d1a <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d34:	4cd8                	lw	a4,28(s1)
    80003d36:	2705                	addiw	a4,a4,1
    80003d38:	0027179b          	slliw	a5,a4,0x2
    80003d3c:	9fb9                	addw	a5,a5,a4
    80003d3e:	0017979b          	slliw	a5,a5,0x1
    80003d42:	54d4                	lw	a3,44(s1)
    80003d44:	9fb5                	addw	a5,a5,a3
    80003d46:	00f95e63          	bge	s2,a5,80003d62 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	96afe0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003d50:	8526                	mv	a0,s1
    80003d52:	ecbfc0ef          	jal	80000c1c <release>
      sleep();
    80003d56:	99cfe0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	e35fc0ef          	jal	80000b90 <acquire>
    80003d60:	bfc1                	j	80003d30 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d62:	0001c517          	auipc	a0,0x1c
    80003d66:	c0e50513          	addi	a0,a0,-1010 # 8001f970 <log>
    80003d6a:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003d6c:	eb1fc0ef          	jal	80000c1c <release>
      break;
    }
  }
}
    80003d70:	60e2                	ld	ra,24(sp)
    80003d72:	6442                	ld	s0,16(sp)
    80003d74:	64a2                	ld	s1,8(sp)
    80003d76:	6902                	ld	s2,0(sp)
    80003d78:	6105                	addi	sp,sp,32
    80003d7a:	8082                	ret

0000000080003d7c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d7c:	7139                	addi	sp,sp,-64
    80003d7e:	fc06                	sd	ra,56(sp)
    80003d80:	f822                	sd	s0,48(sp)
    80003d82:	f426                	sd	s1,40(sp)
    80003d84:	f04a                	sd	s2,32(sp)
    80003d86:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d88:	0001c497          	auipc	s1,0x1c
    80003d8c:	be848493          	addi	s1,s1,-1048 # 8001f970 <log>
    80003d90:	8526                	mv	a0,s1
    80003d92:	dfffc0ef          	jal	80000b90 <acquire>
  log.outstanding -= 1;
    80003d96:	4cdc                	lw	a5,28(s1)
    80003d98:	37fd                	addiw	a5,a5,-1
    80003d9a:	0007891b          	sext.w	s2,a5
    80003d9e:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003da0:	509c                	lw	a5,32(s1)
    80003da2:	e3b1                	bnez	a5,80003de6 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003da4:	04091a63          	bnez	s2,80003df8 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003da8:	0001c497          	auipc	s1,0x1c
    80003dac:	bc848493          	addi	s1,s1,-1080 # 8001f970 <log>
    80003db0:	4785                	li	a5,1
    80003db2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003db4:	8526                	mv	a0,s1
    80003db6:	e67fc0ef          	jal	80000c1c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dba:	54dc                	lw	a5,44(s1)
    80003dbc:	04f04e63          	bgtz	a5,80003e18 <end_op+0x9c>
    acquire(&log.lock);
    80003dc0:	0001c497          	auipc	s1,0x1c
    80003dc4:	bb048493          	addi	s1,s1,-1104 # 8001f970 <log>
    80003dc8:	8526                	mv	a0,s1
    80003dca:	dc7fc0ef          	jal	80000b90 <acquire>
    log.committing = 0;
    80003dce:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003dd2:	549c                	lw	a5,40(s1)
    80003dd4:	2785                	addiw	a5,a5,1
    80003dd6:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003dd8:	8526                	mv	a0,s1
    80003dda:	948fe0ef          	jal	80001f22 <wakeup>
    release(&log.lock);
    80003dde:	8526                	mv	a0,s1
    80003de0:	e3dfc0ef          	jal	80000c1c <release>
}
    80003de4:	a025                	j	80003e0c <end_op+0x90>
    80003de6:	ec4e                	sd	s3,24(sp)
    80003de8:	e852                	sd	s4,16(sp)
    80003dea:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003dec:	00003517          	auipc	a0,0x3
    80003df0:	73450513          	addi	a0,a0,1844 # 80007520 <etext+0x520>
    80003df4:	9fdfc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80003df8:	0001c497          	auipc	s1,0x1c
    80003dfc:	b7848493          	addi	s1,s1,-1160 # 8001f970 <log>
    80003e00:	8526                	mv	a0,s1
    80003e02:	920fe0ef          	jal	80001f22 <wakeup>
  release(&log.lock);
    80003e06:	8526                	mv	a0,s1
    80003e08:	e15fc0ef          	jal	80000c1c <release>
}
    80003e0c:	70e2                	ld	ra,56(sp)
    80003e0e:	7442                	ld	s0,48(sp)
    80003e10:	74a2                	ld	s1,40(sp)
    80003e12:	7902                	ld	s2,32(sp)
    80003e14:	6121                	addi	sp,sp,64
    80003e16:	8082                	ret
    80003e18:	ec4e                	sd	s3,24(sp)
    80003e1a:	e852                	sd	s4,16(sp)
    80003e1c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e1e:	0001ca97          	auipc	s5,0x1c
    80003e22:	b82a8a93          	addi	s5,s5,-1150 # 8001f9a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003e26:	0001ca17          	auipc	s4,0x1c
    80003e2a:	b4aa0a13          	addi	s4,s4,-1206 # 8001f970 <log>
    80003e2e:	018a2583          	lw	a1,24(s4)
    80003e32:	012585bb          	addw	a1,a1,s2
    80003e36:	2585                	addiw	a1,a1,1
    80003e38:	024a2503          	lw	a0,36(s4)
    80003e3c:	da7fe0ef          	jal	80002be2 <bread>
    80003e40:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e42:	000aa583          	lw	a1,0(s5)
    80003e46:	024a2503          	lw	a0,36(s4)
    80003e4a:	d99fe0ef          	jal	80002be2 <bread>
    80003e4e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e50:	40000613          	li	a2,1024
    80003e54:	05850593          	addi	a1,a0,88
    80003e58:	05848513          	addi	a0,s1,88
    80003e5c:	e55fc0ef          	jal	80000cb0 <memmove>
    bwrite(to); // write the log
    80003e60:	8526                	mv	a0,s1
    80003e62:	e57fe0ef          	jal	80002cb8 <bwrite>
    brelse(from);
    80003e66:	854e                	mv	a0,s3
    80003e68:	e83fe0ef          	jal	80002cea <brelse>
    brelse(to);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	e7dfe0ef          	jal	80002cea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e72:	2905                	addiw	s2,s2,1
    80003e74:	0a91                	addi	s5,s5,4
    80003e76:	02ca2783          	lw	a5,44(s4)
    80003e7a:	faf94ae3          	blt	s2,a5,80003e2e <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e7e:	cd7ff0ef          	jal	80003b54 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e82:	4501                	li	a0,0
    80003e84:	d2fff0ef          	jal	80003bb2 <install_trans>
    log.lh.n = 0;
    80003e88:	0001c797          	auipc	a5,0x1c
    80003e8c:	b007aa23          	sw	zero,-1260(a5) # 8001f99c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003e90:	cc5ff0ef          	jal	80003b54 <write_head>
    80003e94:	69e2                	ld	s3,24(sp)
    80003e96:	6a42                	ld	s4,16(sp)
    80003e98:	6aa2                	ld	s5,8(sp)
    80003e9a:	b71d                	j	80003dc0 <end_op+0x44>

0000000080003e9c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e9c:	1101                	addi	sp,sp,-32
    80003e9e:	ec06                	sd	ra,24(sp)
    80003ea0:	e822                	sd	s0,16(sp)
    80003ea2:	e426                	sd	s1,8(sp)
    80003ea4:	e04a                	sd	s2,0(sp)
    80003ea6:	1000                	addi	s0,sp,32
    80003ea8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003eaa:	0001c917          	auipc	s2,0x1c
    80003eae:	ac690913          	addi	s2,s2,-1338 # 8001f970 <log>
    80003eb2:	854a                	mv	a0,s2
    80003eb4:	cddfc0ef          	jal	80000b90 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003eb8:	02c92603          	lw	a2,44(s2)
    80003ebc:	47f5                	li	a5,29
    80003ebe:	04c7cc63          	blt	a5,a2,80003f16 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ec2:	0001c797          	auipc	a5,0x1c
    80003ec6:	aca7a783          	lw	a5,-1334(a5) # 8001f98c <log+0x1c>
    80003eca:	04f05c63          	blez	a5,80003f22 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ece:	4781                	li	a5,0
    80003ed0:	04c05f63          	blez	a2,80003f2e <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ed4:	44cc                	lw	a1,12(s1)
    80003ed6:	0001c717          	auipc	a4,0x1c
    80003eda:	aca70713          	addi	a4,a4,-1334 # 8001f9a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ede:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ee0:	4314                	lw	a3,0(a4)
    80003ee2:	04b68663          	beq	a3,a1,80003f2e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003ee6:	2785                	addiw	a5,a5,1
    80003ee8:	0711                	addi	a4,a4,4
    80003eea:	fef61be3          	bne	a2,a5,80003ee0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003eee:	0621                	addi	a2,a2,8
    80003ef0:	060a                	slli	a2,a2,0x2
    80003ef2:	0001c797          	auipc	a5,0x1c
    80003ef6:	a7e78793          	addi	a5,a5,-1410 # 8001f970 <log>
    80003efa:	97b2                	add	a5,a5,a2
    80003efc:	44d8                	lw	a4,12(s1)
    80003efe:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003f00:	8526                	mv	a0,s1
    80003f02:	e71fe0ef          	jal	80002d72 <bpin>
    log.lh.n++;
    80003f06:	0001c717          	auipc	a4,0x1c
    80003f0a:	a6a70713          	addi	a4,a4,-1430 # 8001f970 <log>
    80003f0e:	575c                	lw	a5,44(a4)
    80003f10:	2785                	addiw	a5,a5,1
    80003f12:	d75c                	sw	a5,44(a4)
    80003f14:	a80d                	j	80003f46 <log_write+0xaa>
    panic("too big a transaction");
    80003f16:	00003517          	auipc	a0,0x3
    80003f1a:	61a50513          	addi	a0,a0,1562 # 80007530 <etext+0x530>
    80003f1e:	8d3fc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    80003f22:	00003517          	auipc	a0,0x3
    80003f26:	62650513          	addi	a0,a0,1574 # 80007548 <etext+0x548>
    80003f2a:	8c7fc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    80003f2e:	00878693          	addi	a3,a5,8
    80003f32:	068a                	slli	a3,a3,0x2
    80003f34:	0001c717          	auipc	a4,0x1c
    80003f38:	a3c70713          	addi	a4,a4,-1476 # 8001f970 <log>
    80003f3c:	9736                	add	a4,a4,a3
    80003f3e:	44d4                	lw	a3,12(s1)
    80003f40:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003f42:	faf60fe3          	beq	a2,a5,80003f00 <log_write+0x64>
  }
  release(&log.lock);
    80003f46:	0001c517          	auipc	a0,0x1c
    80003f4a:	a2a50513          	addi	a0,a0,-1494 # 8001f970 <log>
    80003f4e:	ccffc0ef          	jal	80000c1c <release>
}
    80003f52:	60e2                	ld	ra,24(sp)
    80003f54:	6442                	ld	s0,16(sp)
    80003f56:	64a2                	ld	s1,8(sp)
    80003f58:	6902                	ld	s2,0(sp)
    80003f5a:	6105                	addi	sp,sp,32
    80003f5c:	8082                	ret

0000000080003f5e <sys_sync>:

uint64
sys_sync(void)
{
    80003f5e:	1101                	addi	sp,sp,-32
    80003f60:	ec06                	sd	ra,24(sp)
    80003f62:	e822                	sd	s0,16(sp)
    80003f64:	e426                	sd	s1,8(sp)
    80003f66:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f68:	0001c497          	auipc	s1,0x1c
    80003f6c:	a0848493          	addi	s1,s1,-1528 # 8001f970 <log>
    80003f70:	8526                	mv	a0,s1
    80003f72:	c1ffc0ef          	jal	80000b90 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f76:	509c                	lw	a5,32(s1)
    80003f78:	e799                	bnez	a5,80003f86 <sys_sync+0x28>
    80003f7a:	0001c797          	auipc	a5,0x1c
    80003f7e:	a127a783          	lw	a5,-1518(a5) # 8001f98c <log+0x1c>
    80003f82:	02f05a63          	blez	a5,80003fb6 <sys_sync+0x58>
    80003f86:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003f88:	0001c917          	auipc	s2,0x1c
    80003f8c:	a1092903          	lw	s2,-1520(s2) # 8001f998 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003f90:	0001c497          	auipc	s1,0x1c
    80003f94:	9e048493          	addi	s1,s1,-1568 # 8001f970 <log>
    80003f98:	8526                	mv	a0,s1
    80003f9a:	f1dfd0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	c7dfc0ef          	jal	80000c1c <release>
      sleep();
    80003fa4:	f4ffd0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003fa8:	8526                	mv	a0,s1
    80003faa:	be7fc0ef          	jal	80000b90 <acquire>
    while (log.ncommit < n) {
    80003fae:	549c                	lw	a5,40(s1)
    80003fb0:	fef954e3          	bge	s2,a5,80003f98 <sys_sync+0x3a>
    80003fb4:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003fb6:	0001c517          	auipc	a0,0x1c
    80003fba:	9ba50513          	addi	a0,a0,-1606 # 8001f970 <log>
    80003fbe:	c5ffc0ef          	jal	80000c1c <release>
  return 0;
}
    80003fc2:	4501                	li	a0,0
    80003fc4:	60e2                	ld	ra,24(sp)
    80003fc6:	6442                	ld	s0,16(sp)
    80003fc8:	64a2                	ld	s1,8(sp)
    80003fca:	6105                	addi	sp,sp,32
    80003fcc:	8082                	ret

0000000080003fce <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fce:	1101                	addi	sp,sp,-32
    80003fd0:	ec06                	sd	ra,24(sp)
    80003fd2:	e822                	sd	s0,16(sp)
    80003fd4:	e426                	sd	s1,8(sp)
    80003fd6:	e04a                	sd	s2,0(sp)
    80003fd8:	1000                	addi	s0,sp,32
    80003fda:	84aa                	mv	s1,a0
    80003fdc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003fde:	00003597          	auipc	a1,0x3
    80003fe2:	58a58593          	addi	a1,a1,1418 # 80007568 <etext+0x568>
    80003fe6:	0521                	addi	a0,a0,8
    80003fe8:	b33fc0ef          	jal	80000b1a <initlock>
  lk->name = name;
    80003fec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003ff0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ff4:	0204a423          	sw	zero,40(s1)
}
    80003ff8:	60e2                	ld	ra,24(sp)
    80003ffa:	6442                	ld	s0,16(sp)
    80003ffc:	64a2                	ld	s1,8(sp)
    80003ffe:	6902                	ld	s2,0(sp)
    80004000:	6105                	addi	sp,sp,32
    80004002:	8082                	ret

0000000080004004 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004004:	1101                	addi	sp,sp,-32
    80004006:	ec06                	sd	ra,24(sp)
    80004008:	e822                	sd	s0,16(sp)
    8000400a:	e426                	sd	s1,8(sp)
    8000400c:	e04a                	sd	s2,0(sp)
    8000400e:	1000                	addi	s0,sp,32
    80004010:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004012:	00850913          	addi	s2,a0,8
    80004016:	854a                	mv	a0,s2
    80004018:	b79fc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    8000401c:	409c                	lw	a5,0(s1)
    8000401e:	cf91                	beqz	a5,8000403a <acquiresleep+0x36>
    sleep_prepare(lk);
    80004020:	8526                	mv	a0,s1
    80004022:	e95fd0ef          	jal	80001eb6 <sleep_prepare>
    release(&lk->lk);
    80004026:	854a                	mv	a0,s2
    80004028:	bf5fc0ef          	jal	80000c1c <release>
    sleep();
    8000402c:	ec7fd0ef          	jal	80001ef2 <sleep>
    acquire(&lk->lk);
    80004030:	854a                	mv	a0,s2
    80004032:	b5ffc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    80004036:	409c                	lw	a5,0(s1)
    80004038:	f7e5                	bnez	a5,80004020 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000403a:	4785                	li	a5,1
    8000403c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000403e:	867fd0ef          	jal	800018a4 <myproc>
    80004042:	591c                	lw	a5,48(a0)
    80004044:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004046:	854a                	mv	a0,s2
    80004048:	bd5fc0ef          	jal	80000c1c <release>
}
    8000404c:	60e2                	ld	ra,24(sp)
    8000404e:	6442                	ld	s0,16(sp)
    80004050:	64a2                	ld	s1,8(sp)
    80004052:	6902                	ld	s2,0(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004058:	1101                	addi	sp,sp,-32
    8000405a:	ec06                	sd	ra,24(sp)
    8000405c:	e822                	sd	s0,16(sp)
    8000405e:	e426                	sd	s1,8(sp)
    80004060:	e04a                	sd	s2,0(sp)
    80004062:	1000                	addi	s0,sp,32
    80004064:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004066:	00850913          	addi	s2,a0,8
    8000406a:	854a                	mv	a0,s2
    8000406c:	b25fc0ef          	jal	80000b90 <acquire>
  lk->locked = 0;
    80004070:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004074:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004078:	8526                	mv	a0,s1
    8000407a:	ea9fd0ef          	jal	80001f22 <wakeup>
  release(&lk->lk);
    8000407e:	854a                	mv	a0,s2
    80004080:	b9dfc0ef          	jal	80000c1c <release>
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	64a2                	ld	s1,8(sp)
    8000408a:	6902                	ld	s2,0(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret

0000000080004090 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004090:	7179                	addi	sp,sp,-48
    80004092:	f406                	sd	ra,40(sp)
    80004094:	f022                	sd	s0,32(sp)
    80004096:	ec26                	sd	s1,24(sp)
    80004098:	e84a                	sd	s2,16(sp)
    8000409a:	1800                	addi	s0,sp,48
    8000409c:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000409e:	00850913          	addi	s2,a0,8
    800040a2:	854a                	mv	a0,s2
    800040a4:	aedfc0ef          	jal	80000b90 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040a8:	409c                	lw	a5,0(s1)
    800040aa:	ef81                	bnez	a5,800040c2 <holdingsleep+0x32>
    800040ac:	4481                	li	s1,0
  release(&lk->lk);
    800040ae:	854a                	mv	a0,s2
    800040b0:	b6dfc0ef          	jal	80000c1c <release>
  return r;
}
    800040b4:	8526                	mv	a0,s1
    800040b6:	70a2                	ld	ra,40(sp)
    800040b8:	7402                	ld	s0,32(sp)
    800040ba:	64e2                	ld	s1,24(sp)
    800040bc:	6942                	ld	s2,16(sp)
    800040be:	6145                	addi	sp,sp,48
    800040c0:	8082                	ret
    800040c2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040c4:	0284a983          	lw	s3,40(s1)
    800040c8:	fdcfd0ef          	jal	800018a4 <myproc>
    800040cc:	5904                	lw	s1,48(a0)
    800040ce:	413484b3          	sub	s1,s1,s3
    800040d2:	0014b493          	seqz	s1,s1
    800040d6:	69a2                	ld	s3,8(sp)
    800040d8:	bfd9                	j	800040ae <holdingsleep+0x1e>

00000000800040da <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040da:	1141                	addi	sp,sp,-16
    800040dc:	e406                	sd	ra,8(sp)
    800040de:	e022                	sd	s0,0(sp)
    800040e0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040e2:	00003597          	auipc	a1,0x3
    800040e6:	49658593          	addi	a1,a1,1174 # 80007578 <etext+0x578>
    800040ea:	0001c517          	auipc	a0,0x1c
    800040ee:	9ce50513          	addi	a0,a0,-1586 # 8001fab8 <ftable>
    800040f2:	a29fc0ef          	jal	80000b1a <initlock>
}
    800040f6:	60a2                	ld	ra,8(sp)
    800040f8:	6402                	ld	s0,0(sp)
    800040fa:	0141                	addi	sp,sp,16
    800040fc:	8082                	ret

00000000800040fe <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800040fe:	1101                	addi	sp,sp,-32
    80004100:	ec06                	sd	ra,24(sp)
    80004102:	e822                	sd	s0,16(sp)
    80004104:	e426                	sd	s1,8(sp)
    80004106:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004108:	0001c517          	auipc	a0,0x1c
    8000410c:	9b050513          	addi	a0,a0,-1616 # 8001fab8 <ftable>
    80004110:	a81fc0ef          	jal	80000b90 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004114:	0001c497          	auipc	s1,0x1c
    80004118:	9bc48493          	addi	s1,s1,-1604 # 8001fad0 <ftable+0x18>
    8000411c:	0001d717          	auipc	a4,0x1d
    80004120:	95470713          	addi	a4,a4,-1708 # 80020a70 <disk>
    if (f->ref == 0) {
    80004124:	40dc                	lw	a5,4(s1)
    80004126:	cf89                	beqz	a5,80004140 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004128:	02848493          	addi	s1,s1,40
    8000412c:	fee49ce3          	bne	s1,a4,80004124 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004130:	0001c517          	auipc	a0,0x1c
    80004134:	98850513          	addi	a0,a0,-1656 # 8001fab8 <ftable>
    80004138:	ae5fc0ef          	jal	80000c1c <release>
  return 0;
    8000413c:	4481                	li	s1,0
    8000413e:	a809                	j	80004150 <filealloc+0x52>
      f->ref = 1;
    80004140:	4785                	li	a5,1
    80004142:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004144:	0001c517          	auipc	a0,0x1c
    80004148:	97450513          	addi	a0,a0,-1676 # 8001fab8 <ftable>
    8000414c:	ad1fc0ef          	jal	80000c1c <release>
}
    80004150:	8526                	mv	a0,s1
    80004152:	60e2                	ld	ra,24(sp)
    80004154:	6442                	ld	s0,16(sp)
    80004156:	64a2                	ld	s1,8(sp)
    80004158:	6105                	addi	sp,sp,32
    8000415a:	8082                	ret

000000008000415c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000415c:	1101                	addi	sp,sp,-32
    8000415e:	ec06                	sd	ra,24(sp)
    80004160:	e822                	sd	s0,16(sp)
    80004162:	e426                	sd	s1,8(sp)
    80004164:	1000                	addi	s0,sp,32
    80004166:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004168:	0001c517          	auipc	a0,0x1c
    8000416c:	95050513          	addi	a0,a0,-1712 # 8001fab8 <ftable>
    80004170:	a21fc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    80004174:	40dc                	lw	a5,4(s1)
    80004176:	02f05063          	blez	a5,80004196 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000417a:	2785                	addiw	a5,a5,1
    8000417c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000417e:	0001c517          	auipc	a0,0x1c
    80004182:	93a50513          	addi	a0,a0,-1734 # 8001fab8 <ftable>
    80004186:	a97fc0ef          	jal	80000c1c <release>
  return f;
}
    8000418a:	8526                	mv	a0,s1
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	64a2                	ld	s1,8(sp)
    80004192:	6105                	addi	sp,sp,32
    80004194:	8082                	ret
    panic("filedup");
    80004196:	00003517          	auipc	a0,0x3
    8000419a:	3ea50513          	addi	a0,a0,1002 # 80007580 <etext+0x580>
    8000419e:	e52fc0ef          	jal	800007f0 <panic>

00000000800041a2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041a2:	7139                	addi	sp,sp,-64
    800041a4:	fc06                	sd	ra,56(sp)
    800041a6:	f822                	sd	s0,48(sp)
    800041a8:	f426                	sd	s1,40(sp)
    800041aa:	0080                	addi	s0,sp,64
    800041ac:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ae:	0001c517          	auipc	a0,0x1c
    800041b2:	90a50513          	addi	a0,a0,-1782 # 8001fab8 <ftable>
    800041b6:	9dbfc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    800041ba:	40dc                	lw	a5,4(s1)
    800041bc:	04f05a63          	blez	a5,80004210 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800041c0:	37fd                	addiw	a5,a5,-1
    800041c2:	0007871b          	sext.w	a4,a5
    800041c6:	c0dc                	sw	a5,4(s1)
    800041c8:	04e04e63          	bgtz	a4,80004224 <fileclose+0x82>
    800041cc:	f04a                	sd	s2,32(sp)
    800041ce:	ec4e                	sd	s3,24(sp)
    800041d0:	e852                	sd	s4,16(sp)
    800041d2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041d4:	0004a903          	lw	s2,0(s1)
    800041d8:	0094ca83          	lbu	s5,9(s1)
    800041dc:	0104ba03          	ld	s4,16(s1)
    800041e0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800041e4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041e8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041ec:	0001c517          	auipc	a0,0x1c
    800041f0:	8cc50513          	addi	a0,a0,-1844 # 8001fab8 <ftable>
    800041f4:	a29fc0ef          	jal	80000c1c <release>

  if (ff.type == FD_PIPE) {
    800041f8:	4785                	li	a5,1
    800041fa:	04f90063          	beq	s2,a5,8000423a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800041fe:	3979                	addiw	s2,s2,-2
    80004200:	4785                	li	a5,1
    80004202:	0527f563          	bgeu	a5,s2,8000424c <fileclose+0xaa>
    80004206:	7902                	ld	s2,32(sp)
    80004208:	69e2                	ld	s3,24(sp)
    8000420a:	6a42                	ld	s4,16(sp)
    8000420c:	6aa2                	ld	s5,8(sp)
    8000420e:	a00d                	j	80004230 <fileclose+0x8e>
    80004210:	f04a                	sd	s2,32(sp)
    80004212:	ec4e                	sd	s3,24(sp)
    80004214:	e852                	sd	s4,16(sp)
    80004216:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004218:	00003517          	auipc	a0,0x3
    8000421c:	37050513          	addi	a0,a0,880 # 80007588 <etext+0x588>
    80004220:	dd0fc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    80004224:	0001c517          	auipc	a0,0x1c
    80004228:	89450513          	addi	a0,a0,-1900 # 8001fab8 <ftable>
    8000422c:	9f1fc0ef          	jal	80000c1c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004230:	70e2                	ld	ra,56(sp)
    80004232:	7442                	ld	s0,48(sp)
    80004234:	74a2                	ld	s1,40(sp)
    80004236:	6121                	addi	sp,sp,64
    80004238:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000423a:	85d6                	mv	a1,s5
    8000423c:	8552                	mv	a0,s4
    8000423e:	34c000ef          	jal	8000458a <pipeclose>
    80004242:	7902                	ld	s2,32(sp)
    80004244:	69e2                	ld	s3,24(sp)
    80004246:	6a42                	ld	s4,16(sp)
    80004248:	6aa2                	ld	s5,8(sp)
    8000424a:	b7dd                	j	80004230 <fileclose+0x8e>
    begin_op();
    8000424c:	aabff0ef          	jal	80003cf6 <begin_op>
    iput(ff.ip);
    80004250:	854e                	mv	a0,s3
    80004252:	9deff0ef          	jal	80003430 <iput>
    end_op();
    80004256:	b27ff0ef          	jal	80003d7c <end_op>
    8000425a:	7902                	ld	s2,32(sp)
    8000425c:	69e2                	ld	s3,24(sp)
    8000425e:	6a42                	ld	s4,16(sp)
    80004260:	6aa2                	ld	s5,8(sp)
    80004262:	b7f9                	j	80004230 <fileclose+0x8e>

0000000080004264 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004264:	715d                	addi	sp,sp,-80
    80004266:	e486                	sd	ra,72(sp)
    80004268:	e0a2                	sd	s0,64(sp)
    8000426a:	fc26                	sd	s1,56(sp)
    8000426c:	f44e                	sd	s3,40(sp)
    8000426e:	0880                	addi	s0,sp,80
    80004270:	84aa                	mv	s1,a0
    80004272:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004274:	e30fd0ef          	jal	800018a4 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004278:	409c                	lw	a5,0(s1)
    8000427a:	37f9                	addiw	a5,a5,-2
    8000427c:	4705                	li	a4,1
    8000427e:	04f76263          	bltu	a4,a5,800042c2 <filestat+0x5e>
    80004282:	f84a                	sd	s2,48(sp)
    80004284:	892a                	mv	s2,a0
    ilock(f->ip);
    80004286:	6c88                	ld	a0,24(s1)
    80004288:	826ff0ef          	jal	800032ae <ilock>
    stati(f->ip, &st);
    8000428c:	fb840593          	addi	a1,s0,-72
    80004290:	6c88                	ld	a0,24(s1)
    80004292:	bcaff0ef          	jal	8000365c <stati>
    iunlock(f->ip);
    80004296:	6c88                	ld	a0,24(s1)
    80004298:	8c4ff0ef          	jal	8000335c <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000429c:	4761                	li	a4,24
    8000429e:	fb840693          	addi	a3,s0,-72
    800042a2:	864e                	mv	a2,s3
    800042a4:	04893583          	ld	a1,72(s2)
    800042a8:	05093503          	ld	a0,80(s2)
    800042ac:	a2efd0ef          	jal	800014da <copyout>
    800042b0:	41f5551b          	sraiw	a0,a0,0x1f
    800042b4:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042b6:	60a6                	ld	ra,72(sp)
    800042b8:	6406                	ld	s0,64(sp)
    800042ba:	74e2                	ld	s1,56(sp)
    800042bc:	79a2                	ld	s3,40(sp)
    800042be:	6161                	addi	sp,sp,80
    800042c0:	8082                	ret
  return -1;
    800042c2:	557d                	li	a0,-1
    800042c4:	bfcd                	j	800042b6 <filestat+0x52>

00000000800042c6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042c6:	7179                	addi	sp,sp,-48
    800042c8:	f406                	sd	ra,40(sp)
    800042ca:	f022                	sd	s0,32(sp)
    800042cc:	e84a                	sd	s2,16(sp)
    800042ce:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800042d0:	00854783          	lbu	a5,8(a0)
    800042d4:	c3c5                	beqz	a5,80004374 <fileread+0xae>
    800042d6:	ec26                	sd	s1,24(sp)
    800042d8:	e44e                	sd	s3,8(sp)
    800042da:	84aa                	mv	s1,a0
    800042dc:	89ae                	mv	s3,a1
    800042de:	8932                	mv	s2,a2
    800042e0:	08064c63          	bltz	a2,80004378 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    800042e4:	411c                	lw	a5,0(a0)
    800042e6:	4705                	li	a4,1
    800042e8:	04e78363          	beq	a5,a4,8000432e <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800042ec:	470d                	li	a4,3
    800042ee:	04e78763          	beq	a5,a4,8000433c <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800042f2:	4709                	li	a4,2
    800042f4:	06e79a63          	bne	a5,a4,80004368 <fileread+0xa2>
    ilock(f->ip);
    800042f8:	6d08                	ld	a0,24(a0)
    800042fa:	fb5fe0ef          	jal	800032ae <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042fe:	874a                	mv	a4,s2
    80004300:	5094                	lw	a3,32(s1)
    80004302:	864e                	mv	a2,s3
    80004304:	4585                	li	a1,1
    80004306:	6c88                	ld	a0,24(s1)
    80004308:	b7eff0ef          	jal	80003686 <readi>
    8000430c:	892a                	mv	s2,a0
    8000430e:	00a05563          	blez	a0,80004318 <fileread+0x52>
      f->off += r;
    80004312:	509c                	lw	a5,32(s1)
    80004314:	9fa9                	addw	a5,a5,a0
    80004316:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004318:	6c88                	ld	a0,24(s1)
    8000431a:	842ff0ef          	jal	8000335c <iunlock>
    8000431e:	64e2                	ld	s1,24(sp)
    80004320:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004322:	854a                	mv	a0,s2
    80004324:	70a2                	ld	ra,40(sp)
    80004326:	7402                	ld	s0,32(sp)
    80004328:	6942                	ld	s2,16(sp)
    8000432a:	6145                	addi	sp,sp,48
    8000432c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000432e:	6908                	ld	a0,16(a0)
    80004330:	3b6000ef          	jal	800046e6 <piperead>
    80004334:	892a                	mv	s2,a0
    80004336:	64e2                	ld	s1,24(sp)
    80004338:	69a2                	ld	s3,8(sp)
    8000433a:	b7e5                	j	80004322 <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000433c:	02451783          	lh	a5,36(a0)
    80004340:	03079693          	slli	a3,a5,0x30
    80004344:	92c1                	srli	a3,a3,0x30
    80004346:	4725                	li	a4,9
    80004348:	02d76c63          	bltu	a4,a3,80004380 <fileread+0xba>
    8000434c:	0792                	slli	a5,a5,0x4
    8000434e:	0001b717          	auipc	a4,0x1b
    80004352:	6ca70713          	addi	a4,a4,1738 # 8001fa18 <devsw>
    80004356:	97ba                	add	a5,a5,a4
    80004358:	639c                	ld	a5,0(a5)
    8000435a:	c79d                	beqz	a5,80004388 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    8000435c:	4505                	li	a0,1
    8000435e:	9782                	jalr	a5
    80004360:	892a                	mv	s2,a0
    80004362:	64e2                	ld	s1,24(sp)
    80004364:	69a2                	ld	s3,8(sp)
    80004366:	bf75                	j	80004322 <fileread+0x5c>
    panic("fileread");
    80004368:	00003517          	auipc	a0,0x3
    8000436c:	23050513          	addi	a0,a0,560 # 80007598 <etext+0x598>
    80004370:	c80fc0ef          	jal	800007f0 <panic>
    return -1;
    80004374:	597d                	li	s2,-1
    80004376:	b775                	j	80004322 <fileread+0x5c>
    80004378:	597d                	li	s2,-1
    8000437a:	64e2                	ld	s1,24(sp)
    8000437c:	69a2                	ld	s3,8(sp)
    8000437e:	b755                	j	80004322 <fileread+0x5c>
      return -1;
    80004380:	597d                	li	s2,-1
    80004382:	64e2                	ld	s1,24(sp)
    80004384:	69a2                	ld	s3,8(sp)
    80004386:	bf71                	j	80004322 <fileread+0x5c>
    80004388:	597d                	li	s2,-1
    8000438a:	64e2                	ld	s1,24(sp)
    8000438c:	69a2                	ld	s3,8(sp)
    8000438e:	bf51                	j	80004322 <fileread+0x5c>

0000000080004390 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004390:	00954783          	lbu	a5,9(a0)
    80004394:	10078663          	beqz	a5,800044a0 <filewrite+0x110>
{
    80004398:	715d                	addi	sp,sp,-80
    8000439a:	e486                	sd	ra,72(sp)
    8000439c:	e0a2                	sd	s0,64(sp)
    8000439e:	f84a                	sd	s2,48(sp)
    800043a0:	f052                	sd	s4,32(sp)
    800043a2:	e85a                	sd	s6,16(sp)
    800043a4:	0880                	addi	s0,sp,80
    800043a6:	892a                	mv	s2,a0
    800043a8:	8b2e                	mv	s6,a1
    800043aa:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800043ac:	0e064c63          	bltz	a2,800044a4 <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800043b0:	411c                	lw	a5,0(a0)
    800043b2:	4705                	li	a4,1
    800043b4:	02e78763          	beq	a5,a4,800043e2 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043b8:	470d                	li	a4,3
    800043ba:	02e78863          	beq	a5,a4,800043ea <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043be:	4709                	li	a4,2
    800043c0:	0ce79563          	bne	a5,a4,8000448a <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800043c4:	0ec05663          	blez	a2,800044b0 <filewrite+0x120>
    800043c8:	fc26                	sd	s1,56(sp)
    800043ca:	f44e                	sd	s3,40(sp)
    800043cc:	ec56                	sd	s5,24(sp)
    800043ce:	e45e                	sd	s7,8(sp)
    800043d0:	e062                	sd	s8,0(sp)
    int i = 0;
    800043d2:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    800043d4:	6b85                	lui	s7,0x1
    800043d6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043da:	6c05                	lui	s8,0x1
    800043dc:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800043e0:	a8b5                	j	8000445c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043e2:	6908                	ld	a0,16(a0)
    800043e4:	1fe000ef          	jal	800045e2 <pipewrite>
    800043e8:	a851                	j	8000447c <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043ea:	02451783          	lh	a5,36(a0)
    800043ee:	03079693          	slli	a3,a5,0x30
    800043f2:	92c1                	srli	a3,a3,0x30
    800043f4:	4725                	li	a4,9
    800043f6:	0ad76963          	bltu	a4,a3,800044a8 <filewrite+0x118>
    800043fa:	0792                	slli	a5,a5,0x4
    800043fc:	0001b717          	auipc	a4,0x1b
    80004400:	61c70713          	addi	a4,a4,1564 # 8001fa18 <devsw>
    80004404:	97ba                	add	a5,a5,a4
    80004406:	679c                	ld	a5,8(a5)
    80004408:	c3d5                	beqz	a5,800044ac <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    8000440a:	4505                	li	a0,1
    8000440c:	9782                	jalr	a5
    8000440e:	a0bd                	j	8000447c <filewrite+0xec>
      if (n1 > max)
    80004410:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004414:	8e3ff0ef          	jal	80003cf6 <begin_op>
      ilock(f->ip);
    80004418:	01893503          	ld	a0,24(s2)
    8000441c:	e93fe0ef          	jal	800032ae <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004420:	8756                	mv	a4,s5
    80004422:	02092683          	lw	a3,32(s2)
    80004426:	01698633          	add	a2,s3,s6
    8000442a:	4585                	li	a1,1
    8000442c:	01893503          	ld	a0,24(s2)
    80004430:	b52ff0ef          	jal	80003782 <writei>
    80004434:	84aa                	mv	s1,a0
    80004436:	00a05763          	blez	a0,80004444 <filewrite+0xb4>
        f->off += r;
    8000443a:	02092783          	lw	a5,32(s2)
    8000443e:	9fa9                	addw	a5,a5,a0
    80004440:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004444:	01893503          	ld	a0,24(s2)
    80004448:	f15fe0ef          	jal	8000335c <iunlock>
      end_op();
    8000444c:	931ff0ef          	jal	80003d7c <end_op>

      if (r != n1) {
    80004450:	009a9e63          	bne	s5,s1,8000446c <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    80004454:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    80004458:	0149da63          	bge	s3,s4,8000446c <filewrite+0xdc>
      int n1 = n - i;
    8000445c:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    80004460:	0004879b          	sext.w	a5,s1
    80004464:	fafbd6e3          	bge	s7,a5,80004410 <filewrite+0x80>
    80004468:	84e2                	mv	s1,s8
    8000446a:	b75d                	j	80004410 <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    8000446c:	053a1463          	bne	s4,s3,800044b4 <filewrite+0x124>
    80004470:	8552                	mv	a0,s4
    80004472:	74e2                	ld	s1,56(sp)
    80004474:	79a2                	ld	s3,40(sp)
    80004476:	6ae2                	ld	s5,24(sp)
    80004478:	6ba2                	ld	s7,8(sp)
    8000447a:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000447c:	60a6                	ld	ra,72(sp)
    8000447e:	6406                	ld	s0,64(sp)
    80004480:	7942                	ld	s2,48(sp)
    80004482:	7a02                	ld	s4,32(sp)
    80004484:	6b42                	ld	s6,16(sp)
    80004486:	6161                	addi	sp,sp,80
    80004488:	8082                	ret
    8000448a:	fc26                	sd	s1,56(sp)
    8000448c:	f44e                	sd	s3,40(sp)
    8000448e:	ec56                	sd	s5,24(sp)
    80004490:	e45e                	sd	s7,8(sp)
    80004492:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004494:	00003517          	auipc	a0,0x3
    80004498:	11450513          	addi	a0,a0,276 # 800075a8 <etext+0x5a8>
    8000449c:	b54fc0ef          	jal	800007f0 <panic>
    return -1;
    800044a0:	557d                	li	a0,-1
}
    800044a2:	8082                	ret
    return -1;
    800044a4:	557d                	li	a0,-1
    800044a6:	bfd9                	j	8000447c <filewrite+0xec>
      return -1;
    800044a8:	557d                	li	a0,-1
    800044aa:	bfc9                	j	8000447c <filewrite+0xec>
    800044ac:	557d                	li	a0,-1
    800044ae:	b7f9                	j	8000447c <filewrite+0xec>
    ret = (i == n ? n : -1);
    800044b0:	8532                	mv	a0,a2
    800044b2:	b7e9                	j	8000447c <filewrite+0xec>
    800044b4:	557d                	li	a0,-1
    800044b6:	74e2                	ld	s1,56(sp)
    800044b8:	79a2                	ld	s3,40(sp)
    800044ba:	6ae2                	ld	s5,24(sp)
    800044bc:	6ba2                	ld	s7,8(sp)
    800044be:	6c02                	ld	s8,0(sp)
    800044c0:	bf75                	j	8000447c <filewrite+0xec>

00000000800044c2 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044c2:	7179                	addi	sp,sp,-48
    800044c4:	f406                	sd	ra,40(sp)
    800044c6:	f022                	sd	s0,32(sp)
    800044c8:	ec26                	sd	s1,24(sp)
    800044ca:	e052                	sd	s4,0(sp)
    800044cc:	1800                	addi	s0,sp,48
    800044ce:	84aa                	mv	s1,a0
    800044d0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044d2:	0005b023          	sd	zero,0(a1)
    800044d6:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044da:	c25ff0ef          	jal	800040fe <filealloc>
    800044de:	e088                	sd	a0,0(s1)
    800044e0:	c549                	beqz	a0,8000456a <pipealloc+0xa8>
    800044e2:	c1dff0ef          	jal	800040fe <filealloc>
    800044e6:	00aa3023          	sd	a0,0(s4)
    800044ea:	cd25                	beqz	a0,80004562 <pipealloc+0xa0>
    800044ec:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800044ee:	ddcfc0ef          	jal	80000aca <kalloc>
    800044f2:	892a                	mv	s2,a0
    800044f4:	c12d                	beqz	a0,80004556 <pipealloc+0x94>
    800044f6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044f8:	4985                	li	s3,1
    800044fa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044fe:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004502:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004506:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000450a:	00003597          	auipc	a1,0x3
    8000450e:	0ae58593          	addi	a1,a1,174 # 800075b8 <etext+0x5b8>
    80004512:	e08fc0ef          	jal	80000b1a <initlock>
  (*f0)->type = FD_PIPE;
    80004516:	609c                	ld	a5,0(s1)
    80004518:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000451c:	609c                	ld	a5,0(s1)
    8000451e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004522:	609c                	ld	a5,0(s1)
    80004524:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004528:	609c                	ld	a5,0(s1)
    8000452a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000452e:	000a3783          	ld	a5,0(s4)
    80004532:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004536:	000a3783          	ld	a5,0(s4)
    8000453a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000453e:	000a3783          	ld	a5,0(s4)
    80004542:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004546:	000a3783          	ld	a5,0(s4)
    8000454a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000454e:	4501                	li	a0,0
    80004550:	6942                	ld	s2,16(sp)
    80004552:	69a2                	ld	s3,8(sp)
    80004554:	a01d                	j	8000457a <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004556:	6088                	ld	a0,0(s1)
    80004558:	c119                	beqz	a0,8000455e <pipealloc+0x9c>
    8000455a:	6942                	ld	s2,16(sp)
    8000455c:	a029                	j	80004566 <pipealloc+0xa4>
    8000455e:	6942                	ld	s2,16(sp)
    80004560:	a029                	j	8000456a <pipealloc+0xa8>
    80004562:	6088                	ld	a0,0(s1)
    80004564:	c10d                	beqz	a0,80004586 <pipealloc+0xc4>
    fileclose(*f0);
    80004566:	c3dff0ef          	jal	800041a2 <fileclose>
  if (*f1)
    8000456a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000456e:	557d                	li	a0,-1
  if (*f1)
    80004570:	c789                	beqz	a5,8000457a <pipealloc+0xb8>
    fileclose(*f1);
    80004572:	853e                	mv	a0,a5
    80004574:	c2fff0ef          	jal	800041a2 <fileclose>
  return -1;
    80004578:	557d                	li	a0,-1
}
    8000457a:	70a2                	ld	ra,40(sp)
    8000457c:	7402                	ld	s0,32(sp)
    8000457e:	64e2                	ld	s1,24(sp)
    80004580:	6a02                	ld	s4,0(sp)
    80004582:	6145                	addi	sp,sp,48
    80004584:	8082                	ret
  return -1;
    80004586:	557d                	li	a0,-1
    80004588:	bfcd                	j	8000457a <pipealloc+0xb8>

000000008000458a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000458a:	1101                	addi	sp,sp,-32
    8000458c:	ec06                	sd	ra,24(sp)
    8000458e:	e822                	sd	s0,16(sp)
    80004590:	e426                	sd	s1,8(sp)
    80004592:	e04a                	sd	s2,0(sp)
    80004594:	1000                	addi	s0,sp,32
    80004596:	84aa                	mv	s1,a0
    80004598:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000459a:	df6fc0ef          	jal	80000b90 <acquire>
  if (writable) {
    8000459e:	02090763          	beqz	s2,800045cc <pipeclose+0x42>
    pi->writeopen = 0;
    800045a2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045a6:	21848513          	addi	a0,s1,536
    800045aa:	979fd0ef          	jal	80001f22 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800045ae:	2204b783          	ld	a5,544(s1)
    800045b2:	e785                	bnez	a5,800045da <pipeclose+0x50>
    release(&pi->lock);
    800045b4:	8526                	mv	a0,s1
    800045b6:	e66fc0ef          	jal	80000c1c <release>
    kfree((char *)pi);
    800045ba:	8526                	mv	a0,s1
    800045bc:	c2cfc0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    800045c0:	60e2                	ld	ra,24(sp)
    800045c2:	6442                	ld	s0,16(sp)
    800045c4:	64a2                	ld	s1,8(sp)
    800045c6:	6902                	ld	s2,0(sp)
    800045c8:	6105                	addi	sp,sp,32
    800045ca:	8082                	ret
    pi->readopen = 0;
    800045cc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045d0:	21c48513          	addi	a0,s1,540
    800045d4:	94ffd0ef          	jal	80001f22 <wakeup>
    800045d8:	bfd9                	j	800045ae <pipeclose+0x24>
    release(&pi->lock);
    800045da:	8526                	mv	a0,s1
    800045dc:	e40fc0ef          	jal	80000c1c <release>
}
    800045e0:	b7c5                	j	800045c0 <pipeclose+0x36>

00000000800045e2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045e2:	711d                	addi	sp,sp,-96
    800045e4:	ec86                	sd	ra,88(sp)
    800045e6:	e8a2                	sd	s0,80(sp)
    800045e8:	e4a6                	sd	s1,72(sp)
    800045ea:	e0ca                	sd	s2,64(sp)
    800045ec:	fc4e                	sd	s3,56(sp)
    800045ee:	f852                	sd	s4,48(sp)
    800045f0:	f456                	sd	s5,40(sp)
    800045f2:	1080                	addi	s0,sp,96
    800045f4:	84aa                	mv	s1,a0
    800045f6:	8aae                	mv	s5,a1
    800045f8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045fa:	aaafd0ef          	jal	800018a4 <myproc>
    800045fe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004600:	8526                	mv	a0,s1
    80004602:	d8efc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    80004606:	0d405e63          	blez	s4,800046e2 <pipewrite+0x100>
    8000460a:	f05a                	sd	s6,32(sp)
    8000460c:	ec5e                	sd	s7,24(sp)
    8000460e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004610:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004612:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004614:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004618:	21c48b93          	addi	s7,s1,540
    8000461c:	a091                	j	80004660 <pipewrite+0x7e>
      release(&pi->lock);
    8000461e:	8526                	mv	a0,s1
    80004620:	dfcfc0ef          	jal	80000c1c <release>
      return -1;
    80004624:	597d                	li	s2,-1
    80004626:	7b02                	ld	s6,32(sp)
    80004628:	6be2                	ld	s7,24(sp)
    8000462a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000462c:	854a                	mv	a0,s2
    8000462e:	60e6                	ld	ra,88(sp)
    80004630:	6446                	ld	s0,80(sp)
    80004632:	64a6                	ld	s1,72(sp)
    80004634:	6906                	ld	s2,64(sp)
    80004636:	79e2                	ld	s3,56(sp)
    80004638:	7a42                	ld	s4,48(sp)
    8000463a:	7aa2                	ld	s5,40(sp)
    8000463c:	6125                	addi	sp,sp,96
    8000463e:	8082                	ret
      wakeup(&pi->nread);
    80004640:	8562                	mv	a0,s8
    80004642:	8e1fd0ef          	jal	80001f22 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004646:	855e                	mv	a0,s7
    80004648:	86ffd0ef          	jal	80001eb6 <sleep_prepare>
      release(&pi->lock);
    8000464c:	8526                	mv	a0,s1
    8000464e:	dcefc0ef          	jal	80000c1c <release>
      sleep();
    80004652:	8a1fd0ef          	jal	80001ef2 <sleep>
      acquire(&pi->lock);
    80004656:	8526                	mv	a0,s1
    80004658:	d38fc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    8000465c:	07495863          	bge	s2,s4,800046cc <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    80004660:	2204a783          	lw	a5,544(s1)
    80004664:	dfcd                	beqz	a5,8000461e <pipewrite+0x3c>
    80004666:	854e                	mv	a0,s3
    80004668:	aa3fd0ef          	jal	8000210a <killed>
    8000466c:	f94d                	bnez	a0,8000461e <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000466e:	2184a783          	lw	a5,536(s1)
    80004672:	21c4a703          	lw	a4,540(s1)
    80004676:	2007879b          	addiw	a5,a5,512
    8000467a:	fcf703e3          	beq	a4,a5,80004640 <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000467e:	4705                	li	a4,1
    80004680:	015906b3          	add	a3,s2,s5
    80004684:	faf40613          	addi	a2,s0,-81
    80004688:	0489b583          	ld	a1,72(s3)
    8000468c:	0509b503          	ld	a0,80(s3)
    80004690:	f37fc0ef          	jal	800015c6 <copyin>
    80004694:	03650163          	beq	a0,s6,800046b6 <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004698:	21c4a783          	lw	a5,540(s1)
    8000469c:	0017871b          	addiw	a4,a5,1
    800046a0:	20e4ae23          	sw	a4,540(s1)
    800046a4:	1ff7f793          	andi	a5,a5,511
    800046a8:	97a6                	add	a5,a5,s1
    800046aa:	faf44703          	lbu	a4,-81(s0)
    800046ae:	00e78c23          	sb	a4,24(a5)
      i++;
    800046b2:	2905                	addiw	s2,s2,1
    800046b4:	b765                	j	8000465c <pipewrite+0x7a>
        if (i == 0)
    800046b6:	00090663          	beqz	s2,800046c2 <pipewrite+0xe0>
    800046ba:	7b02                	ld	s6,32(sp)
    800046bc:	6be2                	ld	s7,24(sp)
    800046be:	6c42                	ld	s8,16(sp)
    800046c0:	a809                	j	800046d2 <pipewrite+0xf0>
          i = -1;
    800046c2:	892a                	mv	s2,a0
        break;
    800046c4:	7b02                	ld	s6,32(sp)
    800046c6:	6be2                	ld	s7,24(sp)
    800046c8:	6c42                	ld	s8,16(sp)
    800046ca:	a021                	j	800046d2 <pipewrite+0xf0>
    800046cc:	7b02                	ld	s6,32(sp)
    800046ce:	6be2                	ld	s7,24(sp)
    800046d0:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800046d2:	21848513          	addi	a0,s1,536
    800046d6:	84dfd0ef          	jal	80001f22 <wakeup>
  release(&pi->lock);
    800046da:	8526                	mv	a0,s1
    800046dc:	d40fc0ef          	jal	80000c1c <release>
  return i;
    800046e0:	b7b1                	j	8000462c <pipewrite+0x4a>
  int i = 0;
    800046e2:	4901                	li	s2,0
    800046e4:	b7fd                	j	800046d2 <pipewrite+0xf0>

00000000800046e6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046e6:	715d                	addi	sp,sp,-80
    800046e8:	e486                	sd	ra,72(sp)
    800046ea:	e0a2                	sd	s0,64(sp)
    800046ec:	fc26                	sd	s1,56(sp)
    800046ee:	f84a                	sd	s2,48(sp)
    800046f0:	f44e                	sd	s3,40(sp)
    800046f2:	f052                	sd	s4,32(sp)
    800046f4:	ec56                	sd	s5,24(sp)
    800046f6:	0880                	addi	s0,sp,80
    800046f8:	84aa                	mv	s1,a0
    800046fa:	89ae                	mv	s3,a1
    800046fc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046fe:	9a6fd0ef          	jal	800018a4 <myproc>
    80004702:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004704:	8526                	mv	a0,s1
    80004706:	c8afc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000470a:	2184a703          	lw	a4,536(s1)
    8000470e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004712:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004716:	02f71c63          	bne	a4,a5,8000474e <piperead+0x68>
    8000471a:	2244a783          	lw	a5,548(s1)
    8000471e:	cf9d                	beqz	a5,8000475c <piperead+0x76>
    if (killed(pr)) {
    80004720:	854a                	mv	a0,s2
    80004722:	9e9fd0ef          	jal	8000210a <killed>
    80004726:	e515                	bnez	a0,80004752 <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004728:	8552                	mv	a0,s4
    8000472a:	f8cfd0ef          	jal	80001eb6 <sleep_prepare>
    release(&pi->lock);
    8000472e:	8526                	mv	a0,s1
    80004730:	cecfc0ef          	jal	80000c1c <release>
    sleep();
    80004734:	fbefd0ef          	jal	80001ef2 <sleep>
    acquire(&pi->lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	c56fc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000473e:	2184a703          	lw	a4,536(s1)
    80004742:	21c4a783          	lw	a5,540(s1)
    80004746:	fcf70ae3          	beq	a4,a5,8000471a <piperead+0x34>
    8000474a:	e85a                	sd	s6,16(sp)
    8000474c:	a809                	j	8000475e <piperead+0x78>
    8000474e:	e85a                	sd	s6,16(sp)
    80004750:	a039                	j	8000475e <piperead+0x78>
      release(&pi->lock);
    80004752:	8526                	mv	a0,s1
    80004754:	cc8fc0ef          	jal	80000c1c <release>
      return -1;
    80004758:	5a7d                	li	s4,-1
    8000475a:	a08d                	j	800047bc <piperead+0xd6>
    8000475c:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000475e:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004760:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004762:	05505563          	blez	s5,800047ac <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    80004766:	2184a783          	lw	a5,536(s1)
    8000476a:	21c4a703          	lw	a4,540(s1)
    8000476e:	02f70f63          	beq	a4,a5,800047ac <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004772:	1ff7f793          	andi	a5,a5,511
    80004776:	97a6                	add	a5,a5,s1
    80004778:	0187c783          	lbu	a5,24(a5)
    8000477c:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004780:	4705                	li	a4,1
    80004782:	fbf40693          	addi	a3,s0,-65
    80004786:	864e                	mv	a2,s3
    80004788:	04893583          	ld	a1,72(s2)
    8000478c:	05093503          	ld	a0,80(s2)
    80004790:	d4bfc0ef          	jal	800014da <copyout>
    80004794:	03650e63          	beq	a0,s6,800047d0 <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004798:	2184a783          	lw	a5,536(s1)
    8000479c:	2785                	addiw	a5,a5,1
    8000479e:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800047a2:	2a05                	addiw	s4,s4,1
    800047a4:	0985                	addi	s3,s3,1
    800047a6:	fd4a90e3          	bne	s5,s4,80004766 <piperead+0x80>
    800047aa:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800047ac:	21c48513          	addi	a0,s1,540
    800047b0:	f72fd0ef          	jal	80001f22 <wakeup>
  release(&pi->lock);
    800047b4:	8526                	mv	a0,s1
    800047b6:	c66fc0ef          	jal	80000c1c <release>
    800047ba:	6b42                	ld	s6,16(sp)
  return i;
}
    800047bc:	8552                	mv	a0,s4
    800047be:	60a6                	ld	ra,72(sp)
    800047c0:	6406                	ld	s0,64(sp)
    800047c2:	74e2                	ld	s1,56(sp)
    800047c4:	7942                	ld	s2,48(sp)
    800047c6:	79a2                	ld	s3,40(sp)
    800047c8:	7a02                	ld	s4,32(sp)
    800047ca:	6ae2                	ld	s5,24(sp)
    800047cc:	6161                	addi	sp,sp,80
    800047ce:	8082                	ret
      if (i == 0)
    800047d0:	fc0a1ee3          	bnez	s4,800047ac <piperead+0xc6>
        i = -1;
    800047d4:	8a2a                	mv	s4,a0
    800047d6:	bfd9                	j	800047ac <piperead+0xc6>

00000000800047d8 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800047d8:	1141                	addi	sp,sp,-16
    800047da:	e422                	sd	s0,8(sp)
    800047dc:	0800                	addi	s0,sp,16
    800047de:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800047e0:	8905                	andi	a0,a0,1
    800047e2:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    800047e4:	8b89                	andi	a5,a5,2
    800047e6:	c399                	beqz	a5,800047ec <flags2perm+0x14>
    perm |= PTE_W;
    800047e8:	00456513          	ori	a0,a0,4
  return perm;
}
    800047ec:	6422                	ld	s0,8(sp)
    800047ee:	0141                	addi	sp,sp,16
    800047f0:	8082                	ret

00000000800047f2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047f2:	df010113          	addi	sp,sp,-528
    800047f6:	20113423          	sd	ra,520(sp)
    800047fa:	20813023          	sd	s0,512(sp)
    800047fe:	ffa6                	sd	s1,504(sp)
    80004800:	fbca                	sd	s2,496(sp)
    80004802:	0c00                	addi	s0,sp,528
    80004804:	892a                	mv	s2,a0
    80004806:	dea43c23          	sd	a0,-520(s0)
    8000480a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000480e:	896fd0ef          	jal	800018a4 <myproc>
    80004812:	84aa                	mv	s1,a0

  begin_op();
    80004814:	ce2ff0ef          	jal	80003cf6 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004818:	854a                	mv	a0,s2
    8000481a:	b08ff0ef          	jal	80003b22 <namei>
    8000481e:	c931                	beqz	a0,80004872 <kexec+0x80>
    80004820:	f3d2                	sd	s4,480(sp)
    80004822:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004824:	a8bfe0ef          	jal	800032ae <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004828:	04000713          	li	a4,64
    8000482c:	4681                	li	a3,0
    8000482e:	e5040613          	addi	a2,s0,-432
    80004832:	4581                	li	a1,0
    80004834:	8552                	mv	a0,s4
    80004836:	e51fe0ef          	jal	80003686 <readi>
    8000483a:	04000793          	li	a5,64
    8000483e:	00f51a63          	bne	a0,a5,80004852 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004842:	e5042703          	lw	a4,-432(s0)
    80004846:	464c47b7          	lui	a5,0x464c4
    8000484a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000484e:	02f70663          	beq	a4,a5,8000487a <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004852:	8552                	mv	a0,s4
    80004854:	cadfe0ef          	jal	80003500 <iunlockput>
    end_op();
    80004858:	d24ff0ef          	jal	80003d7c <end_op>
  }
  return -1;
    8000485c:	557d                	li	a0,-1
    8000485e:	7a1e                	ld	s4,480(sp)
}
    80004860:	20813083          	ld	ra,520(sp)
    80004864:	20013403          	ld	s0,512(sp)
    80004868:	74fe                	ld	s1,504(sp)
    8000486a:	795e                	ld	s2,496(sp)
    8000486c:	21010113          	addi	sp,sp,528
    80004870:	8082                	ret
    end_op();
    80004872:	d0aff0ef          	jal	80003d7c <end_op>
    return -1;
    80004876:	557d                	li	a0,-1
    80004878:	b7e5                	j	80004860 <kexec+0x6e>
    8000487a:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    8000487c:	8526                	mv	a0,s1
    8000487e:	936fd0ef          	jal	800019b4 <proc_pagetable>
    80004882:	8b2a                	mv	s6,a0
    80004884:	2c050963          	beqz	a0,80004b56 <kexec+0x364>
    80004888:	f7ce                	sd	s3,488(sp)
    8000488a:	efd6                	sd	s5,472(sp)
    8000488c:	e7de                	sd	s7,456(sp)
    8000488e:	e3e2                	sd	s8,448(sp)
    80004890:	ff66                	sd	s9,440(sp)
    80004892:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004894:	e7042d03          	lw	s10,-400(s0)
    80004898:	e8845783          	lhu	a5,-376(s0)
    8000489c:	12078863          	beqz	a5,800049cc <kexec+0x1da>
    800048a0:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048a2:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800048a4:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    800048a6:	6c85                	lui	s9,0x1
    800048a8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048ac:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800048b0:	6a85                	lui	s5,0x1
    800048b2:	a085                	j	80004912 <kexec+0x120>
      panic("loadseg: address should exist");
    800048b4:	00003517          	auipc	a0,0x3
    800048b8:	d0c50513          	addi	a0,a0,-756 # 800075c0 <etext+0x5c0>
    800048bc:	f35fb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    800048c0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800048c2:	8726                	mv	a4,s1
    800048c4:	012c06bb          	addw	a3,s8,s2
    800048c8:	4581                	li	a1,0
    800048ca:	8552                	mv	a0,s4
    800048cc:	dbbfe0ef          	jal	80003686 <readi>
    800048d0:	2501                	sext.w	a0,a0
    800048d2:	24a49863          	bne	s1,a0,80004b22 <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    800048d6:	012a893b          	addw	s2,s5,s2
    800048da:	03397363          	bgeu	s2,s3,80004900 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800048de:	02091593          	slli	a1,s2,0x20
    800048e2:	9181                	srli	a1,a1,0x20
    800048e4:	95de                	add	a1,a1,s7
    800048e6:	855a                	mv	a0,s6
    800048e8:	e7efc0ef          	jal	80000f66 <walkaddr>
    800048ec:	862a                	mv	a2,a0
    if (pa == 0)
    800048ee:	d179                	beqz	a0,800048b4 <kexec+0xc2>
    if (sz - i < PGSIZE)
    800048f0:	412984bb          	subw	s1,s3,s2
    800048f4:	0004879b          	sext.w	a5,s1
    800048f8:	fcfcf4e3          	bgeu	s9,a5,800048c0 <kexec+0xce>
    800048fc:	84d6                	mv	s1,s5
    800048fe:	b7c9                	j	800048c0 <kexec+0xce>
    sz = sz1;
    80004900:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004904:	2d85                	addiw	s11,s11,1
    80004906:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000490a:	e8845783          	lhu	a5,-376(s0)
    8000490e:	08fdd063          	bge	s11,a5,8000498e <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004912:	2d01                	sext.w	s10,s10
    80004914:	03800713          	li	a4,56
    80004918:	86ea                	mv	a3,s10
    8000491a:	e1840613          	addi	a2,s0,-488
    8000491e:	4581                	li	a1,0
    80004920:	8552                	mv	a0,s4
    80004922:	d65fe0ef          	jal	80003686 <readi>
    80004926:	03800793          	li	a5,56
    8000492a:	1cf51463          	bne	a0,a5,80004af2 <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    8000492e:	e1842783          	lw	a5,-488(s0)
    80004932:	4705                	li	a4,1
    80004934:	fce798e3          	bne	a5,a4,80004904 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004938:	e4043483          	ld	s1,-448(s0)
    8000493c:	e3843783          	ld	a5,-456(s0)
    80004940:	1af4ed63          	bltu	s1,a5,80004afa <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004944:	e2843783          	ld	a5,-472(s0)
    80004948:	94be                	add	s1,s1,a5
    8000494a:	1af4ec63          	bltu	s1,a5,80004b02 <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    8000494e:	df043703          	ld	a4,-528(s0)
    80004952:	8ff9                	and	a5,a5,a4
    80004954:	1a079b63          	bnez	a5,80004b0a <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004958:	e1c42503          	lw	a0,-484(s0)
    8000495c:	e7dff0ef          	jal	800047d8 <flags2perm>
    80004960:	86aa                	mv	a3,a0
    80004962:	8626                	mv	a2,s1
    80004964:	85ca                	mv	a1,s2
    80004966:	855a                	mv	a0,s6
    80004968:	8d7fc0ef          	jal	8000123e <uvmalloc>
    8000496c:	e0a43423          	sd	a0,-504(s0)
    80004970:	1a050163          	beqz	a0,80004b12 <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004974:	e2843b83          	ld	s7,-472(s0)
    80004978:	e2042c03          	lw	s8,-480(s0)
    8000497c:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004980:	00098463          	beqz	s3,80004988 <kexec+0x196>
    80004984:	4901                	li	s2,0
    80004986:	bfa1                	j	800048de <kexec+0xec>
    sz = sz1;
    80004988:	e0843903          	ld	s2,-504(s0)
    8000498c:	bfa5                	j	80004904 <kexec+0x112>
    8000498e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004990:	8552                	mv	a0,s4
    80004992:	b6ffe0ef          	jal	80003500 <iunlockput>
  end_op();
    80004996:	be6ff0ef          	jal	80003d7c <end_op>
  p = myproc();
    8000499a:	f0bfc0ef          	jal	800018a4 <myproc>
    8000499e:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    800049a0:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    800049a4:	6b85                	lui	s7,0x1
    800049a6:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    800049a8:	9bca                	add	s7,s7,s2
    800049aa:	77fd                	lui	a5,0xfffff
    800049ac:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800049b0:	4691                	li	a3,4
    800049b2:	6609                	lui	a2,0x2
    800049b4:	965e                	add	a2,a2,s7
    800049b6:	85de                	mv	a1,s7
    800049b8:	855a                	mv	a0,s6
    800049ba:	885fc0ef          	jal	8000123e <uvmalloc>
    800049be:	e0a43423          	sd	a0,-504(s0)
    800049c2:	e519                	bnez	a0,800049d0 <kexec+0x1de>
  if (pagetable)
    800049c4:	e1743423          	sd	s7,-504(s0)
    800049c8:	4a01                	li	s4,0
    800049ca:	aaa9                	j	80004b24 <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049cc:	4901                	li	s2,0
    800049ce:	b7c9                	j	80004990 <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800049d0:	75f9                	lui	a1,0xffffe
    800049d2:	8baa                	mv	s7,a0
    800049d4:	95aa                	add	a1,a1,a0
    800049d6:	855a                	mv	a0,s6
    800049d8:	a3dfc0ef          	jal	80001414 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    800049dc:	7afd                	lui	s5,0xfffff
    800049de:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    800049e0:	e0043783          	ld	a5,-512(s0)
    800049e4:	6388                	ld	a0,0(a5)
    800049e6:	c15d                	beqz	a0,80004a8c <kexec+0x29a>
    800049e8:	e9040913          	addi	s2,s0,-368
    800049ec:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800049ee:	bd6fc0ef          	jal	80000dc4 <strlen>
    800049f2:	0015079b          	addiw	a5,a0,1
    800049f6:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800049fa:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    800049fe:	115bee63          	bltu	s7,s5,80004b1a <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a02:	e0043c83          	ld	s9,-512(s0)
    80004a06:	000cbc03          	ld	s8,0(s9)
    80004a0a:	8562                	mv	a0,s8
    80004a0c:	bb8fc0ef          	jal	80000dc4 <strlen>
    80004a10:	0015071b          	addiw	a4,a0,1
    80004a14:	86e2                	mv	a3,s8
    80004a16:	865e                	mv	a2,s7
    80004a18:	e0843583          	ld	a1,-504(s0)
    80004a1c:	855a                	mv	a0,s6
    80004a1e:	abdfc0ef          	jal	800014da <copyout>
    80004a22:	0e054e63          	bltz	a0,80004b1e <kexec+0x32c>
    ustack[argc] = sp;
    80004a26:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004a2a:	0485                	addi	s1,s1,1
    80004a2c:	008c8793          	addi	a5,s9,8
    80004a30:	e0f43023          	sd	a5,-512(s0)
    80004a34:	008cb503          	ld	a0,8(s9)
    80004a38:	0921                	addi	s2,s2,8
    80004a3a:	f955                	bnez	a0,800049ee <kexec+0x1fc>
  ustack[argc] = 0;
    80004a3c:	00349793          	slli	a5,s1,0x3
    80004a40:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde3e0>
    80004a44:	97a2                	add	a5,a5,s0
    80004a46:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004a4a:	00148713          	addi	a4,s1,1
    80004a4e:	070e                	slli	a4,a4,0x3
    80004a50:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    80004a54:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a58:	e0843583          	ld	a1,-504(s0)
    80004a5c:	8bae                	mv	s7,a1
  if (sp < stackbase)
    80004a5e:	f75963e3          	bltu	s2,s5,800049c4 <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004a62:	e9040693          	addi	a3,s0,-368
    80004a66:	864a                	mv	a2,s2
    80004a68:	855a                	mv	a0,s6
    80004a6a:	a71fc0ef          	jal	800014da <copyout>
    80004a6e:	0e054663          	bltz	a0,80004b5a <kexec+0x368>
  p->trapframe->a1 = sp;
    80004a72:	0589b783          	ld	a5,88(s3)
    80004a76:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004a7a:	df843783          	ld	a5,-520(s0)
    80004a7e:	0007c703          	lbu	a4,0(a5)
    80004a82:	c315                	beqz	a4,80004aa6 <kexec+0x2b4>
    80004a84:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004a86:	02f00693          	li	a3,47
    80004a8a:	a809                	j	80004a9c <kexec+0x2aa>
  sp = sz;
    80004a8c:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004a90:	4481                	li	s1,0
    80004a92:	b76d                	j	80004a3c <kexec+0x24a>
  for (last = s = path; *s; s++)
    80004a94:	0785                	addi	a5,a5,1
    80004a96:	fff7c703          	lbu	a4,-1(a5)
    80004a9a:	c711                	beqz	a4,80004aa6 <kexec+0x2b4>
    if (*s == '/')
    80004a9c:	fed71ce3          	bne	a4,a3,80004a94 <kexec+0x2a2>
      last = s + 1;
    80004aa0:	def43c23          	sd	a5,-520(s0)
    80004aa4:	bfc5                	j	80004a94 <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004aa6:	4641                	li	a2,16
    80004aa8:	df843583          	ld	a1,-520(s0)
    80004aac:	15898513          	addi	a0,s3,344
    80004ab0:	ae2fc0ef          	jal	80000d92 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ab4:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004ab8:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004abc:	e0843783          	ld	a5,-504(s0)
    80004ac0:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ac4:	0589b783          	ld	a5,88(s3)
    80004ac8:	e6843703          	ld	a4,-408(s0)
    80004acc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004ace:	0589b783          	ld	a5,88(s3)
    80004ad2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ad6:	85d2                	mv	a1,s4
    80004ad8:	f61fc0ef          	jal	80001a38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004adc:	0004851b          	sext.w	a0,s1
    80004ae0:	79be                	ld	s3,488(sp)
    80004ae2:	7a1e                	ld	s4,480(sp)
    80004ae4:	6afe                	ld	s5,472(sp)
    80004ae6:	6b5e                	ld	s6,464(sp)
    80004ae8:	6bbe                	ld	s7,456(sp)
    80004aea:	6c1e                	ld	s8,448(sp)
    80004aec:	7cfa                	ld	s9,440(sp)
    80004aee:	7d5a                	ld	s10,432(sp)
    80004af0:	bb85                	j	80004860 <kexec+0x6e>
    80004af2:	e1243423          	sd	s2,-504(s0)
    80004af6:	7dba                	ld	s11,424(sp)
    80004af8:	a035                	j	80004b24 <kexec+0x332>
    80004afa:	e1243423          	sd	s2,-504(s0)
    80004afe:	7dba                	ld	s11,424(sp)
    80004b00:	a015                	j	80004b24 <kexec+0x332>
    80004b02:	e1243423          	sd	s2,-504(s0)
    80004b06:	7dba                	ld	s11,424(sp)
    80004b08:	a831                	j	80004b24 <kexec+0x332>
    80004b0a:	e1243423          	sd	s2,-504(s0)
    80004b0e:	7dba                	ld	s11,424(sp)
    80004b10:	a811                	j	80004b24 <kexec+0x332>
    80004b12:	e1243423          	sd	s2,-504(s0)
    80004b16:	7dba                	ld	s11,424(sp)
    80004b18:	a031                	j	80004b24 <kexec+0x332>
  ip = 0;
    80004b1a:	4a01                	li	s4,0
    80004b1c:	a021                	j	80004b24 <kexec+0x332>
    80004b1e:	4a01                	li	s4,0
  if (pagetable)
    80004b20:	a011                	j	80004b24 <kexec+0x332>
    80004b22:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004b24:	e0843583          	ld	a1,-504(s0)
    80004b28:	855a                	mv	a0,s6
    80004b2a:	f0ffc0ef          	jal	80001a38 <proc_freepagetable>
  return -1;
    80004b2e:	557d                	li	a0,-1
  if (ip) {
    80004b30:	000a1b63          	bnez	s4,80004b46 <kexec+0x354>
    80004b34:	79be                	ld	s3,488(sp)
    80004b36:	7a1e                	ld	s4,480(sp)
    80004b38:	6afe                	ld	s5,472(sp)
    80004b3a:	6b5e                	ld	s6,464(sp)
    80004b3c:	6bbe                	ld	s7,456(sp)
    80004b3e:	6c1e                	ld	s8,448(sp)
    80004b40:	7cfa                	ld	s9,440(sp)
    80004b42:	7d5a                	ld	s10,432(sp)
    80004b44:	bb31                	j	80004860 <kexec+0x6e>
    80004b46:	79be                	ld	s3,488(sp)
    80004b48:	6afe                	ld	s5,472(sp)
    80004b4a:	6b5e                	ld	s6,464(sp)
    80004b4c:	6bbe                	ld	s7,456(sp)
    80004b4e:	6c1e                	ld	s8,448(sp)
    80004b50:	7cfa                	ld	s9,440(sp)
    80004b52:	7d5a                	ld	s10,432(sp)
    80004b54:	b9fd                	j	80004852 <kexec+0x60>
    80004b56:	6b5e                	ld	s6,464(sp)
    80004b58:	b9ed                	j	80004852 <kexec+0x60>
  sz = sz1;
    80004b5a:	e0843b83          	ld	s7,-504(s0)
    80004b5e:	b59d                	j	800049c4 <kexec+0x1d2>

0000000080004b60 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b60:	7179                	addi	sp,sp,-48
    80004b62:	f406                	sd	ra,40(sp)
    80004b64:	f022                	sd	s0,32(sp)
    80004b66:	ec26                	sd	s1,24(sp)
    80004b68:	e84a                	sd	s2,16(sp)
    80004b6a:	1800                	addi	s0,sp,48
    80004b6c:	892e                	mv	s2,a1
    80004b6e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b70:	fdc40593          	addi	a1,s0,-36
    80004b74:	cc1fd0ef          	jal	80002834 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004b78:	fdc42703          	lw	a4,-36(s0)
    80004b7c:	47bd                	li	a5,15
    80004b7e:	02e7e963          	bltu	a5,a4,80004bb0 <argfd+0x50>
    80004b82:	d23fc0ef          	jal	800018a4 <myproc>
    80004b86:	fdc42703          	lw	a4,-36(s0)
    80004b8a:	01a70793          	addi	a5,a4,26
    80004b8e:	078e                	slli	a5,a5,0x3
    80004b90:	953e                	add	a0,a0,a5
    80004b92:	611c                	ld	a5,0(a0)
    80004b94:	c385                	beqz	a5,80004bb4 <argfd+0x54>
    return -1;
  if (pfd)
    80004b96:	00090463          	beqz	s2,80004b9e <argfd+0x3e>
    *pfd = fd;
    80004b9a:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004b9e:	4501                	li	a0,0
  if (pf)
    80004ba0:	c091                	beqz	s1,80004ba4 <argfd+0x44>
    *pf = f;
    80004ba2:	e09c                	sd	a5,0(s1)
}
    80004ba4:	70a2                	ld	ra,40(sp)
    80004ba6:	7402                	ld	s0,32(sp)
    80004ba8:	64e2                	ld	s1,24(sp)
    80004baa:	6942                	ld	s2,16(sp)
    80004bac:	6145                	addi	sp,sp,48
    80004bae:	8082                	ret
    return -1;
    80004bb0:	557d                	li	a0,-1
    80004bb2:	bfcd                	j	80004ba4 <argfd+0x44>
    80004bb4:	557d                	li	a0,-1
    80004bb6:	b7fd                	j	80004ba4 <argfd+0x44>

0000000080004bb8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004bb8:	1101                	addi	sp,sp,-32
    80004bba:	ec06                	sd	ra,24(sp)
    80004bbc:	e822                	sd	s0,16(sp)
    80004bbe:	e426                	sd	s1,8(sp)
    80004bc0:	1000                	addi	s0,sp,32
    80004bc2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004bc4:	ce1fc0ef          	jal	800018a4 <myproc>
    80004bc8:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004bca:	0d050793          	addi	a5,a0,208
    80004bce:	4501                	li	a0,0
    80004bd0:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004bd2:	6398                	ld	a4,0(a5)
    80004bd4:	cb19                	beqz	a4,80004bea <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004bd6:	2505                	addiw	a0,a0,1
    80004bd8:	07a1                	addi	a5,a5,8
    80004bda:	fed51ce3          	bne	a0,a3,80004bd2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bde:	557d                	li	a0,-1
}
    80004be0:	60e2                	ld	ra,24(sp)
    80004be2:	6442                	ld	s0,16(sp)
    80004be4:	64a2                	ld	s1,8(sp)
    80004be6:	6105                	addi	sp,sp,32
    80004be8:	8082                	ret
      p->ofile[fd] = f;
    80004bea:	01a50793          	addi	a5,a0,26
    80004bee:	078e                	slli	a5,a5,0x3
    80004bf0:	963e                	add	a2,a2,a5
    80004bf2:	e204                	sd	s1,0(a2)
      return fd;
    80004bf4:	b7f5                	j	80004be0 <fdalloc+0x28>

0000000080004bf6 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004bf6:	715d                	addi	sp,sp,-80
    80004bf8:	e486                	sd	ra,72(sp)
    80004bfa:	e0a2                	sd	s0,64(sp)
    80004bfc:	fc26                	sd	s1,56(sp)
    80004bfe:	f84a                	sd	s2,48(sp)
    80004c00:	f44e                	sd	s3,40(sp)
    80004c02:	f052                	sd	s4,32(sp)
    80004c04:	ec56                	sd	s5,24(sp)
    80004c06:	0880                	addi	s0,sp,80
    80004c08:	892e                	mv	s2,a1
    80004c0a:	89b2                	mv	s3,a2
    80004c0c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004c0e:	fb040593          	addi	a1,s0,-80
    80004c12:	f2bfe0ef          	jal	80003b3c <nameiparent>
    80004c16:	8aaa                	mv	s5,a0
    80004c18:	cd45                	beqz	a0,80004cd0 <create+0xda>
    return 0;

  ilock(dp);
    80004c1a:	e94fe0ef          	jal	800032ae <ilock>

  if (dp->nlink == 0) {
    80004c1e:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffde49a>
    80004c22:	cf8d                	beqz	a5,80004c5c <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c24:	4705                	li	a4,1
    80004c26:	04e91563          	bne	s2,a4,80004c70 <create+0x7a>
    80004c2a:	6721                	lui	a4,0x8
    80004c2c:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004c2e:	02e78c63          	beq	a5,a4,80004c66 <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c32:	4601                	li	a2,0
    80004c34:	fb040593          	addi	a1,s0,-80
    80004c38:	8556                	mv	a0,s5
    80004c3a:	c73fe0ef          	jal	800038ac <dirlookup>
    80004c3e:	84aa                	mv	s1,a0
    80004c40:	e951                	bnez	a0,80004cd4 <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004c42:	85ca                	mv	a1,s2
    80004c44:	000aa503          	lw	a0,0(s5)
    80004c48:	cf6fe0ef          	jal	8000313e <ialloc>
    80004c4c:	84aa                	mv	s1,a0
    80004c4e:	0c051e63          	bnez	a0,80004d2a <create+0x134>
    iunlockput(dp);
    80004c52:	8556                	mv	a0,s5
    80004c54:	8adfe0ef          	jal	80003500 <iunlockput>
    return 0;
    80004c58:	4481                	li	s1,0
    80004c5a:	a0a1                	j	80004ca2 <create+0xac>
    iunlockput(dp);
    80004c5c:	8556                	mv	a0,s5
    80004c5e:	8a3fe0ef          	jal	80003500 <iunlockput>
    return 0;
    80004c62:	4481                	li	s1,0
    80004c64:	a83d                	j	80004ca2 <create+0xac>
    iunlockput(dp);
    80004c66:	8556                	mv	a0,s5
    80004c68:	899fe0ef          	jal	80003500 <iunlockput>
    return 0;
    80004c6c:	4481                	li	s1,0
    80004c6e:	a815                	j	80004ca2 <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c70:	4601                	li	a2,0
    80004c72:	fb040593          	addi	a1,s0,-80
    80004c76:	8556                	mv	a0,s5
    80004c78:	c35fe0ef          	jal	800038ac <dirlookup>
    80004c7c:	84aa                	mv	s1,a0
    80004c7e:	c535                	beqz	a0,80004cea <create+0xf4>
    iunlockput(dp);
    80004c80:	8556                	mv	a0,s5
    80004c82:	87ffe0ef          	jal	80003500 <iunlockput>
    ilock(ip);
    80004c86:	8526                	mv	a0,s1
    80004c88:	e26fe0ef          	jal	800032ae <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c8c:	4789                	li	a5,2
    80004c8e:	04f91963          	bne	s2,a5,80004ce0 <create+0xea>
    80004c92:	0444d783          	lhu	a5,68(s1)
    80004c96:	37f9                	addiw	a5,a5,-2
    80004c98:	17c2                	slli	a5,a5,0x30
    80004c9a:	93c1                	srli	a5,a5,0x30
    80004c9c:	4705                	li	a4,1
    80004c9e:	04f76163          	bltu	a4,a5,80004ce0 <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	60a6                	ld	ra,72(sp)
    80004ca6:	6406                	ld	s0,64(sp)
    80004ca8:	74e2                	ld	s1,56(sp)
    80004caa:	7942                	ld	s2,48(sp)
    80004cac:	79a2                	ld	s3,40(sp)
    80004cae:	7a02                	ld	s4,32(sp)
    80004cb0:	6ae2                	ld	s5,24(sp)
    80004cb2:	6161                	addi	sp,sp,80
    80004cb4:	8082                	ret
  ip->nlink = 0;
    80004cb6:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80004cba:	8526                	mv	a0,s1
    80004cbc:	d3efe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	83ffe0ef          	jal	80003500 <iunlockput>
  iunlockput(dp);
    80004cc6:	8556                	mv	a0,s5
    80004cc8:	839fe0ef          	jal	80003500 <iunlockput>
  return 0;
    80004ccc:	4481                	li	s1,0
    80004cce:	bfd1                	j	80004ca2 <create+0xac>
    return 0;
    80004cd0:	84aa                	mv	s1,a0
    80004cd2:	bfc1                	j	80004ca2 <create+0xac>
    iunlockput(dp);
    80004cd4:	8556                	mv	a0,s5
    80004cd6:	82bfe0ef          	jal	80003500 <iunlockput>
    ilock(ip);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	dd2fe0ef          	jal	800032ae <ilock>
    iunlockput(ip);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	81ffe0ef          	jal	80003500 <iunlockput>
    return 0;
    80004ce6:	4481                	li	s1,0
    80004ce8:	bf6d                	j	80004ca2 <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004cea:	85ca                	mv	a1,s2
    80004cec:	000aa503          	lw	a0,0(s5)
    80004cf0:	c4efe0ef          	jal	8000313e <ialloc>
    80004cf4:	84aa                	mv	s1,a0
    80004cf6:	dd31                	beqz	a0,80004c52 <create+0x5c>
  ilock(ip);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	db4fe0ef          	jal	800032ae <ilock>
  ip->major = major;
    80004cfe:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004d02:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004d06:	4785                	li	a5,1
    80004d08:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	cecfe0ef          	jal	800031fa <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d12:	40d0                	lw	a2,4(s1)
    80004d14:	fb040593          	addi	a1,s0,-80
    80004d18:	8556                	mv	a0,s5
    80004d1a:	d6ffe0ef          	jal	80003a88 <dirlink>
    80004d1e:	f8054ce3          	bltz	a0,80004cb6 <create+0xc0>
  iunlockput(dp);
    80004d22:	8556                	mv	a0,s5
    80004d24:	fdcfe0ef          	jal	80003500 <iunlockput>
  return ip;
    80004d28:	bfad                	j	80004ca2 <create+0xac>
  ilock(ip);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	d82fe0ef          	jal	800032ae <ilock>
  ip->major = major;
    80004d30:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004d34:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004d38:	4785                	li	a5,1
    80004d3a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d3e:	8526                	mv	a0,s1
    80004d40:	cbafe0ef          	jal	800031fa <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d44:	40d0                	lw	a2,4(s1)
    80004d46:	00003597          	auipc	a1,0x3
    80004d4a:	8a258593          	addi	a1,a1,-1886 # 800075e8 <etext+0x5e8>
    80004d4e:	8526                	mv	a0,s1
    80004d50:	d39fe0ef          	jal	80003a88 <dirlink>
    80004d54:	f60541e3          	bltz	a0,80004cb6 <create+0xc0>
    80004d58:	004aa603          	lw	a2,4(s5)
    80004d5c:	00003597          	auipc	a1,0x3
    80004d60:	88458593          	addi	a1,a1,-1916 # 800075e0 <etext+0x5e0>
    80004d64:	8526                	mv	a0,s1
    80004d66:	d23fe0ef          	jal	80003a88 <dirlink>
    80004d6a:	f40546e3          	bltz	a0,80004cb6 <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d6e:	40d0                	lw	a2,4(s1)
    80004d70:	fb040593          	addi	a1,s0,-80
    80004d74:	8556                	mv	a0,s5
    80004d76:	d13fe0ef          	jal	80003a88 <dirlink>
    80004d7a:	f2054ee3          	bltz	a0,80004cb6 <create+0xc0>
    dp->nlink++; // for ".."
    80004d7e:	04aad783          	lhu	a5,74(s5)
    80004d82:	2785                	addiw	a5,a5,1
    80004d84:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    80004d88:	8556                	mv	a0,s5
    80004d8a:	c70fe0ef          	jal	800031fa <iupdate>
    80004d8e:	bf51                	j	80004d22 <create+0x12c>

0000000080004d90 <sys_dup>:
{
    80004d90:	7179                	addi	sp,sp,-48
    80004d92:	f406                	sd	ra,40(sp)
    80004d94:	f022                	sd	s0,32(sp)
    80004d96:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004d98:	fd840613          	addi	a2,s0,-40
    80004d9c:	4581                	li	a1,0
    80004d9e:	4501                	li	a0,0
    80004da0:	dc1ff0ef          	jal	80004b60 <argfd>
    return -1;
    80004da4:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004da6:	02054363          	bltz	a0,80004dcc <sys_dup+0x3c>
    80004daa:	ec26                	sd	s1,24(sp)
    80004dac:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004dae:	fd843903          	ld	s2,-40(s0)
    80004db2:	854a                	mv	a0,s2
    80004db4:	e05ff0ef          	jal	80004bb8 <fdalloc>
    80004db8:	84aa                	mv	s1,a0
    return -1;
    80004dba:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004dbc:	00054d63          	bltz	a0,80004dd6 <sys_dup+0x46>
  filedup(f);
    80004dc0:	854a                	mv	a0,s2
    80004dc2:	b9aff0ef          	jal	8000415c <filedup>
  return fd;
    80004dc6:	87a6                	mv	a5,s1
    80004dc8:	64e2                	ld	s1,24(sp)
    80004dca:	6942                	ld	s2,16(sp)
}
    80004dcc:	853e                	mv	a0,a5
    80004dce:	70a2                	ld	ra,40(sp)
    80004dd0:	7402                	ld	s0,32(sp)
    80004dd2:	6145                	addi	sp,sp,48
    80004dd4:	8082                	ret
    80004dd6:	64e2                	ld	s1,24(sp)
    80004dd8:	6942                	ld	s2,16(sp)
    80004dda:	bfcd                	j	80004dcc <sys_dup+0x3c>

0000000080004ddc <sys_read>:
{
    80004ddc:	7179                	addi	sp,sp,-48
    80004dde:	f406                	sd	ra,40(sp)
    80004de0:	f022                	sd	s0,32(sp)
    80004de2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004de4:	fd840593          	addi	a1,s0,-40
    80004de8:	4505                	li	a0,1
    80004dea:	a67fd0ef          	jal	80002850 <argaddr>
  argint(2, &n);
    80004dee:	fe440593          	addi	a1,s0,-28
    80004df2:	4509                	li	a0,2
    80004df4:	a41fd0ef          	jal	80002834 <argint>
  if (argfd(0, 0, &f) < 0)
    80004df8:	fe840613          	addi	a2,s0,-24
    80004dfc:	4581                	li	a1,0
    80004dfe:	4501                	li	a0,0
    80004e00:	d61ff0ef          	jal	80004b60 <argfd>
    80004e04:	87aa                	mv	a5,a0
    return -1;
    80004e06:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e08:	0007ca63          	bltz	a5,80004e1c <sys_read+0x40>
  return fileread(f, p, n);
    80004e0c:	fe442603          	lw	a2,-28(s0)
    80004e10:	fd843583          	ld	a1,-40(s0)
    80004e14:	fe843503          	ld	a0,-24(s0)
    80004e18:	caeff0ef          	jal	800042c6 <fileread>
}
    80004e1c:	70a2                	ld	ra,40(sp)
    80004e1e:	7402                	ld	s0,32(sp)
    80004e20:	6145                	addi	sp,sp,48
    80004e22:	8082                	ret

0000000080004e24 <sys_write>:
{
    80004e24:	7179                	addi	sp,sp,-48
    80004e26:	f406                	sd	ra,40(sp)
    80004e28:	f022                	sd	s0,32(sp)
    80004e2a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e2c:	fd840593          	addi	a1,s0,-40
    80004e30:	4505                	li	a0,1
    80004e32:	a1ffd0ef          	jal	80002850 <argaddr>
  argint(2, &n);
    80004e36:	fe440593          	addi	a1,s0,-28
    80004e3a:	4509                	li	a0,2
    80004e3c:	9f9fd0ef          	jal	80002834 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e40:	fe840613          	addi	a2,s0,-24
    80004e44:	4581                	li	a1,0
    80004e46:	4501                	li	a0,0
    80004e48:	d19ff0ef          	jal	80004b60 <argfd>
    80004e4c:	87aa                	mv	a5,a0
    return -1;
    80004e4e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e50:	0007ca63          	bltz	a5,80004e64 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e54:	fe442603          	lw	a2,-28(s0)
    80004e58:	fd843583          	ld	a1,-40(s0)
    80004e5c:	fe843503          	ld	a0,-24(s0)
    80004e60:	d30ff0ef          	jal	80004390 <filewrite>
}
    80004e64:	70a2                	ld	ra,40(sp)
    80004e66:	7402                	ld	s0,32(sp)
    80004e68:	6145                	addi	sp,sp,48
    80004e6a:	8082                	ret

0000000080004e6c <sys_close>:
{
    80004e6c:	1101                	addi	sp,sp,-32
    80004e6e:	ec06                	sd	ra,24(sp)
    80004e70:	e822                	sd	s0,16(sp)
    80004e72:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004e74:	fe040613          	addi	a2,s0,-32
    80004e78:	fec40593          	addi	a1,s0,-20
    80004e7c:	4501                	li	a0,0
    80004e7e:	ce3ff0ef          	jal	80004b60 <argfd>
    return -1;
    80004e82:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004e84:	02054063          	bltz	a0,80004ea4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e88:	a1dfc0ef          	jal	800018a4 <myproc>
    80004e8c:	fec42783          	lw	a5,-20(s0)
    80004e90:	07e9                	addi	a5,a5,26
    80004e92:	078e                	slli	a5,a5,0x3
    80004e94:	953e                	add	a0,a0,a5
    80004e96:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e9a:	fe043503          	ld	a0,-32(s0)
    80004e9e:	b04ff0ef          	jal	800041a2 <fileclose>
  return 0;
    80004ea2:	4781                	li	a5,0
}
    80004ea4:	853e                	mv	a0,a5
    80004ea6:	60e2                	ld	ra,24(sp)
    80004ea8:	6442                	ld	s0,16(sp)
    80004eaa:	6105                	addi	sp,sp,32
    80004eac:	8082                	ret

0000000080004eae <sys_fstat>:
{
    80004eae:	1101                	addi	sp,sp,-32
    80004eb0:	ec06                	sd	ra,24(sp)
    80004eb2:	e822                	sd	s0,16(sp)
    80004eb4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004eb6:	fe040593          	addi	a1,s0,-32
    80004eba:	4505                	li	a0,1
    80004ebc:	995fd0ef          	jal	80002850 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004ec0:	fe840613          	addi	a2,s0,-24
    80004ec4:	4581                	li	a1,0
    80004ec6:	4501                	li	a0,0
    80004ec8:	c99ff0ef          	jal	80004b60 <argfd>
    80004ecc:	87aa                	mv	a5,a0
    return -1;
    80004ece:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ed0:	0007c863          	bltz	a5,80004ee0 <sys_fstat+0x32>
  return filestat(f, st);
    80004ed4:	fe043583          	ld	a1,-32(s0)
    80004ed8:	fe843503          	ld	a0,-24(s0)
    80004edc:	b88ff0ef          	jal	80004264 <filestat>
}
    80004ee0:	60e2                	ld	ra,24(sp)
    80004ee2:	6442                	ld	s0,16(sp)
    80004ee4:	6105                	addi	sp,sp,32
    80004ee6:	8082                	ret

0000000080004ee8 <sys_link>:
{
    80004ee8:	7169                	addi	sp,sp,-304
    80004eea:	f606                	sd	ra,296(sp)
    80004eec:	f222                	sd	s0,288(sp)
    80004eee:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ef0:	08000613          	li	a2,128
    80004ef4:	ed040593          	addi	a1,s0,-304
    80004ef8:	4501                	li	a0,0
    80004efa:	973fd0ef          	jal	8000286c <argstr>
    return -1;
    80004efe:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f00:	10054163          	bltz	a0,80005002 <sys_link+0x11a>
    80004f04:	08000613          	li	a2,128
    80004f08:	f5040593          	addi	a1,s0,-176
    80004f0c:	4505                	li	a0,1
    80004f0e:	95ffd0ef          	jal	8000286c <argstr>
    return -1;
    80004f12:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f14:	0e054763          	bltz	a0,80005002 <sys_link+0x11a>
    80004f18:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f1a:	dddfe0ef          	jal	80003cf6 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004f1e:	ed040513          	addi	a0,s0,-304
    80004f22:	c01fe0ef          	jal	80003b22 <namei>
    80004f26:	84aa                	mv	s1,a0
    80004f28:	cd35                	beqz	a0,80004fa4 <sys_link+0xbc>
  ilock(ip);
    80004f2a:	b84fe0ef          	jal	800032ae <ilock>
  if (ip->type == T_DIR) {
    80004f2e:	04449703          	lh	a4,68(s1)
    80004f32:	4785                	li	a5,1
    80004f34:	06f70d63          	beq	a4,a5,80004fae <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004f38:	04a49783          	lh	a5,74(s1)
    80004f3c:	6721                	lui	a4,0x8
    80004f3e:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004f40:	06e78f63          	beq	a5,a4,80004fbe <sys_link+0xd6>
    80004f44:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f46:	2785                	addiw	a5,a5,1
    80004f48:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f4c:	8526                	mv	a0,s1
    80004f4e:	aacfe0ef          	jal	800031fa <iupdate>
  iunlock(ip);
    80004f52:	8526                	mv	a0,s1
    80004f54:	c08fe0ef          	jal	8000335c <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f58:	fd040593          	addi	a1,s0,-48
    80004f5c:	f5040513          	addi	a0,s0,-176
    80004f60:	bddfe0ef          	jal	80003b3c <nameiparent>
    80004f64:	892a                	mv	s2,a0
    80004f66:	c93d                	beqz	a0,80004fdc <sys_link+0xf4>
  ilock(dp);
    80004f68:	b46fe0ef          	jal	800032ae <ilock>
  if (dp->nlink == 0) {
    80004f6c:	04a91783          	lh	a5,74(s2)
    80004f70:	cfb9                	beqz	a5,80004fce <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004f72:	00092703          	lw	a4,0(s2)
    80004f76:	409c                	lw	a5,0(s1)
    80004f78:	04f71f63          	bne	a4,a5,80004fd6 <sys_link+0xee>
    80004f7c:	40d0                	lw	a2,4(s1)
    80004f7e:	fd040593          	addi	a1,s0,-48
    80004f82:	854a                	mv	a0,s2
    80004f84:	b05fe0ef          	jal	80003a88 <dirlink>
    80004f88:	04054763          	bltz	a0,80004fd6 <sys_link+0xee>
  iunlockput(dp);
    80004f8c:	854a                	mv	a0,s2
    80004f8e:	d72fe0ef          	jal	80003500 <iunlockput>
  iput(ip);
    80004f92:	8526                	mv	a0,s1
    80004f94:	c9cfe0ef          	jal	80003430 <iput>
  end_op();
    80004f98:	de5fe0ef          	jal	80003d7c <end_op>
  return 0;
    80004f9c:	4781                	li	a5,0
    80004f9e:	64f2                	ld	s1,280(sp)
    80004fa0:	6952                	ld	s2,272(sp)
    80004fa2:	a085                	j	80005002 <sys_link+0x11a>
    end_op();
    80004fa4:	dd9fe0ef          	jal	80003d7c <end_op>
    return -1;
    80004fa8:	57fd                	li	a5,-1
    80004faa:	64f2                	ld	s1,280(sp)
    80004fac:	a899                	j	80005002 <sys_link+0x11a>
    iunlockput(ip);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	d50fe0ef          	jal	80003500 <iunlockput>
    end_op();
    80004fb4:	dc9fe0ef          	jal	80003d7c <end_op>
    return -1;
    80004fb8:	57fd                	li	a5,-1
    80004fba:	64f2                	ld	s1,280(sp)
    80004fbc:	a099                	j	80005002 <sys_link+0x11a>
    iunlockput(ip);
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	d40fe0ef          	jal	80003500 <iunlockput>
    end_op();
    80004fc4:	db9fe0ef          	jal	80003d7c <end_op>
    return -1;
    80004fc8:	57fd                	li	a5,-1
    80004fca:	64f2                	ld	s1,280(sp)
    80004fcc:	a81d                	j	80005002 <sys_link+0x11a>
    iunlockput(dp);
    80004fce:	854a                	mv	a0,s2
    80004fd0:	d30fe0ef          	jal	80003500 <iunlockput>
    goto bad;
    80004fd4:	a021                	j	80004fdc <sys_link+0xf4>
    iunlockput(dp);
    80004fd6:	854a                	mv	a0,s2
    80004fd8:	d28fe0ef          	jal	80003500 <iunlockput>
  ilock(ip);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ad0fe0ef          	jal	800032ae <ilock>
  ip->nlink--;
    80004fe2:	04a4d783          	lhu	a5,74(s1)
    80004fe6:	37fd                	addiw	a5,a5,-1
    80004fe8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fec:	8526                	mv	a0,s1
    80004fee:	a0cfe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    80004ff2:	8526                	mv	a0,s1
    80004ff4:	d0cfe0ef          	jal	80003500 <iunlockput>
  end_op();
    80004ff8:	d85fe0ef          	jal	80003d7c <end_op>
  return -1;
    80004ffc:	57fd                	li	a5,-1
    80004ffe:	64f2                	ld	s1,280(sp)
    80005000:	6952                	ld	s2,272(sp)
}
    80005002:	853e                	mv	a0,a5
    80005004:	70b2                	ld	ra,296(sp)
    80005006:	7412                	ld	s0,288(sp)
    80005008:	6155                	addi	sp,sp,304
    8000500a:	8082                	ret

000000008000500c <sys_unlink>:
{
    8000500c:	7151                	addi	sp,sp,-240
    8000500e:	f586                	sd	ra,232(sp)
    80005010:	f1a2                	sd	s0,224(sp)
    80005012:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005014:	08000613          	li	a2,128
    80005018:	f3040593          	addi	a1,s0,-208
    8000501c:	4501                	li	a0,0
    8000501e:	84ffd0ef          	jal	8000286c <argstr>
    80005022:	16054063          	bltz	a0,80005182 <sys_unlink+0x176>
    80005026:	eda6                	sd	s1,216(sp)
  begin_op();
    80005028:	ccffe0ef          	jal	80003cf6 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000502c:	fb040593          	addi	a1,s0,-80
    80005030:	f3040513          	addi	a0,s0,-208
    80005034:	b09fe0ef          	jal	80003b3c <nameiparent>
    80005038:	84aa                	mv	s1,a0
    8000503a:	c945                	beqz	a0,800050ea <sys_unlink+0xde>
  ilock(dp);
    8000503c:	a72fe0ef          	jal	800032ae <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005040:	00002597          	auipc	a1,0x2
    80005044:	5a858593          	addi	a1,a1,1448 # 800075e8 <etext+0x5e8>
    80005048:	fb040513          	addi	a0,s0,-80
    8000504c:	84bfe0ef          	jal	80003896 <namecmp>
    80005050:	10050e63          	beqz	a0,8000516c <sys_unlink+0x160>
    80005054:	00002597          	auipc	a1,0x2
    80005058:	58c58593          	addi	a1,a1,1420 # 800075e0 <etext+0x5e0>
    8000505c:	fb040513          	addi	a0,s0,-80
    80005060:	837fe0ef          	jal	80003896 <namecmp>
    80005064:	10050463          	beqz	a0,8000516c <sys_unlink+0x160>
    80005068:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000506a:	f2c40613          	addi	a2,s0,-212
    8000506e:	fb040593          	addi	a1,s0,-80
    80005072:	8526                	mv	a0,s1
    80005074:	839fe0ef          	jal	800038ac <dirlookup>
    80005078:	892a                	mv	s2,a0
    8000507a:	0e050863          	beqz	a0,8000516a <sys_unlink+0x15e>
  ilock(ip);
    8000507e:	a30fe0ef          	jal	800032ae <ilock>
  if (ip->nlink < 1)
    80005082:	04a91783          	lh	a5,74(s2)
    80005086:	06f05763          	blez	a5,800050f4 <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000508a:	04491703          	lh	a4,68(s2)
    8000508e:	4785                	li	a5,1
    80005090:	06f70963          	beq	a4,a5,80005102 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005094:	4641                	li	a2,16
    80005096:	4581                	li	a1,0
    80005098:	fc040513          	addi	a0,s0,-64
    8000509c:	bb9fb0ef          	jal	80000c54 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050a0:	4741                	li	a4,16
    800050a2:	f2c42683          	lw	a3,-212(s0)
    800050a6:	fc040613          	addi	a2,s0,-64
    800050aa:	4581                	li	a1,0
    800050ac:	8526                	mv	a0,s1
    800050ae:	ed4fe0ef          	jal	80003782 <writei>
    800050b2:	47c1                	li	a5,16
    800050b4:	08f51b63          	bne	a0,a5,8000514a <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    800050b8:	04491703          	lh	a4,68(s2)
    800050bc:	4785                	li	a5,1
    800050be:	08f70d63          	beq	a4,a5,80005158 <sys_unlink+0x14c>
  iunlockput(dp);
    800050c2:	8526                	mv	a0,s1
    800050c4:	c3cfe0ef          	jal	80003500 <iunlockput>
  ip->nlink--;
    800050c8:	04a95783          	lhu	a5,74(s2)
    800050cc:	37fd                	addiw	a5,a5,-1
    800050ce:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050d2:	854a                	mv	a0,s2
    800050d4:	926fe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    800050d8:	854a                	mv	a0,s2
    800050da:	c26fe0ef          	jal	80003500 <iunlockput>
  end_op();
    800050de:	c9ffe0ef          	jal	80003d7c <end_op>
  return 0;
    800050e2:	4501                	li	a0,0
    800050e4:	64ee                	ld	s1,216(sp)
    800050e6:	694e                	ld	s2,208(sp)
    800050e8:	a849                	j	8000517a <sys_unlink+0x16e>
    end_op();
    800050ea:	c93fe0ef          	jal	80003d7c <end_op>
    return -1;
    800050ee:	557d                	li	a0,-1
    800050f0:	64ee                	ld	s1,216(sp)
    800050f2:	a061                	j	8000517a <sys_unlink+0x16e>
    800050f4:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800050f6:	00002517          	auipc	a0,0x2
    800050fa:	4fa50513          	addi	a0,a0,1274 # 800075f0 <etext+0x5f0>
    800050fe:	ef2fb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005102:	04c92703          	lw	a4,76(s2)
    80005106:	02000793          	li	a5,32
    8000510a:	f8e7f5e3          	bgeu	a5,a4,80005094 <sys_unlink+0x88>
    8000510e:	e5ce                	sd	s3,200(sp)
    80005110:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005114:	4741                	li	a4,16
    80005116:	86ce                	mv	a3,s3
    80005118:	f1840613          	addi	a2,s0,-232
    8000511c:	4581                	li	a1,0
    8000511e:	854a                	mv	a0,s2
    80005120:	d66fe0ef          	jal	80003686 <readi>
    80005124:	47c1                	li	a5,16
    80005126:	00f51c63          	bne	a0,a5,8000513e <sys_unlink+0x132>
    if (de.inum != 0)
    8000512a:	f1845783          	lhu	a5,-232(s0)
    8000512e:	efa1                	bnez	a5,80005186 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005130:	29c1                	addiw	s3,s3,16
    80005132:	04c92783          	lw	a5,76(s2)
    80005136:	fcf9efe3          	bltu	s3,a5,80005114 <sys_unlink+0x108>
    8000513a:	69ae                	ld	s3,200(sp)
    8000513c:	bfa1                	j	80005094 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000513e:	00002517          	auipc	a0,0x2
    80005142:	4ca50513          	addi	a0,a0,1226 # 80007608 <etext+0x608>
    80005146:	eaafb0ef          	jal	800007f0 <panic>
    8000514a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000514c:	00002517          	auipc	a0,0x2
    80005150:	4d450513          	addi	a0,a0,1236 # 80007620 <etext+0x620>
    80005154:	e9cfb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    80005158:	04a4d783          	lhu	a5,74(s1)
    8000515c:	37fd                	addiw	a5,a5,-1
    8000515e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005162:	8526                	mv	a0,s1
    80005164:	896fe0ef          	jal	800031fa <iupdate>
    80005168:	bfa9                	j	800050c2 <sys_unlink+0xb6>
    8000516a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000516c:	8526                	mv	a0,s1
    8000516e:	b92fe0ef          	jal	80003500 <iunlockput>
  end_op();
    80005172:	c0bfe0ef          	jal	80003d7c <end_op>
  return -1;
    80005176:	557d                	li	a0,-1
    80005178:	64ee                	ld	s1,216(sp)
}
    8000517a:	70ae                	ld	ra,232(sp)
    8000517c:	740e                	ld	s0,224(sp)
    8000517e:	616d                	addi	sp,sp,240
    80005180:	8082                	ret
    return -1;
    80005182:	557d                	li	a0,-1
    80005184:	bfdd                	j	8000517a <sys_unlink+0x16e>
    iunlockput(ip);
    80005186:	854a                	mv	a0,s2
    80005188:	b78fe0ef          	jal	80003500 <iunlockput>
    goto bad;
    8000518c:	694e                	ld	s2,208(sp)
    8000518e:	69ae                	ld	s3,200(sp)
    80005190:	bff1                	j	8000516c <sys_unlink+0x160>

0000000080005192 <sys_open>:

uint64
sys_open(void)
{
    80005192:	7131                	addi	sp,sp,-192
    80005194:	fd06                	sd	ra,184(sp)
    80005196:	f922                	sd	s0,176(sp)
    80005198:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000519a:	f4c40593          	addi	a1,s0,-180
    8000519e:	4505                	li	a0,1
    800051a0:	e94fd0ef          	jal	80002834 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051a4:	08000613          	li	a2,128
    800051a8:	f5040593          	addi	a1,s0,-176
    800051ac:	4501                	li	a0,0
    800051ae:	ebefd0ef          	jal	8000286c <argstr>
    800051b2:	87aa                	mv	a5,a0
    return -1;
    800051b4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051b6:	0a07c263          	bltz	a5,8000525a <sys_open+0xc8>
    800051ba:	f526                	sd	s1,168(sp)

  begin_op();
    800051bc:	b3bfe0ef          	jal	80003cf6 <begin_op>

  if (omode & O_CREATE) {
    800051c0:	f4c42783          	lw	a5,-180(s0)
    800051c4:	2007f793          	andi	a5,a5,512
    800051c8:	c3d5                	beqz	a5,8000526c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800051ca:	4681                	li	a3,0
    800051cc:	4601                	li	a2,0
    800051ce:	4589                	li	a1,2
    800051d0:	f5040513          	addi	a0,s0,-176
    800051d4:	a23ff0ef          	jal	80004bf6 <create>
    800051d8:	84aa                	mv	s1,a0
    if (ip == 0) {
    800051da:	c541                	beqz	a0,80005262 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800051dc:	04449703          	lh	a4,68(s1)
    800051e0:	478d                	li	a5,3
    800051e2:	00f71763          	bne	a4,a5,800051f0 <sys_open+0x5e>
    800051e6:	0464d703          	lhu	a4,70(s1)
    800051ea:	47a5                	li	a5,9
    800051ec:	0ae7ed63          	bltu	a5,a4,800052a6 <sys_open+0x114>
    800051f0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800051f2:	f0dfe0ef          	jal	800040fe <filealloc>
    800051f6:	892a                	mv	s2,a0
    800051f8:	c179                	beqz	a0,800052be <sys_open+0x12c>
    800051fa:	ed4e                	sd	s3,152(sp)
    800051fc:	9bdff0ef          	jal	80004bb8 <fdalloc>
    80005200:	89aa                	mv	s3,a0
    80005202:	0a054a63          	bltz	a0,800052b6 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005206:	04449703          	lh	a4,68(s1)
    8000520a:	478d                	li	a5,3
    8000520c:	0cf70263          	beq	a4,a5,800052d0 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005210:	4789                	li	a5,2
    80005212:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005216:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000521a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000521e:	f4c42783          	lw	a5,-180(s0)
    80005222:	0017c713          	xori	a4,a5,1
    80005226:	8b05                	andi	a4,a4,1
    80005228:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000522c:	0037f713          	andi	a4,a5,3
    80005230:	00e03733          	snez	a4,a4
    80005234:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005238:	4007f793          	andi	a5,a5,1024
    8000523c:	c791                	beqz	a5,80005248 <sys_open+0xb6>
    8000523e:	04449703          	lh	a4,68(s1)
    80005242:	4789                	li	a5,2
    80005244:	08f70d63          	beq	a4,a5,800052de <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005248:	8526                	mv	a0,s1
    8000524a:	912fe0ef          	jal	8000335c <iunlock>
  end_op();
    8000524e:	b2ffe0ef          	jal	80003d7c <end_op>

  return fd;
    80005252:	854e                	mv	a0,s3
    80005254:	74aa                	ld	s1,168(sp)
    80005256:	790a                	ld	s2,160(sp)
    80005258:	69ea                	ld	s3,152(sp)
}
    8000525a:	70ea                	ld	ra,184(sp)
    8000525c:	744a                	ld	s0,176(sp)
    8000525e:	6129                	addi	sp,sp,192
    80005260:	8082                	ret
      end_op();
    80005262:	b1bfe0ef          	jal	80003d7c <end_op>
      return -1;
    80005266:	557d                	li	a0,-1
    80005268:	74aa                	ld	s1,168(sp)
    8000526a:	bfc5                	j	8000525a <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    8000526c:	f5040513          	addi	a0,s0,-176
    80005270:	8b3fe0ef          	jal	80003b22 <namei>
    80005274:	84aa                	mv	s1,a0
    80005276:	c11d                	beqz	a0,8000529c <sys_open+0x10a>
    ilock(ip);
    80005278:	836fe0ef          	jal	800032ae <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000527c:	04449703          	lh	a4,68(s1)
    80005280:	4785                	li	a5,1
    80005282:	f4f71de3          	bne	a4,a5,800051dc <sys_open+0x4a>
    80005286:	f4c42783          	lw	a5,-180(s0)
    8000528a:	d3bd                	beqz	a5,800051f0 <sys_open+0x5e>
      iunlockput(ip);
    8000528c:	8526                	mv	a0,s1
    8000528e:	a72fe0ef          	jal	80003500 <iunlockput>
      end_op();
    80005292:	aebfe0ef          	jal	80003d7c <end_op>
      return -1;
    80005296:	557d                	li	a0,-1
    80005298:	74aa                	ld	s1,168(sp)
    8000529a:	b7c1                	j	8000525a <sys_open+0xc8>
      end_op();
    8000529c:	ae1fe0ef          	jal	80003d7c <end_op>
      return -1;
    800052a0:	557d                	li	a0,-1
    800052a2:	74aa                	ld	s1,168(sp)
    800052a4:	bf5d                	j	8000525a <sys_open+0xc8>
    iunlockput(ip);
    800052a6:	8526                	mv	a0,s1
    800052a8:	a58fe0ef          	jal	80003500 <iunlockput>
    end_op();
    800052ac:	ad1fe0ef          	jal	80003d7c <end_op>
    return -1;
    800052b0:	557d                	li	a0,-1
    800052b2:	74aa                	ld	s1,168(sp)
    800052b4:	b75d                	j	8000525a <sys_open+0xc8>
      fileclose(f);
    800052b6:	854a                	mv	a0,s2
    800052b8:	eebfe0ef          	jal	800041a2 <fileclose>
    800052bc:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052be:	8526                	mv	a0,s1
    800052c0:	a40fe0ef          	jal	80003500 <iunlockput>
    end_op();
    800052c4:	ab9fe0ef          	jal	80003d7c <end_op>
    return -1;
    800052c8:	557d                	li	a0,-1
    800052ca:	74aa                	ld	s1,168(sp)
    800052cc:	790a                	ld	s2,160(sp)
    800052ce:	b771                	j	8000525a <sys_open+0xc8>
    f->type = FD_DEVICE;
    800052d0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052d4:	04649783          	lh	a5,70(s1)
    800052d8:	02f91223          	sh	a5,36(s2)
    800052dc:	bf3d                	j	8000521a <sys_open+0x88>
    itrunc(ip);
    800052de:	8526                	mv	a0,s1
    800052e0:	8bcfe0ef          	jal	8000339c <itrunc>
    800052e4:	b795                	j	80005248 <sys_open+0xb6>

00000000800052e6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800052e6:	7175                	addi	sp,sp,-144
    800052e8:	e506                	sd	ra,136(sp)
    800052ea:	e122                	sd	s0,128(sp)
    800052ec:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052ee:	a09fe0ef          	jal	80003cf6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800052f2:	08000613          	li	a2,128
    800052f6:	f7040593          	addi	a1,s0,-144
    800052fa:	4501                	li	a0,0
    800052fc:	d70fd0ef          	jal	8000286c <argstr>
    80005300:	02054363          	bltz	a0,80005326 <sys_mkdir+0x40>
    80005304:	4681                	li	a3,0
    80005306:	4601                	li	a2,0
    80005308:	4585                	li	a1,1
    8000530a:	f7040513          	addi	a0,s0,-144
    8000530e:	8e9ff0ef          	jal	80004bf6 <create>
    80005312:	c911                	beqz	a0,80005326 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005314:	9ecfe0ef          	jal	80003500 <iunlockput>
  end_op();
    80005318:	a65fe0ef          	jal	80003d7c <end_op>
  return 0;
    8000531c:	4501                	li	a0,0
}
    8000531e:	60aa                	ld	ra,136(sp)
    80005320:	640a                	ld	s0,128(sp)
    80005322:	6149                	addi	sp,sp,144
    80005324:	8082                	ret
    end_op();
    80005326:	a57fe0ef          	jal	80003d7c <end_op>
    return -1;
    8000532a:	557d                	li	a0,-1
    8000532c:	bfcd                	j	8000531e <sys_mkdir+0x38>

000000008000532e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000532e:	7135                	addi	sp,sp,-160
    80005330:	ed06                	sd	ra,152(sp)
    80005332:	e922                	sd	s0,144(sp)
    80005334:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005336:	9c1fe0ef          	jal	80003cf6 <begin_op>
  argint(1, &major);
    8000533a:	f6c40593          	addi	a1,s0,-148
    8000533e:	4505                	li	a0,1
    80005340:	cf4fd0ef          	jal	80002834 <argint>
  argint(2, &minor);
    80005344:	f6840593          	addi	a1,s0,-152
    80005348:	4509                	li	a0,2
    8000534a:	ceafd0ef          	jal	80002834 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000534e:	08000613          	li	a2,128
    80005352:	f7040593          	addi	a1,s0,-144
    80005356:	4501                	li	a0,0
    80005358:	d14fd0ef          	jal	8000286c <argstr>
    8000535c:	02054563          	bltz	a0,80005386 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005360:	f6841683          	lh	a3,-152(s0)
    80005364:	f6c41603          	lh	a2,-148(s0)
    80005368:	458d                	li	a1,3
    8000536a:	f7040513          	addi	a0,s0,-144
    8000536e:	889ff0ef          	jal	80004bf6 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005372:	c911                	beqz	a0,80005386 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005374:	98cfe0ef          	jal	80003500 <iunlockput>
  end_op();
    80005378:	a05fe0ef          	jal	80003d7c <end_op>
  return 0;
    8000537c:	4501                	li	a0,0
}
    8000537e:	60ea                	ld	ra,152(sp)
    80005380:	644a                	ld	s0,144(sp)
    80005382:	610d                	addi	sp,sp,160
    80005384:	8082                	ret
    end_op();
    80005386:	9f7fe0ef          	jal	80003d7c <end_op>
    return -1;
    8000538a:	557d                	li	a0,-1
    8000538c:	bfcd                	j	8000537e <sys_mknod+0x50>

000000008000538e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000538e:	7135                	addi	sp,sp,-160
    80005390:	ed06                	sd	ra,152(sp)
    80005392:	e922                	sd	s0,144(sp)
    80005394:	e14a                	sd	s2,128(sp)
    80005396:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005398:	d0cfc0ef          	jal	800018a4 <myproc>
    8000539c:	892a                	mv	s2,a0

  begin_op();
    8000539e:	959fe0ef          	jal	80003cf6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800053a2:	08000613          	li	a2,128
    800053a6:	f6040593          	addi	a1,s0,-160
    800053aa:	4501                	li	a0,0
    800053ac:	cc0fd0ef          	jal	8000286c <argstr>
    800053b0:	04054363          	bltz	a0,800053f6 <sys_chdir+0x68>
    800053b4:	e526                	sd	s1,136(sp)
    800053b6:	f6040513          	addi	a0,s0,-160
    800053ba:	f68fe0ef          	jal	80003b22 <namei>
    800053be:	84aa                	mv	s1,a0
    800053c0:	c915                	beqz	a0,800053f4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053c2:	eedfd0ef          	jal	800032ae <ilock>
  if (ip->type != T_DIR) {
    800053c6:	04449703          	lh	a4,68(s1)
    800053ca:	4785                	li	a5,1
    800053cc:	02f71963          	bne	a4,a5,800053fe <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053d0:	8526                	mv	a0,s1
    800053d2:	f8bfd0ef          	jal	8000335c <iunlock>
  iput(p->cwd);
    800053d6:	15093503          	ld	a0,336(s2)
    800053da:	856fe0ef          	jal	80003430 <iput>
  end_op();
    800053de:	99ffe0ef          	jal	80003d7c <end_op>
  p->cwd = ip;
    800053e2:	14993823          	sd	s1,336(s2)
  return 0;
    800053e6:	4501                	li	a0,0
    800053e8:	64aa                	ld	s1,136(sp)
}
    800053ea:	60ea                	ld	ra,152(sp)
    800053ec:	644a                	ld	s0,144(sp)
    800053ee:	690a                	ld	s2,128(sp)
    800053f0:	610d                	addi	sp,sp,160
    800053f2:	8082                	ret
    800053f4:	64aa                	ld	s1,136(sp)
    end_op();
    800053f6:	987fe0ef          	jal	80003d7c <end_op>
    return -1;
    800053fa:	557d                	li	a0,-1
    800053fc:	b7fd                	j	800053ea <sys_chdir+0x5c>
    iunlockput(ip);
    800053fe:	8526                	mv	a0,s1
    80005400:	900fe0ef          	jal	80003500 <iunlockput>
    end_op();
    80005404:	979fe0ef          	jal	80003d7c <end_op>
    return -1;
    80005408:	557d                	li	a0,-1
    8000540a:	64aa                	ld	s1,136(sp)
    8000540c:	bff9                	j	800053ea <sys_chdir+0x5c>

000000008000540e <sys_exec>:

uint64
sys_exec(void)
{
    8000540e:	7121                	addi	sp,sp,-448
    80005410:	ff06                	sd	ra,440(sp)
    80005412:	fb22                	sd	s0,432(sp)
    80005414:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005416:	e4840593          	addi	a1,s0,-440
    8000541a:	4505                	li	a0,1
    8000541c:	c34fd0ef          	jal	80002850 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005420:	08000613          	li	a2,128
    80005424:	f5040593          	addi	a1,s0,-176
    80005428:	4501                	li	a0,0
    8000542a:	c42fd0ef          	jal	8000286c <argstr>
    8000542e:	87aa                	mv	a5,a0
    return -1;
    80005430:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005432:	0c07c463          	bltz	a5,800054fa <sys_exec+0xec>
    80005436:	f726                	sd	s1,424(sp)
    80005438:	f34a                	sd	s2,416(sp)
    8000543a:	ef4e                	sd	s3,408(sp)
    8000543c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000543e:	10000613          	li	a2,256
    80005442:	4581                	li	a1,0
    80005444:	e5040513          	addi	a0,s0,-432
    80005448:	80dfb0ef          	jal	80000c54 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000544c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005450:	89a6                	mv	s3,s1
    80005452:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    80005454:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005458:	00391513          	slli	a0,s2,0x3
    8000545c:	e4040593          	addi	a1,s0,-448
    80005460:	e4843783          	ld	a5,-440(s0)
    80005464:	953e                	add	a0,a0,a5
    80005466:	b42fd0ef          	jal	800027a8 <fetchaddr>
    8000546a:	02054663          	bltz	a0,80005496 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    8000546e:	e4043783          	ld	a5,-448(s0)
    80005472:	c3a9                	beqz	a5,800054b4 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005474:	e56fb0ef          	jal	80000aca <kalloc>
    80005478:	85aa                	mv	a1,a0
    8000547a:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000547e:	cd01                	beqz	a0,80005496 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005480:	6605                	lui	a2,0x1
    80005482:	e4043503          	ld	a0,-448(s0)
    80005486:	b6cfd0ef          	jal	800027f2 <fetchstr>
    8000548a:	00054663          	bltz	a0,80005496 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    8000548e:	0905                	addi	s2,s2,1
    80005490:	09a1                	addi	s3,s3,8
    80005492:	fd4913e3          	bne	s2,s4,80005458 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005496:	f5040913          	addi	s2,s0,-176
    8000549a:	6088                	ld	a0,0(s1)
    8000549c:	c931                	beqz	a0,800054f0 <sys_exec+0xe2>
    kfree(argv[i]);
    8000549e:	d4afb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054a2:	04a1                	addi	s1,s1,8
    800054a4:	ff249be3          	bne	s1,s2,8000549a <sys_exec+0x8c>
  return -1;
    800054a8:	557d                	li	a0,-1
    800054aa:	74ba                	ld	s1,424(sp)
    800054ac:	791a                	ld	s2,416(sp)
    800054ae:	69fa                	ld	s3,408(sp)
    800054b0:	6a5a                	ld	s4,400(sp)
    800054b2:	a0a1                	j	800054fa <sys_exec+0xec>
      argv[i] = 0;
    800054b4:	0009079b          	sext.w	a5,s2
    800054b8:	078e                	slli	a5,a5,0x3
    800054ba:	fd078793          	addi	a5,a5,-48
    800054be:	97a2                	add	a5,a5,s0
    800054c0:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800054c4:	e5040593          	addi	a1,s0,-432
    800054c8:	f5040513          	addi	a0,s0,-176
    800054cc:	b26ff0ef          	jal	800047f2 <kexec>
    800054d0:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054d2:	f5040993          	addi	s3,s0,-176
    800054d6:	6088                	ld	a0,0(s1)
    800054d8:	c511                	beqz	a0,800054e4 <sys_exec+0xd6>
    kfree(argv[i]);
    800054da:	d0efb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054de:	04a1                	addi	s1,s1,8
    800054e0:	ff349be3          	bne	s1,s3,800054d6 <sys_exec+0xc8>
  return ret;
    800054e4:	854a                	mv	a0,s2
    800054e6:	74ba                	ld	s1,424(sp)
    800054e8:	791a                	ld	s2,416(sp)
    800054ea:	69fa                	ld	s3,408(sp)
    800054ec:	6a5a                	ld	s4,400(sp)
    800054ee:	a031                	j	800054fa <sys_exec+0xec>
  return -1;
    800054f0:	557d                	li	a0,-1
    800054f2:	74ba                	ld	s1,424(sp)
    800054f4:	791a                	ld	s2,416(sp)
    800054f6:	69fa                	ld	s3,408(sp)
    800054f8:	6a5a                	ld	s4,400(sp)
}
    800054fa:	70fa                	ld	ra,440(sp)
    800054fc:	745a                	ld	s0,432(sp)
    800054fe:	6139                	addi	sp,sp,448
    80005500:	8082                	ret

0000000080005502 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005502:	7139                	addi	sp,sp,-64
    80005504:	fc06                	sd	ra,56(sp)
    80005506:	f822                	sd	s0,48(sp)
    80005508:	f426                	sd	s1,40(sp)
    8000550a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000550c:	b98fc0ef          	jal	800018a4 <myproc>
    80005510:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005512:	fd840593          	addi	a1,s0,-40
    80005516:	4501                	li	a0,0
    80005518:	b38fd0ef          	jal	80002850 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000551c:	fc840593          	addi	a1,s0,-56
    80005520:	fd040513          	addi	a0,s0,-48
    80005524:	f9ffe0ef          	jal	800044c2 <pipealloc>
    return -1;
    80005528:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    8000552a:	0a054663          	bltz	a0,800055d6 <sys_pipe+0xd4>
  fd0 = -1;
    8000552e:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005532:	fd043503          	ld	a0,-48(s0)
    80005536:	e82ff0ef          	jal	80004bb8 <fdalloc>
    8000553a:	fca42223          	sw	a0,-60(s0)
    8000553e:	08054363          	bltz	a0,800055c4 <sys_pipe+0xc2>
    80005542:	fc843503          	ld	a0,-56(s0)
    80005546:	e72ff0ef          	jal	80004bb8 <fdalloc>
    8000554a:	fca42023          	sw	a0,-64(s0)
    8000554e:	06054263          	bltz	a0,800055b2 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005552:	4711                	li	a4,4
    80005554:	fc440693          	addi	a3,s0,-60
    80005558:	fd843603          	ld	a2,-40(s0)
    8000555c:	64ac                	ld	a1,72(s1)
    8000555e:	68a8                	ld	a0,80(s1)
    80005560:	f7bfb0ef          	jal	800014da <copyout>
    80005564:	00054f63          	bltz	a0,80005582 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005568:	4711                	li	a4,4
    8000556a:	fc040693          	addi	a3,s0,-64
    8000556e:	fd843603          	ld	a2,-40(s0)
    80005572:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005574:	64ac                	ld	a1,72(s1)
    80005576:	68a8                	ld	a0,80(s1)
    80005578:	f63fb0ef          	jal	800014da <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000557c:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000557e:	04055c63          	bgez	a0,800055d6 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    80005582:	fc442783          	lw	a5,-60(s0)
    80005586:	07e9                	addi	a5,a5,26
    80005588:	078e                	slli	a5,a5,0x3
    8000558a:	97a6                	add	a5,a5,s1
    8000558c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005590:	fc042783          	lw	a5,-64(s0)
    80005594:	07e9                	addi	a5,a5,26
    80005596:	078e                	slli	a5,a5,0x3
    80005598:	94be                	add	s1,s1,a5
    8000559a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000559e:	fd043503          	ld	a0,-48(s0)
    800055a2:	c01fe0ef          	jal	800041a2 <fileclose>
    fileclose(wf);
    800055a6:	fc843503          	ld	a0,-56(s0)
    800055aa:	bf9fe0ef          	jal	800041a2 <fileclose>
    return -1;
    800055ae:	57fd                	li	a5,-1
    800055b0:	a01d                	j	800055d6 <sys_pipe+0xd4>
    if (fd0 >= 0)
    800055b2:	fc442783          	lw	a5,-60(s0)
    800055b6:	0007c763          	bltz	a5,800055c4 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    800055ba:	07e9                	addi	a5,a5,26
    800055bc:	078e                	slli	a5,a5,0x3
    800055be:	97a6                	add	a5,a5,s1
    800055c0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800055c4:	fd043503          	ld	a0,-48(s0)
    800055c8:	bdbfe0ef          	jal	800041a2 <fileclose>
    fileclose(wf);
    800055cc:	fc843503          	ld	a0,-56(s0)
    800055d0:	bd3fe0ef          	jal	800041a2 <fileclose>
    return -1;
    800055d4:	57fd                	li	a5,-1
}
    800055d6:	853e                	mv	a0,a5
    800055d8:	70e2                	ld	ra,56(sp)
    800055da:	7442                	ld	s0,48(sp)
    800055dc:	74a2                	ld	s1,40(sp)
    800055de:	6121                	addi	sp,sp,64
    800055e0:	8082                	ret
	...

00000000800055f0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800055f0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800055f2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800055f4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800055f6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800055f8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800055fa:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800055fc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800055fe:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005600:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005602:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005604:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005606:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005608:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000560a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000560c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000560e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005610:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005612:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005614:	8a4fd0ef          	jal	800026b8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005618:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000561a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000561c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000561e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005620:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005622:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005624:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005626:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005628:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000562a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000562c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000562e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005630:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005632:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005634:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005636:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005638:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000563a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000563c:	10200073          	sret
	...

000000008000564e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000564e:	1141                	addi	sp,sp,-16
    80005650:	e422                	sd	s0,8(sp)
    80005652:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005654:	0c0007b7          	lui	a5,0xc000
    80005658:	4705                	li	a4,1
    8000565a:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000565c:	0c0007b7          	lui	a5,0xc000
    80005660:	c3d8                	sw	a4,4(a5)
}
    80005662:	6422                	ld	s0,8(sp)
    80005664:	0141                	addi	sp,sp,16
    80005666:	8082                	ret

0000000080005668 <plicinithart>:

void
plicinithart(void)
{
    80005668:	1141                	addi	sp,sp,-16
    8000566a:	e406                	sd	ra,8(sp)
    8000566c:	e022                	sd	s0,0(sp)
    8000566e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005670:	a08fc0ef          	jal	80001878 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005674:	0085171b          	slliw	a4,a0,0x8
    80005678:	0c0027b7          	lui	a5,0xc002
    8000567c:	97ba                	add	a5,a5,a4
    8000567e:	40200713          	li	a4,1026
    80005682:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005686:	00d5151b          	slliw	a0,a0,0xd
    8000568a:	0c2017b7          	lui	a5,0xc201
    8000568e:	97aa                	add	a5,a5,a0
    80005690:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005694:	60a2                	ld	ra,8(sp)
    80005696:	6402                	ld	s0,0(sp)
    80005698:	0141                	addi	sp,sp,16
    8000569a:	8082                	ret

000000008000569c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000569c:	1141                	addi	sp,sp,-16
    8000569e:	e406                	sd	ra,8(sp)
    800056a0:	e022                	sd	s0,0(sp)
    800056a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056a4:	9d4fc0ef          	jal	80001878 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800056a8:	00d5151b          	slliw	a0,a0,0xd
    800056ac:	0c2017b7          	lui	a5,0xc201
    800056b0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056b2:	43c8                	lw	a0,4(a5)
    800056b4:	60a2                	ld	ra,8(sp)
    800056b6:	6402                	ld	s0,0(sp)
    800056b8:	0141                	addi	sp,sp,16
    800056ba:	8082                	ret

00000000800056bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056bc:	1101                	addi	sp,sp,-32
    800056be:	ec06                	sd	ra,24(sp)
    800056c0:	e822                	sd	s0,16(sp)
    800056c2:	e426                	sd	s1,8(sp)
    800056c4:	1000                	addi	s0,sp,32
    800056c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056c8:	9b0fc0ef          	jal	80001878 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    800056cc:	00d5151b          	slliw	a0,a0,0xd
    800056d0:	0c2017b7          	lui	a5,0xc201
    800056d4:	97aa                	add	a5,a5,a0
    800056d6:	c3c4                	sw	s1,4(a5)
}
    800056d8:	60e2                	ld	ra,24(sp)
    800056da:	6442                	ld	s0,16(sp)
    800056dc:	64a2                	ld	s1,8(sp)
    800056de:	6105                	addi	sp,sp,32
    800056e0:	8082                	ret

00000000800056e2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056e2:	1141                	addi	sp,sp,-16
    800056e4:	e406                	sd	ra,8(sp)
    800056e6:	e022                	sd	s0,0(sp)
    800056e8:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800056ea:	479d                	li	a5,7
    800056ec:	04a7ca63          	blt	a5,a0,80005740 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800056f0:	0001b797          	auipc	a5,0x1b
    800056f4:	38078793          	addi	a5,a5,896 # 80020a70 <disk>
    800056f8:	97aa                	add	a5,a5,a0
    800056fa:	0187c783          	lbu	a5,24(a5)
    800056fe:	e7b9                	bnez	a5,8000574c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005700:	00451693          	slli	a3,a0,0x4
    80005704:	0001b797          	auipc	a5,0x1b
    80005708:	36c78793          	addi	a5,a5,876 # 80020a70 <disk>
    8000570c:	6398                	ld	a4,0(a5)
    8000570e:	9736                	add	a4,a4,a3
    80005710:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005714:	6398                	ld	a4,0(a5)
    80005716:	9736                	add	a4,a4,a3
    80005718:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000571c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005720:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005724:	97aa                	add	a5,a5,a0
    80005726:	4705                	li	a4,1
    80005728:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000572c:	0001b517          	auipc	a0,0x1b
    80005730:	35c50513          	addi	a0,a0,860 # 80020a88 <disk+0x18>
    80005734:	feefc0ef          	jal	80001f22 <wakeup>
}
    80005738:	60a2                	ld	ra,8(sp)
    8000573a:	6402                	ld	s0,0(sp)
    8000573c:	0141                	addi	sp,sp,16
    8000573e:	8082                	ret
    panic("free_desc 1");
    80005740:	00002517          	auipc	a0,0x2
    80005744:	ef050513          	addi	a0,a0,-272 # 80007630 <etext+0x630>
    80005748:	8a8fb0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    8000574c:	00002517          	auipc	a0,0x2
    80005750:	ef450513          	addi	a0,a0,-268 # 80007640 <etext+0x640>
    80005754:	89cfb0ef          	jal	800007f0 <panic>

0000000080005758 <virtio_disk_init>:
{
    80005758:	1101                	addi	sp,sp,-32
    8000575a:	ec06                	sd	ra,24(sp)
    8000575c:	e822                	sd	s0,16(sp)
    8000575e:	e426                	sd	s1,8(sp)
    80005760:	e04a                	sd	s2,0(sp)
    80005762:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005764:	00002597          	auipc	a1,0x2
    80005768:	eec58593          	addi	a1,a1,-276 # 80007650 <etext+0x650>
    8000576c:	0001b517          	auipc	a0,0x1b
    80005770:	42c50513          	addi	a0,a0,1068 # 80020b98 <disk+0x128>
    80005774:	ba6fb0ef          	jal	80000b1a <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005778:	100017b7          	lui	a5,0x10001
    8000577c:	4398                	lw	a4,0(a5)
    8000577e:	2701                	sext.w	a4,a4
    80005780:	747277b7          	lui	a5,0x74727
    80005784:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005788:	18f71063          	bne	a4,a5,80005908 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000578c:	100017b7          	lui	a5,0x10001
    80005790:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005792:	439c                	lw	a5,0(a5)
    80005794:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005796:	4709                	li	a4,2
    80005798:	16e79863          	bne	a5,a4,80005908 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000579c:	100017b7          	lui	a5,0x10001
    800057a0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800057a2:	439c                	lw	a5,0(a5)
    800057a4:	2781                	sext.w	a5,a5
    800057a6:	16e79163          	bne	a5,a4,80005908 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800057aa:	100017b7          	lui	a5,0x10001
    800057ae:	47d8                	lw	a4,12(a5)
    800057b0:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057b2:	554d47b7          	lui	a5,0x554d4
    800057b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057ba:	14f71763          	bne	a4,a5,80005908 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057be:	100017b7          	lui	a5,0x10001
    800057c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057c6:	4705                	li	a4,1
    800057c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ca:	470d                	li	a4,3
    800057cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057ce:	10001737          	lui	a4,0x10001
    800057d2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057d4:	c7ffe737          	lui	a4,0xc7ffe
    800057d8:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fdd9af>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057dc:	8ef9                	and	a3,a3,a4
    800057de:	10001737          	lui	a4,0x10001
    800057e2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057e4:	472d                	li	a4,11
    800057e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057e8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057ec:	439c                	lw	a5,0(a5)
    800057ee:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057f2:	8ba1                	andi	a5,a5,8
    800057f4:	12078063          	beqz	a5,80005914 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057f8:	100017b7          	lui	a5,0x10001
    800057fc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005800:	100017b7          	lui	a5,0x10001
    80005804:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005808:	439c                	lw	a5,0(a5)
    8000580a:	2781                	sext.w	a5,a5
    8000580c:	10079a63          	bnez	a5,80005920 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005810:	100017b7          	lui	a5,0x10001
    80005814:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005818:	439c                	lw	a5,0(a5)
    8000581a:	2781                	sext.w	a5,a5
  if (max == 0)
    8000581c:	10078863          	beqz	a5,8000592c <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005820:	471d                	li	a4,7
    80005822:	10f77b63          	bgeu	a4,a5,80005938 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005826:	aa4fb0ef          	jal	80000aca <kalloc>
    8000582a:	0001b497          	auipc	s1,0x1b
    8000582e:	24648493          	addi	s1,s1,582 # 80020a70 <disk>
    80005832:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005834:	a96fb0ef          	jal	80000aca <kalloc>
    80005838:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000583a:	a90fb0ef          	jal	80000aca <kalloc>
    8000583e:	87aa                	mv	a5,a0
    80005840:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005842:	6088                	ld	a0,0(s1)
    80005844:	10050063          	beqz	a0,80005944 <virtio_disk_init+0x1ec>
    80005848:	0001b717          	auipc	a4,0x1b
    8000584c:	23073703          	ld	a4,560(a4) # 80020a78 <disk+0x8>
    80005850:	0e070a63          	beqz	a4,80005944 <virtio_disk_init+0x1ec>
    80005854:	0e078863          	beqz	a5,80005944 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005858:	6605                	lui	a2,0x1
    8000585a:	4581                	li	a1,0
    8000585c:	bf8fb0ef          	jal	80000c54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005860:	0001b497          	auipc	s1,0x1b
    80005864:	21048493          	addi	s1,s1,528 # 80020a70 <disk>
    80005868:	6605                	lui	a2,0x1
    8000586a:	4581                	li	a1,0
    8000586c:	6488                	ld	a0,8(s1)
    8000586e:	be6fb0ef          	jal	80000c54 <memset>
  memset(disk.used, 0, PGSIZE);
    80005872:	6605                	lui	a2,0x1
    80005874:	4581                	li	a1,0
    80005876:	6888                	ld	a0,16(s1)
    80005878:	bdcfb0ef          	jal	80000c54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000587c:	100017b7          	lui	a5,0x10001
    80005880:	4721                	li	a4,8
    80005882:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005884:	4098                	lw	a4,0(s1)
    80005886:	100017b7          	lui	a5,0x10001
    8000588a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000588e:	40d8                	lw	a4,4(s1)
    80005890:	100017b7          	lui	a5,0x10001
    80005894:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005898:	649c                	ld	a5,8(s1)
    8000589a:	0007869b          	sext.w	a3,a5
    8000589e:	10001737          	lui	a4,0x10001
    800058a2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058a6:	9781                	srai	a5,a5,0x20
    800058a8:	10001737          	lui	a4,0x10001
    800058ac:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058b0:	689c                	ld	a5,16(s1)
    800058b2:	0007869b          	sext.w	a3,a5
    800058b6:	10001737          	lui	a4,0x10001
    800058ba:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058be:	9781                	srai	a5,a5,0x20
    800058c0:	10001737          	lui	a4,0x10001
    800058c4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058c8:	10001737          	lui	a4,0x10001
    800058cc:	4785                	li	a5,1
    800058ce:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058d0:	00f48c23          	sb	a5,24(s1)
    800058d4:	00f48ca3          	sb	a5,25(s1)
    800058d8:	00f48d23          	sb	a5,26(s1)
    800058dc:	00f48da3          	sb	a5,27(s1)
    800058e0:	00f48e23          	sb	a5,28(s1)
    800058e4:	00f48ea3          	sb	a5,29(s1)
    800058e8:	00f48f23          	sb	a5,30(s1)
    800058ec:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058f0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058f4:	100017b7          	lui	a5,0x10001
    800058f8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	64a2                	ld	s1,8(sp)
    80005902:	6902                	ld	s2,0(sp)
    80005904:	6105                	addi	sp,sp,32
    80005906:	8082                	ret
    panic("could not find virtio disk");
    80005908:	00002517          	auipc	a0,0x2
    8000590c:	d5850513          	addi	a0,a0,-680 # 80007660 <etext+0x660>
    80005910:	ee1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005914:	00002517          	auipc	a0,0x2
    80005918:	d6c50513          	addi	a0,a0,-660 # 80007680 <etext+0x680>
    8000591c:	ed5fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005920:	00002517          	auipc	a0,0x2
    80005924:	d8050513          	addi	a0,a0,-640 # 800076a0 <etext+0x6a0>
    80005928:	ec9fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	d9450513          	addi	a0,a0,-620 # 800076c0 <etext+0x6c0>
    80005934:	ebdfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	da850513          	addi	a0,a0,-600 # 800076e0 <etext+0x6e0>
    80005940:	eb1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005944:	00002517          	auipc	a0,0x2
    80005948:	dbc50513          	addi	a0,a0,-580 # 80007700 <etext+0x700>
    8000594c:	ea5fa0ef          	jal	800007f0 <panic>

0000000080005950 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005950:	7159                	addi	sp,sp,-112
    80005952:	f486                	sd	ra,104(sp)
    80005954:	f0a2                	sd	s0,96(sp)
    80005956:	eca6                	sd	s1,88(sp)
    80005958:	e8ca                	sd	s2,80(sp)
    8000595a:	e4ce                	sd	s3,72(sp)
    8000595c:	e0d2                	sd	s4,64(sp)
    8000595e:	fc56                	sd	s5,56(sp)
    80005960:	f85a                	sd	s6,48(sp)
    80005962:	f45e                	sd	s7,40(sp)
    80005964:	f062                	sd	s8,32(sp)
    80005966:	ec66                	sd	s9,24(sp)
    80005968:	1880                	addi	s0,sp,112
    8000596a:	8a2a                	mv	s4,a0
    8000596c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000596e:	00c52c83          	lw	s9,12(a0)
    80005972:	001c9c9b          	slliw	s9,s9,0x1
    80005976:	1c82                	slli	s9,s9,0x20
    80005978:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000597c:	0001b517          	auipc	a0,0x1b
    80005980:	21c50513          	addi	a0,a0,540 # 80020b98 <disk+0x128>
    80005984:	a0cfb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005988:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    8000598a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000598c:	0001bb17          	auipc	s6,0x1b
    80005990:	0e4b0b13          	addi	s6,s6,228 # 80020a70 <disk>
  for (int i = 0; i < 3; i++) {
    80005994:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005996:	0001bc17          	auipc	s8,0x1b
    8000599a:	0f2c0c13          	addi	s8,s8,242 # 80020a88 <disk+0x18>
    8000599e:	a0bd                	j	80005a0c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800059a0:	00fb0733          	add	a4,s6,a5
    800059a4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800059a8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800059aa:	0207c563          	bltz	a5,800059d4 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    800059ae:	2905                	addiw	s2,s2,1
    800059b0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059b2:	07590163          	beq	s2,s5,80005a14 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800059b6:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800059b8:	0001b717          	auipc	a4,0x1b
    800059bc:	0b870713          	addi	a4,a4,184 # 80020a70 <disk>
    800059c0:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    800059c2:	01874683          	lbu	a3,24(a4)
    800059c6:	fee9                	bnez	a3,800059a0 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    800059c8:	2785                	addiw	a5,a5,1
    800059ca:	0705                	addi	a4,a4,1
    800059cc:	fe979be3          	bne	a5,s1,800059c2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800059d0:	57fd                	li	a5,-1
    800059d2:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    800059d4:	01205d63          	blez	s2,800059ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059d8:	f9042503          	lw	a0,-112(s0)
    800059dc:	d07ff0ef          	jal	800056e2 <free_desc>
      for (int j = 0; j < i; j++)
    800059e0:	4785                	li	a5,1
    800059e2:	0127d663          	bge	a5,s2,800059ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059e6:	f9442503          	lw	a0,-108(s0)
    800059ea:	cf9ff0ef          	jal	800056e2 <free_desc>
    sleep_prepare(&disk.free[0]);
    800059ee:	8562                	mv	a0,s8
    800059f0:	cc6fc0ef          	jal	80001eb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    800059f4:	0001b917          	auipc	s2,0x1b
    800059f8:	1a490913          	addi	s2,s2,420 # 80020b98 <disk+0x128>
    800059fc:	854a                	mv	a0,s2
    800059fe:	a1efb0ef          	jal	80000c1c <release>
    sleep();
    80005a02:	cf0fc0ef          	jal	80001ef2 <sleep>
    acquire(&disk.vdisk_lock);
    80005a06:	854a                	mv	a0,s2
    80005a08:	988fb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005a0c:	f9040613          	addi	a2,s0,-112
    80005a10:	894e                	mv	s2,s3
    80005a12:	b755                	j	800059b6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a14:	f9042503          	lw	a0,-112(s0)
    80005a18:	00451693          	slli	a3,a0,0x4

  if (write)
    80005a1c:	0001b797          	auipc	a5,0x1b
    80005a20:	05478793          	addi	a5,a5,84 # 80020a70 <disk>
    80005a24:	00a50713          	addi	a4,a0,10
    80005a28:	0712                	slli	a4,a4,0x4
    80005a2a:	973e                	add	a4,a4,a5
    80005a2c:	01703633          	snez	a2,s7
    80005a30:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a32:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a36:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a3a:	6398                	ld	a4,0(a5)
    80005a3c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a3e:	0a868613          	addi	a2,a3,168
    80005a42:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a44:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a46:	6390                	ld	a2,0(a5)
    80005a48:	00d605b3          	add	a1,a2,a3
    80005a4c:	4741                	li	a4,16
    80005a4e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a50:	4805                	li	a6,1
    80005a52:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a56:	f9442703          	lw	a4,-108(s0)
    80005a5a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005a5e:	0712                	slli	a4,a4,0x4
    80005a60:	963a                	add	a2,a2,a4
    80005a62:	058a0593          	addi	a1,s4,88
    80005a66:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a68:	0007b883          	ld	a7,0(a5)
    80005a6c:	9746                	add	a4,a4,a7
    80005a6e:	40000613          	li	a2,1024
    80005a72:	c710                	sw	a2,8(a4)
  if (write)
    80005a74:	001bb613          	seqz	a2,s7
    80005a78:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a7c:	00166613          	ori	a2,a2,1
    80005a80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a84:	f9842583          	lw	a1,-104(s0)
    80005a88:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a8c:	00250613          	addi	a2,a0,2
    80005a90:	0612                	slli	a2,a2,0x4
    80005a92:	963e                	add	a2,a2,a5
    80005a94:	577d                	li	a4,-1
    80005a96:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005a9a:	0592                	slli	a1,a1,0x4
    80005a9c:	98ae                	add	a7,a7,a1
    80005a9e:	03068713          	addi	a4,a3,48
    80005aa2:	973e                	add	a4,a4,a5
    80005aa4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005aa8:	6398                	ld	a4,0(a5)
    80005aaa:	972e                	add	a4,a4,a1
    80005aac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ab0:	4689                	li	a3,2
    80005ab2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ab6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005aba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005abe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ac2:	6794                	ld	a3,8(a5)
    80005ac4:	0026d703          	lhu	a4,2(a3)
    80005ac8:	8b1d                	andi	a4,a4,7
    80005aca:	0706                	slli	a4,a4,0x1
    80005acc:	96ba                	add	a3,a3,a4
    80005ace:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005ad2:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ad6:	6798                	ld	a4,8(a5)
    80005ad8:	00275783          	lhu	a5,2(a4)
    80005adc:	2785                	addiw	a5,a5,1
    80005ade:	00f71123          	sh	a5,2(a4)
    80005ae2:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ae6:	100017b7          	lui	a5,0x10001
    80005aea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005aee:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005af2:	0001b497          	auipc	s1,0x1b
    80005af6:	0a648493          	addi	s1,s1,166 # 80020b98 <disk+0x128>
  while (b->disk == 1) {
    80005afa:	4905                	li	s2,1
    80005afc:	03079163          	bne	a5,a6,80005b1e <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80005b00:	8552                	mv	a0,s4
    80005b02:	bb4fc0ef          	jal	80001eb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b06:	8526                	mv	a0,s1
    80005b08:	914fb0ef          	jal	80000c1c <release>
    sleep();
    80005b0c:	be6fc0ef          	jal	80001ef2 <sleep>
    acquire(&disk.vdisk_lock);
    80005b10:	8526                	mv	a0,s1
    80005b12:	87efb0ef          	jal	80000b90 <acquire>
  while (b->disk == 1) {
    80005b16:	004a2783          	lw	a5,4(s4)
    80005b1a:	ff2783e3          	beq	a5,s2,80005b00 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005b1e:	f9042903          	lw	s2,-112(s0)
    80005b22:	00290713          	addi	a4,s2,2
    80005b26:	0712                	slli	a4,a4,0x4
    80005b28:	0001b797          	auipc	a5,0x1b
    80005b2c:	f4878793          	addi	a5,a5,-184 # 80020a70 <disk>
    80005b30:	97ba                	add	a5,a5,a4
    80005b32:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b36:	0001b997          	auipc	s3,0x1b
    80005b3a:	f3a98993          	addi	s3,s3,-198 # 80020a70 <disk>
    80005b3e:	00491713          	slli	a4,s2,0x4
    80005b42:	0009b783          	ld	a5,0(s3)
    80005b46:	97ba                	add	a5,a5,a4
    80005b48:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b4c:	854a                	mv	a0,s2
    80005b4e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b52:	b91ff0ef          	jal	800056e2 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005b56:	8885                	andi	s1,s1,1
    80005b58:	f0fd                	bnez	s1,80005b3e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b5a:	0001b517          	auipc	a0,0x1b
    80005b5e:	03e50513          	addi	a0,a0,62 # 80020b98 <disk+0x128>
    80005b62:	8bafb0ef          	jal	80000c1c <release>
}
    80005b66:	70a6                	ld	ra,104(sp)
    80005b68:	7406                	ld	s0,96(sp)
    80005b6a:	64e6                	ld	s1,88(sp)
    80005b6c:	6946                	ld	s2,80(sp)
    80005b6e:	69a6                	ld	s3,72(sp)
    80005b70:	6a06                	ld	s4,64(sp)
    80005b72:	7ae2                	ld	s5,56(sp)
    80005b74:	7b42                	ld	s6,48(sp)
    80005b76:	7ba2                	ld	s7,40(sp)
    80005b78:	7c02                	ld	s8,32(sp)
    80005b7a:	6ce2                	ld	s9,24(sp)
    80005b7c:	6165                	addi	sp,sp,112
    80005b7e:	8082                	ret

0000000080005b80 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b80:	1101                	addi	sp,sp,-32
    80005b82:	ec06                	sd	ra,24(sp)
    80005b84:	e822                	sd	s0,16(sp)
    80005b86:	e426                	sd	s1,8(sp)
    80005b88:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b8a:	0001b497          	auipc	s1,0x1b
    80005b8e:	ee648493          	addi	s1,s1,-282 # 80020a70 <disk>
    80005b92:	0001b517          	auipc	a0,0x1b
    80005b96:	00650513          	addi	a0,a0,6 # 80020b98 <disk+0x128>
    80005b9a:	ff7fa0ef          	jal	80000b90 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b9e:	100017b7          	lui	a5,0x10001
    80005ba2:	53b8                	lw	a4,96(a5)
    80005ba4:	8b0d                	andi	a4,a4,3
    80005ba6:	100017b7          	lui	a5,0x10001
    80005baa:	d3f8                	sw	a4,100(a5)
    80005bac:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005bb0:	689c                	ld	a5,16(s1)
    80005bb2:	0204d703          	lhu	a4,32(s1)
    80005bb6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bba:	04f70663          	beq	a4,a5,80005c06 <virtio_disk_intr+0x86>
    80005bbe:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bc2:	6898                	ld	a4,16(s1)
    80005bc4:	0204d783          	lhu	a5,32(s1)
    80005bc8:	8b9d                	andi	a5,a5,7
    80005bca:	078e                	slli	a5,a5,0x3
    80005bcc:	97ba                	add	a5,a5,a4
    80005bce:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005bd0:	00278713          	addi	a4,a5,2
    80005bd4:	0712                	slli	a4,a4,0x4
    80005bd6:	9726                	add	a4,a4,s1
    80005bd8:	01074703          	lbu	a4,16(a4)
    80005bdc:	e321                	bnez	a4,80005c1c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bde:	0789                	addi	a5,a5,2
    80005be0:	0792                	slli	a5,a5,0x4
    80005be2:	97a6                	add	a5,a5,s1
    80005be4:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005be6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bea:	b38fc0ef          	jal	80001f22 <wakeup>

    disk.used_idx += 1;
    80005bee:	0204d783          	lhu	a5,32(s1)
    80005bf2:	2785                	addiw	a5,a5,1
    80005bf4:	17c2                	slli	a5,a5,0x30
    80005bf6:	93c1                	srli	a5,a5,0x30
    80005bf8:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005bfc:	6898                	ld	a4,16(s1)
    80005bfe:	00275703          	lhu	a4,2(a4)
    80005c02:	faf71ee3          	bne	a4,a5,80005bbe <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c06:	0001b517          	auipc	a0,0x1b
    80005c0a:	f9250513          	addi	a0,a0,-110 # 80020b98 <disk+0x128>
    80005c0e:	80efb0ef          	jal	80000c1c <release>
}
    80005c12:	60e2                	ld	ra,24(sp)
    80005c14:	6442                	ld	s0,16(sp)
    80005c16:	64a2                	ld	s1,8(sp)
    80005c18:	6105                	addi	sp,sp,32
    80005c1a:	8082                	ret
      panic("virtio_disk_intr status");
    80005c1c:	00002517          	auipc	a0,0x2
    80005c20:	afc50513          	addi	a0,a0,-1284 # 80007718 <etext+0x718>
    80005c24:	bcdfa0ef          	jal	800007f0 <panic>
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
