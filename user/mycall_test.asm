
user/_mycall_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Hello from mycall_test!\n");
   8:	00001517          	auipc	a0,0x1
   c:	89850513          	addi	a0,a0,-1896 # 8a0 <malloc+0xfe>
  10:	6de000ef          	jal	6ee <printf>
    exit(0);
  14:	4501                	li	a0,0
  16:	298000ef          	jal	2ae <exit>

000000000000001a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  1a:	1141                	addi	sp,sp,-16
  1c:	e406                	sd	ra,8(sp)
  1e:	e022                	sd	s0,0(sp)
  20:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  22:	fdfff0ef          	jal	0 <main>
  exit(r);
  26:	288000ef          	jal	2ae <exit>

000000000000002a <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	86be                	mv	a3,a5
  84:	0785                	addi	a5,a5,1
  86:	fff7c703          	lbu	a4,-1(a5)
  8a:	ff65                	bnez	a4,82 <strlen+0x10>
  8c:	40a6853b          	subw	a0,a3,a0
  90:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  for (n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void *
memset(void *dst, int c, uint n)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  a2:	ca19                	beqz	a2,b8 <memset+0x1c>
  a4:	87aa                	mv	a5,a0
  a6:	1602                	slli	a2,a2,0x20
  a8:	9201                	srli	a2,a2,0x20
  aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ae:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
  b2:	0785                	addi	a5,a5,1
  b4:	fee79de3          	bne	a5,a4,ae <memset+0x12>
  }
  return dst;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strchr>:

