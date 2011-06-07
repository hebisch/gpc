/*GNU Pascal Compiler Preprocessor (GPCPP)

  Copyright (C) 1986-2006 Free Software Foundation, Inc.

  Authors: Paul Rubin
           Richard Stallman
           Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>

  This file was originally derived from GCC's `cccp.c'.

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

#include "gcc-version.h"
#ifndef EGCS  /* gcc-2.8.1 doesn't check for it. Let's just assume it's there. */
#define HAVE_SYS_STAT_H 1
#define HOST_WIDEST_INT long long int
#endif
#include "config.h"
#ifndef EGCS97
#include "gansidecl.h"
#else
#include "version.h"
#endif
#include "system.h"
#include "gpc-options.h"
#include "p/p-version.h"
#ifndef EGCS97
extern void *alloca (size_t);
#endif

#include "gpcpp.h"

#ifndef FATAL_EXIT_CODE
#define FATAL_EXIT_CODE 1
#endif
#ifndef SUCCESS_EXIT_CODE
#define SUCCESS_EXIT_CODE 0
#endif

#ifndef DIR_SEPARATOR
#define DIR_SEPARATOR '/'
#endif
#ifndef IS_DIR_SEPARATOR
#ifndef DIR_SEPARATOR_2
#define IS_DIR_SEPARATOR(CH) (((CH) == DIR_SEPARATOR) || ((CH) == '/'))
#else
#define IS_DIR_SEPARATOR(CH) (((CH) == DIR_SEPARATOR) || ((CH) == DIR_SEPARATOR_2) || ((CH) == '/'))
#endif
#endif

static const char dir_separator_str[] = { DIR_SEPARATOR, 0 };

#if defined (MSDOS) || defined (_WIN32) || defined (__EMX__)
#define IS_ABSOLUTE_PATHNAME(STR) \
  (IS_DIR_SEPARATOR ((STR)[0]) || (STR)[0] == '$' \
   || ((STR)[0] != '\0' && (STR)[1] == ':' && IS_DIR_SEPARATOR ((STR)[2])))
#else
#define IS_ABSOLUTE_PATHNAME(STR) \
  (IS_DIR_SEPARATOR ((STR)[0]) || (STR)[0] == '$')
#endif

#include <signal.h>

#ifdef HAVE_SYS_RESOURCE_H
# include <sys/resource.h>
#endif

#if !defined (__STDC__) && !defined (HAVE_VPRINTF)
#define vfprintf(file, msg, args) \
  { \
    char *a0 = va_arg (args, char *); \
    char *a1 = va_arg (args, char *); \
    char *a2 = va_arg (args, char *); \
    char *a3 = va_arg (args, char *); \
    fprintf (file, msg, a0, a1, a2, a3); \
  }
#endif

#define INCLUDE_LEN_FUDGE 0  /* From old VMS stuff */

struct gpc_option
{
  int source;
  const char *name;
};

#define OPTIONS_ONLY
#define GPC_OPT(SOURCE, NAME, OPTION, VALUE, DESCRIPTION) { SOURCE, NAME },
static const struct gpc_option gpc_options[] =
{
#include "lang-options.h"
  { 0, NULL }
};
#undef GPC_OPT

typedef unsigned char U_CHAR;

#ifndef EGCS97
extern char * const version_string;
#endif

/* Name under which this program was invoked. */
static const char *progname;

static int delphi_comments;

static int bp_dialect = 0;

/* Current maximum length of directory names in the search path
   for include files. (Altered as we get more of them.) */
static int max_include_len;

/* Nonzero means print the names of included files rather than
   the preprocessed output. */
static int print_deps = 0;

/* File to names of included files are printed */
FILE * deps_out_file;

/* Nonzero means print names of header files (-H). */
static int print_include_names = 0;

/* Nonzero means don't output line number information. */
static int no_line_directives;

static int no_macros = 0;

static int mixed_comments = 0;
static int warn_mixed_comments = 0;

static int nested_comments = 0;
static int warn_nested_comments = 0;
static int pedantic;
static int pedantic_errors;
static int inhibit_warnings = 0;

static int warnings_are_errors;

/* Nonzero causes output not to be done, but directives such as #define
   that have side effects are still obeyed. */
static int no_output;

/* Nonzero means this file was included with a -imacros or -include
   command line and should not be recorded as an include file. */
static int no_record_file;

/* Line where a newline was first seen in a string constant. */
static int multiline_string_line = 0;

/* I/O buffer structure.
   The `fname' field is nonzero for source files and #include files
   and for the dummy text used for -D and -U.
   It is zero for rescanning results of macro expansion
   and for expanding macro arguments. */
#define INPUT_STACK_MAX 400
typedef struct file_buf
{
  const char *fname;  /* Filename specified with #line directive. */
  const char *nominal_fname;  /* Where in the search path this file was found, for #include_next. */
  struct file_name_list *dir;
  int lineno;
  int length;
  U_CHAR *buf;
  U_CHAR *bufp;
  /* Macro that this level is the expansion of.
     Included so that we can reenable the macro
     at the end of this level. */
  struct hashnode *macro;
  /* Value of if_stack at start of this file.
     Used to prohibit unmatched #endif (etc) in an include file. */
  struct if_stack *if_stack;
  U_CHAR *free_ptr;  /* Object to be freed at end of input at this level. */
} FILE_BUF;
static FILE_BUF instack[INPUT_STACK_MAX];
static int last_error_tick;        /* Incremented each time we print it. */
static int input_file_stack_tick;  /* Incremented when the status changes. */

/* Current nesting level of input sources.
   `instack[indepth]' is the level currently being read. */
static int indepth = -1;
#define CHECK_DEPTH(code) \
  if (indepth >= INPUT_STACK_MAX - 1) \
    { \
      error_with_line (line_for_error (instack[indepth].lineno), \
                       "macro or `$include' recursion too deep"); \
      code; \
    }

/* The output buffer. Its LENGTH field is the amount of room allocated
   for the buffer; the number of chars actually present is bufp - buf. */
#define OUTBUF_SIZE 10  /* initial size of output buffer */
static FILE_BUF outbuf;

/* Grow output buffer OBUF points at so it can hold at least NEEDED more chars. */
#define check_expand(OBUF, NEEDED)  \
  (((OBUF)->length - ((OBUF)->bufp - (OBUF)->buf) <= (NEEDED))  \
   ? grow_outbuf ((OBUF), (NEEDED)) : 0)

struct file_name_list
{
  struct file_name_list *next;
  const char *fname;
};

static struct file_name_list *include = 0;  /* First dir to search */
/* This is the first element to use for #include <...>.
   If it is 0, use the entire chain for such includes. */
static struct file_name_list *first_bracket_include = 0;
static struct file_name_list *last_include = 0; /* Last in chain */

/* Chain of include directories to put at the end of the other chain. */
static struct file_name_list *after_include = 0;
static struct file_name_list *last_after_include = 0;  /* Last in chain */

/* Directory prefix that should replace `/usr' in the standard include file directories. */
static char *include_prefix;

/* Structure returned by create_definition */
typedef struct macrodef
{
  struct definition *defn;
  U_CHAR *symnam;
  int symlen;
} MACRODEF;

/* Structure allocated for every #define. For a replacement without
   macros, nargs = -1, the `pattern' list is null, and the expansion
   is just the replacement text. Nargs = 0 means a functionlike macro
   with no args, e.g. `#define getchar() getc (stdin)'.
   When there are args, the expansion is the replacement text with the
   args squashed out, and the reflist is a list describing how to
   build the output from the input: e.g., "3 chars, then the 1st arg,
   then 9 chars, then the 3rd arg, then 0 chars, then the 2nd arg".
   The chars here come from the expansion. Whatever is left of the
   expansion after the last arg-occurrence is copied after that arg.
   Note that the reflist can be arbitrarily long. Its length depends
   on the number of times the arguments appear in the replacement text,
   not how many args there are. Example:
   #define f(x) x+x+x+x+x+x+x would have replacement text "++++++" and
   pattern list
     { (0, 1), (1, 1), (1, 1), ..., (1, 1), NULL }
   where (x, y) means (nchars, argno). */
typedef struct definition
{
  int nargs;
  int length;          /* length of expansion string */
  int predefined;      /* True if the macro was builtin or came from the command line */
  U_CHAR *expansion;
  int line;            /* Line number of definition */
  const char *file;    /* File of definition */
  char rest_args;      /* Nonzero if last arg. absorbs the rest */
  struct reflist
  {
    struct reflist *next;
    U_CHAR stringify;  /* set if a # operator before arg */
    U_CHAR raw_before; /* set if a ## operator before arg */
    U_CHAR raw_after;  /* set if a ## operator after arg */
    char rest_args;    /* Nonzero if this arg. absorbs the rest */
    int nchars;        /* Number of literal chars to copy before this arg occurrence. */
    int argno;         /* Number of arg to substitute (origin-0) */
  } *pattern;
  /* Names of macro args, concatenated in reverse order with comma-space between them.
     The only use of this is that we warn on redefinition
     if this differs between the old and new definitions. */
  U_CHAR *argnames;
} DEFINITION;

/* different kinds of things that can appear in the value field
   of a hash node. Actually, this may be useless now. */
union hashval
{
  char *cpval;
  DEFINITION *defn;
};

/* special extension string that can be added to the last macro argument to
   allow it to absorb the "rest" of the arguments when expanded. Ex:
     #define wow(a, b...)       process (b, a, b)
     { wow (1, 2, 3); }     ->  { process (2, 3, 1, 2, 3); }
     { wow (one, two); }    ->  { process (two, one, two); }
   if this "rest_arg" is used with the concat token '##' and if it is not
   supplied then the token attached to with ## will not be outputted. Ex:
     #define wow (a, b...)      process (b ## , a, ## b)
     { wow (1, 2); }        ->  { process (2, 1, 2); }
     { wow (one); }         ->  { process (one); { */
static char rest_extension[] = "...";
#define REST_EXTENSION_LENGTH (sizeof (rest_extension) - 1)

/* The structure of a node in the hash table. The hash table
   has entries for all tokens defined by #define directives (type T_MACRO),
   plus some special tokens like __LINE__ (these each have their own
   type, and the appropriate code is run when that type of node is seen.
   It does not contain control words like "#define", which are recognized
   by a separate piece of code. */

/* different flavors of hash nodes -- also used in keyword table */
enum node_type
{
  T_DEFINE = 1,
  T_INCLUDE,
  T_INCLUDE_NEXT,
  T_IFDEF,
  T_IFNDEF,
  T_IFOPT,
  T_IF,
  T_ELSE,
  T_ELIF,
  T_UNDEF,
  T_LINE,
  T_ERROR,
  T_WARNING,
  T_ENDIF,
  T_SPECLINE,     /* `__LINE__' */
  T_DATE,
  T_FILE,
  T_BASE_FILE,
  T_INCLUDE_LEVEL,
  T_VERSION,
  T_TIME,
  T_MACRO,        /* macro */
  T_DISABLED,     /* macro temporarily turned off for rescan */
  T_SPEC_DEFINED  /* special `defined' macro for use in #if statements */
};

typedef struct hashnode
{
  struct hashnode *next;  /* double links for easy deletion */
  struct hashnode *prev;
  struct hashnode **bucket_hdr; /* also, a back pointer to this node's hash
                                   chain is kept, in case the node is the head
                                   of the chain and gets deleted. */
  enum node_type type;  /* type of special token */
  int length;           /* length of token, for quick comparison */
  U_CHAR *name;         /* the actual name */
  int case_sensitive;   /* whether the name is case-sensitive */
  union hashval value;  /* pointer to expansion, or whatever */
} HASHNODE;

/* Some definitions for the hash table. The hash function MUST be
   computed as shown in hashf () below. That is because the rescan
   loop computes the hash value `on the fly' for most tokens,
   in order to avoid the overhead of a lot of procedure calls to
   the hashf () function. Hashf () only exists for the sake of
   politeness, for use when speed isn't so important. */

#define LOCASE(x) (((x) >= 'A' && (x) <= 'Z') ? ((x) - 'A' + 'a') : (x))
#define HASHSIZE 1403
static HASHNODE *hashtab[HASHSIZE];
#define HASHSTEP(old, c) ((old << 2) + LOCASE (c))
#define MAKE_POS(v) (v & 0x7fffffff)  /* make number positive */

/* Structure used in Pascal to keep track of active options */
struct option_list
{
  struct option_list *next;
  const char *option;
};

static struct option_list *current_options = NULL;

struct hashnode_list
{
  struct hashnode_list *next;
  HASHNODE *hashnode;
};

/* Structure used to keep track of local options */
struct local_option_list
{
  struct local_option_list *next;
  struct option_list *options;
  struct hashnode_list *hashnodes;
};

static struct local_option_list *local_options_stack = NULL;

#define DO_PARAMS (U_CHAR *, U_CHAR *, FILE_BUF *, struct directive *)

/* `struct directive' defines one #-directive, including how to handle it. */
struct directive
{
  int length;             /* Length of name */
  int (*func) DO_PARAMS;  /* Function to handle directive */
  const char *name;       /* Name of directive */
  enum node_type type;    /* Code which describes which directive. */
  char angle_brackets;    /* Nonzero => <...> is special. */
};

static int do_define1 (U_CHAR *, U_CHAR *, FILE_BUF *, struct directive *, int, HASHNODE **);

/* These functions are declared to return int instead of void since they
   are going to be placed in the table and some old compilers have trouble with
   pointers to functions returning void. */
static int do_define DO_PARAMS;
static int do_elif DO_PARAMS;
static int do_else DO_PARAMS;
static int do_endif DO_PARAMS;
static int do_error DO_PARAMS;
static int do_if DO_PARAMS;
static int do_include DO_PARAMS;
static int do_line DO_PARAMS;
static int do_undef DO_PARAMS;
static int do_warning DO_PARAMS;
static int do_xifdef DO_PARAMS;
static int do_ifopt DO_PARAMS;

/* Here is the actual list of #-directives, most-often-used first. */
static struct directive directive_table[] =
{
  {  6, do_define, "define", T_DEFINE, 0 },
  {  7, do_define, "definec", T_DEFINE, 0 },
  {  5, do_define, "macro", T_DEFINE, 0 },
  {  2, do_if, "if", T_IF, 0 },
  {  3, do_if, "ifc", T_IF, 0 },
  {  5, do_xifdef, "ifdef", T_IFDEF, 0 },
  {  6, do_xifdef, "ifndef", T_IFNDEF, 0 },
  {  5, do_endif, "endif", T_ENDIF, 0 },
  {  4, do_endif, "endc", T_ENDIF, 0 },
  {  4, do_else, "else", T_ELSE, 0 },
  {  5, do_else, "elsec", T_ELSE, 0 },
  {  4, do_elif, "elif", T_ELIF, 0 },
  {  5, do_elif, "elifc", T_ELIF, 0 },
  {  4, do_line, "line", T_LINE, 0 },
  {  7, do_include, "include", T_INCLUDE, 1 },
  { 12, do_include, "include_next", T_INCLUDE_NEXT, 1 },
  {  5, do_undef, "undef", T_UNDEF, 0 },
  {  6, do_undef, "undefc", T_UNDEF, 0 },
  {  5, do_error, "error", T_ERROR, 0 },
  {  6, do_error, "errorc", T_ERROR, 0 },
  {  7, do_warning, "warning", T_WARNING, 0 },
  {  5, do_ifopt, "ifopt", T_IFOPT, 0 },
  {  6, do_ifopt, "ifoptc", T_IFOPT, 0 },
  {  -1, 0, "", 0, 0 }
};

/* The arglist structure is built by do_define to tell
   collect_definition where the argument names begin. That
   is, for a define like "#define f(x,y,z) foo+x-bar*y", the arglist
   would contain pointers to the strings x, y, and z.
   Collect_definition would then build a DEFINITION node,
   with reflist nodes pointing to the places x, y, and z had
   appeared. So the arglist is just convenience data passed
   between these two routines. It is not kept around after
   the current #define has been processed and entered into the
   hash table. */
struct arglist
{
  struct arglist *next;
  U_CHAR *name;
  int length;
  int argno;
  char rest_args;
};

/* When a directive handler is called,
   this points to the # that started the directive. */
static U_CHAR *directive_start;

static U_CHAR is_idchar[256];  /* char can be part of an identifier. */
static U_CHAR is_idstart[256];  /* char can be first char of an identifier. */
static U_CHAR is_hor_space[256];  /* char is horizontal space. */
static U_CHAR is_space[256];  /* char is horizontal or vertical space. */

#define SKIP_WHITE_SPACE(p) do { while (is_hor_space[*p]) p++; } while (0)
#define SKIP_ALL_WHITE_SPACE(p) do { while (is_space[*p]) p++; } while (0)

static int errors = 0;  /* Error counter */

/* Stack of conditionals currently in progress
   (including both successful and failing conditionals). */
typedef struct if_stack
{
  struct if_stack *next;  /* for chaining to the next stack frame */
  const char *fname;      /* copied from input when frame is made */
  int lineno;             /* similarly */
  int if_succeeded;       /* true if a leg of this if-group
                             has been passed through rescan */
  enum node_type type;    /* type of last directive seen in this group */
} IF_STACK_FRAME;
static IF_STACK_FRAME *if_stack = NULL;

/* Nonzero means -I- has been seen,
   so don't look for #include "foo" the source-file directory. */
static int ignore_srcdir;

static U_CHAR *lexptr, *lexend;
static int skip_evaluation, unget_ch;
static HOST_WIDEST_INT yylval;

/* This structure represents one parsed argument in a macro call.
   `raw' points to the argument text as written (`raw_length' is its length).
   `expanded' points to the argument's macro-expansion
   (its length is `expand_length').
   `stringified_length' is the length the argument would have
   if stringified.
   `use_count' is the number of times this macro arg is substituted
   into the macro. If the actual use count exceeds 10,
   the value stored is 10.
   `free1' and `free2', if nonzero, point to blocks to be freed
   when the macro argument data is no longer needed. */
struct argdata
{
  U_CHAR *raw, *expanded;
  int raw_length, expand_length;
  int stringified_length;
  U_CHAR *free1, *free2;
  char newlines;
  char use_count;
};

static int safe_read (int, char *, int);
static void safe_write (const char *, int, char *, int);
static void newline_fix (U_CHAR *);
static void name_newline_fix (U_CHAR *);
static void warn_mixed_comment (void);
static void warn_nested_comment (void);
static U_CHAR *skip_one_comment (U_CHAR *, U_CHAR *, int *, int);
static void rescan (FILE_BUF *, int);
static FILE_BUF expand_to_temp_buffer (U_CHAR *, U_CHAR *, int);
static char *check_negative_option (const char *, size_t, int, int *);
static int is_dialect_option (const char *);
static void remove_option (const char *);
static int handle_option (const char *);
static int handle_directive (FILE_BUF *, FILE_BUF *, int);
static void handle_pascal_directive (FILE_BUF *, FILE_BUF *, U_CHAR *);
static void special_symbol (HASHNODE *, FILE_BUF *);
static int open_input_file (int, FILE_BUF *);
static void finclude (int, char *, FILE_BUF *, struct file_name_list *);
static MACRODEF create_definition (U_CHAR *, U_CHAR *, FILE_BUF *);
static int check_macro_name (U_CHAR *, const char *);
static int compare_defs (DEFINITION *, DEFINITION *);
static DEFINITION *collect_expansion  (U_CHAR *, U_CHAR *, int, struct arglist *);
enum tokens { EOT = 257, INTCST, False, True, NE, LE, GE, OR, XOR, LSH, RSH, AND };
static int yylex (void);
static HOST_WIDEST_INT factor (void);
static HOST_WIDEST_INT term (void);
static HOST_WIDEST_INT simple_exp (void);
static HOST_WIDEST_INT expr (void);
static int eval_if_expression (U_CHAR *, int);
static void conditional_skip (FILE_BUF *, int, enum node_type);
static void skip_if_group (FILE_BUF *, int);
static U_CHAR *skip_to_end_of_comment (FILE_BUF *, int *, int);
static const U_CHAR *skip_quoted_string (const U_CHAR *, const U_CHAR *, int, int *, int *, int *);
static char *quote_string (char *, const char *);
enum file_change_code {same_file, enter_file, leave_file};  /* Last arg to output_line_directive. */
static void output_line_directive (FILE_BUF *, FILE_BUF *, int, enum file_change_code);
static void macroexpand (HASHNODE *, FILE_BUF *);
static const char *macarg (struct argdata *, int);
static U_CHAR *macarg1 (U_CHAR *, U_CHAR *, int *, int *, int *, int);
static int discard_comments (U_CHAR *, int, int);
static int change_newlines (U_CHAR *, int);
static void gpc_warning (const char *, ...) ATTRIBUTE_PRINTF_1;
static void error (const char *, ...) ATTRIBUTE_PRINTF_1;
static void verror (const char *, va_list);
static void error_from_errno (const char *);
static void vwarning (const char *, va_list);
static void error_with_line (int, const char *, ...) ATTRIBUTE_PRINTF_2;
static void pedwarn (const char *, ...) ATTRIBUTE_PRINTF_1;
static void pedwarn_with_file_and_line (const char *, int, const char *, ...) ATTRIBUTE_PRINTF_3;
static void print_containing_files (void);
static int line_for_error (int);
static int grow_outbuf (FILE_BUF *, int);
static HASHNODE *install (U_CHAR *, int, enum node_type, char *, int, int);
static HASHNODE *lookup (U_CHAR *, int, int);
static void delete_macro (HASHNODE *);
static int hashf (U_CHAR *, int, int);
static void initialize_builtins (void);
static void make_undef (char *, FILE_BUF *);
static void append_include_chain (struct file_name_list *, struct file_name_list *);
static void perror_with_name (const char *);
static void pfatal_with_name (const char *) ATTRIBUTE_NORETURN;
static void pipe_closed (int) ATTRIBUTE_NORETURN;
extern int main (int, char **);

static void fatal (const char *, ...) ATTRIBUTE_PRINTF_1 ATTRIBUTE_NORETURN;

#ifndef EGCS
static const char *xstrerror (int);
#endif
#ifndef EGCS97
extern PTR xmalloc (size_t);
extern PTR xrealloc (PTR, size_t);
extern PTR xcalloc (size_t, size_t);
#endif

/* Check if a `(*' or `//' (if enabled) comment starts at p */
#define IS_COMMENT_START(p) ((*(p) == '(' && (p)[1] == '*') \
                             || (delphi_comments && *(p) == '/' && (p)[1] == '/'))

/* Check if a `(*' or `{' comment starts at p */
#define IS_COMMENT_START2(p) ((*(p) == '(' && (p)[1] == '*') || (*(p) == '{'))

/* Read LEN bytes at PTR from descriptor DESC, for file FILENAME,
   retrying if necessary. Return a negative value if an error occurs,
   otherwise return the actual number of bytes read,
   which must be LEN unless end-of-file was reached. */
static int
safe_read (int desc, char *ptr, int len)
{
  int left = len;
  while (left > 0)
  {
    int nchars = read (desc, ptr, left);
    if (nchars < 0)
      {
#ifdef EINTR
        if (errno == EINTR)
          continue;
#endif
        return nchars;
      }
    if (nchars == 0)
      break;
    ptr += nchars;
    left -= nchars;
  }
  return len - left;
}

/* Write LEN bytes at PTR to descriptor DESC,
   retrying if necessary, and treating any real error as fatal. */
static void
safe_write (const char * out_fname, int desc, char *ptr, int len)
{
  while (len > 0)
  {
    int written = write (desc, ptr, len);
    if (written < 0)
      {
#ifdef EINTR
        if (errno == EINTR)
          continue;
#endif
        pfatal_with_name (out_fname);
      }
    ptr += written;
    len -= written;
  }
}

/* Stores into *is_negative_p (if not NULL) whether option is negative.
   Returns a newly allocated string. If make_positive is zero, it
   contains option negated, otherwise it contains the positive version
   of option, whether or not options was positive or negative. */
