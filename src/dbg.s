# --- Debug Tool
#>toc library
# - a simple evaluation tool, for debugging symbol values
#



# --- Class method
# --- dbg  expression
# create an error message that evaluates the given expression, if possible.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module dbg, 2
.if module.included == 0; #punkpc
  .macro dbg,i,x;.ifb \x;.altmacro;dbg %\i,\i;.noaltmacro;.else;.warning "\x = \i";.endif;.endm
.endif
