.ifndef if.included
  if.included = 0
.endif;
.ifeq if.included
  if.included = 1
  .include "./punkpc/ifalt.s"
  .include "./punkpc/ifdef.s"
  .include "./punkpc/ifnum.s"
.endif

