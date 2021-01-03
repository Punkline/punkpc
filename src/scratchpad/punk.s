#### Punkline tools ################################################################################
# -- purgem -- macro purger object -----------------------------------------------------------------
# Method "purgem" may be used to purge macros like the .purgem directive, but with state memory
# You may be explicit about what the internal state of an initial *.purgem property (0 or 1)
# You may use purgem like a vararg macro

# METHODS   : purgem
# PROPERTIES: purgem, *.purgem

#  METHOD: purgem - purge macro
# May be used to purge macros like the .purgem directive, but with state memory
# May also be used to inquire about the purgable state of a macro, instead of purging it outright

#  purgem macro, [check]
#   macro  : STR   : the name of a macro that will be defined soon after this method call
purgem.c=0;purgem.s=0;purgem.p=0;purgem.v=0;purgem.d=1;purgem.op=-1

.macro purgem.s, va:vararg
  purgem.c=0;  purgem.s=0;  purgem.p=0
  purgem.s.iter \va
  purgem.op=purgem.op+1
.endm
.macro purgem.s.iter, a, va:vararg
  .ifnb \a
    purgem.\a = 1
    purgem.s.iter \va
  .endif
.endm
.macro purgem.d, v
  .if purgem.d
    purgem.v=\v
  .endif
.endm
.macro purgem.op, op, op2
  purgem.op = -1
  purgem.op.iter \op, \op2
.endm

.macro purgem.op.iter, op, op2, i
  .ifnb \op;
    .rept 1  # rept lets us exit block with .exitm, like nested else; ifc; blocks
      .ifc "\op", "0";  purgem.v=0;   purgem.d=0;     .exitm;  .endif  # value v = 0
      .ifc "\op", "1";  purgem.v=1;   purgem.d=0;     .exitm;  .endif  # value v = 1
      .ifc "\op", "=";  purgem.d 0;   purgem.s s;     .exitm;  .endif  # set state=v
      .ifc "\op", "?";  purgem.d 1;   purgem.s c;     .exitm;  .endif  # check ndef?(init=v)
      .ifc "\op", "!";  purgem.d 0;   purgem.s c p;   .exitm;  .endif  # check and purge
      .ifc "\op", ".";  purgem.d -1;  purgem.s p;     .exitm;  .endif  # purge (stateless)
    .endr;   .ifeq \i;  purgem.op.iter \op2,,1;  .endif  # call self once to handle tuple pair
  .endif;  purgem.d=1  # reset defaults flag for next op tuple
.endm


.macro purgem, macro, va:vararg;   purgem.s c s p;  purge.v=1;   .ifnb \va;  purgem.iter \va;  .endif;  purgem.iter.state \macro;  .endm

.macro purgem.iter, a, b, va:vararg
  .ifnb \a;  purgem \b \va
    purgem.op \a, \b
    .ifgt purgem.op;  purgem.iter.state \a;  .endif
    # if only \b is op, then \a is a macro vararg
    # else, op was interpreted in both \a and \b; so we just skip this iteration to read next \a
  .endif
.endm

.macro purgem.iter.state, macro
    .if purgem.c;  ifndef \macro\().purgem;   purgem.s=1;  .exitm;.endif.endif         # check
    .if purgem.p;  .purgem \macro;   .iflt purgem.v; purgem.s=0;  .exitm.;endif;.endif # purge
    .if purgem.s;  \macro\().purgem = purgem.v;  .exitm;.endif                         # state
.endm






# rewriting this ....
.macro purgem.iter, state, macro, a, va:vararg
.ifnb \a;
  .ifc "\a", "0";  purgem.iter 0 \macro, \va;  .exitm;  .endif
  .ifc "\a", "1";  purgem.iter 1 \macro, \va;  .exitm;  .endif
  .ifc "\a", "?";  purgem=0
    .ifdef \macro\().purgem;  .if \macro\().purgem;  purgem=1;  .endif;  .endif;  .exitm;
  .endif
  .ifndef \macro\().purgem
    \macro\().purgem = \state
  .endif
  .if \macro\().purgem
    .purgem \macro
  .endif
  \macro\().purgem = 0

  purgem.iter \

.endif
.endm

.macro purgem, macro, check
  .ifc "\check", "?"
    purgem=0
    .ifdef \macro\().purgem
      .if \macro\().purgem;  purgem=1;  .endif
    .endif
    .exitm
  .endif
  .ifdef \macro\().purgem
    .if \macro\().purgem;  .purgem \macro;  .endif
  .endif
  \macro\().purgem = 0
.endm







# -- em -- emitter object --------------------------------------------------------------------------
# Emits string literals (like assembler directives, powerpc instructions, macro definitions, etc)
# Can instantiate new methods of emitting literals from a sequence of arguments.
#
#  METHODS   :  em  em.l  em.l  em.comp  em.va  em.new  em.new.builder
#  PROPERTIES:  em


#  METHOD: em - Emit Literals (Concatenated by Spaces)
# Emit string literals without requiring quotation marks.
# When varargs encounter a null (,,) a newline is (;) is emitted
#  em [l, ...]
#   l     : STR   : varargs are concatenated with spaces, so quotes are not required


#  METHOD: em.l - Emit Literal and Update
# Emit and concatenate literal string with optional prefix/suffix, if not blank
# Updates the em property to reflect whether or not emission was omitted.
#  em.l [l]
#   l     : STR    : optional string literal
#                    omitting causes no emission, allowing for nulls
# - SETS:
#  em.l   : BOOL   : self keeps record of whether or not last emission was blank
#                     (this does not check if suffix or prefix is blank)
#                    0 = BLANK;   else = NOT BLANK


#  METHOD: em.l - Emit Literal (Fast, No Update or Concat)
# Same as em.l "Emit Literal" -- but skips the check, update, and concatenation
# This may be necessary for emitting some types of directives.
#  em.l [l]
#   l     : STR    : optional string literal
#                    omitting causes no emission, allowing for nulls


#  METHOD: em.vaf - Emit Literal vararg (Fast, No recursion)
# Quickly emit the remaining varargs in a recursive parse without more recursion
#  em.va [l, ...]
#   va    : VARARG : optional string literal(s)
#                    omitting causes no emission, allowing for nulls


#  METHOD:  em.comp
# Passes a individual strings of compacted varargs to em.
# Compacted varargs must be encapsulated in quotation marks.
#  em [comp, ...]
#   comp  : STR  : varargs compacted into single strings





#  METHOD: em.new - New Emitter Type
# Construct additional emitter methods using with argument strings
#  em.new [name, proc, ops]
#   name  : STR     : name of this emitter op
#   proc  : STR     : literals describing a parse operation, or macro call
#   ops   : STR     : other emitter type names that can be parsed in this emitter type


#  METHOD: em.new.builder - New Emitter Type (recursive op condition builder)
# Helper for em.new
#  em.new.building [str, proc, op, ... ]
#   str   : STR     : used to concat literals together as builder builds macro
#   proc  : STR     : saved from em.new argument
#   op    : STR     : the name of another type that can be parsed like an opcode name in built macro
#   va    : VARARG  : other ops that need to be given .ifc conditions

.ifndef em.basic.init; em.init = 0; .endif

.ifeq em.basic.init
.macro em.pls, l, p, s;  .ifnb \l; em.l=1; em.l "\p\l\s";  .else; em.l=0;  .endif;  .endm; em=0
.macro em.l, l;\l;.endm
.macro em, a, b, va:vararg; .ifnb \b;  em "\a \b ", \va; .exitm; .endif; em.l "\a ;";  .ifnb \a; em \va; .endif; .endm
.macro em.vaf, va:vararg;\va;.endm
.macro em.comp, comp, va:vararg;  .ifnb \comp; em \comp; .endif;  .ifnb \va; em.comp \va; .endif;  .endm

.macro em.commas, prefix, a, b, va:vararg
  .ifnb \b; em.commas "\prefix \a,", \b \va
  .else;    em.l "\prefix \a"
  .endif
.endm

.macro em.new, name, proc="em.\name\().hlpr \a \b \c \d \va", ops=""
  .ifnb \ops; em.new.builder ".irpc ch, \op;  .ifc \ch, .; "
  .else; em.new.builder "", \name, \proc, \ops
  .endif
.endm

.macro em.new.builder, str, n, p, op, varg:vararg
.endm


em.new b
.macro em.b.hlpr, a, b, c, d, va:vararg
  em.l \a ".byte "; em.b \b \c \d \va
.endm

em.b 1 2 3 4





# --- rewriting this....
.macro em.new.building, str, n, p, op, varg:vararg
  .ifnb \op;  em.new.building ".ifc .\a, \op;  em.\op \b \c \d \va ;  .exitm;  .endif; " /*
  */, \n, \p, \varg
  .else;  em.mac " .macro em.\n, a, b, c, d, va:vararg;  .irpc c, \a;  .ifc \c, . ; \str .endif;  .endr;  .if em.exiting; .exitm; .endif; \p ; em.exiting = 1; .endm "
  .endif
.endm

em.new b, ".byte \a ; em.b \b \c \d \va ", l
# em.new l, ".long \a; em.l \b \c \d \va ", b

em.b 1 2 3


.macro em.l, l;  \l;  .endm  # helper for chars limited by input syntaxes, such as semicolons ';'
.macro em.opbuilder, op, prefix, suffix
.macro em.opbuilder.build, l, i, o, idefault=" ", od="lw, ls"


.macro em.ls, l, va:vararg; em.l "\l;";  .ifnb \va;  emitva \va;  .endif;  .endm
.macro em.lw, l, va:vararg; em.l "\l ";


# mac -- a wrapper for small 1-line macros
.macro mac, margs, va:vararg;  .macro \margs; emitva \va; .endm; .endm
mac "mymac, x=1", nop nop ".long 0", "blrl", nop nop "subfic r3, r4, 0"
mymac


# alt -- creates a wrapper around a macro call for the .altmacro mode
# This is an object, with attribute properties and methods

.macro alt

.macro alt.save;
  .ifc %0, "0";  alt.save=1;  .else; alt.save=0; .endif
  .ifeq alt.depth;  alt.save.root=alt.save; .endif;
.endm
# alt.save inquires about the current macro state using an expression string %0
# if in altmacro mode, alt.save=1; else=0;
# if alt.depth is 0, then alt.save.root copies this saved state for restoring again at 0

.macro alt.open;  alt.depth = alt.depth + 1;  alt.save
.endm
.macro alt, va:vararg;
.ifeq alt.depth; .altmacro; alt.depth = depth+1

.macro mac, def, va:vararg;

.macro makeif, name, type

.macro makeif, name, va:vararg
  .macro if\name, x, l, else
    .ifnb \else;  .if\name \x;  \l;  .else;  \else;  .endif
    .else;  .if\name \x;  \l;  .endif
    .endif;  .endm; .ifnb \va; makeif \va; .endif
.endm;  makeif eq gt lt ge le ne b nb def ndef " "
.macro makeifc, name, va:vararg
  .macro if\name, c, str, l, else
    .ifnb \else;  .if\name \c , \str ;  \l;  .else;  \else;  .endif
    .else;  .if\name \c , \str ;  \l;  .endif
    .endif;  .endm;  .ifnb \va; makeif \va; .endif
.endm;  makeifc c nc
# shortcuts for if statements have been generated
# if eq gt lt ge le ne b nb def ndef c nc

.macro mac, margs, line, va:vararg
.err "\margs \line \va"
  .macro \margs
    \line
    ifnb \va, "mac.va \va"
  .endm
.endm
.macro mac.va, line, va:vararg
  \line
  ifnb \va, "mac.va \va"
.endm
# shortcut for making macros

mac alt.open, .altmacro "alt.depth = alt.depth + 1"
mac alt.close, "alt.depth = alt.depth - 1;  ifeq alt.depth; .noaltmacro"
mac "alt, l, va:vararg", ifnb \l, "alt.openalt.va \va", alt.close
mac "alt.va, l, va:vararg" \l, ifnb \va, "alt.va \va"


# Object Symbols
# - object symbols can be used as both a value and a macro
# - they use a namespace that can be appended to create attribute objects

.macro obj, name, property=0, method=0, margs=0, parent
  ifnc \method 0 "mac \parent\name\, \margs \method"
  \parent\name = \property
.endm


# --- End of Punkline Tools ---















# --- MCM printline experiments



alt.depth = 0; .macro alt, mac; .altmacro; \mac; .noaltmacro; .endm
.macro alt.open;  alt.depth=alt.depth+1; .ifgt alt.depth; .altmacro; .endif; .endm
.macro alt.close; alt.depth=alt.depth-1; .ifle alt.depth; alt.depth=0; .noaltmacro; .endif; .endm

# alt.* -- altmacro utilities
# - altmacro contexts change the way macros are called by your ASM
# - the alt module lets you create easy-to-use wrappers for creating altmacro contexts

# internal class object properties:

# alt  (input lines separated by ';' chars)
# - altmacro wrapper; a shortcut for putting something small in an altmacro context
# EX:           alt   myMacro  <str arg>, numexps, %numexps
# equiv:              myMacro  "str arg", numexps, "03"
# equiv:   alt.open;  myMacro  <str arg>, numexps, %numexps;  alt.close

# alt.open
# alt.close
# - alt.open and alt.close mutate alt.depth, creating tags for alt.depth to keep track of
# - .altmacro and .noaltmacro are hidden behind these methods to relate them to alt.depth

# ---

.macro ___exlab, lab, %ex, va:vararg; .ifnb \va; ___exlab \lab\ex \va; .else; \lab = \exp; .endif .endm
.macro exlab va:vararg; altm "___exlab <> \va"; .endm


# exlab substr, [%ex, %ex, ...], %val
# - expression label (not to be confused with label expressions)
# - each given expression %ex is interpreted and converted into a string and concatenated to \lab
# - final \lab\ex\ex\... name is then given the value %val
# EX:




.macro sx, str
  .altmacro
  v = 0; i = 0
  .irpc c, \str
    i = i ^ 1
    .if i; test <\c>
    .else; test <\c>; .byte v; v=0
    .endif
  .endr
  .noaltmacro
.endm

.macro test c, str
  v = v<<4 | 0x\c
.endm

# .altmacro
sx 0123456789ABCDEF0123456789abcdef
# .noaltmacro
# .macro altm, mac; .altmacro; \mac; .noaltmacro; .endm
# altm "sx 0123456789ABCDEF0123456789abcdef"





# .macro xlab, lab, ex, va:vararg
#    ___xlab \lab %ex \va
# .endm
# .macro ___xlab, lab, ex, ex2, va:vararg
#   .ifnb \va
#     ___xlab \lab\ex %ex2 \va
#   .else; \lab\ex\() = \ex2;
#    #.error "\lab\ex = \ex2" # uncomment for test message
#   .endif
# .endm
# .macro altm, mac; .altmacro; \mac; .noaltmacro; .endm
#
# i = -1
# .rept 20; i = i + 1
# altm "xlab x i i i"
# .endr
#
#
# .macro altmtest
# altm "xlab x i i i"
# .endm
#
#
# .macro xlab, str, expr, value, va:vararg;
#   xlab.iter \str, \value, %expr, \va;
# .endm
#
# .macro xlab.iter, str, v, x, s, nx, ns, va:vararg
#   .ifb \s;
#     .ifb \x; \str = \v;
#       #.ifdef xlab.debug;
#       #  .if xlab.debug;
#       #   .error "\str = \v";
#       #  .endif;
#       #.endif;
#       .exitm;
#     .endif
#   .endif
#   .ifnb \nx; xlab.iter "\str\x\s\()", \v, %nx, \ns, \va;
#   .else; xlab.iter "\str\s\()", \v,, \ns, \va;
#   .endif
# .endm
#
# .altmacro
# xlab test 0 1


# .macro concat, margs, va:vararg;  concat.ws=0;  concat.exp=0;  concat.alt=0; concat.exp=0; .ifc "0", %0; concat.alt=1; .endif; concat.str "\margs", \va; .endm
# .macro concat.exp  m, s, x, n2, n3, va:vararg; concat.exp=0; concat.str \m, \s, %x, \n2, \n3, \va; .endm
# .macro concat.str, m, s, x, n2, n3, va:vararg;  .noaltmacro
#   .ifb \x
#     .ifb \n2
#       .ifb \n3;  .if concat.alt; .altmacro; .exitm; .endif;  \m "\s" \va; .exitm; .endif
#       concat.ws = 2; concat.str "\m", "\s", "\n3", \va;  .exitm;  .endif
#     concat.ws = 1; concat.str "\m", "\s", "\n2", "\n3", \va;  .exitm;
#   .else
#     .irpc c, "\x";  .ifc "\c", "("; concat.exp=1; .endif; .exitm;  .endr
#     .if concat.exp  # if arg is in parentheses, then interpret it like a sub-expression
#       .altmacro; concat.exp \m, \s, \x, \n2, \n3, \va
#     .else  # else, concat string
#       .if     concat.ws == 0; concat.str "\m", "\s\x", "\n2", "\n3", \va
#       .elseif concat.ws == 1; concat.str "\m", "\s \x", "\n2", "\n3", \va
#       .elseif concat.ws == 2; concat.str "\m", "\s; \x", "\n2", "\n3", \va
#       .endif; concat.ws = 0
#     .endif
#   .endif
# .endm
#
# .macro test, x, va:vararg; .ifnb \x; .byte 0x\x; test \va; .endif; .endm
#
# 0: test a b c d e f 0 1 2 3 4 5 6 7 8 9
# concat .error, "length=",, (.-0b),, bytes
#
# i=1
# concat .error, test,, (i)















.macro purgem.op.iter, op, op2, i
  .ifnb \op;
    .rept 1  # rept lets us exit block with .exitm, like nested else; ifc; blocks
      .ifc "\op", "0";  purgem.v=0;   purgem.d=0;     .exitm;  .endif  # value v = 0
      .ifc "\op", "1";  purgem.v=1;   purgem.d=0;     .exitm;  .endif  # value v = 1
      .ifc "\op", "=";  purgem.d 0;   purgem.s s;     .exitm;  .endif  # set state=v
      .ifc "\op", "?";  purgem.d 1;   purgem.s c;     .exitm;  .endif  # check ndef?(init=v)
      .ifc "\op", "!";  purgem.d 0;   purgem.s c p;   .exitm;  .endif  # check and purge
      .ifc "\op", ".";  purgem.d -1;  purgem.s p;     .exitm;  .endif  # purge (stateless)
    .endr;   .ifeq \i;  purgem.op.iter \op2,,1;  .endif  # call self once to handle tuple pair
  .endif;  purgem.d=1  # reset defaults flag for next op tuple
.endm


.macro purgem, macro, va:vararg;   purgem.s c s p;  purge.v=1;   .ifnb \va;  purgem.iter \va;  .endif;  purgem.iter.state \macro;  .endm

.macro purgem.iter, a, b, va:vararg
  .ifnb \a;  purgem \b \va
    purgem.op \a, \b
    .ifgt purgem.op;  purgem.iter.state \a;  .endif
    # if only \b is op, then \a is a macro vararg
    # else, op was interpreted in both \a and \b; so we just skip this iteration to read next \a
  .endif
.endm

.macro purgem.iter.state, macro
    .if purgem.c;  ifndef \macro\().purgem;   purgem.s=1;  .exitm;.endif.endif         # check
    .if purgem.p;  .purgem \macro;   .iflt purgem.v; purgem.s=0;  .exitm.;endif;.endif # purge
    .if purgem.s;  \macro\().purgem = purgem.v;  .exitm;.endif                         # state
.endm

# -- str -- string objects ------------------------------------------------------------------
# str objects are actually macros that contain default arguments that act as abstract properties
# As macros, str objects have strange interface requirements:
#  - (name).set macro may be used to set or concatenate a new string
#    - to concatenate, you must omit the str argument by using keywords or positional nulls ",,"
#  - (name) macro may be used to give its saved string to another macro in the form of an argument

# METHODS    : (name), (name).set
# ABSTRACT PROPERTIES: (default string) (internalized name)

# -- str builder ---
# str objects are built by the "str" method
# - str may be used to create a new string by the name of (name) with the string value of (s)
#  - if "name" already exists,

# METHODS   : str, str.rebuild
# DEPENDANCIES: purgem

.macro str, name, s
  purgem \name\().set ?
  .if purgem; \name\().set,, "\s"
  .else; str.rebuild \name,, "\s"
  .endif
.endm

.macro str.rebuild n, p, st, s
  purgem \n\().set
  .macro \n\().set, prefix, str="\p\st\s", suffix
    purgem \n
    .macro \n, string="\prefix\str\suffix", cont, va:vararg
      \cont "\string" \va
    .endm
  .endm
  \n\().set
.endm


# str test "hello "
# str test " world!"
# test, .error




.macro is.string, s
# requires alt macro mode
  is.string=0         # bool is true if quoted and not blank
  is.stringorblank=0  # bool is true if quoted or blank
  .ifb \s; is.stringorblank=1; .exitm; .endif
  .irpc c, "\s";
    .ifc \c\c, ""; is.string=1; .endif;
    .exitm
  .endr
  is.stringorblank=is.stringorblank|is.string
.endm
.macro is.altstring, s:vararg
# requires noalt macro mode
  is.altstring=0     # bool is true if 1st char is <
  .irpc c, \s
    .ifc "\c", "<"; is.altstring=1; .endif
    .exitm
  .endr
.endm
.macro is.nestedstring, s
# requires noalt macro mode
  is.nestedstring=0
  is.altstring \s
  .if is.altstring; .altmacro; is.string \s; .noaltmacro
    .if is.string; is.nestedstring=1; .endif
  .endif
.endm


# .altmacro
# is.string "is this a quoted string?"
# .long is.string, is.stringorblank
# # >>> 00000001 00000001
# is.string this?
# .long is.string, is.stringorblank
# # >>> 00000000 00000000
# is.string
# .long is.string, is.stringorblank
# # >>> 00000000 00000001
#
# .noaltmacro
# is.altstring <is this an altstring?>
# .long is.altstring
# # >>> 00000001
# is.altstring "how about this?"
# .long is.altstring
# # >>> 00000000
# is.altstring "<also detects altstring nested in strings>"
# .long is.altstring
# # >>> 00000001
# is.nestedstring <"this version detects strings nested in altstrings">
# .long is.nestedstring
# # >>> 00000001




.macro str.length, set="str.length", str; \set = 0; .irpc c, "\str"; \set = \set + 1; .endr; .endm
# allows you to set input symbol (or self property, if blank) to length value of given string



.macro str.i, sub, string, start=0, end=0x7FFFFFFF, limit=0
# substring \sub is searched for in \string, starting at \start, ending at \end
# number of matches is limited to \limit, before termination
# - if \limit is <= 0 then count is unlimited; else count is limited
# - if (signed) \end is larger than \string length, then length is used instead of \end
# - if \start or \end arguments are negative, they become offsets from the end \string length
# - if count is limited, then length property only updates with the number of chars parsed

  str.length str.j.length "\sub";
  str.i=-1;
  str.j=-1;
  str.i.exitm=0;
  str.i.first=-1;
  str.i.part=0;
  str.j.part=0;
  str.i.last=-1;
  str.i.count=0;
  str.i.start=\start;
  str.i.end=\end;
  str.i.limit=\limit;
  str.i.length=0
  # property states are initialized

  .iflt str.i.start
    str.length str.i.length "\string"; str.i.start = str.i.length + str.i.start
  .endif  # if \start is negative, then get length, set = \start + length
  .iflt str.i.end; .ifeq str.i.length; str.length str.i.length "\string"; .endif
    str.i.end = str.i.length + str.i.end
  .endif  # if \end is negative, then (if length is null, then get length) set = \end + length
  .irpc i, "\string";  str.i = str.i + 1
    .ifgt (str.i - str.i.end);  .exitm;  .endif
    .ifge (str.i - str.i.start); str.j = -1
    # while str.i >= start, and str.i < end ...
      .irpc j, "\sub";  str.j = str.j + 1
        .ifeq (str.j - str.j.part)
          # if str.j == str.j.part ...
          .ifc \i, \j
            # if matching char ...
            .ifeq str.j.part;  str.i.part = str.i;  .endif
            str.j.part = str.j.part + 1
            # update "*.part" properties to save index of partial matches
          .else; str.j.part = 0; .exitm
          .endif # reset str.j.part on mismatches
          .ifeq (str.j.part - str.j.length)
            # if matching substr ...
            str.j.part = 0
            .ifeq str.i.count;  str.i.first = str.i.part;  .endif
            str.i.count = str.i.count + 1
            str.i.last = str.i.part
            # update values to record match range
            .ifeq (\limit - str.i.count); str.i.exitm = 1; .endif
            # trigger exit if count limit has been reached
          .endif
        .exitm
        .endif
      .endr
      .if str.i.exitm;  .exitm;  .endif
      # "str.i.exitm" is a flag for triggering exit condition in primary loop
    .endif
  .endr
  .ifeq str.i.length;  str.i = str.i + 1;  .endif
  # update str.i to reflect amount of characters parsed, if true length wasn't recorded
.endm
# str.i "na", "Banana"
# .byte str.i.first, str.i.last, str.i.count, str.i.limit, str.j.length, str.i.length, str.i.part

.macro str.indexof, sub, string, start=0, end=0x7FFFFFFF, limit=1
  str.indexof = -1
  str.i "\sub", "\string", \start \end \limit
  str.indexof = str.i.last
.endm  # method of str.i limits to 1 by default, and sets self property to index of last found
# str.indexof "na", "Banana"
# .long str.indexof, str.i.length

.macro str.contains, sub, string, start=0, end=0x7FFFFFFF, limit=0
  str.i "\sub", "\string", \start \end \limit
  str.contains = str.i.count
.endm  # method of str.i sets self property to number of matches found, for convenient bool name
# str.contains "na", "Banana"
# .long str.contains, str.i.length

# str.contains "Desc", "JObjDesc"
# .if str.contains;  loadDesc=1; .else;  loadDesc=0;  .endif





.macro str.extract, m, logic, filter, trim, str, start, end, va:vararg
  str.extract.trimmem=-1;  str.extract.iter "\m", \logic, "\filter", "\trim", "", "", "", "\str", 0, \start, \end, \va
  str.extract = str.extract.i + 1
.endm

.macro str.extract.iter, m, logic, filter, trim, pre, ext, post, str, i, s, e, va:vararg
  str.extract.i=-1;  str.extract.exitm=0;  str.extract.t=-1
  .irpc c, "\str"; str.extract.i = str.extract.i + 1
  # for each character in \str, i+=1
    .if str.extract.i >= \i
      str.extract.filter=0
      str.extract.trim=-1
      # if i >= argument i; then check for filter
      .irpc f, "\filter"
        .ifc "\f", "\c"; str.extract.filter= 1; .exitm
        .else; str.extract.filter = 0
        .endif

      .endr

      .if str.extract.filter ^ \logic
        str.extract.iter "\m", \logic, "\filter", "\trim", "\pre", "\ext", "\post", "\str", \i+1, \s, \e, \va
        # skip char if it's part of the filter
      .else
        .irpc t, "\trim"; str.extract.t = str.extract.t + 1
          .ifc "\t", "\c"; str.extract.trim = str.extract.t; .exitm;
          .endif
        .endr

        .if str.extract.trim != -1;
          .if str.extract.trimmem != str.extract.trim
            str.extract.trimmem = str.extract.trim
          .else; str.extract.iter "\m", \logic, "\filter", "\trim", "\pre", "\ext", "\post", "\str", \i+1, \s, \e, \va; .exitm
          # skip char if trim has been activated for the same char multiple times
          .endif

        .else; str.extract.trimmem=-1
        # else, if not trimming; then reset trim memory
        .endif

        .if \i < \s
          str.extract.iter "\m", \logic, "\filter", "\trim", "\pre\c", "\ext", "\post", "\str", \i+1, \s, \e, \va
          # concat to pre if < \s start
        .elseif \i < \e
          str.extract.iter "\m", \logic, "\filter", "\trim", "\pre", "\ext\c", "\post", "\str", \i+1, \s, \e, \va
          # else concat to ext if < \e end
        .else
          str.extract.iter "\m", \logic, "\filter", "\trim", "\pre", "\ext", "\post\c", "\str", \i+1, \s, \e, \va
          # else concat to post
        .endif

        .exitm
      .endif

    .endif

  .endr

  .if str.extract.exitm; .exitm
  .else; \m "\pre", "\ext", "\post", \va ; str.extract.exitm=1
  .endif

.endm

# .macro test, a, b, c; .error "pre= \a  extract= \b  post= \c"; .endm
# str.extract test, 1, "abf", "a", "aaabbbcccdddeeefff", 3, 6




.macro str.replace, m, key, rep, str, va:vararg; str.replace.iter "\m", "\key", "\replace", "\str", \va; .endm
.macro str.replace.extract, pre, ex, post, res, m, k, r, s, va:vararg; str.replace.iter "\res\pre\k", "\m", "\k", "\r", "\post"; .endm
.macro str.replace.iter, res, m, k, r, s, va:vararg
  .ifnb \s
    str.indexof "\k", "\s"
    .if str.indexof>=0
      str.extract str.replace.extract, 0, "", "", "\s", str.indexof, str.indexof+str.j.length, "\res", "\m", "\k", "\r", "\s", \va
    .else
      str.replace.iter "\res\s", "\m",,,, \va
    .endif
  .else; \m "\res", \va
  .endif
.endm



.macro str.exp, va:vararg; .altmacro; str.exp.alt \va; .endm
.macro str.exp.alt, e, va:vararg; str.exp.noalt %e, \va; .endm
.macro str.exp.noalt, e, m, va:vararg; .noaltmacro; \m "\e", \va; .endm
# .macro test, e, a, b; .error "\a\e\b"; .endm
# str.exp (16) test "value = ", " -- also 'Hello World'"

