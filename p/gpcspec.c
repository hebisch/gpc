/*Specific flags and argument handling of the Pascal front-end.
  @@ This file will take the place of gpc.c once automake is removed.

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

  Author: Peter Gerwinski <peter@gerwinski.de>

  This file is derived from GNU Fortran's `g77spec.c'.

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

/* This file is a copy of GNU Fortran's `g77spec.c', modified for
   Pascal. It contains a filter for the main `gcc' driver, which is
   replicated for the `gpc' driver by adding this filter. The purpose
   of this filter is to be basically identical to gcc (in that
   it faithfully passes all of the original arguments to gcc) but,
   unless explicitly overridden by the user in certain ways, ensure
   that the needs of the language supported by this wrapper are met.

   For GNU Pascal (gpc), we do the following to the argument list
   before passing it to `gcc':

   1. Make sure `-lgpc -lm' is at the end of the list.

   2. Make sure each time `-lgpc' or `-lm' is seen, it forms
      part of the series `-lgpc -lm'.

   #1 and #2 are not done if `-nostdlib' or any option that disables
   the linking phase is present, or if `-xfoo' is in effect. Note that
   a lack of source files or -l options disables linking.

   This program was originally made out of gcc/cp/g++spec.c, but the
   way it builds the new argument list was rewritten so it is much
   easier to maintain, improve the way it decides to add or not add
   extra arguments, etc. And several improvements were made by the
   Fortran people in the handling of arguments, primarily to make it
   more consistent with `gcc' itself. */

#include "config.h"
#include "system.h"
#include "p/version.h"

#ifndef MATH_LIBRARY
#define MATH_LIBRARY "-lm"
#endif

#ifndef PASCAL_LIBRARY
#define PASCAL_LIBRARY "-lgpc"
#endif

/* Options this driver needs to recognize, not just know how to
   skip over. */
typedef enum
{
  OPTION_b,                     /* Aka --prefix. */
  OPTION_B,                     /* Aka --target. */
  OPTION_c,                     /* Aka --compile. */
  OPTION_E,                     /* Aka --preprocess. */
  OPTION_help,                  /* --help. */
  OPTION_i,                     /* -imacros, -include, -include-*. */
  OPTION_l,
  OPTION_L,                     /* Aka --library-directory. */
  OPTION_M,                     /* Aka --dependencies. */
  OPTION_MM,                    /* Aka --user-dependencies. */
  OPTION_nostdlib,              /* Aka --no-standard-libraries, or
                                   -nodefaultlibs. */
  OPTION_o,                     /* Aka --output. */
  OPTION_S,                     /* Aka --assemble. */
  OPTION_syntax_only,           /* -fsyntax-only. */
  OPTION_v,                     /* Aka --verbose. */
  OPTION_version,               /* --version. */
  OPTION_V,                     /* Aka --use-version. */
  OPTION_x,                     /* Aka --language. */
  OPTION_                       /* Unrecognized or unimportant. */
} Option;

/* The original argument list and related info is copied here. */
static int gpc_xargc;
static char **gpc_xargv;
static void (*gpc_fn) ();

/* The new argument list will be built here. */
static int gpc_newargc;
static char **gpc_newargv;

extern char *version_string;

/* --- This comes from gcc.c (2.8.1) verbatim: */

/* This defines which switch letters take arguments. */

#define DEFAULT_SWITCH_TAKES_ARG(CHAR)      \
  ((CHAR) == 'D' || (CHAR) == 'U' || (CHAR) == 'o' \
   || (CHAR) == 'e' || (CHAR) == 'T' || (CHAR) == 'u' \
   || (CHAR) == 'I' || (CHAR) == 'm' || (CHAR) == 'x' \
   || (CHAR) == 'L' || (CHAR) == 'A')

#ifndef SWITCH_TAKES_ARG
#define SWITCH_TAKES_ARG(CHAR) DEFAULT_SWITCH_TAKES_ARG(CHAR)
#endif

/* This defines which multi-letter switches take arguments. */

#define DEFAULT_WORD_SWITCH_TAKES_ARG(STR)              \
 (!strcmp (STR, "Tdata") || !strcmp (STR, "Ttext")      \
  || !strcmp (STR, "Tbss") || !strcmp (STR, "include")  \
  || !strcmp (STR, "imacros") || !strcmp (STR, "aux-info") \
  || !strcmp (STR, "idirafter") || !strcmp (STR, "iprefix") \
  || !strcmp (STR, "iwithprefix") || !strcmp (STR, "iwithprefixbefore") \
  || !strcmp (STR, "isystem") || !strcmp (STR, "specs"))

