.include "punkpc.s"
punkpc ppc
# import punkpc macroinstructions...

mOp       = 0xFC000000  #+ FC000000
mA        = 0x03F80000  #+ 03F80000
mB        = 0x00070000  #+ 00070000
mC        = 0x0000FFFF  #+ 0000FFFF
abs_func  = 0x804D7A48
# named symbol masks, and a callable address


# function start:
prolog rComp, rData   # saved params
regs rOp, rA, rB, rC  # unsaved args0

  rlwimi rComp, rOp, mOp
  rlwimi rComp, rA, mA
  rlwimi rComp, rB, mB
  rlwimi rComp, rC, mC
  # abstract away rotation math in integer compression
  # - omit the rotation value from 4-argument syntax
  
  data.start

    0: .long 0
    1: .asciz "Hello "
    2: .asciz "World"
    .align 2
    
    data.struct 0, "inl.", xPointer, xStrA, xStrB
    # generate named offsets for numbered items (starting at '0')
    # - enumerations are defined for the 'inl.*' namespace
    # - each can be referenced as an offset from 'rData'

  data.end rData
  # rData = inline data table base address
  # - this inline table is branched over
  
  mr r3, rComp
  addi r4, rData, inl.xPointer
  addi r5, rData, inl.xStrA
  addi r6, rData, inl.xStrB
  bla abs_func
  # pass generated data offsets to a function
  # - absolute address is called in long form (4 instructions)
  
  mr r3, rComp 
  # return compressed params
  
epilog
blr

