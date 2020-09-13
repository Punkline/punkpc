/*## Header:
# --- Enumerator Tools
# Basic tools for assigning indices and mask bools to a list of symbol names

##*/
/*## Attributes:
# Volatile Working Properties:
# --- i - volatile loop counter
# --- a - volatile argument flag

# --- Class Properties ---

# --- enum.count  - shared index counter
# --- enum.step   - shared index step
# --- enumb.count - shared boolean index counter
# --- enumb.step  - shared boolean index step
# --- enumb.mask  - generated combination of masks with their boolean TRUE/FALSE values
# --- enumb.crf   - output crf mask, for using mtcrf instructions to load in enumb.mask


# --- Class Methods ---

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



# --- Constructor Methods ---

# --- enum.new   name, pfx, Sym, Sym, ...
# A constructor for making objects that can perform an 'enum' method with a private counter
# - if pfx is blank "", then it will be unused
# - if symbols are not provided, they can be added later by invoking the new object by name

# --- enumb.new  name, pfx, Sym, Sym, ...
# A constructor for making objects that can perform 'enumb' and 'enumb.mask' methods

  # --- Object Properties ---

    # --- .last   - keeps memory of the last assigned count
    # --- .count  - these 4 properties are like internal versions of the Class Properties
    # --- .step
    # --- .mask
    # --- .crf
    # --- .count.reset - these keep the initial properties set by the object constructor
    # --- .step.reset  - they will be applied when using the '.reset' method

  # --- Object Methods ---
    # --- .reset
    # resets the enumerator object back to its initial counter/step settings

  # --- enum Object Methods ---
    # --- (self)  Sym, Sym, ...
    # Just like the 'enum.pfx' Class method, but also internalizes an optional prefix

  # --- enumb Object Methods ---
    # --- (self)  Sym, Sym, ...
    # Just like the 'enumb.pfx' Class method, but internalizes an optional prefix

    # --- .mask   Sym, Sym, ...
    # Just like the 'enumb.mask.pfx' Class method, but internalizes an optional prefix


##*/
/*## Examples:
.include "./punkpc/enum.s"


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


# --- BOOL MASK GENERATOR ---

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


# --- ENUM PREFIXES ---
enum.pfx "myNamespace.", -4, (0x10), A, B, C, D
.byte myNamespace.A, myNamespace.B, myNamespace.C, myNamespace.D
# - pfx allows first argument to create a prefix substring added to the beginning of each input name
# - doesn't need to be in quotes, but it makes the syntax a bit more readible and doesn't interfere


# --- ENUMERATOR OBJECTS ---

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

myRegs.reset
myRegs rThis, rThat
# the '.reset' method can be used to reset the counter/step back to its original settings

lwz rThis, 0x00(r4)
lwz rThat, 0x10(r4)
stmw myRegs.last, 0x10(sp)
# the '.last' property saves the last assigned count value, and can be used in stmw/lmw instructions

myRegs.reset
myRegs rThese, rThose, rSize
lwz rThese, 0x0(r5)
lwz rThose, 0x8(r4)
li rSize, myStruct.count
stmw myRegs.last, 0x20(sp)
# the '.count' property memorizes the next count value to assign, and can be used to reference sizes

##*/

.ifndef enum.included; enum.included = 0; .endif; .ifeq enum.included; enum.included = 4
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

.include "./punkpc/ifdef.s"
.include "./punkpc/xem.s"
# include the ifdef module, for checking if escaped names exist in enum.mask
# include the xem module for installing initial symbol names for various registers

enum$=0; enumb$=0  # these count the number of enumerator objects that have been instantiated
# - each object has its own private counter

