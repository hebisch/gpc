/*Declarations for the GNU Back End as used from GNU Pascal

  Copyright (C) 1997-2005 Free Software Foundation, Inc.

  Authors: Jan-Jaap van der Heijden <j.j.vanderheijden@student.utwente.nl>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3, or (at your option)
  any later version.

  GNU Pascal is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to
  the Free Software Foundation, 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA. */

/* Allow for multiple inclusion. */
#ifndef _GBE_H_
#define _GBE_H_

/* Find out which version of the GBE we are using. */
#include "gcc-version.h"

/* The GNU Back End (GBE).

   Up to gcc-2.8.x, there were no real header files for the GBE.
   With EGCS (gcc-2.95.x), one has started to write them.
   With EGCS97 (gcc-2.97.x), they are essentially complete.
   In the meantime, the GBE itself has changed substantially
   (for instance obstacks have been dropped with EGCS97).

   In order to make GPC work with all those versions of the GBE,
   we have to use all those `#ifdef's below and everywhere. */

#include "config.h"

#ifndef GCC_4_0
#define TYPE_UNSIGNED TREE_UNSIGNED
#define BIT_FIELD_REF_UNSIGNED TREE_UNSIGNED
#endif

#ifdef GCC_4_0
extern int immediate_size_expand;
#endif

#ifndef GCC_3_4
#define build_constructor(type, elements) (build (CONSTRUCTOR, (type), NULL_TREE, (elements)))
#endif

#ifndef EGCS97

#ifndef EGCS  /* gcc-2.8.1 doesn't check for it. Let's just assume it's there. */
#define HAVE_SYS_STAT_H 1
#endif

#define ARRAY_SIZE(a) (sizeof (a) / sizeof ((a)[0]))

#ifdef PROMOTE_PROTOTYPES
#undef PROMOTE_PROTOTYPES
#define PROMOTE_PROTOTYPES 1
#else
#define PROMOTE_PROTOTYPES 0
#endif

/* By default, colon separates directories in a path.  */
#ifndef PATH_SEPARATOR
#define PATH_SEPARATOR ':'
#endif

#ifndef DIR_SEPARATOR
#define DIR_SEPARATOR '/'
#endif

/* Define IS_DIR_SEPARATOR. */
#ifndef IS_DIR_SEPARATOR
#ifndef DIR_SEPARATOR_2
#define IS_DIR_SEPARATOR(ch) (((ch) == '/') || ((ch) == DIR_SEPARATOR))
#else
#define IS_DIR_SEPARATOR(ch) \
  (((ch) == '/') || ((ch) == DIR_SEPARATOR) || ((ch) == DIR_SEPARATOR_2))
#endif
#endif

#define TOLOWER(x) (tolower ((int) (x)))
#define TOUPPER(x) (toupper ((int) (x)))

#if defined (__STDC__) || defined (ALMOST_STDC)
#define CONCAT2(a,b) a##b
#define STRINGX(s) #s
#else
#define CONCAT2(a,b) a/**/b
#define STRINGX(s) "s"
#endif

#include "obstack.h"
#include "gansidecl.h"

extern unsigned long concat_length (const char *, ...);
extern char *concat_copy2 (const char *, ...);
extern char *libiberty_concat_ptr;
#define ACONCAT(ACONCAT_PARAMS) \
  (libiberty_concat_ptr = alloca (concat_length ACONCAT_PARAMS + 1), \
   concat_copy2 ACONCAT_PARAMS)

#endif

#include "system.h"
#ifdef GCC_3_4
#define CONCAT2(a,b) a##b
#define STRINGX(s) #s
#define lineno input_line
#define warning_with_decl(x, y) (gpc_warning ("%H" y, &DECL_SOURCE_LOCATION (x), \
        DECL_NAME (x) ? IDENTIFIER_POINTER (DECL_NAME (x)) : NULL))
#define error_with_decl(x, y) (error ("%H" y, &DECL_SOURCE_LOCATION (x), \
        DECL_NAME (x) ? IDENTIFIER_POINTER (DECL_NAME (x)) : NULL))
#include "coretypes.h"
#include "tm.h"
#endif
#include <signal.h>
#include "tree.h"
#ifdef EGCS97
#include "debug.h"
#include "errors.h"
#include "target.h"
#include "diagnostic.h"
#include "ggc.h"
#include "intl.h"
#ifdef GCC_3_3
#include "real.h"
#endif
#endif
#include "input.h"
#include "rtl.h"
#include "flags.h"
#include "output.h"
#include "expr.h"
#include "except.h"
#include "function.h"
#include "convert.h"
#include "toplev.h"

/* Missing in toplev.h */
extern int save_argc;
extern char **save_argv;
#ifdef EGCS97
#ifndef GCC_3_4
extern struct function *outer_function_chain;
#endif
#else
extern char *version_string;
extern char *progname;  /* in cpplib.h, but we don't need to include it just for that */
extern struct obstack permanent_obstack;
extern struct obstack *current_obstack;
extern int errorcount;
extern int sorrycount;
extern void (*print_error_function) (const char *);
extern PTR alloca (size_t);
extern tree void_list_node;
#endif

#ifndef GCC_3_3
#define copy_decl_lang_specific copy_lang_decl
#endif

#ifdef EGCS

#include "dbxout.h"
#include "libiberty.h"

#else

extern char *concat (const char *, ...);
extern void *xmalloc (size_t);
extern void *xrealloc (void *, size_t);
extern void debug_tree (tree node);
extern void emit_nop (void);
extern rtx label_rtx (tree);
extern char **save_argv;
extern int version_flag;
extern void pedwarn (const char *, ...);
extern void warning (const char *, ...);
extern void error (const char *, ...);
extern void error_with_decl (tree, const char *, ...);
extern void rest_of_decl_compilation (tree, const char *, int, int);
extern void warning_with_file_and_line (const char *, int, char *, ...);
extern int pedantic;
extern int int_fits_type_p (tree, tree);
extern int really_constant_p (tree);
extern void pop_momentary_nofree (void);

/* GCC files not really part of the GBE. */
#define PEXECUTE_FIRST   1
#define PEXECUTE_LAST    2
#define PEXECUTE_SEARCH  4
#define PEXECUTE_VERBOSE 8
extern int pwait (int, int *, int);
extern int pexecute (const char *, char * const *, const char *,
                     const char *, char **, char **, int);
extern char *choose_temp_base (void);

#ifdef __EMX__
# include <process.h>
#endif

extern void *alloca (size_t);

#endif /* not EGCS */

#endif /* _GBE_H_ */
