.ifndef punkpc.library.included
  .include "punkpc.s"
.endif;
punkpc.module ppc, 2
.if module.included == 0
  punkpc branch, cr, data, idxr, load, small, sp
.endif

