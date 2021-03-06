# Kernel Version Check
KVER  := $(shell uname -r | cut -c1-3 | sed 's/2\.[56]/2\.6/')

# Makefile for a basic kernel module - 2.4.x
KINC=
ifeq ($(KINC),)
KINC  := $(shell uname -r)
endif
CC    := gcc
MODCFLAGS := -DMODULE -D__KERNEL__ -DLINUX -DOLDKERNEL -O -I/usr/src/linux-$(KINC)/include

# Makefile for a basic kernel module - 2.6.x
obj-m := plcm_drv.o
KDIR  := /lib/modules/$(shell uname -r)/build
PWD   := $(shell pwd)

# MODULE -- This tells the header files to give the appropriate
# definitions for a kernel module.
#
# __KERNEL__ -- This tells the header files that this code will
# be run in kernel mode not as part of a user process.
#
# LINUX -- Technically speaking, this is not necessary. However,
# if you ever want to write a serious kernel module which will
# compile on more than one operating system, you'll be happy you
# did. This will allow you to do conditional compilation on the
# parts which are OS dependant.
#
default:
ifeq ($(wildcard /dev/plcm_drv),)
	mknod /dev/plcm_drv c 241 0
endif
	gcc -O2 plcm_test.c -o plcm_test
	gcc -O2 plcm_cursor_char.c -o plcm_cursor_char
ifeq ($(KVER),2.6)
	$(MAKE) -C $(KDIR) M=$(PWD) modules
endif
ifeq ($(KVER),2.4)
	$(CC) $(MODCFLAGS) -c plcm_drv.c
endif
ifeq ($(wildcard Test),)
	echo "rmmod plcm_drv" > Test
ifeq ($(KVER),2.6)
	echo "insmod plcm_drv.ko" >> Test
endif
ifeq ($(KVER),2.4)
	echo "insmod plcm_drv.o" >> Test
endif
	echo "./plcm_test" >> Test
	echo "./plcm_test -stop" >> Test
	echo "rmmod plcm_drv" >> Test
	chmod 777 Test
endif
clean:
	rm -f plcm_test
	rm -f plcm_cursor_char
ifeq ($(KVER),2.6)
	$(MAKE) -C $(KDIR) M=$(PWD) clean
endif
ifeq ($(KVER),2.4)
	rm -f *.o *.ko
endif

