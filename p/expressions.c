/*Pascal expressions.

  Copyright (C) 1992-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

  Parts of this file were originally derived from GCC's `c-common.c'.

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

#ifdef GCC_4_0
#include "tree-gimple.h"
#endif


static int implicit_comparison = 0;
int operators_defined = 0;

static void warn_operands (enum tree_code, tree, int);
static tree shorten_compare (tree *, tree *, tree *, enum tree_code *);
static const char *get_op_name (enum tree_code);
static void binary_op_error (enum tree_code);
static tree get_type_name (tree);
static inline tree get_op_id (const char *, const char *, const char *);
static int compatible_types_p (tree, tree);
static int compatible_relop_p (tree, tree);
static tree c_size_in_bytes (tree);
static tree pointer_int_sum (enum tree_code, tree, tree);
static tree pointer_diff (tree, tree);
static tree strip_needless_lists (tree);
static tree do_range_error (tree, const char *);

/* Set the type of a strings, starting at index 1.
   The empty string gets range 1 .. 1, because 1 .. 0 would be invalid.
   Note: TREE_STRING_LENGTH includes a trailing #0 (to output C-compatible
   strings and to avoid changing the backend's output code), but the domain
   doesn't (so the #0 doesn't appear in Pascal string usage). */
void
set_string_length (tree value, int wide_flag, int length)
{
  gcc_assert (length >= 0);
//  length ++;
  TREE_TYPE (value) = build_simple_array_type (p_build_type_variant (
    wide_flag ? wchar_type_node : char_type_node, 1, 0),
    build_range_type (pascal_integer_type_node, integer_one_node,
     length == 0 ? integer_one_node : build_int_2 (length, 0)));
  /* In addition, the string (array) constant is `packed' */
  PASCAL_TYPE_PACKED (TREE_TYPE (value)) = 1;
  TREE_CONSTANT (value) = 1;
  TREE_READONLY (value) = 1;
  TREE_STATIC (value) = 1;
}

tree
build_string_constant (const char *s, int length, int literal)
{
  tree t;
  char *buf = alloca (length + 1);
  memcpy (buf, s, length);
  buf[length] = 0;
  t = build_string (length + 1, buf);
  PASCAL_CST_FRESH (t) = literal;
  set_string_length (t, 0, length);
  return t;
}

tree
build_caret_string_constant (int c)
{
  char tmp = TOUPPER (c) ^ 0x40;
  chk_dialect ("char constants with `^' are", B_D_PASCAL);
  /* It is a single char, but the parser expects it as a string constant. */
  return build_string_constant (&tmp, 1, 1);
}

/* Given a list of STRING_CST nodes, concatenate them into one STRING_CST.
   mode means:
   0: `Concat' or `+'
   1: sequence without separators
   2: implicit for `asm' (insert "\n\t" between the strings)
   3: internal */
tree
combine_strings (tree strings, int mode)
{
  tree value, l, t;
  int length = 1, wide_length = 0, wide_flag = 0, nchars;
  int wchar_bytes = TYPE_PRECISION (wchar_type_node) / BITS_PER_UNIT;
  char *p, *q;

  if (!TREE_CHAIN (strings))
    {
      if (TREE_STRING_LENGTH (TREE_VALUE (strings)) == 1)
        chk_dialect ("the empty string is", NOT_CLASSIC_PASCAL);
      return TREE_VALUE (strings);
    }

  if (!mode)
    chk_dialect ("string concatenation with `+' is", NOT_CLASSIC_PASCAL);
  else if (mode < 3)
    chk_dialect ("string concatenation without `Concat' or `+' is", B_D_PASCAL);

  /* Don't include the #0 at the end of each substring,
     except for the last one.
     Count wide strings and ordinary strings separately. */
  for (l = strings; l; l = TREE_CHAIN (l))
    {
      t = TREE_VALUE (l);
      if (TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (t))) == wchar_type_node)
        {
          wide_length += TREE_STRING_LENGTH (t) - wchar_bytes;
          wide_flag = 1;
          if (mode == 2 && TREE_CHAIN (l)) wide_length += 2 * wchar_bytes;
        }
      else
        {
          length += TREE_STRING_LENGTH (t) - 1;
          if (mode == 2 && TREE_CHAIN (l)) length += 2;
        }
    }

  /* If anything is wide, the non-wides will be converted,
     which makes them take more space. */
  if (wide_flag)
    length = length * wchar_bytes + wide_length;

#ifdef EGCS97
  p = xmalloc (length);
#else
  p = savealloc (length);
#endif

  /* Copy the individual strings into the new combined string.
     If the combined string is wide, convert the chars to ints
     for any individual strings that are not wide. */
  q = p;
  for (l = strings; l; l = TREE_CHAIN (l))
    {
      int len;
      t = TREE_VALUE (l);
      len = TREE_STRING_LENGTH (t) - ((TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (t))) == wchar_type_node) ? wchar_bytes : 1);
      if ((TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (t))) == wchar_type_node) == wide_flag)
        {
          memcpy (q, TREE_STRING_POINTER (t), len);
          q += len;
        }
      else
        {
          int i;
          for (i = 0; i < len; i++)
            {
              if (TYPE_PRECISION (wchar_type_node) == HOST_BITS_PER_SHORT)
                ((short *) q)[i] = TREE_STRING_POINTER (t)[i];
              else
                ((int *) q)[i] = TREE_STRING_POINTER (t)[i];
            }
          q += len * wchar_bytes;
        }
      if (mode == 2 && TREE_CHAIN (l))
        {
          if (!wide_flag)
            {
              *q++ = '\n';
              *q++ = '\t';
            }
          else if (TYPE_PRECISION (wchar_type_node) == HOST_BITS_PER_SHORT)
            {
              ((short *) q)[0] = '\n';
              ((short *) q)[1] = '\t';
              q += 2 * sizeof (short);
            }
          else
            {
              ((int *) q)[0] = '\n';
              ((int *) q)[1] = '\t';
              q += 2 * sizeof (int);
            }
        }
    }
  if (wide_flag)
    for (nchars = 0; nchars < wchar_bytes; nchars++)
      *q++ = 0;
  else
    *q = 0;
#ifdef GCC_4_0
  value = build_string (length, p);
  free (p);
#else
  value = make_node (STRING_CST);
  TREE_STRING_POINTER (value) = p;
  TREE_STRING_LENGTH (value) = length;
#endif
  PASCAL_CST_FRESH (value) = !!mode;
  set_string_length (value, wide_flag, wide_flag ? length / wchar_bytes : length - 1);
  return value;
}

tree
gpc_build_call(tree rtype, tree function, tree params)
#ifndef GCC_4_3
{
  return build3 (CALL_EXPR, rtype, function, params, NULL_TREE);
}
#else
{
  long nargs = list_length (params);
  tree * argarray = (tree *) alloca (nargs * sizeof (tree));
  tree * argp;
  tree tp;
  for(tp = params, argp = argarray; tp;
      tp = TREE_CHAIN(tp), argp++)
      *argp = TREE_VALUE(tp);
  return
    fold_builtin_call_array (rtype,
           function, nargs, argarray);
}
#endif


/* Print a warning if a constant expression had overflow in folding.
   Invoke this function on every expression that the language
   requires to be a constant expression. */
void
constant_expression_warning (tree value)
{
  if ((TREE_CODE (value) == INTEGER_CST || TREE_CODE (value) == REAL_CST
       || TREE_CODE (value) == COMPLEX_CST)
      && TREE_CONSTANT_OVERFLOW (value) && pedantic)
    error ("overflow in constant expression");
}

tree
gpc_build_range_check (tree min, tree max, tree expr, int is_io,
                       int gimplifying)
{
  int chklo = min != NULL_TREE;
  int chkhi = max != NULL_TREE;
          {
#ifndef EGCS97
          tree cond, t;
          expr = save_expr (expr);
          cond = chklo ? build_implicit_pascal_binary_op (LT_EXPR, expr, min) : NULL_TREE;
          if (chkhi)
            {
              tree cond2 = build_implicit_pascal_binary_op (GT_EXPR, expr, max);
              cond = cond ? build_pascal_binary_op (TRUTH_ORIF_EXPR, cond, cond2) : cond2;
            }
          t = save_expr (build3 (COND_EXPR, TREE_TYPE (expr),
                cond, build2 (COMPOUND_EXPR, TREE_TYPE (expr),
                         build_predef_call (is_io ? p_IORangeCheckError :
                                            p_RangeCheckError, NULL_TREE),
                         expr), expr));
          return t;
#else
          int side_effects = TREE_SIDE_EFFECTS (expr);
          tree cond, tv, t;
          tree tmpvar =
#ifdef GCC_4_0
            gimplifying ?
              create_tmp_var (TREE_TYPE (expr), "range_check") :
#endif
              make_new_variable ("range_check", TREE_TYPE (expr));
#ifndef GCC_4_0
          gcc_assert(!gimplifying);
#endif
#ifdef GCC_4_0
          TREE_NO_WARNING (tmpvar) = 1;
#endif
          tv = build2 (MODIFY_EXPR, TREE_TYPE (expr), tmpvar, expr);
          TREE_SIDE_EFFECTS (tv) = 1;
          PASCAL_VALUE_ASSIGNED (tmpvar) = 1;
          cond = chklo ? build_implicit_pascal_binary_op (LT_EXPR,
                               tmpvar, min) : NULL_TREE;
          if (chkhi)
            {
              tree cond2 = build_implicit_pascal_binary_op (GT_EXPR,
                                                            tmpvar, max);
              cond = cond ? build_pascal_binary_op (TRUTH_ORIF_EXPR,
                                 cond, cond2) : cond2;
            }
          t = build2 (COMPOUND_EXPR, TREE_TYPE (tmpvar),
                build_predef_call (is_io ? p_IORangeCheckError :
                                   p_RangeCheckError, NULL_TREE),
                tmpvar /* min? min : max */);
          t = build3 (COND_EXPR, TREE_TYPE (tmpvar), cond, t, tmpvar);
          t = build2 (COMPOUND_EXPR, TREE_TYPE (t), tv, t);
          return t;
#endif
        }
}

tree
do_range_error (tree min, const char * msg)
{
  if (co->pascal_dialect & C_E_O_PASCAL)
    {
      gpc_warning (msg);
      return build2 (COMPOUND_EXPR, TREE_TYPE (min), 
               build_predef_call (p_RangeCheckError, NULL_TREE), min);
    }
  else
    {
      error (msg);
      return error_mark_node;
    }
}

tree
range_check_2 (tree min, tree max, tree expr)
{
  tree low_expr, high_expr;
  int is_cst;
  CHK_EM (expr);
  CHK_EM (min);
  CHK_EM (max);
  if (!ORDINAL_TYPE (TREE_CODE (TREE_TYPE (expr)))
      || contains_discriminant (expr, NULL_TREE)
      || contains_discriminant (min, NULL_TREE)
      || contains_discriminant (max, NULL_TREE))
    return expr;
  STRIP_TYPE_NOPS (expr);
  expr = fold (expr);
  is_cst = TREE_CODE (expr) == INTEGER_CST;
  if (is_cst && (const_lt (expr, min) || const_lt (max, expr)))
    return do_range_error (min, "constant out of range");
  low_expr  = is_cst ? expr : TYPE_MIN_VALUE (TREE_TYPE (expr));
  high_expr = is_cst ? expr : TYPE_MAX_VALUE (TREE_TYPE (expr));
  if (const_lt (max, low_expr) || const_lt (high_expr, min))
    return do_range_error (min, "ranges of value and target are disjoint");
  if (co->range_checking)
    {
      int chklo = TREE_CODE (low_expr)  != INTEGER_CST || TREE_CODE (min) != INTEGER_CST || const_lt (low_expr, min);
      int chkhi = TREE_CODE (high_expr) != INTEGER_CST || TREE_CODE (max) != INTEGER_CST || const_lt (max, high_expr);
      if (chklo || chkhi)
        {
          enum tree_code code;
          if (!chklo)
            min = NULL_TREE;
          if (!chkhi)
            max = NULL_TREE;

          if (TREE_SIDE_EFFECTS (expr))
            return gpc_build_range_check(min, max, expr, co->range_checking>1, 0);
          else if (co->range_checking>1)
            code = IO_RANGE_CHECK_EXPR;
          else
            code = RANGE_CHECK_EXPR;
          return build3 (code, TREE_TYPE (expr), 
                      min, max, expr);
        }
    }
  return expr;
}

tree
range_check (tree type, tree expr)
{
  if (!ORDINAL_TYPE (TREE_CODE (type)))
    return expr;
  return range_check_2 (TYPE_MIN_VALUE (type), TYPE_MAX_VALUE (type), expr);
}

tree
convert_and_check (tree type, tree expr)
{
  tree ttype, stype;
  CHK_EM (expr);
  if (contains_discriminant (expr, NULL_TREE))
    return build1 (CONVERT_EXPR, type, expr);
  /* Don't complain about `High (WordBool)' etc. */
  if (TREE_CODE (TREE_TYPE (expr)) == BOOLEAN_TYPE && TREE_CODE (type) == BOOLEAN_TYPE
      && const_lt (TYPE_MAX_VALUE (type), TYPE_MAX_VALUE (TREE_TYPE (expr))))
    expr = build_pascal_binary_op (NE_EXPR, expr, boolean_false_node);
  if (TREE_CODE (type) == TREE_CODE (TREE_TYPE (expr))
        && PASCAL_CHAR_TYPE (type) == PASCAL_CHAR_TYPE (TREE_TYPE (expr))
      || !ORDINAL_TYPE (TREE_CODE (type)))
    return convert (type, range_check (type, expr));
  /* Type conversions: Particularly tricky are cases such as casting a value of
     type -100 .. 100 to 'a' .. 'z'. We can neither convert first and check
     then, nor convert the target bounds back to the source type; in both cases,
     the values might be out of range already. So we need to get the base-types
     *and* always convert to the larger type (since converting a negative value
     to Char would still overflow. */
  stype = base_type (TREE_TYPE (expr));
  ttype = base_type (type);
  /* @@@@ Strictly speaking enumeral type may have so many values
     that it does not fit into integer, but we disregard this... */
  if (TREE_CODE (ttype) == ENUMERAL_TYPE)
    {
      if (TYPE_PRECISION (integer_type_node) > TYPE_PRECISION (stype))
        stype = integer_type_node;
      return convert (type, range_check_2 (
                              convert (stype, TYPE_MIN_VALUE (type)),
                              convert (stype, TYPE_MAX_VALUE (type)),
                              convert (stype, expr)));
    }
  /* @@@@ The code below may still get checks wrong due to signed/unsigned
     convertion */
  if (TYPE_PRECISION (ttype) >= TYPE_PRECISION (stype))
    return convert (type, range_check (type, convert (ttype, expr)));
  else
    return convert (type, range_check_2 (convert (stype, TYPE_MIN_VALUE (type)),
                                         convert (stype, TYPE_MAX_VALUE (type)), expr));
}

tree
discriminant_mismatch_error (tree cond)
{
  cond = fold (cond);
  if (TREE_CODE (cond) == INTEGER_CST && !integer_zerop (cond)
      && (pedantic || !(co->pascal_dialect & C_E_O_PASCAL)))
    error ("actual schema discriminants do not match");
  return fold (build3 (COND_EXPR, integer_type_node, cond,
                 build_predef_call (p_DiscriminantsMismatchError, NULL_TREE),
                 integer_zero_node));
}

/* Return an expression to compare actual discriminants and report an error if
   they do not match. The arguments can be expressions (pre- or discriminated)
   or types (discriminated). */
tree
check_discriminants (tree x, tree y)
{
  tree fx, fy, cond = NULL_TREE;
  tree tx = TREE_CODE_CLASS (TREE_CODE (x)) == tcc_type ? x : TREE_TYPE (x);
  tree ty = TREE_CODE_CLASS (TREE_CODE (y)) == tcc_type ? y : TREE_TYPE (y);
  if (PASCAL_TYPE_SCHEMA (tx) && PASCAL_TYPE_SCHEMA (ty)
      && TYPE_LANG_BASE (tx) == TYPE_LANG_BASE (ty))
    {
      if (TYPE_MAIN_VARIANT (tx) == TYPE_MAIN_VARIANT (ty))
        return integer_zero_node;
      for (fx = TYPE_FIELDS (tx), fy = TYPE_FIELDS (ty); fx && fy && PASCAL_TREE_DISCRIMINANT (fx);
           fx = TREE_CHAIN (fx), fy = TREE_CHAIN (fy))
        {
          tree dx = DECL_LANG_FIXUPLIST (fx), dy = DECL_LANG_FIXUPLIST (fy), cond1;
          gcc_assert (PASCAL_TREE_DISCRIMINANT (fy));
          if (!dx || TREE_CODE (dx) == TREE_LIST)
            {
              gcc_assert (x != tx);
              dx = simple_component_ref (x, fx);
            }
          if (!dy || TREE_CODE (dy) == TREE_LIST)
            {
              gcc_assert (y != ty);
              dy = simple_component_ref (y, fy);
            }
          cond1 = build_pascal_binary_op (NE_EXPR, dx, dy);
          cond = cond ? build_pascal_binary_op (TRUTH_ORIF_EXPR, cond, cond1) : cond1;
        }
    }
  else
    return error_mark_node;
  gcc_assert (cond);
  return discriminant_mismatch_error (cond);
}

static const char *
get_op_name (enum tree_code code)
{
  switch (code)
  {
#ifdef GCC_4_3
    case POINTER_PLUS_EXPR:
#endif
    case PLUS_EXPR:        return "+";
    case MINUS_EXPR:       return "-";
    case MULT_EXPR:        return "*";
    case MAX_EXPR:         return "Max";
    case MIN_EXPR:         return "Min";
    case LE_EXPR:          return "<=";
    case GE_EXPR:          return ">=";
    case LT_EXPR:          return "<";
    case GT_EXPR:          return ">";
    case EQ_EXPR:          return "=";
    case NE_EXPR:          return "<>";
    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:   return "mod";
    case TRUNC_DIV_EXPR:
    case FLOOR_DIV_EXPR:   return "div";
    case RDIV_EXPR:        return "/";
    case POW_EXPR:         return "pow";
    case POWER_EXPR:       return "**";
    case TRUTH_NOT_EXPR:   return "not";
    case BIT_AND_EXPR:
    case TRUTH_AND_EXPR:
    case TRUTH_ANDIF_EXPR: return "and";
    case BIT_IOR_EXPR:
    case TRUTH_OR_EXPR:
    case TRUTH_ORIF_EXPR:  return "or";
    case BIT_XOR_EXPR:
    case TRUTH_XOR_EXPR:   return "xor";
    case IN_EXPR:          return "in";
    case SYMDIFF_EXPR:     return "><";
    case LSHIFT_EXPR:      return "shl";
    case RSHIFT_EXPR:      return "shr";
    default:               gcc_unreachable ();
  }
}

/* Print an error message for invalid operands to arith operation CODE.
   NOP_EXPR is used as a special case (see truthvalue_conversion). */
static void
binary_op_error (enum tree_code code)
{
  if (code == NOP_EXPR)
    error ("invalid type conversion");
  else
    error ("invalid operands to `%s'", get_op_name (code));
}

static tree
get_type_name (tree t)
{
  if (TYPE_NAME (t))
    t = TYPE_NAME (t);
  else if (TREE_CODE (t) == REFERENCE_TYPE && TYPE_NAME (TREE_TYPE (t)))
    t = TYPE_NAME (TREE_TYPE (t));
  if (t && TREE_CODE (t) == TYPE_DECL)
    t = DECL_NAME (t);
  return (t && TREE_CODE (t) == IDENTIFIER_NODE) ? t : NULL_TREE;
}

/* This is a separate function, so ACONCAT releases its memory early. */
static inline tree
get_op_id (const char *op_id, const char *n1, const char *n2)
{
  return get_identifier (ACONCAT ((op_id, "_", (*n1 >= 'A' && *n1 <= 'Z') ? "" : "OP", n1,
                                          "_", (*n2 >= 'A' && *n2 <= 'Z') ? "" : "OP", n2, NULL)));
}

/* Return an identifier_node (if new is set; NULL_TREE in case of error) or a
   FUNCTION_DECL (if new is not set; NULL_TREE if not found) for a user-defined
   operator. Both args may be expression, type or type_decl nodes. */
