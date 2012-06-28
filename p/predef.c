/*Predefined identifiers, RTS interface

  Copyright (C) 1987-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
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

#define RTS_CONSTANT(NAME, VALUE) NAME = VALUE,
enum {
#include "rts/constants.def"
  RTS_CONSTANT_DUMMY
};

/* Implementation-defined length of the `Name' field of `BindingType'. */
#define BINDING_NAME_LENGTH 2048

// #ifndef EGCS
tree
xnon_lvalue (tree x)
{
  return TREE_CODE (x) == INTEGER_CST ? x : 
     build1 (NON_LVALUE_EXPR, TREE_TYPE (x), x);
}
// #undef non_lvalue
// #define non_lvalue xnon_lvalue
// #endif

#undef EOF
#undef asm
#undef inline
#undef register
#undef static
#undef volatile

#undef PREDEF_KEYWORD
#undef PREDEF_INTERFACE
#undef PREDEF_CONST
#undef PREDEF_TYPE
#undef PREDEF_VAR
#undef PREDEF_SYNTAX
#undef PREDEF_SYMBOL
#undef PREDEF_ID
#undef PREDEF_ROUTINE
#undef PREDEF_ALIAS
#undef PREDEF_ROUTINE_NO_ID

#define PREDEF_INTERNAL(NAME, RTS_NAME, ALIAS_NAME, SYMBOL, KIND, SIG, ATTRIBUTES, DIALECT, VALUE) \
  { NAME, RTS_NAME, ALIAS_NAME, SYMBOL, KIND, SIG, ATTRIBUTES, DIALECT, VALUE, NULL_TREE, 0 },
#define PREDEF_ID(NAME, DIALECT) \
  PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, CONCAT2(p_,NAME), bk_none, NULL, 0, DIALECT, NULL)
#define PREDEF_KEYWORD(NAME, WEAK, DIALECT) \
  PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, CONCAT2(p_,NAME), bk_keyword, NULL, WEAK > 0 ? KW_WEAK : WEAK < 0 ? KW_DIRECTIVE : 0, DIALECT, NULL)
#define PREDEF_INTERFACE(NAME, DIALECT) PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, CONCAT2(p_,NAME), bk_interface, NULL, 0, DIALECT, NULL)
#define PREDEF_CONST(NAME, VALUE, DIALECT) PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, 0, bk_const, NULL, 0, DIALECT, &VALUE)
#define PREDEF_TYPE(NAME, TYPE, DIALECT) PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, 0, bk_type, NULL, 0, DIALECT, &TYPE)
#define PREDEF_VAR(NAME, VAR, DIALECT) PREDEF_INTERNAL (STRINGX(NAME), NULL, NULL, CONCAT2(p_,NAME), bk_var, NULL, 0, DIALECT, &VAR)
#define PREDEF_SYNTAX(NAME, SIG, ATTRIBUTES, DIALECT) \
  PREDEF_INTERNAL (STRINGX(NAME), STRINGX(NAME), NULL, CONCAT2(p_,NAME), bk_special_syntax, SIG, ATTRIBUTES, DIALECT, NULL)
#define PREDEF_ROUTINE(NAME, SIG, ATTRIBUTES, DIALECT) PREDEF_ALIAS (NAME, NAME, SIG, ATTRIBUTES, DIALECT)
#define PREDEF_ALIAS(NAME, RTS_NAME, SIG, ATTRIBUTES, DIALECT) \
  PREDEF_INTERNAL (STRINGX(NAME), STRINGX(RTS_NAME), NULL, CONCAT2(p_,NAME), bk_routine, SIG, ATTRIBUTES, DIALECT, NULL)
#define PREDEF_ROUTINE_NO_ID(RTS_NAME, SIG, ATTRIBUTES) \
  PREDEF_SYMBOL (CONCAT2(p_,RTS_NAME), RTS_NAME, STRINGX(RTS_NAME), SIG, ATTRIBUTES)
#define PREDEF_SYMBOL(SYMBOL, RTS_NAME, ALIAS_NAME, SIG, ATTRIBUTES) \
  PREDEF_INTERNAL (NULL, STRINGX(RTS_NAME), ALIAS_NAME, SYMBOL, bk_routine, SIG, ATTRIBUTES, ANY_PASCAL, NULL)

static GTY(()) struct predef predef_table[] =
{
#include <predef.def>
};

static tree type_from_sig (int);
static tree int_range_type (tree, int);
static int direct_access_warning (tree);
static tree get_read_flags (int);
static unsigned HOST_WIDE_INT get_string_length_plus_1 (tree, int);
static tree actual_set_parameters (tree, int);
static tree build_read (int, tree, const char *);
static tree string_par (tree *);
static tree build_write (int, tree, const char *);
static tree build_val (tree);
static tree pascal_unpack_and_pack (int, tree, tree, tree, const char *);
static tree check_argument (tree, const char *, int, const char **, tree *, enum tree_code *);
static tree get_standard_input (void);
static tree get_standard_output (void);

/*@@*/
static tree check_files (tree);
static tree
check_files (tree list)
{
  tree t;
  for (t = list; t; t = TREE_CHAIN (t))
    if (PASCAL_TYPE_FILE (TREE_TYPE (TREE_VALUE (t))))
      TREE_VALUE (t) = build_component_ref (TREE_VALUE (t), get_identifier ("_p_File_"));
  return list;
}

static tree
type_from_sig (int c)
{
  switch (c)
  {
    case '!': /* Pascal function, but implemented as an RTS procedure: FALLTHROUGH */
    case '>': /* Write procedure: FALLTHROUGH */
    case '-': return void_type_node;
    case 'i': return pascal_integer_type_node;
    case 'h': return pascal_cardinal_type_node;
    case 'l': return long_long_integer_type_node;
    case 'n': return long_long_unsigned_type_node;
    case 'r': return double_type_node;
    case 'e': return long_double_type_node;
    case '/': return float_type_node;
    case 'z': return complex_type_node;
    case 'b': return boolean_type_node;
    case 'c': return char_type_node;
    case 's': return string_schema_proto_type;
    case 'q': return cstring_type_node;
    case 'p': return ptr_type_node;
    case 'a': return gpc_type_BindingType;
    case 't': return gpc_type_TimeStamp;
    case 'f': case '@': return any_file_type_node;
    case 'j': return text_type_node;
    case '$': return size_type_node;
    case '~': return gpc_type_DateTimeString;
    case '%': return build_pointer_type (string_schema_proto_type);
  }
  gcc_unreachable ();
}

static tree
int_range_type (tree low, int high)
{
  tree h = build_int_2 (high, 0);
  return build_range_type (
    const_lt (h, TYPE_MAX_VALUE (pascal_integer_type_node)) ? pascal_integer_type_node :
    const_lt (h, TYPE_MAX_VALUE (long_integer_type_node)) ? long_integer_type_node :
    long_long_integer_type_node, low, h);
}

void
init_predef (void)
{
  tree temp;
  int i;

  lexer_filename = compiler_filename = pascal_input_filename;
  lexer_lineno = compiler_lineno = lineno;
  lexer_column = compiler_column = column;

  /* A unique prototype string schema. */
  string_schema_proto_type = build_pascal_string_schema (NULL_TREE);
  TYPE_LANG_CODE (string_schema_proto_type) = PASCAL_LANG_UNDISCRIMINATED_STRING;
  TYPE_LANG_BASE (string_schema_proto_type) = string_schema_proto_type;

  /* A read-only variant of this. */
  const_string_schema_proto_type = p_build_type_variant (string_schema_proto_type, 1, 0);

  const_string_schema_par_type = build_type_copy (build_reference_type (const_string_schema_proto_type));
  PASCAL_TYPE_VAL_REF_PARM (const_string_schema_par_type) = 1;
  PASCAL_CONST_PARM (const_string_schema_par_type) = 1;

  string255_type_node = build_pascal_string_schema (build_int_2 (255, 0));

  text_type_node = build_file_type (char_type_node, NULL_TREE, 0);
  TYPE_LANG_CODE (text_type_node) = PASCAL_LANG_TEXT_FILE;

  untyped_file_type_node = build_file_type (void_type_node, NULL_TREE, 1);
  /* This decl is needed in parse.y: variable_or_routine_access_no_builtin_function. */
  temp = build_decl (TYPE_DECL, get_identifier ("File"), untyped_file_type_node);
  DECL_ARTIFICIAL (temp) = 1;
  TREE_PUBLIC (temp) = 1;
  TYPE_NAME (untyped_file_type_node) = temp;

  any_file_type_node = build_file_type (void_type_node, NULL_TREE, 1);

  /* A canonical-string-type returned by `Date' and `Time' with
     implementation-dependent length, e.g. `14 Nov 2003' or `22:55:26' */
  gpc_type_DateTimeString = build_pascal_string_schema (build_int_2 (11, 0));

  /* Required type `TimeStamp' */
  temp = chainon (build_field (get_identifier ("Datevalid"), boolean_type_node),
         chainon (build_field (get_identifier ("Timevalid"), boolean_type_node),
         chainon (build_field (get_identifier ("Year"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Month"), int_range_type (integer_one_node, 12)),
         chainon (build_field (get_identifier ("Day"), int_range_type (integer_one_node, 31)),
         chainon (build_field (get_identifier ("Dayofweek"), int_range_type (integer_zero_node, 6)),
         chainon (build_field (get_identifier ("Hour"), int_range_type (integer_zero_node, 23)),
         chainon (build_field (get_identifier ("Minute"), int_range_type (integer_zero_node, 59)),
         chainon (build_field (get_identifier ("Second"), int_range_type (integer_zero_node, 61)),
         chainon (build_field (get_identifier ("Microsecond"), int_range_type (integer_zero_node, 999999)),
         chainon (build_field (get_identifier ("Timezone"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Dst"), boolean_type_node),
         chainon (build_field (get_identifier ("Tzname1"), build_pascal_string_schema (build_int_2 (32, 0))),
                  build_field (get_identifier ("Tzname2"), build_pascal_string_schema (build_int_2 (32, 0))))))))))))))));
  defining_packed_type++;
  gpc_type_TimeStamp = pack_type (finish_struct (start_struct (RECORD_TYPE), temp, 1));
  defining_packed_type--;

  /* Required type `BindingType' */
  temp = chainon (build_field (get_identifier ("Bound"), boolean_type_node),
         chainon (build_field (get_identifier ("Force"), boolean_type_node),
         chainon (build_field (get_identifier ("Extensions_valid"), boolean_type_node),
         chainon (build_field (get_identifier ("Readable"), boolean_type_node),
         chainon (build_field (get_identifier ("Writable"), boolean_type_node),
         chainon (build_field (get_identifier ("Executable"), boolean_type_node),
         chainon (build_field (get_identifier ("Existing"), boolean_type_node),
         chainon (build_field (get_identifier ("Directory"), boolean_type_node),
         chainon (build_field (get_identifier ("Special"), boolean_type_node),
         chainon (build_field (get_identifier ("Symlink"), boolean_type_node),
         chainon (build_field (get_identifier ("Size"), long_long_integer_type_node),
         chainon (build_field (get_identifier ("Accesstime"), long_long_integer_type_node),
         chainon (build_field (get_identifier ("Modificationtime"), long_long_integer_type_node),
         chainon (build_field (get_identifier ("Changetime"), long_long_integer_type_node),
         chainon (build_field (get_identifier ("User"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Group"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Mode"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Device"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Inode"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Links"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Textbinary"), boolean_type_node),
         chainon (build_field (get_identifier ("Handle"), pascal_integer_type_node),
         chainon (build_field (get_identifier ("Closeflag"), boolean_type_node),
                  build_field (get_identifier ("Name"), build_pascal_string_schema (build_int_2 (BINDING_NAME_LENGTH, 0))))))))))))))))))))))))));
  defining_packed_type++;
  gpc_type_BindingType = pack_type (finish_struct (start_struct (RECORD_TYPE), temp, 1));
  defining_packed_type--;

  /* Object type VMT */
  temp = start_struct (RECORD_TYPE);
  gpc_type_PObjectType = build_pointer_type (temp);
  gpc_fields_PObjectType = chainon (build_field (get_identifier ("Size"), size_type_node),
                           chainon (build_field (get_identifier ("Negatedsize"), signed_type (size_type_node)),
                           chainon (build_field (get_identifier ("Parent"), gpc_type_PObjectType),
                                    build_field (get_identifier ("Name"), build_pointer_type (const_string_schema_proto_type)))));
  temp = finish_struct (temp, gpc_fields_PObjectType, 0);
  TYPE_READONLY (temp) = 1;  /* No need for a variant, this type is always readonly */
  /* Root object */
  root_object_type_node = NULL_TREE;

  /* Obtain the input and output files initialized in the RTS. */
  input_variable_node = declare_variable (get_identifier ("_p_Input"),
    text_type_node, NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);
  DECL_NAME (input_variable_node) = get_identifier ("Input");
  PASCAL_EXTERNAL_OBJECT (input_variable_node) = 1;

  output_variable_node = declare_variable (get_identifier ("_p_Output"),
    text_type_node, NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);
  DECL_NAME (output_variable_node) = get_identifier ("Output");
  PASCAL_EXTERNAL_OBJECT (output_variable_node) = 1;

  error_variable_node = declare_variable (get_identifier ("_p_StdErr"),
    text_type_node, NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);
  DECL_NAME (error_variable_node) = get_identifier ("Stderr");
  PASCAL_EXTERNAL_OBJECT (error_variable_node) = 1;

  inoutres_variable_node = declare_variable (get_identifier ("_p_InOutRes"),
    pascal_integer_type_node, NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);
  paramcount_variable_node = declare_variable (get_identifier ("_p_CParamCount"),
    pascal_integer_type_node, NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);
  paramstr_variable_node = declare_variable (get_identifier ("_p_CParameters"),
    build_pointer_type (cstring_type_node), NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);

  /* routine to set bits to 1. Used in set constructors */
  temp = build_implicit_routine_decl (get_identifier ("__setbits"),
    void_type_node, tree_cons (NULL_TREE, ptr_type_node, 
           tree_cons (NULL_TREE, long_integer_type_node,
           tree_cons (NULL_TREE, long_integer_type_node,
           tree_cons (NULL_TREE, long_integer_type_node, void_list_node)))),
           ER_EXTERNAL);
  DECL_ARTIFICIAL (temp) = 1;
  setbits_routine_node = temp;
