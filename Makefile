# Makefile for the simple example kernel.
AS =as
LD =ld
LDFLAGS =-m elf_i386 -Ttext 0 -e startup_32 -s -x -M 

all: Image

Image: boot system
	objcopy -O binary boot.o Image
	objcopy -O binary system head
	cat head >> Image

head.o: head.s

system: head.o 
	$(LD) $(LDFLAGS) head.o -o system > System.map

boot: boot.s
	$(AS) -o boot.o boot.s

clean:
	rm -f Image System.map core boot *.o system