tree
get_operator (const char *op_id, const char *op_name, tree arg1, tree arg2, int new)
{
  tree found = NULL_TREE, t1, t2, a1, a2, next1, next2;

  /* If no user operators have been (or are being) defined, don't waste time looking for any. */
  if (new)
    operators_defined = 1;
  if (!operators_defined)
    return NULL_TREE;

  arg1 = string_may_be_char (arg1, 0);
  arg2 = string_may_be_char (arg2, 0);
  STRIP_TYPE_NOPS (arg1);
  STRIP_TYPE_NOPS (arg2);

  /* For "fresh" constants try the most basic and the longest type.
     For Char constants try Char and String. */
  if (TREE_CODE_CLASS (TREE_CODE (arg1)) == tcc_constant
       && PASCAL_CST_FRESH (arg1))
    {
      if (TREE_CODE (arg1) == INTEGER_CST &&
          TYPE_IS_INTEGER_TYPE (TREE_TYPE (arg1)))
        {
          found = get_operator (op_id, op_name, pascal_integer_type_node, arg2, new);
          arg1 = long_long_integer_type_node;
        }
      if (TREE_CODE (arg1) == REAL_CST)
        {
          found = get_operator (op_id, op_name, double_type_node, arg2, new);
          arg1 = long_double_type_node;
        }
      if (TREE_CODE (arg1) == INTEGER_CST &&
          TYPE_IS_CHAR_TYPE (TREE_TYPE (arg1)))
        {
          found = get_operator (op_id, op_name, char_type_node, arg2, new);
          arg1 = string_schema_proto_type;
        }
      if (found)
        return found;
    }
  if (TREE_CODE_CLASS (TREE_CODE (arg1)) != tcc_type
       && is_string_compatible_type (arg1, 0))
    {
      found = get_operator (op_id, op_name, string_schema_proto_type, arg2, new);
      if (found)
        return found;
    }
  if (TREE_CODE_CLASS (TREE_CODE (arg2)) == tcc_constant
       && PASCAL_CST_FRESH (arg2))
    {
      if (TREE_CODE (arg2) == INTEGER_CST &&
          TYPE_IS_INTEGER_TYPE (TREE_TYPE (arg2)))
        {
          found = get_operator (op_id, op_name, arg1, pascal_integer_type_node, new);
          arg2 = long_long_integer_type_node;
        }
      if (TREE_CODE (arg2) == INTEGER_CST &&
          TYPE_IS_CHAR_TYPE (TREE_TYPE (arg2)))
        {
          found = get_operator (op_id, op_name, arg1, char_type_node, new);
          arg2 = string_schema_proto_type;
        }
      if (TREE_CODE (arg2) == REAL_CST)
        {
          found = get_operator (op_id, op_name, arg1, double_type_node, new);
          arg2 = long_double_type_node;
        }
      if (found)
        return found;
    }
  if (TREE_CODE_CLASS (TREE_CODE (arg2)) != tcc_type
       && is_string_compatible_type (arg2, 0))
    {
      found = get_operator (op_id, op_name, arg1, string_schema_proto_type, new);
      if (found)
        return found;
    }
  if (!TYPE_P (arg1))
    arg1 = TREE_TYPE (arg1);
  if (!TYPE_P (arg2))
    arg2 = TREE_TYPE (arg2);
  if (!arg1 || EM (arg1) || !arg2 || EM (arg2))
    return NULL_TREE;

  /* Look through all variants, but try the given type first to get
     the expected name when defining a new operator. */
  for (a1 = arg1, next1 = TYPE_MAIN_VARIANT (arg1); a1;
       a1 = next1, next1 = a1 ? TYPE_NEXT_VARIANT (a1) : NULL_TREE)
    if ((t1 = get_type_name (a1)))
      for (a2 = arg2, next2 = TYPE_MAIN_VARIANT (arg2); a2;
           a2 = next2, next2 = a2 ? TYPE_NEXT_VARIANT (a2) : NULL_TREE)
        if ((t2 = get_type_name (a2)))
          {
            const char *n1 = IDENTIFIER_POINTER (t1), *n2 = IDENTIFIER_POINTER (t2);
            tree result = get_op_id (op_id, n1, n2);
            tree t = new ? result : lookup_name (result);
            if (t)
              {
                gcc_assert (new || TREE_CODE (t) == FUNCTION_DECL);
                if (!IDENTIFIER_SPELLING (result)
                    && op_name
                    && IDENTIFIER_SPELLING (t1)
                    && IDENTIFIER_SPELLING (t2))
                  {
                    char *s = ACONCAT ((op_name, " (", IDENTIFIER_SPELLING (t1),
                                                 ", ", IDENTIFIER_SPELLING (t2),
                                                 ")", NULL));
                    set_identifier_spelling (result, s, NULL, 0, 0);
                  }
                return t;
              }
          }
  return NULL_TREE;
}

/* A user-defined operator expression is converted to a function call. */
tree
build_operator_call (tree op, tree exp1, tree exp2, int pxsc)
{
  tree fun = get_operator (IDENTIFIER_POINTER (op), NULL, exp1, exp2, 0);
  if (pxsc)
    chk_dialect ("overloaded and rounding operators are", PASCAL_SC);
  CHK_EM (exp1);
  CHK_EM (exp2);
  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (exp1)) || PASCAL_TYPE_RESTRICTED (TREE_TYPE (exp2)))
    error ("invalid binary operation with restricted value");
  if (fun)
    return build_routine_call (fun, tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));
  if (pxsc)
    error ("PXSC operators are not built-in but must be overloaded");
  else
    {
      tree t = lookup_name (op);
      if (t && TREE_CODE (t) == OPERATOR_DECL)
        error ("invalid use of operator `%s'", IDENTIFIER_NAME (op));
      else
        error ("syntax error before `%s'", IDENTIFIER_NAME (op));
    }
  return error_mark_node;
}

static void
warn_operands (enum tree_code outer, tree exp_inner, int rhs)
{
#define REL_OP(code) \
  (code == EQ_EXPR || code == LT_EXPR || code == GT_EXPR \
   || code == NE_EXPR || code == LE_EXPR || code == GE_EXPR || code == IN_EXPR)
#define OR_OP(code) \
  (code == BIT_IOR_EXPR || code == TRUTH_OR_EXPR || code == TRUTH_ORIF_EXPR \
   || code == BIT_XOR_EXPR || code == TRUTH_XOR_EXPR)
#define AND_OP(code) \
  (code == BIT_AND_EXPR || code == TRUTH_AND_EXPR || code == TRUTH_ANDIF_EXPR)
  /* FIXME: implement for 4.3 */
#ifndef GCC_4_3
  if (co->warn_parentheses && HAS_EXP_ORIGINAL_CODE_FIELD (exp_inner))
    {
      enum tree_code inner = EXP_ORIGINAL_CODE (exp_inner);
      if ((AND_OP (inner) && OR_OP (outer))
          || ((OR_OP (inner) || AND_OP (inner) || (!rhs && inner == TRUTH_NOT_EXPR)) && REL_OP (outer)))
        gpc_warning ("suggest parentheses around `%s' in operand of `%s'",
                 get_op_name (inner), get_op_name (outer));
    }
#endif
}

/* @@ Kludge to solve problems with Boolean shortcut operators. (fjf226*.pas)
      The problem is that expressions may cause assignments to temporary
      variables to be *expanded* before the expressions are used. The
      work-around implemented here is to also expand the operands of the
      short-cut operators and wrap up the RHS one in a conditional statement.
      So we actually contribute to the problem that we then work-around.
      Statement-expressions might be a better solution.
      As a side benefit, we can output line number information for each
      operand in the parser, so the evaluation of such shortcut operations
      can be traced in the debugger. */
tree
start_boolean_binary_op (enum tree_code code, tree exp1)
{
  if (TREE_CODE (TREE_TYPE (exp1)) == BOOLEAN_TYPE
      && current_function_decl
      && (code == TRUTH_ANDIF_EXPR || code == TRUTH_ORIF_EXPR || co->short_circuit))
    {
      tree tempvar = make_new_variable ("fjf226", boolean_type_node);
      expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, exp1));
      expand_start_cond ((code == TRUTH_AND_EXPR || code == TRUTH_ANDIF_EXPR)
        ? tempvar : build_unary_op (TRUTH_NOT_EXPR, tempvar, 0), 0);
      mark_temporary_levels ();
      return tempvar;
    }
  else
    return NULL_TREE;
}

tree
finish_boolean_binary_op (enum tree_code code, tree exp1, tree exp2, tree tempvar)
{
  if (tempvar)
    {
      if (TREE_CODE (TREE_TYPE (exp2)) == FUNCTION_TYPE)
        exp2 = probably_call_function (exp2);
      if (TREE_CODE (TREE_TYPE (exp2)) != BOOLEAN_TYPE)
        {
          release_temporary_levels ();
          expand_end_cond ();  /* don't leave it open */
          exp1 = tempvar;  /* don't evaluate the expression again */
        }
      else
        {
          int is_cst = 0;
          tree e1 = exp1, e2 = exp2, t;
          STRIP_TYPE_NOPS (e1);
          e1 = fold (e1);
          STRIP_TYPE_NOPS (e2);
          e2 = fold (e2);
          if (TREE_CODE (e1) == INTEGER_CST && TREE_CODE (e2) == INTEGER_CST)
            is_cst = 1;
          else
            expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, exp2));
          release_temporary_levels ();
          expand_end_cond ();
          if (!is_cst)
            {
              warn_operands (code, exp1, 0);
              warn_operands (code, exp2, 1);
              t = set_exp_original_code (non_lvalue (tempvar), code);
              TREE_SIDE_EFFECTS (t) |= TREE_SIDE_EFFECTS (exp1) || TREE_SIDE_EFFECTS (exp2);
              return t;
            }
        }
    }
  return parser_build_binary_op (code, exp1, exp2);
}

/* Set operation code. ERROR_MARK means no (relevant) operation.
   NOP_EXPR stands for parentheses which have special treatment in ISO modes. */
tree
set_exp_original_code (tree t, enum tree_code code)
{
  CHK_EM (t);

  /* Ignore codes that warn_operands doesn't check to avoid extra effort. */
  switch (code)
  {
    case NOP_EXPR:  /* parentheses */
    case EQ_EXPR:
    case LT_EXPR:
    case GT_EXPR:
    case NE_EXPR:
    case LE_EXPR:
    case GE_EXPR:
    case IN_EXPR:
    case BIT_IOR_EXPR:
    case TRUTH_OR_EXPR:
    case TRUTH_ORIF_EXPR:
    case BIT_XOR_EXPR:
    case TRUTH_XOR_EXPR:
    case BIT_AND_EXPR:
    case TRUTH_AND_EXPR:
    case TRUTH_ANDIF_EXPR:
    case TRUTH_NOT_EXPR: break;
    default: code = ERROR_MARK;
  }

  /* Flag constants in parentheses for ISO 7185. */
  if ((TREE_CODE_CLASS (TREE_CODE (t)) == tcc_constant
        || TREE_CODE (t) == NON_LVALUE_EXPR)
      && PASCAL_CST_PARENTHESES (t) != (code == NOP_EXPR))
    {
      t = copy_node (t);
      PASCAL_CST_PARENTHESES (t) = code == NOP_EXPR;
    }

  /* ISO Pascal doesn't allow parentheses around lvalues. We cannot flag the
     expression and check it on usage, as it might be something non-temporary
     as a VAR_DECL. Instead we put a NON_LVALUE_EXPR around it here. Do this
     only in ISO mode, as other dialects allow parentheses around lvalues. */
  if (code == NOP_EXPR
      && !((co->pascal_dialect & C_E_O_PASCAL) && lvalue_p (t)))
    code = ERROR_MARK;  /* just clear any code possibly set before */

  if (!HAS_EXP_ORIGINAL_CODE_FIELD (t) || code == NOP_EXPR)
    {
      tree old = t;
      if (code == ERROR_MARK)
        return t;
      /* A NON_LVALUE_EXPR around STRING_CSTs etc. doesn't work well.
         But they shouldn't be produced by the operations listed above
         and are already no lvalues (WRT ISO parentheses). */
      gcc_assert (TREE_CODE (t) != STRING_CST);
      gcc_assert (TREE_CODE (t) != CONSTRUCTOR);
      t = build1 (NON_LVALUE_EXPR, TREE_TYPE (old), old);
      TREE_CONSTANT (t) = TREE_CONSTANT (old);
      TREE_OVERFLOW (t) = TREE_OVERFLOW (old);
      PASCAL_CST_PARENTHESES (t) = code == NOP_EXPR;
    }
  SET_EXP_ORIGINAL_CODE (t, code);
  return t;
}

/* Return 1 if a + 1 < b for INTEGER_CST nodes, optimized to save building and
   folding expressions most of the time. */
int
const_plus1_lt (tree a, tree b)
{
  return const_lt (a, b)
    && !(TREE_INT_CST_LOW (a) + 1 == TREE_INT_CST_LOW (b)
         && tree_int_cst_equal (fold (build2 (PLUS_EXPR,
             long_long_integer_type_node,
             convert (long_long_integer_type_node, a),
             convert (long_long_integer_type_node, integer_one_node))), b));
}

/* Perform set operations on constant constructors. This function assumes the
   constructors are sorted and merged as build_set_constructor does. */
tree
const_set_constructor_binary_op (enum tree_code code, tree e0, tree e1)
{
  tree e[2], v[2], lo = NULL_TREE, vc, res = NULL_TREE;
  int on[2], out0 = 0, vc_on, mask, ne = 0;
  switch (code)
  {
    case MINUS_EXPR:   mask = 2; break;
    case MULT_EXPR:    mask = 8; break;
    case SYMDIFF_EXPR: mask = 6; break;
    default:           mask = 0; break;
  }
  on[0] = on[1] = 0;
  e[0] = e0;
  e[1] = e1;
  v[0] = e0 ? TREE_PURPOSE (e0) : NULL_TREE;
  v[1] = e1 ? TREE_PURPOSE (e1) : NULL_TREE;
  while (v[0] || v[1])
    {
      int a = 0, b = 1, i;
      if (!v[0])
        a = 1;
      else if (!v[1])
        b = 0;
      else
        {
          gcc_assert (TREE_CODE (v[0]) == INTEGER_CST && TREE_CODE (v[1]) == INTEGER_CST);
          if (on[0] == on[1] ? const_lt (v[a], v[b]) :
              on[0] > on[1] ? const_plus1_lt (v[a], v[b]) : !const_lt (v[b], v[a]))
            b = 0;
          else if (on[0] == on[1] ? const_lt (v[b], v[a]) :
                   on[1] > on[0] ? const_plus1_lt (v[b], v[a]) : !const_lt (v[a], v[b]))
            a = 1;
        }
      vc = v[a];
      vc_on = on[a];
      for (i = a; i <= b; i++)
        {
          on[i] = !on[i];
          if (!e[i])
            v[i] = NULL_TREE;
          else if (on[i])
            {
              v[i] = TREE_VALUE (e[i]);
              e[i] = TREE_CHAIN (e[i]);
            }
          else
            v[i] = TREE_PURPOSE (e[i]);
        }
      if (mask)  /* arithmetics */
        {
          int out1 = mask & (1 << (on[0] + 2 * on[1]));
          if (out1 && !out0)
            lo = !vc_on ? vc : fold (build2 (PLUS_EXPR, TREE_TYPE (vc),
               vc, convert (TREE_TYPE (vc), integer_one_node)));
          else if (out0 && !out1)
            {
              tree hi = vc_on ? vc : fold (build2 (MINUS_EXPR, TREE_TYPE (vc),
                   vc, convert (TREE_TYPE (vc), integer_one_node)));
              gcc_assert (TREE_CODE (lo) == INTEGER_CST &&
                          TREE_CODE (hi) == INTEGER_CST);
              res = tree_cons (lo, hi, res);
              lo = NULL_TREE;
            }
          out0 = out1;
        }
      else  /* comparisons */
        if (on[0] != on[1])
          {
            switch (code)
            {
              case NE_EXPR: return boolean_true_node;
              case EQ_EXPR: return boolean_false_node;
              case GE_EXPR:
              case GT_EXPR: if (on[1])
                              return boolean_false_node;
                            break;
              case LE_EXPR:
              case LT_EXPR: if (on[0])
                              return boolean_false_node;
                            break;
              default:      gcc_unreachable ();
            }
            ne = 1;
          }
    }
  gcc_assert (!on[0] && !on[1] && !lo);
  if (mask)
    return build_set_constructor (res);
  switch (code)
  {
    case NE_EXPR: return boolean_false_node;
    case EQ_EXPR:
    case LE_EXPR:
    case GE_EXPR: return boolean_true_node;
    case GT_EXPR:
    case LT_EXPR: return ne ? boolean_true_node : boolean_false_node;
    default:      gcc_unreachable ();
  }
}

/* This is the entry point used by the parser for binary operators in the input.
   In addition to constructing the expression, we check for operands that were
   combined with other binary operators in a way that is likely to confuse the
   user. (Parentheses clear EXP_ORIGINAL_CODE to prevent these warnings.) */
tree
parser_build_binary_op (enum tree_code code, tree exp1, tree exp2)
{
  tree result, tt1, tt2;
  const char *op_name, *op_name2;
  enum tree_code t1, t2;

  CHK_EM (TREE_TYPE (exp1));
  CHK_EM (TREE_TYPE (exp2));
  DEREFERENCE_SCHEMA (exp1);
  DEREFERENCE_SCHEMA (exp2);

  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (exp1)) || PASCAL_TYPE_RESTRICTED (TREE_TYPE (exp2)))
    error ("invalid operation with a restricted value");

  /* Call functions. */
  if (TREE_CODE (TREE_TYPE (exp1)) == FUNCTION_TYPE)
    exp1 = probably_call_function (exp1);
  if (TREE_CODE (TREE_TYPE (exp2)) == FUNCTION_TYPE)
    exp2 = probably_call_function (exp2);

  /* Check for string constants being chars. */
  if (TREE_CODE (exp1) == STRING_CST && TREE_STRING_LENGTH (exp1) == 2)
    exp1 = string_may_be_char (exp1, 0);
  if (TREE_CODE (exp2) == STRING_CST && TREE_STRING_LENGTH (exp2) == 2)
    exp2 = string_may_be_char (exp2, 0);

  /* Look if this is a user-defined operator which must be converted to a function call. */
  op_name2 = NULL;
  switch (code)
  {
    case PLUS_EXPR:        op_name = "BPlus";    break;
    case MINUS_EXPR:       op_name = "BMinus";   break;
    case MULT_EXPR:        op_name = "BMult";    break;
    case RDIV_EXPR:        op_name = "RDiv";     break;
    case TRUNC_DIV_EXPR:   op_name = "Div";      break;
    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:   op_name = "Mod";      break;
    case POWER_EXPR:       op_name = "RPower";   break;
    case POW_EXPR:         op_name = "Pow";      break;
    case LSHIFT_EXPR:      op_name = "Shl";      break;
    case RSHIFT_EXPR:      op_name = "Shr";      break;
    case IN_EXPR:          op_name = "In";       break;
    case LT_EXPR:          op_name = "LT";       break;
    case EQ_EXPR:          op_name = "EQ";       break;
    case GT_EXPR:          op_name = "GT";       break;
    case NE_EXPR:          op_name = "NE";       break;
    case GE_EXPR:          op_name = "GE";       break;
    case LE_EXPR:          op_name = "LE";       break;
    case TRUTH_AND_EXPR:   op_name = "And";      break;
    case TRUTH_ANDIF_EXPR: op_name = "And_then"; op_name2 = "SAnd"; /* @@ */ break;
    case TRUTH_OR_EXPR:    op_name = "Or";       break;
    case TRUTH_ORIF_EXPR:  op_name = "Or_else";  op_name2 = "SOr"; /* @@ */ break;
    case TRUTH_XOR_EXPR:   op_name = "Xor";      break;
    case SYMDIFF_EXPR:     op_name = "SymDiff";  break;
    default:               op_name = NULL;  /* `Min', `Max', ... */
  }
  if (op_name)
    {
      tree func = get_operator (op_name, NULL, exp1, exp2, 0);
      if (!func && op_name2)
        func = get_operator (op_name2, NULL, exp1, exp2, 0);
      if (func)
        return build_routine_call (func, tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));
    }

  /* @@ This was in the parser before, but for overloaded operators both
        the type checking and the joining of `pow' and `**' is too early
        there (maur7.pas). It's probably not the best place here, but
        operator overloading will have to be rewritten, anyway, etc. ... */
  if (code == POWER_EXPR)
    {
      chk_dialect_name ("**", E_O_M_PASCAL);
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (exp2)))
        exp2 = convert (TREE_TYPE (real_zero_node), exp2);
      if (TREE_CODE (TREE_TYPE (exp2)) != REAL_TYPE)
        {
          error ("`**' exponent is not of real or integer type");
          return error_mark_node;
        }
    }
  else if (code == POW_EXPR)
    {
      if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (exp2)))
        {
          error ("`pow' exponent is not of integer type");
          return error_mark_node;
        }
    }
  else if (code == TRUTH_OR_EXPR)
    {
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (exp1)))
        {
          code = BIT_IOR_EXPR;
          chk_dialect ("bitwise `or' is", B_D_M_PASCAL);
        }
      else if (co->short_circuit)
        code = TRUTH_ORIF_EXPR;
    }
  else if (code == TRUTH_AND_EXPR)
    {
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (exp1)))
        {
          code = BIT_AND_EXPR;
          chk_dialect ("bitwise `and' is", B_D_M_PASCAL);
        }
      else if (co->short_circuit)
        code = TRUTH_ANDIF_EXPR;
    }
  else if (code == TRUTH_XOR_EXPR &&
           TYPE_IS_INTEGER_TYPE (TREE_TYPE (exp1)))
    {
      code = BIT_XOR_EXPR;
      chk_dialect ("bitwise `xor' is", B_D_M_PASCAL);
    }

  tt1 = TREE_TYPE (exp1);
  t1 = TREE_CODE (tt1);
  tt2 = TREE_TYPE (exp2);
  t2 = TREE_CODE (tt2);

  if (!co->pointer_arithmetic
      && (t1 == POINTER_TYPE || t2 == POINTER_TYPE)
      && code != EQ_EXPR
      && code != NE_EXPR)
    {
      error ("only `=' and `<>' operators are allowed for pointers");
      ptrarith_inform ();
    }

  /* @@@@ Do some type-checking (fjf547*.pas). This is by far not enough. */
  switch (code)
  {
    case PLUS_EXPR:
      if (!((IS_NUMERIC (tt1) && IS_NUMERIC (tt2))
            || (t1 == POINTER_TYPE && TYPE_IS_INTEGER_TYPE (tt2))
            || (t1 == SET_TYPE && t2 == SET_TYPE)
            ||  (is_string_compatible_type (exp1, 1) && is_string_compatible_type (exp2, 1))))
        {
          binary_op_error (code);
          return error_mark_node;
        }
      break;
    case MINUS_EXPR:
      if (!((IS_NUMERIC (tt1) && IS_NUMERIC (tt2))
            || (t1 == POINTER_TYPE &&
                (t2 == POINTER_TYPE || TYPE_IS_INTEGER_TYPE (tt2)))
            || (t1 == SET_TYPE && t2 == SET_TYPE)))
        {
          binary_op_error (code);
          return error_mark_node;
        }
      break;
    case MULT_EXPR:
      if (!((IS_NUMERIC (tt1) && IS_NUMERIC (tt2))
            || (t1 == SET_TYPE && t2 == SET_TYPE)))
        {
          binary_op_error (code);
          return error_mark_node;
        }
      break;
    case RDIV_EXPR:
    case TRUNC_DIV_EXPR:
    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:
    case POWER_EXPR:
    case LSHIFT_EXPR:
    case RSHIFT_EXPR:
      if (!IS_NUMERIC (tt1) || !IS_NUMERIC (tt2))
        {
          binary_op_error (code);
          return error_mark_node;
        }
      break;
    default: /* NOTHING */;
  }

  result = build_pascal_binary_op (code, exp1, exp2);
  if (TREE_CODE_CLASS (TREE_CODE (result)) == tcc_constant
       && TREE_OVERFLOW (result))
    {
      TREE_OVERFLOW (result) = 0;
      error ("constant overflow in expression");
    }
  warn_operands (code, exp1, 0);
  warn_operands (code, exp2, 1);
  return set_exp_original_code (result, code);
}

