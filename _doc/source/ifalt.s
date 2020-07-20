# --- ifalt - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
# updates properties 'alt' and 'nalt' for use as evaluatable properties in .if statements
# ifalt
# # create an evaluable property out of the current altmacro state
# .if alt;  # then environment is in .altmacro mode
# .if nalt; # then environment is in .noaltmacro mode

.ifndef ifalt.included; ifalt.included = 0; .endif; .ifeq ifalt.included; ifalt.included = 1
  .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;
.endif
