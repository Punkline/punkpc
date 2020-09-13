# --- Enumerator Tools
# Basic tools for assigning indices and mask bools to a list of symbol names


# --- Example use of the enum module:

.include "./punkpc/enum.s"


# --- ENUMERATIONS --------------------------------------------------------------------------------
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


# --- BOOL ENUMERATIONS ---------------------------------------------------------------------------
enumb Enable, UseIndex, IsStr
# state the bool symbol names you want to use:
# >>> bEnable   = 31; mEnable   = 0x00000001
# >>> bUseIndex = 30; mUseIndex = 0x00000002
# >>> bIsStr    = 29; mIsStr    = 0x00000004
# mMask and bBit symbols are created for each

enumb (0), +1, A, B, C
# >>> bA = 0; mA = 0x80000000
# >>> bB = 1; mB = 0x40000000
# >>> bC = 2; mC = 0x20000000

.long mA|mB|mC
# >>> 0xE0000000

rlwinm. r3, r0, 0, bUseIndex, bUseIndex
rlwinm. r3, r0, 0, mUseIndex
# both of these rlwinms are identical

rlwimi r0, r0, bIsStr-bC, mC
# insert bIsStr into bC in a single register/instruction


# --- BOOL MASK GENERATOR -------------------------------------------------------------------------

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
bf- bIsStr, 1f; nop; 1:
bt+ bUseIndex, 0f; nop; 0:
# once in the CR, each bool can be referenced by name in 'bf' or 'bt' branch instructions


# --- ENUM PREFIXES -------------------------------------------------------------------------------
enum.pfx "myNamespace.", -4, (0x10), A, B, C, D
.byte myNamespace.A, myNamespace.B, myNamespace.C, myNamespace.D
# - pfx allows first argument to create a prefix substring added to the beginning of each input name
# - doesn't need to be in quotes, but it makes the syntax a bit more readible and doesn't interfere


# --- ENUMERATOR OBJECTS --------------------------------------------------------------------------

enum.new myStruct, "struct.", +4, (0)  # creates an enumerator object called 'myStruct'
# - the second argument creates a prefix name that gets attached to the beginning of each input name

enum.new myRegs, "", -1, (r31)  # creates an enumerator object called 'myRegs'
# - a blank second argument will use a 'blank' prefix that generates the given symbol names directly
myRegs   rPrev, rNext, rColor, rData, rStr, rID, rPriority, rBools
myStruct xPrev, xNext, xColor, xData, xStr, +1, xID, xPriority, +2, xBools

lwz rPrev,     struct.xPrev(r3)     # 0x00, r31
lwz rNext,     struct.xNext(r3)     # 0x04, r30
lwz rColor,    struct.xColor(r3)    # 0x08, r29
lwz rData,     struct.xData(r3)     # 0x0C, r28
lwz rStr,      struct.xStr(r3)      # 0x10, r27
lbz rID,       struct.xID(r3)       # 0x14, r26
lbz rPriority, struct.xPriority(r3) # 0x15, r25
lhz rBools,    struct.xBools(r3)    # 0x16, r24
# load struct vars into named registers using named offsets

myRegs.restart
myRegs rThis, rThat
# the '.restart' method can be used to restart the counter/step back to its original settings

lwz rThis, 0x00(r4)
lwz rThat, 0x10(r4)
stmw myRegs.last, 0x10(sp)
# the '.last' property saves the last assigned count value, and can be used in stmw/lmw instructions

myRegs.restart
myRegs rThese, rThose, rSize
lwz rThese, 0x0(r5)
lwz rThose, 0x8(r4)
li rSize, myStruct.count
stmw myRegs.last, 0x20(sp)
# the '.count' property memorizes the next count value to assign, and can be used to reference sizes

myStruct.bool Enable, UseIndex, IsStr
# >>> struct.bEnable   = 31; struct.mEnable   = 0x00000001
# >>> struct.bUseIndex = 30; struct.mUseIndex = 0x00000002
# >>> struct.bIsStr    = 29; struct.mIsStr    = 0x00000004


# --- ENUMERATOR OBJECT CALLBACKS -----------------------------------------------------------------

myStruct.restart
# restart 'myStruct' enumerator

.purgem myStruct.enum_callback
.macro  myStruct.enum_callback, self, symbol, pfx, sfx
# purge the '.enum_callback' dummy method so that we can re-define it in this macro:

  # self   is the namespace of the object, in case passing through more generic macros is necessary
  # symbol is the full name of the enumerated symbol argument that was just processed
  # pfx    is the prefix namespace used for the symbol, to access properties belonging to it
  # sfx    is the suffix namespace used for the symbol, for adding substrings in the middle of names

  # for this, we'll only use 'symbol', which has sampled the value of this enumerator's count

  .long \symbol
  # this will simply emit numbers recording the enumerated count of the structure we write

.endm
# now that the callback is defined, it's safe to execute the mutated object

myStruct xPrev, xNext, xColor, xData, xStr, +1, xID, xPriority, +2, xBools
# >>> 00000000 00000004
# >>> 00000008 0000000C
# >>> 00000010 00000014
# >>> 00000015 00000016
# now, the myStruct enumerator also emits a word for each offset created in the struct