/* Do some checks and conversions and call build_binary_op. */
tree
build_pascal_binary_op (enum tree_code code, tree exp1, tree exp2)
{
  enum tree_code t1 = TREE_CODE (exp1), t2 = TREE_CODE (exp2);
  tree tt1 = TREE_TYPE (exp1), tt2 = TREE_TYPE (exp2);
  tree result;

  CHK_EM (tt1);
  CHK_EM (tt2);

  if (TYPE_IS_INTEGER_TYPE (tt1)
      && TYPE_IS_INTEGER_TYPE (tt2)
      && code != RDIV_EXPR
      && code != RSHIFT_EXPR
      && code != LSHIFT_EXPR
      && code != TRUNC_MOD_EXPR
      && code != FLOOR_MOD_EXPR
      && code != EQ_EXPR
      && code != NE_EXPR
      && code != LE_EXPR
      && code != GE_EXPR
      && code != LT_EXPR
      && code != GT_EXPR)
    {
      tree common_integer_type = select_integer_type (exp1, exp2, code);
      exp1 = convert (common_integer_type, exp1);
      exp2 = convert (common_integer_type, exp2);
    }

  /* Convert set constructors to sets. */
  if (t1 == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (tt1) == SET_TYPE)
    exp1 = construct_set (exp1, NULL_TREE, 1);
  if (t2 == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (tt2) == SET_TYPE && code != IN_EXPR)
    exp2 = construct_set (exp2, NULL_TREE, 1);

  tt1 = TREE_TYPE (exp1);
  tt2 = TREE_TYPE (exp2);
  CHK_EM (tt1);
  CHK_EM (tt2);
  t1 = TREE_CODE (tt1);
  t2 = TREE_CODE (tt2);

  /* @@ Hmm? A left shift may require the last bit of LongestCard -- but
        then again, it might require a sign. At least use an unsigned
        type when we know the left operand is unsigned. In the general
        case (left operand is variable), it may depend on the actual value
        which type (if any) fits. -- Frank */
  if (code == LSHIFT_EXPR && TYPE_IS_INTEGER_TYPE (tt1) &&
      TYPE_IS_INTEGER_TYPE (tt2))
    {
      tree t = (TYPE_UNSIGNED (tt1)
                || (TREE_CODE (exp1) == INTEGER_CST &&
                    !INT_CST_LT (exp1, integer_zero_node)))
               ? long_long_unsigned_type_node
               : long_long_integer_type_node;
      exp1 = convert (t, exp1);
    }

  if (code == POWER_EXPR || code == POW_EXPR)
    return build_predef_call ((code == POW_EXPR) ? p_pow : LEX_POWER,
             tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));

  /* Optimize arithmetics with exactly one complex operand (except
     "Real / Complex" which is more complicated and doesn't gain so much). */
  if ((code == PLUS_EXPR || code == MINUS_EXPR || code == MULT_EXPR || code == RDIV_EXPR)
      && ((t1 == COMPLEX_TYPE) ^ (t2 == COMPLEX_TYPE))
      && !(code == RDIV_EXPR && t2 == COMPLEX_TYPE))
    {
      int c_left = t1 == COMPLEX_TYPE, minus_rc = code == MINUS_EXPR && !c_left;
      tree c_exp = save_expr (c_left ? exp1 : exp2);
      tree c_real = build_unary_op (REALPART_EXPR, c_exp, 1);
      tree c_imag = build_unary_op (IMAGPART_EXPR, c_exp, 1);
      tree r_exp = save_expr (convert (TREE_TYPE (c_real), c_left ? exp2 : exp1));
      return build2 (COMPLEX_EXPR, TREE_TYPE (c_exp),
        minus_rc ? build_pascal_binary_op (code, r_exp, c_real) :
                   build_pascal_binary_op (code, c_real, r_exp),
        (code == PLUS_EXPR || code == MINUS_EXPR) ?
          (minus_rc ? build_unary_op (NEGATE_EXPR, c_imag, 1) : c_imag)
          : build_pascal_binary_op (code, c_imag, r_exp));
    }

  /* All string and char types are compatible in Extended Pascal. */
  if (is_string_compatible_type (exp1, 1)
      && is_string_compatible_type (exp2, 1)
      && (!TYPE_IS_CHAR_TYPE (tt1) || !TYPE_IS_CHAR_TYPE (tt2)
          || code == PLUS_EXPR))
    {
      int rts_code = 0;
      switch (code)
      {
        case EQ_EXPR: rts_code = '=';    break;
        case NE_EXPR: rts_code = LEX_NE; break;
        case LT_EXPR: rts_code = '<';    break;
        case LE_EXPR: rts_code = LEX_LE; break;
        case GT_EXPR: rts_code = '>';    break;
        case GE_EXPR: rts_code = LEX_GE; break;
        default:  /* NOTHING */;
      }
      if (rts_code)
        {
          if (t1 != t2 || !tree_int_cst_equal (PASCAL_STRING_LENGTH (exp1), PASCAL_STRING_LENGTH (exp2)))
            chk_dialect ("comparison of different string and char types is", NOT_CLASSIC_PASCAL);
          return build_predef_call (rts_code, tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));
        }

      /* String catenation */
      if (code == PLUS_EXPR)
        {
          STRIP_TYPE_NOPS (exp1);
          STRIP_TYPE_NOPS (exp2);
          if (IS_STRING_CST (exp1) && IS_STRING_CST (exp2))
            return combine_strings (tree_cons (NULL_TREE, char_may_be_string (exp1), build_tree_list (NULL_TREE, char_may_be_string (exp2))), 0);

          {
            /* Length of the combined strings */
            tree len1 = PASCAL_STRING_LENGTH (exp1);
            tree len2 = PASCAL_STRING_LENGTH (exp2);
            tree length = save_expr (build_pascal_binary_op (PLUS_EXPR, len1, len2));

            /* Create a new string object */
            tree nstr = make_new_variable ("concat", build_pascal_string_schema (length));
            tree sval = PASCAL_STRING_VALUE (nstr);
            tree str_addr = build_unary_op (ADDR_EXPR, sval, 0);

            DECL_ARTIFICIAL (nstr) = 1;
            DECL_IGNORED_P (nstr) = 1;
#ifdef GCC_4_0
            TREE_NO_WARNING (nstr) = 1;
#endif

            /* Assign the first string to the new object */
            if (TYPE_IS_CHAR_TYPE (tt1))
              expand_expr_stmt1 (
                build_modify_expr (build_array_ref (sval, integer_one_node),
                                      NOP_EXPR, exp1));
            else
              expand_expr_stmt1 (build_memcpy (
                str_addr, build1 (ADDR_EXPR, cstring_type_node,
                                  PASCAL_STRING_VALUE (exp1)), len1));

            /* Catenate the second string to the first */
            if (TYPE_IS_CHAR_TYPE (tt2))
              expand_expr_stmt1 (build_modify_expr (
                build_array_ref (sval, build_pascal_binary_op (PLUS_EXPR,
                   len1, integer_one_node)), NOP_EXPR, exp2));
            else
#ifndef GCC_4_3
              expand_expr_stmt1 (build_memcpy (
                build2 (PLUS_EXPR, cstring_type_node, str_addr, len1),
                build1 (ADDR_EXPR, cstring_type_node,
                        PASCAL_STRING_VALUE (exp2)), len2));
#else
              expand_expr_stmt1 (build_memcpy (
                build2 (POINTER_PLUS_EXPR, cstring_type_node, 
                        convert (cstring_type_node, str_addr), 
                        convert (sizetype, len1)),
                build1 (ADDR_EXPR, cstring_type_node,
                        PASCAL_STRING_VALUE (exp2)), len2));
#endif

            /* Store the combined length of strings */
            expand_expr_stmt1 (build_modify_expr (
                PASCAL_STRING_LENGTH (nstr), NOP_EXPR, length));
            return non_lvalue (nstr);
          }
        }
    }

  if (code == IN_EXPR)
    {
      if (!ORDINAL_TYPE (t1))
        {
          error ("left operand to `in' must be of ordinal type");
          return error_mark_node;
        }

      if (TREE_CODE (tt2) != SET_TYPE)
        {
          error ("right operand to `in' must be a set");
          return error_mark_node;
        }

      if (TREE_CODE (exp2) == PASCAL_SET_CONSTRUCTOR)
        {
          /* Optimize `foo in [a, b .. c]' to become
             `(foo = a) or ((foo >= b) and (foo <= c))'
             (where foo is evaluated only once). */
          tree elem = SET_CONSTRUCTOR_ELTS (exp2),
               result = NULL_TREE, exp = save_expr (exp1);
          if (!elem)
            {
              gpc_warning ("`... in []' (empty set) is always `False'.");
              if (TREE_SIDE_EFFECTS (exp1))
                gpc_warning (" Operand with side-effects is not evaluated.");
              return boolean_false_node;
            }
          for (; elem; elem = TREE_CHAIN (elem))
            {
              tree min_c = TREE_PURPOSE (elem);
              tree max_c = TREE_VALUE (elem);
              tree condition;

              if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (min_c)),
                              TYPE_MAIN_VARIANT (TREE_TYPE (exp1))))
                {
                  error ("incompatible operands to `in'");
                  return error_mark_node;
                }

              STRIP_NOPS (min_c);
              STRIP_NOPS (max_c);

              /* !max_c: old-style set constructor, should not happen */
              gcc_assert (max_c);

              if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (exp1)), TYPE_MAIN_VARIANT (TREE_TYPE (min_c)))
                  || !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (exp1)), TYPE_MAIN_VARIANT (TREE_TYPE (max_c))))
                binary_op_error (code);

              if (max_c == min_c)
                /* This is a single element, not a range. */
                condition = build_pascal_binary_op (EQ_EXPR, exp, min_c);
              else
                {
                  /* This is a range. Avoid warning in the case
                     `<unsigned value> in [0 .. <whatever>]'. */
                  if (integer_zerop (min_c) && TYPE_UNSIGNED (TREE_TYPE (exp)))
                    condition = build_pascal_binary_op (LE_EXPR, exp, max_c);
                  else
                    condition = build_pascal_binary_op (TRUTH_ANDIF_EXPR,
                                  build_pascal_binary_op (GE_EXPR, exp, min_c),
                                  build_pascal_binary_op (LE_EXPR, exp, max_c));
                }
              if (result)
                result = build_pascal_binary_op (TRUTH_ORIF_EXPR, result, condition);
              else
                result = condition;
            }
          gcc_assert (result);
          return result;
        }
      else if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (exp2))),
                           TYPE_MAIN_VARIANT (TREE_TYPE (exp1))))
        {
          error ("incompatible operands to `in'");
          return error_mark_node;
        }
      else
        /* No optimization possible. Create an RTS call. */
        return build_predef_call (p_in, tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));
    }

  if (t1 == SET_TYPE && t2 == SET_TYPE)
    {
      int r_num = 0, negate = 0, empty1, empty2;
      tree result, temp;

      if (!comptypes (TYPE_MAIN_VARIANT (tt1), TYPE_MAIN_VARIANT (tt2)))
        {
          error ("operation on incompatible sets");
          return error_mark_node;
        }
      if (code == LT_EXPR || code == GT_EXPR)
        chk_dialect ("`>' or `<' applied to sets is", GNU_PASCAL);
      if (code == SYMDIFF_EXPR)
        chk_dialect ("symmetric set difference is", E_O_PASCAL);

      if (TREE_CODE (exp1) == PASCAL_SET_CONSTRUCTOR 
          && TREE_CODE (exp2) == PASCAL_SET_CONSTRUCTOR)
        {
          if (code == PLUS_EXPR)
            return build_set_constructor (chainon (
                     copy_list (SET_CONSTRUCTOR_ELTS (exp1)),
                     copy_list (SET_CONSTRUCTOR_ELTS (exp2))));
          else if (PASCAL_CONSTRUCTOR_INT_CST (exp1)
                   && PASCAL_CONSTRUCTOR_INT_CST (exp2))
            return const_set_constructor_binary_op (code, 
                     SET_CONSTRUCTOR_ELTS (exp1),
                     SET_CONSTRUCTOR_ELTS (exp2));
        }

      result = NULL_TREE;

      empty1 = TREE_TYPE (exp1) == empty_set_type_node;
      empty2 = TREE_TYPE (exp2) == empty_set_type_node;

      if (empty1)
        switch (code)
        {
          case PLUS_EXPR:
          case SYMDIFF_EXPR:
            gpc_warning ("Set operation has no effect.");
            return exp2;
          case MINUS_EXPR:
          case MULT_EXPR:
            gpc_warning ("Set operation always yields the empty set.");
            result = build_set_constructor (NULL_TREE);
            break;
          case GT_EXPR:
            gpc_warning ("`>' comparison of the empty set is always false.");
            result = boolean_false_node;
            break;
          case LE_EXPR:
            gpc_warning ("`<=' comparison of the empty set is always true.");
            result = boolean_true_node;
            break;
          case EQ_EXPR:
          case GE_EXPR:
            if (empty2)
              return boolean_true_node;
            r_num = p_Set_IsEmpty;
            exp1 = exp2;
            break;
          case NE_EXPR:
          case LT_EXPR:
            if (empty2)
              return boolean_false_node;
            r_num = p_Set_IsEmpty;
            exp1 = exp2;
            negate = 1;
            break;
          default: /* NOTHING */;
        }
      if (!result && !r_num && empty2)
        switch (code)
        {
          case PLUS_EXPR:
          case MINUS_EXPR:
          case SYMDIFF_EXPR:
            gpc_warning ("Set operation has no effect.");
            return exp1;
          case MULT_EXPR:
            gpc_warning ("Set operation always yields the empty set.");
            result = build_set_constructor (NULL_TREE);
            break;
          case LT_EXPR:
            gpc_warning ("`<' comparison against the empty set is always false.");
            result = boolean_false_node;
            break;
          case GE_EXPR:
            gpc_warning ("`>=' comparison against the empty set is always true.");
            result = boolean_true_node;
            break;
          case EQ_EXPR:
          case LE_EXPR:
            r_num = p_Set_IsEmpty;
            break;
          case NE_EXPR:
          case GT_EXPR:
            r_num = p_Set_IsEmpty;
            negate = 1;
            break;
          default: /* NOTHING */;
        }
      if (result)
        {
          if (TREE_SIDE_EFFECTS (empty1 ? exp2 : exp1))
            gpc_warning (" Operand with side-effects is not evaluated.");
          return result;
        }
      if (!r_num)
        switch (code)
        {
          case PLUS_EXPR:
            r_num = p_Set_Union;
            break;
          case MINUS_EXPR:
            r_num = p_Set_Diff;
            break;
          case MULT_EXPR:
            r_num = p_Set_Intersection;
            break;
          case SYMDIFF_EXPR:
            r_num = p_Set_SymDiff;
            break;
          case EQ_EXPR:
            r_num = p_Set_Equal;
            break;
          case NE_EXPR:
            r_num = p_Set_Equal;
            negate = 1;
            break;
          case LT_EXPR:
            r_num = p_Set_Less;
            break;
          case GT_EXPR:
            r_num = p_Set_Less;
            temp = exp1;
            exp1 = exp2;
            exp2 = temp;
            break;
          case LE_EXPR:
            r_num = p_Set_LE;
            break;
          case GE_EXPR:
            r_num = p_Set_LE;
            temp = exp1;
            exp1 = exp2;
            exp2 = temp;
            break;
          default:
            /* No other set operations are defined. */
            binary_op_error (code);
            return error_mark_node;
        }
      if (r_num == p_Set_IsEmpty)
        result = build_predef_call (r_num, build_tree_list (NULL_TREE, exp1));
      else
        result = build_predef_call (r_num, tree_cons (NULL_TREE, exp1, build_tree_list (NULL_TREE, exp2)));
      if (negate)
        result = build_pascal_unary_op (TRUTH_NOT_EXPR, result);
      return result;
    }

  switch (code)
  {
    case RDIV_EXPR:
    case TRUNC_DIV_EXPR:
    case FLOOR_DIV_EXPR:
      if (integer_zerop (exp2))
        error_or_warning (pedantic || !(co->pascal_dialect & C_E_O_PASCAL), "division by zero");
      break;
    case FLOOR_MOD_EXPR:
      {
        tree temp;
        tree tu1 = unsigned_type (TREE_TYPE (exp1)), e1u;
        tree tu2 = unsigned_type (TREE_TYPE (exp2)), e2u;
        int side_effects = TREE_SIDE_EFFECTS (exp1) || TREE_SIDE_EFFECTS (exp2);
        if (integer_zerop (exp2))
          error_or_warning (pedantic || !(co->pascal_dialect & C_E_O_PASCAL), "zero modulus");
        exp1 = save_expr (exp1);
        exp2 = save_expr (exp2);
        e1u = convert (tu1, exp1);
        e2u = convert (tu2, exp2);
        temp = build_binary_op (code, e1u, e2u);
        /* @@@@ This is kind of a kludge for the case when signed
           and unsigned types are used together to avoid wrap-around
           (fjf434c.pas). It might be better to select a longer result
           type (unless both are the longest types already)-:. */
        if (!TYPE_UNSIGNED (TREE_TYPE (exp1)))
          {
            /* (-exp1) mod exp2 */
            tree temp2 = save_expr (build_binary_op (code,
                           convert (tu1, build_unary_op (NEGATE_EXPR, exp1, 0)), e2u));
            /* exp1 >= 0 ? exp1 mod exp2 : temp2 == 0 ? 0 : exp2 - temp2 */
            temp = build3 (COND_EXPR, tu2,
                    build_binary_op (GE_EXPR, exp1, integer_zero_node),
                    convert (tu2, temp),
                    build3 (COND_EXPR, tu2,
                     build_binary_op (EQ_EXPR, temp2, integer_zero_node),
                      convert (tu2, integer_zero_node),
                      convert (tu2, build_binary_op (MINUS_EXPR, e2u, temp2))));
            TREE_SIDE_EFFECTS (temp) = side_effects;
            temp = build2 (COMPOUND_EXPR, tu2, exp2, temp);
          }
        if (!const_lt (integer_zero_node, exp2))
          temp = build3 (COND_EXPR, TREE_TYPE (temp),
                        build_binary_op (LE_EXPR, exp2, integer_zero_node),
                        build2 (COMPOUND_EXPR, TREE_TYPE (temp),
                          build_predef_call (p_ModRangeError, NULL_TREE),
                          integer_zero_node),
                        temp);
        TREE_SIDE_EFFECTS (temp) = side_effects;
        return temp;
      }
    case TRUNC_MOD_EXPR:
      if (integer_zerop (exp2))
        error ("zero modulus");
      /* @@@@ This is kind of a kludge for the case when signed
         and unsigned types are used together to avoid wrap-around.
         (fjf434a.pas) It might be better to select a longer result
         type (unless both are the longest types already)-:. */
      if (!TYPE_UNSIGNED (TREE_TYPE (exp2)))
        exp2 = convert (unsigned_type (TREE_TYPE (exp2)), build_unary_op (ABS_EXPR, exp2, 0));
      if (!TYPE_UNSIGNED (TREE_TYPE (exp1)))
        {
          tree tu1 = unsigned_type (TREE_TYPE (exp1));
          tree ts1 = signed_type (TREE_TYPE (exp1));
          int side_effects = TREE_SIDE_EFFECTS (exp1) || TREE_SIDE_EFFECTS (exp2);
          exp1 = save_expr (exp1);
          exp2 = save_expr (exp2);
          result = build3 (COND_EXPR, ts1,
                     build_binary_op (GE_EXPR, exp1, integer_zero_node),
                     convert (ts1, build_binary_op (code, convert (tu1, exp1), exp2)),
                     build_unary_op (NEGATE_EXPR,
                       convert (ts1, build_binary_op (code, convert (tu1,
                         build_unary_op (NEGATE_EXPR, exp1, 0)), exp2)), 0));
          /* Make sure exp2 is evaluated before the branch */
          result = build2 (COMPOUND_EXPR, TREE_TYPE (result), exp2, result);
          TREE_SIDE_EFFECTS (result) = side_effects;
          return result;
        }
      break;
    default: /* NOTHING */;
  }

  /* Handle comparisons between signed and unsigned integers
     which the backend gets wrong (i.e., the C way) */
  switch (code)
  {
    case EQ_EXPR:
    case NE_EXPR:
    case LE_EXPR:
    case GE_EXPR:
    case LT_EXPR:
    case GT_EXPR:
      if (TYPE_IS_INTEGER_TYPE (tt1) && TYPE_IS_INTEGER_TYPE (tt2)
          && TYPE_UNSIGNED (tt1) != TYPE_UNSIGNED (tt2))
        {
          tree unsigned_type, signed_exp;
          int lz;  /* 1: signed_exp < 0 means always True; 0: ... means always False */

          /* If one operand is constant and fits into the other's range, just convert it */
          tree tmp = fold (exp1);
          if (TREE_CODE (tmp) == INTEGER_CST)
            {
              tree tmp1 = convert (TREE_TYPE (exp2), tmp);
              tree tmp2 = fold (convert (TREE_TYPE (exp1), tmp1));
              if (!TREE_OVERFLOW (tmp2) && tree_int_cst_equal (tmp2, exp1))
                {
                  exp1 = tmp1;
                  break;
                }
            }
          tmp = fold (exp2);
          if (TREE_CODE (tmp) == INTEGER_CST)
            {
              tree tmp1 = convert (TREE_TYPE (exp1), tmp);
              tree tmp2 = fold (convert (TREE_TYPE (exp2), tmp1));
              if (!TREE_OVERFLOW (tmp2) && tree_int_cst_equal (tmp2, exp2))
                {
                  exp2 = tmp1;
                  break;
                }
            }
          if (TYPE_UNSIGNED (TREE_TYPE (exp2)))
            {
              signed_exp = exp1 = save_expr (exp1);
              lz = code == NE_EXPR || code == LT_EXPR || code == LE_EXPR;
            }
          else
            {
              signed_exp = exp2 = save_expr (exp2);
              lz = code == NE_EXPR || code == GT_EXPR || code == GE_EXPR;
            }
          unsigned_type = type_for_size (MAX (TYPE_PRECISION (TREE_TYPE (exp1)),
                                              TYPE_PRECISION (TREE_TYPE (exp2))), 1);
          return build_binary_op ((lz ? TRUTH_ORIF_EXPR : TRUTH_ANDIF_EXPR),
                   build_binary_op (code, convert (unsigned_type, exp1),
                                          convert (unsigned_type, exp2)),
                   build_binary_op ((lz ? LT_EXPR : GE_EXPR), signed_exp,
                     convert (TREE_TYPE (signed_exp), integer_zero_node)));
        }
      break;
    default: /* NOTHING */;
  }

  result = build_binary_op (code, exp1, exp2);
  if (TREE_CODE_CLASS (TREE_CODE (result)) == tcc_constant
       && TREE_OVERFLOW (result))
    error ("arithmetical overflow");
  return result;
}

