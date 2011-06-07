/*GPC command-line options and compiler directives

  Copyright (C) 1988-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
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

#include "gpc.h"
#include "gpc-options.h"
#include "p/p-version.h"
#ifdef GCC_4_0
#include "version.h"
#endif


#ifdef GCC_3_4
#include "options.h"
#endif

const char *lang_version_string = GPC_RELEASE_STRING ", based on gcc-";

/* An array with all long Pascal command-line switches. */
static const struct
{
  int source;
  const char *name;
} gpc_options[] =
{
#define OPTIONS_ONLY
#define GPC_OPT(SOURCE, NAME, OPTION, VALUE, DESCRIPTION) { SOURCE, NAME },
#include "lang-options.h"
#undef GPC_OPT
  { 0, NULL }
};

struct options *lexer_options, *compiler_options, *co;

struct option_stack
{
  struct option_stack *next;
  unsigned int maximum_field_alignment;
  int write_width[5];
};

static struct option_stack *option_stack = NULL, last_option_stack;

string_list *deferred_options = NULL;

/* Whether extra_inits has been used already. Changing it later is pointless. */
int extra_inits_used;

/* The backend needs this. Not used in GPC. */
int flag_traditional = 0;

/* Global options. These are not kept in option_stack, so they usually should
   not be changed by any directives that are allowed in the source code (see
   lang-options.h), only by command-line options. */

/* Name(s) of extra modules/units to be initialized automatically.
   (This can be changed from the source, but only appended to, so that's ok. */
char *extra_inits;

/* Name of the main program, usually `main'. This can be changed from the
   source, but has only a global effect. */
const char *gpc_main;

/* Name(s) of extra modules/units to be imported automatically. */
char *extra_imports;

/* Name of a file to store information about targets in. */
const char *automake_temp_filename;

/* Programs to call in automake. */
char *automake_gpc;
char *automake_gcc;
char *automake_gpp;

/* Zero if the default unit and object paths should be used. */
int flag_disable_default_paths;

/* Search path for GPI and unit source files. */
char *unit_path;
char *default_unit_path;

/* Search path for object and non-Pascal source files. */
char *object_path;
char *default_object_path;

/* Name of executable file to be produced. An empty string (not NULL)
   indicates that we want to derive the file name of the executable
   from the name of the main input file. */
const char *executable_file_name;

/* Path where executable files should be produced. */
char *executable_destination_path;

/* Path where unit `.o' and `.gpi' files should be produced during automake. */
char *unit_destination_path;

/* Path where `.o' files from `$L' directives should be produced during automake. */
char *object_destination_path;

/* Path where `.gpi' files should be produced during this compilation.
   (For `.o' files, `-o /foo/bar.o' can be used.) This is needed for
   internal use during automake. */
char *gpi_destination_path;

/* Nonzero means to output progress report messages. */
int flag_progress_messages;

/* Nonzero means to output progress bar information. */
int flag_progress_bar;

static const char dir_separator_str[2] = { DIR_SEPARATOR, 0 };
static const char path_separator_str[2] = { PATH_SEPARATOR, 0 };

static int is_prefix_word (const char *, const char *);
static int strtoint (const char *, int);
static int option_without_argument (const char *, const char *);
static char *option_with_argument (const char *, const char *, int);
static void string_append (char **, const char *, const char *);

/* Return a newly allocated copy of the string s */
char *
save_string (const char *s)
{
  return strcpy (xmalloc (strlen (s) + 1), s);
}

