#	boot.s
# It then loads the system at 0x10000, using BIOS interrupts.Then move 
# system code to address 0x00000000. Thereafterit disables all interrupts,
# changes to protected mode, and jmp to the system code. 

BOOTSEG = 0x07c0        # boot sector will be load to 0x7c00 by BIOS 
SYSSEG  = 0x1000	# system loaded at 0x10000 (65536).
SYSLEN  = 17		# sectors occupied by the kernel.
.code16
.text
	.globl _start
_start:
	ljmp $BOOTSEG,$go     #跳转指令，用于设置cs段寄存器
go:	movw %cs,%ax
	movw %ax,%ds
	movw %ax,%ss
	mov $0x400,%sp        #地址只需要大于boot程序的末端(512)，
                              #并留有一定的空间   
load_system:
	movw $0x0000,%dx       #BIOS0x13号中断，功能号2
	movw $0x0002,%cx       #DH-磁头号 DL-驱动器号 CH-10位磁道号低8位
	movw $SYSSEG,%ax       #CL-位7、6是磁道号高2位 5～0起始扇区号（从1开始）
	movw %ax,%es           #ES:BX 读入缓冲区位置
	xor %bx,%bx
	movw $0x200+SYSLEN,%ax  #AH-读取扇区功能号，AL-读取的扇区数
	int $0x13
	jnc load_complete
die:	jmp die
	
load_complete:
	cli
	movw $SYSSEG,%ax        #将内核移动到地址0开始的位置
	movw %ax,%ds
	xor %ax,%ax
	movw %ax,%es
	mov $0x1000,%cx
	sub %si,%si
	sub %di,%di
	rep movsw                #重复移动DS:SI到ES:DI	
	
	movw $BOOTSEG,%ax
	movw %ax,%ds
	lidt idt_48             #加载IDTR 6字节操作数：2字节表长，4字节线性基址
	lgdt gdt_48             #加载GDTR 6字节操作数：2字节表长，4字节线性基址

#进入保护模式	
	movw $0x0001,%ax        #加载CR0(机器状态字)的位0～15
	lmsw %ax
	ljmp $8,$0                #加载eip=0，cs=8 此时cs内容：0000 0000 0000 1 000 后三位分
                                #别是TI和RPL
	

gdt:	.word	0,0,0,0		#保留不用

	.word	0x07FF		# 8Mb - limit=2047 (2048*4096=8Mb)
	.word	0x0000		# base address=0x00000
	.word	0x9A00		# code read/exec
	.word	0x00C0		# granularity=4096, 386

	.word	0x07FF		# 8Mb - limit=2047 (2048*4096=8Mb)
	.word	0x0000		# base address=0x00000
	.word	0x9200		# data read/write
	.word	0x00C0		# granularity=4096, 386

idt_48: .word	0		# idt limit=0
	.word	0,0		# idt base=0L
gdt_48: .word	0x7FF		# gdt limit=2048, 256 GDT entries
	.word	0x7c00+gdt,0	# gdt base = 07xxx
.org 510
	.word   0xAA55

