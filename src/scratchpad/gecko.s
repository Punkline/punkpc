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

# --- gecko.ov  address, overwrite
# Creates an 8-byte 'overwrite' opcode
# - can't be used inside of a 'gecko.inj' block without terminating the block
#   - if the '0x' prefix is not detected in the address, macro will attempt to add it
#   - if the '0x' prefix is not detected in the overwrite, it will be used like a raw instruction

# --- gecko.end
# Ends a 'gecko.inj' block, if one is currently open
# This is called automatically on all 'gecko.inj' and 'gecko.ov' calls
# - 'gecko.end' only needs to be called at the end of a sequence of 'gecko.inj' blocks
#   - if a 'gecko.ov' op is placed at the end, then 'gecko.end' never needs to be called explicitly

# --- gecko  a, b
# A convenience macro, for invoking all of the above through different syntaxes:
# gecko a, b  :  gecko.ov   address, overwrite
# gecko a     :  gecko.inj  address
# gecko       :  gecko.end


##*/
/*## Examples:
.include "punkpc.s"
punkpc gecko
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- OVERWRITE OPCODES ---



# --- INJECTION OPCODES ---
# You can use 'gecko.inj' to start an injection block

gecko.inj 0x8006b0a4
  li r3, 1
  stw r3, 0x904(r30)
  stw r0, 0x65F(r31)
  # this code will be given a hook at the given address

gecko.end
# You must always terminate a block with some form of gecko call
# - 'gecko.end' is purely for closing blocks -- but all other gecko calls invoke it, too
#   - you may instead use another 'gecko.inj', a 'gecko.ov' or the 'gecko' convenience macro


##*/
/*## Results:
##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module gecko, 1
.if module.included == 0

  punkpc errata, align, ifnum

  errata.new  gecko.block
  gecko.block.__open = 0
  # gecko.block errata object keeps block context params in a tuple
  # - special property '.open' keeps track of block state

  .macro gecko.inj, address
    ifnum_ascii \address
    .if num != 0x30; gecko.inj 0x\address; .exitm; .endif
    gecko.end
    gecko.block.__open = 1
    gecko.block.ref gecko.__size
    .long 0xC2000000 | (0x01FFFFFF & \address), gecko.__size
    gecko.__start = .
    
  .endm; .macro gecko.ov, address, overwrite:vararg
    ifnum_ascii \address
    .if num != 0x30; gecko.inj 0x\address; .exitm; .endif
    gecko.end
    .long 0x04000000 | (0x01FFFFFF & \address)
    ifnum_ascii \overwrite
    .if num != 0x30; \overwrite; .else; .long \overwrite; .endif

  .endm; .macro gecko.end
    .if gecko.block.__open; gecko.block.__open = 0
      .if (. - gecko.__start) & 7; .long 0
      .else; nop; .long 0; .endif
      gecko.size = (. - gecko.__start)>>3
      gecko.block.solve gecko.size
      gecko.block.i = gecko.block.i + 1
    .endif
  .endm; .macro gecko, a, b:vararg
    .ifnb \a; .ifnb \b; gecko.ov \a, \b; .else; gecko.inj \a; .endif; .else; gecko.end; .endif
  .endm
.endif
