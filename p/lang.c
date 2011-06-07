/*Language-specific hook definitions for Pascal front end.

  Copyright (C) 1991-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Jan-Jaap van der Heijden <j.j.vanderheijden@student.utwente.nl>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

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
#include "gpcpp.h"
#ifdef EGCS97
#include "langhooks.h"
#include "langhooks-def.h"
#endif
#ifdef GCC_3_3
#include "gtype-p.h"
#endif

#ifdef GCC_4_0
#include "tree-gimple.h"
#endif

/* The following functions are not called from GPC, but needed by
   the backend. Depending on the GCC version, they're simply called
   as extern, so we can't make them static (yet). */
extern void print_lang_decl (FILE *, tree, int);
extern void print_lang_type (FILE *, tree, int);
extern void print_lang_identifier (FILE *, tree, int);
extern void lang_print_xnode (FILE *, tree, int);
extern void lang_init_options (void);
extern void add_pascal_tree_codes (void);
#ifdef EGCS97
extern const char *init_parse (const char *);
#else
extern char *init_parse (char *);
#endif
#ifdef EGCS
extern int lang_decode_option (int, char **);
#ifdef EGCS97
extern const char *lang_init (const char *);
#else
extern void lang_init (void);
#endif
void finish_parse (void);
#endif
extern tree maybe_build_cleanup (tree);
#ifdef GCC_3_3
extern int yyparse (void);
static void pascal_parse (int);
#endif

#ifdef GCC_3_4
int save_argc;
char * * save_argv;
#endif

#ifndef GCC_3_4
extern char * asm_file_name;
#endif
static void open_gpcpp_output (const char *out_fname);
static void call_gpcpp (const char * filename, FILE * fi);

static FILE * gpcpp_out_stream;
static const char * gpcpp_out_fname;

void open_input (const char *filename);

#ifdef EGCS97
const char *language_string = "GNU Pascal";
#else
/* Declared without `const' in ../config/mips/mips.h */
char *language_string = "GNU Pascal";
#endif

#ifdef GCC_3_4
static rtx
pascal_expand_expr (tree t, rtx r, enum machine_mode mm, int em, rtx *a ATTRIBUTE_UNUSED)
#else
#ifdef GCC_3_3
static rtx pascal_expand_expr (tree, rtx, enum machine_mode, int);
static rtx
pascal_expand_expr (tree t, rtx r, enum machine_mode mm, int em)
#else
static rtx pascal_expand_expr (tree, rtx, enum machine_mode, enum expand_modifier);
static rtx
pascal_expand_expr (tree t, rtx r, enum machine_mode mm, enum expand_modifier em)
#endif
#endif
{
#ifndef GCC_4_0
  enum tree_code code = TREE_CODE (t);
  if (code == PASCAL_BIT_FIELD_REF)
    return expand_expr (
             build_pascal_packed_array_ref (
               TREE_OPERAND (t, 0),
               TREE_OPERAND (t, 1),
               TREE_OPERAND (t, 2),
               1), r, mm, em);
  else if (code == RANGE_CHECK_EXPR 
            || code == IO_RANGE_CHECK_EXPR)
    return expand_expr (
             build_range_check (
               TREE_OPERAND (t, 0),
               TREE_OPERAND (t, 1),
               TREE_OPERAND (t, 2),
               code == IO_RANGE_CHECK_EXPR, 0),
             r, mm, em);
  else if (code == PASCAL_CONSTRUCTOR_CALL)
    return expand_expr (
             build_predef_call (p_New, TREE_OPERAND (t, 0)),
             r, mm, em);

#if 0
  if (code == NON_RVALUE_EXPR)
    {
       error ("Function requires parameters");
       return expand_expr (error_mark_node, r, mm, em);
    }
#endif
  else
#endif
    gcc_unreachable ();
}

#ifdef GCC_4_0
int
pascal_gimplify_expr (tree *expr_p, tree *pre_p ATTRIBUTE_UNUSED,
                   tree *post_p ATTRIBUTE_UNUSED)
{
  tree t = *expr_p;
  enum tree_code code = TREE_CODE (t);
  tree res;
  switch (code)
    {
    case PASCAL_BIT_FIELD_REF:      
      res = build_pascal_packed_array_ref (
               TREE_OPERAND (t, 0),
               TREE_OPERAND (t, 1),
               TREE_OPERAND (t, 2),
               1);
      res = unshare_expr (res);
      break;

    case RANGE_CHECK_EXPR:
    case IO_RANGE_CHECK_EXPR:
      res = build_range_check (
               TREE_OPERAND (t, 0),
               TREE_OPERAND (t, 1),
               TREE_OPERAND (t, 2),
               code == IO_RANGE_CHECK_EXPR, 1);
      res = unshare_expr (res);
      break;

    case PASCAL_CONSTRUCTOR_CALL:
      {
        tree save_statement_list = current_statement_list;
        current_statement_list = NULL_TREE;
        res = build_predef_call (p_New, TREE_OPERAND (t, 0));
        res = build (COMPOUND_EXPR, TREE_TYPE (res),
                       current_statement_list, res);
        current_statement_list = save_statement_list;
        res = unshare_expr (res);
      }
      break;

    case ADDR_EXPR:
      /* Case taken for Ada front end */
      /* If we're taking the address of a constant CONSTRUCTOR, force it to
         be put into static memory.  We know it's going to be readonly given
         the semantics we have and it's required to be static memory in
         the case when the reference is in an elaboration procedure.  */
      if (TREE_CODE (TREE_OPERAND (t, 0)) == CONSTRUCTOR
          && TREE_CONSTANT (TREE_OPERAND (t, 0)))
        {
          tree new_var
            = create_tmp_var (TREE_TYPE (TREE_OPERAND (t, 0)), "constructor");

          TREE_READONLY (new_var) = 1;
          TREE_STATIC (new_var) = 1;
          TREE_ADDRESSABLE (new_var) = 1;
          DECL_INITIAL (new_var) = TREE_OPERAND (t, 0);

          TREE_OPERAND (t, 0) = new_var;
          recompute_tree_invarant_for_addr_expr (t);
          return GS_ALL_DONE;
        }
      return GS_UNHANDLED;

    case PASCAL_SET_CONSTRUCTOR:
      if (TREE_CODE (TREE_TYPE (t)) == SET_TYPE)
        {
          tree type = TREE_TYPE (t);
          tree elt = SET_CONSTRUCTOR_ELTS (t);
          tree domain = TYPE_DOMAIN (type);
          tree domain_min = convert (sbitsizetype, TYPE_MIN_VALUE (domain));
          tree domain_max = convert (sbitsizetype, TYPE_MAX_VALUE (domain));
          tree bitlength;
          tree st;
          tree dest;
          res = create_tmp_var (type, "set_constructor");
          dest = build_unary_op (ADDR_EXPR, res, 0);

      /* Align the set.  */
      if (set_alignment)
        domain_min = size_binop (BIT_AND_EXPR, domain_min, sbitsize_int (-(int)
set_alignment));

      bitlength = size_binop (PLUS_EXPR,
                              size_binop (MINUS_EXPR, domain_max, domain_min),
                              sbitsize_int (1));


     if (TREE_INT_CST_HIGH (bitlength)) {
        error ("set size too big for host integers");
        return GS_ERROR;
      }
      bitlength = convert (sizetype, bitlength);

          /* Clear storage */
          st = build_memset (dest, TYPE_SIZE_UNIT (type), integer_zero_node);
          gimplify_and_add (st, pre_p);
          /* Set bits */
          for (; elt != NULL_TREE; elt = TREE_CHAIN (elt))
            { 
              tree startbit = TREE_PURPOSE (elt);
              tree endbit   = TREE_VALUE (elt);
              if (startbit == NULL_TREE)
            {
              startbit = save_expr (endbit);
              endbit = startbit;
            }
              
          startbit = convert (sizetype, startbit);
          endbit = convert (sizetype, endbit);
          if (! integer_zerop (domain_min))
            {
              startbit = convert (sbitsizetype, startbit);
              endbit = convert (sbitsizetype, endbit);
              startbit = size_binop (MINUS_EXPR, startbit, domain_min);
              endbit = size_binop (MINUS_EXPR, endbit, domain_min);
            }
          startbit = convert (sizetype, startbit);
          endbit = convert (sizetype, endbit);

              st = build_routine_call (setbits_routine_node,
                     tree_cons (NULL_TREE, dest,
                     tree_cons (NULL_TREE, bitlength, 
                     tree_cons (NULL_TREE, startbit,
                     build_tree_list (NULL_TREE, endbit)))));
              gimplify_and_add (st, pre_p);
            }
          break;
        }
      else
        {
//          fprintf(stderr, "pascal_gimplify_expr");
//          debug_tree (t);
        }
      /* Falltrough */
    default:
      return GS_UNHANDLED;
    }
    *expr_p = res;
    return GS_OK;
}
#endif

