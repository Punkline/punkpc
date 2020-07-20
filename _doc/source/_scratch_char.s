/*## Header:
# --- char buffers
# Char objects are scalar character variables
# Each object uses a stack to memorize an array of ascii characters, for encoding/decoding strings
# Each character in the serial array may be edited before encoding
# Encoding a buffer will save the contents as an immutable (but destroyable) string
#  - these strings may be passed to other macros by calling the '.pass' method of a char object

##*/
/*## Attributes:
##*/
/*## Examples:
##*/

#.include "./punkpc/str.s"
.include "./punkpc/stacks.s"




.macro m, str:vararg
  test = 0
  .irpc c, "\str"
    .ifc " ", \c \c; test = 1; .endif
  .endr
.endm



m "Hello"
.long test


.macro m, str:vararg

  .irpc c, "\str";   test = 1
    .ifc " ", \c \c; test = 0; .endif
    .if test; pass "'\c", "\c";
    .else; .byte 0x22;
    .endif
  .endr
.endm; .macro pass, va:vararg
   pass2 \va
.endm; .macro pass2, c, va:vararg
  .byte \c
.endm

m "Hell:o"
# this will parse quotes literally outside of altmacro mode!
# - quotes still have to be in pairs in order to be safe
# - strings may risk interpretation like literals? needs more testing




































# Static Class Properties:
char.chugsize = 48  # determines how big of a sip of characters each decoder step is allowed
# - higher numbers may be faster, but have a higher risk of approaching the ~100 call stack limit
char.mems = 0   # memorizes stack index temporarily
char.memq = 0   # memorizes queue index temporarily
char.range = 0  # memorizes parse range, for decoding
char.filt = 0   # flag is used to determine if filter is validating or invalidating a character
char.decode = 0          # counter for enforcing chugsize, when outputing decoded strings
char.decode.out = 0      # counts number of output partial strings generated with each chug
char.decode.checkesc = 0 # flag is used to identify problematic characters in altstring transition
char = 0        # property is used to input/output characters to encode/decode


# Object Constructor:
# --- char  name, str
# Char objects are stacks of integers generated from an input string argument


# Object Inheritance:
# --- self  - stack object namespace
# --- self  - string object namespace


# Object Properties:
# ---


# Object Methods:


# Static Class Methods:
# --- char.encoder  char, str, filters...
# Encode a given string of literals into a char object by creating an array of ascii integers
# charobj : a scalar 'char' object to store buffer array of encoded ascii char ints
#    str  : an input string of ascii character literals to encode into integers
# filters : optional filter keyword/argument array for limiting what characters can be buffered
# - see 'char.filter' below for available filter operations

# --- char.decoder  char, start, end, filters...
# Decode a range from a given char object's ascii buffer
# Decoded string becomes available through the '.pass' and '.passva' object methods
# Filters work just like 'char.encoder' filters
# - an implied filter of 'exc,0,0' is always appended to the end of filters, even in blank entries
#   - this prevents problematic null ascii chars from entering a decoded string buffer
#   - null characters will cause an output string to become uninterpretable (beyond the null)
# In addition, if a buffered ascii int is negative, it will tell the decoder to terminate early
# - these terminators can be created by invoking the '.terminate' method of a char object

# --- char.filter  keyword, varargs...
# Uses 'keyword' as a method name suffix for a callback event, passing varargs to the event
# Valid filter operation keywords, with arguments:
  # --- exc  start, end, ...
  # Exclude ascii range [start...end] from buffer
  # Keyword invokes 'char.filt_exc' callback
  # - if ascii is within this range, it will become invalidated, and skipped in the buffer
  # --- inc  start, end, ...
  # Include ascii range [start...end] from buffer
  # Keyword invokes 'char.filt_inc' callback
  # - if ascii is within this range, it will become validated
  # - if this is the first or lone filter in a sequence...
  #   - then ascii falling outside of range will also become invalidated
  #   - else, no invalidation occurs
  # Each filter callback calls char.filter on exit, allowing extra filters to be stated in '...'
  # - char.filter is invoked by other methods to handle the 'filters' vararg
  #   - may be used at user-level through utilization of the 'char' and 'char.buf' property values
  #     - 'char' is used to input an encoded ascii integer for a filter query before calling
  #     - 'char.filt' returns FALSE (0) if a character is not


