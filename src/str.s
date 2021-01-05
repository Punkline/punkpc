/*## Header:
# --- str buffers
# String objects create purgable, concatenatable buffers of unmutable string data
# String data is made addressable by copying and appending argument strings to macro calls
# - this is done with special passing methods available in each string object

##*/
##/* Updates:
# version 0.1.1
# - replaced pointer methods with 'obj' module implementation
# - reorganized namespaces into hidden and non-hidden layers, with '.__' delimiters
# - moved object guts into class-level methods, for smaller object instances
# - added a '.concitems' and '.pfxitems' method, for creating lists of symbol items

# --- version 0.1.0
# - added high-level convenience macros for using multiple strings in the following directives:
#   - .error, .warning, .print, .ascii, .asciz
#   - also added special '.asciiz' method, for creating a single null-terminated string from args
# - added 'str.emit' class method, for building and emitting temp strings from args and pointers
# - added 'str.self_pointers' property, to allow string object names to evaluate as string pointers
# - added counting features for comma-separated items and characters
# - added a '.irpc' method to complement the '.irp' method
# - fixed bug where '.strq' method would have reversed vararg order if done from normal string mem
# version 0.0.4
# - added high-level convenience macros for operating with write methods of objects through pointers
# version 0.0.3
# - fixed bug where commas would be added to strings when whitespace was added
# - created a pointer.get feature, for handling both a str obj and a str pointer in the same way
# - added high-level convenience macros for creating iterators out of strings or string pointers
# - added high-level convenience macros for operating with read methods of objects through pointers
# version 0.0.2
# - added a lazy '.is_blank' flag update that can be used to help find empty buffers
# version 0.0.1 - added to punkpc module library



