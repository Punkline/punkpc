# --- Expression Emitter Tool
#>toc library
# - a tiny precursor to `sidx` that names things without any special delimiters
# - used in the `regs` module to create register names

# --- Updates:
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- xem  pfx, expr, sfx
# Emit an evaluated expression as decimal literals, with optional literal prefix/suffix
#   pfx  : literals to concatenate to the front of the evaluated expression
#   expr : an expression that can be evaluated into a 32-bit signed integer, as decimal literals
#   sfx  : literals to concatenate to the end of the evaluated expression
# - pfx and sfx must be enclosed in "< double-quoted brackets >" to be protected from interpretation
#   - leading and trailing spaces for pfx and sfx will be trimmed when passed to altmacro mode
# - expr must be an absolute expression; no undefined values

# --- xema  pfx, %(expr), sfx
# An altmacro mode alternative that requires the expression argument be given a '%' prefix.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module xem, 2; .if module.included == 0
  .macro xem,p,x,s;.altmacro;xema \p,%\x,\s;.noaltmacro;.endm;.macro xema,p,x,s;\p\x\s;.endm;xem=0
.endif
/**/
