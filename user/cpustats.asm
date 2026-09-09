
user/_cpustats:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    struct cpustats st;
    if(cpustats(&st) < 0) {
   8:	fe840513          	addi	a0,s0,-24
   c:	378000ef          	jal	384 <cpustats>
  10:	00054f63          	bltz	a0,2e <main+0x2e>
        printf("cpustats call failed\n");
        exit(1);
    }
    printf("procs=%d ticks=%d\n", st.nproc, st.ticks);
  14:	fec42603          	lw	a2,-20(s0)
  18:	fe842583          	lw	a1,-24(s0)
  1c:	00001517          	auipc	a0,0x1
  20:	8bc50513          	addi	a0,a0,-1860 # 8d8 <malloc+0x110>
  24:	6f0000ef          	jal	714 <printf>
    exit(0);
  28:	4501                	li	a0,0
  2a:	2aa000ef          	jal	2d4 <exit>
        printf("cpustats call failed\n");
  2e:	00001517          	auipc	a0,0x1
  32:	89250513          	addi	a0,a0,-1902 # 8c0 <malloc+0xf8>
  36:	6de000ef          	jal	714 <printf>
        exit(1);
  3a:	4505                	li	a0,1
  3c:	298000ef          	jal	2d4 <exit>

0000000000000040 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  40:	1141                	addi	sp,sp,-16
  42:	e406                	sd	ra,8(sp)
  44:	e022                	sd	s0,0(sp)
  46:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  48:	fb9ff0ef          	jal	0 <main>
  exit(r);
  4c:	288000ef          	jal	2d4 <exit>

0000000000000050 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  50:	1141                	addi	sp,sp,-16
  52:	e422                	sd	s0,8(sp)
  54:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  56:	87aa                	mv	a5,a0
  58:	0585                	addi	a1,a1,1
  5a:	0785                	addi	a5,a5,1
  5c:	fff5c703          	lbu	a4,-1(a1)
  60:	fee78fa3          	sb	a4,-1(a5)
  64:	fb75                	bnez	a4,58 <strcpy+0x8>
    ;
  return os;
}
  66:	6422                	ld	s0,8(sp)
  68:	0141                	addi	sp,sp,16
  6a:	8082                	ret

000000000000006c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  6c:	1141                	addi	sp,sp,-16
  6e:	e422                	sd	s0,8(sp)
  70:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  72:	00054783          	lbu	a5,0(a0)
  76:	cb91                	beqz	a5,8a <strcmp+0x1e>
  78:	0005c703          	lbu	a4,0(a1)
  7c:	00f71763          	bne	a4,a5,8a <strcmp+0x1e>
    p++, q++;
  80:	0505                	addi	a0,a0,1
  82:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  84:	00054783          	lbu	a5,0(a0)
  88:	fbe5                	bnez	a5,78 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  8a:	0005c503          	lbu	a0,0(a1)
}
  8e:	40a7853b          	subw	a0,a5,a0
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strlen>:

uint
strlen(const char *s)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  9e:	00054783          	lbu	a5,0(a0)
  a2:	cf91                	beqz	a5,be <strlen+0x26>
  a4:	0505                	addi	a0,a0,1
  a6:	87aa                	mv	a5,a0
  a8:	86be                	mv	a3,a5
  aa:	0785                	addi	a5,a5,1
  ac:	fff7c703          	lbu	a4,-1(a5)
  b0:	ff65                	bnez	a4,a8 <strlen+0x10>
  b2:	40a6853b          	subw	a0,a3,a0
  b6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret
  for (n = 0; s[n]; n++)
  be:	4501                	li	a0,0
  c0:	bfe5                	j	b8 <strlen+0x20>

00000000000000c2 <memset>:

void *
memset(void *dst, int c, uint n)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  c8:	ca19                	beqz	a2,de <memset+0x1c>
  ca:	87aa                	mv	a5,a0
  cc:	1602                	slli	a2,a2,0x20
  ce:	9201                	srli	a2,a2,0x20
  d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d4:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
  d8:	0785                	addi	a5,a5,1
  da:	fee79de3          	bne	a5,a4,d4 <memset+0x12>
  }
  return dst;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strchr>:

char *
strchr(const char *s, char c)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  for (; *s; s++)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cb99                	beqz	a5,104 <strchr+0x20>
    if (*s == c)
  f0:	00f58763          	beq	a1,a5,fe <strchr+0x1a>
  for (; *s; s++)
  f4:	0505                	addi	a0,a0,1
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbfd                	bnez	a5,f0 <strchr+0xc>
      return (char *)s;
  return 0;
  fc:	4501                	li	a0,0
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  return 0;
 104:	4501                	li	a0,0
 106:	bfe5                	j	fe <strchr+0x1a>