/*
build1 (ADDR_EXPR, build_pointer_type (
    p_build_type_variant (TREE_TYPE (temp), TREE_READONLY (temp), TREE_THIS_VOLATILE (temp))), temp);
*/
  /* This procedure may return if InOutRes = 0. But it is called automatically
     only if InOutRes <> 0 (more efficient, to save function calls in the
     normal case). Declaring it noreturn here is thus correct in this
     circumstance and improves the generated code. */
  temp = build_implicit_routine_decl (get_identifier ("_p_CheckInOutRes"),
    void_type_node, void_list_node, ER_EXTERNAL | ER_NORETURN);
  DECL_ARTIFICIAL (temp) = 1;
  /* Build a function pointer to simplify its usage later. */
  checkinoutres_routine_node = build1 (ADDR_EXPR, build_pointer_type (
    p_build_type_variant (TREE_TYPE (temp), TREE_READONLY (temp), TREE_THIS_VOLATILE (temp))), temp);

  validate_pointer_ptr_node = declare_variable (get_identifier ("_p_ValidatePointerPtr"),
    build_pointer_type (build_function_type (void_type_node, tree_cons (NULL_TREE, ptr_type_node, void_list_node))),
    NULL_TREE, VQ_EXTERNAL | VQ_IMPLICIT);

  /* Built-in identifiers */
  for (i = 0; i < (int) ARRAY_SIZE (predef_table); i++)
    {
      enum built_in_kind kind = predef_table[i].kind;
      tree decl = NULL_TREE;
      const char *p = predef_table[i].idname;
      if (p)
        {
          tree id;
          char *new_name = alloca (strlen (p) + 1), *q = new_name;
          /* Would cause lexer problems WRT LEX_CARET_LETTER; bad style anyway. */
          if (predef_table[i].symbol != p_c)  /* @@ */
            gcc_assert (strlen (p) > 1);
          *q++ = TOUPPER (*p++);
          while (*p)
            *q++ = TOLOWER (*p++);
          *q = 0;
          id = get_identifier (new_name);
          IDENTIFIER_BUILT_IN_VALUE (id) = &predef_table[i];
          if ((kind == bk_const || kind == bk_type || kind == bk_var) && !is_gpi_special_node (*predef_table[i].value))
            error ("internal error: node `%s' missing in SPECIAL_NODES in module.c", predef_table[i].idname);
          if (kind == bk_const)
            {
              tree v = *predef_table[i].value;
              decl = build_decl (CONST_DECL, id, TREE_TYPE (v));
              DECL_INITIAL (decl) = v;
              if (TREE_CODE_CLASS (TREE_CODE (v)) == tcc_constant)
                PASCAL_CST_FRESH (v) = 1;
            }
          if (kind == bk_type)
            {
              tree type = *predef_table[i].value, orig = NULL_TREE;
              if (TYPE_NAME (type))
                type = build_type_copy ((orig = type));
              TYPE_NAME (type) = decl = build_decl (TYPE_DECL, id, type);
              DECL_ORIGINAL_TYPE (decl) = NULL_TREE  /* orig @@ dwarf-2 and gcc-3.3 */;
              /* necessary to get debug info (e.g. fjf910.pas, tested with gcc-2.8.1, stabs) */
#ifndef GCC_4_0
              rest_of_decl_compilation (decl, NULL, 1, 1);
#endif
            }
          if (kind == bk_var)
            decl = *predef_table[i].value;
        }
      if (kind == bk_special_syntax || kind == bk_routine)
        {
          tree args = NULL_TREE, id;
          const char *signature = predef_table[i].signature, *p;
          gcc_assert (predef_table[i].rts_idname && signature);
          p = strchr (signature, '|');
          if (p)
            {
              signature = p + 1;
              if (!*signature)  /* no RTS routine, always inlined */
                continue;
            }
          for (p = signature + 1; *p; p++)
            if (*p != ',')
              {
                unsigned char c = *p;
                tree t;
                if (c == 's')  /* value string parameters to the RTS are always `const' */
                  t = const_string_schema_par_type;
                else if (c == 'M' || c == 'm')  /* sets */
                  {
                    args = tree_cons (NULL_TREE, pascal_integer_type_node,
                      tree_cons (NULL_TREE, c == 'M' ? ptr_type_node : const_ptr_type_node, args));
                    t = pascal_integer_type_node;
                  }
                else if (c == 'F' || c == 'f' || c == 'J' || c == 'j' || c == '@')
                  {
                    t = ptr_type_node;
                    if (c == '@')
                      t = build_reference_type (t);
                  }
                else
                  {
                    t = type_from_sig (TOLOWER (c));
                    /* `TimeStamp' is always passed by reference, but possibly `protected'
                       (files were too, but they're pointers now anyway, so they're always
                       passed by value to the RTS internally; execption: InitFDR (`@')) */
                    if (ISUPPER (c) && c != 'F' && c != 'J')
                      t = build_reference_type (t);
                    else if (/* c == 'f' || c == 'j' || */ c == 't')
                      t = build_reference_type (p_build_type_variant (t, 1, TYPE_VOLATILE (t)));
                  }
                args = tree_cons (NULL_TREE, t, args);
              }
          args = nreverse (args);
          if (p[-1] != ',')
            args = chainon (args, void_list_node);
          id = get_identifier (ACONCAT (("_p_", predef_table[i].rts_idname, NULL)));
          decl = build_implicit_routine_decl (id, type_from_sig (*signature),
                   args, ER_EXTERNAL | predef_table[i].attributes);
        }
      if (decl)
        {
          DECL_ARTIFICIAL (decl) = 1;
          TREE_PUBLIC (decl) = 1;
          predef_table[i].decl = decl;
#if defined (EGCS97) && !defined (GCC_3_3)
          ggc_add_tree_root (&predef_table[i].decl, 1);
#endif
        }
    }
  do_deferred_options ();
}

static tree
actual_set_parameters (tree val, int reference)
{
  tree domain = TYPE_DOMAIN (TREE_TYPE (val)), addr;
  unsigned long save_pascal_dialect = co->pascal_dialect;
  int addressable = mark_addressable (val);
  co->pascal_dialect = ANY_PASCAL;

  gcc_assert (addressable);

  /* Callers now handle the constant empty set. */
  gcc_assert (TREE_TYPE (val) != empty_set_type_node);

  /* Functions returning sets are no lvalues, so build_pascal_unary_op
     would complain. So call build1 directly for value parameters.
     For reference parameters, let build_pascal_unary_op do its checks. */
  if (reference)
    addr = build_pascal_unary_op (ADDR_EXPR, val);
  else
    addr = build1 (ADDR_EXPR, build_pointer_type (TREE_TYPE (val)), val);
  co->pascal_dialect = save_pascal_dialect;
  return tree_cons (NULL_TREE, addr,
    tree_cons (NULL_TREE, convert (pascal_integer_type_node, TYPE_MIN_VALUE (domain)),
      build_tree_list (NULL_TREE, convert (pascal_integer_type_node, TYPE_MAX_VALUE (domain)))));
}

static int
direct_access_warning (tree type)
{
  if (!TYPE_LANG_FILE_DOMAIN (type))
    chk_dialect ("direct access to files without declared domain is", B_D_M_PASCAL);
  return !TYPE_LANG_FILE_DOMAIN (type);
}

static tree
get_read_flags (int is_val)
{
  int flags = 0;
  if (co->read_base_specifier)
    flags |= INT_READ_BASE_SPEC_MASK;
  if (co->read_hex)
    flags |= INT_READ_HEX_MASK;
  if (!is_val && co->read_white_space)
    flags |= NUM_READ_CHK_WHITE_MASK;
  if (co->pascal_dialect && !(co->pascal_dialect & NOT_CLASSIC_PASCAL))
    flags |= REAL_READ_SP_ONLY_MASK;
  if (is_val)
    flags |= VAL_MASK;
  return build_int_2 (flags, 0);
}

/* Return the string length (modulo padding) + 1 if known, 0 otherwise. (We need an unsigned type here.) */
static unsigned HOST_WIDE_INT
get_string_length_plus_1 (tree string, int nopad)
{
  unsigned HOST_WIDE_INT l;
  const char *p;
  tree t = PASCAL_STRING_LENGTH (string);
  if (TREE_CODE (t) != INTEGER_CST)
    return 0;
  l = TREE_INT_CST_LOW (t);
  if (nopad)
    return l + 1;
  if (TREE_CODE (string) == INTEGER_CST &&
      TYPE_IS_CHAR_TYPE (TREE_TYPE (string)))
    return TREE_INT_CST_LOW (string) == ' ' ? 1 : 2;
  if (TREE_CODE (string) != STRING_CST)
    return 0;
  p = TREE_STRING_POINTER (string);
  while (l > 0 && p[l - 1] == ' ')
    l--;
  return l + 1;
}

/* Make sure that a string can be accessed multiple times (usually for the
   length and contents). Note that the string does not need to be an lvalue.
   (note `function: PString' vs. `function: String') */
tree
save_expr_string (tree string)
{
  tree t, stmts = NULL_TREE, addr;
  /* Non-schema strings don't need to be saved, because the routines will
     access them only once, anyway (not for the length). */
  if (!PASCAL_TYPE_STRING (TREE_TYPE (string)) || !TREE_SIDE_EFFECTS (string))
    return string;

  t = string;
  while (1)
    if (TREE_CODE (t) == NOP_EXPR
        || TREE_CODE (t) == CONVERT_EXPR
        || TREE_CODE (t) == NON_LVALUE_EXPR
        || TREE_CODE (t) == SAVE_EXPR)
      t = TREE_OPERAND (t, 0);
    else if (TREE_CODE (t) == COMPOUND_EXPR)
      {
        stmts = stmts ? build2 (COMPOUND_EXPR, void_type_node,
                          TREE_OPERAND (t, 0), stmts) : TREE_OPERAND (t, 0);
        t = TREE_OPERAND (t, 1);
      }
    else
      break;
  if (TREE_CODE (t) == INDIRECT_REF)
    addr = TREE_OPERAND (t, 0);
  else if (TREE_CODE (t) != VAR_DECL && TREE_CODE (t) != PARM_DECL)  /* calling `function: String' creates a temp var decl */
    addr = build_unary_op (ADDR_EXPR, t, 2);
  else
    return string;
  if (stmts)
    addr = build2 (COMPOUND_EXPR, TREE_TYPE (addr), stmts, addr);
  return build_indirect_ref (save_expr (addr), NULL);
}

/* If *str is a valid string parameter, put its address in *str and
   return its length. Otherwise return NULL_TREE. */
static tree
string_par (tree *str)
{
  if (is_string_compatible_type (*str, 1))
    {
      tree t = save_expr_string (*str);
      tree ptype = cstring_type_node;
      if (TYPE_IS_CHAR_TYPE (TREE_TYPE (t)))
        ptype = build_pointer_type (TREE_TYPE (t));
      *str = build1 (ADDR_EXPR, ptype, PASCAL_STRING_VALUE (t));
      *str = convert (cstring_type_node, *str);
      return PASCAL_STRING_LENGTH (t);
    }
  else if ((co->cstrings_as_strings || (co->pascal_dialect & B_D_M_PASCAL))
           && TYPE_MAIN_VARIANT (base_type (TREE_TYPE (*str))) == cstring_type_node)
    {
      *str = save_expr (*str);
      return build_routine_call (strlen_routine_node, build_tree_list (NULL_TREE, *str));
    }
  else
    return NULL_TREE;
}

/* Read from files and strings. */
static tree
build_read (int r_num, tree params, const char *r_name)
{
  tree file, parm;
  if (r_num == p_ReadStr || r_num == p_ReadString)
    {
      tree parm0, save_parm0, length = NULL_TREE;
      if (params)
        {
          save_parm0 = parm0 = TREE_VALUE (params);
          length = string_par (&parm0);
        }
      if (!length)
        {
          error ("argument 1 to `%s' must be the string to read from", r_name);
          if (params && TYPE_MAIN_VARIANT (TREE_TYPE (TREE_VALUE (params))) == cstring_type_node)
            cstring_inform ();
          return error_mark_node;
        }
      params = TREE_CHAIN (params);
      if (r_num == p_ReadStr && !params)
        error_or_warning (co->pascal_dialect & E_O_PASCAL, 
               "ISO requires at least one output parameter in `ReadStr'");
      for (parm = params; parm; parm = TREE_CHAIN (parm))
        if (TREE_SIDE_EFFECTS (TREE_VALUE (parm)))
          {
            parm0 = save_parm0;
            if (TYPE_MAIN_VARIANT (TREE_TYPE (parm0)) == cstring_type_node)
              parm0 = build_predef_call (p_CString2String,
                        build_tree_list (NULL_TREE, parm0));
            parm0 = new_string_by_model (NULL_TREE, parm0, 1);
            length = string_par (&parm0);
            gcc_assert (length);
            break;
          }
      /* This file variable is needed internally. It is no real file,
         so be careful what you do with it. Don't call `init_any'. */
      file = declare_variable (get_unique_identifier ("readstr_tmp_file"), text_type_node, NULL_TREE, VQ_IMPLICIT);
      expand_expr_stmt (build_modify_expr (build_component_ref (file,
          get_identifier ("_p_File_")), NOP_EXPR,
        build_predef_call (p_ReadStr_Init, tree_cons (NULL_TREE, parm0,
          tree_cons (NULL_TREE, length, build_tree_list (NULL_TREE,
            get_read_flags (0)))))));
    }
  else
    {
      if (params && PASCAL_TYPE_FILE (TREE_TYPE (TREE_VALUE (params))))
        {
          file = TREE_VALUE (params);
          params = TREE_CHAIN (params);
        }
      else
        file = get_standard_input ();
      if (PASCAL_TYPE_ANYFILE (TREE_TYPE (file)))
        {
          error ("`%s' cannot be used with files of type `AnyFile'", r_name);
          return error_mark_node;
        }
      if (r_num == p_Read && !params)
        {
          error_or_warning (co->pascal_dialect & C_E_O_PASCAL, "`Read' without variables to read -- ignored");
          return NULL_TREE;
        }
      if (!PASCAL_TYPE_TEXT_FILE (TREE_TYPE (file)))
        {
          /* Reading from a typed file */
          if (r_num != p_Read)
            {
              error ("`%s' is allowed only when reading from files of type `Text'", r_name);
              return error_mark_node;
            }
          for (parm = params; parm; parm = TREE_CHAIN (parm))
            {
              /* Call build_buffer_ref *within* the loop so the lazy getting is done each time */
              expand_pascal_assignment (undo_schema_dereference (TREE_VALUE (parm)), build_buffer_ref (file, p_LazyGet));
              build_predef_call (p_Get, build_tree_list (NULL_TREE, file));
            }
          return NULL_TREE;
        }
      build_predef_call (p_Read_Init, tree_cons (NULL_TREE, file, build_tree_list (NULL_TREE, get_read_flags (0))));
    }
  for (parm = params; parm; parm = TREE_CHAIN (parm))
    {
      tree p = TREE_VALUE (parm), type = TREE_TYPE (p), t;
      int r_num2;
      if (!mark_lvalue (p, "reading in", 1))
        return error_mark_node;
      switch (TREE_CODE (type))
      {
        case INTEGER_TYPE:
          if (TYPE_IS_CHAR_TYPE (type))
            r_num2 = p_Read_Char;
          else
            r_num2 = TYPE_UNSIGNED (type) ? p_Read_Cardinal : p_Read_Integer;
          break;
#ifndef GCC_4_2
        case CHAR_TYPE:
          r_num2 = p_Read_Char;
          break;
#endif
        case REAL_TYPE:
          {
            if (TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node))
              r_num2 = p_Read_LongReal;
            else if (TYPE_PRECISION (type) > TYPE_PRECISION (float_type_node))
              r_num2 = p_Read_Real;
            else
              r_num2 = p_Read_ShortReal;
            break;
          }
        case RECORD_TYPE:  /* String schema */
        case ARRAY_TYPE:   /* Fixed length string */
          if (is_string_type (p, 1))
            {
              chk_dialect ("reading strings from `Text' files is", E_O_B_D_M_PASCAL);
              if (PASCAL_TYPE_STRING (type))
                {
                  p = save_expr_string (p);
                  expand_expr_stmt (build_modify_expr (PASCAL_STRING_LENGTH (p), NOP_EXPR,
                    build_predef_call (p_Read_String, tree_cons (NULL_TREE, file,
                      tree_cons (NULL_TREE, convert (ptr_type_node, 
                        build_unary_op (ADDR_EXPR, PASCAL_STRING_VALUE (p), 1)),
                        build_tree_list (NULL_TREE, PASCAL_STRING_CAPACITY (p)))))));
                }
              else
                expand_expr_stmt (build_predef_call (p_Read_FixedString,
                  tree_cons (NULL_TREE, file, tree_cons (NULL_TREE, 
                    convert (ptr_type_node, build_unary_op (ADDR_EXPR, p, 1)),
                    build_tree_list (NULL_TREE, pascal_array_type_nelts (type))))));
              continue;
            }
          /* FALLTHROUGH */
        default:
          error ("argument to `%s' is of wrong type", r_name);
          /* FALLTHROUGH */
        case ERROR_MARK:
          return error_mark_node;
      }

      t = build_predef_call (r_num2, build_tree_list (NULL_TREE, file));
      co->range_checking <<= 1;
      t = build_modify_expr (p, NOP_EXPR, t);
      co->range_checking >>= 1;
      expand_expr_stmt (t);
    }
  if (r_num == p_ReadLn)
    build_predef_call (p_Read_Line, build_tree_list (NULL_TREE, file));
  if (r_num == p_ReadStr || r_num == p_ReadString)
    build_predef_call (p_ReadWriteStr_Done, build_tree_list (NULL_TREE, file));
  if (co->io_checking)
    expand_expr_stmt (convert (void_type_node, build_iocheck ()));
  return NULL_TREE;
}

/* `Val' */
static tree
build_val (tree params)
{
  tree target, type, res_pos, file, length, t;
  int r_num;
  length = string_par (&TREE_VALUE (params));
  if (!length)
    {
      error ("argument 1 to `Val' must be a string");
      return error_mark_node;
    }
  res_pos = TREE_VALUE (TREE_CHAIN (TREE_CHAIN (params)));
  if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (res_pos)))
    {
      error ("argument 3 to `Val' must be an integer");
      return error_mark_node;
    }
  target = TREE_VALUE (TREE_CHAIN (params));
  type = TREE_TYPE (target);
  if (TYPE_IS_INTEGER_TYPE (type))
    r_num = TYPE_UNSIGNED (type) ? p_Read_Cardinal : p_Read_Integer;
  else if (TREE_CODE (type) == REAL_TYPE)
    {
      if (TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node))
        r_num = p_Read_LongReal;
      else if (TYPE_PRECISION (type) > TYPE_PRECISION (float_type_node))
        r_num = p_Read_Real;
      else
        r_num = p_Read_ShortReal;
    }
  else
    {
      error ("argument 2 to `Val' must be of integer or real type");
      return error_mark_node;
    }
  TREE_CHAIN (params) = tree_cons (NULL_TREE, length, build_tree_list (NULL_TREE, (get_read_flags (1))));
  /* This file variable is needed internally. It is no real file,
     so be careful what you do with it. Don't call `init_any'. */
  file = declare_variable (get_unique_identifier ("val_tmp_file"), text_type_node, NULL_TREE, VQ_IMPLICIT);
  expand_expr_stmt (build_modify_expr (build_component_ref (file,
    get_identifier ("_p_File_")), NOP_EXPR, build_predef_call (p_ReadStr_Init, params)));

  t = build_predef_call (r_num, build_tree_list (NULL_TREE, file));
  co->range_checking <<= 1;
  t = build_modify_expr (target, NOP_EXPR, t);
  co->range_checking >>= 1;
  expand_expr_stmt (t);
  expand_expr_stmt (build_modify_expr (res_pos, NOP_EXPR, build_predef_call (p_Val_Done, build_tree_list (NULL_TREE, file))));
  return NULL_TREE;
}