#define NEGATION "no-"
static char *
check_negative_option (const char *option, size_t length, int make_positive, int *is_negative_p)
{
  char *result;
  int is_negative = length >= 2 + strlen (NEGATION)
                    && !strncmp (option + 2, NEGATION, strlen (NEGATION));
  if (is_negative_p)
    *is_negative_p = is_negative;
  if (is_negative)
    {
      result = (char *) xmalloc (length - strlen (NEGATION) + 1);
      result[0] = option[0];
      result[1] = option[1];
      strncpy (result + 2, option + 2 + strlen (NEGATION), length - 2 - strlen (NEGATION));
      result[length - strlen (NEGATION)] = 0;
    }
  else if (make_positive)
    {
      result = (char *) xmalloc (length + 1);
      strncpy (result, option, length);
      result[length] = 0;
    }
  else
    {
      result = (char *) xmalloc (length + strlen (NEGATION) + 1);
      result[0] = option[0];
      result[1] = option[1];
      strncpy (result + 2, NEGATION, strlen (NEGATION));
      strncpy (result + 2 + strlen (NEGATION), option + 2, length - 2);
      result[length + strlen (NEGATION)] = 0;
    }
  return result;
}

static int
is_dialect_option (const char *option)
{
  const char *const *dialect_option = dialect_options;
  while (*dialect_option && strcmp (*dialect_option, option) != 0)
    dialect_option++;
  return *dialect_option != NULL;
}

static void
remove_option (const char *option)
{
  struct option_list *po, **ppo;
  ppo = &current_options;
  while (*ppo && strcmp ((*ppo)->option, option) != 0)
    ppo = &((*ppo)->next);
  if (*ppo)
    {
      po = *ppo;
      *ppo = po->next;
      free (po);
    }
}

static int
handle_option (const char *option)
{
  const struct lang_option_map *map = lang_option_map;
  const char *p, *name = option + 2, *temp, *const *dialect_option;
  char *positive_option;
  int j, is_negative;
  size_t length;
  struct option_list *po;

  /* Handle implications between options */
  while (*map->src)
    {
      const char **src = map->src;
      while (*src && strcmp (*src, option) != 0)
        src++;
      if (*src)
        {
          const char **dest = map->dest;
          while (*dest)
            handle_option (*dest++);
        }
      map++;
    }

  /* If this is a dialect option, forget about any other dialect options */
  if (is_dialect_option (option))
    for (dialect_option = dialect_options; *dialect_option; dialect_option++)
      if (strcmp (*dialect_option, option) != 0)
        remove_option (*dialect_option);

  /* If this is a negative option, forget about the corresponding
     positive option, otherwise remember this option for `ifopt'. */
  p = name;
  while (*p && *p != '=' && *p != ':' && *p != ' ' && *p != '\t' && *p != '\n' && *p != '\r')
    p++;
  positive_option = check_negative_option (option, p - option, 1, &is_negative);
  if (is_negative)
    {
      remove_option (positive_option);
      free (positive_option);
    }
  else
    {
      po = current_options;
      while (po && strcmp (po->option, positive_option) != 0)
        po = po->next;
      if (!po)
        {
          po = (struct option_list *) xmalloc (sizeof (struct option_list));
          po->next = current_options;
          po->option = positive_option;
          current_options = po;
        }
      else
        free (positive_option);
    }

  /* Handle those options that directly affect the preprocessor */
  if (option[0] == '-')
    switch (option[1])
    {
      case 'f':
        if (!strcmp (name, "macros"))
          no_macros = 0;
        else if (!strcmp (name, "no-macros"))
          no_macros = 1;
        else if (!strcmp (name, "mixed-comments"))
          mixed_comments = 1;
        else if (!strcmp (name, "no-mixed-comments"))
          mixed_comments = 0;
        else if (!strcmp (name, "nested-comments"))
          nested_comments = 1;
        else if (!strcmp (name, "no-nested-comments"))
          nested_comments = 0;
        else if (!strcmp (name, "delphi-comments"))
          delphi_comments = 1;
        else if (!strcmp (name, "no-delphi-comments"))
          delphi_comments = 0;
        else if (!strcmp (name, "borland-pascal")
                 || !strcmp (name, "delphi"))
          bp_dialect = 1;
        else if (!strcmp (name, "gnu-pascal"))
          bp_dialect = 0;
        else if (!strcmp (name, "pedantic"))
          pedantic = 1;
        else if (!strcmp (name, "no-pedantic"))
          pedantic = 0;
        else
          break;
        return 1;

      case 'W':
        if (!strcmp (name, "warnings"))
          inhibit_warnings = 0;
        else if (!strcmp (name, "no-warnings"))
          inhibit_warnings = 1;
        else if (!strcmp (name, "error"))
          warnings_are_errors = 1;
        else if (!strcmp (name, "no-error"))
          warnings_are_errors = 0;
        else if (!strcmp (name, "mixed-comments"))
          warn_mixed_comments = 1;
        else if (!strcmp (name, "no-mixed-comments"))
          warn_mixed_comments = 0;
        else if (!strcmp (name, "nested-comments"))
          warn_nested_comments = 1;
        else if (!strcmp (name, "no-nested-comments"))
          warn_nested_comments = 0;
        else if (!strcmp (name, "float-equal") || !strcmp (name, "no-float-equal"))
          ;
        else
          break;
        return 1;
    }
  length = strlen (option);
  j = 0;
  while ((temp = gpc_options[j].name) != NULL
         && (strlen (temp) != length || strncmp (temp, option, length) != 0))
    j++;
  return temp && gpc_options[j].source;
}

static int
open_input_file (int f, FILE_BUF *fp)
{
  struct stat sbuf;
  if (fstat (f, &sbuf) < 0)
    {
      perror_with_name (fp->fname);
      return 0;
    }
  if (S_ISDIR (sbuf.st_mode)) {
    error ("trying to read directory `%s'", fp->fname);
    return 0;
  } else if (S_ISREG (sbuf.st_mode)) {
    /* Read a file whose size we can determine in advance.
       For the sake of VMS, st_size is just an upper bound. */
    fp->buf = (U_CHAR *) xmalloc (sbuf.st_size + 2);
    fp->length = safe_read (f, (char *) fp->buf, sbuf.st_size);
    if (fp->length < 0) {
      perror_with_name (fp->fname);
      return 0;
    }
  } else {
    /* Read input from a file that is not a normal disk file.
       We cannot preallocate a buffer with the correct size,
       so we must read in the file a piece at a time and make it bigger. */
    int size = 0, bsize = 2000, cnt;
    fp->buf = (U_CHAR *) xmalloc (bsize + 2);
    for (;;) {
      cnt = safe_read (f, (char *) fp->buf + size, bsize - size);
      if (cnt < 0) {
        perror_with_name (fp->fname);
        return 0;
      }
      size += cnt;
      if (size != bsize) break;  /* end of file */
      bsize *= 2;
      fp->buf = (U_CHAR *) xrealloc (fp->buf, bsize + 2);
    }
    fp->length = size;
  }
  fp->bufp = fp->buf;
  fp->lineno = 1;
  /* Make sure data ends with a newline. And put a null after it. */
  if ((fp->length > 0 && fp->buf[fp->length - 1] != '\n')
      /* Backslash-newline at end is not good enough. */
      || (fp->length > 1 && fp->buf[fp->length - 2] == '\\'))
    fp->buf[fp->length++] = '\n';
  fp->buf[fp->length] = '\0';
  return 1;
}

static char **pend_includes = 0;
static int gpcpp_argc;
static FILE_BUF *fp;
int
gpcpp_process_options (int argc, char **argv)
{
  const char /* *in_fname, */ *cp;
  int inhibit_output = 0, verbose = 0, i;
  char **pend_defs = (char **) xmalloc (argc * sizeof (char *));
  int *pend_defs_case_sensitive = (int *) xmalloc (argc * sizeof (int));
  char **pend_undefs = (char **) xmalloc (argc * sizeof (char *));
  /* Non-0 means don't output the preprocessed program. */
  const char *const *option;
  char tmp_buf[256];

#ifdef RLIMIT_STACK
  /* Get rid of any avoidable limit on stack size, so alloca does not fail. */
  struct rlimit rlim;
  getrlimit (RLIMIT_STACK, &rlim);
  rlim.rlim_cur = rlim.rlim_max;
  setrlimit (RLIMIT_STACK, &rlim);
#endif

  pend_includes = (char **) xmalloc (argc * sizeof (char *));
  gpcpp_argc = argc;

#ifdef SIGPIPE
  signal (SIGPIPE, pipe_closed);
#endif

  cp = argv[0] + strlen (argv[0]);
  while (cp != argv[0] && !IS_DIR_SEPARATOR (cp[-1]))
    --cp;
  progname = cp;

  no_line_directives = 0;
  no_output = 0;
  delphi_comments = 0;

  memset ((char *) pend_defs, 0, argc * sizeof (char *));
  memset ((char *) pend_defs_case_sensitive, 0, argc * sizeof (int));
  memset ((char *) pend_undefs, 0, argc * sizeof (char *));
  memset ((char *) pend_includes, 0, argc * sizeof (char *));

  option = default_options;
  while (*option)
    handle_option (*option++);

  /* Process switches and find input file name. */

  for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      switch (argv[i][1]) {

      case 'i':
        if (!strcmp (argv[i], "-include")) {
          if (i + 1 == argc)
            fatal ("filename missing after `-include' option");
          else
            pend_includes[i] = argv[i+1], i++;
        } else if (!strcmp (argv[i], "-imacros"))
          i++;
        else if (!strcmp (argv[i], "-iprefix")) {
          if (i + 1 == argc)
            fatal ("filename missing after `-iprefix' option");
          else
            include_prefix = argv[++i];
        } else if (!strcmp (argv[i], "-isystem")) {
          struct file_name_list *dirtmp;
          char *s;
          if (i + 1 == argc)
            fatal ("filename missing after `-isystem' option");
          dirtmp = (struct file_name_list *) xmalloc (sizeof (struct file_name_list));
          dirtmp->next = 0;
          s = (char *) xmalloc (strlen (argv[i + 1]) + 1);
          strcpy (s, argv[++i]);
          dirtmp->fname = s;
        } else if (!strcmp (argv[i], "-iwithprefix")) {
          /* Add directory to end of path for includes,
             with the default prefix at the front of its name. */
          struct file_name_list *dirtmp;
          const char *prefix = include_prefix ? include_prefix : "";
          char *s;
          dirtmp = (struct file_name_list *) xmalloc (sizeof (struct file_name_list));
          dirtmp->next = 0;  /* New one goes on the end */
          if (i + 1 == argc)
            fatal ("directory name missing after `-iwithprefix' option");

          s = (char *) xmalloc (strlen (argv[i + 1]) + strlen (prefix) + 1);
          strcpy (s, prefix);
          strcat (s, argv[++i]);
          dirtmp->fname = s;

          if (!after_include)
            after_include = dirtmp;
          else
            last_after_include->next = dirtmp;
          last_after_include = dirtmp;  /* Tail follows the last one */
        } else if (!strcmp (argv[i], "-iwithprefixbefore")) {
          /* Add directory to main path for includes,
             with the default prefix at the front of its name. */
          struct file_name_list *dirtmp;
          const char *prefix = include_prefix ? include_prefix : "";
          char *s;
          dirtmp = (struct file_name_list *) xmalloc (sizeof (struct file_name_list));
          dirtmp->next = 0;  /* New one goes on the end */
          if (i + 1 == argc)
            fatal ("directory name missing after `-iwithprefixbefore' option");
          s = (char *) xmalloc (strlen (argv[i + 1]) + strlen (prefix) + 1);
          strcpy (s, prefix);
          strcat (s, argv[++i]);
          dirtmp->fname = s;
          append_include_chain (dirtmp, dirtmp);
        } else if (!strcmp (argv[i], "-idirafter")) {
          /* Add directory to end of path for includes. */
          struct file_name_list *dirtmp;
          dirtmp = (struct file_name_list *) xmalloc (sizeof (struct file_name_list));
          dirtmp->next = 0;  /* New one goes on the end */
          if (i + 1 == argc)
            fatal ("directory name missing after `-idirafter' option");
          else
            dirtmp->fname = argv[++i];
          if (!after_include)
            after_include = dirtmp;
          else
            last_after_include->next = dirtmp;
          last_after_include = dirtmp; /* Tail follows the last one */
        } else
          goto option_error;
        break;

      case 'p':
        if (!strcmp (argv[i], "-pedantic"))
          pedantic = 1;
        else if (!strcmp (argv[i], "-pedantic-errors")) {
          pedantic = 1;
          pedantic_errors = 1;
        } else
          goto option_error;
        break;

      case 'w':
        inhibit_warnings = 1;
        break;

      case 'f':
        if (!strncmp (argv[i], "-fcidefine", strlen ("-fcidefine")))
          {
            char *p = argv[i] + strlen ("-fcidefine");
            if (*p != '=' || p[1] == 0)
              fatal ("macro name missing after `--cidefine' option");
            pend_defs[i] = p + 1;
            pend_defs_case_sensitive[i] = 0;
            break;
          }
        if (!strncmp (argv[i], "-fcsdefine", strlen ("-fcsdefine")))
          {
            char *p = argv[i] + strlen ("-fcsdefine");
            if (*p != '=' || p[1] == 0)
              fatal ("macro name missing after `--csdefine' option");
            pend_defs[i] = p + 1;
            pend_defs_case_sensitive[i] = 1;
            break;
          }
        /* FALLTHROUGH */
      case 'W':
        handle_option (argv[i]);
        break;

      case 'D':
        if (argv[i][2] != 0)
          pend_defs[i] = argv[i] + 2;
        else if (i + 1 == argc)
          fatal ("macro name missing after `-D' option");
        else
          i++, pend_defs[i] = argv[i];
        pend_defs_case_sensitive[i] = 1;
        break;

      case 'M':
        inhibit_output = 1;
        if (!strcmp (argv[i], "-M"))
          print_deps = 1;
        else
          goto option_error;
        break;

      case '-':
        if (strcmp (argv[i], "--help"))
          goto option_error;
      case 'v':
        if (!argv[i][2])
          fprintf (stderr, "GNU Pascal Compiler PreProcessor version %s, based on gcc-%s", GPC_RELEASE_STRING, version_string);
#ifdef TARGET_VERSION
        TARGET_VERSION;
#endif
        fprintf (stderr, "\n");
        verbose = 1;
        break;

      case 'H':
        print_include_names = 1;
        break;

      case 'A':  /* ignore `-A...' options */
        break;

      case 'U':
        if (argv[i][2] != 0)
          pend_undefs[i] = argv[i] + 2;
        else if (i + 1 == argc)
          fatal ("macro name missing after `-U' option");
        else
          pend_undefs[i] = argv[i+1], i++;
        break;

      case 'P':
        no_line_directives = 1;
        break;

      case 'I':  /* Add directory to path for includes. */
        {
          struct file_name_list *dirtmp;
          if (!ignore_srcdir && !strcmp (argv[i] + 2, "-"))
          {
            ignore_srcdir = 1;
            /* Don't use any preceding -I directories for #include <...>. */
            first_bracket_include = 0;
          }
          else
          {
            dirtmp = (struct file_name_list *) xmalloc (sizeof (struct file_name_list));
            dirtmp->next = 0;  /* New one goes on the end */
            if (argv[i][2] != 0)
              dirtmp->fname = argv[i] + 2;
            else if (i + 1 == argc)
              fatal ("directory name missing after `-I' option");
            else
              dirtmp->fname = argv[++i];
            append_include_chain (dirtmp, dirtmp);
          }
        }
        break;

      case 'r':
        if (strcmp (argv[i], "-remap") != 0)
          goto option_error;
        break;

      case 'd':
        if (strcmp (argv[i], "-dD") != 0)
          goto option_error;
        break;

      case 'n':
        if (strncmp (argv[i], "-nostdinc", 9) != 0)
          goto option_error;
        break;

      case 'q':
        if (strncmp (argv[i], "-quiet", 6) != 0)
          goto option_error;
        break;

        /* FALLTHROUGH */
      default:
      option_error: ;
#if 0
        fatal ("invalid option `%s'", argv[i]);
#endif
      }
    }
  }

  /* Initialize output buffer */
  outbuf.buf = (U_CHAR *) xmalloc (OUTBUF_SIZE);
  outbuf.bufp = outbuf.buf;
  outbuf.length = OUTBUF_SIZE;

  /* Do partial setup of input buffer for the sake of generating
     early #line directives (when -g is in effect). */
  fp = &instack[++indepth];

  /* Install __LINE__, etc. Must follow initialize_char_syntax and option processing. */
  initialize_builtins ();

  strcat (strcpy (tmp_buf, "__GPC__="), GPC_MAJOR);
  make_definition (tmp_buf, 1);
  strcat (strcpy (tmp_buf, "__GPC_MINOR__="), GPC_MINOR);
  make_definition (tmp_buf, 1);
  strcat (strcat (strcat (strcpy (tmp_buf, "__GPC_VERSION__="), GPC_MAJOR), "."), GPC_MINOR);
  make_definition (tmp_buf, 1);
  strcat (strcpy (tmp_buf, "__GPC_RELEASE__="), GPC_VERSION_STRING);
  make_definition (tmp_buf, 1);

  /* Now handle the command line options. */
  /* Do -U's and -D's in the order they were seen. */
  for (i = 1; i < argc; i++)
  {
    if (pend_undefs[i])
      make_undef (pend_undefs[i], &outbuf);
    if (pend_defs[i])
    {
      int c;
      char *p = pend_defs[i];
      make_definition (p, pend_defs_case_sensitive[i]);
#ifndef GCC_3_3 
      if ((!strncmp (p, "MSDOS", c = 5) ||
           !strncmp (p, "_WIN32", c = 6) ||
           !strncmp (p, "__EMX__", c = 7))
          && (p[c] == 0 || p[c] == '='))
        make_definition ("__OS_DOS__=1", 1);
#endif
    }
  }

  /* Tack the after_include chain at the end of the include chain. */
  append_include_chain (after_include, last_after_include);

  /* With -v, print the list of include dirs to search. */
  if (verbose && include)
  {
    struct file_name_list *p;
    fprintf (stderr, "{$include \"...\"} search starts here:\n");
    for (p = include; p; p = p->next)
    {
      if (p == first_bracket_include)
        fprintf (stderr, "{$include <...>} search starts here:\n");
      fprintf (stderr, " %s\n", p->fname);
    }
    fprintf (stderr, "End of search list.\n");
  }
  return 0;
}

int
gpcpp_main (const char *filename, FILE * in_file)
{
  int i;
  /* Copy the entire contents of the main input file into
     the stacked input buffer previously allocated for it. */

  fp->nominal_fname = fp->fname = filename;
  if (!open_input_file (fileno (in_file), fp))
    return 1;
  fp->if_stack = if_stack;

  output_line_directive (fp, &outbuf, 0, same_file);

  /* Scan the -include files before the main input. */
  no_record_file++;
  for (i = 1; i < gpcpp_argc; i++)
    if (pend_includes[i]) {
      int fd = open (pend_includes[i], O_RDONLY, 0666);
      if (fd < 0) {
        perror_with_name (pend_includes[i]);
        return FATAL_EXIT_CODE;
      }
      finclude (fd, pend_includes[i], &outbuf, NULL);
    }
  no_record_file--;

  /* Scan the input, processing macros and directives. */
  rescan (&outbuf, 0);

  /* Now we have processed the entire input. */

  if (local_options_stack)
    error ("missing `$endlocal'");
  if (errors)
    exit (FATAL_EXIT_CODE);
  return errors;
}

int
gpcpp_writeout (const char *out_filename, FILE * out_file)
{
  safe_write (out_filename, fileno (out_file),
               (char *) outbuf.buf, outbuf.bufp - outbuf.buf);
  if (ferror (out_file) || fclose (out_file) != 0)
    fatal ("I/O error on output");
  return errors;
}

int 
gpcpp_fillbuf(char * buf, int max_size)
{
  static char * p = 0;
  int res;
  if (!p) {
    p = (char *) outbuf.buf;
  }
  res = (char *) outbuf.bufp - p > max_size ? max_size : 
        (char *) outbuf.bufp - p;
  memcpy (buf, p, res);
  p += res;
  return res;
}

/* Move all backslash-newline pairs out of embarrassing places.
   Exchange all such pairs following BP
   with any potentially-embarrassing characters that follow them.
   Potentially-embarrassing characters are / and *
   (because a backslash-newline inside a comment delimiter
   would cause it not to be recognized). */
static void
newline_fix (U_CHAR *bp)
{
  U_CHAR *p = bp;
  /* First count the backslash-newline pairs here. */
  while (p[0] == '\\' && p[1] == '\n')
    p += 2;
  /* What follows the backslash-newlines is not embarrassing. */
  if (*p != '(' && *p != ')' && *p != '*')
    return;
  /* Copy all potentially embarrassing characters
     that follow the backslash-newline pairs
     down to where the pairs originally started. */
  while (*p == '*' || *p == '(' || *p == ')')
    *bp++ = *p++;
  /* Now write the same number of pairs after the embarrassing chars. */
  while (bp < p) {
    *bp++ = '\\';
    *bp++ = '\n';
  }
}

/* Like newline_fix but for use within a directive-name.
   Move any backslash-newlines up past any following symbol constituents. */
static void
name_newline_fix (U_CHAR *bp)
{
  U_CHAR *p = bp;
  /* First count the backslash-newline pairs here. */
  while (p[0] == '\\' && p[1] == '\n')
    p += 2;
  /* What follows the backslash-newlines is not embarrassing. */
  if (!is_idchar[*p])
    return;
  /* Copy all potentially embarrassing characters
     that follow the backslash-newline pairs
     down to where the pairs originally started. */
  while (is_idchar[*p])
    *bp++ = *p++;
  /* Now write the same number of pairs after the embarrassing chars. */
  while (bp < p) {
    *bp++ = '\\';
    *bp++ = '\n';
  }
}

static void
warn_mixed_comment (void)
{
  if (warn_mixed_comments && !inhibit_warnings)
    {
      gpc_warning ("comments starting with `(*' and ending with `}' or starting with");
      gpc_warning (" `{' and ending with `*)' are an obscure ISO Pascal feature");
    }
}

static void
warn_nested_comment (void)
{
  if (warn_nested_comments && !inhibit_warnings)
    gpc_warning (nested_comments ? "nested comments are a GPC extension" : "comment opener found within comment");
}

/* Skip the (non-`//') comment starting at bp, handling C, Pascal,
   mixed and nested comments if wanted. Count newlines in lineno if
   not NULL. limit, if not NULL, gives the maximum end of the
   comment. */
static U_CHAR *
skip_one_comment (U_CHAR *bp, U_CHAR *limit, int *lineno, int fix_newlines)
{
  int comment_count = 1, comment1 = 2, comment2 = 2;
  if (*bp == '{')
    {
      bp++;
      comment2 = mixed_comments;
    }
  else
    {
      bp += 2;
      comment1 = mixed_comments;
    }
  while (*bp && comment_count != 0 && (!limit || bp < limit))
    {
      U_CHAR bp1 = (!limit || bp + 1 < limit) ? bp[1] : 0;
      if (fix_newlines && bp1 == '\\' && (!limit || bp + 2 < limit) && bp[2] == '\n')
        newline_fix (bp + 1);
      if (comment2 && *bp == '*' && bp1 == ')')
        {
          if (comment2 == 1) warn_mixed_comment ();
          comment_count--;
          bp += 2;
        }
      else if (comment1 && *bp == '}')
        {
          if (comment1 == 1) warn_mixed_comment ();
          comment_count--;
          bp++;
        }
      else if (comment2 && *bp == '(' && bp1 == '*' && !((!limit || bp + 2 < limit) && bp[2] == ')'))
        {
          warn_nested_comment ();
          if (nested_comments)
            {
              if (comment2 == 1) warn_mixed_comment ();
              comment_count++;
            }
          bp += 2;
        }
      else if (comment1 && *bp == '{')
        {
          warn_nested_comment ();
          if (nested_comments)
            {
              if (comment1 == 1) warn_mixed_comment ();
              comment_count++;
            }
          bp++;
        }
      else
        {
          if (*bp == '\n' && lineno)
            (*lineno)++;
          bp++;
        }
    }
  return bp;
}