const char *
pascal_decl_name (tree decl, int verbosity ATTRIBUTE_UNUSED)
{
  return IDENTIFIER_NAME (DECL_NAME (decl));
}

void
print_lang_decl (FILE *file, tree node, int indent)
{
  if (DECL_LANG_SPECIFIC (node))
    {
      print_node (file, TREE_CODE (node) == FUNCTION_DECL ? "pascal_parms" : "pascal_fixuplist",
                        DECL_LANG_INFO1 (node), indent + 4);
      print_node (file, "result_variable", DECL_LANG_INFO2 (node), indent + 4);
      print_node (file, PASCAL_METHOD (node) ? "method_decl" : "operator_decl",
                        DECL_LANG_INFO3 (node), indent + 4);
      print_node (file, "nonlocal_exit_label", DECL_LANG_INFO4 (node), indent + 4);
      if (DECL_LANG_SPECIFIC (node)->used_in_scope)
        {
          indent_to (file, indent + 4);
          fprintf (file, "used_in_scope %li\n", DECL_LANG_SPECIFIC (node)->used_in_scope);
        }
    }
}

void
print_lang_type (FILE *file, tree node, int indent)
{
  print_node (file, "main_variant", TYPE_MAIN_VARIANT (node), indent + 4);
  if TYPE_LANG_SPECIFIC (node)
    {
      static const char *const type_lang_codes[13] =
      {
        NULL,
        "pascal_variant_record",
        "pascal_non_text_file",
        "pascal_text_file",
        "pascal_object",
        "pascal_abstract_object",
        "pascal_undiscriminated_string",
        "pascal_prediscriminated_string",
        "pascal_discriminated_string",
        "pascal_undiscriminated_schema",
        "pascal_prediscriminated_schema",
        "pascal_discriminated_schema",
        "pascal_fake_packed_array"
      };
      static const char *const type_lang_infos[13] =
      {
        NULL,
        "pascal_variant_tag",
        "pascal_file_domain",
        "pascal_file_domain",
        "pascal_vmt_field",
        "pascal_vmt_field",
        "pascal_declared_capacity",
        "pascal_declared_capacity",
        "pascal_declared_capacity",
        NULL,
        NULL,
        NULL,
        "pascal_fake_array_elements"
      };
      unsigned int code = TYPE_LANG_CODE (node);
      indent_to (file, indent + 3);
      if (code >= ARRAY_SIZE (type_lang_codes))
        fprintf (file, " !!unknown Pascal TYPE_LANG_CODE %i!!", code);
      else
        {
          if (type_lang_codes[code])
            fprintf (file, " %s", type_lang_codes[code]);
          print_node (file, type_lang_infos[code] ? type_lang_infos[code]
                                                  : "!!unknown_pascal_info!!",
                            TYPE_LANG_INFO (node), indent + 4);
        }
      print_node (file, "pascal_vmt_var", TYPE_LANG_INFO2 (node), indent + 4);
      print_node (file, "pascal_base", TYPE_LANG_BASE (node), indent + 4);
      print_node (file, "pascal_initializer", TYPE_LANG_INITIAL (node), indent + 4);
      if (TYPE_LANG_SORTED_FIELDS (node))
        fprintf (file, " %i sorted_fields", TYPE_LANG_FIELD_COUNT (node));
    }
}

void
print_lang_identifier (FILE *file, tree node, int indent)
{
  struct predef *p = IDENTIFIER_BUILT_IN_VALUE (node);
  if (IDENTIFIER_SPELLING (node))
    {
      indent_to (file, indent + 3);
      if (IDENTIFIER_SPELLING_FILE (node))
        fprintf (file, " spelling %s (%s:%i:%i)",
                       IDENTIFIER_SPELLING (node),
                       IDENTIFIER_SPELLING_FILE (node),
                       IDENTIFIER_SPELLING_LINENO (node),
                       IDENTIFIER_SPELLING_COLUMN (node));
      else
        fprintf (file, " spelling %s", IDENTIFIER_SPELLING (node));
    }
  print_node (file, "value", IDENTIFIER_VALUE (node), indent + 4);
  print_node (file, "error_locus", IDENTIFIER_ERROR_LOCUS (node), indent + 4);
  if (p)
    {
      indent_to (file, indent + 3);
      fprintf (file, " predefined %s #%i",
                     (  p->kind == bk_none ? "no_special_meaning"
                      : p->kind == bk_keyword ? "keyword"
                      : p->kind == bk_const ? "const"
                      : p->kind == bk_type ? "type"
                      : p->kind == bk_var ? "var"
                      : p->kind == bk_routine ? "routine"
                      : p->kind == bk_special_syntax ? "special_syntax"
                      : "!!unknown_kind!!"),
                     p->symbol);
    }
}

void
lang_print_xnode (FILE *file, tree node, int indent)
{
  if (TREE_CODE (node) == IMPORT_NODE)
    {
      print_node (file, "interface", IMPORT_INTERFACE (node), indent + 4);
      print_node (file, "qualifier", IMPORT_QUALIFIER (node), indent + 4);
      print_node (file, "filename", IMPORT_FILENAME (node), indent + 4);
    }
}

void
get_current_routine_name (const char **desc, const char **name)
{
  *name = pascal_decl_name (current_function_decl, 2);
  if (DECL_ARTIFICIAL (current_function_decl))
    {
      if (!strncmp (*name, "init_", strlen ("init_")))
        {
          *desc = "constructor of module/unit";
          *name += strlen ("init_");
        }
      else if (!strncmp (*name, "fini_", strlen ("fini_")))
        {
          *desc = "destructor of module/unit";
          *name += strlen ("fini_");
        }
      else
        {
          *desc = "main program";
          *name = NULL;
        }
    }
  else if (PASCAL_METHOD (current_function_decl))
    {
      if (!PASCAL_STRUCTOR_METHOD (current_function_decl))
        *desc = "method";
      else if (TREE_CODE (TREE_TYPE (TREE_TYPE (current_function_decl))) == VOID_TYPE)
        *desc = "destructor";
      else
        *desc = "constructor";
    }
  else if (DECL_LANG_OPERATOR_DECL (current_function_decl))
    *desc = "operator";
  else if (TREE_CODE (TREE_TYPE (TREE_TYPE (current_function_decl))) == VOID_TYPE)
    *desc = "procedure";
  else
    *desc = "function";
}

/* Our function to print out name of current routine that caused an error. */
#define error_function_changed() (last_error_function != current_function_decl)
#define record_last_error_function() (last_error_function = current_function_decl)
#define output_add_string(X, S) fprintf (stderr, S)
#define output_printf(X, S, A, B) fprintf (stderr, S, A, B);
#define output_add_newline(X) fprintf (stderr, "\n")
#ifndef _
#define _(S) S
#endif
static tree last_error_function = NULL;
#ifdef EGCS97
static void pascal_print_error_function (diagnostic_context *, const char *);
static void
pascal_print_error_function (diagnostic_context *context ATTRIBUTE_UNUSED, const char *file)
#else
static void pascal_print_error_function (const char *);
static void
pascal_print_error_function (const char *file)
#endif
{
  if (error_function_changed ())
    {
      if (file)
        fprintf (stderr, "%s: ", file);
      if (!current_function_decl || EM (current_function_decl))
        output_add_string ((output_buffer *) context, _("At top level:"));
      else
        {
          const char *desc, *name;
          get_current_routine_name (&desc, &name);
          output_printf ((output_buffer *) context, name ? "In %s `%s':" : "In %s:", desc, name);
        }
      output_add_newline ((output_buffer *) context);
      record_last_error_function ();
    }
}

#ifndef EGCS97
void
lang_init_options (void)
{
  pascal_init_options ();
}
#endif

#ifndef GCC_3_3
/* Tree code classes. */

#ifdef EGCS
#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) TYPE,
static const char pascal_tree_code_type[] = {
  'x',
#include "p-tree.def"
};
#undef DEFTREECODE
#else
#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) TYPE,
static const char *pascal_tree_code_type[] = {
  "x",
#include "p-tree.def"
};
#undef DEFTREECODE
#endif

/* Table indexed by tree code giving number of expression
   operands beyond the fixed part of the node structure.
   Not used for types or decls. */
#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) LENGTH,
static const int pascal_tree_code_length[] = {
  0,
#include "p-tree.def"
};
#undef DEFTREECODE

/* Names of tree components.
   Used for printing out the tree and error messages. */
#define DEFTREECODE(SYM, NAME, TYPE, LEN) NAME,
static const char *const pascal_tree_code_name[] = {
  "@@dummy",
#include "p-tree.def"
};
#undef DEFTREECODE