/* Write to files and strings. */
static tree
build_write (int r_num, tree params, const char *r_name)
{
  tree file = NULL_TREE, parm, format_string = NULL_TREE, string_length = NULL_TREE;
  int flags;
  flags = (co->pascal_dialect & (CLASSIC_PASCAL_LEVEL_0 | CLASSIC_PASCAL_LEVEL_1)) ? NEG_ZERO_WIDTH_ERROR_MASK
          : (co->pascal_dialect & E_O_PASCAL) ? NEG_WIDTH_ERROR_MASK
          : (co->pascal_dialect & B_D_M_PASCAL) ? 0
          : NEG_WIDTH_LEFT_MASK;
  if (!co->real_blank)
    flags |= REAL_NOBLANK_MASK;
  if (co->capital_exponent)
    flags |= REAL_CAPITAL_EXP_MASK;
  if (co->write_clip_strings)
    flags |= CLIP_STRING_MASK;
  if (co->truncate_strings)
    flags |= TRUNCATE_STRING_MASK;

  if (r_num == p_FormatString || r_num == p_WriteStr || r_num == p_Str
      || r_num == p_StringOf)
    /* This file variable is needed internally. It is no real file,
       so be careful what you do with it. Don't call `init_any'. */
    file = declare_variable (get_unique_identifier ("writestr_tmp_file"), text_type_node, NULL_TREE, VQ_IMPLICIT);

  if (r_num == p_FormatString || r_num == p_StringOf)
    {
      if (r_num == p_FormatString)
        {
      if (!is_string_compatible_type (TREE_VALUE (params), 1))
        {
          error ("argument 1 to `%s' must be a string or char", r_name);
          return error_mark_node;
        }
      if (TREE_PURPOSE (params))
        error ("spurious field width specification in format string in `%s'", r_name);
      format_string = TREE_VALUE (params);
      params = TREE_CHAIN (params);
        }
      expand_expr_stmt (build_modify_expr (build_component_ref (file, get_identifier ("_p_File_")), NOP_EXPR,
        build_predef_call (p_FormatString_Init, tree_cons (NULL_TREE, build_int_2 (flags, 0),
        build_tree_list (NULL_TREE, build_int_2 (list_length (params), 0))))));
    }
  else if (r_num == p_WriteStr || r_num == p_Str)
    {
      tree string, capacity;
      if (!params || !TREE_CHAIN (params))
        {
          error ("too few arguments to `%s'", r_name);
          return error_mark_node;
        }
      if (r_num == p_WriteStr)
        {
          string = params;
          params = TREE_CHAIN (params);
        }
      else
        {
          tree last = NULL_TREE;
          for (string = params; TREE_CHAIN (string); string = TREE_CHAIN (string))
            last = string;
          TREE_CHAIN (last) = NULL_TREE;
          if (TREE_CHAIN (params))
            chk_dialect_1 ("`%s' with multiple values is", GNU_PASCAL, r_name);
        }
      if (TREE_PURPOSE (string))
        error ("spurious field width specification in target string in `%s'", r_name);
      string = TREE_VALUE (string);
      if (!mark_lvalue (string, r_num == p_WriteStr
            ? "use as `WriteStr' destination" : "use as `Str' destination", 1))
        return error_mark_node;
      if (PASCAL_TYPE_STRING (TREE_TYPE (string)))
        {
          string_length = PASCAL_STRING_LENGTH (string);
          capacity = PASCAL_STRING_CAPACITY (string);
        }
      else if (is_string_type (string, 1))
        {
          flags |= WRITE_FIXED_STRING_MASK;
          capacity = pascal_array_type_nelts (TREE_TYPE (string));
        }
      else
        {
          error ("%s argument to `%s' must be the string to write to", r_num == p_WriteStr ? "first" : "last", r_name);
          return error_mark_node;
        }
      expand_expr_stmt (build_modify_expr (build_component_ref (file, get_identifier ("_p_File_")), NOP_EXPR,
        build_predef_call (p_WriteStr_Init,
          tree_cons (NULL_TREE, build_unary_op (ADDR_EXPR, PASCAL_STRING_VALUE (string), 0),
          tree_cons (NULL_TREE, capacity,
          build_tree_list (NULL_TREE, build_int_2 (flags, 0)))))));
    }
  else
    {
      if (r_num == p_WriteLn && params)
        {
          tree t = tree_last (params), v = TREE_VALUE (t);
          if (!TREE_PURPOSE (t) && IS_STRING_CST (v))
            {
              TREE_VALUE (t) = combine_strings (tree_cons (NULL_TREE, char_may_be_string (v),
                build_tree_list (NULL_TREE, build_string_constant ("\n", 1, 0))), 3);
              r_num = p_Write;
            }
        }
      if (params && PASCAL_TYPE_FILE (TREE_TYPE (TREE_VALUE (params))))
        {
          if (TREE_PURPOSE (params))
            error ("spurious field width specification in target file to `%s'", r_name);
          file = TREE_VALUE (params);
          params = TREE_CHAIN (params);
        }
      else
        file = get_standard_output ();
      if (PASCAL_TYPE_ANYFILE (TREE_TYPE (file)))
        {
          error ("`%s' cannot be used with files of type `AnyFile'", r_name);
          return error_mark_node;
        }
      if (r_num == p_Write && !params)
        {
          error_or_warning (co->pascal_dialect & C_E_O_PASCAL, "`Write' without values to write -- ignored");
          return NULL_TREE;
        }
      if (!PASCAL_TYPE_TEXT_FILE (TREE_TYPE (file)))
        {
          /* Writing to a typed file */
          if (r_num != p_Write)
            {
              error ("`%s' is allowed only when writing to files of type `Text'", r_name);
              return error_mark_node;
            }
          for (parm = params; parm; parm = TREE_CHAIN (parm))
            {
              expand_pascal_assignment (build_buffer_ref (file, p_LazyUnget),
                string_may_be_char (undo_schema_dereference (TREE_VALUE (parm)), 1));
              build_predef_call (p_Put, build_tree_list (NULL_TREE, file));
            }
          return NULL_TREE;
        }
      build_predef_call (p_Write_Init, tree_cons (NULL_TREE, file, build_tree_list (NULL_TREE, build_int_2 (flags, 0))));
    }
  if (params && r_num != p_FormatString && r_num != p_StringOf)
    {
      for (parm = params; TREE_CHAIN (parm); )
        if (IS_STRING_CST (TREE_VALUE (parm)) && IS_STRING_CST (TREE_VALUE (TREE_CHAIN (parm)))
            && !TREE_PURPOSE (parm) && !TREE_PURPOSE (TREE_CHAIN (parm)))
          {
            TREE_VALUE (parm) = combine_strings (tree_cons (NULL_TREE, char_may_be_string (TREE_VALUE (parm)),
              build_tree_list (NULL_TREE, char_may_be_string (TREE_VALUE (TREE_CHAIN (parm))))), 3);
            TREE_CHAIN (parm) = TREE_CHAIN (TREE_CHAIN (parm));
          }
        else
          parm = TREE_CHAIN (parm);
    }
  for (parm = params; parm; parm = TREE_CHAIN (parm))
    {
      int use_write_width_index = -1, r_num2 = -1;
      tree length = NULL_TREE, field1 = NULL_TREE, field2 = NULL_TREE, args = NULL_TREE;
      tree p = string_may_be_char (TREE_VALUE (parm), 0), type = TREE_TYPE (p);
      enum tree_code code = TREE_CODE (type);
      STRIP_TYPE_NOPS (p);
      if (TREE_PURPOSE (parm))
        {
          field1 = TREE_VALUE (TREE_PURPOSE (parm));
          field2 = TREE_PURPOSE (TREE_PURPOSE (parm));
          if (field1)
            STRIP_TYPE_NOPS (field1);
          if (field2)
            STRIP_TYPE_NOPS (field2);
          if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (field1))
              || (field2 && !TYPE_IS_INTEGER_TYPE (TREE_TYPE (field2))))
            {
              error ("field width and precision must be of integer type");
              field1 = NULL_TREE;
              field2 = NULL_TREE;
            }
          if (flags & NEG_ZERO_WIDTH_ERROR_MASK)
            {
              if (field1 && TREE_CODE (field1) == INTEGER_CST && !const_lt (integer_zero_node, field1))
                error ("fixed field width must be positive");
              if (field2 && TREE_CODE (field2) == INTEGER_CST && !const_lt (integer_zero_node, field2))
                error ("fixed real fraction field width must be positive");
            }
          else if (flags & NEG_WIDTH_ERROR_MASK)
            {
              if (field1 && const_lt (field1, integer_zero_node))
                error ("fixed field width cannot be negative");
              if (field2 && const_lt (field2, integer_zero_node))
                error ("fixed real fraction field width cannot be negative");
            }
        }
      if (field2 && code != REAL_TYPE)
        error ("number of fractional digits allowed only when writing values of real type");
      if (r_num == p_Str && !TYPE_IS_INTEGER_TYPE (type) && code != REAL_TYPE)
        chk_dialect_1 ("`%s' with non-numeric values is", GNU_PASCAL, r_name);
      switch (code)
      {
        case ERROR_MARK:
          return error_mark_node;
#ifndef GCC_4_2
        case CHAR_TYPE:
          r_num2 = p_Write_Char;
          break;
#endif
        case INTEGER_TYPE:
          if (TYPE_IS_CHAR_TYPE (type))
            {
              r_num2 = p_Write_Char;
              break;
            }
          if (TREE_CODE (p) == INTEGER_CST)
            {
              if (int_fits_type_p (p, pascal_integer_type_node))
                p = convert (pascal_integer_type_node, p);
              else if (int_fits_type_p (p, pascal_cardinal_type_node))
                p = convert (pascal_cardinal_type_node, p);
            }
          r_num2 = (TYPE_PRECISION (TREE_TYPE (p)) > TYPE_PRECISION (pascal_integer_type_node))
            ? (TYPE_UNSIGNED (TREE_TYPE (p)) ? p_Write_LongCard : p_Write_LongInt)
            : (TYPE_UNSIGNED (TREE_TYPE (p)) ? p_Write_Cardinal : p_Write_Integer);
          use_write_width_index = (r_num2 == p_Write_LongInt || r_num2 == p_Write_LongCard) ? 3 : 0;
          break;
        case REAL_TYPE:
          use_write_width_index =
            (TYPE_MAIN_VARIANT (type) == long_double_type_node
             || TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node)) ? 4 : 1;
          r_num2 = p_Write_Real;
          args = build_tree_list (NULL_TREE, field2 ? field2 : TYPE_MIN_VALUE (pascal_integer_type_node));
          break;
        case BOOLEAN_TYPE:
          use_write_width_index = 2;
          r_num2 = p_Write_Boolean;
          break;
        case RECORD_TYPE:
        case ARRAY_TYPE:
        case POINTER_TYPE:
          if ((length = string_par (&p)))
            r_num2 = p_Write_String;
          break;
        default:
          break;
      }
      if (r_num2 < 0)
        {
          error ("argument to `%s' is of wrong type", r_name);
          if (TYPE_MAIN_VARIANT (type) == cstring_type_node)
            cstring_inform ();
          continue;
        }
      if (!field1 && use_write_width_index >= 0 && co->write_width[use_write_width_index])
        field1 = build_int_2 (co->write_width[use_write_width_index], 0);
      args = tree_cons (NULL_TREE, field1 ? field1 : TYPE_MIN_VALUE (pascal_integer_type_node), args);
      if (length)
        args = tree_cons (NULL_TREE, length, args);

      if (parm != params
          && (TREE_SIDE_EFFECTS (p)
              || (field1 && TREE_SIDE_EFFECTS (field1))
              || (field2 && TREE_SIDE_EFFECTS (field2)))
          && (r_num == p_Write || r_num == p_WriteLn))
        {
          build_predef_call (p_Write_Flush, build_tree_list (NULL_TREE, file));
          build_predef_call (p_Write_Init, tree_cons (NULL_TREE, file, build_tree_list (NULL_TREE, build_int_2 (flags, 0))));
        }

      expand_expr_stmt (build_predef_call (r_num2, tree_cons (NULL_TREE, file, tree_cons (NULL_TREE, p, args))));
    }
  if (r_num == p_FormatString)
    {
      tree res1 = save_expr (build_predef_call (p_FormatString_Result,
        tree_cons (NULL_TREE, file, build_tree_list (NULL_TREE, format_string))));
      return non_lvalue (new_string_by_model (NULL_TREE,
        build1 (INDIRECT_REF, TREE_TYPE (TREE_TYPE (res1)), res1), 1));
    }
  else if (r_num == p_StringOf)
    {
      tree res1 = save_expr (build_predef_call (p_StringOf_Result,
        build_tree_list (NULL_TREE, file)));
      return non_lvalue (new_string_by_model (NULL_TREE,
        build1 (INDIRECT_REF, TREE_TYPE (TREE_TYPE (res1)), res1), 1));
    }
  else if (r_num == p_WriteStr || r_num == p_Str)
    {
      tree length = build_predef_call (p_WriteStr_GetLength, build_tree_list (NULL_TREE, file));
      if (string_length)
        expand_expr_stmt (build_modify_expr (string_length, NOP_EXPR, length));
      else
        expand_expr_stmt (length);
    }
  else
    {
      if (r_num == p_WriteLn)
        build_predef_call (p_Write_Line, build_tree_list (NULL_TREE, file));
      build_predef_call (p_Write_Flush, build_tree_list (NULL_TREE, file));
      if (co->io_checking)
        expand_expr_stmt (convert (void_type_node, build_iocheck ()));
    }
  return NULL_TREE;
}

/* Pascal `Pack' and `Unpack' transfer procedures. */
static tree
pascal_unpack_and_pack (int unpack_flag, tree unpacked, tree packed, tree ustart, const char *name)
{
  int is_string = 0;
  tree schema_check, utype = TREE_TYPE (unpacked), ptype = TREE_TYPE (packed), len0, len, bits;
  tree cutype = TREE_TYPE (utype), cptype = TREE_TYPE (ptype);
  CHK_EM (unpacked);
  CHK_EM (packed);

  schema_check = check_discriminants (
    build_array_ref (unpacked, TYPE_MIN_VALUE (TYPE_DOMAIN (utype))),
    build_array_ref (packed, TYPE_MIN_VALUE (TYPE_DOMAIN (ptype))));
  if (!EM (schema_check))
    expand_expr_stmt (convert (void_type_node, schema_check));
  else if (!strictly_comp_types (cutype, cptype))
    {
      if ((TYPE_IS_CHAR_TYPE (cutype) || is_of_string_type (cutype, 0)) &&
          (TYPE_IS_CHAR_TYPE (cptype) || is_of_string_type (cptype, 0)))
        is_string = 1;
      else
        {
          error ("source and destination arrays in `%s' must be of the same type", name);
          return error_mark_node;
        }
    }

  /* Length to copy is the length of the packed array */
  len0 = build_pascal_binary_op (MINUS_EXPR,
          convert (pascal_integer_type_node, TYPE_MAX_VALUE (TYPE_DOMAIN (ptype))),
          convert (pascal_integer_type_node, TYPE_MIN_VALUE (TYPE_DOMAIN (ptype))));
  len = build_pascal_binary_op (PLUS_EXPR, len0, integer_one_node);

  ustart = range_check_2 (TYPE_MIN_VALUE (TYPE_DOMAIN (utype)),
    convert_and_check (base_type (TYPE_DOMAIN (utype)), build_pascal_binary_op (MINUS_EXPR,
    TYPE_MAX_VALUE (TYPE_DOMAIN (utype)), len0)), ustart);
  CHK_EM (ustart);

  bits = count_bits (cptype, NULL);
  if (is_string || (bits && TREE_INT_CST_LOW (bits) != TREE_INT_CST_LOW (TYPE_SIZE (cptype))))
    {
      /* Construct a loop like ISO wants (abbreviated):
         j := Low (packed);
         k := ustart;
         repeat
           if unpack_flag then
             unpacked[k] := packed[j]
           else
             packed[j] := unpacked[k];
           if j < High (packed) then
             begin
               Inc (j);
               Inc (k)
             end
         until j >= High (packed); */
      tree j = make_new_variable ("pack", TREE_TYPE (TYPE_DOMAIN (ptype)));
      tree k = make_new_variable ("pack", TREE_TYPE (TYPE_DOMAIN (utype)));
      tree condition, packed_j, unpacked_k;
      tree j_as_integer = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (j)), TYPE_UNSIGNED (TREE_TYPE (j))), j);
      tree k_as_integer = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (k)), TYPE_UNSIGNED (TREE_TYPE (k))), k);
      expand_expr_stmt (build_modify_expr (j, NOP_EXPR, TYPE_MIN_VALUE (TYPE_DOMAIN (ptype))));
      expand_expr_stmt (build_modify_expr (k, NOP_EXPR, convert (TREE_TYPE (k), ustart)));
      expand_start_loop (1);
      unpacked_k = build_pascal_array_ref (unpacked, build_tree_list (NULL_TREE, k));
      packed_j = build_pascal_array_ref (packed, build_tree_list (NULL_TREE, j));
      if (unpack_flag)
        expand_expr_stmt (build_modify_expr (unpacked_k, NOP_EXPR, packed_j));
      else
        expand_expr_stmt (build_modify_expr (packed_j, NOP_EXPR, unpacked_k));
      condition = build_pascal_binary_op (LT_EXPR, j, TYPE_MAX_VALUE (TYPE_DOMAIN (ptype)));
      expand_exit_loop_if_false (0, condition);
      expand_expr_stmt (build_modify_expr (j_as_integer, PLUS_EXPR, integer_one_node));
      expand_expr_stmt (build_modify_expr (k_as_integer, PLUS_EXPR, integer_one_node));
      expand_end_loop ();
      return error_mark_node;  /* nothing to expand anymore */
    }
  else
    {
      /* Not really packed; elements have same size. Just copy the memory. */
      tree length = fold (build2 (MULT_EXPR, pascal_integer_type_node,
             convert (pascal_integer_type_node, size_in_bytes (cutype)), len));
      tree adr_u = build_unary_op (ADDR_EXPR, build_array_ref (unpacked, ustart), 0);
      tree adr_p = build_unary_op (ADDR_EXPR, packed, 0);
      if (unpack_flag)
        return build_memcpy (adr_u, adr_p, length);
      else
        return build_memcpy (adr_p, adr_u, length);
    }
}

