# --- Alignment Tool (relative)
#>toc library
# - an alternative to the `.align` directive that doesn't destroy absolute expressions
#   - relative addresses (labels) can't be measured after normal aligns using this directive
# - useful for measuring arbitrary body sizes that include un-aligned data
#   - byte arrays and strings are examples of structs that commonly need re-alignment

# --- Updates:
# version 0.0.1
# - added to punkpc module library

# --- Class Properties ---
# --- _align.__start - a copy of the '_punkpc' library object label
# --- align.default - setting this will change the default bit alignment size

# --- Class Methods ---
# --- align  exp
# Align the program counter in the current section using a power of 2, 'exp'
# 'exp' - accepts values up to '15'
# - 0 is 1-bytealignment
# - 1 is 2-byte short alignment
# - 2 is 4-byte word alignment (default)
# - 3 is 8-byte alignment
# - 4 is 16-byte alignment
# - etc...

# --- align.to  exp, label
# This version of align accepts a base offset in the form of a label
# 'label' can be used to override the default '_align.__start' base label.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module align, 1
.if module.included == 0

  punkpc ifalt

  _align.__start = _punkpc
  align.default = 2
  .macro align, exp=align.default; align.to \exp
  .endm; .macro align.to, exp, lab=_align.__start;
    align.__altm = alt; ifalt
    align.__alt = alt; .noaltmacro
    align.__noalt (\exp & 0xF), \lab
    ifalt.reset align.__alt; alt = align.__altm
  .endm; .macro align.__noalt, exp, lab
    align.__exp = 1 << \exp - 1
    align.__exp = (align.__exp - (. - \lab - 1) & align.__exp)
    .if align.__exp; .zero align.__exp; .endif
  .endm
.endif
