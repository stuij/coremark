#!/bin/bash

# todo: thumb + `HAS_FLOAT 1` (set in port_me.h) gets errors
# (HAS_FLOAT is only used for reporting, no float testing in CoreMark)
MEM=iwram
INSTR=arm
LLVM=1
OPT_FLAGS="-mllvm -enable-dfa-jump-thread -mllvm -inline-threshold=500 -mllvm -unroll-threshold=450"
OPT_LEVEL=3
MGBA=/Applications/mGBA.app/Contents/MacOS/mGBA

make PORT_DIR=gba clean
make PORT_DIR=gba CODE_MEM=${MEM} INSTR_SET=${INSTR} COMP_LLVM=${LLVM} \
     OPT_C="${OPT_FLAGS}" OPT_LEVEL=${OPT_LEVEL}
${MGBA} coremark.gba -l 127
