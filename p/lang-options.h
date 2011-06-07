/*Definitions for switches for Pascal.

  Copyright (C) 1997-2005 Free Software Foundation, Inc.

  Authors: Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA. */

/* This is the contribution to the `lang_options' array in gcc.c for
   gpc. */

#ifndef OPTIONS_ONLY
#include "gcc-version.h"
#ifdef EGCS
DEFINE_LANG_NAME ("Pascal")
#define GPC_OPT(SOURCE, NAME, OPTION, VALUE, DESCRIPTION) { NAME, DESCRIPTION },
#else
#define GPC_OPT(SOURCE, NAME, OPTION, VALUE, DESCRIPTION) NAME,
#endif
#endif

/* Note: If the name of option A is a prefix of the name of option B, A must come *after* B. */
  GPC_OPT (1, "-fdebug-tree", dummy, SEE_CODE,
           "(For GPC developers.) Show the internal representation of a given tree node (name or address)")
  GPC_OPT (1, "-fdebug-gpi", debug_gpi, 1,
           "(For GPC developers.) Show what is written to and read from GPI files (huge output!)")
  GPC_OPT (1, "-fdebug-automake", debug_automake, 1,
           "(For GPC developers.) Give additional information about the actions of automake")
  GPC_OPT (1, "-fdebug-source", debug_source, 1,
           "Output the source while it is being processed to standard error")
  GPC_OPT (1, "-fno-debug-source", debug_source, 0,
           "Do not output the source while it is being processed (default)")
  GPC_OPT (1, "-fdisable-debug-info", dummy, SEE_CODE,
           "Inhibit `-g' options (temporary work-around, this option may disappear in the future)")
  GPC_OPT (0, "-fprogress-messages", dummy, SEE_CODE,
           "Output source file names and line numbers while compiling")
  GPC_OPT (0, "-fno-progress-messages", dummy, SEE_CODE,
           "Do not output source file names and line numbers while compiling (default)")
  GPC_OPT (0, "-fprogress-bar", dummy, SEE_CODE,
           "Output number of processed lines while compiling")
  GPC_OPT (0, "-fno-progress-bar", dummy, SEE_CODE,
           "Do not output number of processed lines while compiling (default)")
  GPC_OPT (0, "-fautomake-gpc", dummy, SEE_CODE,
           "Set the Pascal compiler invoked by automake")
  GPC_OPT (0, "-fautomake-gcc", dummy, SEE_CODE,
           "Set the C compiler invoked by automake")
  GPC_OPT (0, "-fautomake-g++", dummy, SEE_CODE,
           "Set the C++ compiler invoked by automake")
  GPC_OPT (0, "-famtmpfile", dummy, SEE_CODE,
           "(Internal switch used for automake)")
  GPC_OPT (0, "-fautolink", automake_level, 1,
           "Automatically link object files provided by units/modules or `{$L ...}' (default)")
  GPC_OPT (0, "-fno-autolink", automake_level, 0,
           "Do not automatically link object files provided by units/modules/`{$L ...}'")
  GPC_OPT (0, "-fautomake", automake_level, 2,
           "Automatically compile changed units/modules/`{$L ...}' files and link the object files provided")
  GPC_OPT (0, "-fno-automake", automake_level, 0,
           "Same as `--no-autolink'")
  GPC_OPT (0, "-fautobuild", automake_level, 3,
           "Automatically compile all units/modules/`{$L ...}' files and link the object files provided")
  GPC_OPT (0, "-fno-autobuild", automake_level, 0,
           "Same as `--no-autolink'")
  GPC_OPT (1, "-fmaximum-field-alignment", dummy, SEE_CODE,
           "Set the maximum field alignment in bits if `pack-struct' is in effect")
  GPC_OPT (1, "-fignore-packed", ignore_packed, 1,
           "Ignore `packed' in the source code (default in `--borland-pascal')")
  GPC_OPT (1, "-fno-ignore-packed", ignore_packed, 0,
           "Do not ignore `packed' in the source code (default)")
  GPC_OPT (1, "-fignore-garbage-after-dot", ignore_garbage_after_dot, 1,
           "Ignore anything after the terminating `.' (default in `--borland-pascal')")
  GPC_OPT (1, "-fno-ignore-garbage-after-dot", ignore_garbage_after_dot, 0,
           "Complain about anything after the terminating `.' (default)")
  GPC_OPT (1, "-fextended-syntax", dummy, SEE_CODE,
           "same as `--ignore-function-results --pointer-arithmetic --cstrings-as-strings -Wno-absolute' (same as `{$X+}')")
  GPC_OPT (1, "-fno-extended-syntax", dummy, SEE_CODE,
           "Opposite of `--extended-syntax' (same as `{$X-}')")
  GPC_OPT (1, "-fignore-function-results", ignore_function_results, 1,
           "Do not complain when a function is called like a procedure")
  GPC_OPT (1, "-fno-ignore-function-results", ignore_function_results, 0,
           "Complain when a function is called like a procedure (default)")
  GPC_OPT (1, "-fpointer-arithmetic", pointer_arithmetic, 1,
           "Enable pointer arithmetic")
  GPC_OPT (1, "-fno-pointer-arithmetic", pointer_arithmetic, 0,
           "Disable pointer arithmetic (default)")
  GPC_OPT (1, "-fcstrings-as-strings", cstrings_as_strings, 1,
           "Treat CStrings as strings")
  GPC_OPT (1, "-fno-cstrings-as-strings", cstrings_as_strings, 0,
           "Do not treat CStrings as strings (default)")
  GPC_OPT (1, "-Wabsolute", warn_absolute, 1,
           "Warn about variables at absolute adresses and `absolute' variable with non-constant addresses (default)")
  GPC_OPT (1, "-Wno-absolute", warn_absolute, 0,
           "Do not warn about variables at absolute adresses and `absolute' variable with non-constant addresses")
  GPC_OPT (1, "-fshort-circuit", short_circuit, 1,
           "Guarantee short-circuit Boolean evaluation (default; same as `{$B-}')")
  GPC_OPT (1, "-fno-short-circuit", short_circuit, 0,
           "Do not guarantee short-circuit Boolean evaluation (same as `{$B+}')")
  GPC_OPT (1, "-fmixed-comments", mixed_comments, 1,
           "Allow comments like `{ ... *)' as required in ISO Pascal (default in ISO 7185/10206 Pascal mode)")
  GPC_OPT (1, "-fno-mixed-comments", mixed_comments, 0,
           "Ignore `{' and `}' within `(* ... *)' comments and vice versa (default)")
  GPC_OPT (1, "-fnested-comments", nested_comments, 1,
           "Allow nested comments like `{ { } }' and `(* (* *) *)'")
  GPC_OPT (1, "-fno-nested-comments", nested_comments, 0,
           "Do not allow nested comments (default)")
  GPC_OPT (1, "-fdelphi-comments", delphi_comments, 1,
           "Allow Delphi style `//' comments (default)")
  GPC_OPT (1, "-fno-delphi-comments", delphi_comments, 0,
           "Do not allow Delphi style `//' comments")
  GPC_OPT (1, "-fmacros", dummy, SEE_CODE,
           "Expand macros (default)")
  GPC_OPT (1, "-fno-macros", dummy, SEE_CODE,
           "Do not expand macros (default with `--ucsd-pascal', `--borland-pascal' or `--delphi')")
  GPC_OPT (1, "-ftruncate-strings", truncate_strings, 1,
           "Truncate strings being assigned to other strings of too short capacity")
  GPC_OPT (1, "-fno-truncate-strings", truncate_strings, 0,
           "Treat string assignments to other strings of too short capacity as errors")
  GPC_OPT (1, "-fexact-compare-strings", exact_compare_strings, 1,
           "Do not blank-pad strings for comparisons")
  GPC_OPT (1, "-fno-exact-compare-strings", exact_compare_strings, 0,
           "Blank-pad strings for comparisons")
  GPC_OPT (1, "-fdouble-quoted-strings", double_quoted_strings, 1,
           "Allow strings enclosed in \"\" (default)")
  GPC_OPT (1, "-fno-double-quoted-strings", double_quoted_strings, 0,
           "Do not allow strings enclosed in \"\" (default with dialect other than `--mac-pascal')")
  GPC_OPT (1, "-flongjmp-all-nonlocal-labels", longjmp_all_nonlocal_labels, 1,
           "Use `longjmp' for all nonlocal labels (default for Darwin/PPC)")
  GPC_OPT (1, "-fno-longjmp-all-nonlocal-labels", longjmp_all_nonlocal_labels, 0,
           "Use `longjmp' only for nonlocal labels in the main program (default except for Darwin/PPC)")
  GPC_OPT (1, "-fiso-goto-restrictions", iso_goto_restrictions, 1,
           "Do not allow jumps into structured instructions (default)")
  GPC_OPT (1, "-fno-iso-goto-restrictions", iso_goto_restrictions, 0,
           "Allow jumps into structured instructions (default in `--borland-pascal')")
  GPC_OPT (1, "-fnonlocal-exit", nonlocal_exit, 1,
           "Allow non-local `Exit' statements (default in `--ucsd-pascal' and `--mac-pascal')")
  GPC_OPT (1, "-fno-nonlocal-exit", nonlocal_exit, 0,
           "Do not allow non-local `Exit' statements (default)")
  GPC_OPT (1, "-fio-checking", io_checking, 1,
           "Check I/O operations automatically (same as `{$I+}') (default)")
  GPC_OPT (1, "-fno-io-checking", io_checking, 0,
           "Do not check I/O operations automatically (same as `{$I-}')")
  GPC_OPT (1, "-fpointer-checking-user-defined", pointer_checking_user_defined, 1,
           "Use user-defined procedure for validating pointers")
  GPC_OPT (1, "-fno-pointer-checking-user-defined", pointer_checking_user_defined, 0,
           "Do not use user-defined procedure for validating pointers (default)")
  GPC_OPT (1, "-fpointer-checking", pointer_checking, 1,
           "Validate pointers before dereferencing")
  GPC_OPT (1, "-fno-pointer-checking", pointer_checking, 0,
           "Do not validate pointers before dereferencing (default)")
  GPC_OPT (1, "-fobject-checking", object_checking, 1,
           "Check for valid objects on virtual method calls (default)")
  GPC_OPT (1, "-fno-object-checking", object_checking, 0,
           "Do not check for valid objects on virtual method calls")
  GPC_OPT (1, "-frange-checking", range_checking, 1,
           "Do automatic range checks') (default)")
  GPC_OPT (1, "-fno-range-checking", range_checking, 0,
           "Do not do automatic range checks (same as `{$R-}')")
  GPC_OPT (1, "-frange-and-object-checking", dummy, SEE_CODE,
           "Same as `--range-checking --object-checking', same as `{$R+}'")
  GPC_OPT (1, "-fno-range-and-object-checking", dummy, SEE_CODE,
           "Same as `--no-range-checking --no-object-checking', same as `{$R-}'")
  GPC_OPT (1, "-fcase-value-checking", case_value_checking, 1,
           "Cause a runtime error if a `case' matches no branch (default in ISO Pascal modes)")
  GPC_OPT (1, "-fno-case-value-checking", case_value_checking, 0,
           "Do not cause a runtime error if a `case' matches no branch (default)")
  GPC_OPT (1, "-fstack-checking", dummy, SEE_CODE,
           "Enable stack checking (same as `{$S+}')")
  GPC_OPT (1, "-fno-stack-checking", dummy, SEE_CODE,
           "Disable stack checking (same as `{$S-} (default)')")
  GPC_OPT (1, "-fread-base-specifier", read_base_specifier, 1,
           "In read statements, allow input base specifier `n#' (default)")
  GPC_OPT (1, "-fno-read-base-specifier", read_base_specifier, 0,
           "In read statements, do not allow input base specifier `n#' (default in ISO 7185 Pascal)")
  GPC_OPT (1, "-fread-hex", read_hex, 1,
           "In read statements, allow hexadecimal input with `$' (default)")
  GPC_OPT (1, "-fno-read-hex", read_hex, 0,
           "In read statements, do not allow hexadecimal input with `$' (default in ISO 7185 Pascal)")
  GPC_OPT (1, "-fread-white-space", read_white_space, 1,
           "In read statements, require whitespace after numbers")
  GPC_OPT (1, "-fno-read-white-space", read_white_space, 0,
           "In read statements, do not require whitespace after numbers (default)")
  GPC_OPT (1, "-fwrite-clip-strings", write_clip_strings, 1,
           "In write statements, truncate strings exceeding their field width (`Write (SomeLongString : 3)')")
  GPC_OPT (1, "-fno-write-clip-strings", write_clip_strings, 0,
           "Do not truncate strings exceeding their field width")
  GPC_OPT (1, "-fwrite-real-blank", real_blank, 1,
           "Output a blank in front of positive reals in exponential form (default)")
  GPC_OPT (1, "-fno-write-real-blank", real_blank, 0,
           "Do not output a blank in front of positive reals in exponential form")
  GPC_OPT (1, "-fwrite-capital-exponent", capital_exponent, 1,
           "Write real exponents with a capital `E'")
  GPC_OPT (1, "-fno-write-capital-exponent", capital_exponent, 0,
           "Write real exponents with a lowercase `e'")
  GPC_OPT (1, "-ftransparent-file-names", transparent_file_names, 1,
           "Derive external file names from variable names")
  GPC_OPT (1, "-fno-transparent-file-names", transparent_file_names, 0,
           "Do not derive external file names from variable names (default)")
  GPC_OPT (1, "-ffield-widths", dummy, SEE_CODE,
           "Optional colon-separated list of default field widths for Integer, Real, Boolean, LongInt, LongReal")
  GPC_OPT (1, "-fno-field-widths", dummy, SEE_CODE,
           "Reset the default field widths")
  GPC_OPT (1, "-fpedantic", dummy, SEE_CODE,
           "Reject everything not allowed in some dialect, e.g. redefinition of its keywords")
  GPC_OPT (1, "-fno-pedantic", dummy, SEE_CODE,
           "Don't give pedantic warnings")
  GPC_OPT (1, "-ftyped-address", typed_address, 1,
           "Make the result of the address operator typed (same as `{$T+}', default)")
  GPC_OPT (1, "-fno-typed-address", typed_address, 0,
           "Make the result of the address operator an untyped pointer (same as `{$T-}')")
  GPC_OPT (1, "-fenable-keyword", dummy, SEE_CODE,
           "Enable a keyword, independently of dialect defaults")
  GPC_OPT (1, "-fdisable-keyword", dummy, SEE_CODE,
           "Disable a keyword, independently of dialect defaults")
  GPC_OPT (1, "-fimplicit-result", implicit_result, 1,
           "Enable implicit `Result' for functions (default only in `--delphi')")
  GPC_OPT (1, "-fno-implicit-result", implicit_result, 0,
           "Disable implicit `Result' for functions")
  GPC_OPT (1, "-fenable-predefined-identifier", dummy, SEE_CODE,
           "Enable a predefined identifier, independently of dialect defaults")
  GPC_OPT (1, "-fdisable-predefined-identifier", dummy, SEE_CODE,
           "Disable a predefined identifier, independently of dialect defaults")
  GPC_OPT (1, "-fassertions", assertions, 1,
           "Enable assertion checking (default)")
  GPC_OPT (1, "-fno-assertions", assertions, 0,
           "Disable assertion checking")
  GPC_OPT (1, "-fsetlimit", dummy, SEE_CODE,
           "Define the range for `set of Integer' etc.")
  GPC_OPT (1, "-fgpc-main", dummy, SEE_CODE,
           "External name for the program's entry point (default: `main')")
  GPC_OPT (1, "-fpropagate-units", propagate_units, 1,
           "Automatically re-export all imported declarations")
  GPC_OPT (1, "-fno-propagate-units", propagate_units, 0,
           "Do not automatically re-export all imported declarations")
  GPC_OPT (0, "-finterface-only", interface_only, 1,
           "Compile only the interface part of a unit/module and exit (creates `.gpi' file, no `.o' file")
  GPC_OPT (0, "-fimplementation-only", dummy, SEE_CODE,
           "Do not produce a GPI file; only compile the implementation part")
  GPC_OPT (0, "-fexecutable-file-name", dummy, SEE_CODE,
           "Name for the output file, if specified; otherwise derive from main source file name")
  GPC_OPT (0, "-funit-path", dummy, SEE_CODE,
           "Directories where to look for unit/module sources")
  GPC_OPT (0, "-fno-unit-path", dummy, SEE_CODE,
           "Forget about directories where to look for unit/module sources")
  GPC_OPT (0, "-fobject-path", dummy, SEE_CODE,
           "Directories where to look for additional object (and source) files")
  GPC_OPT (0, "-fno-object-path", dummy, SEE_CODE,
           "Forget about directories where to look for additional object (and source) files")
  GPC_OPT (0, "-fexecutable-path", dummy, SEE_CODE,
           "Path where to create the executable file")
  GPC_OPT (0, "-fno-executable-path", dummy, SEE_CODE,
           "Create the executable file in the directory where the main source is (default)")
  GPC_OPT (0, "-funit-destination-path", dummy, SEE_CODE,
           "Path where to create object and GPI files of Pascal units")
  GPC_OPT (0, "-fno-unit-destination-path", dummy, SEE_CODE,
           "Create object and GPI files of Pascal units in the current directory (default)")
  GPC_OPT (0, "-fobject-destination-path", dummy, SEE_CODE,
           "Path where to create additional object files (e.g. of C files, not Pascal units)")
  GPC_OPT (0, "-fno-object-destination-path", dummy, SEE_CODE,
           "Create additional object files (e.g. of C files, not Pascal units) in the current directory (default)")
  GPC_OPT (0, "-fdisable-default-paths", dummy, SEE_CODE,
           "Do not add a default path to the unit and object path")
  GPC_OPT (0, "-fgpi-destination-path", dummy, SEE_CODE,
           "(Internal switch used for automake)")
  GPC_OPT (0, "-fuses", dummy, SEE_CODE,
           "Add an implicit `uses' clause")
  GPC_OPT (1, "-finit-modules", dummy, SEE_CODE,
           "Initialize the named modules in addition to those imported regularly; kind of a kludge")
  GPC_OPT (0, "-fcidefine", dummy, SEE_CODE, /* handled specially by the preprocessor when in the source */
           "Define a case-insensitive macro")
  GPC_OPT (0, "-fcsdefine", dummy, SEE_CODE, /* handled specially by the preprocessor when in the source */
           "Define a case-sensitive macro")
  GPC_OPT (0, "-fbig-endian", option_big_endian, 1,
           "Tell GPC that the system is big-endian (for those targets where it can vary)")
  GPC_OPT (0, "-flittle-endian", option_big_endian, 0,
           "Tell GPC that the system is little-endian (for those targets where it can vary)")
  GPC_OPT (0, "-fprint-needed-options", print_needed_options, 1,
           "Print the needed options")
  GPC_OPT (1, "-Wwarnings", dummy, SEE_CODE,
           "Enable warnings (same as `{$W+}')")
  GPC_OPT (1, "-Wno-warnings", dummy, SEE_CODE,
           "Disable all warnings (same as `{$W-}')")
  GPC_OPT (1, "-Widentifier-case-local", warn_id_case, 1,
           "Warn about an identifier written with varying case within one program/module/unit")
  GPC_OPT (1, "-Wno-identifier-case-local", warn_id_case, 0,
           "Same as `-Wno-identifier-case'")
  GPC_OPT (1, "-Widentifier-case", warn_id_case, 2,
           "Warn about an identifier written with varying case")
  GPC_OPT (1, "-Wno-identifier-case", warn_id_case, 0,
           "Do not warn about an identifier written with varying case (default)")
  GPC_OPT (1, "-Winterface-file-name", warn_interface_file_name, 1,
           "Warn when a unit/module interface differs from the file name")
  GPC_OPT (1, "-Wno-interface-file-name", warn_interface_file_name, 0,
           "Do not warn when a unit/module interface differs from the file name (default)")
  GPC_OPT (1, "-fmethods-always-virtual", methods_always_virtual, 1,
           "Make all methods virtual (default in `--mac-pascal')")
  GPC_OPT (1, "-fno-methods-always-virtual", methods_always_virtual, 0,
           "Do not make all methods virtual (default)")
  GPC_OPT (1, "-fobjects-are-references", objects_are_references, 1,
           "Turn objects into references (default in `--mac-pascal')")
  GPC_OPT (1, "-fno-objects-are-references", objects_are_references, 0,
           "Do not turn objects into references (default)")
  GPC_OPT (1, "-fobjects-require-override", objects_require_override, 1,
           "Require override directive for objects (default in `--mac-pascal')")
  GPC_OPT (1, "-fno-objects-require-override", objects_require_override, 0,
           "Do not require override directive for objects (default)")
  GPC_OPT (1, "-fdelphi-method-shadowing", delphi_method_shadowing, 1,
           "Redefining methods silently shadows old definition (default in `--delphi')")
  GPC_OPT (1, "-fno-delphi-method-shadowing", delphi_method_shadowing, 0,
           "Do not silently shadow method definitions (default)")
  GPC_OPT (1, "-fborland-objects", dummy, SEE_CODE,
           "Choose Borland object model")
  GPC_OPT (1, "-fmac-objects", dummy, SEE_CODE,
           "Choose Mac object model")
  GPC_OPT (1, "-fooe-objects", dummy, SEE_CODE,
           "Choose OOE object model")
  GPC_OPT (1, "-fgnu-objects", dummy, SEE_CODE,
           "Reset object model to default state")
  GPC_OPT (0, "-fpreprocessed", preprocessed, 1,
             "Treat the input file as already preprocessed")
  GPC_OPT (0, "-nostdinc", dummy, SEE_CODE, "Do not search standard system"
     " include directories (those specified with -isystem will still be used)")
  GPC_OPT (0, "-remap", dummy, SEE_CODE,
             "Remap file names when including files")
  GPC_OPT (0, "-v", dummy, SEE_CODE, "Enable verbose output")
  GPC_OPT (0, "-A", dummy, SEE_CODE, "Ignored")
  GPC_OPT (0, "-D", dummy, SEE_CODE, "Define a macro symbol")
  GPC_OPT (0, "-E", preprocess_only, 1, "Preprocess only")
  GPC_OPT (0, "-H", dummy, SEE_CODE,
             "Print the name of include files as they are used")
  GPC_OPT (0, "-M", dummy, SEE_CODE, "Generate make dependencies")
  GPC_OPT (0, "-P", dummy, SEE_CODE, "Do not generate #line directives")
  GPC_OPT (1, "-Wimplicit-abstract", warn_implicit_abstract, 1,
           "Warn when an object type not declared `abstract' contains an abstract method (default)")
  GPC_OPT (1, "-Wno-implicit-abstract", warn_implicit_abstract, 0,
           "Do not warn when an object type not `declared' abstract contains an abstract method")
  GPC_OPT (1, "-Winherited-abstract", warn_inherited_abstract, 1,
           "Warn when an abstract object type inherits from a non-abstract one (default)")
  GPC_OPT (1, "-Wno-inherited-abstract", warn_inherited_abstract, 0,
           "Do not warn when an abstract object type inherits from a non-abstract one")
  GPC_OPT (1, "-Wobject-assignment", warn_object_assignment, 1,
           "Warn when when assigning objects or declaring them as value parameters or function results (default)")
  GPC_OPT (1, "-Wno-object-assignment", warn_object_assignment, 0,
           "Do not warn when assigning objects or declaring them as value parameters or function results (default in `--borland-pascal')")
  GPC_OPT (1, "-Wimplicit-io", warn_implicit_io, 1,
           "Warn when `Input' or `Output' are used implicitly")
  GPC_OPT (1, "-Wno-implicit-io", warn_implicit_io, 0,
           "Do not warn when `Input' or `Output' are used implicitly (default)")