/* The main loop of the program.

   Read characters from the input stack, transferring them to the
   output buffer OP.

   Macros are expanded and push levels on the input stack.
   At the end of such a level it is popped off and we keep reading.
   At the end of any other kind of level, we return.

   If OUTPUT_MARKS is nonzero, keep Newline markers found in the input
   and insert them when appropriate. This is set while scanning macro
   arguments before substitution. It is zero when scanning for final output.

   There are three types of Newline markers:
   - Newline -- follows a macro name that was not expanded
     because it appeared inside an expansion of the same macro.
     This marker prevents future expansion of that identifier.
     When the input is rescanned into the final output, these are deleted.
     These are also deleted by ## concatenation.
   - Newline Space (or Newline and any other whitespace character)
     stands for a place that tokens must be separated or whitespace
     is otherwise desirable, but where the ANSI standard specifies there
     is no whitespace. This marker turns into a Space (or whichever other
     whitespace char appears in the marker) in the final output,
     but it turns into nothing in an argument that is stringified with #.
     Such stringified arguments are the only place where the ANSI standard
     specifies with precision that whitespace may not appear.

   During this function, IP->bufp is kept cached in IBP for speed of access.
   Likewise, OP->bufp is kept in OBP. Before calling a subroutine
   IBP, IP and OBP must be copied back to memory. IP and IBP are
   copied back with the RECACHE macro. OBP must be copied back from OP->bufp
   explicitly, and before RECACHE, since RECACHE uses OBP. */
static void
rescan (FILE_BUF *op, int output_marks)
{
  U_CHAR c;  /* Character being scanned in main loop. */
  int ident_length = 0;  /* Length of pending accumulated identifier. */
  int hash = 0;   /* Hash code of pending accumulated identifier. */
  FILE_BUF *ip;   /* Current input level (&instack[indepth]). */
  U_CHAR *ibp;    /* Pointer for scanning input. */
  U_CHAR *limit;  /* Pointer to end of input. End of scan is controlled by LIMIT. */
  U_CHAR *obp;    /* Pointer for storing output. */
  /* REDO_CHAR is nonzero if we are processing an identifier
     after backing up over the terminating character.
     Sometimes we process an identifier without backing up over
     the terminating character, if the terminating character
     is not special. Backing up is done so that the terminating character
     will be dispatched on again once the identifier is dealt with. */
  int redo_char = 0;
  /* 1 if within an identifier inside of which a concatenation
     marker (Newline -) has been seen. */
  int concatenated = 0;
  /* While scanning a comment or a string constant,
     this records the line it started on, for error messages. */
  int start_line;
  U_CHAR *beg_of_line;  /* Record position of last "real" newline. */

/* Pop the innermost input stack level, assuming it is a macro expansion. */
#define POPMACRO \
do \
{ \
  ip->macro->type = T_MACRO; \
  if (ip->free_ptr) free (ip->free_ptr); \
  --indepth; \
} while (0)

/* Reload `rescan's local variables that describe the current
   level of the input stack. */
#define RECACHE  \
do { \
  ip = &instack[indepth]; \
  ibp = ip->bufp; \
  limit = ip->buf + ip->length; \
  op->bufp = obp; \
  check_expand (op, limit - ibp); \
  beg_of_line = 0; \
  obp = op->bufp; \
} while (0)

  if (no_output && instack[indepth].fname != 0)
    skip_if_group (&instack[indepth], 1);

  obp = op->bufp;
  RECACHE;

  beg_of_line = ibp;

  /* Our caller must always put a null after the end of the input at each input stack level. */
  if (*limit != 0)
    abort ();

  while (1) {
    c = *ibp++;
    *obp++ = c;

    switch (c) {

    case '^':
      if (*ibp == '\'' || *ibp == '"')
        *obp++ = *ibp++;
      break;

    case '\\':
      if (*ibp == '\n' && !ip->macro) {
        /* At the top level, always merge lines ending with backslash-newline,
           even in middle of identifier. But do not merge lines in a macro,
           since backslash might be followed by a newline-space marker. */
        ++ibp;
        ++ip->lineno;
        --obp;  /* remove backslash from obuf */
        break;
      }
      /* If ANSI, backslash is just another character outside a string. */
      goto randomchar;

    case '#':
      /* If this is expanding a macro definition, don't recognize directives. */
      if (ip->macro != 0)
        goto randomchar;
      /* If this is expand_into_temp_buffer, don't recognize them either. Warn about them
         only after an actual newline at this level, not at the beginning of the input level. */
      if (!ip->fname) {
            /* note BP character constants */
        if (ip->buf != beg_of_line && ((*ibp < '0' || *ibp > '9') && *ibp != '$'))
          gpc_warning ("preprocessing directive not recognized within macro arg");
        goto randomchar;
      }
      if (ident_length)
        goto specialchar;
      /* # keyword: a # must be first nonblank char on the line */
      if (beg_of_line == 0)
        goto randomchar;
      {
        U_CHAR *bp;

        /* Scan from start of line, skipping whitespace, comments
           and backslash-newlines, and see if we reach this #.
           If not, this # is not special. */
        bp = beg_of_line;
        while (1) {
          if (is_hor_space[*bp])
            bp++;
          else if (*bp == '\\' && bp[1] == '\n')
            bp += 2;
          else if (IS_COMMENT_START2 (bp))
            bp = skip_one_comment (bp, NULL, NULL, 0);
          /* There is no point in trying to deal with `//' comments here,
             because if there is one, then this # must be part of the
             comment and we would never reach here. */
          else break;
        }
        if (bp + 1 != ibp)
          goto randomchar;
      }
      /* This # can start a directive. */
      --obp;  /* Don't copy the '#' */
      ip->bufp = ibp;
      op->bufp = obp;
      if (!handle_directive (ip, op, 0)) {
#ifdef USE_C_ALLOCA
        alloca (0);
#endif
        /* Not a known directive: treat it as ordinary text.
           IP, OP, IBP, etc. have not been changed. */
        if (no_output && instack[indepth].fname) {
          /* If not generating expanded output, skip ordinary text.
             Discard everything until next # directive. */
          skip_if_group (&instack[indepth], 1);
          RECACHE;
          beg_of_line = ibp;
          break;
        }
        *obp++ = '#';
        /* Don't expand an identifier that could be a macro directive. */
        SKIP_WHITE_SPACE (ibp);
        if (is_idstart[*ibp])
          {
            *obp++ = *ibp++;
            while (is_idchar[*ibp])
              *obp++ = *ibp++;
          }
        goto randomchar;
      }
#ifdef USE_C_ALLOCA
      alloca (0);
#endif
      /* A # directive has been successfully processed. */
      /* If not generating expanded output, ignore everything until
         next # directive. */
      if (no_output && instack[indepth].fname)
        skip_if_group (&instack[indepth], 1);
      obp = op->bufp;
      RECACHE;
      beg_of_line = ibp;
      break;

    case '"':  /* skip quoted string */
    case '\'':
      if (ident_length)
        goto specialchar;

      start_line = ip->lineno;

      /* Skip ahead to a matching quote. */

      while (1) {
        if (ibp >= limit) {
          if (ip->macro != 0) {
            /* try harder: this string crosses a macro expansion boundary.
               Only command line options can make a macro with an unmatched quote. */
            POPMACRO;
            RECACHE;
            continue;
          }
          error_with_line (line_for_error (start_line), "unterminated string or character constant");
          /* @@ Should output the file name in case a previous string was in another file (when using include). */
          error_with_line (multiline_string_line, "possible real start of unterminated constant");
          multiline_string_line = 0;
          break;
        }
        *obp++ = *ibp;
        switch (*ibp++) {
        case '\n':
          ++ip->lineno;
          ++op->lineno;
          if (multiline_string_line == 0)
            multiline_string_line = ip->lineno - 1;
          break;

        case '\\':
          if (c == '\'')
            break;
          if (ibp >= limit)
            break;
          if (*ibp == '\n') {
            /* Backslash newline is replaced by nothing at all,
               but keep the line counts correct. */
            --obp;
            ++ibp;
            ++ip->lineno;
          } else {
            /* ANSI stupidly requires that in \\ the second \
               is *not* prevented from combining with a newline. */
            while (*ibp == '\\' && ibp[1] == '\n') {
              ibp += 2;
              ++ip->lineno;
            }
            *obp++ = *ibp++;
          }
          break;

        case '"':
        case '\'':
          if (ibp[-1] == c)
            goto while2end;
          break;
        }
      }
    while2end:
      break;

    case '{':
      if (ip->macro != 0)
        goto randomchar;
      if (ident_length)
        goto specialchar;

      start_line = ip->lineno;

      /* Comments are equivalent to spaces */
      obp[-1] = ' ';

      {
        U_CHAR *before_bp = ibp;
        U_CHAR *begin_pascal_directive = NULL;
        int comment_count = 1;

        while (ibp < limit) {
          switch (*ibp++) {
          case '{':
            warn_nested_comment ();
            if (nested_comments)
              comment_count++;
            break;
          case '(':
            if (*ibp == '\\' && ibp[1] == '\n')
              newline_fix (ibp);
            if (ibp < limit && *ibp == '*' && mixed_comments && !(ibp + 1 < limit && ibp[1] == ')'))
              {
                warn_nested_comment ();
                if (nested_comments)
                  {
                    warn_mixed_comment ();
                    comment_count++;
                  }
                ibp++;
              }
            break;
          case '*':
            if (*ibp == '\\' && ibp[1] == '\n')
              newline_fix (ibp);
            if (ibp < limit && *ibp == ')' && mixed_comments)
              {
                warn_mixed_comment ();
                ibp++;
                if (--comment_count == 0)
                  goto p_comment_end;
              }
            break;
          case '}':
            if (--comment_count == 0)
              goto p_comment_end;
            break;
          case '\n':
            ++ip->lineno;
            /* Copy the newline into the output buffer, in order to
               avoid the pain of a #line every time a multiline comment
               is seen. */
            if (!begin_pascal_directive)
              *obp++ = '\n';
            ++op->lineno;
            break;
          case '$':
            if (ibp == before_bp + 1)
              {
                obp[-1] = '{';
                begin_pascal_directive = ibp;
              }
            break;
          }
        }

      p_comment_end:

        if (comment_count != 0)
          error_with_line (line_for_error (start_line), "unterminated comment");
        else {
          /* Now ibp points to the first char after comment */
          if (begin_pascal_directive) {
            memcpy ((char *) obp, (char *) before_bp, ibp - before_bp);
            obp += ibp - before_bp;
          }
          if (begin_pascal_directive)
            {
              U_CHAR *save_ibp = ibp;
              U_CHAR *end_pascal_directive = ibp - (ibp[-1] == ')' ? 2 : 1);
              ip->bufp = begin_pascal_directive;
              op->bufp = obp;
              handle_pascal_directive (ip, op, end_pascal_directive);
              if (ip->bufp <= save_ibp)
                ip->bufp = save_ibp;
              obp = op->bufp;
              RECACHE;
            }
        }
      }
      break;

    case '/':
    case '(':
      if (*ibp == '\\' && ibp[1] == '\n')
        newline_fix (ibp);
      if (!IS_COMMENT_START (ibp - 1))
        goto randomchar;
      if (ip->macro != 0)
        goto randomchar;
      if (ident_length)
        goto specialchar;

      if (*ibp == '/') {
        /* `//' comment */
        start_line = ip->lineno;

        /* Comments are equivalent to spaces. */
        obp[-1] = ' ';

        while (++ibp < limit) {
          if (*ibp == '\n') {
            if (ibp[-1] != '\\')
              break;
            ++ip->lineno;
            /* Copy the newline into the output buffer, in order to
               avoid the pain of a #line every time a multiline comment
               is seen. */
            *obp++ = '\n';
            ++op->lineno;
          }
        }
        break;
      }

      /* Ordinary comment. */

      start_line = ip->lineno;

      ++ibp;  /* Skip the star. */

      /* Comments are equivalent to spaces.
         Note that we already output the slash; we might not want it. */
      obp[-1] = ' ';

      {
        U_CHAR *before_bp = ibp;
        U_CHAR *begin_pascal_directive = NULL;
        int comment_count = 1;

        while (ibp < limit) {
          switch (*ibp++) {
          case '{':
            if (mixed_comments)
              {
                warn_nested_comment ();
                if (nested_comments)
                  {
                    warn_mixed_comment ();
                    comment_count++;
                  }
              }
            break;
          case '}':
            if (mixed_comments)
              {
                warn_mixed_comment ();
                if (--comment_count == 0)
                  goto comment_end;
              }
            break;
          case '(':
            if (*ibp == '\\' && ibp[1] == '\n')
              newline_fix (ibp);
            if (*ibp == '*' && !(ibp + 1 < limit && ibp[1] == ')'))
              {
                warn_nested_comment ();
                if (nested_comments)
                  comment_count++;
                ibp++;
              }
            break;
          case '*':
            if (*ibp == '\\' && ibp[1] == '\n')
              newline_fix (ibp);
            if (ibp >= limit || (*ibp == ')' && --comment_count == 0))
              {
                ibp++;
                goto comment_end;
              }
            break;
          case '\n':
            ++ip->lineno;
            /* Copy the newline into the output buffer, in order to
               avoid the pain of a #line every time a multiline comment
               is seen. */
            if (!begin_pascal_directive)
              *obp++ = '\n';
            ++op->lineno;
            break;
          case '$':
            if (ibp == before_bp + 1)
              {
                obp[-1] = '(';
                *obp++ = '*';
                begin_pascal_directive = ibp;
              }
            break;
          }
        }
      comment_end:

        if (comment_count != 0)
          error_with_line (line_for_error (start_line), "unterminated comment");
        else {
          /* Now ibp points to the first char after comment */
          if (begin_pascal_directive) {
            memcpy ((char *) obp, (char *) before_bp, ibp - before_bp);
            obp += ibp - before_bp;
          }
          if (begin_pascal_directive)
            {
              U_CHAR *save_ibp = ibp;
              U_CHAR *end_pascal_directive = ibp - (ibp[-1] == ')' ? 2 : 1);
              ip->bufp = begin_pascal_directive;
              op->bufp = obp;
              handle_pascal_directive (ip, op, end_pascal_directive);
              if (ip->bufp <= save_ibp)
                ip->bufp = save_ibp;
              obp = op->bufp;
              RECACHE;
            }
        }
      }
      break;

    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
      /* If digit is not part of identifier, it starts a number,
         which means that following letters are not an identifier.
         "0x5" does not refer to an identifier "x5".
         So copy all alphanumerics that follow without accumulating
         as an identifier. Periods also, for sake of "3.e7". */

      if (ident_length == 0) {
        for (;;) {
          while (ibp[0] == '\\' && ibp[1] == '\n') {
            ++ip->lineno;
            ibp += 2;
          }
          c = *ibp++;
          if (!is_idchar[c] && c != '.') {
            --ibp;
            break;
          }
          *obp++ = c;
          /* A sign can be part of a preprocessing number
             if it follows an e. */
          if (c == 'e' || c == 'E') {
            while (ibp[0] == '\\' && ibp[1] == '\n') {
              ++ip->lineno;
              ibp += 2;
            }
            if (*ibp == '+' || *ibp == '-')
              *obp++ = *ibp++;
          }
        }
        break;
      }
      /* FALLTHROUGH */

    case '_':
    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
    case 'g': case 'h': case 'i': case 'j': case 'k': case 'l':
    case 'm': case 'n': case 'o': case 'p': case 'q': case 'r':
    case 's': case 't': case 'u': case 'v': case 'w': case 'x':
    case 'y': case 'z':
    case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
    case 'G': case 'H': case 'I': case 'J': case 'K': case 'L':
    case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R':
    case 'S': case 'T': case 'U': case 'V': case 'W': case 'X':
    case 'Y': case 'Z':
      ident_length++;
      /* Compute step of hash function, to avoid a proc call on every token */
      hash = HASHSTEP (hash, c);
      break;

    case '\n':
      if (ip->fname == 0 && *ibp == '-') {
        /* Newline - inhibits expansion of preceding token.
           If expanding a macro arg, we keep the newline -.
           In final output, it is deleted.
           We recognize Newline - in macro bodies and macro args. */
        if (!concatenated) {
          ident_length = 0;
          hash = 0;
        }
        ibp++;
        if (!output_marks)
          obp--;
        else {
          /* If expanding a macro arg, keep the newline -. */
          *obp++ = '-';
        }
        break;
      }

      /* If reprocessing a macro expansion, newline is a special marker. */
      else if (ip->macro != 0) {
        /* Newline White is a "funny space" to separate tokens that are
           supposed to be separate but without space between.
           Here White means any whitespace character.
           Newline - marks a recursive macro use that is not
           supposed to be expandable. */

        if (is_space[*ibp]) {
          /* Newline Space does not prevent expansion of preceding token
             so expand the preceding token and then come back. */
          if (ident_length > 0)
            goto specialchar;

          /* If generating final output, newline space makes a space. */
          if (!output_marks) {
            obp[-1] = *ibp++;
            /* And Newline Newline makes a newline, so count it. */
            if (obp[-1] == '\n')
              op->lineno++;
          } else {
            /* If expanding a macro arg, keep the newline space.
               If the arg gets stringified, newline space makes nothing. */
            *obp++ = *ibp++;
          }
        } else abort ();  /* Newline followed by something random? */
        break;
      }

      /* If there is a pending identifier, handle it and come back here. */
      if (ident_length > 0)
        goto specialchar;

      beg_of_line = ibp;

      /* Update the line counts and output a #line if necessary. */
      ++ip->lineno;
      ++op->lineno;
      if (ip->lineno != op->lineno) {
        op->bufp = obp;
        output_line_directive (ip, op, 1, same_file);
        check_expand (op, limit - ibp);
        obp = op->bufp;
      }
      break;

    case 0:
      /* Come here either after (1) a null character that is part of the input
         or (2) at the end of the input, because there is a null there. */
      if (ibp <= limit)
        /* Our input really contains a null character. */
        goto randomchar;

      /* At end of a macro-expansion level, pop it and read next level. */
      if (ip->macro != 0) {
        obp--;
        ibp--;
        POPMACRO;
        RECACHE;
        break;
      }

      /* If we don't have a pending identifier, return at end of input. */
      if (ident_length == 0) {
        obp--;
        ibp--;
        op->bufp = obp;
        ip->bufp = ibp;
        goto ending;
      }

      /* If we do have a pending identifier, just consider this null
         a special character and arrange to dispatch on it again.
         The second time, IDENT_LENGTH will be zero so we will return. */

      /* FALLTHROUGH */

specialchar:

      /* Handle the case of a character such as /, ', " or null
         seen following an identifier. Back over it so that
         after the identifier is processed the special char
         will be dispatched on again. */

      ibp--;
      obp--;
      redo_char = 1;

    default:

randomchar:

      if (ident_length > 0) {

        /* We have just seen an identifier end. If it's a macro, expand it.
           IDENT_LENGTH is the length of the identifier and HASH is its hash code.
           The identifier has already been copied to the output,
           so if it is a macro we must remove it.
           If REDO_CHAR is 0, the char that terminated the identifier
           has been skipped in the output and the input.
           OBP-IDENT_LENGTH-1 points to the identifier.
           If the identifier is a macro, we must back over the terminator.
           If REDO_CHAR is 1, the terminating char has already been
           backed over. OBP-IDENT_LENGTH points to the identifier. */
        if (!no_macros || (ident_length == 7 && !memcmp (obp - 7 - !redo_char, "defined", 7))) {
          HASHNODE *hp;
          for (hp = hashtab[MAKE_POS (hash) % HASHSIZE]; hp != NULL; hp = hp->next) {
            if (hp->length == ident_length) {
              int obufp_before_macroname;
              int op_lineno_before_macroname;
              int i = ident_length;
              U_CHAR *p = hp->name;
              U_CHAR *q = obp - i;
              int disabled;

              if (!redo_char)
                q--;

              /* All this to avoid a strn[case]cmp () */
              if (hp->case_sensitive)
                do {
                  if (*p++ != *q++)
                    goto hashcollision;
                } while (--i);
              else
                do {
                  U_CHAR cp = *p++, cq = *q++;
                  if (LOCASE (cp) != LOCASE (cq))
                    goto hashcollision;
                } while (--i);

              /* We found a use of a macro name.
                 see if the context shows it is a macro call. */

              /* Back up over terminating character if not already done. */
              if (!redo_char) {
                ibp--;
                obp--;
              }

              /* Save this as a displacement from the beginning of the output
                 buffer. We cannot save this as a position in the output
                 buffer, because it may get realloc'ed by RECACHE. */
              obufp_before_macroname = (obp - op->buf) - ident_length;
              op_lineno_before_macroname = op->lineno;

              /* Record whether the macro is disabled. */
              disabled = hp->type == T_DISABLED;

              /* This looks like a macro ref, but if the macro was disabled,
                 just copy its name and put in a marker if requested. */

              if (disabled) {
                if (output_marks) {
                  check_expand (op, limit - ibp + 2);
                  *obp++ = '\n';
                  *obp++ = '-';
                }
                break;
              }

              /* If macro wants an arglist, verify that a '(' follows.
                 first skip all whitespace, copying it to the output
                 after the macro name. Then, if there is no '(',
                 decide this is not a macro call and leave things that way. */
              if ((hp->type == T_MACRO || hp->type == T_DISABLED) && hp->value.defn->nargs >= 0)
                {
                  U_CHAR *old_ibp = ibp;
                  U_CHAR *old_obp = obp;
                  int old_iln = ip->lineno;
                  int old_oln = op->lineno;

                  while (1) {
                    /* Scan forward over whitespace, copying it to the output. */
                    if (ibp == limit && ip->macro != 0) {
                      POPMACRO;
                      RECACHE;
                      old_ibp = ibp;
                      old_obp = obp;
                      old_iln = ip->lineno;
                      old_oln = op->lineno;
                    }
                    /* A comment: copy it unchanged or discard it. */
                    else if (IS_COMMENT_START2 (ibp)) {
                      int comment_count = 1, comment1 = 2, comment2 = 2;
                      if (*ibp == '{')
                        {
                          ibp += 2;
                          comment2 = mixed_comments;
                        }
                      else
                        {
                          ibp++;
                          comment1 = mixed_comments;
                        }
                      *obp++ = ' ';
                      while (ibp + 1 != limit && comment_count != 0) {
                        int l = 1;
                        if (comment2 && ibp[0] == '*' && ibp[1] == ')')
                          {
                            if (comment2 == 1) warn_mixed_comment ();
                            comment_count--;
                            l = 2;
                          }
                        else if (comment1 && *ibp == '}')
                          {
                            if (comment1 == 1) warn_mixed_comment ();
                            comment_count--;
                          }
                        else if (comment2 && *ibp == '(' && ibp[1] == '*' && !(ibp + 2 < limit && ibp[2] == ')'))
                          {
                            warn_nested_comment ();
                            if (nested_comments)
                              {
                                if (comment2 == 1) warn_mixed_comment ();
                                comment_count++;
                              }
                            l = 2;
                          }
                        else if (comment1 && *ibp == '{')
                          {
                            warn_nested_comment ();
                            if (nested_comments)
                              {
                                if (comment1 == 1) warn_mixed_comment ();
                                comment_count++;
                              }
                          }
                        /* We need not worry about newline-marks,
                           since they are never found in comments. */
                        else if (*ibp == '\n') {
                          /* Newline in a file. Count it. */
                          ++ip->lineno;
                          ++op->lineno;
                        }
                        while (l--)
                          ibp++;
                      }
                    }
                    else if (is_space[*ibp]) {
                      *obp++ = *ibp++;
                      if (ibp[-1] == '\n') {
                        if (ip->macro == 0) {
                          /* Newline in a file. Count it. */
                          ++ip->lineno;
                          ++op->lineno;
                        } else if (!output_marks) {
                          /* A newline mark, and we don't want marks in the output.
                             If it is newline-hyphen, discard it entirely. Otherwise,
                             it is newline-whitechar, so keep the whitechar. */
                          obp--;
                          if (*ibp == '-')
                            ibp++;
                          else {
                            if (*ibp == '\n')
                              ++op->lineno;
                            *obp++ = *ibp++;
                          }
                        } else {
                          /* A newline mark; copy both chars to the output. */
                          *obp++ = *ibp++;
                        }
                      }
                    }
                    else break;
                  }
                  if (*ibp != '(') {
                    /* It isn't a macro call.
                       Put back the space that we just skipped. */
                    ibp = old_ibp;
                    obp = old_obp;
                    ip->lineno = old_iln;
                    op->lineno = old_oln;
                    /* Exit the for loop. */
                    break;
                  }
                }

              /* This is now known to be a macro call.
                 Discard the macro name from the output,
                 along with any following whitespace just copied,
                 but preserve newlines if not outputting marks since this
                 is more likely to do the right thing with line numbers. */
              obp = op->buf + obufp_before_macroname;
              if (output_marks)
                op->lineno = op_lineno_before_macroname;
              else {
                int newlines = op->lineno - op_lineno_before_macroname;
                while (0 < newlines--)
                  *obp++ = '\n';
              }

              /* Prevent accidental token-pasting with a character
                 before the macro call. */
              if (obp != op->buf) {
                switch (obp[-1]) {
                case '!':  case '%':  case '&':  case '*':
                case '+':  case '-':  case '/':  case ':':
                case '<':  case '=':  case '>':  case '^':
                case '|':
                  /* If we are expanding a macro arg, make a newline marker to separate
                     the tokens. If we are making real output, a plain space will do. */
                  if (output_marks)
                    *obp++ = '\n';
                  *obp++ = ' ';
                }
              }

              /* Expand the macro, reading arguments as needed,
                 and push the expansion on the input stack. */
              ip->bufp = ibp;
              op->bufp = obp;
              macroexpand (hp, op);

              /* Reexamine input stack, since macroexpand has pushed
                 a new level on it. */
              obp = op->bufp;
              RECACHE;
              break;
            }
hashcollision:
            ;
          }
        }
        ident_length = hash = 0; /* Stop collecting identifier */
        redo_char = 0;
        concatenated = 0;
      }
    }
  }

  /* Come here to return -- but first give an error message
     if there was an unterminated successful conditional. */
ending:
  if (if_stack != ip->if_stack)
    {
      const char *str;
      switch (if_stack->type)
        {
        case T_IF:
          str = "if";
          break;
        case T_IFDEF:
          str = "ifdef";
          break;
        case T_IFNDEF:
          str = "ifndef";
          break;
        case T_ELSE:
          str = "else";
          break;
        case T_ELIF:
          str = "elif";
          break;
        case T_IFOPT:
          str = "ifopt";
          break;
        default:
          abort ();
        }
      error_with_line (line_for_error (if_stack->lineno), "unterminated `$%s' conditional", str);
    }
  if_stack = ip->if_stack;
}

