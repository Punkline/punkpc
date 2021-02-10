# --- Hex Emitter Objects (with Array of Byte History)
# >toc library
# - extends the 'enc' object class
#   - emit bytes from raw hex literals, as user inputs
#     - accepts a mix of whitespace, commas, and '0x' prefixes
#     - buffers nibbles as partial bytes, for odd char inputs
#     - skips non-hex literals, save for a couple of special syntaxes:
#       - use `.` chars to align the buffer to various powers of 2
#       - use `"` chars to enter raw ascii in place of hex literals
#   - saves input bytes as an array of readable/writable bytes
#   - can emit bytes after saving and modifying them in memory



# --- Class Properties ---

# --- hex - a class-instantiated hex object (see object constructor below)


# --- Constructor Method ---
# --- hex.new  name, ...
# Create a new 'hex' object...


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
