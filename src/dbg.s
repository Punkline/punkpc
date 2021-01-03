/*## Header:
# --- Debug expression
# simply prints an error "[expression] = (evaluation)" -- useful for debugging without a debugger

##*/
##/* Updates:
# version 0.0.2
# - changed '.error' directive into a '.warning' directive
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:
# --- Class method
# --- dbg  expression
# create an error message that evaluates the given expression, if possible

##*/
/*## Examples:
.include "punkpc.s"
punkpc dbg
# Use the 'punkpc' statement to load this module, or include the module file directly

i = 0x1337; dbg i
# >>> Warning: i = 4919
##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module dbg, 2
.if module.included == 0; #punkpc
  .macro dbg,i,x;.ifb \x;.altmacro;dbg %\i,\i;.noaltmacro;.else;.warning "\x = \i";.endif;.endm
.endif
