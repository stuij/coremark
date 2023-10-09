# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original Author: Shay Gal-on

#File : core_portme.mak

# comment out to compile with GCC
# Define COMPILE_WITH_LLVM on the cmdline to compile with LLVM

ifdef COMPILE_WITH_LLVM
      ifeq ($(strip $(GBA_LLVM)),)
      $(error Please set GBA_LLVM in your environment. export GBA_LLVM=<path to gba-llvm installation>)
      endif

      GBAFIX   = $(GBA_LLVM)/bin/gbafix
      OBJCOPY  = $(GBA_LLVM)/bin/llvm-objcopy

      # Flag : CC
      #	Use this flag to define compiler to use
      CC 		= $(GBA_LLVM)/bin/clang
      # Flag : LD
      #	Use this flag to define compiler to use
      LD		= $(GBA_LLVM)/bin/clang
      # Flag : AS
      #	Use this flag to define compiler to use
      AS		= $(GBA_LLVM)/bin/clang
      #	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
      PORT_CFLAGS = -O3 -mthumb --config armv4t-gba.cfg -Wl,-T,gba_cart.ld # -mllvm -unroll-count=8
      LFLAGS 	= --config armv4t-gba.cfg
      ASFLAGS   = -mthumb
      #Flag : LFLAGS_END
      #	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts).
      #	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
      LFLAGS_END = -ltonc
else
      ifeq ($(strip $(DEVKITARM)),)
      $(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
      endif

      GBAFIX   = gbafix
      OBJCOPY  = arm-none-eabi-objcopy

      # Flag : CC
      #	Use this flag to define compiler to use
      CC 		= arm-none-eabi-gcc
      # Flag : LD
      #	Use this flag to define compiler to use
      LD		= arm-none-eabi-gcc
      # Flag : AS
      #	Use this flag to define compiler to use
      AS		= arm-none-eabi-as
      #	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
      PORT_CFLAGS = -O3 -mthumb -mlong-calls -specs=gba.specs -I$(DEVKITARM)/../libtonc/include # -funroll-all-loops
      LFLAGS 	= -specs=gba.specs
      ASFLAGS   = -mthumb -mlong-calls
      #Flag : LFLAGS_END
      #	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts).
      #	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
      LFLAGS_END = -L$(DEVKITARM)/../libtonc/lib -ltonc

endif

# Flag : OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(LFLAGS) $(XLFLAGS) $(LFLAGS_END)"
# Flag : CFLAGS
CFLAGS = $(PORT_CFLAGS) -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"

# Flag : SEPARATE_COMPILE
# SEPARATE_COMPILE=1

OBJOUT 	= -o
OFLAG 	= -o
COUT 	= -c

# Flag : PORT_SRCS
# 	Port specific source files can be added here
#	You may also need cvt.c if the fcvt functions are not provided as intrinsics by your compiler!
PORT_SRCS = $(PORT_DIR)/core_portme.c $(PORT_DIR)/ee_printf.c
vpath %.c $(PORT_DIR)
vpath %.s $(PORT_DIR)

# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

LOAD = echo "Please set LOAD to the process of loading the executable to the flash"
RUN = echo "Please set LOAD to the process of running the executable (e.g. via jtag, or board reset)"

OEXT = .o
EXE = .bin

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.s
	$(AS) $(ASFLAGS) $< $(OBJOUT) $@

# Target : port_pre% and port_post%
.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload

port_postbuild:
	$(OBJCOPY) -O binary $(OUTNAME) coremark.gba
	$(GBAFIX) coremark.gba

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p
