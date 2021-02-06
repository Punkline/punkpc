# --- Encoder Stacks
#>toc sidx
# - convert source literals into a stack of ascii ints
#   - extended stack object constructor lets you create multiple encoder buffers
# - may be used to create pseudo-regex-like parses of input literals

# --- Updates:
# version 0.0.2
# - changed constructor name to 'enc.new' instead of 'enc'
# version 0.0.1
# - added to punkpc module library

# --- ENCODER OBJECTS
# Extends stack objects to provide extra methods for pushing bytes generated from input literals

# --- Constructor Method
# --- enc.new  name, start, end
# Construct a new encoder object with name 'name'
#  Start and End args will create a default character index range, for parsing inputs
# - if 'start' is blank, 0 is assumed   (parse begins at start of string)
# - if 'end' is blank, -1 is assumed    (parse to end of string)



  # --- Object Properties
  # extends 'stack' properties

  # --- .enc_start  - memory of the given 'start' argument
  # --- .enc_end    - memory of the given 'end argument
  # - changing these properties will change the parse range on encoding with '.enc'
  # - these properties can be overridden on a per-call basis with '.enc_range'



  # --- Object Methods
  # extends 'stack' methods

  # --- .enc      input
  # Push bytes for each character in 'input'
  #  (only the 'start' and 'end' range of chars is parsed)
  # - quotes are ignored by encoder, but will protect the input literals for using special chars
  #   - special chars include anything that confuses the GAS parser, and '\' escapes
  #   - quotes that start with a '\' will be escaped and encoded
  #   - ascii escapes '\n', '\r', and '\t' are supported
  #   - hex escapes of any char '\x00' are supported

  # --- .enc_range  start, end, input
  # Variation of '.enc' method that overrides '.enc_start' and '.enc_end' properties with args

  # --- .enc_raw    start, end, input
  # Variation of '.enc_range' that does not escape quotes or backslashes for special chars
  # - can be used to detect quotes in quoted inputs.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module enc, 1