void
add_pascal_tree_codes (void)
{
#ifndef EGCS
  tree_code_type = (char **) xrealloc (tree_code_type, LAST_AND_UNUSED_TREE_CODE * sizeof (char *) + sizeof (pascal_tree_code_type));
  tree_code_length = (int *) xrealloc (tree_code_length, LAST_AND_UNUSED_TREE_CODE * sizeof (int) + sizeof (pascal_tree_code_length));
  tree_code_name = (char **) xrealloc (tree_code_name, LAST_AND_UNUSED_TREE_CODE * sizeof (char *) + sizeof (pascal_tree_code_name));
#endif
  memcpy (tree_code_type + (int) LAST_AND_UNUSED_TREE_CODE,
          pascal_tree_code_type, sizeof (pascal_tree_code_type));
  memcpy (tree_code_length + (int) LAST_AND_UNUSED_TREE_CODE,
          pascal_tree_code_length, sizeof (pascal_tree_code_length));
  memcpy (tree_code_name + (int) LAST_AND_UNUSED_TREE_CODE,
          pascal_tree_code_name, sizeof (pascal_tree_code_name));
}
#else

/* Tree code classes. */
#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) TYPE,
#ifdef GCC_4_0
const enum tree_code_class tree_code_type[] = {
#include "tree.def"
 tcc_exceptional,
#include "p-tree.def"
};
#else
const char tree_code_type[] = {
#include "tree.def"
  'x',
#include "p-tree.def"
};
#endif
#undef DEFTREECODE

/* Table indexed by tree code giving number of expression
   operands beyond the fixed part of the node structure.
   Not used for types or decls. */
#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) LENGTH,

const unsigned char tree_code_length[] = {
#include "tree.def"
  0,
#include "p-tree.def"
};
#undef DEFTREECODE

/* Names of tree components.
   Used for printing out the tree and error messages. */
#define DEFTREECODE(SYM, NAME, TYPE, LEN) NAME,

const char *const tree_code_name[] = {
#include "tree.def"
  "@@dummy",
#include "p-tree.def"
};
#undef DEFTREECODE

#endif

extern int debug_no_type_hash;

static void builtin_define (const char *); ATTRIBUTE_UNUSED
static void builtin_define_with_value (const char *, const char *, int); ATTRIBUTE_UNUSED
static void builtin_define_with_int_value (const char *, HOST_WIDE_INT); ATTRIBUTE_UNUSED
static void builtin_define_std (const char *); ATTRIBUTE_UNUSED

static void
do_def (const char *s)
{
  int c;
  make_definition (s, 1);
#ifdef GCC_3_3
  if ((!strncmp (s, "MSDOS", c = 5) ||
       !strncmp (s, "_WIN32", c = 6) ||
       !strncmp (s, "__EMX__", c = 7))
       && (s[c] == 0 || s[c] == '='))
    make_definition ("__OS_DOS__=1", 1);
#endif
}

static void
builtin_define (const char *s)
{
  do_def (s);
}

static void
builtin_define_with_value (const char *s1, const char *s2, int is_str)
{
  char * buff = alloca (strlen (s1) + strlen (s2) + 6);
  sprintf(buff, is_str ? "%s=\"%s\"" : "%s=%s", s1, s2);
  do_def (buff);
}

static void
builtin_define_with_int_value (const char *s1, HOST_WIDE_INT s2)
{
  size_t n = strlen (s1) + 25;
  char * buff = alloca (n);
  snprintf(buff, n, "%s=" HOST_WIDE_INT_PRINT_DEC, s1, s2);
  do_def (buff);
}

static void
builtin_define_std (const char *s)
{
  char * buff = alloca (strlen (s)+7);
  do_def (s);
  sprintf(buff, "__%s", s);
  do_def (buff);
  sprintf(buff, "__%s__", s);
  do_def (buff);
}

#ifdef GCC_3_3
#define builtin_assert(s)

extern int c_lex (tree *);
int
c_lex (tree *t ATTRIBUTE_UNUSED)
{
  return 0;
}

extern void gpc_cpp_define (void *, const char *);
void
gpc_cpp_define (void *r ATTRIBUTE_UNUSED, const char *s)
{
  builtin_define_std (s);
}

#define cpp_define(r, s) gpc_cpp_define(r, s)

extern void gpc_cpp_assert (void *, const char *);
void
gpc_cpp_assert (void *pfile ATTRIBUTE_UNUSED, const char *str ATTRIBUTE_UNUSED)
{
}

#define cpp_assert(pfile, str) gpc_cpp_assert(pfile, str)

#define preprocessing_asm_p() 0
#define preprocessing_trad_p() 0
/* @@ Backend bug: TARGET_OS_CPP_BUILTINS on some targets uses them
      though they are C specific flags. */
#define c_language (-1)
#define c_dialect_cxx() 0
#define c_dialect_objc() 0
#define clk_c 0
#define clk_objc 0
#define clk_cxx 0
#define clk_objcxx 0
#define clk_cplusplus 0
#define flag_iso 1
#define flag_objc 0
#define flag_isoc99 0
#define rs6000_cpu_cpp_builtins(foo)
#define darwin_cpp_builtins(foo)
#endif

#ifdef GCC_3_4
#include "options.h"
#include "opts.h"

static int saved_lineno;
static const char *saved_filename = NULL;

static bool pascal_post_options (const char **);
static bool
pascal_post_options (const char **pfilename)
{
  const char *filename = num_in_fnames > 0 ? in_fnames[0] : NULL  /* "-" */;
  if (co->preprocess_only)
    {
      const char *out_fname = asm_file_name;
      flag_syntax_only = 1;
      *pfilename = filename;

      if (num_in_fnames > 1)
        error ("too many filenames given.  Type %s --help for usage",
               progname);

      /* Open the output now.  We must do so even if flag_no_output is
         on, because there may be other output than from the actual
         preprocessing (e.g. from -dM).  */

      open_gpcpp_output (out_fname);

      return true;
    }

  if (co->preprocessed)
  {  
    filename = init_parse (filename);
    /* The beginning of the file is a new line; check for `#'.
       With luck, we discover the real source file's name from that
       and put it in input_filename. */
    main_input_filename = NULL;
    lineno = 1;
    /* With luck, we discover the real source file name from a line directive
       at the beginning of the file and put it in input_filename. */
    set_old_input_filename (filename ? filename : "???");
    peek_token (0);
    saved_lineno = lineno;

    lineno = 0;
    *pfilename = main_input_filename ? main_input_filename : filename;
  }
  else
    *pfilename = filename;
  saved_filename = filename;
  return false;
}

static int pascal_handle_option (size_t, const char *, int);
static int
pascal_handle_option (size_t scode, const char *arg, int value)
{
#ifdef GCC_4_0
  if ((enum opt_code) scode == OPT_Werror)
    {
      global_dc->warning_as_error_requested = value;
      return 1;
    }
#endif

  switch ((enum opt_code) scode)
  {
#include "handle-opts.c"

    default:
      break;
  }
  return 1;
}

static size_t pascal_tree_size (enum tree_code);
static size_t
pascal_tree_size (enum tree_code code)
{
  switch (code)
  {
    case INTERFACE_NAME_NODE: return sizeof (struct tree_inn);
    case IMPORT_NODE:         return sizeof (struct tree_import);
    default:                  gcc_unreachable ();
  }
}

static bool lang_init_3_4 (void);
static bool
lang_init_3_4 (void)
{
  if (saved_filename)
    lang_init (saved_filename);
  else
    lang_init (main_input_filename);
  return !co->preprocess_only;
}
#endif



void
open_input (const char *filename)
{
#if USE_CPPLIB
  gcc_unreachable ();
#endif
  /* Open input file. */
  if (!filename || !strcmp (filename, "-"))
    {
      finput = stdin;
      filename = "stdin";
    }
  else
    finput = fopen (filename, "r");
  if (!finput)
    {
      fprintf (stderr, "%s: ", progname);
      perror (filename);
      exit (FATAL_EXIT_CODE);
    }
#ifdef IO_BUFFER_SIZE
  setvbuf (finput, (char *) xmalloc (IO_BUFFER_SIZE), _IOFBF, IO_BUFFER_SIZE);
#endif
}

static void
call_gpcpp (const char * filename, FILE * fi)
{
  init_gpcpp();
  gpcpp_main (filename, fi);
  fclose (fi);
  if (!co->print_deps)
    gpcpp_writeout (gpcpp_out_fname, gpcpp_out_stream);
  else
    fclose (gpcpp_out_stream);

  exit (EXIT_SUCCESS);
}