0000000000000108 <gets>:

char *
gets(char *buf, int max)
{
 108:	711d                	addi	sp,sp,-96
 10a:	ec86                	sd	ra,88(sp)
 10c:	e8a2                	sd	s0,80(sp)
 10e:	e4a6                	sd	s1,72(sp)
 110:	e0ca                	sd	s2,64(sp)
 112:	fc4e                	sd	s3,56(sp)
 114:	f852                	sd	s4,48(sp)
 116:	f456                	sd	s5,40(sp)
 118:	f05a                	sd	s6,32(sp)
 11a:	ec5e                	sd	s7,24(sp)
 11c:	1080                	addi	s0,sp,96
 11e:	8baa                	mv	s7,a0
 120:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 122:	892a                	mv	s2,a0
 124:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 126:	4aa9                	li	s5,10
 128:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 12a:	89a6                	mv	s3,s1
 12c:	2485                	addiw	s1,s1,1
 12e:	0344d663          	bge	s1,s4,15a <gets+0x52>
    cc = read(0, &c, 1);
 132:	4605                	li	a2,1
 134:	faf40593          	addi	a1,s0,-81
 138:	4501                	li	a0,0
 13a:	1b2000ef          	jal	2ec <read>
    if (cc < 1)
 13e:	00a05e63          	blez	a0,15a <gets+0x52>
    buf[i++] = c;
 142:	faf44783          	lbu	a5,-81(s0)
 146:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 14a:	01578763          	beq	a5,s5,158 <gets+0x50>
 14e:	0905                	addi	s2,s2,1
 150:	fd679de3          	bne	a5,s6,12a <gets+0x22>
    buf[i++] = c;
 154:	89a6                	mv	s3,s1
 156:	a011                	j	15a <gets+0x52>
 158:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 15a:	99de                	add	s3,s3,s7
 15c:	00098023          	sb	zero,0(s3)
  return buf;
}
 160:	855e                	mv	a0,s7
 162:	60e6                	ld	ra,88(sp)
 164:	6446                	ld	s0,80(sp)
 166:	64a6                	ld	s1,72(sp)
 168:	6906                	ld	s2,64(sp)
 16a:	79e2                	ld	s3,56(sp)
 16c:	7a42                	ld	s4,48(sp)
 16e:	7aa2                	ld	s5,40(sp)
 170:	7b02                	ld	s6,32(sp)
 172:	6be2                	ld	s7,24(sp)
 174:	6125                	addi	sp,sp,96
 176:	8082                	ret

0000000000000178 <stat>:

int
stat(const char *n, struct stat *st)
{
 178:	1101                	addi	sp,sp,-32
 17a:	ec06                	sd	ra,24(sp)
 17c:	e822                	sd	s0,16(sp)
 17e:	e04a                	sd	s2,0(sp)
 180:	1000                	addi	s0,sp,32
 182:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 184:	4581                	li	a1,0
 186:	18e000ef          	jal	314 <open>
  if (fd < 0)
 18a:	02054263          	bltz	a0,1ae <stat+0x36>
 18e:	e426                	sd	s1,8(sp)
 190:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 192:	85ca                	mv	a1,s2
 194:	198000ef          	jal	32c <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	160000ef          	jal	2fc <close>
  return r;
 1a0:	64a2                	ld	s1,8(sp)
}
 1a2:	854a                	mv	a0,s2
 1a4:	60e2                	ld	ra,24(sp)
 1a6:	6442                	ld	s0,16(sp)
 1a8:	6902                	ld	s2,0(sp)
 1aa:	6105                	addi	sp,sp,32
 1ac:	8082                	ret
    return -1;
 1ae:	597d                	li	s2,-1
 1b0:	bfcd                	j	1a2 <stat+0x2a>

00000000000001b2 <atoi>:

