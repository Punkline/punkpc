# --- load/store multiple floats
# Simple instruction macros for loading/storing multiple floating points
# - macro creates an instruction for each floating point, but can be written like 'lmw' or 'stmw'


# --- Example use of the lmf module:

.include "./punkpc/lmf.s"


# --- BASIC USE -----------------------------------------------------------------------------------
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


# --- RANGES --------------------------------------------------------------------------------------

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


# --- Module attributes:
# --- Class Methods:
# - these emit PowerPC instructions, and follow the instruction naming convention of lmw, stmw:

#                            [optional]

# --- lmfs   fStart, idx(r),  [ fEnd ]  - floating point singles
# --- stmfs  fStart, idx(r),  [ fEnd ]
# --- stmfd  fStart, idx(r),  [ fEnd ]
# These can be used to load/store multiple floating points to/from an array of registers/RAM
# if 'fEnd' is left blank, then the argumen becomes 'f31' automatically -- simulating lmw, stmw
# if 'fEnd' is smaller than 'fStart' -- then the register sequence descends instead of ascends