#ifndef WORD_SWITCH_TAKES_ARG
#define WORD_SWITCH_TAKES_ARG(STR) DEFAULT_WORD_SWITCH_TAKES_ARG (STR)
#endif

/* --- End of verbatim. */

/* Assumes text[0] == '-'. Returns number of argv items that belong to
   (and follow) this one, an option id for options important to the
   caller, and a pointer to the first char of the arg, if embedded (else
   returns NULL, meaning no arg or it's the next argv).

   Note that this also assumes gcc.c's pass converting long options
   to short ones, where available, has already been run. */

static void
lookup_option (Option *xopt, int *xskip, char **xarg, char *text)
{
  Option opt = OPTION_;
  int skip;
  char *arg = NULL;

  if ((skip = SWITCH_TAKES_ARG (text[1])))
    skip -= (text[2] != '\0');  /* See gcc.c. */

  if (text[1] == 'B')
    opt = OPTION_B, skip = (text[2] == '\0'), arg = text + 2;
  else if (text[1] == 'b')
    opt = OPTION_b, skip = (text[2] == '\0'), arg = text + 2;
  else if ((text[1] == 'c') && (text[2] == '\0'))
    opt = OPTION_c, skip = 0;
  else if ((text[1] == 'E') && (text[2] == '\0'))
    opt = OPTION_E, skip = 0;
  else if (text[1] == 'i')
    opt = OPTION_i, skip = 0;
  else if (text[1] == 'l')
    opt = OPTION_l;
  else if (text[1] == 'L')
    opt = OPTION_L, arg = text + 2;
  else if (text[1] == 'o')
    opt = OPTION_o;
  else if ((text[1] == 'S') && (text[2] == '\0'))
    opt = OPTION_S, skip = 0;
  else if (text[1] == 'V')
    opt = OPTION_V, skip = (text[2] == '\0');
  else if ((text[1] == 'v') && (text[2] == '\0'))
    opt = OPTION_v, skip = 0;
  else if (text[1] == 'x')
    opt = OPTION_x, arg = text + 2;
  else
    {
      if ((skip = WORD_SWITCH_TAKES_ARG (text + 1)) != 0)  /* See gcc.c. */
        ;
      else if (!strcmp (text, "-fhelp"))  /* Really --help!! */
        opt = OPTION_help;
      else if (!strcmp (text, "-M"))
        opt = OPTION_M;
      else if (!strcmp (text, "-MM"))
        opt = OPTION_MM;
      else if (!strcmp (text, "-nostdlib")
               || !strcmp (text, "-nodefaultlibs"))
        opt = OPTION_nostdlib;
      else if (!strcmp (text, "-fsyntax-only"))
        opt = OPTION_syntax_only;
      else if (!strcmp (text, "-dumpversion"))
        opt = OPTION_version;
      else if (!strcmp (text, "-Xlinker")
               || !strcmp (text, "-specs"))
        skip = 1;
      else
        skip = 0;
    }

  if (xopt != NULL)
    *xopt = opt;
  if (xskip != NULL)
    *xskip = skip;
  if (xarg != NULL)
    {
      if ((arg != NULL)
          && (arg[0] == '\0'))
        *xarg = NULL;
      else
        *xarg = arg;
    }
}

/* Append another argument to the list being built. As long as it is
   identical to the corresponding arg in the original list, just increment
   the new arg count. Otherwise allocate a new list, etc. */

static void
append_arg (char *arg)
{
  static int newargsize;

#if 0
  fprintf (stderr, "`%s'\n", arg);
#endif

  if (gpc_newargv == gpc_xargv
      && gpc_newargc < gpc_xargc
      && (arg == gpc_xargv[gpc_newargc]
          || !strcmp (arg, gpc_xargv[gpc_newargc])))
    {
      ++gpc_newargc;
      return;                   /* Nothing new here. */
    }

  if (gpc_newargv == gpc_xargv)
    {                           /* Make new arglist. */
      int i;

      newargsize = (gpc_xargc << 2) + 20;       /* This should handle all. */
      gpc_newargv = (char **) xmalloc (newargsize * sizeof (char *));

      /* Copy what has been done so far. */
      for (i = 0; i < gpc_newargc; ++i)
        gpc_newargv[i] = gpc_xargv[i];
    }

  if (gpc_newargc == newargsize)
    (*gpc_fn) ("overflowed output arg list for `%s'", arg);

  gpc_newargv[gpc_newargc++] = arg;
}

