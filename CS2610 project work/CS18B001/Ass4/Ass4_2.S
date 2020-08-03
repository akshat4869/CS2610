#machine mode code excluding the trap handler part is read write and execute protected
#this is done using pmp
#machine mode code starts from 0x10010000
#I have set up page tables for 0x10010000 in machine mode. So, the machine mode code will be executed even after the satp reg is set 
#supervisor code begins from address 0x10011000 (I have done a p2align 12)
#This page has an infinite loop (The dummy process)
#But I have not set up the page table for 0x10011000. So, I get a page fault when I try to execute this.
#Trap Delegation is allowed. So, this page fault is handled by the supervisor trap handler 
#Note that the code for the supervisor trap handler is on another page(from 0x10012000)
#and the page table for 0x10012000 has already been set up in machine mode code 
#I set the page table entry for 0x10011000 in supervisor trap handler and return to the infinite loop
#Note: Also need to set the page table for 0x10022000 in machine mode 
#This is because I'm accessing this memory in supervisor trap handler while setting page table entry for 0x10011000


#if __riscv_xlen ==  64
#define LREG ld
#define SREG sd
#define REGBYTES 8
#else
#define LREG lw
#define SREG sw
#define REGBYTES 4
#endif

#define STACK_BASE_ADDR 0x10010900

#machine mode code start
_start:
#pmp_begin
la t1, _start 
srli t1,t1,2
csrw pmpaddr0, t1 #setting start address

li t0, 0x000000f0  #setting pmp0cfg
csrc pmpcfg0, t0

la t1, machine_mode_end 
srli t1,t1,2
csrw pmpaddr1, t1 #setting end address

li t0, 0x800
csrs pmpcfg0, t0 #setting pmp1cfg
#pmp_end



li sp, STACK_BASE_ADDR  #set sp
la t0, trap_entry        
csrw mtvec, t0  #setting mtvec for handling traps 

andi t0, t0, 0
li t0, 0xffff
csrs medeleg, t0 #enabling trap delegation 
#setting medeleg reg to handle traps in supervisor mode

#setting up 3 level page table for 0x10010000
li t0, 0x10020000
li t1, 0x4008401
sd t1,0(t0)

li t0, 0x10021400
li t1, 0x4008801
sd t1,0(t0)

li t0, 0x10022080
li t1, 0x400404f
sd t1,0(t0)
#done setting up page table for 0x10010000
#setting up 3 level page table for 0x10012000

li t0, 0x10022090
li t1, 0x400484f
sd t1,0(t0)

#done setting up page table for 0x10012000
#setting up 3 level page table for 0x10022000

li t0, 0x10022110
li t1, 0x40088cf
sd t1,0(t0)

#done setting up page table for 0x1002200

#switching to supervisor mode
andi t0, t0, 0
li t0, 0x1800
csrrc zero, mstatus, t0
li t0, 0x0800
csrs mstatus, t0 #setting mpp bits

la t0, s_mode_begin 
csrw mepc, t0

la x17, _data1
csrw stvec, x17 #set stvec for handling traps in supervisor mode

#setting satp register
andi t0,t0,0
addi t0,t0,8
slli t0,t0,60

li t1,0x10020000
srli t1,t1,12

or t0, t1, t0
csrw satp, t0
#After this any address is a virtual address
mret
machine_mode_end:
#machine mode code end




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






#supervisor mode code
.p2align 12
s_mode_begin:
    infloop:
        j infloop  #Dummy process


.p2align 12
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
#set page table entry here for 0x10011000
#setting up 3 level page table for 0x10022000
li t0, 0x10022088
li t1, 0x400444f
sd t1,0(t0)
#done setting up page table for 0x10022000
j 1b