int
atoi(const char *s)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 1b8:	00054683          	lbu	a3,0(a0)
 1bc:	fd06879b          	addiw	a5,a3,-48
 1c0:	0ff7f793          	zext.b	a5,a5
 1c4:	4625                	li	a2,9
 1c6:	02f66863          	bltu	a2,a5,1f6 <atoi+0x44>
 1ca:	872a                	mv	a4,a0
  n = 0;
 1cc:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1ce:	0705                	addi	a4,a4,1
 1d0:	0025179b          	slliw	a5,a0,0x2
 1d4:	9fa9                	addw	a5,a5,a0
 1d6:	0017979b          	slliw	a5,a5,0x1
 1da:	9fb5                	addw	a5,a5,a3
 1dc:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1e0:	00074683          	lbu	a3,0(a4)
 1e4:	fd06879b          	addiw	a5,a3,-48
 1e8:	0ff7f793          	zext.b	a5,a5
 1ec:	fef671e3          	bgeu	a2,a5,1ce <atoi+0x1c>
  return n;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  n = 0;
 1f6:	4501                	li	a0,0
 1f8:	bfe5                	j	1f0 <atoi+0x3e>

00000000000001fa <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 200:	02b57463          	bgeu	a0,a1,228 <memmove+0x2e>
    while (n-- > 0)
 204:	00c05f63          	blez	a2,222 <memmove+0x28>
 208:	1602                	slli	a2,a2,0x20
 20a:	9201                	srli	a2,a2,0x20
 20c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 210:	872a                	mv	a4,a0
      *dst++ = *src++;
 212:	0585                	addi	a1,a1,1
 214:	0705                	addi	a4,a4,1
 216:	fff5c683          	lbu	a3,-1(a1)
 21a:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 21e:	fef71ae3          	bne	a4,a5,212 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
    dst += n;
 228:	00c50733          	add	a4,a0,a2
    src += n;
 22c:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 22e:	fec05ae3          	blez	a2,222 <memmove+0x28>
 232:	fff6079b          	addiw	a5,a2,-1
 236:	1782                	slli	a5,a5,0x20
 238:	9381                	srli	a5,a5,0x20
 23a:	fff7c793          	not	a5,a5
 23e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 240:	15fd                	addi	a1,a1,-1
 242:	177d                	addi	a4,a4,-1
 244:	0005c683          	lbu	a3,0(a1)
 248:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 24c:	fee79ae3          	bne	a5,a4,240 <memmove+0x46>
 250:	bfc9                	j	222 <memmove+0x28>

0000000000000252 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 258:	ca05                	beqz	a2,288 <memcmp+0x36>
 25a:	fff6069b          	addiw	a3,a2,-1
 25e:	1682                	slli	a3,a3,0x20
 260:	9281                	srli	a3,a3,0x20
 262:	0685                	addi	a3,a3,1
 264:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 266:	00054783          	lbu	a5,0(a0)
 26a:	0005c703          	lbu	a4,0(a1)
 26e:	00e79863          	bne	a5,a4,27e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 272:	0505                	addi	a0,a0,1
    p2++;
 274:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 276:	fed518e3          	bne	a0,a3,266 <memcmp+0x14>
  }
  return 0;
 27a:	4501                	li	a0,0
 27c:	a019                	j	282 <memcmp+0x30>
      return *p1 - *p2;
 27e:	40e7853b          	subw	a0,a5,a4
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  return 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <memcmp+0x30>

