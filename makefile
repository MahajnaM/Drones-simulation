# All Targets
all: ass3

ass3: ass3.o drone.o printer.o scheduler.o target.o
	gcc -m32 -Wall -g ass3.o drone.o printer.o scheduler.o target.o -o ass3

target.o: target.s
	nasm -f elf32 target.s -o target.o

drone.o: drone.s
	nasm -f elf32 drone.s -o drone.o

printer.o: printer.s
	nasm -f elf32 printer.s -o printer.o

scheduler.o: scheduler.s
	nasm -f elf32 scheduler.s -o scheduler.o

ass3.o: ass3.s
	nasm -f elf32 ass3.s -o ass3.o








#tell make that "clean" is not a file name!
.PHONY: clean

# Check memory leak using valgrind
memleak: all
	valgrind --leak-check=full --show-reachable=yes ./ass3 5 8 10 30 15019

#Clean the build directory
clean: 
	rm -f *.o ass3