# User-level:
.macro char \self, str;
  ifdef \self\().isChar; .if ndef; char$=char$+1; \self\().isChar=char$;
    stack \self;  str \self, "\str"
    .macro \self\().tochar,str,filters:vararg; char.encoder \self,"\str",\filters; .endm;
    .macro \self\().tostr,filters:vararg; char.decoder \self,\self\().q,\self\().s,\filters; .endm;
  .endif
.endm; .macro char.encoder, char, str, filters:vararg
  .irpc c, "\str"; char.encode "'\c"; char.filt = 1 # flag remains true if filter permits this char
    char.filter \filters; .if char.filt; \char\().push char; .endif; .endr
    # each encoded char becomes a part of the char object buffer

.endm; .macro char.decoder, char, start, end, filters:vararg
  char.mems = \char\().s; \char\().s \start
  char.memq = \char\().q; \char\().q \end   # temporarily set new stack range using args
  char.range = \char\().s - \char\().q; .altmacro; # calculate range size and enter altmacro mode
  .if char.range > 0; char.decode.out = 0 # counts number of output partial strings, with each chug
  .rept (char.range + char.chugsize-1) / char.chugsize; char.decode = 0 # recursive step counter
      char.decode \char,,,\filters; .if char.range <= 0; .exitm; .endif; .endr; .endif;
      # concat sequences of chars parsed in recursive gulps, determined by 'chugsize'
      # - size must be limited because of shallow runtime stackframe

  char.decode.concat \char; \char\().s = char.mems; \char\().q = char.memq
  # concat all partial strings after done chugging, and restore stack memory
  # (after concat, output string becomes available)

.endm; .macro char.filter, kw, va:vararg;
# filter needs to have first iteration create a flag state machine
# - first filter has a special action for filt_inc


# Hidden-level:
.endm; .macro char.encode, c; char = \c
.endm; .macro char.filt_exc,s,e,f:vararg;

.endm; .macro char.filt_inc,s,e,f:vararg

.endm; .macro char.decode,char,c,str,f:vararg;
  .if char.decode < char.chugsize; char.decode = char.decode + 1; char.decode.checkesc <!\c>
    .if char.decode.checkesc==0;\char\().deq char;char.filter \f;char.decode \char,%char,<\str\c>
    .endif
  .else;  char.decode = 0;


.endm; .macro char.decode.concat char







charmap maker?
.irpc
 !"#$%&'()*+,-./
0123456789
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
















# Can hold one or many characters in the form of a navigatable stack of numerical ascii characters
# Can pass ranges from stack as string arguments to other macros

.include "punkpc/stacks.s"

stack char.decbuf
# static decoder stack is used to buffer outputs from the .pass object method
# (see char.decode class methods)

.macro char

.endm; .macro char.encoder, char, str, filters:vararg
  .ifb \filters; char.filter=0; .else; char.filter=1; .endif
  .irpc c, \str;  char.encode "'\c"; char.buf = 1 # if filter sets char.buf = 0,
    .if char.filter; char.filter \c, \filters; .endif; # then this char doesn't enter buffer stream
    .if char.buf; \char\().buf.push char; .endif; .endr
# char.encoder is invoked by a char object's .buf method to convert a string into a char buffer
# - if chars already exist in given char buffer object
.endm; .macro char.encode, c; char = \c
# char.encode is invoked by char.encoder for each given character.
# - strictly requires input char to be formatted as a string argument "'\char", when called
.endm; .macro char.filter, kw, va:vararg
  .ifnb \kw; char.filt_\kw \va; .endif