.macro str.concat, margs, va:vararg; str.concat.x=0; str.concat.alt=0; str.concat.ws=1; .ifc "0", %0; str.concat.alt=1; .endif; .noaltmacro; str.concat.va "\margs", \va; .endm
.macro str.concat.x, e, m, s, va:vararg; str.concat.va "\m", "\s", "\e", \va; .endm
.macro str.concat.va, m, s, s1, s2, s3, va:vararg
  str.concat.x=0
  .ifb \s1  # if 1 null is found
    .ifb \s2  # if 2 nulls are found
      .ifb \s3  # if 3 or more nulls are found
        .if str.concat.alt;
        .altmacro; .ifb \va; \m \s; .else; \m \s, \va; .endif; .exitm
        # if staying in alt, do not use quotes;  if no va, then use no comma after \s

        .else; .ifb \va; \m "\s"; .else; \m "\s", \va; .endif; .exitm
        # else, use quotes;  if no va, then use no comma after \s
        .endif
      .endif

    str.concat.ws = 2; str.concat.va "\m", "\s", "\s3", \va; .exitm;
    # if 2 nulls are found, ws is set to 2 to generate a newline semi-colon on next concat
    .endif

  str.concat.ws = 0; str.concat.va "\m", "\s", "\s2", "\s3", \va; .exitm
  # if 1 null is found, ws is set to 0 to generate no whitespace on next concat
  # if no nulls are found, ws is left alone (1 by default generating a space on next concat)

  .else  # if no nulls in s1, s2, s3
    .irpc c, "\s1"; .ifc "\c", "(";  str.concat.x=1; .endif; .exitm; .endr
    # str.concat.x is true if first character of s1 is "("

    .if str.concat.x;  .altmacro;  str.exp \s1 str.concat.x "\m", "\s", "\s2", "\s3", \va
      # use str.exp to evaluate expressions contained in parentheses

    .else
      .if     str.concat.ws==0; str.concat.ws=1; str.concat.va "\m", "\s\s1", "\s2", "\s3", \va
      .elseif str.concat.ws==1; str.concat.ws=1; str.concat.va "\m", "\s \s1", "\s2", "\s3", \va
      .elseif str.concat.ws==2; str.concat.ws=1; str.concat.va "\m", "\s; \s1", "\s2", "\s3", \va
      .endif;
    .endif
  .endif
.endm
stacknum=10; rIndex=31; xIndex=0x80; rBase=30
str.concat .error Hello "world,", "str.concat.ws =", (str.concat.ws),,, stack_element_,, (stacknum), is ready,,, lwz r,,(rIndex),,",", (xIndex),,"\(r",,(rBase),,")",,, nop





.macro str.parser, key, patstart, pat, patend, margs, va:vararg
.macro str.parser.va, res, key,pre,post,str, a,b,c,d, pat0,pat1,pat2, margs, va:vararg
# res = result string -- compounds all strings in parse using patterns
  # for each string
    # if index of key in str
    # extract pre and post
    # explode args
    # if only pat0; then the str is discarded after single match
    # if only pat1; then the pattern is used for each match found in str
    # if only pat2; then the pattern is used only for the last match
    # if pat0 and pat1; use pat0 on first, then pat1 on subsequent matches
    # if pat1 and pat2; use pat1 on each, then pat2 only on last match
    # if pat0 and pat2; use pat0 on first, and pat2 on last
    # if pat0, pat1, pat2; use 0 on first, 1 on each, 2 on last
    # patterns may use special escape variables + literal string characters:
    # \str \pre \key \post \a \b \c \d
.endm



.macro is.num, s; is.num=0; .irpc c, "\s"; .irpc i, "-0123456789+"; .ifc "\c", "\i"; is.num=1; .endif; .endr; .exitm; .endr; .endm;
# 'is.num' makes an educated guess as to whether or not a given input is a literal number
# positive and negative numbers can be identified, but subexpressions and variables cannot



# --- Enumeration Macros and Symbols
.macro enum, base=enum, incr=1, va:vararg; enum.f \base, \incr, "", "", \va; enum=enum.f; .endm;
.macro enum.f, e=enum.f, i=1, p, s, name, va:vararg; .ifnb \name; \p\name\s=\e; .ifne enum.debug; enum.debug, \p\name\s; .endif; enum.f \e+\i, \i, \p, \s, \va; .else; enum.f=\e; .endif; .endm; enum=0;enum.f=0;enum.debug=0;
.irpc c, rfp; enum.f 0, 1, \c,, /*
*/,  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15/*
*/, 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; .endr
lt=0;gt=1;eq=2;.irpc i, 01234567;.irp x, lt, gt, eq; cr\i\().\x=\x+\i<<2;.endr;.endr
# enumeration macros, register symbols, and cr symbols

.ifndef def
.macro ifdef,     sym; .altmacro; ifdef.alt \sym; .noaltmacro; .endm; def=0
.macro ifdef.alt, sym; def=0; .ifdef sym; def=1; .endif; ndef=def^1; .endm
.endif

.ifndef enum
.macro enum, base=enum, incr=1, va:vararg;
  enum.f \base, \incr, "", "", \va; enum=enum.f
.endm; enum=0;
# 'enum' can set a base value modified by an incrementor to multiple symbols in a sequence
#   if incrementor is set to 0, then all symbols recieve the same base value
#   else, each symbol gets last value + incrementor
# Sets 'enum' (self) property to next enumeration value
#   blank base will use self property by default
# ex: enum 0, 4, A B C D
#     .byte A, B, C, D
# >>> .byte 0, 4, 8, 12

.macro enum.f, e=enum.f, i=1, p, s, name, va:vararg;
  .ifnb \name;
    \p\name\s=\e;
    .ifne enum.debug; enum.debug, \p\name\s; .endif
    enum.f \e+\i, \i, \p, \s, \va;
  .else; enum.f=\e;
  .endif;
.endm; enum.f=0; enum.debug=0
# 'enum.f' can be used to set up specialized enum macros, with prefixes/suffixes
# Sets 'enum.f' (self) property to next enumeration value
# ex: enum.f 0, 4, x, , A B C D
#     .byte xA, xB, xC, xD
# >>> .byte 0, 4, 8, 12

.macro enum.debug, value, name;
  .ifb \value;
    .ifdef str.hexp.prefix; /*use str.hexp if available*/;
      str.hexp, tsup, \name, enum.debug, \name;
    .else;
      .altmacro;
      enum.debug %\name, \name;
      .noaltmacro;
      .exitm;
    .endif;
  .else; .error "\name = \value\()";
  .endif;
.endm;
# 'enum.debug' is automatically invoked by all uses of enum.f if the property enum.debug = 1

lt=0;gt=1;eq=2;.irpc i, 01234567;.irp x, lt, gt, eq; cr\i\().\x=\x+\i<<2; .endr; .endr
# cr symbols lt, gt, eq, and crN.* symbols
.irpc c, rfp; enum.f 0, 1, \c,, /*
*/   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15/*
*/, 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; .endr
# register symbols, for r- GPRs, f- FPRs, and p- paired singles

.macro enumbool, base=enumbool, va:vararg;
  .ifge \base;
    enumbool.mask \base, 1, \va;
    enum.f \base, 1, b,, \va;
    enumbool=enum.f;
  .else;
    enumbool.mask -(\base), -1, \va;
    enum.f -(\base), -1, b,, \va;
    enumbool=-(enum.f);
  .endif;
.endm;
.macro enumbool.mask, s, i, name, va:vararg;
  .ifnb \name;
    m\name= 1<<(31-(\s));
    enumbool.mask \s+\i, \i, \va;
  .endif;
.endm; enumbool=-31;
# 'enumbool' macro creates a b- boolean index symbol and a m- mask symbol for each given name.
#   The incrementor assumes -1 or +1 from the sign of the given starting base.
#   The base corresponds with the b- symbol value, and is equal to the bit's big-endian index.
#   May be used to streamline mask data generation with 'genmask' macro
# Sets 'enumbool' (self) property to next enumeration value
# ex: enumbool -31, A B C D
#     bf- bC, 0f;  rlwimi r0, r0, bA-bC, mC;     0:
# >>> bf- 29, 0f;  rlwimi r0, r0, 2, 0x00000004; 0:

.macro genmask, va:vararg;
  genmask=0;
  genmask.crf=0;
  genmask.i=0
  genmask.va \va;
.endm;
.macro genmask.va, name, va:vararg;
  .ifnb \name;
    ifdef m\name
    .if def
      .if \name;
        genmask=genmask|m\name;
      .endif;
    .else;
      genmask=genmask|\name;
    .endif;
    genmask.va \va;
  .else;
    .rept 8;
      .if (genmask & (0xF<<(genmask.i<<2)));
        genmask.crf=genmask.crf|(1<<genmask.i);
      .endif;
      genmask.i=genmask.i+1;
    .endr;
  .endif;
.endm; genmask=0; genmask.crf=0;
# 'genmask' macro compiles a mask int and a crf byte for loading in cr bits from data or immediates
# Sets 'genamsk' (self) property to the generated int value.
# Sets 'genmask.crf' property to the generated crf mask for using the mtcrf PPC instruction.
# ex: enumbool -31, A B C D
#     A=1;  B=1;  C=0;  D=1
#     genmask A B C D
#     li r0, genmask;  mtcrf genmask.crf, r0;  bf- bC, 0f;  rlwimi r0, r0, bA-bC, mC;     0:
# >>> li r0, 0xB;      mtcrf 0x01, r0;         bf- 29, 0f;  rlwimi r0, r0, 2, 0x00000004; 0:

.macro enumreg, base=enumreg, va:vararg;
  .ifge \base;
    enum.f \base, 1, r,, \va;
    enumreg=enum.f;
  .else; enum.f -(\base), -1, r,, \va;
    enumreg=-(enum.f);
  .endif;
.endm; enumreg=-r31;
# 'enumreg' macro creates an r- register symbol, for naming registers.
#   The incrementor assumes -1 or +1 from the sign of the given starting base.
#   The base corresponds with the literal register number used for PPC instructions.
# Sets 'enumreg' (self) property to next enumeration value
# ex: enumreg -r31, Key K Query Q
#     lbzu rK, 1(rKey)
#     lbzu rQ, 1(rQuery)
# >>> lbzu r30, 1(r31)
# >>> lbzu r28, 1(r29)

#enum 0, 4, A B C D
#.byte A, B, C, D
#.byte 0, 4, 8, 12
#
#enum.f 0, 4, x, , A B C D
#.byte xA, xB, xC, xD
#.byte 0, 4, 8, 12
#
#enumbool -31, A B C D
#A=1;  B=1;  C=0;  D=1
#genmask A B C D
#li r0, genmask;  mtcrf genmask.crf, r0;  bf- bC, 0f;  rlwimi r0, r0, bA-bC, mC;     0:
#li r0, 0xB;      mtcrf 0x01, r0;         bf- 29, 0f;  rlwimi r0, r0, 2, 0x00000004; 0:
#
#enumreg -r31, Key K Query Q
#lbzu rK, 1(rKey)
#lbzu rQ, 1(rQuery)
#lbzu r30, 1(r31)
#lbzu r28, 1(r29)

## # Examples:
## enum,, xTest, xName
## .long xTest, xName
## # enum can be used to create named index places
##
## enumreg, Test Name
## li rTest, 0
## li rName, 0
## # enumreg can be used to name registers
##
## enumbool -31, O0 O1 O2 O3 O4 O5 O6 O7
## # enumbool can be used to create boolean index and mask names
## # 20...31 are for interpreting ints as bool fields
##
## Options=0x46
## # int represents a compressed configuration of options for O0...O7
##
## enum 1, 0, A B C D E F G
## # enum can set multiple variables to the same value
##
## enumbool -19, A B
## # 8...19 are saved cr bits
##
## enumbool -15, C
## enumbool, D E
## # nulls will continue with the last used index/incremntor
## # (if no value is present, it defaults to -31)
##
## enumbool 0, F G
## # 0...7 are volatile working cr bits
##
## genmask A B C D E F G Options
## # genmask compiles an int from all of the symbol information generated by enumbool
##
## .long genmask
## .long genmask.crf
## lis r0, genmask@h
## ori r3, r0, genmask@l
## # genmask properties can be used in expressions
##
## mtcrf genmask.crf, r3
## cmpwi cr1, r3, 0
## bt+ bO1, 0x100
## bf+ bO7, 0x100
## cror eq, cr1.eq, bO3
## beq- 0x100
## # generated symbols can be used in cr-based instructions
.endif

.macro str.exp, va:vararg; .altmacro; str.exp.alt \va; .endm
.macro str.exp.alt, e, va:vararg; str.exp.noalt %e, \va; .endm
.macro str.exp.noalt, e, m, va:vararg; .noaltmacro; \m "\e", \va; .endm
# .macro test, e, a, b; .error "\a\e\b"; .endm
# str.exp (16) test "value = ", " -- also 'Hello World'"

.macro str.concat, margs, va:vararg; str.concat.x=0; str.concat.alt=0; str.concat.ws=1; .ifc "0", %0; str.concat.alt=1; .endif; .noaltmacro; str.concat.va "\margs", \va; .endm
.macro str.concat.x, e, m, s, va:vararg; str.concat.va "\m", "\s", "\e", \va; .endm
.macro str.concat.va, m, s, s1, s2, s3, va:vararg
  str.concat.x=0
  .ifb \s1  # if 1 null is found
    .ifb \s2  # if 2 nulls are found
      .ifb \s3  # if 3 or more nulls are found
        .if str.concat.alt;
        .altmacro; .ifb \va; \m \s; .else; \m \s, \va; .endif; .exitm
        # if staying in alt, do not use quotes;  if no va, then use no comma after \s

        .else; .ifb \va; \m "\s"; .else; \m "\s", \va; .endif; .exitm
        # else, use quotes;  if no va, then use no comma after \s
        .endif
      .endif

    str.concat.ws = 2; str.concat.va "\m", "\s", "\s3", \va; .exitm;
    # if 2 nulls are found, ws is set to 2 to generate a newline semi-colon on next concat
    .endif

  str.concat.ws = 0; str.concat.va "\m", "\s", "\s2", "\s3", \va; .exitm
  # if 1 null is found, ws is set to 0 to generate no whitespace on next concat
  # if no nulls are found, ws is left alone (1 by default generating a space on next concat)

  .else  # if no nulls in s1, s2, s3
    .irpc c, "\s1"; .ifc "\c", "(";  str.concat.x=1; .endif; .exitm; .endr
    # str.concat.x is true if first character of s1 is "("

    .if str.concat.x;  .altmacro;  str.exp \s1 str.concat.x "\m", "\s", "\s2", "\s3", \va
      # use str.exp to evaluate expressions contained in parentheses

    .else
      .if     str.concat.ws==0; str.concat.ws=1; str.concat.va "\m", "\s\s1", "\s2", "\s3", \va
      .elseif str.concat.ws==1; str.concat.ws=1; str.concat.va "\m", "\s \s1", "\s2", "\s3", \va
      .elseif str.concat.ws==2; str.concat.ws=1; str.concat.va "\m", "\s; \s1", "\s2", "\s3", \va
      .endif;
    .endif
  .endif
.endm
# stacknum=10; rIndex=31; xIndex=0x80; rBase=30
# str.concat .error Hello "world,", "str.concat.ws =", (str.concat.ws),,, stack_element_,, (stacknum), is ready,,, lwz r,,(rIndex),,",", (xIndex),,"\(r",,(rBase),,")",,, nop


.macro nmacro, n, m, va:vararg
  nmacro=0;
  .ifb \n; nmacro=1; \m \va; .endif
.endm
# calls next-next vararg if next vararg is null

.macro str.vexp, va:vararg;
  nmacro \va
  .if nmacro;
    .exitm;
  .endif
  .altmacro;
  str.vexp.alt \va;
.endm;
.macro str.vexp.alt, e, va:vararg;
  .irpc c, "\e";
    .ifc \c\c, "";
      str.vexp.noalt \e, \va;
    .else;
      str.vexp.noalt %e, \va;
    .endif;
    .exitm;
  .endr;
.endm;
.macro str.vexp.noalt, e, va:vararg;
  .noaltmacro;
  str.vexp \va, \e;
.endm;
# Interprets a sequence of expression strings and/or literal strings
# - terminate vararg sequence with a double comma,, followed by a macro designed to use result
# - string results will appear at END of varargs for continuation macro; not at start
# - pass a literal string instead of an expression by wrapping an argument in "double quotes"
# .macro testmac, a, b, c; .error "\a \b \c"; .endm; three=3
# str.vexp 0+1, "two", three,, testmac





.macro vactr, va:vararg; vactr=0; vactr.va \va; .endm
.macro vactr.va, x, va:vararg;  .ifnb \x;  vactr=vactr+1;  vactr.va \va;  .endif;  .endm
# count number of args left in va:vararg without committing to their str interpretations

.macro str.hexp, i, va:vararg;
  str.hexp.bit=32;
  .altmacro;
  .if str.hexp.prefix & (str.hexp.sign & (\i < 0) ==0);
    str.hexp.va <0x>,,, \i, \va;
  .elseif str.hexp.sign & (\i < 0);
    str.hexp.va <-0x>,,, -\i, \va;
  .else;
    str.hexp.va <>,,, \i, \va;
  .endif;
.endm; str.hexp.trim=1; str.hexp.prefix=1; str.hexp.sign=0 /* <-- defaults for hex format*/;
.macro str.hexp.va, p, s, o, i, m, va:vararg; LOCAL oct, nib, trim
  str.hexp.bit = str.hexp.bit - 4;
  .ifge str.hexp.bit;
    nib = (\i >> str.hexp.bit) & 0xF;
    oct = nib+60 + (11 & (nib > 9));
    trim = (str.hexp.trim!=0) & (nib==0) & (str.hexp.bit > 0);
    .ifnb \s;  trim = 0;  .endif;
    .if trim;
      .ifb \o; str.hexp.va <\p>, <\s>,, \i, \m, \va;
      .else;   str.hexp.va <\p>, <\s\0\o>,, \i, \m, \va;
      .endif;
    .else;
      .ifb \o; str.hexp.va <\p>, <\s>, %oct, \i, \m, \va;
      .else;   str.hexp.va <\p>, <\s\0\o>, %oct, \i, \m, \va;
      .endif;
    .endif;
  .else;
    .noaltmacro;
    vactr \va;
    .if vactr; \m "\p\s\0\o", \va;
    .else; \m "\p\s\0\o";
    .endif;
  .endif;
.endm;
# Convert expression strings into evaluated numbers, but in hex
# str.exp and str.vexp macros do the same, but in decimal
# str.hexp.trim     = 1
# str.hexp.sign = 1
# str.hexp.prefix   = 1  # prefix is always used with negative
# str.hexp -16+0x4, .error  # <- prints evaluated, formatted hex

.macro MCM_start; MCM_start = .; .endm; MCM_start; /* <-- this marks start of emitted program */;
.macro MCM_placeholder, l, x, l2;
  MCM_placeholder               = . - MCM_start;
  MCM_placeholder.hexp.trim     = str.hexp.trim;
  MCM_placeholder.hexp.prefix   = str.hexp.prefix;
  MCM_placeholder.hexp.sign = str.hexp.sign;
  MCM_placeholder.alt           = 0;
  .ifc "0", %0;
    MCM_placeholder.alt = 1;
  .endif;
  str.hexp.trim     = 0;
  str.hexp.prefix   = 0;
  str.hexp.sign = 0;
  str.hexp MCM_placeholder, MCM_placeholder.x, "\l", \x, "\l2";
  .if MCM_placeholder.alt;
    .altmacro;
  .endif;
  str.hexp.trim     = MCM_placeholder.hexp.trim;
  str.hexp.prefix   = MCM_placeholder.hexp.prefix;
  str.hexp.sign = MCM_placeholder.hexp.sign;
.endm;

.macro MCM_placeholder.x, o, l, x, l2;
  str.hexp.trim     = 1;
  str.hexp.prefix   = 1;
  str.hexp.sign = 0;
  .long 0;
  .ifb \x; MCM_placeholder.store, "\o: \l", "\l2";
  .else;   str.hexp \x, MCM_placeholder.store, "\o: \l", "\l2";
  .endif;
.endm;
.macro MCM_placeholder.store, x, s, l2;
  MCM_print "\s\x\l2";
.endm;
# Creates a null word and prints the offset, with a literal message and an optional expression
# - argument literals must be in "quotes", expression must be in (parentheses)
#   - literals l, l2, may optionally use a \ to escape brackets, preventing detection from MCM
#   - expression x is evaluated, so it may include labels and other symbol names


.macro MCM_print, s; MCM_printbuilder "\n";  .endm
.macro MCM_printbuilder, s, p;
  .purgem MCM_print
  .macro MCM_print, str, print="\p\s\n";
    .ifnb \str; MCM_printbuilder "\str", "\print";
    .else; .print "\print"
    .endif;
  .endm
.endm
func_printf = 0x80323eb4;
xMyStruct   = 0x44;
0:
MCM_placeholder "bl ", func_printf;
MCM_placeholder "b \<myFunc>";
MCM_placeholder "lis r0, <\<myData>> + ", (xMyStruct+4), "@h";
MCM_placeholder "ori r31, r0, <\<myData>> + ", (xMyStruct+4), "@l";
MCM_placeholder ".long <\<thisContainer>> +", (0f-0b) # this still fails...
0:

# maybe try saving the \x expression for evaluation at time of print?







# --- hasva
# - standalone utility -- checks vararg without committing to mutation
.macro hasva, x, va:vararg; hasva=0; .ifnb \x; hasva=1; .endif; .endm



# --- str.hexp
# - uses 'hasva' module
.macro str.hexp, i, va:vararg
  .ifb \i; str.hexp.params \va
  .else;
    str.hexp.bit=32
    .altmacro
    .if str.hexp.prefix & (str.hexp.sign & (\i < 0) ==0)
      str.hexp.va <0x>,,, <(\i)>, \va
    .elseif str.hexp.sign & (\i < 0)
      str.hexp.va <-0x>,,, <-(\i)>, \va
    .else
      str.hexp.va <>,,, <(\i)>, \va
    .endif
  .endif
.endm; str.hexp.trim=1; str.hexp.prefix=1; str.hexp.sign=0; str.hexp.case=1
 /*- defaults params*/
/*opening function conditionally calls .params and sets up a prefix based on options*/

.macro str.hexp.params, p, i, va:vararg
  .ifb \p; .error "'str.hexp,' found no usable params"; .abort; .endif
  str.hexp.mask=1;
  .irpc c, "\p";/*for each char in argument p ...*/
    .rept 1;   /*.exitm will exit just this .rept block*/
      .ifc \c, +; str.hexp.mask   = 1;                 .exitm; .endif
      .ifc \c, -; str.hexp.mask   = 0;                 .exitm; .endif
      .ifc \c, t; str.hexp.trim   = str.hexp.mask;     .exitm; .endif
      .ifc \c, s; str.hexp.sign   = str.hexp.mask;     .exitm; .endif
      .ifc \c, p; str.hexp.prefix = str.hexp.mask;     .exitm; .endif
      .ifc \c, l; str.hexp.case   = str.hexp.mask ^ 1; .exitm; .endif
      .ifc \c, c; str.hexp.case   = str.hexp.mask ^ 1; .exitm; .endif
      .ifc \c, C; str.hexp.case   = str.hexp.mask;     .exitm; .endif
      .ifc \c, u; str.hexp.case   = str.hexp.mask;     .exitm; .endif
      .ifc \c, U; str.hexp.case   = str.hexp.mask;     .exitm; .endif
      .error "'str.hexp,' found invalid params in '\p' "
    .endr;
  .endr; .ifnb \i; str.hexp \i \va; .endif
.endm;  /*.params allows calls to str.hexp, (with a ',' prefix) to specify format paramters*/

.macro str.hexp.va, p, s, o, i, m, va:vararg; LOCAL oct, ascii, nib, trimming
  str.hexp.bit = str.hexp.bit - 4
  .ifge str.hexp.bit;
    nib      = \i >> str.hexp.bit && 0xF      /*extract nth nibble from input expression*/
    ascii    = nib + 0x30 + ((nib > 9) && (7 + (32 && (str.hexp.case==0))))/*ascii math*/
    trimming = (str.hexp.trim != 0) && (nib == 0) && (str.hexp.bit > 0)   /*trim logic*/
    .ifnb \o;  trimming = 0;  .endif       /*only trim if all conditions evaluate > 0*/
    oct =       (ascii >> 6 && 7) * 100   /*3-digit oct escape code, in dec literals*/
    oct = oct + (ascii >> 3 && 7) * 10
    oct = oct + (ascii >> 0 && 7) * 1
    .if trimming
      str.hexp.va <\p>, <\s>,, \i, \m, \va
    .else;
      .ifb \o;  str.hexp.va <\p>, <\s>,   %oct, \i, \m, \va
      .else;    str.hexp.va <\p>, <\s\\o>, %oct, \i, \m, \va
      .endif;     /*evaluate %oct as numeric (decimal) literals, and append after evaluation*/
    .endif;
  .else;
    .ifnb \o; str.hexp.va <\p\s\\o >,,,, \m, \va
      /*when we run out of digits, concat last octal with string and given prefix*/
    .else;
      .noaltmacro; str.hexp.continue \m, \p, \va
    .endif   /*pass resulting string to macro \m as first argument*/
  .endif;
.endm;  /*recursively format hex literals, with format options*/
.macro str.hexp.continue, m, p, va:vararg
  hasva \va
  .if hasva; \m \p, \va
  .else;     \m \p
  .endif  /*avoid using a comma if va is blank*/
.endm /*final step removes any qoutes that may have been given to \m*/
# Accepts constants, variables, or expressions that don't have any shifts in them

## # EXAMPLES:
## .macro m, s, ss; .error "\s \ss"; .endm;
## str.hexp 1-10*5, m   # <- error text = evaluated, formatted hex from given expression
## x'Var = 10+12>>2     # - expressions with shifts must be passed via symbols
## str.hexp x'Var,  m   # <- but they can still be evaluated
## str.hexp 1000+x'Var, m, "and then some more text"
## # macros will recieve the hex as the first argument, followed by any extra arguments given
##
## # you can also use a blank first argument to set basic format options in the second argument:
## str.hexp, -tsp, 150, m # - remove trim, sign, and prefix options
## str.hexp, +tsp, 150, m # - add trim, sign and prefix options
## str.hexp, -s,  -150, m # - sign can be used to summarize negatives
## str.hexp, sl,  -150, m # - options can be toggled on without a + sign
## str.hexp, -s+t,-150, m # - you can also mix multiple signs in one param string
## # t = trim   s = sign   p = prefix   l, c = lowercase   u, U, C = uppercase






.macro MCM_start; MCM_start = .; .endm; MCM_start; /* <-- this marks start of emitted program */;
.macro MCM_placeholder, l, x=none, l2=none;
  MCM_placeholder             = . - MCM_start;
  MCM_placeholder.hexp.trim   = str.hexp.trim;
  MCM_placeholder.hexp.prefix = str.hexp.prefix;
  MCM_placeholder.hexp.sign   = str.hexp.sign;
  MCM_placeholder.alt           = 0;
  .ifc "0", %0;
    MCM_placeholder.alt = 1;
  .endif;
  str.hexp.trim   = 0;
  str.hexp.prefix = 0;
  str.hexp.sign   = 0;
  str.hexp MCM_placeholder, MCM_finish, "\x \l2 \l"
  .if MCM_placeholder.alt;
    .altmacro;
  .endif;
  str.hexp.trim     = MCM_placeholder.hexp.trim;
  str.hexp.prefix   = MCM_placeholder.hexp.prefix;
  str.hexp.sign = MCM_placeholder.hexp.sign;
.endm;
.macro MCM_finish, o, s; .ifnb \o; MCM_printbuilder \o, "\s"; .endif; .endm
.macro MCM_printbuilder, offset, string, print
  .purgem MCM_finish
  .macro MCM_finish, o, s, p="\print MCM_placeholder.print \offset \string;"
    .ifnb \o; MCM_printbuilder "\o", "\s", "\p";
    .else; \p
    .endif;
  .endm
.endm
.macro MCM_placeholder.print, o, x, l2, l:vararg;
  MCM_placeholder.print.trim   = str.hexp.trim;
  MCM_placeholder.print.prefix = str.hexp.prefix;
  MCM_placeholder.print.sign   = str.hexp.sign;
  str.hexp.trim      = 1;
  str.hexp.prefix    = 1;
  str.hexp.sign  = 0;
  .ifc "\l2", "none";
    .ifc "\x", "none";  MCM_placeholder.print.x  "", "\o", "", "\l";
    .else; str.hexp \x, MCM_placeholder.print.x, "\o", "\l2", "\l";
    .endif;
  .else;
    .ifc "\x", "none";  MCM_placeholder.print.x  "", "\o", "\l2", "\l"
    .else; str.hexp \x, MCM_placeholder.print.x, "\o", "\l2", "\l";
    .endif;
  .endif;
  str.hexp.trim   = MCM_placeholder.print.trim;
  str.hexp.prefix = MCM_placeholder.print.prefix;
  str.hexp.sign   = MCM_placeholder.print.sign;
.endm;
.macro MCM_placeholder.print.x, x, o, l2, l:vararg;
  .print "\o: \l\x\l2"
.endm

func_printf = 0x80323eb4;
xMyStruct   = 0x44;
0:
MCM_placeholder "bl ", func_printf;
MCM_placeholder "b \<myFunc>";
MCM_placeholder "lis r0, <\<myData>> + ", (xMyStruct+4), "@h";
MCM_placeholder "ori r31, r0, <\<myData>> + ", (xMyStruct+4), "@l";
MCM_placeholder ".long <\<thisContainer>> +", (0f-0b) # this still fails...
0:





