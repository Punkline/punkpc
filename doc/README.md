# Documentation:
- [Guides](/doc#Guides)
- [Modules](/doc#Modules) : *documentation*
  - [library](/doc#library) : *generic tools*
    - [align](/doc#align), [bcount](/doc#bcount), [dbg](/doc#dbg), [en](/doc#en), [hidden](/doc#hidden), [idxr](/doc#idxr), [xem](/doc#xem), [xev](/doc#xev)
    - [if](/doc#if) : *special if blocks*
      - [ifalt](/doc#ifalt), [ifdef](/doc#ifdef), [ifnum](/doc#ifnum)
  - [obj](/doc#obj) : *objects and classes*
    - [enum](/doc#enum), [mut](/doc#mut)
    - [sidx](/doc#sidx) : *integer buffers*
      - [enc](/doc#enc), [list](/doc#list), [stack](/doc#stack)
    - [str](/doc#str) : *literal buffers*
      - [errata](/doc#errata), [items](/doc#items)
  - [ppc](/doc#ppc) : *powerpc modules*
    - [branch](/doc#branch), [cr](/doc#cr), [data](/doc#data), [lmf](/doc#lmf), [load](/doc#load), [regs](/doc#regs), [small](/doc#small), [sp](/doc#sp), [spr](/doc#spr)


## Guides

- [Creating New Library Objects](/doc/md/guide_library_objects.md)

## Modules

### align

Alignment Tool (relative)
 - an alternative to the `.align` directive that doesn't destroy absolute expressions
 - useful for measuring arbitrary body sizes that include un-aligned data
   - byte arrays and strings are examples of structs that commonly need re-alignment

>[source](/src/align.s), [examples](/doc/s/examples/align_ex.s)

---
### bcount

Bit Counter Tools
 - useful for finding int sizes when creating masks, for compression

>[source](/src/bcount.s), [examples](/doc/s/examples/bcount_ex.s)

---
### branch

Branch (absolute)
 - absolute branch macroinstructions that replace the `bla` and `ba` instructions
   - these create long-form 4-instruction absolute calls/branches via `blrl` or `bctr`

>[source](/src/branch.s), [examples](/doc/s/examples/branch_ex.s)

---
### cr

Condition/Comparison Register/Fields
 - cr instruction fixes, and utilities for working with cr fields
 - used to more efficiently (and legibly) write binary trees in PowerPC functions

>[source](/src/cr.s), [examples](/doc/s/examples/cr_ex.s)

---
### data

Inline Data Tables
 - creates macroinstructions that exploit the link register in `bl` and `blrl`
 - instructions are capable of referencing data local to the program counter
 - also includes some utilities for creating binary data structs

>[source](/src/data.s), [examples](/doc/s/examples/data_ex.s)

---
### dbg

Debug Tool
 - a simple evaluation tool, for debugging symbol values

>[source](/src/dbg.s), [examples](/doc/s/examples/dbg_ex.s)

---
### en

Enumerator (quick)
 - a fast, featureless enumeration tool for naming offset and register symbols

>[source](/src/en.s), [examples](/doc/s/examples/en_ex.s)

---
### enc

Encoder Stacks
 - for converting source literals into ascii ints
 - may be used to create pseudo-regex-like parses of input literals

>[source](/src/enc.s), [examples](/doc/s/examples/enc_ex.s)

---
### enum

Enumerator Objects
 - a powerful object class for parsing comma-separated inputs
 - default behaviors are useful for counting named registers and offsets
 - highly mutable objects may be individually mutated for custom behaviors

>[source](/src/enum.s), [examples](/doc/s/examples/enum_ex.s)

---
### errata

Errata Objects
 - for generating constants that can be referenced before they are defined
 - requires that the errata doesn't need to be immediately evaluated after being emitted
 - useful for making cumulative results of an arbitrary number of operations
   - delaying the assignment of a constant until it is ready can be a useful concept in GAS

>[source](/src/errata.s), [examples](/doc/s/examples/errata_ex.s)

---
### hidden

Hidden Symbol Names
 - a tool for creating hidden symbol names
   - exploits support of the `\001` char in temp labels
 - intended for use without a linker

>[source](/src/hidden.s), [examples](/doc/s/examples/hidden_ex.s)

---
### idxr

Index (Register)
 - index (register) input extraction tool
 - useful for simulating load/store syntaxes, like `lwz r3, 0x20(r30)`

>[source](/src/idxr.s), [examples](/doc/s/examples/idxr_ex.s)

---
### if

Special If Statements
 - a collection of various checks that may be used with `.if` block directives
 - intended for making useful checks of difficult to compare things in GAS

>[source](/src/if.s), [examples](/doc/s/examples/if_ex.s)

---
### ifalt

Check if in Altmacro Mode
 - an if tool that can be used to check the current altmacro environment state
 - used to preserve the altmacro mode, and avoid ruining string interpretations

>[source](/src/ifalt.s), [examples](/doc/s/examples/ifalt_ex.s)

---
### ifdef

Check if Symbol is Defined
 - an if tool that circumvents the need for `\` chars in .ifdef checks
   - this is needed to prevent errors when testing argument names in macro definitions
 - used to provide most protections for object and class namespaces

>[source](/src/ifdef.s), [examples](/doc/s/examples/ifdef_ex.s)

---
### ifnum

Check if Input Starts with a Numerical Expression
 - an if tool that checks the first char of input literals for a numerical expression
 - useful for catching arguments that can't be treated like symbols before creating any errors

>[source](/src/ifnum.s), [examples](/doc/s/examples/ifnum_ex.s)

---
### items

Argument Item Buffer Objects
 - a scalar buffer object pseudo-class that can efficiently store `:vararg` items
 - useful for creating iterators that do not attempt to evaluate the contents
   - buffers are similar to `str` objects, but are much lighter-weight and less featured

>[source](/src/items.s), [examples](/doc/s/examples/items_ex.s)

---
### library

Library Objects
 - a class that enables library objects, like `punkpc`
 - can be used to define specialized sub-dirs for storing extra modules or binary files

>[source](/src/library.s), [examples](/doc/s/examples/library_ex.s)

---
### list

List Objects
 - an extended version of a `stack` object
   - list objects have an internal iterator index for iterating through a stack buffer
   - indexing allows for random-access get/set features at the object-level
   - mutable iterator and indexing methods can be given custom behaviors

>[source](/src/list.s), [examples](/doc/s/examples/list_ex.s)

---
### lmf

Load Multiple Floats
 - can be used similarly to the `lmw` and `stmw` instructions, but for various float types
   - `lmfs` and `stmfs` for single-precision
   - `lmfd` and `stmfd` for double-precision
 - does not change the number of instructions required for multiple registers

>[source](/src/lmf.s), [examples](/doc/s/examples/lmf_ex.s)

---
### load

Load Immediate(s)
 - a tool for creating multi-immediate loads
 - immediates larger than 16-bits will require multiple instructions
   - you can use this macroinstruction to string together as many as you need for a given input

>[source](/src/load.s), [examples](/doc/s/examples/load_ex.s)

---
### mut

Object Method Mutator Hooks
 - a core module for defining mutable behavior hooks
 - useful for making your class/objects customizable
 - extended by the `obj` module

>[source](/src/mut.s), [examples](/doc/s/examples/mut_ex.s)

---
### obj

Objects (and Classes)
 - a core module for defining classes that construct objects
 - objects are uniquely named
 - unique objects may be given pointer IDs, for identifying instances of a class
 - object methods may be defined through hook callers, for creating mutable behaviors
   - mutable object methods may be reached via pointers, at the class level
 - object properties may be given hidden names, used internally by the constructor

>[source](/src/obj.s), [examples](/doc/s/examples/obj_ex.s)

---
### ppc

PowerPC Modules
 - a collection of all of the modules that include PowerPC related macroinstructions
 - version 0.0.2 includes: `branch`, `cr`, `data`, `idxr`, `load`, `small`, and `sp`
 - if no args are given to `punkpc` when calling it, this module is loaded by default

>[source](/src/ppc.s), [examples](/doc/s/examples/ppc_ex.s)

---
### regs

Register Symbols
 - a module that defines normal register indices like `r3`, `r4`, `r5` as global symbols
 - useful for enabling registers for use like indices as part of counters
 - also includes names for cr bits and fields

>[source](/src/regs.s), [examples](/doc/s/examples/regs_ex.s)

---
### sidx

Scalar Index Tools
 - useful for referencing object/dictionary elements as part of an array of indexed symbols
   - symbol arrays are indexed literally by casting evaluated indices into decimal literals
   - the decimal literals are appended to symbol names with a `$` delimitter
     - '$' stands for 'Scalar Index'

>[source](/src/sidx.s), [examples](/doc/s/examples/sidx_ex.s)

---
### small

Small Integer Tools/Instructions
 - macroinstructions for inserting/extracting small integers into/out of larger ones
 - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

>[source](/src/small.s), [examples](/doc/s/examples/small_ex.s)

---
### sp

Runtime Stack Pointer (prolog/epilog block generators)
 - dramatically simplifies function writing
 - makes it very easy to create and use named registers, quickly
 - supports nested and/or serial frame definitions
 - comes with enumerators mutated to handle definition of all temporary memory in stack frame
   - includes anonymous and named register backups/restores
   - includes anonymous and named temporary memory allocation offset names
   - includes all special-purpose register names

>[source](/src/sp.s), [examples](/doc/s/examples/sp_ex.s)

---
### spr

SPR utilities
 - creates macroinstructions for loading and storing multiple special purpose registers
   - each load or store costs 2 sintructions (a 'move' and a 'read/write')
 - includes a dictionary of spr keywords, unified by the `spr.*` namespace

>[source](/src/spr.s), [examples](/doc/s/examples/spr_ex.s)

---
### stack

Stack Objects
 - a scalar stack object class, powered by `sidx`
 - useful for making scalar variables that can be pushed, popped, dequeued
   - corresponding symbol memory can be accessed randomly, if referenced directly
 - can be easily fashioned into arrays, structs, or pointer tables
 - can be easily extended to create more specific features that require scalar memory

>[source](/src/stack.s), [examples](/doc/s/examples/stack_ex.s)

---
### str

String Objects
 - a scalar buffer object class that stores literal memory
 - can store "quoted strings" for pretecting literals
 - can store \<\<nestable\>, \<altmacro strings\>\> for creating complex tuples
 - can store `literal strings` that are unprotected, and can be executed like macros
   - unlike the `items` class, no delimiting commas are implied, and buffers can use prefix concatenation methods

>[source](/src/str.s), [examples](/doc/s/examples/str_ex.s)

---
### xem

Expression Emitter Tool
 - a tiny precursor to `sidx` that names things without any special delimiters
 - used in the `regs` module to create register names

>[source](/src/xem.s), [examples](/doc/s/examples/xem_ex.s)

---
### xev

Extract Evaluation Tool
 - for extracting evaluable literals from 2 known character indices in a given string argument
 - useful when parsing complex inputs for evaluable sub-expressions

>[source](/src/xev.s), [examples](/doc/s/examples/xev_ex.s)

---