# filter triggers a given callback keyword like an event
# - each callback re-calls char.filter to allow multiple filters in a single encoding
# Keywords "inc" and "exc" take 2 range arguments (start, end)
#  - includes or excludes characters if they fall within a given ascii range
.endm; .macro char.filt_exc, start, end, va:vararg
  .if (char >= \start) && (char <= \end); char.buf = 0; .endif; char.filter \va
.endm; .macro char.filt_inc, start, end, va:vararg
  .if (char >= \start) && (char <= \end); char.buf = 0; .endif; char.filter \va
# (These callbacks handle the different filter keywords, from char.filter)

.endm; .macro char.decoder, char, start, end, macro, va:vararg
  char.qmem = \char\().buf.q;  \char\().buf.q \start  # back up q, and set it to argument index
  char.declen = \end - \char\().buf.q  # calculate decoded string (parse) length
  .if char.declen <= 0; char.decode.pass, \macro, \va # pass blank to macro if no char length
  .else; .if \va; .altmacro; char.decode16 \char,,,,,,,,,,,,,,,,,,\macro,\va;
    .else; .altmacro; char.decode16 \char,,,,,,,,,,,,,,,,,,\macro; .endif;
  # literals are generated by recursion, and descending powers of 2 from 16 handle multiple chars
  # (this works around small char limit imposed by shallow runtime stack frame, for recursion)

.endm; .macro char.decode, char; char = 0
  .if char.declen > 0; \char\().deq char; char.declen = char.declen - 1;
    char.buf = 1; char.filter exc,0,0; .if char.buf == 0; char.decode \char
    # call self until valid char is found, or until out of chars
    .else; char = ((char >> 6) * 100) + (((char >> 3) & 7) * 10) + (char & 7);
    # if char is accepted, create an octal ascii code that can be escaped from decimal literals
    .endif; .endif

# chunky decoding tiers:
# SO MUCH extra string copying just to get around recursion limit...

.endm; .macro char.decode16, char, str, l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14,l15, /*
  */ m, va:vararg; char.decbuf.s = 0; char.decbuf.q = 0; .noaltmacro
  .if char.declen > 0;
  .rept 16; char.decode \char  # find up to 16 valid chars...
    char.decbuf.push char; .if char.declen <= 0; .exitm; .endif; .endr; .endif
  .altmacro  # exit loop if char.decode can't find any more chars...
  .if char.decbuf.s>=16;
    char.decode16,\char,\str\l0\l1\l2\l3\l4\l5\l6\l7\l8\l9\l10\l11\l12\l13\l14\l15, /*
    */ %char.decbuf$0, %char.decbuf$1, %char.decbuf$2, %char.decbuf$3, /*
    */ %char.decbuf$4, %char.decbuf$5, %char.decbuf$6, %char.decbuf$7, /*
    */ %char.decbuf$8, %char.decbuf$9, %char.decbuf$10, %char.decbuf$11, /*
    */ %char.decbuf$12, %char.decbuf$13, %char.decbuf$14, %char.decbuf$15, \m, \va
  .elseif char.decbuf.s&8;
    char.decode8,\char,\str\l0\l1\l2\l3\l4\l5\l6\l7\l8\l9\l10\l11\l12\l13\l14\l15, /*
    */ %char.decbuf$0, %char.decbuf$1, %char.decbuf$2, %char.decbuf$3, /*
    */ %char.decbuf$4, %char.decbuf$5, %char.decbuf$6, %char.decbuf$7, \m, \va
  .elseif char.decbuf.s&4;
    char.decode4,\char,\str\l0\l1\l2\l3\l4\l5\l6\l7\l8\l9\l10\l11\l12\l13\l14\l15, /*
    */ %char.decbuf$0, %char.decbuf$1, %char.decbuf$2, %char.decbuf$3, \m, \va
  .elseif char.decbuf.s&2;
    char.decode2,\char,\str\l0\l1, \str\l0\l1\l2\l3\l4\l5\l6\l7\l8\l9\l10\l11\l12\l13\l14\l15, /*
    */ %char.decbuf$0, %char.decbuf$1, \m, \va
  .elseif char.decbuf.s&1;
    char.decode1,\char,\str\l0\l1\l2\l3\l4\l5\l6\l7\l8\l9\l10\l11\l12\l13\l14\l15, /*
    */ %char.decbuf$0, \m, \va
  .else; char.decode.pass \str, \m, \va; .endif
