#3 system calls need to be handled in supervisor mode: bite, cite and kite
#Use ecall from user mode to return to Supervisor mode using a0,...,a7 registers to pass the arguments
#_if bite is called set a0=1
#_if cite is called set a0=2
#_if kite is called set a0=3 and check a0 in trap_handler to identify the system call
#_if more than 8 arguments need to be passed use a stack
#The program ends in an infinite loop in user mode 


#if __riscv_xlen ==  64
#define LREG ld
#define SREG sd
#define REGBYTES 8
#else
#define LREG lw
#define SREG sw
#define REGBYTES 4
#endif

#define STACK_BASE_ADDR 0x10012000

_start:
        li sp, STACK_BASE_ADDR      
        la t0, trap_entry
        csrw mtvec, t0 #mtvec has been set to trap_entry

        andi t0, t0, 0
        li t0, 0xffff
        csrs medeleg, t0
        #setting medeleg reg to handle traps in supervisor mode since, ecall is a trap

        andi t0, t0, 0
        li t0, 0x1800
        csrrc zero, mstatus, t0
        li t0, 0x0800
        csrs mstatus, t0 #setting mpp bits

        la t0, s_mode_begin 
        csrw mepc, t0
        mret 

#supervisor mode
s_mode_begin:
#setting stvec
        la x17, _data1
        csrw stvec, x17 
#switching to user mode
        li t0, 0x0100
        csrc sstatus, t0 #set spp bit
        la t0, u_mode_begin 

        csrw sepc, t0
        sret

#user mode
u_mode_begin:
#The functions(system calls) will be called from here
#setting a0 bit which will help decide which system call is this in the trap handler
#bite(10, 95, 66)
    andi a0, a0, 0
    addi a0, a0, 1
    andi a1, a1, 0
    addi a1, a1, 10
    andi a2, a2, 0
    addi a2, a2, 95
    andi a3, a3, 0
    addi a3, a3, 66
    #all arguments passed in a1, a2, a3 reg
    ecall
#cite(23, 67)
    andi a0, a0, 0
    addi a0, a0, 2
    andi a1, a1, 0
    addi a1, a1, 23
    andi a2, a2, 0
    addi a2, a2, 67
    ecall 
#kite(35, 99, 12, 13, 0, 4, 5, 9, 12, 1, 2, 2, 3, 9)
#since more than 8 arguments are there we will us a stack
    andi a0, a0, 0
    addi a0, a0, 3

    addi sp, sp, -15*8

    andi x1, x1, 0
    addi x1, x1, 35
    sd x1, 1*8(sp)

    andi x1, x1, 0
    addi x1, x1, 99
    sd x1, 2*8(sp)

    andi x1, x1, 0
    addi x1, x1, 12
    sd x1, 3*8(sp)

    andi x1, x1, 0
    addi x1, x1, 13
    sd x1, 4*8(sp)

    andi x1, x1, 0
    addi x1, x1, 0
    sd x1, 5*8(sp)

    andi x1, x1, 0
    addi x1, x1, 4
    sd x1, 6*8(sp)

    andi x1, x1, 0
    addi x1, x1, 5
    sd x1, 7*8(sp)

    andi x1, x1, 0
    addi x1, x1, 9
    sd x1, 8*8(sp)

    andi x1, x1, 0
    addi x1, x1, 12
    sd x1, 9*8(sp)

    andi x1, x1, 0
    addi x1, x1, 1
    sd x1, 10*8(sp)

    andi x1, x1, 0
    addi x1, x1, 2
    sd x1, 11*8(sp)

    andi x1, x1, 0
    addi x1, x1, 2
    sd x1, 12*8(sp)

    andi x1, x1, 0
    addi x1, x1, 3
    sd x1, 13*8(sp)
    
    andi x1, x1, 0
    addi x1, x1, 9
    sd x1, 14*8(sp)

    ecall 

here: j here 
#user mode ends


#trap handler code
trap_handler:
#chk the mcause for interrupt or exception
	csrr t0,mcause
	li t3, 0x80000000
	and t0,t0,t3
	beqz t0, exception_handler
1:      ret

#code for handling exceptions
exception_handler:
#we are storing the no of times an exception happens in memory
	  
    #check ecall
    csrr t0, mcause 
    and t1,t0, 0x9 
    bnez t1, s_ecall_hdlr

    meh_end: j 1b

    s_ecall_hdlr:
#handles e call from supervisor 
#Do appropriate thing here
    here: j here 
	j meh_end



#entry point for trap
.p2align 2
trap_entry:     # currently trap_entry saves base reg values and calls trap handler
addi sp, sp, -32*8
 #x0 is always 0