static tree
check_argument (tree arg, const char *r_name, int n, const char **pargtypes, tree *ptype, enum tree_code *pcode)
{
  const char *errstr = NULL;
  enum tree_code code;
  tree type, val = TREE_VALUE (arg);
  int assignment_compatibility = 0;

  /* @@ quite kludgy */
  char argtype_lower, argtype_lower_orig, argtype = *((*pargtypes)++);
  if (argtype == ',') argtype = *((*pargtypes)++);
  if (!argtype || argtype == '|') (*pargtypes)--, argtype = 'x';
  if (argtype == '&')  /* `Pack' and `Unpack' require only assignment-compatibility
                          (like normal routines, but unlike other predefined ones) */
    {
      assignment_compatibility = 1;
      argtype = 'u';
    }
  argtype_lower = TOLOWER ((unsigned char) argtype);
  switch (argtype_lower)
  {
    case 'c':
    case 'u':
    case 'v':
    case 'w':
      val = string_may_be_char (val, assignment_compatibility);
      break;
  }

  if (TREE_CODE (val) == TYPE_DECL && argtype_lower != '#' && argtype_lower != '^')
    {
      error ("parameter expected -- type name given");
      val = error_mark_node;
    }

  type = TREE_TYPE (val);
  if (EM (val) || !type)
    return error_mark_node;
  code = TREE_CODE (type);
  if (code == FUNCTION_TYPE)
    {
      /* This is a function without parameters. Call it. */
      val = probably_call_function (val);
      type = TREE_TYPE (val);
      code = TREE_CODE (type);
    }
  CHK_EM (type);
  argtype_lower_orig = argtype_lower;
  if (argtype_lower == 'v' && !co->pointer_arithmetic)
    argtype_lower = 'w';
  switch (argtype_lower)
  {
    case 'i': case 'l': case 'h': case 'n':
      if (!TYPE_IS_INTEGER_TYPE (type))
        errstr = "argument %d to `%s' must be an integer";
      break;
    case 'r': case 'e':
      if (!INT_REAL (type))
        errstr = "argument %d to `%s' must be a real or an integer";
      break;
    case 'z': 
      if (!IS_NUMERIC (type))
        errstr = "argument %d to `%s' must be an integer, real"
                 "or complex number";
      break;
    case 'b': if (code != BOOLEAN_TYPE)                                 errstr = "argument %d to `%s' must be a Boolean"; break;
    case 'c':
      if (!TYPE_IS_CHAR_TYPE (type))
        errstr = "argument %d to `%s' must be a char";
      break;
    case 's': if (!is_string_compatible_type (val, 1))                  errstr = "argument %d to `%s' must be a string or char"; break;
    case 'q': if (!(code == POINTER_TYPE && integer_zerop (val)) && TYPE_MAIN_VARIANT (type) != cstring_type_node && !is_string_compatible_type (val, 1))
                                                                        errstr = "argument %d to `%s' must be a `CString' (`PChar')"; break;
    case 'p': case '^': if (code != POINTER_TYPE)                       errstr = "argument %d to `%s' must be a pointer"; break;
    case 'y': if (code != POINTER_TYPE && code != REFERENCE_TYPE)       errstr = "argument %d to `%s' must be of pointer or procedural type"; break;
    case 'f': case '@': if (!PASCAL_TYPE_FILE (type))                   errstr = "argument %d to `%s' must be a file"; break;
    case 'j': if (!PASCAL_TYPE_TEXT_FILE (type))                        errstr = "argument %d to `%s' must be a `Text' file"; break;
    case 'k': if (!PASCAL_TYPE_FILE (type) || TREE_CODE (TREE_TYPE (type)) != VOID_TYPE)
                                                                        errstr = "argument %d to `%s' must be an untyped file"; break;
    case 'm': if (code != SET_TYPE)                                     errstr = "argument %d to `%s' must be a set"; break;
    case 'o': if (!PASCAL_TYPE_OBJECT (type))                           errstr = "argument %d to `%s' must be of object type"; break;
    case 'u': if (!ORDINAL_TYPE (code))                                 errstr = "argument %d to `%s' must be of ordinal type"; break;
    case 'v': if (!ORDINAL_OR_REAL_TYPE (code) && code != POINTER_TYPE) errstr = "argument %d to `%s' must be of ordinal, real or pointer type"; break;
    case 'w': if (!ORDINAL_OR_REAL_TYPE (code))                         errstr = "argument %d to `%s' must be of ordinal or real type"; break;
    case 't': if (TYPE_MAIN_VARIANT (type) != gpc_type_TimeStamp)       errstr = "argument %d to `%s' must be of type `TimeStamp'"; break;
    case 'a': if (TYPE_MAIN_VARIANT (type) != gpc_type_BindingType)     errstr = "argument %d to `%s' must be of type `BindingType'"; break;
    case 'x': break;  /* Untyped parameter */
    case '#': if (TREE_CONSTANT (val)
                  && ((TREE_CODE (val) != CONSTRUCTOR
                       && TREE_CODE (val) != PASCAL_SET_CONSTRUCTOR)
                      || type == empty_set_type_node))
                {
                  error ("`%s' applied to a constant", r_name);
                  return error_mark_node;
                }
              break;  /* expression or type allowed */
    default: gcc_unreachable ();
  }
  if (ISUPPER ((unsigned char) argtype))
    {
      if (argtype == 'S' && !PASCAL_TYPE_STRING (type))
        errstr = "argument %d to `%s' must be a string schema";
      else if (!check_reference_parameter (val, 0))
        return error_mark_node;
    }
  if (errstr)
    {
      error (errstr, n, r_name);
      if (argtype_lower_orig == 'v' && code == POINTER_TYPE)
        ptrarith_inform ();
      return error_mark_node;
    }
  TREE_VALUE (arg) = val;
  *ptype = type;
  *pcode = code;
  return val;
}

/* This routine resolves predefined routines and similar things. If necessary,
   it constructs RTS calls with correct arguments. `r_num' is the id of the
   predefined thing. `apar' is a TREE_LIST chain of arguments; args are in the
   TREE_VALUE field. If there is something in the TREE_PURPOSE field, it is a
   TREE_LIST node of write output field length expressions, the first expression
   in TREE_VALUE and the second one in TREE_PURPOSE, for
   `actual_parameter : expression : expression'. */
