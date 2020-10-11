/*## Header:
# --- encoder module
# Encodes strings of ascii chars into a stack of integers
# - inputs are converted into ascii bytes, but can be translated using filters and parse callbacks


##*/
/*## Attributes:
# --- ENCODER OBJECTS ---


# --- Class Properties ---
# --- enc$ - encoder object counter

# --- Constructor Method ---
# --- enc  name, filter, start, end
# Construct a new encoder object with the name 'name.enc'
# - name   : a '.enc' sub-object will be given to this name, for use of the encoder methods/ppts
# - filter : if blank, 'ascii' is used. You can use a default one, or make your own filter object
# - start  : if blank, 0 is used. This is the idx that the encoder will start parsing at
# - end    : if blank, -1 is used. if -1, the parser will not terminate untill string is finished

  # --- Object Properties ---
  # --- .isEnc - the non-0 ID of this encoder object instance
  # --- .enc   - stack object, with stack index properties like '.q' queue, '.s' stack
  # --- .enc.start  - this remembers the given 'start' argument in constructor method
  # --- .enc.end    - this remebmers the given 'end' argument in constructor method
  #      - you may change .enc.start/end to change the default range used in the .enc method

  # --- Object Methods ---
    # These are extensions of the stack object associated with this encoder object:

    # --- .enc        input
    # Encode the input using ascii -> (optional filter)
    # - the output becomes a stack of integers, + any parsing procedures associated with the filter
    # - reach the output with '.enc' stack methods
    #   - to ref chars directly, use '.enc$n' where n is the index of a parsed character
    # - use 'enc.reset' to assign a new filter object to this encoder

    # --- .enc.range  start, end, input
    # Encode a substring from input, using given index range start ... end (inclusive)
    # - if start is blank, then '.start' property is used
    # - if end is blank, then '.end' property is used

    # --- .enc.reset  start, end, filter
    # Mutated stack method - Resets the stack/queue indices to start argument
    # If a new filter keyword is detected, it will also re-build itself with the new filter object
    # - if start is blank, then '.start' property is used
    # - if end is blank, then '.end' property is used

# --- Class Methods ---


# --- ENCODER FILTER OBJECTS ---

# --- Class Properties ---
# --- enc.filter$ - filter object counter


# --- Constructor Method ---
# --- enc.filter.new  name, mapper_args, ...
# Construct a new encoder filter with the keyword 'name'
# You may construct encoder objects that use filters made with this tool
# Default filters are provided using this tool
# - name        : keyword that can be specified when making a new encoder object, to set the filter
# - mapper_args : these are pairs of strings that provide a list of filtered ranges, and a callback
#               - You may specify as many mapper_args as needed to complete the filter
# Calling this constructor multiple times will re-write the mappings of an existing filter each time

# --- 'enc.filter$\name' - the constructed name is hidden behind a '$' in the class namespace


  # --- Object Properties ---
  # --- .map$ - the number of mapped callback macros in this object


  # --- Object Methods ---
  # --- .map$n  - where n is a literal decimal number
  # - filter objects have several 'mapped' callback macros that run in a sequence
  #   - these macros are designed by the user through calls to 'enc.filter' or 'enc.filter.mapper'


# --- Class Methods ---
# --- enc.filter.mapper  name, idx, filter, macro, ...
# This is called in a loop from enc.filter when making new filter objects
# - idx    : the index to operate on -- where idx is the 'nth parsed character'
#          - if this is blank, then it will be applied to all characters in the parsed range
# - filter : a "quoted string" containing comma-separated ascii number ranges to select or unselect
#          - listed values are consumed in pairs, forming a selection range with each pair
#            - if either value in pair is negative, then the range 'unselects' instead
#          - if you use ';' delimiters, you can also add statements to execute after filter
# - macro  : a statement that can be concatenated by a set of varargs given to a filter map call
#          - this will be executed after the filter has 'selected' or 'unselected' an ascii char
#          - if provided as a quoted string, you may pass multiple statements with ';' delimiters
# - ...    : repeat idx,filter,macro as many times as necessary to map multiple callbacks at once

# --- enc.filter.map     name, ...
# This is called by the encoder object when an ascii char has been buffered into object properties
# - the ... is any number of arguments that you would like to pass on to the mapped macro(s)
# - the macros will be responsible for handling any information


##*/
/*## Examples:
.include "./punkpc/enc.s"


# --- BASICS ---

enc myEnc
# creates encoder 'myEnc'
# - main property/method is not defined in encoder objects
# - instead, encoders use the '.enc' sub-object namespace

myEnc.enc Testing
# buffer the ascii for 'Testing' into the encoder object we just made

myEnc.deq char
.byte char
# >>> 54
# >>> 'T' -- the first char in 'Testing'
# - .enc is just a mutated stack, so it can be used like one to navigate the character buffer
# - .enc.deq will dequeue the characters in the order they came in

myEnc.pop
char = myEnc
# popped memory comes from self, to create scalar character variables

.byte char
# >> 67
# >> 'g' -- the last char in 'Testing'
# - .enc.pop will dequeue the characters in reverse order, if you want to check the other end


# --- PROTECTING INPUTS ---

.macro m, str:vararg  # macro m, for testing encoder m
  myEnc \str          # pass string to encoder
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

m "\000\x01\x02\x03\x04\x05\x06\x07\x08	\012\013\014\015\d014\d015\d016\d017\d018\d019\d020\d021\d022\d023\d024\031\032\033\034\035\036\037 !\"\043$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
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

m "\d'A"
# using \d with the ' escape is not supported, but interestingly it half-works
# - this will produce a null and then translate the escaped decimal ascii for 'A
# >>> 0041
# - this would be just like using...
m "\000A"
# >>> 0041


##*/


