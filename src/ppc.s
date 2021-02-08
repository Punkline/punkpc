# --- PowerPC Modules
#>toc Modules : powerpc modules
# - a collection of all of the modules that include PowerPC related macroinstructions
# - if no args are given to `punkpc` when calling it, this module is loaded by default

# --- Updates:
# version 0.0.2
# - updated list to include sp module, as intended
# version 0.0.1
# - added to punkpc module library

# --- included modules

# --- branch
# Enables the 'bla' and 'ba' instructions as a method of doing 'blrl' and 'bctr' abs branches

# --- cr
# Enables replacements for 'crset' and 'crclr' that prevent errors in powerpc emulators

# --- data
# Enables inline data tables with the 'blrl' exploit of the powerpc 'link register'

# --- enum
# Enables bool generators that work well with 'cr' and instructions that execute bitwise operations

# --- idxr
# A tool for extracting index and register args from powerpc load/store syntaxes, in macros

# --- load
# Enables the 'load' instruction for loading immediates larger than 16 bits, and strings

# --- lmf
# Enables various 'lmf' instructions for loading multiple floats in a sequence of registers

# --- small
# Enables extended 'rlwinm' and 'rlwimi' syntaxes for inserting and extracting small integers

# --- sp
# Enables flexible stack frame building tools for powerpc function design

# --- spr
# Enables a dictionary of spr names that powers methods available in the 'sp' module

# --- regs
# Enables generic gpr, fpr, and cr names as symbols with an expression emitter

# --- bcount, hidden, if, mut, obj, sidx, stack, items
# - these are also include, as part of the prereqs for the other modules

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module ppc, 2
.if module.included == 0

  punkpc branch, cr, data, idxr, load, small, sp

.endif
