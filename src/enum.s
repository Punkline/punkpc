.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module enum, 0x202
.if module.included == 0

  punkpc obj, en
  # import punkpc class module prereqs, if not already in assembler environment
  enum.uses_mutators = 1
  obj.class enum
  enum.uses_pointers = 1
  enum.self_pointers = 0
  enum.count_default = 0
  enum.step_default  = 1
  enumb.count_default = 31
  enumb.step_default  = -1
  # class properties

  # raw constructor:
  .macro enum.new_raw, self, prefix, suffix, varg:vararg
    enum.obj \self
    .if obj.ndef
    # if 'self' has just been newly defined, then initialize its methods and properties:

      \self\().enum_exiting  = 0
      # setting this to 1 from inside of a mutator callback will cause parse to abort
      # setting this to a number higher than 1 will cause it to count down each iter, and exit on 0

      enum.purge_hook \self,  enum_parse
      # this sets the default 'enum_parse' hook for '.enum_conc' to use
      # - default is implied, so hook starts off uninstantiated (purged)

      enum.meth \self, restart
      # this sets the default 'restart' method of this object

      \self\().mut,  enum_parse_iter, restart
      # - the comma creates a blank first argument -- causing a nop to be used in place of a hook
      # - executing these hooks does nothing, but creates no errors

      .macro \self, va:vararg;
        enum.mut.enum_conc.default \self, \prefix, \suffix, \va
        # 'self' method memorizes initial 'prefix' and 'suffix' literals from this constructor call

      .endm
    .endif
  .endm;

  # generic constructor:
  .macro enum.new_generic, self, prefix, suffix, varg:vararg
  # A basic enumerator, with default modes and properties

    enum.new_raw \self, \prefix, \suffix
    .if obj.ndef
      \self\().count.restart = 0
      \self\().step.restart  = 1
      \self\().count = enum.count_default
      \self\().step  = enum.step_default
      \self\().steps = 0
      \self\().last  = 0
      # generic properties power the default hooks

      enum.purge_hook \self, enum_parse_iter, numerical, count, step, restart
      # all purged hooks will defer to their default modes

      \self\().mut, literal
      # default hooks use the 'default' mode keyword
      # - nops from generic are given a hook call, as a replacement
      # - additional hooks are created for 'numerical', 'count', and 'step'
      # - 'literal' still has a nop to handle non-numerical args
      #   - numerical args only handle '(', '+', and '-' to invoke 'count' and 'step'
      # all or none of these may be overridden by the wrappers that extend them
    .endif
  .endm

  # default constructor:
  .macro enum.new, self, prefix, suffix, va:vararg
    enum.new_generic \self, \prefix, \suffix
    .if obj.ndef
      \self \va
      \self\().step.restart = \self\().step
      \self\().count.restart = \self\().count
      \self\().count = enum.count_default
      \self\().step = enum.step_default
      # the resulting count and step is recorded into the '*.restart'

      enum.purge_hook \self, literal
      # default literal mode is assumed by default

      \self \va
      # Default modes are all set
      # initial 'step' or 'count' syntaxes in starting inputs are remembered by '*.restart' values
      # - if none are provided, then defaults set by 'new_generic' are retained

    .endif
  .endm

  # bool mask mode constructor:
  .macro enumb.new, self, prefix, suffix, varg:vararg
    enum.new_generic \self, \prefix, \suffix
    .if obj.ndef
      \self\().mask = 0
      \self\().crf = 0
      \self\().mode count, bool
      # hook is instantiated to change this objects count mode to 'bool'

      \self\().count = enumb.count_default
      \self\().step = enumb.step_default
      # set count hook to bool mode, causing it to be masked to a 5-bit value
      # - this represents a bit index, between 0...31 -- and fits into cr instruction args

      \self \varg
      \self\().step.restart = \self\().step
      \self\().count.restart = \self\().count
      enum.purge_hook \self, mask
      # default mask mode is assumed

      \self\().mode literal, bool
      # hook is instantiated to change object's literal mode to 'bool

      \self\().count = enumb.count_default
      \self\().step = enumb.step_default
      \self \varg
      .macro \self\().mask, va:vararg
        mut.call \self, mask, default, enum, , , \prefix, \suffix, \va
      .endm
    .endif
  .endm


enum.meth, enum_parse, enum_parse_iter, numerical, literal, count, step, mask
# These class methods automatically defer to the 'default' mutator callbacks, below:


# --- Default Mutator Mode callbacks:

  .macro enum.mut.enum_conc.default, self, va:vararg
    ifalt
    enum.ifalt = alt
    .noaltmacro
    mut.call \self, enum_parse, default, enum, , , \va
    ifalt.reset enum.ifalt

  .endm; .macro enum.mut.enum_parse.default, self, pfx, sfx, va:vararg
    .irp arg, \va;
      \self\().enum_exiting = 0
      .ifnb \arg # for each arg in varargs

        mut.call \self, enum_parse_iter, default, enum, , , \pfx\arg\sfx, \pfx, \sfx, \arg
        # execute parse iteration hook, with

        .if \self\().enum_exiting > 0  # if the exiting countdown is a positive number...

          \self\().enum_exiting = \self\().enum_exiting -1
          .if \self\().enum_exiting == 0
            .exitm
          .endif
        .endif
      .endif
    .endr  # dump each non-blank arg into the 'enum_parse_iter' hook
  .endm

  .macro enum.mut.enum_parse_iter.default, self, sym, pfx, sfx, arg, va:vararg
    ifnum_ascii \arg
    .if num; mut.call \self, numerical, default, enum, , , \arg, num, \pfx, \sfx, \va
    .else;   mut.call \self, literal, default, enum, , , \sym, \pfx, \sfx, \arg, \va; .endif

  .endm; .macro enum.mut.numerical.default, self, arg, char, va:vararg
    .if \char == 0x28;     mut.call \self, count, default, enum, , , \arg, \va
    .elseif \char >= 0x30
      .if \char <= 0x39;   mut.call \self, count, default, enum, , , \arg, \va; .endif
    .elseif \char == 0x2B; mut.call \self, step, default, enum, , , \arg, \va
    .elseif \char == 0x2D; mut.call \self, step, default, enum, , , \arg, \va
    .endif

  .endm; .macro enum.mut.literal.default, self, arg, va:vararg
    \arg = \self\().count
    mut.call \self, count, default, enum, , , \self\().count + \self\().step
    \self\().steps = \self\().steps + 1

  .endm; .macro enum.mut.count.default, self, arg, va:vararg
    \self\().last = \self\().count; \self\().count = \arg

  .endm; .macro enum.mut.step.default, self, arg, va:vararg
    \self\().step = \arg

  .endm; .macro enum.mut.restart.default, self, va:vararg
    \self\().step = \self\().step.restart
    \self\().count = \self\().count.restart

  .endm; .macro enum.mut.mask.default, self, pfx, sfx, va:vararg
    .irp arg, \va
      .ifnb \arg
        .irp conc, m\arg\sfx; enum.__bool_mask \self, \pfx\arg\sfx, \pfx\conc; .endr
      .endif
    .endr

  .endm; .macro enum.__bool_mask, self, arg, mask, va:vararg
    ifnum \arg
    .if nnum
      ifdef \arg
      .if ndef
        \arg = 0
      .endif
      .if \arg
        \self\().mask = \self\().mask | \mask
        enum.__crf_index = \arg >> 2
        \self\().crf = \self\().crf | (1 << enum.__crf_index) & 0xFF
      .endif
    .endif

  .endm; .macro enum.mut.literal.bool, self, sym, pfx, sfx, arg, va:vararg
    \pfx\()b\arg\sfx = \self\().count & 0x1F
    mut.call \self, count, bool, enum, , , \self\().count + \self\().step
    \pfx\()m\arg\sfx = 0x80000000 >> \pfx\()b\arg\sfx
    \self\().steps = \self\().steps + 1

  .endm; .macro enum.mut.count.bool, self, arg, va:vararg
    \self\().last = \self\().count; \self\().count = \arg & 0x1F



  .endm; .macro enum.mut.numerical.relative, self, arg, char, va:vararg
    .if \char == 0x28;     mut.call \self, count, default, enum, , , \self\().count + \arg, \va
    .elseif \char >= 0x30
      .if \char <= 0x39;   mut.call \self, count, default, enum, , , \self\().count + \arg, \va;
      .endif
    .elseif \char == 0x2B; mut.call \self, step, default, enum, , , \arg, \va
    .elseif \char == 0x2D; mut.call \self, step, default, enum, , , \arg, \va
    .endif


  .endm; .macro enum.mut.enum_parse_iter.quick, self, arg, va:vararg
    \arg=\self\().count; \self\().count = \self\().count + \self\().step

  .endm





  # The following macros provide backwards compatability with legacy class-level enum tools

  enum.new enum.temp
  enumb.new enumb.temp, , , -1, (31)
  # default 'temp' objects, for volatile use through class-level macros

# --- enum - powered by 'enum.temp'
  .macro enum, va:vararg;
    enum.enum_conc,, \va
  .endm; .macro enum.enum_conc, va:vararg
    .irp p, last, count, step, steps; enum.temp.\p = enum.\p; .endr
      enum.mut.enum_conc.default enum.temp, \va
    .irp p, last, count, step, steps; enum.\p = enum.temp.\p; .endr
  .endm; .macro enum.restart, self, va:vararg
    .ifb \self;
      .irp p, restart.count, restart.step; enum.temp.\p = enum.\p; .endr
        enum.temp.restart
      .irp p, count, step; enum.\p = enum.temp.\p; .endr
    .else; enum.call_mut \self, restart, default, \va; .endif

# --- enumb - powered by 'enumb.temp'
  .endm; .macro enumb, va:vararg;
    enumb.enum_conc,, \va
  .endm; .macro enumb.enum_conc, va:vararg
    .irp p, last, count, step, steps; enumb.temp.\p = enumb.\p; .endr
      enum.mut.enum_conc.default enumb.temp, \va
    .irp p, last, count, step, steps; enumb.\p = enumb.temp.\p; .endr
  .endm; .macro enumb.restart
    .irp p, count.restart, step.restart; enumb.temp.\p = enumb.\p; .endr
      enumb.temp.restart
    .irp p, count, step; enumb.\p = enumb.temp.\p; .endr
  .endm; .macro enumb.mask, va:vararg
    .irp p, mask, crf; enumb.temp.\p = enumb.\p; .endr
      enumb.temp.mask \va
    .irp p, mask, crf; enumb.\p = enumb.temp.\p; .endr
  .endm
  .irp p, last, count, step, steps, count.restart, step.restart
    enum.\p = enum.temp.\p; enumb.\p = enumb.temp.\p
  .endr; enumb.mask = 0; enumb.crf = 0


  punkpc regs
  # - regs module is dependent on enum macros, but also useful to enum syntaxes
  # - codependency requires that it is implemented after all enum macros are defined

.endif
