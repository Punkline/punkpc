# --- Condition/Comparison Register/Fields
#>toc ppc
# - utilities for working with cr fields
#   - also includes fixes for some cr instructions that are poory emulated in some environmnets
# - useful for writing efficient (and legible) binary trees in PowerPC functions

# --- Example use of the cr module:

.include "punkpc.s"
punkpc cr
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- CR INSTRUCTION OVERRIDES ---

crset gt
# >>> crorc  1, 1, 1
# 'gt' is interpreted as the corresponding bit in cr0
# 'crorc' is functionally identical to 'crset', and prevents errors in some powerpc emulations

crclr gt
# >>> crandc 1, 1, 1
# Another functionally identical operation

cr.disable_overrides
crset gt
crclr gt
# >>> crset 1
# >>> crclr 1
# The overrides can be disabled and enabled with macros

cr.enable_overrides
crset cr1.eq
crclr cr7.lt
# >>> crorc  6, 6, 6
# >>> crandc 28, 28, 28
# cr0 ... cr7 have the bits 'lt', 'gt', 'eq', and 'so' available, for full CR coverage




# --- BOOL ENUMERATIONS ---
# This tool lets you work with bools as named indices and mask values, for creating conditions

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
# both of these rlwinms are identical

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

## 4C210B42 4C210902
## 4C210A42 4C210982
## 4CC63342 4F9CE102
## E0000000 540307BD
## 540307BD 5000D884
## 00000003 7C001120
## 409F0014 409D0008
## 60000000 41BE0008
## 60000000
