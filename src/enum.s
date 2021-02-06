# --- Enumerator Objects
#>toc obj
# - a powerful object class for parsing comma-separated inputs
#   - default behaviors are useful for counting named registers and offsets
#   - highly mutable objects may be individually mutated for custom behaviors
# - useful for creating methods that handle user inputs, or that consume `items` buffers

# --- Updates:
# version 0.2.2
# - added 'en' module, for fast (featureless) enumeration processes
# - added 'quick' 'enum_parse_iter' mutator mode, for implementing 'en'-like enumerator objects
# - added 'relative' 'numerical' mutator mode, to edit count index relatively instead of absolutely
# version 0.2.1
# - implemented default mutator hooks, to lower the number of macros required for each object
# - changed order of operations in loading old 'xem' prereq with 'regs' at end of module
#   - 'regs' relies on macros defined by enum, so it must come after the module is initialized

# --- version 0.2.0
# - rewrote entire module from scratch, simplified many things
# - everything is now driven by mutator hooks from the 'mut' module
#   - whole object may be re-designed through the use of custom behaviors
#   - broke into different default constructors that support different hook modes
# - implemented object pointers, with the 'obj' module

# --- version 0.1.0
# - completely remodeled object system to be mutator-based
# - added sidx.s and ifalt.s to module, for 4D scalars and altmacro mode checks
# - removed 'enum.bool' and 'enum.bool_restart' methods in favor of mutated 'enum'
# - added new state flags that can be used to drive the enumerator parse through callbacks
# - fleshed out callback system to support many new method mutators
# - added a generic mutator class method that can be used to assign macros in place of obj methods
# - remodeled character parse to be mutable, so that you can add new types of argument syntaxes
# version 0.0.5
# - fixed bug in original code that was preventing crf from updating correctly in .mask methods
# - merged the enum and enumb constructors into one class
# - provided mutators that create backwards compatability with old enumb namespaces
# - remamed '.reset' to '.restart' to avoid conflict with stack method names
# - created a separate restart method for bool counting
# - added overridable dummy callbacks to object methods
# version 0.0.4
# - added '.reset' methods to enumerator objects
# - added a '.last' and '.reset' property for enumerator objects
# version 0.0.3
# - added varargs to constructors, so initial settings can be added to enum generators
# - updated documentation attributes
# version 0.0.2
# - added xem.s to module, for register names
# - added *.pfx variants of old functions, to support prefix namespaces
# - added a constructor, for instantiating enumerators with a private count, and name

# --- Constructor Methods

# --- enum.new      self, prefix, suffix, ...    - default enumerator type
# --- enumb.new     self, prefix, suffix, ...    - special 'bool mask' enumerator type
# Constructors for making enumerator objects called 'self'
#   'prefix' and 'suffix' can be used to give each symbol name input an implied beginning/ending
#   - can be blank, to ignore concatenation
# '...' can be used to input arguments into the new enumerator, after it is created
# - alternatively, inputs can be made iteratively through calls to the object -- directly by name