.endm; .macro char.decode8, char, str, l0,l1,l2,l3,l4,l5,l6,l7, m, va:vararg; LOCAL c0,c1,c2,c3#
  .if char.decbuf.s&4; .irp c,c0,c1,c2,c3; char.decbuf.deq; \c = char.decbuf.deq; .endr
    .altmacro; char.decode4, \char, \str\l0\l1\l2\l3\l4\l5\l6\l7, %c0,%c1,%c2,%c3, \m, \va;
  .elseif char.decbuf.s&2; .irp c,c0,c1; char.decbuf.deq; \c = char.decbuf.deq; .endr
    .altmacro; char.decode2, \char, \str\l0\l1\l2\l3\l4\l5\l6\l7, %c0,%c1, \m, \va;
  .elseif char.decbuf.s&1; char.decbuf.deq c0
    .altmacro; char.decode1, \char, \str\l0\l1\l2\l3\l4\l5\l6\l7, %c0, \m, \va;
  .else; char.decode.pass \str, \m, \va; .endif

.endm; .macro char.decode4, char, str, l0,l1,l2,l3, m, va:vararg; LOCAL c0,c1#
  .if char.debuf.s&2; .irp c,c0,c1; char.decbuf.deq; \c = char.decbuf.deq; .endr

.endm; .macro char.decode2, char, str, l0,l1,l2,l3, m, va:vararg

.endm; .macro char.decode1, char, str, l0,l1,l2,l3, m, va:vararg

.endm






  .if char.declen > 7; .irp x, c0, c1, c2, c3, c4, c5, c6, c7; \char\().buf.deq char
      char.\x = ((char >> 6) * 100) + (((char >> 3) & 7) * 10) + (char & 7)
    .endr; char.declen = char.declen - 8; char.decode8, \char, \m, \ch0\ch1\ch2\ch3\ch4\ch5\ch6\ch7, /*
    */ %char.ch0, %char.ch1, %char.ch2, %char.ch3, %char.ch4, %char.ch5, %char.ch6, %char.ch7;
  .else; char.decode4, \char, \m, \ch0\ch1\ch2\ch3\ch4\ch5\ch6\ch7; .endif
.endm; .macro char.decode4, char, m, str, c0, c1, c2, c3
  .if char.declen > 3; .irp x, c0, c1, c2, c3; \char\().buf.deq char
      char.\x = ((char >> 6) * 100) + (((char >> 3) & 7) * 10) + (char & 7)
    .endr; char.declen = char.declen - 4; char.decode4, \char, \m, \ch0\ch1\ch2\ch3, /*
    */ %char.ch0, %char.ch1, %char.ch2, %char.ch3
  .else; char.decode2, \char, \m, \ch0\ch1\ch2\ch3; .endif
.endm; .macro char.decode2, char, m, str, c0, c1
  .if char.declen > 1; .irp x, c0, c1; \char\().buf.deq char
      char.\x = ((char >> 6) * 100) + (((char >> 3) & 7) * 10) + (char & 7)
    .endr; char.declen = char.declen - 2; char.decode2, \char, \m, \ch0\ch1, %char.ch0, %char.ch1
  .else; char.decode1, \char, \m, \ch0\ch1; .endif
.endm; .macro char.decode1, char, m, str, c0; char.ch0 = 0
  .if char.declen > 0;
    char.ch0 = ((char >> 6) * 100) + (((char >> 3) & 7) * 10) + (char & 7)

.endm;