/* @@ The global flag is not really nice, but an extra parameter to
      build_pascal_binary_op would affect all callers, hmm ... */
tree
build_implicit_pascal_binary_op (enum tree_code code, tree exp1, tree exp2)
{
  tree t;
  implicit_comparison++;
  t = build_pascal_binary_op (code, exp1, exp2);
  implicit_comparison--;
  return t;
}

tree
build_pascal_unary_op (enum tree_code code, tree xarg)
{
  tree t = xarg;
  int noconvert = 0;

  CHK_EM (t);
  DEREFERENCE_SCHEMA (t);

  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (t)))
    error ("invalid unary operation with restricted value");

  if (TREE_CODE (TREE_TYPE (t)) == FUNCTION_TYPE)
    t = probably_call_function (t);

  if (code == TRUTH_NOT_EXPR && TYPE_IS_INTEGER_TYPE (TREE_TYPE (t)))
    {
      chk_dialect ("bitwise `not' is", B_D_M_PASCAL);
      code = BIT_NOT_EXPR;
      noconvert = 1;
    }

  if (code == NEGATE_EXPR && TREE_CODE (t) == INTEGER_CST &&
      TYPE_IS_INTEGER_TYPE (TREE_TYPE (t)))
    {
      if (tree_int_cst_sgn (t) < 0)
        {
          /* Convert negative constants to an unsigned type if necessary
             (which always fits after negation) */
          t = build_unary_op (code, t, 0);
          if (TREE_OVERFLOW (t) || const_lt (TYPE_MAX_VALUE (TREE_TYPE (t)), t))
            t = convert (unsigned_type (TREE_TYPE (t)), t);
        }
      /* Convert positive constants to a signed type and do necessary range checking. */
      else if (TYPE_UNSIGNED (TREE_TYPE (t))
               && INT_CST_LT_UNSIGNED (build_int_2 (0, (HOST_WIDE_INT) -1 << (HOST_BITS_PER_WIDE_INT - 1)), t))
        {
          error ("value does not fit in longest integer type");
          return error_mark_node;
        }
      else
        t = build_unary_op (code, convert (long_long_integer_type_node, t), 0);

      /* No overflow here, since cases were checked properly, even if intermediate values did overflow. */
      TREE_OVERFLOW (t) = 0;
    }
  else
    t = build_unary_op (code, t, noconvert);

  t = set_exp_original_code (t, code);

  /* -42 is still a simple constant, but -(42) is not. */
  if ((code == NEGATE_EXPR || code == CONVERT_EXPR)
      && TREE_CODE_CLASS (TREE_CODE (t)) == tcc_constant
      && TREE_CODE_CLASS (TREE_CODE (xarg)) == tcc_constant)
    {
      PASCAL_CST_FRESH (t) = PASCAL_CST_FRESH (xarg);
      PASCAL_CST_PARENTHESES (t) = PASCAL_CST_PARENTHESES (xarg);
    }
  return t;
}

/* Dereference a pointer, explicitly via `^'. This may result in a function call. */
tree
build_pascal_pointer_reference (tree pointer)
{
  tree result, fun_type;
  CHK_EM (pointer);
  if (TREE_CODE (pointer) == TYPE_DECL)
    {
      error ("trying to dereference a type rather than an expression");
      return error_mark_node;
    }

  if (co->pascal_dialect & C_E_O_PASCAL
      && TREE_CODE (pointer) == NON_LVALUE_EXPR
      && PASCAL_CST_PARENTHESES (pointer))
    error ("invalid parentheses according to ISO Pascal");

  pointer = probably_call_function (pointer);

  if (TREE_SIDE_EFFECTS (pointer))
    pointer = save_expr (pointer);
  prediscriminate_schema (pointer);

  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (pointer)))
    error ("dereferencing a restricted pointer is not allowed");

  if (PASCAL_TYPE_CLASS (TREE_TYPE (pointer)))
    error ("dereferencing a class");

  if (PASCAL_TYPE_FILE (TREE_TYPE (pointer)))
    result = build_buffer_ref (pointer, p_LazyTryGet);
  else if (MAYBE_CALL_FUNCTION (pointer)
           && (fun_type = (TREE_CODE (pointer) == FUNCTION_DECL
                           ? TREE_TYPE (pointer)
                           : TREE_TYPE (TREE_TYPE (pointer))),
               TYPE_ARG_TYPES (fun_type)
               && TREE_CODE (TREE_VALUE (TYPE_ARG_TYPES (fun_type))) == VOID_TYPE))
    {
      int function_calls = allow_function_calls (1);
      result = maybe_call_function (pointer, 1);
      allow_function_calls (function_calls);
      if (TREE_CODE (pointer) == FUNCTION_DECL)  /* direct function call */
        result = build_pascal_pointer_reference (result);
    }
  else
    {
      tree type = TREE_TYPE (pointer);
      if (TREE_CODE (pointer) == FUNCTION_DECL || CALL_METHOD (pointer))
        type = TREE_TYPE (type);
      if (TREE_CODE (pointer) != ADDR_EXPR
          && TREE_CODE (type) == POINTER_TYPE
          && TREE_CODE (TREE_TYPE (type)) == VOID_TYPE
          && !(co->pascal_dialect & B_D_PASCAL))
        {
          error ("dereferencing untyped pointer");
          return error_mark_node;
        }
      if (co->pointer_checking && co->pointer_checking_user_defined)
        {
          tree check =
              gpc_build_call (void_type_node, validate_pointer_ptr_node,
                              build_tree_list (NULL_TREE, pointer));
          TREE_SIDE_EFFECTS (check) = 1;
          pointer = build2 (COMPOUND_EXPR, TREE_TYPE (pointer), check, pointer);
        }
      else if (co->pointer_checking)
        {
          tree cond = fold (build_pascal_binary_op (EQ_EXPR, pointer, null_pointer_node));
          if (TREE_CODE (cond) == INTEGER_CST && integer_zerop (cond))
            ;
          else if (TREE_CODE (cond) == INTEGER_CST
                   && (pedantic || !(co->pascal_dialect & C_E_O_PASCAL)))
            error ("nil pointer dereference");
          else
            pointer = fold (build3 (COND_EXPR, TREE_TYPE (pointer), cond,
              convert (TREE_TYPE (pointer), build_predef_call (p_NilPointerError, NULL_TREE)), pointer));
        }
      result = build_indirect_ref (pointer, "`^'");
    }
  return result;
}

tree
undo_schema_dereference (tree val)
{
  while (TREE_CODE (val) == COMPONENT_REF
         && TREE_CODE (TREE_OPERAND (val, 1)) == FIELD_DECL
         && DECL_NAME (TREE_OPERAND (val, 1)) == schema_id)
    val = TREE_OPERAND (val, 0);
  return val;
}

tree
build_variable_or_routine_access (tree t)
{
  tree pt = t;
  if (TREE_CODE (t) == TYPE_DECL)
    {
      error ("variable access expected -- type name given");
      return error_mark_node;
    }
  DEREFERENCE_SCHEMA (pt);
  if (MAYBE_CALL_FUNCTION (pt) && TREE_CODE (function_result_type (pt)) != VOID_TYPE)
    t = maybe_call_function (t, 0);
  else if (CALL_METHOD (t))
    t = call_method (t, NULL_TREE);
  return t;
}

/* Return an expression for the address of FACTOR.
   In most cases, this is an ADDR_EXPR, but it may also be a cast of a
   reference to a pointer. */
tree
build_pascal_address_expression (tree factor, int untyped)
{
  tree result;

  /* Undo a function call without parameters. Note: The first operand
     of the CALL_EXPR is already the address of the function. */
#ifndef GCC_4_3
  if (TREE_CODE (factor) == CALL_EXPR && !TREE_OPERAND (factor, 1))
#else
  if (TREE_CODE (factor) == CALL_EXPR && call_expr_nargs (factor) == 0)
#endif
    {
      result = CALL_EXPR_FN (factor);
      if (TREE_CODE (result) == ADDR_EXPR)
        /* build_routine_call does not do it, intentionally */
        mark_addressable (TREE_OPERAND (result, 0));
      return result;
    }

  /* build_unary_op accepts CONSTRUCTORs (for parameters), but the backend
     would later crash. Maybe it should be checked elsewhere, but it
     seems to work here. -- Frank */
  if (TREE_CODE (factor) == CONSTRUCTOR
      || TREE_CODE (factor) == PASCAL_SET_CONSTRUCTOR)
    {
      error ("reference expected, value given");
      return error_mark_node;
    }

  factor = undo_schema_dereference (factor);

  /* If `foo' is a procedure reference, `@foo' is a type cast to a procedure pointer. */
  if (PASCAL_PROCEDURAL_TYPE (TREE_TYPE (factor)))
    result = convert (build_pointer_type (TREE_TYPE (TREE_TYPE (factor))), factor);
  else
    {
      tree t;
      tree string_cst_type = NULL_TREE;

      if (TREE_CODE (factor) == STRING_CST)
        {
          tree length = convert (pascal_integer_type_node,
                          build_int_2 (TREE_STRING_LENGTH (factor) - 1, 0));
          tree st = build_pascal_string_schema (length);
          tree capf = TYPE_FIELDS (st);
          tree lenf = TREE_CHAIN (capf);
          tree schf = TREE_CHAIN (lenf);
#ifndef GCC_4_1
          tree inilist = tree_cons (capf, length, 
                           tree_cons (lenf, length,
                           build_tree_list (schf, factor)));
#else
          VEC(constructor_elt,gc) * inilist = 0;
          CONSTRUCTOR_APPEND_ELT (inilist, capf, length);
          CONSTRUCTOR_APPEND_ELT (inilist, lenf, length);
          CONSTRUCTOR_APPEND_ELT (inilist, schf, factor);
#endif
          factor = build_constructor (build_pascal_string_schema (length),
                                      inilist);
          /* Make this a valid lvalue for taking addresses. */
          TREE_CONSTANT (factor) = 1;
          TREE_STATIC (factor) = 1;
          string_cst_type = TREE_TYPE (factor);
          factor = declare_variable (get_unique_identifier ("const_string"),
                     TREE_TYPE (factor), build_tree_list (NULL_TREE, factor),
                     VQ_IMPLICIT | VQ_CONST | VQ_STATIC);
        }

      t = factor;
      while (TREE_CODE (t) == NOP_EXPR
             || TREE_CODE (t) == CONVERT_EXPR
             || TREE_CODE (t) == NON_LVALUE_EXPR
             || TREE_CODE (t) == COMPONENT_REF
             || TREE_CODE (t) == ARRAY_REF)
        t = TREE_OPERAND (t, 0);
      if (TREE_CODE (t) == VAR_DECL)
        PASCAL_VALUE_ASSIGNED (t) = 1;

      if (TREE_CODE_CLASS (TREE_CODE (t)) == tcc_constant)
        {
          error ("trying to take the address of a constant");
          return error_mark_node;
        }

      /* Don't call build_pascal_unary_op() which would call the function. */
      result = build_unary_op (ADDR_EXPR, factor, 0);

      /* Mark constant addresses as such (for initialization). */
      if ((TREE_CODE (factor) == VAR_DECL || TREE_CODE (factor) == FUNCTION_DECL)
          && (!DECL_CONTEXT (factor)
              || (TREE_CODE (factor) == FUNCTION_DECL && DECL_NO_STATIC_CHAIN (factor))))
        TREE_CONSTANT (result) = 1;
#if 0
      if (string_cst_type)
        {
          result = convert (build_pointer_type (string_cst_type), result);
        }
#endif
    }

  if (untyped)
    result = convert (ptr_type_node, result);

  return result;
}

/* Special case where `@foo' can be an lvalue: If `foo' is a procedure
   reference, `@foo' is a type cast to a procedure pointer. */
tree
build_pascal_lvalue_address_expression (tree expr)
{
  chk_dialect ("the address operator is", B_D_M_PASCAL);
  if (PASCAL_PROCEDURAL_TYPE (TREE_TYPE (expr)))
    return convert (build_pointer_type (TREE_TYPE (TREE_TYPE (expr))), expr);
  error ("using address expression as lvalue");
  return error_mark_node;
}

/* Subroutine of build_binary_op, used for comparison operations.
   See if the operands have both been converted from subword integer types
   and, if so, perhaps change them both back to their original type.
   This function is also responsible for converting the two operands
   to the proper common type for comparison.

   The arguments of this function are all pointers to local variables
   of build_binary_op: OP0_PTR is &OP0, OP1_PTR is &OP1,
   RESTYPE_PTR is &RESULT_TYPE and RESCODE_PTR is &RESULTCODE.

   If this function returns nonzero, it means that the comparison has
   a constant value. What this function returns is an expression for
   that value. */