.ifndef enc.included; enc.included = 0; .endif; .ifeq enc.included; enc.included = 1
.include "./punkpc/stacks.s"
.include "./punkpc/if.s"

# --- encoder filter objects

enc.i = 0
enc.a = 0
enc.b = 0
enc.mem = 0
enc.filter$ = 0
enc.filter.match = 1
enc.filter.lastmatch = enc.filter.match
enc.filter.inverting = 0
enc.filter.key = 0
enc.filter.exit = 0
enc.filter.skip = 0

.macro enc.filter.new, self, va:vararg
  ifalt; enc.filter.alt = alt; .noaltmacro
  # run in noaltmacro mode
  # - we back up the altmacro state flag in case this is called in altmacro mode

  ifdef enc.filter$\self\().isEncFilter
  .if ndef; enc.filter$\self\().isEncFilter = 0; .endif
  .if enc.filter$\self\().isEncFilter == 0
    enc.filter$ = enc.filter$ + 1; enc.filter$\self\().isEncFilter = enc.filter$
    enc.filter$\self\().map$ = 0 # for counting the number of mapped filter callback operations
    # newly created filters will be initialized

  .else;
    .rept enc.filter$\self\().map$
      sidx.noalt "<.purgem enc.filter$\self\().map>", senc.filter$\self\().map$
      enc.filter$\self\().map$ = enc.filter$\self\().map$ - 1
    .endr # re-mapping a filter requires purging each previously mapped callbacks
  .endif

  enc.filter.mapper \self, \va
  # the mapper will recursively handle varargs in tuples of 3

  ifalt.reset enc.filter.alt

.endm; .macro enc.filter.mapper, self,  idx, filt, op,  va:vararg
  .ifnb \op
    enc.filter$\self\().map$ = enc.filter$\self\().map$ + 1
    sidx.noalt "<enc.filter.mapper.iter enc.filter$\self\().map>", enc.filter$\self\().map$,, /*
    */ \idx, "\filt", "\op"
  .endif

.endm; .macro enc.filter.mapper.iter, m, idx=-1, filt, op
  .if \idx < 0;
    .macro \m, self, va:vararg  # - note that '\self' here is for enc object, not filter object
      .ifnb \va; enc.filter \self, \self\().enc, \filt; \op, \self, \va
      .else;     enc.filter \self, \self\().enc, \filt; \op, \self; .endif
    .endm # no-idx version
  .else;
    .macro \m, self, va:vararg
      .if \self\().enc.q-1 == \idx;
        .ifnb \va; enc.filter \self, \self\().enc, \filt; \op \self, \va; .endif
        .else;     enc.filter \self, \self\().enc, \filt; \op \self; .endif
      .endif
    .endm # idx version
  .endif
  # these mappings hardcode the given arguments into a filter operation, preparing the op callback
  # - if an idx is provided, then it will be enforced -- otherwise no index is checked
  # - when enforcing an idx, the mapped callbacks only run for specific character places
  #   - this can be used to check for serial character combinations