/* Rescan a string into a temporary buffer and return the result
   as a FILE_BUF. Note this function returns a struct, not a pointer.
   OUTPUT_MARKS nonzero means keep Newline markers found in the input
   and insert such markers when appropriate. See `rescan' for details.
   OUTPUT_MARKS is 1 for macroexpanding a macro argument separately
   before substitution; it is 0 for other uses. */
static FILE_BUF
expand_to_temp_buffer (U_CHAR *buf, U_CHAR *limit, int output_marks)
{
  FILE_BUF *ip, obuf;
  int length = limit - buf;
  U_CHAR *buf1;
  int odepth = indepth;
  if (length < 0)
    abort ();
  /* Set up the input on the input stack. */
  buf1 = (U_CHAR *) alloca (length + 1);
  {
    U_CHAR *p1 = buf, *p2 = buf1;
    while (p1 != limit)
      *p2++ = *p1++;
  }
  buf1[length] = 0;
  /* Set up to receive the output. */
  obuf.length = length * 2 + 100;  /* Usually enough. Why be stingy? */
  obuf.bufp = obuf.buf = (U_CHAR *) xmalloc (obuf.length);
  obuf.fname = 0;
  obuf.macro = 0;
  obuf.free_ptr = 0;
  CHECK_DEPTH (return obuf);
  ++indepth;
  ip = &instack[indepth];
  ip->fname = 0;
  ip->nominal_fname = 0;
  ip->macro = 0;
  ip->free_ptr = 0;
  ip->length = length;
  ip->buf = ip->bufp = buf1;
  ip->if_stack = if_stack;
  ip->lineno = obuf.lineno = 1;
  /* Scan the input, create the output. */
  rescan (&obuf, output_marks);
  /* Pop input stack to original state. */
  --indepth;
  if (indepth != odepth)
    abort ();
  /* Record the output. */
  obuf.length = obuf.bufp - obuf.buf;
  return obuf;
}

/* Process a # directive. Expects IP->bufp to point after the '#', as in
   `#define foo bar'. Passes to the directive handler
   (do_define, do_include, etc.): the addresses of the 1st and
   last chars of the directive (starting immediately after the #
   keyword), plus op and the keyword table pointer. If the directive
   contains comments it is copied into a temporary buffer sans comments
   and the temporary buffer is passed to the directive handler instead.
   Likewise for backslash-newlines.
   Returns nonzero if this was a known # directive.
   Otherwise, returns zero, without advancing the input pointer. */
static int
handle_directive (FILE_BUF *ip, FILE_BUF *op, int pascal_directive)
{
  U_CHAR *bp, *cp;
  struct directive *kt;
  int ident_length;
  int this_can_be_a_char_constant = 1;
  U_CHAR *resume_p;
  /* Nonzero means we must copy the entire directive
     to get rid of comments or backslash-newlines. */
  int copy_directive = 0;
  U_CHAR *ident, *after_ident;
  bp = ip->bufp;
  /* Record where the directive started. do_xifdef needs this. */
  directive_start = bp - 1;

  /* Skip whitespace and \-newline. */
  while (1) {
    if (*bp == ' ' || *bp == '\t') {
      this_can_be_a_char_constant = 0;
      bp++;
    } else if (*bp == '{') {
      if (bp[1] == '$')
        gpc_warning ("ignoring Pascal style directive within C style directive");
      ip->bufp = bp + 1;
      skip_to_end_of_comment (ip, &ip->lineno, '}');
      bp = ip->bufp;
    } else if ((*bp == '\\') && bp[1] == '\n') {
    } else if (IS_COMMENT_START (bp)) {
      if (bp[1] == '*' && bp[2] == '$')
        gpc_warning ("ignoring Pascal style directive within C style directive");
      ip->bufp = bp + 2;
      skip_to_end_of_comment (ip, &ip->lineno, 0);
      bp = ip->bufp;
    } else if ((*bp == '\\') && bp[1] == '\n') {
      bp += 2; ip->lineno++;
    } else break;
  }

  /* Now find end of directive name.
     If we encounter a backslash-newline, exchange it with any following
     symbol-constituents so that we end up with a contiguous name. */
  cp = bp;
  while (1) {
    if (is_idchar[*cp])
      cp++;
    else {
      if ((*cp == '\\') && cp[1] == '\n')
        name_newline_fix (cp);
      if (is_idchar[*cp])
        cp++;
      else break;
    }
  }
  ident_length = cp - bp;
  ident = bp;
  after_ident = cp;

  /* A line of just `#' becomes blank. */

  if (ident_length == 0 && *after_ident == '\n') {
    ip->bufp = after_ident;
    return 1;
  }

  if (ident_length == 0 || !is_idstart[*ident]) {
    U_CHAR *p = ident;
    while (is_idchar[*p]) {
      if (*p < '0' || *p > '9')
        break;
      p++;
    }
    /* Don't confuse BP style #13 character constants with line numbers.
       (See gpc-lex.c for details.) */
    if ((p != ident || *p == '$') && this_can_be_a_char_constant)
      {
        *op->bufp = '#';
        op->bufp++;
        while (ip->bufp < after_ident)
          {
            *op->bufp = *ip->bufp;
            ip->bufp++;
            op->bufp++;
          }
        return 1;
      }
    /* Handle # followed by a line number. */
    else if (p != ident && !is_idchar[*p]) {
      static struct directive line_directive_table[] = {
        { 4, do_line, "line", T_LINE, 0 },
      };
      if (pedantic)
        pedwarn ("`#' followed by integer");
      after_ident = ident;
      kt = line_directive_table;
      goto old_linenum;
    }
    if (!pascal_directive)
      error ("invalid preprocessing directive name");
    return 0;
  }

  /* Decode the keyword and call the appropriate expansion
     routine, after moving the input pointer up to the next line. */
  for (kt = directive_table; kt->length > 0; kt++) {
    if (kt->length == ident_length && !memcmp (kt->name, ident, ident_length)) {
      U_CHAR *buf, *limit;
      int *already_output;

    old_linenum:

      limit = ip->buf + ip->length;
      already_output = 0;

      /* Find the end of this directive (first newline not backslashed
         and not in a string or comment).
         Set COPY_DIRECTIVE if the directive must be copied
         (it contains a backslash-newline or a comment). */

      buf = bp = after_ident;
      while (bp < limit) {
        U_CHAR c = *bp++;
        switch (c) {
        case '\\':
          if (bp < limit) {
            if (*bp == '\n') {
              ip->lineno++;
              copy_directive = 1;
              bp++;
            }
          }
          break;

          /* <...> is special for #include. */
        case '<':
          if (!kt->angle_brackets)
            break;
          while (bp < limit && *bp != '>' && *bp != '\n') {
            if (*bp == '\\' && bp[1] == '\n') {
              ip->lineno++;
              copy_directive = 1;
              bp++;
            }
            bp++;
          }
          break;

        case '{':
          {
            U_CHAR *obp = bp - 1;
            if (*bp == '$')
              {
                gpc_warning ("ignoring Pascal style directive within C style directive");
                *bp = ' ';
              }
            ip->bufp = bp;
            skip_to_end_of_comment (ip, &ip->lineno, '}');
            bp = ip->bufp;
            /* No need to copy the command because of a comment at the end;
               just don't include the comment in the directive. */
            if (bp == limit || *bp == '\n') {
              bp = obp;
              goto endloop1;
            }
            copy_directive++;
          }
          break;

        case '/':
        case '(':
          if (*bp == '\\' && bp[1] == '\n')
            newline_fix (bp);
          if (IS_COMMENT_START (bp - 1)) {
            U_CHAR *obp = bp - 1;
            if (*bp == '*' && bp[1] == '$')
              {
                gpc_warning ("ignoring Pascal style directive within C style directive");
                bp[1] = ' ';
              }
            ip->bufp = bp + 1;
            skip_to_end_of_comment (ip, &ip->lineno, 0);
            bp = ip->bufp;
            /* No need to copy the directive because of a comment at the end;
               just don't include the comment in the directive. */
            if (bp == limit || *bp == '\n') {
              bp = obp;
              goto endloop1;
            }
            copy_directive++;
          }
          break;

        case '\n':
          --bp;  /* Point to the newline */
          ip->bufp = bp;
          goto endloop1;
        }
      }
      ip->bufp = bp;

    endloop1:
      resume_p = ip->bufp;
      /* BP is the end of the directive.
         RESUME_P is the next interesting data after the directive.
         A comment may come between. */

      if (copy_directive) {
        U_CHAR *xp = buf;
        /* Need to copy entire directive into temp buffer before dispatching */
        cp = (U_CHAR *) alloca (bp - buf + 5); /* room for directive plus some slop */
        buf = cp;

        /* Copy to the new buffer, deleting comments
           and backslash-newlines (and whitespace surrounding the latter). */
        while (xp < bp) {
          U_CHAR c = *xp++;
          *cp++ = c;

          switch (c) {
          case '\n':
            abort ();  /* A bare newline should never part of the line. */
            break;

            /* <...> is special for #include. */
          case '<':
            if (!kt->angle_brackets)
              break;
            while (xp < bp && c != '>') {
              c = *xp++;
              if (c == '\\' && xp < bp && *xp == '\n')
                xp++;
              else
                *cp++ = c;
            }
            break;

          case '\\':
            if (*xp == '\n') {
              xp++;
              cp--;
              if (cp != buf && is_hor_space[cp[-1]]) {
                while (cp - 1 != buf && is_hor_space[cp[-2]])
                  cp--;
                SKIP_WHITE_SPACE (xp);
              } else if (is_hor_space[*xp]) {
                *cp++ = *xp++;
                SKIP_WHITE_SPACE (xp);
              }
            }
            break;

          case '\'':
          case '"':
            {
              const U_CHAR *bp1 = skip_quoted_string (xp - 1, bp, ip->lineno, NULL, NULL, NULL);
              while (xp != bp1)
                if (*xp == '\\') {
                  if (*++xp != '\n')
                    *cp++ = '\\';
                  else
                    xp++;
                } else
                  *cp++ = *xp++;
            }
            break;

          case '{':
            ip->bufp = xp;
            /* If we already copied the command through,
               already_output != 0 prevents outputting comment now. */
            skip_to_end_of_comment (ip, already_output, '}');
            cp[-1] = ' ';
            xp = ip->bufp;
            break;

          case '/':
          case '(':
            if (IS_COMMENT_START (xp - 1)) {
              ip->bufp = xp + 1;
              /* If we already copied the directive through,
                 already_output != 0 prevents outputting comment now. */
              skip_to_end_of_comment (ip, already_output, 0);
              /* Replace the slash. */
              cp[-1] = ' ';
              xp = ip->bufp;
            }
          }
        }
        /* Null-terminate the copy. */
        *cp = 0;
      } else
        cp = bp;
      ip->bufp = resume_p;
      /* Call the appropriate directive handler. buf now points to
         either the appropriate place in the input buffer, or to
         the temp buffer if it was necessary to make one. cp
         points to the first char after the contents of the (possibly
         copied) directive, in either case. */
      (*kt->func) (buf, cp, op, kt);
      check_expand (op, ip->length - (ip->bufp - ip->buf));
      return 1;
    }
  }
  /* It is deliberate that we don't warn about undefined directives.
     That is the responsibility of gpc1. */
  return 0;
}

/* Special directives that are not handled like C directives or like
   command line options. */
#define D_LOCAL    "local "
#define D_ENDLOCAL "endlocal"
#define D_CSDEFINE "csdefine "
#define D_CIDEFINE "cidefine "
#define D_DEFINE   "define "

/* Handle a Pascal directive */
static void
handle_pascal_directive (FILE_BUF *ip, FILE_BUF *op, U_CHAR *limit)
{
  U_CHAR *p = ip->bufp, *q, *r, save_char;
  char *allocated_option;
  const char *option;
  int count = 0;
  struct directive *kt;
  struct local_option_list *local_options = NULL;
  /* First kill nested comments, tabs and newlines within range of
     directive. Don't worry about line numbers: This text has
     already been handled properly as a comment. */
  while (p < limit)
    {
      /* Directives within directives can cause much trouble. Think of
         macro definitions within macros, or parts of `{$if}'/`{$endif}'
         conditionals. So, just don't allow such things ... */
      if (*p == '{' && p[1] == '$')
        {
          gpc_warning ("ignoring compiler directive within another directive");
          p[1] = ' ';
        }
      if (*p == '(' && p[1] == '*' && p[2] == '$')
        {
          gpc_warning ("ignoring compiler directive within another directive");
          p[2] = ' ';
        }
      if (IS_COMMENT_START2 (p))
        {
          warn_nested_comment ();
          if (nested_comments)
            {
              q = skip_one_comment (p, limit, NULL, 1);
              while (p < q)
                *p++ = ' ';
            }
          else
            p++;
        }
      else if (*p == '\t' || *p == '\n' || *p == '\r')
        *p++ = ' ';
      else
        p++;
    }
  while (ip->bufp < limit)
    {
      U_CHAR *define_start = NULL;
      int case_sensitive = 0;
      while (*ip->bufp == ' ')
        ip->bufp++;
      p = ip->bufp;
      for (q = p; q < limit && *q != ' ' && *q != ','; q++)
        if (*q >= 'A' && *q <= 'Z')
          *q += 'a' - 'A';
      if (count == 0 && !strncmp ((char *) p, D_ENDLOCAL, strlen (D_ENDLOCAL)))
        {
          for (; q < limit && *q == ' '; q++);
          if (q < limit)
            error ("garbage after `$endlocal'");
          if (local_options_stack)
            {
              struct option_list *options, *temp_o;
              struct hashnode_list *hashnodes, *temp_h;
              local_options = local_options_stack;
              local_options_stack = local_options_stack->next;
              options = local_options->options;
              while (options)
                {
                  int length;
                  char *option = (char *) xmalloc (strlen (options->option) + 1);
                  strcpy (option, options->option);
                  handle_option (option);
                  if (option[0] == '-' && option[1] == 'W')
                    {
                      option[0] = 'W';
                      option[1] = ' ';
                    }
                  else
                    option += 2;
                  length = strlen (option);
                  check_expand (op, length + 4);
                  *op->bufp++ = '{';
                  *op->bufp++ = '$';
                  memcpy (op->bufp, option, length);
                  op->bufp += length;
                  *op->bufp++ = '}';
                  temp_o = options;
                  options = options->next;
                  free (temp_o);
                }
              hashnodes = local_options->hashnodes;
              while (hashnodes)
                {
                  delete_macro (hashnodes->hashnode);
                  temp_h = hashnodes;
                  hashnodes = hashnodes->next;
                  free (temp_h);
                }
              free (local_options);
              local_options = NULL;
            }
          else
            error ("unmatched `$endlocal'");
          ip->bufp = limit;
          continue;
        }
      if (count++ == 0 && !strncmp ((char *) p, D_LOCAL, strlen (D_LOCAL)))
        {
          local_options = (struct local_option_list *) xmalloc (sizeof (struct local_option_list));
          local_options->options = NULL;
          local_options->hashnodes = NULL;
          local_options->next = local_options_stack;
          local_options_stack = local_options;
          ip->bufp = p + strlen (D_LOCAL);
          continue;
        }
      for (; q < limit && *q != ','; q++);
      for (r = q; r > p && r[-1] == ' '; r--);
      if (q < limit)
        q++;
      ip->bufp = q;
      option = NULL;
      allocated_option = NULL;
      save_char = *r;
      if (r - p == 2 && (p[1] == '+' || p[1] == '-'))
        {
          const struct gpc_short_option *short_option = gpc_short_options;
          while (short_option->short_name
                 && (short_option->short_name != p[0] || (!short_option->bp_option && bp_dialect)))
            short_option++;
          if (short_option->short_name)
            {
              if (p[1] == '+')
                option = short_option->long_name;
              else
                option = short_option->inverted_long_name;
            }
        }
      else
        {
          *r = 0;
          if (p[0] == 'w' && p[1] == ' ')
            {
              p[0] = '-';
              p[1] = 'W';
              option = (char *) p;
            }
          else
            {
              allocated_option = (char *) xmalloc (strlen ((char *) p) + 3);
              allocated_option[0] = '-';
              allocated_option[1] = 'f';
              strcpy (allocated_option + 2, (char *) p);
              option = allocated_option;
            }
        }
      if (option)
        {
          int option_handled = 0;
          const char *reverse_option = NULL;
          if (local_options)
            {
              int is_negative;
              char *positive_option = check_negative_option (option, strlen (option), 1, &is_negative);
              struct option_list *po = current_options;
              while (po && strcmp (po->option, positive_option) != 0)
                po = po->next;
              if ((po == NULL) != is_negative)  /* `!=' means xor */
                {
                  if (!is_dialect_option (option))
                    reverse_option = check_negative_option (option, strlen (option), 0, NULL);
                  else
                    {
                      struct option_list *po = current_options;
                      while (po && !is_dialect_option (po->option))
                        po = po->next;
                      if (po)
                        reverse_option = po->option;
                      else
                        reverse_option = "-fgnu-pascal";  /* default */
                    }
                }
              free (positive_option);
              /* numeric options */
              if (!strncmp (option, "-fmaximum-field-alignment", 25))
                reverse_option = "-finternal-restore-mfa", option_handled = 1;
              if (!strncmp (option, "-ffield-widths", 14)
                  || !strncmp (option, "-fno-field-widths", 17))
                reverse_option = "-finternal-restore-fw", option_handled = 1;
            }
          if (!option_handled)
            option_handled = handle_option (option) || option[1] == '!' || option[1] == '#';
          if (reverse_option && option_handled)
            {
              struct option_list *temp = (struct option_list *) xmalloc (sizeof (struct option_list));
              temp->next = local_options->options;
              temp->option = reverse_option;
              local_options->options = temp;
            }
          *r = save_char;
          if (allocated_option)
            free (allocated_option);
          if (option_handled)
            continue;
        }

      if (!strncmp ((char *) p, D_CSDEFINE, strlen (D_CSDEFINE)))
        {
          define_start = p + strlen (D_CSDEFINE);
          case_sensitive = 1;
        }
      if (!strncmp ((char *) p, D_CIDEFINE, strlen (D_CIDEFINE)))
        define_start = p + strlen (D_CIDEFINE);
      if (!strncmp ((char *) p, D_DEFINE, strlen (D_DEFINE)))
        define_start = p + strlen (D_DEFINE);
      if (define_start)
        {
          HASHNODE *hashnode = NULL;
          for (kt = directive_table; kt->type != T_DEFINE; kt++);
          do_define1 (define_start, limit, op, kt, case_sensitive, &hashnode);
          if (hashnode && local_options)
            {
              struct hashnode_list *temp = (struct hashnode_list *) xmalloc (sizeof (struct hashnode_list));
              temp->hashnode = hashnode;
              temp->next = local_options->hashnodes;
              local_options->hashnodes = temp;
            }
          ip->bufp = limit;
          break;
        }
      if (p[0] == 'i' && p[1] == ' ') /* include a file */
        {
          U_CHAR *s;
          char *fn, *t;
          if (local_options)
            error ("includes cannot be local");
          for (p += 2; p < r && *p == ' '; p++);
          *r = 0;
          for (s = r; s > p && *s != '.'; s--);
          /* Add quotes and file suffix ".pas" if no dot present */
          t = (char *) xmalloc (r - p + 7);
          if (s > p)
            sprintf (t, "\"%s\"", p);
          else
            sprintf (t, "\"%s.pas\"", p);
          /* Make the filename low-case */
          for (fn = t; *fn; fn++)
            if (*fn >= 'A' && *fn <= 'Z')
              *fn += 'a' - 'A';
          /* Let do_include do the work */
          for (kt = directive_table; kt->type != T_INCLUDE; kt++);
          do_include ((U_CHAR *) t, (U_CHAR *) t + strlen (t), op, kt);
          free (t);
          ip->bufp = limit;
          break;
        }
      if (local_options)
        error ("unknown local option");
      /* Handle C preprocessor directives.
         Add one newline at the end. It overwrites the closing brace.
         In case it is read it will artificially increase the line number. */
      *limit = '\n';
      /* Call the C directive handler. */
      while (p >= ip->buf && *p != '$')
        p--;
      ip->bufp = p + 1;
      handle_directive (ip, op, 1);
      if (ip->bufp > limit)
        {
          /* This happens when processing an $if...
             Skip back to the beginning of the directive, but not when at
             the end of the buffer, otherwise error messages about unterminated
             `if's can get lost because a previous `endif' is read again, and
             the line count may become wrong (fjf427*.pas). */
          ip->lineno--;
          q = ip->bufp;
          if (q < ip->buf + ip->length)
            {
              q--;
              while (q > limit && *q != '{' && *q != '(')
                q--;
            }
          ip->bufp = q;
        }
      else
        ip->bufp = limit;
    }
}

/* expand things like __FILE__. Place the expansion into the output
   buffer *without* rescanning. */
