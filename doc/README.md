# Documentation:
- [Guides](/doc#Guides)
- [Modules](/doc#Modules) : 
  - [`library`](/doc#library) : *generic tools*
    - [`align`](/doc#align), [`bcount`](/doc#bcount), [`dbg`](/doc#dbg), [`en`](/doc#en), [`hex`](/doc#hex), [`hidden`](/doc#hidden), [`idxr`](/doc#idxr), [`xem`](/doc#xem), [`xev`](/doc#xev)
    - [`if`](/doc#if) : *special if blocks*
      - [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum)
    - [`obj`](/doc#obj) : *objects and classes*
      - [`enum`](/doc#enum), [`mut`](/doc#mut)
      - [`sidx`](/doc#sidx) : *integer buffers*
        - [`enc`](/doc#enc), [`errata`](/doc#errata), [`list`](/doc#list), [`stack`](/doc#stack)
      - [`str`](/doc#str) : *literal buffers*
        - [`items`](/doc#items)
  - [`ppc`](/doc#ppc) : *powerpc modules*
    - [`branch`](/doc#branch), [`cr`](/doc#cr), [`data`](/doc#data), [`gecko`](/doc#gecko), [`lmf`](/doc#lmf), [`load`](/doc#load), [`regs`](/doc#regs), [`small`](/doc#small), [`sp`](/doc#sp), [`spr`](/doc#spr)


## Guides

- [Project Overview](https://github.com/Punkline/punkpc#punkpc)
- [Creating New Library Objects](/doc/md/guide_library_objects.md)

## Modules

Documentation links use the following emojis:

[:pencil2:](/src) = ***commented source***, with attribute information <br />
[:alembic:](/doc/s/examples) = ***example usage***, with guiding comments <br />
[:boom:](/doc/s/exploded_lines) = ***exploded lines***, uncommented

Some modules use other modules as dependencies. Loading them will load the dependencies alongside the module automatically, as required:

:arrow_right: = ***prerequisite modules*** <br />
:negative_squared_cross_mark: = ***stand-alone modules*** require no prerequisites <br /><br />

NOTE:
> when using the `punkpc` library object to include modules (like each module does, internally) -- a `.include` statement is only called if the file is not already in the GAS environment.
>
>Including multiple modules that have a common prerequisite will have faster load times because the prereq only needs to be loaded once between them all.

---

### [`align`](/doc#align)

Alignment Tool (relative)
 - an alternative to the `.align` directive that doesn't destroy absolute expressions
   - relative addresses (labels) can't be measured after normal aligns using this directive
 - useful for measuring arbitrary body sizes that include un-aligned data
   - byte arrays and strings are examples of structs that commonly need re-alignment

>[*Links*](/doc#modules) : [:pencil2:](/src/align.s)[:alembic:](/doc/s/examples/align_ex.s)[:boom:](/doc/s/exploded_lines/align.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifalt`](/doc#ifalt)

---
### [`bcount`](/doc#bcount)

Bit Counter Tools
 - fast checks for counting unused bits in an integer
 - useful for finding integer sizes when creating masks, for compression

>[*Links*](/doc#modules) : [:pencil2:](/src/bcount.s)[:alembic:](/doc/s/examples/bcount_ex.s)[:boom:](/doc/s/exploded_lines/bcount.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`branch`](/doc#branch)

Branch (absolute)
 - absolute branch macroinstructions that replace the `bla` and `ba` instructions
   - these create long-form 4-instruction absolute calls/branches via `blrl` or `bctr`

>[*Links*](/doc#modules) : [:pencil2:](/src/branch.s)[:alembic:](/doc/s/examples/branch_ex.s)[:boom:](/doc/s/exploded_lines/branch.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`cr`](/doc#cr)

Condition/Comparison Register/Fields
 - utilities for working with cr fields
   - also includes fixes for some cr instructions that are poory emulated in some environmnets
 - useful for writing efficient (and legible) binary trees in PowerPC functions

>[*Links*](/doc#modules) : [:pencil2:](/src/cr.s)[:alembic:](/doc/s/examples/cr_ex.s)[:boom:](/doc/s/exploded_lines/cr.s)<br />
[:top:](/doc#Documentation):arrow_right: [`enum`](/doc#enum), [`regs`](/doc#regs), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`xem`](/doc#xem), [`en`](/doc#en)

---
### [`data`](/doc#data)

Inline Data Tables
 - creates macroinstructions that exploit the link register in `bl` and `blrl` to make data tables
   - resulting instructions are capable of referencing data local to the runtime program counter
 - also includes some utilities for creating binary data structs

>[*Links*](/doc#modules) : [:pencil2:](/src/data.s)[:alembic:](/doc/s/examples/data_ex.s)[:boom:](/doc/s/exploded_lines/data.s)<br />
[:top:](/doc#Documentation):arrow_right: [`if`](/doc#if), [`sidx`](/doc#sidx), [`align`](/doc#align), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum)

---
### [`dbg`](/doc#dbg)

Debug Tool
 - a simple evaluation tool, for debugging symbol values

>[*Links*](/doc#modules) : [:pencil2:](/src/dbg.s)[:alembic:](/doc/s/examples/dbg_ex.s)[:boom:](/doc/s/exploded_lines/dbg.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`en`](/doc#en)

Enumerator (quick)
 - a fast, featureless enumeration tool for naming offset and register symbols
   - intended to work similarly to [`enum`](/doc#enum), but as small and quick as possible

>[*Links*](/doc#modules) : [:pencil2:](/src/en.s)[:alembic:](/doc/s/examples/en_ex.s)[:boom:](/doc/s/exploded_lines/en.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`enc`](/doc#enc)

Encoder Stacks
 - convert source literals into a stack of ascii ints
   - extended stack object constructor lets you create multiple encoder buffers
 - may be used to create pseudo-regex-like parses of input literals

>[*Links*](/doc#modules) : [:pencil2:](/src/enc.s)[:alembic:](/doc/s/examples/enc_ex.s)[:boom:](/doc/s/exploded_lines/enc.s)<br />
[:top:](/doc#Documentation):arrow_right: [`stack`](/doc#stack), [`if`](/doc#if), [`sidx`](/doc#sidx), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`obj`](/doc#obj)

---
### [`enum`](/doc#enum)

Enumerator Objects
 - a powerful object class for parsing comma-separated inputs
   - default behaviors are useful for counting named registers and offsets
   - highly mutable objects may be individually mutated for custom behaviors
 - useful for creating methods that handle user inputs, or that consume [`items`](/doc#items) buffers

>[*Links*](/doc#modules) : [:pencil2:](/src/enum.s)[:alembic:](/doc/s/examples/enum_ex.s)[:boom:](/doc/s/exploded_lines/enum.s)<br />
[:top:](/doc#Documentation):arrow_right: [`obj`](/doc#obj), [`en`](/doc#en), [`regs`](/doc#regs), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`xem`](/doc#xem), [`enum`](/doc#enum)

---
### [`errata`](/doc#errata)

Errata Objects
 - generate constants that can be referenced before they are defined
   - requires that the errata doesn't need to be immediately evaluated after being emitted
 - useful for making cumulative results of an arbitrary number of operations, like block contexts

>[*Links*](/doc#modules) : [:pencil2:](/src/errata.s)[:alembic:](/doc/s/examples/errata_ex.s)[:boom:](/doc/s/exploded_lines/errata.s)<br />
[:top:](/doc#Documentation):arrow_right: [`obj`](/doc#obj), [`sidx`](/doc#sidx), [`if`](/doc#if), [`hidden`](/doc#hidden), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`mut`](/doc#mut)

---
### [`gecko`](/doc#gecko)

Gecko Injection and Overwrite Ops
 - in-assembler gecko opcodes, for writing injection and overwrite patches
   - injection ops create blocks that are written as `C2` codes
   - overwrite ops create individual `04` codes

>[*Links*](/doc#modules) : [:pencil2:](/src/gecko.s)[:alembic:](/doc/s/examples/gecko_ex.s)[:boom:](/doc/s/exploded_lines/gecko.s)<br />
[:top:](/doc#Documentation):arrow_right: [`errata`](/doc#errata), [`align`](/doc#align), [`if`](/doc#if), [`obj`](/doc#obj), [`hidden`](/doc#hidden), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`mut`](/doc#mut), [`sidx`](/doc#sidx)

---
### [`hex`](/doc#hex)

Hex Emitter Objects (with Array of Byte History)
 - extends the 'enc' object class
   - emit bytes from raw hex literals, as user inputs
     - accepts a mix of whitespace, commas, and '0x' prefixes
     - buffers nibbles as partial bytes, for odd char inputs
     - skips non-hex literals, save for a couple of special syntaxes:
       - use `.` chars to align the buffer to various powers of 2
       - use `"` chars to enter raw ascii in place of hex literals
   - saves input bytes as an array of readable/writable bytes
   - can emit bytes after saving and modifying them in memory

>[*Links*](/doc#modules) : [:pencil2:](/src/hex.s)[:alembic:](/doc/s/examples/hex_ex.s)[:boom:](/doc/s/exploded_lines/hex.s)<br />
[:top:](/doc#Documentation):arrow_right: [`enc`](/doc#enc), [`align`](/doc#align), [`stack`](/doc#stack), [`sidx`](/doc#sidx), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`if`](/doc#if), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`obj`](/doc#obj)

---
### [`hidden`](/doc#hidden)

Hidden Symbol Names
 - a tool for creating hidden symbol names
   - exploits support of the `\001` char in LOCAL labels in symbol names
 - (intended for use without a linker)

>[*Links*](/doc#modules) : [:pencil2:](/src/hidden.s)[:alembic:](/doc/s/examples/hidden_ex.s)[:boom:](/doc/s/exploded_lines/hidden.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`idxr`](/doc#idxr)

Index (Register)
 - index (register) input extraction tool
 - useful for simulating load/store syntaxes like the `0x20(r30)` part of `lwz r3, 0x20(r30)`

>[*Links*](/doc#modules) : [:pencil2:](/src/idxr.s)[:alembic:](/doc/s/examples/idxr_ex.s)[:boom:](/doc/s/exploded_lines/idxr.s)<br />
[:top:](/doc#Documentation):arrow_right: [`xev`](/doc#xev)

---
### [`if`](/doc#if)

Special If Statements
 - a collection of various checks that may be used with `.if` block directives
 - intended for making useful checks of difficult to compare things in GAS

>[*Links*](/doc#modules) : [:pencil2:](/src/if.s)[:alembic:](/doc/s/examples/if_ex.s)[:boom:](/doc/s/exploded_lines/if.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum)

---
### [`ifalt`](/doc#ifalt)

If in Altmacro Mode
 - an if tool that can be used to check the current altmacro environment state
 - used to preserve the altmacro mode, and avoid ruining string interpretations

>[*Links*](/doc#modules) : [:pencil2:](/src/ifalt.s)[:alembic:](/doc/s/examples/ifalt_ex.s)[:boom:](/doc/s/exploded_lines/ifalt.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`ifdef`](/doc#ifdef)

If Symbol is Defined
 - an if tool that circumvents the need for `\` chars in .ifdef checks
   - this is needed to prevent errors when testing argument names in macro definitions
 - used to provide most protections for object and class namespaces

>[*Links*](/doc#modules) : [:pencil2:](/src/ifdef.s)[:alembic:](/doc/s/examples/ifdef_ex.s)[:boom:](/doc/s/exploded_lines/ifdef.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifalt`](/doc#ifalt)

---
### [`ifnum`](/doc#ifnum)

If Input Starts with a Numerical Expression
 - an if tool that checks the first char of input literals for a numerical expression
 - useful for catching arguments that can't be treated like symbols before creating any errors
   - may also be useful for checking ascii in [`enc`](/doc#enc) stacks

>[*Links*](/doc#modules) : [:pencil2:](/src/ifnum.s)[:alembic:](/doc/s/examples/ifnum_ex.s)[:boom:](/doc/s/exploded_lines/ifnum.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`items`](/doc#items)

Argument Item Buffer Objects
 - a scalar buffer object pseudo-class that can efficiently store `:vararg` items
 - buffers are similar to [`str`](/doc#str) objects, but are much lighter-weight and less featured
 - useful for creating iterators that do not attempt to evaluate the contents
   - may be used to buffer args that are consumed by [`enum`](/doc#enum) parsers

>[*Links*](/doc#modules) : [:pencil2:](/src/items.s)[:alembic:](/doc/s/examples/items_ex.s)[:boom:](/doc/s/exploded_lines/items.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`library`](/doc#library)

Library Objects
 - a class that enables library objects, like `punkpc`
   - `punkpc` is like the origin of all importable class modules
 - can be used to define specialized sub-dirs for storing extra modules or binary files
   - new library objects can be made besides `punkpc`

>[*Links*](/doc#modules) : [:pencil2:](/src/library.s)[:alembic:](/doc/s/examples/library_ex.s)[:boom:](/doc/s/exploded_lines/library.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`list`](/doc#list)

List Objects
 - an extended version of a [`stack`](/doc#stack) object
   - list objects have an internal iterator index for iterating through a stack buffer
   - indexing allows for random-access get/set features at the object-level
   - mutable iterator and indexing methods can be given custom behaviors

>[*Links*](/doc#modules) : [:pencil2:](/src/list.s)[:alembic:](/doc/s/examples/list_ex.s)[:boom:](/doc/s/exploded_lines/list.s)<br />
[:top:](/doc#Documentation):arrow_right: [`stack`](/doc#stack), [`sidx`](/doc#sidx), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`if`](/doc#if), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`obj`](/doc#obj)

---
### [`lmf`](/doc#lmf)

Load Multiple Floats
 - handle loading and storing many floats in a sequence of instructions using single macro calls
 - can be used similarly to the `lmw` and `stmw` instructions, but for various float types
   - `lmfs` and `stmfs` for single-precision
   - `lmfd` and `stmfd` for double-precision
 - does not change the number of instructions required for multiple registers

>[*Links*](/doc#modules) : [:pencil2:](/src/lmf.s)[:alembic:](/doc/s/examples/lmf_ex.s)[:boom:](/doc/s/exploded_lines/lmf.s)<br />
[:top:](/doc#Documentation):arrow_right: [`regs`](/doc#regs), [`idxr`](/doc#idxr), [`xem`](/doc#xem), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`enum`](/doc#enum), [`en`](/doc#en), [`xev`](/doc#xev)

---
### [`load`](/doc#load)

Load Immediate(s)
 - a tool for creating multiple immediate loads
   - immediates larger than 16-bits will require multiple instructions
   - you can use this macroinstruction to string together as many as you need for a given input
 - useful for writing functions that load absolute addresses, ascii keywords, and other things

>[*Links*](/doc#modules) : [:pencil2:](/src/load.s)[:alembic:](/doc/s/examples/load_ex.s)[:boom:](/doc/s/exploded_lines/load.s)<br />
[:top:](/doc#Documentation):arrow_right: [`regs`](/doc#regs), [`xem`](/doc#xem), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`enum`](/doc#enum), [`en`](/doc#en)

---
### [`mut`](/doc#mut)

Object Method Mutator Hooks
 - a core module for defining mutable behavior hooks
   - 'hooks' create method calls that may have a default behavior that yields to a mutable mode
 - useful for making your class/objects customizable
 - extensively used by the [`obj`](/doc#obj) module

>[*Links*](/doc#modules) : [:pencil2:](/src/mut.s)[:alembic:](/doc/s/examples/mut_ex.s)[:boom:](/doc/s/exploded_lines/mut.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifdef`](/doc#ifdef), [`ifalt`](/doc#ifalt)

---
### [`obj`](/doc#obj)

Objects (and Classes)
 - a core module for defining classes that construct objects
 - objects are uniquely named
   - unique objects may be given pointer IDs, for identifying instances of a class
 - object methods may be defined through hook callers with [`mut`](/doc#mut), for creating mutable behaviors
   - mutable object methods may be reached via pointers, at the class level
 - object properties may be given [`hidden`](/doc#hidden) names, used internally by the constructor
 - very useful for stream-lining the creation of object constructors

>[*Links*](/doc#modules) : [:pencil2:](/src/obj.s)[:alembic:](/doc/s/examples/obj_ex.s)[:boom:](/doc/s/exploded_lines/obj.s)<br />
[:top:](/doc#Documentation):arrow_right: [`if`](/doc#if), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum)

---
### [`ppc`](/doc#ppc)

PowerPC Modules
 - a collection of all of the modules that include PowerPC related macroinstructions
 - if no args are given to `punkpc` when calling it, this module is loaded by default

>[*Links*](/doc#modules) : [:pencil2:](/src/ppc.s)[:alembic:](/doc/s/examples/ppc_ex.s)[:boom:](/doc/s/exploded_lines/ppc.s)<br />
[:top:](/doc#Documentation):arrow_right: [`branch`](/doc#branch), [`cr`](/doc#cr), [`data`](/doc#data), [`idxr`](/doc#idxr), [`load`](/doc#load), [`small`](/doc#small), [`sp`](/doc#sp), [`gecko`](/doc#gecko), [`enum`](/doc#enum), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`xem`](/doc#xem), [`en`](/doc#en), [`regs`](/doc#regs), [`sidx`](/doc#sidx), [`align`](/doc#align), [`xev`](/doc#xev), [`bcount`](/doc#bcount), [`enc`](/doc#enc), [`stack`](/doc#stack), [`lmf`](/doc#lmf), [`spr`](/doc#spr), [`items`](/doc#items), [`errata`](/doc#errata)

---
### [`regs`](/doc#regs)

Register Symbols
 - a module that defines normal register indices like `r3`, `r4`, `r5` as global symbols
 - useful for enabling registers for use like indices as part of counters
 - also includes names for [`cr`](/doc#cr) bits and fields

>[*Links*](/doc#modules) : [:pencil2:](/src/regs.s)[:alembic:](/doc/s/examples/regs_ex.s)[:boom:](/doc/s/exploded_lines/regs.s)<br />
[:top:](/doc#Documentation):arrow_right: [`xem`](/doc#xem), [`enum`](/doc#enum), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`en`](/doc#en), [`regs`](/doc#regs)

---
### [`sidx`](/doc#sidx)

Scalar Index Tools
 - create statements that include pre-evaluated decimal literals
 - decimal literals may be used to create indexed integer arrays, using named symbols
   - the decimal literals are appended to symbol names with a `$` delimitter
     - `$` stands for 'Scalar Index'
 - useful for creating buffers, and powers many object types in `punkpc`

>[*Links*](/doc#modules) : [:pencil2:](/src/sidx.s)[:alembic:](/doc/s/examples/sidx_ex.s)[:boom:](/doc/s/exploded_lines/sidx.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifalt`](/doc#ifalt)

---
### [`small`](/doc#small)

Small Integer Tools/Instructions
 - macroinstructions for inserting/extracting small integers into/out of larger ones
 - overrides the `rlwinm` and `rlwimi` instructions to provide an alternative 3-argument syntax
   - 3-argument syntax implies all rotation math, requiring only a mask symbol, and registers
   - existing 4-argument and 5-argument syntaxes are reverted to, when detected

>[*Links*](/doc#modules) : [:pencil2:](/src/small.s)[:alembic:](/doc/s/examples/small_ex.s)[:boom:](/doc/s/exploded_lines/small.s)<br />
[:top:](/doc#Documentation):arrow_right: [`bcount`](/doc#bcount), [`enum`](/doc#enum), [`ifalt`](/doc#ifalt), [`obj`](/doc#obj), [`if`](/doc#if), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`xem`](/doc#xem), [`en`](/doc#en), [`regs`](/doc#regs)

---
### [`sp`](/doc#sp)

Runtime Stack Pointer (prolog/epilog block generators)
 - dramatically simplifies function writing
   - use `prolog` and `epilog` to create a block context
 - makes it very easy to create and use named registers, quickly
   - use `sp.gprs` and `sp.fprs` to create any register names you like
     - alternatively, give `prolog` arguments starting with `rName` or `fName` camel-case names
 - comes with enumerators mutated to handle definition of all temporary memory in stack frame
   - includes anonymous and named register backups/restores
     - give `prolog` any normal register names, like `r30` or `f30` to back up a range
   - includes anonymous and named temporary memory allocation offset names
     - give `prolog` an expression, or an `xName` camel-case name
   - includes support for all special-purpose register names
 - includes support for nested and/or serial frame definitions

>[*Links*](/doc#modules) : [:pencil2:](/src/sp.s)[:alembic:](/doc/s/examples/sp_ex.s)[:boom:](/doc/s/exploded_lines/sp.s)<br />
[:top:](/doc#Documentation):arrow_right: [`regs`](/doc#regs), [`enc`](/doc#enc), [`lmf`](/doc#lmf), [`spr`](/doc#spr), [`items`](/doc#items), [`xem`](/doc#xem), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`enum`](/doc#enum), [`en`](/doc#en), [`stack`](/doc#stack), [`sidx`](/doc#sidx), [`idxr`](/doc#idxr), [`xev`](/doc#xev)

---
### [`spr`](/doc#spr)

SPR utilities
 - creates macroinstructions for loading and storing multiple special purpose registers
   - each load or store costs 2 sintructions (a 'move' and a 'read/write')
 - includes a dictionary of spr keywords, unified by the `spr.*` namespace
 - also includes support for some non-spr keywords, like `msr` and `sr`

>[*Links*](/doc#modules) : [:pencil2:](/src/spr.s)[:alembic:](/doc/s/examples/spr_ex.s)[:boom:](/doc/s/exploded_lines/spr.s)<br />
[:top:](/doc#Documentation):arrow_right: [`idxr`](/doc#idxr), [`regs`](/doc#regs), [`xev`](/doc#xev), [`xem`](/doc#xem), [`obj`](/doc#obj), [`if`](/doc#if), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut), [`enum`](/doc#enum), [`en`](/doc#en)

---
### [`stack`](/doc#stack)

Stack Objects
 - a scalar stack object class, powered by [`sidx`](/doc#sidx)
 - useful for making scalar variables that can be pushed, popped, dequeued
   - corresponding symbol memory can be accessed randomly, if referenced directly
 - can be easily fashioned into arrays, structs, or pointer tables
 - can be easily extended to create more specific features that require scalar memory

>[*Links*](/doc#modules) : [:pencil2:](/src/stack.s)[:alembic:](/doc/s/examples/stack_ex.s)[:boom:](/doc/s/exploded_lines/stack.s)<br />
[:top:](/doc#Documentation):arrow_right: [`sidx`](/doc#sidx), [`if`](/doc#if), [`obj`](/doc#obj), [`ifalt`](/doc#ifalt), [`ifdef`](/doc#ifdef), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut)

---
### [`str`](/doc#str)

String Objects
 - a scalar buffer object class that stores literal memory
 - can store `"quoted strings"` for protecting literals
 - can store `<<nestable>, <altmacro strings>>` for creating complex tuples
 - can store `literal strings` that are unprotected, and can be executed like macros
   - unlike the [`items`](/doc#items) class, no delimiting commas are implied, and buffers can use prefix concatenation methods

>[*Links*](/doc#modules) : [:pencil2:](/src/str.s)[:alembic:](/doc/s/examples/str_ex.s)[:boom:](/doc/s/exploded_lines/str.s)<br />
[:top:](/doc#Documentation):arrow_right: [`ifdef`](/doc#ifdef), [`ifalt`](/doc#ifalt), [`obj`](/doc#obj), [`if`](/doc#if), [`ifnum`](/doc#ifnum), [`hidden`](/doc#hidden), [`mut`](/doc#mut)

---
### [`xem`](/doc#xem)

Expression Emitter Tool
 - a tiny utility that provides less-featured decimal literal evaluations, similar to [`sidx`](/doc#sidx)
   - input strings are not concatenated with special delimiter `$`
 - used in the [`regs`](/doc#regs) module to create register names

>[*Links*](/doc#modules) : [:pencil2:](/src/xem.s)[:alembic:](/doc/s/examples/xem_ex.s)[:boom:](/doc/s/exploded_lines/xem.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
### [`xev`](/doc#xev)

Extract Evaluation Tool
 - for extracting evaluable literals from 2 known character indices in a given string argument
 - useful when parsing complex inputs for evaluable sub-expressions

>[*Links*](/doc#modules) : [:pencil2:](/src/xev.s)[:alembic:](/doc/s/examples/xev_ex.s)[:boom:](/doc/s/exploded_lines/xev.s)<br />
[:top:](/doc#Documentation) :negative_squared_cross_mark: -- no dependencies

---