#ifdef EGCS97
const char *
lang_init (const char *filename)
#else
void
lang_init (void)
#endif
{
  /* What type_hash_canon() does is wrong for Pascal (distinct, but structurally
     identical types are not compatible, fjf834.pas). Also, it's not compatible
     with the end_temporary_allocation() call in build_pascal_array_type
     (gcc-2 only), and it seems to cause a hard to reproduce memory management
     problem (gcc-3 only, reported by David Wood <DJWOOD1@qinetiq.com>).
     So we just turn it off here. */
#ifndef GCC_4_0
  debug_no_type_hash = 1;
#endif

#ifndef EGCS
  init_gpc_lex (input_filename);
#endif

#ifdef EGCS97
  if (co->preprocess_only)
    {
      open_input (filename);
#ifndef GCC_3_4
      open_gpcpp_output (asm_file_name);
#endif
      call_gpcpp (filename, finput);
      return 0;
    }

  init_decl_processing ();
#ifdef GCC_3_4
  if (!co->preprocessed)
#endif
    {
      filename = init_parse (filename);
    }

#ifndef GCC_3_3
  decl_printable_name = pascal_decl_name;
#endif
#else
  decl_printable_name = (char *(*) (tree, int)) pascal_decl_name;
  /* dwarf2 with gcc-2 gave some bugs which didn't seem easy to fix
     (this whole stuff is quite hairy and not well documented).
     It doesn't seem worth fixing it since gcc-2 is to be deprecated,
     anyway, and gcc-3 can be used on platforms that require dwarf
     (e.g. IRIX/MIPS). -- Frank */
  if (write_symbols == DWARF_DEBUG || write_symbols == DWARF2_DEBUG)
    {
      error ("dwarf debug info does not work with GPC based on gcc-2.x (try gcc-3.x)");
      exit (FATAL_EXIT_CODE);
    }
#endif
#ifndef GCC_3_3
  lang_expand_expr = pascal_expand_expr;
  print_error_function = pascal_print_error_function;
#endif

  if (co->option_big_endian == 0 && BYTES_BIG_ENDIAN)
    {
      input_filename = NULL;
      lineno = column = 0;
      error ("`--little-endian' given, but target system is big endian");
      exit (FATAL_EXIT_CODE);
    }
  if (co->option_big_endian > 0 && !BYTES_BIG_ENDIAN)
    {
      input_filename = NULL;
      lineno = column = 0;
      error ("`--big-endian' given, but target system is little endian");
      exit (FATAL_EXIT_CODE);
    }

      /* Should be not needed with integrated preprocessor */
      /* The following is no joke! The difference between what the
         preprocessor and the compiler think of BYTES_BIG_ENDIAN is
         exactly the problem we're dealing with here. */
  if (co->print_needed_options)
    {
      fputs ("\n", stderr);
      while (fgetc (finput) != EOF) ;
      exit (1);
    }

  /* In gcc-2.8.1, init_tree_codes() has not been called yet.
     Do it in init_parse instead. */
#ifndef GCC_3_3
  add_pascal_tree_codes ();
#endif

  /* With luck, we discover the real source file name from a line directive
     at the beginning of the file and put it in input_filename. */
#ifdef GCC_3_4
  if (!co->preprocessed)
#endif    
    peek_token (0);

#ifdef EGCS97
  if (main_input_filename)
    filename = main_input_filename;
  return filename;
#endif
}

#ifndef TARGET_OS_CPP_BUILTINS
# define TARGET_OS_CPP_BUILTINS()
#endif

#ifndef TARGET_OBJFMT_CPP_BUILTINS
# define TARGET_OBJFMT_CPP_BUILTINS()
#endif


void
init_gpcpp (void)
{
  initialize_char_syntax ();
  if (BITS_BIG_ENDIAN)
    builtin_define ("__BITS_BIG_ENDIAN__=1");
  else
    builtin_define ("__BITS_LITTLE_ENDIAN__=1");
  if (BYTES_BIG_ENDIAN)
    builtin_define ("__BYTES_BIG_ENDIAN__=1");
  else
    builtin_define ("__BYTES_LITTLE_ENDIAN__=1");
  if (WORDS_BIG_ENDIAN)
    builtin_define ("__WORDS_BIG_ENDIAN__=1");
  else
    builtin_define ("__WORDS_LITTLE_ENDIAN__=1");
  if (STRICT_ALIGNMENT)
    builtin_define ("__NEED_ALIGNMENT__=1");
  else
    builtin_define ("__NEED_NO_ALIGNMENT__=1");
#ifdef GCC_3_3
  {
#if 1
  /* Definitions for LP64 model.  */
    if (LONG_TYPE_SIZE == 64
        && POINTER_SIZE == 64
        && INT_TYPE_SIZE == 32)
      {
        builtin_define ("_LP64");
        builtin_define ("__LP64__");
      }
#endif
      if (optimize_size)
        builtin_define ("__OPTIMIZE_SIZE__");
      if (optimize)
        builtin_define ("__OPTIMIZE__");
      TARGET_CPU_CPP_BUILTINS ();
      TARGET_OS_CPP_BUILTINS ();
      TARGET_OBJFMT_CPP_BUILTINS ();
  }
#endif
  gpcpp_process_options (save_argc, save_argv);
}

/* If DECL has a cleanup, build and return that cleanup here.
   This is a callback called by expand_expr. */
tree
maybe_build_cleanup (tree decl ATTRIBUTE_UNUSED)
{
  /* There are no cleanups in Pascal (yet). */
  return NULL_TREE;
}

#ifndef EGCS97
extern void lang_finish (void);
extern char *lang_identify (void);
extern void print_lang_statistics (void);
extern void GNU_xref_begin (void);
extern void GNU_xref_end (void);

void
lang_finish (void)
{
}

char *
lang_identify (void)
{
  return "Pascal";
}

void
print_lang_statistics (void)
{
}

void
GNU_xref_begin (void)
{
  error ("GPC does not yet support XREF");
  exit (FATAL_EXIT_CODE);
}

void
GNU_xref_end (void)
{
  error ("GPC does not yet support XREF");
  exit (FATAL_EXIT_CODE);
}
#else
#ifndef GCC_3_3
void
insert_default_attributes (tree decl ATTRIBUTE_UNUSED)
{
}
#endif
#endif

#ifdef EGCS
int
lang_decode_option (int argc, char **argv)
{
  return pascal_decode_option (argc, (const char **) argv);
}
#else
int
lang_decode_option (char *p)
{
  return pascal_decode_option (1, (const char **) &p);
}
#endif

static void 
open_gpcpp_output (const char *out_fname)
{

      if (co->preprocessed)
        {
          error ("can not preprocess already preprocessed input");
          exit (FATAL_EXIT_CODE);
        }

      if (!out_fname || out_fname[0] == '\0')
        {
          gpcpp_out_stream = stdout;
          gpcpp_out_fname = "stdout";
        }
      else
        {
          gpcpp_out_stream = fopen (out_fname, "w");
          gpcpp_out_fname = out_fname;
        }

      if (gpcpp_out_stream == NULL)
        {
          error ("opening output file %s: %m", out_fname);
          exit (EXIT_FAILURE);
        }
      if (co->print_deps)
        deps_out_file = gpcpp_out_stream;
}

#ifdef EGCS
#ifdef EGCS97
const char *
init_parse (const char *filename)
#else
char *
init_parse (char *filename)
#endif
{
  open_input (filename);
#ifndef EGCS97
  if (co->preprocess_only)
    {
      open_gpcpp_output (asm_file_name);
      call_gpcpp (filename, finput);
    }
#endif
  init_gpc_lex (filename);
  return filename;
}

void
finish_parse (void)
{
#if USE_CPPLIB
  gcc_unreachable ();
#else
  fclose (finput);
#endif
}
#endif

#ifndef EGCS
void init_lex (void);
void init_lex (void)
{
  add_pascal_tree_codes ();
  set_identifier_size (sizeof (struct lang_identifier));
  /* Loop unrolling is buggy. It breaks array initialization (fjf533.pas),
     possibly also the `for' loop bugs (see FOR_BUG_OK), but I currently can't
     test it on an affected system (e.g., AIX). Since gcc-2.8.1 is fading out,
     I don't want to try to fix it anymore, just disable it here. -- Frank */
  flag_unroll_loops = 0;
 
  if (co->preprocess_only)
    {
      open_gpcpp_output (asm_file_name);
      call_gpcpp (input_filename, finput);
    }
}
#endif

#ifdef EGCS97

/* @@@@@ The following attribute handling code is copied from
   gcc-3.3's c-common.c. There's another attribute handling code for
   gcc-2 below, copied from gcc-2's c-common.c. gcc-3.2 doesn't need
   either, it's done in attribs.c which is provided by the backend.
   This should be checked and resolved. It's not nice to have two
   copies of more or less equivalent code in GPC. Most of these
   attributes are low-level, so it would be nice if we could leave
   their handling to the backend. */
