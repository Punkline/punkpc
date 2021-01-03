/*## Header:
# --- load/store multiple floats
# Simple instruction macros for loading/storing multiple floating points
# - macro creates an instruction for each floating point, but can be written like 'lmw' or 'stmw'

##*/
##/* Updates:
# version 0.0.2
# - fixed symbol name typo in stmfd macro that was causing errors
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:

# --- Class Methods:
# - these emit PowerPC instructions, and follow the instruction naming convention of lmw, stmw:

#                            [optional]
# --- lmfs   fStart, idx(r),  [ fEnd ]  - floating point singles
# --- stmfs  fStart, idx(r),  [ fEnd ]
# --- lmfd   fStart, idx(r),  [ fEnd ]  - floating point doubles
# --- stmfd  fStart, idx(r),  [ fEnd ]
# These can be used to load/store multiple floating points to/from an array of registers/RAM
# if 'fEnd' is left blank, then the argumen becomes 'f31' automatically -- simulating lmw, stmw
# if 'fEnd' is smaller than 'fStart' -- then the register sequence descends instead of ascends



## Binary from examples:

## DBA10010 DBC10018
## DBE10020 CBA10010
## CBC10018 CBE10020
## C07F0024 C09F0028
## C0BF002C D07F0024
## D09F0028 D0BF002C
## C0BF0024 C09F0028
## C07F002C D0BF0024
## D09F0028 D07F002C

##*/
/*## Examples:
.include "punkpc.s"
punkpc lmf
# Use the 'punkpc' statement to load this module, or include the module file directly


# --- BASIC USE ---
# can be used similar to stmw and lmw, but produces an instruction for each float stored/loaded

stmfd f29, 0x10(sp)
lmfd  f29, 0x10(sp)
# >> stfd f29,16(sp)
# >> stfd f30,24(sp)
# >> stfd f31,32(sp)
# - backup saved floats (as doubles)

# >> lfd f29,16(sp)
# >> lfd f30,24(sp)
# >> lfd f31,32(sp)
# - restore saved floats (as doubles)


# --- RANGES ---

lmfs  f3, 0x24(r31), f5
stmfs f3, 0x24(r31), f5
# - you can specify a range by adding an extra register argument, at the end
#>>> lfs f3,36(r31)
#>>> lfs f4,40(r31)
#>>> lfs f5,44(r31)
# - load float range f3...f5 (as singles)

#>>> stfs f3,36(r31)
#>>> stfs f4,40(r31)
#>>> stfs f5,44(r31)
# - store float range f3...f5 (as singles)

lmfs  f5, 0x24(r31), f3
stmfs f5, 0x24(r31), f3
# >>> lfs f5,36(r31)
# >>> lfs f4,40(r31)
# >>> lfs f3,44(r31)
# - reversed load order

# >>> stfs f5,36(r31)
# >>> stfs f4,40(r31)
# >>> stfs f3,44(r31)
# - reversed store order

##*/
.ifndef punkpc.library.included; .include "punkpc.s"; .endif
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
