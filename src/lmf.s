# --- Load Multiple Floats
#>toc ppc
# - can be used similarly to the `lmw` and `stmw` instructions, but for various float types
#   - `lmfs` and `stmfs` for single-precision
#   - `lmfd` and `stmfd` for double-precision
# - does not change the number of instructions required for multiple registers

# --- Updates:
# version 0.0.2
# - fixed symbol name typo in stmfd macro that was causing errors
# version 0.0.1
# - added to punkpc module library

# --- Class Methods:
# - these emit PowerPC instructions, and follow the instruction naming convention of lmw, stmw:

#                            [optional]
# --- lmfs   fStart, idx(r),  [ fEnd ]  - floating point singles
# --- stmfs  fStart, idx(r),  [ fEnd ]
# --- lmfd   fStart, idx(r),  [ fEnd ]  - floating point doubles
# --- stmfd  fStart, idx(r),  [ fEnd ]
# These can be used to load/store multiple floating points to/from an array of registers/RAM
# if 'fEnd' is left blank, then the argumen becomes 'f31' automatically -- simulating lmw, stmw
# if 'fEnd' is smaller than 'fStart' -- then the register sequence descends instead of ascends.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module lmf, 2
.if module.included == 0; punkpc regs, idxr

  .macro lmfs, start, idxr, end=31
    lmfs.r = \start & 31
    # .r is the counting register we will use

    idxr \idxr
    # idxr.x = index from \idxr input
    # idxr.r = register from \idxr input

    .if \end >= \start;
      .rept ((\end&31)+1)-(\start&31)
        lfs lmfs.r, idxr.x(idxr.r)
        lmfs.r = lmfs.r + 1
        idxr.x = idxr.x + 4
      .endr # registers are normally loaded from lowest to highest, like lmw

    .else
      .rept ((\start&31)+1)-(\end&31)
        lfs lmfs.r, idxr.x(idxr.r)
        lmfs.r = lmfs.r - 1
        idxr.x = idxr.x + 4
      .endr # if end < start -- then the register sequence is inverted
    .endif

  .endm; .macro stmfs, start, idxr, end=31
    stmfs.r = \start & 31
    idxr \idxr
    .if \end >= \start;
      .rept ((\end&31)+1)-(\start&31)
        stfs stmfs.r, idxr.x(idxr.r)
        stmfs.r = stmfs.r + 1
        idxr.x  =  idxr.x + 4
      .endr
    .else
      .rept ((\start&31)+1)-(\end&31)
        stfs stmfs.r, idxr.x(idxr.r)
        stmfs.r = stmfs.r - 1
        idxr.x  =  idxr.x + 4
      .endr
    .endif
  .endm; .macro lmfd, start, idxr, end=31
    lmfd.r = \start & 31
    idxr \idxr
    .if \end >= \start;
      .rept ((\end&31)+1)-(\start&31)
        lfd lmfd.r, idxr.x(idxr.r)
        lmfd.r = lmfd.r + 1
        idxr.x = idxr.x + 8
      .endr
    .else
      .rept ((\start&31)+1)-(\end&31)
        lfd lmfd.r, idxr.x(idxr.r)
        lmfd.r = lmfd.r - 1
        idxr.x = idxr.x + 8
      .endr
    .endif
  .endm; .macro stmfd, start, idxr, end=31
    stmfd.r = \start & 31
    idxr \idxr
    .if \end >= \start;
      .rept ((\end&31)+1)-(\start&31)
        stfd stmfd.r, idxr.x(idxr.r)
        stmfd.r = stmfd.r + 1
        idxr.x  =  idxr.x + 8
      .endr
    .else
      .rept ((\start&31)+1)-(\end&31)
        stfd stmfd.r, idxr.x(idxr.r)
        stmfd.r = stmfd.r - 1
        idxr.x  =  idxr.x + 8
      .endr
    .endif
  .endm;
.endif