< test <test> test <test> <test> <test> <<test><test>> test >



.macro m, s, va:vararg;
  .ifnb \s;
    mm \s;
    m \va;
  .endif;
.endm;
.macro mm, s, va:vararg;
  .ifnb \s;
    mmm "\s";
    mm \va;
  .endif;
.endm;
.macro mmm, s;
  .error \s;
.endm;
# .altmacro
# m <<00000044:\040lis r0,\0400x10>,<string tuple>>

.macro m, s, va:vararg;
  .altmacro
  .ifnb \s;
    mm \s;
    m \va;
  .endif;
.endm;
.macro mm, s, va:vararg;
  .ifnb \s;
    mmm "\s";
    mm \va;
  .endif;
.endm;
.macro mmm, s;
  .error \s;
.endm;
# m "<00000044:\040lis r0,\0400x10>,<string tuple>"



.macro mac, s; m <\s>; .endm
.macro m, s
  .macro print, ss=<\s>
    mm %\ss;
  .endm
.endm
.macro mm, s
  .rept 2; .print ": \s";.endr
.endm
# .altmacro
# _test1=.
# .long 0, 1, 2, 3
# mac _test2-_test1
# .long 4, 5, 6, 7
# _test2=.
# print



$'start = .
$'end = .
# ' converts ascii into a decimal number with up to 3 digits

.macro m', m'=1
  .long \m'
.endm
mc'leet = 0x1337
m'
# the above is all valid

s=2
m' s
m' mc'leet
# symbols can use some illegal characters directly; macros cannot

.macro this' is' a' macro' name
  .long 1
.endm
this' is' a' macro' name
this32is32a32macro32name
# from the source end, this may be appealing for validating visual spaces or punctuation

mc'% = 100
.long mc'%
# or summarizing the meaning of a variable with an operator symbol

.macro .macro'', .macro''=2
  .long \.macro''
.endm
.macro''
# you can also convert the escape character

'a: x'Alternative = 0x320
.long '%f-'ab + x'Alternative
'a:
# they can create temporary label instances with -f forward and -b back

.macro m, s;.error "\s";.endm
m these\x20\are\040all\'(spaces
# the above argument is singular

lwz r3, 0x4(rThis' is' my' very' valid' register' name)
# this is stupid, but valid

x'a = 1
x'b = 2
x'c = 3
x'd = 4
.long x'a, x'b, x'c, x'd
.long x97, x98, x99, x100
# The numerical aliases will be equivical -- and necessary if "used within string literals"






# those alt string tho?

1:  .macro m,str;.error "\str";.endm
# These are read as single args thanks to quote encapsulation
# "", <>, (), []

2: .altmacro
# in alt mode... "" quoted strings preserve quotes when passed
3:  m <hello world>              # <> spaces supported
4:  m <hell no, world>           # <> destroys literal spaces after commas
5:  m <<hell no>, <world>>       # <<>> destroys literal spaces
6:  m < <hell no>, <world> >     # <<>> destroys literal spaces
7:  m < <hello>,\040<world> >    # <<>> octal space + null
8:  m <<hello>,\040<world> >     # <<>> octal space + null
9:  m <<hell no>,\040<world>\()> # <<>> octal space + null
10: m <<hello>,\040< world>>     # <<>> octal space + null
11: m <<hello >,\040<world>>     # <<>> octal space + null
12: m <<hell>,\040<world>>       # <<>> octal space ...
13: m "hello world"              # "" quotes are passed to macro ...
# (parse 12: failure without null somewhere in string with octal)
# (parse 13: failure because nested quotes close string early)

14: .noaltmacro
# in normal mode... "" quoted strings lose quotes when passed
15: m "hello world"     # "" support spaces, destroys quote nesting
16: m "hello, world"    # "" support commas, destroys quote nesting
17: m hello\040world    #   literals supported without literal spaces/commas
18: m ""hell no world"" # """" empty strings + spaced literals, break string
19: m <hell no world>   # <> spaces are null, and break string
20: m (hello world)     # () support spaces without creating nulls
21: m (hell no, world)  # () commas are null, and break string
22: m [hello world]     # [] support spaces without creating nulls
23: m [hell no, world]  # [] commas are null, and break string






.macro testascii, myexp, myhex, mylit
  char='0
  .byte   0x30       # hex integer (expression)
  .byte  "000"       # string literals
  .byte  '0          # character literal
  .byte  char        # symbol evaluation (expression)
  .ascii "000"       # string literals
  .ascii "\x30"      # hex char
  .ascii "\060"      # oct char
  .ascii <48>        # alternative string literals
  .byte  \myexp      # argument expression
  .ascii "\x\myhex"  # argument byte literal
  .ascii "\mylit"    # argument string literals
  .fill (.+7)&-8-., 1, \myexp
  # fill with \myexp until . is at next <<3 alignment

.endm;  testascii  myexp= '0-48+0x30,  myhex= 30,  mylit= 0
# >>> 30303030 30303030 30303030 30303030




.macro MCM_placeholder.x, o, l, x, l2;
str.hexp.trim     = 1;
str.hexp.prefix   = 1;
str.hexp.sign = 0;
.long 0;
.ifb \x; MCM_placeholder.print, "\o: \l", "\l2";
.else;   str.hexp \x, MCM_placeholder.print, "\o: \l", "\l2";
.endif;
.endm;
.macro MCM_placeholder.print, x, s, l2;
.print "\s\x\l2";
.endm;

.macro strtoc, base, start, va:vararg;
  i=0;
  \base\():
  .irp s, \va;
    .altmacro;
      pointlocstr %i;
      i=i+1;
    .noaltmacro;
  .endr;
  i=0;
  strtoc.va \va;
.endm;
.macro strtoc.va, s, va:vararg;
  .ifnb \s;
    .altmacro;
      poslocstr %i;
    .noaltmacro;
    .asciz "\s";
    i=i+1;
    strtoc.va \va;
  .else;
    .align 2;
  .endif;
.endm;
.macro pointlocstr, labnum;
  # MCM_placeholder ".long <<\start>>", (\labnum\()f)
.endm;
.macro poslocstr, labnum;
  \labnum\():;
.endm;
.macro getloc, reg, label, start;
  #MCM_placeholder "lis \reg, <<\start>>@h"
  #MCM_placeholder "ori \reg, \reg, <<\start>>@l"
.endm

strtoc _myStrings, "<\<myDataContainer>>", "Hello World!", "These are all strings included in the program", "They are mapped, and can be selected with a word-aligned index from _myStrings", "Jeffrey Epstein didn't kill himself", "This macro can be implemented in many different programs"


.macro align, a, newbase;
  .ifnb \newbase; align.base = \newbase; .endif
  align.a = 1 << \a - 1;  align.a = (align.a - (. - align.base - 1) & align.a)
  .if align.a;  .zero align.a;  .endif;  align = .
.endm; _align.start: align.base= _align.start
/*align works just like the .align directive, but protects labels in absolute expressions*/










ascizw
.macro YAML.returnToMap,  p=default; YAML.return 1+YAML.listing, \p; YAML.listing = 0; .endm
.macro YAML.returnToList, p=default; YAML.return 1,              \p; YAML.listing = 1; .endm
.macro YAML.returnToTop,  p=default; YAML.return -1,             \p; YAML.listing = 0; .endm
.macro YAML.return i, p;

.endm;
# returnTo options help close indent folding correctly

.macro YAML.item, key, val, printer=default;
  .ifndef YAML.printers.\p\().isevent;
    macroevent YAML.printers.\p\().isevent;
  .else;

  .endif;
.endm;
# provides functionality for .list and .map methods by queueing items to the printer
# - an undefinied printer in either will causes a new printer to be defined
# - if printer is left blank, then a default YAML printer will be used instead of a specific one

.macro YAML.list, va:vararg; YAML.listing = 1; YAML.item \va; .endm;
# New indents from a list must closed with .returnToList or .returnToTop
# - a blank key makes a list item
# - a blank value makes a nested map header
# - a key:value makes a nested map value within the sequence

.macro YAML.map,  va:vararg; YAML.listing = 0; YAML.item \va; .endm;
# New indents from a map must be closed with .returnToMap or .returnToTop
# - a key:value makes a map item
# - a blank key value will throw an error
# - a blank value will make a nested map header









.macro hexFilter, va:vararg;  hexFilter.iter, \va;  .endm
.macro hexFilter.iter, str, x, va:vararg
  .irpc c, "\str"
    .irpc k, "\x"

    .endr
  .endr
.endm

.macro em,l;\l;.endm
.macro $, a, b, va:vararg
  .ifb \a; emit.va "\b",, \va
  .else; emit.va,, "\a", "\b", \va
.endm
.macro emit.va, m, e, a, b, t, va:vararg
  .ifb \a
    .ifb \b;  em.l ""
    .else;

    .ifb \t


.macro em, a, b, va:vararg
  .ifnb \b
    em "\a \b ", \va
    .exitm
  .endif
  em.l "\a ;"
  .ifnb \a
    em \va
  .endif
.endm

.macro hex, va:vararg
  hex=.; hex.i=0; hex.r=0; hex.a=2
  hex.va "", \va; hex.len = .-hex
.endm; .macro hex.va, q, a, b, va:vararg
  .ifnb \a;
    .ifc "\a", "fs";
    .ifc "\a", "fd";
    .ifc "\a", "$";   emit
    # emit source literals

    .ifc "\a", "pop"; hex.pop \q, \b, \va; .exitm; .endif
    # write up to 4 bytes from expression memory

      .irpc c, \a
        .ifc "\c", "(";
        hex.i = hex.i + 1
      .endr
  .else;
  .endif
  .ifnb \b
  .else;
  .endif
.endm





.macro xlab, value, str, expr, va:vararg;
  .ifb \expr;  xlab.iter \value, \str,      , \va
  .else;       xlab.iter \value, \str, %expr, \va
  .endif
.endm

.macro xlab.iter, v, str, x, s, nx, ns, va:vararg
  .ifb \s;
    .ifb \x; \str = \v;
      .ifdef xlab.debug;
        .if xlab.debug;
          .error "\str = \v";
        .endif;
      .endif;
      .exitm;
    .endif
  .endif
  .ifnb \nx; xlab.iter \v \str\x\s, %nx, \ns, \va;
  .else; xlab.iter \v \str\x\s,, \ns \va;
  .endif
.endm
xlab.debug = 1
.altmacro
xlab 1337 mytest ,xlab.debug





.macro int.defaults, value=0, add=1, mult=0x80000000, mask=1, shift=1, floor=0x80000000, ceil=0x7FFFFFFF, cap=0, str="";  int.value=\value;  int.add=\add;  int.mult=\mult;  int.mask=\mask;  int.shift=\shift;  int.floor=\floor;  int.ceil=\ceil;  int.cap=\cap; .endm; int.defaults

.macro int, a, b, c, d, va:vararg
  .ifnb \a; int.hlpr \a, \b, \c, \d, \va; \a + 0; .exitm; .endif
  .ifnb \b; \b\().mem = \b;  int.target \c, \d, \b, \va; .endif
.endm

.macro int.hlpr, name, value=int.value, va:vararg
  .ifnb \name #  setting initial properties...
    \name=\value; \name\().add=int.add; \name\().mult=int.mult; \name\().mask=int.mask; \name\().shift=int.shift; \name\().floor=int.floor;  \name\().ceil=int.ceil;  \name\().cap=int.cap
    .macro \name, x  # defining method...
      .rept 1  # select case
        .ifc "\x", "+";  \name = \name + \name\().add;    .exitm;  .endif
        .ifc "\x", "++"; \name = \name + 1;               .exitm;  .endif
        .ifc "\x", "-";  \name = \name - \name\().add;    .exitm;  .endif
        .ifc "\x", "--"; \name = \name - 1;               .exitm;  .endif
        .ifc "\x", "*";
          .if \name\().mult == 0x80000000; \name = \name * \name # magic number for self
          .else; \name = \name * \name\().mult; .endif;   .exitm;  .endif
        .ifc "\x", "<<"; \name = \name << \name\().shift; .exitm;  .endif
        .ifc "\x", ">>"; \name = \name >> \name\().shift; .exitm;  .endif
        .ifc "\x", "|";  \name = \name | \name\().mask;   .exitm;  .endif
        .ifc "\x", "||"; \name = \name | 1;               .exitm;  .endif
        .ifc "\x", "^";  \name = \name ^ \name\().mask;   .exitm;  .endif
        .ifc "\x", "^^"; \name = \name ^ 1;               .exitm;  .endif
        .ifc "\x", "~";  \name = ~\name;                  .exitm;  .endif
          \name = \name \x  # else, use given expression with a missing first operand
      .endr
      .if \name > \name\().ceil
        .if \name\().cap;  \name = \name\().ceil
        .else; \name = (\name % (\name\().ceil - \name\().floor)) + \name\().floor
        .endif
      .endif
    .endm
    int.hlpr \va  # repeat int attribute definitions for each additional vararg pair
  .else
    .ifnb \va; int.target \value \va
    # if a null has been found before end of va, switch to target mode
    .endif
  .endif
.endm

.macro int.target, target, x, name, nt, nx, va:vararg
# target mode uses an int's properties to transform some other target symbol's value
  int.target = 0
  .ifnb \target
    int.target = \name; \name = 0; \name \x
    \target = \name; \name = int.target; int.target = \target
    int.target \nt, \nx, \name, \va
  .else
  .endif
.endm

#int i
## integer object "i"
#
#.long i
#.irp x,   i ++,   i + 5,   i ~,   i = 0,  i --,   i --,   i & 0xFF,   i ^^
## shortcut math using special int operators
#  \x
#  .long i
#.endr
#
#j = 0
## symbol "j" -- not an integer object
#
#int, i j ++
## applies shortcut math from given int "i" to value of symbol "j"








.macro bl, va:vararg; .error "This is my instruction now."; .abort; .endm;
/*example of bl instruction override*/

.macro $$bl
  .if  bl.purgem; .purgem bl; bl.purgem=0
  .else; bl.purgem=1
    .macro bl, va:vararg;MCM.branchoverride bl, \va;.endm
  .endif
.endm; bl.purgem=0; $$bl /*initialize bl object method using class method*/
/*toggle custom bl behavior with $$bl class method*/
.macro $$b
  .if  b.purgem; .purgem b; b.purgem=0
  .else; b.purgem=1
    .macro b, va:vararg;MCM.branchoverride b, \va;.endm
  .endif
.endm; b.purgem=0; $$b /*initialize b object method using class method*/
/*toggle custom b behavior with $$b class method*/
.macro MCM.branchcheck, i, va:vararg; \i\().bracket=0; \i\().abslit=0; \i\().len=0
  .irpc c, "\va"  /*for each char*/
    .ifnc "\c", "("; .ifnc "\c", " "; \i\().len=\i\().len+1; .endif; .endif
    .if (\i\().len > 4) && (\i\().len <= 10) && \i\().abslit; \i\().abslit=0;
      .irpc x, 0123456789abcdefABCDEF; .ifc "\c", "\x";  \i\().abslit=1; .endif; .endr
    .elseif \i\().len == 1;            .ifc  "\c", "0";  \i\().abslit=1; .endif
    .elseif \i\().len == 2;            .ifnc "\c", "x";  \i\().abslit=0; .endif
    .elseif \i\().len == 3;            .ifnc "\c", "8";  \i\().abslit=0; .endif
    .elseif \i\().len == 4;                              \i\().abslit=0
      .irpc x, 01;                     .ifc  "\c", "\x"; \i\().abslit=1; .endif; .endr
    .endif /*ends with '>' check*/
    .ifc "\c", ">"; \i\().bracket=\i\().len; .endif;  /*record last use of '>'*/
  .endr
.endm; /*mostly just a check for absolute literal address -- without requiring evaluation*/
.macro MCM.branchoverride, i, va:vararg; MCM.branchcheck \i, \va
  .if      \i\().bracket==\i\().len; MCM.placeholder "\i \va"; /*handle special syntaxes with MCM*/
  .elseif (\i\().abslit!=0) && (\i\().len==10); MCM.placeholder "\i " \va
  .else; $$\i; \i \va; $$\i;  /*else, revert to default instruction handle*/
  .endif
.endm;/*creates MCM.placeholders for absolute address literals and function names*/



# --- Experimental branch overrides
.macro $$bl
  .if  bl.purgem; .purgem bl; bl.purgem=0
  .else; bl.purgem=1
    .macro bl, va:vararg;MCM.branchoverride bl, \va;.endm
  .endif
.endm; bl.purgem=0; bl.link=1; $$bl /*initialize bl object method using class method*/
/*toggle custom bl behavior with $$bl class method*/
.macro $$b
  .if  b.purgem; .purgem b; b.purgem=0
  .else; b.purgem=1
    .macro b, va:vararg;MCM.branchoverride b, \va;.endm
  .endif
.endm; b.purgem=0; b.link=0; $$b /*initialize b object method using class method*/
/*toggle custom b behavior with $$b class method*/
.macro MCM.branchcheck, i, va:vararg; \i\().bracket=0; \i\().abslit=0; \i\().len=0
  .irpc c, "\va"  /*for each char*/
    .ifnc "\c", "("; .ifnc "\c", " "; \i\().len=\i\().len+1; .endif; .endif
    .if (\i\().len > 4) && (\i\().len <= 10) && \i\().abslit; \i\().abslit=0;
      .irpc x, 0123456789abcdefABCDEF; .ifc "\c", "\x";  \i\().abslit=1; .endif; .endr
    .elseif \i\().len == 1;            .ifc  "\c", "0";  \i\().abslit=1; .endif
    .elseif \i\().len == 2;            .ifnc "\c", "x";  \i\().abslit=0; .endif
    .elseif \i\().len == 3;            .ifnc "\c", "8";  \i\().abslit=0; .endif
    .elseif \i\().len == 4;                              \i\().abslit=0
      .irpc x, 01;                     .ifc  "\c", "\x"; \i\().abslit=1; .endif; .endr
    .endif /*ends with '>' check*/
    .ifc "\c", ">"; \i\().bracket=\i\().len; .endif;  /*record last use of '>'*/
  .endr
.endm; /*mostly just a check for absolute literal address -- without requiring evaluation*/
.macro MCM.branchoverride, i, va:vararg; MCM.branchcheck \i, \va
  .if MCM.gecko; MCM.gecko.branchoverride \i, \va; /*disable MCM.placeholders if in MCM.gecko mode*/
  .elseif \i\().bracket==\i\().len; MCM.placeholder "\i \va"; /*handle special syntaxes with MCM*/
  .elseif (\i\().abslit!=0) && (\i\().len==10); MCM.placeholder "\i " \va
  .else; $$\i; \i \va; $$\i;  /*else, revert to default instruction handle*/
  .endif
.endm;MCM.gecko=0; /*creates MCM.placeholders for absolute address literals and function names*/
.macro MCM.gecko.branchoverride, i, va:vararg; MCM.branchcheck \i, \va;
  .if \i\().bracket==\i\().len; \i\().len=0; MCM.gecko.resolvebracket \i, "\va",
  .elseif (\i\().abslit!=0) && (\i\().len==10); MCM.gecko.abslit \i, \va
  .else; $$\i; \i \va; $$\i;
  .endif;
.endm; /*for easy gecko code conversions*/
.macro MCM.gecko.resolvebracket, i, func, name
  MCM.gecko.resolvebracket.exit = 0; \i\().bracket = 0; \i\().skipchar = 0
  .ifnb \func
    .irpc c, "\func"
      .if \i\().bracket == \i\().len;
        \i\().len = \i\().len + 1;
        .irpc b, "><"; .ifc \c, \b; \i\().skipchar = 1; .endif; .endr
        .if \i\().skipchar; MCM.gecko.resolvebracket \i, "\func", "\name"
        .else;              MCM.gecko.resolvebracket \i, "\func", "\name\c"
        .endif; MCM.gecko.resolvebracket.exit = 1
        .exitm /*only exits irpc block*/
      .endif; \i\().bracket = \i\().bracket + 1
    .endr
  .endif
  .if MCM.gecko.resolvebracket.exit==0;
    .if \name < 0x81800000; MCM.gecko.abslit \i, \name
    .else; $$\i; \i \name; $$\i
    .endif;  /*assume symbol is absolute, and check if it is an address*/
  .endif    /*if addr, use longform abslit blrl or bctr; else default to instruction*/
.endm
.macro MCM.gecko.abslit, i, addr
  lis r0, \addr @h; ori r0, r0, \addr @l;
  .if \i\().link; mtlr r0; blrl
  .else; mtctr r0; bctr
  .endif
.endm

# Examples:
MCM.begin; myFunc=0x80323eb4
MCM.gecko=0
nop; bl MCM.begin; bl _myLabel; bl 0x80323eb4; bl <myFunc>; bl 0x40
nop; b  MCM.begin; b  _myLabel; b  0x80323eb4; b  <myFunc>; b  0x40
# The $$bl overrider lets us use 'bl' for handling the creation of MCM.placeholders internally
# Normal use of bl still defaults to instruction handle

MCM.gecko=1
_myLabel:
nop; bl MCM.begin; bl _myLabel; bl 0x80323eb4; bl <myFunc>; bl 0x40
nop; b  MCM.begin; b  _myLabel; b  0x80323eb4; b  <myFunc>; b  0x40
# With MCM.gecko enabled, longform blrl and bctr branches are used instead of MCM.placeholders
MCM.finish





.macro nodelink, t=generic, n, o=0;
  .ifdef nodelink.\t; nodelink.\t = nodelink.\t + 1;
  .else; nodelink.closer \t, \o;  nodelink.\t\().o = \o;
  .endif; .altmacro;
     nodelink.alt %(-1+nodelink.\t), %(nodelink.\t), %(1+nodelink.\t), \t, \n, nodelink.\t\().o;
   .noaltmacro;
.endm; .macro nodelink.alt, prev, this, next, t, n, o;
  .ifnb \n;
    .if \prev >= 0; \t\().\n\().prev = \t\().\prev;
    .else; \t\().\n\().prev = \t\().\this\().link;
    .endif; \t\().\n = .-\o; \t\().\n\().link = .; \t\().\n\().next = \t\().\next;
  .endif; \t\().\this = .-\o; \t\().\this\().link = .; .long \t\().\next - \t\().\this\().link;
.endm; .macro $$nodelink.closer, str; .purgem nodelink.closer;
  .macro nodelink.closer, t, o, s="\str";
    .ifnb \t;  $$nodelink.closer "\t, \s"; nodelink.\t = 0;
    .else; .altmacro; nodelink.closer.alt,, \s; .noaltmacro; $$nodelink.closer;
    .endif;
  .endm;
.endm; .macro nodelink.closer.alt, l, n, t, s:vararg;
  .ifnb \t; .ifb \l; nodelink.closer.alt %(-1+nodelink.\t), %(nodelink.\t), \t, \s;
    .else; \t\().\n = \t\().\l\().link; nodelink.closer.alt,, \s; nodelink.\t = nodelink.\t + 1
  .endif; .endif;
.endm; .macro nodelink.closer; .endm; $$nodelink.closer;
.macro nodelink.close, t;
  .ifnb \t; .altmacro; nodelink.closer.alt,, \t; .noaltmacro; .else; nodelink.closer; .endif;
.endm;
# nodelink [type], [name], [offset]
#  use this to create nodes that link together
# - [type] = a name for this linked list;  blank= "generic"
# - [name] = an optional name, for assigning .prev and .next values
# - [offset] = offset of this link pointer (from node base - only required on type init)
# nodelink.close [type]
#  use this to make a null at the last node for [type]
# - omit [type] to close all nodes

.macro relpoint, t; .if (\t!=.)&&(\t!=0); .long \t-.; .else; .long 0; .endif; .endm;
# relpoint [target]
#  use this to make relocatable relative pointers to target labels
# - [target] = a label within your ASM program

.macro nodelink.reloc, next=-0x7FFF, child=-0x7FFF, mask:vararg;
  nodelink.reloc = .; nodelink.reloc.i=4; nodelink.reloc.b=0;
  b _nodelink.reloc.\@; .hword \next, \child, (_nodelink.reloc.\@-nodelink.reloc)-12;
  nodelink.reloc.mask \mask; _nodelink.reloc.\@: ;
.endm; .macro nodelink.reloc.mask, s, m:vararg;
  .ifnb \s;
    .irpc c, \s; nodelink.reloc.i = (nodelink.reloc.i + 1);
      .if nodelink.reloc.i&1; nodelink.reloc.b = \c<<4;
      .else; nodelink.reloc.b = nodelink.reloc.b | \c; .byte nodelink.reloc.b;
      .endif;
    .endr; nodelink.reloc.mask \m
  .elseif nodelink.reloc.i&7; nodelink.reloc.mask 0
  .endif;
.endm;
# nodelink.reloc [next], [child], [mask]
# - [next] = offset of 'next' pointer, for this node
# - [child] = offset of 'child' pointer, for this node
# - [mask] = bitmask indexes ordered pointer offsets in node structure


.macro reloc.node, label, links, pointers;
  rn.links = 0; rn.start = -1; rn.end; rn.pointers = 0; rn.op=1; _rn.start\@:
  .ifb \label; rn.op = rn.op | 0x10; .endif
  /*if label is missing, then this bit tells the parser to use r3 argument for input base*/
  .irp x, \links; .ifnb \x; rn.links = rn.links+1; .endif; .endr;
  /*count link dimensions*/
  .irp x, \pointers;
    .ifnb \x; rn.pointers = rn.pointers+1
      .if rn.start != -1;
        .if \x < rn.start; rn.start = \x; .endif
        .if \x > rn.end; rn.end = \x; .endif;
      .else; rn.start = \x; rn.end = \x;
      .endif; /*find lowest/highest pointer offsets to calculate range*/
    .endif;
  .endr;   rn.range = rn.end-rn.start; rn.q=-1; rn.mask=0
  rn.ctr = rn.range>>2
  /*set up argument properties for .mask method*/
  .byte rn.op, rn.links; .hword \links, rn.start, rn.range + (. - _rn.start\@) & 2
  reloc.node.mask \pointers  /*emit argument info*/
  .ifnb \label; .long \label - .; .endif; /*write pointer to label, if provided*/
.endm; .macro reloc.node.mask, p, q:vararg;
  .if rn.ctr; rn.q = rn.q + 1
    .if rn.q != rn.ctr;
    .endif
  .endif
.endm




.macro reloc.node, label, links=0, pointers=0
  rn.links=0; rn.start=-1; rn.end=-1; rn.pointers=0; rn.op=1; _rn.start\@\():
  .ifb \label; rn.op=rn.op | 0x10; .endif
  .irp x, \links; .ifnb \x; rn.links=rn.links+1; .endif; .endr
  .irp x, \pointers; /*counted links*/
    .ifnb \x; rn.pointers = rn.pointers+1
      .if rn.start!=-1
        .if \x<rn.start; rn.start=\x; .endif
        .if \x+4>rn.end; rn.end=\x+4; .endif
      .else; rn.start=\x; rn.end=\x
      .endif;
    .endif
  .endr; /*found start/end of range*/
  rn.range = rn.end-rn.start; rn.q=-1; rn.mask=0;
  rn.ctr = rn.pointers; rn.limit = (rn.start+64)
  .byte rn.op, rn.links
  .hword rn.start, rn.range, _rn.end\@ - _rn.start\@
  .ifnb \label; .long . - \label; .endif
  .if rn.links; .hword \links; .endif
  .if rn.ctr; reloc.node.mask \pointers; .endif
  .if (. - _rn.start\@ ) & 2; .hword 0; .endif; _rn.end\@\():
  /*emitted bytes for parser to interpret*/
.endm; .macro reloc.node.mask, o, va:vararg; rn.q = rn.q+1
  .if rn.q == rn.ctr;
    .hword rn.mask&0xFFFF; rn.mask = 0; rn.q = 0; rn.limit = rn.limit+64;
  .endif; /*write hword after completing a queue iteration*/
  .ifnb \o\va;
    .if \o >= rn.limit; reloc.node.mask \va \o; /*requeue if not in range*/
    .else;
      rn.this = ((rn.limit-\o )>>2)&15;
      rn.mask = rn.mask|(1<<rn.this);
      rn.ctr = rn.ctr-1; rn.q = rn.q-1
      reloc.node.mask \va
    .endif; /*pop offsets that are in range and add them to bitmask*/
  .endif; /*continue until all varargs are eliminated*/
.endm



.macro reloc.op, root, a, b
  _rn.start\@:
  .ifb \root; rn.op = rn.op | 0x10; .endif
  .if (rn.op & (rn.op.table|rn.op.node))==(rn.op.table|rn.op.node) &

  .elseif (rn.op & rn.op.node)
    rn.linkcount =  0
    rn.start     = -1
    rn.end       = -1
    rn.pointers  =  0

  .elseif (rn.op)
  .endif

.endm;
rn.op = 0; rn.op.table = 1; rn.op.node = 2; rn.op.array = 4;
# +0 = disabled (no target for relocation)
# +1 = pointer table (a contiguous array of pointers)
# +2 = node structure (a structure that creates a linked list, tree, etc)
# +3 = pointer table of multiple node structures (of the same type)
# +4 = part of an array of other ops (using )



.macro rl.op, root, a, b

.endm; rl.op=0
m=31; b=0; .irp x, Done, Root, Multi, Base, Remote, Null, Mask, Table
  rl.m\x = 0x80000000 >> m; rl.b\x = b; rl.\x = 0; m=m-1; b=b+1
.endr; # enumerate bool and mask names