sd x1, 1*8(sp)
sd x2, 2*8(sp)
sd x3, 3*8(sp)
sd x4, 4*8(sp)
sd x5, 5*8(sp)
sd x6, 6*8(sp)
sd x7, 7*8(sp)
sd x8, 8*8(sp)
sd x9, 9*8(sp)
sd x10, 10*8(sp)
sd x11, 11*8(sp)
sd x12, 12*8(sp)
sd x13, 13*8(sp)
sd x14, 14*8(sp)
sd x15, 15*8(sp)
sd x16, 16*8(sp)
sd x17, 17*8(sp)
sd x18, 18*8(sp)
sd x19, 19*8(sp)
sd x20, 20*8(sp)
sd x21, 21*8(sp)
sd x22, 22*8(sp)
sd x23, 23*8(sp)
sd x24, 24*8(sp)
sd x25, 25*8(sp)
sd x26, 26*8(sp)
sd x27, 27*8(sp)
sd x28, 28*8(sp)
sd x29, 29*8(sp)
sd x30, 30*8(sp)
sd x31, 31*8(sp)

#jump to trap handler
jal trap_handler

ld x1, 1*8(sp)
ld x2, 2*8(sp)
ld x3, 3*8(sp)
ld x4, 4*8(sp)
ld x5, 5*8(sp)
ld x6, 6*8(sp)
ld x7, 7*8(sp)
ld x8, 8*8(sp)
ld x9, 9*8(sp)
ld x10, 10*8(sp)
ld x11, 11*8(sp)
ld x12, 12*8(sp)
ld x13, 13*8(sp)
ld x14, 14*8(sp)
ld x15, 15*8(sp)
ld x16, 16*8(sp)
ld x17, 17*8(sp)
ld x18, 18*8(sp)
ld x19, 19*8(sp)
ld x20, 20*8(sp)
ld x21, 21*8(sp)
ld x22, 22*8(sp)
ld x23, 23*8(sp)
ld x24, 24*8(sp)
ld x25, 25*8(sp)
ld x26, 26*8(sp)
ld x27, 27*8(sp)
ld x28, 28*8(sp)
ld x29, 29*8(sp)
ld x30, 30*8(sp)
ld x31, 31*8(sp)
mret

#some data section
.p2align 2
_data1:     # currently trap_entry saves base reg values and calls trap handler
addi sp, sp, -32*8
 #x0 is always 0
sd x1, 1*8(sp)
sd x2, 2*8(sp)
sd x3, 3*8(sp)
sd x4, 4*8(sp)
sd x5, 5*8(sp)
sd x6, 6*8(sp)
sd x7, 7*8(sp)
sd x8, 8*8(sp)
sd x9, 9*8(sp)
sd x10, 10*8(sp)
sd x11, 11*8(sp)
sd x12, 12*8(sp)
sd x13, 13*8(sp)
sd x14, 14*8(sp)
sd x15, 15*8(sp)
sd x16, 16*8(sp)
sd x17, 17*8(sp)
sd x18, 18*8(sp)
sd x19, 19*8(sp)
sd x20, 20*8(sp)
sd x21, 21*8(sp)
sd x22, 22*8(sp)
sd x23, 23*8(sp)
sd x24, 24*8(sp)
sd x25, 25*8(sp)
sd x26, 26*8(sp)
sd x27, 27*8(sp)
sd x28, 28*8(sp)
sd x29, 29*8(sp)
sd x30, 30*8(sp)
sd x31, 31*8(sp)

#jump to trap handler
jal strap_handler

ld x1, 1*8(sp)
ld x2, 2*8(sp)
ld x3, 3*8(sp)
ld x4, 4*8(sp)
ld x5, 5*8(sp)
ld x6, 6*8(sp)
ld x7, 7*8(sp)
ld x8, 8*8(sp)
ld x9, 9*8(sp)
ld x10, 10*8(sp)
ld x11, 11*8(sp)
ld x12, 12*8(sp)
ld x13, 13*8(sp)
ld x14, 14*8(sp)
ld x15, 15*8(sp)
ld x16, 16*8(sp)
ld x17, 17*8(sp)
ld x18, 18*8(sp)
ld x19, 19*8(sp)
ld x20, 20*8(sp)
ld x21, 21*8(sp)
ld x22, 22*8(sp)
ld x23, 23*8(sp)
ld x24, 24*8(sp)
ld x25, 25*8(sp)
ld x26, 26*8(sp)
ld x27, 27*8(sp)
ld x28, 28*8(sp)
ld x29, 29*8(sp)
ld x30, 30*8(sp)
ld x31, 31*8(sp)
sret

#trap handler in S mode
strap_handler:
	#extracting msb of scause
    csrr t0, scause
    li t3, 0x80000000
    and t0, t0, t3
    beqz t0, sexception_handler 
1: ret


sexception_handler:

csrr t0,scause

#check for trap as ecall from user mode
and t1,t0, 0x8
bnez t1, u_ecall_hdlr


seh_end: j 1b


u_ecall_hdlr:
#please use the value in a0 here
#For example, if you want to put the char on a uart termninal
#pass this a0 value to the uart driver code


#check a0 register to jump to instruction code of appropriate system call
#_if a0 = 1 jump to set of instructions whice execute bite 
#_if a0 = 2 jump to set of instructions whice execute cite
#_if a0 = 3 jump to set of instructions whice execute kite


j seh_end