##*/
/*## Attributes:
# --- Class Properties

# --- str$                - String ID counter
# used to enable string pointers by assigning each string object a unique ID

# --- str.self_pointers   - Bool option (true by default)
# copies object '.is_str' to 'self' when a string is newly created
# - keeping this on allows string names to be evaluated as pointers in addition to object names
# - if you don't want the constructor to assign a property to self, you may turn this off
#   - turning this off will still allow string pointers to be referenced from the '.is_str' property



# --- Object Constructors

# --- str  name, string
# Create a new string buffer, or overwrite an existing string/literal buffer
#  name   : the name of the string/literal buffer to use
#  string : a starting string to start with (can be blank)
# - string buffers concatenate internally from a pair of quotes in the buffer
# - string buffers can protect its contents from being interpreted literally
# - string buffers can optionally be emitted as literals

# --- lit  name, string
# Create a new literal buffer, or overwrite an existing string/literal buffer
# - literal buffers concatenate externally from any quotes in the buffer
# - literal buffers can emit source literals that include quotes in the buffer
# - literal buffers may be re-quoted as strings if they contain no quotes internally


  # ---Object Properties:

  # --- .is_str      - a unique ID for this buffer (can be used with str.point to pass a str name)
  # --- .is_blank - a bool that is 0 (false) if the string buffer is (thought to be) empty
  # --- .litmode    - a read-only status of literal buffer memory mode type
  # - litmode determines whether a buffer is a string or a literal string


  # ---Object Methods:

  # --- .clear
  # Clear the memory in this buffer, and reset to string mode if in literal memory mode

  # --- .conc    sfx
  # Concatenate a suffix to this string/literal buffer
  # - this will try to input c as one whole string rather than multiple literal arguments
  # sfx : suffix to concatenate

  # --- .pfx     pfx
  # Concatenate a prefix to this string/literal buffer
  # - this will try to input c as one whole string rather than multiple literal arguments
  # pfx : prefix to concatenate

  # --- .str    macro, trailing...
  # Pass the string buffer to given macro (or directive) with optional trailing args
  #   macro    : the name of a macro or directive to use when handling this string buffer
  #   trailing : arguments that would come AFTER the output string argument; for macro call
  # - if in litmode, the object will try to quote the contents before passing them

  # --- .strq   macro, leading...
  # Pass the buffer contents to given macro (or directive) with optional leading args
  #   macro    : the name of a macro or directive to use when handling this string buffer
  #   trailing : arguments that would come BEFORE the output string argument; for macro call
  # - if in litmode, the object will try to quote the contents before passing them


  # literal buffer variations:
  # --- .conclit  sfx...
  # variant of '.conc' that forces the buffer into literal memory mode
  # - suffix can be multiple arguments, and concatenation will come after any buffered quotes
  #   - if multiple arguments are given, then there will always be a space ' ' at point of concat

  # --- .pfxlit   pfx...
  # variant of '.pfx' that forces the buffer into literal memory mode
  # - prefix can be multiple arguments, and concatenation will come after any buffered quotes
  #   - if multiple arguments are given, then there will always be a space ' ' at point of concat

  # --- .lit      macro, trailing...
  # variant of '.str' that does not attempt to re-quote the output argument(s)
  # - if used on a buffer without litmode enabled, the string memory will be unquoted on output
  #   - if multiple trailing args are given, then they will be preceeded by a space ' '

  # --- .litq     macro, leading...
  # variant of '.str' that does not attempt to re-quote the output argument(s)
  # - if used on a buffer without litmode enabled, the string memory will be unquoted on output
  #   - if multiple leading args are given, then they will be preceeded by a space ' '


  # Argument Item list variations:
  # --- .concitems  sfx




# --- Class Methods

# --- str.point  id, macro, trailing...
# Point to a string object by referencing a unique string ID stored in the 'self.is_str' property
#   id       : an ID matching the '.is_str' property of an associated string
#            - if id is blank, then the 'str.point' property will be used
#   macro    : the name of a macro or directive to use when handling this string object name
#   trailing : arguments that would come AFTER the output name argument; for macro call

# --- str.pointer  str
# str can be either a string object or a string pointer
# - saves resulting string pointer in the 'str.point' property

# --- str.irp        str, macro, trailing...
# --- str.irpq       str, macro, leading...
# These can be used to iterate through comma-separated-values saved in a string buffer
# - str can be either a string object name or a string pointer/pointer name
# - the macro is called once for EACH item
# - the leading/trailing args are added to EACH item

# --- str.str        str, macro, trailing...
# --- str.strq       str, macro, leading...
# --- str.lit        str, macro, trailing...
# --- str.litq       str, macro, leading...
# --- str.conc       str, ...
# --- str.pfx        str, ...
# --- str.conclit    str, ...
# --- str.pfxlit     str, ...
# --- str.clear      str, ...
# These can be used to invoke object methods from a class level
# - 'str' may be either a string object name or a numerical string pointer

# --- str.emit   macro, str, ...
# This lets you emit statements using a combination of strings and string pointers
# 'str' may be specified in [brackets] to reference a string pointer
# - creates a temporary string to be emitted, called 'str.emitter' -- which can be used afterwards
# - string pointers must be evaluable expressions that reference the number ID given to a string
# - all arguments are automatically given a space to separate them

# --- str.error  str, ...
# Turn multiple string arguments into a contiguous error message
# str : a string argument (not a string object)
# - you can use '.strq' object methods to stack up string arguments

# --- str.errors str, ...
# Turn multiple string arguments into a series of error messages


# --- str.warning  str, ...
# --- str.warnings str, ...
# - a warning version of error/errors

# --- str.print_line  str, ...
# --- str.print_lines str, ...
# - a printer version of error/errors

# --- str.ascii  str, ...
# --- str.asciz  str, ...
# - ascii emitters; asciz adds a null terminator to the end of each string argument

# --- str.asciiz str, ...
# - special ascii emitter that makes one big null terminated string

# --- Callback Methods

# indexed class methods str.__strbuf_event$ 0-31 are used to handle object method cases
# indexed class methods $_str.point$ n are used to handle string pointers



## Messages from examples:

## Error: Hello World!
## Error: OVERWRITE ME
## Error: CLEAR ME
## Error:
## Error: I AM JUST A BUFFER
## Error: Hello World
## Error: HelloWorld
## Error: Hello World
## Error: These are multiple arguments
## Error: Theseare multiple arguments
## Error: This literal statement is self-contained
## Error: This literal statement is also self-contained
## Error: Error
## Error: Message
## Error: Error Message
## Error: ErrorMessage
## Error: Error Message
## Error: too many positional arguments
## Error: too many positional arguments
## Error: Hello World!
## Error: Hello World>
## Error: OVERWRITE ME
## Error: CLEAR ME
## Error:
## Error: I AM JUST A ALTBUFFER
## Error: 0,1,2,3,4,5,
## Error: Nested
## Error: Strings
## Error: Protected
## Error: Strings
## Error: myString
## Error: You found me
## Error: You found me ... again!
## Error: You found me ... again!
## Error: You found me ... again!
## Error: H
## Error: e
## Error: l
## Error: l
## Error: o
## Warning: Hello World
## Warning: Hello
## Warning: World
## Error: Count found 4 item(s) in list ...
## Error:  ... and 27 char(s) in string

##*/
/*## Examples:
.include "punkpc.s"
punkpc str
# Use the 'punkpc' statement to load this module, or include the module file directly




# --- BASICS ---
str test, "World"
# Creates a string called 'test' with the buffer holding memory of the string "World"

test.pfx "Hello "     # This prefixes "Hello " to the FRONT of the buffer
# buffer = "Hello World"
# - the space in "Hello " is not trimmed, because it is quoted
# - the two quoted concatenations are combined into a single quoted string

test.conc "!"         # This concatenates a "!" to the END of the buffer
# buffer = "Hello World!"
# - quoted strings can be concatenated or prefixed, to merge inputs over multiple calls

test.str .error
# >>> Error: Hello World!
# Passes buffer contents as an argument to the directive '.error', to display the string
# - The .error directive requires that its input be quoted, and then displays the unquoted error
# - any macro name can be used to handle the string contained in the str buffer

str test "OVERWRITE ME";  test.str .error
str test "CLEAR ME";  test.str .error
test.clear;  test.str .error
test.conc "I AM JUST A BUFFER";  test.str .error
# >>> Error: OVERWRITE ME
# >>> Error: CLEAR ME
# >>> Error:
# >>> Error: I AM JUST A BUFFER
# String objects can be overwritten by re-initializing with the 'str' constructor
# You can erase string memory by re-initializing with a blank string, or by using '.clear'


# --- MEMORY TYPES ---
# There are 2 types of string memory used in string buffers
#   - the type used is determined automatically as required by user inputs:
# --- String memory - quoted strings
# --- A string contained within "quotes", and containing no other quotes internally
# - Normal (quoted) strings are protected from being interpreted as literal strings when processed
# - Normal strings are unquoted before concatenations, and then requoted before writing memory
# - .conc and .pfx will maintain string memory mode for a buffer on concatenation
# - .conclit and .pfxlit will force a string memory buffer to become a literal memory buffer
# - Normal string inputs/outputs are unquoted when passed using .lit, .litq, .conclit, and .pfxlit
# --- Literal Memory - source literals
# --- A super string that can contain multiple strings/arguments
# - Literal strings are not protected from being interpreted unless explicitly quoted internally
# - Literal strings are concatenated without any unquoting/requoting
# - Normal strings converted into literals with .conclit or .pfxlit become unquoted on transition
# - Literal string inputs/outputs are requoted when passed using .str, .strq, .conc, and .pfx

str s, "Hello " # 's' is a new str object, with string memory contained in its buffer
s.conc World    # '.conc' internally concatenates string memory with an input argument
# >>> buffer = "Hello World"
s.str .error # >>> Error: Hello World
# Concatenations to string memory are done internal to the outer quotation marks
# - when passed through s.str, the buffer is unquoted on copy, and requoted when emitted literally
# - when passed through s.conc, the input is unquoted (if needed) before concatenation
#   - because of this, singular argument concatenation inputs don't always need to be quoted

str s   # - if we do this; the existing 's' object becomes cleared and replaced by a blank string
s.conc "Hello "  # concatenating a blank string is like starting a new string
s.conclit World  # .conclit causes String memory to become Literal memory
# >>> buffer = HelloWorld
s.str .error # >>> Error: HelloWorld
# Literal cocatenations to string string memory will cause the resulting buffer to become unquoted
# Unquoted Literal memory will not maintain any leading or trailing spaces on copy/concatenation
# - because of this, the space in "Hello " gets trimmed

str s
s.conclit Hello  # literal memory buffer trims leading/trailing spaces...
s.conc " World"  # ...but quoted input will be protected from interpretation as source literals...
# >>> buffer = Hello World
s.str .error # >>> Error: Hello World
# Literal memory can be concatenated by unquoted strings with the .conc method
# - this can be used to preserve whitespace on concatenation
#   - NOTE: sequences of more than 1 space will always be reduced to just 1 space character

str s
s.conclit These
s.conclit are multiple arguments
# >>> buffer = These are multiple arguments
s.str .error # >>> Error : These are multiple arguments
# When concatenating multiple arguments or strings (at once) to literal memory, a space is added
# - this is imposed by a limitation of concatening 2 literal strings in a single macro call

str s
s.conclit These
s.conc    are multiple arguments
# >>> buffer = Theseare multiple arguments
s.str .error # >>> Error : Theseare multiple arguments
# Using '.conc' in place of '.conclit' enquote the multiple arguments, reading it in as 1 argument
# - this causes it to be concatenated as a single argument, circumventing the generated space char
# - this isn't safe if the multiple arguments contain quotation marks outside of altmacro mode

# Literals can be generated from string memory by using '.lit' in place of '.str' to pass buffer
#  .lit  >>> .float 3.1415         # string result is not quoted
#  .str  >>> .ascii "Hello World"  # string result is quoted
# - doing this does not cause string memory to convert into literal memory
# - if used with literal memory, the result is simply not quoted on passing

# 'lit' can be used in place of 'str' constructor to clear with literal memory buffer instead
# Literal memory is capable of keeping quoted strings internally, if they come in pairs
lit s, .error "This literal statement is self-contained"
# buffer = .error "This literal statement is self-contained"
s.lit
# >>> Error : This literal statement is self-contained
# when emitted by itself, it's possible to invoke macro or directive names saved IN the buffer

# The above is exactly the same as the following:
str s
s.conclit .error "This literal statement is also self-contained"
s.lit
# - 'lit' in place of 'str' is just an option for better user-readability



# --- ERROR BUILDING ---
# 'str.errors' is a macro that can emit multiple error messages from 1 or more arguments:
# - each argument may optionally be quoted
lit s, Error Message
# buffer = Error Message

s.lit str.errors
# >>> Error : Error
# >>> Error : Message
# Passing  Error Message to 'str.errors' with '.lit' will cause each argument to be read separately

s.str str.errors
# >>> Error : Error Message
# Passing  Error Message  to str.errors with '.str' will enquote the whole argument string


# 'str.error' is a variation of 'str.errors' that concatenates multiple strings into one error:
s.lit str.error
# >>> Error : ErrorMessage
# - spaces are trimmed between Error and Message arguments

s.str str.error
# >>> Error : Error Message
# - space is preserved when enquoted



# --- ARGUMENT BUILDING ---
# You can enqueue multiple string buffers into a single macro call with '.strq' and '.litq'
# - this allows you to construct arguments abstractly
str pi  "3.141592654"
str e   2.718281828
lit one 1.0
pi.litq e.litq, one.litq, .float
# >>> .float 3.141592654, 2.718281828, 1.0
# >>> 0x40490FDB, 0x402DF854, 0x3F800000
# - NOTE: this example emits bytes, not error messages -- so it will get lost in the other examples

# If desired, you can also save these kinds of lines in a another string, for evoking separately:
lit myFloats, pi.litq e.litq, one.litq, .float
myFloats.lit
# >>> .float 3.141592654, 2.718281828, 1.0
# >>> 0x40490FDB, 0x402DF854, 0x3F800000



# --- ALTSTRINGS !!! ---
.altmacro
# Use the .altmacro directive to switch to altmacro mode
# - this just changes the way macro calls are made, and is otherwise just a simple boolean switch
# - never switch to altmacro mode if you don't know you'll be able to switch back before returning
#   - if you must find what mode you are in procedurally, use the 'ifalt' module to create a sensor

# When in altmacro mode, you must use  <alt strings>  instead of  "quoted strings"
# - these take the place of  "quoted strings"  when handling  <string memory>  vs  literal memory

# While altstrings are supported by str objects, they are still subject to the quirks of altstrings
# - ! < and > chars can be problematic, but "internally quoted strings" are usually ok
# - % may sometimes be used to pre-emptively evaluate an expression string (on passing)
# - & and | operators may sometimes create syntax errors in evaluations
# - leading/trailing spaces of <quoted altstrings> are trimmed
#   - ex: <  mystr  > == <mystr>
# - it is possible to nest < quoted, <altstrings> > and unwrap them in layers by using macro calls

# Leading/trailing spaces within altmacro strings are trimmed as though they were literals
# - this is because the string internally is still treated like literal memory in certain ways
str test, <World>
test.pfx <Hello >  # buffer = <HelloWorld>
# - the space in "Hello " is trimmed even though it is quoted, because it is in altmacro mode

str test, <Hello World>
# buffer = <Hello World>
# Trying to put a '!' at the end of this buffer will be problematic in altmacro mode...
test.conc <!> # --- this will create an error:
# --->>> Error: too many positional arguments
# In altmacro mode, the characters '!' '<' and '>' must be prefixed with a '!' escape char
# - omitting this usually makes the buffer unstable, escaping part of the altstring in this case
test.conc <!!> # --- this will also create an error
# You might expect this to work, but however, serial '!!' escapes will recursively escape on concat
# - the resulting '!' char gets treated like an escape char on each passing, so it escapes again
# - this may be unique to just the '!' char, and may not be a problem for brackes '<' and '>'

.noaltmacro
# Use the .noaltmacro directive to switch out of altmacro mode
# It's easy to briefly switch back to noaltmacro mode to make this concatenation safely:
test.conc "!"
test.str str.error
# >>> Error : HelloWorld!
# However, this buffer is now only stable in noaltmacro mode

.altmacro
test.str str.error
# >>> Error : HelloWorld>
# Attempting to use it in altmacro mode will cause the '!' char to create an escape
# <HelloWorld!> causes the '>' to become a literal character, interpreted as a second argument
# - this is because again, the buffered '!' char makes the buffer unstable in altmacro mode
#   - keep this in mind when using altstrings with the str object buffer

# If you keep the leading/trailing space trimming and the escaped character quirks in mind...
# ...then the output should otherwise be comparable to noaltmacro mode:
str test <OVERWRITE ME>;  test.str str.error
str test <CLEAR ME>;  test.str str.error
test.clear;  test.str str.error
test.conc <I AM JUST A ALTBUFFER>;  test.str str.error
# >>> Error: OVERWRITE ME
# >>> Error: CLEAR ME
# >>> Error:
# >>> Error: I AM JUST A ALTBUFFER
str pi  <3.141592654>
str e   2.718281828
lit one 1.0
pi.litq e.litq, one.litq, .float
# >>> .float 3.141592654, 2.718281828, 1.0
# >>> 0x40490FDB, 0x402DF854, 0x3F800000



# --- ALTSTRING EVALUATIONS ---
# One exceptionally useful aspect of altmacro mode is the ability to evaluate integer expressions:
myInt=0; str test
.rept 6; test.conc %myInt; test.conc <,>; myInt=myInt+1; .endr
test.str str.error
# >>> Error : 0,1,2,3,4,5
# - evaluations are always literal decimal values
# - if a given expression can't be evaluated, an error will be generated, and 0 will be used



# --- ALTSTRING NESTING ---
# Another is its ability to nest strings within another altstring:
str test, < <.error "Nested">, <.error "Strings"> >
.macro myParser, va:vararg; .irp str, \va; \str; .endr; .endm
test.lit myParser
# >>> Error : Nested
# >>> Error : Strings
# - these are 2 statements containing "double quotes" wrapped in <altstrings>
# - the pair of statements are nested within a super <altstring> that lists them
# - the parser handles the list by simply emitting the contents of each sequential altstring
#   - this is a recipe for creating parsable string-based events



# --- NOALTSTRING PROTECTION ---
# If you can avoid using internal quotes, then you can protect a pure altstring for noaltmacro mode
# - this allows you to use some characters that would otherwise be problematic, like semicolon ;
.noaltmacro
str test, ".irp s, <str.errors <Protected> >, <str.errors <Strings> >; \s; .endr"
.altmacro; test.lit
# >>> Error : Protected
# >>> Error : Strings
# This is particularly powerful, because it allows you to write loop blocks
# - so far, I have not been able to get this to work for .macro blocks or .if blocks...
#   - it's possible to create builder macros that do this however, for macro blocks at least


.noaltmacro



# --- STRING OBJECT POINTERS ---
# Each string object has a unique ID generated in its '.is_str' property
# - '.is_str' is case sensitive
# This ID may be used with the 'str.point' class method to identify a string object's name
# - this string name is then passed to a given macro

str myString, "You found me"
myPointer = myString.is_str
# myPointer is just a normal symbol, holding the number associated with identifying 'myString'

str.point myPointer, str.error
# >>> Error : myString
# - this doesn't cause the string's contents to be read -- rather just the name of the string

.macro myStrObjectHandler, obj; \obj\().str str.error; .endm
# You can easily construct macros that handle the string object by using its namespace
# - this string object handler simply emits the string's contents in an error message

str.point myPointer, myStrObjectHandler
# >>> Error : You found me
# The string has been reached from a numerical pointer value stored in 'myPointer'


str.pointer myString;
myPointer = str.pointer
# You may use 'str.pointer' to handle either a string name or a string pointer like a pointer:
# The 'str.pointer' property returns a pointer value that you can copy, or use directly

str.pointer myString.is_str
# the name of a valid string object can be used, or a string pointer ID from the '.is_str' property

myString.conc " ... again!"

str.point myPointer, myStrObjectHandler
str.point str.pointer, myStrObjectHandler
# >>> Error : You found me ... again!
# >>> Error : You found me ... again!
# these are both handled like pointers
# - as you can see, the string can be updated in the meantime

str.point, myStrObjectHandler
# >>> Error : You found me ... again!
# You can use the 'str.point' property automatically by just skipping the argument field with ','
# - this is convenient, but may be syntactically confusing




# --- STRING POINTER HANDLERS ---
# As of update 0.1.0, strings will now automatically copy their string IDs to their own symbol name
# - this means that the name 'myString' represents both the object namespace and a property
#   - the property can be evaluated to find the numerical ID of this string
#   - this means that the name can be passed as part of an expression

# It's possible to disable this if you want to make the property do something else
# - the ID can also be found through the '.is_str' property or 'str.pointer'

# Many high-level class methods are capable of handling pointers in ways that are very convenient

str myItems, 15, 6701, 8, 9, 100
str.irp myItems, "li r0, "
# >>> li r0, 15
# >>> li r0, 6701
# >>> li r0, 8
# >>> li r0, 9
# >>> li r0, 100
# '.irp' puts the string buffer through a .irp loop; giving each item to a macro or directive

str.pointer myItems
currentItems = str.pointer
# - create an assembler-time pointer variable

str.irp currentItems, "li r0, "
# >>> li r0, 15
# >>> li r0, 6701
# >>> li r0, 8
# >>> li r0, 9
# >>> li r0, 100
# These pointer functions can handle both string object names and pointers

str otherItems, str.pointer, myItems.is_str, 32, 64
currentItems = otherItems.is_str
.macro currentItems, imm;  li r, \imm; r=r+1; .endm
# This callback can be passed to str.irp
# - note that string items do not have a main method, so you can turn them into whatever you like

r=3
str.irp currentItems, currentItems
# >>> li r3, 8
# >>> li r4, 8
# >>> li r5, 32
# >>> li r6, 64
# The pointer can point to any string ID kept in another symbol, like 'currentItems'
# Macros can also be passed to handle more complex processes via callbacks

# Arguments can also be added to either end of each item:
str.irp  myItems, ".hword ", 1, 2, 3
#+ 000F 0001 0002 0003 : .irp - gives extra args to end of each item
#+ 1A2D 0001 0002 0003
#+ 0008 0001 0002 0003
#+ 0009 0001 0002 0003
#+ 0064 0001 0002 0003
str.irpq myItems, ".hword ", 1, 2, 3
#+ 0001 0002 0003 000F : .irpq - gives extra args to beginning of each item
#+ 0001 0002 0003 1A2D
#+ 0001 0002 0003 0008
#+ 0001 0002 0003 0009
#+ 0001 0002 0003 0064

str myChars, "Hello"
str.irpc myChars, "str.error "
# >>> Error: H  : .irpc and .irpcq can be used to operate on each char in a string
# >>> Error: e
# >>> Error: l
# >>> Error: l
# >>> Error: o

# in addition to .irp, there are also class methods for invoking object methods remotely
Items = myItems.is_str
str.lit  myItems, ".hword ", , 1, 2, 3
#+ 000F1A2D 00080009 : .lit - arguments come after items, so an extra comma prefixes arguments
#+ 00640001 00020003
str.litq   Items, ".hword ", 1, 2, 3
#+ 00010002 0003000F : .litq - items are enqued to given list of comma separated arguments
#+ 1A2D0008 00090064

# - as you can see, pointers can be used in place of string names here, as well

# You can take advantage of some other class methods included to invoke certain directives
# - we've been using str.errors and str.error in these examples a lot, but there are others too

str.str   myItems, "str.asciiz,", ", 1, 2, 3"; .align 3
#+ 31352C36 3730312C : .str - passing multiple string args to a single .ascii directive
#+ 382C392C 3130302C "15,6701,8,9,100, 1, 2, 3"  -- spaces are preserved from args, but not lits
#+ 20312C20 322C2033
#+ 00000000 00000000
str.strq    Items, "str.asciiz ", "1, 2, 3, "; .align 3
#+ 312C2032 2C20332C : .strq
#+ 2031352C 36373031 "1, 2, 3, 15,6701,8,9,100"
#+ 2C382C39 2C313030
#+ 00000000 00000000
# The str.asciiz (with an extra i) combines multiple input strings together with .ascii,
#  and ends with a null-terminator like .asciz -- creating one big null-terminated string
# - .align 3 then aligns the 0s to 8 bytes

str.clear Items
str.conc  Items, "Hello World"
str.str   Items, str.warning
# >>> Warning: Hello World
# - a more threatening take on Hello World

str.lit   Items, str.warnings
# >>> Warning: Hello
# >>> Warning: World
# - it works just like .errors, but it's a warning not an error
# - you can disable warnings made with the str library by setting 'str.show_warnings' to false
# - you can also disable them entirely with some command line settings in as.exe

str Items, "You can't see this"
str.show_warnings=0
str.str  Items, str.warning
# - this is effectively a NOP because of the nullified property

str.show_warnings=1
# - turning it back on will allow all subsequent warnings to be displayed




# --- STRING EMITTER ---
# The string emitter can combine raw string arguments, string pointers, and evaluations
# - these

str msg1, "item(s) in list"
str msg2, "char(s) in string"
# create some strings for emitting in errors

str Items, "Class, PLink, GXLink, SLink"
# a new list of items to count

str.count.items Items;  items.count = str.count
str.count.chars Items;  items.chars = str.count
# these counter methods can help you figure out how many things are in a string
# - you can use str.__vacount and str.__vachars to pass direct string arguments, too

str.emit .error, "Count found", %items.count, [msg1], "..."
str.emit .error, " ... and", %items.chars, [msg2]
# >>> Error: Count found 4 item(s) in list ...
# >>> Error:  ... and 27 char(s) in string
# - these high-level emitter statements are very flexible, and are good for formatting messages

##*/




