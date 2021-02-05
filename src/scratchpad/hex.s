/*## Header:
# --- Hex Emitter Tool
# Hex parser interprets all raw hexadecimal inputs and emits them in an array of bytes
# - for copying bytes into the assembly from a more flexible ascii form than '.byte' inputs

##*/
/*## Updates
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---

# --- Constructor Method ---

  # --- Object Properties ---

  # --- Object Methods ---

# --- Class Methods ---

##*/
/*## Examples:
.include "punkpc.s"
punkpc hex
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- EMITTING BYTES WITH HEX ---
# The class level 'hex' object can be used to emit bytes using a specialized encoder stack:

hex 80cb0480, 003 209, 1 0x1 000, , 0x2
# >>> 80, cb, 04, 80, 00, 32, 09, 11, 00, 02

hex 0x123456789abcdef0123456789ABCDEF0
# >>> 12, 34, 56, 78, 9a, bc, de, f0, 12, 34, 56, 78, 9a, bc, de, f0



# The bytes are read one nibble at a time, buffering one byte at a time:
hex 0x1
hex 23
hex 0x4
# >>> 12, 34
# hexadecimal is implied, so prefixes are trimmed



hex Hello World!
# >>> ed
# Nearly all non-hex chars will be ignored
# There are 2 exceptions to this rule, however...



# --- ALIGNMENT SYNTAX ---
# The '.' char may be used to align to a ceiling byte, short, word, double, quad, or oct
# This alignment is relative to the hex buffer, not the program counter

hex 1.
# >>> 10
# a single '.' aligns to a byte

hex 1..
# >>> 10, 00
# a double '..' aligns to an hword (2byte)

hex 1...
# >>> 10, 00, 00, 00
# a triple '...' aligns to a word (4byte)

hex 1.........
# >>> hex 1......
# If more than 6 sequential '.' chars are detected, it will be capped at 6
# - this produces 32-byte alignment


hex 10.
# >> 10
# alignments will not b




# --- ARRAY OF BYTE HISTORY ---
# Every emitted byte has its own indexed symbol in the 'hex' encoder stack object:

stack.rept_range hex, 0, 3, .byte
# >>> 80, cb, 04, 80
# These are the first 4 bytes we emitted in the examples
# The bytes are stored using the 'sidx' indexing syntax, as a part of a stack buffer




# You may use 'hex' exclusively for this feature by turning off the byte emitter:

hex.emit = 0
hex 1234
# >>> (nothing is emitted)
# This is useful if you want to create structures and emit them or reference them later

hex.popm byte1, byte0
.byte byte0, byte1
# >>> 12, 34
# The 'hex' sub-object is an encoder stack, and can be operated on like any other stack
# - this is useful for creating parses of your byte history

.align 2




# --- HEX OBJECTS ---
# 'hex' is just the name of a class-instantiated object
# You may create your own hex objects with their own discrete memories

hex.new  aob
# This creates a new hex object called 'aob' (array of bytes)

aob 48656c6c6f20576f726c64
# >>> (nothing is emitted)
# By default, it has its '.emit' property set to false so that we can build data

.byte aob$3, aob$5, aob$10, 0
# >>> 6c, 20, 64, 00
# You may reference individual bytes directly, using the sidx symbols generated for stack memory
##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module hex, 1
.if module.included == 0
  punkpc enc

  .macro hex.new, self, va:vararg
    .ifnb \self
      enc.new \self
      stack.purge_hook \self, hex
      .macro \self, va:vararg; stack.call_mut \self, hex, default, \va; .endm
      # extend the 'enc' object, which extends the 'stack' object

    .endif
  .endm


.endif
