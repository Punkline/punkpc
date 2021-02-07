# --- Small Integer Tools/Instructions
#>toc ppc
# - macroinstructions for inserting/extracting small integers into/out of larger ones
# - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
#   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
#   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

# --- Updates:
# version 0.1.1
# - added ifalt protections
# - reworked method of masking to better handle zeroed and inverted masks
# - removed mask memory symbols

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

    .ifc \rlw, rlwimi; small.__ins = 1
    .else; .ifc \rlw, rlwimi.; small.__ins = 1; .endif; .endif
    .if \m

      # if not 0
      bcount.zbe \m, small.__beg
      bcount.be \m
      small.__end = (bcount-1)&31
      small.__inv = (small.__beg == 0) && (small.__end == 31)
      .if small.__inv

        bcount.zbe ~(\m), small.__end
        bcount.be ~(\m), small.__beg
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
