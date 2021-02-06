# --- PowerPC Modules
#>toc Modules : powerpc modules
# - a collection of all of the modules that include PowerPC related macroinstructions
# - if no args are given to `punkpc` when calling it, this module is loaded by default

# --- Example use of the ppc module:

.include "punkpc.s"
punkpc ppc
# Use the 'punkpc' statement to load this module, or include the module file directly




# --- branch ---

bla 0x802852b8
ba r0, 0x800c2754
# >>> lis; ori; mtlr; blrl
# >>> lis; ori; mtctr; bctr
# Use 'bla' and 'ba' enable long-form absolute calls and branches
# - an optional register may be given to specify where instructions build the address






# --- cr and enum(b) ---

crset 31
crclr 30
# >>> crorc  31, 31, 31
# >>> crnand 30, 30, 30
# Override problematic cr instructions with equivalent gates in other instructions

enumb       Flag, Check, Bool
enumb.mask  Flag, Check, Bool
mtcrf  enumb.crf, r3
# 3 input bools, inserted directly into cr with no checks

bf+ bCheck, 0f
  bf+ bBool, 1f
    bf+ bFlag, 2f

    2:
  1:
0:  # bools can be referenced with 'bf' (branch if FALSE) or 'bt' (branch if TRUE)






# --- data ---

data.start
# Start an inline data struct...

  0: .asciz "Hello"
  1: .asciz " "
  2: .asciz "world"
  3: .asciz "!"
  .align 2
  # numbered entries will have their positions calculated in the struct offset method

  data.struct 0, "str.", a, b, c, d
  # Create struct offset names using the numbered entries

data.end r31
addi r3, r31, str.a
addi r4, r31, str.b
addi r5, r31, str.c
addi r6, r31, str.d
# named offsets for inline struct dictionary called 'str'







# --- lmf and spr using idx(r)
lmfs f1, 0x10(sp), f3
stmfs f1, 0x10(sp), f3
# >>>   lfs f0;   lfs f1;   lfs f2
# >>>  stfs f0;  stfs f1;  stfs f2
# Extended lmfs stmfs macro instructions lets you load and store a range of floats
# - reversing f1 and f3 in this case will change the order from incrementing to decrementing

lmfs f30, 0x10(sp)
stmfs f30, 0x10(sp)
# >>>   lfs f31;   lfs f30
# >>>  stfs f31;  stfs f30
# omitting extra arg assumes a decrement from f31, for saved registers

stmspr r0, 0x10(sp), cr, ctr, xer
# >>> mfcr;  stw;  mfctr;  stw;  mfspr;  stw
# spr macros on the other hand use only 1 register as a buffer for moving/storing/loading sprs
# - an arbitrary number of keywords can be used to specify a tuple of registers to save/restore

lmspr r0, 0x10(sp), cr, ctr, xer
# using the same keywords in the same order can be used to restore old spr values






# --- small ---
# 'small' implements a special alternative syntax to 'rlwinm' and 'rlwimi' instructions

# The syntax is determined by the number of arguments given to the instruction:
#
# PowerPC 5 arg:   rDest, rSource, rot, start, end    - bit index definition
# PowerPC 4 arg:   rDest, rSource, rot, mask          - mask definition
# PunkPC  3 arg:   rDest, rSource, mask               - zero-rotated mask definition

# The new syntax abstracts away all rotation math needed to insert and/or extract compressed ints
# It does this using masks, which can be stored entirely in named symbols:

mMyMask=0x0001FF80
# this mask value has all the information necessary to extract an int of given size and location
# - the mask is 10 contiguous bits
# - the mask is leftshifted by 7 (from a zero-shifted value)
#   - these are values that can be used to inform rlwimi and rlwinm instructions

# Masks like this may be used to claim only a certain range of bits within the int it resides in

li r0, 1000
# This is an example of a small integer we'd like to insert into our mask section
# r0 = zero-shifted integer value '1000'

# To extract or 'unpack' an integer, use 'rlwinm' :

# 5 arg - BIT INDEX syntax:
rlwinm r31, r3, (32-7)&31, 22, 31      # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, 15, 24               # r3  = packed 10-bit integer (from r0)

# 4 arg - MASK syntax:
rlwinm r31, r3, (32-7)&31, mMyMask>>7  # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, mMyMask              # r3  = packed 10-bit integer (from r0)

# 3 arg - ZEROED MASK syntax:
rlwinm r31, r3, mMyMask                # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, mMyMask                 # r3 = packed 10-bit integer  (from r0)

# All 3 of these pairs are the same, they just use different syntaxes

# Only the 3-arg sytnax is communicative between inserting and extracting





# --- sp and regs ---
# 'sp' can be used to make stack frames, for writing functions in PowerPC

sp.push lr, rString, rValue, xStruct, 0x38
regs rStruct
# push stack frame enough to accommodate lr, r30, r31, and 0x40 bytes of temporary memory
# - all specified registers are automatically backed up

lwz rString, 0x0(rStruct)
lwz rValue,  0x4(rStruct)
stw rStruct, sp.xStruct(sp)
addi rStruct, sp, sp.xStruct
# ...

sp.pop
# - all registers backed up in sp.push are restored

# This is no different than the following:
mflr  r0
stwu  r1,-0x60(sp)
stw   r0, 0x64(sp)
stmw r30, 0x48(sp)

lwz  r31, 0x00(r3)
lwz  r30, 0x04(r3)
stw   r3, 0x10(sp)
addi  r3, sp, 0x10
# ...

lmw r30, 0x48(sp)
lwz  r0, 0x64(sp)
addi sp, sp, 0x60
mtlr r0

# --- Example Results:

## bla 0x802852b8
## 3C00800C 60002754
## 7C0903A6 4E800420
## 4FFFFB42 4FDEF102
## 7C600120 40BE000C
## 40BD0008 40BF0004
## 48000018 4E800021
## 48656C6C 6F002000
## 776F726C 64002100
## 4BFFFFED 7FE802A6
## 387F0000 389F0006
## 38BF0008 38DF000E
## C0210010 C0410014
## C0610018 D0210010
## D0410014 D0610018
## C3C10010 C3E10014
## D3C10010 D3E10014
## 7C000026 90010010
## 7C0902A6 90010014
## 7C0102A6 90010018
## 80010010 7C0FF120
## 80010014 7C0903A6
## 80010018 7C0103A6
## 380003E8 547FCDBE
## 50033BF0 547FCDBE
## 50033BF0 547FCDBE
## 50033BF0 7C0802A6
## 9421FFB0 90010054
## BFC10048 83E30000
## 83C30004 90610010
## 38610010 BBC10048
## 80010054 38210050
## 7C0803A6 7C0802A6
## 9421FFA0 90010064
## BFC10048 83E30000
## 83C30004 90610010
## 38610010 BBC10048
## 80010064 38210060
## 7C0803A6
