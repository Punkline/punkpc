/*## Header:
# --- Hex Emitter and Array of Byte Tools
# >toc library
# - emit bytes from raw hex literals, as user inputs
#   - accepts a mix of whitespace, commas, and '0x' prefixes
#   - buffers nibbles as partial bytes, for odd char inputs
#   - skips non-hex literals, save for a couple of special syntaxes:
  #   - use `.` chars to align the buffer to various powers of 2
  #   - use `"` chars to enter raw ascii in place of hex literals
# - saves input bytes as an array of readable/writable bytes
# - can emit bytes after saving and modifying them in memory
##*/
/*## Updates
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---

# --- hex - a class-instantiated hex object (see object constructor below)



# --- Constructor Method ---

# --- hex.new  name, ...
# Create a new 'hex' object




  # --- Object Properties ---
  # - extends the 'enc' object class

  # --- .read_size - a number between 1 and 4, for the amount of bytes to read per '.read' iter
  # --- .emit  - a bool that causes the object to emit bytes as inputs are given to it
  # --- .i - an index value used to mark the last emitted portion of hex, up to '.s' (stack index)



  # --- Object Methods ---
  # - extends the 'enc' object class

  # --- (self)  ...
  # Convert hexadecimal inputs from '...' into an array of bytes
  # - will emit bytes if the '.emit' property is not 0
  # - will store bytes in stack memory, pushing from index in property '.s' (stack index)

  # --- .emit   start, end, macro
  # Emit bytes using the given index range, and macro
  # - 'start' is '.q' by default (queue index, floor of stack)
  # - 'end' is '.s-1' by default (stack index, ceiling of stack memory)
  # - 'macro' is '.byte' by default (to emit bytes in the assembly)

  # --- .read  index, sym, ...
  # Sample an 'N-byte' value from byte history, where 'N' is '.read_size' property
  # - up to 4 bytes can be interpreted as a single symbol
  # - a tuple of symbols can be given to sample a sequence of values

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
aob "Hello"20 "World"...
# >>> 48656c6c6f20576f726c6400
# You may change the '.emit' property to make it behave like the 'hex' object, and emit as called
##*/
/*## Results:
80CB0480 00320911
00021234 56789ABC
DEF01234 56789ABC
DEF01234 ED101000
10000000 10000000
00000000 00000000
00000000 00000000
00000000 00000000
10000000 68656C6C
6F217468 69736973
72617761 73636969
74686973 20697320
72617720 61736369
69000000 80CB0480
80CB0480 80CB0480
80CB0480 12346B6E
6C206400 48656C6C
6F20576F 48656C6C
6F20576F 48656C6C
6F20576F 726C6400

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module hex, 1
.if module.included == 0
  punkpc enc, align

  # macros:
  .macro hex.new, self, va:vararg
    .ifnb \self
      enc.new \self
      .if obj.ndef
        stack.purge_hook \self, hex, emit, read
        stack.meth \self, emit, read
        .macro \self, varg:vararg; stack.call_mut \self, hex, default, \varg; .endm
        # extend the 'enc' object, which extends the 'stack' object

        \self\().mode push, hex
        # special mode is used to filter inputs when pushing bytes through the encoder

        \self\().i = 0
        \self\().emit = 0
        \self\().read_size = 1
        # extended properties

        \self\().__nib = 0
        \self\().__byte = 0
        \self\().__align = 0
        \self\().__pushing_hex = 0
        # hidden properties (for parse state machine)

      .endif
    .endif
  .endm; .macro stack.mut.hex.default, self, va:vararg
    \self\().__pushing_hex = 1; \self\().i = \self\().s
    hex.__altm = alt; ifalt; hex.__alt = alt; .noaltmacro
    .ifnb \va; \self\().enc_raw 0, -1, \va; .endif
    # encoder will invoke mutated stack push behavior

    hex.__flush_escaped \self
    ifalt.reset hex.__alt; alt = hex.__altm
    \self\().__pushing_hex = 0
    # wrapper flag induces special behavior instead of default

    .if \self\().emit; \self\().emit \self\().i; .endif


  .endm; .macro stack.mut.read.default, self, idx, va:vararg
    hex.__idx = \idx
    .if \self\().read_size > 4; \self\().read_size = 4
    .elseif \self\().read_size < 1; \self\().read_size = 1; .endif
    hex.__size = \self\().read_size
    .irp sym, \va
      .ifnb \sym
        hex.__read = 0
        sidx.rept \self, hex.__idx, hex.__size+hex.__idx-1, hex.__read_byte
        \sym = hex.__read
        hex.__idx = hex.__idx + hex.__size
      .endif
    .endr
  .endm; .macro hex.__read_byte, arg; hex.__read = (hex.__read << 8) | \arg
  .endm; .macro stack.mut.emit.default, self, beg, end, macro=.byte, va:vararg
    .ifb \beg; hex.__emit_beg = \self\().q; .else; hex.__emit_beg = \beg; .endif
    .ifb \end; hex.__emit_end = \self\().s-1; .else; hex.__emit_end = \end; .endif
    stack.rept_range \self, hex.__emit_beg, hex.__emit_end, \macro

  .endm; .macro stack.mut.push.hex, self, char, va:vararg
    .if \self\().__pushing_hex == 0;
      stack.mut.push.default \self, \char, \va; .exitm;
    .endif
    # default is used when pushing normally

    .if \self\().__pushing_hex == 1
      .if \char == 0x30; \self\().__pushing_hex = 2
      .else; hex.__check_escape \self, \char; .endif
    .else; hex.__escaping \self, \char; .endif
    # this preliminary check handles dispatching to

  .endm; .macro hex.__flush_escaped, self
    .if \self\().__pushing_hex == 2; hex.__check_escape \self, 0x30
    .elseif \self\().__pushing_hex == 3
      .if hex.__align > 1
        hex.__align = (1<<(hex.__align-1))
        hex.__align = (hex.__align - \self\().s) & (hex.__align-1)
        .rept hex.__align
          stack.mut.push.default \self, 0
        .endr;
      .endif
    .endif; \self\().__pushing_hex = 1; hex.__align = 0
    # this resets back to normal hex pushing mode, after one of the escaping modes is done

  .endm; .macro hex.__check_escape, self, char
    .if (enc.__quotes & 1); \self\().__pushing_hex = 4
    .elseif \char == 0x2E; hex.__escape_dot \self
    .elseif ((\char >= 0x30) && (\char <= 0x39)); hex.__nibble \self, \char - 0x30
    .elseif ((\char >= 0x41) && (\char <= 0x46)); hex.__nibble \self, \char - 0x37
    .elseif ((\char >= 0x61) && (\char <= 0x66)); hex.__nibble \self, \char - 0x57
    .endif # this handles a filter for only pushing hex digits to the nibble buffer method

  .endm; .macro hex.__nibble, self, val
    \self\().__byte = (\self\().__byte << 4) | (\val)
    .if \self\().__nib; stack.mut.push.default \self, (\self\().__byte & 0xFF); .endif
    \self\().__nib = \self\().__nib ^ 1
    # this creates a push buffer that combines 2 nibbles at a time to generate bytes

  .endm; .macro hex.__escaping, self, char
    .if \self\().__pushing_hex == 2
      .if ((\char == 0x78) || (\char == 0x58));
        \self\().__pushing_hex = 1
        # skip over '0x' or '0X' combinations

      .else;
        hex.__flush_escaped \self

        .if \char == 0x30; \self\().__pushing_hex = 2
        .else; hex.__check_escape \self, \char; .endif
      .endif
    .elseif \self\().__pushing_hex == 3
      .if \char == 0x2E; hex.__escape_dot \self
      # accumulate alignment dots

      .else; hex.__flush_escaped \self
      .endif
    .elseif \self\().__pushing_hex == 4
      .if (enc.__quotes & 1)
        stack.mut.push.default \self, \char
      .else; \self\().__pushing_hex = 1; .endif
    .endif

  .endm; .macro hex.__escape_dot, self
    .if \self\().__align < 6; \self\().__align = \self\().__align + 1; .endif;
    \self\().__pushing_hex = 3
    .if \self\().__align == 1; .if \self\().__nib; hex.__nibble \self, 0; .endif; .endif
  .endm; .macro hex.__escape_quote, self
  .endm; hex.new hex; hex.emit = 1
.endif