#ifdef GCC_3_3
static tree handle_nocommon_attribute   (tree *, tree, tree, int, bool *);
static tree handle_common_attribute     (tree *, tree, tree, int, bool *);
static tree handle_noreturn_attribute   (tree *, tree, tree, int, bool *);
static tree handle_unused_attribute     (tree *, tree, tree, int, bool *);
static tree handle_const_attribute      (tree *, tree, tree, int, bool *);
static tree handle_section_attribute    (tree *, tree, tree, int, bool *);
static tree handle_aligned_attribute    (tree *, tree, tree, int, bool *);
static tree handle_weak_attribute       (tree *, tree, tree, int, bool *);
static tree handle_alias_attribute      (tree *, tree, tree, int, bool *);

const struct attribute_spec gpc_attribute_table[] =
{
  { "nocommon",               0, 0, true,  false, false,
                              handle_nocommon_attribute },
  { "common",                 0, 0, true,  false, false,
                              handle_common_attribute },
  /* FIXME: logically, noreturn attributes should be listed as
     "false, true, true" and apply to function types.  But implementing this
     would require all the places in the compiler that use TREE_THIS_VOLATILE
     on a decl to identify non-returning functions to be located and fixed
     to check the function type instead.  */
  { "noreturn",               0, 0, true,  false, false,
                              handle_noreturn_attribute },
  { "unused",                 0, 0, false, false, false,
                              handle_unused_attribute },
  /* The same comments as for noreturn attributes apply to const ones.  */
  { "const",                  0, 0, true,  false, false,
                              handle_const_attribute },
  { "section",                1, 1, true,  false, false,
                              handle_section_attribute },
  { "aligned",                0, 1, false, false, false,
                              handle_aligned_attribute },
  { "weak",                   0, 0, true,  false, false,
                              handle_weak_attribute },
  { "alias",                  1, 1, true,  false, false,
                              handle_alias_attribute },
  { NULL,                     0, 0, false, false, false, NULL }
};

/* Handle a "nocommon" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_nocommon_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  if (TREE_CODE (*node) == VAR_DECL)
    DECL_COMMON (*node) = 0;
  else
    {
      gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Handle a "common" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_common_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  if (TREE_CODE (*node) == VAR_DECL)
    DECL_COMMON (*node) = 1;
  else
    {
      gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Handle a "noreturn" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_noreturn_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  tree type = TREE_TYPE (*node);

  /* See FIXME comment in c_common_attribute_table.  */
  if (TREE_CODE (*node) == FUNCTION_DECL)
    TREE_THIS_VOLATILE (*node) = 1;
  else if (TREE_CODE (type) == POINTER_TYPE
           && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE)
    TREE_TYPE (*node)
      = build_pointer_type
        (build_type_variant (TREE_TYPE (type),
                             TREE_READONLY (TREE_TYPE (type)), 1));
  else
    {
      gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Handle a "unused" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_unused_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags, bool *no_add_attrs)
{
  if (DECL_P (*node))
    {
      tree decl = *node;

      if (TREE_CODE (decl) == PARM_DECL
          || TREE_CODE (decl) == VAR_DECL
          || TREE_CODE (decl) == FUNCTION_DECL
          || TREE_CODE (decl) == LABEL_DECL
          || TREE_CODE (decl) == TYPE_DECL)
        TREE_USED (decl) = 1;
      else
        {
          gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
          *no_add_attrs = true;
        }
    }
  else
    {
      if (!(flags & (int) ATTR_FLAG_TYPE_IN_PLACE))
        *node = build_type_copy (*node);
      TREE_USED (*node) = 1;
    }

  return NULL_TREE;
}