static void
special_symbol (HASHNODE *hp, FILE_BUF *op)
{
  const char *buf;
  char *s;
  int i, len;
  int true_indepth;
  FILE_BUF *ip = NULL;
  static struct tm *timebuf = NULL;
  int parenthesis = 0;  /* For special `defined' keyword */

  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  if (ip == NULL) {
    error ("gpcpp error: not in any file?!");
    return;  /* the show must go on */
  }

  switch (hp->type) {
  case T_FILE:
  case T_BASE_FILE:
    {
      const char *string;
      if (hp->type == T_FILE)
        string = ip->nominal_fname;
      else
        string = instack[0].nominal_fname;
      if (string)
        {
          if (!IS_ABSOLUTE_PATHNAME (string))
            {
              char b[2048], *cwd = getcwd (b, sizeof (b));
              if (cwd)
                {
                  s = (char *) alloca (strlen (cwd) + strlen (string) + 2);
                  sprintf (s, "%s%c%s", cwd, DIR_SEPARATOR, string);
                  string = s;
                }
            }
          s = (char *) alloca (3 + 4 * strlen (string));
          quote_string (s, string);
          buf = s;
        }
      else
        buf = "\"\"";
      break;
    }

  case T_INCLUDE_LEVEL:
    true_indepth = 0;
    for (i = indepth; i >= 0; i--)
      if (instack[i].fname != NULL)
        true_indepth++;

    s = (char *) alloca (8);  /* Eight bytes ought to be more than enough */
    sprintf (s, "%d", true_indepth - 1);
    buf = s;
    break;

  case T_VERSION:
    s = (char *) alloca (3 + strlen (version_string));
    sprintf (s, "\"%s\"", version_string);
    buf = s;
    break;

  case T_SPECLINE:
    s = (char *) alloca (10);
    sprintf (s, "%d", ip->lineno);
    buf = s;
    break;

  case T_DATE:
  case T_TIME:
    s = (char *) alloca (20);
    if (!timebuf) {
      time_t t = time ((time_t *) 0);
      timebuf = localtime (&t);
    }
    if (hp->type == T_DATE)
      sprintf (s, "\"%04d-%02d-%02d\"", timebuf->tm_year + 1900, timebuf->tm_mon + 1, timebuf->tm_mday);
    else
      sprintf (s, "\"%02d:%02d:%02d\"", timebuf->tm_hour, timebuf->tm_min, timebuf->tm_sec);
    buf = s;
    break;

  case T_SPEC_DEFINED:
    buf = " 0 ";  /* Assume symbol is not defined */
    ip = &instack[indepth];
    SKIP_WHITE_SPACE (ip->bufp);
    if (*ip->bufp == '(') {
      parenthesis++;
      ip->bufp++;  /* Skip over the parenthesis */
      SKIP_WHITE_SPACE (ip->bufp);
    }

    if (!is_idstart[*ip->bufp])
      goto oops;
    if ((hp = lookup (ip->bufp, -1, -1)))
      buf = " 1 ";
    while (is_idchar[*ip->bufp])
      ++ip->bufp;
    SKIP_WHITE_SPACE (ip->bufp);
    if (parenthesis) {
      if (*ip->bufp != ')')
        goto oops;
      ++ip->bufp;
    }
    break;

oops:
    error ("`defined' without an identifier");
    break;

  default:
    error ("gpcpp error: invalid special hash type");  /* time for gdb */
    abort ();
  }
  len = strlen (buf);
  check_expand (op, len);
  memcpy ((char *) op->bufp, buf, len);
  op->bufp += len;
  return;
}

/* Routines to handle #directives */

/* Handle #include.
   This function expects to see "fname" or <fname> on the input. */
static int
do_include (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword)
{
  int skip_dirs = (keyword->type == T_INCLUDE_NEXT);
  char *fname;  /* Dynamically allocated fname buffer */
  U_CHAR *fbeg, *fend;  /* Beginning and end of fname */
  struct file_name_list *search_start = include;  /* Chain of dirs to search */
  struct file_name_list dsp[1];  /* First in chain, if #include "..." */
  struct file_name_list *searchptr = 0;
  size_t flen;
  int f = -1;  /* file number */
  int retried = 0;  /* Have already tried macro expanding the include line*/

get_filename:

  fbeg = buf;
  SKIP_WHITE_SPACE (fbeg);
  /* Discard trailing whitespace so we can easily see
     if we have parsed all the significant chars we were given. */
  while (limit != fbeg && is_hor_space[limit[-1]]) limit--;

  switch (*fbeg++) {
  case '"':
    {
      FILE_BUF *fp;
      /* Copy the operand text, concatenating the strings. */
      {
        U_CHAR *fin = fbeg;
        fbeg = (U_CHAR *) alloca (limit - fbeg + 1);
        fend = fbeg;
        while (fin != limit) {
          while (fin != limit && *fin != '"')
            *fend++ = *fin++;
          fin++;
          if (fin == limit)
            break;
          /* If not at the end, there had better be another string. */
          /* Skip just horiz space, and don't go past limit. */
          while (fin != limit && is_hor_space[*fin]) fin++;
          if (fin != limit && *fin == '"')
            fin++;
          else
            goto fail;
        }
      }
      *fend = 0;

      /* We have "filename". Figure out directory this source
         file is coming from and put it on the front of the list. */

      /* If -I- was specified, don't search current dir, only spec'd ones. */
      if (ignore_srcdir) break;

      for (fp = &instack[indepth]; fp >= instack; fp--)
        {
          int n;
          const char *ep, *nam;

          if ((nam = fp->nominal_fname) != NULL) {
            /* Found a named file. Figure out dir of the file,
               and put it in front of the search list. */
            dsp[0].next = search_start;
            search_start = dsp;
#ifndef VMS
            ep = strrchr (nam, '/');
#ifdef DIR_SEPARATOR
            if (ep == NULL) ep = strrchr (nam, DIR_SEPARATOR);
            else {
              char *tmp = strrchr (nam, DIR_SEPARATOR);
              if (tmp != NULL && tmp > ep) ep = tmp;
            }
#endif
#else
            ep = strrchr (nam, ']');
            if (ep == NULL) ep = strrchr (nam, '>');
            if (ep == NULL) ep = strrchr (nam, ':');
            if (ep != NULL) ep++;
#endif
            if (ep != NULL) {
              char *s;
              n = ep - nam;
              s = (char *) alloca (n + 1);
              strncpy (s, nam, n);
              s[n] = '\0';
              dsp[0].fname = s;
              if (n + INCLUDE_LEN_FUDGE > max_include_len)
                max_include_len = n + INCLUDE_LEN_FUDGE;
            } else
              dsp[0].fname = "."; /* Current directory */
            break;
          }
        }
      break;
    }

  case '<':
    fend = fbeg;
    while (fend != limit && *fend != '>') fend++;
    if (*fend == '>' && fend + 1 == limit) {
      /* If -I-, start with the first -I dir after the -I-. */
      if (first_bracket_include)
        search_start = first_bracket_include;
      break;
    }
    goto fail;

  default:
  fail:
    if (retried) {
      error ("`$%s' expects \"FILENAME\" or <FILENAME>", keyword->name);
      return 0;
    } else {
      /* Expand buffer and then remove any newline markers.
         We can't just tell expand_to_temp_buffer to omit the markers,
         since it would put extra spaces in include file names. */
      FILE_BUF trybuf;
      U_CHAR *src;
      trybuf = expand_to_temp_buffer (buf, limit, 1);
      src = trybuf.buf;
      buf = (U_CHAR *) alloca (trybuf.bufp - trybuf.buf + 1);
      limit = buf;
      while (src != trybuf.bufp) {
        switch ((*limit++ = *src++)) {
          case '\n':
            limit--;
            src++;
            break;

          case '\'':
          case '"':
            {
              const U_CHAR *src1 = skip_quoted_string (src - 1, trybuf.bufp, 0, NULL, NULL, NULL);
              while (src != src1)
                *limit++ = *src++;
            }
            break;
        }
      }
      *limit = 0;
      free (trybuf.buf);
      retried++;
      goto get_filename;
    }
  }

  /* For #include_next, skip in the search path
     past the dir in which the containing file was found. */
  if (skip_dirs) {
    FILE_BUF *fp;
    for (fp = &instack[indepth]; fp >= instack; fp--)
      if (fp->fname != NULL) {
        /* fp->dir is null if the containing file was specified
           with an absolute file name. In that case, don't skip anything. */
        if (fp->dir)
          search_start = fp->dir->next;
        break;
      }
  }

  flen = fend - fbeg;

  if (flen == 0)
    {
      error ("empty file name in `$%s'", keyword->name);
      return 0;
    }

  /* Allocate this permanently, because it gets stored in the definitions
     of macros. */
  fname = (char *) xmalloc (max_include_len + flen + 4);
  /* + 2 '/' and 0.
     + 2 '.h' on VMS (to support '#include filename') */

  /* If specified file name is absolute, just open it. */

  if (IS_ABSOLUTE_PATHNAME (fbeg)) {
    strncpy (fname, (char *) fbeg, flen);
    fname[flen] = 0;
    f = open (fname, O_RDONLY, 0666);
  } else {
    /* Search directory path, trying to open the file.
       Copy each filename tried into FNAME. */

    for (searchptr = search_start; searchptr; searchptr = searchptr->next) {
      if (searchptr->fname) {
        /* The empty string in a search path is ignored.
           This makes it possible to turn off entirely
           a standard piece of the list. */
        if (searchptr->fname[0] == 0)
          continue;
        strcpy (fname, searchptr->fname);
        if (fname[0] && !IS_DIR_SEPARATOR (fname[strlen (fname) - 1]))
          strcat (fname, dir_separator_str);
      } else
        fname[0] = 0;
      strncat (fname, (char *) fbeg, flen);
      f = open (fname, O_RDONLY, 0666);
#ifdef EACCES
      if (f == -1 && errno == EACCES)
        gpc_warning ("header file %s exists, but is not readable", fname);
#endif
      if (f >= 0)
        break;
    }
  }
  if (f < 0) {
    /* A file that was not found. */
    strncpy (fname, (char *) fbeg, flen);
    fname[flen] = 0;
    if (search_start)
      error_from_errno (fname);
    else
      error ("no include path in which to find %s", fname);
  } else {
    if (print_deps)
      fprintf (deps_out_file, "%s\n", fname);
    if (print_include_names)
      fprintf (stderr, "%*s%s\n", indepth, "", fname);
    finclude (f, fname, op, searchptr);
  }
  return 0;
}

/* Process the contents of include file FNAME, already open on descriptor F,
   with output to OP.
   DIRPTR is the link in the dir path through which this file was found,
   or 0 if the file name was absolute. */
static void
finclude (int f, char *fname, FILE_BUF *op, struct file_name_list *dirptr)
{
  FILE_BUF *fp;  /* For input stack frame */
  CHECK_DEPTH (return);
  fp = &instack[indepth + 1];
  memset ((char *) fp, 0, sizeof (FILE_BUF));
  fp->nominal_fname = fp->fname = fname;
  fp->length = 0;
  fp->if_stack = if_stack;
  fp->dir = dirptr;
  if (!open_input_file (f, fp))
    {
      close (f);
      free (fp->buf);
      return;
    }
  close (f);
  indepth++;
  input_file_stack_tick++;
  output_line_directive (fp, op, 0, enter_file);
  rescan (op, 0);
  indepth--;
  input_file_stack_tick++;
  output_line_directive (&instack[indepth], op, 0, leave_file);
  free (fp->buf);
  return;
}

/* Create a DEFINITION node from a #define directive. Arguments are
   as for do_define. */
static MACRODEF
create_definition (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op)
{
  U_CHAR *bp;       /* temp ptr into input buffer */
  U_CHAR *symname;  /* remember where symbol name starts */
  int sym_length;   /* and how long it is */
  int line = instack[indepth].lineno;
  const char *file = instack[indepth].nominal_fname;
  int rest_args = 0;

  DEFINITION *defn;
  int arglengths = 0;  /* Accumulate lengths of arg names plus number of args. */
  MACRODEF mdef;

  bp = buf;

  while (is_hor_space[*bp])
    bp++;

  symname = bp;  /* remember where it starts */
  sym_length = check_macro_name (bp, "macro");
  bp += sym_length;

  /* Lossage will occur if identifiers or control keywords are broken
     across lines using backslash. This is not the right place to take
     care of that. */

  if (*bp == '(') {
    struct arglist *arg_ptrs = NULL;
    int argno = 0;

    bp++;  /* skip '(' */
    SKIP_WHITE_SPACE (bp);

    /* Loop over macro argument names. */
    while (*bp != ')') {
      struct arglist *temp;

      temp = (struct arglist *) alloca (sizeof (struct arglist));
      temp->name = bp;
      temp->next = arg_ptrs;
      temp->argno = argno++;
      temp->rest_args = 0;
      arg_ptrs = temp;

      if (rest_args)
        pedwarn ("another parameter follows `%s'", rest_extension);

      if (!is_idstart[*bp])
        pedwarn ("invalid character in macro parameter name");

      /* Find the end of the arg name. */
      while (is_idchar[*bp]) {
        bp++;
        /* do we have a "special" rest-args extension here? */
        if ((size_t) (limit - bp) > REST_EXTENSION_LENGTH &&
            memcmp (rest_extension, bp, REST_EXTENSION_LENGTH) == 0) {
          rest_args = 1;
          temp->rest_args = 1;
          break;
        }
      }
      temp->length = bp - temp->name;
      if (rest_args == 1)
        bp += REST_EXTENSION_LENGTH;
      arglengths += temp->length + 2;
      SKIP_WHITE_SPACE (bp);
      if (temp->length == 0 || (*bp != ',' && *bp != ')')) {
        error ("badly punctuated parameter list in `$define'");
        goto nope;
      }
      if (*bp == ',') {
        bp++;
        SKIP_WHITE_SPACE (bp);
        /* A comma at this point can only be followed by an identifier. */
        if (!is_idstart[*bp]) {
          error ("badly punctuated parameter list in `$define'");
          goto nope;
        }
      }
      if (bp >= limit) {
        error ("unterminated parameter list in `$define'");
        goto nope;
      }
      {
        struct arglist *otemp;
        for (otemp = temp->next; otemp != NULL; otemp = otemp->next)
          if (temp->length == otemp->length &&
              memcmp (temp->name, otemp->name, temp->length) == 0)
            {
              error ("duplicate argument name `%.*s' in `$define'",
                     temp->length, temp->name);
              goto nope;
            }
      }
    }

    ++bp;  /* skip parenthesis */
    SKIP_WHITE_SPACE (bp);
    /* now everything from bp before limit is the definition. */
    defn = collect_expansion (bp, limit, argno, arg_ptrs);
    defn->rest_args = rest_args;

    /* Now set defn->argnames to the result of concatenating
       the argument names in reverse order
       with comma-space between them. */
    defn->argnames = (U_CHAR *) xmalloc (arglengths + 1);
    {
      struct arglist *temp;
      int i = 0;
      for (temp = arg_ptrs; temp; temp = temp->next) {
        memcpy (&defn->argnames[i], temp->name, temp->length);
        i += temp->length;
        if (temp->next != 0) {
          defn->argnames[i++] = ',';
          defn->argnames[i++] = ' ';
        }
      }
      defn->argnames[i] = 0;
    }
  } else {
    /* Simple expansion or empty definition. */
    if (bp < limit)
      {
        if (is_hor_space[*bp]) {
          bp++;
          SKIP_WHITE_SPACE (bp);
        } else
          gpc_warning ("missing white space after `$define %.*s'",
                   sym_length, symname);
      }
    /* Now everything from bp before limit is the definition. */
    defn = collect_expansion (bp, limit, -1, NULL);
    defn->argnames = (U_CHAR *) "";
  }

  defn->line = line;
  defn->file = file;

  /* OP is null if this is a predefinition */
  defn->predefined = !op;
  mdef.defn = defn;
  mdef.symnam = symname;
  mdef.symlen = sym_length;
  return mdef;

 nope:
  mdef.defn = 0;
  return mdef;
}

/* Process a #define directive.
   BUF points to the contents of the #define directive, as a contiguous string.
   LIMIT points to the first character past the end of the definition.
   KEYWORD is the keyword-table entry for #define. */
static int
do_define1 (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword ATTRIBUTE_UNUSED, int case_sensitive, HASHNODE **hashnode)
{
  int hashcode;
  HASHNODE *hp;
  MACRODEF mdef;
  mdef = create_definition (buf, limit, op);
  if (mdef.defn == 0)
    return 1;
  hashcode = hashf (mdef.symnam, mdef.symlen, HASHSIZE);
  /* Allow redefining locally (hashnode != NULL), and create
     new definitions in this case. */
  if ((hp = lookup (mdef.symnam, mdef.symlen, hashcode)) != NULL && !hashnode) {
    int ok = 0;
    /* Redefining a macro is ok if the definitions are the same. */
    if (hp->type == T_MACRO)
      ok = !compare_defs (mdef.defn, hp->value.defn);
    /* Print the warning if it's not ok. */
    if (!ok) {
      pedwarn ("`%.*s' redefined", mdef.symlen, mdef.symnam);
      if (hp->type == T_MACRO)
        pedwarn_with_file_and_line (hp->value.defn->file, hp->value.defn->line,
                                    "this is the location of the previous definition");
    }
    /* Replace the old definition. */
    hp->type = T_MACRO;
    hp->value.defn = mdef.defn;
  } else {
    /* If we are passing through #define and #undef directives, do
       that for this new definition now. */
    hp = install (mdef.symnam, mdef.symlen, T_MACRO,
             (char *) mdef.defn, hashcode, case_sensitive);
    if (hashnode)
      *hashnode = hp;
  }
  return 0;
}

static int
do_define (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword)
{
  return do_define1 (buf, limit, op, keyword, 1, NULL);
}

/* Check a purported macro name SYMNAME, and yield its length.
   USAGE is the kind of name this is intended for. */
static int
check_macro_name (U_CHAR *symname, const char *usage)
{
  U_CHAR *p;
  int sym_length;
  for (p = symname; is_idchar[*p]; p++)
    ;
  sym_length = p - symname;
  if (sym_length == 0)
    error ("invalid %s name", usage);
  else if (!is_idstart[*symname] || (sym_length == 7 && !memcmp (symname, "defined", 7)))
    error ("invalid %s name `%.*s'", usage, sym_length, symname);
  return sym_length;
}

/* return zero if two DEFINITIONs are isomorphic */
static int
compare_defs (DEFINITION *d1, DEFINITION *d2)
{
  struct reflist *a1, *a2;
  if (d1->nargs != d2->nargs || strcmp ((char *) d1->argnames, (char *) d2->argnames))
    return 1;
  for (a1 = d1->pattern, a2 = d2->pattern; a1 && a2; a1 = a1->next, a2 = a2->next)
    if (a1->nchars != a2->nchars
        || a1->argno != a2->argno
        || a1->stringify != a2->stringify
        || a1->raw_before != a2->raw_before
        || a1->raw_after != a2->raw_after)
      return 1;
  return a1 || a2 || d1->length != d2->length || memcmp (d1->expansion, d2->expansion, d1->length);
}

/* Read a replacement list for a macro with parameters.
   Build the DEFINITION structure.
   Reads characters of text starting at BUF until END.
   ARGLIST specifies the formal parameters to look for
   in the text of the definition; NARGS is the number of args
   in that list, or -1 for a macro name that wants no argument list.
   MACRONAME is the macro name itself (so we can avoid recursive expansion)
   and NAMELEN is its length in characters.
   Note that comments, backslash-newlines, and leading white space
   have already been deleted from the argument. */

/* If there is no trailing whitespace, a Newline Space is added at the end
   to prevent concatenation that would be contrary to the standard. */
static DEFINITION *
collect_expansion (U_CHAR *buf, U_CHAR *end, int nargs, struct arglist *arglist)
{
  DEFINITION *defn;
  U_CHAR *p, *limit, *lastp, *exp_p;
  struct reflist *endpat = NULL;
  U_CHAR *concat = 0;  /* Pointer to first nonspace after last ## seen. */
  U_CHAR *stringify = 0;  /* Pointer to first nonspace after last single-# seen. */
  /* How those tokens were spelled. */
  U_CHAR concat_sharp_token_type = 0;
  U_CHAR stringify_sharp_token_type = 0;
  int maxsize;
  int expected_delimiter = '\0';

  /* Scan thru the replacement list, ignoring comments and quoted
     strings, picking up on the macro calls. It does a linear search
     thru the arg list on every potential symbol. Profiling might say
     that something smarter should happen. */

  if (end < buf)
    abort ();

  /* Find the beginning of the trailing whitespace. */
  limit = end;
  p = buf;
  while (p < limit && is_space[limit[-1]]) limit--;

  /* Allocate space for the text in the macro definition.
     Each input char may or may not need 1 byte,
     so this is an upper bound.
     The extra 3 are for invented trailing newline-marker and final null. */
  maxsize = (sizeof (DEFINITION)
             + (limit - p) + 3);
  defn = (DEFINITION *) xcalloc (1, maxsize);

  defn->nargs = nargs;
  exp_p = defn->expansion = (U_CHAR *) defn + sizeof (DEFINITION);
  lastp = exp_p;

  if (p[0] == '#' && p[1] == '#') {
    error ("`##' at start of macro definition");
    p += 2;
  }

  /* Process the main body of the definition. */
  while (p < limit) {
    int skipped_arg = 0;
    U_CHAR c = *p++;

    *exp_p++ = c;

    switch (c)
    {
      case '^':
        if (*p == '\'' || *p == '"')
          *exp_p++ = *p++;
        break;

      case '\'':
      case '"':
        if (expected_delimiter != '\0') {
          if (c == expected_delimiter)
            expected_delimiter = '\0';
        } else
          expected_delimiter = c;
        break;

      case '\\':
        if (p < limit && expected_delimiter && expected_delimiter != '\'') {
          /* In a string, backslash goes through and makes next char ordinary. */
          *exp_p++ = *p++;
        }
        break;

      case '#':
        /* # is ordinary inside a string. */
        if (expected_delimiter)
          break;
        if (*p == '#') {
          /* ##: concatenate preceding and following tokens.
             Take out the first #, discard preceding whitespace. */
          exp_p--;
          while (exp_p > lastp && is_hor_space[exp_p[-1]])
            --exp_p;
          /* Skip the second #. */
          p++;
          concat_sharp_token_type = c;
          if (is_hor_space[*p]) {
            concat_sharp_token_type = c + 1;
            p++;
            SKIP_WHITE_SPACE (p);
          }
          concat = p;
          if (p == limit)
            error ("`##' at end of macro definition");
                   /* note BP character constants */
        } else if (nargs >= 0 && ((*p < '0' || *p > '9') && *p != '$')) {
          /* Single #: stringify following argument ref.
             Don't leave the # in the expansion. */
          exp_p--;
          stringify_sharp_token_type = c;
          if (is_hor_space[*p]) {
            stringify_sharp_token_type = c + 1;
            p++;
            SKIP_WHITE_SPACE (p);
          }
          if (!is_idstart[*p] || nargs == 0)
            error ("`#' operator is not followed by a macro argument name");
          else
            stringify = p;
        }
        break;
    }

    /* Handle the start of a symbol. */
    if (is_idchar[c] && nargs > 0) {
      U_CHAR *id_beg = p - 1;
      int id_len;

      --exp_p;
      while (p != limit && is_idchar[*p]) p++;
      id_len = p - id_beg;

      if (is_idstart[c]) {
        struct arglist *arg;

        for (arg = arglist; arg != NULL; arg = arg->next) {
          struct reflist *tpat;

          if (arg->name[0] == c
              && arg->length == id_len
              && memcmp (arg->name, id_beg, id_len) == 0) {
            U_CHAR tpat_stringify;
            if (expected_delimiter)
              /* Don't substitute inside a string. */
              break;
            else
              tpat_stringify = (stringify == id_beg ? stringify_sharp_token_type : 0);
            /* make a pat node for this arg and append it to the end of the pat list */
            tpat = (struct reflist *) xmalloc (sizeof (struct reflist));
            tpat->next = NULL;
            tpat->raw_before = concat == id_beg ? concat_sharp_token_type : 0;
            tpat->raw_after = 0;
            tpat->rest_args = arg->rest_args;
            tpat->stringify = tpat_stringify;

            if (endpat == NULL)
              defn->pattern = tpat;
            else
              endpat->next = tpat;
            endpat = tpat;

            tpat->argno = arg->argno;
            tpat->nchars = exp_p - lastp;
            {
              U_CHAR *p1 = p;
              SKIP_WHITE_SPACE (p1);
              if (p1[0]=='#' && p1[1]=='#')
                tpat->raw_after = p1[0] + (p != p1);
            }
            lastp = exp_p;  /* place to start copying from next time */
            skipped_arg = 1;
            break;
          }
        }
      }

      /* If this was not a macro arg, copy it into the expansion. */
      if (!skipped_arg) {
        U_CHAR *lim1 = p;
        p = id_beg;
        while (p != lim1)
          *exp_p++ = *p++;
        if (stringify == id_beg)
          error ("`#' operator should be followed by a macro argument name");
      }
    }
  }

  if (expected_delimiter == 0) {
    /* If ANSI, put in a newline-space marker to prevent token pasting.
       But not if "inside a string" (which in ANSI mode happens only for
       -D option). */
    *exp_p++ = '\n';
    *exp_p++ = ' ';
  }

  *exp_p = '\0';

  defn->length = exp_p - defn->expansion;

  /* Crash now if we overrun the allocated size. */
  if (defn->length + 1 > maxsize)
    abort ();

  return defn;
}

