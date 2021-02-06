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


# --- INSERT AND EXTRACT SYNTAXES ---
# rlwinm and rlwimi can summarize a 'rotate' and '32-bit mask' operation
# - these are then combined with AND or (ANDC + OR) operations to insert or extract rotated bits


# a new 3-arg rlwinm syntax is made available with this module for extracting:

rlwinm r4, r3, 0xF8000000  # r4 = extracted 5-bit value
rlwinm r5, r3, 0x07C00000  # r5 = extracted 5-bit value
rlwinm r6, r3, 0x003FF000  # r6 = extracted 10-bit value
rlwinm r7, r3, 0x00000800  # r7 = extracted 1-bit value
rlwinm r8, r3, 0x00000700  # r8 = extracted 3-bit value
rlwinm r9, r3, 0x000000FF  # r9 = extracted 8-bit value
# masks with no rotation argument will imply an automatic zero-shifted extraction of small integers


# rlwimi now also supports an identical insertion syntax:

li r0, 0
rlwimi r0, r4, 0xF8000000  # inserted 5-bit value
rlwimi r0, r5, 0x07C00000  # inserted 5-bit value
rlwimi r0, r6, 0x003FF000  # inserted 10-bit value
rlwimi r0, r7, 0x00000800  # inserted 1-bit value
rlwimi r0, r8, 0x00000700  # inserted 3-bit value
rlwimi r0, r9, 0x000000FF  # inserted 8-bit value
# -- these inserted masks are identical to the extractions
# If saved to symbols, mask values like this can be used interchangably between inserts/extracts


mMyMask=0x0001FF80
# this mask value has all the information necessary to extract an int of given size and location
# - the mask is 10 contiguous bits
# - the mask is leftshifted by 7 (from a zero-shifted value)
#   - these are values that can be used to inform rlwimi and rlwinm instructions


li r0, 1000
# r0 = zero-shifted integer value '1000'
# - this will become a new packed value in r3

# normally, the instructions would look like this when 'packing' or 'unpacking' small integers:

rlwinm r31, r3, (32-7)&31, mMyMask>>7     # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, mMyMask          # r3  = packed 10-bit integer (from r0)
# MASK syntaxes require a rotation value and a mask
# - the extraction requires a mask of the RESULT - making it different than insertion
# - the insertion requires a mask of the RESULT - making it different than extraction
# - right-rotation requires you to subtract the amount from 32, and shift the mask



rlwinm r31, r3, (32-7)&31, 22, 31  # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, 15, 24           # r3  = packed 10-bit integer (from r0)
# BIT INDEX syntaxes are the same, but you have to describe bit indices instead of a mask

# The differences between extracting and inserting bits is syntactically confusing
# ...but the 'instr' and 'extr' syntaxes can re-use the exact same mask to create an i/o interface:



rlwinm r31, r3, mMyMask  # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, mMyMask   # r3 = packed 10-bit integer  (from r0)
# The new ZEROED syntax assumes the rotation math needed to zero-shift input masks
# - masks can be represented as named symbols, abstracting away all of the rotation math on use
# - this becomes a much more user-friendly tool for packing and unpacking integers


# The above 3 pairs of instructions assemble identically:
# >>> 547FCDBE 50033BF0
# >>> 547FCDBE 50033BF0
# >>> 547FCDBE 50033BF0




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
54642EFE 546556FE
5466A5BE 5467AFFE
5468C77E 5469B850
38000000 5080D808
50A0B152 50C062A6
50E05D28 5100456E
51204E3E 380003E8
547FCDBE 50033BF0
547FCDBE 50033BF0
547FCDBE 50033BF0
0D0E0A13 00120000
E0000000 540307BD
540307BD 5403FFFF
5000D884 00000003
7C001120 409F0014
409D0008 60000000
41BE0008 60000000

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module small, 0x101
.if module.included == 0
  punkpc bcount, enum, ifalt

  .macro small.__instr_build, rlw
    .macro \rlw, va:vararg; small.__instr_handle \rlw, \va; .endm

  .endm; .macro small.__instr_handle, \va; small.__altm = alt
    ifalt; small.__alt = alt; .noaltmacro; small.__instr \va;
    ifalt.reset small.__alt; alt = ifalt.__altm

  .endm; .macro small.__instr, rlw, d, a, m, va:vararg
    .purgem \rlw
    # temporarily purge instruction hook

    .ifnb \va; \rlw \d, \a, (\m)&31, \va;
      # run normal instruction if 4 or more args are given

    .else; small.__instr_logic \rlw, \m


  .endm; .macro small.__instr_logic, rlw, m
    small.__beg = 0
    small.__end = 0
    small.__rot = 0
    small.__inv = 0
    small.__ins = 0
    .ifc \rlw, rlwimi; small.__ins = 1
    .else; .ifc \rlw, rlwimi.; small.__ins = 1; .endif; .endif
    .if \m
      bcount.zbe \m
      small.__beg = bcount
      bcount.zle \m
      small.__end = bcount
      small.__rot = bcount
      small.__inv = (small.__beg == 0) && (small.__end == 0)  # inversion flag
      .if small.__inv
        bcount.signed \m
        small.__end = bcount
        bcount.zbe (\m << bcount)
        small.__beg = bcount
      .endif



      bcount.zbe \m
      small.__beg = bcount
      bcount.be \m
      small.__end = bcount
      .if (small.__beg == 0) && (small.__end == 31)
        bcount


      small.rot_bits = 0
      .ifc \rlw, rlwimi; small.rot_bits = 1;
      .else; .ifc \rlw, rlwimi.; small.rot_bits = 1; .endif; .endif
      # check if inserting or extracting

      .if \m
        .if (\m)&1
          bcount.zsigned \m
          .if bcount.sign
            bcount = 1 + bcount
          .endif
        .else;
          bcount.be \m
        .endif
        # bcount = number of bits to rotate mask left by

        .if small.rot_bits
          small.rot_mask = \m
          small.rot_bits = 32 - bcount
          # use mask and inverted bits if inserting

        .else
          small.rot_bits = bcount
          small.rot_mask = \m << bcount
          small.rot_mask = small.rot_mask | (\m >> ((32-bcount)&31))
          # use bits and rotated mask if extracting

        .endif
        small.rot_bits = small.rot_bits & 31
        \rlw \d, \a, small.rot_bits, small.rot_mask
        # invoke normal instruction with interpreted custom syntax

      .else
        .if small.rot_bits == 0
          li \d, 0
        .endif # if mask is null, and we're extracting a number, then just load '0' as an immediate
      .endif
    .endif
    small.__instr_build \rlw
    # rebuild instruction hook

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