/* gcc-3.x supports the following two options already. Listing them here
   would prevent automake from passing them to C compiler invocations. */
#ifndef EGCS97
  GPC_OPT (1, "-Wfloat-equal", dummy, SEE_CODE,
           "Warn about `=' and `<>' comparisons of real numbers")
  GPC_OPT (1, "-Wno-float-equal", dummy, SEE_CODE,
           "Do not warn about `=' and `<>' comparisons of real numbers")
#endif
  GPC_OPT (1, "-Wtyped-const", warn_typed_const, 1,
           "Warn about misuse of typed constants as initialized variables (default)")
  GPC_OPT (1, "-Wno-typed-const", warn_typed_const, 0,
           "Do not warn about misuse of typed constants as initialized variables")
  GPC_OPT (1, "-Wnear-far", warn_near_far, 1,
           "Warn about use of useless `near' or `far' directives (default)")
  GPC_OPT (1, "-Wno-near-far", warn_near_far, 0,
           "Do not warn about use of useless `near' or `far' directives")
  GPC_OPT (1, "-Wunderscore", warn_underscore, 1,
           "Warn about double/leading/trailing underscores in identifiers")
  GPC_OPT (1, "-Wno-underscore", warn_underscore, 0,
           "Do not warn about double/leading/trailing underscores in identifiers")
  GPC_OPT (1, "-Wsemicolon", warn_semicolon, 1,
           "Warn about a semicolon after `then', `else' or `do' (default)")
  GPC_OPT (1, "-Wno-semicolon", warn_semicolon, 0,
           "Do not warn about a semicolon after `then', `else' or `do'")
  GPC_OPT (1, "-Wlocal-external", warn_local_external, 1,
           "Warn about local `external' declarations")
  GPC_OPT (1, "-Wno-local-external", warn_local_external, 0,
           "Do not warn about local `external' declarations")
  GPC_OPT (1, "-Wdynamic-arrays", warn_dynamic_arrays, 1,
           "Warn about arrays whose size is determined at run time (including array slices)")
  GPC_OPT (1, "-Wno-dynamic-arrays", warn_dynamic_arrays, 0,
           "Do not warn about arrays whose size is determined at run time (including array slices)")
  GPC_OPT (1, "-Wmixed-comments", warn_mixed_comments, 1,
           "Warn about mixed comments like `{ ... *)'")
  GPC_OPT (1, "-Wno-mixed-comments", warn_mixed_comments, 0,
           "Do not warn about mixed comments")
  GPC_OPT (1, "-Wnested-comments", warn_nested_comments, 1,
           "Warn about nested comments like `{ { } }'")
  GPC_OPT (1, "-Wno-nested-comments", warn_nested_comments, 0,
           "Do not warn about nested comments")
  GPC_OPT (1, "-fclassic-pascal-level-0", pascal_dialect, CLASSIC_PASCAL_LEVEL_0,
           "Reject conformant arrays and anything besides ISO 7185 Pascal")
  GPC_OPT (1, "-fstandard-pascal-level-0", pascal_dialect, CLASSIC_PASCAL_LEVEL_0,
           "Synonym for `--classic-pascal-level-0'")
  GPC_OPT (1, "-fclassic-pascal", pascal_dialect, CLASSIC_PASCAL_LEVEL_1,
           "Reject anything besides ISO 7185 Pascal")
  GPC_OPT (1, "-fstandard-pascal", pascal_dialect, CLASSIC_PASCAL_LEVEL_1,
           "Synonym for `--classic-pascal'")
  GPC_OPT (1, "-fextended-pascal", pascal_dialect, EXTENDED_PASCAL,
           "Reject anything besides ISO 10206 Extended Pascal")
  GPC_OPT (1, "-fobject-pascal", pascal_dialect, OBJECT_PASCAL,
           "Reject anything besides (the implemented parts of) ANSI draft Object Pascal")
  GPC_OPT (1, "-fucsd-pascal", pascal_dialect, UCSD_PASCAL,
           "Try to emulate UCSD Pascal")
  GPC_OPT (1, "-fborland-pascal", pascal_dialect, BORLAND_PASCAL,
           "Try to emulate Borland Pascal, version 7.0")
  GPC_OPT (1, "-fdelphi", pascal_dialect, BORLAND_DELPHI,
           "Try to emulate Borland Pascal, version 7.0, with some Delphi extensions")
  GPC_OPT (1, "-fpascal-sc", pascal_dialect, PASCAL_SC,
           "Be strict about the implemented Pascal-SC extensions")
  GPC_OPT (1, "-fvax-pascal", pascal_dialect, VAX_PASCAL,
           "Support (a few features of) VAX Pascal")
  GPC_OPT (1, "-fsun-pascal", pascal_dialect, SUN_PASCAL,
           "Support (a few features of) Sun Pascal")
  GPC_OPT (1, "-fmac-pascal", pascal_dialect, MAC_PASCAL,
           "Support (some features of) traditional Macintosh Pascal compilers")
  GPC_OPT (1, "-fgnu-pascal", pascal_dialect, 0,
            "Undo the effect of previous dialect options, allow all features again")
