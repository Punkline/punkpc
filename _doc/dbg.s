# --- dbg: DeBuG expression - dbg [expression]
#  prints an error "[expression] = (evaluation)" -- useful for debugging

/*## Example:
i = 0x1337; dbg i
# >>>  (error message: i = 4919)
##*/

.ifndef dbg.included; dbg.included=0; .endif; .ifeq dbg.included; dbg.included = 1
  .macro dbg,i,x;.ifb \x;.altmacro;dbg %\i,\i;.noaltmacro;.else;.error "\x = \i";.endif;.endm
.endif