.ifndef punkpc.library.included;
.include "punkpc.s"; .endif
punkpc.module str, 0x101
.if module.included == 0; punkpc ifdef, ifalt, obj

obj.class str
str.self_pointers = 1
# set up str class for creating objects
# - enable self pointers, so that string names can be used directly as pointers

# Static Class Properties:
str.__vacount=0       # returns count of variadic arguments in a given argument string
str.__force_litmem=0  # helps the str.lit convenience macro
str.__logic=0         # temporarily holds logical bools for generating a callback key
str.show_warnings=1   # allows warnings made with str.warning(s) to be be displayed

# Boolean masks, for handling callback logic
str.__mRead    = 1; str.__mWrite=0
# --- TRUE  -  This is a read operation (pass the str to a macro, with optional varargs)
# --- FALSE -  This is a write operation (concatenate the string buffer with new literals)
str.__mLitmem  = 2; str.__mStrmem=0
# --- TRUE  -  Output uses literal memory (:vararg)
# --- FALSE -  Output uses str memory (single argument)
str.__mLitio   = 4; str.__mStrio=0
# --- TRUE  -  Input/Output is to be evoked \literally when passed
# --- FALSE -  Input/Output is to be "\requoted" when passed
str.__mPrefix  = 8; str.__mSuffix=0
# --- TRUE  -  Concatenation is prefixing existing memory
# --- FALSE -  Concatenation is suffixing existing memory
str.__mAltstr = 16; str.__mNoalt=0
# --- TRUE  -  Input/Output requotes using <> instead of "", keeping altmacro mode on return
# --- FALSE -  Input/Output requotes using "", switching back to noaltmacro mode
# - mRead, mLitio, and mPrefix are determined by 8 variations of of method names
# - mAltstr and mLitmem are background conditions observed by object and environment properties




