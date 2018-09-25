#
# created by Enkhbold Ochirsuren
# last change: 2007.07.11
# TOS application for LEON2+RFU2 simulation
#

leon2_tb_dir := /home/boldoo/leon2-rfu-2/RFU_Projekt/PrimeRFU/leon_tb # LEON2 testbench directory
rfu2_lib_dir  := /opt/tinyos-2.x/tos/chips/leon2/rfu # RFU2 library directory

tinyos:
	sparc-elf-as boot.S -o boot.o
	sparc-elf-gcc -static -nostdlib -O2 -Tlinkfpga boot.o app.c -L$(rfu2_lib_dir) -lrfu2 -e start -o app.bin --save-temps
	sparc-elf-objdump -x -d app.bin > app.bin.dump
	sparc-elf-objcopy --remove-section=.comment app.bin
	sparc-elf-objcopy --only-section=.text app.bin app.text
	sparc-elf-objdump -s app.text | grep "^ " | awk '{print $$2 "\n" $$3 "\n" $$4 "\n" $$5}' | ./hex2bit | grep -v "^$$" > app.romimage
	sparc-elf-objcopy --only-section=.data app.bin app.data
	sparc-elf-objdump -s app.data | grep "^ " | awk '{print $$2 "\n" $$3 "\n" $$4 "\n" $$5}' | ./hex2bit | grep -v "^$$" >> app.romimage
	rm app.text app.data
	cp app.romimage testout.txt
	./vhdlrom2007.exe # rom image to rom.vhd
	scp rom.vhd boldoo@asterix:$(leon2_tb_dir) # for simulation
	scp app.bin.dump boldoo@asterix:$(leon2_tb_dir) # for software debugging