char *
strchr(const char *s, char c)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  for (; *s; s++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cb99                	beqz	a5,de <strchr+0x20>
    if (*s == c)
  ca:	00f58763          	beq	a1,a5,d8 <strchr+0x1a>
  for (; *s; s++)
  ce:	0505                	addi	a0,a0,1
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbfd                	bnez	a5,ca <strchr+0xc>
      return (char *)s;
  return 0;
  d6:	4501                	li	a0,0
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret
  return 0;
  de:	4501                	li	a0,0
  e0:	bfe5                	j	d8 <strchr+0x1a>

00000000000000e2 <gets>:

char *
gets(char *buf, int max)
{
  e2:	711d                	addi	sp,sp,-96
  e4:	ec86                	sd	ra,88(sp)
  e6:	e8a2                	sd	s0,80(sp)
  e8:	e4a6                	sd	s1,72(sp)
  ea:	e0ca                	sd	s2,64(sp)
  ec:	fc4e                	sd	s3,56(sp)
  ee:	f852                	sd	s4,48(sp)
  f0:	f456                	sd	s5,40(sp)
  f2:	f05a                	sd	s6,32(sp)
  f4:	ec5e                	sd	s7,24(sp)
  f6:	1080                	addi	s0,sp,96
  f8:	8baa                	mv	s7,a0
  fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
  fc:	892a                	mv	s2,a0
  fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 100:	4aa9                	li	s5,10
 102:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 104:	89a6                	mv	s3,s1
 106:	2485                	addiw	s1,s1,1
 108:	0344d663          	bge	s1,s4,134 <gets+0x52>
    cc = read(0, &c, 1);
 10c:	4605                	li	a2,1
 10e:	faf40593          	addi	a1,s0,-81
 112:	4501                	li	a0,0
 114:	1b2000ef          	jal	2c6 <read>
    if (cc < 1)
 118:	00a05e63          	blez	a0,134 <gets+0x52>
    buf[i++] = c;
 11c:	faf44783          	lbu	a5,-81(s0)
 120:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 124:	01578763          	beq	a5,s5,132 <gets+0x50>
 128:	0905                	addi	s2,s2,1
 12a:	fd679de3          	bne	a5,s6,104 <gets+0x22>
    buf[i++] = c;
 12e:	89a6                	mv	s3,s1
 130:	a011                	j	134 <gets+0x52>
 132:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 134:	99de                	add	s3,s3,s7
 136:	00098023          	sb	zero,0(s3)
  return buf;
}
 13a:	855e                	mv	a0,s7
 13c:	60e6                	ld	ra,88(sp)
 13e:	6446                	ld	s0,80(sp)
 140:	64a6                	ld	s1,72(sp)
 142:	6906                	ld	s2,64(sp)
 144:	79e2                	ld	s3,56(sp)
 146:	7a42                	ld	s4,48(sp)
 148:	7aa2                	ld	s5,40(sp)
 14a:	7b02                	ld	s6,32(sp)
 14c:	6be2                	ld	s7,24(sp)
 14e:	6125                	addi	sp,sp,96
 150:	8082                	ret

0000000000000152 <stat>:

int
stat(const char *n, struct stat *st)
{
 152:	1101                	addi	sp,sp,-32
 154:	ec06                	sd	ra,24(sp)
 156:	e822                	sd	s0,16(sp)
 158:	e04a                	sd	s2,0(sp)
 15a:	1000                	addi	s0,sp,32
 15c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 15e:	4581                	li	a1,0
 160:	18e000ef          	jal	2ee <open>
  if (fd < 0)
 164:	02054263          	bltz	a0,188 <stat+0x36>
 168:	e426                	sd	s1,8(sp)
 16a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 16c:	85ca                	mv	a1,s2
 16e:	198000ef          	jal	306 <fstat>
 172:	892a                	mv	s2,a0
  close(fd);
 174:	8526                	mv	a0,s1
 176:	160000ef          	jal	2d6 <close>
  return r;
 17a:	64a2                	ld	s1,8(sp)
}
 17c:	854a                	mv	a0,s2
 17e:	60e2                	ld	ra,24(sp)
 180:	6442                	ld	s0,16(sp)
 182:	6902                	ld	s2,0(sp)
 184:	6105                	addi	sp,sp,32
 186:	8082                	ret
    return -1;
 188:	597d                	li	s2,-1
 18a:	bfcd                	j	17c <stat+0x2a>

000000000000018c <atoi>:

int
atoi(const char *s)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 192:	00054683          	lbu	a3,0(a0)
 196:	fd06879b          	addiw	a5,a3,-48
 19a:	0ff7f793          	zext.b	a5,a5
 19e:	4625                	li	a2,9
 1a0:	02f66863          	bltu	a2,a5,1d0 <atoi+0x44>
 1a4:	872a                	mv	a4,a0
  n = 0;
 1a6:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1a8:	0705                	addi	a4,a4,1
 1aa:	0025179b          	slliw	a5,a0,0x2
 1ae:	9fa9                	addw	a5,a5,a0
 1b0:	0017979b          	slliw	a5,a5,0x1
 1b4:	9fb5                	addw	a5,a5,a3
 1b6:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1ba:	00074683          	lbu	a3,0(a4)
 1be:	fd06879b          	addiw	a5,a3,-48
 1c2:	0ff7f793          	zext.b	a5,a5
 1c6:	fef671e3          	bgeu	a2,a5,1a8 <atoi+0x1c>
  return n;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  n = 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <atoi+0x3e>

00000000000001d4 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1da:	02b57463          	bgeu	a0,a1,202 <memmove+0x2e>
    while (n-- > 0)
 1de:	00c05f63          	blez	a2,1fc <memmove+0x28>
 1e2:	1602                	slli	a2,a2,0x20
 1e4:	9201                	srli	a2,a2,0x20
 1e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 1ec:	0585                	addi	a1,a1,1
 1ee:	0705                	addi	a4,a4,1
 1f0:	fff5c683          	lbu	a3,-1(a1)
 1f4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 1f8:	fef71ae3          	bne	a4,a5,1ec <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
    dst += n;
 202:	00c50733          	add	a4,a0,a2
    src += n;
 206:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 208:	fec05ae3          	blez	a2,1fc <memmove+0x28>
 20c:	fff6079b          	addiw	a5,a2,-1
 210:	1782                	slli	a5,a5,0x20
 212:	9381                	srli	a5,a5,0x20
 214:	fff7c793          	not	a5,a5
 218:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 21a:	15fd                	addi	a1,a1,-1
 21c:	177d                	addi	a4,a4,-1
 21e:	0005c683          	lbu	a3,0(a1)
 222:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 226:	fee79ae3          	bne	a5,a4,21a <memmove+0x46>
 22a:	bfc9                	j	1fc <memmove+0x28>

000000000000022c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 232:	ca05                	beqz	a2,262 <memcmp+0x36>
 234:	fff6069b          	addiw	a3,a2,-1
 238:	1682                	slli	a3,a3,0x20
 23a:	9281                	srli	a3,a3,0x20
 23c:	0685                	addi	a3,a3,1
 23e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 240:	00054783          	lbu	a5,0(a0)
 244:	0005c703          	lbu	a4,0(a1)
 248:	00e79863          	bne	a5,a4,258 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 24c:	0505                	addi	a0,a0,1
    p2++;
 24e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 250:	fed518e3          	bne	a0,a3,240 <memcmp+0x14>
  }
  return 0;
 254:	4501                	li	a0,0
 256:	a019                	j	25c <memcmp+0x30>
      return *p1 - *p2;
 258:	40e7853b          	subw	a0,a5,a4
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  return 0;
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <memcmp+0x30>

