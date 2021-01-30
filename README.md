# punkpc

Punkpc is a collection of several loose experiments made for use in GNU Assembler that may assist in writing small binaries. The tools are presented as importable modules with a special macro that handles `.include` statements as needed for branching prerequisites.

## About

I started this project after exploring the kind of utility that could be squeezed out of basic symbol and macro primitives in GAS. It provides in-assembler tools that are useful for writing injection code, function libraries, and small files with just `as.exe`. It's intended to be usable without relying on a linker or a compiler for high level features.

Some of the modules offer convenient tweaks and extensions to the PowerPC language. They are all collected under the module called `ppc`:

![example use of the 'ppc' module][img_ppc]

---

Punkpc is intended for use with the PowerPC instruction set, but contains tools that work with just GNU Assembler, as well. Other modules provide 'classes' in GAS that can instantiate objects for use in the assembler. These classes are simply strict uses of namespaces in macros and symbols.

For instance: the `str` module offers a useful class of 'string' objects for the GAS environment. These allow for scalar literal memory to be stored, appended, and emitted elsewhere in the assembly program as part of a statement:

![example use of the 'str' module][img_str]

---

The `stack` module is another example of a useful class of object. They allow for a different type of scalar memory that uses integers through a scalar variable, or through references to discretely named symbols.

Stack objects are also made with the `obj` module, and can be extended and mutated.

Lists from the `list` module are an extended version of stacks that include features for iterating through a stack of integer values, or reading/writing to them more easily with random access:

![example use of the 'list' module][img_list]

---

It's possible to do tasks such as sorting, pointing, and concatenation with scalar buffers provided by these objects. These kinds of constructs are normally very tedious to create in GAS, but become much easier to implement and make use of through this meta-object system.

- For a full list of the provided class modules, and some guides on how to use them -- see the table of contents in the extra readme in the [doc directory][doc].



## Installation

To install punkpc, simply copy the contents of the [.include directory][inc] into your working `as.exe` directory.

> alternatively, copy the contents into a place that is accessed by the `-I` [command][icommand], for include directories.



## Usage

Use the `.include` directive to load **"punkpc.s"** (in quotes, all lowercase):

```YAML
.include "punkpc.s"
```


This gives you access to the `punkpc` library object, which you can invoke it to import modules:

```YAML
punkpc str, list, data
```

Each 'module' argument `*` corresponds with a `*.s` file in the library object's designated folder. For punkpc, this is the `punkpc/` folder. You may adjust this as needed by your assembler environment.

Modules are imported through conditional use of the `.include` statement, which can be used as a manual alternative to using library objects, if desired.


## More Info

- See the [doc directory][doc] for examples, documentation, and guides
- See the [src directory][src] for commented source and scratch notes

[doc]: /doc/
[src]: /src/
[inc]: /.include/

[img_ppc]:  /doc/img/readme_main_ppc.png
[img_str]:  /doc/img/readme_main_str.png
[img_list]: /doc/img/readme_main_list.png

[guide_library_objects]: /doc/md/guide_library_objects.md

[icommand]: https://sourceware.org/binutils/docs/as/Invoking.html#Invoking
