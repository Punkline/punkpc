/*## Header:
# --- Small Integer Tools/Instructions
#>toc ppc
# - macroinstructions for inserting/extracting small integers into/out of larger ones
# - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
#   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
#   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

##*/
/*## Updates:
# version 0.1.1
# - added ifalt protections
# - reworked method of masking, to better handle zeroed and inverted masks

# --- version 0.1.0
# - renamed to 'small' for 'small integers'
# - included 'bcount' module
#   - bcount methods can be used to measure int sizes
# - included 'enum' module
#   - enumb can be used to build bool masks
# - removed 'extr' and 'insr', and added their features as obfuscating macros 'rlwinm' and 'rliwmi'
#   - these macros check the number of comma-separated arguments
#   - if 4 or 5 are counted, the default instructions are invoked
#   - if 3 are counted, then old 'extr' and 'insr' features are invoked
#     - (all cases result in rlwinm or rlwimi instructions being assembled)

# version 0.0.1
# - added to punkpc module library






##*/
/*## Attributes:

# --- PowerPC Instruction Syntax Extensions

# --- rlwinm    rD, rA, extr_mask
# A new rlwinm syntax that uses 3 args to extract a small int from a larger int
#   extr_mask  : rA will be ANDED by this mask, and the result will be zero-aligned
#              - 0x00FFFF00 would be right-shifted by 8, for example
#              - null masks cause the immediate '0' to be generated with an 'li' instruction

# --- rlwimi    rD, rA, insr_mask
# A new rlwimi syntax that uses 3 args to insert a small int into a larger int
#   insr_mask  : rA will be rotated from zero into place of this mask, ANDED, and inserted into rD

# --- rlwinm.
# --- rlwimi.
# Variation also compare the result of rD to 0 in cr0
# - while enabled, rotation args are still accepted in 4 and 5 arg syntaxes
#   - syntax extension also masks rotation argument, allowing for negatives

# --- small.enable_insr_extr
# --- small.disable_insr_extr
# Use these macros to toggle the syntax on or off




# --- Class Properties

# --- small.rot_bits - record of the bits used in last shorthand rlwnim/rlwimi instruction
# --- small.rot_mask - record of the mask used in last shorthand rlwnim/rlwimi instruction

# --- bcount      - return value; to be copied to other symbols or used directly on macro return
# --- bcount.sign - returned sign of integer as 1 or 0, for signed methods

# --- enumb.count - bit index for bool enumerator
# --- enumb.step  - added index to each step in bool enumerator
# --- enumb.mask  - last generated mask from bool enumerator mask generator
# --- enumb.crf   - crf mask for the 'mtcrf' instruction, corresponding with enumb.mask contents



# --- Class Methods

# --- bcount      int
# Count the number of bits used by an unsigned integer
# - looks for most significant true bit
# - this is an alias of "bcount.le" (little-endian bit count)
# --- bcount.signed   int
# Count the number of bits used by a signed integer
# - always includes sign + up to 31 bits on Little End
# --- bcount.zsigned  int
# Count the number of unused bits in a signed integer
# - does not include sign, but counts up to 31 sign-duplicate bits on Big End

# --- bcount.zbe  int
# Count the number of Zeroed bits on the Big End (bigger digits, left side) of given integer
# --- bcount.zle  int
# Count the number of Zeroed bits on the Little End (smaller digits, right side) of given integer
# --- bcount.be   int
# Count the number of bits in use by a big-endian value (by inverting bcount.zbe)
# --- bcount.le   int
# Count the number of bits in use by a little-endian value (by inverting bcound.zle)

# --- See 'enum.s' for details about 'enumb' bool mask counters

##*/
/*## Examples:
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


##*/
/*## Results:
547F673E 53E3A216
547F673E 53E3A216
547F673E 53E3A216
547F413E 53E3C30E
547F073E 53E3073E
50839998 50A3835E
50C3043E 0D0E0A13
00120000 E0000000
540307BD 540307BD
5403FFFF 5000D884
00000003 7C001120
409F0014 409D0008
60000000 41BE0008
60000000

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module small, 0x101
.if module.included == 0
  punkpc bcount, enum, ifalt

  .macro small.__instr_build, rlw
    .macro \rlw, va:vararg; small.__instr_handle \rlw, \va; .endm

  .endm; .macro small.__instr_handle, va:vararg; small.__altm = alt
    ifalt; small.__alt = alt; .noaltmacro; small.__instr \va;
    ifalt.reset small.__alt; alt = ifalt.__altm

  .endm; .macro small.__instr, rlw, d, a, m, va:vararg
    .purgem \rlw
    # temporarily purge instruction hook

    .ifnb \va; \rlw \d, \a, (\m)&31, \va;
      # run normal instruction if 4 or more args are given

    .else; small.__instr_logic \rlw, \d, \a, \m; .endif

    small.__instr_build \rlw
    # rebuild instruction hook

  .endm; .macro small.__instr_logic, rlw, d, a, m
    small.__beg = 0
    small.__end = 0
    small.__rot = 0
    small.__inv = 0
    small.__ins = 0

    ## 00F00000
    #rlwinm r31, r3, 12, 28, 31
    #rlwimi r3,  r0, 20,  8, 11
    #+ 00000000 00F00000   # 8, 11, >> 20
    #+ 00000008 00000014   # zbe=8,  zle=20
    #+ 0000000C 00000018   # be=12,  le=24
    #+ 00000019 00000007   # signed=25, zsigned=7
    #rlwinm r31, r3,  8, 12, 31
    #rlwimi r3,  r0, 24, 20,  7
    ## 00FFF000
    #wimi.beg = zbe
    #wimi.end = (be-1)&31
    #.if both are 0
    #  wimi.end = zsigned
    #  wimi.rot = signed-1
    #  m = mask << wimi.end+1
    #  winm.beg = zbe
    #  wimi.beg = winm.beg + wimi.end+1
    #  winm.end = 31
    #  winm.rot = (32-wimi.rot)&31
    #.else
    #  wimi.rot = (31-wimi.end)&31
    #  winm.end = 31
    #  winm.beg = (wimi.beg + wimi.rot)&31
    #  winm.rot = (32-wimi.rot)&31
    #
    ## FF0FFFFF
    #rlwinm r31, r3,  8,  4, 31
    #rlwimi r3,  r0, 24, 12,  7
    #+ 00000000 FF0FFFFF   # 12, 7, >> 24
    #+ 00000000 00000000   # zbe=0, zle=0
    #+ 00000020 00000020   # be=32, le=32
    #+ 00000019 00000007   # signed=25, zsigned=7
    #
    #+ # zeroed
    #+ 00000000 0000000F   # 28, 31, >> 0
    #+ 0000001C 00000000   # zbe=28, zle=0
    #+ 00000020 00000004   # be=32, le=4
    #+ 00000005 0000001B   # signed=5, zsigned=23

    .ifc \rlw, rlwimi; small.__ins = 1
    .else; .ifc \rlw, rlwimi.; small.__ins = 1; .endif; .endif
    .if \m

      # if not 0
      bcount.zbe \m, small.__beg
      bcount.be \m
      small.__end = (bcount-1)&31
      small.__inv = (small.__beg == 0) && (small.__end == 31)
      .if small.__inv

      #  # if inverted...
      #  bcount.zsigned \m, small.__end
      #  bcount.signed \m
      #  small.__rot = (bcount - 1)&31
      #  bcount.zbe (\m << (small.__end +1)&31), small.__beg
      #  .if small.__ins

      #    # if inserting inverted...
      #    small.__beg = (small.__beg + small.__end + 1)&31
      #  .else

      #    # if extracting inverted...
      #    small.__rot = (32-small.__rot)&31
      #    small.__end = 31
      #  .endif
       #.else

        bcount.zbe ~(\m), small.__end
        bcount.be ~(\m)
        small.__beg = bcount + 1
        .if small.__ins

          # if inverted insert...
          small.__rot = (32-small.__end)&31
          small.__end = small.__end - 1
        .else

          # if inverted extract...
          small.__rot = small.__end
          small.__beg = small.__beg - small.__end
          small.__end = 31
        .endif
      .else

        # if not inverted...
        small.__rot = (31-small.__end)&31
        .if small.__ins == 0

          # if extracting...
          small.__end = 31
          small.__beg = (small.__beg + small.__rot)&31
          small.__rot = (32-small.__rot)&31
        .endif
      .endif
      \rlw \d, \a, (small.__rot&31), (small.__beg&31), (small.__end&31)
    .elseif small.__ins == 0
      li \d, 0
      # if mask is null, and we're extracting a number, then just load '0' as an immediate

    .endif

  .endm; .macro small.enable_insr_extr
    .if small.enable_insr_extr == 0
      small.enable_insr_extr = 1
      .irp rlw, rlwinm, rlwinm., rlwimi, rlwimi.
        small.__instr_build \rlw
      .endr
    .endif
  .endm; .macro small.disable_insr_extr
    .if small.enable_insr_extr
      small.enable_insr_extr = 0
      .irp rlw, rlwinm, rlwinm., rlwimi, rlwimi.
        .purgem \rlw
      .endr
    .endif
  .endm; small.enable_insr_extr = 0; small.enable_insr_extr
.endif