# --- enum.new_generic  self, prefix, suffix
# --- enum.new_raw      self, prefix, suffix
# Low level constructors used by enum.new, enumb.new, and any custom constructors that extend enum
# - other functions can be written to wrap around it to make other types of enumerator objects
# - this will accept '...' args for compatibility, but does nothing with them



  # --- Generic (Default) Object Properties

  # --- .is_enum - Object instance ID, for creating pointers
  # --- .steps - keeps memory of the number of iterations made, ignoring step size
  # --- .step  - keeps memory of how much to increase (or decrease) index by each step
  # --- .step.restart  - overridable property given by the constructor arguments
  # --- .last  - keeps memory of last assigned count
  # --- .count - keeps memory of the current index being counted
  # --- .count.restart - overridable property given by the constructor arguments
  # --- .hook.enum_parse_iter.mode - ID indicating current parse mutator mode
  # --- .hook.numerical.mode       - ID indicating current num mutator mode
  # --- .hook.literal.mode         - ID indicating current nnum mutator mode
  # --- .hook.count.mode           - ID indicating current count mutator mode
  # --- .hook.step.mode            - ID indicating current step mutator mode
  # --- .hook.restart.mode         - ID indicating current restart mutator mode
  # 1 = default mode ID




  # --- Generic (Default) Object Methods ---
  # This is a mode of object generated with 'enum.new' constructor

  # --- (self)  sym, sym ...
  # Assigns a count to each given symbol name, according to enumeration property memory
  # - if 'sym' starts with a letter or _.$ chars -- then it is couted like a symbol
  # - if not, then the input is checked for special in-line syntaxes:
  #   - inputs starting with '+' or '-' will set the '.step' property to a new value
  #   - inputs enclosed in (parentheses) will set the '.count' property to a new value

  # --- .enum_conc  pfx, sfx,  sym, sym, ...
  # A version of main method 'self' that lets you use custom symbol prefixes/suffixes
  # - 'pfx' will be concatenated to the front of each given symbol
  # - 'sfx' will be concatenated to the end of each given symbol
  #   - if 'pfx' or 'sfx' is blank, the resulting concatenations will also be blank
  # - (self) method invokes this method

  # --- .restart
  # Restarts the enumerator object, setting it back to its first assigned count/step
  # - these values are stored in '.restart.count' and '.restart.step'

  # --- .mut   mut, hook, ...
  # Apply mutator 'mut' macro in place of current behavior for given hook keyword
  # - if multiple hooks are given through '...', they will all recieve the same mutator
  # - see Hooks for more info, below

  # --- .mode  hook, mode
  # Apply a mode to a given hook name, undoing any mutations made to the hook
  # - see Modes for more info, below

  # --- .hook  hook, ...
  # Register any number of hook names as new hooks for this object
  # - if hook has already been created, then this will cause it to restart back to class default




  # --- Bool Mask Object Mode Mutations ---
  # This is a mode of object generated with the 'enumb.new'

    # --- (self)  Sym, Sym ...
    # Alternate enumerator sticks to an index between 0...31, and generates 'bool' and 'mask' syms
    # - Each given 'Sym' produces a 'bSym' and an 'mSym' symbol with special index values
    #   - 'bSym' is a bit index that matches syntax used in PPC cr instructions
    #   - 'mSym' is a mask representing the bit index
    # - if 'Sym' is an existing symbol, then its value as 0 (FALSE) or not 0 (TRUE) can build masks

    # --- .mask   Sym, Sym, ...
    # Generates a 32-bit mask out of a series of Symbols, and their corresponding mSymbol masks
    # - 'Sym' is an input symbol that matches the name given to the '(self)' method, earlier
    #   - if the value 'Sym' is not defined, it is assumed to be FALSE
    #   - if the value is 0, it is assumed to be FALSE
    #   - else, it is assumed to be TRUE
    # - the value of 'Sym' will be ORed in using the corresponding 'mSym' mask bit(s)
    # --- .mask - a return property, for the '.mask' method




  # --- Modes ---
  # Use '.mode' to set these keyword combinations '\hook, \mode' manually
  #  'enum.new'  and  'enumb.new'  will handle these mode settings automatically on construction
  #  You may create custom modes by defining macros with the syntax:  \self\().mut.\hook\().\mode

    # --- enum_parse, default
    # Parses for each given argument, unless the '.enum_exiting' property is set to true

    # --- enum_parse_iter, default
    # Simply checks the first char for numbers or math chars, and splits handle as 'num' or 'else'

    # --- numerical, default
    # Handles inputs that start with '(', '+', or '-' by invoking either the 'count' or 'step' hooks

    # --- literal, default
    # Handles inputs as symbol names, for assignment -- also increments '.count' by '.step'

    # --- count, default
    # Assignments to '.count' have no checks or limitations

    # --- step, default
    # Assignments to '.step' have no checks or limitations

    # --- restart, default
    # restarts '.count' and '.step' back to memorized init values, and sets '.steps' to 0


    # --- literal, bool
    # Assigns a calculated 'bit index' with the count hook, and a 'mask' symbol with the result

    # --- count, bool
    # Assigns count after ANDing it by 0x1F -- creating a modulo range of 0...31


    # --- numerical, relative
    # Causes adjustments to the count index to be relative instead of absolute



  # --- Hooks ---
  # Use '.mut' with these keywords to assign new macros in place of default hooks
  # - Mutators will be called like callbacks, with the following provided arguments
  # - '...' indicates any additional args will also be passed, for extending the hook functionality

    # --- enum_parse  self, prefix, suffix, ...
    # Override this to change how all given inputs get parsed

    # --- enum_parse_iter  self, symbol, prefix, suffix, arg
    # Override this to completely take control of the 'for each argument' loop in the main method

    # --- numerical   self, arg, prefix, suffix, ...
    # The method that gets invoked to handle inputs that trigger 'ifnum'
    # - override this to change how inputs that start with '0123456789+-*%/&^!~()[]' are handled
    # - 'char' is the ascii encoding for the detected character

    # --- literal     self, symbol, prefix, suffix, arg, ...
    # The method that gets invoked to handle each literal input
    # - 'literal' inputs are just inputs that didn't trigger 'numerical' check, through 'ifnum'
    # - override this to change how literal inputs are handled after counting

    # --- count       self, symbol, prefix, suffix, arg, ...
    # Responsible for setting the 'count' property
    # - override this to create conditions, rules, and processing for the resulting value

    # --- step        self, symbol, prefix, suffix, arg, ...
    # Responsible for setting the 'step' property
    # - override this to create conditions, rules, and processing for the resulting value

    # --- restart     self, symbol, prefix, suffix, arg, ...
    # Responsible for restartting the volatile properties used by this object


