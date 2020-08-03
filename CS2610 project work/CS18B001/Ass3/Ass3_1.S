#The code below jumps from M mode to S mode and then to U mode by setting mpp and spp bits and
#jumps from U mode to S mode and from S mode to M mode using e call
#it then stays in an infinite loop in M mode 


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

#machine mode
_start:
        li sp, STACK_BASE_ADDR      
        la t0, trap_entry
        csrw mtvec, t0 #mtvec has been set to trap_entry

        andi t0, t0, 0
        li t0, 0xffff
        csrs medeleg, t0

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
        
#now switching back to S mode 
        ecall #this ecall from user mode is handled by supervisor trap handler
#user mode end


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

ecall #this ecall from supervisor mode is handled by machine mode trap handler

j seh_end