/* interpret #line directive. Remembers previously seen fnames
   in its very own hash table. */
#define FNAME_HASHSIZE 37

static int
do_line (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword ATTRIBUTE_UNUSED)
{
  U_CHAR *bp;
  FILE_BUF *ip = &instack[indepth], tem;
  int new_lineno;
  enum file_change_code file_change = same_file;

  /* Expand any macros. */
  tem = expand_to_temp_buffer (buf, limit, 0);

  /* Point to macroexpanded line, which is null-terminated now. */
  bp = tem.buf;
  SKIP_WHITE_SPACE (bp);

  if (!(*bp >= '0' && *bp <= '9')) {
    error ("invalid format `#line' directive");
    return 0;
  }

  /* The Newline at the end of this line remains to be processed.
     To put the next line at the specified line number,
     we must store a line number now that is one less. */
  new_lineno = atoi ((char *) bp) - 1;

  /* NEW_LINENO is one less than the actual line number here. */
  if (pedantic && new_lineno < 0)
    pedwarn ("line number out of range in `#line' directive");


  /* skip over the line number. */
  while (*bp >= '0' && *bp <= '9')
    bp++;

  SKIP_WHITE_SPACE (bp);

  if (*bp == '"') {
    static HASHNODE *fname_table[FNAME_HASHSIZE];
    HASHNODE *hp, **hash_bucket;
    U_CHAR *fname, *p;
    int fname_length;

    fname = ++bp;

    /* Turn the file name, which is a character string literal,
       into a null-terminated string. Do this in place. */
    p = bp;
    for (;;)
      switch ((*p++ = *bp++)) {
      case '\0':
        error ("invalid format of `#line' directive");
        return 0;

      case '\\':
        if ((p[-1] = *bp++) == '\n')
          p--;
        break;

      case '"':
        p[-1] = 0;
        goto fname_done;
      }
  fname_done:
    fname_length = p - fname;

    SKIP_WHITE_SPACE (bp);
    if (*bp) {
      if (pedantic)
        pedwarn ("garbage at end of `#line' directive");
      if (*bp == '1')
        file_change = enter_file;
      else if (*bp == '2')
        file_change = leave_file;
      else if (*bp != '3' && *bp != '4') {
        error ("invalid format `#line' directive");
        return 0;
      }

      bp++;
      SKIP_WHITE_SPACE (bp);
      if (*bp == '3' || *bp == '4') {
        bp++;
        SKIP_WHITE_SPACE (bp);
      }
      if (*bp) {
        error ("invalid format `#line' directive");
        return 0;
      }
    }

    hash_bucket = &fname_table[hashf (fname, fname_length, FNAME_HASHSIZE)];
    for (hp = *hash_bucket; hp != NULL; hp = hp->next)
      if (hp->length == fname_length &&
          memcmp (hp->value.cpval, fname, fname_length) == 0) {
        ip->nominal_fname = hp->value.cpval;
        break;
      }
    if (hp == 0) {
      /* Didn't find it; cons up a new one. */
      hp = (HASHNODE *) xcalloc (1, sizeof (HASHNODE) + fname_length + 1);
      hp->next = *hash_bucket;
      *hash_bucket = hp;

      hp->length = fname_length;
      ip->nominal_fname = hp->value.cpval = ((char *) hp) + sizeof (HASHNODE);
      memcpy (hp->value.cpval, fname, fname_length);
    }
  } else if (*bp) {
    error ("invalid format `#line' directive");
    return 0;
  }

  ip->lineno = new_lineno;
  output_line_directive (ip, op, 0, file_change);
  check_expand (op, ip->length - (ip->bufp - ip->buf));
  return 0;
}

/* remove the definition of a symbol from the symbol table.
   according to un*x /lib/cpp, it is not an error to undef
   something that has no definitions, so it isn't one here either. */
static int
do_undef (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword ATTRIBUTE_UNUSED)
{
  int sym_length;
  HASHNODE *hp;
  SKIP_WHITE_SPACE (buf);
  sym_length = check_macro_name (buf, "macro");
  while ((hp = lookup (buf, sym_length, -1)) != NULL) {
    /* If we are generating additional info for debugging (with -g) we
       need to pass through all effective #undef directives. */
    if (hp->type != T_MACRO)
      gpc_warning ("undefining `%s'", hp->name);
    delete_macro (hp);
  }
  if (pedantic) {
    buf += sym_length;
    SKIP_WHITE_SPACE (buf);
    if (buf != limit)
      pedwarn ("garbage after `$undef' directive");
  }
  return 0;
}

/* Report an error detected by the program we are processing.
   Use the text of the line in the error message.
   (We use error because it prints the filename & line#.) */
static int
do_error (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword ATTRIBUTE_UNUSED)
{
  int length = limit - buf;
  U_CHAR *copy = (U_CHAR *) xmalloc (length + 1);
  memcpy ((char *) copy, (char *) buf, length);
  copy[length] = 0;
  SKIP_WHITE_SPACE (copy);
  error ("#error %s", copy);
  return 0;
}

/* Report a warning detected by the program we are processing.
   Use the text of the line in the warning message, then continue.
   (We use error because it prints the filename & line#.) */
static int
do_warning (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword ATTRIBUTE_UNUSED)
{
  int length = limit - buf;
  U_CHAR *copy = (U_CHAR *) xmalloc (length + 1);
  memcpy ((char *) copy, (char *) buf, length);
  copy[length] = 0;
  SKIP_WHITE_SPACE (copy);
  gpc_warning ("#gpc_warning %s", copy);
  return 0;
}

/* handle #if directive by
   1) inserting special `defined' keyword into the hash table
      that gets turned into 0 or 1 by special_symbol (thus,
      if the luser has a symbol called `defined' already, it won't
      work inside the #if directive)
   2) rescan the input into a temporary output buffer
   3) pass the output buffer to the yacc parser and collect a value
   4) clean up the mess left from steps 1 and 2.
   5) call conditional_skip to skip til the next #endif (etc.),
      or not, depending on the value from step 3. */
static int
do_if (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword ATTRIBUTE_UNUSED)
{
  FILE_BUF *ip = &instack[indepth];
  conditional_skip (ip, eval_if_expression (buf, limit - buf) == 0, T_IF);
  return 0;
}

/* handle a #elif directive by not changing if_stack either.
   see the comment above do_else. */
static int
do_elif (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword ATTRIBUTE_UNUSED)
{
  FILE_BUF *ip = &instack[indepth];
  if (if_stack == instack[indepth].if_stack) {
    error ("`$elif' not within a conditional");
    return 0;
  } else {
    if (if_stack->type != T_IF && if_stack->type != T_ELIF && if_stack->type != T_IFOPT) {
      error ("`$elif' after `$else'");
      fprintf (stderr, " (matches line %d", if_stack->lineno);
      if (if_stack->fname != NULL && ip->fname != NULL &&
          strcmp (if_stack->fname, ip->nominal_fname) != 0)
        fprintf (stderr, ", file %s", if_stack->fname);
      fprintf (stderr, ")\n");
    }
    if_stack->type = T_ELIF;
  }
  if (if_stack->if_succeeded)
    skip_if_group (ip, 0);
  else {
    if (eval_if_expression (buf, limit - buf) == 0)
      skip_if_group (ip, 0);
    else {
      ++if_stack->if_succeeded; /* continue processing input */
      output_line_directive (ip, op, 1, same_file);
    }
  }
  return 0;
}

#define yyunget(C) (unget_ch = (C))
#define yyerror(S) error ("conditional expression: %s", (S))
#define OVERFLOW(C) if ((C) && !skip_evaluation) yyerror ("arithmetic overflow")

static int
yylex (void)
{
  /* Some C operators are also supported, so some "common"
     conditional expressions can be shared between Pascal and C. */
  static struct token
  {
    const char *name;
    int token;
  } tokentab[] =
  {
    { "not", '!' },
    { "and", AND },
    { "&&", AND },
    { "or", OR },
    { "||", OR },
    { "xor", XOR },
    { "div", '/' },
    { "shl", LSH },
    { "<<", LSH },
    { "shr", RSH },
    { ">>", RSH },
    { "==", '=' },
    { "<>", NE },
    { "!=", NE },
    { "<=", LE },
    { ">=", GE },
    { "false", False },
    { "true", True },
    { NULL, 0 }
  };
  int i;
  struct token *t;
  if (unget_ch != EOT)
    {
      i = unget_ch;
      unget_ch = EOT;
      return i;
    }
  while (lexptr < lexend && is_space[*lexptr])
    lexptr++;
  if (lexptr >= lexend)
    return EOT;
  for (t = tokentab; t->name; t++)
    if (lexend - lexptr >= (i = strlen (t->name))
        && !strncasecmp ((char *) lexptr, t->name, i)
        && (!is_idchar[(U_CHAR) *(t->name)] || lexend - lexptr == i || !is_idchar[lexptr[i]]))
      {
        lexptr += i;
        return t->token;
      }
  if (*lexptr >= '0' && *lexptr <= '9')
    {
      unsigned HOST_WIDEST_INT n = 0, od;
      int overflow = 0;
      while (lexptr < lexend && *lexptr >= '0' && *lexptr <= '9')
        {
          od = n;
          n = 10 * n + *lexptr++ - '0';
          overflow |= (od > (~(unsigned HOST_WIDEST_INT) 0) / 10) || n < od;
        }
      if (overflow || ((HOST_WIDEST_INT) n) < 0)
        yyerror ("integer constant out of range");
      if (lexptr < lexend && is_idchar[*lexptr])
        yyerror ("missing white space after integer constant");
      yylval = n;
      return INTCST;
    }
  if (is_idchar[*lexptr])
    {
      U_CHAR *c = lexptr;
      while (lexptr < lexend && is_idchar[*lexptr])
        lexptr++;
      if (!skip_evaluation)
        error ("conditional expression: `%.*s' is not defined", (int) (lexptr - c), c);
      return False;
    }
  return *lexptr++;
}

static HOST_WIDEST_INT
factor (void)
{
  HOST_WIDEST_INT i, j;
  int c = yylex ();
  switch (c)
  {
    case '(':
      i = expr ();
      if (yylex () != ')') yyerror ("missing `)'");
      return i;
    case '+':
      return factor ();
    case '-':
      i = factor ();
      j = -i;
      OVERFLOW (j < 0 && i < 0);
      return j;
    case '!':
      return !factor ();
    case False:
      return 0;
    case True:
      return 1;
    case INTCST:
      return yylval;
  }
  yyerror ("parse error");
  while (yylex () != EOT) ;
  return 0;
}

static HOST_WIDEST_INT
term (void)
{
  HOST_WIDEST_INT j = factor (), i, k;
  while (1)
    {
      int c = yylex ();
      i = j;
      switch (c)
      {
        case '*':
          k = factor ();
          j = i * k;
          OVERFLOW (i && (j / i != k || (j < 0 && i < 0 && k < 0)));
          break;
        case '/':
        case '%':
          k = factor ();
          if (k == 0)
            {
              if (!skip_evaluation)
                yyerror ("division by zero");
              k = 1;
            }
          if (c == '/')
            {
              j = i / k;
              OVERFLOW (j < 0 && i < 0 && k < 0);
            }
          else
            j = i % k;
          break;
        case LSH:
          k = factor ();
          j = i << k;
          OVERFLOW (j >> k != i);
          break;
        case RSH:
          j = i >> factor ();
          break;
        case AND:
          skip_evaluation += !i;
          k = factor ();
          skip_evaluation -= !i;
          j = i && k;
          break;
        default:
          yyunget (c);
          return i;
      }
    }
}

static HOST_WIDEST_INT
simple_exp (void)
{
  HOST_WIDEST_INT j = term (), i, k;
  while (1)
    {
      int c = yylex ();
      i = j;
      switch (c)
      {
        case '+':
          k = term ();
          j = i + k;
          OVERFLOW ((i ^ k) >= 0 && (i ^ j) < 0);
          break;
        case '-':
          k = term ();
          j = i - k;
          OVERFLOW ((j ^ k) >= 0 && (j ^ i) < 0);
          break;
        case OR:
          skip_evaluation += !!i;
          k = term ();
          skip_evaluation -= !!i;
          j = i || k;
          break;
        case XOR:
          j = !!i != !!term ();
          break;
        default:
          yyunget (c);
          return i;
      }
    }
}

static HOST_WIDEST_INT
expr (void)
{
  HOST_WIDEST_INT j = simple_exp (), i;
  while (1)
    {
      int c = yylex ();
      i = j;
      switch (c)
      {
        case '=': j = i == simple_exp (); break;
        case NE:  j = i != simple_exp (); break;
        case LE:  j = i <= simple_exp (); break;
        case GE:  j = i >= simple_exp (); break;
        case '<': j = i <  simple_exp (); break;
        case '>': j = i >  simple_exp (); break;
        default:
          yyunget (c);
          return i;
      }
    }
}

/* Evaluate an `#if' expression in BUF, of length LENGTH,
   then parse the result return the value. */
static int
eval_if_expression (U_CHAR *buf, int length)
{
  int value;
  HASHNODE *save_defined = install ((U_CHAR *) "defined", -1, T_SPEC_DEFINED, NULL, -1, 0);
  FILE_BUF temp_obuf;
  temp_obuf = expand_to_temp_buffer (buf, buf + length, 0);
  delete_macro (save_defined);  /* clean up special symbol */
  lexptr = temp_obuf.buf;
  lexend = lexptr + temp_obuf.length;
  unget_ch = EOT;
  skip_evaluation = 0;
  value = expr () != 0;
  if (yylex () != EOT)
    {
      yyerror ("trailing garbage");
      value = 0;
    }
  free (temp_obuf.buf);
  return value;
}

/* Handle ifdef/ifndef. Try to look up the symbol, then do or don't
   skip to the #endif/#else/#elif. */
static int
do_xifdef (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword)
{
  int skip;
  FILE_BUF *ip = &instack[indepth];
  U_CHAR *end;

  /* Discard leading and trailing whitespace. */
  SKIP_WHITE_SPACE (buf);
  while (limit != buf && is_hor_space[limit[-1]]) limit--;

  /* Find the end of the identifier at the beginning. */
  for (end = buf; is_idchar[*end]; end++);

  if (end == buf) {
    skip = (keyword->type == T_IFDEF);
    pedwarn (end == limit ? "`$%s' with no argument"
             : "`$%s' argument starts with punctuation", keyword->name);
  } else {
    HASHNODE *hp;
    if (pedantic && buf[0] >= '0' && buf[0] <= '9')
      pedwarn ("`$%s' argument starts with a digit", keyword->name);
    else if (end != limit)
      pedwarn ("garbage at end of `$%s' argument", keyword->name);
    hp = lookup (buf, end-buf, -1);
    skip = (hp == NULL) ^ (keyword->type == T_IFNDEF);
  }
  conditional_skip (ip, skip, T_IF);
  return 0;
}

/* Handle `ifopt' */
static int
do_ifopt (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op ATTRIBUTE_UNUSED, struct directive *keyword ATTRIBUTE_UNUSED)
{
  FILE_BUF *ip = &instack[indepth];
  int skip = 1, is_negative, option_ok = 0;
  size_t length, this_length = 0;
  char *copy, *copy_option, *p;
  const char *this_option = NULL;
  while (buf < limit && (*buf == ' ' || *buf == '\t' || *buf == '\n' || *buf == '\r'))
    buf++;
  while (buf < limit && (limit[-1] == ' ' || limit[-1] == '\t' || limit[-1] == '\n' || limit[-1] == '\r'))
    limit--;
  length = limit - buf;
  copy = (char *) xmalloc (length + 3);
  copy_option = copy + 2;
  strncpy (copy_option, (char *) buf, length);
  copy_option[length] = 0;
  for (p = copy_option; *p; p++)
    if (*p >= 'A' && *p <= 'Z')
      *p += 'a' - 'A';
  if (length == 2 && (copy_option[1] == '+' || copy_option[1] == '-'))
    {
      const struct gpc_short_option *short_option = gpc_short_options;
      while (short_option->short_name
             && (short_option->short_name != copy_option[0] || (!short_option->bp_option && bp_dialect)))
        short_option++;
      if (short_option->short_name)
        {
          if (copy_option[1] == '+')
            this_option = short_option->long_name;
          else
            this_option = short_option->inverted_long_name;
          option_ok = 1;
        }
    }
  else if (copy_option[0] == 'w' && copy_option[1] == ' ')
    {
      copy_option[0] = '-';
      copy_option[1] = 'W';
      this_option = copy_option;
    }
  else
    {
      copy[0] = '-';
      copy[1] = 'f';
      this_option = copy;
    }
  if (this_option)
    this_length = strlen (this_option);
  if (!option_ok && this_option)
    {
      const char *option;
      int j = 0;
      while ((option = gpc_options[j].name) != NULL &&
             (strlen (option) != this_length || strncmp (option, this_option, this_length) != 0))
        j++;
      option_ok = option && gpc_options[j].source;
    }
  if (option_ok)
    {
      char *positive_option = check_negative_option (this_option, this_length, 1, &is_negative);
      struct option_list *po = current_options;
      while (po && strcmp (po->option, positive_option) != 0)
        po = po->next;
      skip = (po == NULL) != is_negative;  /* `!=' means xor */
      free (positive_option);
    }
  else
    error ("unknown option `%.*s' in `$ifopt'\n", (int) length, buf);
  free (copy);
  conditional_skip (ip, skip, T_IFOPT);
  return 0;
}

/* Push TYPE on stack; then, if SKIP is nonzero, skip ahead. */
static void
conditional_skip (FILE_BUF *ip, int skip, enum node_type type)
{
  IF_STACK_FRAME *temp;
  temp = (IF_STACK_FRAME *) xcalloc (1, sizeof (IF_STACK_FRAME));
  temp->fname = ip->nominal_fname;
  temp->lineno = ip->lineno;
  temp->next = if_stack;
  if_stack = temp;
  if_stack->type = type;
  if (skip != 0) {
    skip_if_group (ip, 0);
    return;
  } else {
    ++if_stack->if_succeeded;
    output_line_directive (ip, &outbuf, 1, same_file);
  }
}

/* skip to #endif, #else, or #elif. Adjust line numbers, etc.
   leaves input ptr at the sharp sign found.
   If ANY is nonzero, return at next directive of any sort. */
static void
skip_if_group (FILE_BUF *ip, int any)
{
  U_CHAR *bp = ip->bufp, *beg_of_line = bp;
  const U_CHAR *cp, *endb, *ident, *after_ident;
  struct directive *kt;
  IF_STACK_FRAME *save_if_stack = if_stack;  /* don't pop past here */
  int ident_length, match = 0;
  endb = ip->buf + ip->length;

  while (bp < endb) {
    char pascal_directive = 0;
    switch (*bp++) {
    case '^':
      if (*bp == '\'' || *bp == '"')
        bp++;
      break;
    case '{':
      if (*bp == '$')
        {
          match = '}';
          ip->bufp = bp++;
          pascal_directive = '{';
          goto directive;
        }
      ip->bufp = bp;
      bp = skip_to_end_of_comment (ip, &ip->lineno, '}');
      break;

    case '/':  /* possible comment */
    case '(':
      if (*bp == '\\' && bp[1] == '\n')
        newline_fix (bp);
      if (IS_COMMENT_START (bp - 1)) {
        ip->bufp = ++bp;
        if (*bp == '$')
          {
            ip->bufp = bp++;
            pascal_directive = '*';
            match = 0;
            goto directive;
          }
        bp = skip_to_end_of_comment (ip, &ip->lineno, 0);
      }
      break;
    case '"':
    case '\'':
      bp = (U_CHAR *) skip_quoted_string (bp - 1, endb, ip->lineno, &ip->lineno, NULL, NULL);
      break;
    case '\\':
      /* Char after backslash loses its special meaning. */
      if (bp < endb) {
        if (*bp == '\n')
          ++ip->lineno;  /* But do update the line-count. */
        bp++;
      }
      break;
    case '\n':
      ++ip->lineno;
      beg_of_line = bp;
      break;
    case '#':
      /* # keyword: a # must be first nonblank char on the line */
      if (beg_of_line == 0)
        break;
      ip->bufp = bp - 1;
      /* Scan from start of line, skipping whitespace, comments
         and backslash-newlines, and see if we reach this #.
         If not, this # is not special. */
      bp = beg_of_line;
      while (1)
        {
          if (is_hor_space[*bp])
            bp++;
          else if (*bp == '\\' && bp[1] == '\n')
            bp += 2;
          else if (IS_COMMENT_START2 (bp))
            bp = skip_one_comment (bp, NULL, NULL, 0);
          /* There is no point in trying to deal with `//' comments here,
             because if there is one, then this # must be part of the
             comment and we would never reach here. */
          else
            break;
        }
      if (bp != ip->bufp) {
        bp = ip->bufp + 1;  /* Reset bp to after the #. */
        break;
      }

    directive:

      bp = ip->bufp + 1;  /* Point after the '#' */

      /* Skip whitespace and \-newline. */
      while (1) {
        if (is_hor_space[*bp])
          bp++;
        else if (!pascal_directive && *bp == '\\' && bp[1] == '\n')
          bp += 2;
        else if (IS_COMMENT_START2 (bp))
          bp = skip_one_comment (bp, NULL, &ip->lineno, 0);
        else if (delphi_comments && *bp == '/' && bp[1] == '/') {
          bp += 2;
          while (bp[-1] == '\\' || *bp != '\n') {
            if (*bp == '\n')
              ip->lineno++;
            bp++;
          }
        }
        else
          break;
      }

      cp = bp;

      /* Now find end of directive name.
         If we encounter a backslash-newline, exchange it with any following
         symbol-constituents so that we end up with a contiguous name. */
      while (1) {
        /* Ignore case in Pascal directives. */
        if (pascal_directive && *bp >= 'A' && *bp <= 'Z')
          *bp += ('a' - 'A');
        if (is_idchar[*bp])
          bp++;
        else {
          if (*bp == '\\' && bp[1] == '\n')
            name_newline_fix (bp);
          if (is_idchar[*bp])
            bp++;
          else break;
        }
      }
      ident_length = bp - cp;
      ident = cp;
      after_ident = bp;

      /* A line of just `#' becomes blank. */
      if (ident_length == 0 && *after_ident == '\n') {
        continue;
      }

      if (ident_length == 0 || !is_idstart[*ident]) {
        const U_CHAR *p = ident;
        while (is_idchar[*p]) {
          if (*p < '0' || *p > '9')
            break;
          p++;
        }
        /* Handle # followed by a line number.
           I think we don't have to bother about BP style
           character constants here, since this is only about
           pedantic warnings, and such constants will be warned
           about by the compiler, anyway, if pedantic. -- Frank */
        if (p != ident && !is_idchar[*p]) {
          if (pedantic)
            pedwarn ("`%c' followed by integer", pascal_directive ? '$' : '#');
          continue;
        }

        if (pedantic && !pascal_directive)
          pedwarn ("invalid preprocessing directive name");
        continue;
      }

      for (kt = directive_table; kt->length >= 0; kt++) {
        IF_STACK_FRAME *temp;
        if (ident_length == kt->length && memcmp (cp, kt->name, kt->length) == 0) {
          /* If we are asked to return on next directive, do so now. */
          if (any)
            return;

          switch (kt->type) {
          case T_IF:
          case T_IFDEF:
          case T_IFNDEF:
          case T_IFOPT:
            temp = (IF_STACK_FRAME *) xcalloc (1, sizeof (IF_STACK_FRAME));
            temp->next = if_stack;
            if_stack = temp;
            temp->lineno = ip->lineno;
            temp->fname = ip->nominal_fname;
            temp->type = kt->type;
            break;
          case T_ELSE:
          case T_ENDIF:
          case T_ELIF:
            if (if_stack == instack[indepth].if_stack) {
              error ("`%c%s' not within a conditional", pascal_directive ? '$' : '#', kt->name);
              break;
            }
            else if (if_stack == save_if_stack)
              return;

            if (kt->type != T_ENDIF) {
              if (if_stack->type == T_ELSE)
                error ("`$else' or `$elif' after `$else'");
              if_stack->type = kt->type;
              break;
            }

            temp = if_stack;
            if_stack = if_stack->next;
            free (temp);
            break;

          default:
            break;
          }
          break;
        }
      }
      /* Don't let erroneous code go by. */
      if (kt->length < 0 && !pascal_directive && pedantic)
        pedwarn ("invalid preprocessing directive name");

      if (pascal_directive)
        {
          ip->bufp = bp;
          skip_to_end_of_comment (ip, &ip->lineno, match);
          bp = ip->bufp;
        }
    }
  }

  ip->bufp = bp;
  /* after this returns, rescan will exit because ip->bufp
     now points to the end of the buffer.
     rescan is responsible for the error message also. */
}

