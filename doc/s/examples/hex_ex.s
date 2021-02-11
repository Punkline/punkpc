# --- Hex Emitter Objects (with Array of Byte History)
# >toc sidx
# - extends the 'enc' object class
#   - emit bytes from raw hex literals, as user inputs
#     - accepts a mix of whitespace, commas, and '0x' prefixes
#     - buffers nibbles as partial bytes, for odd char inputs
#     - skips non-hex literals, save for a couple of special syntaxes:
#       - use `.` chars to align the buffer to various powers of 2
#       - use `"` chars to enter raw ascii in place of hex literals
#   - saves input bytes as an array of readable/writable bytes
#   - can emit bytes after saving and modifying them in memory

# --- Example use of the hex module:

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
# - this produces a max of 32-byte alignment


hex 10.
# >> 10
# alignments will not add padding if the counter is already aligned
# - the counter is relative to byte index 0 of the buffer
# - as a stack, this index is represented by the '.s' property


hex ...
# >>> 00, 00, 00
# Alignments don't need to be prefaced by any input bytes, either





# --- RAW ASCII SYNTAX ---
# The inputs will detect whether or not it is in between a pair of "" quotes
# - if it is quoted, an input will be translated as ascii into bytes, instead of just hex literals

hex "hello!"
# >>> 68656C6C6F21  (hello!)
# Quotes are detected, but the contents are not actually protected from interpretation

hex "this is raw ascii"
# >>> 74686973 69737261 77617363 6969   (thisisrawascii)
# ... this means that some features of strings, like preserving ' ' spaces is not supported
# - this may change in a future version

hex "this"20 "is"20 "raw"20 "ascii"00...
# >>> 7468697320 697320 72617720 6173636969000000   (this is raw ascii\000)
# ... otherwise, the parse allows for directly in-line strings with the normal hex syntaxes
# - this may be used in the meantime to get around poor support for protected strings

hex.enc "this is raw ascii\000"
hex.emit hex.i, hex.s-1
# >>> 7468697320 697320 72617720 617363696900   (this is raw ascii\000)
# ... you may also use the '.enc' methods, as 'hex' objects are extensions of the 'enc' object class
# - 'enc' stands for 'encode' or 'encoder'
# - the '.i' property is used to save the place of the last emitted range of bytes
# - the '.s' property is used to save the place of the stack index, for pushing new bytes




# --- ARRAY OF BYTE HISTORY ---
# Every emitted byte has its own indexed symbol in the 'hex' encoder stack object:

.byte hex$0, hex$1, hex$2, hex$3
# >>> 80, cb, 04, 80
# These are the first 4 bytes we input into the hex macro
# - they are stored as part of stack memory, which uses 'sidx' indices to count elements in an array

hex.emit 0, 3
# >>> 80, cb, 04, 80
# This '.emit' method call is virtually identical to the above tuple of '.byte' arguments
# - it reaches into indices 0, 1, 2, and 3 (range 0, 3) and emits them as bytes in the assembly


hex.read 0, a, b, c, d
.byte a, b, c, d
# >>> 80, cb, 04, 80
# The '.read' method can be used to extract bytes from the byte history in the form of a symbol
# - these symbols can then be used in expressions, instead of just being emitted as bytes

hex.read_size = 4
hex.read 0, addr
.long addr
# >>> 80cb0480
# You can read up to 4 bytes at a time by adjusting the '.read_size' property before using '.read'



# The 'hex' object has its '.emit' property set to true
# If we set it to false, then inputing data to the hex object will not automatically emit the bytes

hex.emit = 0
hex 1234
# >>> (nothing is emitted)

hex.popm A, B
.byte B, A
# >>> 12, 34
# As a stack, 'hex' can use stack methods like '.pop' and '.popm'
# - here you can see that even though the bytes weren't emitted, they were still recorded

# The '.s' property marks the current stack index, for pushing new bytes
# The '.ss' property marks the highest recorded stack index, for measuring safe read thresholds
# The '.sss' property marks the highest allowed stack index, for limiting the size of an array

.byte hex.s, hex.ss
# >>> 0x43, 0x46
# By popping 2 elements (from memory, with '.popm'), we've set '.s' back 2 spaces, plus the buffer
# - one extra index is recorded in '.ss' to mark the next place to push, for the stack buffer

align 2
# The 'align' module is included to create an alternative to the '.align' directive
# - it works in the same way, but doesn't destroy label information in absolute expressions





# --- HEX OBJECTS ---
# 'hex' is just the name of a class-instantiated object
# You may create your own hex objects with their own discrete memories using 'hex.new'

hex.new  aob
# This creates a new hex object called 'aob' that we can use just like the 'hex' object




aob 48656c6c6f20576f726c64
# >>> (nothing is emitted)
# By default, it has its '.emit' property set to false so that it's easier to build up data

.byte aob$3, aob$5, aob$10, 0
# >>> 6c, 20, 64, 00
# You may reference individual bytes directly, using the sidx symbols generated for stack memory

aob.read_size = 2
aob.read 0, a, b, c, d
.short a, b, c, d
# >>> 4865, 6c6c, 6f20, 576f
# You may read arrays of 1...4-byte values into tuples

stack.rept_range aob, 0, 7, .byte
# >>> 48, 65, 6c, 6c, 6f, 20, 57, 6f
# You may use stack methods to access or manipulate the bytes
# - swap out the '.byte' directive with a macro here to create a parser

aob.emit = 1
aob "Hello"20 "World"00...
# >>> 48656c6c6f20576f726c6400
# You may change the '.emit' property to make it behave like the 'hex' object, and emit as called

# --- Example Results:

## 80CB0480 00320911
## 00021234 56789ABC
## DEF01234 56789ABC
## DEF01234 ED101000
## 10000000 10000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 10000000 68656C6C
## 6F217468 69736973
## 72617761 73636969
## 74686973 20697320
## 72617720 61736369
## 69000000 74686973
## 20697320 72617720
## 61736369 69000000
## 74686973 20697320
## 72617720 61736369
## 690080CB 048080CB
## 048080CB 048080CB
## 04801234 7D800000
## 6C206400 48656C6C
## 6F20576F 48656C6C
## 6F20576F 48656C6C
## 6F20576F 726C6400
