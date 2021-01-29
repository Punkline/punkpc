# Documentation

This dir is for sharing additional documentation.


## Guides:
- [Creating New Library Objects](/doc/md/guide_library_objects.md)


## Modules
All punkpc modules create utilities for the GNU Assembler environment. Each of the following links contains **examples** and/or **attribute information** about each class module.

Not all modules create formal classes, but each has a dedicated file:

- [**bcount**](/s/examples/bcount_doc) - some bit counter tools, for finding int sizes
- [**branch**](/s/examples/branch_doc) - absolute branch macroinstructions that replace the `bla` and `ba` instructions with long-form 4-instruction absolute calls/branches via `blrl` or `bctr`
- [**cr**](/s/examples/cr_doc) - cr instruction fixes, and utilities for working with cr fields to more efficiently (and legibly) write binary trees in PowerPC functions
- [**data**](/s/examples/data_doc) - inline data tables macroinstructions, and some utilities for creating binary data structs
- [**dbg**](/s/examples/dbg_doc) - a simple evaluation tool, for debugging macros
- [**en**](/s/examples/en_doc) - a fast, featureless enumeration tool for naming offset and register symbols
- [**enc**](/s/examples/enc_doc) - encoder stacks, for converting source literals into ascii ints
- [**enum**](/s/examples/enum_doc) - a powerful, 'enumerator object' class, for creating input parsers with mutable hooks
- [**hidden**](/s/examples/hidden_doc) - a tool for creating hidden symbol names (without a linker)
- [**idxr**](/s/examples/idxr_doc) - index (register) input extraction tool, for simulating load/store syntaxes
- [**if**](/s/examples/if_doc) - a collection of various 'if' tools, for checking difficult to compare things in GAS
- [**ifalt**](/s/examples/ifalt_doc) - an if tool that can be used to check the current altmacro environment state
- [**ifdef**](/s/examples/ifdef_doc) - an if tool that circumvents the need for `\` chars in .ifdef checks
- [**ifnum**](/s/examples/ifnum_doc) - an if tool that checks the first char of input literals for a numerical expression
- [**items**](/s/examples/items_doc) - a scalar buffer object pseudo-class that can efficiently store `:vararg` items, for iterating through
- [**library**](/s/examples/library_doc) - a class that enables library objects, like `punkpc`
- [**list**](/s/examples/list_doc) - an extended version of a `stack` object, with an internal iterator index for buffering integers as symbol values
- [**lmf**](/s/examples/lmf_doc) - load multiple floats (a collection of load/store floating point macros)
- [**load**](/s/examples/load_doc) - a tool for creating multi-immediate loads (2 or more, supports string inputs)
- [**mut**](/s/examples/mut_doc) - a core module for defining mutable behavior hooks, for object methods and internal calls
- [**obj**](/s/examples/obj_doc) - a core module for defining class modules that construct objects with pointers, mutators, and/or hidden property names
- [**ppc**](/s/examples/ppc_doc) - a collection of all of the modules that include PowerPC related macroinstructions
- [**regs**](/s/examples/regs_doc) - a module that defines normal register indices like r0, r1, r2 as global symbols, with definitions for various cr bits and fields
- [**sidx**](/s/examples/sidx_doc) - scalar index generators, for referencing object/dictionary namespaces that include a variable number as part of their symbol/macro names
- [**small**](/s/examples/small_doc) - macroinstructions for inserting/extracting small integers, and various tools that help make it easier
- [**sp**](/s/examples/sp_doc) - stack pointer prolog/epilog generators, with support for populating temporary memory with named offsets, named register backups, and support for spr keywords
- [**stack**](/s/examples/stack_doc) - a scalar stack object class, for making scalar variables that can be pushed, popped, dequeued, and corresponding memory that has random access to its elements
- [**str**](/s/examples/str_doc) - a scalar buffer object class that stores "quoted strings", \<\<nestable\>, \<altmacro strings\>\>, and `literal strings` in a way that can be passed as arguments for a macro, instruction, or directive call
- [**xem**](/s/examples/xem_doc) - expression emitter tool - a tiny precursor to `sidx` that names things without any special delimiters
- [**xev**](/s/examples/xev_doc) - extract evaluation tool, for extracting evaluable literals from 2 known character indices in a given string argument
