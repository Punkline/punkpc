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
# - this produces a max of 32-byte alignment


hex 10.
# >> 10
# alignments will not add padding if the counter is already aligned
# - the counter is relative to byte index 0 of the buffer
# - as a stack, this index is represented by the '.s' property



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
      .if obj.ndef
        stack.purge_hook \self, hex, emit_bytes
        stack.meth \self, emit_bytes
        .macro \self, varg:vararg; stack.call_mut \self, hex, default, \varg; .endm
        # extend the 'enc' object, which extends the 'stack' object

        \self\().mode push, hex
        # special mode is used to filter inputs when pushing bytes through the encoder

        \self\().pushing_hex = 0
        \self\().emit = 1
        \self\().i = 0
        # extended properties

        \self\().__nib = 0
        \self\().__byte = 0
        \self\().__align = 0
        # hidden properties (for parse state machine)

      .endif
    .endif
  .endm; .macro stack.mut.hex.default, self, va:vararg
    \self\().pushing_hex = 1; \self\().i = \self\().s
    hex.__altm = alt; ifalt; hex.__alt = alt; .noaltmacro
    .irp arg, \va;
      .ifnb \arg;
        \self\().enc \arg;
      .endif;
    .endr
    # encoder will invoke mutated stack push behavior

    hex.__flush_escaped \self
    ifalt.reset hex.__alt; alt = hex.__altm
    \self\().pushing_hex = 0
    # wrapper flag induces special behavior instead of default

    .if \self\().emit; \self\().emit_bytes \self\().i; .endif


  .endm; .macro stack.mut.emit_bytes.default, self, beg, end, va:vararg
    .ifb \beg; hex.__emit_beg = \self\().q; .else; hex.__emit_beg = \beg; .endif
    .ifb \end; hex.__emit_end = \self\().s-1; .else; hex.__emit_end = \end; .endif
    stack.rept_range \self, hex.__emit_beg, hex.__emit_end, .byte

  .endm; .macro stack.mut.push.hex, self, char, va:vararg
    .if \self\().pushing_hex == 0;
      stack.mut.push.default \self, \char, \va; .exitm;
    .endif
    # default is used when pushing normally

    .if \self\().pushing_hex == 1
      .if \char == 0x30; \self\().pushing_hex = 2
      .else; hex.__check_escape \self, \char; .endif
    .else; hex.__escaping \self, \char; .endif
    # this preliminary check handles dispatching to

  .endm; .macro hex.__flush_escaped, self
    .if \self\().pushing_hex == 2; hex.__check_escape \self, 0x30
    .elseif \self\().pushing_hex == 3
      .if hex.__align > 1
        hex.__align = (1<<(hex.__align-1))
        hex.__align = (hex.__align - \self\().s) & (hex.__align-1)
        .rept hex.__align
          stack.mut.push.default \self, 0
        .endr; hex.__align = 0
      .elseif \self\().__nib; hex.__nibble \self, 0; .endif
    .endif; \self\().pushing_hex = 1
    # this resets back to normal hex pushing mode, after one of the escaping modes is done

  .endm; .macro hex.__check_escape, self, char
    .if \char == 0x2E; hex.__escape_dot \self
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
    .if \self\().pushing_hex == 2
      .if ((\char == 0x78) || (\char == 0x58));
        \self\().pushing_hex = 1
        # skip over '0x' or '0X' combinations

      .else;
        hex.__flush_escaped \self

        .if \char == 0x30; \self\().pushing_hex = 2
        .else; hex.__check_escape \self, \char; .endif
      .endif
    .elseif \self\().pushing_hex == 3
      .if \char == 0x2E; hex.__escape_dot \self
      # accumulate alignment dots

      .else; hex.__flush_escaped \self
      .endif
    .endif

  .endm; .macro hex.__escape_dot, self
    .if \self\().__align < 6; \self\().__align = \self\().__align + 1; .endif
    \self\().pushing_hex = 3
  .endm; hex.new hex
.endif
