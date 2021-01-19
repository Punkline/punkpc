/*## Header:
# --- Encoder Module
# Encodes input literals into a stack of byte symbols (indexed int variables)

##*/
##/* Updates:
# version 0.0.2
# - changed constructor name to 'enc.new' instead of 'enc'
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:
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
  # - can be used to detect quotes in quoted inputs

## Binary from examples:

## 54676573 74696E48
## 656C6C6F 576F726C
## 64004865 6C6C6F20
## 576F726C 64224865
## 6C6C6F57 6F726C64
## 22224865 6C6C6F20
## 576F726C 64224865
## 6C6C6F20 576F726C
## 645C225C 20222274
## 65737422 20666F72
## 203B2022 6C697465
## 72616C70 726F7465
## 6374696F 6E220000
## 00010203 04050607
## 08090A0B 0C0D0E0F
## 10111213 14151617
## 18191A1B 1C1D1E1F
## 20212223 24252627
## 28292A2B 2C2D2E2F
## 30313233 34353637
## 38393A3B 3C3D3E3F
## 40414243 44454647
## 48494A4B 4C4D4E4F
## 50515253 54555657
## 58595A5B 5C5D5E5F
## 60616263 64656667
## 68696A6B 6C6D6E6F
## 70717273 74757677
## 78797A7B 7C7D7E7F
## 80818283 84858687
## 0A0D0900 224C0000
## 4C224C22 696E67

##*/
/*## Examples:
.include "punkpc.s"
punkpc enc
# Use the 'punkpc' statement to load this module, or include the module file directly


# --- BASICS ---

enc.new myEnc
# creates encoder 'myEnc'
# - main property/method is not defined in encoder objects

myEnc.enc Testing
# buffer the ascii for 'Testing' into the encoder object we just made

myEnc.deq char
.byte char
# >>> 54
# >>> 'T' -- the first char in 'Testing'
# - 'myEnc' is just a mutated stack, so it can be used like one to navigate the character buffer
# - '.deq' will dequeue the characters in the order they came in

myEnc.pop
char = myEnc
# popped memory comes from self, to create scalar character variables

.byte char
# >> 67
# >> 'g' -- the last char in 'Testing'
# - '.pop' will dequeue the characters in reverse order, if you want to check the other end


# --- PROTECTING INPUTS ---

.macro m, str:vararg  # macro m, for testing encoder m
  myEnc.enc \str          # pass string to encoder
  .rept myEnc.s       # for each char in encoder
    myEnc.deq         # dequeue a char
    .byte myEnc.deq   # emit char as a byte
  .endr
.endm # this simply prints out the bytes so that the result can be displayed
# - this is just to demonstrate the escape syntaxes

m Hello World
# >>> HelloWorld
# unquoted strings can be encoded, but they are unprotected from interpretation when passed
# - unprotected inputs can't maintain spaces, and will fail on certain chars like ';' or '='

m "Hello World"
# >>> Hello world
# quoted strings will have the quotation marks skipped in the encoding
# - this lets you protect your inputs with anything in-between quotes
# - quotes must still be given in pairs even though they are skipped

m "\"Hello World\""
# >>> "HelloWorld"
# You can escape certain characters like quotes while inside of a protected string
# - however, this creates 2 pairs of quotes to your string; causing the middle to become unprotected
# - this makes the output lose its spaces again

m "\""Hello World"\""
# >>> "Hello World"
# By adding yet another pair of quotes, you can re-protect the body of the string
# - the initial pair makes the quote escape possible
# - the second pair is escaped, so that it shows up in the encoded buffer
# - the third pair re-protects the body of the string so that it can contain problematic chars
#   - this is why spaces are working again in this odd quotation format

m """Hello World"""
# >>> Hello World
# - you can do this as many times as necessary to protect your string


# --- ESCAPED INPUTS ---

m "\\"
# >>> \
# backslash escapes backslash literally

m "\""
# >>> "
# it can escape quotes literally, but only if the escaped quote doesn't interrupt pairing logic

m "\\ \""
# >>> \ "

m "\"test\" for ; \"literal protection\""
# >>> "test" for ; "literal protection"
# - possible to control literal quotation logic now by using dummy " marks
#   - anything between a pair of quotes is protected
#     - escaped quotes do not count in the pairing logic
#   - only literally backslashed " marks will be encoded without risk of syntax errors
#     - backslashes internal to a quote pair may create errors

.align 2

m "\000\x01\x02\x03\x04\x05\x06\x07\x08\t\012\013\014\015\d014\d015\d016\d017\d018\d019\d020\d021\d022\d023\d024\031\032\033\034\035\036\037 !\"\043$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
# >>> 00010203 04050607 ... 7C7D7E7F
# all 128 chars in this range can now be encoded in the input string
# - \x00  -- hex encoded ascii     (base 16)
# - \d000 -- decimal encoded ascii (base 10)
# - \000  -- octal encoded ascii   (base 8)

m "\x80\x81\x82\x83" "\d132\d133\206\207"
# >>> 80818283 84858687
# hexadecimal, decimal, and octal characters can be used to escape un-typable characters

m "\n\r\t"
# >>> 0A0D09
# specially recognized lower-case-only escape character aliases


.align 2





# --- RAW INPUTS ---

myEnc.enc_raw 0, 1, "\testing"
.byte myEnc$0
# >>> "
# This is a direct index of a raw sampling of the input text
# - note that in order to do this, the input is given an extra pair of quotes
#   - this will break quote logic in some cases unless you account for it

.byte myEnc$1
# >>> \
# The direct indices are easy to reference without processing, but can be dangerous
# - we only sampled chars 0 and 1, so indices above that will be unavailable, or garbage

myEnc.enc_raw, 1, "\testing"
# When the sample range arguments are blank, they assume the object's default range
# - in this case, we get a [0] index for the start



# We've stacked 4 character bytes from sampling the first 2 chars twice

.align 2
.rept myEnc.s; myEnc.popm; .byte myEnc; .endr
# >>>\"\"
# This pops each sampled char from the stack
# - as you can see, unsafe 'raw' characters are safe to parse as integers



# --- CHARACTER PARSING (FAKE REGEX) ---

myEnc.enc_raw,, "\TESTing"
# Blank defaults will parse the whole string, giving us a sample of each char

.rept myEnc.s
  myEnc.deq char     # de-queue each char (in the order they were sampled)
  .if char >= 'a
    .if char <= 'z
      myEnc.push char  # if character is lowercase, re-push it to end of queue
    .endif
  .endif
.endr
# This loop extracts only the lower-case alphabetical characters from our sample

.rept myEnc.s-myEnc.q
  myEnc.deq char
  .byte char
.endr
# >>> ing
# This second half emits only the characters sampled from the first pass





##*/


.ifndef punkpc.library.included; .include "punkpc.s"; .endif
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
