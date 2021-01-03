.ifndef punkpc.library.included
  .include "punkpc.s";.endif;punkpc.module ppc, 1
.if module.included == 0;  punkpc branch, cr, data, enum, idxr, load, lmf, small, spr, regs;.endif