static tree
shorten_compare (tree *op0_ptr, tree *op1_ptr, tree *restype_ptr, enum tree_code *rescode_ptr)
{
  tree type, op0 = *op0_ptr, op1 = *op1_ptr, primop0, primop1;
  int unsignedp0, unsignedp1, real1, real2;
  enum tree_code code = *rescode_ptr;

  /* Throw away any conversions to wider types already present in the operands. */

  primop0 = get_narrower (op0, &unsignedp0);
  primop1 = get_narrower (op1, &unsignedp1);

  /* @@@@ This is probably wrong (or not optimal) in general, but it fixes
          couper1.pas; the whole stuff is just too confusing (seems to
          be still more C than Pascal) to make any sense of. :-( -- Frank */
  if (TYPE_PRECISION (TREE_TYPE (primop0)) % BITS_PER_UNIT != 0)
    {
      primop0 = op0;
      unsignedp0 = TYPE_UNSIGNED (TREE_TYPE (op0));
    }
  if (TYPE_PRECISION (TREE_TYPE (primop1)) % BITS_PER_UNIT != 0)
    {
      primop1 = op1;
      unsignedp1 = TYPE_UNSIGNED (TREE_TYPE (op1));
    }

  /* Handle the case that OP0 does not *contain* a conversion
     but it *requires* conversion to FINAL_TYPE. */

  if (op0 == primop0 && TREE_TYPE (op0) != *restype_ptr)
    unsignedp0 = TYPE_UNSIGNED (TREE_TYPE (op0));
  if (op1 == primop1 && TREE_TYPE (op1) != *restype_ptr)
    unsignedp1 = TYPE_UNSIGNED (TREE_TYPE (op1));

  /* If one of the operands must be floated, we cannot optimize. */
  real1 = TREE_CODE (TREE_TYPE (primop0)) == REAL_TYPE;
  real2 = TREE_CODE (TREE_TYPE (primop1)) == REAL_TYPE;

  /* If first arg is constant, swap the args (changing operation
     so value is preserved), for canonicalization. Don't do this if
     the second arg is 0. */

  if (TREE_CONSTANT (primop0) && !integer_zerop (primop1) && !real_zerop (primop1))
    {
      tree tem = primop0;
      int temi = unsignedp0;
      primop0 = primop1;
      primop1 = tem;
      tem = op0;
      op0 = op1;
      op1 = tem;
      *op0_ptr = op0;
      *op1_ptr = op1;
      unsignedp0 = unsignedp1;
      unsignedp1 = temi;
      temi = real1;
      real1 = real2;
      real2 = temi;

      switch (code)
      {
        case LT_EXPR:
          code = GT_EXPR;
          break;
        case GT_EXPR:
          code = LT_EXPR;
          break;
        case LE_EXPR:
          code = GE_EXPR;
          break;
        case GE_EXPR:
          code = LE_EXPR;
          break;
        default:
          break;
      }
      *rescode_ptr = code;
    }

  /* If comparing an integer against a constant more bits wide, maybe we can
     deduce a value of True or False independent of the data. Or else truncate
     the constant now rather than extend the variable at run time.

     This is only interesting if the constant is the wider arg. Also, it is not
     safe if the constant is unsigned and the variable arg is signed, since in
     this case the variable would be sign-extended and then regarded as
     unsigned. Our technique fails in this case because the lowest/highest
     possible unsigned results don't follow naturally from the lowest/highest
     possible values of the variable operand. For just EQ_EXPR and NE_EXPR there
     is another technique that could be used: see if the constant can be
     faithfully represented in the other operand's type, by truncating it and
     reextending it and see if that preserves the constant's value. */

  if (!real1 && !real2
      && TREE_CODE (primop1) == INTEGER_CST
      && TYPE_PRECISION (TREE_TYPE (primop0)) < TYPE_PRECISION (*restype_ptr))
    {
      int min_gt, max_gt, min_lt, max_lt;
      tree maxval, minval;
      /* 1 if comparison is nominally unsigned. */
      int unsignedp = TYPE_UNSIGNED (*restype_ptr);
      tree val;

      type = signed_or_unsigned_type (unsignedp0, TREE_TYPE (primop0));

      maxval = TYPE_MAX_VALUE (type);
      minval = TYPE_MIN_VALUE (type);

      if (unsignedp && !unsignedp0)
        *restype_ptr = signed_type (*restype_ptr);

      if (TREE_TYPE (primop1) != *restype_ptr)
        primop1 = convert (*restype_ptr, primop1);
      if (type != *restype_ptr)
        {
          minval = convert (*restype_ptr, minval);
          maxval = convert (*restype_ptr, maxval);
        }

      /* minval and maxval are not necessarily INTEGER_CST */
      min_gt = const_lt (primop1, minval);
      max_lt = const_lt (maxval, primop1);
      max_gt = TREE_CODE (maxval) != INTEGER_CST || const_lt (primop1, maxval);
      min_lt = TREE_CODE (minval) != INTEGER_CST || const_lt (minval, primop1);

      val = NULL_TREE;
      /* This used to be a switch, but Genix compiler can't handle that. */
      if (code == NE_EXPR)
        {
          if (max_lt || min_gt)
            val = boolean_true_node;
        }
      else if (code == EQ_EXPR)
        {
          if (max_lt || min_gt)
            val = boolean_false_node;
        }
      else if (code == LT_EXPR)
        {
          if (max_lt)
            val = boolean_true_node;
          if (!min_lt)
            val = boolean_false_node;
        }
      else if (code == GT_EXPR)
        {
          if (min_gt)
            val = boolean_true_node;
          if (!max_gt)
            val = boolean_false_node;
        }
      else if (code == LE_EXPR)
        {
          if (min_gt)
            val = boolean_false_node;
          if (!max_gt)
            val = boolean_true_node;
        }
      else if (code == GE_EXPR)
        {
          if (max_lt)
            val = boolean_false_node;
          if (!min_lt)
            val = boolean_true_node;
        }

      /* If primop0 was sign-extended and unsigned comparison specified,
         we did a signed comparison above using the signed type bounds.
         But the comparison we output must be unsigned.

         Also, for inequalities, VAL is no good; but if the signed
         comparison had *any* fixed result, it follows that the
         unsigned comparison just tests the sign in reverse
         (positive values are LE, negative ones GE).
         So we can generate an unsigned comparison
         against an extreme value of the signed type. */
      if (unsignedp && !unsignedp0)
        {
          if (val)
            switch (code)
            {
              case LT_EXPR:
              case GE_EXPR:
                primop1 = TYPE_MIN_VALUE (type);
                val = NULL_TREE;
                break;

              case LE_EXPR:
              case GT_EXPR:
                primop1 = TYPE_MAX_VALUE (type);
                val = NULL_TREE;
                break;

              default:
                break;
            }
          type = unsigned_type (type);
        }

      /* Don't complain about internally generated comparisons. */
      if (!implicit_comparison && !max_gt && !unsignedp0 && TREE_CODE (primop0) != INTEGER_CST)
        {
          if (val == boolean_false_node)
            gpc_warning ("Comparison always yields `False' due to limited range of data type.");
          if (val == boolean_true_node)
            gpc_warning ("Comparison always yields `True' due to limited range of data type.");
        }
      if (!implicit_comparison && !min_lt && unsignedp0 && TREE_CODE (primop0) != INTEGER_CST)
        {
          if (val == boolean_false_node)
            gpc_warning ("Comparison always yields `False' due to limited range of data type.");
          if (val == boolean_true_node)
            gpc_warning ("Comparison always yields `True' due to limited range of data type.");
        }

      if (val)
        {
          if (TREE_SIDE_EFFECTS (primop0))
            gpc_warning (" Operand with side-effects is not evaluated.");
          return val;
        }

      /* Value is not predetermined, but do the comparison
         in the type of the operand that is not constant.
         TYPE is already properly set. */
    }
  else if (real1 && real2
           && (TYPE_PRECISION (TREE_TYPE (primop0)) == TYPE_PRECISION (TREE_TYPE (primop1))))
    type = TREE_TYPE (primop0);

  /* If args' natural types are both narrower than nominal type
     and both extend in the same manner, compare them
     in the type of the wider arg.
     Otherwise must actually extend both to the nominal
     common type lest different ways of extending alter the result.
     (eg, (short) -1 == (unsigned short) -1  should be 0.) */

  else if (unsignedp0 == unsignedp1 && real1 == real2
           && TYPE_PRECISION (TREE_TYPE (primop0)) < TYPE_PRECISION (*restype_ptr)
           && TYPE_PRECISION (TREE_TYPE (primop1)) < TYPE_PRECISION (*restype_ptr))
    {
      type = common_type (TREE_TYPE (primop0), TREE_TYPE (primop1));
      type = signed_or_unsigned_type (unsignedp0 || TYPE_UNSIGNED (*restype_ptr), type);
      /* Make sure shorter operand is extended the right way
         to match the longer operand. */
      primop0 = convert (signed_or_unsigned_type (unsignedp0, TREE_TYPE (primop0)), primop0);
      primop1 = convert (signed_or_unsigned_type (unsignedp1, TREE_TYPE (primop1)), primop1);
    }
  else
    {
      /* Here we must do the comparison on the nominal type
         using the args exactly as we received them. */
      type = *restype_ptr;
      primop0 = op0;
      primop1 = op1;

      if (!real1 && !real2 && integer_zerop (primop1)
          && TYPE_UNSIGNED (*restype_ptr))
        {
          tree value = NULL_TREE;
          switch (code)
          {
            case GE_EXPR:
              /* All unsigned values are >= 0, so we warn if extra warnings
                 are requested. However, if OP0 is a constant that is >= 0,
                 the signedness of the comparison isn't an issue, so suppress
                 the warning. */
              if (!implicit_comparison && TREE_CODE (primop0) != INTEGER_CST)
                gpc_warning ("Comparison `unsigned value >= 0' always yields `True'.");
              value = boolean_true_node;
              break;

            case LT_EXPR:
              if (!implicit_comparison && TREE_CODE (primop0) != INTEGER_CST)
                gpc_warning ("Comparison `unsigned value < 0' always yields `False'.");
              value = boolean_false_node;
              break;

            default:
              break;
          }

          if (value)
            {
              if (TREE_SIDE_EFFECTS (primop0))
                gpc_warning (" Operand with side-effects is not evaluated.");
              return value;
            }
        }
    }
  *op0_ptr = convert (type, primop0);
  *op1_ptr = convert (type, primop1);
  *restype_ptr = boolean_type_node;
  return 0;
}

/* Prepare expr to be an argument of a TRUTH_NOT_EXPR,
   or validate its data type for an `if' or `while' statement or COND_EXPR.
   This preparation consists of taking the ordinary
   representation of an expression expr and producing a valid tree
   boolean expression describing whether expr is nonzero. We could
   simply always do build_binary_op (NE_EXPR, expr, boolean_false_node, 1),
   but we optimize comparisons, &&, ||, and !.
   The resulting type should always be `boolean_type_node'. */
tree
truthvalue_conversion (tree expr)
{
  CHK_EM (expr);
  /* @@@@@@@@@ Gimplifier puts error_mark_node as a type */
  CHK_EM (TREE_TYPE (expr));
  switch (TREE_CODE (expr))
  {
    case EQ_EXPR:
    case NE_EXPR:
    case LE_EXPR:
    case GE_EXPR:
    case LT_EXPR:
    case GT_EXPR:
      return convert (boolean_type_node, expr);

    case TRUTH_ANDIF_EXPR:
    case TRUTH_ORIF_EXPR:
    case TRUTH_AND_EXPR:
    case TRUTH_OR_EXPR:
    case TRUTH_XOR_EXPR:
    case TRUTH_NOT_EXPR:
      if (TREE_TYPE (expr) != boolean_type_node)
        return fold (build2 (TREE_CODE (expr), boolean_type_node,
                              truthvalue_conversion (TREE_OPERAND (expr, 0)),
                              truthvalue_conversion (TREE_OPERAND (expr, 1))));
//      gcc_assert (TREE_TYPE (expr) == boolean_type_node);
      return expr;

    case INTEGER_CST:
      return integer_zerop (expr) ? boolean_false_node : boolean_true_node;

    case REAL_CST:
      return real_zerop (expr) ? boolean_false_node : boolean_true_node;

    case ADDR_EXPR:
      /* If we are taking the address of a external decl, it might be zero
         if it is weak, so we cannot optimize. */
      if (DECL_P (TREE_OPERAND (expr, 0)) && DECL_EXTERNAL (TREE_OPERAND (expr, 0)))
        break;
      return boolean_true_node;

    case COMPLEX_EXPR:
      return build_binary_op (TRUTH_ORIF_EXPR,
                              truthvalue_conversion (TREE_OPERAND (expr, 0)),
                              truthvalue_conversion (TREE_OPERAND (expr, 1)));

    case NEGATE_EXPR:
    case ABS_EXPR:
    case FLOAT_EXPR:
      /* These don't change whether an object is non-zero or zero. */
      return truthvalue_conversion (TREE_OPERAND (expr, 0));

    case COND_EXPR:
      /* Distribute the conversion into the arms of a COND_EXPR. */
      return fold (build3 (COND_EXPR, boolean_type_node, TREE_OPERAND (expr, 0),
                          truthvalue_conversion (TREE_OPERAND (expr, 1)),
                          truthvalue_conversion (TREE_OPERAND (expr, 2))));

    case CONVERT_EXPR:
      /* Don't cancel the effect of a CONVERT_EXPR from a REFERENCE_TYPE,
         since that affects how `default_conversion' will behave. */
      if (TREE_CODE (TREE_TYPE (expr)) == REFERENCE_TYPE
          || TREE_CODE (TREE_TYPE (TREE_OPERAND (expr, 0))) == REFERENCE_TYPE)
        break;
      /* FALLTHROUGH */
    case NOP_EXPR:
      /* If this is widening the argument, we can ignore it. */
      if (TYPE_PRECISION (TREE_TYPE (expr)) >= TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (expr, 0))))
        return truthvalue_conversion (TREE_OPERAND (expr, 0));
      break;

    case MINUS_EXPR:
      /* With IEEE arithmetic, x - x may not equal 0, so we can't optimize this case. */
      if (TARGET_FLOAT_FORMAT == IEEE_FLOAT_FORMAT
          && TREE_CODE (TREE_TYPE (expr)) == REAL_TYPE)
        break;
      /* FALLTHROUGH */
    case BIT_XOR_EXPR:
      /* This and MINUS_EXPR can be changed into a comparison of the two objects. */
      if (TREE_TYPE (TREE_OPERAND (expr, 0)) == TREE_TYPE (TREE_OPERAND (expr, 1)))
        return build_binary_op (NE_EXPR, TREE_OPERAND (expr, 0), TREE_OPERAND (expr, 1));
      return build_binary_op (NE_EXPR, TREE_OPERAND (expr, 0),
               fold (build1 (NOP_EXPR, TREE_TYPE (TREE_OPERAND (expr, 0)), TREE_OPERAND (expr, 1))));

    case BIT_AND_EXPR:
      if (integer_onep (TREE_OPERAND (expr, 1)) && TREE_TYPE (expr) != boolean_type_node)
        /* Using convert here would cause infinite recursion. */
        return build1 (NOP_EXPR, boolean_type_node, expr);
      break;

    default:
      break;
  }

  if (TREE_CODE (TREE_TYPE (expr)) == COMPLEX_TYPE)
    return (build_binary_op
            (TRUTH_ORIF_EXPR,
             truthvalue_conversion (build_unary_op (REALPART_EXPR, expr, 0)),
             truthvalue_conversion (build_unary_op (IMAGPART_EXPR, expr, 0))));

  return build_binary_op (NE_EXPR, default_conversion (expr), integer_zero_node);
}

/* Check if selected types are compatible in various contexts.
   Strings should not come here.
   @@@ Should perhaps rewrite the type checking functions
       instead of patching them like this, sigh. */
static int
compatible_types_p (tree type0, tree type1)
{
  return TREE_CODE (type0) == TREE_CODE (type1)
         && PASCAL_CHAR_TYPE (type0) == PASCAL_CHAR_TYPE (type1)
         && (TREE_CODE (type0) != ENUMERAL_TYPE ||
             base_type (type0) == base_type (type1));
}

static int
compatible_relop_p (tree type0, tree type1)
{
  enum tree_code code0 = TREE_CODE (type0), code1 = TREE_CODE (type1);
  return compatible_types_p (type0, type1)
         || (code0 == REAL_TYPE && TYPE_IS_INTEGER_TYPE(type1))
         || (TYPE_IS_INTEGER_TYPE (type0) && code1 == REAL_TYPE)
         || (code0 == COMPLEX_TYPE && (code1 == REAL_TYPE ||
               TYPE_IS_INTEGER_TYPE (type1)))
         || ((code0 == REAL_TYPE || TYPE_IS_INTEGER_TYPE (type0)) &&
            code1 == COMPLEX_TYPE);
}

/* Build a binary-operation expression without default conversions.
   CODE is the kind of expression to build.
   This function differs from `build' in several ways:
   the data type of the result is computed and recorded in it,
   warnings are generated if arg data types are invalid,
   special handling for addition and subtraction of pointers is known,
   and some optimization is done (operations on narrow ints
   are done in the narrower type when that gives the same result).
   Constant folding is also done before the result is returned. */
