# --- Small Integer extraction and insertion macros
# - these translate a relatively human-readable syntax into rlwinm and rlwimi instructions
# - 'extr' may be used in cases that rlwinm would be needed to extract a small int from a large int
# - 'insr' may be used in cases that rlwimi would be needed to insert a small int into a large int


# --- Example use of the smallints module:

.include "./punkpc/smallints.s"

mMyMask=0x0001FF80
# this mask value has all the information necessary to extract an int of given size and location
# - the mask is 10 contiguous bits
# - the mask is leftshifted by 7 (from a zero-shifted value)
#   - these are values that can be used to inform rlwimi and rlwinm instructions

li r0, 1000
# r0 = zero-shifted integer value '1000'
# - this will become a new packed value in r3

# rlwinm and rlwimi can summarize a 'rotate' and '32-bit mask' operation
# - these are then combined with AND or (ANDC + OR) operations to insert or extract rotated bits

# normally, the instructions would like like this when 'packing' or 'unpacking' small integers:
rlwinm r31, r3, (32-7)&31, mMyMask>>7     # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, mMyMask          # r3  = packed 10-bit integer (from r0)
# MASK syntaxes require a rotation value and a mask
# - the extraction requires a mask of the RESULT - making it different than insertion
# - the insertion requires a mask of the RESULT - making it different than extraction
# - right-rotation requires you to subtract the amount from 32, and shift the mask

rlwinm r31, r3, (32-7)&31, 22, 31  # r31 = unpacked 10-bit int   (from r3)
rlwimi r3, r0, 7, 15, 24           # r3  = packed 10-bit integer (from r0)
# BIT INDEX syntaxes are the same, but you have to describe bit indices instead of a mask

# The differences between extracting and inserting bits is syntactically confusing
# ...but the 'instr' and 'extr' macros can re-use the exact same mask to create an i/o interface:
extr r31, r3, mMyMask  # r31 = unpacked 10-bit int   (from r3)
insr r3, r0, mMyMask   # r3 = packed 10-bit integer  (from r0)

# This assumes the rotation math needed to zero-shift extractions, or insert zero-shifted numbers
# - masks can be represented as named symbols, thus abstracting away all of the rotation math on use
# - this becomes a much more user-friendly tool for packing and unpacking integers

# these 3 pairs of instructions assemble identically:
# >>> 380003E8 547FCDBE
# ... 50033BF0 547FCDBE
# ... 50033BF0 547FCDBE
# ... 50033BF0


# --- Module attributes:
# --- Class Methods -------------------------------------------------------------------------------

# --- extr  regout, regin, mask
# Extract a zero-shifted small integer from another integer using just a mask input
# - writes a rlwinm instruction from given input
# - can be used to abstract away all of the rotation math in 'rlwinm' behind a mask input
# regout : the output GPR for this operation
# regin  : the input GPR for this operation
# mask   : 32-bit mask of (unshifted) small int container in 'regin' contents
# - null masks cause the immediate '0' to be generated

# --- insr regout, regin, mask
# Insert a zero-shifted small integer into another integer using just a mask input
# - writes a rlwimi instruction from given input
# - can be used with exactly the same mask used by 'extr'
# - when combined with 'extr' -- this creates an i/o utility for packing/unpacking small ints

# --- insr. regout, regin, mask
# - variants compare result to 0 in cr0 using rlwinm. or rlwimi. (with a '.' )