/* Handle a "const" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_const_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  tree type = TREE_TYPE (*node);

  /* See FIXME comment on noreturn in c_common_attribute_table.  */
  if (TREE_CODE (*node) == FUNCTION_DECL)
    TREE_READONLY (*node) = 1;
  else if (TREE_CODE (type) == POINTER_TYPE
           && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE)
    TREE_TYPE (*node)
      = build_pointer_type
        (build_type_variant (TREE_TYPE (type), 1,
                             TREE_THIS_VOLATILE (TREE_TYPE (type))));
  else
    {
      gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Handle a "section" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_section_attribute (tree *node, tree name ATTRIBUTE_UNUSED, tree args, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  tree decl = *node;

  if (targetm.have_named_sections)
    {
      if ((TREE_CODE (decl) == FUNCTION_DECL
           || TREE_CODE (decl) == VAR_DECL)
          && TREE_CODE (TREE_VALUE (args)) == STRING_CST)
        {
          if (TREE_CODE (decl) == VAR_DECL
              && current_function_decl != NULL_TREE
              && ! TREE_STATIC (decl))
            {
              error_with_decl (decl,
                               "section attribute cannot be specified for local variables");
              *no_add_attrs = true;
            }

          /* The decl may have already been given a section attribute
             from a previous declaration.  Ensure they match.  */
          else if (DECL_SECTION_NAME (decl) != NULL_TREE
                   && strcmp (TREE_STRING_POINTER (DECL_SECTION_NAME (decl)),
                              TREE_STRING_POINTER (TREE_VALUE (args))) != 0)
            {
              error_with_decl (*node,
                               "section of `%s' conflicts with previous declaration");
              *no_add_attrs = true;
            }
          else
            DECL_SECTION_NAME (decl) = TREE_VALUE (args);
        }
      else
        {
          error_with_decl (*node,
                           "section attribute not allowed for `%s'");
          *no_add_attrs = true;
        }
    }
  else
    {
      error_with_decl (*node,
                       "section attributes are not supported for this target");
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Handle a "aligned" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_aligned_attribute (tree *node, tree name ATTRIBUTE_UNUSED, tree args, int flags, bool *no_add_attrs)
{
  tree decl = NULL_TREE;
  tree *type = NULL;
  int is_type = 0;
  tree align_expr = (args ? TREE_VALUE (args)
                     : size_int (BIGGEST_ALIGNMENT / BITS_PER_UNIT));
  int i;

  if (DECL_P (*node))
    {
      decl = *node;
      type = &TREE_TYPE (decl);
      is_type = TREE_CODE (*node) == TYPE_DECL;
    }
  else if (TYPE_P (*node))
    type = node, is_type = 1;

  /* Strip any NOPs of any kind.  */
  while (TREE_CODE (align_expr) == NOP_EXPR
         || TREE_CODE (align_expr) == CONVERT_EXPR
         || TREE_CODE (align_expr) == NON_LVALUE_EXPR)
    align_expr = TREE_OPERAND (align_expr, 0);

  if (TREE_CODE (align_expr) != INTEGER_CST)
    {
      error ("requested alignment is not a constant");
      *no_add_attrs = true;
    }
  else if ((i = tree_log2 (align_expr)) == -1)
    {
      error ("requested alignment is not a power of 2");
      *no_add_attrs = true;
    }
  else if (i > HOST_BITS_PER_INT - 2)
    {
      error ("requested alignment is too large");
      *no_add_attrs = true;
    }
  else if (is_type)
    {
      /* If we have a TYPE_DECL, then copy the type, so that we
         don't accidentally modify a builtin type.  See pushdecl.  */
      if (decl && TREE_TYPE (decl) != error_mark_node
          && DECL_ORIGINAL_TYPE (decl) == NULL_TREE)
        {
          tree tt = TREE_TYPE (decl);
          *type = build_type_copy (*type);
          DECL_ORIGINAL_TYPE (decl) = tt;
          TYPE_NAME (*type) = decl;
          TREE_USED (*type) = TREE_USED (decl);
          TREE_TYPE (decl) = *type;
        }
      else if (!(flags & (int) ATTR_FLAG_TYPE_IN_PLACE))
        *type = build_type_copy (*type);

      TYPE_ALIGN (*type) = (1 << i) * BITS_PER_UNIT;
      TYPE_USER_ALIGN (*type) = 1;
    }
  else if (TREE_CODE (decl) != VAR_DECL
           && TREE_CODE (decl) != FIELD_DECL)
    {
      error_with_decl (decl, "alignment may not be specified for `%s'");
      *no_add_attrs = true;
    }
  else
    {
      DECL_ALIGN (decl) = (1 << i) * BITS_PER_UNIT;
      DECL_USER_ALIGN (decl) = 1;
    }

  return NULL_TREE;
}

/* Handle a "weak" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_weak_attribute (tree *node, tree name ATTRIBUTE_UNUSED, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs ATTRIBUTE_UNUSED)
{
  declare_weak (*node);

  return NULL_TREE;
}

/* Handle an "alias" attribute; arguments as in
   struct attribute_spec.handler.  */

static tree
handle_alias_attribute (tree *node, tree name, tree args, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  tree decl = *node;

  if ((TREE_CODE (decl) == FUNCTION_DECL && DECL_INITIAL (decl))
      || (TREE_CODE (decl) != FUNCTION_DECL && ! DECL_EXTERNAL (decl)))
    {
      error_with_decl (decl,
                       "`%s' defined both normally and as an alias");
      *no_add_attrs = true;
    }
  else if (decl_function_context (decl) == 0)
    {
      tree id;

      id = TREE_VALUE (args);
      if (TREE_CODE (id) != STRING_CST)
        {
          error ("alias arg not a string");
          *no_add_attrs = true;
          return NULL_TREE;
        }
      id = get_identifier (TREE_STRING_POINTER (id));
      /* This counts as a use of the object pointed to.  */
      TREE_USED (id) = 1;

      if (TREE_CODE (decl) == FUNCTION_DECL)
        DECL_INITIAL (decl) = error_mark_node;
      else
        DECL_EXTERNAL (decl) = 0;
    }
  else
    {
      gpc_warning ("`%s' attribute ignored", IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}
#endif

static void pascal_clear_binding_stack (void);
static void
pascal_clear_binding_stack (void)
{
  if (errorcount || sorrycount)
    exit_compilation ();
  while (! global_bindings_p ())
    poplevel (0, 0, 0);
}


#undef LANG_HOOKS_NAME
#define LANG_HOOKS_NAME "GNU Pascal"
#undef LANG_HOOKS_INIT
#ifndef GCC_3_4
#define LANG_HOOKS_INIT lang_init
#else
#define LANG_HOOKS_INIT lang_init_3_4
#undef LANG_HOOKS_TREE_SIZE
#define LANG_HOOKS_TREE_SIZE pascal_tree_size
#undef LANG_HOOKS_HANDLE_OPTION
#define LANG_HOOKS_HANDLE_OPTION pascal_handle_option
#undef LANG_HOOKS_POST_OPTIONS
#define LANG_HOOKS_POST_OPTIONS pascal_post_options
#endif

#ifndef GCC_4_0
#undef LANG_HOOKS_CLEAR_BINDING_STACK
#define LANG_HOOKS_CLEAR_BINDING_STACK pascal_clear_binding_stack
#endif

#undef LANG_HOOKS_DECODE_OPTION
#define LANG_HOOKS_DECODE_OPTION lang_decode_option
#undef LANG_HOOKS_INIT_OPTIONS
#define LANG_HOOKS_INIT_OPTIONS pascal_init_options
#undef LANG_HOOKS_PRINT_DECL
#define LANG_HOOKS_PRINT_DECL print_lang_decl
#undef LANG_HOOKS_PRINT_TYPE
#define LANG_HOOKS_PRINT_TYPE print_lang_type
#undef LANG_HOOKS_PRINT_IDENTIFIER
#define LANG_HOOKS_PRINT_IDENTIFIER print_lang_identifier
#undef LANG_HOOKS_SET_YYDEBUG
#define LANG_HOOKS_SET_YYDEBUG set_yydebug
#undef LANG_HOOKS_GET_ALIAS_SET
#define LANG_HOOKS_GET_ALIAS_SET hook_get_alias_set_0
#undef LANG_HOOKS_PRINT_XNODE
#define LANG_HOOKS_PRINT_XNODE lang_print_xnode

#undef LANG_HOOKS_EXPAND_EXPR
#define LANG_HOOKS_EXPAND_EXPR pascal_expand_expr

#ifdef GCC_3_3
#undef LANG_HOOKS_DECL_PRINTABLE_NAME
#define LANG_HOOKS_DECL_PRINTABLE_NAME pascal_decl_name
#undef LANG_HOOKS_PRINT_ERROR_FUNCTION
#define LANG_HOOKS_PRINT_ERROR_FUNCTION pascal_print_error_function

#define LANG_HOOKS_UNSIGNED_TYPE unsigned_type
#define LANG_HOOKS_SIGNED_TYPE signed_type
#define LANG_HOOKS_SIGNED_OR_UNSIGNED_TYPE signed_or_unsigned_type
#define LANG_HOOKS_TYPE_FOR_SIZE type_for_size
#define LANG_HOOKS_TYPE_FOR_MODE type_for_mode

#define LANG_HOOKS_MARK_ADDRESSABLE pascal_mark_addressable

#ifndef GCC_4_1
#define LANG_HOOKS_TRUTHVALUE_CONVERSION truthvalue_conversion
#endif

#undef LANG_HOOKS_DUP_LANG_SPECIFIC_DECL
#define LANG_HOOKS_DUP_LANG_SPECIFIC_DECL copy_decl_lang_specific

#undef LANG_HOOKS_PARSE_FILE
#define LANG_HOOKS_PARSE_FILE pascal_parse

#undef LANG_HOOKS_COMMON_ATTRIBUTE_TABLE
#define LANG_HOOKS_COMMON_ATTRIBUTE_TABLE gpc_attribute_table

#undef LANG_HOOKS_HASH_TYPES
#define LANG_HOOKS_HASH_TYPES false


#ifdef GCC_4_0
#undef LANG_HOOKS_CALLGRAPH_EXPAND_FUNCTION
#define LANG_HOOKS_CALLGRAPH_EXPAND_FUNCTION pascal_expand_function

#undef LANG_HOOKS_GIMPLIFY_EXPR
#define LANG_HOOKS_GIMPLIFY_EXPR pascal_gimplify_expr

#undef LANG_HOOKS_TYPES_COMPATIBLE_P
#define LANG_HOOKS_TYPES_COMPATIBLE_P pascal_types_compatible_p

#ifdef GCC_4_1
#undef LANG_HOOKS_INIT_TS
#define LANG_HOOKS_INIT_TS pascal_init_ts
#undef LANG_HOOKS_EXPAND_CONSTANT
#define LANG_HOOKS_EXPAND_CONSTANT pascal_expand_constant



/* Expand (the constant part of) a SET_TYPE CONSTRUCTOR node.
   The result is placed in BUFFER (which has length BIT_SIZE),
   with one bit in each char ('\000' or '\001').

   If the constructor is constant, NULL_TREE is returned.
   Otherwise, a TREE_LIST of the non-constant elements is emitted.  */

static tree
get_set_constructor_bits (tree init, char *buffer, int bit_size)
{
  int i;
  tree vals;
  HOST_WIDE_INT domain_min
    = tree_low_cst (TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (init))), 0);
  HOST_WIDE_INT low_limit = domain_min;
  tree non_const_bits = NULL_TREE;

  if (set_alignment)
    /* Note: `domain_min -= domain_min % set_alignment' would be wrong for negative
       numbers (rounding towards 0, while we have to round towards -inf). */
    domain_min &= -(int) set_alignment;

  low_limit -= domain_min;

  for (i = 0; i < bit_size; i++)
    buffer[i] = 0;

  for (vals = TREE_OPERAND (init, 0) /* CONSTRUCTOR_ELTS (init) */;
       vals != NULL_TREE; vals = TREE_CHAIN (vals))
    {
      if (!host_integerp (TREE_VALUE (vals), 0)
	  || (TREE_PURPOSE (vals) != NULL_TREE
	      && !host_integerp (TREE_PURPOSE (vals), 0)))
	non_const_bits
	  = tree_cons (TREE_PURPOSE (vals), TREE_VALUE (vals), non_const_bits);
      else if (TREE_PURPOSE (vals) != NULL_TREE)
	{
	  /* Set a range of bits to ones.  */
	  HOST_WIDE_INT lo_index
	    = tree_low_cst (TREE_PURPOSE (vals), 0) - domain_min;
	  HOST_WIDE_INT hi_index
	    = tree_low_cst (TREE_VALUE (vals), 0) - domain_min;

          if (lo_index < low_limit || hi_index >= bit_size)
            {
              error ("invalid initializer for set");
              return NULL_TREE;
            }

	  gcc_assert (lo_index >= 0);
	  gcc_assert (lo_index < bit_size);
	  gcc_assert (hi_index >= 0);
	  gcc_assert (hi_index < bit_size);
	  for (; lo_index <= hi_index; lo_index++)
	    buffer[lo_index] = 1;
	}
      else
	{
	  /* Set a single bit to one.  */
	  HOST_WIDE_INT index
	    = tree_low_cst (TREE_VALUE (vals), 0) - domain_min;
	  if (index < 0 || index >= bit_size)
	    {
	      error ("invalid initializer for set");
	      return NULL_TREE;
	    }
	  buffer[index] = 1;
	}
    }
  return non_const_bits;
}

/* Expand (the constant part of) a SET_TYPE CONSTRUCTOR node.
   The result is placed in BUFFER (which is an array of bytes).
   If the constructor is constant, NULL_TREE is returned.
   Otherwise, a TREE_LIST of the non-constant elements is emitted.  */

static tree
get_set_constructor_bytes (tree init, unsigned char *buffer, int wd_size)
{
  int i;
#ifdef GPC
  int bit_size = wd_size * BITS_PER_UNIT;
  unsigned int bit_pos = 0;
#else /* not GPC */
  int set_word_size = BITS_PER_UNIT;
  int bit_size = wd_size * set_word_size;
  int bit_pos = 0;
#endif /* not GPC */
  unsigned char *bytep = buffer;
  char *bit_buffer = alloca (bit_size);
  tree non_const_bits = get_set_constructor_bits (init, bit_buffer, bit_size);

  for (i = 0; i < wd_size; i++)
    buffer[i] = 0;

  for (i = 0; i < bit_size; i++)
    {
#ifdef GPC
      if (bit_buffer[i])
      {
          int k = bit_pos / BITS_PER_UNIT;
          if (WORDS_BIG_ENDIAN)
            k = set_word_size / BITS_PER_UNIT - 1 - k;
        if (set_words_big_endian)
          bytep[k] |= (1 << (BITS_PER_UNIT - 1 - bit_pos % BITS_PER_UNIT));
        else
          bytep[k] |= (1 << (bit_pos % BITS_PER_UNIT));
      }
      bit_pos++;
      if (bit_pos >= set_word_size)
        {
          bit_pos = 0;
          bytep += set_word_size / BITS_PER_UNIT;
        }
#else /* not GPC */
      if (bit_buffer[i])
	{
	  if (BYTES_BIG_ENDIAN)
	    *bytep |= (1 << (set_word_size - 1 - bit_pos));
	  else
	    *bytep |= 1 << bit_pos;
	}
      bit_pos++;
      if (bit_pos >= set_word_size)
	bit_pos = 0, bytep++;
#endif
    }
  return non_const_bits;
}


static tree
pascal_expand_constant (tree t)
{
  tree nt;
  if (TREE_CODE (t) == PASCAL_SET_CONSTRUCTOR)
    {
      HOST_WIDE_INT len = int_size_in_bytes (TREE_TYPE (t));
      char *tmp = xmalloc (len);
      if (!get_set_constructor_bytes (t, (unsigned char *) tmp, len))
        {
          nt = build_string (len, tmp);
          gcc_assert (TREE_INT_CST_LOW (TYPE_SIZE (char_type_node)) == 8);
          TREE_TYPE (nt) = build_simple_array_type (char_type_node,
                              build_index_type (build_int_2 (len, 0)));
          t = build1 (VIEW_CONVERT_EXPR, TREE_TYPE (t), nt);
        }
    }
  return t;
}

static void
pascal_init_ts (void)
{
  tree_contains_struct[NAMESPACE_DECL][TS_DECL_COMMON] = 1;
  tree_contains_struct[OPERATOR_DECL][TS_DECL_COMMON] = 1;
  tree_contains_struct[NAMESPACE_DECL][TS_DECL_MINIMAL] = 1;
  tree_contains_struct[OPERATOR_DECL][TS_DECL_MINIMAL] = 1;
}

#endif


int 
pascal_types_compatible_p (tree t1, tree t2)
{
  if (TREE_CODE (t1) == POINTER_TYPE && TREE_CODE (t2) == POINTER_TYPE)
    {
      t1 = TREE_TYPE (t1);
      t2 = TREE_TYPE (t2);
    }
  if (PASCAL_TYPE_STRING (t1) && PASCAL_TYPE_STRING (t2))
    return 1;
  else if (PASCAL_TYPE_SCHEMA (t1) && PASCAL_TYPE_SCHEMA (t2))
    {
      tree base1 = t1, base2 = t2;
      if (TYPE_LANG_BASE (t1))
        base1 = TYPE_LANG_BASE (t1);
      if (TYPE_LANG_BASE (t2))
        base2 = TYPE_LANG_BASE (t2);
      base1 = TYPE_MAIN_VARIANT (base1);
      base2 = TYPE_MAIN_VARIANT (base2);
      if (base1 == base2)
        return 1;
    }
  return strictly_comp_types (TYPE_MAIN_VARIANT (t1), TYPE_MAIN_VARIANT (t2));
}

static void
pascal_expand_function (tree fndecl)
{
  /* We have nothing special to do while expanding functions for Pascal.  */
  tree_rest_of_compilation (fndecl);
}
#endif

#ifdef GCC_3_3
bool
#else
int
#endif
pascal_mark_addressable (tree exp)
{
  return mark_addressable2 (exp, 1);
}



static void
pascal_parse (int debug)
{
  set_yydebug (debug);
  yyparse ();
}

#else

void
lang_mark_tree (tree t)
{
  if (TREE_CODE (t) == IDENTIFIER_NODE)
    {
      struct lang_identifier *i = (struct lang_identifier *) t;
      ggc_mark_tree (i->value);
      ggc_mark_tree (i->error_locus);
    }
  else if (TREE_CODE (t) == IMPORT_NODE)
    {
      ggc_mark_tree (IMPORT_INTERFACE (t));
      ggc_mark_tree (IMPORT_QUALIFIER (t));
      ggc_mark_tree (IMPORT_FILENAME (t));
    }
  else if (TYPE_P (t) && TYPE_LANG_SPECIFIC (t))
    {
      struct lang_type *lt = TYPE_LANG_SPECIFIC (t);
      ggc_mark (lt);
      ggc_mark_tree (lt->info);
      ggc_mark_tree (lt->info2);
      ggc_mark_tree (lt->base);
      ggc_mark_tree (lt->initial);
      if (lt->sorted_fields)
        ggc_mark (lt->sorted_fields);
    }
  else if (DECL_P (t) && DECL_LANG_SPECIFIC (t))
    {
      struct lang_decl *ld = DECL_LANG_SPECIFIC (t);
      ggc_mark (ld);
      ggc_mark_tree (ld->info1);
      ggc_mark_tree (ld->info2);
      ggc_mark_tree (ld->info3);
      ggc_mark_tree (ld->info4);
    }
}
#endif

const struct lang_hooks lang_hooks = LANG_HOOKS_INITIALIZER;
#endif

#ifndef EGCS97
enum attrs { A_NOCOMMON, A_COMMON, A_NORETURN, A_CONST,
             A_SECTION, A_ALIGNED, A_UNUSED, A_WEAK, A_ALIAS };

static struct { enum attrs id; tree name; int min, max, decl_req; } attrtab[50];
static int attrtab_idx = 0;

static void add_attribute (enum attrs, const char *, int, int, int);
static void
add_attribute (enum attrs id, const char *string, int min_len, int max_len, int decl_req)
{
  char buf[100];
  attrtab[attrtab_idx].id = id;
  attrtab[attrtab_idx].name = get_identifier (string);
  attrtab[attrtab_idx].min = min_len;
  attrtab[attrtab_idx].max = max_len;
  attrtab[attrtab_idx++].decl_req = decl_req;
  sprintf (buf, "__%s__", string);
  attrtab[attrtab_idx].id = id;
  attrtab[attrtab_idx].name = get_identifier (buf);
  attrtab[attrtab_idx].min = min_len;
  attrtab[attrtab_idx].max = max_len;
  attrtab[attrtab_idx++].decl_req = decl_req;
}
#endif

/* Process the attributes listed in ATTRIBUTES and install them in NODE,
   which is either a DECL (including a TYPE_DECL) or a TYPE. */
void
pascal_decl_attributes (tree *anode, tree attributes)
{
#ifndef EGCS97
  tree node = *anode, decl = 0, type = 0;
  int is_type = 0;
#endif
  tree a;
  for (a = attributes; a; a = TREE_CHAIN (a))
    TREE_PURPOSE (a) = de_capitalize (TREE_PURPOSE (a));
#ifdef EGCS97
  decl_attributes (anode, attributes, 0);
#else

  if (!attrtab_idx)
    {
      add_attribute (A_NOCOMMON, "nocommon", 0, 0, 1);
      add_attribute (A_COMMON, "common", 0, 0, 1);
      add_attribute (A_NORETURN, "noreturn", 0, 0, 1);
      add_attribute (A_UNUSED, "unused", 0, 0, 0);
      add_attribute (A_CONST, "const", 0, 0, 1);
      add_attribute (A_SECTION, "section", 1, 1, 1);
      add_attribute (A_ALIGNED, "aligned", 0, 1, 0);
      add_attribute (A_WEAK, "weak", 0, 0, 1);
      add_attribute (A_ALIAS, "alias", 1, 1, 1);
    }

  if (DECL_P (node))
    {
      decl = node;
      type = TREE_TYPE (decl);
      is_type = TREE_CODE (node) == TYPE_DECL;
    }
  else if (TYPE_P (node))
    type = node, is_type = 1;

  for (a = attributes; a; a = TREE_CHAIN (a))
    {
      tree name = TREE_PURPOSE (a);
      tree args = TREE_VALUE (a);
      int i;
      enum attrs id;

      for (i = 0; i < attrtab_idx; i++)
        if (attrtab[i].name == name)
          break;

      if (i == attrtab_idx)
        {
          if (TYPE_P (node))
            *anode = type = build_type_copy (type);
          if (!valid_machine_attribute (name, args, decl, type))
            gpc_warning ("`%s' attribute directive ignored", IDENTIFIER_NAME (name));
          else if (decl)
            type = TREE_TYPE (decl);
          continue;
        }
      else if (attrtab[i].decl_req && !decl)
        {
          gpc_warning ("`%s' attribute does not apply to types", IDENTIFIER_NAME (name));
          continue;
        }
      else if (list_length (args) < attrtab[i].min || list_length (args) > attrtab[i].max)
        {
          error ("wrong number of arguments specified for `%s' attribute",
                 IDENTIFIER_NAME (name));
          continue;
        }

      id = attrtab[i].id;
      switch (id)
      {
        case A_NOCOMMON:
          if (TREE_CODE (decl) == VAR_DECL)
            DECL_COMMON (decl) = 0;
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;

        case A_COMMON:
          if (TREE_CODE (decl) == VAR_DECL)
            DECL_COMMON (decl) = 1;
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;

        case A_NORETURN:
          if (TREE_CODE (decl) == FUNCTION_DECL)
            TREE_THIS_VOLATILE (decl) = 1;
          else if (TREE_CODE (type) == POINTER_TYPE && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE)
            TREE_TYPE (decl) = type = build_pointer_type (p_build_type_variant (TREE_TYPE (type),
              TREE_READONLY (TREE_TYPE (type)), 1));
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;

        case A_UNUSED:
          if (TYPE_P (node))
            *anode = type = build_type_copy (type);
          if (is_type)
            TREE_USED (type) = 1;
          else if (TREE_CODE (decl) == PARM_DECL
                   || TREE_CODE (decl) == VAR_DECL
                   || TREE_CODE (decl) == FUNCTION_DECL)
            TREE_USED (decl) = 1;
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;

        case A_CONST:
          if (TREE_CODE (decl) == FUNCTION_DECL)
            TREE_READONLY (decl) = 1;
          else if (TREE_CODE (type) == POINTER_TYPE && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE)
            TREE_TYPE (decl) = type = build_pointer_type (p_build_type_variant (TREE_TYPE (type),
              1, TREE_THIS_VOLATILE (TREE_TYPE (type))));
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;

        case A_SECTION:
#ifdef ASM_OUTPUT_SECTION_NAME
          if ((TREE_CODE (decl) == FUNCTION_DECL || TREE_CODE (decl) == VAR_DECL)
              && TREE_CODE (TREE_VALUE (args)) == STRING_CST)
            {
              if (TREE_CODE (decl) == VAR_DECL
                  && current_function_decl
                  && !TREE_STATIC (decl))
                error_with_decl (decl, "section attribute cannot be specified for local variables");
              /* The decl may have already been given a section attribute from
                 a previous declaration. Ensure they match. */
              else if (DECL_SECTION_NAME (decl)
                       && strcmp (TREE_STRING_POINTER (DECL_SECTION_NAME (decl)),
                                  TREE_STRING_POINTER (TREE_VALUE (args))) != 0)
                error_with_decl (node, "section of `%s' conflicts with previous declaration");
              else
                DECL_SECTION_NAME (decl) = TREE_VALUE (args);
            }
          else
            error_with_decl (node, "section attribute not allowed for `%s'");
#else
          error_with_decl (node, "section attributes are not supported for this target");
#endif
          break;

        case A_ALIGNED:
          {
            tree align_expr = (args ? TREE_VALUE (args) : size_int (BIGGEST_ALIGNMENT / BITS_PER_UNIT));
            int align;

            /* Strip any NOPs of any kind. */
            while (TREE_CODE (align_expr) == NOP_EXPR
                   || TREE_CODE (align_expr) == CONVERT_EXPR
                   || TREE_CODE (align_expr) == NON_LVALUE_EXPR)
              align_expr = TREE_OPERAND (align_expr, 0);

            if (TREE_CODE (align_expr) != INTEGER_CST)
              {
                error ("requested alignment is not a constant");
                continue;
              }

            align = TREE_INT_CST_LOW (align_expr) * BITS_PER_UNIT;

            if (TYPE_P (node))
              *anode = type = build_type_copy (type);
            if (exact_log2 (align) == -1)
              error ("requested alignment is not a power of 2");
            else if (is_type)
              TYPE_ALIGN (type) = align;
            else if (TREE_CODE (decl) != VAR_DECL && TREE_CODE (decl) != FIELD_DECL)
              error_with_decl (decl, "alignment may not be specified for `%s'");
            else
              DECL_ALIGN (decl) = align;
          }
          break;

        case A_WEAK:
          declare_weak (decl);
          break;

        case A_ALIAS:
          if ((TREE_CODE (decl) == FUNCTION_DECL && DECL_INITIAL (decl))
              || (TREE_CODE (decl) != FUNCTION_DECL && !DECL_EXTERNAL (decl)))
            error_with_decl (decl, "`%s' defined both normally and as an alias");
          else if (!decl_function_context (decl))
            {
              tree id = get_identifier (TREE_STRING_POINTER (TREE_VALUE (args)));
              if (TREE_CODE (decl) == FUNCTION_DECL)
                DECL_INITIAL (decl) = error_mark_node;
              else
                DECL_EXTERNAL (decl) = 0;
              assemble_alias (decl, id);
            }
          else
            gpc_warning ("`%s' attribute ignored", IDENTIFIER_NAME (name));
          break;
      }
    }
#endif
}

#ifndef EGCS
char *
concat (const char *first, ...)
{
  int length;
  char *newstr;
  char *end;
  const char *arg;
  va_list args;
#ifndef __STDC__
  const char *first;
#endif
  /* First compute the size of the result and get sufficient memory. */
  VA_START (args, first);
#ifndef __STDC__
  first = va_arg (args, const char *);
#endif
  arg = first;
  length = 0;
  while (arg)
    {
      length += strlen (arg);
      arg = va_arg (args, const char *);
    }
  newstr = (char *) xmalloc (length + 1);
  va_end (args);
  /* Now copy the individual pieces to the result string. */
  VA_START (args, first);
#ifndef __STDC__
  first = va_arg (args, const char *);
#endif
  end = newstr;
  arg = first;
  while (arg)
    {
      while (*arg)
        *end++ = *arg++;
      arg = va_arg (args, const char *);
    }
  *end = '\000';
  va_end (args);
  return (newstr);
}
#endif

/* For ACONCAT */
#ifndef EGCS97
#if defined (__STDC__) || defined (_AIX) || (defined (__mips) && defined (_SYSTYPE_SVR4)) || defined(_WIN32)
#define VA_OPEN(AP, VAR) { va_list AP; va_start(AP, VAR); { struct Qdmy
#define VA_CLOSE(AP) } va_end(AP); }
#define VA_FIXEDARG(AP, T, N) struct Qdmy
#else
#define VA_OPEN(AP, VAR) { va_list AP; va_start(AP); { struct Qdmy
#define VA_CLOSE(AP) } va_end(AP); }
#define VA_FIXEDARG(AP, TYPE, NAME) TYPE NAME = va_arg(AP, TYPE)
#endif

char *libiberty_concat_ptr;

unsigned long
concat_length (const char *first, ...)
{
  unsigned long length = 0;
  const char *arg;
  VA_OPEN (args, first);
  VA_FIXEDARG (args, const char *, first);
  for (arg = first; arg ; arg = va_arg (args, const char *))
    length += strlen (arg);
  VA_CLOSE (args);
  return length;
}

char *
concat_copy2 (const char *first, ...)
{
  char *end = libiberty_concat_ptr;
  const char *arg;
  VA_OPEN (args, first);
  VA_FIXEDARG (args, const char *, first);
  for (arg = first; arg ; arg = va_arg (args, const char *))
    {
      unsigned long length = strlen (arg);
      memcpy (end, arg, length);
      end += length;
    }
  *end = '\000';
  VA_CLOSE (args);
  return libiberty_concat_ptr;
}
#endif

/* Exit compilation as successfully as reasonable. */
void
exit_compilation (void)
{
  if (errorcount)
    exit (FATAL_EXIT_CODE);
  if (sorrycount)
    exit (FATAL_EXIT_CODE);
  exit (SUCCESS_EXIT_CODE);
}

void
assert_fail (const char *msg, const char *file, const char *function, int line)
{
  if (function)
    fprintf (stderr, "%s:%i:%s: failed assertion `%s'\n", file, line, function, msg);
  else
    fprintf (stderr, "%s:%i: failed assertion `%s'\n", file, line, msg);
  error ("Internal compiler error.\n\
Please submit a full bug report to the GPC mailing list <gpc@gnu.de>.\n\
See <URL:http://www.gnu-pascal.de/todo.html> for details.");
  exit (FATAL_EXIT_CODE);
}
