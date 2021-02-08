/*## Header:
# --- Gecko Injection and Overwrite Ops
#>toc library
# - in-assembler gecko opcodes, for writing injection and overwrite patches
#   - injection ops create blocks that are written as `C2` codes
#   - overwrite ops create individual `04` codes

##*/
/*## Updates:
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Methods ---
# --- gecko.inj  address
# Starts a new injection block, for writing an injection code
# Must be terminated with 'gecko.end' or another 'gecko.inj' call
# - the 'address' will become part of the 'C2' opcode
#   - if the '0x' prefix is not detected, macro will attempt to add it

# --- gecko.ovw  address, overwrite
# Creates an 8-byte 'overwrite' opcode
# - can't be used inside of a 'gecko.inj' block without terminating the block
#   - if the '0x' prefix is not detected in the address, macro will attempt to add it
#   - if the '0x' prefix is not detected in the overwrite, it will be used like a raw instruction

# --- gecko.end
# Ends a 'gecko.inj' block, if one is currently open
# This is called automatically on all 'gecko.inj' and 'gecko.ovw' calls
# - 'gecko.end' only needs to be called at the end of a sequence of 'gecko.inj' blocks
#   - if a 'gecko.ovw' op is placed at the end, then 'gecko.end' never needs to be called explicitly

# --- gecko  a, b
# A convenience macro, for invoking all of the above through different syntaxes:
# gecko a, b  :  gecko.ovw   address, overwrite
# gecko a     :  gecko.inj  address
# gecko       :  gecko.end


##*/
/*## Examples:
.include "punkpc.s"
punkpc gecko
# Use the 'punkpc' statement to load this module, or include the module file directly

# The 'gecko' object can be used to create overwrite opcodes, or start/end injection blocks





# --- OVERWRITE OPCODES ---
# Overwrites require an address and at least 1 overwrite argument:


gecko  0x804DA840, 0x1337
# >>> 044DA840 00001337
# The first argument is the address of the word that will be overwritten
# The second argument is a word to overwrite the target address with




# If you provide an instruction for the overwrite argument, it will use that in place of a number:

gecko 0x804DA840,   lwz r3, 0x40(sp)
# >>> 044DA840 80610040




# If you wrap the instruction in quotes, you can generate a sequence of 04 codes:

gecko 0x804DA840,   "lwz r3, 0x40(sp)",  "lwz r4, 0x10(r3)",  "lwz r5, 0x0(r30)"
# >>> 044DA840 80610040
# >>> 044DA844 80830010
# >>> 044DA848 80BE0000
# These write serially upon the target address, incrementing by 4 bytes with each line




# Similarly, if you need to make an expression, you can use parentheses:

addr = 0x804DA840
value = 360
# some symbols, for creating expressions

gecko  addr,   1, 0x2, (3), (value + 4), blrl
# >>> 044DA840 00000001
# >>> 044DA844 00000002
# >>> 044DA848 00000003
# >>> 044DA84C 0000016C
# >>> 044DA850 4E800021
# The address doesn't need parentheses
# - overwrite args, however, must be wrapped in parentheses to distinguish them from instructions
#   - alternatively, starting an arg with a number literal like '0+ ...' may also work

# raw numbers need no parentheses:

gecko 0x80390ff8,  0x2C000000, 0x40800024
gecko 0x80390f38,  0x2C000000, 0x40800024
# >>> # Toggleable GObj Displays
# >>> 04390ff8 2C000000
# >>> 04390ffC 40800024
# >>> 04390f38 2C000000
# >>> 04390f3C 40800024




# If you prefer, you can use the more explicit name, 'gecko.ovw' for overwrites:

gecko      addr,    1, 2, 3
gecko.ovw  addr+12, 4, 5, 6
# >>> 044DA840 00000001
# >>> 044DA844 00000002
# >>> 044DA848 00000003
# >>> 044DA84C 00000004
# >>> 044DA850 00000005
# >>> 044DA854 00000006
# 'gecko.ovw' is invoked by 'gecko' syntactically -- so they are virtually identical







# --- INJECTION OPCODES ---
# You can use 'gecko' to start an injection block

gecko 0x8006b0a4
# Calling 'gecko' with only an argument address will begin an injection block context

  li r3, 1
  stw r3, 0x904(r30)
  stw r0, 0x65F(r31)
  # this code will be given a hook at the given address

gecko
# The next gecko call will terminate the block in addition to the call's function
# - calling with no args does nothing -- but will still terminate the block

# >>> C206B0A4 00000002
# >>> 38600001 907E0904
# >>> 901F065F 00000000
# This block context emits an 8-byte aligned, headed, measured, and terminated C2 code block
# - these may be used to create injection codes



# Like overwrites, you may use more explicit method names if you prefer:
gecko.inj 0x8006b0a4
  li r3, 1
  stw r3, 0x904(r30)
  stw r0, 0x65F(r31)
gecko.end
# 'gecko.inj' and 'gecko.end' are invoked syntactically by 'gecko', just like 'gecko.ovw'

# The syntax rules are simple:
# overwrites = 2 or more args:  gecko addr, ...
# injections = 1 arg:           gecko addr
# block ends = 0 args:          gecko



# Using a sequence of injection calls will automatically terminate all but the last block:

gecko 0x8036e8d8
  lhz r7, 0xC(r3)
  andi. r0, r7, 0x0800
  beq+ 0f
    ori r7, r7, 0xC000
  0:
gecko 0x8037449c
  lwz r3, 0x14(r3)
  andis. r0, r3, 0x0800
  beq+ 0f
    ori r3, r3, 0x10
  0:
gecko 0x80390ff8
  cmpwi cr1, r0, 0;
  rlwinm. r15, r0, 0, ~(1<<31)
  crorc 2, 2, 4
gecko 0x80390f38
  cmpwi cr1, r0, 0
  rlwinm. r15, r0, 0, ~(1<<31)
  crorc 2, 2, 4
gecko
# >>> # HSD Hide Module
# >>> C236E8D8 00000003  -- inj 1
# >>> A0E3000C 70E00800
# >>> 41A20008 60E7C000
# >>> 60000000 00000000
# >>> C237449C 00000003  -- inj 2
# >>> 80630014 74600800
# >>> 41A20008 60630010
# >>> 60000000 00000000
# >>> C2390FF8 00000002  -- inj 3
# >>> 2C800000 540F007F
# >>> 4C422342 00000000
# >>> C2390F38 00000002  -- inj 4
# >>> 2C800000 540F007F
# >>> 4C422342 00000000
# As you can see, each subsequent call terminates the last, but a final empty call is still needed
# - this is to terminate the last block context



# Since overwrites do not require block contexts, you may also use them in place of a blank
# Here's an example that mixes them together:

punkpc branch
# import the 'bla' instruction, for making calls in a gecko-friendly way

gecko 0x80030288
  bla r0, 0x80030A78
  cmpwi r3, 0
  beq- 0f
    bla r0, 0x80059e60
  0: lbz    r0, 0 (r31)
gecko 0x8005a2ec, 0x4bfffb75
# >>> # Collision Link Draw Order Fix
# >>> C2030288 00000006
# >>> 3C008003 60000A78
# >>> 7C0803A6 4E800021
# >>> 2C030000 41820014
# >>> 3C008005 60009E60
# >>> 7C0803A6 4E800021
# >>> 881F0000 00000000
# >>> 04099A7C 60000000
# >>> 04099A80 38600000




# --- A NOTE ABOUT BYTE ALIGNMENTS ---
# Gecko codes must be 8-byte aligned, and the macro enforces this automatically
# ... however, using the '.align' directive in an injection body will mess up the calculation

show_errors = 0
# set this to 1 to demonstrate the error:

.if show_errors
  gecko 0x80000000
    blrl
    .asciz "hello"
    .align 2
  gecko
.endif
# >>> Error : non-constant in 'if' statement

# This error will appear because the '.align' directive destroys information
# The 'gecko' module includes the 'align' module as a way to subvert this problem:

gecko 0x80000000
  blrl
  .asciz "hello"
  align 2  # --- use 'align' without a '.'
gecko
# >>> C2000000 00000002
# >>> 4E800021 68656C6C
# >>> 6F000000 00000000
# This does not produce errors because of the subsection-friendly way it emits padding



##*/
/*## Results:
044DA840 00001337
044DA840 80610040
044DA840 80610040
044DA844 80830010
044DA848 80BE0000
044DA840 00000001
044DA844 00000002
044DA848 00000003
044DA84C 0000016C
044DA850 4E800021
04390FF8 2C000000
04390FFC 40800024
04390F38 2C000000
04390F3C 40800024
044DA840 00000001
044DA844 00000002
044DA848 00000003
044DA84C 00000004
044DA850 00000005
044DA854 00000006
C206B0A4 00000002
38600001 907E0904
901F065F 00000000
C206B0A4 00000002
38600001 907E0904
901F065F 00000000
C236E8D8 00000003
A0E3000C 70E00800
41A20008 60E7C000
60000000 00000000
C237449C 00000003
80630014 74600800
41A20008 60630010
60000000 00000000
C2390FF8 00000002
2C800000 540F007F
4C422342 00000000
C2390F38 00000002
2C800000 540F007F
4C422342 00000000
C2030288 00000006
3C008003 60000A78
7C0803A6 4E800021
2C030000 41820014
3C008005 60009E60
7C0803A6 4E800021
881F0000 00000000
0405A2EC 4BFFFB75
C2000000 00000002
4E800021 68656C6C
6F000000 00000000

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module gecko, 1
.if module.included == 0

  punkpc errata, align, if

  errata.new  gecko.block
  gecko.block.__open = 0
  # gecko.block errata object keeps block context params in a tuple
  # - special property '.open' keeps track of block state

  .macro gecko.inj, address
    gecko.end
    gecko.block.__open = 1
    gecko.block.ref gecko.__size
    .long 0xC2000000 | (0x01FFFFFF & \address), gecko.__size
    gecko.__start = .

  .endm; .macro gecko.ovw, address, va:vararg
    gecko.end
    gecko.__altm = alt
    ifalt; gecko.__alt = alt
    gecko.__target = \address - 4
    gecko.__quote = 0
    .noaltmacro
    gecko.__ovw, \va
  .endm; .macro gecko.__ovw, arg, va:vararg
    .ifnb \arg;
      .long 0x04000000 | (0x01FFFFFF & gecko.__target)
      .if gecko.__quote; \arg
      .else; .long \arg ; .endif
    .endif
    gecko.__target = gecko.__target + 4

    .ifnb \va
      .altmacro
      gecko.__ovw_alt \va
      .noaltmacro
      .if gecko.__quote; gecko.__ovw \va
      .else; gecko.__ovw_check \va
        .if num; gecko.__ovw \va;
        .else; gecko.__ovw_va \va; .endif;
      .endif
    .endif
  .endm; .macro gecko.__ovw_alt, arg, va:vararg
    gecko.__i = 0; gecko.__quote = 0
    .irpc c, <\arg>;
      .if gecko.__i;
        .ifc \c\c, ""; gecko.__quote = 1; .endif; .exitm;
      .else; gecko.__i = 1; .endif
    .endr
  .endm; .macro gecko.__ovw_check, arg, va:vararg;  ifnum \arg;
  .endm; .macro gecko.__ovw_va, va:vararg
    .ifnb \va; .long 0x04000000 | (0x01FFFFFF & gecko.__target); \va;  .endif
  .endm; .macro gecko.end
    .if gecko.block.__open; gecko.block.__open = 0
      .if (. - gecko.__start) & 7; .long 0
      .else; nop; .long 0; .endif
      gecko.size = (. - gecko.__start)>>3
      gecko.block.solve gecko.size
      gecko.block.i = gecko.block.i + 1
    .endif
  .endm; .macro gecko, a, b:vararg
    .ifnb \a; .ifnb \b; gecko.ovw \a, \b; .else; gecko.inj \a; .endif; .else; gecko.end; .endif
  .endm
.endif
