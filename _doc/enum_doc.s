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

# --- enum        sym, sym, ...
# An enumerator tool that lets you assign iterations of a counting number to a sequence of names
#  - if sym starts with an symbol-friendly character, then it will be assigned a step in the count
#  - if sym starts with a + or a -, it is considered as an argument step amount, for counter
#  - if sym is (enclosed in parentheses) then it is considered as an argument index, to set counter

# --- enumb.mask  Sym, Sym, ...
# A method that evaluates given symbol names, and uses their aliases to build a combined mask
#  - if 'Sym' does not exist, but 'mSym' does - then value is assumed false