# these constructors let you make an integer enumerator or a bool enumerator
# - bool enumerators create names with m- and b- prefixes
.macro enum.new, self, pfx, varg:vararg
  ifdef \self\().isEnum
  .if ndef; enum$ = enum$ + 1; \self\().isEnum = enum$
    \self\().count=0;\self\().step=1; \self\().last=0
    .macro \self, va:vararg;
      .irp a,  \va;  a=1
        .irpc c,  \a
          .irpc i,  -+
            .ifc \c,  \i;  \self\().step=\a;a=0;.endif;
            .ifc \c,  (;  \self\().count=\a;a=0;.endif;.endr;.exitm;.endr;
        .if a;  \pfx\a=\self\().count; \self\().last=\self\().count
          \self\().count=\self\().count + \self\().step;.endif;.endr;
    .endm; .macro \self\().reset;
      \self\().count = \self\().count.reset; \self\().step = \self\().step.reset
    .endm
    .ifnb \varg; \self \varg; .endif
    \self\().count.reset = \self\().count
    \self\().step.reset = \self\().step
  .endif
.endm
.macro enumb.new, self, pfx, varg:vararg
  ifdef \self\().isEnumb
  .if ndef; enumb$ = enumb$ + 1; \self\().isEnumb = enumb$
    \self\().count=31;\self\().step=-1;
    .macro \self, va:vararg;
      .irp a,  \va;  a=1
        .irpc c,  \a
          .irpc i,  -+;
            .ifc \c,  \i;  \self\().step=\a;a=0;.endif;
            .ifc \c,  (;  \self\().count=\a;a=0;.endif;.endr;.exitm;.endr;
        .if a;
          \pfx\()b\a  = \self\().count
          \pfx\()m\a = 0x80000000 >> \pfx\()b\a
          \self\().last=\self\().count
          \self\().count = \self\().count + \self\().step
        .endif
      .endr
    .endm; .macro \self\().mask, va:vararg;
      i=0; .irp a,  \va;  ifdef \pfx\a
        .if ndef;  \pfx\a=0;.endif; ifdef \pfx\()m\()\a
        .if ndef;  \pfx\()m\()\a=0;.endif;
        i=i | (\pfx\()m\a & (\pfx\a != 0));
      .endr; \self\().mask=i;\self\().crf=0
      .rept 8;  \self\().crf=(\self\().crf<<1)|!!(i&0xF)
        i=i<<4;
      .endr;
    .endm; .macro \self\().reset;
      \self\().count = \self\().count.reset; \self\().step = \self\().step.reset
    .endm
    .ifnb \varg; \self \varg; .endif
    \self\().count.reset = \self\().count
    \self\().step.reset = \self\().step
  .endif
.endm; enum.new enum, "", +1, (0); enumb.new enumb, "", -1, (b31)

# special, fake methods for creating generic prefixed lists
.macro enum.pfx, pfx,  va:vararg
  .irp a,  \va;  a=1
    .irpc c,  \a
      .irpc i,  -+
        .ifc \c,  \i;  enum.step=\a;a=0;.endif;
        .ifc \c,  (;  enum.count=\a;a=0;.endif;.endr;.exitm;.endr;
    .if a;  \pfx\a=enum.count; enum.count=enum.count + enum.step;.endif;.endr;
.endm;.macro enumb.pfx, pfx, va:vararg
  .irp a,  \va;  a=1
    .irpc c,  \a
      .irpc i,  -+
        .ifc \c,  \i;  enumb.step=\a;a=0;.endif;
        .ifc \c,  (;  enumb.count=\a;a=0;.endif;.endr;.exitm;.endr;
    .if a;  \pfx\()b\a=enumb.count; enumb.count=enumb.count+enumb.step
      \pfx\()m\a=0x80000000>>\pfx\()b\a; .endif;.endr;
.endm; .macro enumb.mask.pfx, pfx, va:vararg;  i=0
  .irp a,  \va;  ifdef \pfx\a
    .if ndef;  \pfx\a=0;.endif; ifdef \pfx\()m\()\a
    .if ndef;  \pfx\()m\()\a=0;.endif;
    i=i | (\pfx\()m\a & (\pfx\a != 0));
  .endr; enumb.mask=i;enumb.crf=0
  .rept 8;  enumb.crf=(enumb.crf<<1)|!!(i&0xF)
    i=i<<4;.endr;
.endm

    .endif
/**/
