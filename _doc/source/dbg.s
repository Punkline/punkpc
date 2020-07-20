/*## Header:
# --- Debug expression
# simply prints an error "[expression] = (evaluation)" -- useful for debugging without a debugger

##*/
/*## Attributes:
# --- Class method ---
# --- dbg  expression
# create an error message that evaluates the given expression, if possible

##*/
/*## Examples:
.include "./punkpc/dbg.s"

i = 0x1337; dbg i
# >>> Error: i = 4919
##*/

.ifndef dbg.included; dbg.included=0; .endif; .ifeq dbg.included; dbg.included = 1
  .macro dbg,i,x;.ifb \x;.altmacro;dbg %\i,\i;.noaltmacro;.else;.error "\x = \i";.endif;.endm
.endif
