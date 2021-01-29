# Documentation

This dir is for sharing additional documentation.


## Guides:
- [Creating New Library Objects](/doc/md/guide_library_objects.md)


## Modules
All punkpc modules create utilities for the GNU Assembler environment.

Each of the following links contains **examples** and/or **attribute information** about each class module.

Not all modules create formal classes, but each has a dedicated file:

- [**bcount**](/doc/s/examples/bcount_doc.s) - some bit counter tools, for finding int sizes
- [**branch**](/doc/s/examples/branch_doc.s) - absolute branch macroinstructions that replace the `bla` and `ba` instructions with long-form 4-instruction absolute calls/branches via `blrl` or `bctr`
- [**cr**](/doc/s/examples/cr_doc.s) - cr instruction fixes, and utilities for working with cr fields to more efficiently (and legibly) write binary trees in PowerPC functions
- [**data**](/doc/s/examples/data_doc.s) - inline data tables macroinstructions, and some utilities for creating binary data structs
- [**dbg**](/doc/s/examples/dbg_doc.s) - a simple evaluation tool, for debugging macros
- [**en**](/doc/s/examples/en_doc.s) - a fast, featureless enumeration tool for naming offset and register symbols
- [**enc**](/doc/s/examples/enc_doc.s) - encoder stacks, for converting source literals into ascii ints
- [**enum**](/doc/s/examples/enum_doc.s) - a powerful, 'enumerator object' class, for creating input parsers with mutable hooks
- [**hidden**](/doc/s/examples/hidden_doc.s) - a tool for creating hidden symbol names (without a linker)
- [**idxr**](/doc/s/examples/idxr_doc.s) - index (register) input extraction tool, for simulating load/store syntaxes
- [**if**](/doc/s/examples/if_doc.s) - a collection of various 'if' tools, for checking difficult to compare things in GAS
- [**ifalt**](/doc/s/examples/ifalt_doc.s) - an if tool that can be used to check the current altmacro environment state
- [**ifdef**](/doc/s/examples/ifdef_doc.s) - an if tool that circumvents the need for `\` chars in .ifdef checks
- [**ifnum**](/doc/s/examples/ifnum_doc.s) - an if tool that checks the first char of input literals for a numerical expression
- [**items**](/doc/s/examples/items_doc.s) - a scalar buffer object pseudo-class that can efficiently store `:vararg` items, for iterating through
- [**library**](/doc/s/examples/library_doc.s) - a class that enables library objects, like `punkpc`
- [**list**](/doc/s/examples/list_doc.s) - an extended version of a `stack` object, with an internal iterator index for buffering integers as symbol values
- [**lmf**](/doc/s/examples/lmf_doc.s) - load multiple floats (a collection of load/store floating point macros)
- [**load**](/doc/s/examples/load_doc.s) - a tool for creating multi-immediate loads (2 or more, supports string inputs)
- [**mut**](/doc/s/examples/mut_doc.s) - a core module for defining mutable behavior hooks, for object methods and internal calls
- [**obj**](/doc/s/examples/obj_doc.s) - a core module for defining class modules that construct objects with pointers, mutators, and/or hidden property names
- [**ppc**](/doc/s/examples/ppc_doc.s) - a collection of all of the modules that include PowerPC related macroinstructions
- [**regs**](/doc/s/examples/regs_doc.s) - a module that defines normal register indices like r0, r1, r2 as global symbols, with definitions for various cr bits and fields
- [**sidx**](/doc/s/examples/sidx_doc.s) - scalar index tools, for referencing object/dictionary namespaces that include a variable number as part of their symbol/macro names
- [**small**](/doc/s/examples/small_doc.s) - macroinstructions for inserting/extracting small integers, and various tools that help make it easier
- [**sp**](/doc/s/examples/sp_doc.s) - stack pointer prolog/epilog generators, with support for populating temporary memory with named offsets, named register backups, and support for spr keywords
- [**stack**](/doc/s/examples/stack_doc.s) - a scalar stack object class, for making scalar variables that can be pushed, popped, dequeued, and corresponding memory that has random access to its elements
- [**str**](/doc/s/examples/str_doc.s) - a scalar buffer object class that stores "quoted strings", \<\<nestable\>, \<altmacro strings\>\>, and `literal strings` in a way that can be passed as arguments for a macro, instruction, or directive call
- [**xem**](/doc/s/examples/xem_doc.s) - expression emitter tool - a tiny precursor to `sidx` that names things without any special delimiters
- [**xev**](/doc/s/examples/xev_doc.s) - extract evaluation tool, for extracting evaluable literals from 2 known character indices in a given string argument
