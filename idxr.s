.ifndef xr.included; xr.included=0; .endif; .ifeq xr.included; xr.included = 1; xr.reg=0
.include "./punkpc/xev.s"
.macro idxr, xr; .irp s,len,beg,dep,end,idx,reg; xr.\s=-1;.endr; .irpc c,\xr; xr.len=xr.len+1
.ifc (,\c; xr.dep=xr.dep+1; .if xr.dep==0; xr.beg=xr.len+1; xr.end=-1; .endif; .endif
.ifc ),\c; xr.dep=xr.dep-1; .if xr.dep==-1; xr.end=xr.len-1; .endif; .endif
.endr; xev 0,xr.beg-2,\xr; xr.idx=xev; xev xr.beg,xr.end,\xr; xr.reg=xev;.endm;.endif