# --- Object Constructor:
.macro lit, va:vararg; str.__force_litmem=1; str \va
.endm; .macro str, self, varg:vararg;
  str.obj \self
  .if ndef;
  \self\().litmode=0
  \self\().is_blank=1

  .irp method, .conc, .pfx, .str, .strq, .conclit, .pfxlit, .lit, .litq, .concitems, .pfxitems
    .macro \self\method, va:vararg; str.__obj_\method \self, \va; .endm
  .endr  # bind object methods to class-level methods


  # Most object methods are basically just a setup for a callback to a keyed handle
  # - str.__logic sets up the callback key based on the conditions and operation type
  # - altmacro mode is then used to turn the logic into an evaluated decimal number
  # - This evaluation can then be used to concatenate a macro name when making a call
  #   - 5 boolean conditions create 32 callback handles -- but from only 8 callable methods

# Splitting the cases into callbacks like this greatly reduces the number of string copies needed
# - the events that invoke these callbacks are called 'str.__strbuf_dispatch' and '.__strbuf_event'
#   - the event invokes a special rebuilder macro that is responsible for feeding it string inputs
  .macro \self\().clear; str.__buildstrmem \self; \self\().is_blank=1
  .endm; .macro \self\().__strbuf_event;  .endm; .endif;  str.__vacount \varg;
  .if str.__force_litmem; str.__vacount=2; .endif; str.__force_litmem=0
  .if str.__vacount>1;  str.__buildlitmem \self,,,\varg;
  .else;  str.__buildstrmem \self, \varg; .endif
  # There are 2 variations of this builder macro, for different memory methods:
  # - str memory builder
  # - lit memory builder