# Calling '.hook' with any of these keywords will automatically set them to their 'default' modes
# --- ex:  enum.temp.hook  count
# - count hook has been set to default behavior

# Calling '.mut' with a custom mutator name will override the current hook(s)
# --- ex:  enum.temp.mut   my_mutator,  numerical, literal
# - numerical and literal argument handlers have been mutated

# Calling '.mut' with a blank mutator name will cause any assigned hooks to become nops
# --- ex:  enum.temp.mut   , count, step
# - count and step argument handlers now do nothing



# --- Class level Objects

# --- enum  - for global (volatile) use -- uses default modes
# --- enumb - for global (volatile) use -- uses bool mask counter modes



# --- Class Properties

# --- Class Methods

# --- enum.point   enum_pointer, macro, ...
# Pass the name associated with a specific enum object pointer to a given macro
# - a 'pointer' is just an id number, recorded at construction in the '.is_enum' property

# '...' will become trailing arguments in the resulting call, like:   macro  obj, ...

# --- enum.pointq  enum_pointer, macro, ...
# A variation of 'enum.point' that inserts '...' BEFORE the object name argument, instead of after
# - 'q' for 'queue'


# --- enum.pointer  obj
# Generate a pointer from either an enum object name, or an evaluation of the pointer (redundantly)
# - allows obj names/pointers to be used interchangeably in cases where self-pointers are not used
# --- enum.pointer - return property for 'enum.pointer' produces a pointer ID


# --- enum.hook        hook, enum  - construct mutator hooks
# --- enum.mode  mode, hook, enum  - mutate hook with a registered mode keyword
# --- enum.mut   mut,  hook, enum  - mutate hook with unregistered mutation callback
# --- enum.mut   enum   - alternative syntax constructs mutator methods for new obj
# Class level mutator Macros
# - 'enum' is the name of an enumerator object
#   - you may use these at the object level, too.ifndef punkpc.library.included; .include "punkpc.s"; .endif
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
