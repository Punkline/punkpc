/*## Header:
# --- Enumerator Tools
# Useful tools for making index dictionaries
# Highly mutable, can be used as a generic parsing object generator, with custom behaviors

##*/

##/* Updates:

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
##*/


/*## Attributes:

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
#   - you may use these at the object level, too


## Binary from examples:

## E0000000 540307BD
## 540307BD 5000D884
## 00000003 7C001120
## 409F0014 409D0008
## 60000000 41BE0008
## 60000000 100C0804
## 83E30000 83C30004
## 83A30008 8383000C
## 83630010 8B430014
## 8B230015 A3030016
## 83E40000 83C40010
## BFC10010 83E50000
## 83C40008 3BA00018
## BFA10020 63180000
## B3030016 7F000120
## 409F0014 409D0008
## 60000000 41BE0008
## 60000000 00000009
## 00000009 00000009
## 00000000 00000001
## 00000002 00000003
## 00000003 00000009
## 0000000F 00000000
## 00000003 00000009
## 0000000F 00000000
## 00010203 04000102
## 00010001 20112028
## 202F202F 20321A20
## 20203220 35202F20
## 2720EC00 1337BEEF
## 1337BEEF 1337BEEF
## 00000000 00000001

##*/
/*## Examples:
.include "punkpc.s"
punkpc enum
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- ENUMERATIONS ---

enum A B C D  # enumerate given symbols with a count; starting with 0, and incrementing by +1
enum E F G H  # ... next call will continue previous enumerations...
# >>>  A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7

enum (31)     # re-orient enumeration value so that count will start at 31, using ( ) parentheses
enum -4       # set enumeration to increment/decrement by a specific amount with +/-
enum I, +1, J K L  # these can be in-line with symbol arguments
# >>>  I=31, J=27, K=28, L=29

enum (31),-1,rPlayer,rGObj,rIndex,rCallback,rBools,rCount
# enumerate register names ...

sp.xWorkspace=0x220
enum (sp.xWorkspace),+4,VelX,VelY,RotX,RotY,RGBA
# enumerate offset names ...
# etc..




# --- BOOL ENUMERATIONS ---

enumb Enable, UseIndex, IsStr
# state the bool symbol names you want to use:
# >>> bEnable   = 31; mEnable   = 0x00000001
# >>> bUseIndex = 30; mUseIndex = 0x00000002
# >>> bIsStr    = 29; mIsStr    = 0x00000004
#   mMask and bBit symbols are created for each

enumb (0), +1, A, B, C
# >>> bA = 0; mA = 0x80000000
# >>> bB = 1; mB = 0x40000000
# >>> bC = 2; mC = 0x20000000
#   (0) sets the index to 0, and +1 sets the step to increment by 1

.long mA|mB|mC
# >>> 0xE0000000

rlwinm. r3, r0, 0, bUseIndex, bUseIndex
rlwinm. r3, r0, 0, mUseIndex
# both of these rlwinms are identical

rlwimi r0, r0, bIsStr-bC, mC
# insert bIsStr into bC in a single register/instruction




# --- BOOL MASK GENERATOR ---

enumb.restart
# you can reset the counter back to its default position this way, to make a new mask

enumb Enable, UseIndex, IsStr       # state the bool symbol names you want to use
Enable = 1; UseIndex = 1;           # set some boolean values as T/F
# unassigned bool IsStr is assumed to be 0

enumb.mask Enable, UseIndex, IsStr  # generate a mask with said bools using 'enumb.mask'
# this uses the mMask value and the state values to create a combined state mask

m=enumb.mask;  .long m              # mask will compile from given 'enumb' index values
# you can save the combined mask by copying the return enumb.mask property
# >>> 0x00000003

crf=enumb.crf;  mtcrf crf, r0
# you can move partial fields directly into the volatile CR registers with mtcrf, and enumb.crf

bf- bEnable, 0f
  bf- bIsStr, 1f
    nop  # example string handler goes here

  1:
  bt+ bUseIndex, 0f
    nop  # example index handler goes here

0:
# once in the CR, each bool can be referenced by name in 'bf' or 'bt' branch instructions




# --- ENUM PREFIXES AND SUFFIXES ---

enum.enum_conc "myNamespace.", "", -4, (0x10), A, B, C, D
# "myNamespace." is a prefix
# "" is a blank suffix, which can also just be left blank, or as a space character
# - doesn't need to be in quotes, but it makes the syntax a bit more readible and doesn't interfere

.byte myNamespace.A, myNamespace.B, myNamespace.C, myNamespace.D
# 'enum_conc' allows you to imply a static part of a namespace in the resulting symbol assignments




# --- ENUMERATOR OBJECTS ---
# Enumerator objects can have prefixes and suffixes built into them

enum.new  myStruct, "struct.", "", +4, (0)
# creates an enumerator object called 'myStruct'
# - this object will restart at index 0, with a +4 step
# - all symbol names given to the main method will be given a prefix of 'struct.*'


# The "" arguments may be entirely blank, you just have to make sure to add commas:

enum.new  myRegs, , , -1, (r31)
# creates an enumerator object called 'myRegs'
# - this object will count down from r31, and restart at r31 with the '.restart' method
# - it has no prefix or suffix strings applied to symbol names by default


myRegs    rPrev, rNext, rColor, rData, rStr, rID, rPriority, rBools
myStruct  xPrev, xNext, xColor, xData, xStr, +1, xID, xPriority, +2, xBools

# These register and offset names can be used in load/store instructions:

lwz rPrev,     struct.xPrev(r3)     # 0x00, r31
lwz rNext,     struct.xNext(r3)     # 0x04, r30
lwz rColor,    struct.xColor(r3)    # 0x08, r29
lwz rData,     struct.xData(r3)     # 0x0C, r28
lwz rStr,      struct.xStr(r3)      # 0x10, r27
lbz rID,       struct.xID(r3)       # 0x14, r26
lbz rPriority, struct.xPriority(r3) # 0x15, r25
lhz rBools,    struct.xBools(r3)    # 0x16, r24


myRegs.restart
# the '.restart' method can be used to restart the counter/step back to its original settings

myRegs  rThis, rThat
# - since we restarted the counter, this is a new set of registers

lwz rThis, 0x00(r4)
lwz rThat, 0x10(r4)
stmw myRegs.last, 0x10(sp)
# the '.last' property saves the last assigned count value, and can be used in stmw/lmw instructions
# - in the case of stmw, this lets us reference the last register without using its name directly


myRegs.restart
myRegs  rThese, rThose, rSize
lwz rThese, 0x0(r5)
lwz rThose, 0x8(r4)
li rSize, myStruct.count
stmw myRegs.last, 0x20(sp)
# the '.count' property memorizes the next count value to assign, and can be used to reference sizes



# The 'step' is just an added or subtracted value

# Setting the step to +0 will cause the iterations to stop counting, but still make assignments
enum.new  set_false, "", "", (0), +0
enum.new  set_true,  "", "", (1), +0
# - these will not count up when assigning their value (0 or 1) to each given symbol name

set_true  Enabled, UseIndex, EnableLinks
# This sets the given symbols to '1', which is a 'true' value
# - we've assigned the bools 'Enabled', 'UseIndex' and 'EnableLinks' to 'true'


enumb.new  myBools, "myBools."
# 'enumb' variant of the constructor creates bit mask counters, like the 'enumb' macro
# - this starts at a default count of 31, with a -1 step

myBools   Enabled, Hidden, UseIndex, IsStr, UseIDKey, SkipPriority, EnableLinks, CustomColor
# Every symbol given here is used to assign a bit index and a bit mask to represent bool values
#  mEnabled      = 0x01       bEnabled      = 31       Enabled       = 1
#  mHidden       = 0x02       bHidden       = 30       Hidden        = 0
#  mUseIndex     = 0x04       bUseIndex     = 29       UseIndex      = 1
#  mIsStr        = 0x08       bIsStr        = 28       IsStr         = 0
#  mUseIDKey     = 0x10       bUseIDKey     = 27       UseIDKey      = 0
#  mSkipPriority = 0x20       bSkipPriority = 26       SkipPriority  = 0
#  mEnableLinks  = 0x40       bEnableLinks  = 25       EnableLinks   = 1
#  mCustomColor  = 0x80       bCustomColor  = 24       CustomColor   = 0
# The 'm*' names are 'mask' symbols for each bool
# The 'b*' names are 'bit index' symbols for each bool
# The real names store the boolean value we want to encode  (or are yet to be defined, if false)

myBools.mask  Enabled, Hidden, UseIndex, IsStr, UseIDKey, SkipPriority, EnableLinks, CustomColor
# A mask has been generated out of these bool names
# If the given symbol names already exist, then their values are checked
# - if the symbols have not been defined yet, then they are automatically 0

ori rBools, rBools, myBools.mask
# >>> 0x45   (mEnabled | mUseIndex | mEnableLinks)
# - 'Enabled, UseIndex, EnableLinks' are encoded into the mask
# - as a small integer, it can easily fit inside of a hardcoded immediate in a PPC instruction

sth rBools, struct.xBools(r3)
# update bools with our inserted mask



# Another powerpc function that checks the bools can then use the crf mask to load them into CR

mtcrf myBools.crf, rBools
# update CR6 and CR7 with our bools
# - we can now use the bit index symbols in cr instructions without making any comparisons

bf- bEnable, 0f
  bf- bIsStr, 1f
    nop  # example string handler goes here

  1:
  bt+ bUseIndex, 0f
    nop  # example index handler goes here

0:



# --- ENUMERATOR OBJECT POINTERS ---
# Every enumerator object has a property called '.is_enum' that keeps track of an object ID

enum.new  myList, "list."
# new enumerator object called 'myList' that uses the prefix 'list.' for its symbols dictionary

enum.new  myOtherList, "list.", , (9)
enum.new  notAList, , , (0xF)
enum.new  counter
# A few other example enumerators


.long myList.is_enum
# >>> n
# This will be a number representing the nth enum object generated in your ASM environment
# - it's a non-0 number, and 2 default objects come with the class module, so it will be >= 3


enum.pointer  myList, point_from_name
# 'enum.pointer' can be used to pull out this number from the object name 'myList'

# since the value is a number, it can be saved to a symbol as an integer
# 'point_from_name' now holds a copy of the number representing 'myList'

enum.pointer  point_from_name
# 'enum.pointer' will attempt to use unrecognized object names as direct pointer values
# - this allows enum.pointer to handle both object names and pointer values in the same way

point_from_num = enum.pointer
# If no symbol name is given to 'enum.pointer', it will use a property of the same name



# This number 'n' is like a dictionary index for the name 'myList'
# ---   n : 'myList'

.long point_from_name,  point_from_num
# >>> n, n
# These are the same value, because they represent the same object



enum.point  point_from_num, , a, b, c
# >>> myList a, b, c
# This converts the pointer value from 'point_from_num' into the object name 'myList'
# The blank argument is a macro name
# - a blank causes the object to be invoked directly, and passes the trailing arguments to it
# - if it were not blank, then a macro of the given name would be called to handle the object

.long list.a, list.b, list.c
# >>> 0, 1, 2
# The values 'a, b, c' have been enumerated by this enumerator
# - but we never invoked the enumerator by name, directly



# New macros can be used to handle enumerators by object name

.macro emit_count, enum, va:vararg
  .long \enum\().count
  .ifnb \va
    emit_count \va
  .endif
.endm # this macro emits the count of each given enumerator object


enum.pointer  myList
# If you don't give 'enum.pointer' a return symbol, you can also give a blank to 'enum.point'
# - both imply use of the property called 'enum.pointer'

enum.point ,  emit_count
# >>> emit_count  myList
# >>> 3


# By passing the object handler in place of a blank macro name, we use it to handle the object name
# - this causes 'myList' to be plugged into the 'enum' argument in 'emit_count'
# - we passed 'myList' to this macro in the form of a numer value instead of a name


# You may also use 'enum.pointq' to stack multiple objects onto the end of a trail of arguments:

point1 = enum.pointer
enum.pointer  myOtherList, point2
enum.pointer  notAList,    point3
enum.pointer  counter,     point4
# point1, 2, 3, and 4 all point to different enumerator objects

enum.pointq  point1,, enum.pointq point2,, enum.pointq point3,, enum.pointq point4, emit_count
# >>> emit_count  myList, myOtherList, notAList, counter
# >>> 3, 9, F, 0
# - none of these enumerators are being invoked directly by name



# To make a simpler, more robust handler; we can incorporate pointers internally:

.purgem emit_count
.macro emit_count, va:vararg
  .irp enum, \va
    .ifnb \enum
      enum.pointer \enum
      enum.point, emit_count.handler
    .endif
  .endr
.endm # this macro invokes the handler using 'enum.point' for each given argument

.macro emit_count.handler, enum
  .long \enum\().count
.endm  # this macro does something with the given 'enum' object


emit_count  point1, myOtherList, point3, point4
# >>> 3, 9, F, 0
# Now, the 'emit_count' macro is equipped to handle both object names AND pointer inputs
# - you can apply this in more creative ways to make useful object methods that extend enum objects




# --- MUTABLE OBJECT METHOD HOOKS ---
# All methods in enumerator objects are driven by hooks that can be easily mutated

# Mutators are macros written at a static level that are used to control object attributes
# - this is done by having the object pass 'self' alongside any arguments through a 'hook' call


# For example, the 3 following hooks are in charge of the behaviors for updating enum properties:

# --- count       self, arg, ...
# Responsible for setting the 'count' property
# - override this to create conditions, rules, and processing for the resulting value

# --- step        self, arg, ...
# Responsible for setting the 'step' property
# - override this to create conditions, rules, and processing for the resulting value

# --- restart     self, ...
# Responsible for restartting the volatile properties used by this object



# Let's mutate the 'count' hook
# We'll make it so that the count uses a modulo (%) to reset the counter if it gets too high


.macro my_mutator, self, arg, va:vararg
  \self\().count = (\arg) % my_modulo
.endm

my_modulo = 5
# With this macro 'my_mutator' and this property 'my_modulo', we can mutate any enum object



enum.new  modulo
modulo.mut  my_mutator, count
# We create a new enumerator object, and mutate it with '.mut'
# 'my_mutator' gets assigned as a behavior that overrides the 'count' hook
# - now the mutated behavior will take place of the default count behavior

modulo A, B, C, D, E, F, G, H
.byte A, B, C, D, E, F, G, H
# >>> 0, 1, 2, 3,  4, 0, 1, 2
# - the counter has been mutated to reset after it reaches 5, using a modulo operation

my_modulo = 2
modulo.restart

modulo I, J, K, L
.byte I, J, K, L
# >>> 0, 1, 0, 1
# - the modulo property can be set to a new value to control the behavior




# Other hooks in the enumerator object can be used to override things in more significant ways:

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



# Let's make a hex emitter by overriding at the 'enum_parse_iter' level
# This time, we'll register our mutator as a formal 'mode'


# We can create a new mode called 'hex_emit' for 'enum_parse_iter' with the following macro name:

.macro enum.mut.enum_parse_iter.hex_emit, self, symbol, prefix, suffix, arg
  .irpc c, \arg
    # for each character 'c' in argument 'arg'

     # each character of hexadecimal is 4 bits, so we'll need to buffer 2 before we emit a byte

     .ifnc "\c", " "
     # we skip over spaces in the sequence

       \self\().count = \self\().count ^ 1
       # we can use the first bit in '.count' and an XOR operation to make a binary counter

       .if \self\().count
          \self\().last = 0x\c <<4
          # we can use '.last' to buffer our unemitted bits

       .else
          .byte \self\().last | 0x\c
          # on aligned nibbles, emit the buffered bits ORed in with the next nibble

       .endif
     .endif
  .endr
.endm

# This mode 'hex_emit' will now be available to all enumerator objects with '.mode'


enum.new  hex
hex.mode  enum_parse_iter, hex_emit
# This creates a new enumerator object in 'hex_emit' mode
# - the object will use our mutator in place of the normal parse iteration routine

hex 20112028202f202f20321a, 2020 20322035202f2027 20ec
.align 2
# >>> 20112028 202f202f 20321a20 20203220 35202f20 2720ec00

hex 133 7BE EF1 337 BEE F13 37B EEF
# >>> 1337BEEF 1337BEEF 1337BEEF


# The enumerator object 'hex' has been mutated to have entirely new behavior

# We can revert the hook back to default by using the 'default' mode:

hex.mode  enum_parse_iter, default
hex.restart
hex hello, world
.long hello, world
# >>> 0, 1
# Default behavior is resumed when mode is changed back



# Mutators are powerful, and can be used creatively to extend what enumerators do internally

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module enum, 0x201
.if module.included == 0

  punkpc obj
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