.endm; .macro enc.filter, enc, va:vararg
  enc.filter.inverting = 0
  enc.filter.lastmatch = enc.filter.match
  enc.filter.match = 1
  enc.a = 0  # start char
  enc.b = 0  # end char
  enc.i = 0  # binary counter
  enc.mem = 0 # buffer for linear single-arg irp loop
  # filter arguments in va will determine if the given encoded int is within selection range

  # --- for each value in varargs
  .irp val, \va; enc.i = enc.i ^ 1

    .if enc.i # --- even args - 0, 2, 4, ...
      .ifnb \val; enc.mem = \val; .endif
      # save first arg in memory buffer for odd step

    .else; # --- odd args - 1, 3, 5, ...
      enc.a = enc.mem
      .ifb \val; enc.b = enc.mem
      .else; enc.b = \val; .endif
      # .a and .b are ready to be checked for negatives
      # - blank .a args are interpreted as old .mem values
      # - blank .b args are interpreted as copies of the curren .a value
      # - .mem remembers .a before the check, so that blanks can revert back to it


      enc.filter.inverting = 0; .irpc v, ab
        .if enc.filter.\v < 0; enc.filter.inverting = 1 # negatives cause 'unselect'
          enc.filter.\v = -enc.filter.\v; .endif
      .endr # .inverting is now ready to select or unselect according to this range pair

      .if \enc >= enc.a; .if \enc <= enc.b
          enc.filter.match = !enc.filter.inverting; .endif; .endif

    .endif
    # enc.filter updates the 'enc.filter.match' to check if given char int is within given ranges

.endm; .macro enc.filter.map, self, filter, va:vararg
  enc.filter.key = 0
  enc.filter.exit = 0
  enc.filter.skip = 0

  # --- for each mapped callback
  .rept enc.filter$\filter\().map$
    enc.filter.key = enc.filter.key + 1
    # increment map key to select next callback

    .if enc.filter.skip == 0;
      .ifnb \va; sidx.noalt "<enc.filters$\filter\().map>", enc.filter.key, "<\self, \va>"
      .else;     sidx.noalt "<enc.filters$\filter\().map>", enc.filter.key, "<\self>"; .endif
    .endif # pass args and self to this mapped callback

    .if enc.filter.exit; .exitm; .endif
    .if enc.filter.skip > 0; enc.filter.skip = enc.filter.skip - 1; .endif
  .endr
.endm

enc.filter.new ascii

# --- encoder objects
enc$ = 0
enc.char = 0
enc.skip = 0
enc.exit = 0
enc.escaping = 0
stack enc.escaped

.macro enc, self, filter=ascii, st=0, en=-1
  ifdef \self\().isEnc
  .if ndef; \self\().isEnc = 0; .endif; .if \self\().isEnc == 0
    enc$ = enc$ + 1; \self\().isEnc = enc$
    stack \self\().enc
    .purgem \self\().enc.reset
    # .enc is a mutated stack object

    \self\().enc.start = \st
    \self\().enc.end = \en
    .macro \self\(), str:vararg;
      enc.encode \self, \filter, \self\().enc.start, \self\().enc.end, \str
      # .enc invokes 'enc.encode' with a pre-defined range (start ... end)

    .endm; .macro \self\().encrange, start=\self\().enc.start, end=\self\().enc.end, str:vararg;
      enc.encode \self, \filter, \start, \end, \str
      # .enc.range lets you specify a custom range

    .endm; .macro \self\().reset, start=\st, end=\en, filt
      \self\().enc.q[\start] # reset queue index
      \self\().enc.s[\start] # reset stack index
      # reset indices to beginning of specified range (default if blank)

      .ifnb \filt; enc \self, \filt, \start, \end; .endif
      # re-create object with a new filter if given the name of a filter object

    .endm
  .endif
.endm; .macro enc.encode, self, filter, start, end, str:vararg
  ifalt; enc.encode.alt = alt; .noaltmacro
  enc.escaping = 0
  enc.escapes = 0
  enc.quotes = 0
  enc.skip = 0
  enc.exit = 0
  \self\().enc.reset
  .irpc c, \str
    enc.encode.char "'\c+1", "\c "
    .if enc.escaping == 0
      enc.filter.map \self, \filter
      .if enc.skip == 0; \self\().enc.push enc.char; .endif
      .if enc.exit; .exitm; .endif
      .if enc.skip > 0; enc.skip = enc.skip - 1; .endif
    .endif
  .endr
  ifalt.reset enc.encode.alt