/* Handle an #else directive. Do this by just continuing processing
   without changing if_stack; this is so that the error message
   for missing #endif's etc. will point to the original #if. */
static int
do_else (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword ATTRIBUTE_UNUSED)
{
  FILE_BUF *ip = &instack[indepth];
  if (pedantic) {
    SKIP_WHITE_SPACE (buf);
    if (buf != limit)
      pedwarn ("ignoring text following `$else'");
  }
  if (if_stack == instack[indepth].if_stack) {
    error ("`$else' not within a conditional");
    return 0;
  } else {
    if (if_stack->type != T_IF && if_stack->type != T_ELIF && if_stack->type != T_IFOPT) {
      error ("`$else' after `$else'");
      fprintf (stderr, " (matches line %d", if_stack->lineno);
      if (strcmp (if_stack->fname, ip->nominal_fname) != 0)
        fprintf (stderr, ", file %s", if_stack->fname);
      fprintf (stderr, ")\n");
    }
    if_stack->type = T_ELSE;
  }

  if (if_stack->if_succeeded)
    skip_if_group (ip, 0);
  else {
    ++if_stack->if_succeeded;  /* continue processing input */
    output_line_directive (ip, op, 1, same_file);
  }
  return 0;
}

/* unstack after #endif directive */
static int
do_endif (U_CHAR *buf, U_CHAR *limit, FILE_BUF *op, struct directive *keyword ATTRIBUTE_UNUSED)
{
  if (pedantic) {
    SKIP_WHITE_SPACE (buf);
    if (buf != limit)
      pedwarn ("ignoring text following `$endif'");
  }
  if (if_stack == instack[indepth].if_stack)
    error ("unbalanced `$endif'");
  else {
    IF_STACK_FRAME *temp = if_stack;
    if_stack = if_stack->next;
    free (temp);
    output_line_directive (&instack[indepth], op, 1, same_file);
  }
  return 0;
}

/* Skip a comment, assuming the input ptr immediately follows the
   begin character(s). Bump *LINE_COUNTER for each newline.
   (The canonical line counter is &ip->lineno.)
   Don't use this routine (or the next one) if bumping the line
   counter is not sufficient to deal with newlines in the string. */
static U_CHAR *
skip_to_end_of_comment (FILE_BUF *ip, int *line_counter /* place to remember newlines, or NULL */, int match)
{
  U_CHAR *limit = ip->buf + ip->length, *bp = ip->bufp;
  int start_line = line_counter ? *line_counter : 0, comment_count = 1;
  if (delphi_comments && bp[-2] == '/' && bp[-1] == '/') {
    while (bp < limit) {
      if ((bp[-1] != '\\') && *bp == '\n') {
        break;
      } else {
        if (*bp == '\n' && line_counter)
          ++*line_counter;
        bp++;
      }
    }
    ip->bufp = bp;
    return bp;
  }
  while (bp < limit) {
    switch (*bp++) {
    case '{':
      if (match == '}' || mixed_comments)
        {
          warn_nested_comment ();
          if (nested_comments)
            {
              if (match != '}') warn_mixed_comment ();
              comment_count++;
            }
        }
      break;
    case '(':
      if ((match != '}' || mixed_comments) && bp < limit && *bp == '*' && !(bp + 1 < limit && bp[1] == ')'))
        {
          warn_nested_comment ();
          if (nested_comments)
            {
              if (match == '}') warn_mixed_comment ();
              comment_count++;
            }
          bp++;
        }
      break;
    case '\n':
      /* If this is the end of the file, we have an unterminated comment.
         Don't swallow the newline. We are guaranteed that there will be a
         trailing newline and various pieces assume it's there. */
      if (bp == limit)
        {
          --bp;
          --limit;
          break;
        }
      if (line_counter != NULL)
        ++*line_counter;
      break;
    case '}':
      if (match == '}' || mixed_comments)
        {
          if (match != '}') warn_mixed_comment ();
          ip->bufp = bp;
          if (--comment_count == 0)
            return bp;
        }
      break;
    case '*':
      if (match == '}' && !mixed_comments)
        break;  /* normal char */
      if (match == '}') warn_mixed_comment ();
      if (*bp == '\\' && bp[1] == '\n')
        newline_fix (bp);
      if (*bp == ')') {
        ip->bufp = ++bp;
        if (--comment_count == 0)
          return bp;
      }
      break;
    }
  }
  error_with_line (line_for_error (start_line), "unterminated comment");
  ip->bufp = bp;
  return bp;
}

/* Skip over a quoted string. BP points to the opening quote.
   Returns a pointer after the closing quote. Don't go past LIMIT.
   START_LINE is the line number of the starting point (but it need
   not be valid if the starting point is inside a macro expansion).
   The input stack state is not changed.
   If COUNT_NEWLINES is nonzero, it points to an int to increment
   for each newline passed.
   If BACKSLASH_NEWLINES_P is nonzero, store 1 thru it
   if we pass a backslash-newline.
   If EOFP is nonzero, set *EOFP to 1 if the string is unterminated. */
static const U_CHAR *
skip_quoted_string (const U_CHAR *bp, const U_CHAR *limit, int start_line, int *count_newlines, int *backslash_newlines_p, int *eofp)
{
  U_CHAR c, match;
  match = *bp++;
  while (1) {
    if (bp >= limit) {
      error_with_line (line_for_error (start_line), "unterminated string or character constant");
      error_with_line (multiline_string_line, "possible real start of unterminated constant");
      multiline_string_line = 0;
      if (eofp)
        *eofp = 1;
      break;
    }
    c = *bp++;
    if (c == '\\' && match != '\'') {
      while (*bp == '\\' && bp[1] == '\n') {
        if (backslash_newlines_p)
          *backslash_newlines_p = 1;
        if (count_newlines)
          ++*count_newlines;
        bp += 2;
      }
      if (*bp == '\n' && count_newlines) {
        if (backslash_newlines_p)
          *backslash_newlines_p = 1;
        ++*count_newlines;
      }
      bp++;
    } else if (c == '\n') {
      if (pedantic) {
        error_with_line (line_for_error (start_line), "unterminated string or character constant");
        bp--;
        if (eofp)
          *eofp = 1;
        break;
      }
      if (count_newlines)
        ++*count_newlines;
      if (multiline_string_line == 0)
        multiline_string_line = start_line;
    } else if (c == match)
      break;
  }
  return bp;
}

/* Place into DST a quoted string representing the string SRC.
   Return the address of DST's terminating null. */
static char *
quote_string (char *dst, const char *src)
{
  U_CHAR c;
  *dst++ = '"';
  while ((c = *src++))
    if (c >= ' ' && c <= 126)
      {
        if (c == '"' || c == '\\')
          *dst++ = '\\';
        *dst++ = c;
      }
    else
      {
        sprintf (dst, "\\%03o", c);
        dst += 4;
      }
  *dst++ = '"';
  *dst = 0;
  return dst;
}

/* write out a #line directive, for instance, after an #include file.
   If CONDITIONAL is nonzero, we can omit the #line if it would
   appear to be a no-op, and we can output a few newlines instead
   if we want to increase the line number by a small amount.
   FILE_CHANGE says whether we are entering a file, leaving, or neither. */
static void
output_line_directive (FILE_BUF *ip, FILE_BUF *op, int conditional, enum file_change_code file_change)
{
  int len;
  char *line_directive_buf, *line_end;
  if (no_line_directives || ip->fname == NULL || no_output) {
    op->lineno = ip->lineno;
    return;
  }
  if (conditional) {
    if (ip->lineno == op->lineno)
      return;
    /* If the inherited line number is a little too small,
       output some newlines instead of a #line directive. */
    if (ip->lineno > op->lineno && ip->lineno < op->lineno + 8) {
      check_expand (op, 10);
      while (ip->lineno > op->lineno) {
        *op->bufp++ = '\n';
        op->lineno++;
      }
      return;
    }
  }
  /* Don't output a line number of 0 if we can help it. */
  if (ip->lineno == 0 && ip->bufp - ip->buf < ip->length && *ip->bufp == '\n')
  {
    ip->lineno++;
    ip->bufp++;
  }
  line_directive_buf = (char *) alloca (4 * strlen (ip->nominal_fname) + 100);
  sprintf (line_directive_buf, "# %d ", ip->lineno);
  line_end = quote_string (line_directive_buf + strlen (line_directive_buf), ip->nominal_fname);
  if (file_change != same_file) {
    *line_end++ = ' ';
    *line_end++ = file_change == enter_file ? '1' : '2';
  }
  *line_end++ = '\n';
  len = line_end - line_directive_buf;
  check_expand (op, len + 1);
  if (op->bufp > op->buf && op->bufp[-1] != '\n')
    *op->bufp++ = '\n';
  memcpy ((char *) op->bufp, (char *) line_directive_buf, len);
  op->bufp += len;
  op->lineno = ip->lineno;
}

/* Expand a macro call.
   HP points to the symbol that is the macro being called.
   Put the result of expansion onto the input stack
   so that subsequent input by our caller will use it.
   If macro wants arguments, caller has already verified that
   an argument list follows; arguments come from the input stack. */
static void
macroexpand (HASHNODE *hp, FILE_BUF *op)
{
  int nargs;
  DEFINITION *defn = hp->value.defn;
  U_CHAR *xbuf;
  FILE_BUF *ip2;
  int xbuf_len;
  int start_line = instack[indepth].lineno;
  int rest_args, rest_zero;

  CHECK_DEPTH (return);

  /* it might not actually be a macro. */
  if (hp->type != T_MACRO) {
    special_symbol (hp, op);
    return;
  }

  nargs = defn->nargs;

  if (nargs >= 0) {
    int i;
    struct argdata *args;
    const char *parse_error = 0;

    args = (struct argdata *) alloca ((nargs + 1) * sizeof (struct argdata));

    for (i = 0; i < nargs; i++) {
      args[i].raw = (U_CHAR *) "";
      args[i].expanded = 0;
      args[i].raw_length = args[i].expand_length = args[i].stringified_length = 0;
      args[i].free1 = args[i].free2 = 0;
      args[i].use_count = 0;
    }

    /* Parse all the macro args that are supplied. I counts them.
       The first NARGS args are stored in ARGS. The rest are discarded.
       If rest_args is set then we assume macarg absorbed the rest of the args. */
    i = 0;
    rest_args = 0;
    do {
      /* Discard the open-parenthesis or comma before the next arg. */
      ++instack[indepth].bufp;
      if (rest_args)
        continue;
      if (i < nargs || (nargs == 0 && i == 0)) {
        /* if we are working on last arg which absorbs rest of args... */
        if (i == nargs - 1 && defn->rest_args)
          rest_args = 1;
        parse_error = macarg (&args[i], rest_args);
      }
      else
        parse_error = macarg (NULL, 0);
      if (parse_error) {
        error_with_line (line_for_error (start_line), parse_error);
        break;
      }
      i++;
    } while (*instack[indepth].bufp != ')');

    /* If we got one arg but it was just whitespace, call that 0 args. */
    if (i == 1) {
      U_CHAR *bp = args[0].raw, *lim = bp + args[0].raw_length;
      /* cpp.texi says for foo ( ) we provide one argument.
         However, if foo wants just 0 arguments, treat this as 0. */
      if (nargs == 0)
        while (bp != lim && is_space[*bp]) bp++;
      if (bp == lim)
        i = 0;
    }

    /* Don't output an error message if we have already output one for a parse error above. */
    rest_zero = 0;
    if (nargs == 0 && i > 0) {
      if (!parse_error)
        error ("arguments given to macro `%s'", hp->name);
    } else if (i < nargs) {
      /* the rest args token is allowed to absorb 0 tokens */
      if (i == nargs - 1 && defn->rest_args)
        rest_zero = 1;
      else if (parse_error)
        ;
      else if (i == 0)
        error ("macro `%s' used without args", hp->name);
      else if (i == 1)
        error ("macro `%s' used with just one arg", hp->name);
      else
        error ("macro `%s' used with only %d args", hp->name, i);
    } else if (i > nargs) {
      if (!parse_error)
        error ("macro `%s' used with too many (%d) args", hp->name, i);
    }

    /* Swallow the closeparen. */
    ++instack[indepth].bufp;

    /* If macro wants zero args, we parsed the arglist for checking only.
       Read directly from the macro definition. */
    if (nargs == 0) {
      xbuf = defn->expansion;
      xbuf_len = defn->length;
    } else {
      U_CHAR *exp = defn->expansion;
      int offset;  /* offset in expansion, copied a piece at a time */
      int totlen;  /* total amount of exp buffer filled so far */
      struct reflist *ap, *last_ap;

      /* Macro really takes args. Compute the expansion of this call. */

      /* Compute length in characters of the macro's expansion.
         Also count number of times each arg is used. */
      xbuf_len = defn->length;
      for (ap = defn->pattern; ap != NULL; ap = ap->next) {
        if (ap->stringify)
          xbuf_len += args[ap->argno].stringified_length;
        else if (ap->raw_before || ap->raw_after)
          /* Add 4 for two newline-space markers to prevent
             token concatenation. */
          xbuf_len += args[ap->argno].raw_length + 4;
        else {
          /* We have an ordinary (expanded) occurrence of the arg.
             So compute its expansion, if we have not already. */
          if (args[ap->argno].expanded == 0) {
            FILE_BUF obuf;
            obuf = expand_to_temp_buffer
                     (args[ap->argno].raw, args[ap->argno].raw + args[ap->argno].raw_length, 1);

            args[ap->argno].expanded = obuf.buf;
            args[ap->argno].expand_length = obuf.length;
            args[ap->argno].free2 = obuf.buf;
          }

          /* Add 4 for two newline-space markers to prevent
             token concatenation. */
          xbuf_len += args[ap->argno].expand_length + 4;
        }
        if (args[ap->argno].use_count < 10)
          args[ap->argno].use_count++;
      }

      xbuf = (U_CHAR *) xmalloc (xbuf_len + 1);

      /* Generate in XBUF the complete expansion
         with arguments substituted in.
         TOTLEN is the total size generated so far.
         OFFSET is the index in the definition
         of where we are copying from. */
      offset = totlen = 0;
      for (last_ap = NULL, ap = defn->pattern; ap != NULL; last_ap = ap, ap = ap->next) {
        struct argdata *arg = &args[ap->argno];
        int count_before = totlen;

        /* Add chars to XBUF. */
        for (i = 0; i < ap->nchars; i++, offset++)
          xbuf[totlen++] = exp[offset];

        /* If followed by an empty rest arg with concatenation,
           delete the last run of nonwhite chars. */
        if (rest_zero && totlen > count_before
            && ((ap->rest_args && ap->raw_before)
                || (last_ap != NULL && last_ap->rest_args && last_ap->raw_after))) {
          /* Delete final whitespace. */
          while (totlen > count_before && is_space[xbuf[totlen - 1]])
            totlen--;

          /* Delete the nonwhites before them. */
          while (totlen > count_before && !is_space[xbuf[totlen - 1]])
            totlen--;
        }

        if (ap->stringify != 0) {
          int arglen = arg->raw_length;
          int escaped = 0;
          int in_string = 0;
          int c;
          i = 0;
          while (i < arglen && (c = arg->raw[i], is_space[c]))
            i++;
          while (i < arglen && (c = arg->raw[arglen - 1], is_space[c]))
            arglen--;
          xbuf[totlen++] = '"'; /* insert beginning quote */
          for (; i < arglen; i++) {
            c = arg->raw[i];

            /* Special markers Newline Space generate nothing for a stringified argument. */
            if (c == '\n' && arg->raw[i+1] != '\n') {
              i++;
              continue;
            }

            /* Internal sequences of whitespace are replaced by one space
               except within a string or char token. */
            if (!in_string && (c == '\n' ? arg->raw[i+1] == '\n' : is_space[c])) {
              while (1) {
                /* Note that Newline Space does occur within whitespace
                   sequences; consider it part of the sequence. */
                if (c == '\n' && is_space[arg->raw[i+1]])
                  i += 2;
                else if (c != '\n' && is_space[c])
                  i++;
                else break;
                c = arg->raw[i];
              }
              i--;
              c = ' ';
            }

            if (escaped)
              escaped = 0;
            else {
              if (c == '\\' && in_string != '\'')
                escaped = 1;
              if (in_string) {
                if (c == in_string)
                  in_string = 0;
              } else if (c == '"' || c == '\'')
                in_string = c;
            }

            /* Escape these chars */
            if (c == '"' || (in_string && c == '\\'))
              xbuf[totlen++] = '\\';
            if (c >= ' ' && c <= 126)
              xbuf[totlen++] = c;
            else {
              sprintf ((char *) &xbuf[totlen], "\\%03o", (unsigned int) c);
              totlen += 4;
            }
          }
          xbuf[totlen++] = '"'; /* insert ending quote */
        } else if (ap->raw_before || ap->raw_after) {
          U_CHAR *p1 = arg->raw;
          U_CHAR *l1 = p1 + arg->raw_length;
          if (ap->raw_before) {
            while (p1 != l1 && is_space[*p1]) p1++;
            while (p1 != l1 && is_idchar[*p1])
              xbuf[totlen++] = *p1++;
            /* Delete any no-reexpansion marker that follows
               an identifier at the beginning of the argument
               if the argument is concatenated with what precedes it. */
            if (p1[0] == '\n' && p1[1] == '-')
              p1 += 2;
          } else {
          /* Ordinary expanded use of the argument.
             Put in newline-space markers to prevent token pasting. */
            xbuf[totlen++] = '\n';
            xbuf[totlen++] = ' ';
          }
          if (ap->raw_after) {
            /* Arg is concatenated after: delete trailing whitespace,
               whitespace markers, and no-reexpansion markers. */
            while (p1 != l1) {
              if (is_space[l1[-1]]) l1--;
              else if (l1[-1] == '-') {
                U_CHAR *p2 = l1 - 1;
                /* If a `-' is preceded by an odd number of newlines then it
                   and the last newline are a no-reexpansion marker. */
                while (p2 != p1 && p2[-1] == '\n') p2--;
                if ((l1 - 1 - p2) & 1) {
                  l1 -= 2;
                }
                else break;
              }
              else break;
            }
          }

          memcpy ((char *) (xbuf + totlen), (char *) p1, l1 - p1);
          totlen += l1 - p1;
          if (!ap->raw_after) {
            /* Ordinary expanded use of the argument.
               Put in newline-space markers to prevent token pasting. */
            xbuf[totlen++] = '\n';
            xbuf[totlen++] = ' ';
          }
        } else {
          /* Ordinary expanded use of the argument.
             Put in newline-space markers to prevent token pasting. */
          xbuf[totlen++] = '\n';
          xbuf[totlen++] = ' ';
          memcpy ((char *) (xbuf + totlen), (char *) arg->expanded, arg->expand_length);
          totlen += arg->expand_length;
          xbuf[totlen++] = '\n';
          xbuf[totlen++] = ' ';
          /* If a macro argument with newlines is used multiple times,
             then only expand the newlines once. This avoids creating output
             lines which don't correspond to any input line, which confuses
             gdb and gcov. */
          if (arg->use_count > 1 && arg->newlines > 0) {
            arg->use_count = 1;
            arg->expand_length = change_newlines (arg->expanded, arg->expand_length);
          }
        }

        if (totlen > xbuf_len)
          abort ();
      }

      /* If there is anything left of the definition after handling the arg list, copy that in too. */
      for (i = offset; i < defn->length; i++) {
        /* if we've reached the end of the macro */
        if (exp[i] == ')')
          rest_zero = 0;
        if (!(rest_zero && last_ap != NULL && last_ap->rest_args && last_ap->raw_after))
          xbuf[totlen++] = exp[i];
      }

      xbuf[totlen] = 0;
      xbuf_len = totlen;

      for (i = 0; i < nargs; i++) {
        if (args[i].free1 != 0)
          free (args[i].free1);
        if (args[i].free2 != 0)
          free (args[i].free2);
      }
    }
  } else {
    xbuf = defn->expansion;
    xbuf_len = defn->length;
  }

  /* Now put the expansion on the input stack so our caller will commence reading from it. */
  ip2 = &instack[++indepth];
  ip2->fname = 0;
  ip2->nominal_fname = 0;
  /* This may not be exactly correct, but will give much better error
     messages for nested macro calls than using a line number of zero. */
  ip2->lineno = start_line;
  ip2->buf = xbuf;
  ip2->length = xbuf_len;
  ip2->bufp = xbuf;
  ip2->free_ptr = (nargs > 0) ? xbuf : 0;
  ip2->macro = hp;
  ip2->if_stack = if_stack;
  hp->type = T_DISABLED;
}

/* Parse a macro argument and store the info on it into *ARGPTR.
   REST_ARGS is passed to macarg1 to make it absorb the rest of the args.
   Return nonzero to indicate a syntax error. */
static const char *
macarg (struct argdata *argptr, int rest_args)
{
  FILE_BUF *ip = &instack[indepth];
  int parenthesis = 0;
  int newlines = 0;
  int comments = 0;
  const char *result = 0;

  /* Try to parse as much of the argument as exists at this input stack level. */
  U_CHAR *bp = macarg1 (ip->bufp, ip->buf + ip->length, &parenthesis, &newlines, &comments, rest_args);

  /* If we find the end of the argument at this level,
     set up *ARGPTR to point at it in the input stack. */
  if (!(ip->fname != 0 && (newlines != 0 || comments != 0)) && bp != ip->buf + ip->length) {
    if (argptr != 0) {
      argptr->raw = ip->bufp;
      argptr->raw_length = bp - ip->bufp;
      argptr->newlines = newlines;
    }
    ip->bufp = bp;
  } else {
    /* This input stack level ends before the macro argument does.
       We must pop levels and keep parsing. Therefore, we must allocate
       a temporary buffer and copy the macro argument into it. */
    int bufsize = bp - ip->bufp;
    int extra = newlines;
    U_CHAR *buffer = (U_CHAR *) xmalloc (bufsize + extra + 1);
    int final_start = 0;

    memcpy ((char *) buffer, (char *) ip->bufp, bufsize);
    ip->bufp = bp;
    ip->lineno += newlines;

    while (bp == ip->buf + ip->length) {
      if (instack[indepth].macro == 0) {
        result = "unterminated macro call";
        break;
      }
      ip->macro->type = T_MACRO;
      if (ip->free_ptr)
        free (ip->free_ptr);
      ip = &instack[--indepth];
      newlines = 0;
      comments = 0;
      bp = macarg1 (ip->bufp, ip->buf + ip->length, &parenthesis, &newlines, &comments, rest_args);
      final_start = bufsize;
      bufsize += bp - ip->bufp;
      extra += newlines;
      buffer = (U_CHAR *) xrealloc (buffer, bufsize + extra + 1);
      memcpy ((char *) (buffer + bufsize - (bp - ip->bufp)), (char *) ip->bufp, bp - ip->bufp);
      ip->bufp = bp;
      ip->lineno += newlines;
    }

    /* Now, if arg is actually wanted, record its raw form,
       discarding comments and duplicating newlines in whatever
       part of it did not come from a macro expansion.
       EXTRA space has been preallocated for duplicating the newlines.
       FINAL_START is the index of the start of that part. */
    if (argptr != 0) {
      argptr->raw = buffer;
      argptr->raw_length = bufsize;
      argptr->free1 = buffer;
      argptr->newlines = newlines;
      if ((newlines || comments) && ip->fname != 0)
        argptr->raw_length = final_start
          + discard_comments (argptr->raw + final_start, argptr->raw_length - final_start, newlines);
      argptr->raw[argptr->raw_length] = 0;
      if (argptr->raw_length > bufsize + extra)
        abort ();
    }
  }

  /* If we are not discarding this argument,
     macroexpand it and compute its length as stringified.
     All this info goes into *ARGPTR. */

  if (argptr != 0) {
    U_CHAR *buf, *lim;
    int totlen;

    buf = argptr->raw;
    lim = buf + argptr->raw_length;

    while (buf != lim && is_space[*buf])
      buf++;
    while (buf != lim && is_space[lim[-1]])
      lim--;
    totlen = 2;  /* Count opening and closing quote. */
    while (buf != lim) {
      U_CHAR c = *buf++;
      totlen++;
      if (c == '"' || c == '\\') /* escape these chars */
        totlen++;
      else if (!(c >= ' ' && c <= 126))
        totlen += 3;
    }
    argptr->stringified_length = totlen;
  }
  return result;
}