.macro hex, b, va:vararg;
  .ifb \b; hex.va \va;
  # if first arg is blank, then skip initializing hex size and alignment properties
  # - this allows 'hex,' with a ',' to continue from a previous 'hex' statement

  .else; _hex.start = .; hex.len = 0; hex.align=hex.align.def; hex.va \b, \va;
  # else, define start of length, and push variadic argument string to .va handler

  .endif; _hex.last = .; hex.len = _hex.last-_hex.start
  # on return, set end of length so that return property .len can be copied


.endm; .macro hex.va, a, va:vararg;
  # .va vararg handler handles an arbitrary number of arguments; popping one at a time (\a)

  .ifc \a, $; hex.align \va; .exitm; .endif
  # if entire argument is '$', then pass the next argument to a special alignment handler
  .ifc \a, %; hex.exp \va; .exitm; .endif;
  # if the argmuent is '%', then pass the next argument to a special expression handler
  # else, handle this argument by parsing each character as a hex literal

  .irpc c, \a;
    # for each character...
    .ifnc \c, .; hex.exp 4, 0x\c
    # if the character IS NOT '.' then assume it is a hex literal (4-bit expression)
    .else; hex.exp,,; hex.alignmask=((.-_hex.anchor)&(1<<(hex.align)-1))
      .if hex.alignmask; hex.exp ((1<<hex.align)-hex.alignmask)<<3; .endif
      # if the character IS '.', then make an alignment using to the current .align parameter
    .endif;

  .endr; .ifnb \va; hex.va \va; .endif
  # recursively continue if another argument exists


.endm; .macro hex.exp b=(8-hex.bits)&7, v=0, va:vararg;
  # .exp expression handler puts an int of a known bit size into the byte buffer
  # - if no \b bit size is specified, the remaining bits in byte buffer are filled
  # - if no \v value is specified, zero is assumed
  # - sizes over 32 bits are accepted, but values over 32 bits are not valid

  .ifc \b, .; hex.buf (4-hex.bits)&3, 0; hex.va \v, \va; .exitm; .endif; hex.b=\b; hex.v=\v;
  # if bit size is specified as '.', then align to nibble using only 1 argument
  # - evaluate \b and \v by copying them to symbols
  #  - this requires that any given expression is absolute at the time of being written

  .rept (hex.bits + \b + (7&(\b!=0)))>>3;
  # else, for each byte to be buffered...

    .if hex.bits+hex.b <= 8;
      hex.s=hex.b;
      hex.buf hex.s, hex.v;
      # if the remaining bits + the buffer to not make up a whole byte, then just append them

    .else; hex.s=(8-hex.bits);
      .if 33 > hex.b;
        hex.buf hex.s, hex.v>>((hex.b-hex.s));
        .else; hex.buf hex.s, 0; .endif
      # else, add the remaining bits needed to fill the byte buffer
      # - use 0 for the value if bit index above 32
      # - hex.s is used to create a temporary memory of hex.b after hex.b is updated

    .endif; hex.b=hex.b-hex.s;
    .if hex.b<32;
      hex.v=hex.v&((1<<hex.b)-1);
    .endif
    # mask value memory with each buffer update if 31 or fewer bits are remaining

  .endr; .ifnb \va; hex.va \va; .endif
  # continue variadic macro check if \va was given


.endm; .macro hex.buf b, v;
  hex.buf=(hex.buf<<\b)|(\v&((1<<\b)-1));
  hex.bits=hex.bits+\b;
  # .buf buffer handler takes a measured amount of bits frin .exp and ORs them into a buffer
  # - bit total must never exceed 8, so arguments must be taken from .exp

  .if hex.bits==8;
    hex.bits=0;
    .byte hex.buf&0xFF;
    hex.buf=0;
  .endif
  # if buffer is now at 8 bits, then emit them as a byte
  # - only absolute expressions may be used to construct these bits


.endm; .macro hex.align, a, va:vararg; hex.align=\a; hex.va ., \va;
  # .align alignment handler updates the .align property inline with the vararg string
  # - can be invoked with '$'
  # - use '$,n' to create an alignment akin to the directive '.align n'

.endm; _hex.anchor=.; hex.align.def=2; hex.align=2; hex.bits=0; hex.buf=0
# hex anchor gives the definition a relative base to use to avoid relying on the .align directive
# - using .align causes location values (labels, or memory of '.') to become non-constant
#  - non-constant values can't be evaluated until the program has finished


# above is prototype...













.macro hex, b, va:vararg;
  .ifb \b; hex.va \va;
  .else; _hex.start = .; hex.len = 0; hex.align=hex.align.def; hex.va \b, \va;
  .endif; _hex.last = .; hex.len = _hex.last-_hex.start;