tree
build_predef_call (int r_num, tree apar)
{
  tree val = NULL_TREE, val2 = NULL_TREE, val3 = NULL_TREE, val4 = NULL_TREE;
  tree type = NULL_TREE, type2 = NULL_TREE, type3 = NULL_TREE, type4 = NULL_TREE;
  tree retval = NULL_TREE, fun;
  tree convert_result = NULL_TREE;  /* type to convert the result to */
  tree post_statement = NULL_TREE;  /* statement to be executed after calling the RTS procedure */
  tree actual_result = NULL_TREE;  /* value to return for a procedure call if any */
  int argcount, swapargs = 0, invert_result = 0, minarg, maxarg, i, procflag, orig_p_id = r_num;
  enum tree_code code = ERROR_MARK, code2 = ERROR_MARK, code3 = ERROR_MARK, code4 = ERROR_MARK;
  const char *errstr = NULL, *r_name = NULL, *signature = NULL, *tmpsig;

  /* We must check the dialect before r_num may be changed. */
  for (i = 0; i < (int) ARRAY_SIZE (predef_table) && (predef_table[i].symbol != r_num || predef_table[i].kind == bk_keyword); i++) ;
  gcc_assert (i < (int) ARRAY_SIZE (predef_table));
  r_name = predef_table[i].idname;
  if (!r_name) r_name = predef_table[i].alias_name;
  gcc_assert (r_name);
#if 0
  chk_dialect_name (r_name, predef_table[i].dialect);
#endif

  if (r_num == p_Exit && apar)
    {
      tree id = TREE_VALUE (apar);
      tree obn = TREE_PURPOSE (apar);
      apar = NULL_TREE;
      if (obn)
        chk_dialect ("`Exit' with a qualified identifier as an argument is", 
                     GNU_PASCAL);
      else
        chk_dialect ("`Exit' with an argument is", U_M_PASCAL);
      if (id == void_type_node || (current_module->main_program && id == current_module->name))
        r_num = p_Halt;
      else if (!(current_function_decl && !obn
                 && id == DECL_NAME (current_function_decl)))
        {
          struct function *p = outer_function_chain;
          while (p)
            {
              if (!obn && DECL_NAME (p->decl) == id)
                break;
              if (PASCAL_METHOD (p->decl))
                {
                  tree ot = DECL_CONTEXT (p->decl);
                  tree on, mn;
                  gcc_assert (ot && PASCAL_TYPE_OBJECT (ot));
                  if (TYPE_POINTER_TO (ot) &&
                      PASCAL_TYPE_CLASS (TYPE_POINTER_TO (ot)))
                    ot = TYPE_POINTER_TO (ot);
                  on = DECL_NAME (TYPE_NAME (TYPE_MAIN_VARIANT (ot)));
                  if (obn && on != obn)
                    continue;
                  mn = get_method_name (on, id);
                  if (mn == DECL_NAME (p->decl))
                    break;
                } 
#ifdef EGCS97
              p = p->outer;
#else
              p = p->next;
#endif
            }
          if (!p)
            error ("invalid argument `%s' to `Exit'", IDENTIFIER_NAME (id));
          else if (DECL_LANG_SPECIFIC (p->decl) && DECL_LANG_NONLOCAL_EXIT_LABEL (p->decl))
            pascal_expand_goto (DECL_LANG_NONLOCAL_EXIT_LABEL (p->decl));
          else
            error ("`%s' does not allow non-local `Exit'", IDENTIFIER_NAME (id));
          return error_mark_node;
        }
    }

  for (val = apar; val; val = TREE_CHAIN (val))
    {
      CHK_EM (val);
      CHK_EM (TREE_VALUE (val));
      if (TREE_CODE (TREE_VALUE (val)) != TYPE_DECL)
        DEREFERENCE_SCHEMA (TREE_VALUE (val));
    }

  argcount = list_length (apar);
  if (argcount >= 1)
    {
      type = TREE_TYPE (TREE_VALUE (apar));
      code = TREE_CODE (type);
    }

  /* Resolve built-in overloading here. Afterwards r_num must not change. */
  switch (r_num)
  {
    case p_UpCase:
      if (co->pascal_dialect & B_D_M_PASCAL)
        r_num = p_BP_UpCase;
      break;

    case p_Random:
      if (argcount == 0)
        r_num = p_RandReal;
      break;

    case p_Abs:
      if (code == COMPLEX_TYPE)
        r_num = p_Complex_Abs;
      break;

    case p_SqRt:
    case p_Sin:
    case p_Cos:
    case p_Exp:
    case p_Ln:
    case p_ArcSin:
    case p_ArcCos:
    case p_ArcTan:
      if (code == COMPLEX_TYPE)
        switch (r_num)
        {
          case p_SqRt:   r_num = p_Complex_SqRt;   break;
          case p_Sin:    r_num = p_Complex_Sin;    break;
          case p_Cos:    r_num = p_Complex_Cos;    break;
          case p_Exp:    r_num = p_Complex_Exp;    break;
          case p_Ln:     r_num = p_Complex_Ln;     break;
          case p_ArcSin: r_num = p_Complex_ArcSin; break;
          case p_ArcCos: r_num = p_Complex_ArcCos; break;
          case p_ArcTan: r_num = p_Complex_ArcTan; break;
          default:       gcc_unreachable ();
        }
      else if (code == REAL_TYPE && TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node))
        switch (r_num)
        {
          case p_SqRt:   r_num = p_LongReal_SqRt;   break;
          case p_Sin:    r_num = p_LongReal_Sin;    break;
          case p_Cos:    r_num = p_LongReal_Cos;    break;
          case p_Exp:    r_num = p_LongReal_Exp;    break;
          case p_Ln:     r_num = p_LongReal_Ln;     break;
          case p_ArcSin: r_num = p_LongReal_ArcSin; break;
          case p_ArcCos: r_num = p_LongReal_ArcCos; break;
          case p_ArcTan: r_num = p_LongReal_ArcTan; break;
          default:       gcc_unreachable ();
        }
      break;

    case LEX_POWER:
      if (code == COMPLEX_TYPE)
        r_num = p_Complex_Power;
      else if (argcount >= 2  /* otherwise error given below, don't crash here */
               && ((TREE_CODE (type) == REAL_TYPE
                    && TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node))
                   || (TREE_CODE (TREE_TYPE (TREE_VALUE (TREE_CHAIN (apar)))) == REAL_TYPE
                       && TYPE_PRECISION (TREE_TYPE (TREE_VALUE (TREE_CHAIN (apar))))
                          > TYPE_PRECISION (double_type_node))))
        r_num = p_LongReal_Power;
      break;

    case p_pow:
      if (TYPE_IS_INTEGER_TYPE (type))
        r_num = p_Integer_Pow;
      else if (code == COMPLEX_TYPE)
        r_num = p_Complex_Pow;
      else if (TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node))
        r_num = p_LongReal_Pow;
      break;

    case p_Set_Copy:
      if (TREE_TYPE (TREE_VALUE (TREE_CHAIN (apar))) == empty_set_type_node)
        {
          r_num = p_Set_Clear;
          argcount = 1;
        }
      break;

    case p_Index:
      /* Same as p_Pos, but swap the first two arguments. */
      if (argcount >= 2)
        {
          val = TREE_VALUE (apar);
          TREE_VALUE (apar) = TREE_VALUE (TREE_CHAIN (apar));
          TREE_VALUE (TREE_CHAIN (apar)) = val;
        }
    case p_Pos:
      /* optimize a common case */
      if (argcount >= 1)
        {
          TREE_VALUE (apar) = string_may_be_char (TREE_VALUE (apar), 0);
          if (TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_VALUE (apar))))
            r_num = p_PosChar;
        }
      break;

    /* String comparisons */
    case p_EQ:
    case p_NE:
    case p_LT:
    case p_LE:
    case p_GT:
    case p_GE:
    case p_EQPad:
    case p_NEPad:
    case p_LTPad:
    case p_LEPad:
    case p_GTPad:
    case p_GEPad:
    case '=':
    case LEX_NE:
    case '<':
    case LEX_LE:
    case '>':
    case LEX_GE:
      /* First, reduce the number of operators from 12 to 4 :-) */
      switch (r_num)
      {
        case p_NE:    r_num = p_EQ;                  invert_result = 1; break;
        case p_GT:    r_num = p_LT;    swapargs = 1;                    break;
        case p_GE:    r_num = p_LT;                  invert_result = 1; break;
        case p_LE:    r_num = p_LT;    swapargs = 1; invert_result = 1; break;
        case p_NEPad: r_num = p_EQPad;               invert_result = 1; break;
        case p_GTPad: r_num = p_LTPad; swapargs = 1;                    break;
        case p_GEPad: r_num = p_LTPad;               invert_result = 1; break;
        case p_LEPad: r_num = p_LTPad; swapargs = 1; invert_result = 1; break;
        case LEX_NE:  r_num = '=';                   invert_result = 1; break;
        case '>':     r_num = '<';     swapargs = 1;                    break;
        case LEX_GE:  r_num = '<';                   invert_result = 1; break;
        case LEX_LE:  r_num = '<';     swapargs = 1; invert_result = 1; break;
        default: /* nothing */;
      }
      /* If co->exact_compare_strings is nonzero, `=' etc. comparisons are never padded with spaces */
      if (co->exact_compare_strings)
        {
          if (r_num == '=')
            r_num = p_EQ;
          else if (r_num == '<')
            r_num = p_LT;
        }
      /* The `...Pad' functions always pad with spaces. */
      if (r_num == p_EQPad)
        r_num = '=';
      else if (r_num == p_LTPad)
        r_num = '<';
  }

  if (r_num != orig_p_id)
    for (i = 0; i < (int) ARRAY_SIZE (predef_table) && (predef_table[i].symbol != r_num || predef_table[i].kind == bk_keyword); i++) ;
  gcc_assert (i < (int) ARRAY_SIZE (predef_table));
  fun = predef_table[i].decl;
  signature = predef_table[i].signature;
  gcc_assert (signature);
  tmpsig = signature + 1;
  while (*tmpsig && *tmpsig != '|' && *tmpsig != ',') tmpsig++;
  minarg = tmpsig - (signature + 1);
  if (!*tmpsig || *tmpsig == '|')
    maxarg = minarg;
  else if (*++tmpsig && *tmpsig != '|')
    {
      while (*tmpsig && *tmpsig != '|') tmpsig++;
      maxarg = tmpsig - (signature + 2);
    }
  else
    maxarg = -1;
  if (argcount < minarg)
    errstr = "too few arguments to `%s'";
  else if (maxarg >= 0 && argcount > maxarg)
    errstr = "too many arguments to `%s'";
  /* @@ should be generalized for n arguments */
  tmpsig = signature + 1;
  if (argcount >= 1)
    {
      val = check_argument (apar, r_name, 1, &tmpsig, &type, &code);
      CHK_EM (val);
    }
  if (!(r_num == p_New && PASCAL_TYPE_OBJECT (TREE_TYPE (type))))
    {
      if (argcount >= 2)
        {
          val2 = check_argument (TREE_CHAIN (apar), r_name, 2, &tmpsig, &type2, &code2);
          CHK_EM (val2);
        }
      if (argcount >= 3)
        {
          val3 = check_argument (TREE_CHAIN (TREE_CHAIN (apar)), r_name, 3, &tmpsig, &type3, &code3);
          CHK_EM (val3);
        }
      if (argcount >= 4)
        {
          val4 = check_argument (TREE_CHAIN (TREE_CHAIN (TREE_CHAIN (apar))), r_name, 4, &tmpsig, &type4, &code4);
          CHK_EM (val4);
        }
    }

  procflag = *signature == '!' || *signature == '>' || *signature == '-';

  if (!errstr) switch (r_num)
  {

  case p_Break:
  case p_Leave:
    if (!expand_exit_loop (NULL))
      error ("`%s' statement not within a loop", r_name);
    return NULL_TREE;

  case p_Continue:
  case p_Cycle:
    if (!expand_continue_loop (NULL))
      error ("`%s' statement not within a loop", r_name);
    return NULL_TREE;

  case p_Exit:
    expand_return_statement (DECL_LANG_RESULT_VARIABLE (current_function_decl));
    return NULL_TREE;

  case p_Return:
    if (argcount == 0)
      expand_return_statement (NULL_TREE);
    else
      {
        tree resvar = DECL_LANG_RESULT_VARIABLE (current_function_decl);
        if (!resvar)
          error ("`%s' with a value in a procedure", r_name);
        else
          {
            expand_pascal_assignment (resvar, val);
            expand_return_statement (resvar);
          }
      }
    return NULL_TREE;

  case p_Fail:
    /* Check whether we are inside a constructor. `Fail' cannot be
       called from a subroutine of a constructor (BP compatible). */
    if (!PASCAL_CONSTRUCTOR_METHOD (current_function_decl))
      error ("`Fail' called from outside a constructor");
    else
      {
        PASCAL_VALUE_ASSIGNED (DECL_LANG_RESULT_VARIABLE (current_function_decl)) = 1;
        expand_return_statement (boolean_false_node);
      }
    return NULL_TREE;

  case p_Card:
    if (TREE_CODE (val) == PASCAL_SET_CONSTRUCTOR 
        && PASCAL_CONSTRUCTOR_INT_CST (val))
      {
        tree e;
        retval = integer_zero_node;
        for (e = SET_CONSTRUCTOR_ELTS (val); e; e = TREE_CHAIN (e))
          {
            tree l = TREE_PURPOSE (e), u = TREE_VALUE (e);
            gcc_assert (TREE_CODE (l) == INTEGER_CST && TREE_CODE (u) == INTEGER_CST);
            retval = build_pascal_binary_op (PLUS_EXPR, retval,
              build_pascal_binary_op (PLUS_EXPR,
                convert (long_long_integer_type_node,
                  build_pascal_binary_op (MINUS_EXPR, u, l)), integer_one_node));
          }
        gcc_assert (TREE_CODE (retval) == INTEGER_CST);
        break;
      }
    if (TREE_CODE (val) == PASCAL_SET_CONSTRUCTOR
        && TREE_CODE (TREE_TYPE (val)) == SET_TYPE)
      {
        val = construct_set (val, NULL_TREE, 1);
        CHK_EM (val);
      }
    gcc_assert (TREE_TYPE (val) != empty_set_type_node);
    apar = actual_set_parameters (val, 0);
    break;

  case p_Sqr:
    if (TREE_SIDE_EFFECTS (val))
      val = save_expr (val);
    retval = build_pascal_binary_op (MULT_EXPR, val, val);
    break;

  case p_Trunc:
  case p_Round:
    if (TYPE_IS_INTEGER_TYPE (type))
      {
        if (co->pascal_dialect & C_E_O_PASCAL)
          error ("argument to `%s' must be of real type", r_name);
        else
          gpc_warning ("`%s' applied to integers has no effect", r_name);
        retval = val;
      }
    else
      {
        if (r_num == p_Round)
          {
            /* ISO Pascal: Round (x) := Trunc (x >= 0.0 ? x + 0.5 : x - 0.5); */
            tree t = TYPE_PRECISION (type) > TYPE_PRECISION (double_type_node)
                     ? long_double_type_node : double_type_node;
            val = save_expr (val);
            val = build3 (COND_EXPR, t,
                         build_pascal_binary_op (GE_EXPR, val, real_zero_node),
                         convert (t, build_pascal_binary_op (PLUS_EXPR, val, real_half_node)),
                         convert (t, build_pascal_binary_op (MINUS_EXPR, val, real_half_node)));
          }
        retval = convert (long_long_integer_type_node, val);
      }
    break;

  case p_Succ:
  case p_Pred:
  case p_Inc:
  case p_Dec:
    if (code == REAL_TYPE)
      {
        chk_dialect_1 ("`%s' applied to real numbers is", GNU_PASCAL, r_name);
        if (argcount == 1)
          error ("`%s' applied to real numbers requires a second argument", r_name);
      }
    else if (code2 == REAL_TYPE)
      error ("argument 2 of `%s' must be of integer type", r_name);
    if (argcount == 1)
      val2 = integer_one_node;
    if (r_num == p_Succ || r_num == p_Pred)
      {
        if (argcount != 1)
          chk_dialect_1 ("`%s' with two arguments is", E_O_PASCAL, r_name);
        retval = convert_and_check (base_type (type), build_pascal_binary_op ((r_num == p_Succ) ? PLUS_EXPR : MINUS_EXPR, val, val2));
      }
    else
      retval = build_modify_expr (val, (r_num == p_Inc) ? PLUS_EXPR : MINUS_EXPR, val2);
    break;

  case p_FillChar:
    if (!TYPE_IS_CHAR_TYPE (type3))
      chk_dialect_1 ("non-`Char' values for argument 3 to `%s' are", B_D_M_PASCAL, r_name);
    retval = build_memset (build_unary_op (ADDR_EXPR, undo_schema_dereference (val), 0),
      val2, convert_and_check (byte_unsigned_type_node, val3));
    break;

  case p_Move:
  case p_MoveLeft:
  case p_MoveRight:
    TREE_VALUE (apar) = build_unary_op (ADDR_EXPR, undo_schema_dereference (val), 0);
    TREE_VALUE (TREE_CHAIN (apar)) = build_unary_op (ADDR_EXPR, undo_schema_dereference (val2), 0);
    break;

  case p_BlockRead:
  case p_BlockWrite:
    if (argcount == 3)
      apar = chainon (apar, build_tree_list (NULL_TREE, null_pseudo_const_node));
    else if (TREE_TYPE (val4) != pascal_cardinal_type_node)
      {
        tree result_tmpvar = make_new_variable ("blockread_write_result", pascal_cardinal_type_node);
        TREE_VALUE (TREE_CHAIN (TREE_CHAIN (TREE_CHAIN (apar)))) = result_tmpvar;
        post_statement = build_modify_expr (val4, NOP_EXPR, result_tmpvar);
      }
    TREE_VALUE (TREE_CHAIN (apar)) = build_unary_op (ADDR_EXPR, undo_schema_dereference (val2), 0);
    TREE_CHAIN (apar) = tree_cons (NULL_TREE,
      PASCAL_TYPE_ANYFILE (type) ? boolean_true_node : boolean_false_node, TREE_CHAIN (apar));
    break;

  case p_Concat:
    {
      tree arg;
      if (argcount == 1)
        gpc_warning ("`%s' with only one argument has no effect", r_name);
      for (arg = apar; arg; arg = TREE_CHAIN (arg))
        if (!is_string_compatible_type (TREE_VALUE (arg), 1))
          errstr = "arguments to `%s' must be strings or chars";
      retval = val;
      if (!errstr)
        for (arg = TREE_CHAIN (apar); arg; arg = TREE_CHAIN (arg))
          retval = build_pascal_binary_op (PLUS_EXPR, retval, TREE_VALUE (arg));
      break;
    }

  case p_not:
    chk_dialect_1 ("procedure-like use of `%s' is", GNU_PASCAL, r_name);
    retval = build_modify_expr (val, NOP_EXPR, build_pascal_unary_op (BIT_NOT_EXPR, val));
    break;

  case p_and:
  case p_or:
  case p_xor:
  case p_shl:
  case p_shr:
    {
      enum tree_code bitopcode = 0;
      switch (r_num)
      {
        case p_and: bitopcode = BIT_AND_EXPR; break;
        case p_or:  bitopcode = BIT_IOR_EXPR; break;
        case p_xor: bitopcode = BIT_XOR_EXPR; break;
        case p_shl: bitopcode = LSHIFT_EXPR;  break;
        case p_shr: bitopcode = RSHIFT_EXPR;  break;
      }
      chk_dialect_1 ("procedure-like use of `%s' is", GNU_PASCAL, r_name);
      retval = build_modify_expr (val, bitopcode, val2);
      break;
    }

  case p_Ord:
    if (TYPE_IS_INTEGER_TYPE (type))
      {
        gpc_warning ("`%s' applied to integers has no effect", r_name);
        retval = val;
      }
    else
      retval = convert (type_for_size (TYPE_PRECISION (type), TYPE_UNSIGNED (type)), val);
    break;

  case p_Chr:
    retval = convert_and_check (char_type_node, val);
    break;

  case p_Initialize:
  case p_Finalize:
    {
      tree init = NULL_TREE;
      val = undo_schema_dereference (val);
      type = TREE_TYPE (val);
      if (r_num == p_Initialize)
        {
          if (TREE_CODE (val) == VAR_DECL)
            init = DECL_INITIAL (val);
          else
            {
              init = TYPE_GET_INITIALIZER (type);
              if (init)
                init = build_pascal_initializer (type, init, "type in `Initialize'", 0);
            }
        }
      if (init)
        expand_expr_stmt (build_modify_expr (val, NOP_EXPR, init));
      else if (pedantic && !contains_auto_initialized_part (type, r_num == p_Finalize))
        {
          if (r_num == p_Finalize)
            gpc_warning ("variable does not need any finalization");
          else
            gpc_warning ("variable does not need any initialization");
        }
      init_any (val, r_num == p_Finalize, 0);
      retval = error_mark_node;  /* nothing to expand anymore -- init_any does it already */
      break;
    }

  case p_Include:
  case p_Exclude:
    if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (type)), TYPE_MAIN_VARIANT (type2)))
      errstr = "incompatible type for argument 2 to `%s'";
    apar = chainon (actual_set_parameters (val, 1), build_tree_list (NULL_TREE,
      convert (pascal_integer_type_node, range_check (TYPE_DOMAIN (type), val2))));
    break;

  case p_Odd:
    retval = convert (boolean_type_node, build_pascal_binary_op (BIT_AND_EXPR, val, integer_one_node));
    break;

  case p_ReturnAddress:
  case p_FrameAddress:
    if (!really_constant_p (val))
      errstr = "argument to `%s' must be constant";
    else
      retval = build_routine_call (r_num == p_ReturnAddress ? return_address_routine_node : frame_address_routine_node, apar);
    break;

  case p_CurrentRoutineName:
    {
      const char *s;
      if (current_function_decl && DECL_NAME (current_function_decl))
        s = pascal_decl_name (current_function_decl, 2);
      else
        s = "top level";
      retval = build_string_constant (s, strlen (s), 0);
      break;
    }

  case p_SetType:
    retval = build_modify_expr (convert (gpc_type_PObjectType, get_vmt_field (val)), NOP_EXPR, val2);
    break;

  case p_SetLength:
    val = save_expr_string (val);
    retval = build_modify_expr (build_component_ref (val, get_identifier ("length")), NOP_EXPR,
      range_check_2 (integer_zero_node, PASCAL_STRING_CAPACITY (val), val2));
    break;

  case p_Length:
    retval = non_lvalue (convert (pascal_integer_type_node, PASCAL_STRING_LENGTH (val)));
    break;

  case p_ParamCount:
    retval = build_pascal_binary_op (MINUS_EXPR, paramcount_variable_node, integer_one_node);
    break;

  case p_ParamStr:
    {
      /* CString2String (((val < 0) or (val >= _p_CParamCount)) ? nil : _p_CParameters[val]) */
      tree condition;
      val = save_expr (val);
      condition = build_pascal_binary_op (GE_EXPR, val, paramcount_variable_node);
      /* Save one comparison when VAL is unsigned. */
      if (!TYPE_UNSIGNED (type))
        condition = build_pascal_binary_op (TRUTH_ORIF_EXPR,
                      build_pascal_binary_op (LT_EXPR, val, integer_zero_node), condition);
      val = build3 (COND_EXPR, cstring_type_node, condition, null_pointer_node,
                   build_indirect_ref (build_pascal_binary_op (PLUS_EXPR, paramstr_variable_node, val), NULL));
      type = TREE_TYPE (val);
      code = TREE_CODE (type);
    }
    /* FALLTHROUGH */
  case p_CString2String:
    if (code == POINTER_TYPE && integer_zerop (val))  /* explicit `nil' */
      retval = new_string_by_model (NULL_TREE, empty_string_node, 1);
    else
      {
        tree strlength;
        TREE_VALUE (apar) = val = save_expr (val);

        /* (val = nil) ? 0 : strlen|Length (val) */
        if (TYPE_MAIN_VARIANT (type) == cstring_type_node)
          strlength = build3 (COND_EXPR, pascal_integer_type_node,
            build_pascal_binary_op (EQ_EXPR, val, null_pointer_node),
            convert (pascal_integer_type_node, integer_zero_node),
            convert (pascal_integer_type_node,
              build_routine_call (strlen_routine_node, 
                build_tree_list (NULL_TREE, val))));
        else
          strlength = PASCAL_STRING_LENGTH (val);
        retval = make_new_variable ("cstring2string", build_pascal_string_schema (save_expr (strlength)));

        /* _p_CopyCString (val, retval); */
        expand_expr_stmt1 (build_routine_call (fun, chainon (apar, build_tree_list (NULL_TREE, retval))));
        TREE_READONLY (retval) = 1;
        retval = non_lvalue (retval);
      }
    break;

  case p_String2CString:
    retval = make_new_variable ("string2cstring_result",
      build_simple_array_type (char_type_node, build_range_type (pascal_integer_type_node,
        integer_zero_node, save_expr (PASCAL_STRING_LENGTH (val)))));
    expand_expr_stmt (build_routine_call (fun, tree_cons (NULL_TREE, retval, apar)));
    retval = build1 (ADDR_EXPR, cstring_type_node, retval);
    break;

  case p_Cmplx:
    {
      tree complex = TREE_TYPE (complex_type_node);
      if (type != complex)
        val = convert (complex, val);
      if (type2 != complex)
        val2 = convert (complex, val2);
      retval = build2 (COMPLEX_EXPR, complex_type_node, val, val2);
      break;
    }

  case p_Re:
  case p_Conjugate:
    if (INT_REAL (type))
      {
        gpc_warning ("`%s' applied to real numbers has no effect", r_name);
        retval = val;
      }
    else if (r_num == p_Re)
      retval = build_unary_op (REALPART_EXPR, val, 1);
    else
      retval = build_pascal_unary_op (CONJ_EXPR, val);
    break;

  case p_Im:
    if (INT_REAL (type))
      {
        gpc_warning ("`%s' applied to real numbers always yields 0.", r_name);
        if (TREE_SIDE_EFFECTS (val))
          gpc_warning (" Argument with side-effects is not evaluated.");
        retval = real_zero_node;
      }
    else
      retval = build_unary_op (IMAGPART_EXPR, val, 1);
    break;

  case p_Max:
  case p_Min:
    if (TYPE_IS_INTEGER_TYPE (type) && code2 == REAL_TYPE)
      val = convert ((type = type2), val);
    else if (code == REAL_TYPE && TYPE_IS_INTEGER_TYPE (type2))
      val2 = convert (type, val2);
    retval = convert (type, build_pascal_binary_op (r_num == p_Max ? MAX_EXPR : MIN_EXPR, val, val2));
    break;

  case p_Pack:
    {
      tree unpacked_domain = TYPE_DOMAIN (type);
      if (code3 != ARRAY_TYPE || !PASCAL_TYPE_PACKED (type3))
        errstr = "argument 3 to `%s' must be a packed array";
      else if (code != ARRAY_TYPE || PASCAL_TYPE_PACKED (type))
        errstr = "argument 1 to `%s' must be an unpacked array";
        /* XXXX FIXME is it correct ???? */
      else if (code2 != TREE_CODE (unpacked_domain)
               && (!TYPE_IS_INTEGER_TYPE (unpacked_domain)
                   || code2 != TREE_CODE (TREE_TYPE (unpacked_domain))))
        errstr = "argument 2 to `%s' must be of unpacked array index type";
      else
        retval = pascal_unpack_and_pack (0, val, val3, val2, r_name);
      break;
    }

  case p_Unpack:
    {
      tree unpacked_domain = TYPE_DOMAIN (type2);
      if (code2 != ARRAY_TYPE || PASCAL_TYPE_PACKED (type2))
        errstr = "argument 2 to `%s' must be an unpacked array";
      else if (code != ARRAY_TYPE || !PASCAL_TYPE_PACKED (type))
        errstr = "argument 1 to `%s' must be a packed array";
        /* XXXX FIXME is it correct ???? */
      else if (code3 != TREE_CODE (unpacked_domain)
               && (!TYPE_IS_INTEGER_TYPE (unpacked_domain)
                   || code3 != TREE_CODE (TREE_TYPE (unpacked_domain))))
        errstr = "argument 3 to `%s' must be of unpacked array index type";
      else
        retval = pascal_unpack_and_pack (1, val2, val, val3, r_name);
      break;
    }

  case p_Assigned:
    retval = build2 (NE_EXPR, boolean_type_node, val,
                      convert (TREE_TYPE (val), integer_zero_node));
    break;

  case p_GetMem:
    procflag = 1;
    retval = build_modify_expr (val, NOP_EXPR, convert (type, build_routine_call (fun, TREE_CHAIN (apar))));
    break;

  case p_New:
    {
      /* There are a lot of call styles for `New':

           New (AnyPtrVar);                               (CP)
           Ptr := New (AnyPtrType);                       (BP)

           New (VariantRecordPtrVar, TagFields);          (CP)
           Ptr := New (VariantRecordPtrType, TagFields);  (GPC)

           New (SchemaPtrVar, Discriminants);             (EP)
           Ptr := New (SchemaPtrType, Discriminants);     (GPC)

           New (ObjectPtrVar, ConstructorCall);           (BP)
           Ptr := New (ObjectPtrType, ConstructorCall);   (BP)

         Internally, we call `New' as a function whose only parameter is
         the size of the thing being created (of type `SizeType').
         If called as a procedure, we do the assignment inline. */

      tree result, orig_type = NULL_TREE, ptype = TREE_TYPE (type), tags = TREE_CHAIN (apar), init, res_deref;
      gcc_assert (code == POINTER_TYPE);
      CHK_EM (ptype);

      if (TREE_CODE (ptype) == VOID_TYPE && !(co->pascal_dialect & B_D_PASCAL))
        gpc_warning ("argument to `%s' should not be an untyped pointer", r_name);
      if (PASCAL_TYPE_ANYFILE (ptype))
        error ("`AnyFile' pointers cannot be allocated with `%s'", r_name);

      /* Schema with discriminants. To allocate the space required
         we create a temporary new type with the actual discriminants. */
      if (PASCAL_TYPE_UNDISCRIMINATED_STRING (ptype)
          || PASCAL_TYPE_PREDISCRIMINATED_STRING (ptype)
          || PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (ptype)
          || PASCAL_TYPE_PREDISCRIMINATED_SCHEMA (ptype))
        {
          int schema_ids = number_of_schema_discriminants (ptype);
          chk_dialect_1 ("discriminants in `%s' are", E_O_PASCAL, r_name);
          argcount -= schema_ids;
          if (argcount != 1)
            {
              error ("`%s' applied to this schema requires %d %s", r_name,
                     schema_ids, schema_ids > 1 ? "discriminant values" : "discriminant value");
              return error_mark_node;
            }

          if (PASCAL_TYPE_STRING (ptype))
            type = build_pointer_type (build_pascal_string_schema (val2));
          else
            {
              /* Get the base type, i.e. the undiscriminated schema type. */
              tree schema_type = ptype, tmp;
              while (TYPE_LANG_BASE (schema_type) && TYPE_LANG_BASE (schema_type) != schema_type)
                schema_type = TYPE_LANG_BASE (schema_type);
              gcc_assert (TREE_CODE (schema_type) != TYPE_DECL);
              for (tmp = tags; tmp; tmp = TREE_CHAIN (tmp))
                {
                  tree v1 = TREE_VALUE (tmp);
                  if (TREE_CODE (v1) == NON_LVALUE_EXPR)
                    v1 = TREE_OPERAND (v1, 0);

/* @@@@@@@@@@@@@@@@ ??????
   if (TREE_SIDE_EFFECTS (v1))
     var
   else
     save_expr 
*/
                  if (TREE_CODE (v1) != INTEGER_CST 
                      && TREE_CODE (v1) != STRING_CST)
                    {
                      tree v2 = make_new_variable ("new_disc", TREE_TYPE (v1));
                      expand_expr_stmt (build_modify_expr (v2, NOP_EXPR, v1));
                      TREE_VALUE (tmp) = v2;
//                    TREE_VALUE (tmp) = save_expr (TREE_VALUE (tmp));
                    }
                  else
                    TREE_VALUE (tmp) = v1;
                }
              type = build_discriminated_schema_type (schema_type, tags, 1);
              CHK_EM (type);
              type = build_pointer_type (type);
            }

          /* Force the type of the variable to be a pointer to the discriminated
             schema type instead of a pointer to the schema type. This will be
             undone after the newly allocated object has been initialized. */
          orig_type = TREE_TYPE (val);
          TREE_TYPE (val) = type;
        }

      /* Call the RTS function. */
      retval = convert (type, build_routine_call (fun,
        build_tree_list (NULL_TREE, size_of_type (TREE_TYPE (type)))));

      if (TREE_CODE (val) == TYPE_DECL)
        {
          /* Function-style call. We use a temporary variable here because we
             want to avoid this function to be called more than once if it
             returns a string or schema. */
          chk_dialect_1 ("function-style `%s' call is", B_D_M_PASCAL, r_name);
          result = make_new_variable ("new", type);
          expand_expr_stmt (build_modify_expr (result, NOP_EXPR, retval));
#if 0
          result = build (COMPOUND_EXPR, type, 
                           build_modify_expr (result, NOP_EXPR, retval),
                           result);
#endif
          retval = result;
          /* @@ This would be easier (fjf226k.pas), but then init_any below must
                return an expression and we have to use COMPOUND_EXPR's here
                (also for assign_tags). Since init_any can produce loops, this
                seems to require a statement-expression.
          retval = result = save_expr (retval); */
        }
      else
        {
          /* Procedure-style call. Do the assignment to the first parameter here. */
          mark_lvalue (val, "assignment via `New'", 1);
          expand_expr_stmt (build_modify_expr (val, NOP_EXPR, retval));
          retval = error_mark_node;  /* @@ nothing to expand anymore below */
          result = val;
        }

      /* Initialize the new variable. */
      res_deref = build_indirect_ref (result, NULL);
      init = TYPE_GET_INITIALIZER (TREE_TYPE (type));
      if (init)
        {
#if 0
          /* @@@@@@@@ Need more work */
          int save_warn_object_assignment = co->warn_object_assignment;
          co->warn_object_assignment = 0;
#endif


          expand_expr_stmt (build_modify_expr (res_deref, NOP_EXPR,
            build_pascal_initializer (TREE_TYPE (type), init, "type in `New'", 0)));


#if 0
          co->warn_object_assignment = save_warn_object_assignment;
#endif
        }

      if (argcount > 1 && !PASCAL_TYPE_OBJECT (ptype))
        {
          /* Tag fields of variant records. init_any needs them already. */
          chk_dialect_1 ("tag fields in `%s' are", ~U_B_D_M_PASCAL, r_name);
          tags = assign_tags (build_indirect_ref (result, NULL), tags);
          if (tags)
            expand_expr_stmt (tags);
        }

      init_any (res_deref, 0, 1);

      /* For schemata, restore the undiscriminated type after init_any has done
         its job to avoid type conflicts when this pointer is assigned to some
         lvalue. val might be a type decl, thus we must repair it, too. */
      if (orig_type)
        TREE_TYPE (result) = TREE_TYPE (val) = orig_type;

      if (argcount > 1 && PASCAL_TYPE_OBJECT (ptype))
        {
          /* Object constructor calls. If the constructor returns `False',
             dispose the object and return `nil'. */
          gcc_assert (TREE_CODE (TREE_VALUE (tags)) == COMPONENT_REF);
          expand_start_cond (build_pascal_unary_op (TRUTH_NOT_EXPR,
            build_routine_call (DECL_LANG_METHOD_DECL (TREE_OPERAND (TREE_VALUE (tags), 1)),
            tree_cons (NULL_TREE, build_indirect_ref (result, NULL), TREE_CHAIN (tags)))), 0);
          build_predef_call (p_Dispose, build_tree_list (NULL_TREE, result));
          expand_expr_stmt (build_modify_expr (result, NOP_EXPR, null_pointer_node));
          expand_end_cond ();
        }
      break;
    }

  case p_Dispose:
    gcc_assert (code == POINTER_TYPE);
    TREE_VALUE (apar) = val = save_expr (val);
    if (argcount > 1 && PASCAL_TYPE_OBJECT (TREE_TYPE (type)))
      {
        gcc_assert (argcount == 2);
        gcc_assert (TREE_CODE (val2) == CALL_EXPR || TREE_CODE (val2) == CONVERT_EXPR);
        expand_expr_stmt (val2);
        argcount = 1;
        TREE_CHAIN (apar) = NULL_TREE;
      }
    if (argcount > 1
        && !PASCAL_TYPE_UNDISCRIMINATED_STRING (TREE_TYPE (type))
        && !PASCAL_TYPE_PREDISCRIMINATED_STRING (TREE_TYPE (type))
        && !PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (TREE_TYPE (type))
        && !PASCAL_TYPE_PREDISCRIMINATED_SCHEMA (TREE_TYPE (type))
        && !PASCAL_TYPE_VARIANT_RECORD (TREE_TYPE (type)))
      {
        error ("too many arguments to `%s'", r_name);
        argcount = 1;
        TREE_CHAIN (apar) = NULL_TREE;
      }
    expand_start_cond (build2 (NE_EXPR, boolean_type_node, val, 
                        convert (TREE_TYPE (val), integer_zero_node)), 0);
    init_any (build_indirect_ref (val, NULL), 1, 1);
    if (co->pascal_dialect & C_E_O_PASCAL)
      {
        expand_start_else ();
        build_predef_call (p_DisposeNilError, NULL_TREE);
      }
    expand_end_cond ();
    /* FALLTHROUGH */
  case p_FreeMem:
    if (integer_zerop (val))
      {
        if (co->pascal_dialect & C_E_O_PASCAL)
          error ("standard Pascal forbids `%s (nil)'", r_name);
        else
          gpc_warning ("`%s (nil)' has no effect", r_name);
      }
    if (argcount > 1)
      {
        if (PEDANTIC (GNU_PASCAL))
          gpc_warning (r_num == p_Dispose
                   ? "tag fields ignored in `%s'"
                   : "second parameter ignored in `%s'", r_name);
        /* @@ Perhaps we should do a run-time check ? */
        TREE_CHAIN (apar) = NULL_TREE;
      }
    break;

  case p_Position:
  case p_LastPosition:
    if (!direct_access_warning (type))
      retval = convert (base_type (TYPE_LANG_FILE_DOMAIN (type)), build_pascal_binary_op (PLUS_EXPR,
                 build_routine_call (fun, check_files (apar)),
                 convert (long_long_integer_type_node, TYPE_MIN_VALUE (TYPE_LANG_FILE_DOMAIN (type)))));
    break;

  case p_Page:
    if (argcount == 0)
      apar = build_tree_list (NULL_TREE, get_standard_output ());
    break;

  case p_RunError:
    if (argcount == 0)
      apar = build_tree_list (NULL_TREE, integer_minus_one_node);
    break;

  case p_Halt:
    if (argcount == 0)
      apar = build_tree_list (NULL_TREE, integer_zero_node);
    else
      chk_dialect ("parameters to `Halt' are", U_B_D_M_PASCAL);
    break;

  case p_Empty:
  case p_Update:
    direct_access_warning (type);
    break;

  case p_Seek:
  case p_SeekUpdate:
  case p_SeekRead:
  case p_SeekWrite:
    if (!direct_access_warning (type))
      {
        if (!comptypes (base_type (TYPE_LANG_FILE_DOMAIN (type)), TYPE_MAIN_VARIANT (type2)))
          errstr = "index type does not match direct access file range type";
        else
          {
            val2 = convert (long_long_integer_type_node, build_pascal_binary_op (MINUS_EXPR, val2, TYPE_MIN_VALUE (TYPE_LANG_FILE_DOMAIN (type))));
            TREE_VALUE (TREE_CHAIN (apar)) = val2;
          }
      }
    break;

  case p_EOF:
  case p_EOLn:
  case p_SeekEOF:
  case p_SeekEOLn:
    if (argcount == 0)
      apar = build_tree_list (NULL_TREE, get_standard_input ());
    break;

  case p_Random:
    {
      tree t = TREE_CODE (val) == INTEGER_CST ? val : TYPE_MAX_VALUE (type);
      if (TREE_CODE (t) == INTEGER_CST && !const_lt (TYPE_MAX_VALUE (long_long_integer_type_node), t))
        convert_result = long_long_integer_type_node;
      break;
    }

  case p_Abs:
    retval = build_unary_op (ABS_EXPR, val, 0);
    break;

  case p_Int:
    if (TYPE_IS_INTEGER_TYPE (type))
      {
        gpc_warning ("`%s' applied to integers has no effect", r_name);
        retval = val;
      }
    break;

  case p_Frac:
    if (TYPE_IS_INTEGER_TYPE (type))
      {
        gpc_warning ("`%s' applied to integers always yields 0.", r_name);
        if (TREE_SIDE_EFFECTS (val))
          gpc_warning (" Argument with side-effects is not evaluated.");
        retval = integer_zero_node;
      }
    break;

  case p_Assign:
    if (co->pascal_dialect & (B_D_M_PASCAL))
      {
        /* init_any (val, 1, 0); @@ fjf858.pas */
        init_any (val, 0, 0);
      }
    break;

  case p_Extend:
  case p_Append:
  case p_Reset:
  case p_Rewrite:
    {
      tree file_name = NULL_TREE, file_name_given;
      tree buffer_size = NULL_TREE;
      if ((r_num == p_Extend || r_num == p_Append) && !PASCAL_TYPE_TEXT_FILE (type))
        chk_dialect_1 ("`%s' for non-text files is", E_O_PASCAL, r_name);
      if (argcount >= 2)
        {
          if (is_string_compatible_type (val2, 1))
            file_name = val2;
          else if (TYPE_IS_INTEGER_TYPE (type2))
            buffer_size = val2;
          else
            errstr = "type mismatch in optional argument to `%s'";
          if (argcount >= 3)
            {
              if (buffer_size)
                errstr = "file buffer size given twice to `%s'";
              else
                buffer_size = val3;
            }
        }

      if (file_name)
        {
          chk_dialect_1 ("file name parameters to `%s' are",
                          U_M_PASCAL, r_name);
          file_name_given = boolean_true_node;
        }
      else
        {
          file_name = empty_string_node;
          file_name_given = boolean_false_node;
        }

      if (TREE_CODE (TREE_TYPE (type)) == VOID_TYPE && !PASCAL_TYPE_ANYFILE (type))
        {
          if (buffer_size)
            {
              chk_dialect_1 ("file buffer size arguments to `%s' are", B_D_M_PASCAL, r_name);
              STRIP_TYPE_NOPS (buffer_size);
              if (TREE_CODE (buffer_size) == INTEGER_CST && !INT_CST_LT (integer_zero_node, buffer_size))
                errstr = "file buffer size in `%s' must be > 0";
            }
          else if (co->pascal_dialect & U_B_D_M_PASCAL)
            {
              gpc_warning ("unspecified buffer size for untyped file defaults to 128 in `%s'", r_name);
              buffer_size = build_int_2 (128, 0);
            }
          else
            errstr = "missing buffer size argument to `%s' for untyped file";
        }
      else if (buffer_size)
        errstr = "file buffer size argument to `%s' allowed only for untyped files";
      if (!buffer_size)
        buffer_size = integer_one_node;  /* for untyped files used as `AnyFile' */
      apar = tree_cons (NULL_TREE, val,
             tree_cons (NULL_TREE, file_name,
             tree_cons (NULL_TREE, file_name_given,
             build_tree_list (NULL_TREE, buffer_size))));
      break;
    }

  case p_Set_IsEmpty:
    apar = actual_set_parameters (val, 0);
    break;

  case p_in:
    apar = chainon (actual_set_parameters (val2, 0),
             build_tree_list (NULL_TREE, convert (pascal_integer_type_node, val)));
    break;

  case p_Set_Equal:
  case p_Set_Less:
  case p_Set_LE:
    apar = chainon (actual_set_parameters (val, 0), actual_set_parameters (val2, 0));
    break;

  case p_Set_Intersection:
  case p_Set_Union:
  case p_Set_Diff:
  case p_Set_SymDiff:
    {
      tree res_type = type;
      /* For the result type of `+' and `><' use the union of operand ranges;
         the result of `*' and `-' always fits in the type of the first operand */
      if (r_num == p_Set_Union || r_num == p_Set_SymDiff)
        {
          tree main1 = TYPE_MAIN_VARIANT (TREE_TYPE (type));
          tree main2 = TYPE_MAIN_VARIANT (TREE_TYPE (type2));
          tree low1  = convert (main1, TYPE_MIN_VALUE (TYPE_DOMAIN (type)));
          tree low2  = convert (main2, TYPE_MIN_VALUE (TYPE_DOMAIN (type2)));
          tree high1 = convert (main1, TYPE_MAX_VALUE (TYPE_DOMAIN (type)));
          tree high2 = convert (main2, TYPE_MAX_VALUE (TYPE_DOMAIN (type2)));
          res_type = build_set_type (build_pascal_range_type (
            build_pascal_binary_op (MIN_EXPR, low1, low2),
            build_pascal_binary_op (MAX_EXPR, high1, high2)));
          if (PASCAL_TYPE_PACKED (type) || PASCAL_TYPE_PACKED (type2))
            PASCAL_TYPE_PACKED (res_type) = 1;
        }
      else if (PASCAL_TYPE_CANONICAL_SET (type) &&
               !PASCAL_TYPE_CANONICAL_SET (type2))
        {
          res_type = build_set_type (TYPE_DOMAIN (type));
          PASCAL_TYPE_PACKED (res_type) = PASCAL_TYPE_PACKED (type2);
        }
      actual_result = make_new_variable ("set_result", res_type);
      apar = chainon (actual_set_parameters (val, 0),
             chainon (actual_set_parameters (val2, 0),
                      actual_set_parameters (actual_result, 1)));
      break;
    }

  case p_Set_Clear:
    apar = actual_set_parameters (val, 1);
    procflag = 0;
    break;

  case p_Set_Copy:
    apar = chainon (actual_set_parameters (val2, 0), actual_set_parameters (val, 1));
    procflag = 0;
    break;

  case p_Set_RangeCheck:
    apar = chainon (actual_set_parameters (val, 0), TREE_CHAIN (apar));
    break;

  case p_Str:
  case p_StringOf:
  case p_WriteStr:
  case p_FormatString:
  case p_Write:
  case p_WriteLn:
    return build_write (r_num, apar, r_name);

  case p_ReadStr:
  case p_ReadString:
  case p_Read:
  case p_ReadLn:
    return build_read (r_num, apar, r_name);

  case p_Val:
    return build_val (apar);

  case p_Insert:
    /* Add an implicit fourth parameter that tells whether the
       string shall be truncated if it becomes too long.
       @@ Currently, we always pass `True'. */
    apar = chainon (apar, build_tree_list (NULL_TREE, boolean_true_node));
    break;

  case p_Delete:
    if (argcount == 2)
      {
        chk_dialect_1 ("`%s' with only two arguments is", GNU_PASCAL, r_name);
        apar = chainon (apar, build_tree_list (NULL_TREE, pascal_maxint_node));
      }
    break;

  case p_Index:
  case p_Pos:
  case p_PosChar:
    if (IS_STRING_CST (val) && IS_STRING_CST (val2))
      {
        unsigned int l1, l2, n, r;
        val = char_may_be_string (val);
        val2 = char_may_be_string (val2);
        l1 = TREE_STRING_LENGTH (val) - 1;
        l2 = TREE_STRING_LENGTH (val2) - 1;
        if (l1 == 0)
          r = 1;
        else if (l2 == 0)
          r = 0;
        else
          {
            n = l2 - l1 + 1;
            r = 1;
            while (r <= n && memcmp (TREE_STRING_POINTER (val2) + r - 1, TREE_STRING_POINTER (val), l1))
              r++;
            if (r > n)
              r = 0;
          }
        retval = build_int_2 (r, 0);
        procflag = 0;
      }
    break;

  case p_Copy:
  case p_SubStr:
    if (argcount == 2 && r_num == p_Copy)
      chk_dialect_1 ("`%s' with only two arguments is", GNU_PASCAL, r_name);
    STRIP_TYPE_NOPS (val);
    val = fold (val);
    STRIP_TYPE_NOPS (val2);
    val2 = fold (val2);
    if (argcount > 2)
      {
        STRIP_TYPE_NOPS (val3);
        val3 = fold (val3);
      }
    if (IS_STRING_CST (val) && TREE_CODE (val2) == INTEGER_CST
        && (argcount == 2 || TREE_CODE (val3) == INTEGER_CST))
      {
        unsigned int l, m, n;
        val = char_may_be_string (val);
        gcc_assert (TREE_CODE (val) == STRING_CST);
        l = TREE_STRING_LENGTH (val) - 1;
        if (TREE_INT_CST_HIGH (val2) || TREE_INT_CST_LOW (val2) <= 0 || TREE_INT_CST_LOW (val2) > l + 1)
          {
            errstr = "argument 2 to `%s' out of range";
            break;
          }
        m = TREE_INT_CST_LOW (val2);
        n = l - m + 1;
        if (argcount > 2)
          {
            if (TREE_INT_CST_HIGH (val3) || TREE_INT_CST_LOW (val3) > n)
              {
                errstr = "argument 3 to `%s' out of range";
                break;
              }
            n = TREE_INT_CST_LOW (val3);
          }
        retval = build_string_constant (TREE_STRING_POINTER (val) + m - 1, n, 0);
        procflag = 0;
      }
    else
      {
        tree l;
        TREE_VALUE (apar) = val = save_expr_string (val);
        /* Allocate a new string and pass that to the RTS. When copying a few
           characters out of a large string, don't allocate too much space.
           OTOH, if the string (or its capacity) is not too large, don't waste
           complicate things with length computations. */
        l = PASCAL_STRING_LENGTH (val);
        if (TREE_CODE (l) != INTEGER_CST && PASCAL_TYPE_DISCRIMINATED_STRING (TREE_TYPE (val)))
          l = TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (val));
        if (TREE_CODE (l) != INTEGER_CST || TREE_INT_CST_HIGH (l) || TREE_INT_CST_LOW (l) > 0x1000)
          {
            if (argcount != 2)
              {
                tree v = TREE_VALUE (TREE_CHAIN (TREE_CHAIN (apar))) = save_expr (TREE_VALUE (TREE_CHAIN (TREE_CHAIN (apar))));
                l = build_pascal_binary_op (MIN_EXPR, l, build_pascal_binary_op (MAX_EXPR, v, integer_one_node));
              }
          }
        actual_result = make_new_variable ("substr_result", build_pascal_string_schema (l));
        /* If 3rd parameter is missing, pass MaxInt and let the RTS truncate */
        if (argcount == 2)
          apar = chainon (apar, build_tree_list (NULL_TREE, pascal_maxint_node));
        apar = tree_cons (NULL_TREE, convert (ptr_type_node, 
          build_unary_op (ADDR_EXPR, PASCAL_STRING_VALUE (val), 2)),
          tree_cons (NULL_TREE, PASCAL_STRING_LENGTH (val), TREE_CHAIN (apar)));
        apar = chainon (apar, tree_cons (NULL_TREE, actual_result, build_tree_list (NULL_TREE,
          r_num == p_Copy ? integer_zero_node : argcount == 2 ? integer_one_node : build_int_2 (2, 0))));
      }
    break;

  case p_Trim:
    STRIP_TYPE_NOPS (val);
    val = fold (val);
    if (IS_STRING_CST (val))
      {
        unsigned int l;
        const char *p;
        val = char_may_be_string (val);
        gcc_assert (TREE_CODE (val) == STRING_CST);
        p = TREE_STRING_POINTER (val);
        for (l = TREE_STRING_LENGTH (val) - 1; l > 0 && p[l - 1] == ' '; l--) ;
        retval = build_string_constant (p, l, 0);
        procflag = 0;
      }
    else
      {
        /* Allocate a new string and pass that to RTS. */
        actual_result = new_string_by_model (NULL_TREE, val, 0);
        apar = chainon (apar, build_tree_list (NULL_TREE, actual_result));
      }
    break;

  case p_Integer_Pow:
    STRIP_TYPE_NOPS (val);
    val = fold (val);
    STRIP_TYPE_NOPS (val2);
    val2 = fold (val2);
    if (TREE_CODE (val) == INTEGER_CST && TREE_CODE (val2) == INTEGER_CST)
      {
        unsigned HOST_WIDE_INT y = TREE_INT_CST_LOW (val2);
        if (integer_zerop (val))
          {
            if (const_lt (integer_zero_node, val2))
              retval = integer_zero_node;
            else
              {
                errstr = "left argument of `pow' is 0 while right argument is <= 0";
                if (!pedantic && (co->pascal_dialect & C_E_O_PASCAL))
                  {
                    gpc_warning (errstr);
                    errstr = NULL;
                  }
              }
          }
        else if (integer_zerop (val2) || integer_onep (val))
          retval = integer_one_node;
        else if (!TYPE_UNSIGNED (TREE_TYPE (val)) && tree_int_cst_equal (val, integer_minus_one_node))
          retval = y & 1 ? integer_minus_one_node : integer_one_node;
        else if (const_lt (val2, integer_zero_node))
          retval = integer_zero_node;
        else
          {
            int overflow = TREE_INT_CST_HIGH (val2) != 0;  /* we have |val| >= 2 here */
            tree t = TYPE_UNSIGNED (TREE_TYPE (val)) ? long_long_unsigned_type_node : long_long_integer_type_node;
            val = convert (t, val);
            retval = convert (t, integer_one_node);
            while (y)
              {
                if (y & 1)
                  {
                    retval = fold (build2 (MULT_EXPR, t, retval, val));
                    gcc_assert (TREE_CODE (retval) == INTEGER_CST);
                    overflow |= TREE_OVERFLOW (retval);
                  }
                y >>= 1;
                if (y)
                  {
                    val = fold (build2 (MULT_EXPR, t, val, val));
                    gcc_assert (TREE_CODE (val) == INTEGER_CST);
                    overflow |= TREE_OVERFLOW (val);
                  }
              }
            if (overflow)
              errstr = "overflow in `pow'";
          }
      }
    break;

  /* String comparisons */
  case p_EQ:
  case p_LT:
  case '=':
  case '<':
    {
      int nopad = r_num == p_EQ || r_num == p_LT;
      const char *warning_str = NULL;

      if (swapargs)
        {
          TREE_VALUE (apar) = val2;
          val2 = TREE_VALUE (TREE_CHAIN (apar)) = val;
          val = TREE_VALUE (apar);
        }

      if (r_num == p_EQ || r_num == '=')
        {
          unsigned HOST_WIDE_INT l1 = get_string_length_plus_1 (val, nopad), l2 = get_string_length_plus_1 (val2, nopad);
          tree c1 = PASCAL_TYPE_STRING (TREE_TYPE (val )) ? PASCAL_STRING_CAPACITY (val ) : PASCAL_STRING_LENGTH (val );
          tree c2 = PASCAL_TYPE_STRING (TREE_TYPE (val2)) ? PASCAL_STRING_CAPACITY (val2) : PASCAL_STRING_LENGTH (val2);
          if (l1 > 0 && l2 > 0 && l1 != l2)
            warning_str = "string comparison is always %s due to different length of fixed-size strings";
          else if ((l2 > 0 && TREE_CODE (c1) == INTEGER_CST && TREE_INT_CST_LOW (c1) < l2 - 1) ||
                   (l1 > 0 && TREE_CODE (c2) == INTEGER_CST && TREE_INT_CST_LOW (c2) < l1 - 1))
            warning_str = "string comparison is always %s because the capacity of one string is smaller than the length of the fixed-size string";
        }

      if (!warning_str && IS_STRING_CST (val) && IS_STRING_CST (val2))
        {
          const char *p1, *p2;
          unsigned int l1, l2, r;
          val = char_may_be_string (val);
          val2 = char_may_be_string (val2);
          l1 = TREE_STRING_LENGTH (val) - 1;
          l2 = TREE_STRING_LENGTH (val2) - 1;
          p1 = TREE_STRING_POINTER (val);
          p2 = TREE_STRING_POINTER (val2);
          if (r_num == '=' || r_num == '<')
            {
              if (l1 < l2)
                {
                  char *p = alloca (l2 * sizeof (char));
                  if (l1)
                    memcpy (p, p1, l1);
                  memset (p + l1, ' ', l2 - l1);
                  p1 = p;
                  l1 = l2;
                }
              else if (l2 < l1)
                {
                  char *p = alloca (l1 * sizeof (char));
                  if (l2)
                    memcpy (p, p2, l2);
                  memset (p + l2, ' ', l1 - l2);
                  p2 = p;
                  l2 = l1;
                }
            }
          if (r_num == p_EQ || r_num == '=')
            r = (l1 == l2) && !memcmp (p1, p2, l1);
          else
            if (l1 < l2)
              r = !l1 || memcmp (p1, p2, l1) <= 0;
            else
              r = l2 && memcmp (p1, p2, l2) < 0;
          retval = r ? boolean_true_node : boolean_false_node;
          break;
        }

      /* Optimize non-padding comparisons against the constant empty string */
      if (!warning_str && nopad)
        {
          tree comp_empty = NULL;
          if (IS_CONSTANT_EMPTY_STRING (val))
            {
              if (r_num == p_LT)  /* '' < s is equivalent to '' <> s */
                invert_result = !invert_result;
              comp_empty = val2;
            }
          else if (IS_CONSTANT_EMPTY_STRING (val2))
            {
              if (r_num == p_LT)  /* s < '' is impossible */
                warning_str =
                  "`>=' comparison against the empty string is always %s.";
              else
                comp_empty = val;
            }
          if (comp_empty)
            {
              /* Now we only have to compare the length against 0. */
              if (is_string_compatible_type (comp_empty, 1))
                retval = build_pascal_binary_op (EQ_EXPR, integer_zero_node,
                           convert (pascal_integer_type_node, PASCAL_STRING_LENGTH (comp_empty)));
              else
                errstr = "argument to `%s' must be a string or char";
              break;
            }
        }

      if (warning_str)
        {
          gpc_warning (warning_str, invert_result ? "true" : "false");
          if (TREE_SIDE_EFFECTS (val) || TREE_SIDE_EFFECTS (val2))
            gpc_warning (" Operand with side-effects is not evaluated.");
          return invert_result ? boolean_true_node : boolean_false_node;
        }
      break;
    }

  case p_Discard:
    if (TREE_SIDE_EFFECTS (val))
      expand_expr_stmt (convert (void_type_node, val));
    return NULL_TREE;

  case p_Assert:
    if (!co->assertions)
      {
        if (TREE_SIDE_EFFECTS (val))
          expand_expr_stmt (convert (void_type_node, val));
        return NULL_TREE;
      }
    else if (argcount < 2)
      apar = chainon (apar, build_tree_list (NULL_TREE, empty_string_node));
    break;

  case p_CompilerAssert:
    STRIP_TYPE_NOPS (val);
    val = fold (val);
    if (TREE_CODE (val) != INTEGER_CST)
      errstr = "first argument to `%s' is no compile-time constant";
    else if (!integer_onep (val))
      errstr = "first argument to `%s' is False";
    if (argcount == 2)
      {
        if (TREE_CODE (val2) == FUNCTION_DECL
            || (TREE_CODE (TREE_TYPE (val2)) == REFERENCE_TYPE && 
                TREE_CODE (TREE_TYPE (TREE_TYPE (val2))) == FUNCTION_TYPE))
          errstr = "`%s' can not return a routine";
        else
          retval = val2;
      }
    else 
      {
        retval = copy_node (boolean_true_node);
        PASCAL_CST_FRESH (retval) = 0;
        PASCAL_TREE_IGNORABLE (retval) = 1;
      }
    break;

  case p_as:
    /* @@ Don't expand it because it's used in a COMPOUND_EXPR in
          build_is_as(). In the future, build_predef_call should not
          expand anything at all, and this special case can vanish. */
    return build_routine_call (fun, apar);

  case p_SizeOf:
  case p_BitSizeOf:
  case p_AlignOf:
    val = undo_schema_dereference (val);
    if (is_packed_field (val))
      {
        if (r_num != p_BitSizeOf)
          errstr = "`%s' applied to a packed record/array field";
        else
          {
            if (TREE_CODE (val) != COMPONENT_REF)
              retval = count_bits (TREE_TYPE (val), NULL);
            else
#ifndef EGCS97
              retval = build_int_2 (DECL_FIELD_SIZE (TREE_OPERAND (val, 1)), 0);
#else
              retval = fold (build1 (NOP_EXPR, size_type_node, DECL_SIZE (TREE_OPERAND (val, 1))));
#endif
            retval = non_lvalue (retval);
          }
        break;
      }

    if (r_num == p_AlignOf && TREE_CODE (val) == INDIRECT_REF)
      {
        tree t = TREE_OPERAND (val, 0), best = t;
        int bestalign = TYPE_ALIGN (TREE_TYPE (TREE_TYPE (t)));
        while (TREE_CODE (t) == NOP_EXPR && TREE_CODE (TREE_TYPE (TREE_OPERAND (t, 0))) == POINTER_TYPE)
          {
            int thisalign;
            t = TREE_OPERAND (t, 0);
            thisalign = TYPE_ALIGN (TREE_TYPE (TREE_TYPE (t)));
            if (thisalign > bestalign)
              {
                best = t;
                bestalign = thisalign;
              }
          }
        type = TREE_TYPE (TREE_TYPE (best));
      }
    else
      /* Now val is either a variable access or a type declaration.
         In both cases, TREE_TYPE (val) carries the actual type. */
      type = TREE_TYPE (val);
    code = TREE_CODE (type);

    if (EM (type))
      retval = error_mark_node;
    else if (code == VOID_TYPE)
      errstr = "`%s' applied to a void type";
    else if (TREE_CODE (val) == TYPE_DECL && PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
      errstr = "`%s' applied to an undiscriminated schema";
    else if (TREE_CODE (val) == TYPE_DECL && PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
      errstr = "`%s' applied to an undiscriminated string";
    else if (code == FUNCTION_TYPE)
      {
        if (r_num != p_AlignOf)
          errstr = "`%s' applied to a function type";
        else
          retval = build_int_2 (FUNCTION_BOUNDARY / BITS_PER_UNIT, 0);
      }
    else if (!TYPE_SIZE (type))
      errstr = "`%s' applied to an incomplete type";
    else if (r_num != p_AlignOf && PASCAL_TYPE_OBJECT (type))
      {
        /* If it's an object type, get the size from the static VMT.
           Also the size of non-polymorphic objects can be read from the
           static VMT, and in fact *must* be read from there, in case the
           object is not initialized (chief32*.pas). */
        tree vmt, t = val;
        while (TREE_CODE (t) == NOP_EXPR
               || TREE_CODE (t) == CONVERT_EXPR
               || TREE_CODE (t) == NON_LVALUE_EXPR)
          t = TREE_OPERAND (t, 0);
        if (TREE_CODE (val) == TYPE_DECL
            || TREE_CODE (t) == VAR_DECL
            || TREE_CODE (t) == PARM_DECL
            || TREE_CODE (t) == COMPONENT_REF
            || TREE_CODE (t) == ARRAY_REF)
          {
            if (TYPE_LANG_CODE (TREE_TYPE (val)) == PASCAL_LANG_ABSTRACT_OBJECT)
              error ("`%s' applied to an abstract object type", r_name);
            vmt = TYPE_LANG_VMT_VAR (TREE_TYPE (val));
            gcc_assert (vmt);
          }
        else
          /* Read the size of the object at run time from the VMT. */
          vmt = build_indirect_ref (get_vmt_field (val), NULL);
        retval = build_component_ref (vmt, get_identifier ("Size"));
        if (r_num == p_BitSizeOf)
          retval = build_pascal_binary_op (MULT_EXPR, retval, build_int_2 (BITS_PER_UNIT, 0));
        retval = non_lvalue (retval);
      }
    else if (r_num == p_SizeOf)
      {
#if 0
#ifdef PG__NEW_STRINGS
        /* @@@@@@ what if val is a TYPE_DECL ??? */
        if (PASCAL_TYPE_PREDISCRIMINATED_STRING (type))
#if 1
          // gcc_assert (0);
            0;
//          retval = SUBSTITUTE_PLACEHOLDER_IN_EXPR (retval, val);
#else
          retval = fold (non_lvalue (
                     build (WITH_RECORD_EXPR, size_type_node,
                       convert (size_type_node, retval), val)));
#endif
        else
#endif
#endif
#ifdef EGCS97
        retval = non_lvalue (build_pascal_binary_op (CEIL_DIV_EXPR, convert (size_type_node, TYPE_SIZE_UNIT (type)),
                   build_int_2 (TYPE_PRECISION (byte_integer_type_node) / BITS_PER_UNIT, 0)));
#else
        retval = non_lvalue (build_pascal_binary_op (CEIL_DIV_EXPR, convert (size_type_node, TYPE_SIZE (type)),
                   build_int_2 (TYPE_PRECISION (byte_integer_type_node), 0)));
#endif
        if (PASCAL_TYPE_PREDISCRIMINATED_STRING (type))
#ifdef GCC_4_0
          retval = SUBSTITUTE_PLACEHOLDER_IN_EXPR (retval, val); 
#else
          retval = fold (non_lvalue (build (WITH_RECORD_EXPR, size_type_node,
                       convert (size_type_node, retval), val)));
#endif
      }
    else if (r_num == p_BitSizeOf)
      retval = non_lvalue (convert (long_long_integer_type_node, TYPE_SIZE (type)));
    /* `AlignOf' */
    else if (TREE_CODE (val) == VAR_DECL)
      retval = build_int_2 (DECL_ALIGN (val) / BITS_PER_UNIT, 0);
    else if (TREE_CODE (val) == COMPONENT_REF && TREE_CODE (TREE_OPERAND (val, 1)) == FIELD_DECL)
      retval = build_int_2 (DECL_ALIGN (TREE_OPERAND (val, 1)) / BITS_PER_UNIT, 0);
    else
      retval = build_int_2 (TYPE_ALIGN (type) / BITS_PER_UNIT, 0);
    break;

  case p_High:
  case p_Low:
    /* Implicitly dereference schemata. */
    while (PASCAL_TYPE_SCHEMA (type))
      {
        if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
          {
            errstr = "`%s' applied to an undiscriminated schema";
            type = error_mark_node;
            break;
          }
        else if (TREE_CODE (val) == TYPE_DECL)
          {
            tree field;
            if (!TYPE_SIZE (type))
              incomplete_type_error (NULL_TREE, type);
            field = simple_get_field (schema_id, type, NULL);
            type = TREE_TYPE (field);
            /* Don't change val, so its code is still TYPE_DECL below */
          }
        else
          {
            val = build_component_ref (val, schema_id);
            type = TREE_TYPE (val);
            code = TREE_CODE (type);
          }
      }
    if (EM (type))
      retval = error_mark_node;
    else if (code == RECORD_TYPE && PASCAL_TYPE_STRING (type))
      {
        if (PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
          errstr = "`%s' applied to an undiscriminated string";
        else if (r_num == p_Low)
          retval = integer_one_node;
        else if (TREE_CODE (val) != TYPE_DECL)
          retval = non_lvalue (PASCAL_STRING_CAPACITY (val));
        else
          {
            retval = non_lvalue (TYPE_LANG_DECLARED_CAPACITY (type));
            if (integer_zerop (retval))
              errstr = "`%s' applied to undiscriminated string field";
          }
      }
    else
      {
        if (TREE_CODE (type) == ARRAY_TYPE || TREE_CODE (type) == SET_TYPE)
          type = TYPE_DOMAIN (type);
        if (!ORDINAL_TYPE (TREE_CODE (type)))
          errstr = "invalid argument to `%s'";
        else
          {
            retval = non_lvalue ((r_num == p_High) ? TYPE_MAX_VALUE (type) : TYPE_MIN_VALUE (type));
            if (contains_discriminant (retval, NULL_TREE))
              errstr = "`%s' applied to undiscriminated schema field";
          }
      }
    break;

  case p_TypeOf:
    if (!PASCAL_TYPE_OBJECT (type))
      errstr = "`%s' applied to something not an object";
    else if (!TYPE_SIZE (type))
      errstr = "`%s' applied to an incomplete type";
    else
      {
        if (TREE_CODE (val) == TYPE_DECL)
          retval = build_pascal_unary_op (ADDR_EXPR, TYPE_LANG_VMT_VAR (type));
        else
          /* Return the implicit VMT field. */
          retval = get_vmt_field (val);
        if (!EM (retval))
          retval = non_lvalue (convert (gpc_type_PObjectType, retval));
      }
    break;

  }  /* The big `switch' statement ends here. */

  if (errstr)
    {
      error (errstr, r_name);
      return error_mark_node;
    }

  /* Construct a call to the RTS unless retval was set already. */
  if (!retval)
    retval = build_routine_call (fun, check_files (apar));

  /* If this is a statement, expand it, otherwise return the tree to the caller. */
  if (procflag)
    {
      /* If we need to return something, like a string written
         by an RTS procedure (acting as a function) */
      if (actual_result)
        /* save_expr so the actual RTS call is only done once even if the
           result is used multiple times (e.g. in `s := Copy (...)'). */
        retval = non_lvalue (build2 (COMPOUND_EXPR, TREE_TYPE (actual_result),
                   save_expr (retval), actual_result));
      else if (!EM (retval))
        {
          expand_expr_stmt (retval);
          retval = error_mark_node;
        }
    }

  if (convert_result)
    retval = convert (convert_result, retval);

  if (invert_result)
    retval = build_pascal_unary_op (TRUTH_NOT_EXPR, retval);

  if (post_statement)
    expand_expr_stmt (post_statement);

  return retval;
}

/* Lazy file I/O
   func is the RTS function to call (must return a pointer to the buffer) */
tree
build_buffer_ref (tree file, int func)
{
  tree ref, t = TREE_TYPE (TREE_TYPE (file));  /* type of file component */
  CHK_EM (t);
  if (PASCAL_TYPE_ANYFILE (TREE_TYPE (file)))
    error ("files of type `AnyFile' cannot be dereferenced");
  ref = build1 (INDIRECT_REF, t, save_expr (convert (build_pointer_type (t),
          build_predef_call (func, build_tree_list (NULL_TREE, file)))));
  init_any (ref, 0, 1);
  return ref;
}

/* Return implicitly accessible `Input' or `Output'. */
static tree
get_standard_input (void)
{
  if (co->warn_implicit_io)
    gpc_warning ("implicit use of `Input'");
  if (!current_module->input_available)
    {
      current_module->input_available = 1;
      chk_dialect ("use of `Input' without declaring it as a program parameter or importing `StandardInput' is", U_B_D_M_PASCAL);
    }
  return input_variable_node;
}

static tree
get_standard_output (void)
{
  if (co->warn_implicit_io)
    gpc_warning ("implicit use of `Output'");
  if (!current_module->output_available)
    {
      current_module->output_available = 1;
      chk_dialect ("use of `Output' without declaring it as a program parameter or importing `StandardOutput' is", U_B_D_M_PASCAL);
    }
  return output_variable_node;
}

/* Construct a tree expression that copies LENGTH units of
   storage from SOURCE to DEST. */
tree
build_memcpy (tree dest, tree source, tree length)
{
  return build_routine_call (memcpy_routine_node, tree_cons (NULL_TREE, dest,
    tree_cons (NULL_TREE, source, build_tree_list (NULL_TREE, length))));
}

/* Construct a tree expression that pads LENGTH units of
   storage DEST with the byte PATTERN. */
tree
build_memset (tree dest, tree length, tree pattern)
{
  return build_routine_call (memset_routine_node, tree_cons (NULL_TREE, dest,
    tree_cons (NULL_TREE, pattern, build_tree_list (NULL_TREE, length))));
}

/* Problem:
     New (ObjectPointer, ConstructorName (Arguments))  (BP)
   vs.
     New (SchemaPointer, FunctionCall (Arguments))     (EP)
   Same with `Dispose'.

   `ConstructorName' does not contain the object name, so it must be
   taken from `ObjectPointer', i.e., it depends on its semantic
   value, so we can't distinguish it while parsing. Furthermore,
   constructors are treated this way only in the first position of
   the second argument, while its arguments can contain the same
   identifier with another meaning (fjf915[abe].pas). This is
   completely contrary to the usual Pascal scoping rules, but
   actually BP's behaviour. So we can't just install constructor
   names temporarily as identifier meanings.

   We parse it ambiguously using `%dprec', at the cost of some more
   parser conflicts, and having to expand the second argument here
   (which might be a predefined or explicit function call or type
   cast) if the first argument is no object, thereby duplicating
   some work usually done from the parser directly.

   Of the various kludges considered so far, this seems to be the
   least harmful one. (GLR's `%merge' feature looked promising, but
   it evaluates both alternatives before merging, so the wrong one
   might produce spurious error messages etc.) */
tree
build_new_dispose (int r_num, tree arg1, tree arg2_id, tree args)
{
  tree t;
  struct predef *pd;
  int is_object = TREE_CODE (TREE_TYPE (arg1)) == POINTER_TYPE && PASCAL_TYPE_OBJECT (TREE_TYPE (TREE_TYPE (arg1)));
  /* Harmless case */
  if (!arg2_id && (!args || !is_object))
    return build_predef_call (r_num, tree_cons (NULL_TREE, arg1, args));
  /* Objects, the interesting case */
  if (is_object)
    {
      tree t;
      if (r_num == p_New)
        {
          if (PASCAL_TYPE_CLASS (TREE_TYPE (arg1)))
            t = TYPE_NAME (TREE_TYPE (t));
          else
            t = TYPE_NAME (TREE_TYPE (TREE_TYPE (arg1)));
          gcc_assert (TREE_CODE (t) == TYPE_DECL);
          t = arg2_id ? build_component_ref (t, arg2_id) : NULL_TREE;
          if (t && !EM (t) && PASCAL_CONSTRUCTOR_METHOD (TREE_OPERAND (t, 1)))
            return build_predef_call (r_num, tree_cons (NULL_TREE, arg1, tree_cons (NULL_TREE, t, args)));
        }
      else
        {
          arg1 = save_expr (arg1);
          t = build_indirect_ref (arg1, NULL);
          t = arg2_id ? build_component_ref (t, arg2_id) : NULL_TREE;
          if (t && !EM (t) && PASCAL_DESTRUCTOR_METHOD (TREE_OPERAND (t, 1)))
            return build_predef_call (r_num, tree_cons (NULL_TREE, arg1, build_tree_list (NULL_TREE, call_method (t, args))));
        }
      error (r_num == p_New ? "constructor expected in object `New'" : "destructor expected in object `Dispose'");
      return error_mark_node;
    }
  /* Spurious parse */
  t = NULL_TREE;
  pd = IDENTIFIER_BUILT_IN_VALUE (arg2_id);
  if (!IDENTIFIER_VALUE (arg2_id) && PD_ACTIVE (pd))
    {
      if (pd->kind == bk_routine && pd->signature[0] != '-' && pd->signature[0] != '>')
        t = build_predef_call (pd->symbol, args);
      else if (!lookup_name (arg2_id))
        {
          error ("invalid use of `%s'", IDENTIFIER_NAME (arg2_id));
          return error_mark_node;
        }
    }
  if (!t)
    t = args ? build_call_or_cast (check_identifier (arg2_id), args) : check_identifier (arg2_id);
  return build_predef_call (r_num, tree_cons (NULL_TREE, arg1, build_tree_list (NULL_TREE, t)));
}

#ifdef GCC_3_3
#include "gt-p-predef.h"
#endif
