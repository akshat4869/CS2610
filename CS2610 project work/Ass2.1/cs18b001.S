#define mtime 0x200bff8
#define mtimecmp 0x2004000

_start:
andi t4,t4,0
andi t2,t2,0
andi t3,t3,0
andi t6,t6,0

la t6,mtimecmp
andi t3,t3,0
addi t3,t3,-1
sw t3,0(t6)

lui sp, 0x1011

la t0,vtrap_entry
csrw mtvec,t0

andi t1,t1,0
addi t1,t1,1
csrs mtvec,t1

la t6,mtimecmp
addi t4,t4,900
slli t4,t4,63
lui t4,0x80000
addi t4,t4,999

la t2,mtime
ld t3,0(t2)
add t3,t4,t3
sd t3,0(t6)

li t0,8
csrrs zero,mstatus,0

li t0, 0x80
csrrs zero,mie,t0

here : j here


.p2align 2
vtrap_entry:
j a_handler
nop
j b_handler
nop
j c_handler
nop
j d_handler
nop
j e_handler
nop
j f_handler
nop
j g_handler
nop
j m_ti_int_handler
nop



m_ti_int_handler:
la t6,mtimecmp
andi t3,t3,0
addi t3,t3,-1
sd t3,0(t6)
j here