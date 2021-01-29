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
