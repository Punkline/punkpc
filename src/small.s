# --- Small Integer Tools/Instructions
#>toc ppc
# - macroinstructions for inserting/extracting small integers into/out of larger ones
# - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
#   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
#   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

# --- Updates:
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

# --- See 'enum.s' for details about 'enumb' bool mask counters.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module small, 0x100
.if module.included == 0
  punkpc bcount, enum

  .macro small.__build, rlw
    .macro \rlw, va:vararg; small.__instr \rlw, \va; .endm
  .endm

  .macro small.__instr, rlw, d, a, m, va:vararg
    .purgem \rlw
    # temporarily purge instruction hook

    .ifnb \va; \rlw \d, \a, (\m)&31, \va;
      # run normal instruction if 4 or more args are given

    .else

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
    small.__build \rlw
    # rebuild instruction hook

  .endm; .macro small.enable_insr_extr
    .if small.enable_insr_extr == 0
      small.enable_insr_extr = 1
      .irp rlw, rlwinm, rlwinm., rlwimi, rlwimi.
        small.__build \rlw
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