void
lang_specific_driver (void (*fn) (), int *in_argc, char ***in_argv, int *in_added_libraries)
{
  int argc = *in_argc;
  char **argv = *in_argv;
  int i;
  int verbose = 0;
  Option opt;
  int skip;
  char *arg;

  /* This will be NULL if we encounter a situation where we should not
     link in libf2c. */
  char *library = PASCAL_LIBRARY;

  /* This will become 0 if anything other than -v and kin (like -V)
     is seen, meaning the user is trying to accomplish something.
     If it remains nonzero, and the user wants version info, add stuff to
     the command line to make gcc invoke all the appropriate phases
     to get all the version info. */
  int add_version_magic = 1;

  /* 0 => -xnone in effect.
     1 => -xfoo in effect. */
  int saw_speclang = 0;

  /* 0 => initial/reset state
     1 => last arg was -l<library>
     2 => last two args were -l<library> -lm. */
  int saw_library = 0;

  /* By default, we throw on the math library if we have one. */
  int need_math = (MATH_LIBRARY[0] != '\0');

  /* The number of input and output files in the incoming arg list. */
  int n_infiles = 0;
  int n_outfiles = 0;

#if 0
  fprintf (stderr, "Incoming:");
  for (i = 0; i < argc; i++)
    fprintf (stderr, " %s", argv[i]);
  fprintf (stderr, "\n");
#endif

  gpc_xargc = argc;
  gpc_xargv = argv;
  gpc_newargc = 0;
  gpc_newargv = argv;
  gpc_fn = fn;

  /* First pass through arglist.

     If -nostdlib or a "turn-off-linking" option is anywhere in the
     command line, don't do any library-option processing (except
     relating to -x). Also, if -v is specified, but no other options
     that do anything special (allowing -V version, etc.), remember
     to add special stuff to make gcc command actually invoke all
     the different phases of the compilation process so all the version
     numbers can be seen.

     Also, here is where all problems with missing arguments to options
     are caught. If this loop is exited normally, it means all options
     have the appropriate number of arguments as far as the rest of this
     program is concerned. */

  for (i = 1; i < argc; ++i)
    {
      if ((argv[i][0] == '+') && (argv[i][1] == 'e'))
        {
          add_version_magic = 0;
          continue;
        }

      if ((argv[i][0] != '-') || (argv[i][1] == '\0'))
        {
          ++n_infiles;
          add_version_magic = 0;
          continue;
        }

      lookup_option (&opt, &skip, NULL, argv[i]);

      switch (opt)
      {
        case OPTION_nostdlib:
        case OPTION_c:
        case OPTION_S:
        case OPTION_syntax_only:
        case OPTION_E:
        case OPTION_M:
        case OPTION_MM:
          /* These options disable linking entirely or linking of the
             standard libraries. */
          library = 0;
          add_version_magic = 0;
          break;

        case OPTION_l:
          ++n_infiles;
          add_version_magic = 0;
          break;

        case OPTION_o:
          ++n_outfiles;
          add_version_magic = 0;
          break;

        case OPTION_v:
          if (!verbose)
            fprintf (stderr, "gpc version %s\n", GPC_RELEASE_STRING);
          verbose = 1;
          break;

        case OPTION_b:
        case OPTION_B:
        case OPTION_L:
        case OPTION_i:
        case OPTION_V:
          /* These options are useful in conjunction with -v to get
             appropriate version info. */
          break;

        case OPTION_version:
          printf ("\
GNU Pascal version %s, based on gcc-%s.\n\
Copyright (C) 1987-2006 Free Software Foundation, Inc.\n\
\n\
GNU Pascal is free software; you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation; either version 3, or (at your option)\n\
any later version.\n\
\n\
GNU Pascal is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n\
GNU General Public License for more details.\n\
\n\
For more version information on components of the GNU Pascal compiler,\n\
especially useful when reporting bugs, type the command\n\
    `%s --verbose'.\n\
\n\
Most used command line options:\n\
    -c         Compile or assemble the source files, but do not link.\n\
    -o FILE    Place output in file FILE.\n\
    -v         Be verbose.\n\
\n\
The command line options are described in the online documentation.\n\
    `info -f gpc invoking' describes them in detail.\n\
\n\
Report bugs to <gpc@gnu.de>.\n\
\n\
", GPC_RELEASE_STRING,
   version_string, programname);
          exit (0);
          break;

        case OPTION_help:
          /* Let gcc.c handle this, as the egcs version has a really
             cool facility for handling --help and --verbose --help. */
          return;

        default:
          add_version_magic = 0;
          break;
      }

      /* This is the one place we check for missing arguments in the
         program. */

      if (i + skip < argc)
        i += skip;
      else
        (*fn) ("argument to `%s' missing", argv[i]);
    }

  if ((n_outfiles != 0) && (n_infiles == 0))
    (*fn) ("No input files; unwilling to write output files");

  /* Second pass through arglist, transforming arguments as appropriate. */

  append_arg (argv[0]); /* Start with command name, of course. */

  for (i = 1; i < argc; ++i)
    {
      if (argv[i][0] == '\0')
        {
          append_arg (argv[i]); /* Interesting. Just append as is. */
          continue;
        }

      if ((argv[i][0] == '-') && (argv[i][1] != 'l'))
        {
          /* Not a filename or library. */

         if (saw_library == 1 && need_math)    /* -l<library>. */
            append_arg (MATH_LIBRARY);

          saw_library = 0;

          lookup_option (&opt, &skip, &arg, argv[i]);

          if (argv[i][1] == '\0')
            {
              append_arg (argv[i]);     /* "-" == Standard input. */
              continue;
            }

          if (opt == OPTION_x)
            {
              /* Track input language. */
              char *lang;

              if (arg == NULL)
                lang = argv[i+1];
              else
                lang = arg;

              saw_speclang = (strcmp (lang, "none") != 0);
            }

          append_arg (argv[i]);

          for (; skip != 0; --skip)
            append_arg (argv[++i]);

          continue;
        }

      /* A filename/library, not an option. */

      if (saw_speclang)
        saw_library = 0;        /* -xfoo currently active. */
      else
        {                       /* -lfoo or filename. */
          if (strcmp (argv[i], MATH_LIBRARY) == 0
#ifdef ALT_LIBM
              || strcmp (argv[i], ALT_LIBM) == 0
#endif
              )
            {
              if (saw_library == 1)
                saw_library = 2;        /* -l<library> -lm. */
              else
                append_arg (PASCAL_LIBRARY);
            }
          else if (strcmp (argv[i], PASCAL_LIBRARY) == 0)
            saw_library = 1;    /* -l<library>. */
          else
            {           /* Other library, or filename. */
             if (saw_library == 1 && need_math)
                append_arg (MATH_LIBRARY);
              saw_library = 0;
            }
        }
      append_arg (argv[i]);
    }

  /* Append `-lg2c -lm' as necessary. */

  if (!add_version_magic && library)
    {                           /* Doing a link and no -nostdlib. */
      if (saw_speclang)
        append_arg ("-xnone");

      switch (saw_library)
      {
        case 0:
          append_arg (library);
        case 1:
         if (need_math)
           append_arg (MATH_LIBRARY);
        default:
          break;
      }
    }
#if 0
  else if (add_version_magic && verbose)
    {
      append_arg ("-c");
      append_arg ("-xgpc-version");
      append_arg ("/dev/null");
      append_arg ("-xnone");
    }

  if (verbose
      && gpc_newargv != gpc_xargv)
    {
      fprintf (stderr, "Driving:");
      for (i = 0; i < gpc_newargc; i++)
        fprintf (stderr, " %s", gpc_newargv[i]);
      fprintf (stderr, "\n");
    }
#endif

  *in_argc = gpc_newargc;
  *in_argv = gpc_newargv;
}

/* Called before linking. Returns 0 on success and -1 on failure. */
int lang_specific_pre_link (void)  /* Not used for GPC. */
{
  return 0;
}

/* Number of extra output files that lang_specific_pre_link may generate. */
int lang_specific_extra_outfiles = 0;  /* Not used for GPC. */
