.ifndef ifalt.included;  ifalt.included = 0;.endif;
.ifeq ifalt.included;  ifalt.included = 2
  .macro ifalt
    .irp alt_check,  %1;  alt=0
      .ifc \alt_check,  1;  alt=1;.endif;nalt=alt^1;.endr;
  .endm;.macro ifalt.reset,  reset_alt=alt
    .if \reset_alt;  .altmacro
    .else;  .noaltmacro;.endif;ifalt
  .endm;.endif;

