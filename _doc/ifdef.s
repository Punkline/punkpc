# --- ifdef - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
# Updates properties 'def' and 'ndef' for use as evaluatable properties in .if statements
#   ifdef \myObjectName\().exists
# This creates a numerically evaluable property out of a problematic symbol name:
#   .if def;  # then given symbol exists
#   .if ndef; # then given symbol does not exist
# - if calling in .altmacro mode, use the 'ifdef.alt' variant

.ifndef ifdef.included; ifdef.included = 0; .endif; .ifeq ifdef.included; ifdef.included = 1
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
.endif
/**/