tree
build_binary_op (enum tree_code code, tree op0, tree op1)
{
  enum tree_code code0, code1;
  tree type0, type1;

  /* Expression code to give to the expression when it is built.
     Normally this is CODE, which is what the caller asked for,
     but in some special cases we change it. */
  enum tree_code resultcode = code;

  /* Data type in which the computation is to be performed.
     In the simplest cases this is the common type of the arguments. */
  tree result_type = NULL;

  /* Nonzero means operands have already been type-converted
     in whatever way is necessary.
     Zero means they need to be converted to RESULT_TYPE. */
  int converted = 0;

  /* Nonzero means create the expression with this type, rather than
     RESULT_TYPE. */
  tree build_type = 0;

  /* Nonzero means after finally constructing the expression
     convert it to this type. */
  tree final_type = 0;

  /* Nonzero if this is an operation like MIN or MAX which can
     safely be computed in short if both args are promoted shorts.
     Also implies COMMON.
     -1 indicates a bitwise operation; this makes a difference
     in the exact conditions for when it is safe to do the operation
     in a narrower mode. */
  int shorten = 0;

  /* Nonzero if this is a comparison operation;
     if both args are promoted shorts, compare the original shorts.
     Also implies COMMON. */
  int short_compare = 0;

  /* Nonzero if this is a right-shift operation, which can be computed on the
     original short and then promoted if the operand is a promoted short. */
  int short_shift = 0;

  /* Nonzero means set RESULT_TYPE to the common type of the args. */
  int common = 0;

  type0 = TREE_TYPE (op0);
  type1 = TREE_TYPE (op1);

  /* If an error was already reported for one of the arguments,
     avoid reporting another error. */
  CHK_EM (type0);
  CHK_EM (type1);

  /* The expression codes of the data types of the arguments tell us
     whether the arguments are integers, floating, pointers, etc. */
  code0 = TREE_CODE (type0);
  code1 = TREE_CODE (type1);

  /* Strip NON_LVALUE_EXPRs, etc., since we aren't using as an lvalue. */
  STRIP_TYPE_NOPS (op0);
  STRIP_TYPE_NOPS (op1);

  gcc_assert (code0 != SET_TYPE && code1 != SET_TYPE);

  switch (code)
  {
    case PLUS_EXPR:
      /* Handle the pointer + int case. */
      if (code0 == POINTER_TYPE && TYPE_IS_INTEGER_TYPE (type1))
        return pointer_int_sum (PLUS_EXPR, op0, op1);
      else if (code1 == POINTER_TYPE && TYPE_IS_INTEGER_TYPE (type0))
        return pointer_int_sum (PLUS_EXPR, op1, op0);
      else
        common = 1;
      break;

    case MINUS_EXPR:
      /* Subtraction of two similar pointers.
         We must subtract them as integers, then divide by object size. */
      if (code0 == POINTER_TYPE && code1 == POINTER_TYPE &&
          comp_target_types (type0, type1))
        return pointer_diff (op0, op1);
      /* Handle pointer minus int. Just like pointer plus int. */
      else if (code0 == POINTER_TYPE && TYPE_IS_INTEGER_TYPE (type1))
        return pointer_int_sum (MINUS_EXPR, op0, op1);
      else
        common = 1;
      break;

    case MULT_EXPR:
      common = 1;
      break;

    case RDIV_EXPR:
      if (INT_REAL (type0) && INT_REAL (type1))
        {
          if ((code0 == REAL_TYPE && TYPE_PRECISION (type0) > TYPE_PRECISION (double_type_node))
              || (code1 == REAL_TYPE && TYPE_PRECISION (type1) > TYPE_PRECISION (double_type_node)))
            result_type = long_double_type_node;
          else
            result_type = double_type_node;
          /* This is wrong, e.g., if exactly one operand is LongReal (fjf237.pas)
          converted = code0 != INTEGER_TYPE && code1 != INTEGER_TYPE; */
        }
      else if (IS_NUMERIC (type0) && IS_NUMERIC (type1))
        {
          result_type = complex_type_node;
          /* This is wrong if one operand is real and the other one is complex (maur4.pas)
          converted = 1; */
        }
      break;

    case TRUNC_DIV_EXPR:
    case CEIL_DIV_EXPR:
    case FLOOR_DIV_EXPR:
    case ROUND_DIV_EXPR:
    case EXACT_DIV_EXPR:
      if (TYPE_IS_INTEGER_TYPE (type0) && TYPE_IS_INTEGER_TYPE (type1))
        {
          /* Although it would be tempting to shorten always here, that
             loses on some targets, since the modulo instruction is
             undefined if the quotient can't be represented in the
             computation mode. We shorten only if unsigned or if
             dividing by something we know != -1. */
          shorten = TYPE_UNSIGNED (TREE_TYPE (op0))
                    || (TREE_CODE (op1) == INTEGER_CST && !integer_all_onesp (op1));
          common = 1;
        }
      break;

    case BIT_AND_EXPR:
#ifndef GCC_3_4
    case BIT_ANDTC_EXPR:
#endif
    case BIT_IOR_EXPR:
    case BIT_XOR_EXPR:
      if (TYPE_IS_INTEGER_TYPE (type0) &&
          TYPE_IS_INTEGER_TYPE (type1))
        shorten = -1;
      /* If one operand is a constant, and the other is a short type
         that has been converted to an int,
         really do the work in the short type and then convert the
         result to int. If we are lucky, the constant will be 0 or 1
         in the short type, making the entire operation go away. */
      if (TREE_CODE (op0) == INTEGER_CST
          && TREE_CODE (op1) == NOP_EXPR
          && TYPE_PRECISION (type1) > TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (op1, 0)))
          && TYPE_UNSIGNED (TREE_TYPE (TREE_OPERAND (op1, 0))))
        {
          final_type = result_type;
          op1 = TREE_OPERAND (op1, 0);
          result_type = TREE_TYPE (op1);
        }
      if (TREE_CODE (op1) == INTEGER_CST
          && TREE_CODE (op0) == NOP_EXPR
          && TYPE_PRECISION (type0) > TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (op0, 0)))
          && TYPE_UNSIGNED (TREE_TYPE (TREE_OPERAND (op0, 0))))
        {
          final_type = result_type;
          op0 = TREE_OPERAND (op0, 0);
          result_type = TREE_TYPE (op0);
        }
      if (code0 == SET_TYPE && code1 == SET_TYPE)
        {
          converted = 1;
          result_type = TREE_TYPE (op0);
        }
      break;

    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:
      if (TYPE_IS_INTEGER_TYPE (type0) &&
          TYPE_IS_INTEGER_TYPE (type1))
        {
          /* Although it would be tempting to shorten always here, that loses
             on some targets, since the modulo instruction is undefined if the
             quotient can't be represented in the computation mode. We shorten
             only if unsigned or if dividing by something we know != -1. */
          shorten = TYPE_UNSIGNED (TREE_TYPE (op0))
                    || (TREE_CODE (op1) == INTEGER_CST && !integer_all_onesp (op1));
          common = 1;
        }
      break;

    case TRUTH_ANDIF_EXPR:
    case TRUTH_ORIF_EXPR:
    case TRUTH_AND_EXPR:
    case TRUTH_OR_EXPR:
    case TRUTH_XOR_EXPR:
      build_type = boolean_type_node;
      if (code0 == BOOLEAN_TYPE && code1 == BOOLEAN_TYPE)
        {
          result_type = boolean_type_node;
          op0 = truthvalue_conversion (op0);
          op1 = truthvalue_conversion (op1);
          converted = 1;
        }
      break;

    /* Shift operations: result has same type as first operand;
       always convert second operand to int.
       Also set SHORT_SHIFT if shifting rightward. */

    case RSHIFT_EXPR:
      if (TYPE_IS_INTEGER_TYPE (type0) && TYPE_IS_INTEGER_TYPE (type1))
        {
          if (TREE_CODE (op1) == INTEGER_CST)
            {
              if (tree_int_cst_sgn (op1) < 0)
                gpc_warning ("right shift count is negative");
              else
                {
                  if (TREE_INT_CST_LOW (op1) | TREE_INT_CST_HIGH (op1))
                    short_shift = 1;
                  if (TREE_INT_CST_HIGH (op1) != 0
                      || ((unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (op1) >= TYPE_PRECISION (type0)))
                    gpc_warning ("right shift count >= width of type");
                }
            }
          /* Use the type of the value to be shifted for the result. */
          result_type = type0;
          if (TYPE_MAIN_VARIANT (TREE_TYPE (op1)) != pascal_integer_type_node)
            op1 = convert (pascal_integer_type_node, op1);
          /* Avoid converting op1 to result_type later. */
          converted = 1;
        }
      break;

    case LSHIFT_EXPR:
      if (TYPE_IS_INTEGER_TYPE (type0) && TYPE_IS_INTEGER_TYPE (type1))
        {
          result_type = TYPE_UNSIGNED (TREE_TYPE (op0)) ? long_long_unsigned_type_node : long_long_integer_type_node;
          op0 = convert (result_type, op0);
          if (TREE_CODE (op1) == INTEGER_CST)
            {
              if (tree_int_cst_sgn (op1) < 0)
                gpc_warning ("left shift count is negative");
              else if (TREE_INT_CST_HIGH (op1) != 0
                       || ((unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (op1) >= TYPE_PRECISION (result_type)))
                gpc_warning ("left shift count >= width of type");
            }
          if (TYPE_MAIN_VARIANT (TREE_TYPE (op1)) != pascal_integer_type_node)
            op1 = convert (pascal_integer_type_node, op1);
          /* Avoid converting op1 to result_type later. */
          converted = 1;
        }
      break;

    case EQ_EXPR:
    case NE_EXPR:
      if (co->warn_float_equal && (code0 == REAL_TYPE || code1 == REAL_TYPE))
        gpc_warning ("comparing real numbers with `=' or `<>' is unsafe");
      /* Result of comparison is always Boolean, but don't convert the args to Boolean. */
      build_type = boolean_type_node;
      if (ORDINAL_REAL_OR_COMPLEX_TYPE (code0) && compatible_relop_p (type0, type1))
        short_compare = 1;
      else if (code0 == ARRAY_TYPE && code1 == ARRAY_TYPE && comptypes (type0, type1))
        {
          if (!is_string_type (op0, 1) || !is_string_type (op1, 1))
            error ("comparison between arrays that are not of string type");
          else
            result_type = boolean_type_node;
          converted = 1;
        }
      else if (code0 == SET_TYPE && code1 == SET_TYPE)
        {
          result_type = boolean_type_node;
          converted = 1;
        }
      else if (code0 == POINTER_TYPE && code1 == POINTER_TYPE)
        {
          tree tt0 = TREE_TYPE (type0);
          tree tt1 = TREE_TYPE (type1);
          if (comp_target_types (type0, type1))
            result_type = common_type (type0, type1);
          else if (TYPE_MAIN_VARIANT (tt0) != void_type_node
                   && TYPE_MAIN_VARIANT (tt1) != void_type_node
                   && !comp_object_or_schema_pointer_types (tt0, tt1, 0)
                   && !comp_object_or_schema_pointer_types (tt1, tt0, 0))
            error ("comparison of incompatible pointer types");
          if (!result_type)
            result_type = ptr_type_node;
        }
      else if (code1 == REFERENCE_TYPE && TREE_CODE (TREE_TYPE (type1)) == FUNCTION_TYPE
               && code0 == POINTER_TYPE && integer_zerop (op0))
        result_type = type1;
      else if (code0 == REFERENCE_TYPE && TREE_CODE (TREE_TYPE (type0)) == FUNCTION_TYPE
               && ((code1 == POINTER_TYPE && integer_zerop (op1))
                   || (code1 == REFERENCE_TYPE && TREE_CODE (TREE_TYPE (type1)) == FUNCTION_TYPE
                       && strictly_comp_types (TREE_TYPE (type0), TREE_TYPE (type1)))))
        result_type = type0;
      break;

    case MAX_EXPR:
    case MIN_EXPR:
      if (ORDINAL_OR_REAL_TYPE (code0) && compatible_types_p (type0, type1))
        shorten = 1;
      else if (code0 == POINTER_TYPE && code1 == POINTER_TYPE)
        {
          if (comp_target_types (type0, type1))
            {
              result_type = common_type (type0, type1);
              if (TREE_CODE (TREE_TYPE (type0)) == FUNCTION_TYPE)
                gpc_warning ("ordered comparisons of pointers to routines");
            }
          else if (!comp_object_or_schema_pointer_types (TREE_TYPE (type0), TREE_TYPE (type1), 0)
                   && !comp_object_or_schema_pointer_types (TREE_TYPE (type1), TREE_TYPE (type0), 0))
            {
              result_type = ptr_type_node;
              pedwarn ("comparison of distinct pointer types lacks a cast");
            }
        }
      break;

    case LE_EXPR:
    case GE_EXPR:
    case LT_EXPR:
    case GT_EXPR:
      build_type = boolean_type_node;
      if (ORDINAL_OR_REAL_TYPE (code0) && compatible_relop_p (type0, type1))
        {
          result_type = boolean_type_node;
          short_compare = 1;
        }
      else if (code0 == POINTER_TYPE && code1 == POINTER_TYPE)
        {
          if (comp_target_types (type0, type1))
            {
              result_type = common_type (type0, type1);
              if (COMPLETE_OR_VOID_TYPE_P (TREE_TYPE (type0))
                  != COMPLETE_OR_VOID_TYPE_P (TREE_TYPE (type1)))
                pedwarn ("comparison of complete and incomplete pointers");
              else if (pedantic && TREE_CODE (TREE_TYPE (type0)) == FUNCTION_TYPE)
                gpc_warning ("ordered comparision of pointers to routines");
            }
          else
            {
              result_type = ptr_type_node;
              pedwarn ("comparison of distinct pointer types lacks a cast");
            }
        }
      else if (code0 == ARRAY_TYPE && code1 == ARRAY_TYPE)
        {
          if (!is_string_type (op0, 1) || !is_string_type (op1, 1))
            error ("comparison between arrays that are not of string type");
          else
            result_type = boolean_type_node;
          converted = 1;
        }
      else if (code0 == SET_TYPE && code1 == SET_TYPE)
        {
          result_type = boolean_type_node;
          converted = 1;
        }
      break;

    /* dead code was here */
    case IN_EXPR:
#ifndef GCC_4_0
    case CARD_EXPR:
#endif
      gcc_unreachable ();

    default:
      break;
  }

  if ((ORDINAL_REAL_OR_COMPLEX_TYPE (code0) && ORDINAL_REAL_OR_COMPLEX_TYPE (code1))
      || (code0 == SET_TYPE && code1 == SET_TYPE))
    {
      int none_complex = code0 != COMPLEX_TYPE && code1 != COMPLEX_TYPE;

      if (shorten || common || short_compare)
        result_type = common_type (type0, type1);

      /* For certain operations (which identify themselves by shorten != 0)
         if both args were extended from the same smaller type,
         do the arithmetic in that type and then extend.

         shorten !=0 and !=1 indicates a bitwise operation.
         For them, this optimization is safe only if
         both args are zero-extended or both are sign-extended.
         Otherwise, we might change the result.
         Eg, (short) -1 | (unsigned short) -1 is (int) -1
         but calculated in (unsigned short) it would be (unsigned short) -1. */

      if (shorten && none_complex)
        {
          int unsigned0, unsigned1;
          tree arg0 = get_narrower (op0, &unsigned0);
          tree arg1 = get_narrower (op1, &unsigned1);
          /* UNS is 1 if the operation to be done is an unsigned one. */
          int uns = TYPE_UNSIGNED (result_type);
          tree type;

          final_type = result_type;

          /* Handle the case that OP0 (or OP1) does not *contain* a conversion
             but it *requires* conversion to FINAL_TYPE. */

          if ((TYPE_PRECISION (TREE_TYPE (op0)) == TYPE_PRECISION (TREE_TYPE (arg0)))
              && TREE_TYPE (op0) != final_type)
            unsigned0 = TYPE_UNSIGNED (TREE_TYPE (op0));
          if ((TYPE_PRECISION (TREE_TYPE (op1)) == TYPE_PRECISION (TREE_TYPE (arg1)))
              && TREE_TYPE (op1) != final_type)
            unsigned1 = TYPE_UNSIGNED (TREE_TYPE (op1));

          /* Now UNSIGNED0 is 1 if ARG0 zero-extends to FINAL_TYPE. */

          /* For bitwise operations, signedness of nominal type
             does not matter. Consider only how operands were extended. */
          if (shorten == -1)
            uns = unsigned0;

          /* Note that in all three cases below we refrain from optimizing
             an unsigned operation on sign-extended args.
             That would not be valid. */

          /* Both args variable: if both extended in same way
             from same width, do it in that width.
             Do it unsigned if args were zero-extended. */
          if ((TYPE_PRECISION (TREE_TYPE (arg0)) < TYPE_PRECISION (result_type))
              && (TYPE_PRECISION (TREE_TYPE (arg1)) == TYPE_PRECISION (TREE_TYPE (arg0)))
              && unsigned0 == unsigned1
              && (unsigned0 || !uns))
            result_type = signed_or_unsigned_type (unsigned0,
              common_type (TREE_TYPE (arg0), TREE_TYPE (arg1)));
          else if (TREE_CODE (arg0) == INTEGER_CST
                   && (unsigned1 || !uns)
                   && (TYPE_PRECISION (TREE_TYPE (arg1)) < TYPE_PRECISION (result_type))
                   && (type = signed_or_unsigned_type (unsigned1, TREE_TYPE (arg1)),
                       int_fits_type_p (arg0, type)))
            result_type = type;
          else if (TREE_CODE (arg1) == INTEGER_CST
                   && (unsigned0 || !uns)
                   && (TYPE_PRECISION (TREE_TYPE (arg0)) < TYPE_PRECISION (result_type))
                   && (type = signed_or_unsigned_type (unsigned0, TREE_TYPE (arg0)),
                       int_fits_type_p (arg1, type)))
            result_type = type;
        }

      /* Shifts can be shortened if shifting right. */

      if (short_shift)
        {
          int unsigned_arg;
          tree arg0 = get_narrower (op0, &unsigned_arg);

          final_type = result_type;

          if (arg0 == op0 && final_type == TREE_TYPE (op0))
            unsigned_arg = TYPE_UNSIGNED (TREE_TYPE (op0));

          if (TYPE_PRECISION (TREE_TYPE (arg0)) < TYPE_PRECISION (result_type)
              /* We can shorten only if the shift count is less than the
                 number of bits in the smaller type size. */
              && !TREE_INT_CST_HIGH (op1)
              && TYPE_PRECISION (TREE_TYPE (arg0)) > TREE_INT_CST_LOW (op1)
              /* If arg is sign-extended and then unsigned-shifted,
                 we can simulate this with a signed shift in arg's type
                 only if the extended result is at least twice as wide
                 as the arg. Otherwise, the shift could use up all the
                 ones made by sign-extension and bring in zeros.
                 We can't optimize that case at all, but in most machines
                 it never happens because available widths are 2**N. */
              && (!TYPE_UNSIGNED (final_type)
                  || unsigned_arg
                  || 2 * TYPE_PRECISION (TREE_TYPE (arg0)) <= TYPE_PRECISION (result_type)))
            {
              /* Do an unsigned shift if the operand was zero-extended. */
              result_type = signed_or_unsigned_type (unsigned_arg, TREE_TYPE (arg0));
              /* Convert value-to-be-shifted to that type. */
              if (TREE_TYPE (op0) != result_type)
                op0 = convert (result_type, op0);
              converted = 1;
            }
        }

      /* Comparison operations are shortened too but differently.
         They identify themselves by setting short_compare = 1. */

      if (short_compare)
        {
          /* Don't write &op0, etc., because that would prevent op0
             from being kept in a register.
             Instead, make copies of the our local variables and
             pass the copies by reference, then copy them back afterward. */
          int unsignedp0, unsignedp1;
          tree primop0, primop1;
          tree xop0 = op0, xop1 = op1, xresult_type = result_type;
          enum tree_code xresultcode = resultcode;
          tree val = shorten_compare (&xop0, &xop1, &xresult_type, &xresultcode);
          if (val)
            return build_type ? convert (build_type, val) : val;
          op0 = xop0, op1 = xop1;
          converted = 1;
          resultcode = xresultcode;

          primop0 = get_narrower (op0, &unsignedp0);
          primop1 = get_narrower (op1, &unsignedp1);

          /* Warn if two unsigned values are being compared in a size
             larger than their original size, and one (and only one) is the
             result of a `not' operator. This comparison will always fail.

             Also warn if one operand is a constant, and the constant
             does not have all bits set that are set in the `not' operand
             when it is extended. */

          if ((TREE_CODE (primop0) == BIT_NOT_EXPR) != (TREE_CODE (primop1) == BIT_NOT_EXPR))
            {
              if (TREE_CODE (primop0) == BIT_NOT_EXPR)
                primop0 = get_narrower (TREE_OPERAND (primop0, 0), &unsignedp0);
              else
                primop1 = get_narrower (TREE_OPERAND (primop1, 0), &unsignedp1);

              if (TREE_CODE (primop0) == INTEGER_CST || TREE_CODE (primop1) == INTEGER_CST)
                {
                  tree primop;
                  long constant, mask;
                  int unsignedp, bits;

                  if (TREE_CODE (primop0) == INTEGER_CST)
                    {
                      primop = primop1;
                      unsignedp = unsignedp1;
                      constant = TREE_INT_CST_LOW (primop0);
                    }
                  else
                    {
                      primop = primop0;
                      unsignedp = unsignedp0;
                      constant = TREE_INT_CST_LOW (primop1);
                    }

                  bits = TYPE_PRECISION (TREE_TYPE (primop));
                  if (bits < TYPE_PRECISION (result_type) && bits < HOST_BITS_PER_LONG && unsignedp)
                    {
                      mask = (~0L) << bits;
                      if ((mask & constant) != mask)
                        gpc_warning ("comparison of promoted `not' unsigned with constant");
                    }
                }
              else if (unsignedp0 && unsignedp1
                       && (TYPE_PRECISION (TREE_TYPE (primop0)) < TYPE_PRECISION (result_type))
                       && (TYPE_PRECISION (TREE_TYPE (primop1)) < TYPE_PRECISION (result_type)))
                gpc_warning ("comparison of promoted `not' unsigned with unsigned");
            }
        }
    }

  /* At this point, RESULT_TYPE must be nonzero to avoid an error message.
     If CONVERTED is zero, both args will be converted to type RESULT_TYPE.
     Then the expression will be built.
     It will be given type FINAL_TYPE if that is nonzero;
     otherwise, it will be given type RESULT_TYPE. */

  if (!result_type)
    {
      binary_op_error (code);
      return error_mark_node;
    }

  if (!converted)
    {
      if (TREE_TYPE (op0) != result_type)
        op0 = convert (result_type, op0);
      if (TREE_TYPE (op1) != result_type)
        op1 = convert (result_type, op1);
    }

  if (!build_type)
    build_type = result_type;

  {
    tree result = build2 (resultcode, build_type, op0, op1);
    tree folded = fold (result);
    if (folded == result)
      TREE_CONSTANT (folded) = TREE_CONSTANT (op0) && TREE_CONSTANT (op1);

    /* Backend doesn't detect unsigned overflows */
    if (TREE_CODE (folded) == INTEGER_CST
        && TYPE_UNSIGNED (TREE_TYPE (op0))
        && TYPE_UNSIGNED (TREE_TYPE (op1))
        && ((resultcode == PLUS_EXPR && const_lt (folded, op0))
            || (resultcode == MINUS_EXPR && const_lt (op0, folded))))
      TREE_OVERFLOW (folded) = 1;

    if (final_type)
      return convert (final_type, folded);
    return folded;
  }
}

/* Compute the size to increment a pointer by. */
static tree
c_size_in_bytes (tree type)
{
  enum tree_code code = TREE_CODE (type);
  tree t;
  if (code == FUNCTION_TYPE || code == VOID_TYPE || EM (type))
    return size_int (1);
  if (!TYPE_SIZE (type))
    {
      error ("arithmetic on pointer to an incomplete type");
      return size_int (1);
    }
  /* Convert in case a char is more than one unit. */
#ifdef EGCS
  t = size_binop (CEIL_DIV_EXPR, TYPE_SIZE_UNIT (type),
                  size_int (TYPE_PRECISION (byte_integer_type_node) / BITS_PER_UNIT));
#else
  t = size_binop (CEIL_DIV_EXPR, TYPE_SIZE (type), size_int (BITS_PER_UNIT));
#endif
#ifdef GCC_4_0
  if (TREE_CODE (t) == INTEGER_CST)
    {
#ifndef GCC_4_3
      force_fit_type (t, 0, 0, 0);
#else
      tree ttype = TREE_TYPE (t);
      force_fit_type_double (ttype, TREE_INT_CST_LOW (t),
                             TREE_INT_CST_HIGH (t), 0, 0);
#endif
    }
#else
  force_fit_type (t, 0);
#endif
  return t;
}

/* Return a tree for the sum or difference (code says which)
   of pointer ptrop and integer intop. */
static tree
pointer_int_sum (enum tree_code code, tree ptrop, tree intop)
{
  /* The result is a pointer of the same type that is being added. */
  tree result_type = TREE_TYPE (ptrop), size_exp = integer_one_node, result, folded;
  if (TREE_CODE (TREE_TYPE (result_type)) == VOID_TYPE)
    gpc_warning ("untyped pointer used in arithmetic");
  else if (TREE_CODE (TREE_TYPE (result_type)) == FUNCTION_TYPE)
    gpc_warning ("pointer to a routine used in arithmetic");
  else
    size_exp = c_size_in_bytes (TREE_TYPE (result_type));
  /* Replace the integer argument with a suitable product by the object size. */
  intop = convert (sizetype, build_pascal_binary_op (MULT_EXPR,
    convert (ptrsize_unsigned_type_node, intop),
    convert (ptrsize_unsigned_type_node, size_exp)));
  /* Create the sum or difference. */
#ifndef GCC_4_3
  result = build2 (code, result_type, ptrop, intop);
#else
  if (code == MINUS_EXPR)
    intop = fold (build1 (NEGATE_EXPR, sizetype, intop));
  result = build2 (POINTER_PLUS_EXPR, result_type, ptrop, intop);
#endif
  folded = fold (result);
  if (folded == result)
    TREE_CONSTANT (folded) = TREE_CONSTANT (ptrop) & TREE_CONSTANT (intop);
  return folded;
}

/* Return a tree for the difference of pointers OP0 and OP1. */
static tree
pointer_diff (tree op0, tree op1)
{
  tree result, folded, restype = ptrdiff_type_node;
  tree target_type = TREE_TYPE (TREE_TYPE (op0));
  if (TREE_CODE (target_type) == VOID_TYPE)
    gpc_warning ("untyped pointer used in pointer difference");
  if (TREE_CODE (target_type) == FUNCTION_TYPE)
    gpc_warning ("pointer to a routine used in pointer difference");
  /* First do the subtraction as integers, then divide. */
  op0 = build_pascal_binary_op (MINUS_EXPR, convert (restype, op0), convert (restype, op1));
  /* This generates an error if op1 is pointer to incomplete type. */
  if (!TYPE_SIZE (TREE_TYPE (TREE_TYPE (op1)))
      && TREE_CODE (TREE_TYPE (TREE_TYPE (op1))) != VOID_TYPE)
    error ("arithmetic on pointer to an incomplete type");
  /* This generates an error if op0 is pointer to incomplete type. */
  op1 = c_size_in_bytes (target_type);
  /* Divide by the size, in easiest possible way. */
  result = build2 (EXACT_DIV_EXPR, restype, op0, convert (restype, op1));
  folded = fold (result);
  if (folded == result)
    TREE_CONSTANT (folded) = TREE_CONSTANT (op0) & TREE_CONSTANT (op1);
  return folded;
}

/* Construct and perhaps optimize a tree representation
   for a unary operation. CODE, a tree_code, specifies the operation
   and XARG is the operand. NOCONVERT nonzero suppresses
   the default promotions (such as from short to int), except for
   ADDR_EXPR where it means not to warn about packed fields, 2 means
   not even to require an lvalue. */