# --- Convenience Methods:
.endm; .macro str.str, str, va:vararg; str.pointer \str;  str.point, str.__read_handle, str, \va
.endm; .macro str.lit, str, va:vararg; str.pointer \str;  str.point, str.__read_handle, lit, \va
.endm; .macro str.strq, str, va:vararg; str.pointer \str; str.point, str.__read_handle, strq, \va
.endm; .macro str.litq, str, va:vararg; str.pointer \str; str.point, str.__read_handle, litq, \va
# these let objects be read by pointers

.endm; .macro str.conc, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, conc, \va
.endm; .macro str.pfx, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, pfx, \va
.endm; .macro str.conclit, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, conclit, \va
.endm; .macro str.pfxlit, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, pfxlit, \va
.endm; .macro str.clear, str; str.pointer \str;
  str.point, str.__write_handle, clear
.endm; .macro str.concitems, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, concitems, \va
.endm; .macro str.pfxitems, str, va:vararg; str.pointer \str;
  str.point, str.__write_handle, pfxitems, \va
# these let objects be written by pointers


.endm; .macro str.count.items, str
  str.pointer \str; str.litq str.pointer, str.__vacount; str.count = str.__vacount
.endm; .macro str.count.chars, str
  str.pointer \str; str.strq str.pointer, str.__vachars; str.count = str.__vacount
  # these can count the comma-separated items or characters in a string, in 'str.count'

.endm; .macro str.errors, va:vararg; str.__qrecurse_iter .error, \va
.endm; .macro str.error, va:vararg; str.__qrecurse .error, \va
.endm; .macro str.warnings, va:vararg;
  .if str.show_warnings;str.__qrecurse_iter .warning, \va;.endif
.endm; .macro str.warning, va:vararg; .if str.show_warnings;str.__qrecurse .warning, \va;.endif
.endm; .macro str.print_lines, va:vararg; str.__qrecurse_iter .print, \va
.endm; .macro str.print_line, va:vararg; str.__qrecurse .print, \va
.endm; .macro str.print, va:vararg; str.__qrecurse .print, \va
.endm; .macro str.ascii, va:vararg; str.__qrecurse_iter .ascii, \va
.endm; .macro str.asciz, va:vararg; str.__qrecurse_iter .asciz, \va
.endm; .macro str.asciiz, va:vararg; str.__qrecurse_iter .ascii, \va; .byte 0
# these macros use qrecurse to pass multiple (possibly unquoted) strings to string directives

.endm; .macro str.emit, m, va:vararg;
  ifalt; .if alt; st.delimit \m, < >, \va; .else; str.delimit \m, " ", \va; .endif
  # this tool lets you build statements out of a combination of string arguments and string pointers
  # use a % prefix to force an input expression to be evaluated before recorded as string
  # use [brackets] to enclose an evaluable expression that references a numerical string pointer
  # - each string object creates a string pointer out of its own name on construction
  #   - this makes it possible to type just the [string_name] to pass a pointer