.endm; .macro enc.encode.char, i, va:vararg
  enc.char = \i-1
  .if enc.escaping < 0; enc.escaping = 0; .endif # negative is a terminator state for escaping
  .if enc.escaping;  enc.escape    # if in escaping mode, handle with the escape macro
  .elseif enc.char == 451; enc.escaping = -1;  enc.char = 0x22; enc.quotes=enc.quotes + 1
  .elseif enc.char == 430; enc.escaping = 1;   enc.char = 0x4C; enc.escapes=enc.escapes + 1
  # skip/count un-escaped quotes, or begin escape sequence with backslash
  .endif

.endm; .macro enc.escape
  # enc.char is the query
  # enc.escaping is a bool/int -- non-0 = escaping, and int = escape mode type
  # 1 = single char escape entry   \\ \" \t \n \r
  # 2, 3, 4 = octal ascii escape         \101
  # 5, 6, 7 = decimal ascii escape       \d065
  # 8, 9, 10 = hexadecimal ascii escape  \x41
  .if enc.escaping == 1; enc.escape.beg     # handle char escape beginning
  .elseif enc.escaping <= 4; enc.escape.oct # handle nth octal char
  .elseif enc.escaping <= 7; enc.escape.dec # handle nth decimal char
  .elseif enc.escaping <= 9; enc.escape.hex # handle nth hex char
  .else; enc.escaping = 0; .endif  # handle else case

.endm; .macro enc.escape.beg
  .if enc.char == 451;      enc.escaping = 0; enc.char = 0x22  # case of " escape
  .elseif enc.char == 430;  enc.escaping = 0; enc.char = 0x5C    # case of \ escape
  .elseif (enc.char >= 0x30) && (enc.char <= 0x37); enc.escaping = 2 # case of oct escape
    enc.escape  # recurse, because octals have no symbolic prefix
  .elseif enc.char == 0x64; enc.escaping = 5          # case of dec escape
  .elseif enc.char == 0x78; enc.escaping = 8          # case of hex escape
  .elseif enc.char == 0x74; enc.escaping = 0; enc.char = 0x9 # case of tab escape
  .elseif enc.char == 0x72; enc.escaping = 0; enc.char = 0xD # case of carriage return escape
  .elseif enc.char == 0x6E; enc.escaping = 0; enc.char = 0xA # case of newline escape
  .else; enc.escaping = 0; .endif  # handle else case

.endm; .macro enc.escape.oct
  enc.escaping = enc.escaping + 1
  .if (enc.char >= 0x30) && (enc.char <= 0x37);  enc.escaped.push enc.char & 7
    .if enc.escaping >= 5; enc.escaping = 0; .endif
  .else; enc.escaping = 0; .endif;
  .if enc.escaping == 0; enc.char = 0
    .rept enc.escaped.s
      enc.escaped.deq enc.escaped
      enc.char = enc.char << 3 | enc.escaped
    .endr # ascii has been built from octal sequence
  .endif

.endm; .macro enc.escape.dec
  enc.escaping = enc.escaping + 1
  .if (enc.char >= 0x30) && (enc.char <= 0x39);  enc.escaped.push enc.char & 15
    .if enc.escaping >= 8; enc.escaping = 0; .endif
  .else; enc.escaping = 0; .endif
  .if enc.escaping == 0; enc.char = 0
    .rept enc.escaped.s
      enc.escaped.deq enc.escaped
      enc.char = enc.char * 10 + enc.escaped
    .endr # ascii has been built from decimal sequence
  .endif

.endm; .macro enc.escape.hex
  enc.escaping = enc.escaping + 1
  .if (enc.char >= 0x30) && (enc.char <= 0x39);  enc.escaped.push (enc.char & 15)
  .else; enc.char = enc.char - 0x37
    .if (enc.char >= 10) && (enc.char <= 15);  enc.escaped.push enc.char
    .else; enc.char = enc.char - 0x20;
      .if (enc.char >= 10) && (enc.char <= 15);  enc.escaped.push enc.char
      .else; enc.escaping = 0
  .endif; .endif; .endif
  # accepts capital or lower-case a-f in addition to decimals
  .if enc.escaping >= 10; enc.escaping = 0; .endif
  .if enc.escaping == 0; enc.char = 0
    .rept enc.escaped.s
      enc.escaped.deq enc.escaped
      enc.char = enc.char << 4 | enc.escaped
    .endr # ascii has been built from hex sequence
  .endif
.endm

.endif