.if module.included == 0; punkpc stack, if

  enc.__char = 0
  enc.__skip = 0
  enc.__exit = 0
  enc.__escaping = 0
  enc.__encode_raw = 0
  stack enc.__escaped
  .macro enc.new, self, st=0, en=-1
    stack \self
    .if obj.ndef

      # if object was undefined, then instantiate encoder attributes to extend new stack instance
      \self\().enc_start = \st
      \self\().enc_end = \en
      .macro \self\().enc, str:vararg;
        enc.__encode_raw = 0
        enc.__encode \self, \self\().enc_start, \self\().enc_end, \str
        # .enc invokes 'enc.__encode' with a pre-defined range (start ... end)

      .endm; .macro \self\().enc_range, start=\self\().enc_start, end=\self\().enc_end, str:vararg
        enc.__encode_raw = 0
        enc.__encode \self, \start, \end, \str
        # .enc_range lets you specify a custom range

      .endm; .macro \self\().enc_raw, start=\self\().enc_start, end=\self\().enc_end, str:vararg
        enc.__encode_raw = 1
        enc.__encode \self, \start, \end, "\str"
        # enc_raw lets you specify a custom range, and does not ignore/escape quotes and backslashes

      .endm
    .endif
  .endm; .macro enc.__encode, self, start, end, str:vararg
    ifalt; enc.__encode.alt = alt; .noaltmacro
    enc.__escaping = 0
    enc.__escapes = 0
    enc.__quotes = 0
    enc.__skip = 0
    enc.__index = 0
    enc.__exit = 0
    .irpc c, \str
      .if enc.__index >= \start
        enc.__encode.char "'\c+1", "\c "
        .if enc.__escaping == 0
          .if enc.__skip == 0; \self\().push enc.__char; .endif
          .if enc.__exit; .exitm; .endif
          .if enc.__skip > 0; enc.__skip = enc.__skip - 1; .endif
        .endif
      .endif
      enc.__index = enc.__index + 1
      .if enc.__index == \end; enc.__exit = 1; .endif
    .endr
    ifalt.reset enc.__encode.alt

  .endm; .macro enc.__encode.char, i, va:vararg
    enc.__char = \i-1
    .if enc.__escaping < 0; enc.__escaping = 0; .endif # negative is a terminator state for escaping
    .if enc.__escaping;  enc.__escape    # if in escaping mode, handle with the escape macro
    .elseif enc.__char == 451;
      enc.__escaping = -!enc.__encode_raw; enc.__char = 0x22; enc.__quotes=enc.__quotes + 1
    .elseif enc.__char == 430;
      enc.__escaping = !enc.__encode_raw;  enc.__char = 0x4C; enc.__escapes=enc.__escapes + 1
    .endif # skip/count un-escaped quotes, or begin escape sequence with backslash
    # - if raw encoding, then escape flag is never set

  .endm; .macro enc.__escape
    # enc.__char is the query
    # enc.__escaping is a bool/int -- non-0 = escaping, and int = escape mode type
    # 1 = single char escape entry   \\ \" \t \n \r
    # 2, 3, 4 = octal ascii escape         \101
    # 5, 6, 7 = decimal ascii escape       \d065
    # 8, 9, 10 = hexadecimal ascii escape  \x41
    .if enc.__escaping == 1; enc.__escape.beg     # handle char escape beginning
    .elseif enc.__escaping <= 4; enc.__escape.oct # handle nth octal char
    .elseif enc.__escaping <= 7; enc.__escape.dec # handle nth decimal char
    .elseif enc.__escaping <= 9; enc.__escape.hex # handle nth hex char
    .else; enc.__escaping = 0; .endif  # handle else case

  .endm; .macro enc.__escape.beg
    .if enc.__char == 451;      enc.__escaping = 0; enc.__char = 0x22  # case of " escape
    .elseif enc.__char == 430;  enc.__escaping = 0; enc.__char = 0x5C    # case of \ escape
    .elseif (enc.__char >= 0x30) && (enc.__char <= 0x37); enc.__escaping = 2 # case of oct escape
      enc.__escape  # recurse, because octals have no symbolic prefix
    .elseif enc.__char == 0x64; enc.__escaping = 5          # case of dec escape
    .elseif enc.__char == 0x78; enc.__escaping = 8          # case of hex escape
    .elseif enc.__char == 0x74; enc.__escaping = 0; enc.__char = 0x9 # case of tab escape
    .elseif enc.__char == 0x72; enc.__escaping = 0; enc.__char = 0xD # case of carriage return
    .elseif enc.__char == 0x6E; enc.__escaping = 0; enc.__char = 0xA # case of newline escape
    .else; enc.__escaping = 0; .endif  # handle else case

  .endm; .macro enc.__escape.oct
    enc.__escaping = enc.__escaping + 1
    .if (enc.__char >= 0x30) && (enc.__char <= 0x37);  enc.__escaped.push enc.__char & 7
      .if enc.__escaping >= 5; enc.__escaping = 0; .endif
    .else; enc.__escaping = 0; .endif;
    .if enc.__escaping == 0; enc.__char = 0
      .rept enc.__escaped.s
        enc.__escaped.deq enc.__escaped
        enc.__char = enc.__char << 3 | enc.__escaped
      .endr # ascii has been built from octal sequence
    .endif

  .endm; .macro enc.__escape.dec
    enc.__escaping = enc.__escaping + 1
    .if (enc.__char >= 0x30) && (enc.__char <= 0x39);  enc.__escaped.push enc.__char & 15
      .if enc.__escaping >= 8; enc.__escaping = 0; .endif
    .else; enc.__escaping = 0; .endif
    .if enc.__escaping == 0; enc.__char = 0
      .rept enc.__escaped.s
        enc.__escaped.deq enc.__escaped
        enc.__char = enc.__char * 10 + enc.__escaped
      .endr # ascii has been built from decimal sequence
    .endif

  .endm; .macro enc.__escape.hex
    enc.__escaping = enc.__escaping + 1
    .if (enc.__char >= 0x30) && (enc.__char <= 0x39);  enc.__escaped.push (enc.__char & 15)
    .else; enc.__char = enc.__char - 0x37
      .if (enc.__char >= 10) && (enc.__char <= 15);  enc.__escaped.push enc.__char
      .else; enc.__char = enc.__char - 0x20;
        .if (enc.__char >= 10) && (enc.__char <= 15);  enc.__escaped.push enc.__char
        .else; enc.__escaping = 0
    .endif; .endif; .endif
    # accepts capital or lower-case a-f in addition to decimals
    .if enc.__escaping >= 10; enc.__escaping = 0; .endif
    .if enc.__escaping == 0; enc.__char = 0
      .rept enc.__escaped.s
        enc.__escaped.deq enc.__escaped
        enc.__char = enc.__char << 4 | enc.__escaped
      .endr # ascii has been built from hex sequence
    .endif
  .endm
.endif