.endm; .macro str.delimit, m, delimit, va:vararg
  str str.emitter; ifalt
  .irp str, \va; str.emitter.point = 0; str.emitter.eval = 0
    .irpc c, \str;
      .ifc \c, [; str.emitter.point = \str; .exitm; .endif
      .ifc \c, %; str.emitter.eval  = 1; .exitm; .endif
      .exitm;
    .endr
    .if str.emitter.eval;
      str.emitter.alt = alt
      str str.emitter.eval
      .altmacro; str.emitter.eval.conc \str
      ifalt.reset str.emitter.alt
      str.emitter.point = str.emitter.eval.is_str; .endif
    .if str.emitter.point; str.str str.emitter.point, str.emitter.conc
      .if alt;  str.emitter.conc <\delimit>; .else; str.emitter.conc "\delimit"; .endif
    .else;
      .if alt;  str.emitter.conc <\str\delimit>; .else; str.emitter.conc "\str\delimit"; .endif
    .endif
  .endr; str.emitter.str \m
  # - a version of 'str.emit' that allows for an input delimitter argument
  # use the 'delimit' arg to add a char or sequence of chars that will delimit the string args



.endm; .macro str.irp, str, m, va:vararg;
  str.pointer \str;  str.point, str.__irp_handle, 0, "\m", \va
.endm; .macro str.irpq, str, va:vararg; str.pointer \str; str.point, str.__irp_handle, 1, \va
  # this allows comma separated items to be iterated through by a macro, directive, or instruction
  # args can optionally be added to each iteration


.endm; .macro str.irpc, str, va:vararg; str.pointer \str;  str.point, str.__irpc_handle, 0, \va
.endm; .macro str.irpcq, str, va:vararg; str.pointer \str; str.point, str.__irpc_handle, 1, \va
# this is a version of .irp that works on each character in the string, instead of each arg




# --- (hidden layer)

.endm; .macro str.__logic, self, va:vararg; str.__logic = 0;
# This lets the callback event figure out where to dispatch to pre-emptively by compiling a mask
# - this allows us to avoid many unnecessary string copies of buffer memory by avoiding if-logic
# Logic avoids using & and | operators to prevent strange syntax errors in altmacro mode (???)
  str.__logic = 0; str.__Altstr = 0; str.__Prefix=0
  ifalt; .if alt; str.__logic = str.__logic + str.__mAltstr; str.__Altstr = str.__mAltstr; .endif
  .if \self\().litmode; str.__logic = str.__logic + str.__mLitmem; .endif
  .irp m, \va;str.__logic = str.__logic + str.__\m;
    .ifc \m,mPrefix; str.__Prefix=str.__mPrefix;.endif; .endr



.endm; .macro str.__vacount, va:vararg
str.__vacount=0; .irp x, \va; str.__vacount = str.__vacount+1; .endr;
# str.__vacount simply counts the number of args in a group of varargs without popping anything

.endm; .macro str.__vachars, va:vararg
str.__vacount=0; .irpc c, \va; str.__vacount = str.__vacount+1; .endr
# like vacount, but counts chars instead of args




.endm; .macro str.__obj_.conc, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mStrio,mSuffix; .altmacro; .if str.__vacount>1
  str.__strbuf_quoteme \self, %str.__logic, \va; .else;   # enquote if multiple args are given
  str.__strbuf_dispatch \self, %str.__logic, \va; .endif  # leave as is if >= 1 args are given
  \self\().is_blank=0
  # - by passing to _quoteme variation, we attempt to wrap up arguments into a single arg
  # - .conclit can be used to handle multiple arguments differently
.endm; .macro str.__obj_.pfx, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mStrio,mPrefix; .altmacro; .if str.__vacount>1
  str.__strbuf_quoteme \self, %str.__logic, \va; .else
  str.__strbuf_dispatch \self, %str.__logic, \va; .endif
  \self\().is_blank=0
.endm; .macro str.__obj_.str, self, va:vararg
str.__logic \self,mRead,mStrio,mSuffix;.altmacro;str.__strbuf_commasuf \self, %str.__logic, \va
.endm; .macro str.__obj_.strq, self, va:vararg
str.__logic \self,mRead,mStrio,mPrefix;.altmacro;str.__strbuf_commapre \self, %str.__logic, \va
.endm; .macro str.__obj_.conclit, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mLitio,mSuffix; .altmacro; .if str.__vacount>1
  str.__strbuf_dispatch \self, %str.__logic,,\va; .else   # pass varargs if multiple arguments
  str.__strbuf_dispatch \self, %str.__logic,\va; .endif   # pass single arg if possible
  \self\().is_blank=0
  # - by passing a vararg, a space character must be generated on concatenation
  # - this is can be avoided by concatenating singular arguments instead of multiple arguments
.endm; .macro str.__obj_.pfxlit, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mLitio,mPrefix; .altmacro; .if str.__vacount>1
  str.__strbuf_dispatch \self, %str.__logic,,\va; .else   # pass varargs if multiple arguments
  str.__strbuf_dispatch \self, %str.__logic,\va; .endif   # pass single arg if possible
  \self\().is_blank=0
.endm; .macro str.__obj_.lit, self, va:vararg
str.__logic \self,mRead,mLitio,mSuffix;.altmacro;str.__strbuf_commasuf \self, %str.__logic, \va
.endm; .macro str.__obj_.litq, self, va:vararg;
str.__logic \self,mRead,mLitio,mPrefix;.altmacro;str.__strbuf_commapre \self, %str.__logic, \va
.endm; .macro str.__obj_.concitems, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mStrio,mSuffix; .altmacro;
  .if \self\().is_blank; .if str.__vacount>1
    str.__strbuf_quoteme \self, %str.__logic, \va; .else
    str.__strbuf_dispatch \self, %str.__logic, \va; .endif
  .else; .if str.__vacount>1
    str.__strbuf_quoteme \self, %str.__logic, , \va; .else
    str.__strbuf_dispatch \self, %str.__logic, , \va; .endif
  .endif;  \self\().is_blank=0
.endm; .macro str.__obj_.pfxitems, self, va:vararg
str.__vacount \va; str.__logic \self,mWrite,mStrio,mPrefix; .altmacro;
  .if \self\().is_blank; .if str.__vacount>1
    str.__strbuf_quoteme \self, %str.__logic, \va; .else
    str.__strbuf_dispatch \self, %str.__logic, \va; .endif
  .else;.if str.__vacount>1
    str.__strbuf_quoteme \self, %str.__logic, \va,; .else
    str.__strbuf_dispatch \self, %str.__logic, \va,; .endif
  .endif; \self\().is_blank=0


.endm; .macro str.__buildstrmem, self, strmem
# --- strmem - memory that is encapsulated in a quoted string
#  - str memory is safe from being interpreted accidentally as source literals
#  - str memory can be concatenated by either quoted or unquoted strings
#  - str memory can't contain quotation marks internally; only the external pair they are saved in
# For strmem, we only need to account for the correct quotation types with mAltstr
# - this creates 2 str copies per dispatch, from the necessary if logic
  \self\().litmode = 0; .purgem \self\().__strbuf_event
  .macro \self\().__strbuf_event, cb, a, va:vararg;
    .if str.__Altstr;
    str.__strbuf_event$\cb \self, <\a>, <\strmem>, \va; .else
    str.__strbuf_event$\cb \self, "\a", "\strmem", \va; .endif
  .endm

.endm; .macro str.__buildlitmem, self, pfxmem, concmem, litmem:vararg
# --- litmem - memory that makes no assumptions about quotes, and reads/writes literally
# For litmem, we need to concatenate 2 sets of varargs from separate macros
# We also need to re-quote on string passing
# - this creates a total of 8 str copies per dispatch, from the necessary if logic
  \self\().litmode = 1; .purgem \self\().__strbuf_event
  .macro \self\().__strbuf_event, cb, a, va:vararg
    .if str.__Altstr
      .if str.__Prefix
        .if \cb == 27
          str.__strbuf_event$\cb \self, <\a>, \va <\pfxmem\litmem\concmem>; .else
          str.__strbuf_event$\cb \self, <\a>, \va \pfxmem\litmem\concmem; .endif
      .else
        .if \cb == 19
          str.__strbuf_event$\cb \self, <\a>, <\pfxmem\litmem\concmem> \va; .else
          str.__strbuf_event$\cb \self, <\a>, \pfxmem\litmem\concmem \va; .endif
      .endif
    .else;
      .if str.__Prefix
        .if \cb == 11
          str.__strbuf_event$\cb \self, "\a", \va "\pfxmem\litmem\concmem"; .else
          str.__strbuf_event$\cb \self, "\a", \va \pfxmem\litmem\concmem; .endif
      .else
        .if \cb == 3
          str.__strbuf_event$\cb \self, "\a", "\pfxmem\litmem\concmem" \va; .else
          str.__strbuf_event$\cb \self, "\a", \pfxmem\litmem\concmem \va; .endif
      .endif; # extra if logic in litmem is required because of combined varargs
    .endif; # memory of buffer can only be distinguished in this scope, so some cases are added
  .endm; # - because of this, very large strmem buffers will be slightly faster than litmem buffers



.endm; .macro str.__strbuf_dispatch, self, cb, va:vararg
  .if nalt; .noaltmacro; .endif; \self\().__strbuf_event \cb, \va
  # dispatcher helps correct the literal copying method according to macro mode

.endm; .macro str.__strbuf_quoteme, self, cb, va:vararg
  .if nalt; .noaltmacro;
         \self\().__strbuf_event \cb, "\va"
  .else; \self\().__strbuf_event \cb, <\va>; .endif;
  # alternative to dispatcher passes quoted varargs - used in .conc and .pfx object methods

.endm; .macro str.__strbuf_commapre, self, cb, a, va:vararg
  str.__vacount \va; .if str.__vacount == 1; .ifb \va; str.__vacount = 0; .endif; .endif
  .if str.__vacount
    .if nalt; .noaltmacro;
           \self\().__strbuf_event \cb, "\a", \va,
    .else; \self\().__strbuf_event \cb, <\a>, \va,; .endif
  .else;
    .if nalt; .noaltmacro;
           \self\().__strbuf_event \cb, "\a"
    .else; \self\().__strbuf_event \cb, <\a>; .endif;
  .endif
.endm; .macro str.__strbuf_commasuf, self, cb, a, va:vararg
  str.__vacount \va; .if str.__vacount
    .if nalt; .noaltmacro;
           \self\().__strbuf_event \cb, "\a", \va
    .else; \self\().__strbuf_event \cb, <\a>, \va; .endif
  .else; .if nalt; .noaltmacro;
           \self\().__strbuf_event \cb, "\a"
    .else; \self\().__strbuf_event \cb, <\a>; .endif; .endif
  # special comma dispatchers isolate the first argument and enforce commas in the varargs



.endm; .macro str.__write_handle, str, method, va:vararg; \str\().\method \va
.endm; .macro str.__read_handle, str, method, cb, va:vararg
  str.__vacount \va; .if str.__vacount == 1; .ifb \va; str.__vacount=0; .endif; .endif
  .if str.__vacount; \str\().\method \cb, \va
  .else;           \str\().\method \cb; .endif
.endm; .macro str.__irpc_handle, str, q, m, va:vararg
  str str.irpc ".irpc char,"
  str.__vacount \va; .if str.__vacount == 1; .ifb \va; str.__vacount=0; .endif; .endif
  .if str.__vacount;
    .if \q;  \str\().litq str.irpc.conc; str.irpc.conc "; \m \va, \char; .endr"
    .else;   \str\().litq str.irpc.conc; str.irpc.conc "; \m \char, \va; .endr"; .endif
  .else;     \str\().litq str.irpc.conc; str.irpc.conc "; \m \char; .endr";  .endif
  str.irpc.lit
.endm; .macro str.__irp_handle, str, q, m, va:vararg
  str str.irp ".irp item,"
  str.__vacount \va; .if str.__vacount == 1; .ifb \va; str.__vacount=0; .endif; .endif
  .if str.__vacount;
    .if \q;  \str\().litq str.irp.conc; str.irp.conc "; \m \va, \item; .endr"
    .else;   \str\().litq str.irp.conc; str.irp.conc "; \m \item, \va; .endr"; .endif
  .else;     \str\().litq str.irp.conc; str.irp.conc "; \m \item; .endr";  .endif
  str.irp.lit


.endm; .macro str.__qrecurse_iter, m, str, va:vararg;
  \m "\str"; .ifnb \va; str.__qrecurse_iter \m, \va; .endif
.endm; .macro str.__qrecurse, va:vararg; ifalt;
  .if alt; str.__qrecurse_alt \va; .else; str.__qrecurse_nalt \va; .endif
.endm; .macro str.__qrecurse_alt, m, str, conc, va:vararg
  .ifnb \va; str.__qrecurse_alt \m, <\str\conc>, \va
  .else; \m "\str\conc"; .endif
.endm; .macro str.__qrecurse_nalt, m, str, conc, va:vararg
  .ifnb \va; str.__qrecurse_nalt \m, "\str\conc", \va
  .else; \m "\str\conc"; .endif
  # low level recursive macros for plugging convenient directive handlers, like .error and .ascii
  # - it quotes the outputs regardless of macro mode, as required by string directives
  # - it still needs to differentiate between modes to recursively concatenate them



# --- Callback Logic Map:
# 5-bools make an index between 0 and 31

.endm; .macro str.__strbuf_event$0, self,a,str,va:vararg # --- .conc    - "strmem"
# mWrite, mStrmem, mStrio, mSuffix, mNoalt
  str.__buildstrmem \self, "\str\a"

.endm; .macro str.__strbuf_event$1, self,a,str,va:vararg # ---   .str   - "strmem"
# mRead, mStrmem, mStrio, mSuffix, mNoalt
  \a "\str" \va

.endm; .macro str.__strbuf_event$2, self,a,va:vararg # --- .conc    - litmem
# mWrite, mLitmem, mStrio, mSuffix, mNoalt
  str.__buildlitmem \self,,"\a",\va

.endm; .macro str.__strbuf_event$3, self,a,va:vararg # ---   .str   - litmem
# mRead, mLitmem, mStrio, mSuffix, mNoalt
  \a \va

.endm; .macro str.__strbuf_event$4, self,a,str,va:vararg # --- .conclit - "strmem"
# mWrite, mStrmem, mLitio, mSuffix, mNoalt
  str.__buildlitmem \self,,\a,\str\va

.endm; .macro str.__strbuf_event$5, self,a,str,va:vararg # ---   .lit   - "strmem"
# mRead, mStrmem, mLitio, mSuffix, mNoalt
  \a \str \va

.endm; .macro str.__strbuf_event$6, self,a,va:vararg # --- .conclit - litmem
# mWrite, mLitmem, mLitio, mSuffix, mNoalt
  str.__buildlitmem \self,,\a,\va

.endm; .macro str.__strbuf_event$7, self,a,va:vararg # ---   .lit   - litmem
# mRead, mLitmem, mLitio, mSuffix, mNoalt
  \a \va

.endm; .macro str.__strbuf_event$8, self,a,str,va:vararg # --- .pfx     - "strmem"
# mWrite, mStrmem, mStrio, mPrefix, mNoalt
  str.__buildstrmem \self, "\a\str"

.endm; .macro str.__strbuf_event$9, self,a,str,va:vararg # ---   .strq  - "strmem"
# mRead, mStrmem, mStrio, mPrefix, mNoalt
  \a \va "\str"

.endm; .macro str.__strbuf_event$10,self,a,va:vararg # --- .pfx     - litmem
# mWrite, mLitmem, mStrio, mPrefix, mNoalt
  str.__buildlitmem \self,"\a",,\va

.endm; .macro str.__strbuf_event$11,self,a,va:vararg # ---   .strq  - litmem
# mRead, mLitmem, mStrio, mPrefix, mNoalt
  \a \va

.endm; .macro str.__strbuf_event$12,self,a,str,va:vararg # --- .pfxlit  - "strmem"
# mWrite, mStrmem, mLitio, mPrefix, mNoalt
  str.__buildlitmem \self,\a,,\va\str

.endm; .macro str.__strbuf_event$13,self,a,str,va:vararg # ---   .litq  - "strmem"
# mRead, mStrmem, mLitio, mPrefix, mNoalt
  \a \va \str

.endm; .macro str.__strbuf_event$14,self,a,va:vararg # --- .pfxlit  - litmem
# mWrite, mLitmem, mLitio, mPrefix, mNoalt
  str.__buildlitmem \self,\a,,\va

.endm; .macro str.__strbuf_event$15,self,a,va:vararg # ---   .litq  - litmem
# mRead, mLitmem, mLitio, mPrefix, mNoalt
  \a \va

.endm; .macro str.__strbuf_event$16,self,a,str,va:vararg # --- .conc    - "strmem", <ALTSTR>
# mWrite, mStrmem, mStrio, mSuffix, mAltstr
  str.__buildstrmem \self, <\str\a>

.endm; .macro str.__strbuf_event$17,self,a,str,va:vararg # ---   .str   - "strmem", <ALTSTR>
# mRead, mStrmem, mStrio, mSuffix, mAltstr
  \a <\str> \va

.endm; .macro str.__strbuf_event$18,self,a,va:vararg # --- .conc    - litmem, <ALTSTR>
# mWrite, mLitmem, mStrio, mSuffix, mAltstr
  str.__buildlitmem \self,,<\a>,\va

.endm; .macro str.__strbuf_event$19,self,a,va:vararg # ---   .str   - litmem, <ALTSTR>
# mRead, mLitmem, mStrio, mSuffix, mAltstr
  \a \va

.endm; .macro str.__strbuf_event$20,self,a,str,va:vararg # --- .conclit - "strmem", <ALTSTR>
# mWrite, mStrmem, mLitio, mSuffix, mAltstr
  str.__buildlitmem \self,,\a,\str\va

.endm; .macro str.__strbuf_event$21,self,a,str,va:vararg # ---   .lit   - "strmem", <ALTSTR>
# mRead, mStrmem, mLitio, mSuffix, mAltstr
  \a \str \va

.endm; .macro str.__strbuf_event$22,self,a,va:vararg # --- .conclit - litmem, <ALTSTR>
# mWrite, mLitmem, mLitio, mSuffix, mAltstr
  str.__buildlitmem \self,,\a,\va

.endm; .macro str.__strbuf_event$23,self,a,va:vararg # ---   .lit   - litmem, <ALTSTR>
# mRead, mLitmem, mLitio, mSuffix, mAltstr
  \a \va

.endm; .macro str.__strbuf_event$24,self,a,str,va:vararg # --- .pfx     - "strmem", <ALTSTR>
# mWrite, mStrmem, mStrio, mPrefix, mAltstr
  str.__buildstrmem \self, <\a\str>

.endm; .macro str.__strbuf_event$25,self,a,str,va:vararg # ---   .strq  - "strmem", <ALTSTR>
# mRead, mStrmem, mStrio, mPrefix, mAltstr
  \a <\str> \va

.endm; .macro str.__strbuf_event$26,self,a,va:vararg # --- .pfx     - litmem, <ALTSTR>
# mWrite, mLitmem, mStrio, mPrefix, mAltstr
  str.__buildlitmem \self,<\a>,,\va

.endm; .macro str.__strbuf_event$27,self,a,va:vararg # ---   .strq  - litmem, <ALTSTR>
# mRead, mLitmem, mStrio, mPrefix, mAltstr
  \a \va

.endm; .macro str.__strbuf_event$28,self,a,str,va:vararg # --- .pfxlit  - "strmem", <ALTSTR>
# mWrite, mStrmem, mLitio, mPrefix, mAltstr
  str.__buildlitmem \self,\a,,\va\str

.endm; .macro str.__strbuf_event$29,self,a,str,va:vararg # ---   .litq  - "strmem", <ALTSTR>
# mRead, mStrmem, mLitio, mPrefix, mAltstr
  \a \va \str

.endm; .macro str.__strbuf_event$30,self,a,va:vararg # --- .pfxlit  - litmem, <ALTSTR>
# mWrite, mLitmem, mLitio, mPrefix, mAltstr
  str.__buildlitmem \self,\a,,\va

.endm; .macro str.__strbuf_event$31,self,a,va:vararg # ---   .litq  - litmem, <ALTSTR>
# mRead, mLitmem, mLitio, mPrefix, mAltstr
  \a \va

.endm
.endif