tree
build_unary_op (enum tree_code code, tree xarg, int noconvert)
{
  /* No default_conversion here. It causes trouble for ADDR_EXPR. */
  tree arg = xarg, addr, argtype = TREE_TYPE (arg);
  enum tree_code typecode = TREE_CODE (argtype);
  const char *errstring = NULL;

  CHK_EM (argtype);

  switch (code)
  {
    case CONVERT_EXPR:
      /* This is used for unary plus, because a CONVERT_EXPR
         is enough to prevent anybody from looking inside for
         associativity, but won't generate any code. */
      if (!IS_NUMERIC (argtype))
        errstring = "wrong type of argument to unary `+'";
      else if (!noconvert)
        arg = default_conversion (arg);
      break;

    case NEGATE_EXPR:
      if (!IS_NUMERIC (argtype))
        errstring = "wrong type of argument to unary `-'";
      else
        {
          if (!noconvert)
            arg = default_conversion (arg);
          if (TYPE_IS_INTEGER_TYPE (argtype))
            arg = convert (select_signed_integer_type (TREE_TYPE (arg)), arg);
        }
      break;

    case BIT_NOT_EXPR:
      if (!TYPE_IS_INTEGER_TYPE (argtype))
        errstring = "wrong type of argument to bitwise `not'";
      else
        if (!noconvert)
          arg = default_conversion (arg);
      break;

    case ABS_EXPR:
      if (!IS_NUMERIC (argtype))
        errstring = "wrong type of argument to `Abs'";
      else if (!noconvert)
        arg = default_conversion (arg);
      break;

    case CONJ_EXPR:
      /* Conjugating a real value is a no-op, but allow it anyway. */
      if (!IS_NUMERIC (argtype))
        errstring = "wrong type of argument to conjugation";
      else if (!noconvert)
        arg = default_conversion (arg);
      break;

    case TRUTH_NOT_EXPR:
      if (typecode != BOOLEAN_TYPE)
        errstring = "wrong type of argument to Boolean `not'";
      else
        return invert_truthvalue (truthvalue_conversion (arg));

    case NOP_EXPR:
      break;

    case REALPART_EXPR:
      if (TREE_CODE (arg) == COMPLEX_CST)
        return TREE_REALPART (arg);
      else if (TREE_CODE (TREE_TYPE (arg)) == COMPLEX_TYPE)
        return fold (build1 (REALPART_EXPR, TREE_TYPE (TREE_TYPE (arg)), arg));
      else
        return arg;

    case IMAGPART_EXPR:
      if (TREE_CODE (arg) == COMPLEX_CST)
        return TREE_IMAGPART (arg);
      else if (TREE_CODE (TREE_TYPE (arg)) == COMPLEX_TYPE)
        return fold (build1 (IMAGPART_EXPR, TREE_TYPE (TREE_TYPE (arg)), arg));
      else
        return convert (TREE_TYPE (arg), integer_zero_node);

    case ADDR_EXPR:
      /* Note that this operation never does default_conversion
         regardless of NOCONVERT which has a different meaning here. */

      /* Let &* cancel out to simplify resulting code. */
      if (TREE_CODE (arg) == INDIRECT_REF)
        {
          /* Don't let this be an lvalue. */
          if (lvalue_p (TREE_OPERAND (arg, 0)))
            return non_lvalue (TREE_OPERAND (arg, 0));
          return TREE_OPERAND (arg, 0);
        }

      /* For &x[y], return x+y */
      if (TREE_CODE (arg) == ARRAY_REF)
        {
          tree index, array = TREE_OPERAND (arg, 0);

          if (!mark_addressable2 (array, !!noconvert))
            return error_mark_node;

          if (!noconvert && PASCAL_TYPE_PACKED (TREE_TYPE (TREE_OPERAND (arg, 0))))
            chk_dialect ("this use of packed array components is", B_D_M_PASCAL);

          /* Kenner's get_inner_reference() code affected also this
             -- Interesting. So what? -- Frank */

          /* Pascal arrays are not pointers. */
          index = default_conversion (TREE_OPERAND (arg, 1));
          if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (index))
              && ORDINAL_TYPE (TREE_CODE (TREE_TYPE (index))))
            index = convert (pascal_integer_type_node, index);

          return build_pascal_binary_op (PLUS_EXPR, convert_array_to_pointer (array),
            fold (build_pascal_binary_op (MINUS_EXPR, index, TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (array))))));
        }

      if (TREE_CODE (arg) == COND_EXPR)
        {
          tree op1 = build_unary_op (ADDR_EXPR, TREE_OPERAND (arg, 1),
                                     noconvert);
          tree op2 = build_unary_op (ADDR_EXPR, TREE_OPERAND (arg, 2),
                                     noconvert);
          CHK_EM (op1);
          CHK_EM (op2);
          return build3 (COND_EXPR, TREE_TYPE (op1), TREE_OPERAND (arg, 0),
                         op1, op2);
        }

      if (TREE_CODE (arg) == COMPOUND_EXPR)
        {
          tree real_result = build_unary_op (ADDR_EXPR, TREE_OPERAND (arg, 1),
                                             noconvert);
          return build2 (COMPOUND_EXPR, TREE_TYPE (real_result),
                         TREE_OPERAND (arg, 0), real_result);
        }

      /* Addresses of constructors are needed for parameters. */
      if (TREE_CODE (arg) == CONSTRUCTOR 
          || TREE_CODE (arg) == PASCAL_SET_CONSTRUCTOR)
        {
          if (!TREE_CONSTANT (arg))
            {
              /* Create a temporary variable for non-constant constructors. */
              tree temp = make_new_variable ("structured_value", TREE_TYPE (arg));
              expand_expr_stmt (build_modify_expr (temp, NOP_EXPR, arg));
              arg = temp;
            }
        }
      else if (TREE_CODE (arg) == NOP_EXPR || TREE_CODE (arg) == CONVERT_EXPR)
        /* Address of a cast is just a cast of the address of the operand of the cast. */
        return convert (build_pointer_type (TREE_TYPE (arg)),
                        build_unary_op (ADDR_EXPR, TREE_OPERAND (arg, 0), noconvert));
      else if (typecode != FUNCTION_TYPE && TREE_CODE (arg) != STRING_CST && noconvert < 2 && !lvalue_p (arg))
        {
          error ("reference expected, value given");
          return error_mark_node;
        }

      /* Ordinary case; arg is a COMPONENT_REF or a decl. */
      argtype = TREE_TYPE (arg);

      /* If the lvalue is const or volatile, merge that into the type
         to which the address will point. Note that you can't get a
         restricted pointer by taking the address of something, so we
         only have to deal with `const' and `volatile' here. */
      if ((DECL_P (arg) || TREE_CODE_CLASS (TREE_CODE (arg)) == tcc_reference)
          && (TREE_READONLY (arg) || TREE_THIS_VOLATILE (arg)))
        argtype = c_build_type_variant (argtype, TREE_READONLY (arg), TREE_THIS_VOLATILE (arg));

      argtype = build_pointer_type (argtype);

      if (!mark_addressable2 (arg, !!noconvert))
        return error_mark_node;

      if (TREE_CODE (arg) == BIT_FIELD_REF && PASCAL_TYPE_PACKED (TREE_TYPE (TREE_OPERAND (arg, 0))))
        {
          error ("invalid use of component of packed array `%s'",
               IDENTIFIER_NAME (DECL_NAME (TREE_OPERAND (arg, 0))));
          return error_mark_node;
        }

      if (TREE_CODE (arg) == COMPONENT_REF)
        {
          tree field = TREE_OPERAND (arg, 1);
          if (!noconvert && PASCAL_TYPE_PACKED (TREE_TYPE (TREE_OPERAND (arg, 0))))
            chk_dialect ("this use of packed record fields is", B_D_M_PASCAL);

          if (!noconvert && DECL_PACKED_FIELD (field))
            {
              error ("invalid use of field `%s' of packed record `%s'",
                     IDENTIFIER_NAME (DECL_NAME (field)),
                     IDENTIFIER_NAME (DECL_NAME (TREE_OPERAND (arg, 0))));
              return error_mark_node;
            }

          addr = convert (argtype, build_unary_op (ADDR_EXPR, TREE_OPERAND (arg, 0), noconvert));
#ifndef EGCS97
          if (!integer_zerop (bit_position (field)))
            {
              tree offset = size_binop (EXACT_DIV_EXPR, bit_position (field), bitsize_int (BITS_PER_UNIT));
              /* int flag = TREE_CONSTANT (addr); */
              addr = fold (build2 (PLUS_EXPR, argtype, addr,
                                   convert (argtype, offset)));
              /* TREE_CONSTANT (addr) = flag; */
            }
#else
#ifndef GCC_4_3
          addr = fold (build2 (PLUS_EXPR, argtype, addr,
                               convert (argtype, byte_position (field))));
#else
          addr = fold (build2 (POINTER_PLUS_EXPR, argtype, addr,
                               convert (sizetype, byte_position (field))));
#endif
#endif
        }
      else
        addr = build1 (code, argtype, arg);

      /* Address of a static or external variable or file-scope function counts as a constant. */
      if (staticp (arg) && !(TREE_CODE (arg) == FUNCTION_DECL && DECL_CONTEXT (arg) && !DECL_NO_STATIC_CHAIN (arg)))
        TREE_CONSTANT (addr) = 1;
      return addr;

    default:
      gcc_unreachable ();
      break;
  }

  if (!errstring)
    return fold (build1 (code, TREE_TYPE (arg), arg));

  error (errstring);
  return error_mark_node;
}

/* Build an expression representing a cast to type TYPE of expression EXPR. */
tree
build_type_cast (tree type, tree value)
{
  tree otype, ovalue;

  CHK_EM (type);
  CHK_EM (value);
  type = TYPE_MAIN_VARIANT (type);
  gcc_assert (TREE_CODE (type) != FUNCTION_TYPE);

  /* Dereference procedural variables before casting them.
     Use the address operator `@' to cast a reference to a pointer. */
  if (PASCAL_PROCEDURAL_TYPE (TREE_TYPE (value)))
    value = build_indirect_ref (value, NULL);
  if (TREE_CODE (TREE_TYPE (value)) == FUNCTION_TYPE)
    value = probably_call_function (value);
  if (TREE_CODE (TREE_TYPE (value)) == FUNCTION_TYPE)  /* still */
    {
      error ("cannot cast a function");
      return error_mark_node;
    }

  value = string_may_be_char (value, 0);

  if (type == TREE_TYPE (value))
    {
      if (TREE_CODE_CLASS (TREE_CODE (value)) == tcc_constant
           && PASCAL_CST_FRESH (value))
        {
          value = copy_node (value);
          PASCAL_CST_FRESH (value) = 0;
        }
      return value;
    }

  /* If casting to void, avoid the error that would come
     from default_conversion in the case of a non-lvalue array. */
  if (TREE_CODE (type) == VOID_TYPE)
    return build1 (CONVERT_EXPR, type, value);

  otype = TREE_TYPE (value);

#if 0
  /* Optionally warn about potentially worrisome casts. */
  if (warn_cast_qual && TREE_CODE (type) == POINTER_TYPE && TREE_CODE (otype) == POINTER_TYPE)
    {
      if (TYPE_VOLATILE (TREE_TYPE (otype)) && !TYPE_VOLATILE (TREE_TYPE (type)))
        pedwarn ("cast discards `volatile' from pointer target type");
      if (TYPE_READONLY (TREE_TYPE (otype)) && !TYPE_READONLY (TREE_TYPE (type)))
        pedwarn ("cast discards `const' from pointer target type");
    }
#endif

  /* Warn about possible alignment problems. */
  if (warn_cast_align
      && TREE_CODE (type) == POINTER_TYPE
      && TREE_CODE (otype) == POINTER_TYPE
      && TREE_CODE (TREE_TYPE (otype)) != VOID_TYPE
      && TREE_CODE (TREE_TYPE (otype)) != FUNCTION_TYPE
      && TYPE_ALIGN (TREE_TYPE (type)) > TYPE_ALIGN (TREE_TYPE (otype)))
    gpc_warning ("cast increases required alignment of target type");

  if (TYPE_PRECISION (type) != TYPE_PRECISION (otype) && !TREE_CONSTANT (value))
    {
      if (TYPE_IS_INTEGER_TYPE (type) && TREE_CODE (otype) == POINTER_TYPE)
        gpc_warning ("cast from pointer to integer of different size");
      if (TREE_CODE (type) == POINTER_TYPE && TYPE_IS_INTEGER_TYPE (otype)
          && TREE_CODE (value) != PLUS_EXPR && TREE_CODE (value) != MINUS_EXPR)
        gpc_warning ("cast to pointer from integer of different size");
    }

  ovalue = value;
  if ((ORDINAL_TYPE (TREE_CODE (otype)) || TREE_CODE (otype) == POINTER_TYPE || TREE_CODE (otype) == REFERENCE_TYPE)
      && (ORDINAL_TYPE (TREE_CODE (type)) || TREE_CODE (type) == POINTER_TYPE || TREE_CODE (type) == REFERENCE_TYPE))
    {
      /* Value type cast. */
      STRIP_TYPE_NOPS (value);
      /* If the source and the target type differ both in size and
         in sign, do the conversion in two stages such that the size
         conversion is done on the unsigned type to avoid the value
         being 1-padded.
         Examples: Integer --> Cardinal --> LongCard
                   Byte --> Cardinal --> Integer */
      if (TYPE_IS_INTEGER_TYPE (type)
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE (value))
          && TYPE_UNSIGNED (type) != TYPE_UNSIGNED (TREE_TYPE (value))
          && TYPE_PRECISION (type) != TYPE_PRECISION (TREE_TYPE (value)))
        value = convert_and_check (signed_or_unsigned_type (1,
                  TYPE_UNSIGNED (type) ? TREE_TYPE (value) : type), value);
      value = convert_and_check (type, value);
      /* Ignore any integer overflow caused by the cast. */
      if (TREE_CODE (value) == INTEGER_CST)
        {
          TREE_OVERFLOW (value) = TREE_OVERFLOW (ovalue);
          TREE_CONSTANT_OVERFLOW (value) = TREE_CONSTANT_OVERFLOW (ovalue);
        }
      /* cast to type of different size can't be a variable type-cast */
      if (!tree_int_cst_equal (TYPE_SIZE (otype), TYPE_SIZE (type)))
        value = non_lvalue (value);
    }
  else if (!lvalue_p (value))
    {
      error ("invalid type cast");
      return error_mark_node;
    }
  else
    {
      /* Variable type cast. Convert a pointer internally. */

      /* @@ GPC allows `@'...'' as an extension, but we don't want that here. */
      if (TREE_CODE (value) == STRING_CST)
        error ("reference expected, value given");

      if (TREE_CODE (otype) != VOID_TYPE
          && TREE_CODE (type) != VOID_TYPE
          && !tree_int_cst_equal (TYPE_SIZE (otype), TYPE_SIZE (type)))
        gpc_warning ("cast to type of different size");

      value = build_indirect_ref (convert (build_pointer_type (type),
            build_pascal_unary_op (ADDR_EXPR, value)), NULL);
    }
  return value;
}

/* Given an expression PTR for a pointer, return an expression for the value
   pointed to. errorstring is the name of the operator to appear in error
   messages or NULL for internal usage which should cause no error. */
tree
build_indirect_ref (tree ptr, const char *errorstring)
{
  tree pointer = default_conversion (ptr), type;
  CHK_EM (ptr);
  if ((TREE_CODE (TREE_TYPE (pointer)) == FUNCTION_TYPE && TREE_CODE (TREE_TYPE (TREE_TYPE (pointer))) == POINTER_TYPE)
      || CALL_METHOD (pointer))
    pointer = probably_call_function (pointer);
  type = TREE_TYPE (pointer);
  if (TREE_CODE (type) == POINTER_TYPE)
    {
      tree t = TREE_TYPE (type), ref;
      if (!TYPE_SIZE (t) && TREE_CODE (t) != VOID_TYPE
          && !PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (t))
        {
          error ("dereferencing pointer to incomplete type");
          return error_mark_node;
        }
      if (TREE_CODE (pointer) == ADDR_EXPR
#ifndef GCC_3_4
          && !flag_volatile
#endif
          && (TREE_TYPE (TREE_OPERAND (pointer, 0)) == t))
        return TREE_OPERAND (pointer, 0);

      ref = build1 (INDIRECT_REF, t, pointer);
      TREE_READONLY (ref) = TYPE_READONLY (t);
      TREE_THIS_VOLATILE (ref) = TYPE_VOLATILE (t);
#ifndef GCC_3_4
      TREE_SIDE_EFFECTS (ref) = TYPE_VOLATILE (t) || TREE_SIDE_EFFECTS (pointer) || flag_volatile;
#else
      TREE_SIDE_EFFECTS (ref) = TYPE_VOLATILE (t) || TREE_SIDE_EFFECTS (pointer);
#endif
      prediscriminate_schema (ref);
      return ref;
    }
  else if (!EM (pointer))
    {
      gcc_assert (errorstring);
      error ("invalid type of argument of %s", errorstring);
    }
  return error_mark_node;
}

/* Enables (state = 1) or disables (state = 0) procedure/function evaluation
   when the routines have no parameters.
   Reason:
   1) When parsing an LEX_ID it may be either a routine name or a variable name.
   2) When passing such an item to a routine, it may have to be evaluated or
      not depending of the corresponding FORMAL parameter type; if this is a
      procedural parameter, the routine should be passed, if not, the routine
      should be evaluated, and the result passed.
   3) Enabling is necessary when parsing constructs like `@foo.bar' where `foo'
      is a function which returns a record containing a field `bar'. In this
      case, `foo' must be called although it follows an address operator.
   The old value of the flag is returned. By passing it again, the previous
   state is restored. */
static int evaluate_function_calls = 1;
int
allow_function_calls (int state)
{
  int old = evaluate_function_calls;
  evaluate_function_calls = state;
  return old;
}

/* Return the result type of the function FUN which may be a
   function decl, a reference or a pointer to a function. */
tree
function_result_type (tree fun)
{
  tree type = TREE_TYPE (fun);
  if (TREE_CODE (type) == POINTER_TYPE || TREE_CODE (type) == REFERENCE_TYPE)
    type = TREE_TYPE (type);
  gcc_assert (TREE_CODE (type) == FUNCTION_TYPE);
  return TREE_TYPE (type);
}

/* Maybe call the function, or pass it as a routine parameter, or assign
   its address to some lvalue. The problem is that the corresponding
   argument type is not known when the factor is parsed. Neither is it known
   if this is part of an expression ...
   @@ Not sure exactly what the second parameter means, `flag' is always a
      good name for a Boolean value. ;-) -- Frank */
tree
maybe_call_function (tree fun, int flag)
{
  tree temp = fun;

  /* 1) This is a procedure statement without parameters.
     2) This is an assignment from a function with no parameters to some
        variable, or passing the result of such function to another routine.
        @@@@ It may also have args, for function pointer calls.
     3) This procedure or function is being passed to a procedural parameter
        list.
     4) This is the assignment of the ADDRESS of a function to some lvalue.
     5) This is the assignment of the function itself to a procedural variable.
     6) This is a procedure call without parameters through a procedural
        variable.

     The problem is:
     in 1, 2, and 6 above the procedure/function should be called;
     in 3, 4, and 5 it should *not* be called. */

  DEREFERENCE_SCHEMA (fun);

  if (evaluate_function_calls)
    if ((TREE_CODE (fun) == FUNCTION_DECL
         && TYPE_ARG_TYPES (TREE_TYPE (fun))
         && TREE_CODE (TREE_VALUE (TYPE_ARG_TYPES (TREE_TYPE (fun)))) == VOID_TYPE)
        || (((TREE_CODE (fun) == PARM_DECL && PASCAL_PROCEDURAL_PARAMETER (fun))
             || PASCAL_PROCEDURAL_TYPE (TREE_TYPE (fun)))
            && TYPE_ARG_TYPES (TREE_TYPE (TREE_TYPE (fun)))
            && TREE_CODE (TREE_VALUE (TYPE_ARG_TYPES (TREE_TYPE (TREE_TYPE (fun))))) == VOID_TYPE)
        || flag)
      {
        if (PASCAL_PROCEDURAL_TYPE (TREE_TYPE (fun)) || TREE_CODE (TREE_TYPE (fun)) == POINTER_TYPE)
          fun = build_indirect_ref (fun, NULL);
        temp = build_routine_call (fun, NULL_TREE);
      }

  return temp;
}

/* A problem with the function calls again ...
   If a forward declared/external function is used in an expression that
   is part of some function arguments it will not be called by the routine
   maybe_call_function().
   The function probably_call_function() is used when we know that the
   function is not a function parameter but rather should be evaluated. */
tree
probably_call_function (tree fun)
{
  tree t, f = fun;
  CHK_EM (f);
  DEREFERENCE_SCHEMA (f);
  t = TREE_TYPE (f);
  if (TREE_CODE (t) == REFERENCE_TYPE)
    t = TREE_TYPE (t);
  /* If this is a function without parameters, call it */
  if (TREE_CODE (t) == FUNCTION_TYPE
      && TREE_CODE (TREE_TYPE (t)) != VOID_TYPE
      && TYPE_ARG_TYPES (t)
      && TREE_CODE (TREE_VALUE (TYPE_ARG_TYPES (t))) == VOID_TYPE)
    fun = build_routine_call (f, NULL_TREE);
  else if (CALL_METHOD (f))
    fun = call_method (f, NULL_TREE);
  return fun;
}

