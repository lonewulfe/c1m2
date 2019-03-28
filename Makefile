#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# <I TOOK SO LONG TO DO THIS>
#
# Use: make [TARGET] [PLATFORM-OVERRIDES]
#
# Build Targets:
#      <Put a description of the supported targets here>
#
# Platform Overrides:
#      <Put a description of the supported Overrides here
#
#------------------------------------------------------------------------------
include sources.mk

TARGET=c1m2
# Platform Overrides
	PLATFORM = HOST

# Dependency Flags
	DEPENDENCY = -MM -MF 

# Architectures Specific Flags
	LINKER_FILE = -T msp432p401r.lds
	CPU = cortex-m4
	ARCH = thumb
	SPECS = nosys.specs
	FPU = fpv4-sp-d16
	MFLOAT = hard
	MARCH = armv7e-m

# Compiler Flags and Defines

ifeq ($(PLATFORM),HOST)
	CC = gcc
	LD = 
	LDFLAGS =-Wl,-Map=$(TARGET).map
	CFLAGS =-Wall -Werror -g -O0 -std=c99
	CPPFLAGS = -DHOST
else
	CC = arm-none-eabi-gcc
	LD = arm-none-eabi-ld
	LDFLAGS =-Wl,-Map=$(TARGET).map $(LINKER_FILE)
	CFLAGS = -Wall -Werror -g -O0 -std=c99 -mcpu=$(CPU) -m$(ARCH) --specs=$(SPECS) -march=$(MARCH) -mfpu=$(FPU) -mfloat-abi=$(MFLOAT) -Wall
	CPPFLAGS = -DMSP432 
endif

# Rules

OBJS = $(SOURCES:.c=.o)	



%.o : %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(SOURCES) -o $@


%.asm: %.i 
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -S 
	objdump -D $(OBJS)

%.i: %.c
	$(CC) $(CFLAGS) -D$(PLATFORM) -MD -E $(SOURCES)


.PHONY: compile-all
compile-all:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(SOURCES) 

.PHONY: build
build: all

.PHONY: all
all: $(TARGET).out

$(TARGET).out: main.o memory.o
	$(CC) main.o memory.o $(CFLAGS) $(LDFLAGS) -o $@

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET).o $(TARGET).out $(TARGET).map *.o *.gch *.d
