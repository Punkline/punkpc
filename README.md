# punkpc
Modules for working with GNU Assembler and the `-mgekko` PowerPC instruction set.
Intended for use without a compiler or a linker.



Installation
------------

Drag and drop the contents of the [.include folder][include] into your working `as.exe` directory.
Alternatively, place them in a folder that is accessed by the `-I` [command][icommand], for include directories.



Usage
-----

Use the `.include` directive to load "punkpc.s" (in quotes) in order to access the main library object:

```
.include "punkpc.s"
```


This gives you access to the `punkpc` library object. 
You can invoke it to import modules:

```
punkpc str, list, data
```

Each 'module' corresponds with a `*.s` file in the `punkpc/` folder. `*` is then made into a keyword that can be used to conditionally trigger loading the file. 

Modules accessed by the library object in this manner will not attempt to `.include` any modules already in the GAS environment, and can be configured to use a different target subdirectory and file extension.



Adding Modules to Libraries
---------------------------

You may create new importable class modules into punkpc or for a custom library in your own implementations using the `library` module.

To make one, you must make a file for `.include` statements to access. 



### PunkPC Library Object

Here is the file used for punkpc, as an example to start with:

```
.ifndef punkpc.library.included

  .ifndef punkpc.module.version
    .include "punkpc/library.s"
  .endif

  module.library punkpc, ".s", ppc
.endif

punkpc.subdir "punkpc/", ".s"

```
- `library.s` is the class module responsible for creating library objects.
- `punkpc.module.version` is the non-0 version number signifying that the library module is already included.
- `module.library` is a method used to generate a library object -- in this case 'punkpc', which uses `.s` file extensions and has the default argument `ppc` if none are given to it when invoked.
- `punkpc.library.included` is a symbol defined signifiy that the 'punkpc' library object exists somewhere in the GAS environment.
- `punkpc.subdir` is a method of the punkpc library object that can be used to change the subdirectory used in `.include` statements made by the library object.



### PunkPC Module Container

By including the above library object file in a `.include "punkpc.s"` statement, we cause the library module to create a new library object that accesses the folder called `punkpc/` for importing `*.s` files. 
The `.ifdef` blocks protect the object from being loaded multiple times in a single environment. 
Each file can be referenced as part of a list of comma-separated arguments that have no extension or path.

All files imported by the punkpc library object is formatted like so, to qualify as a module:

```
.ifndef punkpc.library.included
  .include "punkpc.s"
.endif

punkpc.module myModule, 1
.if module.included == 0


  # --- a new punkpc module called 'myModule' goes here


.endif
```
`punkpc.library.included` is checked here at the module level to ensure that the library object is available. This enables the module to be loaded without the class module and still afford similar protections through `.if` blocks.
`punkpc.module` is a method of punkpc that instantiates a non-0 version number for this module -- which helps inform the environment about whether or not this module is already loaded
`module.included` is a volatile return bool that can be used to inform a `.if` block that protects your module contents.

The `.if` block generated from the returned `module.included` flag will protect the contents of the class module from being defined multiple times. In that sense, class modules are nothing more than protective wrappers for writing constructor macros that create and manage a designed class of object.


A module may technically contain anything, not just class definitions. Any number of macros or symbols you would like to make importable in an assembler environment can be placed here.




### Custom Library Objects

Adding a custom library is then just a matter of invoking `punkpc/library.s` to set up a new library object with a different name, subdirectory, and paramters.

Here is an example that defines an object called 'myLib', and uses the 'myLib/' subdirectory:

```
.ifndef myLib.library.included

  .ifndef punkpc.module.version
    .include "punkpc/library.s"
  .endif

  module.library myLib, ".s"
.endif

myLib.subdir "myLib/", ".s"
```


... and the corresponding module template:

```
.ifndef punkpc.library.included
  .include "punkpc.s"
.endif

punkpc.module myModule, 1
.if module.included == 0


  # --- write module contents here


.endif
```


You can find more details in the [library_doc.s file comments][lib_doc].



More Info
---------

- See the [_doc folder][doc] for examples and documentation of various punkpc class modules
- See the [src folder][src] for commented source and scratch notes

[doc]: https://github.com/Punkline/punkpc/tree/master/_doc
[lib_doc]: https://github.com/Punkline/punkpc/tree/master/_doc/library_doc.s
[src]: https://github.com/Punkline/punkpc/tree/master/src
[include]: https://github.com/Punkline/punkpc/tree/master/.include
[icommand]: https://sourceware.org/binutils/docs/as/Invoking.html#Invoking