.endm; .macro hex.va a, va:vararg; hex.va=-1; hex.pre=0; hex.op=0; hex.cut=0;
  .ifnb \a;
    .irpc c, \a; hex.va=hex.va+1;
      .if hex.va==0;
        .ifc \c, (; hex.op=1; .endif;
        .ifc \c, 0; hex.pre=hex.pre+1; .endif;
      .elseif hex.va==1;
        .ifc \c, x; hex.pre=hex.pre+1; .endif;
      .else; .exitm; .endif;
    .endr; .if hex.op; hex.exp \a, \va; .exitm; .endif;
    .if hex.pre==2; hex.cut=hex.cut+hex.pre; .endif; hex.va=-1;
    .irpc c, \a; hex.va=hex.va+1;
      .if hex.va >= hex.cut;
        .ifnc \c, .;
          .if hex.op==0; hex.exp 0x\c, 4;
          .else;
            .if hex.op>=2; hex.align 0x\c; .endif;
            .if hex.op>=3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif;
            .if hex.op==1; hex.exp,,; hex.exp 0x\c, 4; .endif;
            hex.op=0;
          .endif;
        .else; hex.op=hex.op+1; .endif;
      .endif;
    .endr;
    .if hex.op;
      .if hex.op==1; hex.exp,,;
      .elseif hex.op==2; hex.align hex.align.def;
      .elseif hex.op==3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif;
    .endif; hex.va \va;
  .endif;
.endm; .macro hex.exp, v=0, b=(8-hex.bits)&7, va:vararg;
  .ifnc \b, 0x4;
    .ifnc \b, hex.exp.op; hex.exp.op=0;
      .irpc c, Bb;   .ifc \b, \c; hex.exp,,; hex.exp.op=8; .exitm;.endif;.endr;
      .irpc c, SsHh; .ifc \b, \c; hex.exp,,; hex.exp.op=16; .exitm;.endif;.endr;
      .irpc c, IiWw; .ifc \b, \c; hex.exp,,; hex.exp.op=32; .exitm;.endif;.endr;
      .if hex.exp.op; hex.exp \v, hex.exp.op, \va; .exitm; .endif;
    .endif;
    .ifc \b, .; hex.exp \v,, \va; .exitm; .endif;
    .ifc \b, ..; hex.align hex.align.def; hex.exp \v, ..., \va; .exitm; .endif;
    .ifc \b, ...; hex.align; hex.exp \v, hex.alignp+((8-hex.bits)&7), \va; .exitm; .endif;
    .if hex.bits==0;
      .if \b==8; .byte \v&0xFF; .exitm;
      .elseif \b==16; .hword \v&0xFFFF; .exitm;
      .elseif \b==32; .long \v; .exitm;
      .endif;
    .endif;
  .endif;
  hex.v=\v; hex.b=\b;
  .rept (hex.bits + \b + (7&(\b!=0)))>>3;
    .if hex.bits+hex.b <= 8;
      hex.s=hex.b;
      hex.buf hex.s, hex.v;
    .else; hex.s=(8-hex.bits);
      .if 33 > hex.b;
        hex.buf hex.s, hex.v>>(hex.b-hex.s);
      .else; hex.buf hex.s, 0; .endif;
    .endif; hex.b=hex.b-hex.s;
    .if hex.b<32; hex.v=hex.v&((1<<hex.b)-1); .endif;
  .endr; .ifnb \va; hex.va \va; .endif;
.endm; .macro hex.buf b, v;
  hex.buf=(hex.buf<<\b)|(\v&((1<<\b)-1)); hex.bits=hex.bits+\b;
  .if hex.bits==8; hex.bits=0; .byte hex.buf&0xFF; hex.buf=0; .endif;
.endm; .macro hex.align, a;
  hex.alignz=((8-hex.bits)&7);
  .ifnb \a; hex.align=\a; .endif;
  hex.alignz=((.-(_hex.anchor-((hex.alignz!=0)&1)))&(1<<(hex.align)-1));
  hex.alignp=((1<<hex.align)-hex.alignz)<<3;
  .if hex.alignz; hex.alignz=hex.alignp; .endif;
.endm; _hex.anchor=.; _hex.start=.; hex.align.def=2; hex.align=2; hex.bits=0; hex.buf=0;

.macro hex, b, va:vararg; .ifb \b; hex.va \va; .else; _hex.start = .; hex.len = 0; hex.align=hex.align.def; hex.va \b, \va; .endif; _hex.last = .; hex.len = _hex.last-_hex.start; .endm; .macro hex.va a, va:vararg; hex.va=-1; hex.pre=0; hex.op=0; hex.cut=0; .ifnb \a; .irpc c, \a; hex.va=hex.va+1; .if hex.va==0; .ifc \c, (; hex.op=1; .endif; .ifc \c, 0; hex.pre=hex.pre+1; .endif; .elseif hex.va==1; .ifc \c, x; hex.pre=hex.pre+1; .endif; .else; .exitm; .endif; .endr; .if hex.op; hex.exp \a, \va; .exitm; .endif; .if hex.pre==2; hex.cut=hex.cut+hex.pre; .endif; hex.va=-1; .irpc c, \a; hex.va=hex.va+1; .if hex.va >= hex.cut; .ifnc \c, .; .if hex.op==0; hex.exp 0x\c, 4; .else; .if hex.op>=2; hex.align 0x\c; .endif; .if hex.op>=3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif; .if hex.op==1; hex.exp,,; hex.exp 0x\c, 4; .endif; hex.op=0; .endif; .else; hex.op=hex.op+1; .endif; .endif; .endr; .if hex.op; .if hex.op==1; hex.exp,,; .elseif hex.op==2; hex.align hex.align.def; .elseif hex.op==3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif; .endif; hex.va \va; .endif; .endm; .macro hex.exp, v=0, b=(8-hex.bits)&7, va:vararg; .ifnc \b, 0x4; .ifnc \b, hex.exp.op; hex.exp.op=0; .irpc c, Bb;   .ifc \b, \c; hex.exp,,; hex.exp.op=8; .exitm;.endif;.endr; .irpc c, SsHh; .ifc \b, \c; hex.exp,,; hex.exp.op=16; .exitm;.endif;.endr; .irpc c, IiWw; .ifc \b, \c; hex.exp,,; hex.exp.op=32; .exitm;.endif;.endr; .if hex.exp.op; hex.exp \v, hex.exp.op, \va; .exitm; .endif; .endif; .ifc \b, .; hex.exp \v,, \va; .exitm; .endif; .ifc \b, ..; hex.align hex.align.def; hex.exp \v, ..., \va; .exitm; .endif; .ifc \b, ...; hex.align; hex.exp \v, hex.alignp+((8-hex.bits)&7), \va; .exitm; .endif; .if hex.bits==0; .if \b==8; .byte \v&0xFF; .exitm; .elseif \b==16; .hword \v&0xFFFF; .exitm; .elseif \b==32; .long \v; .exitm; .endif; .endif; .endif; hex.v=\v; hex.b=\b; .rept (hex.bits + \b + (7&(\b!=0)))>>3; .if hex.bits+hex.b <= 8; hex.s=hex.b; hex.buf hex.s, hex.v; .else; hex.s=(8-hex.bits); .if 33 > hex.b; hex.buf hex.s, hex.v>>(hex.b-hex.s); .else; hex.buf hex.s, 0; .endif; .endif; hex.b=hex.b-hex.s; .if hex.b<32; hex.v=hex.v&((1<<hex.b)-1); .endif; .endr; .ifnb \va; hex.va \va; .endif; .endm; .macro hex.buf b, v; hex.buf=(hex.buf<<\b)|(\v&((1<<\b)-1)); hex.bits=hex.bits+\b; .if hex.bits==8; hex.bits=0; .byte hex.buf&0xFF; hex.buf=0; .endif; .endm; .macro hex.align, a; hex.alignz=((8-hex.bits)&7); .ifnb \a; hex.align=\a; .endif; hex.alignz=((.-(_hex.anchor-((hex.alignz!=0)&1)))&(1<<(hex.align)-1)); hex.alignp=((1<<hex.align)-hex.alignz)<<3; .if hex.alignz; hex.alignz=hex.alignp; .endif; .endm; _hex.anchor=.; _hex.start=.; hex.align.def=2; hex.align=2; hex.bits=0; hex.buf=0;
# --- hex - a macro for emitting arbitrary length hex literal strings and small integers in ASM
#   - if first char is a comma ',' then the previous hex table is continued
#   - else, a new hex table is started
#     - this isn't important if you don't need to use the .len and .align properties
# Any hex literal is accepted as part of any number of arbitrary-length strings
#   - Emits 8 bits at a time -- reads 4 bits at a time
#   - '0x' prefix is accepted for each given string, but is not required
#   - Strings do not need to be in quotes, but they can be
#   - Strings do not need to be aligned to normal integer sizes
#     - partial bytes are memorized, and emitted when bit buffer reaches 8 bits
# Use resulting 'hex.len' property to copy the byte length of your emitted hex table
#   - copy length with a statement like  'myLen = hex.len;'
#   - Use a comma after 'hex' call, like 'hex,' to continue from the beginning of last 'hex' call
#     - Length is concatenated from beginning of the last call made without a beginning comma
#     - Alignment properties are preserved in continued tables
# Use  '.'  to dump the bit buffer by adding padding bits, emitting a partial byte
# Use  '..n'  to change the alignment to 1<<'n' bytes
#   - Only 1 'n' char is read, so max is 'F' (1<<15)
#   - if 'n' is a space or a comma, then default (n=2) is used
#     - The default alignment is n=2, which is a word alignment (4-byte, 32-bit)
#     - Default alignment may be changed from the  'hex.align.def'  symbol
# Use  '...n'  to change the alignment, and then align with padding bytes (if not aligned)
#   - Only 1 'n' char is read, so max is 'F' (1<<15)
#   - if 'n' is a space or a comma, then last alignment is used instead of a new alignment
#     - default  'hex.align.def'  is used if an alignment hasn't been set for this 'hex' table
# Use  '(expr),bits,'  to add a masked expression into a hex string with a bit size of 'bits'
#   -  'expr' must be wrapped in parentheses '()' and must use commas to separate the arguments
#     - Spaces before or after '()' are ignored in expression strings, but not commas
#   -- if 'bits'=='.' then the bit size is set to the remainder of the bit buffer (up to 7 bits)
#   -- if 'bits'=='..' then the bit size is set to the default byte alignment size
#   -- if 'bits'=='...' then the bit size is set to the current byte alignment size
#   -- if 'bits'== char [bB], [sShH], [iIwW] then make a byte-aligned 8, 16, 32-bit integer
#     - 8, 16, and 32-bit ints use '(expr)' directly with a .byte, .hword, and .long directive
#       - By skipping evaluation in the buffer, these save unevaluated expression strings
#         - This allows non-absolute expressions to resolve without pre-emptive evaluation
#           - Things like forward-reaching labels or undefined symbols create non-abs expressions
#           - If not aligned, non-abs expressions will make errors when evaluated in the buffer
#           -- in other words:  use aligned int sizes to avoid non-abs expression errors

.macro hex, b, va:vararg; /*v1*/
# main method can be called to interface with the static hex emitter object through arg strings
# - this macro checks the first argument for a blank to trigger a special continuation syntax
#   - this can be triggered if the 'hex' method is called with a comma, like 'hex,'

  .ifb \b;
  # if continuing previous hex call...

    hex.va \va;
    # the previous call's _hex.start label is preserved, adding to the hex.len size
    # the previous call's .align property is preserved as well, if it was modified

  .else; _hex.start = .; hex.len = 0; hex.align=hex.align.def; hex.va \b, \va;
  # else if not continuing... then reset length and alignment properties

  .endif; _hex.last = .; hex.len = _hex.last-_hex.start
  # after returning from recursive .va method; update '_hex.last' to calculate new length

.endm; .macro hex.va a, va:vararg; hex.va=-1; hex.pre=0; hex.op=0; hex.cut=0
# .va method handles each variadic argument
# - properties  .va, .pre, .op, .cut  are reset on each recursive iteration

  .ifnb \a;
  # if argument isn't blank...
  # - blank arguments will terminate the argument sequence
  # - this causes a trailing ',' in the varg string to be acceptable

    .irpc c, \a; hex.va=hex.va+1;
    # for each character in string...
    # - in first pass, we exit loop after 2nd char because we're only checking for a prefix

      .if hex.va==0;
        .ifc \c, (; hex.op=1; .endif;
        # if first char is '(' then .op == 1

        .ifc \c, 0; hex.pre=hex.pre+1; .endif;
      .elseif hex.va==1;
        .ifc \c, x; hex.pre=hex.pre+1; .endif;
        # if 1st and 2nd chars are '0x' then .pre == 2

      .else; .exitm; .endif;
      # on 3rd char, exit loop
      # - .exitm  exits  .rept, .irp, or .irpc  loops in addition to  .macro  blocks

    .endr; .if hex.op; hex.exp \a, \va; .exitm; .endif;
    # at end of loop, if .op is true, then feed arg directly into variadic .exp method
    # - the .exitm here exits this macro call, since the arg \a is handled in a separate macro
    # - the .exp method has been designed to pass trailing arguments \va back to another .va call


    .if hex.pre==2; hex.cut=hex.cut+hex.pre; .endif; hex.va=-1
    # else, if .pre == 2, then .cut is set to skip the first 2 characters in 2nd pass
    # - reset the .va property, which stores the current .va method character index

    .irpc c, \a; hex.va=hex.va+1;
    # for each character in string...
    # - this time we know if it is prefixed, and that it is not an expression to be evaluated

      .if hex.va >= hex.cut;
      # only for un-cut prefix characters...

        .ifnc \c, .;
          .if hex.op==0; hex.exp 0x\c, 4;
          # if character is NOT '.' (most likely case) -- then consider it a 4-bit mask
          # - this is the most likely case, so (.ifnc && .if .op==0) is used to check this first

          .else;
          # else, if op!=0, then this is the first character after a sequence of '.' characters

            .if hex.op>=2; hex.align 0x\c; .endif
            # if '..n' or '...n' then \c is 'n'
            # - 'n' is used to set a new alignment for this hex table
            # - 'n' can be a number between 0...F  (1<<0...1<<15 bytes)

            .if hex.op>=3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif
            # if '...n' then align to new 'n' alignment
            # - '..n' does not invoke the alignment that is set; only saves it

            .if hex.op==1; hex.exp,,; hex.exp 0x\c, 4; .endif;
            # if '.' then dump then align the bit buffer, and continue hex literals
            # - \c in this case is just another hex literal; no 'n'

            hex.op=0
            # .op property is reset to 0 on first non-'.' char

          .endif
        .else; hex.op=hex.op+1; .endif;
        # else, if character IS '.', then increment the .op iterator

      .endif
      # (cut prefix characters are ignored)

    .endr;
    # end of loop (all characters are parsed, no exit)


    .if hex.op;
    # if loop ended without resolving .op, then there was no character to provide an inline \c
    # - handle defaults with post-loop check

      .if hex.op==1; hex.exp,,;
      # '.' functions just like its in-line counterpart because it has no 'n'

      .elseif hex.op==2; hex.align hex.align.def;
      # '..' sets the alignment back to default, which is n=2
      # - this will be used in next use of the '...' alignment operation

      .elseif hex.op==3; hex.exp,,; hex.align; hex.exp, hex.alignz; .endif;
      # '...' aligns to the last set alignment size with '..n' or '...n', or default n=2
      # - 'hex' calls without the continuation comma 'hex,' will reset this to default n=2

    .endif; hex.va \va
  .endif
  # at end of non-blank argument handle, call self to handle any additional arguments
  # - if the argument is blank, it will skip over the entire macro and terminate

.endm; .macro hex.exp, v=0, b=(8-hex.bits)&7, va:vararg;
# .exp method handles passing integers to the buffer handler with a known bit size
# - if the bit size  \b  is a recognizable op, then it is handled as a special case

  .ifnc \b, 0x4;
  # skip op evaluation if \b is just a hex literal
  # - this is the most common case, so it will prevent unnecessary checks in most cases

    .ifnc \b, hex.exp.op; hex.exp.op=0;
    # if \b op is not the symbol for the .exp.op property, then reset the .exp.op property
    # - allows recursion to handle setting op names with known bit size constants

      .irpc c, Bb;   .ifc \b, \c; hex.exp,,; hex.exp.op=8; .exitm;.endif;.endr
      # if 'b' or 'B' for 'byte',  then set hex.exp.op=8

      .irpc c, SsHh; .ifc \b, \c; hex.exp,,; hex.exp.op=16; .exitm;.endif;.endr
      # if 's', 'S', for 'short', or 'h', 'H', for 'hword', then set hex.exp.op=16

      .irpc c, IiWw; .ifc \b, \c; hex.exp,,; hex.exp.op=32; .exitm;.endif;.endr
      # if 'i', 'I', for 'int', or 'w', 'W', for '32-bit word', then set hex.exp.op=32

      .if hex.exp.op; hex.exp \v, hex.exp.op, \va; .exitm; .endif
      # if hex.exp.op !=0, then call self with the value stored in hex.exp.op, then exit this call

    .endif;
    # if no integer ops were found, then proceed with alignment op checks

    .ifc \b, .; hex.exp \v,, \va; .exitm; .endif;
    # if bit size is '.', then fill the remainder of the bit buffer with value \v and emit it
    # - if bit buffer is already aligned to 0, then nothing is emitted

    .ifc \b, ..; hex.align hex.align.def; hex.exp \v, ..., \va; .exitm; .endif;
    # if bit size is '..', then fill the remainder of the default byte alignment (1<<2 bytes)
    # - if bytes are already aligned, then the value is still emitted at the next alignment

    .ifc \b, ...; hex.align; hex.exp \v, hex.alignp+((8-hex.bits)&7), \va; .exitm; .endif;
    # if the bit size is '...', then fill the remainder of last used byte alignment (1<<n bytes)
    # - if bytes are already aligned, then the value is still emitted at the next alignment

    .if hex.bits==0;
    # if the bit buffer is aligned to 0, then check for special numerical evaluations
    # - these cause the whole \v expression to be passed directly to integer emitter directives
    #   - by doing this, \v is not evaluated by .v for use in the bit buffer

      .if \b==8; .byte \v&0xFF; .exitm
      .elseif \b==16; .hword \v&0xFFFF; .exitm
      .elseif \b==32; .long \v; .exitm
      .endif;
      # handle 8, 16, and 32-bit aligned ints without evaluation in the bit buffer symbols
      # - these can be invoked with [bBsShHiIwW] chars to evaluate non-absolute expressions
      # - they can only be invoked with the  '(expr),bits'  argument style from the 'hex' call

    .endif
  .endif;
  # end of operations check
  # - if \b == 4, then all of the above is just skipped


  hex.v=\v; hex.b=\b
  # evaluate arguments to summarize expressions for splitting into segments in bit buffer

  .rept (hex.bits + \b + (7&(\b!=0)))>>3;
  # for each byte that needs to be emitted, and/or each partial byte that needs to be remembered
  # - in this loop, .b holds decrementing memory of remaining bits in given \b argument
  # - .v holds the remaining bits of the masked value in given \v argument

    .if hex.bits+hex.b <= 8; hex.s=hex.b; hex.buf hex.s, hex.v;
    # if remaining bits in expression mask will not overflow the buffer
    # .s (shift amount) becomes equal to remaing .b (bits)

    .else; hex.s=(8-hex.bits);
    # else, if overflow requires segments; .s fills the remaining bits in the bit buffer

      .if 33 > hex.b; hex.buf hex.s, hex.v>>(hex.b-hex.s);
      # if mask is at 32 bits or under, then include .v in the bit buffer iteration

      .else; hex.buf hex.s, 0; .endif
      # if mask is larger than possible input value, then just use 0 in place of .v
      # - when .b decrements below 32 bits, the value in .v will be used instead

    .endif; hex.b=hex.b-hex.s;
    # decrement .b by .s

    .if hex.b<32; hex.v=hex.v&((1<<hex.b)-1); .endif
    # update value if the bit mask is below 32

  .endr; .ifnb \va; hex.va \va; .endif
  # at end of buffer input loop, pass any trailing args back to another call of hex.va
  # - this allows the .exp method to optionally continue a variadic argument chain


.endm; .macro hex.buf b, v;
# .buf method depends on .exp to give it the correct bit size in \b
# - if \v is larger than bit size \b, it will be masked

  hex.buf=(hex.buf<<\b)|(\v&((1<<\b)-1)); hex.bits=hex.bits+\b;
  # .buf property holds the current bit buffer value
  # - shift existing value by \b, concat with masked value, and update .bits property

  .if hex.bits==8; hex.bits=0; .byte hex.buf&0xFF; hex.buf=0; .endif
  # if last incr was enough to fill the bit buffer, emit 8 bits as a byte

.endm; .macro hex.align, a;
# .align method is a leaf that can be used to update the .align properties
# - hex.align carries the byte alignment (1<<n)
# - hex.alignz is used to store the return calculation for a zeroed (shy) alignment
# - hex.alignp is used to store the return calculation for a pushed (greedy) alignment

  hex.alignz=((8-hex.bits)&7);
  # default selects remaining bits in bit buffer
  # - mask &7 creates .alignz value

  .ifnb \a; hex.align=\a; .endif;
  # if a value has been given to method, use it to set a new alignment

  hex.alignz=((.-(_hex.anchor-((hex.alignz!=0)&1)))&(1<<(hex.align)-1));
  # calculate .alignz first using masked '_hex.anchor' delta to create a relative alignment
  # - the relative alignment prevents some inputs from becoming non-constant

  hex.alignp=((1<<hex.align)-hex.alignz)<<3;
  # calculate .alignp by shifting to create a bit size

  .if hex.alignz; hex.alignz=hex.alignp; .endif
  # if .alignz is not 0, then .alignz = .alignp
  # - this logic allows .alignz to remain zero in cases of perfect alignment
  # - .alignp will hold the exact alignment size in cases of perfect alignment

.endm; _hex.anchor=.; _hex.start=.; hex.align.def=2; hex.align=2; hex.bits=0; hex.buf=0
# static properties are set after method definitions, creating the static 'hex' object
# - the '_hex.anchor' label variable should be placed at the base of your ASM section (PC=0)
#   - normally, the top of your program is good enough for this
#   - alternatively, you can re-assign 'hex.anchor' to another location to affect byte alignment




# good prototype above
# - uses variadic macros, and nesting depth is risky
# - redesign as a .irp loop with appropriate properties
# - redesign expr syntax to use (expr, bits) with a 2-step parse
# - redesign \va carries to use state properties instead




.macro hex, b, va:vararg; /*v2*/
# hex is a user-level macro for interfacing with the hex emitter object
# - it uses methods .exp, .buf, .align, and .reset to create behaviors for the object
# - this main method breaks apart given arguments like events that trigger these behaviors
# ---  ARGS -- any number of strings; optionally quoted; optionally split by spaces or commas
# ---          n = inline 'hex literal' -- 4-bit integer
#                -- n is valid if it matches: (0x)?[0-9a-fA-F]+
#                 - any number of these can be strung together, with an optional '0x' prefix
#                   - terminate with spaces ' ' and/or commas ',' (or newlines ';')
#                     - additional strings or arguments can be concattenated after termination
#                     - commas are needed to concatenate masked expressions ', (m, e),'
# ---       ...n = inline 'byte alignment' syntax
#                -- aligns to the next (1<<n) bytes
#                -- lazy alignment -- only emits when unaligned
#                 - if n is a space or a comma '... ' then previous alignment is used (default n=2)
#                 - n is a single hex literal, so max is (1<<15)
#                 - this and other '.' syntaxes can be used inline with other hex literals
# ---        ..n = inline 'set byte alignment' syntax
#                -- assigns alignment to (1<<n) bytes, but does not invoke the alignment
#                 - if n is a space or a comma '.. ' then the default 'n=2' is assigned
# ---          . = inline 'bit alignment' syntax
#                -- aligns the bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - on alignment, a partial byte is emitted with padding 0s on the little-end
# ---    (m, e), = masked expression -- m-bit integer
#                -- concats an 'm'-bit integer from evaluated expression 'e'
#                 - args must be wrapped in parentheses, and separated by commas
#                 - parentheses must also be separated by commas if neighbor args contain numbers
#                 - 'e' can only express 32 bits, but 'm' can be set higher to create padding
#                   - emitted value appears on the little-end of the resulting mask
#                   - padding appears on the big-end of the resulting mask
# ---  (..., e), = byte aligned expression
#                -- like '(m, e),' but emitted value is aligned to byte alignment
#                -- greedy alignment -- proceeds to next alignment if already aligned
# ---   (.., e), = default aligned expression
#                -- like '(..., e),' but uses the default byte alignment (1<<2; word alignment)
#                -- greedy alignment -- proceeds to next alignment if already aligned
#                 - default can be changed by assigning hex.adef=(new default)
#                   - this default is used to reset the hex table alignment in new tables
# ---    (., e), = buffer aligned expression
#                -- concats to remaining bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - mask size will be between 0 and 7 bits, depending on current buffer contents
# ---     (, e), = nibble aligned expression
#                -- concats to next 4-bit point in the bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - mask size will be between 0 and 3 bits, depending on current buffer contents
#                 - this may be used to realign the hex literal parser halfway into the bit buffer
# ---        fp, = floating point mode
#                -- all inputs following this will be read as floating points; like '1.0' or '1'
#                 - use 'hex,' to return to hex mode
# ---       str, = null terminated string mode -- ascii with null '00' bytes at end
#                -- all inputs following this will be read as strings
#                 - multiple strings may be given in sequence, and each will be given a null
#                   - if strings are not in quotes, spaced words will be emitted with nulls
#                 - use 'hex,' to return to hex mode
# ---       hex, = return to hex literal mode -- terminate 'str, ' or 'fp, ' modes
#                -- alternatively, just use a blank argument: ',,' or ' "" '
#                 - mode is reset in-between each call to the 'hex' macro
# --- ;ASM; hex, = inline Assembly -- any number of ASM lines concatenated with newlines
#                -- include other directives or macros in your hex table
#                 - real newlines or semicolons ';' may be used to concatenate ASM lines
#                 - calls to 'hex' that start with a comma 'hex,' contiue the previous table
# ---    _label, = label name
#                 - create a new label (variable) that points to current location
#                 - must start with a '_' to trigger the syntax
# ---         @, = set anchor -- to current PC location
#                -- this is the relative base for alignment used in '...' and '..' keywords
#                 - setting anchor to a new position can be useful for relative alignments
# ---        @@, = reset anchor -- to default location
#                 - default location is the location of the object definition

  .ifb \b\va; hex.reset; .endif
  .ifnb \b; hex.reset; .endif;
  .irp a \b, \va;
    .ifnb \a; hex.ch=-1; hex.pfx=0;
    # for each non-blank arg \a in varargs...

      .if hex.op==1; hex.op=0; .endif
      # return to normal operation state '.op=0' if previous arg triggered '.op=1'

      .ifc \a, @; hex.reset .; hex.op=1; .endif
      # if a '@' keyword was found, set anchor to current position, and trigger '.op=1'
      # - reset anchor to (self), and skip this argument

      .ifc \a, fp; hex.op='f; .endif;
      #

      .if hex.op==0;
      # if in normal operation state...
        .irpc c, \a; hex.ch=hex.ch+1
        # check for prefix...
          .if hex.ch==0;
            .ifc \c, 0; hex.op='0; .endif
            .ifc \c, (; hex.op='(; .endif
              # if a '(' was found, then check for keywords in expression syntax...
          .elseif (hex.ch==1)&&(hex.op=='0);
            .ifc \c, x; hex.op=0; hex.pfx=2; .endif
            # if a '0x' was found, literal parse skips first 2 chars
          .else; .exitm; .endif
        .endr;
      .endif

      .if hex.op==0;
      # for normal operation state...
        .irpc c, \a
          .ifnc \c, .;
          # for each non-'.' char...

            .if hex.op==0; hex.buf 4, 0x\c
            # if no ellipses op, assume hex literal (most common case)
            .elseif hex.op==1; hex.exp ((8-hex.bit)&7)+4, 0x\c
            # - if 1 inline dot  '.n' then lazy align the bit buffer before next literal \c
            .elseif hex.op==2; hex.align 0x\c;
            # - if 2 inline dots '..n' then set byte alignment to 1<<n, where n=\c
            .elseif hex.op==3; hex.align 0x\c; hex.exp hex.alaz;
            # - if 3 inline dots '...n' then set byte alignment to 1<<n, then lazy align
            .endif; hex.op=0
          .else; hex.op=hex.op+1; .endif
          # else count ellipses dots '.' before next non-'.' char

        .endr
        # if end of chars, but ellipses was unhandled; handle ellipses op without input char...

        .if hex.op==1; hex.exp,,
        # - if 1 suffix dot  '.' then lazy align the bit buffer to next byte
        .elseif hex.op==2; hex.align hex.adef
        # - if 2 suffix dots '..' then set byte alignment back to default (1<<2)
        .elseif hex.op==3; hex.align; hex.exp hex.alaz
        # - if 3 suffix dots '...' then lazy align to current byte alignment
        .endif; hex.op=0
      .endif

      .if hex.op=='); hex.op=0; hex.exp hex.mask, (\a; .endif
      # if in expression arg2 state, load expression mask from arg1 and use arg2 directly

      .if hex.op=='(; hex.op=')
      # for expression arg1 state...
        .rept 1; hex.mask=0
        # select case for keyword arg translation...
          .ifc \a, (; hex.mask=(4-hex.bit)&3; .exitm;.endif
          # - if blank arg, then lazy align bit buffer to next nibble
          .ifc \a, (.; hex.mask=(8-hex.bit)&7; .exitm;.endif;
          # - if 1 dot  '.', then lazy align bit buffer to next byte
          .ifc \a, (..; hex.align hex.adef; hex.mask=hex.agrd; .exitm;.endif
          # - if 2 dots '..', then greedy align to default byte alignment (1<<2)
          .ifc \a, (...; hex.align hex.align; hex.mask=hex.agrd; .exitm;.endif
          # - if 3 dots '...', then greedy align to current byte alignment
          .irpc c, Bb; .ifc \a, (\c; hex.mask=8; .exitm;.endif;.endr;
          # - if byte, then set mask to 8-bit
          .irpc c, SsHh; .ifc \a, (\c; hex.mask=16; .exitm;.endif;.endr;
          # - if short/hword, then set mask to 16-bit
          .irpc c, IiWw; .ifc \a, (\c; hex.mask=32; .exitm;.endif;.endr;
          # - if int/word, then set mask to 32-bit
          .if hex.mask==0; hex.mask=\a ); .endif
          # else, read mask size directly
        .endr
      .endif

    .else; hex.op=1
    # blank args are skipped, and trigger a reset in the .op state
    # - blank args can be used to terminate an argument syntax

    .endif
  .endr
.endm; .macro hex.exp, m=(8-hex.bit)&7, e=0
# .exp method takes mask size \m and an expression \e and feeds it to .buf method
# - recursively calls self to handle different cases
#   - shallow recursion only requires a few passes in worst cases

  .if 33>(hex.bit+(\m)); hex.buf \m, \e;
  # if mask is small enough to emit value, pass it to the buffer to handle recursively
  # - only 32-bit values can be expressed in \e, so we assume OOB \m bits are zero
  # - if the value is greater than 32 bits, then the next cases are used to handle blank space

  .elseif hex.bit; hex.bitd=8-hex.bit; hex.exp hex.bitd; hex.exp (\m)-(hex.bitd), \e;
  # if unaligned, and size is larger than value; then align and retry
  # - this emits blank bits, and preserves \e for when the expression string is used
  #   - if more bits remain after alignment, then they are handled in the next case

  .else; .zero ((\m)-32)>>3); hex.exp 32, \e; .endif
  # speed through large blank spaces given to .exp with the .zero directive
  # - this emits blank bytes, and helps avoid deep recursion in .buf calls
  #   - the emitable 32 bits that remain are then handled by the first case

.endm; .macro hex.buf m, e, b
# .buf method inputs \e into the buffer by using a special symbol juggling act
# - recursively calls self to set up and handle each emitted byte, or store
#   - shallow recursion only requires 5 passes in worst case
#   - shift boundaries are used to create masks without
# - when the buffer must be stored, .buf takes turns assigning it to xbuf and ybuf
#   - this causes the resulting expression strings to avoid referencing their own symbol names
#   --- because of this, it's possible to express symbol names that have not been defined yet
#     -- forward labels, uninitialized variables, or non-constant values can buffered

  .ifb \b;
    .if \m; hex.buf \m, (\e)<<(32-\m), (\e)<<(32-\m)>>24; .endif
  # if \b was not provided, take it from initial expression

  .elseif (hex.bit==0)&(\m>0);
    .byte (\b)&0xFF;
    hex.buf (\m)-8, (\e)<<8, (\e)>>24
  # aligned bit buffer can emit bytes quickly by taking advantage of recursive expression string

  .elseif (hex.bit+(\m))<8; hex.bit=hex.bit+(\m)
  # small ints that do not fill the buffer will need to be juggled
  # - xbuf and ybuf can't be evaluated in .if statements, so ibuf is used to check iteration

    hex.ibuf=hex.ibuf^1
    .if hex.ibuf; hex.xbuf=(8-hex.bit)<<(\b)
    .else;        hex.ybuf=; .endif


  .else;

  .endif
.endm; .macro hex.align

.endm; .macro hex.reset, a;
  .ifnb \a; _hex.anchor=\a;
  .else; hex.exp,,; _hex.start=.; hex.len=0; hex.align=1<<hex.adef; .endif
.endm; hex.adef=2; hex.reset .; hex.reset
.irp p, pfx, op, elp, alaz, agrd, op, ch, ibuf, xbuf, ybufb, bit, mask, align; hex.\p = 0; .endr;
# hex - object attribute definitions





.macro hex, b, va:vararg; /*v2*/
# hex is a user-level macro for interfacing with the hex emitter object
# - it uses methods .exp, .buf, .align, and .reset to create behaviors for the object
# - this main method breaks apart given arguments like events that trigger these behaviors
# ---  ARGS -- any number of strings; optionally quoted; optionally split by spaces or commas
# ---          n = inline 'hex literal' -- 4-bit integer
#                -- n is valid if it matches: (0x)?[0-9a-fA-F]+
#                 - any number of these can be strung together, with an optional '0x' prefix
#                   - terminate with spaces ' ' and/or commas ',' (or newlines ';')
#                     - additional strings or arguments can be concattenated after termination
#                     - commas are needed to concatenate masked expressions ', (m, e),'
# ---       ...n = inline 'byte alignment' syntax
#                -- aligns to the next (1<<n) bytes
#                -- lazy alignment -- only emits when unaligned
#                 - if n is a space or a comma '... ' then previous alignment is used (default n=2)
#                 - n is a single hex literal, so max is (1<<15)
#                 - this and other '.' syntaxes can be used inline with other hex literals
# ---        ..n = inline 'set byte alignment' syntax
#                -- assigns alignment to (1<<n) bytes, but does not invoke the alignment
#                 - if n is a space or a comma '.. ' then the default 'n=2' is assigned
# ---          . = inline 'bit alignment' syntax
#                -- aligns the bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - on alignment, a partial byte is emitted with padding 0s on the little-end
# ---    (m, e), = masked expression -- m-bit integer
#                -- concats an 'm'-bit integer from evaluated expression 'e'
#                 - args must be wrapped in parentheses, and separated by commas
#                 - parentheses must also be separated by commas if neighbor args contain numbers
#                 - 'e' can only express 32 bits, but 'm' can be set higher to create padding
#                   - emitted value appears on the little-end of the resulting mask
#                   - padding appears on the big-end of the resulting mask
# ---  (..., e), = byte aligned expression
#                -- like '(m, e),' but emitted value is aligned to byte alignment
#                -- greedy alignment -- proceeds to next alignment if already aligned
# ---   (.., e), = default aligned expression
#                -- like '(..., e),' but uses the default byte alignment (1<<2; word alignment)
#                -- greedy alignment -- proceeds to next alignment if already aligned
#                 - default can be changed by assigning hex.adef=(new default)
#                   - this default is used to reset the hex table alignment in new tables
# ---    (., e), = buffer aligned expression
#                -- concats to remaining bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - mask size will be between 0 and 7 bits, depending on current buffer contents
# ---     (, e), = nibble aligned expression
#                -- concats to next 4-bit point in the bit buffer
#                -- lazy alignment -- only emits when unaligned
#                 - mask size will be between 0 and 3 bits, depending on current buffer contents
#                 - this may be used to realign the hex literal parser halfway into the bit buffer
# ---        fp, = floating point mode
#                -- all inputs following this will be read as floating points; like '1.0' or '1'
#                 - use ',,' ';hex, ' or a '0x' prefix to return to hex mode
# ---       str, = null terminated string mode -- ascii with null '00' bytes at end
#                -- all inputs following this will be read as strings
#                 - multiple strings may be given in sequence, and each will be given a null
#                   - if strings are not in quotes, spaced words will be emitted with nulls
#                 - use ';hex,' to return to hex mode, where ';' can be a newline
# --- ;ASM; hex, = inline Assembly -- any number of ASM lines concatenated with newlines
#                -- include other directives or macros in your hex table
#                 - the comma at end of 'hex,' begins a new hex call that continues prev table
#                 - real newlines or semicolons ';' may be used to concatenate ASM lines
# ---    _label, = label name
#                 - create a new label (variable) that points to current location
#                 - must start with a '_' to trigger the syntax
# ---         @, = set anchor -- to current PC location
#                -- this is the relative base for alignment used in '...' and '..' keywords
#                 - setting anchor to a new position can be useful for relative alignments
# ---        @@, = reset anchor -- to default location
#                 - default location is the location of the object definition


.macro hex, b, va:vararg;
  .ifb \b\va; hex.new.table; .endif
  .ifnb \b; hex.new.table; .endif;
  .irp a \b, \va;
    .ifnb \a; hex.suffix=0
    # for each non-blank arg '\a' in varargs '\va'...

    .if hex.pfmode; hex.chi=-1; hex.pfxbuf=0;
    # --- prefix parser - fast partial string checker
      .irpc c, \a;hex.chi=hex.chi+1; .if hex.chi<4; hex.pfbuf "'\c"; .endif; .endr
      # if the parse tree does not find a match, .pxfbuf int is cleared
      # - buffer max of 4 prefix chars, and count the rest in .chi (char index property)
      # else -- the buffer is interpreted by a .pfxop instance to continue parse
      # - the leaves of each chain can be used to trigger a user defined callback macro
      # - if the callback requires use of \a, it may specify it is a keyword callback

      hex.suffix=hex.chi;
      # loop counts string length to inform char parser of suffix position

    .endif;

    .if hex.exmode
    # --- extra operation - can be triggered by other callbacks that assign a value to .exmode
      hex.exop hex.exmode, \a
      # .exop uses evaluated decimal value literals from .exmode property to call another macro
      # - the given value must be registered using the .exmode method to link to another macro
      # - other callbacks from other mode operations can be used to control the .exmode property

    .endif;

    .if hex.chmode; hex.chi=-1
    # --- character parser - continues from point where prefix parser finished (or didn't start)
    # - can be influenced or overridden by .exop event

    .irpc c, \a
      .if hex.chskip; hex.chskip=hex.chskip-1
      .else; hex.chi=hex.chi+1

      .endif
    .endr



.macro hex.newkey, type, keyword, macro; hex.newkey=0
  .irp t, p pre pfx prefix; .ifc \type, \t; hex.newkey=0, "\keyword", "\macro"; .endif; .endr
  .irp t, k kw key keyword; .ifc \type, \t; hex.newkey=1, "\keyword", "\macro"; .endif; .endr
  .irp t, c ch char inline; .ifc \type, \t; hex.newkey=2, "\keyword", "\macro"; .endif; .endr
  .ifeq hex.newkey; hex.newkey=\type
  # property .newkey holds the type value
  # - type value can be directly given, or interpreted from the various names above

  hex.newkbuf=0; hex.newki=-1
  .irpc c, \keyword; hex.newki=hex.newki+1
    .if hex.newki<4; hex.newkbuf "'\c"; .
  .endr
.endm


##------------------------------------------------------------------------------------------------##
.ifndef def
# --- ifdef - alternative to .ifdef -- prevents assembly errors caused by nested .ifdef blocks
# - use to update properties 'def' and 'ndef' with the result of a safe '.ifdef' directive
.macro ifdef,     sym; .altmacro; ifdef.alt \sym; .noaltmacro; .endm; def=0
.macro ifdef.alt, sym; def=0; .ifdef sym; def=1; .endif; ndef=def^1; .endm
.endif;

ifdef parser.exists; .if ndef
# --- parser class object - makes parser objects
# - parsers can be programmed to interpret input strings or characters with other macros

# static properties:
.irp a, exists; parser.\a=1; .endr

# static methods:
.macro parser, self,  conc_pfx, conc_suf=", ", conc_vasuf,  proc_init, proc_cont,
# --- main class method -- creates new parser objects called by a name given in '\self'
# '\self' arg is the name of this new parser object, and is the only required argument
#   \self\(). is used to reference the namespace created for object attributes
# - '\()' creates a null character that is not included in the interpreted string
#   - this is needed to properly terminate the inserted literals from the '\self' arg
#   - '\()' is only needed if a character (like '.') comes after '\self' in the namespace

# '\conc' args may be used to modify the part of the first and last arg of all parsed strings
#   each parser input is broken into '\b' and '\va' so that the first arg can be checked
# - string is literally "\conc_pfx\b\conc_suf\va\conc_vasuf"
# The given concats will be applied to the input to generate the string fed to .irp loop
#   if left blank, '\conc' args concatenate nothing to the string
#   else they will be applied to the given inputs:
#   - \conc_pfx prefixes the first arg '\b'
#   - \conc_suf suffixes the first arg '\b'
#     - can also be used to give '\va' a prefix with custom \conc arguments
#     - default gives b a comma ', ' to keep the first argument separated in case of expressions
#   - \conc_vasuf suffixes the last arg in '\va'
#     - commas and spaces in '\va' are preserved by the :vararg keyword

# '\proc' args are used to generate the contents of a parser's main object method
#  - the defaults will function normally, but can be overridden to fine-tune a parser
#  - these defaults can only be changed when the parser object is defined

  ifdef \self\().exists; .if def; .exitm; .endif;
  # if parser '\self' already exists - then exit call and do nothing (nop)
  # - prevents attempting to define methods that already exist by name, which would throw errors

  .irp a, exists chmode; \self\().\a=1; .endr
  .irp a, premode postmode chbuf; \self\().\a=0; .endr
  # else, begin defining \self attributes...
  # - object properties are used to store parameters to be handled or updated by object methods
  # - these attributes are generated for each new parser
  # - object properties may have the same name as some object methods



  .macro \self, b, va:vararg
# --- main obj method - user level macro takes in parsable arguments
# - event methods that link programmable behaviors to this parser are triggered by args
# - args may be programmed to create opcode sequences, or parsable character sequences

  # first arg '\b' is checked for blank to determine if parser is continuing or re-initializing
    .ifb \b;\proc_cont;.endif; /*  \self, [args] : proc when continuing last stream*/
    .else;\proc_init;.endif;   /*  \self [args] : proc when initializing new stream*/
    .irp a \conc_pfx\b\conc_suf\va\conc_vasuf
      .ifnb \a;\self\().suffix=0
      # for each non-blank arg '\a' in constructed string...
        .if \self\().premode;\proc_pre;.endif
        # - (.premode != 0) triggers pre-parse proc string
        .if \self\().chmode;.irpc;\proc_ch;.endr;.endif
        # - (.chmode != 0) triggers character parse loop iteration proc string
        .if \self\().postmode;\proc_post;.endif
        # - (.postmode != 0) triggers post-parse proc string
      .else;\proc_null;.endif
      # - if arg was blank, trigger null proc string
    .endr
  .endm; .macro \self\().chbuf, ch; \self\().chbuf=\self\().chbuf<<8|\ch
  # --- .chbuf method - takes an input char "'\c" and interprets it like an integer
  # - .chbuf property holds the last 4 buffered 8-bit chars as part of a 32-bit value
  # - the most recent char is at mask position 0x000000FF
  .endm;


.endm; .macro parser.newkey, self,
# --- static .newkey method - can be used to generate a parser tree entry for a given keyword
# - type determines what kind of keyword is parsed:
#   0 = prefix keyword -- only the first 1-4 chars can be checked for a prefix
#         - inline parse may continue after point where prefix ends
#   1 = full keyword -- can contain virtually any number of chars
#         - first 4 chars are checked to narrow down name lookup macro size
#   2 =
.endm



# --- keyword ops - full argument string matches
# --- suffix ops - tail-end of inline ops, but with no arg chars
# - pre-defined argument state change, and argument count
# - run argument-less event

# --- prefix ops - state initializer for the inline parser
# --- inline ops - ops enabled by the 'inline' parser state
# - copy argument string or char







# --- ifalt object - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
.ifndef nalt; .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm; .endif
# --- ifdef object - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
.ifndef ndef;
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
  ifdef def
.endif;
# --- string objects - requires ifdef and ifalt

# for normal quoted strings " " in .noaltmacro mode:
.macro str, self, s;
# --- class method - makes new strings, or resets old ones

  ifdef \self\().isstr;
  .if ndef; \self\().isstr=1
    .macro \self;.endm;
    .macro \self\().copy;.endm;
    # if undefined, then define the initial attributes, including dummmy method names

    .macro \self\().stack, pfx:vararg; \self "\pfx";.endm
    .macro \self\().queue, suf:vararg; \self,, "\suf";.endm
    # --- .stack and .queue object methods - for appending a prefix or suffix vararg to string
    # - these use :vararg, which means that inputs do not need quotes
    #   - unquoted strings are susceptible to sensitive chars, like ':' ';' ''' '"' '\' or '='
    #   - spaces and commas will be preserved

  .endif; str.build \self "\s"; \self
  # call static .build class method to clear str mem and replace it with an optional arg

.endm;
.macro str.build, self, st
# --- static .build method - used to rebuild the methods of a target string object
# - string objects use this to update or clear themselves

  .purgem \self
  .purgem \self\().copy
  .macro \self, pfx, str="\st", suf;
  # --- main object method - destroys itself after passing a copy of its string to .build method

    ifalt; .if alt;.noaltmacro; \self \pfx, \str, \suf; .altmacro; .exitm; .endif
    # if .noalt string is called in .alt mode then call self again in the correct mode
    str.build \self, "\pfx\str\suf"
    # else, rebuild self with memory and concatenations

  .endm;
  .macro \self\().copy, s="\st", m, va:vararg;
  # --- .copy method - copies string memory and pushes it to a vararg stack
  # put 2 commas after '\m' to make a blank arg for the string to be copied
  # ex:  mystr.copy mymacro,, argument, sequence
  # - string will be copied to the blank spot after \m with no comma
  # - additional arguments can be stacked behind the blank argument

  .ifb \va;\m "\s";.else;\m "\s", \va;.endif
  # - avoid adding a comma to blank vararg stack, to prevent null arg entries

  .endm
.endm

# for nestable bracket strings << >, < >> in .altmacro mode:
.macro str.alt, self, s; ifdef.alt \self\().isstr;
  .if def; \self\().conc,, <\s>
  .else; \self\().isstr=2; .macro \self; .endm; str.new.alt \self,, <\s>; .endif
.endm;.macro str.new.alt, self, pf, st, su
  .macro \self\().conc, pfx, str=<\pf\st\su>, suf;
    ifalt; .if nalt;.altmacro; \self\().conc \pfx, \str, \suf; .noaltmacro; .exitm; .endif
    .purgem \self;
    .macro \self, s=<\pfx\str\suf>, m, va:vararg;
      .ifb \va;\m <\s>;.else;\m <\s>, \va;.endif
    .endm
  .endm;
  .macro \self\().stack, pfx:vararg; \self\().conc <\pfx>;.endm
  .macro \self\().queue, suf:vararg; \self\().conc,, <\suf>;.endm
.endm;



# good prototype above... but has too many string copy operations
# - try to reduce them by using callback macros, with cases built into the callback names

.ifndef nalt;
# --- ifalt object - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
  .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;
.endif
.ifndef ndef;
# --- ifdef object - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
  ifdef def
.endif
# ifalt and ifdef objects help solve issues

ifdef str.altm;
.if ndef
# --- str class - primitive support for string memory in GNU ASM
# the contents of this if block define a series of attributes that make a class called 'str'

.macro str, name, str:vararg; str.new \name, 0, \str
.endm;.macro str.alt, name, str:vararg; str.new \name, 1, \str
# --- static class methods - generates string objects
# 'str' class method creates a "quoted string" in .noaltmacro mode (the default mode)
# 'str.alt' class method creates a <<nestable>, <bracket string>> in .altmacro mode

.endm; .macro str.new, self, altm, str:vararg
# --- static .new method - internally handles building objects from class methods

  \self\().altm=\altm
  # update the .altm property, even if object has already been defined

  ifdef \self\().isstr
  # the existence of .isstr property means that a str object has already been defined
  # 'ifdef' object is used to test escaped symbol name without risking parsing errors
  # - '.ifdef' directive sometimes has trouble parsing '\', so 'ifdef' object is used instead
  # - logic is applied below with a second numerical evaluation of the resulting 'ndef' property

  .if ndef; \self\().isstr=1
  # if string object of this name has not been defined yet, then generate object attributes...
  # - the namespace \self and \self\().* turns into the given object name

    .macro \self, sfx, pfx, new; str.altm /*sample mode, and enter .altmacro mode*/
    # --- main object method - concatenate string memory with argument suffix and/or prefix string
    # input strings can only remain unquoted if they contain inoffensive source literals
    # - no commas, spaces, colons, semicolons, equals signs -- unless using escaped octal codes
    # - use quotes " " (or brackets < > in .alt mode) to avoid this limitation
    # leaving '\new' blank will cause the memorized string to be concatenated with inputs
    # - providing a string in '\new' will overwrite the string memory
    # if '\sfx' and/or '\pfx' are blank, then nothing is concatenated as a suffix and/or prefix
    # - you can leave blanks with commas, like ', , ' or just ',, '
    #   - if arg comes right after the macro name, then only 1 comma is used, like 'macroname, '
    #   - blank args are equiv to leaving a blank string, like "" or <>
    # static property 'str.altm' is used to create volatile memory of current altmode state
    # object property '\self\().altm' is used to remember the state given to the object
    # - these properties help maintain the correct macro mode when copying quoted strings

      \self\().cb 1 0 0 %\self().altm, \new, \sfx, \pfx
      # callback dispatch only requires evaluation of the .altm object property

    # 2 copy methods can be used to copy string memory into argument positions for a macro call:
    .endm;.macro \self\().copy, m, va:vararg; str.altm
      \self\().cb 0 0, %\self\().isstr, %\self\().altm,, \m, \va
      # --- .copy object method   : push str to vararg stack -  macroname [pasted str], ...
      # Copy a string to front of varargs for macro '\m'
      # - '\va' varargs can contain additional arguments that come after copied string

    .endm;.macro \self\().copyq, m, va:vararg; str.altm
      \self\().cb 0 1, %\self\().isstr, %\self\().altm,, \m, \va
      # --- .copyq object method  : push str to vararg queue -  macroname ..., [pasted str]
      # Copy a string to end of varargs for macro '\m'
      # Queueing allows chaining multiple str copies in a sequence
      # ex:  x.copy y.copy z.copy handle_xyz
      # - results in:  handle_xyz "\x", "\y", "\z"

    # 2 properties influence the behavior of the .copy and .copyq methods:
    # --- .isstr object property - controls whether copy is emitted as string or source literals
    # 0 = emit source literals -- will append string without quotes
    # 1 = emit str literals -- will wrap emitted string in either quotes " " or brackets < >
    # --- .altm object property - determines quote style
    # - set by class method 'str' or 'str.alt' on string initialization
    #   - property can be safely changed when string is blank, or when a clear is pending

    .endm;.macro \self\().stack, s:vararg; str.altm
      \self\().cb 1 0 1, %\self\().altm,, \s
    .endm;.macro \self\().queue, s:vararg; str.altm
      \self\().cb 1 1 1, %\self\().altm,, \s
    # --- .stack and .queue methods - assign raw source literals to front or end of string memory
    # input does not need to be quoted, making macro mode flexible when writing string
    # - characters like spaces and commas are accepted, but not colons, semicolons, or equals
    # quotes are preserved when passed to string, so avoid nesting " " quotes in a non-alt string
    # - use the pfx/sfx args in main object method to safely concat a "quoted string" to memory
    # - use str.alt to initialize a nestable string, if that's what you are trying to do

    .endm; .macro \self\().altm;.ifeq \self\().altm;.noaltmacro;.endif;
    # --- .altm object method - return to .noaltmacro mode if needed
    # this is used by the .cb method to modify the macro mode state to match the string quote type

    .endm;.macro \self\().cb# --- dummy
    # .cb is purged and redefined in str.build call, so we make a dummy to claim its name
    # - .cb method dispatches a memorized string to a specific subroutine method
    # - making this 1 extra string copy prevents str methods from needing to make 11 more

    .endm;
  .endif; str.build \self, \str; \self
  # (re)build string memory, and initialize the (re)instantiated object

.endm;.macro str.build, self, str:vararg
# --- static .build method - used to re-instantiate objects' .cb macros, for updating string

  .purgem \self\().cb
  .macro \self\().cb, rw, sq, av, an, mem=\str, va:vararg;
  # --- .cb method - memorizes string, gets rebuilt every time string updates
  # - dispatches object property-driven arguments to static class callback methods

    \self\().altm
    # update altmacro mode according to string property
    # - callback is coming from .altmacro mode, so this resets to .noaltmacro mode if .altm is 0

    str.cb$\rw\sq\av\an \mem, \va
    # construct callback name and pass string to static callback
    # - the first 4 args make up the macro name suffix
    # - this prevents the need for any .if blocks, and reduces the amount of string copys needed

    str.restore.altm
    # return to sampled macro mode in static 'str.altm' property
    # - each method that invokes .cb will first save current mode state to static .altm property

  .endm
.endm; .macro str.altm; ifalt;str.altm=alt;.altmacro
.endm; .macro str.restore.altm; .if str.altm; .altmacro; .else; .noaltmacro; .endif
# --- static .altm methods - used to maintain the .altmacro/.noaltmacro mode state
# - '.altm' samples the current mode, and goes into .altmacro mode
# - '.restore.altm' restores the sampled mode

# --- static subroutine methods - for object .cb interface
# the following methods have been separated by 4 logical bools built into the macro names
# - 0 and 1 represent:  read/write, stack/queue, arg/varg, alt/nalt
# isolating the handles by name like this minimizes the assembly time of large strings
# - selecting cases in a shared macro would cause the full string to be copied for each case
bl <token>

.endm;.macro str.cb$0000,self,s,m,va:vararg;\m "\s", \va
# - .copy:  0000 - stack a copy of "quoted string"  in varargs

.endm;.macro str.cb$0001,self,s,m,va:vararg;\m <\s>, \va
# - .copy:  0001 - stack a copy of <<nested>, <strings>>  in varargs

.endm;.macro str.cb$0010,self,s,m,va:vararg;\m \s, \va
# - .copy:  0010 - stack a copy of contents of string  in varargs

.endm;.macro str.cb$0100,self,s,m,va:vararg;\m \va, "\s"
# - .copy:  0100 - queue a copy of "quoted string"  in varargs

.endm;.macro str.cb$0101,self,s,m,va:vararg;\m \va, <\s>
# - .copy:  0101 - queue a copy of <<nested>, <strings>>  in varargs

.endm;.macro str.cb$0110,self,s,m,va:vararg;\m \va, \s
# - .copy:  0110 - queue a copy of contents of string  in varargs

.endm;.macro str.cb$1000,self,s,p,n;str.build \self, "\p\n\s"
# - main:   1000 - concatenate prefix/suffix to "quoted string"

.endm;.macro str.cb$1001,self,s,p,n;str.build \self, <\p\n\s>
# - main:   1001 - concatenate prefix/suffix to <<nested>, <strings>>

.endm;.macro str.cb$1010,self,s,va:vararg;str.build \self, "\va\s"
# - .stack: 1010 - stack varargs to front of "quoted string"

.endm;.macro str.cb$1011,self,s,va:vararg;str.build \self, <\va\s>
# - .stack: 1011 - stack varargs to front of <<nested>, <strings>>

.endm;.macro str.cb$1110,self,s,va:vararg;str.build \self, "\s\va"
# - .queue: 1110 - queue varargs to back of "quoted string"

.endm;.macro str.cb$1111,self,s,va:vararg;str.build \self, <\s\va>
# - .queue: 1111 - queue varargs to back of <<nested>, <strings>>

.endm

.endif





# AGAIN FROM SCRATCH
# make it a little less messy




# --- prerequisites for str module
# - each section is wrapped in a definition check
#   - this prevents errors when redundantly including these modules in a program

.ifndef nalt;
# --- ifalt object - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
  .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;
  # updates properties 'alt' and 'nalt' for use as evaluatable properties in .if statements
  ## .if alt;  # then environment is in .altmacro mode
  ## .if nalt; # then environment is in .noaltmacro mode
.endif

.ifndef ndef;
# --- ifdef object - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
  # updates properties 'def' and 'ndef' for use as evaluatable properties in .if statements
  ## .if def;  # then given symbol exists
  ## .if ndef; # then given symbol does not exist
  # - if calling in .altmacro mode, use the 'ifdef.alt' variant
.endif


# --- str module
ifdef str.classExists;
.if ndef;

  # --- str class - static properties
  str.classExists=0  # prereq flag - existence of symbol can be checked; value is not used
  str.setalt=0       # altstring flag - used to init an altstring instead of a normal string
  str.savealt=0      # altmode memory - used to temporarily remember current altmode on calls
  str.objects=0      # counts number of new string objects made
  str.rebuilds=0     # counts number of string rebuilds, including updates to existing strings

  # --- str class - methods (as macros)

  .macro str, self, str:vararg
  # --- class method - instantiates new string objects

    str.savealt;
    .if str.savealt; ifdef \self\().isstr;
    .else; ifdef.alt \self\().isstr
    .endif; .if ndef
    # if instantiating a new string object, then define initial attributes...

      # --- new object - properties...
      \self\().isstr=1           # if 0 - memory is copied literally; else as string
      \self\().isalt=str.setalt  # if 0 - string uses quotes " "; if 1 uses brackets < >
      \self\().length=0          # string length - updated only by the .length method
      \self\().count=0           # argument count - updated only by the .count method

      str.setalt=0
      str.objects=str.objects+1
      # update static properties

      .macro \self, sfx, pfx, new;
      # --- main method - concatenates argument substring(s) to string object memory
      # - concat quoted strings, or unqouted strings that have no literal spaces or commas
      #   - use '.stack' or '.queue' to concat strings that contain inline quotes/brackets
        str.savealt; .altmacro
        \self\().cb %(0b01000|\self\().isalt), \new, \sfx, \pfx
        # calls to self '.cb' method cause the object to pass its string memory to a class behavior
        # - dispatch prevents redundant string copies that would be required by .if logic
        # - requires .altmacro mode to pre-emptively evaluate the expression for use as a string
        #   - this is done using a %- prefix when passing an expression as a macro argument

      .endm;.macro \self\().copy, m, va:vararg;
      # --- .copy method - push a copy of string memory to arguments for macro '\m'
      # - can be used to copy string memory to the first argument of a macro call
        str.savealt; .altmacro
        \self\().cb %(0b00000)|\self\().isstr<<1|\self\().isalt),, \m, \va


      .endm;.macro \self\().copyq, m, va:vararg; str.savealt; .altmacro
        \self\().cb 0,0,1, %\self\().isstr, %\self\().isalt,, \m, \va
        # --- .copyq method - enqueue a copy of string memory to end of argument sequence for '\m'
        # - can be used in a sequence to queue up multiple strings as varargs for 1 macro call

      .endm;.macro \self\().stack, s:vararg; str.savealt; .altmacro
        \self\().cb 0,1,0,1, %\self\().isalt,, \s
        # --- .stack method - stack argument source literals to prefix of string memory
        # - stacks literals as given, including quotes " " or brackets < >
        #   - use main method if you want to unwrap quoted string before concatenation

      .endm;.macro \self\().queue, s:vararg; str.savealt; .altmacro
        # --- .queue method - enqueue argument source literals to suffix of string memory
        # - queues literals as given, including quotes " " or brackets < >
        #   - use main method if you want to unwrap quoted string before concatenation

      .endm;.macro \self\().length, sym=\self\().length; s
        # --- .length method - count the number of characters in string memory
        # - test length of string

      .endm;.macro \self\().count, sym=\self\().count; str.savealt; .altmacro
        # --- .count method - count the number of separate arguments in string memory
        # - test length of arg array


    .endif
  .endm;.macro str.rebuild, self, str:vararg
  # --- str .rebuild method - rebuilds the string memory stored in the .cb dispatcher method

  .endm;.macro str.savealt;
  .endm;.macro str.restorealt;

  # --- callback methods - isolated behaviors that minimize the number of required string copies
  # - these are branched into using higher-level object methods, listed as comments below
  # - each name has been given a number that represents a logical configuration of bools
  .endm;.macro str.cb$00000,self,s,m,va:vararg;\m "\s", \va /*.copy (string)*/
  .endm;.macro str.cb$00001,self,s,m,va:vararg;\m <\s>, \va /*.copy (altstring)*/
  .endm;.macro str.cb$00010,self,s,m,va:vararg;\m \s, \va   /*.copy (source)*/
  .endm;.macro str.cb$00100,self,s,m,va:vararg;\m \va, "\s" /*.copyq (string)*/
  .endm;.macro str.cb$00101,self,s,m,va:vararg;\m \va, <\s> /*.copyq (altstring)*/
  .endm;.macro str.cb$00110,self,s,m,va:vararg;\m \va, \s   /*.copyq (source)*/
  .endm;.macro str.cb$01000,self,s,p,n;str.build \self, "\p\n\s" /*main (string)*/
  .endm;.macro str.cb$01001,self,s,p,n;str.build \self, <\p\n\s> /*main (altstring)*/
  .endm;.macro str.cb$01010,self,s,va:vararg;str.build \self, "\va\s" /*.stack (string)*/
  .endm;.macro str.cb$01011,self,s,va:vararg;str.build \self, <\va\s> /*.stack (altstring)*/
  .endm;.macro str.cb$01110,self,s,va:vararg;str.build \self, "\s\va" /*.queue (string)*/
  .endm;.macro str.cb$01111,self,s,va:vararg;str.build \self, <\s\va> /*.queue (altstring)*/
  .endm;

.endif









.macro saveregs, r, va:vararg;
  .ifnb \r;
    saveregs=saveregs+1;
    \r=32-saveregs;
    saveregs \va;
  .endif;
.endm;
.macro prolog, va:vararg;
  .irp x,saveregs,workspace,splr,spcr,spctr,spqr6,spqr7;
    \x=0;
  .endr;
  prologva \va;
.endm;
.macro prologva, x, i, va:vararg; .ifnb \x; prologva=1
    .irp s,lr,cr,ctr,qr6,qr7; .ifc \x,\s;sp\s=1;prologva \i,\va;prologva=0;.exitm;.endif
    .endr; .if prologva; workspace=workspace+\i; prologva \va;.endif
  .else;
.endm;
.macro epilog

.endm















.ifndef nalt;
  .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;
  # --- ifalt object - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
  # updates properties 'alt' and 'nalt' for use as evaluatable properties in .if statements
  # ifalt
  # # create an evaluable property out of the current altmacro state
  # .if alt;  # then environment is in .altmacro mode
  # .if nalt; # then environment is in .noaltmacro mode
.endif

.ifndef ndef;
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
  # --- ifdef object - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
  # updates properties 'def' and 'ndef' for use as evaluatable properties in .if statements
  # ifdef \myObjectName\().exists
  # # create a numerically evaluable property out of a problematic symbol name
  # .if def;  # then given symbol exists
  # .if ndef; # then given symbol does not exist
  # - if calling in .altmacro mode, use the 'ifdef.alt' variant
.endif

ifdef enumb.v
.if ndef
  .macro enum,va:vararg;.irp a,\va;a=1;.irpc c,\a;.irpc i,-+;.ifc \c,\i;enum.i=\a;a=0;.endif;
  .ifc \c,(;enum.v=\a;a=0;.endif;.endr;.exitm;.endr;.if a;\a=enum.v;enum.v=enum.v+enum.i;.endif;
  .endr;.endm;enum.v=0;enum.i=1; # --- enumerator object:
  # updates properties 'enum.v' counter and 'enum.i' increment amount
  # enum A B C D  # enumerate given symbols with incrementing value;  start with '.v= 0; .i= +1'
  # enum E F G H  # next call will continue previous enumerations
  # # >>>  A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7
  # enum (31)     # re-orient enumeration value '.v=n' with parentheses ( )
  # enum -4       # set enumeration to increment/decrement '.i=n' by a specific amount with +/-
  # enum I, +1, J K L
  # # >>>  I=31, J=27, K=28, L=29
  # enum (31),-1,rPlayer,rGObj,rIndex,rCallback,rBools,rCount
  # # register names ...
  # sp.xWorkspace=0x220
  # enum (sp.xWorkspace),+4,VelX,VelY,RotX,RotY,RGBA
  # # offset names ...
  # # etc..

  .macro enumb,va:vararg;.irp a,\va;a=1;.irpc c,\a;.irpc i,-+;.ifc \c,\i;enumb.i=\a;a=0;.endif;
  .ifc \c,(;enumb.v=\a;a=0;.endif;.endr;.exitm;.endr;.if a;b\a=enumb.v;enumb.v=enumb.v+enumb.i;
  m\a=0x80000000>>b\a;.endif;.endr;.endm;# --- bool enumerator object:
  # enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
  # # >>> bEnable   = 31; mEnable   = 0x00000001
  # # >>> bUseIndex = 30; mUseIndex = 0x00000002
  # # >>> bIsStr    = 29; mIsStr    = 0x00000004
  # # mMask and bBit symbols are created for each
  # enumb (0), +1, A, B, C
  # # >>> bA = 0; mA = 0x80000000
  # # >>> bB = 1; mB = 0x40000000
  # # >>> bC = 2; mC = 0x20000000
  # .long mA|mB|mC
  # # >>> 0xE0000000
  # rlwinm. r3, r0, 0, bUseIndex, bUseIndex
  # rlwinm. r3, r0, 0, mUseIndex
  # # both of these rlwinms are identical
  # rlwimi r0, r0, bIsStr-bC, mC
  # # insert bIsStr into bC in a single register/instruction

  .macro enumb.mask,va:vararg;i=0;.irp a,\va;ifdef \a;
  .if ndef;\a=0;.endif;ifdef m\()\a;.if ndef;m\()\a=0;.endif;i=i|(m\a&(\a!=0));.endr;enumb.mask=i;
  .rept 8;enumb.crf=(enumb.crf<<1)|!!(i&0xF);i=i<<4;.endr;.endm;enumb.v=31;enumb.i=-1;
  # --- mask generator:
  # enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
  # Enable = 1; UseIndex = 1;           # set some boolean values as T/F
  # # unassigned bool IsStr is assumed to be 0
  # enumb.mask Enable, UseIndex, IsStr  # generate a mask with said bools using 'enumb.mask'
  # # this uses the mMask value and the state values to create a combined state mask
  # m=enumb.mask;  .long m              # mask will compile from given 'enumb' index values
  # # you can save the combined mask by copying the return enumb.mask property
  # # >>> 0x00000003
  # crf=enumb.crf;  mtcrf crf, r0
  # # you can move partial fields directly into the volatile CR registers with mtcrf, and enumb.crf
  # bf- bEnable, 0f
  #   bf- bIsStr, 1f; nop; 1:
  #   bt+ bUseIndex 0f; nop; 0:
  # # once in the CR, each bool can be referenced by name in 'bf' or 'bt' branch instructions
.endif




##-----------------------------------------------------------------------------------------------##
/* punkpc.s */ i=0;.ifndef punkpc;i=1;punkpc=0x00000001;.endif;.if i
## the following only loads if no other version of punkpc is included in this program

.ifndef dbg.included; dbg.included=1
  .macro dbg,i,x;.ifb \x;.altmacro;dbg %\i,\i;.noaltmacro;.else;.error "\x = \i";.endif;.endm
  # --- dbg: DeBuG expression - dbg [expression]
  #  prints an error "[expression] = (evaluation)" -- useful for debugging
  # i=0x1337; dbg i
  # # >>>  (error message: i = 4919)
.endif

.ifndef nalt;
  .macro ifalt, a=0;alt=0;.ifc 0,a;alt=1;.endif;nalt=alt^1;.endm;
  # --- ifalt object - a method for checking if in .altmacro mode 'alt' or .noaltmacro mode 'nalt'
  # updates properties 'alt' and 'nalt' for use as evaluatable properties in .if statements
  # ifalt
  # # create an evaluable property out of the current altmacro state
  # .if alt;  # then environment is in .altmacro mode
  # .if nalt; # then environment is in .noaltmacro mode
.endif

.ifndef ndef;
  .macro ifdef,sym;.altmacro;ifdef.alt \sym;.noaltmacro;.endm;
  .macro ifdef.alt,sym;def=0;.ifdef sym;def=1;.endif;ndef=def^1;.endm;
  # --- ifdef object - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
  # updates properties 'def' and 'ndef' for use as evaluatable properties in .if statements
  # ifdef \myObjectName\().exists
  # # create a numerically evaluable property out of a problematic symbol name
  # .if def;  # then given symbol exists
  # .if ndef; # then given symbol does not exist
  # - if calling in .altmacro mode, use the 'ifdef.alt' variant
.endif

ifdef enumb.v
.if ndef
  .macro enum,va:vararg;.irp a,\va;a=1;.irpc c,\a;.irpc i,-+;.ifc \c,\i;enum.i=\a;a=0;.endif;
  .ifc \c,(;enum.v=\a;a=0;.endif;.endr;.exitm;.endr;.if a;\a=enum.v;enum.v=enum.v+enum.i;.endif;
  .endr;.endm;enum.v=0;enum.i=1; # --- enumerator object:
  # updates properties 'enum.v' counter and 'enum.i' increment amount
  # enum A B C D  # enumerate given symbols with incrementing value;  start with '.v= 0; .i= +1'
  # enum E F G H  # next call will continue previous enumerations
  # # >>>  A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7
  # enum (31)     # re-orient enumeration value '.v=n' with parentheses ( )
  # enum -4       # set enumeration to increment/decrement '.i=n' by a specific amount with +/-
  # enum I, +1, J K L
  # # >>>  I=31, J=27, K=28, L=29
  # enum (31),-1,rPlayer,rGObj,rIndex,rCallback,rBools,rCount
  # # register names ...
  # sp.xWorkspace=0x220
  # enum (sp.xWorkspace),+4,VelX,VelY,RotX,RotY,RGBA
  # # offset names ...
  # # etc..

  .macro enumb,va:vararg;.irp a,\va;a=1;.irpc c,\a;.irpc i,-+;.ifc \c,\i;enumb.i=\a;a=0;.endif;
  .ifc \c,(;enumb.v=\a;a=0;.endif;.endr;.exitm;.endr;.if a;b\a=enumb.v;enumb.v=enumb.v+enumb.i;
  m\a=0x80000000>>b\a;.endif;.endr;.endm;# --- bool enumerator object:
  # enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
  # # >>> bEnable   = 31; mEnable   = 0x00000001
  # # >>> bUseIndex = 30; mUseIndex = 0x00000002
  # # >>> bIsStr    = 29; mIsStr    = 0x00000004
  # # mMask and bBit symbols are created for each
  # enumb (0), +1, A, B, C
  # # >>> bA = 0; mA = 0x80000000
  # # >>> bB = 1; mB = 0x40000000
  # # >>> bC = 2; mC = 0x20000000
  # .long mA|mB|mC
  # # >>> 0xE0000000
  # rlwinm. r3, r0, 0, bUseIndex, bUseIndex
  # rlwinm. r3, r0, 0, mUseIndex
  # # both of these rlwinms are identical
  # rlwimi r0, r0, bIsStr-bC, mC
  # # insert bIsStr into bC in a single register/instruction

  .macro enumb.mask,va:vararg;i=0;.irp a,\va;ifdef \a;
  .if ndef;\a=0;.endif;ifdef m\()\a;.if ndef;m\()\a=0;.endif;i=i|(m\a&(\a!=0));.endr;enumb.mask=i;
  enumb.crf=0;.rept 8;enumb.crf=(enumb.crf<<1)|!!(i&0xF);i=i<<4;.endr;.endm;enumb.v=31;enumb.i=-1
  # --- mask generator:
  # enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
  # Enable = 1; UseIndex = 1;           # set some boolean values as T/F
  # # unassigned bool IsStr is assumed to be 0
  # enumb.mask Enable, UseIndex, IsStr  # generate a mask with said bools using 'enumb.mask'
  # # this uses the mMask value and the state values to create a combined state mask
  # m=enumb.mask;  .long m              # mask will compile from given 'enumb' index values
  # # you can save the combined mask by copying the return enumb.mask property
  # # >>> 0x00000003
  # crf=enumb.crf;  mtcrf crf, r0
  # # you can move partial fields directly into the volatile CR registers with mtcrf, and enumb.crf
  # bf- bEnable, 0f
  #   bf- bIsStr, 1f; nop; 1:
  #   bt+ bUseIndex, 0f; nop; 0:
  # # once in the CR, each bool can be referenced by name in 'bf' or 'bt' branch instructions
.endif

.ifndef extr.included; extr.included=1
  .macro extr rA,rB,mask=0,i=32,dot;.if \mask;.ifeq (\mask)&1;extr \rA,\rB,(\mask)>>1,\i-1,\dot;
      .else;rlwinm\dot \rA,\rB,(\i)&31,\mask;.endif;.else;li \rA,0;.endif;
  .endm;.macro extr.,rA,rB,m;extr \rA,\rB,\m,,.;.endm;
  # --- extr:  EXTRact small int from mask - extr [regout], [regin], [32-bit mask value]
  #  input a 32-bit (contiguous) mask value, and extract a zero-shifted small int from [regin]
  #  'extr.' variant compares result to 0
  #  null masks cause the immediate '0' to be generated
  # - can be used to abstract away all of the rotation math in 'rlwinm' behind a mask symbol:
  # mMyMask=0x0001FF80
  # extr r31, r3, mMyMask
  # # r31 = 10-bit int extracted from r3, and zero-shifted from position described by mask value
  # extr r3, r3, ~mMyMask
  # # r3 = updated self to zero out the mask position where r31 was extracted from

  .macro insr rA,rB,mask=0,i=0,dot;.if \mask;.ifeq (\mask)&1;insr \rA,\rB,(\mask)>>1,\i+1,\dot;
      .else;rlwimi\dot \rA,\rB,(\i)&31,\mask<<(\i&31);.endif;.endif;
  .endm;.macro insr.,rA,rB,m;extr \rA,\rB,\m,,.;.endm;
  # --- insr: INSeRt small int with mask - insr [regcombined], [reginsertion], [32-bit mask value]
  #  like a reverse 'extr' -- this inserts a zeroed int into a target mask position
  #  'insr.' variant compares result (combination) to 0
  #  null masks cause no instructions to be emitted
  #  - when combined with 'extr' -- this creates an i/o utility for small ints:
  # mMyMask=0x0001FF80
  # extr r31, r3, mMyMask
  # # save extraction in r31
  # li r0, 15
  # insr r3, r0, mMyMask
  # # r3 = updated with new value loaded from immediate in r0
.endif

.ifndef bla.included; bla.included=1
  .macro bla, a, b
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtlr r0;blrl
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtlr \a;blrl;.endif;.endm;.macro ba, a, b;
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtctr r0;bctr
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtctr \a;bctr;.endif;
  .endm;.irp l,l,,;.macro branch\l,va:vararg;b\l\()a \va;.endm;.endr
  # --- bla, ba:  polymorphic Branch (Link) Absolute - bl [addr]  OR  bl [reg], [addr]
  # --- branchl, branch - aliases are also accepted
  # macros override default PPC 'bla' and 'ba' instructions with a gecko-compatible replacement
  # - MCM overrides macro, making gecko-version assemble only outside of MCM
  #   - if optional register is provided as first argument -- MCM syntax can be overridden
  #   - 'branch' and 'branchl' alias may also be used to override MCM syntax
  # # Examples:
  # bla 0x8037a120
  # # MCM will use a placeholder for this -- Gecko will use macro
  # bla r0, 0x8037a120
  # # MCM will not catch this, leaving it to the macro in all cases
.endif

.ifndef qr.f32;
  .irpc i,01234567;.macro mtqr\i, r,as,aq=f32,bs,bq;qr.val=0;.ifnb \as;.ifb \bs;
        mtqr\i \r,\as,\aq,\as,\aq;.exitm;.else;qr.val=(((\bs&0x3F)<<8)|(qr.\bq&7));.endif;
      qr.val=qr.val|(((\as&0x3F)<<24)|((qr.\aq&7)<<16));.endif;ld \r,qr.val;.endif;mtspr 912+\i,\r;
  .endm;.macro mfqr\i, r;mfspr \r,912+\i;.endm;.endr;.irp s,"u8,u16,s8,s16","4,5,6,7";i=3;
  .irp x,\s;i=i+1;qr.\x=i;.endr;.endr;qr.f32=0;qr.0=0;qr.val=0;
  # --- mfqr0...7: Move From gQR - mfqr7 [reg]
  #  copy a GQR register to GPR
  # - simplified mfspr instruction

  # --- mtqr0...7: Move To gQR - mtqr7 [reg], [scale_l], [type_l], [scale_st], [type_st]
  #  copy a GPR to a GQR register, and optioanlly generate the GQR values using extra args
  #  types include:  u8, u16, s8, s16, and f32
  #  scale represents a number of bits in a fixed-point mantissa
  #  - negative scale == << leftshift quantized value on load
  #  - positive scale == >> rightshift quantized value on load, with removed bits used as mantissa
  #  - scale is a 6-bit signed int, and can scale beyond the actual data type boundaries
  # # Examples:
  # mfqr7 r0;  stw r0, 0x20(sp)
  # # back up the contents of qr7
  # mtqr7 r0, 2, u16, 0, f32
  # # set up qr7 to:
  # # - load hword pairs as 14-bit ints with 2-bit mantissas (before casting to floating points)
  # # - store regular floating point pairs
  # psq_l f0, 0x24(sp),0,7;  psq_l f1, 0x2A(sp),1,7
  # # load 3 hwords from sp, as defined by settings made in qr7
  # psq_st f0, 0x2C(sp),0,7;  stfs f1, 0x34(sp)
  # # store 3 dequantized floating points from casted hword fixed points
.endif

.ifndef xem.included; xem.included=1
  .macro xem,p,x,s;.altmacro;xema %\x,\p,\s;.noaltmacro;.endm;.macro xema,x,p,s;\p\x\s;.endm;x=-1
  # --- xem: eXpression EMitter - xem [prefix], [expression], [suffix]
  #  non-expressions may require quoting in both "<quotes and brackets>"
  # # Examples:
  # # first create macro 'x' that uses 'xem' to push and pop
  # .macro x, va:vararg; .ifb \va; .if x>0;   xem "<.long x$>",x;  x=x-1;.endif; .else; .irp a,\va;
  #      .ifnb \a; x=x+1;   xem "<x$>",x,"<=\a>";  .endif; .endr; .endif; .endm
  # x 100, 101, 102, 103
  # # push 4 values
  # x; x; x; x
  # # pop 4 values (FIFO)
  # # >>> 00000067 00000066 00000065 00000064
.rept 32;x=x+1;.irpc c,rfb;xem \c,x,"<=x>";.endr;xem m,x,"<=1!<!<(31-x)>";.endr;sp=r1;rtoc=r2;x=-1
.rept 8;x=x+1;xem cr,x,"<=x>";i=x<<2;.irp s,lt,gt,eq,so;\s=i&3;xem cr,x,"<.\s=i>";i=i+1;.endr;.endr
  # 'xem' also includes helpful enumerations for r-, f-, cr- registers, m- mask bits, and b- bools
  # # >>> r31, f31, b31 = 31;  cr7 = 7;  m0 = 0x80000000; m31 = 0x00000001
.endif

.ifndef ld.bufi;
  .macro load,va:vararg;ld \va;.endm;.irp x,bufa,bufb,bufi,len,w,em,isstr,opt;ld.\x=0;.endr;
  .macro ld,r=-31,va:vararg;ld.rev=0;i=0;ld.str=0;.irpc c,\r;.ifc \c,-;ld.rev=1;.endif;.exitm;
      .endr;.if ld.rev;ld.va (-(\r)),\va;.else;ld.va \r,\va;.endif;
  .endm;.macro ld.va,r,a,va:vararg;.ifnb \a;ld.isstr=0;.irpc c,"\a";.if ld.isstr;ld.ch "'\c";.else;
    .ifc \c,>;ld.isstr=1;ld.str=ld.str+1;i=0;.else;.exitm;.endif;.endif;.endr;.if ld.isstr;
    .rept (4-i)&3; ld.ch 0;.endr;.else;ld.buf \a;.endif;ld.va \r,\va;.else;ld.w=ld.bufi;ld.bufi=-1;
    ld.len=ld.w<<2;.rept ld.w;ld.bufi=ld.bufi+1;.if ld.rev;ld.em \r-ld.bufi;.else;ld.em ld.bufi+\r;
  .endif;.endr;.endif;.endm;.macro ld.ch,c;i=(i+1)&3;.if i&1;ld.bufa=(ld.bufb<<8)|(\c&0xFF);
    .else;ld.bufb=(ld.bufa<<8)|(\c&0xFF);.endif;.ifeq i;ld.buf ld.bufb;ld.bufb=0;.endif;
  .endm;.macro ld.buf,i;xem ld.buf$,ld.bufi,"<=\i>";ld.bufi=ld.bufi+1;
  .endm;.macro ld.em,r;xem "<ld.em=ld.buf$>",ld.bufi;.if ld.opt;
      .if (ld.em>=-0x7FFF)&&(ld.em<=0x7FFF);li \r,ld.em;.else;lis \r,ld.em@h;.if (ld.em&0xFFFF);
  ori \r,\r,ld.em@l;.endif;.endif;.else;lis \r,ld.em@h;ori \r,\r,ld.em@l;.endif;.endm;
  # --- ld or load: LoaD immediate(s) - ld [reg], [value or string], [next value or string]...
  #  can load multiple values or strings into a sequence of registers
  #  strings should be quoted, and must begin with a '>' character for recognition
  #  - number of instructions is minimized using optional evaluations (see extra note)
  #  if [reg] is positive, that register will be the base of an incrementing register number
  #  if [reg] starts with the literal char '-', the reg number is used with a decrementor instead
  #  if [reg] is blank, a default of decrementing r31 is used to complement lmw/stmw syntax
  # # Examples:
  # li r0, 1
  # ld r0, 1; load r0, 1
  # # 'ld' works like 'li'. 'load' is an alias.
  # ld r4, 0x804019F4, ">Hello World!"
  # stswi r5, r4, ld.len-4
  # # 'ld' can handle 32-bit values, multiple arguments, and even strings that start with '>'
  # #  the 'ld.len' property saves the byte size taken up in the registers

  # --- extra note about ld evaluations:
  # ld.opt=0 by default
  # if ld.opt==0, 'ld' will not optimize the number of instructions used
  #  - when not optimized, expressions with missing definitions can be used as values
  #  - otherwise, default requires that all given expressions are evaluable
  # this scenario is most commonly an issue with label math:
  # # Examples:
  # _back=.
  # ld.opt=0;  ld r0, _forward-_back
  # # 'ld' can handle expressing '_forward' before it is defined, but uses 2 instructions to do so
  # _forward=.
  # ld.opt=1;  ld r0, _forward-_back
  # # optimized 'ld' uses only 1 instruction, but needs to be used after '_forward' is evaluable
  # # if tried before '_forward' is defined, the value will stay 0 until the linker handles it
  # #   - when not using the linker, this may be useful for creating null terminators
.endif

.ifndef xev
  .macro xev,b=xe.beg,e=-1,va:vararg;xe.beg=\b;xe.end=\e&(-1>>1);xe.len=xe.beg-1;xev=-1;xe.ch,\va
  .endm;.macro xe.ch,e,va:vararg;xe.i=-1;xe.len=xe.len+1;.irpc c,\va;xe.i=xe.i+1;.if xe.i>xe.end
    .exitm;.elseif xe.i>=xe.len;xe.ch "\e\c",\va;.endif;.endr;.if xev==-1;xev=\e;.endif
  .endm;.irp x,beg,end,len;xe.\x=0;.endr;xev=-1
  # --- xev: extract eXpression and EValuate - xev [begin char idx], [inclusive end idx], [str]
  #  substring is extracted from body and evaluated through the 'xev' property
  # # Examples:
  # xev 5,6,myVal16; .long xev
  # # expression '16' is extracted from symbol name 'myVal16'
  # xev 5,,myVal17; .long xev
  # # blank end index selects end of string
  # xev,,myVal18; .long xev
  # # blank beginning index reselects last used beginning index; or 0 default
  # # >>> 00000010 00000011 00000012
.endif

.ifndef xr.reg; xr.reg=0
  .macro idxr, xr; .irp s,len,beg,dep,end,idx,reg; xr.\s=-1;.endr; .irpc c,\xr; xr.len=xr.len+1
      .ifc (,\c; xr.dep=xr.dep+1; .if xr.dep==0; xr.beg=xr.len+1; xr.end=-1; .endif; .endif
      .ifc ),\c; xr.dep=xr.dep-1; .if xr.dep==-1; xr.end=xr.len-1; .endif; .endif
    .endr; xev 0,xr.beg-2,\xr; xr.idx=xev; xev xr.beg,xr.end,\xr; xr.reg=xev;.endm
  # --- idxr: InDeX of Register (i/o syntax) - 'idxr x(r)'  becomes->  xr.idx=x  xr.reg=r
  #  evaluates 'x' separately from 'r' from given input
  #  right-most parentheses '( )' captures 'r'
  #  input does not need to be quoted if there are no spaces between idx and reg
  #  outputs return properties 'xr.idx' and 'xr.reg'
  # # Examples:
  # # first create macro 'test' that uses 'idxr' to extract inputs:
  # .macro test,xr; idxr \xr; .long xr.idx, xr.reg;.endm
  # test 0x400(31); test (0x100<<2)((3+29))
  # # >>> 00000400 0000001F 00000400 0000001F
.endif

.ifndef lmfs.included; lmfs.included=1
  .macro mfpr.new,name,ins,siz,fpr=30,idxr=xFPRs(sp),typ,gqr,va:vararg;.ifnb \name;.irp $,"\@";
    .macro \name,f="\fpr",xr="\idxr",t="\typ",q="\gqr";idxr \xr;xr.r\$=(xr.reg);
      xr.x\$=(xr.idx+((31-\f)*\siz));.ifnb \t; mfpr.main \ins,\siz,(\f),xr.x\$,xr.r\$,\t,\q;.else;
      mfpr.main \ins,\siz,(\f),xr.x\$,xr.r\$;.endif;.endm;.endr;mfpr.new \va;.endif;.endm;
  .macro mfpr.main,i,s,f,x,r,t,q;.ifgt 31-(\f);.ifb \t;mfpr.main \i,\s,1+\f,\x-\s,\r;.else;
  mfpr.main \i,\s,1+\f,\x-\s,\r,\t,\q;.endif;.endif;.ifb \t;\i \f,\x(\r);.else;\i \f,\x(\r),\t,\q;
  .endif;.endm;.macro mfpr.newps,n,t,s,q,va:vararg;.ifnb \n;
  mfpr.new \n\()m2\t,\n,(\s*2),,,0,\q,\n\()m1\t,\n,(\s*2),,,1,\q,\n\()m\t,\n,\s,,,1,\q;
  mfpr.newps \va;.endif;.endm;.irp $,l,st;mfpr.new \$\()mfs,\$\()fs,4,,,,,\$\()mfd,\$\()fd,8;.endr;
  .irp $,psq_l,psq_st;  mfpr.newps \$,f32,4,0,\$,u8,1,2,\$,u16,2,3,\$,s8,1,4,\$,s16,2,5;.endr
  # --- lmfs, lmfd   - load multiple f32 or f64 floating points
  # --- stmfs, stmfd - store multiple f32 or f64 floating points
  # --- psq_lm2*  - dequantize load multiple paired singles of type '*'
  # --- psq_lm1*  - dq load pairs, but 2nd float is replaced with '1.0'
  # --- psq_lm*   - dq load singles into 1st float without skipping any; fill 2nd float with '1.0'
  # --- psq_stm2* - quantize store multiple paired singles of type '*'
  # --- psq_stm1* - q store pairs, but always store quantized '1.0' instead of 2nd float
  # --- psq_stm*  - q store singles, but last store has a trailing quantized '1.0' following it
  # --- '*' = f32, u8, u16, s8, s16

  # for all types, syntax is like 'lmw' and 'stmw':
  # # Examples:
  # lmfs f28, 0x400(sp)
  # psq_stmu8 f28, 0x400(sp)

  # for all 'psq_' types, there are 2 extra optional arguments for controling the 2nd float and GQR
  # the GQR can be overridden with this option to use QR6 or QR7 with custom mantissa scales:
  # # Examples:
  # mtqr7 r0, 2, u16, 0, f32      # create a 14-bit int format with a 2-bit mantissa
  # psq_lm2u16 f20, 0(r31),0,7    # load and dequantize 24 hwords -> floating points
  # psq_st2u16 f20, 0x20(sp),0,7  # save them as floating points in the stack frame
.endif













.macro prolog, pva:vararg;prolognew \@;prologva \pva;
.endm; .irp m,saveGPR,saveFPR,prologva,epilog;.macro \m;.endm;.endr;


.macro prolognew, id; .irp m,saveGPR,saveFPR,prologva,epilog;.purgem \m;.endr
  .irp s,gpr,fpr,space,nogpr,cr,ctr,qr6,qr7;sp\s\id=0;.endr;
  xLR=framespace\id+4; xFPRs=xGPRS+(finalgpr<<2); xWorkspace=xFPRs+(finalfpr<<3)
  .macro prologva, x, i, va:vararg; .ifnb \x; prologva=1
    .irp s,nogpr,cr,ctr,qr6,qr7;.ifc \x,\s;sp\s\id=1;prologva \i,\va;prologva=0;.exitm;.endif
    .endr; .if prologva; space\id=space\id+\i; prologva \va; .endif
    .else; mflr r0; stwu sp, -framespace\id(sp); stw r0, xLR(sp)
      .ifeq nogpr\id; stmw 32-finalgpr\id, xGPRs
    .endif
  .endm

.endm
# --- stack frame methods
# prolog [offsetname], [size], ...
# - assign a new stack offset for each given argument pair
# - if keywords "cr" "ctr" "qr6" or "qr7" are found, then they will be backed up and restored
# - if keyword "nogpr" is found, stmw instruction is omitted
# - if calls to saveGPR or saveFPR are made in frame, they will be backed up and restored
# saveGPR [registername], ...
# - assign saved register ID to given register name, for use in function
# - if name is (subexpression) it will be interpreted as a number of unnamed registers
# - saveFPR variant can be used for float registers
# epilog
# - commits all of the frame space defined and used within the function, and closes frame
# --- stack frame properties
# xCR, xCTR, xQR6, xQR7, xGPRs, xFPRs, xWorkspace = usable stack offsets
# - all register/offset names generated with methods are also usable as properties

.macro prl,va:vararg;.irp s,"frame,space,gprs,fprs,cr,ctr,qr6,qr7";prl.push \s;.irp x,\s;prl.x=0;
.endr;.endr;

.endm;.macro prl.push,va:vararg;.irp a,\va;xem prl.\a\()$,prl.sti,"<=prl.\a>";.endr;
  prl.sti=prl.sti+1;.endm;.macro prl.pop,va:vararg;.irp a,\va;xem "<prl.\a=prl.\a\()$>",prl.sti;
prl.sti=prl.sti-1;.endr;.endm;prl.sti=-1;










# --- frac module
# use fixed-point math to estimate floating-point values
# - create 'frac' objects that represent floating points with 4 decimal places
# - values can be between 0.0000 ... 65536.9999; in linear units of 0.0001

.include "punkpc/xev.s"
.include "punkpc/dbg.s"
# --- static 'frac' class attributes:
.irp x,n,f,nl,fl,u32,sh,sg; frac.\x = 0; .endr
# - static methods use the following static properties to read in object properties:
# n   : number component
# f   : fractional component
# nl  : n literal count
# fl  : f literal count (max of 9 decimal places)
# u32 : fixed point value (32-bit, 0xNNNNFFFF)
# sh  : abstract shift amount for fixed point value
# sg  : sign for fixed point

.macro frac, self, value:vararg;
# static object constructor method creates/invokes named object with optional initial value
## ex: frac pi 3.1415926536

  .ifndef \self\().isfrac;  \self\().isfrac=1;
    # --- instantiated 'frac' object attributes:
    .irp x,n,f,nl,fl,u32,sh,sg; \self\().\x = 0; .endr
    # object properties - see class properties for descriptions

    .macro \self, va:vararg; .altmacro
    # object method emits float, or sets value
    # if no args, then emit object's floating point value
      .ifb \va; frac.emit %\self\().n, %\self\().f;   .else;
      # else, interpret args and update object properties...

        .irp x,n,f,nl,fl,u32,sh,sg;  frac.\x = \self\().\x;  .endr;
        # obj -> method : copy object properties as arguments

        frac.intp, \va;
        .irp x,n,f,nl,fl,u32,sh,sg;  \self\().\x = frac.\x;  .endr;
        # obj <- method : update object properties on return

      .endif;  .noaltmacro
    .endm; # object method can be called to interface with static methods using object properties
  .endif; .ifnb \value; \self \value; .endif
  # constructor invokes self before returning, if a value was given

.endm;.macro frac.emit,n,f; .float \n\().\f
.endm;.macro frac.intp, i=0, va:vararg
  i=-1;.irpc c,\va;

  .endr
.endm;.macro frac.c, c;
  .if frac.c.n | frac.c.f; .if (\c >= '0)&&(\c <='9); # is number
  .elseif (\c >= )
.endm;



.macro float, self, value
  .ifndef \self\().isfloat;  \self\().isfloat=1
    .macro \self, v;  .ifb \v;  float.emit \self
      .else;  float.intp \v;  \self\().n = float.n;  \self\().f = float.f
      .endif;  .endm;  \self \value; .endif
.endm;.macro float.intp, v;  float.intp=-1; float.pt=0
  .irpc c,\v; float.intp=float.intp+1;  .ifc \c,.;  float.pt=float.intp;  .endif;  .endr
  xev \v, 0, float.intp-1;  float.n=xev;
  float.f=0;  .if float.pt;















.include "punkpc/ifdef.s"
.irp class,frac,frac.op; .irpc property,nfmde; \class\().\property = 0; .endr; .endr
# --- n - numerical component
# - used to store the integer component of a fixed point number
# --- f - fractional component
# - used to store the fractional component of a fixed point number
#   - n and f are used directly in addition/subtraction
#     - (999,999,999.999999999...0.000000001)
#   - n and f are estimated by m, e, and d when using multiplication/division
#     - (999,999,999.0...1.0)...(0.9999...0.0001)
# --- m - mantissa estimation
# - used to work in 16-bit multiplaction/division using 32-bit integer symbols
# --- d - decimal place multiplier
# - used to split the mantissa for a fractional component, when needed
#   - if d is 0, then 32-bit n is used directly -- in place of m
# --- e - exponent bias
# - used to keep track of how many left/right shifts have been made with m calculations
#   - shifts

.macro frac, self, va:vararg
# constructor method
## ex: frac pi 3.141592654

  ifdef \self\().isfrac; .if ndef; \self\().isfrac=1;
    .irpc property,nfmde; \self\().\property = 0; .endr
    .macro \self, v:vararg; .ifb \v; frac.float \self\().n, \self\().f;
      .else; frac.in \self, \v; .endif
    .endm; .ifnb \va; \self \va
.endm;.macro frac.in, self, va:vararg
# input parse
# handle each vararg like so:
# - copy self -> frac
# - if a destination operand comes before an operator...
#   - then set frac.op -> frac; overwriting self value
# check for an arbitrary number of operators/operands...
# - check for operator ...
#   - if found, process operator and then check for operand
#   - (frac + frac.op), (frac - frac.op), (frac * frac.op), (frack / frac.op)
#     - if operand (-+*/) is found, invoke proper operator method
#     - else exit and conclude this vararg expression
#   - else (if no operator found) exit and conclude this vararg expression
# if another operator is found, then repeat process
# - else, conclude this vararg expression...
#   - update self <- frac
# continue to next vararg

# vararg loop will cause , char to update the variable with the previous expression results
## ex1: frac x 1;  x + x + x + x   # x = 4
## ex2: frac x 1'  x + x, + x + x  # x = 6

  .irp exp, \va; # for each expression string...
    .irpc property,nfmde; frac.\property = \self\().\property; frac.op.\property = 0; .endr
    .irp property,init,input,fract,i; frac.in.\property = 0 ;.endr
    # .init   TRUE = checking operands; FALSE = check for initial statement
    # .input  TRUE = checking operand;  FALSE = checking for next input
    # .fract  TRUE = check for f;       FALSE = check for n
    .irpc c, \exp; frac.in.c.i = frac.in.i + 1; # for each character in expression string...
      .if frac.in.i <= frac.in.c.i; frac.in.c "'\c"
        .if frac.in.c >= '* # skip spaces, and any characters that have already been parsed

          .if frac.in.input       # if parsing an input number...
            .if frac.in.c == '.; frac.in.fract=1; frac.input=1 # enter fract mode
            .elseif (frac.in.c >= '9) && (frac.in.c <= '0) # else check for dec range
              .if frac.in.fract; frac.op.f = (frac.op.f * 10) + (frac.in.c & 0xF)
              .else; frac.op.n = (frac.op.n * 10) + (frac.in.c & 0xF); .endif
            .else; frac.in.input=0; frac.in.fract=0;
            .endif

          .else; # if parsing for operand/operator...
            .if frac.in.c <= '\; # is operator; +,-,*,/, or .
              frac.in.op = frac.in.c
            .elseif frac.in.c <= '9; # is numerical; 0...9
            .else; # is a variable name
            .endif;
          .endif
        .endif;


    .endr
  .endr; .noaltmacro

.endm;.macro frac.in.c, c; frac.in.c=\c;
# interpret this character depending on the current input parse state
.endm;.macro frac.in.n,

.endm;.macro frac.in.f
.endm;.macro frac.in.m
.endm;.macro frac.m
.endm;.macro frac.




.macro mul32, a, b;
# properties mul and mul.h return a 64-bit product from 2 32-bit UNSIGNED ints
  mul.a=\a; mul.b=\b; mul.h=0; mul = mul.a * mul.b & -1
  mul.ah = mul.a>>16; mul.bh = mul.b>>16
  mul.highs = mul.ah * mul.bh
  .if mul.highs; mLow = 0xFFFF; mul.al = mul.a &mLow; mul.bl = mul.b &mLow
    mul.lows = mul.al * mul.bl; mul.lh = mul.al * mul.bh; mul.hl = mul.ah * mul.bl
    mul.carry = mul.lows>>16 + (mul.lh&mLow) + (mul.hl&mLow)
    mul.h = mul.carry>>16 +  mul.highs + (mul.lh>>16) + (mul.hl>>16)
  .endif
.endm;

mul32 -1, -1
.long mul.h, mul



.macro clz, i;
# count leading zeroes
  .if \i;
    .if !(\i&0x80000000); clz.i=clz.i+1; clz \i<<1;
    .else; clz = clz.i; clz.i = 0; .endif
  .else; clz = 32; .endif
.endm; clz.i=0



.macro fl, i; i = \i
# generate floating point from integer value
  s = !!(i&0x80000000)
  .if s;
    i = -i;
  .endif;  clz i
  i = (i<<(clz-8))&0x7fffff
  e = (126+(32-clz))<<23
  fl = s | e | i
.endm
fl 1
.long fl




.macro brutemul, a, b
# 32-bit signed multiply with no conditional statements
# produces 64-bit product: mul.h, mul.l
#          32-bit product: mul
  mul=0; mul.h=0
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
    .rept 32; # for 32 bits
      m=B&1 # creat mask out of bit
      mul.h=-m&A+mul.h # 2s compliment mask to copy A or 0, then add result to highs
      mul=mul>>1|(mul.h<<31) #
      mul.h=mul.h>>1
      B=B>>1
    .endr;
  mul=(-S^mul)+S;mul.h=-S^mul.h # apply remembered sign to high and low fields
  mul.l=mul # copy mul.l once mul is finalized, for 64-bit return property
.endm

x=-3; y=0x7FFFFFFF
brutemul x, y

.macro karamul, a, b
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
  AH=A>>16;AL=A&0xFFFF; BH=B>>16;BL=B&0xFFFF
  mul.h=AH*BH;mul.l=AL*BL; mul.k=((AH+AL)*(BH+BL))-(mul.h+mul.l)
  mul.h=-S^(mul.k>>16+mul.h); mul.l=(-S^(A*B))+S
.endm

brutemul 3, 3
.long mul.h, mul



.macro brutediv, a, b, f=32, n=32
  div=0; div.r=0; div.f=0
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
  .if (!!B & !!A) & !!(\n+\f);
    .rept \n; div=div<<1
      div.r=(A>>31)|(div.r<<1);A=A<<1
      .ifge div.r-B; div.r=div.r-B; div=div|1;.endif
    .endr;.rept \f; div.f=div.f<<1
      div.r=(A>>31)|(div.r<<1);A=A<<1
      .ifge div.r-B; div.r=div.r-B; div.f=div.f|1;.endif
    .endr; div.f=div.f<<(32-\f)
  .endif

.endm

brutediv,


    .rept 32; # for 32 bits

      .ifge div.h-A;

      mul.h=-m&A+mul.h
      mul=mul>>1|(mul.h<<31)
      mul.h=mul.h>>1
      B=B>>1
    .endr;
  mul=(-S^mul)+S;mul.h=-S^mul.h
  mul.l=mul
.endm

frac.dec

.macro frac.abs, self=fracA, ppt=.m>>31; frac.abs=\self\ppt;
  # ppt arg uses argument literals to describe a propert/expression with the self namespace
  .if frac.abs;\self\().m=-\self\().m;.endif; # if ppt is not 0, then value is negated
  # default ppt gives absolute value, but can be overridden to control the sign
.endm; .macro frac.align, self=fracA, op=fracB;
  # normalizes op by using exponent of self
  # if self exponent is smaller than op, args are swapped
  # each argument's sign is sampled as property '.s'
  .if \self\().e != \op\().e
    .if \self\().e < \op\().e
      frac.align \op, \self # call self with swapped args to ensure self >= op exponent
    .else; frac.abs \self; \self\().s=frac.abs # sample signs, and use abs value in alignment
      frac.abs \op; \op\().s=frac.abs # '.s' saves smapled signs
      \op\().m=(\op\().m|0x40000000)>>(\self\().e-\op\().e) # compress smaller number
      \op\().e=\self\().e  # exponents are matched to normalize for calculation
      frac.abs \self,.s; frac.abs \op,.s; .endif; .endif
# .abs with '.s' ppt option overrides function with a condition; restoring saved signs
# sampled signs will still be available on return through '.s'
.endm; .macro frac.add, self=fracA, op=fracB; frac.align \self, \op
  \self\().m= \self\().m+\op\().m # add
  \self\().s=\self\().m>>31 # save resulting sign
  .if \self\().s^(\self\().m>>30&1) # if carrying bit is not the same as sign bit...
    \self\().m= (\self\().m>>1)|(\self\().s<<31) # then shift up by a power of 2
    \self\().e=\self\().e+1; .endif # adjust exponent accordingly
.endm; .macro frac.sub, self=fracA, op=fracB; frac.add \self, -\op
# software subtraction is just addition (because of inclusion of sign in mantissa)
.endm; .macro frac.mul, self=fracA, op=fracB;
  frac.E=\self\().e + \op\().e; frac.align \self, \op
  # product exponent is remembered before alignment, to apply to calculated 64-bit value
  # alignment records sign in '.s' property
  frac.A=(-\self\().s ^ \self\().m ^ 0x40000000) + \self\().s
  frac.B=(-\op\().s ^ \op\().m ^ 0x40000000) + \op\().s
  # A and B garuntee args have exactly 31 significant bits for unsigned multiplication
  # - this makes it easier to scale the product down when normalizing a 30-bit mantissa property
  frac.S=\self\().s ^ \op\().s
  # product sign is remembered before multiplication, to apply to calculated mantissa property

  frac.AH=frac.A>>16; frac.AL=frac.A&0xFFFF
  frac.BH=frac.B>>16; frac.BL=frac.B&0xFFFF
  frac.H=frac.AH*frac.BH; frac.L=frac.AL*frac.BL
  # 16-bit multiply highs and lows together
  frac.kara=(((frac.AH+frac.AL)*(frac.BH+frac.BL))-(frac.H-frac.L))
  # 17-bit multiply sums and subtract lows to implement karatsuba multiplication
  frac.H=-frac.S^(((frac.L>>16+(frac.kara&0xFFFF))>>16)+(frac.kara>>16+frac.H))
  frac.L=(-frac.S^(frac.L)+frac.S
  # correct for carrying errors, and reapplying sign
  # - final .H, .L make a signed 64-bit integer product of exponent .E
  # - (you can use .E with the raw .H,.L product for higher accuracy than saved mantissa)

  \self\().e = frac.E;  \self\().s = frac.S
  \self\().m = (frac.L>>31)|(frac.H<<1)^0x40000000
  # format returned frac properties with a 30-bit normalized mantissa
.endm; .macro frac.div, self=fracA, op=fracB
  frac.E=\self\().e - \op\().e; frac.align \self, \op
  # product exponent is remembered before alignment, to apply to calculated mantissa property
  # alignment records sign in '.s' property
  frac.A=(-\self\().s ^ \self\().m ^ 0x40000000) + \self\().s
  frac.B=(-\op\().s ^ \op\().m ^ 0x40000000) + \op\().s
  # A and B garuntee args have exactly 31 significant bits for unsigned multiplication
  # - this makes it easier to scale the product down when normalizing a 30-bit mantissa property
  frac.S=\self\().s ^ \op\().s
  # product sign is remembered before multiplication, to apply to calculated mantissa property




# frac objects have
# .e = binary exponent of signed mantissa
# .s = sign as 0 or 1
# .m = 32-bit signed mantissa field:
#      +80000000 : sign
#      +40000000 : carry/exponent
#      +3FFFFFFF : 30-bit mantissa component
# .d  = decimal multiplier
# .de = decimal multiplier exponent
# - div/mod by (.d >> (.e-.de)) if .e is positive
# - div/mod by (.d << (abs(.e)-.de)) if .e is negative

.include "punkpc/ifdef.s"
.include "punkpc/xem.s"
# --- DQ Module - double-ended queue objects
# static methods:
.macro DQ.get, DQ,i,v;.ifge \i;xem "<\v=\DQ\().s>",\i;.else; xem "<\v=\DQ\().q>",-\i;.endif
.endm;.macro DQ.set, DQ,i,v;.ifge \i;xem "<\DQ.s>",\i,"<=\v>";.else;xem "<\DQ.q",-\i,"<=\v>";.endif
.macro DQ.index DQ,i,t,b,p;.if \i>\t;\DQ\p=\t;.elseif \i<\b;\DQ\p=\b;.else;\DQ\p=\i;.endif
.endm;.macro DQ, self=DQ, fill=0, init=0
# DQ (DEqueue) object
# - use as a stack, a queue, or a double-ended queue
#   - s index space uses range of stack
#   - q index space uses range of queue (bottom of stack, and negatives)
# - also may be used as an array
#   - i index selects within range of q...s
# - methods act on each index space independently from the others

ifdef \self\().isDQ; .if ndef; \self\().isDQ=1;
# if self doesn't exist, then construct new (else NOP)


  # for 'i' index space...
  # I/O methods:
  # --- .get   i, s, ...
  # Get value of self[i], and assign it to symbol(s) s, ...
  #   i : index of stack to get
  #       - if blank, i = self.i (0 by default)
  #   s : symbol(s) to write copy of value to
  #       - if blank, s = self
  # --- .set   i, v
  # Set value of self[i] to v
  #   i : index of stack to get
  #       - if blank, i = self.i (0 by default)
  #   v : value to assign
  #       - if blank, v = self
  .macro \self\().get, i=\self\().i, s=\self, va:vararg;
    DQ.get \self, \i, \s; .irp v,\va;\v=\s;.endr
  .endm; .macro \self\().set, i=\self\().i, v=\self
    DQ.set \self, \i, \v
  .endm
  # Index methods:
  # --- .i   abs, rel, top, bot   - Index method
  # Set self.i index to a place within bounds of stack...queue
  #   - self.i = (abs + rel)
  # if out of bounds, limit 'top' or 'bot' is used instead
  #   a : absolute index base
  #       - if blank, a = self.i
  #   r : relative offset from abs
  #       - if blank, r = 0
  #   t : top boundary
  #       - if blank, t = self.s
  #   b : bottom boundary
  #       - if blank, b = self.q
  # --- .r   r, t, b    - Rotation method
  # Rotate i index to a relative place within bounds of stack...queue
  #   if out of bounds, index is wrapped around range
  #     - you may create circular buffers that use this method
  # --- .ii  a, r   - Unbounded Index method
  # Set i index to a place within bounds of array memory
  #   limit is set automatically to edge of generated DQ
  #   - you may select popped/dequed records from garbage memory this way
  # --- .rr  r      - Unbounded Rotation method
  # Rotate i index to a relative place within array memory
  #   - like .ii, but with rotation limits instead of cap limits
  .macro \self\().i, a=\self\().i, r=0, t=\self\().s, b=\self\().q
    DQ.index \self, \a+\r, \t, \b, ".i"
  .endm; .macro \self\().ii, a=\self\().i, r=0
    DQ.index \self, \a+\r,
  .endm; .macro \self\().r
  .endm; .macro \self\().rr
  .endm
  # Convenience methods:
  # --- .iter   i, method, ppt
  # Iterate by step i, using 'method' to select new index
  #  i uses self to update current record, set new index, and get new target record
  #   i : iteration step size
  #       - if blank, i = self.iter (+1 by default)
  # - optional arguments may be used to navigate index spaces other than self.i...
  #   method : the name of a method of self that can be used to find a new index
  #       - if blank, self.i method is used to modify the 'ppt' value
  .macro \self\().iter, i=\self\().iter, method=".i="
    DQ.set \self, \self\ppt, \self
    \self\method
    DQ.get \self, \self\ppt, \self
  .endm


  # for 's' index space...
  # I/O methods:
  .macro \self\().


  .macro \self\().push, va:vararg
  # --- .push v, ...
  #   - push value to top of '.pop' STACK
  #   v : value(s) to push to stack
  #       - if blank, v = self, and self is cleared with \fill
  #       - else, self is not modified

    .ifb \va; \self\().push \self; \self=\fill;
    .else; .irp v,\va
        DQ.set \self, \self\().s, \v
        \self\().s, 1
      .endr
    .endif
  .endm

  .macro \self\().pop
  # --- .pop v
  #   - pop top value from '.push' STACK
  #



  # --- .enq - '.push', but use the queue index to reach bottom of the stack instead of the top
  #   - enqueue to '.pop' QUEUE (bottom of STACK)
  # --- .deq - '.pop', but use the queue index to reach bottom of the stack instead of the top
  #   - dequeue from '.push' QUEUE (bottom of STACK)
  # --- .fill - set multiple indices to a single fill value
  # --- .reset - quickly collapse stack without writing to indices
  # --- .i - discard self, set .i, and get target .i
  #   - index for i; confined within range of stack, capped at limits
  # --- .r - rotation method for '.i' allows for circular buffers
  #   - index for i; confined within range of stack, rotates at limits
  # --- .s - discard self, get target .s
  #   - index for s; confined only by lower bounds
  # --- .q -
  # --- .ii - unbounded .i index -- capped at array limits -- use .ss or .qq to push array limits
  # --- .rr - .ii index, but with rotation
  # --- .ss - .s, but can push maximum stack range with a call to
  .macro \self\().fill, v=\fill, s=\self\().s, q=\self\().q;
    .altmacro; .rept \s-\q;xema <>,\s-\q,<=\v>
      xema <>
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm; .macro \self\().
  .endm

.macro DQ, self, fill=0, init=0
# Dequeue object
  ifdef \self\().isDQ; .if ndef; \self\().isDQ=1;

  # object methods
  .macro \self\().reset
    # --- .reset - set properties back to default
    \self=\fill         # value of this element (copied)
    \self\().$i=\init    # index of this value (copied)
    \self\().$prev=\fill # value of last popped element (from either Stack or Queue)
    \self\().$i.prev=\init
    \self\().$s=\init    # index of this stacked element
    \self\().$q=0        # index of this queued element
    \self\().$ss=\init   # highest index of stack elements for this object
    \self\().$qq=0       # lowest index of queue elements for this object
  .endm; .macro \self\().i, i=\self\().$i, r=0
    # --- .i - select element i+r, or cap
    .if \i+\r > \self\().ss; \self\().i \self\().ss;
    .elseif \i+\r < \self\().qq;
    DQ.i \self, \i, \r
  .endm; .macro \self\().fill, v=\fill, s=\self\().$s, q=\self\().$q
    # --- .fill - fill range q...s with value v
    DQ.fill \self, \v, \s, \q
  .endm; .macro \self\().pop;
    # --- .pop  - pop from s top of STACK (opposite end of QUEUE)

    \self\().$i, -1; \self\().$s=\self\().$s-1
  .endm; .macro \self\().push, v=\fill
    # --- .push - push v to STACK
    \self\().$i, 1;
  .endm; .macro \self\().deq
    # --- .deq - pop from QUEUE
  .endm; .macro \self\().enq, v=\fill
    # --- .enq - push v to QUEUE

  .endm; .macro \self\().us # --- unpop from STACK memory, if available

  .endm; .macro \self\().uq # --- unpop from QUEUE memory, if available

  .endm

  # initial object instances

.endm

.macro DQ.i, self, i, r
  \self\().prev=\self; \self\().i.prev=\self\().i
  .ifge \i+\r;  xem "<\self\().$s>",\self\().i,"<=\self>"; xem "<\self=\self\().$s>",(\i+\r)
  .else;  xem "<\self\().$q>",\self\().i,"<=\self>"; xem "<\self=\self\().$q>",(\i+\r); .endif
  \self\().i=\i+\r
.endm;




.macro Stack.i, self, i, r
  .if \i+\r > \self\()SS; Stack.i \self\()SS; .exitm
  .elseif \i+\r < \self\()QQ; \self\().i \self\()QQ; .exitm; .endif
.endm







.macro frac, self, value # static constructor method
  ifdef \self\().isfrac; .if ndef; \self\().isfrac=1;
    .irp property,e,s,m,d,de; \self\().\property = 0; .endr
    .macro \self, v # object method
    .ifb \v; frac.float \self; .else; frac.in \self, \v; .endif; .endm
    .ifnb \value; \self \value
.endm; .macro frac.in, self, v # static parser method

.endm; .macro frac.inc, c # character buffer method

.endm; .macro frac.inn # number detection method

.endm; .macro frac.ins # symbol detection method

.endm; .macro frac.ino # operator detection method

.endm













# --- str buffers
# String objects create purgable, concatenatable buffers of unmutable string data
# Data can be copied to macro arguments by prefixing a macro call with a string passing method

/*## Example usage:

.include "punkpc/str.s"

str test, "World"
# Creates a string called 'test' with the buffer holding memory of the string "World"

test.pfx "Hello "
# Prefixes "Hello " to the FRONT of the buffer, as a prefix; making "Hello World"
# - the space in "Hello " is not trimmed, because it is quoted and concatenated to string memory
# - the two quoted concatenations are combined into a single quoted string
test.conc "!"
# Concatenates a "!" to the END of the buffer, making "Hello World!"
# - quoted strings can be concatenated or prefixed, to merge inputs over multiple calls

test.str .error
# >>> Error: Hello World!
# Passes buffer contents as an argument to the directive '.error', to display the string
# - any macro name can be used to handle the string contained in the str buffer



# There are 2 types of string memory used in string buffers
#   - the types are determined automatically, by input syntax:
# --- String memory - quoted strings
# --- A string contained within "quotes", and containing no other quotes internally
# - Quoted strings are protected from being interpreted as literal strings when processed
# - Quoted strings are concatenated internally:
#   s.conc "Hello ";  s.conc "World"
# >>> "Hello World"
# Strings that remain as a single argument after concatenation will continue being string memory
# - these may be unwrapped for emitting as literals, if needed
# - Normal string memory can't nest strings, but literal memory can... (sort of)

str test "OVERWRITE ME";  test.str .error
str test "CLEAR ME";  test.str .error
test.clear;  test.str .error
test.conc "I AM JUST A BUFFER";  test.str .error
# >>> Error: OVERWRITE ME
# >>> Error: CLEAR ME
# >>> Error:
# >>> Error: I AM JUST A BUFFER
# You can erase string memory by re-initializing with a blank string, or using '.clear'
# - To overwrite memory, you may also re-initialize with a non-blank string

str pi  "3.141592654"
str e   2.718281828
str one "1.0"
pi.litq e.litq, one.litq, .float
# >>> 0x40490FDB, 0x402DF854, 0x3F800000
# >>> (3.1414...) (2.7182...) (1.000...)
# You can enqueue multiple string buffers into a single macro call with '.strq' and '.litq'
# - this allows you to construct arguments abstractly
# Literals can be generated from string memory by using '.lit' in place of '.str' to pass buffer
#  .lit  >>> .float 3.1415         # string result is not quoted
#  .str  >>> .ascii "Hello World"  # string result is quoted
# - the above 2.7182... float is input like a literal string, but is saved like a quoted string
#   - this is because single contiguous arguments can be used interchangably with strings
#   - some unquoted inputs containing problemtic characters (like '=') may still create errors


# --- Literal Memory - source literals
# --- A super string that can contain multiple strings or multiple arguments
# - Literal strings do not unquote strings, and therefor cannot concatenate quoted strings
# - Literal strings are concatenated externally from quotation marks:
#  s.conclit "Hello";  s.conclit , "World"
# >>> "Hello", "World"
# Quoted strings can be enqueued into a list of strings by using a Literal String this way
# - these may be passed as argument strings for macro calls, making them very powerful
#   - arguments that need to be unquoted can be buffered without quotes as literal strings
# - some literals that remain unquoted will cause parsing problems in some cases, like '=' or ':'

str test, Hello World
# Create a literal string containing  Hello World without quotes
# - when interpreted literally, the space ' ' causes this to become 2 separate arguments
#   - this rule can be broken when ending an argument with a number or a math operator
test.lit str.errors
# >>> Error: Hello
# >>> Error: World
# - str.errors is a macro that lets you create multiple errors from an arbitrary number of strings
#   - in this case, 'Hello' and 'World' are interpreted separately
test.str str.errors
# >>> Error: Hello World
# - when using the '.str' method instead of '.lit', you may attempt to wrap the literals in quotes
#   - in this case, this creates a valid single string (because no other quotes are in the buffer)

str test
test.conclit World
# .conclit forces a concatenation to become literal memory even if it is only 1 argument
test.pfxlit Hello_
# .pfxlit can be used to concatenate literals without creating quotations around the input
test.str .error
# >>> Hello_ World
# - When concatening literals however, they generate a space delimiting each concatenation

str.lit test, World
# 'str.lit' may be used in place of 'str' to define a 1-argument literal string
# - you may use this in place of .conclit or .pfxlit, if defining something without concatenation
test.litq str test
# - by passing the literals to a new string definition, we can convert literals->string memory
# - this only works if the literals can be interpreted without syntax errors when made into a string
test.pfx Hello_
test.str .error
# >>> Hello_World
# - now the buffer is back in string memory mode, allowing us to concat without generating spaces

## End of Examples */




.ifndef str.included; str.included=0; .endif;
.ifeq str.included; str.included=1;
.include "punkpc/ifdef.s"

# Static Class Properties:
str$ = 0  # String ID counter

str.bools = 0
str.mQuoting = 1
str.mPrefixing = 2
# process bools, for selecting case for string copy operations
# - this may be optimized later by utilizing altmacro mode with extended callback routines

str.forcelit=0


# Object Contructor Methods:
# --- str name, str ...
# Construct a new (or overwrite an old) string buffer with new string information
#  name : The name of the 'str' object, for referencing this string buffer
#  str  : an optional string that can be quoted, unquoted, or a series of strings
# - blank 'str' will create a blank string, essentially clearing the buffer
# - a "quoted str" or an unquoted argument with no spaces or commas will write 'string memory'
#   - string memory buffers can be passed with their contents either quoted or unquoted
#     - string memory is unquoted before each concatenation, and then requoted when memorized
# - a "series", "of", "strings", or multiple arguments will write 'literal memory'
#   - literal memory buffers act like super-strings that can contain other strings
#     - literals can pass multiple pairs of quotes, but can't unquote strings for string editing
#   - literals can sometimes be re-quoted, but only if the contents contain no other quotes
# --- str.lit name, str ...
# Optional variation of 'str' constructor forces buffer to be a literal string

# Object Propeties:

# Object Methods:
  # --- .conc
  # Concatenate
  # - append a string, or a super-string (a string of strings) to end of buffer mem
  # - multiple strings will cause buffer memory to enter literal mode
  # --- .pfx
  # Prefix
  # - append a string, or a super-string (a string of strings) to front of buffer mem
  # - multiple strings will cause buffer memory to enter literal mode
  # --- .conclit
  # Concatenate Literals
  # - Concatenate, but does not unquote given string for concatenation
  # - forces buffer memory into literal mode
  # --- .pfxlit
  # Prefix Literals
  # - Prefix, but does not unquote given string
  # - forces buffer memory into literal mode
  # --- .clear
  # Clear Buffer
  # - Clears buffer memory, and resets to non-literal mode, if literal mode was enabled
  # - Also clears char buffer, if in use
  # --- .str
  # Pass String
  # - Pass a QUOTED buffer memory to a macro/directive, with optional TRAILING varargs
  # - if not in literal mode; string is unquoted/requoted on pass
  #    - This produces quotes only if they didn't exist before
  # - if in literal mode; literals are wrapped in quotes
  #    - This can't safely produce nested quotes, so attempting to do so will create errors
  # --- .strq
  # Enqueue String
  # - Enqueue a QUOTED buffer memory to a macro/directive call, with optional LEADING varargs
  #   - enqueueing causes strings to build up in the varargs string in the order they are queued
  # --- .lit
  # Pass Literals
  # - Pass UNQUOTED buffer memory to a macro with optional TRAILING varargs
  # --- .litq
  # Enqueue Literals
  # - Enqueue UNQUOTED buffer memory to a macro with optional LEADING varargs

# Class Methods:

.macro str.lit, va:vararg; str.forcelit = 1; str \va
.endm; .macro str, self, varg:vararg

  ifdef \self\().isStr; .if ndef; \self\().isStr = 0; .endif
  .if \self\().isStr == 0; str$ = str$ + 1; \self\().isStr = str$; \self\().litmode=0
    .macro \self\().conc, va:vararg
    str.vacount \va; .if str.vacount > 1;
    str.bools = 0; \self\().strbuf conclit,,\va; .else;
    str.bools = mQuoting; \self\().strbuf conc, \va; .endif
    # --- .conc - Concatenate
    # - append a string, or a super-string (a string of strings) to end of buffer mem
    # - multiple strings will cause buffer memory to enter literal mode

    .endm; .macro \self\().pfx, va:vararg
    str.vacount \va; .if str.vacount > 1;
    str.bools = str.mPrefixing; \self\().strbuf pfxlit,,\va; .else;
    str.bools = str.mPrefixing|str.mQuoting; \self\().strbuf pfx, \va; .endif
    # --- .pfx - Prefix
    # - append a string, or a super-string (a string of strings) to front of buffer mem
    # - multiple strings will cause buffer memory to enter literal mode

    .endm; .macro \self\().conclit, va:vararg
    str.bools = 0; \self\().strbuf conclit,,\va
    # --- .conclit - Concatenate Literals
    # - Concatenate, but does not unquote given string for concatenation
    # - forces buffer memory into literal mode

    .endm; .macro \self\().pfxlit, va:vararg
    str.bools = str.mPrefixing; \self\().strbuf pfxlit,,\va
    # --- .pfxlit - Prefix Literals
    # - Prefix, but does not unquote given string
    # - forces buffer memory into literal mode

    .endm; .macro \self\().clear; str \self
    # --- .clear - Clear Buffer
    # - Clears buffer memory, and resets to non-literal mode, if literal mode was enabled
    # - Also clears char buffer, if in use


    .endm; .macro \self\().str, macro, va:vararg
    str.bools = str.mQuoting; \self\().strbuf str, "\macro", \va
    # --- .str - Pass String
    # - Pass a double-quoted buffer memory to a macro/directive, with optional TRAILING varargs
    # - if litmode = 0; string is unquoted/requoted on pass
    #    - This produces quotes only if they didn't exist before
    # - if litmode = 1; literals are wrapped in quotes  (nesting quotes may cause errors)

    .endm; .macro \self\().strq, macro, va:vararg
    str.bools = str.mQuoting; \self\().strbuf strq, "\macro", \va
    # --- .strq - Enqueue String
    # - Pass a double-quoted buffer memory to a macro/directive, with optional LEADING varargs

    .endm; .macro \self\().lit, macro, va:vararg
    str.bools = 0; \self\().strbuf lit, "\macro", \va
    # --- .lit - Pass Literals
    # - Pass unquoted buffer memory to a macro with optional TRAILING varargs

    .endm; .macro \self\().litq, macro, va:vararg
    str.bools = 0; \self\().strbuf litq, "\macro", \va
    # --- .litq - Enqueue Literals
    # - Pass unquoted buffer memory to a macro with optional LEADING varargs


    .endm; .macro \self\().strbuf;.endm;
    # Dummy method, for memory buffer
    # - this becomes purged, and rewritten to hold our string data -- becoming the "buffer"
    # - when generated, it will be used to dispatch a call to a callback macro from a given keyword
    #   - the callback will then recieve the memorized buffer in a copied, addressable form

  .endif; str.vacount \varg
  .if (str.vacount > 1) || str.forcelit; str.buildlitmem \self, \varg;
  .else; str.buildstrmem \self, \varg; .endif; str.forcelit=0

.endm; .macro str.buildstrmem, self, str
  \self\().litmode = 0; .purgem \self\().strbuf;
    .ifnc "\str", "";
      .macro \self\().strbuf, cb, arg, va:vararg
        str.event.cb_\cb \self, "\arg", "\str" \va
      .endm
    .else;
      .macro \self\().strbuf, cb, arg, va:vararg
        str.event.cb_\cb \self, "\arg", \va
      .endm
    .endif

.endm; .macro str.buildlitmem, self, lit:vararg
  \self\().litmode = 1; .purgem \self\().strbuf
  .macro \self\().strbuf, cb, arg, va:vararg
    .if str.bools & str.mPrefixing; .if str.bools & str.mQuoting
        str.event.cb_\cb \self, "\arg", \va, "\lit"; .else
        str.event.cb_\cb \self, "\arg", \va \lit; .endif
    .else; .if str.bools & str.mQuoting
        str.event.cb_\cb \self, "\arg", "\str", \va; .else
        str.event.cb_\cb \self, "\arg", \lit \va; .endif
    .endif
  .endm

.endm; .macro str.vacount, va:vararg
  str.vacount=0; .irp x, \va; str.vacount = str.vacount+1; .endr;

.endm; .macro str.event.cb_conc, self, conc, mem
  .if \self\().litmode;
    str.buildlitmem \self, \mem \conc;   .else
    str.buildstrmem \self, "\mem\conc"; .endif

.endm; .macro str.event.cb_conclit, self, null, mem:vararg
  str.buildlitmem \self, \mem

.endm; .macro str.event.cb_pfx, self, pfx, mem
  .if \self\().litmode;
    str.buildlitmem \self, \pfx \mem;   .else
    str.buildstrmem \self, "\pfx\mem"; .endif

.endm; .macro str.event.cb_pfxlit, self, null, mem:vararg
  str.buildlitmem \self, \mem

.endm; .macro str.event.cb_str, self, macro, str, va:vararg
  .ifnb \va;
    \macro "\str", \va; .else
    \macro "\str"; .endif

.endm; .macro str.event.cb_strq, self, macro, str, va:vararg
  .ifnb \va;
    \macro \va, "\str"; .else
    \macro "\str"; .endif

.endm; .macro str.event.cb_lit, self, macro, lit, va:vararg
  .ifnb \va;
    \macro \lit, \va; .else
    \macro \lit; .endif

.endm; .macro str.event.cb_litq, self, macro, lit, va:vararg
  .ifnb \va;
    \macro \va, \lit; .else
    \macro \lit; .endif




.endm; .macro str.errors, str, va:vararg;
  .error "\str"; .ifnb \va; str.errors \va; .endif

.endm; .macro str.errors.conc, str, conc, va:vararg;
  .ifnb \va; str.errors.conc "\str\conc", \va
  .else; .error "\str\conc"; .endif

.endm
.endif




















# --- str buffers
# Strings are contained in a passable form by utilizing macro argument memory
# - Strings can be written, overwritten, cleared, and concatenated -- but not otherwise edited
#   - see 'punkpc/char.s' object module for more nuanced character edititng capabilities

/*## Example usage:

.include "punkpc/str.s"

str test, "World"
# Creates a string called 'test' with the buffer holding memory of the string "World"

test.conc "!"
# Concatenates a "!" to the end of the buffer, making "World!"

test.conc, "Hello "
# Concatenates "Hello " to the FRONT of the buffer, making "Hello World!"
# - this is done by adding a comma to '.conc' -> '.conc,'

test.pass .error
# >>> Error: Hello World!
# Passes buffer contents as an argument to the directive '.error', to display the string

str myDirective, ".error"
# Literals can also be stored as strings, so long as they do not use double quotes

myDirective.litva test.passva
# >>> Error: Hello World!
# String arguments can be queued up by using the '.passva' method instead of '.pass'
# - this will cause the strings to be output at the end of the argument chain, in a queue
# Strings can also be emitted literally with '.lit' instead of '.pass'

str pi  "3.141592654"
str e   "2.718281828"
str one "1.0"
pi.litva e.litva, one.litva, .float
# >>> 0x40490FDB, 0x402DF854, 0x3F800000
# Arguments for macros and directives can be constructed abstractly this way

str temp "OVERWRITE ME";  temp.pass .error
str temp "CLEAR ME";  temp.pass .error
str temp;  temp.pass .error
temp.conc "I AM JUST A BUFFER";  temp.pass .error
# >>> Error: OVERWRITE ME
# >>> Error: CLEAR ME
# >>> Error:
# >>> Error: I AM JUST A BUFFER
# You can erase string memory by re-initializing with a blank string
# - To overwrite memory, you may also re-initialize with a non-blank string

## End of Examples */

.ifndef str.included; str.included=0; .endif; .ifeq str.included; str.included=1;
.include "punkpc/ifdef.s"

# Static Class Properties:
str$ = 0  # String ID counter


# Constructor Method:
# --- str name, "string"
# String objects store given string in a string buffer that can be passed as an argument
# - calling the constructor with a string name that already exists will overwrite old string memory
# - if string argument is blank, memory is cleared for this string buffer

# Object Properties:
# --- .isstr   - unique non-0 string Id helps keep track of this string's existence


# Object Methods:
# User-level:
  # --- .conc  "suf", "pfx"
  # Concatenate a prefix and/or suffix to string memory
  #  pfx : prefix literals to concat to memory or overwrite string
  #      - if blank, no prefix is concatenated
  #  suf : suffix literals to concat to memory or overwrite string
  # - syntaxes:
  #   -  myString.conc, "fu"   # a prefix concatenation
  #   -  myString.conc "bar"    # a suffix concatenation

  # --- .pass  macro, ...
  # Pass string memory to a macro, with optional TRAILING varargs
  #  macro : the name of a macro to call, with string passed as first argument
  #    ... : optional trailing arguments that come after passed string
  # - example result:  myMacro "myString", arg1, arg2, arg3
  # --- .lit   macro, ...
  # Pass string memory as an emitted literal argument, unquoted; with optional TRAILING varargs
  # - does not put quotes around string contents -- making them literal
  # - example result:  myMacro  myString, arg1, arg2, arg3

  # --- .passva macro, ...
  # Pass string memory to a macro, with optional LEADING varargs
  #    ... : optional leading arguments that come before passed string
  # - example result:  myMacro arg1, arg2, arg3, "myString"
  # --- .litva  macro, ...
  # - example result:  myMacro arg1, arg2, arg3, myString


# Hidden-level:
  # --- .strmem  cb, mem, ...
  # A method that exploits macro argument memory to store string information
  #   dispatches string memory as an argument to a given callback keyword, with optional varargs
  #  cb : the name of a callback suffix, for the 'str.cb.*' macro namespace
  # mem : the argument that holds memory of given string information
  # ... : additional arguments, for handling callback


# Static Class Methods:
# Hidden-level:
  # --- str.strmem  str, ovw, pfx, suf, ...
  # Builds string memory for a given str object
  #  str : a string object name
  #  ovw : string to overwrite memory with -- blank if using old memory
  #  pfx : prefix to concat to front of string
  #  suf : suffix to concat to end of string
  #  ... : varargs are unused, but accepted to allow for blank commas when passing grouped args

  # --- str.cb.conc str, ...
  # --- str.cb.pass str, macro, ...
  # --- str.cb.passva str, macro, ...
  # --- str.cb.lit str, macro, ...
  # --- str.cb.litva str, macro, ...
  # Hidden callbacks interact with string memory


.macro str, self, s;

  ifdef \self\().isStr;
  .if ndef; \self\().isStr=0; .endif; .if \self\().isStr == 0;
    str$ = str$ + 1; \self\().isStr = str$;

    .macro \self\().conc, suf, pfx; \self\().strmem conc,, "\pfx", "\suf"
    # .conc method can combine a prefix and suffix concatenation operation

    .endm; .macro \self\().pass, macro, va:vararg; \self\().strmem pass,, "\macro", \va
    .endm; .macro \self\().passva, macro, va:vararg; \self\().strmem passva,, "\macro", \va
    .endm; .macro \self\().lit, macro, va:vararg; \self\().strmem lit,, "\macro", \va
    .endm; .macro \self\().litva, macro, va:vararg; \self\().strmem litva,, "\macro", \va
    # .pass method can copy string to first argument of a macro call
    # .passva can copy string to the last argument of a variadic argument queue

    .endm; .macro \self\().strmem;.endm
    # dummy memory method is purged on first string write

  .endif; str.strmem \self "\s";
  # call build method to initialize memory

.endm; .macro str.strmem, self, ovw, pfx, suf, va:vararg
  .purgem \self\().strmem
  # purge old (or dummy) memory method

  .macro \self\().strmem, cb, mem="\pfx\ovw\suf", varg:vararg
    str.cb.\cb \self, "\mem", \varg
    # Re-create memory method with updated string memory

  .endm;
  # The .strmem method will dispatch to a given callback:

.endm; .macro str.cb.conc, self, va:vararg;
  str.strmem \self, \va
.endm; .macro str.cb.pass, self, str, m, va:vararg;
  .ifb \va; \m "\str"; .else; \m "\str", \va; .endif
.endm; .macro str.cb.passva, self, str, m, va:vararg
  .ifb \va; \m "\str"; .else; \m \va, "\str"; .endif
.endm; .macro str.cb.lit, self, str, m, va:vararg;
  .ifb \va; \m \str; .else; \m \str, \va; .endif
.endm; .macro str.cb.litva, self, str, m, va:vararg
  .ifb \va; \m \str; .else; \m \va, \str; .endif
.endm; # String memory is maintained by the event method, and passed to these callbacks
.endif # - these callbacks recieve the string as an argument, allowing the memory to be addressed

/**/








frac.null = -128; frac.inf = 127 # exponent names
.macro frac.align, self=fracA, op=fracB
  # copies properties from inputs
  # denormalizes fractional mantissas for alignment
  dnormA=\self\().m&0x40000000;
  dnormB=\op\().m&0x40000000
  dnormA.e=\self\().e;  normB.e=\op\().e
  dnormA.s=normA.m>>31; normB.s=normB.m>>31
  # remember sign and exponent of normalized
  .if normA.e > normB.e;
    normB=normB>>(normA.e-normB.e)

# if smaller number is too small, it will be replaced with 0 when denormalized
# if number is unordered or null, it will be replaced with 0 when denormalized

.macro frac.abs
















  frac.carry=frac.kara+(frac.L>>16)
  ;
  frac.H=frac.H+frac.carry
  frac.
  (frac.kara>>16+(frac.H&0xFFFF))<<16
  (frac.kara&0xFFFF+(frac.L>>16))

  frac.kara=frac.L>>16+frac.kara;
  frac.L=(-frac.S^(frac.carry&0xFFFF+frac.L)+frac.S;
  frac.carry=(frac.carry^frac.kara)>>16;
  frac.H=-frac.S^(frac.kara>>16+frac.carry+frac.H)
.endm; .macro frac.div
.endm;




.macro frac.align; .if frac.e>frac.op.e; frac.op.m=frac.op.m>>(frac.e-frac.op.e);
    frac.op.e=frac.e; .else; frac.m=frac.m>>(frac.op.e-frac.e); frac.e=frac.op.e; .endif
.endm; .macro frac.add; frac.align; frac.m=frac.m+frac.op.m;
  .if frac.m>>31; frac.m=frac.m>>1; frac.e=frac.e+1; .endif
.endm; .macro frac.sub; frac.align; frac.m=frac.m-frac.op.m;
  .if frac.m>>31; frac.m=frac.m<<1; frac.e=frac.e-1; .endif
.endm; .macro frac.mul; frac.align;

  .if \a\().e < \b\().e; frac.sub \b\().e, \a\().e; .exitm;.endif
  frac.m=\b\().m>>(\a\().e-\b\().e); frac.m=\a\().m+\b\().m
  .if frac.m>>31; frac.m=frac.m>>1; frac.e=\a\().e+1
  .else; frac.e=\a\().e; .endif


.if frac.e > frac.op.e
  frac.op.m=frac.op.m>>(frac.e-frac.op.e); frac.m=frac.m-frac.op.m
  frac.e=frac.e-(frac.m>>31); frac.m=frac.m&0x3FFFFFFF; frac.op.e=frac.e; .else
  frac.m=frac.m>>(frac.op.e-frac.e); frac.m=frac.m+frac.op.m;
  frac.e=frac.e+(frac.sub.s); frac.m=frac.m&0x3FFFFFFF; frac.e=frac.op.e; .endif
.endm





.macro m, i
  .if i==0; i='0
  .elseif i==1; i='1
  .elseif i==2; i='2
  .elseif i==3; i='3
  .endif
.endm


.altmacro
.macro mm, i
  mm\i
.endm; .macro mm0; i='0
.endm; .macro mm1; i='1
.endm; .macro mm2; i='2
.endm; .macro mm3; i='3
.endm;




.macro xem2,p,i1,s1,i2,s2;.altmacro;xem2a p,i1,s1,i2,s2;.noaltmacro;.endm
.macro xem2a,p,i1,s1,i2,s2; \p\i1\s1\i2\s2; .endm
.macro xem3,p,i1,s1,i2,s2,i3,s3;.altmacro;xem3a p,i1,s1,i2,s2,i3,s3;.noaltmacro;.endm
.macro xem3a,p,i1,s1,i2,s2,i3,s3; \p\i1\s1\i2\s2\i3\s3; .endm
.macro xem4,p,i1,s1,i2,s2,i3,s3,i4,s4;.altmacro;xem4a p,i1,s1,i2,s2,i3,s3,i4,s4;.noaltmacro;.endm
.macro xem4a,p,i1,s1,i2,s2,i3,s3,i4,s4; \p\i1\s1\i2\s2\i3\s3\i4\s4; .endm
.macro xem8,p,i1,s1,i2,s2,i3,s3,i4,s4,i5,s5,i6,s6,i7,s7,i8,s8;.altmacro
  xem8a p,i1,s1,i2,s2,i3,s3,i4,s4,i5,s5,i6,s6,i7,s7,i8,s8;.noaltmacro;.endm
.macro xem8a,p,i1,s1,i2,s2,i3,s3,i4,s4,i5,s5,i6,s6,i7,s7,i8,s8
  \p\i1\s1\i2\s2\i3\s3\i4\s4\i5\s5\i6\s6\i7\s7\i8\s8; .endm




.macro altmacro.test; m 0;.endm
.macro test; .altmacro;m %1-1;.endm
.macro m, i; .noaltmacro; m\i; .endm;
.macro m0; m=0; .endm
.rept 0xFFFF

.endr



# --- callback macros
# - can be used to minimize the size of your macro handles, for repetative string copy operations
.macro m, i
  .noaltmacro;m\i
.endm
.macro m0; .byte 0; .endm
.macro m1; .byte 1; .endm
.altmacro;m %1-1
.altmacro;m %1+0



# --- ascii buffered into int...
# very useful
.macro m, s;
  .irpc c, \s;
    mm "'\c"
  .endr
.endm; .macro mm,l;sym=\l;.endm
m 0123456789abcdefABCDEFGHIJLMNOPQRSTUVWXYZ


# --- expression tuple
.irp s (1 + 1 , 3), (4,5)
  .irpc c \s;
    .ifc \c, (; .byte \s )
    .else; .byte ( \s
    .endif; .exitm
  .endr
.endr


# --- evaluation juggling
i=0; x=0; y=0
.macro eval, v, b
  .ifb \v;
    # use blank args to print byte
    # the values of x and y can't be safely evaluated in if statements, so i is checked instead
    .if i; .byte (y)&0xFF;
    .else; .byte (x)&0xFF;
    .endif; x=0; y=0
  # else, give a value and a mask to buffer bits
  .elseif i; x=(\v)&((1<<\b)-1)|((y<<\b)); i=0 # x assignment does not reference x
  .else;     y=(\v)&((1<<\b)-1)|((x<<\b)); i=1 # y assignment does not reference y
  .endif;
.endm
_start:
# evaluate locations by using bools from ((label-self)>0)
# - delta of 2 relative locations becomes absolute
# <, <=, ==, !=, >, >= && ||  create boolean values 0 or -1
#  - 0 and -1 can be used to mask values to hide untrue comparisons
eval ((_a-.)>0), 1
eval ((_b-.)>0), 1
eval ((_c-.)>0), 1
eval ((_d-.)>0), 1
eval ((_e-.)>0), 1
eval ((_f-.)>0), 1
eval
_end:
# the following labels are referenced before they are defined; but are still evaluated
# - if program ends without these labels being defined, errors will be created
_a:_b:_c:_d:_e:_f:





.macro tester, x
test \x
.endm
.macro test, x, va:vararg
  .irpc c, "\x"
    .ifc "\c", "("
	.long 1
    	.exitm
    .endif
    .long 0
    .exitm
  .endr
.endm

tester x=(hello world)