000000000000028c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 294:	f67ff0ef          	jal	1fa <memmove>
}
 298:	60a2                	ld	ra,8(sp)
 29a:	6402                	ld	s0,0(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <sbrk>:

char *
sbrk(int n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2a8:	4585                	li	a1,1
 2aa:	0b2000ef          	jal	35c <sys_sbrk>
}
 2ae:	60a2                	ld	ra,8(sp)
 2b0:	6402                	ld	s0,0(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret

00000000000002b6 <sbrklazy>:

char *
sbrklazy(int n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2be:	4589                	li	a1,2
 2c0:	09c000ef          	jal	35c <sys_sbrk>
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret

00000000000002cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2cc:	4885                	li	a7,1
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d4:	4889                	li	a7,2
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2dc:	488d                	li	a7,3
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e4:	4891                	li	a7,4
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <read>:
.global read
read:
 li a7, SYS_read
 2ec:	4895                	li	a7,5
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <write>:
.global write
write:
 li a7, SYS_write
 2f4:	48c1                	li	a7,16
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <close>:
.global close
close:
 li a7, SYS_close
 2fc:	48d5                	li	a7,21
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <kill>:
.global kill
kill:
 li a7, SYS_kill
 304:	4899                	li	a7,6
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exec>:
.global exec
exec:
 li a7, SYS_exec
 30c:	489d                	li	a7,7
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <open>:
.global open
open:
 li a7, SYS_open
 314:	48bd                	li	a7,15
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31c:	48c5                	li	a7,17
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 324:	48c9                	li	a7,18
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32c:	48a1                	li	a7,8
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <link>:
.global link
link:
 li a7, SYS_link
 334:	48cd                	li	a7,19
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33c:	48d1                	li	a7,20
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 344:	48a5                	li	a7,9
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <dup>:
.global dup
dup:
 li a7, SYS_dup
 34c:	48a9                	li	a7,10
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 354:	48ad                	li	a7,11
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 35c:	48b1                	li	a7,12
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <pause>:
.global pause
pause:
 li a7, SYS_pause
 364:	48b5                	li	a7,13
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36c:	48b9                	li	a7,14
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sync>:
.global sync
sync:
 li a7, SYS_sync
 374:	48d9                	li	a7,22
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mycall>:
.global mycall
mycall:
 li a7, SYS_mycall
 37c:	48dd                	li	a7,23
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <cpustats>:
.global cpustats
cpustats:
 li a7, SYS_cpustats
 384:	48e1                	li	a7,24
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38c:	1101                	addi	sp,sp,-32
 38e:	ec06                	sd	ra,24(sp)
 390:	e822                	sd	s0,16(sp)
 392:	1000                	addi	s0,sp,32
 394:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 398:	4605                	li	a2,1
 39a:	fef40593          	addi	a1,s0,-17
 39e:	f57ff0ef          	jal	2f4 <write>
}
 3a2:	60e2                	ld	ra,24(sp)
 3a4:	6442                	ld	s0,16(sp)
 3a6:	6105                	addi	sp,sp,32
 3a8:	8082                	ret

00000000000003aa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3aa:	715d                	addi	sp,sp,-80
 3ac:	e486                	sd	ra,72(sp)
 3ae:	e0a2                	sd	s0,64(sp)
 3b0:	f84a                	sd	s2,48(sp)
 3b2:	0880                	addi	s0,sp,80
 3b4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 3b6:	c299                	beqz	a3,3bc <printint+0x12>
 3b8:	0805c363          	bltz	a1,43e <printint+0x94>
  neg = 0;
 3bc:	4881                	li	a7,0
 3be:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3c2:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 3c4:	00000517          	auipc	a0,0x0
 3c8:	53450513          	addi	a0,a0,1332 # 8f8 <digits>
 3cc:	883e                	mv	a6,a5
 3ce:	2785                	addiw	a5,a5,1
 3d0:	02c5f733          	remu	a4,a1,a2
 3d4:	972a                	add	a4,a4,a0
 3d6:	00074703          	lbu	a4,0(a4)
 3da:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 3de:	872e                	mv	a4,a1
 3e0:	02c5d5b3          	divu	a1,a1,a2
 3e4:	0685                	addi	a3,a3,1
 3e6:	fec773e3          	bgeu	a4,a2,3cc <printint+0x22>
  if (neg)
 3ea:	00088b63          	beqz	a7,400 <printint+0x56>
    buf[i++] = '-';
 3ee:	fd078793          	addi	a5,a5,-48
 3f2:	97a2                	add	a5,a5,s0
 3f4:	02d00713          	li	a4,45
 3f8:	fee78423          	sb	a4,-24(a5)
 3fc:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 400:	02f05a63          	blez	a5,434 <printint+0x8a>
 404:	fc26                	sd	s1,56(sp)
 406:	f44e                	sd	s3,40(sp)
 408:	fb840713          	addi	a4,s0,-72
 40c:	00f704b3          	add	s1,a4,a5
 410:	fff70993          	addi	s3,a4,-1
 414:	99be                	add	s3,s3,a5
 416:	37fd                	addiw	a5,a5,-1
 418:	1782                	slli	a5,a5,0x20
 41a:	9381                	srli	a5,a5,0x20
 41c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 420:	fff4c583          	lbu	a1,-1(s1)
 424:	854a                	mv	a0,s2
 426:	f67ff0ef          	jal	38c <putc>
  while (--i >= 0)
 42a:	14fd                	addi	s1,s1,-1
 42c:	ff349ae3          	bne	s1,s3,420 <printint+0x76>
 430:	74e2                	ld	s1,56(sp)
 432:	79a2                	ld	s3,40(sp)
}
 434:	60a6                	ld	ra,72(sp)
 436:	6406                	ld	s0,64(sp)
 438:	7942                	ld	s2,48(sp)
 43a:	6161                	addi	sp,sp,80
 43c:	8082                	ret
    x = -xx;
 43e:	40b005b3          	neg	a1,a1
    neg = 1;
 442:	4885                	li	a7,1
    x = -xx;
 444:	bfad                	j	3be <printint+0x14>

0000000000000446 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 446:	711d                	addi	sp,sp,-96
 448:	ec86                	sd	ra,88(sp)
 44a:	e8a2                	sd	s0,80(sp)
 44c:	e0ca                	sd	s2,64(sp)
 44e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 450:	0005c903          	lbu	s2,0(a1)
 454:	28090663          	beqz	s2,6e0 <vprintf+0x29a>
 458:	e4a6                	sd	s1,72(sp)
 45a:	fc4e                	sd	s3,56(sp)
 45c:	f852                	sd	s4,48(sp)
 45e:	f456                	sd	s5,40(sp)
 460:	f05a                	sd	s6,32(sp)
 462:	ec5e                	sd	s7,24(sp)
 464:	e862                	sd	s8,16(sp)
 466:	e466                	sd	s9,8(sp)
 468:	8b2a                	mv	s6,a0
 46a:	8a2e                	mv	s4,a1
 46c:	8bb2                	mv	s7,a2
  state = 0;
 46e:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 470:	4481                	li	s1,0
 472:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 474:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 478:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 47c:	06c00c93          	li	s9,108
 480:	a005                	j	4a0 <vprintf+0x5a>
        putc(fd, c0);
 482:	85ca                	mv	a1,s2
 484:	855a                	mv	a0,s6
 486:	f07ff0ef          	jal	38c <putc>
 48a:	a019                	j	490 <vprintf+0x4a>
    } else if (state == '%') {
 48c:	03598263          	beq	s3,s5,4b0 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 490:	2485                	addiw	s1,s1,1
 492:	8726                	mv	a4,s1
 494:	009a07b3          	add	a5,s4,s1
 498:	0007c903          	lbu	s2,0(a5)
 49c:	22090a63          	beqz	s2,6d0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4a0:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 4a4:	fe0994e3          	bnez	s3,48c <vprintf+0x46>
      if (c0 == '%') {
 4a8:	fd579de3          	bne	a5,s5,482 <vprintf+0x3c>
        state = '%';
 4ac:	89be                	mv	s3,a5
 4ae:	b7cd                	j	490 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 4b0:	00ea06b3          	add	a3,s4,a4
 4b4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4b8:	8636                	mv	a2,a3
      if (c1)
 4ba:	c681                	beqz	a3,4c2 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 4bc:	9752                	add	a4,a4,s4
 4be:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 4c2:	05878363          	beq	a5,s8,508 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 4c6:	05978d63          	beq	a5,s9,520 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 4ca:	07500713          	li	a4,117
 4ce:	0ee78763          	beq	a5,a4,5bc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 4d2:	07800713          	li	a4,120
 4d6:	12e78963          	beq	a5,a4,608 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 4da:	07000713          	li	a4,112
 4de:	14e78e63          	beq	a5,a4,63a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 4e2:	06300713          	li	a4,99
 4e6:	18e78e63          	beq	a5,a4,682 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 4ea:	07300713          	li	a4,115
 4ee:	1ae78463          	beq	a5,a4,696 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 4f2:	02500713          	li	a4,37
 4f6:	04e79563          	bne	a5,a4,540 <vprintf+0xfa>
        putc(fd, '%');
 4fa:	02500593          	li	a1,37
 4fe:	855a                	mv	a0,s6
 500:	e8dff0ef          	jal	38c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 504:	4981                	li	s3,0
 506:	b769                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 508:	008b8913          	addi	s2,s7,8
 50c:	4685                	li	a3,1
 50e:	4629                	li	a2,10
 510:	000ba583          	lw	a1,0(s7)
 514:	855a                	mv	a0,s6
 516:	e95ff0ef          	jal	3aa <printint>
 51a:	8bca                	mv	s7,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	bf8d                	j	490 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 520:	06400793          	li	a5,100
 524:	02f68963          	beq	a3,a5,556 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 528:	06c00793          	li	a5,108
 52c:	04f68263          	beq	a3,a5,570 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 530:	07500793          	li	a5,117
 534:	0af68063          	beq	a3,a5,5d4 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 538:	07800793          	li	a5,120
 53c:	0ef68263          	beq	a3,a5,620 <vprintf+0x1da>
        putc(fd, '%');
 540:	02500593          	li	a1,37
 544:	855a                	mv	a0,s6
 546:	e47ff0ef          	jal	38c <putc>
        putc(fd, c0);
 54a:	85ca                	mv	a1,s2
 54c:	855a                	mv	a0,s6
 54e:	e3fff0ef          	jal	38c <putc>
      state = 0;
 552:	4981                	li	s3,0
 554:	bf35                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 556:	008b8913          	addi	s2,s7,8
 55a:	4685                	li	a3,1
 55c:	4629                	li	a2,10
 55e:	000bb583          	ld	a1,0(s7)
 562:	855a                	mv	a0,s6
 564:	e47ff0ef          	jal	3aa <printint>
        i += 1;
 568:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
        i += 1;
 56e:	b70d                	j	490 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 570:	06400793          	li	a5,100
 574:	02f60763          	beq	a2,a5,5a2 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 578:	07500793          	li	a5,117
 57c:	06f60963          	beq	a2,a5,5ee <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 580:	07800793          	li	a5,120
 584:	faf61ee3          	bne	a2,a5,540 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 588:	008b8913          	addi	s2,s7,8
 58c:	4681                	li	a3,0
 58e:	4641                	li	a2,16
 590:	000bb583          	ld	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	e15ff0ef          	jal	3aa <printint>
        i += 2;
 59a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
        i += 2;
 5a0:	bdc5                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000bb583          	ld	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	dfbff0ef          	jal	3aa <printint>
        i += 2;
 5b4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
        i += 2;
 5ba:	bdd9                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4629                	li	a2,10
 5c4:	000be583          	lwu	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	de1ff0ef          	jal	3aa <printint>
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bd7d                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4681                	li	a3,0
 5da:	4629                	li	a2,10
 5dc:	000bb583          	ld	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	dc9ff0ef          	jal	3aa <printint>
        i += 1;
 5e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
        i += 1;
 5ec:	b555                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4629                	li	a2,10
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	dafff0ef          	jal	3aa <printint>
        i += 2;
 600:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 2;
 606:	b569                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000be583          	lwu	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	d95ff0ef          	jal	3aa <printint>
 61a:	8bca                	mv	s7,s2
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bd8d                	j	490 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 620:	008b8913          	addi	s2,s7,8
 624:	4681                	li	a3,0
 626:	4641                	li	a2,16
 628:	000bb583          	ld	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	d7dff0ef          	jal	3aa <printint>
        i += 1;
 632:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
        i += 1;
 638:	bda1                	j	490 <vprintf+0x4a>
 63a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 63c:	008b8d13          	addi	s10,s7,8
 640:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 644:	03000593          	li	a1,48
 648:	855a                	mv	a0,s6
 64a:	d43ff0ef          	jal	38c <putc>
  putc(fd, 'x');
 64e:	07800593          	li	a1,120
 652:	855a                	mv	a0,s6
 654:	d39ff0ef          	jal	38c <putc>
 658:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65a:	00000b97          	auipc	s7,0x0
 65e:	29eb8b93          	addi	s7,s7,670 # 8f8 <digits>
 662:	03c9d793          	srli	a5,s3,0x3c
 666:	97de                	add	a5,a5,s7
 668:	0007c583          	lbu	a1,0(a5)
 66c:	855a                	mv	a0,s6
 66e:	d1fff0ef          	jal	38c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 672:	0992                	slli	s3,s3,0x4
 674:	397d                	addiw	s2,s2,-1
 676:	fe0916e3          	bnez	s2,662 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 67a:	8bea                	mv	s7,s10
      state = 0;
 67c:	4981                	li	s3,0
 67e:	6d02                	ld	s10,0(sp)
 680:	bd01                	j	490 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 682:	008b8913          	addi	s2,s7,8
 686:	000bc583          	lbu	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	d01ff0ef          	jal	38c <putc>
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	bbf5                	j	490 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 696:	008b8993          	addi	s3,s7,8
 69a:	000bb903          	ld	s2,0(s7)
 69e:	00090f63          	beqz	s2,6bc <vprintf+0x276>
        for (; *s; s++)
 6a2:	00094583          	lbu	a1,0(s2)
 6a6:	c195                	beqz	a1,6ca <vprintf+0x284>
          putc(fd, *s);
 6a8:	855a                	mv	a0,s6
 6aa:	ce3ff0ef          	jal	38c <putc>
        for (; *s; s++)
 6ae:	0905                	addi	s2,s2,1
 6b0:	00094583          	lbu	a1,0(s2)
 6b4:	f9f5                	bnez	a1,6a8 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 6b6:	8bce                	mv	s7,s3
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bbd9                	j	490 <vprintf+0x4a>
          s = "(null)";
 6bc:	00000917          	auipc	s2,0x0
 6c0:	23490913          	addi	s2,s2,564 # 8f0 <malloc+0x128>
        for (; *s; s++)
 6c4:	02800593          	li	a1,40
 6c8:	b7c5                	j	6a8 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 6ca:	8bce                	mv	s7,s3
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b3c9                	j	490 <vprintf+0x4a>
 6d0:	64a6                	ld	s1,72(sp)
 6d2:	79e2                	ld	s3,56(sp)
 6d4:	7a42                	ld	s4,48(sp)
 6d6:	7aa2                	ld	s5,40(sp)
 6d8:	7b02                	ld	s6,32(sp)
 6da:	6be2                	ld	s7,24(sp)
 6dc:	6c42                	ld	s8,16(sp)
 6de:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6e0:	60e6                	ld	ra,88(sp)
 6e2:	6446                	ld	s0,80(sp)
 6e4:	6906                	ld	s2,64(sp)
 6e6:	6125                	addi	sp,sp,96
 6e8:	8082                	ret

00000000000006ea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ea:	715d                	addi	sp,sp,-80
 6ec:	ec06                	sd	ra,24(sp)
 6ee:	e822                	sd	s0,16(sp)
 6f0:	1000                	addi	s0,sp,32
 6f2:	e010                	sd	a2,0(s0)
 6f4:	e414                	sd	a3,8(s0)
 6f6:	e818                	sd	a4,16(s0)
 6f8:	ec1c                	sd	a5,24(s0)
 6fa:	03043023          	sd	a6,32(s0)
 6fe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 702:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 706:	8622                	mv	a2,s0
 708:	d3fff0ef          	jal	446 <vprintf>
}
 70c:	60e2                	ld	ra,24(sp)
 70e:	6442                	ld	s0,16(sp)
 710:	6161                	addi	sp,sp,80
 712:	8082                	ret

0000000000000714 <printf>:

void
printf(const char *fmt, ...)
{
 714:	711d                	addi	sp,sp,-96
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e40c                	sd	a1,8(s0)
 71e:	e810                	sd	a2,16(s0)
 720:	ec14                	sd	a3,24(s0)
 722:	f018                	sd	a4,32(s0)
 724:	f41c                	sd	a5,40(s0)
 726:	03043823          	sd	a6,48(s0)
 72a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	00840613          	addi	a2,s0,8
 732:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 736:	85aa                	mv	a1,a0
 738:	4505                	li	a0,1
 73a:	d0dff0ef          	jal	446 <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6125                	addi	sp,sp,96
 744:	8082                	ret

0000000000000746 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 746:	1141                	addi	sp,sp,-16
 748:	e422                	sd	s0,8(sp)
 74a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 74c:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	00001797          	auipc	a5,0x1
 754:	8b07b783          	ld	a5,-1872(a5) # 1000 <freep>
 758:	a02d                	j	782 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 75a:	4618                	lw	a4,8(a2)
 75c:	9f2d                	addw	a4,a4,a1
 75e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	6398                	ld	a4,0(a5)
 764:	6310                	ld	a2,0(a4)
 766:	a83d                	j	7a4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9f31                	addw	a4,a4,a2
 76e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053683          	ld	a3,-16(a0)
 774:	a091                	j	7b8 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	6398                	ld	a4,0(a5)
 778:	00e7e463          	bltu	a5,a4,780 <free+0x3a>
 77c:	00e6ea63          	bltu	a3,a4,790 <free+0x4a>
{
 780:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	fed7fae3          	bgeu	a5,a3,776 <free+0x30>
 786:	6398                	ld	a4,0(a5)
 788:	00e6e463          	bltu	a3,a4,790 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	fee7eae3          	bltu	a5,a4,780 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 790:	ff852583          	lw	a1,-8(a0)
 794:	6390                	ld	a2,0(a5)
 796:	02059813          	slli	a6,a1,0x20
 79a:	01c85713          	srli	a4,a6,0x1c
 79e:	9736                	add	a4,a4,a3
 7a0:	fae60de3          	beq	a2,a4,75a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 7a8:	4790                	lw	a2,8(a5)
 7aa:	02061593          	slli	a1,a2,0x20
 7ae:	01c5d713          	srli	a4,a1,0x1c
 7b2:	973e                	add	a4,a4,a5
 7b4:	fae68ae3          	beq	a3,a4,768 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ba:	00001717          	auipc	a4,0x1
 7be:	84f73323          	sd	a5,-1978(a4) # 1000 <freep>
}
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	addi	sp,sp,16
 7c6:	8082                	ret

00000000000007c8 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 7c8:	7139                	addi	sp,sp,-64
 7ca:	fc06                	sd	ra,56(sp)
 7cc:	f822                	sd	s0,48(sp)
 7ce:	f426                	sd	s1,40(sp)
 7d0:	ec4e                	sd	s3,24(sp)
 7d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7d4:	02051493          	slli	s1,a0,0x20
 7d8:	9081                	srli	s1,s1,0x20
 7da:	04bd                	addi	s1,s1,15
 7dc:	8091                	srli	s1,s1,0x4
 7de:	0014899b          	addiw	s3,s1,1
 7e2:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 7e4:	00001517          	auipc	a0,0x1
 7e8:	81c53503          	ld	a0,-2020(a0) # 1000 <freep>
 7ec:	c915                	beqz	a0,820 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 7ee:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 7f0:	4798                	lw	a4,8(a5)
 7f2:	08977a63          	bgeu	a4,s1,886 <malloc+0xbe>
 7f6:	f04a                	sd	s2,32(sp)
 7f8:	e852                	sd	s4,16(sp)
 7fa:	e456                	sd	s5,8(sp)
 7fc:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 7fe:	8a4e                	mv	s4,s3
 800:	0009871b          	sext.w	a4,s3
 804:	6685                	lui	a3,0x1
 806:	00d77363          	bgeu	a4,a3,80c <malloc+0x44>
 80a:	6a05                	lui	s4,0x1
 80c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 810:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 814:	00000917          	auipc	s2,0x0
 818:	7ec90913          	addi	s2,s2,2028 # 1000 <freep>
  if (p == SBRK_ERROR)
 81c:	5afd                	li	s5,-1
 81e:	a081                	j	85e <malloc+0x96>
 820:	f04a                	sd	s2,32(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 828:	00000797          	auipc	a5,0x0
 82c:	7e878793          	addi	a5,a5,2024 # 1010 <base>
 830:	00000717          	auipc	a4,0x0
 834:	7cf73823          	sd	a5,2000(a4) # 1000 <freep>
 838:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83a:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 83e:	b7c1                	j	7fe <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 840:	6398                	ld	a4,0(a5)
 842:	e118                	sd	a4,0(a0)
 844:	a8a9                	j	89e <malloc+0xd6>
  hp->s.size = nu;
 846:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 84a:	0541                	addi	a0,a0,16
 84c:	efbff0ef          	jal	746 <free>
  return freep;
 850:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 854:	c12d                	beqz	a0,8b6 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 856:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 858:	4798                	lw	a4,8(a5)
 85a:	02977263          	bgeu	a4,s1,87e <malloc+0xb6>
    if (p == freep)
 85e:	00093703          	ld	a4,0(s2)
 862:	853e                	mv	a0,a5
 864:	fef719e3          	bne	a4,a5,856 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 868:	8552                	mv	a0,s4
 86a:	a37ff0ef          	jal	2a0 <sbrk>
  if (p == SBRK_ERROR)
 86e:	fd551ce3          	bne	a0,s5,846 <malloc+0x7e>
        return 0;
 872:	4501                	li	a0,0
 874:	7902                	ld	s2,32(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
 87c:	a03d                	j	8aa <malloc+0xe2>
 87e:	7902                	ld	s2,32(sp)
 880:	6a42                	ld	s4,16(sp)
 882:	6aa2                	ld	s5,8(sp)
 884:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 886:	fae48de3          	beq	s1,a4,840 <malloc+0x78>
        p->s.size -= nunits;
 88a:	4137073b          	subw	a4,a4,s3
 88e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 890:	02071693          	slli	a3,a4,0x20
 894:	01c6d713          	srli	a4,a3,0x1c
 898:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89e:	00000717          	auipc	a4,0x0
 8a2:	76a73123          	sd	a0,1890(a4) # 1000 <freep>
      return (void *)(p + 1);
 8a6:	01078513          	addi	a0,a5,16
  }
}
 8aa:	70e2                	ld	ra,56(sp)
 8ac:	7442                	ld	s0,48(sp)
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	69e2                	ld	s3,24(sp)
 8b2:	6121                	addi	sp,sp,64
 8b4:	8082                	ret
 8b6:	7902                	ld	s2,32(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
 8be:	b7f5                	j	8aa <malloc+0xe2>