static int
is_prefix_word (const char *prefix, const char *s)
{
  int l = strlen (prefix);
  char c = s[l];
  return !strncmp (prefix, s, l)
    && !((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_');
}

static int
strtoint (const char *s, int length)
{
  char *tail;
  int i;
  errno = 0;
  i = strtol (s, &tail, 10);
  if (errno || tail != s + length)
    {
      error ("integer value expected in compiler option");
      return 0;
    }
  return i;
}

/* If `--foo' is a Pascal option without arguments, the backend will
   accept `--foo-bar' without error, so we must give an error here. */
static int
option_without_argument (const char *p, const char *option)
{
  int l = strlen (option);
  if (strncmp (p, option, l))
    return 0;
  else if (p[l])
    error ("invalid option `%s'", p);
  return 1;
}

static char *
option_with_argument (const char *p, const char *option, int may_be_empty)
{
  const char *q;
  int length = strlen (option);
  if (strncmp (p, option, length))
    return NULL;
  q = p + length;
  if (*q == ' ')
    while (*q == ' ')
      q++;
  else if (*q == ':' || *q == '=')
    q++;
  else if (*q)
    error ("missing separator after `%.*s'", length - 2, p + 2);
  else if (!may_be_empty)
    error ("missing argument to `%.*s'", length - 2, p + 2);
  return save_string (q);
}

static void
string_append (char **strvar, const char *newval, const char *separator)
{
  if (!newval)
    ;
  else if (!*strvar)
    *strvar = save_string (newval);
  else
    *strvar = concat (*strvar, separator, newval, NULL);
}

void
pascal_decode_option_1 (const char *p)
{
  pascal_decode_option (1, &p);
}

/* Return the number of strings consumed. */
int
pascal_decode_option (int argc ATTRIBUTE_UNUSED, const char *const *argv)
{
  int flag, kw;
  char *arg;
  const char *p = argv[0];
  const struct lang_option_map *map = lang_option_map;
  (void) dialect_options;  /* Suppress a warning */
  /* Skip preprocessor options */
  if (p[0] == '-')
    {
      const char * const iopts[] = { "idirafter", "imacros", "include",
                 "iprefix", "isystem", "iwithprefix", "iwithprefixbefore", 0 };
      switch (p[1])
        { 
          int i;
#ifdef EGCS97
          case 'E':
                   if (!p[2])
                     flag_syntax_only = 1;
                   break;
#endif
          case 'M':
                   if (!p[2])
                     {
                       co->preprocess_only = 1;
                       co->print_deps = 1;
                       return 1;
                     }
                   else
                     return 0;
          case 'D':
          case 'U':
          case 'I':
                    return p[2]? 1 : 2;
          case 'i':
                    for (i = 0; iopts[i] && strcmp (iopts[i], p + 1); i++);
                    if (iopts[i]) 
                      return 2;
        }
    }
  while (*map->src)
    {
      const char *const *src = map->src, *const *dest;
      while (*src && strcmp (p, *src) != 0)
        src++;
      if (*src)
        for (dest = map->dest; *dest; dest++)
          if (!pascal_decode_option (1, dest))
            error ("internal problem: unknown implicit option `%s'", *dest);
      map++;
    }
#define OPT(S) (option_without_argument (p, S))
#define OPT_ARG(S, MAY_BE_EMPTY) (arg = option_with_argument (p, S, MAY_BE_EMPTY))
#define SEE_CODE (-99)
/* Note: If the name of option A is a prefix of the name of option B, A must come *after* B. */
  if (OPT_ARG ("-fdebug-tree", 0))
    {
      if (!lineno)  /* get_identifier() might crash if not initialized yet */
        error ("`debug-tree' can be used only as a compiler directive, not on the command-line");
      else
        {
          tree t;
          if (!strncmp (arg, "0x", 2))
            t = (tree) strtol (arg + 2, NULL, 16);
          else if (*arg >= '0' && *arg <= '9')
            t = (tree) strtol (arg, NULL, 16);
          else
            {
              t = get_identifier (arg);
              if (!lookup_name (t))
                {
                  char *qq;
                  *arg = TOUPPER (*arg);
                  for (qq = arg + 1; *qq; qq++)
                    *qq = TOLOWER (*qq);
                  t = get_identifier (arg);
                }
            }
          if (t)
            debug_tree (t);
          else
            fprintf (stderr, "NULL_TREE\n");
          free (arg);
        }
    }
  else if (OPT ("-fdisable-debug-info"))
    {
      gpc_warning ("`--disable-debug-info' is a temporary work-around; it may disappear in the future");
      if (write_symbols == SDB_DEBUG)  /* Not all debug formats like to be reset */
        write_symbols = NO_DEBUG;
      debug_info_level = DINFO_LEVEL_NONE;
      use_gnu_debug_info_extensions = 0;
    }
  else if (OPT_ARG ("-fautomake-gpc", 0))
    {
      if (automake_gpc)
        free (automake_gpc);
      automake_gpc = arg;
    }
  else if (OPT_ARG ("-fautomake-gcc", 0))
    {
      if (automake_gcc)
        free (automake_gcc);
      automake_gcc = arg;
    }
  else if (OPT_ARG ("-fautomake-g++", 0))
    {
      if (automake_gpp)
        free (automake_gpp);
      automake_gpp = arg;
    }
  else if (OPT_ARG ("-famtmpfile", 0))
    {
      /* This information is passed by the gpc driver program, not by the user.
         Extract the `gpc' command line options from the automake
         temp file and use them to initialize automake_gpc_options. */
      FILE *automake_temp_file;
      automake_temp_filename = arg;
      automake_temp_file = fopen (automake_temp_filename, "rt");
      if (!automake_temp_file)
        {
          error ("cannot open automake temp file `%s'", automake_temp_filename);
          exit (FATAL_EXIT_CODE);
        }
      while (!feof (automake_temp_file))
        {
          char s[10240];
          if (fgets (s, sizeof (s), automake_temp_file))
            {
              if (!strncmp (s, "#gpc: ", 6))
                {
                  int l = strlen (s) - 1;
                  if (s[l] == '\n')
                    s[l] = 0;
                  if (automake_gpc)
                    free (automake_gpc);
                  automake_gpc = save_string (s + 6);
                }
              else if (!strncmp (s, "#cmdline: ", 10))
                {
                  int l = strlen (s) - 1;
                  if (s[l] == '\n')
                    s[l] = 0;
                  add_automake_gpc_options (s + 10);
                }
            }
        }
      fclose (automake_temp_file);
    }
  else if (OPT ("-fpack-struct"))
    flag_pack_struct = 1;
  else if (OPT ("-fno-pack-struct"))
    flag_pack_struct = 0;
  else if (OPT_ARG ("-fmaximum-field-alignment", 0))
    {
      int i = strtoint (arg, strlen (arg));
      if (i < 0)
        error ("invalid maximum field alignment %d", i);
      maximum_field_alignment = i < 0 ? 0 : i;
    }
  else if (OPT_ARG ("-ffield-widths", 1))
    {
      unsigned int i;
      co->write_width[0] = 11;
      co->write_width[1] = 23;
      co->write_width[2] = 6;
      co->write_width[3] = 21;
      co->write_width[4] = 29;
      for (i = 0; i < ARRAY_SIZE (co->write_width) && *arg; i++)
        {
          const char *q = arg;
          while (*arg && *arg != ':')
            arg++;
          co->write_width[i] = strtoint (q, arg - q);
          if (*arg)
            arg++;
        }
    }
  else if (OPT ("-fno-field-widths"))
    {
      unsigned int i;
      for (i = 0; i < ARRAY_SIZE (co->write_width); i++)
        co->write_width[i] = 0;
    }
  else if (OPT ("-fpedantic"))
    pedantic = 1;
  else if (OPT ("-fno-pedantic"))
    pedantic = 0;
  else if (OPT ("-fstack-checking"))
    flag_stack_check = 1;
  else if (OPT ("-fno-stack-checking"))
    flag_stack_check = 0;
  else if (OPT ("-fshort-enums"))
    flag_short_enums = 1;
  else if (OPT ("-fno-short-enums"))
    flag_short_enums = 0;
  else if ((kw = 1, flag = 0, OPT_ARG ("-fenable-keyword", 0)) || (flag = 1, OPT_ARG ("-fdisable-keyword", 0)) ||
           (kw = 0, flag = 0, OPT_ARG ("-fenable-predefined-identifier", 0)) || (flag = 1, OPT_ARG ("-fdisable-predefined-identifier", 0)))
    {
      if (!text_type_node)  /* command-line */
        append_string_list (&deferred_options, p, 1);
      else
        {
          struct predef *pd;
          const char *p;
          char t, *buf, *q, *qq;
          do
            {
              while (*arg == ' ') arg++;
              for (q = arg; *q && *q != ' ' && *q != ','; q++) ;
              t = *q;
              *q = 0;
              p = arg;
              buf = arg;
              qq = buf;
              *qq++ = TOUPPER (*p++);
              while (*p)
                *qq++ = TOLOWER (*p++);
              *qq = 0;
              pd = IDENTIFIER_BUILT_IN_VALUE (get_identifier (buf));
              if (!pd || (kw != (pd->kind == bk_none || pd->kind == bk_keyword)))
                error (kw ? "unknown keyword `%s'" : "unknown predefined identifier `%s'", arg);
              else
                pd->user_disabled = flag ? 1 : -1;
              arg = q + 1;
            }
          while (t);
        }
    }
  else if (OPT_ARG ("-fsetlimit", 0))
    {
      int limit = strtoint (arg, strlen (arg));
      if (limit <= 0)
        gpc_warning ("invalid specified set limit %s.", arg);
      else
        co->set_limit = limit;
    }
  else if (OPT_ARG ("-fgpc-main", 0))
    {
      gpc_main = arg;
      while ((*arg >= 'A' && *arg <= 'Z')
             || (*arg >= 'a' && *arg <= 'z')
             || (*arg >= '0' && *arg <= '9')
             || *arg == '_' || *arg == '$' || *arg == '.')
        arg++;
      if (*arg)
        error ("invalid character in `gpc-main' name");
    }
  else if (OPT ("-fimplementation-only"))
    {
      co->implementation_only = 1;
      co->automake_level = 0;
    }
  else if (OPT_ARG ("-fexecutable-file-name", 1))
    executable_file_name = arg;
  else if (OPT_ARG ("-funit-path", 0))
    string_append (&unit_path, arg, path_separator_str);
  else if (OPT ("-fno-unit-path"))
    unit_path = default_unit_path = NULL;
  else if (OPT_ARG ("-fobject-path", 0))
    string_append (&object_path, arg, path_separator_str);
  else if (OPT ("-fno-object-path"))
    object_path = default_object_path = NULL;
  else if (OPT_ARG ("-fexecutable-path", 0))
    {
      if (executable_destination_path)
        free (executable_destination_path);
      if (IS_DIR_SEPARATOR (arg[strlen (arg) - 1]))
        executable_destination_path = arg;
      else
        executable_destination_path = concat (arg, dir_separator_str, NULL);
    }
  else if (OPT ("-fno-executable-path"))
    {
      if (executable_destination_path)
        free (executable_destination_path);
      executable_destination_path = NULL;
    }
  else if (OPT_ARG ("-funit-destination-path", 0))
    {
      if (unit_destination_path)
        free (unit_destination_path);
      if (IS_DIR_SEPARATOR (arg[strlen (arg) - 1]))
        unit_destination_path = arg;
      else
        unit_destination_path = concat (arg, dir_separator_str, NULL);
    }
  else if (OPT ("-fno-unit-destination-path"))
    {
      if (unit_destination_path)
        free (unit_destination_path);
      unit_destination_path = NULL;
    }
  else if (OPT_ARG ("-fobject-destination-path", 0))
    {
      if (object_destination_path)
        free (object_destination_path);
      if (IS_DIR_SEPARATOR (arg[strlen (arg) - 1]))
        object_destination_path = arg;
      else
        object_destination_path = concat (arg, dir_separator_str, NULL);

    }
  else if (OPT ("-fno-object-destination-path"))
    {
      if (object_destination_path)
        free (object_destination_path);
      object_destination_path = NULL;
    }
  else if (OPT ("-fdisable-default-paths"))
    flag_disable_default_paths = 1;
  else if (OPT_ARG ("-fgpi-destination-path", 0))
    {
      if (gpi_destination_path)
        free (gpi_destination_path);
      if (IS_DIR_SEPARATOR (arg[strlen (arg) - 1]))
        gpi_destination_path = arg;
      else
        gpi_destination_path = concat (arg, dir_separator_str, NULL);
    }
  else if (OPT ("-fprogress-messages"))
    flag_progress_messages = 1;
  else if (OPT ("-fno-progress-messages"))
    flag_progress_messages = 0;
  else if (OPT ("-fprogress-bar"))
    flag_progress_bar = 1;
  else if (OPT ("-fno-progress-bar"))
    flag_progress_bar = 0;
  else if (OPT_ARG ("-fuses", 0))
    string_append (&extra_imports, arg, ",");
  else if (OPT_ARG ("-finit-modules", 0))
    {
      if (extra_inits_used)
        error ("`{$init-modules}' must be placed before the constructor");
      string_append (&extra_inits, arg, ":");
    }
  else if (OPT ("-Wwarnings"))
    inhibit_warnings = 0;
  else if (OPT ("-Wno-warnings"))
    inhibit_warnings = 1;
  else if (OPT ("-Wcast-align"))
    warn_cast_align = 1;
  else if (OPT ("-Wno-cast-align"))
    warn_cast_align = 0;
  else if (OPT ("-Wparentheses"))
    co->warn_parentheses = 1;
  else if (OPT ("-Wno-parentheses"))
    co->warn_parentheses = 0;
  else if (OPT ("-Wfloat-equal"))
    co->warn_float_equal = 1;
  else if (OPT ("-Wno-float-equal"))
    co->warn_float_equal = 0;
  else if (OPT ("-Wall"))
    {
      /* We save the value of warn_uninitialized, since if they put
         -Wuninitialized on the command line, we need to generate a
         warning about not using it without also specifying -O. */
      if (warn_uninitialized != 1)
        warn_uninitialized = 2;
#ifdef EGCS97
      /* set_Wunused (1); */
#else
      warn_unused = 1;
#endif
      warn_switch = 1;
      co->warn_parentheses = 1;
    }
  else if (OPT ("-fextended-syntax")
           || OPT ("-fno-extended-syntax")
           || OPT ("-frange-and-object-checking")
           || OPT ("-fno-range-and-object-checking")
           || OPT ("-fborland-objects")
           || OPT ("-fmac-objects")
           || OPT ("-fooe-objects")
           || OPT ("-fgnu-objects"))
    /* only option inclusions in gpc-options.h */ ;
  else if (OPT ("-fmacros")
           || OPT ("-fno-macros")
           || OPT_ARG ("-fcsdefine", 0)
           || OPT_ARG ("-fcidefine", 0))
    /* handled by gpcpp */ ;
  else if (OPT ("-Wswitch")
           || OPT ("-Wpointer-arith")
           || OPT ("-Wmissing-prototypes")
           || OPT ("-Wmissing-declarations")
           || OPT ("-Wwrite-strings")
           || OPT ("-Wno-write-strings")
           || OPT ("-Wunused-function")
           || OPT ("-Wunused-label")
           || OPT ("-Wunused-parameter")
           || OPT ("-Wunused-variable")
           || OPT ("-Wunused-value")
           || OPT ("-Wunused")
           || OPT ("-Wuninitialized")
           || OPT ("--help"))
    /* handled in toplev.c, accept them here without warning */ ;
#define GPC_OPT(SOURCE, NAME, OPTION, VALUE, DESCRIPTION) \
  else if (VALUE != SEE_CODE && OPT (NAME)) co->OPTION = VALUE;
#include "lang-options.h"
#undef GPC_OPT
  else
    return 0;
  return 1;
#undef OPT
#undef OPT_ARG
}

int
is_pascal_option (const char *option)
{
  unsigned int i;
  for (i = 0; i < ARRAY_SIZE (gpc_options) - 1; i++)
    {
      const char *t = gpc_options[i].name;
      if (!strncmp (option, t, strlen (t))
          || (option[0] == '-' && option[1] == '-' && t[0] == '-' && t[1] == 'f'
              && !strncmp (option + 2, t + 2, strlen (t) - 2)))
        return 1;
    }
  return 0;
}

void
activate_options (struct options *options, int save_current)
{
  if (options == co)
    return;
#define BO(NAME) co->NAME = NAME;
  if (save_current)
    {
      BACKEND_OPTIONS
    }
#undef BO
  co = options;
#define BO(NAME) NAME = co->NAME;
  BACKEND_OPTIONS
#undef BO
}

/* Process compiler directives. NAME is given in lower case, except
   for strings and the argument to `{$M }'. Some directives have
   already been handled by the preprocessor.
   Return 0 if rest of directive shall be skipped, otherwise 1. */
int
process_pascal_directive (char *name, int length)
{
  int j, one_letter;
  char *option_name, *start;
  const char *option, *p;
  static int notified = 0;
  if (PEDANTIC (U_B_D_M_PASCAL) && !notified)
    {
      notified = 1;
      gpc_pedwarn ("compiler directives are a UCSD Pascal extension");
    }
  while (length > 0 &&
         (name[length - 1] == ' ' || name[length - 1] == '\t'
          || name[length - 1] == '\n' || name[length - 1] == '\r'))
    name[--length] = 0;
  if (length == 0)
    {
      gpc_warning ("empty Pascal compiler directive");
      return 1;
    }
  if (length == 2 && (name[1] == '+' || name[1] == '-'))
    {
      const struct gpc_short_option *short_option = gpc_short_options;
      while (short_option->short_name
             && (short_option->short_name != name[0]
                 || (!short_option->bp_option && (co->pascal_dialect & U_B_D_PASCAL))))
        short_option++;
      if (short_option->short_name)
        {
          const char *long_name;
          if (name[1] == '+')
            long_name = short_option->long_name;
          else
            long_name = short_option->inverted_long_name;
          if (long_name[1] == '#')
            gpc_warning ("directive `{$%s}' not yet implemented", name);
          else if (long_name[1] == '!')
            {
              /* BP-style directive. In BP mode, ignore it for compatibility. */
              if (pedantic || !(co->pascal_dialect & U_B_D_PASCAL))
                gpc_warning ("ignoring BP directive `{$%s}' which is unnecessary in GPC", name);
            }
          else if (!pascal_decode_option (1, &long_name))
            error ("internal problem: unknown short option expansion `%s'", long_name);
          return 1;
        }
    }

  /* `$local' and `$endlocal' are mostly handled by the preprocessor. */
  if (!strcmp (name, "local"))
    {
      struct option_stack *s = (struct option_stack *) xmalloc (sizeof (struct option_stack));
      s->next = option_stack;
      option_stack = s;
      s->maximum_field_alignment = maximum_field_alignment;
      memcpy (s->write_width, co->write_width, sizeof (co->write_width));
      return 1;
    }
  if (!strcmp (name, "endlocal"))
    {
      last_option_stack = *option_stack;
      free (option_stack);
      option_stack = last_option_stack.next;
      return 1;
    }
  /* These are output by gpcpp after the `endlocal' (for technical reasons),
     so we save the last options in last_option_stack. */
  if (!strcmp (name, "internal-restore-mfa"))
    {
      maximum_field_alignment = last_option_stack.maximum_field_alignment;
      return 1;
    }
  if (!strcmp (name, "internal-restore-fw"))
    {
      memcpy (co->write_width, last_option_stack.write_width, sizeof (co->write_width));
      return 1;
    }

  /* Directives already handled by preprocessor */
  if (is_prefix_word ("define", name)
      || is_prefix_word ("definec", name)
      || is_prefix_word ("macro", name)
      || is_prefix_word ("csdefine", name)
      || is_prefix_word ("cidefine", name)
      || is_prefix_word ("undef", name)
      || is_prefix_word ("undefc", name)
      || is_prefix_word ("include", name)
      || is_prefix_word ("if", name)
      || is_prefix_word ("ifc", name)
      || is_prefix_word ("ifdef", name)
      || is_prefix_word ("ifndef", name)
      || is_prefix_word ("ifopt", name)
      || is_prefix_word ("ifoptc", name)
      || is_prefix_word ("else", name)
      || is_prefix_word ("elsec", name)
      || is_prefix_word ("elif", name)
      || is_prefix_word ("elifc", name)
      || is_prefix_word ("endif", name)
      || is_prefix_word ("endc", name)
      || is_prefix_word ("warning", name))
    return 0;
  one_letter = length >= 2 && (name[1] == ' ' || name[1] == '\t' || name[1] == '\n' || name[1] == '\r');
  /* Allocate option_name on the heap because its value might be
     used as the main program's name or such ... */
  if (one_letter && name[0] == 'w')
    option_name = concat ("-W", name + 2, NULL);
  else
    option_name = concat ("-f", name, NULL);
  p = option_name;
  while (*p && *p != '=' && *p != ':' && *p != ' ' && *p != '\t' && *p != '\n' && *p != '\r')
    p++;
  j = 0;
  while ((option = gpc_options[j].name) != NULL &&
         (strlen (option) != (unsigned int) (p - option_name)
          || strncmp (option, option_name, p - option_name) != 0))
    j++;
  /* Do not accept pointless `$uses' directives. */
  if (!strncmp (option_name, "-fuses", strlen ("-fuses")))
    {
      error ("`$uses' cannot be used as a compiler directive -- use a `uses' clause instead");
      return 1;
    }
  /* Do not accept path names etc. in the source code. */
  if (option && !gpc_options[j].source)
    {
      error ("`%s' must not be specified as a compiler directive", name);
      return 1;
    }
  p = option_name;
  if (pascal_decode_option (1, &p))
    return 1;
  free (option_name);
  start = name + 2;
  if (one_letter)
    switch (name[0])
    {
      /* BP-style one-letter directives with options. In BP mode, ignore them for compatibility. */
      case 'c':
      case 'd':
      case 'g':
      case 'o':
      case 's':
        if (pedantic || !(co->pascal_dialect & U_B_D_PASCAL))
          gpc_warning ("ignoring BP directive `{$%s}' which is unnecessary in GPC", name);
        return 1;
      /* One-letter directive already handled by the preprocessor */
      case 'i':
        return 0;
      /* Message */
      case 'm':
        {
          /* Ignore `{$M 42, $f00}' directives in BP mode for compatibility */
          if (co->pascal_dialect & U_B_D_PASCAL)
            {
              int hex = 0;
              p = start;
              while ((*p >= '0' && *p <= '9')
                     || (*p == '$' && (hex = 1))
                     || (*p == ',' && !(hex = 0))
                     || (hex && ((*p >= 'A' && *p <= 'F') || (*p >= 'a' && *p <= 'f')))
                     || *p == ' ' || *p == '\t' || *p == '\n' || *p == '\r')
                p++;
              if (!*p)
                return 1;
            }
          fprintf (stderr, "%s\n", start);
          return 1;
        }
      /* Linker file specification */
      case 'l':
      case 'r':
        while (start)
          {
            char *filename = start, *p;
            while (*start && *start != ',')
              start++;
            if (!*start)
              start = NULL;
            else
              *start++ = 0;
            while (*filename == ' ' || *filename == '\t' || *filename == '\n' || *filename == '\r')
              filename++;
            if (name[0] == 'r')
              {
                char *new_filename = locate_file (filename, LF_OBJECT);
                if (!new_filename)
                  {
                    error ("resource file `%s' not found", filename);
                    continue;
                  }
                add_to_link_file_list (ACONCAT ((new_filename, ".resource", NULL)));
                free (new_filename);
                continue;
              }
            for (p = filename; *p; p++) ;
            while (p > filename && *p != '.')
              p--;
            if (*p != '.')
              {
                /* filename >= name + 2 ! */
                *--filename = 'l';
                *--filename = '-';
                add_to_link_file_list (filename);
              }
            else
              {
                /* Extension given. Try to locate the file first
                   in the object path, then in the unit path. */
                char *new_filename = locate_file (filename, LF_OBJECT);
                if (!new_filename)
                  {
                    error ("file `%s' not found", filename);
                    continue;
                  }
                if (((p[1] != 'o' && p[1] != 'a') || p[2] != 0)
                    && (p[1] != 's' || p[2] != 'o' || p[3] != 0)
                    && (p[1] != 'l' || p[2] != 'n' || p[3] != 'k' || p[4] != 0))
                  {
                    /* Extension given, but not a linker input file.
                       Recompile it with --automake, if necessary. */
                    char p1 = p[1], p2 = p[2];
                    char *new_object_filename;
                    struct stat object_status, source_status;
                    if (stat (new_filename, &source_status) != 0)
                      source_status.st_mtime = 0;
                    p[1] = 'o';
                    p[2] = 0;
                    new_object_filename = locate_file (filename, LF_COMPILED_OBJECT);
                    p[1] = p1;
                    p[2] = p2;
                    if (co->automake_level > 2
                        || (co->automake_level > 1
                            && (!new_object_filename
                                || stat (new_object_filename, &object_status) != 0
                                || (source_status.st_mtime != 0
                                    && object_status.st_mtime < source_status.st_mtime))))
                      {
                        if (compile_module (new_filename,
                              object_destination_path ? object_destination_path
                                                      : unit_destination_path) != 0)
                          error ("`%s' could not be compiled", new_filename);
                        /* compile_module() adds this to the automake temp file. */
                        free (new_filename);
                        if (new_object_filename)
                          free (new_object_filename);
                        continue;
                      }
                    /* Fall through and link the object file. */
                    free (new_filename);
                    if (new_object_filename)
                      /* No need to recompile. */
                      new_filename = new_object_filename;
                    else
                      {
                        error ("file `%s' must be compiled", filename);
                        new_filename = save_string (filename);
                      }
                  }
                add_to_link_file_list (new_filename);
                free (new_filename);
              }
          }
        return 1;
    }
  gpc_warning ("unknown compiler directive `%s'", name);
  return 1;
}

/* This initialization is run once per compilation just before command-line
   options are processed. */
#ifndef GCC_3_4
void
pascal_init_options (void)
#else
unsigned int
pascal_init_options (unsigned int argc, const char **argv )
#endif
{
  const char *const *option;

#ifndef GCC_3_4
  /* @@@@ Since the (ab)use of language_string in
     ../config/rs6000/rs6000.c prevents us from storing the GPC
     version number there, let's at least output it here ... */
  /* Great! toplev.h doesn't even export version_flag, so check for
     it again. :-/ At least it exports save_arg[cv] ... */
  char *p, *q, *r;
  int version_flag = 0, i;
  for (i = 1; i < save_argc; i++)
    if (!strcmp (save_argv[i], "-version"))
      version_flag = 1;
  if (version_flag)
    fprintf (stderr, "GNU Pascal version is actually %s, based on gcc-%s\n", GPC_RELEASE_STRING, version_string);
#else
  save_argc = argc;
  save_argv = (char * *)argv;
#endif

  lexer_options = compiler_options = co = (struct options *) xmalloc (sizeof (struct options));
  memset (co, 0, sizeof (struct options));
  co->option_big_endian = -1;
  co->set_limit = DEFAULT_SET_LIMIT;
  for (option = default_options; *option; option++)
    if (!pascal_decode_option (1, option))
      error ("internal problem: unknown default option `%s'", *option);
  warn_return_type = 1;

  /* Initialize the default paths, using the directory we are living in. */
  string_append (&default_unit_path, getenv ("GPC_UNIT_PATH"), path_separator_str);
  string_append (&default_object_path, getenv ("GPC_OBJECT_PATH"), path_separator_str);
#ifndef GCC_3_4
  p = save_string (save_argv[0]);
  q = p + strlen (p) - 1;
  while (q >= p && !IS_DIR_SEPARATOR (*q))
    q--;
  if (q >= p)
    {
      q[1] = 0;
      r = ACONCAT ((p, "units", NULL));
      q[0] = 0;
      string_append (&default_unit_path, r, path_separator_str);
      string_append (&default_unit_path, p, path_separator_str);
    }
  free (p);
#else
  string_append (&default_unit_path, GPC_UNITS_DIR, path_separator_str);
  return CL_Pascal;
#endif
}

void
do_deferred_options (void)
{
  while (deferred_options)
    {
      if (!pascal_decode_option (1, (const char **) &deferred_options->string))
        error ("invalid option `%s'", deferred_options->string);
      deferred_options = deferred_options->next;
    }
}

/* Print error or warning, depending on error_flag */
#define MAX_MSG_LENGTH_PER_LINE 60
void
error_or_warning (int error_flag, const char *msg)
{
  char *buf = alloca (strlen (msg) + 1), *p;
  strcpy (buf, msg);
  while (strlen (buf) > MAX_MSG_LENGTH_PER_LINE)
    {
      for (p = buf + MAX_MSG_LENGTH_PER_LINE; p > buf && *p != ' '; p--) ;
      if (p == buf)
        {
          for (p = buf + MAX_MSG_LENGTH_PER_LINE; *p && *p != ' '; p++) ;
          if (!*p)
            break;
        }
      *p = 0;
      if (error_flag)
        error ("%s", buf);
      else
        gpc_warning ("%s", buf);
      *p = ' ';
      buf = p;  /* including the leading space */
    }
  if (error_flag)
    error ("%s", buf);
  else
    gpc_warning ("%s", buf);
}

void
dialect_msg (int error_flag, unsigned long dialect, const char *msg, const char *msg2, const char *arg)
{
  static const struct dialects
  {
    unsigned long dialect;
    const char *name;
  } dialects[] =
  {
    { CLASSIC_PASCAL_LEVEL_0, "ISO 7185 Pascal" },
    { CLASSIC_PASCAL_LEVEL_1, "ISO 7185 Pascal, level 1" },
    { EXTENDED_PASCAL,        "ISO 10206 Extended Pascal" },
    { OBJECT_PASCAL,          "Object Pascal" },
    { UCSD_PASCAL,            "UCSD Pascal" },
    { BORLAND_PASCAL,         "Borland Pascal" },
    { BORLAND_DELPHI,         "Borland Delphi" },
    { PASCAL_SC,              "Pascal-SC" },
    { VAX_PASCAL,             "VAX Pascal" },
    { SUN_PASCAL,             "Sun Pascal" },
    { MAC_PASCAL,             "traditional Macintosh Pascal" },
    { GNU_PASCAL,             "GNU Pascal" },
    { 0,                      NULL }
  };
  const struct dialects *d;
  int first = 1;
  char *buf = alloca (strlen (msg) + (arg ? strlen (arg) : 0) + 1);
  sprintf (buf, msg, arg);
  buf = ACONCAT ((buf, msg2, NULL));
  /* Classic 0 <= Classic 1 <= Extended <= Object */
  if (dialect & CLASSIC_PASCAL_LEVEL_0)
    dialect &= ~(CLASSIC_PASCAL_LEVEL_1 | E_O_PASCAL);
  else if (dialect & CLASSIC_PASCAL_LEVEL_1)
    dialect &= ~E_O_PASCAL;
  else if (dialect & EXTENDED_PASCAL)
    dialect &= ~OBJECT_PASCAL;
  /* BP <= BD */
  if (dialect & BORLAND_PASCAL)
    dialect &= ~BORLAND_DELPHI;
  /* anything <= GNU */
  if (dialect & ~GNU_PASCAL)
    dialect &= ~GNU_PASCAL;
  for (d = dialects; d->dialect; d++)
    if (dialect & d->dialect)
      {
        buf = ACONCAT ((buf, first ? " " : ", ", d->name, NULL));
        first = 0;
      }
  error_or_warning (error_flag, buf);
}

/* Report reserved words of some other dialect that are used as identifiers
   with `-pedantic'. Complain about reserved words in the current dialect that
   are used as identifiers even without `-pedantic'. */
void
warn_about_keyword_redeclaration (tree id, int use_as_identifier)
{
  int error_flag = 0;
  struct predef *pd = IDENTIFIER_BUILT_IN_VALUE (id);
  /* Directives `forward' (ISO) and `near' and `far' (BP) are no reserved words. */
  if (!pd || (pd->kind != bk_none && pd->kind != bk_keyword) || (pd->attributes & (KW_INFORMED | KW_DIRECTIVE)))
    return;
  if ((use_as_identifier && (co->pascal_dialect & pd->dialect)) || flag_pedantic_errors)
    error_flag = 1;
  else if (!pedantic)
    return;
  pd->attributes |= KW_INFORMED;
  if (pd->dialect)
    dialect_msg (error_flag, pd->dialect, "`%s' is a keyword in", "", IDENTIFIER_NAME (id));
}
