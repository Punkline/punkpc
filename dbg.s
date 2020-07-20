.ifndef dbg.included;  dbg.included=0;.endif;
.ifeq dbg.included;  dbg.included = 1
  .macro dbg,  i,  x
    .ifb \x;  .altmacro;dbg %\i, \i;.noaltmacro
    .else;  .error "\x = \i";.endif;
  .endm;.endif;