/* Scan text from START (inclusive) up to LIMIT (exclusive),
   counting parentheses in *DEPTHPTR, and return if reach LIMIT
   or before a `)' that would make *DEPTHPTR negative
   or before a comma when *DEPTHPTR is zero.
   Single and double quotes are matched and termination
   is inhibited within them. Comments also inhibit it.
   Value returned is pointer to stopping place.
   Increment *NEWLINES each time a newline is passed.
   REST_ARGS notifies macarg1 that it should absorb the rest of the args.
   Set *COMMENTS to 1 if a comment is seen. */
static U_CHAR *
macarg1 (U_CHAR *start, U_CHAR *limit, int *depthptr, int *newlines, int *comments, int rest_args)
{
  U_CHAR *bp = start;
  while (bp < limit) {
    switch (*bp) {
    case '^':
      if (*bp == '\'' || *bp == '"')
        bp++;
      break;
    case '{':
      *comments = 1;
      bp = skip_one_comment (bp, limit, newlines, 1);
      bp--; /* is incremented after the switch */
      break;
    case '(':
      if (bp[1] == '\\' && bp[2] == '\n')
        newline_fix (bp + 1);
      if (bp[1] == '*') {
        if (bp + 1 >= limit)
          break;
        *comments = 1;
        bp = skip_one_comment (bp, limit, newlines, 1);
        bp--; /* is incremented after the switch */
        break;
      }
      (*depthptr)++;
      break;
    case ')':
      if (--(*depthptr) < 0)
        return bp;
      break;
    case '\n':
      ++*newlines;
      break;
    case '/':
      if (bp[1] == '\\' && bp[2] == '\n')
        newline_fix (bp + 1);
      if (delphi_comments && bp[1] == '/') {
        *comments = 1;
        bp += 2;
        while (bp < limit && (*bp != '\n' || bp[-1] == '\\')) {
          if (*bp == '\n') ++*newlines;
          bp++;
        }
        /* Now count the newline that we are about to skip. */
        ++*newlines;
        break;
      }
      break;
    case '\'':
    case '"':
      {
        int quotec;
        for (quotec = *bp++; bp + 1 < limit && *bp != quotec; bp++) {
          if (*bp == '\\' && quotec != '\'') {
            bp++;
            if (*bp == '\n')
              ++*newlines;
            while (*bp == '\\' && bp[1] == '\n') {
              bp += 2;
            }
          } else if (*bp == '\n') {
            ++*newlines;
            if (quotec == '\'')
              break;
          }
        }
      }
      break;
    case ',':
      /* if we've returned to lowest level and we aren't absorbing all args */
      if ((*depthptr) == 0 && rest_args == 0)
        return bp;
      break;
    }
    bp++;
  }
  return bp;
}

/* Discard comments and duplicate newlines in the string of length
   LENGTH at START, except inside of string constants.
   The string is copied into itself with its beginning staying fixed.
   NEWLINES is the number of newlines that must be duplicated.
   We assume that that much extra space is available past the end
   of the string. */
static int
discard_comments (U_CHAR *start, int length, int newlines)
{
  U_CHAR *ibp, *obp, *limit;
  int c;

  /* If we have newlines to duplicate, copy everything that many characters
     up. Then, in the second part, we will have room to insert the newlines
     while copying down.
     NEWLINES may actually be too large, because it counts newlines in string
     constants, and we don't duplicate those. But that does no harm. */
  if (newlines > 0) {
    ibp = start + length;
    obp = ibp + newlines;
    limit = start;
    while (limit != ibp)
      *--obp = *--ibp;
  }

  ibp = start + newlines;
  limit = start + length + newlines;
  obp = start;
  while (ibp < limit) {
    *obp++ = c = *ibp++;
    switch (c) {
    case '^':
      if (*ibp == '\'' || *ibp == '"')
        *obp++ = *ibp++;
      break;
    case '\n':
      /* Duplicate the newline. */
      *obp++ = '\n';
      break;

    case '\\':
      if (*ibp == '\n') {
        obp--;
        ibp++;
      }
      break;

    case '{':
      ibp = skip_one_comment (ibp - 1, limit, NULL, 1);
      /* Comments are equivalent to spaces. */
      obp[-1] = ' ';  /* Do this *after* skip_one_comment so as to not
                         overwrite the comment's starting character */
      break;
    case '/':
    case '(':
      if (*ibp == '\\' && ibp[1] == '\n')
        newline_fix (ibp);
      /* Delete any comment. */
      if (delphi_comments && c == '/' && ibp[0] == '/') {
        /* Comments are equivalent to spaces. */
        obp[-1] = ' ';
        ibp++;
        while (ibp < limit && (*ibp != '\n' || ibp[-1] == '\\'))
          ibp++;
        break;
      }
      if (c != '(' || ibp[0] != '*' || ibp + 1 >= limit)
        break;
      ibp = skip_one_comment (ibp - 1, limit, NULL, 1);
      /* Comments are equivalent to spaces. */
      obp[-1] = ' ';  /* Do this *after* skip_one_comment so as to not
                         overwrite the comment's starting character */
      break;

    case '\'':
    case '"':
      /* Notice and skip strings, so that we don't think that comments start
         inside them, and so we don't duplicate newlines in them. */
      {
        int quotec = c;
        while (ibp < limit) {
          *obp++ = c = *ibp++;
          if (c == quotec)
            break;
          if (c == '\n' && quotec == '\'')
            break;
          if (c == '\\' && quotec != '\'' && ibp < limit) {
            while (*ibp == '\\' && ibp[1] == '\n')
              ibp += 2;
            *obp++ = *ibp++;
          }
        }
      }
      break;
    }
  }
  return obp - start;
}

/* Turn newlines to spaces in the string of length LENGTH at START,
   except inside of string constants.
   The string is copied into itself with its beginning staying fixed. */
static int
change_newlines (U_CHAR *start, int length)
{
  U_CHAR *ibp, *obp, *limit;
  int c;
  ibp = start;
  limit = start + length;
  obp = start;
  while (ibp < limit) {
    *obp++ = c = *ibp++;
    switch (c) {
    case '\n':
      /* If this is a double NEWLINE, then this is a real newline in the string.
         Skip past the newline and its duplicate. Put a space in the output. */
      if (*ibp == '\n')
        {
          ibp++;
          obp--;
          *obp++ = ' ';
        }
      break;

    case '^':
      if (*ibp == '\'' || *ibp == '"')
        *obp++ = *ibp++;
      break;
    case '\'':
    case '"':
      /* Notice and skip strings, so that we don't delete newlines in them. */
      {
        int quotec = c;
        while (ibp < limit) {
          *obp++ = c = *ibp++;
          if (c == quotec)
            break;
          if (c == '\n' && quotec == '\'')
            break;
        }
      }
      break;
    }
  }
  return obp - start;
}

/* Print error message and increment count of errors. */
static void
error (const char *msg, ...)
{
  va_list args;
  va_start (args, msg);
  verror (msg, args);
  va_end (args);
}

static void
verror (const char *msg, va_list args)
{
  int i;
  FILE_BUF *ip = NULL;
  print_containing_files ();
  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  if (ip != NULL)
    fprintf (stderr, "%s:%d: ", ip->nominal_fname, ip->lineno);
  vfprintf (stderr, msg, args);
  fprintf (stderr, "\n");
  errors++;
}

/* Error including a message from `errno'. */
static void
error_from_errno (const char *name)
{
  int i;
  FILE_BUF *ip = NULL;
  print_containing_files ();
  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  if (ip != NULL)
    fprintf (stderr, "%s:%d: ", ip->nominal_fname, ip->lineno);
  fprintf (stderr, "%s: %s\n", name, xstrerror (errno));
  errors++;
}

/* Print warning. */
static void
gpc_warning (const char *msg, ...)
{
  va_list args;
  va_start (args, msg);
  vwarning (msg, args);
  va_end (args);
}

static void
vwarning (const char *msg, va_list args)
{
  int i;
  FILE_BUF *ip = NULL;
  if (inhibit_warnings)
    return;
  if (warnings_are_errors)
    errors++;
  print_containing_files ();
  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  if (ip != NULL)
    fprintf (stderr, "%s:%d: ", ip->nominal_fname, ip->lineno);
  fprintf (stderr, "warning: ");
  vfprintf (stderr, msg, args);
  fprintf (stderr, "\n");
}

static void
error_with_line (int line, const char *msg, ...)
{
  int i;
  FILE_BUF *ip = NULL;
  va_list args;
  va_start (args, msg);
  print_containing_files ();
  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  if (ip != NULL)
    fprintf (stderr, "%s:%d: ", ip->nominal_fname, line);
  vfprintf (stderr, msg, args);
  fprintf (stderr, "\n");
  errors++;
  va_end (args);
}

/* Print an error or warning message. */
static void
pedwarn (const char *msg, ...)
{
  va_list args;
  va_start (args, msg);
  if (pedantic_errors)
    verror (msg, args);
  else
    vwarning (msg, args);
  va_end (args);
}

/* Report a warning (or an error if pedantic_errors)
   giving specified file name and line number, not current. */
static void
pedwarn_with_file_and_line (const char *file, int line, const char *msg, ...)
{
  va_list args;
  if (!pedantic_errors && inhibit_warnings)
    return;
  if (file != NULL)
    fprintf (stderr, "%s:%d: ", file, line);
  if (pedantic_errors)
    errors++;
  if (!pedantic_errors)
    fprintf (stderr, "warning: ");
  va_start (args, msg);
  vfprintf (stderr, msg, args);
  va_end (args);
  fprintf (stderr, "\n");
}

/* Print the file names and line numbers of the #include
   directives which led to the current file. */
static void
print_containing_files (void)
{
  FILE_BUF *ip = NULL;
  int i;
  int first = 1;
  /* If stack of files hasn't changed since we last printed this info, don't repeat it. */
  if (last_error_tick == input_file_stack_tick)
    return;
  for (i = indepth; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      break;
    }
  /* Give up if we don't find a source file. */
  if (ip == NULL)
    return;
  /* Find the other, outer source files. */
  for (i--; i >= 0; i--)
    if (instack[i].fname != NULL) {
      ip = &instack[i];
      if (first) {
        first = 0;
        fprintf (stderr, "In file included");
      } else
        fprintf (stderr, ",\n                ");
      fprintf (stderr, " from %s:%d", ip->nominal_fname, ip->lineno);
    }
  if (!first)
    fprintf (stderr, ":\n");
  /* Record we have printed the status as of this time. */
  last_error_tick = input_file_stack_tick;
}

/* Return the line at which an error occurred.
   The error is not necessarily associated with the current spot
   in the input stack, so LINE says where. LINE will have been
   copied from ip->lineno for the current input level.
   If the current level is for a file, we return LINE.
   But if the current level is not for a file, LINE is meaningless.
   In that case, we return the lineno of the innermost file. */
static int
line_for_error (int line)
{
  int i;
  int line1 = line;
  for (i = indepth; i >= 0; ) {
    if (instack[i].fname != 0)
      return line1;
    i--;
    if (i < 0)
      return 0;
    line1 = instack[i].lineno;
  }
  abort ();
  /* NOTREACHED */
  return 0;
}

/* If OBUF doesn't have NEEDED bytes after OPTR, make it bigger.
   As things stand, nothing is ever placed in the output buffer to be
   removed again except when it's KNOWN to be part of an identifier,
   so flushing and moving down everything left, instead of expanding,
   should work ok. You might think void was cleaner for the return type,
   but that would get type mismatch in check_expand in strict ANSI. */
static int
grow_outbuf (FILE_BUF *obuf, int needed)
{
  U_CHAR *p;
  int minsize;

  if (obuf->length - (obuf->bufp - obuf->buf) > needed)
    return 0;

  /* Make it at least twice as big as it is now. */
  obuf->length *= 2;
  /* Make it have at least 150% of the free space we will need. */
  minsize = (3 * needed) / 2 + (obuf->bufp - obuf->buf);
  if (minsize > obuf->length)
    obuf->length = minsize;
  p = (U_CHAR *) xrealloc (obuf->buf, obuf->length);
  obuf->bufp = p + (obuf->bufp - obuf->buf);
  obuf->buf = p;
  return 0;
}

/* Symbol table for macro names and special symbols */

/* install a name in the main hash table, even if it is already there.
   name stops with first non alphanumeric, except leading '#'.
   caller must check against redefinition if that is desired.
   delete_macro () removes things installed by install () in fifo order.
   this is important because of the `defined' special symbol used
   in #if, and also if pushdef/popdef directives are ever implemented.

   If LEN is >= 0, it is the length of the name.
   Otherwise, compute the length by scanning the entire name.

   If HASH is >= 0, it is the precomputed hash code.
   Otherwise, compute the hash code. */
static HASHNODE *
install (U_CHAR *name, int len, enum node_type type, char *value, int hash, int case_sensitive)
{
  HASHNODE *hp;
  int i, bucket;
  U_CHAR *p, *q;
  if (len < 0) {
    for (p = name; is_idchar[*p]; p++) ;
    len = p - name;
  }
  if (hash < 0)
    hash = hashf (name, len, HASHSIZE);
  i = sizeof (HASHNODE) + len + 1;
  hp = (HASHNODE *) xmalloc (i);
  bucket = hash;
  hp->bucket_hdr = &hashtab[bucket];
  hp->next = hashtab[bucket];
  hashtab[bucket] = hp;
  hp->prev = NULL;
  if (hp->next != NULL)
    hp->next->prev = hp;
  hp->type = type;
  hp->length = len;
  hp->value.cpval = value;
  hp->name = ((U_CHAR *) hp) + sizeof (HASHNODE);
  hp->case_sensitive = case_sensitive;
  p = hp->name;
  q = name;
  for (i = 0; i < len; i++)
    *p++ = *q++;
  hp->name[len] = 0;
  return hp;
}

/* find the most recent hash node for name name (ending with first
   non-identifier char) installed by install
   If LEN is >= 0, it is the length of the name.
   Otherwise, compute the length by scanning the entire name.
   If HASH is >= 0, it is the precomputed hash code.
   Otherwise, compute the hash code. */
static HASHNODE *
lookup (U_CHAR *name, int len, int hash)
{
  U_CHAR *bp;
  HASHNODE *bucket;
  if (len < 0) {
    for (bp = name; is_idchar[*bp]; bp++) ;
    len = bp - name;
  }
  if (hash < 0)
    hash = hashf (name, len, HASHSIZE);
  bucket = hashtab[hash];
  while (bucket) {
    if (bucket->case_sensitive)
      {
        if (bucket->length == len && memcmp (bucket->name, name, len) == 0)
          return bucket;
      }
    else if (bucket->length == len)
      {
        U_CHAR *p = bucket->name, *q = name, cp, cq;
        int i = len;
        while (i > 0 && (cp = *p++, cq = *q++, LOCASE (cp) == LOCASE (cq)))
          i--;
        if (i == 0)
          return bucket;
      }
    bucket = bucket->next;
  }
  return NULL;
}

/* Delete a hash node. Some weirdness to free junk from macros.
   Note that the DEFINITION of a macro is removed from the hash table
   but its storage is not freed. This would be a storage leak
   except that it is not reasonable to keep undefining and redefining
   large numbers of macros many times.
   In any case, this is necessary, because a macro can be #undef'd
   in the middle of reading the arguments to a call to it.
   If #undef freed the DEFINITION, that would crash. */
static void
delete_macro (HASHNODE *hp)
{
  if (hp->prev != NULL)
    hp->prev->next = hp->next;
  if (hp->next != NULL)
    hp->next->prev = hp->prev;
  /* make sure that the bucket chain header that
     the deleted guy was on points to the right thing afterwards. */
  if (hp == *hp->bucket_hdr)
    *hp->bucket_hdr = hp->next;
  free (hp);
}

/* return hash function on name. must be compatible with the one
   computed a step at a time, elsewhere */
static int
hashf (U_CHAR *name, int len, int hashsize)
{
  int r = 0;
  while (len--)
    {
      /* HASHSTEP now evaluates its 2nd argument multiple times */
      U_CHAR c = *name++;
      r = HASHSTEP (r, c);
    }
  return MAKE_POS (r) % hashsize;
}

void
initialize_char_syntax (void)
{
  int i;
  for (i = 'a'; i <= 'z'; i++) {
    is_idchar[i - 'a' + 'A'] = 1;
    is_idchar[i] = 1;
    is_idstart[i - 'a' + 'A'] = 1;
    is_idstart[i] = 1;
  }
  for (i = '0'; i <= '9'; i++)
    is_idchar[i] = 1;
  is_idchar['_'] = 1;
  is_idstart['_'] = 1;

  is_hor_space[' '] = 1;
  is_hor_space['\t'] = 1;
  is_hor_space['\v'] = 1;
  is_hor_space['\f'] = 1;
  is_hor_space['\r'] = 1;

  for (i = 0; i <= 255; i++)
    is_space[i] = is_hor_space[i];
  is_space['\n'] = 1;
}

/* Initialize the built-in macros. */
static void
initialize_builtins (void)
{
  install ((U_CHAR *) "__LINE__", -1, T_SPECLINE, NULL, -1, 1);
  install ((U_CHAR *) "__DATE__", -1, T_DATE, NULL, -1, 1);
  install ((U_CHAR *) "__FILE__", -1, T_FILE, NULL, -1, 1);
  install ((U_CHAR *) "__BASE_FILE__", -1, T_BASE_FILE, NULL, -1, 1);
  install ((U_CHAR *) "__INCLUDE_LEVEL__", -1, T_INCLUDE_LEVEL, NULL, -1, 1);
  install ((U_CHAR *) "__VERSION__", -1, T_VERSION, NULL, -1, 1);
  install ((U_CHAR *) "__TIME__", -1, T_TIME, NULL, -1, 1);
}

/* process a given definition string, for initialization
   If STR is just an identifier, define it with value 1.
   If STR has anything after the identifier, then it should
   be identifier=definition. */
void
make_definition (const char *str, int case_sensitive)
{
  FILE_BUF *ip;
  struct directive *kt;
  const U_CHAR *p = (U_CHAR *) str;
  char *buf, *q;
  if (!is_idstart[*p]) {
    error ("malformed option `-D %s'", str);
    return;
  }
  while (is_idchar[*++p])
    ;
  if (*p == '(') {
    while (is_idchar[*++p] || *p == ',' || is_hor_space[*p])
      ;
    if (*p++ != ')')
      p = (const U_CHAR *) str;  /* error */
  }
  if (*p == 0) {
    buf = (char *) alloca (p - (U_CHAR *) str + 4);
    strcpy (buf, str);
    strcat (buf, " 1");
  } else if (*p != '=') {
    error ("malformed option `-D %s'", str);
    return;
  } else {
    /* Copy the entire option so we can modify it. */
    buf = (char *) alloca (2 * strlen (str) + 1);
    strncpy (buf, str, p - (const U_CHAR *) str);
    /* Change the = to a space. */
    buf[p - (const U_CHAR *) str] = ' ';
    /* Scan for any backslash-newline and remove it. */
    p++;
    q = &buf[p - (const U_CHAR *) str];
    while (*p) {
      if (*p == '^' && (p[1] == '\'' || p[1] == '"'))
        {
          *q++ = *p++;
          *q++ = *p++;
        }
      else if (*p == '"' || *p == '\'') {
        int unterminated = 0;
        const U_CHAR *p1 = skip_quoted_string (p, p + strlen ((char *) p), 0, NULL, NULL, &unterminated);
        if (unterminated)
          return;
        while (p != p1)
          if (*p == '\\' && p[1] == '\n')
            p += 2;
          else
            *q++ = *p++;
      } else if (*p == '\\' && p[1] == '\n')
        p += 2;
      /* Change newline chars into newline-markers. */
      else if (*p == '\n')
        {
          *q++ = '\n';
          *q++ = '\n';
          p++;
        }
      else
        *q++ = *p++;
    }
    *q = 0;
  }
  ip = &instack[++indepth];
  ip->nominal_fname = ip->fname = "*Initialization*";
  ip->buf = ip->bufp = (U_CHAR *) buf;
  ip->length = strlen (buf);
  ip->lineno = 1;
  ip->macro = 0;
  ip->free_ptr = 0;
  ip->if_stack = if_stack;
  for (kt = directive_table; kt->type != T_DEFINE; kt++)
    ;
  /* Pass NULL instead of OP, since this is a "predefined" macro. */
  do_define1 ((U_CHAR *) buf, (U_CHAR *) buf + strlen (buf), NULL, kt, case_sensitive, NULL);
  --indepth;
}

static void
make_undef (char *str, FILE_BUF *op)
{
  FILE_BUF *ip;
  struct directive *kt;
  ip = &instack[++indepth];
  ip->nominal_fname = ip->fname = "*undef*";
  ip->buf = ip->bufp = (U_CHAR *) str;
  ip->length = strlen (str);
  ip->lineno = 1;
  ip->macro = 0;
  ip->free_ptr = 0;
  ip->if_stack = if_stack;
  for (kt = directive_table; kt->type != T_UNDEF; kt++)
    ;
  do_undef ((U_CHAR *) str, (U_CHAR *) str + strlen (str), op, kt);
  --indepth;
}

/* Append a chain of `struct file_name_list's
   to the end of the main include chain.
   FIRST is the beginning of the chain to append, and LAST is the end. */
static void
append_include_chain (struct file_name_list *first, struct file_name_list *last)
{
  struct file_name_list *dir;
  if (!first || !last)
    return;
  if (include == 0)
    include = first;
  else
    last_include->next = first;
  if (first_bracket_include == 0)
    first_bracket_include = first;
  for (dir = first; ; dir = dir->next) {
    int len = strlen (dir->fname) + INCLUDE_LEN_FUDGE;
    if (len > max_include_len)
      max_include_len = len;
    if (dir == last)
      break;
  }
  last->next = NULL;
  last_include = last;
}

static void
perror_with_name (const char *name)
{
  fprintf (stderr, "%s: ", progname);
  fprintf (stderr, "%s: %s\n", name, xstrerror (errno));
  errors++;
}

static void
pfatal_with_name (const char *name)
{
  perror_with_name (name);
  exit (FATAL_EXIT_CODE);
}

/* Handler for SIGPIPE. */
static void
pipe_closed (int sig ATTRIBUTE_UNUSED)
{
  fatal ("output pipe has been closed");
}


static void
fatal (const char *msg, ...)
{
  va_list args;
  fprintf (stderr, "%s: ", progname);
  va_start (args, msg);
  vfprintf (stderr, msg, args);
  va_end (args);
  fprintf (stderr, "\n");
  exit (FATAL_EXIT_CODE);
}

#ifndef EGCS
/* return the descriptive text associated with an `errno' code. */
static const char *
xstrerror (int errnum)
{
  const char *result;
#ifndef HAVE_STRERROR
  result = (char *) ((errnum < sys_nerr) ? sys_errlist[errnum] : 0);
#else
  result = strerror (errnum);
#endif
  if (!result)
    result = "undocumented I/O error";
  return result;
}
#endif

#ifndef EGCS
PTR
xcalloc (size_t number, size_t size)
{
  size_t total = number * size;
  PTR ptr = (PTR) malloc (total);
  if (!ptr)
    fatal ("memory exhausted");
  memset (ptr, 0, total);
  return ptr;
}
#endif
