# --- Inline Data Tables
#>toc ppc
# - creates macroinstructions that exploit the link register in `bl` and `blrl`
# - instructions are capable of referencing data local to the program counter
# - also includes some utilities for creating binary data structs

# --- Example use of the data module:

.include "punkpc.s"
punkpc data
# Use the 'punkpc' statement to load this module, or include the module file directly

# --- INLINE DATA STRUCTS
# You can use 'data.start' and 'data.end' to construct a data table in the middle of your code
# - you can also use 'data.foot' to construct one at the end of your code

mflr r0
stwu sp, -0x100(sp)
stw  r0,  0x100+4(sp)
stmw r28, 0x10(sp)
# starting a function in powerpc...

mr rOutput, r3
rOutput = 31; rData = 30; rFloats = 29
# We'll pretend that this function is outputing data to 'rOutput'
# rData will serve as our base address for inline structs
# rFloats will be a sub-table within rData that we can reference like its own table


data.start
# ... you can start an inline data table like this
# - this goes in the middle of your code, like we're doing here

  _myLabel:
  # labels are useful inside of data tables because they save locations that can determine sizes
  # - we'll use this one later as an example


  .long 1,2,3,4
  # these are some example ints that we can load from the base of our data table
  # 0x0...0x10 are the offsets these will reside in



  # We don't need to remember stuff like this though if we use numbered labels:

  0: .asciz "Hello World"
  1: .asciz "These strings are labeled with numbers"
  2: .asciz "Each number creates a byte offset in the our example struct 'myStrings'"
  .align 2
  # These numerical labels are re-writable, and keep 2 copies of memory at any one time:
  #   A 'Forward' reference can be made to these labels with a 'f' suffix
  #   A 'Backward' reference can be made to these labels with a 'b' suffix

  # The above are behind us now, so we would reference '0' as '0b' with a 'backward' reference
  # The numbers must be written in decimal in order to work correctly



  # We don't need to do any label math with these if we just plug them into 'data.struct' :

  data.struct 0, "myStrings.", xHello, xLabels, xOffset
  # This statement plugs the label '0' into a new struct namespace called 'myStrings.*'

  # This is like manually typing out
  #   myStrings.xHello  = 0b - _data.table
  #   myStrings.xLabels = 1b - _data.table
  #   myStrings.xOffset = 2b - _data.table
  # - these offset can be used later on in load/store or addi instructions


  4: .byte 1
  3: .byte 3
  1: .byte 3
  2: .byte 7
  data.struct 1, "leet.", 0, 1, 2, 3
  # The numbers do not necessarily have to be in order, but they do create a sequence in the struct
  # - you must still have a backwards reference available for each assumed number label in sequence
  # Number names are fine to use so long as you give at least one starting char in the struct name



  data.table myFloats
  # You can create new table sections without the inline branch by using 'data.table'
  # - this doesn't change the _data.start label, so you can nest these within data blocks
  # - alternatively, you may use these instead of data blocks

  # A new data table like this will cause new struct offsets to become relative to its position

  i = 100
  99: .float 2.5,  -0.4
  98: .float 3.14, -0.5
  97: .float 1.1,  -0.6
  96: .float 0.89, -0.7
  data.struct i - 4, , xPair0, xPair1, xPair2, xPair3
  # Struct names can be blank, and the index number can be an expression
  # These offsets will be relative to the 'myFloats' table



  data.table _myLabel
  # If you give data.table a symbol name that already exists, it will reference that instead
  # - this lets us set the struct-building base label back to '_myLabel', at the beginning

  data.struct xMySection
  # If you give data.struct only 1 argument, it will make an offset out of current location
  # - this does not require any numbered labels

  .zero 256
  # blank section, for writing data to at runtime


data.end rData
# This is the end of the inline data table
# Since we gave the argument 'rData' -- rData is given the base address of '_data.start'



# The code will continue at this point, where we can use the data:

addi r3, rData, xMySection
stw  r3, 0x0(rOutput)
# r3 now holds the address of 'mySection', which we can store in rOutput as a pointer

data.get rFloats, myFloats
# This is like typing out:
#   addi rFloats, rData,

# data.get knows to use 'rData' because of the argument we gave to 'data.end'
# - if you want to be explicit with a different base_register, you can add a 3rd argument
#   - alternatively, you can manually set the 'data.base_reg' property to 0...31


# rFloats now holds the address of the 'myFloats' table that we made, so we can use its offsets

psq_l f0, xPair0(rFloats), 0, 0 # All are loaded as pairs of uncompressed floating points
psq_l f1, xPair1(rFloats), 0, 0
psq_l f2, xPair2(rFloats), 0, 0
psq_l f3, xPair3(rFloats), 0, 0
ps_madd f0, f1, f0, f3
ps_sub  f0, f2, f0
ps_mul  f0, f3, f0
psq_st f0, 0x4(rOutput), 0, 0
# some nonsensical arithmetic, to show how easily float pairs can be loaded and handled


lbz r0, leet.3(rData)
mtcrf 0x03, r0
li r0, 0
bf- 31, _get_strings
# example of loading some bools from the 'leet' struct, and moving them directly to cr6 and cr7

  lbz  r0, leet.1(rData)
  lbz  r3, leet.2(rData)
  and  r0, r3, r0
  # conditionally use the leet struct to make a mask out of the data

_get_strings:
stwu r0, 0xC(rOutput)
addi r5, rData, myStrings.xHello
addi r6, rData, myStrings.xLabels
addi r7, rData, myStrings.xLabels
stswi r5, rOutput, 0xC
# store 3 string pointers in updated output base


data.table footer, footer
# by adding a location argument at the end of a new table definition, you can assign it remotely
# - _footer is a label that doesn't exist yet, but the table 'footer' now refers to it

data.get r8, footer
# r8 now points to the ending footer section of the function, which has some data in it

_return:
mr r3, rOutput
mr r4, rFloats
# return output, floats, string pointers, and footer pointer as r3...r8

lmw  r28, 0x10(sp)
lwz  r0,  0x100+4(sp)
addi sp, sp, 0x100
mtlr r0
blr

data.foot footer
.zero 0x40
# (example of footer data)

# --- Example Results:

## 7C0802A6 9421FF00
## 90010104 BF810010
## 7C7F1B78 480001B8
## 4E800021 00000001
## 00000002 00000003
## 00000004 48656C6C
## 6F20576F 726C6400
## 54686573 65207374
## 72696E67 73206172
## 65206C61 62656C65
## 64207769 7468206E
## 756D6265 72730045
## 61636820 6E756D62
## 65722063 72656174
## 65732061 20627974
## 65206F66 66736574
## 20696E20 74686520
## 6F757220 6578616D
## 706C6520 73747275
## 63742027 6D795374
## 72696E67 73270000
## 01030307 40200000
## BECCCCCD 4048F5C3
## BF000000 3F8CCCCD
## BF19999A 3F63D70A
## BF333333 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 4BFFFE4D
## 7FC802A6 387E00B0
## 907F0000 3BBE0090
## E01D0018 E03D0010
## E05D0008 E07D0000
## 1001183A 10020028
## 10030032 F01F0004
## 881E008C 7C003120
## 38000000 409F0010
## 881E008F 887E008D
## 7C600038 941F000C
## 38BE0010 38DE001C
## 38FE001C 7CBF65AA
## 391E0214 7FE3FB78
## 7FA4EB78 BB810010
## 80010104 38210100
## 7C0803A6 4E800020
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
## 00000000 00000000
