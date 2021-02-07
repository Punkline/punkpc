# --- Small Integer Tools/Instructions
#>toc ppc
# - macroinstructions for inserting/extracting small integers into/out of larger ones
# - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
#   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
#   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

# --- Example use of the small module:

.include "punkpc.s"
punkpc small
# Use the 'punkpc' statement to load this module, or include the module file directly

# --- NORMAL RLWINM AND RLWIMI SYNTAXES ---
# 'rlwinm' and 'rlwimi' are 'rotate left word' insert/extract instructions
# - rlwinm : 'rotate left word immediate and mask'
# - rlwimi : 'rotate left word immediate masked insertion'

# They are both instructions that have 5 arguments:
# -        rDest : the reg where the product of the operation is stored
# -        rArg  : the reg containing bits we want to insert or extract
# -     rotation : a left-orient rotation to be applied before/after masking
# --- mask begin : the bit index where the AND mask begins
# ---   mask end : the bit index where the AND mask ends

# The last 2 arguments describe a mask range using bit indices

rlwinm r31, r3, 12, 28, 31
# +0x00F00000 : this EXTRACTS a 4-bit value
# -- for rlwinm, the mask indices reflect the mask AFTER rotation

rlwimi r3, r31, 20, 8, 11
# +0x00F00000 : this INSERTS a 4-bit value
# -- unintuitively -- rlwimi does the opposite...




# Both instructions also have a shorter 4 argument syntax:
# -    rDest : the reg where the product of the operation is stored
# -    rArg  : the reg containing bits we want to insert or extract
# - rotation : a left-orient rotation to be applied before/after masking
# ---   mask : a 32 bit mask that has no breaks (unless inverted)

mask = 0x00F00000
# This mask helps us abstract away an ugly-looking expression behind a name

rlwinm r31, r3, 12, mask>>20
rlwimi r3, r31, 20, mask
# -- this syntax is a bit easier to work with, if you have named mask symbols
# The rotation argument is still not communicative between the two instructions, though





# --- THE NEW 3 ARGUMENT SYNTAX ---
# This module adds a new 3-arg syntax that completely abstracts away the rotation math
# -  rDest : the reg where the product of the operation is stored
# -  rArg  : the reg containing bits we want to insert or extract
# --- mask : a 32 bit mask that has no breaks (unless inverted)

rlwinm r31, r3, mask
rlwimi r3, r31, mask
# -- these are identical to the above 2 pairs of instructions
# All of the rotation math is implied when the rotation value is simply omitted

mask = 0xFF0FFFFF
rlwinm r31, r3, mask
rlwimi r3, r31, mask
# Inverted masks will be rotated so that all bits are aligned to zero, when extracted

mask = 0xF
rlwinm r31, r3, mask
rlwimi r3, r31, mask
# Zeroed masks will have no rotation at all


mOp     = 0xFC000000  # in r3
mArg    = 0x03F80000  # in r4
mBools  = 0x00070000  # in r5
mOffset = 0x0000FFFF  # in r6
# These are examples of small integer masks that can be used in the new syntax
# - this example builds an opcode out of argument ints

rlwimi r3, r4, mArg
rlwimi r3, r5, mBools
rlwimi r3, r6, mOffset
# opcode has been constructed in r3 from args r3...r6
# - this is a form of compression, for integers





# --- BIT COUNTERS ---

bcount 0x1337
.byte bcount
# >>> 13 bits (13th bit from little end is most significant true bit)

bcount.signed -0x1337
.byte bcount
# >>> 14 bits (includes sign)

bcount.be 0xFFC00000
.byte bcount
# >>> 10 bits (from big end)

bcount.zbe 0x1337
.byte bcount
# >>> 19 unused zero bits (from big end)

bcount.zle 0x1337
.byte bcount
# >>> 0 unused zero bits (from little end)

bcount.zsigned -0x1337
.byte bcount
# >> 18 sign-duplicate bits (not in use by signed number, excludes sign)

.align 2




# --- BOOL ENUMERATIONS ---

enumb Enable, UseIndex, IsStr
# state the bool symbol names you want to use:
# >>> bEnable   = 31; mEnable   = 0x00000001
# >>> bUseIndex = 30; mUseIndex = 0x00000002
# >>> bIsStr    = 29; mIsStr    = 0x00000004
#   mMask and bBit symbols are created for each

enumb (0), +1, A, B, C
# >>> bA = 0; mA = 0x80000000
# >>> bB = 1; mB = 0x40000000
# >>> bC = 2; mC = 0x20000000
#   (0) sets the index to 0, and +1 sets the step to increment by 1

.long mA|mB|mC
# >>> 0xE0000000

rlwinm. r3, r0, 0, bUseIndex, bUseIndex
rlwinm. r3, r0, 0, mUseIndex
rlwinm. r3, r0, mUseIndex
# all of these rlwinms are identical

rlwimi r0, r0, bIsStr-bC, mC
# insert bIsStr into bC in a single register/instruction




# --- BOOL MASK GENERATOR ---

enumb.restart
# you can reset the counter back to its default position this way, to make a new mask

enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
Enable = 1; UseIndex = 1;           # set some boolean values as T/F
# unassigned bool IsStr is assumed to be 0

enumb.mask Enable, UseIndex, IsStr  # generate a mask with said bools using 'enumb.mask'
# this uses the mMask value and the state values to create a combined state mask

m=enumb.mask;  .long m              # mask will compile from given 'enumb' index values
# you can save the combined mask by copying the return enumb.mask property
# >>> 0x00000003

crf=enumb.crf;  mtcrf crf, r0
# you can move partial fields directly into the volatile CR registers with mtcrf, and enumb.crf

bf- bEnable, 0f
  bf- bIsStr, 1f
    nop  # example string handler goes here

  1:
  bt+ bUseIndex, 0f
    nop  # example index handler goes here

0:
# once in the CR, each bool can be referenced by name in 'bf' or 'bt' branch instructions

# --- Example Results:

## 547F673E 53E3A216
## 547F673E 53E3A216
## 547F673E 53E3A216
## 547F413E 53E3C30E
## 547F073E 53E3073E
## 50839998 50A3835E
## 50C3043E 0D0E0A13
## 00120000 E0000000
## 540307BD 540307BD
## 5403FFFF 5000D884
## 00000003 7C001120
## 409F0014 409D0008
## 60000000 41BE0008
## 60000000