tree
build_iocheck (void)
{
  tree t =
      gpc_build_call (void_type_node, checkinoutres_routine_node,
               NULL_TREE);
  tree pz = convert(pascal_integer_type_node, integer_zero_node);
  TREE_SIDE_EFFECTS (t) = 1;
  return build3 (COND_EXPR, pascal_integer_type_node, 
      build_pascal_binary_op (NE_EXPR, inoutres_variable_node, pz),
      build2 (COMPOUND_EXPR, pascal_integer_type_node, t, pz),
      pz);
}

/* Build a function call to routine FUNCTION with parameters params.
   params is a list -- a chain of TREE_LIST nodes -- in which the
   TREE_VALUE of each node is a parameter-expression.
   FUNCTION's data type may be a function type or a pointer-to-function. */
tree
build_routine_call (tree function, tree params)
{
  tree fntype, fundecl = NULL_TREE, result, coerced_params, t, orig_type;
  int side_effects = 1;

  CHK_EM (function);
  for (t = params; t; t = TREE_CHAIN (t))
    CHK_EM (TREE_VALUE (t));

  orig_type = TREE_TYPE (function);

  /* Strip NON_LVALUE_EXPRs, etc., since we aren't using as an lvalue. */
  STRIP_TYPE_NOPS (function);

  /* Convert anything with function type to a pointer-to-function. */
  if (TREE_CODE (function) == FUNCTION_DECL)
    {
      fundecl = function;
      side_effects = !TREE_READONLY (function);

      /* Differs from default_conversion by not setting TREE_ADDRESSABLE
         (because calling an inline function does not mean the function
         needs to be separately compiled). */
      fntype = p_build_type_variant (TREE_TYPE (function),
        TREE_READONLY (function), TREE_THIS_VOLATILE (function));
      function = build1 (ADDR_EXPR, build_pointer_type (fntype), function);
      TREE_CONSTANT (function) = pascal_global_bindings_p ();
    }
  /* Not converted by default_conversion(). */
  else if (TREE_CODE (TREE_TYPE (function)) == FUNCTION_TYPE)
    function = build_unary_op (ADDR_EXPR, function, 0);
  else if (TREE_CODE (TREE_TYPE (function)) == POINTER_TYPE)
    error ("missing `^' in indirect function call");
  else
    function = default_conversion (function);

  fntype = TREE_TYPE (function);
  CHK_EM (fntype);

  if (!(TREE_CODE (fntype) == POINTER_TYPE && TREE_CODE (TREE_TYPE (fntype)) == FUNCTION_TYPE))
    {
      error ("called object is not a procedure or function");
      return error_mark_node;
    }

  /* fntype now gets the type of function pointed to. */
  fntype = TREE_TYPE (fntype);

  /* Convert the parameters to the types declared with the
     routine, or apply default promotions. */
  coerced_params = convert_arguments (TYPE_ARG_TYPES (fntype), params, fundecl);
  if (coerced_params)
    CHK_EM (coerced_params);

  result =  gpc_build_call (TREE_TYPE (fntype), function, coerced_params);

  TREE_SIDE_EFFECTS (result) = side_effects;

  if (PASCAL_TYPE_STRING (TREE_TYPE (result)))
    {
      /* Handle functions returning string schemata. Since we don't know what
         will happen to the string to be returned, we must provide a temporary
         variable and expand the assignment to it now. Otherwise, subsequent
         component references (to Capacity, length, and string) might cause the
         function to be called three times. */
      tree temp_string = make_new_variable ("string_result", TREE_TYPE (fntype));
      result = build_modify_expr (temp_string, NOP_EXPR, result);
      if (co->io_checking && PASCAL_TYPE_IOCRITICAL (orig_type))
        result = build2 (COMPOUND_EXPR, pascal_integer_type_node,
                         result, build_iocheck ());
      result = build2 (COMPOUND_EXPR, TREE_TYPE (fntype), save_expr (result),
                       non_lvalue (temp_string));
      TREE_USED (result) = 1;
#ifdef GCC_4_0
      TREE_NO_WARNING (result) = 1;
#endif
    }
  else if (co->io_checking && PASCAL_TYPE_IOCRITICAL (orig_type))
    {
      if (TREE_CODE (TREE_TYPE (result)) == VOID_TYPE || EM (TREE_TYPE (result)))
        {
          result = build1 (CONVERT_EXPR, void_type_node, save_expr (
               build2 (COMPOUND_EXPR, pascal_integer_type_node,
               result, build_iocheck ())));
          PASCAL_TREE_IGNORABLE (result) = 1;
        }
      else
        {
          result = save_expr (result);
          result = build2 (COMPOUND_EXPR, TREE_TYPE (result), result,
                           build2 (COMPOUND_EXPR, TREE_TYPE (result),
                                   build_iocheck (), result));
          result = save_expr (result);
        }
    }
  PASCAL_TREE_IGNORABLE (result) |= PASCAL_TREE_IGNORABLE (orig_type) || co->ignore_function_results;
  if (TREE_CODE (TREE_TYPE (result)) == VOID_TYPE || EM (TREE_TYPE (result)))
    return result;
  return require_complete_type (result);
}

static tree
strip_needless_lists (tree list)
{
  while (1)
    {
      tree nl = TREE_VALUE (list);
      if (TREE_CHAIN (list) || TREE_PURPOSE (list) || !nl)
        return NULL_TREE;
      if (TREE_CODE (nl) != TREE_LIST)
        return list;
      if (!PASCAL_BP_INITIALIZER_LIST (nl))
        return NULL_TREE;
      PASCAL_BP_INITIALIZER_LIST (nl) = 0;
      list = nl;
    }
}

tree
build_iso_set_constructor (tree type, tree list, int one_el)
{
  tree nl = NULL_TREE;
  if (one_el)
    {
      if ((list = strip_needless_lists (list)))
        {
          TREE_PURPOSE (list) = TREE_VALUE (list);
          TREE_VALUE (list) = NULL_TREE;
        }
      else
        {
          error ("invalid set constructor");
          return error_mark_node;
        }
    }
  while (list)
    {
      tree low = TREE_PURPOSE (list);
      if (low && TREE_CODE (low) == IDENTIFIER_NODE)
        low = check_identifier (low);
      nl = tree_cons (low, TREE_VALUE (list), nl);
      list = TREE_CHAIN (list);
    }
  return construct_set (build_set_constructor (nreverse (nl)), type, 1);
}

tree
build_iso_constructor (tree tdecl, tree list)
{
  tree type = TREE_TYPE (tdecl);
  gcc_assert (TREE_CODE (list) == TREE_LIST);
  if (TREE_CODE (tdecl) != TYPE_DECL)
    {
      /* Handle `arr[(((expr)))]' -- since we must track parentheses
         in BP initializers, we prefer parsing as initializer over
         parsing as index expression */
      if ((list = strip_needless_lists (list)))
        return build_pascal_array_ref (tdecl, list);
      error ("invalid subscript");
      return error_mark_node;
    }
  if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type)
      || PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
    {
      error ("undiscriminated type in structured value constructor");
      return error_mark_node;
    }
  chk_dialect ("structured value constructors are", E_O_PASCAL);
  if (TREE_CODE (type) == SET_TYPE)
    return build_iso_set_constructor (type, list, 1);
  if (!STRUCTURED_TYPE (TREE_CODE (type)))
    error ("invalid type for structured value constructor");
  list = build_tree_list (NULL_TREE, list);
  if (check_pascal_initializer (type, list))
    {
      error ("invalid structured value constructor");
      return error_mark_node;
    }
  else
    return build_pascal_initializer (type, list, "structured value", 0);
}

tree
build_call_or_cast (tree function, tree args)
{
  if (TREE_CODE (function) == TYPE_DECL)
    {
      chk_dialect ("type casts are", B_D_M_PASCAL);
      if (list_length (args) != 1)
        {
          error ("type cast expects one expression argument");
          return error_mark_node;
        }
      else
        return build_type_cast (TREE_TYPE (function), TREE_VALUE (args));
    }
  else if (CALL_METHOD (function))
    return call_method (function, args);
  else
    return build_routine_call (function, args);
}

/* Build an assignment expression of lvalue LHS from value RHS.
   MODIFYCODE is the code for a binary operator that we use
   to combine the old value of LHS with RHS to get the new value.
   Or else MODIFYCODE is NOP_EXPR meaning do a simple assignment,
   or INIT_EXPR which is the same, but does not mark the variable
   as assigned nor warn about assignments to discriminants etc.
   (meant for automatic initializations). */
tree
build_modify_expr (tree lhs, enum tree_code modifycode, tree rhs)
{
  tree result, newrhs, olhstype, lhstype;
  int is_init = modifycode == INIT_EXPR;
  if (modifycode == INIT_EXPR)
    modifycode = NOP_EXPR;

  /* Types that aren't fully specified cannot be used in assignments. */
  lhs = require_complete_type (lhs);

  CHK_EM (lhs);
  CHK_EM (rhs);
  DEREFERENCE_SCHEMA (lhs);
  DEREFERENCE_SCHEMA (rhs);
  olhstype = lhstype = TREE_TYPE (lhs);

  /* Strip NON_LVALUE_EXPRs since we aren't using as an lvalue.
     Do not use STRIP_NOPS here. We do not want an enumerator
     whose value is 0 to count as a null pointer constant. */
  if (TREE_CODE (rhs) == NON_LVALUE_EXPR && TREE_TYPE (TREE_OPERAND (rhs, 0)) == TREE_TYPE (rhs))
    rhs = TREE_OPERAND (rhs, 0);

  newrhs = rhs;

  /* Object assignments. */
  if (PASCAL_TYPE_OBJECT (lhstype) && PASCAL_TYPE_OBJECT (TREE_TYPE (rhs)))
    {
      tree field = TYPE_FIELDS (lhstype), field2, lastfield, l = lhs;
      if (!comp_object_or_schema_pointer_types (lhstype, TREE_TYPE (rhs), 0))
        {
          error ("assignment between incompatible object types");
          return error_mark_node;
        }
      if (co->warn_object_assignment)
        gpc_warning ("assignment between objects");

      while (TREE_CODE (l) == NOP_EXPR
             || TREE_CODE (l) == CONVERT_EXPR
             || TREE_CODE (l) == NON_LVALUE_EXPR)
        l = TREE_OPERAND (l, 0);
      if (TREE_CODE (l) != VAR_DECL
          && TREE_CODE (l) != PARM_DECL
          && TREE_CODE (l) != COMPONENT_REF
          && TREE_CODE (l) != ARRAY_REF)
        gpc_warning ("left-hand side of object assignment is polymorphic");

      /* The following code assumes that the VMT pointer is the first field.
         This is always the case in GPC. If this ever changes, the code must
         be adapted. */
      gcc_assert (TYPE_LANG_VMT_FIELD (lhstype) == field);
#ifdef EGCS97
      gcc_assert (integer_zerop (DECL_FIELD_BIT_OFFSET (field))
                  && integer_zerop (DECL_FIELD_OFFSET (field)));
#else
      gcc_assert (integer_zerop (bit_position (field)));
#endif
      field = TREE_CHAIN (field);
      field2 = TREE_CHAIN (TYPE_FIELDS (TREE_TYPE (rhs)));
      if (!field)
        {
          if (!is_init)
            gpc_warning ("assignment of object with no fields has no effect");
          return error_mark_node;
        }
      lastfield = tree_last (field);
      return build_memcpy (
#ifndef GCC_4_0
        build_unary_op (ADDR_EXPR, build (COMPONENT_REF, TREE_TYPE (field), lhs, field), 1),
        build_unary_op (ADDR_EXPR, build (COMPONENT_REF, TREE_TYPE (field2), rhs, field2), 2),
#else
        build_unary_op (ADDR_EXPR, build3 (COMPONENT_REF, TREE_TYPE (field),
           lhs, field, NULL_TREE), 1),
        build_unary_op (ADDR_EXPR, build3 (COMPONENT_REF, TREE_TYPE (field2),
           rhs, field2,  NULL_TREE), 2),
#endif
        size_binop (CEIL_DIV_EXPR,
          size_binop (MINUS_EXPR, size_binop (PLUS_EXPR, bit_position (lastfield), DECL_SIZE (lastfield)), bit_position (field)),
          bitsize_int (TYPE_PRECISION (byte_integer_type_node))));
    }

  if (TREE_CODE (lhs) == PASCAL_BIT_FIELD_REF)
    {
      /* See build_pascal_packed_array_ref()! */
      tree pack_info = build_pascal_packed_array_ref (
                         TREE_OPERAND (lhs, 0),
                         TREE_OPERAND (lhs, 1),
                         TREE_OPERAND (lhs, 2), 0);
      tree info = TREE_VALUE (pack_info), info2 = TREE_VALUE (info);
      tree offset = TREE_PURPOSE (TREE_PURPOSE (info2));
      tree mask = TREE_VALUE (TREE_PURPOSE (info2));
      tree low_lhs = TREE_PURPOSE (TREE_VALUE (info2));
      tree high_lhs = TREE_VALUE (TREE_VALUE (info2));
      tree shifted_mask, temprhs, save_rhs_stmt, eraser, brush;
      tree low_assignment, high_assignment;

      lhs = TREE_PURPOSE (pack_info);
      gcc_assert (TREE_CODE (info) == TREE_LIST);

      /* newrhs can be an expression involving the LHS array field, so
         store it into a temporary variable before modifying the LHS. */
      temprhs = make_new_variable ("assign_packed", TREE_TYPE (newrhs));
      save_rhs_stmt = build_modify_expr (temprhs, NOP_EXPR, newrhs);
      newrhs = temprhs;

      /* Do the modification. */
      if (modifycode != NOP_EXPR)
        newrhs = build_pascal_binary_op (modifycode, lhs, newrhs);

      /* Now form a new expression to store the lower part of newrhs in low_lhs.
         Clear the bits in the target. */
      shifted_mask = build_pascal_binary_op (LSHIFT_EXPR, mask, offset);
      eraser = build_modify_expr (low_lhs, BIT_AND_EXPR,
                 convert (packed_array_unsigned_short_type_node,
                   build_unary_op (BIT_NOT_EXPR, shifted_mask, 0)));
      /* Do the assignment. */
      brush = build_pascal_binary_op (BIT_AND_EXPR,
               convert (packed_array_unsigned_long_type_node, newrhs), mask);
      brush = build_pascal_binary_op (LSHIFT_EXPR, brush, offset);
      brush = convert (packed_array_unsigned_long_type_node, brush);
      brush = build_pascal_binary_op (BIT_AND_EXPR, brush,
               convert (packed_array_unsigned_long_type_node,
                TYPE_MAX_VALUE (packed_array_unsigned_short_type_node)));
      brush = convert (packed_array_unsigned_short_type_node, brush);
      brush = build_modify_expr (low_lhs, BIT_IOR_EXPR, brush);
      low_assignment = build2 (COMPOUND_EXPR, TREE_TYPE (brush), save_rhs_stmt,
                         build2 (COMPOUND_EXPR, TREE_TYPE (brush),
                                 eraser, brush));

      /* Now do the same for the higher part and high_lhs. Prepare shifted_mask
         to access the higher half. Clear the bits in the target. */
      shifted_mask = build2 (RSHIFT_EXPR, TREE_TYPE (shifted_mask),
                             shifted_mask, TYPE_SIZE (TREE_TYPE (low_lhs)));
      eraser = build_modify_expr (high_lhs, BIT_AND_EXPR,
                 convert (packed_array_unsigned_short_type_node,
                     build_unary_op (BIT_NOT_EXPR, shifted_mask, 0)));
      /* Do the assignment. */
      brush = build_pascal_binary_op (BIT_AND_EXPR,
               convert (packed_array_unsigned_long_type_node, newrhs), mask);
      brush = build_pascal_binary_op (LSHIFT_EXPR, brush, offset);
      brush = convert (packed_array_unsigned_long_type_node, brush);
      brush = build_pascal_binary_op (RSHIFT_EXPR, brush, TYPE_SIZE (TREE_TYPE (low_lhs)));
      brush = convert (packed_array_unsigned_short_type_node, brush);
      brush = build_modify_expr (high_lhs, BIT_IOR_EXPR, brush);
      /* Construct a COMPOUND_EXPR holding both. */
      high_assignment = build2 (COMPOUND_EXPR, TREE_TYPE (brush),
                                eraser, brush);
      /* Return another COMPOUND_EXPR holding both halfs. */
      return build2 (COMPOUND_EXPR, TREE_TYPE (high_assignment),
                     low_assignment, high_assignment);
    }
  if (TREE_CODE (lhs) == COMPOUND_EXPR)
    {
      /* COMPOUND_EXPRs are generated by some "magic" functions. */
      newrhs = build_modify_expr (TREE_OPERAND (lhs, 1), modifycode, rhs);
      CHK_EM (newrhs);
      return build2 (COMPOUND_EXPR, lhstype, TREE_OPERAND (lhs, 0), newrhs);
    }

  /* If a binary op has been requested, combine the old LHS value with the RHS
     producing the value we should actually store into the LHS. */
  if (modifycode != NOP_EXPR)
    {
      tree t, b;
      lhs = stabilize_reference (lhs);
      t = TREE_TYPE (lhs);
      b = base_type (t);
      if (b != t)
        lhs = convert (b, lhs);
      newrhs = convert_and_check (t, build_pascal_binary_op (modifycode, lhs, rhs));
    }

  if (TREE_CODE (lhs) == NOP_EXPR || TREE_CODE (lhs) == CONVERT_EXPR)
    {
      /* Handle a cast used as an "lvalue". We have already performed any binary
         operator using the value as cast. Now convert the result to the cast
         type of the lhs, and then true type of the lhs and store it there; then
         convert result back to the cast type to be the value of the assignment.
         Do not convert between types; just copy the data in memory. */
      tree inner_lhs = TREE_OPERAND (lhs, 0);

      /* build_type_cast() should already have checked that the sizes of the types match. */
      if (TREE_CODE (TYPE_SIZE (TREE_TYPE (inner_lhs))) == INTEGER_CST
          && TREE_CODE (TYPE_SIZE (lhstype)) == INTEGER_CST)
        gcc_assert (tree_int_cst_equal (TYPE_SIZE (TREE_TYPE (inner_lhs)), TYPE_SIZE (lhstype)));

      if (!comptypes (TREE_TYPE (lhs), TREE_TYPE (newrhs)))
        error ("incompatible types in assignment");

      if (warn_cast_align
          && TREE_CODE (TREE_TYPE (inner_lhs)) == POINTER_TYPE
          && TREE_CODE (TREE_TYPE (lhs)) == POINTER_TYPE
          && TREE_CODE (TREE_TYPE (TREE_TYPE (lhs))) != VOID_TYPE
          && TREE_CODE (TREE_TYPE (TREE_TYPE (lhs))) != FUNCTION_TYPE
          && TYPE_ALIGN (TREE_TYPE (TREE_TYPE (inner_lhs))) > TYPE_ALIGN (TREE_TYPE (TREE_TYPE (lhs))))
        gpc_warning ("lhs cast decreases required alignment of target type");

      return build_modify_expr (inner_lhs, NOP_EXPR, convert (TREE_TYPE (inner_lhs), newrhs));
    }

  /* Now we have handled acceptable kinds of LHS that are not truly lvalues.
     Reject anything strange now. */
  if (!lvalue_or_else (lhs, "assignment"))
    return error_mark_node;

  if (!is_init && !mark_lvalue (lhs, "assignment", 1))
    return error_mark_node;

  /* If storing into a structure or union member, it has probably been given type `int'.
     Compute the type that would go with the actual amount of storage the member occupies. */
  if (TREE_CODE (lhs) == COMPONENT_REF
      && (TYPE_IS_INTEGER_TYPE (lhstype) || TREE_CODE (lhstype) == REAL_TYPE))
    lhstype = TREE_TYPE (get_unwidened (lhs, 0));

  /* If storing in a field that is in actuality a short or narrower than one,
     we must store in the field in its actual type. */
  if (lhstype != TREE_TYPE (lhs))
    {
      lhs = copy_node (lhs);
      TREE_TYPE (lhs) = lhstype;
    }

  /* Convert new value to destination type. */
  newrhs = convert_for_assignment (lhstype, newrhs, "assignment", NULL_TREE, 0);
  CHK_EM (newrhs);

  result = build2 (MODIFY_EXPR, lhstype, lhs, newrhs);
  TREE_SIDE_EFFECTS (result) = 1;

  /* If we got the LHS in a different type for storing in,
     convert the result back to the nominal type of LHS
     so that the value we return always has the same type
     as the LHS argument. */
  if (olhstype == TREE_TYPE (result))
    return result;

  return convert_for_assignment (olhstype, result, "assignment", NULL_TREE, 0);
}