.include "./punkpc/stacks.s"
# load the stacks module so that we can play with stacks of integers

stack myBools, myMasks
# create a pair of stacks called 'myBools' and 'myMasks'

.purgem myStruct.enum.bool_callback
.macro  myStruct.enum.bool_callback, self, symbol, pfx, sfx
  myBools.push \pfx\()b\sfx  # this bool
  myMasks.push \pfx\()m\sfx  # this mask
  # this will push bools and masks of bools into the stacks as each offset is defined

.endm

.long myBools.s, myMasks.s
# >>> 0, 0  # stack index 's' shows that both stacks are empty

myStruct.bool IsFloat, IsInt, IsShort, IsByte
# add more bools to myStruct, from the previous 3

.long myBools.s, myMasks.s
# >>> 4, 4  # stack index 's' now shows that it has collected a sequence of sampled bools and masks

.rept myBools.s     # for stack indices 0...s
  myBools.deq bool
  myMasks.deq mask
  .long bool, mask
.endr
# >>> 0000001C 00000008
# >>> 0000001B 00000010
# >>> 0000001A 00000020
# >>> 00000019 00000040



# Other callbacks that can be replaced in a similar fashion:
# - .enum.mask_callback         - when a composite mask is generated from multiple input bools
# - .enum.restart_callback      - when an integer enumerator is restarted
# - .enum.bool.restart_callback - when a bool enumerator is restarted


# --- Module attributes:
# Volatile Working Properties:

# --- i - volatile loop counter
# --- a - volatile argument flag

# --- Class Properties ----------------------------------------------------------------------------

# --- enum.count  - shared index counter
# --- enum.step   - shared index step
# --- enumb.count - shared boolean index counter
# --- enumb.step  - shared boolean index step
# --- enumb.mask  - generated combination of masks with their boolean TRUE/FALSE values
# --- enumb.crf   - output crf mask, for using mtcrf instructions to load in enumb.mask


# --- Class Methods -------------------------------------------------------------------------------

# --- enum        Sym, Sym, ...
# An enumerator tool that lets you assign iterations of a counting number to a sequence of names
#  - if sym starts with an symbol-friendly character, then it will be assigned a step in the count
#  - if sym starts with a + or a -, it is considered as an argument step amount, for counter
#  - if sym is (enclosed in parentheses) then it is considered as an argument index, to set counter

# --- enumb       Sym, Sym, ...
# Bool enumerator; creates aliases of given symbols to generate boolean indicies and masks
#  - generated mSym = mask of this bool;              ex: mSym = 0x00040000
#  - generated bSym = big-endian index of this bool;  ex: bSym = 13

# --- enumb.mask  Sym, Sym, ...
# A method that evaluates given symbol names, and uses their aliases to build a combined mask
#  - if 'Sym' does not exist, but 'mSym' does - then value is assumed false

# --- enum.pfx        pfx, Sym, Sym, ...
# --- enumb.pfx       pfx, Sym, Sym, ...
# --- enumb.mask.pfx  pfx, Sym, Sym, ...
# Variations of the class methods that concatenate each symbol to a given prefix namespace



# --- Constructor Methods -------------------------------------------------------------------------

# --- enum.new   name, pfx, Sym, Sym, ...
# A constructor for making objects that can perform an 'enum' method with a private counter
# - if pfx is blank "", then it will be unused
# - if symbols are not provided, they can be added later by invoking the new object by name

# --- Object Properties ---------------------------------------------------------------------------
# --- .last   - keeps memory of the last assigned count
# --- .count  - these 4 properties are like internal versions of the Class Properties
# --- .step
# --- .mask
# --- .crf
# --- .count.restart - these keep the initial properties set by the object constructor
# --- .step.restart  - they will be applied when using the '.restart' method

# --- Object Methods ------------------------------------------------------------------------------
# --- (self)  Sym, Sym, ...
  # Just like the 'enum.pfx' Class method, but also internalizes an optional prefix

# --- .bool  Sym, Sym, ...
  # Just like the 'enumb.pfx' Class method, but internalizes an optional prefix

# --- .mask   Sym, Sym, ...
  # Just like the 'enumb.mask.pfx' Class method, but internalizes an optional prefix

# --- .restart
  # restarts the enumerator object back to its initial counter/step settings

# --- .bool.restart
  # a version of '.restart' that operates on the bool enumerator instead of the int enumerator

# --- Overridable Callback Methods ----------------------------------------------------------------
# --- .enum_callback               self, sym, pfx, sfx
# --- .enum.bool_callback          self, sym, pfx, sfx
# --- .enum.mask_callback          self, pfx
# --- .enum.bool.restart_callback  self, pfx
  # These do nothing by default, but can be programmed to do something by purging and redefining
  # - self is a copy of the enumerator object's name
  # - sym is the whole symbol that has just been generated by enum or enum.bool
  # - pfx is the common prefix name given to all symbols of this enumerator
  # - sfx is the specific name of this symbol generated by this enumerator