0000000000000266 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e406                	sd	ra,8(sp)
 26a:	e022                	sd	s0,0(sp)
 26c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 26e:	f67ff0ef          	jal	1d4 <memmove>
}
 272:	60a2                	ld	ra,8(sp)
 274:	6402                	ld	s0,0(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <sbrk>:

char *
sbrk(int n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 282:	4585                	li	a1,1
 284:	0b2000ef          	jal	336 <sys_sbrk>
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret

0000000000000290 <sbrklazy>:

char *
sbrklazy(int n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 298:	4589                	li	a1,2
 29a:	09c000ef          	jal	336 <sys_sbrk>
}
 29e:	60a2                	ld	ra,8(sp)
 2a0:	6402                	ld	s0,0(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a6:	4885                	li	a7,1
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ae:	4889                	li	a7,2
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b6:	488d                	li	a7,3
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2be:	4891                	li	a7,4
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <read>:
.global read
read:
 li a7, SYS_read
 2c6:	4895                	li	a7,5
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <write>:
.global write
write:
 li a7, SYS_write
 2ce:	48c1                	li	a7,16
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <close>:
.global close
close:
 li a7, SYS_close
 2d6:	48d5                	li	a7,21
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <kill>:
.global kill
kill:
 li a7, SYS_kill
 2de:	4899                	li	a7,6
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e6:	489d                	li	a7,7
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <open>:
.global open
open:
 li a7, SYS_open
 2ee:	48bd                	li	a7,15
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f6:	48c5                	li	a7,17
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2fe:	48c9                	li	a7,18
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 306:	48a1                	li	a7,8
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <link>:
.global link
link:
 li a7, SYS_link
 30e:	48cd                	li	a7,19
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 316:	48d1                	li	a7,20
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 31e:	48a5                	li	a7,9
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <dup>:
.global dup
dup:
 li a7, SYS_dup
 326:	48a9                	li	a7,10
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 32e:	48ad                	li	a7,11
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 336:	48b1                	li	a7,12
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pause>:
.global pause
pause:
 li a7, SYS_pause
 33e:	48b5                	li	a7,13
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 346:	48b9                	li	a7,14
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <sync>:
.global sync
sync:
 li a7, SYS_sync
 34e:	48d9                	li	a7,22
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mycall>:
.global mycall
mycall:
 li a7, SYS_mycall
 356:	48dd                	li	a7,23
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <cpustats>:
.global cpustats
cpustats:
 li a7, SYS_cpustats
 35e:	48e1                	li	a7,24
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 366:	1101                	addi	sp,sp,-32
 368:	ec06                	sd	ra,24(sp)
 36a:	e822                	sd	s0,16(sp)
 36c:	1000                	addi	s0,sp,32
 36e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 372:	4605                	li	a2,1
 374:	fef40593          	addi	a1,s0,-17
 378:	f57ff0ef          	jal	2ce <write>
}
 37c:	60e2                	ld	ra,24(sp)
 37e:	6442                	ld	s0,16(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret

0000000000000384 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 384:	715d                	addi	sp,sp,-80
 386:	e486                	sd	ra,72(sp)
 388:	e0a2                	sd	s0,64(sp)
 38a:	f84a                	sd	s2,48(sp)
 38c:	0880                	addi	s0,sp,80
 38e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 390:	c299                	beqz	a3,396 <printint+0x12>
 392:	0805c363          	bltz	a1,418 <printint+0x94>
  neg = 0;
 396:	4881                	li	a7,0
 398:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 39c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 39e:	00000517          	auipc	a0,0x0
 3a2:	52a50513          	addi	a0,a0,1322 # 8c8 <digits>
 3a6:	883e                	mv	a6,a5
 3a8:	2785                	addiw	a5,a5,1
 3aa:	02c5f733          	remu	a4,a1,a2
 3ae:	972a                	add	a4,a4,a0
 3b0:	00074703          	lbu	a4,0(a4)
 3b4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 3b8:	872e                	mv	a4,a1
 3ba:	02c5d5b3          	divu	a1,a1,a2
 3be:	0685                	addi	a3,a3,1
 3c0:	fec773e3          	bgeu	a4,a2,3a6 <printint+0x22>
  if (neg)
 3c4:	00088b63          	beqz	a7,3da <printint+0x56>
    buf[i++] = '-';
 3c8:	fd078793          	addi	a5,a5,-48
 3cc:	97a2                	add	a5,a5,s0
 3ce:	02d00713          	li	a4,45
 3d2:	fee78423          	sb	a4,-24(a5)
 3d6:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 3da:	02f05a63          	blez	a5,40e <printint+0x8a>
 3de:	fc26                	sd	s1,56(sp)
 3e0:	f44e                	sd	s3,40(sp)
 3e2:	fb840713          	addi	a4,s0,-72
 3e6:	00f704b3          	add	s1,a4,a5
 3ea:	fff70993          	addi	s3,a4,-1
 3ee:	99be                	add	s3,s3,a5
 3f0:	37fd                	addiw	a5,a5,-1
 3f2:	1782                	slli	a5,a5,0x20
 3f4:	9381                	srli	a5,a5,0x20
 3f6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 3fa:	fff4c583          	lbu	a1,-1(s1)
 3fe:	854a                	mv	a0,s2
 400:	f67ff0ef          	jal	366 <putc>
  while (--i >= 0)
 404:	14fd                	addi	s1,s1,-1
 406:	ff349ae3          	bne	s1,s3,3fa <printint+0x76>
 40a:	74e2                	ld	s1,56(sp)
 40c:	79a2                	ld	s3,40(sp)
}
 40e:	60a6                	ld	ra,72(sp)
 410:	6406                	ld	s0,64(sp)
 412:	7942                	ld	s2,48(sp)
 414:	6161                	addi	sp,sp,80
 416:	8082                	ret
    x = -xx;
 418:	40b005b3          	neg	a1,a1
    neg = 1;
 41c:	4885                	li	a7,1
    x = -xx;
 41e:	bfad                	j	398 <printint+0x14>

0000000000000420 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 420:	711d                	addi	sp,sp,-96
 422:	ec86                	sd	ra,88(sp)
 424:	e8a2                	sd	s0,80(sp)
 426:	e0ca                	sd	s2,64(sp)
 428:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 42a:	0005c903          	lbu	s2,0(a1)
 42e:	28090663          	beqz	s2,6ba <vprintf+0x29a>
 432:	e4a6                	sd	s1,72(sp)
 434:	fc4e                	sd	s3,56(sp)
 436:	f852                	sd	s4,48(sp)
 438:	f456                	sd	s5,40(sp)
 43a:	f05a                	sd	s6,32(sp)
 43c:	ec5e                	sd	s7,24(sp)
 43e:	e862                	sd	s8,16(sp)
 440:	e466                	sd	s9,8(sp)
 442:	8b2a                	mv	s6,a0
 444:	8a2e                	mv	s4,a1
 446:	8bb2                	mv	s7,a2
  state = 0;
 448:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 44a:	4481                	li	s1,0
 44c:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 44e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 452:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 456:	06c00c93          	li	s9,108
 45a:	a005                	j	47a <vprintf+0x5a>
        putc(fd, c0);
 45c:	85ca                	mv	a1,s2
 45e:	855a                	mv	a0,s6
 460:	f07ff0ef          	jal	366 <putc>
 464:	a019                	j	46a <vprintf+0x4a>
    } else if (state == '%') {
 466:	03598263          	beq	s3,s5,48a <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 46a:	2485                	addiw	s1,s1,1
 46c:	8726                	mv	a4,s1
 46e:	009a07b3          	add	a5,s4,s1
 472:	0007c903          	lbu	s2,0(a5)
 476:	22090a63          	beqz	s2,6aa <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 47a:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 47e:	fe0994e3          	bnez	s3,466 <vprintf+0x46>
      if (c0 == '%') {
 482:	fd579de3          	bne	a5,s5,45c <vprintf+0x3c>
        state = '%';
 486:	89be                	mv	s3,a5
 488:	b7cd                	j	46a <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 48a:	00ea06b3          	add	a3,s4,a4
 48e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 492:	8636                	mv	a2,a3
      if (c1)
 494:	c681                	beqz	a3,49c <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 496:	9752                	add	a4,a4,s4
 498:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 49c:	05878363          	beq	a5,s8,4e2 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 4a0:	05978d63          	beq	a5,s9,4fa <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 4a4:	07500713          	li	a4,117
 4a8:	0ee78763          	beq	a5,a4,596 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 4ac:	07800713          	li	a4,120
 4b0:	12e78963          	beq	a5,a4,5e2 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 4b4:	07000713          	li	a4,112
 4b8:	14e78e63          	beq	a5,a4,614 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 4bc:	06300713          	li	a4,99
 4c0:	18e78e63          	beq	a5,a4,65c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 4c4:	07300713          	li	a4,115
 4c8:	1ae78463          	beq	a5,a4,670 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 4cc:	02500713          	li	a4,37
 4d0:	04e79563          	bne	a5,a4,51a <vprintf+0xfa>
        putc(fd, '%');
 4d4:	02500593          	li	a1,37
 4d8:	855a                	mv	a0,s6
 4da:	e8dff0ef          	jal	366 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4de:	4981                	li	s3,0
 4e0:	b769                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4e2:	008b8913          	addi	s2,s7,8
 4e6:	4685                	li	a3,1
 4e8:	4629                	li	a2,10
 4ea:	000ba583          	lw	a1,0(s7)
 4ee:	855a                	mv	a0,s6
 4f0:	e95ff0ef          	jal	384 <printint>
 4f4:	8bca                	mv	s7,s2
      state = 0;
 4f6:	4981                	li	s3,0
 4f8:	bf8d                	j	46a <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 4fa:	06400793          	li	a5,100
 4fe:	02f68963          	beq	a3,a5,530 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 502:	06c00793          	li	a5,108
 506:	04f68263          	beq	a3,a5,54a <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 50a:	07500793          	li	a5,117
 50e:	0af68063          	beq	a3,a5,5ae <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 512:	07800793          	li	a5,120
 516:	0ef68263          	beq	a3,a5,5fa <vprintf+0x1da>
        putc(fd, '%');
 51a:	02500593          	li	a1,37
 51e:	855a                	mv	a0,s6
 520:	e47ff0ef          	jal	366 <putc>
        putc(fd, c0);
 524:	85ca                	mv	a1,s2
 526:	855a                	mv	a0,s6
 528:	e3fff0ef          	jal	366 <putc>
      state = 0;
 52c:	4981                	li	s3,0
 52e:	bf35                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 530:	008b8913          	addi	s2,s7,8
 534:	4685                	li	a3,1
 536:	4629                	li	a2,10
 538:	000bb583          	ld	a1,0(s7)
 53c:	855a                	mv	a0,s6
 53e:	e47ff0ef          	jal	384 <printint>
        i += 1;
 542:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 544:	8bca                	mv	s7,s2
      state = 0;
 546:	4981                	li	s3,0
        i += 1;
 548:	b70d                	j	46a <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 54a:	06400793          	li	a5,100
 54e:	02f60763          	beq	a2,a5,57c <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 552:	07500793          	li	a5,117
 556:	06f60963          	beq	a2,a5,5c8 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 55a:	07800793          	li	a5,120
 55e:	faf61ee3          	bne	a2,a5,51a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 562:	008b8913          	addi	s2,s7,8
 566:	4681                	li	a3,0
 568:	4641                	li	a2,16
 56a:	000bb583          	ld	a1,0(s7)
 56e:	855a                	mv	a0,s6
 570:	e15ff0ef          	jal	384 <printint>
        i += 2;
 574:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 576:	8bca                	mv	s7,s2
      state = 0;
 578:	4981                	li	s3,0
        i += 2;
 57a:	bdc5                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	008b8913          	addi	s2,s7,8
 580:	4685                	li	a3,1
 582:	4629                	li	a2,10
 584:	000bb583          	ld	a1,0(s7)
 588:	855a                	mv	a0,s6
 58a:	dfbff0ef          	jal	384 <printint>
        i += 2;
 58e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
        i += 2;
 594:	bdd9                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4629                	li	a2,10
 59e:	000be583          	lwu	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	de1ff0ef          	jal	384 <printint>
 5a8:	8bca                	mv	s7,s2
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bd7d                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000bb583          	ld	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	dc9ff0ef          	jal	384 <printint>
        i += 1;
 5c0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	8bca                	mv	s7,s2
      state = 0;
 5c4:	4981                	li	s3,0
        i += 1;
 5c6:	b555                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4629                	li	a2,10
 5d0:	000bb583          	ld	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	dafff0ef          	jal	384 <printint>
        i += 2;
 5da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
        i += 2;
 5e0:	b569                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000be583          	lwu	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	d95ff0ef          	jal	384 <printint>
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bd8d                	j	46a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4681                	li	a3,0
 600:	4641                	li	a2,16
 602:	000bb583          	ld	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	d7dff0ef          	jal	384 <printint>
        i += 1;
 60c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
        i += 1;
 612:	bda1                	j	46a <vprintf+0x4a>
 614:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 616:	008b8d13          	addi	s10,s7,8
 61a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 61e:	03000593          	li	a1,48
 622:	855a                	mv	a0,s6
 624:	d43ff0ef          	jal	366 <putc>
  putc(fd, 'x');
 628:	07800593          	li	a1,120
 62c:	855a                	mv	a0,s6
 62e:	d39ff0ef          	jal	366 <putc>
 632:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 634:	00000b97          	auipc	s7,0x0
 638:	294b8b93          	addi	s7,s7,660 # 8c8 <digits>
 63c:	03c9d793          	srli	a5,s3,0x3c
 640:	97de                	add	a5,a5,s7
 642:	0007c583          	lbu	a1,0(a5)
 646:	855a                	mv	a0,s6
 648:	d1fff0ef          	jal	366 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 64c:	0992                	slli	s3,s3,0x4
 64e:	397d                	addiw	s2,s2,-1
 650:	fe0916e3          	bnez	s2,63c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 654:	8bea                	mv	s7,s10
      state = 0;
 656:	4981                	li	s3,0
 658:	6d02                	ld	s10,0(sp)
 65a:	bd01                	j	46a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 65c:	008b8913          	addi	s2,s7,8
 660:	000bc583          	lbu	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	d01ff0ef          	jal	366 <putc>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bbf5                	j	46a <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 670:	008b8993          	addi	s3,s7,8
 674:	000bb903          	ld	s2,0(s7)
 678:	00090f63          	beqz	s2,696 <vprintf+0x276>
        for (; *s; s++)
 67c:	00094583          	lbu	a1,0(s2)
 680:	c195                	beqz	a1,6a4 <vprintf+0x284>
          putc(fd, *s);
 682:	855a                	mv	a0,s6
 684:	ce3ff0ef          	jal	366 <putc>
        for (; *s; s++)
 688:	0905                	addi	s2,s2,1
 68a:	00094583          	lbu	a1,0(s2)
 68e:	f9f5                	bnez	a1,682 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 690:	8bce                	mv	s7,s3
      state = 0;
 692:	4981                	li	s3,0
 694:	bbd9                	j	46a <vprintf+0x4a>
          s = "(null)";
 696:	00000917          	auipc	s2,0x0
 69a:	22a90913          	addi	s2,s2,554 # 8c0 <malloc+0x11e>
        for (; *s; s++)
 69e:	02800593          	li	a1,40
 6a2:	b7c5                	j	682 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 6a4:	8bce                	mv	s7,s3
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b3c9                	j	46a <vprintf+0x4a>
 6aa:	64a6                	ld	s1,72(sp)
 6ac:	79e2                	ld	s3,56(sp)
 6ae:	7a42                	ld	s4,48(sp)
 6b0:	7aa2                	ld	s5,40(sp)
 6b2:	7b02                	ld	s6,32(sp)
 6b4:	6be2                	ld	s7,24(sp)
 6b6:	6c42                	ld	s8,16(sp)
 6b8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6ba:	60e6                	ld	ra,88(sp)
 6bc:	6446                	ld	s0,80(sp)
 6be:	6906                	ld	s2,64(sp)
 6c0:	6125                	addi	sp,sp,96
 6c2:	8082                	ret

00000000000006c4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c4:	715d                	addi	sp,sp,-80
 6c6:	ec06                	sd	ra,24(sp)
 6c8:	e822                	sd	s0,16(sp)
 6ca:	1000                	addi	s0,sp,32
 6cc:	e010                	sd	a2,0(s0)
 6ce:	e414                	sd	a3,8(s0)
 6d0:	e818                	sd	a4,16(s0)
 6d2:	ec1c                	sd	a5,24(s0)
 6d4:	03043023          	sd	a6,32(s0)
 6d8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6dc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e0:	8622                	mv	a2,s0
 6e2:	d3fff0ef          	jal	420 <vprintf>
}
 6e6:	60e2                	ld	ra,24(sp)
 6e8:	6442                	ld	s0,16(sp)
 6ea:	6161                	addi	sp,sp,80
 6ec:	8082                	ret

00000000000006ee <printf>:

void
printf(const char *fmt, ...)
{
 6ee:	711d                	addi	sp,sp,-96
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e40c                	sd	a1,8(s0)
 6f8:	e810                	sd	a2,16(s0)
 6fa:	ec14                	sd	a3,24(s0)
 6fc:	f018                	sd	a4,32(s0)
 6fe:	f41c                	sd	a5,40(s0)
 700:	03043823          	sd	a6,48(s0)
 704:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 708:	00840613          	addi	a2,s0,8
 70c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 710:	85aa                	mv	a1,a0
 712:	4505                	li	a0,1
 714:	d0dff0ef          	jal	420 <vprintf>
}
 718:	60e2                	ld	ra,24(sp)
 71a:	6442                	ld	s0,16(sp)
 71c:	6125                	addi	sp,sp,96
 71e:	8082                	ret

0000000000000720 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 720:	1141                	addi	sp,sp,-16
 722:	e422                	sd	s0,8(sp)
 724:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 726:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72a:	00001797          	auipc	a5,0x1
 72e:	8d67b783          	ld	a5,-1834(a5) # 1000 <freep>
 732:	a02d                	j	75c <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 734:	4618                	lw	a4,8(a2)
 736:	9f2d                	addw	a4,a4,a1
 738:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 73c:	6398                	ld	a4,0(a5)
 73e:	6310                	ld	a2,0(a4)
 740:	a83d                	j	77e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 742:	ff852703          	lw	a4,-8(a0)
 746:	9f31                	addw	a4,a4,a2
 748:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 74a:	ff053683          	ld	a3,-16(a0)
 74e:	a091                	j	792 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 750:	6398                	ld	a4,0(a5)
 752:	00e7e463          	bltu	a5,a4,75a <free+0x3a>
 756:	00e6ea63          	bltu	a3,a4,76a <free+0x4a>
{
 75a:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	fed7fae3          	bgeu	a5,a3,750 <free+0x30>
 760:	6398                	ld	a4,0(a5)
 762:	00e6e463          	bltu	a3,a4,76a <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 766:	fee7eae3          	bltu	a5,a4,75a <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 76a:	ff852583          	lw	a1,-8(a0)
 76e:	6390                	ld	a2,0(a5)
 770:	02059813          	slli	a6,a1,0x20
 774:	01c85713          	srli	a4,a6,0x1c
 778:	9736                	add	a4,a4,a3
 77a:	fae60de3          	beq	a2,a4,734 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 77e:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 782:	4790                	lw	a2,8(a5)
 784:	02061593          	slli	a1,a2,0x20
 788:	01c5d713          	srli	a4,a1,0x1c
 78c:	973e                	add	a4,a4,a5
 78e:	fae68ae3          	beq	a3,a4,742 <free+0x22>
    p->s.ptr = bp->s.ptr;
 792:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 794:	00001717          	auipc	a4,0x1
 798:	86f73623          	sd	a5,-1940(a4) # 1000 <freep>
}
 79c:	6422                	ld	s0,8(sp)
 79e:	0141                	addi	sp,sp,16
 7a0:	8082                	ret

00000000000007a2 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 7a2:	7139                	addi	sp,sp,-64
 7a4:	fc06                	sd	ra,56(sp)
 7a6:	f822                	sd	s0,48(sp)
 7a8:	f426                	sd	s1,40(sp)
 7aa:	ec4e                	sd	s3,24(sp)
 7ac:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7ae:	02051493          	slli	s1,a0,0x20
 7b2:	9081                	srli	s1,s1,0x20
 7b4:	04bd                	addi	s1,s1,15
 7b6:	8091                	srli	s1,s1,0x4
 7b8:	0014899b          	addiw	s3,s1,1
 7bc:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 7be:	00001517          	auipc	a0,0x1
 7c2:	84253503          	ld	a0,-1982(a0) # 1000 <freep>
 7c6:	c915                	beqz	a0,7fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 7c8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 7ca:	4798                	lw	a4,8(a5)
 7cc:	08977a63          	bgeu	a4,s1,860 <malloc+0xbe>
 7d0:	f04a                	sd	s2,32(sp)
 7d2:	e852                	sd	s4,16(sp)
 7d4:	e456                	sd	s5,8(sp)
 7d6:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 7d8:	8a4e                	mv	s4,s3
 7da:	0009871b          	sext.w	a4,s3
 7de:	6685                	lui	a3,0x1
 7e0:	00d77363          	bgeu	a4,a3,7e6 <malloc+0x44>
 7e4:	6a05                	lui	s4,0x1
 7e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 7ee:	00001917          	auipc	s2,0x1
 7f2:	81290913          	addi	s2,s2,-2030 # 1000 <freep>
  if (p == SBRK_ERROR)
 7f6:	5afd                	li	s5,-1
 7f8:	a081                	j	838 <malloc+0x96>
 7fa:	f04a                	sd	s2,32(sp)
 7fc:	e852                	sd	s4,16(sp)
 7fe:	e456                	sd	s5,8(sp)
 800:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 802:	00001797          	auipc	a5,0x1
 806:	80e78793          	addi	a5,a5,-2034 # 1010 <base>
 80a:	00000717          	auipc	a4,0x0
 80e:	7ef73b23          	sd	a5,2038(a4) # 1000 <freep>
 812:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 814:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 818:	b7c1                	j	7d8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	e118                	sd	a4,0(a0)
 81e:	a8a9                	j	878 <malloc+0xd6>
  hp->s.size = nu;
 820:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 824:	0541                	addi	a0,a0,16
 826:	efbff0ef          	jal	720 <free>
  return freep;
 82a:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 82e:	c12d                	beqz	a0,890 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 830:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 832:	4798                	lw	a4,8(a5)
 834:	02977263          	bgeu	a4,s1,858 <malloc+0xb6>
    if (p == freep)
 838:	00093703          	ld	a4,0(s2)
 83c:	853e                	mv	a0,a5
 83e:	fef719e3          	bne	a4,a5,830 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 842:	8552                	mv	a0,s4
 844:	a37ff0ef          	jal	27a <sbrk>
  if (p == SBRK_ERROR)
 848:	fd551ce3          	bne	a0,s5,820 <malloc+0x7e>
        return 0;
 84c:	4501                	li	a0,0
 84e:	7902                	ld	s2,32(sp)
 850:	6a42                	ld	s4,16(sp)
 852:	6aa2                	ld	s5,8(sp)
 854:	6b02                	ld	s6,0(sp)
 856:	a03d                	j	884 <malloc+0xe2>
 858:	7902                	ld	s2,32(sp)
 85a:	6a42                	ld	s4,16(sp)
 85c:	6aa2                	ld	s5,8(sp)
 85e:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 860:	fae48de3          	beq	s1,a4,81a <malloc+0x78>
        p->s.size -= nunits;
 864:	4137073b          	subw	a4,a4,s3
 868:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86a:	02071693          	slli	a3,a4,0x20
 86e:	01c6d713          	srli	a4,a3,0x1c
 872:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 874:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 878:	00000717          	auipc	a4,0x0
 87c:	78a73423          	sd	a0,1928(a4) # 1000 <freep>
      return (void *)(p + 1);
 880:	01078513          	addi	a0,a5,16
  }
}
 884:	70e2                	ld	ra,56(sp)
 886:	7442                	ld	s0,48(sp)
 888:	74a2                	ld	s1,40(sp)
 88a:	69e2                	ld	s3,24(sp)
 88c:	6121                	addi	sp,sp,64
 88e:	8082                	ret
 890:	7902                	ld	s2,32(sp)
 892:	6a42                	ld	s4,16(sp)
 894:	6aa2                	ld	s5,8(sp)
 896:	6b02                	ld	s6,0(sp)
 898:	b7f5                	j	884 <malloc+0xe2>
