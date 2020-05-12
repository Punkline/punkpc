.ifndef ifalt.included; ifalt.included = 0; .endif; .ifeq ifalt.included; ifalt.included = 1
.macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;.endif
