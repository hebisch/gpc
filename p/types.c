/*Pascal types.

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

#ifndef LONG_TYPE_SIZE
#define LONG_TYPE_SIZE BITS_PER_WORD
#endif

static tree type_for_size1 (unsigned, int);
static int sce_cmp (const PTR, const PTR);
static tree limited_set (tree);
static int has_side_effects (tree, int);
static int count_unsigned_bits (tree);
static void check_nonconstants (tree);

#ifdef GCC_4_0
tree
pascal_build_int_cst (tree type, unsigned HOST_WIDE_INT low, HOST_WIDE_INT hi)
{
  tree t = make_node (INTEGER_CST);

  TREE_INT_CST_LOW (t) = low;
  TREE_INT_CST_HIGH (t) = hi;
  TREE_TYPE (t) = type;
  return t;
}

tree
pascal_fold1 (tree t)
{
  /* Force call to original fold */
  tree res = (fold) (t);
  if (TREE_CODE (res) == INTEGER_CST)
    return copy_node (res);
  else
   return res;
}

#endif


tree
check_result_type (tree type)
{
  CHK_EM (type);
  if (TREE_CODE (type) == VOID_TYPE)
    error ("function result must not be `Void' (use a procedure instead)");
  else if (contains_file_p (type))
    error ("function result must not be a file");
  else if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
    error ("function result must not be an undiscriminated schema type");
  else if (PASCAL_PROCEDURAL_TYPE (type))
    error ("function result must not be a procedural type");
  else
    {
      if (PASCAL_TYPE_OBJECT (type))
        {
          if (TYPE_LANG_CODE_TEST (type, PASCAL_LANG_ABSTRACT_OBJECT))
            error ("abstract object type declared as function result type");
          else if (co->warn_object_assignment)
            gpc_warning ("object type declared as function result type");
        }
      if (!SCALAR_TYPE (TREE_CODE (type)))
        chk_dialect ("structured function result types are", NOT_CLASSIC_PASCAL);
      return type;
    }
  return error_mark_node;
}

/* Return an unsigned type the same as TYPE in other respects. */
tree
unsigned_type (tree type)
{
  tree type1 = TYPE_MAIN_VARIANT (type);
  return TYPE_UNSIGNED (type) ? type
    : type1 == byte_integer_type_node ? byte_unsigned_type_node
    : type1 == pascal_integer_type_node ? pascal_cardinal_type_node
    : type1 == integer_type_node ? unsigned_type_node
    : type1 == short_integer_type_node ? short_unsigned_type_node
    : type1 == long_integer_type_node ? long_unsigned_type_node
    : type1 == long_long_integer_type_node ? long_long_unsigned_type_node
    : type1 == intDI_type_node ? unsigned_intDI_type_node
    : type1 == intSI_type_node ? unsigned_intSI_type_node
    : type1 == intHI_type_node ? unsigned_intHI_type_node
    : type1 == intQI_type_node ? unsigned_intQI_type_node
    : signed_or_unsigned_type (1, type);
}

/* Return a signed type the same as TYPE in other respects. */
tree
signed_type (tree type)
{
  tree type1 = TYPE_MAIN_VARIANT (type);
  return !TYPE_UNSIGNED (type) ? type
    : type1 == byte_unsigned_type_node ? byte_integer_type_node
    : type1 == pascal_cardinal_type_node ? pascal_integer_type_node
    : type1 == unsigned_type_node ? integer_type_node
    : type1 == short_unsigned_type_node ? short_integer_type_node
    : type1 == long_unsigned_type_node ? long_integer_type_node
    : type1 == long_long_unsigned_type_node ? long_long_integer_type_node
    : type1 == unsigned_intDI_type_node ? intDI_type_node
    : type1 == unsigned_intSI_type_node ? intSI_type_node
    : type1 == unsigned_intHI_type_node ? intHI_type_node
    : type1 == unsigned_intQI_type_node ? intQI_type_node
    : signed_or_unsigned_type (0, type);
}

/* Return an integer type with BITS bits of precision,
   that is unsigned if UNSIGNEDP is nonzero, otherwise signed. */
static tree
type_for_size1 (unsigned bits, int unsignedp)
{
  if (bits == TYPE_PRECISION (pascal_integer_type_node))
    return unsignedp ? pascal_cardinal_type_node : pascal_integer_type_node;
  if (bits == TYPE_PRECISION (integer_type_node))
    return unsignedp ? unsigned_type_node : integer_type_node;
  if (bits == TYPE_PRECISION (byte_integer_type_node))
    return unsignedp ? byte_unsigned_type_node : byte_integer_type_node;
  if (bits == TYPE_PRECISION (short_integer_type_node))
    return unsignedp ? short_unsigned_type_node : short_integer_type_node;
  if (bits == TYPE_PRECISION (long_integer_type_node))
    return unsignedp ? long_unsigned_type_node : long_integer_type_node;
  if (bits == TYPE_PRECISION (long_long_integer_type_node))
    return unsignedp ? long_long_unsigned_type_node : long_long_integer_type_node;
  return NULL_TREE;
}

/* Return an integer type with BITS bits of precision,
   that is unsigned if UNSIGNEDP is nonzero, otherwise signed. */
tree
type_for_size (unsigned bits, int unsignedp)
{
  tree t = type_for_size1 (bits, unsignedp);
  if (t)
    return t;
  if (bits <= TYPE_PRECISION (intQI_type_node))
    return unsignedp ? unsigned_intQI_type_node : intQI_type_node;
  if (bits <= TYPE_PRECISION (intHI_type_node))
    return unsignedp ? unsigned_intHI_type_node : intHI_type_node;
  if (bits <= TYPE_PRECISION (intSI_type_node))
    return unsignedp ? unsigned_intSI_type_node : intSI_type_node;
  if (bits <= TYPE_PRECISION (intDI_type_node))
    return unsignedp ? unsigned_intDI_type_node : intDI_type_node;
  if (bits <= TYPE_PRECISION (intTI_type_node))
    return unsignedp ? unsigned_intTI_type_node : intTI_type_node;
  gcc_unreachable ();
}

/* Return a type of the same precision as TYPE and unsigned or signed
   according to UNSIGNEDP. */
tree
signed_or_unsigned_type (int unsignedp, tree type)
{
  tree t;
  if (!ORDINAL_TYPE (TREE_CODE (type)) || TYPE_UNSIGNED (type) == unsignedp)
    return type;
  t = type_for_size1 (TYPE_PRECISION (type), unsignedp);
  return t ? t : type;
}

/* Return a data type that has machine mode MODE. If the mode is an integer,
   then UNSIGNEDP selects between signed and unsigned types. */
tree
type_for_mode (enum machine_mode mode, int unsignedp)
{
  if (mode == TYPE_MODE (pascal_integer_type_node))
    return unsignedp ? pascal_cardinal_type_node : pascal_integer_type_node;
  if (mode == TYPE_MODE (integer_type_node))
    return unsignedp ? unsigned_type_node : integer_type_node;
  if (mode == TYPE_MODE (byte_integer_type_node))
    return unsignedp ? byte_unsigned_type_node : byte_integer_type_node;
  if (mode == TYPE_MODE (short_integer_type_node))
    return unsignedp ? short_unsigned_type_node : short_integer_type_node;
  if (mode == TYPE_MODE (long_integer_type_node))
    return unsignedp ? long_unsigned_type_node : long_integer_type_node;
  if (mode == TYPE_MODE (long_long_integer_type_node))
    return unsignedp ? long_long_unsigned_type_node : long_long_integer_type_node;
  if (mode == TYPE_MODE (intQI_type_node))
    return unsignedp ? unsigned_intQI_type_node : intQI_type_node;
  if (mode == TYPE_MODE (intHI_type_node))
    return unsignedp ? unsigned_intHI_type_node : intHI_type_node;
  if (mode == TYPE_MODE (intSI_type_node))
    return unsignedp ? unsigned_intSI_type_node : intSI_type_node;
  if (mode == TYPE_MODE (intDI_type_node))
    return unsignedp ? unsigned_intDI_type_node : intDI_type_node;
  if (mode == TYPE_MODE (intTI_type_node))
    return unsignedp ? unsigned_intTI_type_node : intTI_type_node;
  if (mode == TYPE_MODE (float_type_node))
    return float_type_node;
  if (mode == TYPE_MODE (double_type_node))
    return double_type_node;
  if (mode == TYPE_MODE (long_double_type_node))
    return long_double_type_node;
  if (mode == TYPE_MODE (build_pointer_type (char_type_node)))
    return build_pointer_type (char_type_node);
  if (mode == TYPE_MODE (build_pointer_type (pascal_integer_type_node)))
    return build_pointer_type (pascal_integer_type_node);
  if (mode == TYPE_MODE (build_pointer_type (integer_type_node)))
    return build_pointer_type (integer_type_node);
  return NULL_TREE;
}

static int
sce_cmp (const PTR xp, const PTR yp)
{
  tree c1 = TREE_PURPOSE (*(tree *) xp);
  tree c2 = TREE_PURPOSE (*(tree *) yp);
  if (const_lt (c1, c2))
    return -1;
  else if (const_lt (c2, c1))
    return 1;
  else
    return 0;
}

/* Build a constructor node for set elements. construct_set later
   converts this to a set. Assumes that input list is unique (can
   be mangled). */
tree
build_set_constructor (tree elements)
{
  tree t, res = elements;
  tree * pres = &res;
  int is_constant = 1, is_intcst = 1, side_effects = 0, n = 0;
  while (*pres)
    {
      tree m = *pres;
      tree lower = TREE_PURPOSE (m), upper = TREE_VALUE (m);
      if (!lower || EM (lower) || (upper && EM (upper)))
        return error_mark_node;
      STRIP_TYPE_NOPS (lower);
      lower = fold (string_may_be_char (lower, 1));
      if (upper)
        {
          STRIP_TYPE_NOPS (upper);
          upper = fold (string_may_be_char (upper, 1));
        }
      if (!ORDINAL_TYPE (TREE_CODE (TREE_TYPE (lower))))
        {
          error ("set constructor elements must be of ordinal type");
          return error_mark_node;
        }
      if (upper && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (lower)), TYPE_MAIN_VARIANT (TREE_TYPE (upper))))
        {
          error ("set range bounds are of incompatible type");
          return error_mark_node;
        }
      if (m != elements
          && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (TREE_PURPOSE (elements))),
                         TYPE_MAIN_VARIANT (TREE_TYPE (lower))))
        {
          error ("set constructor elements are of incompatible type");
          return error_mark_node;
        }
      if (upper
          && TREE_CODE (lower) == INTEGER_CST
          && TREE_CODE (upper) == INTEGER_CST
          && tree_int_cst_lt (upper, lower))
        {
          gpc_warning ("set constructor range is empty");
          *pres = TREE_CHAIN (m);
          continue;
        }
      else
        pres = &TREE_CHAIN (m);
      if (!TREE_CONSTANT (lower) || (upper && !TREE_CONSTANT (upper)))
        is_constant = 0;
      if (TREE_CODE (lower) != INTEGER_CST || (upper && TREE_CODE (upper) != INTEGER_CST))
        is_intcst = 0;
      if (TREE_SIDE_EFFECTS (lower) || (upper && TREE_SIDE_EFFECTS (upper)))
        side_effects = 1;
      if (!upper)  /* Backend requires upper to be set. */
        {
          if (TREE_SIDE_EFFECTS (lower))
            lower = save_expr (lower);
          upper = lower;
        }
      TREE_PURPOSE (m) = lower;
      TREE_VALUE (m) = upper;
      n++;
    }
  elements = res;
  /* A single element/range with side-effects should be safe. */
  if (side_effects && TREE_CHAIN (elements))
    {
      gpc_warning ("expressions with side-effects in set constructors are");
      gpc_warning (" problematic since evaluation is implementation-dependent");
    }
  /* Sort and merge constant constructor elements */
  if (is_intcst && n)
    {
      tree *p = alloca (n * sizeof (tree));
      tree m;
      int i;
      for (m = elements /* copy_list (elements) */, i = 0; m; m = TREE_CHAIN (m), i++)
        p[i] = m;
      gcc_assert (i == n);
      qsort (p, n, sizeof (tree), sce_cmp);
      elements = p[0];
      i = 0;
      while (i < n)
        {
          int j = i + 1;
          tree u = TREE_VALUE (p[i]);
          while (j < n && !const_plus1_lt (u, TREE_PURPOSE (p[j])))
            {
              tree u2 = TREE_VALUE (p[j]);
              if (const_lt (u, u2))
                u = u2;
              j++;
            }
          TREE_VALUE (p[i]) = u;
          TREE_CHAIN (p[i]) = j < n ? p[j] : NULL_TREE;
          i = j;
        }
    }
  t = make_node (PASCAL_SET_CONSTRUCTOR);
  TREE_TYPE (t) = empty_set_type_node;  /* real type not yet known */
  SET_CONSTRUCTOR_ELTS (t) = elements;
  TREE_CONSTANT (t) = TREE_STATIC (t) = is_constant;
#ifdef GCC_4_0
  TREE_INVARIANT (t) = is_constant;
#endif
  PASCAL_CONSTRUCTOR_INT_CST (t) = is_intcst;
  TREE_SIDE_EFFECTS (t) = side_effects;
  TREE_ADDRESSABLE (t) = 1;
  return t;
}

static tree
limited_set (tree lo)
{
  tree hi = fold (build_pascal_binary_op (PLUS_EXPR, lo, size_int (co->set_limit - 1)));
  gpc_warning ("constructing limited integer set `%li .. %li';",
           (long int) TREE_INT_CST_LOW (lo),
           (long int) TREE_INT_CST_LOW (hi));
  gpc_warning (" use `--setlimit=NUMBER' to change the size limit at compile time.");
  return hi;
}

/* Build a SET_TYPE node from a set constructor.

   CONSTRUCTOR is a CONSTRUCTOR type node whose CONSTRUCTOR_ELTS
   contains a TREE_LIST of the elements(/pairs) of the set.

   If arg_type == 0, target_or_type is a VAR_DECL node where we should construct our set.
   If arg_type == 1, target_or_type is a SET_TYPE node which we should model our new set after.
   If arg_type == 2, target_or_type is a SET_TYPE node passed as a parameter to a function.
                     (Special case for empty set constructor passing)

   target_or_type is NULL_TREE if we don't know the destination
   where we should put the constructed set, nor the type we should
   be cloning to our constructed set.

   Return NULL_TREE if we assigned the set to the existing TARGET_SET,
   else return the constructor whose TREE_TYPE type we now set. */
tree
construct_set (tree constructor, tree target_or_type, int arg_type)
{
  tree elements, elem, set_low, set_high, setsize, this_set_type;
  tree nelem;
  CHK_EM (constructor);
  elements = SET_CONSTRUCTOR_ELTS (constructor);
  if (!elements && (arg_type == 0 || (arg_type == 1 && !target_or_type)))
    {
      if (arg_type == 0 && target_or_type)
        {
          /* Clear the target set. */
#ifdef EGCS
          tree size = size_binop (CEIL_DIV_EXPR, TYPE_SIZE_UNIT (TREE_TYPE (target_or_type)),
            size_int (TYPE_PRECISION (byte_integer_type_node) / BITS_PER_UNIT));
#else
          tree size = size_binop (CEIL_DIV_EXPR, TYPE_SIZE (TREE_TYPE (target_or_type)), size_int (BITS_PER_UNIT));
#endif
          expand_expr_stmt (build_memset (build_unary_op (ADDR_EXPR, target_or_type, 0),
            size, integer_zero_node));
          return NULL_TREE;
        }
      else
        return constructor;
    }
  if (target_or_type)
    {
      this_set_type = arg_type ? target_or_type : TREE_TYPE (target_or_type);
      set_low = TYPE_MIN_VALUE (TYPE_DOMAIN (this_set_type));
      set_high = TYPE_MAX_VALUE (TYPE_DOMAIN (this_set_type));
    }
  else
    {
      tree type;
      if (elements)
        type = base_type (TREE_TYPE (TREE_PURPOSE (elements)));
      else
        {
          /* Empty set constructor to unknown set? */
          gcc_assert (target_or_type);
          type = TREE_TYPE (target_or_type);
        }
      set_low = TYPE_MIN_VALUE (type);
      set_high = TYPE_MAX_VALUE (type);

      /* avoid [-MaxInt .. MaxInt] storage request */
      if (TYPE_IS_INTEGER_TYPE (type))
        {
          tree size = NULL_TREE;
          set_low = NULL_TREE;
          set_high = NULL_TREE;

          /* Scan for the min and max values */
          for (elem = elements; elem; elem = TREE_CHAIN (elem))
            {
              tree lo = TREE_PURPOSE (elem);
              tree hi = TREE_VALUE (elem);
              gcc_assert (hi);  /* only ranges here, see build_set_constructor */
              STRIP_NOPS (lo);
              STRIP_NOPS (hi);
              /* Non-constant bounds. Try to rescue it by looking
                 whether their types have reasonable bounds. */
              while (TREE_CODE (lo) != INTEGER_CST)
                lo = TYPE_MIN_VALUE (TREE_TYPE (lo));
              while (TREE_CODE (hi) != INTEGER_CST)
                hi = TYPE_MAX_VALUE (TREE_TYPE (hi));
              if (!set_low || tree_int_cst_lt (lo, set_low))
                set_low = lo;
              if (!set_high || tree_int_cst_lt (set_high, hi))
                set_high = hi;
            }
          if (set_low && set_high)
            size = fold (build2 (PLUS_EXPR, pascal_integer_type_node,
                     integer_one_node,
                     fold (build2 (MINUS_EXPR, pascal_integer_type_node,
                                  convert (pascal_integer_type_node, set_high),
                                  convert (pascal_integer_type_node, set_low)))));

          /* If bounds are constant but too big, construct a limited set. */
          if (size
              && (TREE_OVERFLOW (size)
                  || TREE_INT_CST_HIGH (size) != 0
                  || TREE_INT_CST_LOW (size) == 0  /* overflow */
                  || (unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (size) > co->set_limit))
            size = NULL_TREE;

          if (!size)
            {
              if (!set_low || INT_CST_LT (set_low, integer_zero_node))
                set_low = integer_zero_node;
              set_high = limited_set (set_low);
            }
          type = build_range_type (TREE_TYPE (set_low), set_low, set_high);
          TREE_SET_CODE (type, TREE_CODE (TREE_TYPE (set_low)));
        }
      /* @@ non-constant bounds not yet supported (Why???) */
      gcc_assert (int_size_in_bytes (type) != -1);
      this_set_type = build_set_type (type);
      PASCAL_TYPE_CANONICAL_SET (this_set_type) = 1;
    }

  /* Now we know the type of the target set, so we switch the constructor
     type to be the correct type. */
  constructor = copy_node (constructor);
  TREE_TYPE (constructor) = this_set_type;

  setsize = size_binop (MINUS_EXPR, convert (sbitsizetype, set_high), convert (sbitsizetype, set_low));
  if (TREE_INT_CST_HIGH (setsize)
      || (signed HOST_WIDE_INT) TREE_INT_CST_LOW (setsize) < 0
      || (signed HOST_WIDE_INT) TREE_INT_CST_LOW (setsize) + 1 < 0)
    {
      error ("set size too big");
      return error_mark_node;
    }

  /* Check that the constructor elements are of valid type
     and within the allowed range. */
  nelem = NULL_TREE;
  for (elem = elements; elem; elem = TREE_CHAIN (elem))
    {
      tree lo = TREE_PURPOSE (elem), hi = TREE_VALUE (elem);
      tree lo2, hi2;
      if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (lo)), TYPE_MAIN_VARIANT (TREE_TYPE (this_set_type))))
        {
          error ("type mismatch in set constructor");
          return error_mark_node;
        }
      lo2 = range_check_2 (set_low, set_high, lo);
      CHK_EM (lo2);
      hi2 = hi == lo ? lo2 : range_check_2 (set_low, set_high, hi);
      CHK_EM (hi2);
      nelem = tree_cons (lo2, hi2, nelem);
    }
  nelem = nreverse (nelem);
  SET_CONSTRUCTOR_ELTS (constructor) = nelem;
  return constructor;
}

tree
build_set_type (tree type)
{
  tree t;
  tree lo;
  tree hi;
  CHK_EM (type);
  if (!ORDINAL_TYPE (TREE_CODE (type)))
    {
      error ("set base type must be an ordinal type");
      return error_mark_node;
    }
  lo = TYPE_MIN_VALUE (type);
  hi = TYPE_MAX_VALUE (type);
  if (TREE_CODE (lo) != INTEGER_CST || TREE_CODE (hi) != INTEGER_CST)
    {
      /* Otherwise, layout_type would abort */
      error ("internal GPC error: sets with non-constant bounds are not supported yet");
      return error_mark_node;
    }
  else if (TYPE_IS_INTEGER_TYPE (type))
    {
      /* Avoid huge sets such as `set of Integer' */
      tree sblo = convert (sbitsizetype, lo);
      tree sbhi = convert (sbitsizetype, hi);
      tree bitsize = size_binop (PLUS_EXPR, size_binop (MINUS_EXPR, sbhi, sblo),
                                 convert (sbitsizetype, integer_one_node));
      if (TREE_INT_CST_HIGH (bitsize) != 0
          || TREE_INT_CST_LOW (bitsize) == 0  /* overflow */
          || (unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (bitsize) > co->set_limit)
        {
          sbhi = limited_set (sblo);
          type = build_range_type (pascal_integer_type_node, sblo, sbhi);
          CHK_EM (type);
        }
    }
  t = make_node (SET_TYPE);
  TREE_TYPE (t) = TYPE_DOMAIN (t) = type;
  layout_type (t);
  return t;
}

/* Append `Chr (0)' to the string VAL. If it is not of variable string (schema)
   type already, copy it to a temporary variable first. Appending is always
   possible in string schemata since the size of the char array within the
   string is calculated to reserve place for the #0. */
tree
convert_to_cstring (tree val)
{
  tree ch0 = convert (char_type_node, integer_zero_node);
  tree orig_val = val, stmts = NULL_TREE, chr, z;
  int need_cond;

  val = char_may_be_string (val);

  /* A string constant or a 0-based array of Char is already acceptable as a
     CString. Just take the address. */
  if (TREE_CODE (val) == STRING_CST
      || (TREE_CODE (TREE_TYPE (val)) == ARRAY_TYPE
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE
                (TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (val)))))
          && integer_zerop (TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (val))))))
    {
      while (TREE_CODE (val) == SAVE_EXPR)
        val = TREE_OPERAND (val, 0);
      return convert (cstring_type_node, build_pascal_unary_op (ADDR_EXPR, val));
    }

  /* Dig out the real string, so save_expr does not need to worry about
     NON_LVALUE_EXPRs and such. Track COMPOUND_EXPRs to put back later. */
  while (TREE_CODE (val) == COMPOUND_EXPR
         || TREE_CODE (val) == NON_LVALUE_EXPR
         || TREE_CODE (val) == SAVE_EXPR
         || TREE_CODE (val) == NOP_EXPR)
    if (TREE_CODE (val) == COMPOUND_EXPR)
      {
        if (stmts)
          stmts = build2 (COMPOUND_EXPR, void_type_node,
                          TREE_OPERAND (val, 0), stmts);
        else
          stmts = TREE_OPERAND (val, 0);
        val = TREE_OPERAND (val, 1);
      }
    else
      val = TREE_OPERAND (val, 0);

  if (is_variable_string_type (TREE_TYPE (val)))
    {
      if (lvalue_p (val))
        val = build_indirect_ref (save_expr (build_unary_op (ADDR_EXPR, val, 0)), NULL);
      else
        val = save_expr (val);
      need_cond = 1;
    }
  else
    {
      orig_val = val = new_string_by_model (NULL_TREE, val, 1);
      need_cond = 0;
    }

  chr = build_array_ref (PASCAL_STRING_VALUE (val),
          build_pascal_binary_op (PLUS_EXPR, PASCAL_STRING_LENGTH (val), integer_one_node));

  TREE_READONLY (chr) = 0;  /* avoid warning */
  z = build_modify_expr (chr, NOP_EXPR, ch0);

  /* Don't actually assign the #0 if the memory location contains one
     already. This prevents crashing at runtime if val is in constant
     storage (whether or not it is, is generally not known at
     compile-time, e.g., if it's a reference parameter). If val is a
     temporary variable just created above, we don't need the extra check. */
  if (need_cond)
    z = build3 (COND_EXPR, char_type_node,
                build_pascal_binary_op (EQ_EXPR, chr, ch0), ch0, z);
  if (stmts)
    z = build2 (COMPOUND_EXPR, void_type_node, stmts, z);
  val = build2 (COMPOUND_EXPR, TREE_TYPE (orig_val), z, val);
  return convert (cstring_type_node, build_pascal_unary_op (ADDR_EXPR, PASCAL_STRING_VALUE (val)));
}

/* Convert string constants of length 1 (or 0) to char constants. */
tree
string_may_be_char (tree expr, int assignment_compatibility)
{
  if (expr
      && TREE_CODE (expr) == STRING_CST
      && PASCAL_CST_FRESH (expr)
      && TREE_STRING_LENGTH (expr) <= 2  /* including the trailing #0 */
      && (assignment_compatibility || TREE_STRING_LENGTH (expr) == 2))
    {
      tree t;
      char ch;
      if (TREE_STRING_LENGTH (expr) == 2)
        ch = TREE_STRING_POINTER (expr)[0];
      else
        {
          /* Assigning an empty string to a char.
             According to Extended Pascal this is allowed. (Ouch!) */
          if (pedantic || !(co->pascal_dialect & E_O_PASCAL))
            pedwarn ("assignment of empty string to a char yields a space");
          ch = ' ';
        }
#ifndef GCC_4_0
      t = build_int_2 (ch & ((1 << BITS_PER_UNIT) - 1), 0);
      TREE_TYPE (t) = char_type_node;
#else
      t = build_int_cst_wide (char_type_node, 
                                ch & ((1 << BITS_PER_UNIT) - 1), 0);
#endif
      PASCAL_CST_FRESH (t) = PASCAL_CST_FRESH (expr);
      return t;
    }
  return expr;
}

/* Convert a char constant to a string constant. (This is not necessary for
   constants generated by the lexer since it always generates string constants,
   but it can be necessary for explicitly declared Pascal Char constants.) */
tree
char_may_be_string (tree expr)
{
  if (TREE_CODE (expr) == INTEGER_CST &&
      TYPE_IS_CHAR_TYPE (TREE_TYPE (expr)))
    {
      char buf = TREE_INT_CST_LOW (expr);
      expr = build_string_constant (&buf, 1, PASCAL_CST_FRESH (expr));
    }
  return expr;
}

/* Since a Pascal declaration gives a new type we have to defeat
   caching in `build_pointer_type'. */
tree
build_pascal_pointer_type (tree to_type)
{
  if (TYPE_READONLY (to_type))
    chk_dialect ("pointers to `const' types are", GNU_PASCAL);
  if (TYPE_POINTER_TO (to_type))
    to_type = build_type_copy (to_type);
  return build_pointer_type (to_type);
}

/* Our string schema looks like this:
   String (Capacity: Cardinal) = record
     Length: Cardinal;
     String: array [1 .. Capacity + 1] of Char
   end;
   (the `+ 1' is for appending a #0 in convert_to_cstring) */
tree
build_pascal_string_schema (tree capacity)
{
  tree string, fields, string_range, internal_capacity = capacity;
  if (capacity)
    {
      CHK_EM (capacity);
      if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (capacity)))
        {
          error ("string capacity must be of integer type");
          return error_mark_node;
        }
    }

#ifndef EGCS97
  push_obstacks_nochange ();
  end_temporary_allocation ();
#endif

  string = start_struct (RECORD_TYPE);

  fields = build_field (get_identifier ("Capacity"), pascal_cardinal_type_node);
  PASCAL_TREE_DISCRIMINANT (fields) = 1;

#ifdef PG__NEW_STRINGS
  if (!capacity)
    {
#ifdef GCC_4_0
      internal_capacity = build3 (COMPONENT_REF, pascal_cardinal_type_node,
        build0 (PLACEHOLDER_EXPR, string), fields, NULL_TREE);
#else
      internal_capacity = build (COMPONENT_REF, pascal_cardinal_type_node,
        build (PLACEHOLDER_EXPR, string), fields);
#endif
#if 0
      capacity = integer_zero_node;
#else
      capacity = pascal_maxint_node; /* @@@@ */
//      capacity = internal_capacity;
#endif
    }
  size_volatile++;  /* @@ Otherwise compilation of 'russ3a.pas' crashes */
#else
  if (!capacity)
    internal_capacity = capacity = integer_zero_node;
  size_volatile++;
#endif

  string_range = build_range_type (pascal_integer_type_node, integer_one_node,
                   build_pascal_binary_op (PLUS_EXPR, internal_capacity, integer_one_node));
  fields = chainon (fields,
           chainon (build_field (get_identifier ("length"), pascal_cardinal_type_node),
                    build_field (schema_id, build_simple_array_type (char_type_node, string_range))));
  string = finish_struct (string, fields, 0);

#ifndef PG__NEW_STRINGS
  size_volatile--;
#else
  size_volatile--;  /* @@ */
#endif

#ifndef EGCS97
  pop_obstacks ();
#endif

  CHK_EM (string);
  allocate_type_lang_specific (string);
  TYPE_LANG_CODE (string) = PASCAL_LANG_DISCRIMINATED_STRING;
  TYPE_LANG_BASE (string) = string_schema_proto_type;
  TYPE_LANG_DECLARED_CAPACITY (string) = capacity;
  TYPE_ALIGN (string) = TYPE_ALIGN (pascal_cardinal_type_node);  /* even within packed records */
  return string;
}

int
is_string_compatible_type (tree string, int error_flag)
{
  return TYPE_IS_CHAR_TYPE (TREE_TYPE (string)) || is_string_type (string, error_flag);
}

/* Return 1 if the type of the node STRING is a character array node
            or a string constant or a string schema.
   Return 0 if we know it's not a valid string. */
int
is_string_type (tree string, int error_flag)
{
  return TREE_CODE (string) == STRING_CST || is_of_string_type (TREE_TYPE (string), error_flag);
}

int
is_of_string_type (tree type, int error_flag)
{
  if (PASCAL_TYPE_STRING (type))
    return 1;

  if (TREE_CODE (type) != ARRAY_TYPE
      || TYPE_MAIN_VARIANT (TREE_TYPE (type)) != char_type_node)
    return 0;

  if (!PASCAL_TYPE_PACKED (type))
    {
      if (co->pascal_dialect && !(co->pascal_dialect & (B_D_PASCAL)))
        return 0;
      if (error_flag)
        chk_dialect ("using unpacked character arrays as strings is", B_D_PASCAL);
    }

  /* String type low index must be one and nonvarying according to ISO */
  if (tree_int_cst_equal (TYPE_MIN_VALUE (TYPE_DOMAIN (type)),
                          integer_one_node))
    {
       return !((co->pascal_dialect & CLASSIC_PASCAL) &&
                tree_int_cst_equal (TYPE_MAX_VALUE (TYPE_DOMAIN (type)),
                                    integer_one_node));
    }
  if (co->pascal_dialect & C_E_O_PASCAL)
    return 0;

  chk_dialect ("using character arrays with lower bound not 1 as strings is", B_D_M_PASCAL);
  return 1;
}

int
is_variable_string_type (tree type)
{
  return (TREE_CODE (type) == REFERENCE_TYPE && PASCAL_TYPE_STRING (TREE_TYPE (type)))
         || PASCAL_TYPE_STRING (type);
}

tree
build_discriminants (tree names, tree type, tree stype)
{
  tree t;
  if (!ORDINAL_TYPE (TREE_CODE (type)))
    {
      error ("schema discriminant type must be ordinal");
      type = pascal_integer_type_node;
    }
  for (t = names; t; t = TREE_CHAIN (t))
    {
      /* Build VAR_DECL nodes to represent the formal discriminants.
         Store the previous meanings of the identifiers
         in the TREE_PURPOSE fields of the id_list. */
      tree id = TREE_VALUE (t);
#if 0
      tree decl = TREE_VALUE (t) = build_decl (VAR_DECL, id, type);
      SET_DECL_ASSEMBLER_NAME (decl, id);
      allocate_decl_lang_specific (decl);
      PASCAL_TREE_DISCRIMINANT (decl) = 1;
#else
      tree decl = build_decl (CONST_DECL, id, type);
#endif
      tree field = build_field (id, type);
#ifdef GCC_4_0
      tree val = build3 (COMPONENT_REF, TREE_TYPE (field),
            build0 (PLACEHOLDER_EXPR, stype), field, NULL_TREE);
#else
      tree val = build (COMPONENT_REF, TREE_TYPE (field),
            build (PLACEHOLDER_EXPR, stype), field);
#endif
      DECL_INITIAL (decl) = val;
      TREE_PURPOSE (t) = IDENTIFIER_VALUE (id);
      IDENTIFIER_VALUE (id) = decl;
    }
  return names;
}

/* Check whether the expression EXPR (to be used in type definitions) contains
   formal schema discriminants. This is the case if and only if EXPR contains
   VAR_DECLs with PASCAL_TREE_DISCRIMINANT set. If so, replace them with
   CONVERT_EXPRs and add them to the DECL_LANG_FIXUPLIST field of the
   discriminant's VAR_DECL. */
tree
maybe_schema_discriminant (tree expr)
{
  enum tree_code code = TREE_CODE (expr);
  if (code == VAR_DECL && PASCAL_TREE_DISCRIMINANT (expr))
    {
      tree new_expr = build1 (CONVERT_EXPR, TREE_TYPE (expr), expr);
      PASCAL_TREE_DISCRIMINANT (new_expr) = 1;
      DECL_LANG_FIXUPLIST (expr) = tree_cons (NULL_TREE, new_expr, DECL_LANG_FIXUPLIST (expr));
      expr = new_expr;
    }
  else if (code == CALL_EXPR)
    {
      tree t;
#ifndef GCC_4_3
      CALL_EXPR_FN (expr) = maybe_schema_discriminant (CALL_EXPR_FN (expr));
      for (t = TREE_OPERAND (expr, 1); t; t = TREE_CHAIN (t))
        TREE_VALUE (t) = maybe_schema_discriminant (TREE_VALUE (t));
#else
      long n = call_expr_nargs (expr);
      long i;
      CALL_EXPR_FN (expr) = maybe_schema_discriminant (CALL_EXPR_FN (expr));
      for (i = 0; i < n; i++)
        CALL_EXPR_ARG (expr, i) = maybe_schema_discriminant
                                     (CALL_EXPR_ARG(expr, i));
#endif
    }
  else if (code == TREE_LIST)
    {
      tree t;
      for (t = expr; t; t = TREE_CHAIN (t))
        TREE_VALUE (t) = maybe_schema_discriminant (TREE_VALUE (t));
    }
  else if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (expr, i))
          TREE_OPERAND (expr, i) = maybe_schema_discriminant (TREE_OPERAND (expr, i));
    }
  return expr;
}

static int
has_side_effects (tree t, int had)
{
  enum tree_code code = TREE_CODE (t);
  if (TREE_CODE_CLASS (code) == tcc_type)
    {
      tree i = TYPE_GET_INITIALIZER (t);
      if (i && has_side_effects (i, 0))
        return 1;
    }
  if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      if (!had && TREE_SIDE_EFFECTS (t))
        return 1;
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (t, i) && has_side_effects (TREE_OPERAND (t, i), 1))
          return 1;
    }
  switch (TREE_CODE (t))
  {
    case TREE_LIST:
      for (; t; t = TREE_CHAIN (t))
        if ((TREE_VALUE (t) && has_side_effects (TREE_VALUE (t), 0))
            || (TREE_PURPOSE (t) && has_side_effects (TREE_PURPOSE (t), 0)))
          return 1;
      return 0;

    case VAR_DECL:
      return PASCAL_HAD_SIDE_EFFECTS (t);

    case BOOLEAN_TYPE:
#ifndef GCC_4_2
    case CHAR_TYPE:
#endif
    case ENUMERAL_TYPE:
    case INTEGER_TYPE:
      return has_side_effects (TYPE_MIN_VALUE (t), 0)
             || has_side_effects (TYPE_MAX_VALUE (t), 0)
             || (TREE_TYPE (t) && has_side_effects (TREE_TYPE (t), 0));
    case ARRAY_TYPE:
      return has_side_effects (TREE_TYPE (t), 0) || has_side_effects (TYPE_DOMAIN (t), 0);
    case RECORD_TYPE:
    case UNION_TYPE:
      {
        tree f;
        if (PASCAL_TYPE_STRING (t))
          return has_side_effects (TYPE_LANG_DECLARED_CAPACITY (t), 0);
        for (f = TYPE_FIELDS (t); f; f = TREE_CHAIN (f))
          {
            if (has_side_effects (TREE_TYPE (f), 0)
                || (PASCAL_TREE_DISCRIMINANT (f) && has_side_effects (DECL_LANG_FIXUPLIST (f), 0)))
              return 1;
          }
        return 0;
      }
    default:
      return 0;
  }
}

/* Return a new schema type with formal discriminants discriminants (a TREE_LIST
   holding VAR_DECL nodes) for the type template TYPE. Return a RECORD_TYPE with
   its TYPE_LANG_CODE set accordingly, having as fields the discriminants plus a
   `_p_Schema' field which contains the actual type. */
tree
build_schema_type (tree type, tree discriminants, tree init, tree stype)
{
  tree fields = NULL_TREE, d, tmp, t;
  chk_dialect ("schema types are", E_O_M_PASCAL);
  if (init && check_pascal_initializer (type, init))
    {
      error ("invalid initializer");
      init = NULL_TREE;
    }
  /* Release the identifiers of the discriminants. We must do this also in case
     of a previous error, but check_pascal_initializer still needs them! */
#if 0
  t = stype;
#endif
  for (d = discriminants; d; d = TREE_CHAIN (d))
    {
//      tree id = DECL_NAME (TREE_VALUE (d));
#if 0
      tree field = build_field (id, TREE_TYPE (TREE_VALUE (d)));
      tree val = build3 (COMPONENT_REF, TREE_TYPE (field), 
            build (PLACEHOLDER_EXPR, t), field, NULL_TREE);
      tree fix = DECL_LANG_FIXUPLIST (TREE_VALUE (d));
      for (; fix; fix = TREE_CHAIN (fix))
        {
          tree target = TREE_VALUE (fix);
          gcc_assert (TREE_CODE (target) == CONVERT_EXPR && PASCAL_TREE_DISCRIMINANT (target));
          TREE_OPERAND (target, 0) = val;
        }
#else
      tree id = TREE_VALUE (d);
      tree val = DECL_INITIAL (IDENTIFIER_VALUE (id));
      tree field = TREE_OPERAND (val, 1);
#endif
      fields = chainon (fields, field);
      IDENTIFIER_VALUE (id) = TREE_PURPOSE (d);
    }
  /* Do not return before this point! */
  CHK_EM (type);
  if (!init)
    init = TYPE_GET_INITIALIZER (type);
  fields = chainon (fields, build_field (schema_id, type));
  for (t = fields; t && !has_side_effects (TREE_TYPE (t), 0); t = TREE_CHAIN (t)) ;
  if (t || (init && has_side_effects (init, 0)))
    error ("expressions with side-effects are not allowed in schema types");
  t = finish_struct (stype, fields, 1);
  CHK_EM (t);
  TREE_USED (t) = TREE_USED (type);
  allocate_type_lang_specific (t);
  TYPE_LANG_CODE (t) = PASCAL_LANG_UNDISCRIMINATED_SCHEMA;
  if (init)
    TYPE_LANG_INITIAL (t) = save_nonconstants (init);
  /* Copy the fix-up list from the VAR_DECL's DECL_LANG_FIXUPLIST
     to that of the FIELD_DECL. Mark the discriminants as such. */
  for (d = discriminants, tmp = TYPE_FIELDS (t);
       d && tmp; d = TREE_CHAIN (d), tmp = TREE_CHAIN (tmp))
    {
      allocate_decl_lang_specific (tmp);
      DECL_LANG_FIXUPLIST (tmp) = NULL_TREE /* DECL_LANG_FIXUPLIST (TREE_VALUE (d)) */;
      PASCAL_TREE_DISCRIMINANT (tmp) = 1;
    }
  return t;
}

int
number_of_schema_discriminants (tree type)
{
  if (PASCAL_TYPE_UNDISCRIMINATED_STRING (type)
      || PASCAL_TYPE_PREDISCRIMINATED_STRING (type))
    return 1;
  if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type)
      || PASCAL_TYPE_PREDISCRIMINATED_SCHEMA (type))
    {
      int count = 0;
      tree field;
      for (field = TYPE_FIELDS (type); field; field = TREE_CHAIN (field))
        if (PASCAL_TREE_DISCRIMINANT (field))
          count++;
      gcc_assert (count);
      return count;
    }
  return 0;
}

/* Pre-discriminate an undiscriminated schema which is of pointer or reference
   type, using its own contents. This makes the schema a valid type but
   preserves the fix-up information needed to derive discriminated schemata
   from this schema. (@@ Do we actually need the latter? -- Frank) */
void
prediscriminate_schema (tree decl)
{
  if ((TREE_CODE (TREE_TYPE (decl)) != POINTER_TYPE
       && TREE_CODE (TREE_TYPE (decl)) != REFERENCE_TYPE)
      || EM (TREE_TYPE (TREE_TYPE (decl))))
    return;

  if (PASCAL_TYPE_UNDISCRIMINATED_STRING (TREE_TYPE (TREE_TYPE (decl))))
    {
      tree new_type, string_type = TREE_TYPE (TREE_TYPE (decl));
/* #ifndef PG__NEW_STRINGS */
#if 1
      tree val = build_component_ref (build_indirect_ref (decl, NULL), get_identifier ("Capacity"));
      size_volatile++;
      new_type = build_pascal_string_schema (val);
      size_volatile--;
#else
      new_type = build_pascal_string_schema (NULL_TREE);
#endif
      if (EM (new_type))
        return;
      TYPE_LANG_CODE (new_type) = PASCAL_LANG_PREDISCRIMINATED_STRING;

      /* Preserve volatility and readonlyness. */
      if (TYPE_READONLY (string_type) || TYPE_VOLATILE (string_type))
        {
          new_type = build_type_copy (new_type);
          TYPE_READONLY (new_type) = TYPE_READONLY (string_type);
          TYPE_VOLATILE (new_type) = TYPE_VOLATILE (string_type);
        }

      /* Return the result, but don't spoil pointers/references
         to "the" generic `String' type. */
      TREE_TYPE (decl) = build_type_copy (TREE_TYPE (decl));
      TREE_TYPE (TREE_TYPE (decl)) = new_type;
    }
  else if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (TREE_TYPE (TREE_TYPE (decl))))
    {
      tree schema_type = TREE_TYPE (TREE_TYPE (decl)), new_type;
      tree field, discr = NULL_TREE, ref = build_indirect_ref (decl, NULL);
      for (field = TYPE_FIELDS (schema_type); field && PASCAL_TREE_DISCRIMINANT (field); field = TREE_CHAIN (field))
        discr = chainon (discr, build_tree_list (NULL_TREE, simple_component_ref (ref, field)));

      /* The size of this type may vary within one function body. */
      size_volatile++;
      new_type = build_discriminated_schema_type (schema_type, discr, 1);
      size_volatile--;
      TYPE_LANG_CODE (new_type) = PASCAL_LANG_PREDISCRIMINATED_SCHEMA;

      /* Make the fixup list of the prediscriminated schema invalid. */
      for (field = TYPE_FIELDS (new_type); field; field = TREE_CHAIN (field))
        if (PASCAL_TREE_DISCRIMINANT (field))
          DECL_LANG_FIXUPLIST (field) = NULL_TREE;

      /* Return the result, but don't spoil pointers/references
         to this (undiscriminated) schema type. */
      TREE_TYPE (decl) = build_type_copy (TREE_TYPE (decl));
      new_main_variant (TREE_TYPE (decl));
      TREE_TYPE (TREE_TYPE (decl)) = new_type;
    }
}

tree
build_type_of (tree d)
{
  int indirect = 0;
  tree t;
  chk_dialect_name ("type of", E_O_PASCAL);
  t = d = undo_schema_dereference (d);
  while (TREE_CODE (t) == NOP_EXPR
         || TREE_CODE (t) == NON_LVALUE_EXPR
         || TREE_CODE (t) == CONVERT_EXPR
         || (TREE_CODE (t) == INDIRECT_REF && ++indirect))
    t = TREE_OPERAND (t, 0);
  if (!lvalue_p (d))
    chk_dialect ("`type of' applied to a value is", GNU_PASCAL);
  else if (!((indirect == 0 && TREE_CODE (t) == VAR_DECL)
             || (indirect == 0 && TREE_CODE (t) == PARM_DECL)
             || (indirect == 1 && TREE_CODE (t) == PARM_DECL && TREE_CODE (TREE_TYPE (t)) == REFERENCE_TYPE)))
    chk_dialect ("`type of' applied to non variables/parameters is", GNU_PASCAL);
  t = TREE_TYPE (d);
  CHK_EM (t);
  if (TYPE_READONLY (t))
    t = p_build_type_variant (t, 0, TYPE_VOLATILE (t));
  gcc_assert (!PASCAL_TYPE_UNDISCRIMINATED_STRING (t) && !PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (t));
  if (PASCAL_TYPE_PREDISCRIMINATED_STRING (t))
#if 0
    t = build_pascal_string_schema (save_nonconstants (TYPE_LANG_DECLARED_CAPACITY (t)));
#else
    {
// = build_component_ref (build_indirect_ref (decl, NULL), get_identifier ("Capacity")); 
//      tree l = TYPE_LANG_DECLARED_CAPACITY (t);
      tree l = build_component_ref (d, get_identifier ("Capacity"));
#ifdef GCC_4_0
      l = SUBSTITUTE_PLACEHOLDER_IN_EXPR (l, d);
#else
      l = build (WITH_RECORD_EXPR, TREE_TYPE (l), l, d);
#endif
      t = build_pascal_string_schema (save_nonconstants (l));
    }
#endif
  else if (PASCAL_TYPE_PREDISCRIMINATED_SCHEMA (t))
    {
      tree field, discr = NULL_TREE;
      for (field = TYPE_FIELDS (t); field && PASCAL_TREE_DISCRIMINANT (field); field = TREE_CHAIN (field))
        discr = chainon (discr, build_tree_list (NULL_TREE, simple_component_ref (d, field)));
      t = build_discriminated_schema_type (TYPE_LANG_BASE (t), discr, 0);
    }
  return t;
}

/* Return the main variant of the base type of an ordinal subrange (also if
   nested, fjf729.pas), or of the type itself if it is not a subrange. */
tree
base_type (tree type)
{
  CHK_EM (type);
  while (ORDINAL_TYPE (TREE_CODE (type)) && TREE_TYPE (type))
    type = TREE_TYPE (type);
  return TYPE_MAIN_VARIANT (type);
}

/* index_type is NULL_TREE for a non-direct-access file. */
tree
build_file_type (tree component_type, tree index_type, int allow_void)
{
  if (!allow_void && TREE_CODE (component_type) == VOID_TYPE)
    error ("file element type must not be `Void'");
  else if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (component_type)
           || PASCAL_TYPE_UNDISCRIMINATED_STRING (component_type))
    error ("file element type must not be an undiscriminated schema");
  else if (contains_file_p (component_type))
    error ("file element type must not contain files");
  else
    {
      tree file_type = finish_struct (start_struct (RECORD_TYPE),
             build_field (get_identifier ("_p_File_"), ptr_type_node), 0);
      allocate_type_lang_specific (file_type);
      TYPE_LANG_CODE (file_type) = PASCAL_LANG_NON_TEXT_FILE;
      if (index_type && !EM (index_type))
        TYPE_LANG_FILE_DOMAIN (file_type) = index_type;
      TREE_TYPE (file_type) = component_type;
      return file_type;
    }
  return error_mark_node;
}

tree
build_field (tree name, tree type)
{
  tree decl;
  CHK_EM (type);
  if (!TYPE_SIZE (type) || TREE_CODE (type) == VOID_TYPE)
    {
      error ("field `%s' has incomplete type", IDENTIFIER_NAME (name));
      return error_mark_node;
    }
  if (PASCAL_TYPE_ANYFILE (type))
    error ("field type must not be `AnyFile'");
  decl = build_decl (FIELD_DECL, name, type);
  TREE_READONLY (decl) |= TYPE_READONLY (type);
  TREE_SIDE_EFFECTS (decl) |= TYPE_VOLATILE (type);
  TREE_THIS_VOLATILE (decl) |= TYPE_VOLATILE (type);
  return decl;
}

tree
build_fields (tree list, tree type, tree init)
{
  tree link, ret = NULL_TREE, last = NULL_TREE;
  type = add_type_initializer (type, init);
  for (link = list; link; link = TREE_CHAIN (link))
    {
      tree t = build_field (TREE_VALUE (link), type);
      if (EM (t))
        ;
      else if (!last)
        ret = last = t;
      else
        {
          TREE_CHAIN (last) = t;
          last = t;
        }
    }
  return ret;
}

tree
build_record (tree fixed_part, tree variant_selector, tree variant_list)
{
  tree record, init = NULL_TREE, variant_field = NULL_TREE, f, ti;
  tree selector_type = NULL_TREE, selector_field = NULL_TREE;
  int initializer_variant = 0;
  if (variant_selector)
    {
      enum tree_code code = UNION_TYPE;
      tree t, vf = NULL_TREE;
      int auto_init;
      selector_type = TREE_PURPOSE (variant_selector);
      selector_field = TREE_VALUE (variant_selector);
      if (!selector_field && TREE_CODE (selector_type) == IDENTIFIER_NODE)
        {
          tree decl = lookup_name (selector_type);
#if 0
          if (decl && TREE_CODE (decl) == VAR_DECL && PASCAL_TREE_DISCRIMINANT (decl))
            selector_field = maybe_schema_discriminant (decl);
#endif
          if (decl && TREE_CODE (decl) == CONST_DECL 
              && TREE_CODE (DECL_INITIAL (decl)) == COMPONENT_REF 
              && TREE_CODE (TREE_OPERAND (DECL_INITIAL (decl), 0))
                   == PLACEHOLDER_EXPR
              && TREE_TYPE (TREE_OPERAND (DECL_INITIAL (decl), 0)) 
                   == current_schema)
            selector_field = DECL_INITIAL (decl);
          else if (!(decl && TREE_CODE (decl) == TYPE_DECL))
            {
              error ("selector type name or discriminant identifier expected, `%s' given",
                     IDENTIFIER_NAME (selector_type));
              return error_mark_node;
            }
          selector_type = TREE_TYPE (decl);
        }
      CHK_EM (selector_type);

      /* @@@@@ We should use only one piece of code to verify
         case-constant-list, so the code below should be common
         to initializers, variant records and case instruction. */

      for (t = variant_list; t; t = TREE_CHAIN (t))
        {
          tree f = TREE_VALUE (t), c;
          CHK_EM (f);
          for (c = TREE_PURPOSE (t); c; c = TREE_CHAIN (c))
            {
              tree lo = TREE_VALUE (c), hi = TREE_PURPOSE (c), t2, c2;
              STRIP_NOPS (lo);
              lo = TREE_VALUE (c) = fold (lo);
              if (hi)
                {
                  STRIP_NOPS (hi);
                  hi = TREE_PURPOSE (c) = fold (hi);
                }
              if (!comptypes (TREE_TYPE (lo), selector_type) || (hi && !comptypes (TREE_TYPE (hi), selector_type)))
                error ("type mismatch in variant case constant");
              if (TREE_CODE (lo) != INTEGER_CST || (hi && TREE_CODE (hi) != INTEGER_CST))
                error ("variant case constant must be constant");
              else
                for (t2 = t; t2; t2 = TREE_CHAIN (t2))
                  for (c2 = t2 == t ? TREE_CHAIN (c) : TREE_PURPOSE (t2); c2; c2 = TREE_CHAIN (c2))
                    {
                      tree lo2 = TREE_VALUE (c2), hi2 = TREE_PURPOSE (c2);
                      if (!hi)
                        hi = lo;
                      if (!hi2)
                        hi2 = lo2;
                      if (TREE_CODE (lo2) == INTEGER_CST && TREE_CODE (hi2) == INTEGER_CST
                          && !const_lt (hi2, lo) && !const_lt (hi, lo2))
                        {
                          char buf[256];
                          sprintf (buf, "overlapping case range `%li .. %li' in variant record",
                            (long int) TREE_INT_CST_LOW (const_lt (lo, lo2) ? lo2 : lo),
                            (long int) TREE_INT_CST_LOW (const_lt (hi, hi2) ? hi : hi2));
                          error_or_warning (!(co->pascal_dialect & B_D_PASCAL), buf);
                        }
                    }
            }
          vf = chainon (vf, f);
          /* Don't overlap auto-initialized types. */
          auto_init = contains_auto_initialized_part (TREE_TYPE (f), 0);
          if (auto_init)
            code = RECORD_TYPE;
          if (auto_init || PASCAL_TYPE_INITIALIZER_VARIANTS (TREE_TYPE (f)) || TYPE_GET_INITIALIZER (TREE_TYPE (f)))
            initializer_variant = 1;
        }
      variant_field = build_field (NULL_TREE, finish_struct (start_struct (code), vf, 1));
      PASCAL_TYPE_RECORD_VARIANTS (TREE_TYPE (variant_field)) = 1;
      /* Chain the tag field (but not a discriminant used as the tag) */
      if (selector_field && TREE_CODE (selector_field) == FIELD_DECL)
        fixed_part = chainon (fixed_part, selector_field);
    }
  record = finish_struct (start_struct (RECORD_TYPE), chainon (fixed_part, variant_field), 1);
  CHK_EM (record);
  for (f = fixed_part; f; f = TREE_CHAIN (f))
    if ((ti = TYPE_GET_INITIALIZER (TREE_TYPE (f))))
      {
        tree t = DECL_NAME (f);
        gcc_assert (TREE_CODE (ti) == TREE_LIST && !TREE_PURPOSE (ti));
        if (f == selector_field)
          t = build_tree_list (NULL_TREE, t);  /* simulate `case ... of' */
        else
          t = build_tree_list (t, NULL_TREE);
        init = tree_cons (t, TREE_VALUE (ti), init);
      }
  init = nreverse (init);
  if (init || variant_selector)
    allocate_type_lang_specific (record);
  if (variant_selector)
    {
      TYPE_LANG_CODE (record) = PASCAL_LANG_VARIANT_RECORD;
      TYPE_LANG_VARIANT_TAG (record) = build_tree_list (
        build_tree_list (selector_type, selector_field),
        build_tree_list (variant_list, variant_field));
      if ((ti = TYPE_GET_INITIALIZER (selector_type)))
        {
          gcc_assert (TREE_CODE (ti) == TREE_LIST && !TREE_PURPOSE (ti));
          if (TREE_CODE (TREE_VALUE (ti)) == INTEGER_CST
              && (f = find_variant (TREE_VALUE (ti), variant_list))
              && (ti = TYPE_GET_INITIALIZER (TREE_TYPE (f))))
            {
              gcc_assert (TREE_CODE (ti) == TREE_LIST && !TREE_PURPOSE (ti));
              init = chainon (init, TREE_VALUE (ti));
            }
        }
      PASCAL_TYPE_INITIALIZER_VARIANTS (record) = initializer_variant;
    }
  if (init)
    TYPE_LANG_INITIAL (record) = build_tree_list (NULL_TREE, init);
  return record;
}

/* Mark type as packed, and re-layout it if necessary. Note: In
   `packed array [5 .. 10] of array of [1 .. 20] of Char' the inner array type
   must not be packed, but in `packed array [5 .. 10, 1 .. 20] of Char' it must.
   build_pascal_array_type sets PASCAL_TYPE_INTERMEDIATE_ARRAY for this purpose. */
tree
pack_type (tree type)
{
  CHK_EM (type);
  if (!TYPE_PACKED (type))
    type = pascal_type_variant (type, TYPE_QUALIFIER_PACKED);
  if (TREE_CODE (type) == ARRAY_TYPE)
    {
      int uns = 0, has_packed = 0;
      tree bits, new_size, align, domain = TYPE_DOMAIN (type);

      if (TREE_CODE (TREE_TYPE (type)) == ARRAY_TYPE && PASCAL_TYPE_INTERMEDIATE_ARRAY (TREE_TYPE (type)))
        {
          tree orig = TREE_TYPE (type);
          TREE_TYPE (type) = pack_type (orig);
          if (TREE_TYPE (type) != orig)
            has_packed = 1;
        }

      gcc_assert (TYPE_MIN_VALUE (domain) && TYPE_MAX_VALUE (domain));

      /* The backend does not know about Pascal's idea of
         packed arrays, so we calculate the size here. */
      if (ORDINAL_TYPE (TREE_CODE (TREE_TYPE (type))))
        bits = count_bits (TREE_TYPE (type), &uns);
      else
        bits = NULL_TREE;

      /* Nothing to pack. */
      if (!bits
          || (TREE_CODE (bits) == INTEGER_CST
              && tree_int_cst_equal (bits, TYPE_SIZE (TREE_TYPE (type)))
              && TREE_INT_CST_LOW (bits) % BITS_PER_UNIT == 0
              && (TREE_INT_CST_LOW (bits) == 0 || 256 % TREE_INT_CST_LOW (bits) == 0)))
        {
          if (has_packed)  /* inner array has just been packed */
            {
              TYPE_SIZE (type) = NULL_TREE;
#ifdef EGCS
              TYPE_SIZE_UNIT (type) = NULL_TREE;
#endif
              layout_type (type);
            }
          return type;
        }

#if 1      
      if (uns != TYPE_UNSIGNED (type))
        {
          TREE_TYPE (type) = build_type_copy (TREE_TYPE (type));
          TYPE_UNSIGNED (TREE_TYPE (type)) = uns;
        }
#else
      {
        tree el_type = build_type_copy (TREE_TYPE (type));
        TYPE_UNSIGNED (el_type) = uns;
        TYPE_PRECISION (el_type) = TREE_INT_CST_LOW (bits);
        TYPE_SIZE (el_type) = NULL_TREE;
#ifdef EGCS
        TYPE_SIZE_UNIT (el_type) = NULL_TREE;
#endif
        layout_type (type);
      }
#endif

      TYPE_ALIGN (type) = TYPE_PRECISION (packed_array_unsigned_short_type_node);
      align = bitsize_int (TYPE_ALIGN (type));
      new_size = size_binop (MULT_EXPR, size_binop (CEIL_DIV_EXPR,
        size_binop (MULT_EXPR, size_binop (PLUS_EXPR, convert (bitsizetype,
        size_binop (MINUS_EXPR, convert (sbitsizetype, TYPE_MAX_VALUE (domain)),
                                convert (sbitsizetype, TYPE_MIN_VALUE (domain)))),
        bitsize_one_node), convert (bitsizetype, bits)), align), align);
      TYPE_SIZE (type) = new_size;
#ifdef EGCS
      TYPE_SIZE_UNIT (type) = convert (sizetype,
        size_binop (CEIL_DIV_EXPR, new_size, bitsize_int (BITS_PER_UNIT)));
#endif
#ifdef GCC_4_0
      /* @@@@@@ Maybe */
      /* TYPE_NO_FORCE_BLK (type) = 1; */
      TYPE_MODE (type) = BLKmode;
#endif
    }
  else if (ORDINAL_TYPE (TREE_CODE (type)))
    {
      tree bits = count_bits (type, NULL);
      if (bits && TREE_INT_CST_LOW (bits) != TREE_INT_CST_LOW (TYPE_SIZE (type)))
        {
          TYPE_SIZE (type) = NULL_TREE;
#ifdef EGCS
          TYPE_SIZE_UNIT (type) = NULL_TREE;
#endif
          /* The backend doesn't appear to expect types whose precision is not a
             multiple of BITS_PER_UNIT (such as a type of 5 bits, martin4*.pas).
             E.g., force_fit_type() would turn a constant of -21 into +11 which
             would be right when really operating on 5 bit types. However, since
             the CPU operates on BITS_PER_UNIT (usually 8 bit) wide types,
             adding 11 is not equivalent to subtracting 21. So let's just round
             up the precision to a multiple of BITS_PER_UNIT. This should not
             actually make the type bigger. (Packed arrays where it would matter
             are handled differently above, anyway.) */
          TYPE_PRECISION (type) = ((TREE_INT_CST_LOW (bits) + BITS_PER_UNIT - 1)
                                   / BITS_PER_UNIT) * BITS_PER_UNIT;
          TYPE_ALIGN (type) = 0;
          layout_type (type);
        }
    }
  return type;
}

tree
add_type_initializer (tree type, tree init)
{
  if (init && !EM (type))
    {
      type = build_type_copy (type);
      copy_type_lang_specific (type);
      init = save_nonconstants (init);
      if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type) || !check_pascal_initializer (type, init))
        {
          allocate_type_lang_specific (type);
          TYPE_LANG_INITIAL (type) = init;
          if (TREE_CODE (type) == RECORD_TYPE)
            PASCAL_TYPE_INITIALIZER_VARIANTS (type) = 0;
        }
      else
        error ("initial value is of wrong type");
    }
  return type;
}

/* Return 1 if val is a field of a packed array or record, otherwise 0. */
int
is_packed_field (tree val)
{
  return TREE_CODE (val) == BIT_FIELD_REF
         || TREE_CODE (val) == PASCAL_BIT_FIELD_REF
         || (TREE_CODE (val) == COMPONENT_REF && DECL_PACKED_FIELD (TREE_OPERAND (val, 1)))
         || (TREE_CODE (val) == ARRAY_REF && TYPE_PACKED (TREE_TYPE (TREE_OPERAND (val, 0))))
         /* @@@@@ Wrong for packed sets */
         || (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (TREE_CODE (val))) && PASCAL_TREE_PACKED (val));
}

static int
count_unsigned_bits (tree t)
{
  int bits = 0;
  unsigned HOST_WIDE_INT c;
  if (TREE_CODE (t) != INTEGER_CST)
    {
      int dummy;
      tree tbits = count_bits(TREE_TYPE (t), &dummy);
      if (!tbits)
        return TYPE_PRECISION (TREE_TYPE (t)) 
                - !TYPE_UNSIGNED (TREE_TYPE (t));
      else
        return TREE_INT_CST_LOW (tbits);
    }
  if (tree_int_cst_sgn (t) >= 0)
    {
      c = TREE_INT_CST_HIGH (t);
      if (c)
        bits = HOST_BITS_PER_WIDE_INT;
      else
        c = TREE_INT_CST_LOW (t);
    }
  else
    {
      HOST_WIDE_INT cs = TREE_INT_CST_HIGH (t);
      gcc_assert (cs < 0);
      c = ~cs;
      if (c)
        bits = HOST_BITS_PER_WIDE_INT;
      else
        c = ~TREE_INT_CST_LOW (t);
    }
  for (; c; c >>= 1)
    bits++;
  return bits;
}

/* Count how many bits a variable (e.g. a record field) of type TYPE needs.
   Return the result as an INTEGER_CST node, or NULL_TREE if packing of
   this type is not possible. Store in *punsigned (if not NULL) whether the
   type should be unsigned. */
tree
count_bits (tree type, int *punsigned)
{
  int positive, lo_bits, hi_bits, bits;
  tree lo, hi, result;
  if (!ORDINAL_TYPE (TREE_CODE (type))
      || !(lo = TYPE_MIN_VALUE (type)) || TREE_CODE (lo) != INTEGER_CST
      || !(hi = TYPE_MAX_VALUE (type)) || TREE_CODE (hi) != INTEGER_CST)
    return NULL_TREE;
  positive = tree_int_cst_sgn (lo) >= 0 && tree_int_cst_sgn (hi) >= 0;
  lo_bits = count_unsigned_bits (lo);
  hi_bits = count_unsigned_bits (hi);
  bits = MAX (1, MAX (lo_bits, hi_bits) + !positive);
  gcc_assert (bits <= TYPE_PRECISION (type));
  result = build_int_2 (bits, 0);
  if (punsigned)
    *punsigned = positive;
  return result;
}

/* Return the number of elements of the array type TYPE.
   (Note: array_type_nelts returns the number of elements minus one.) */
tree
pascal_array_type_nelts (tree type)
{
  tree index_type = TYPE_DOMAIN (type);
  CHK_EM (index_type);
  return size_binop (PLUS_EXPR, convert (bitsizetype, size_binop (MINUS_EXPR,
    convert (sbitsizetype, TYPE_MAX_VALUE (index_type)),
    convert (sbitsizetype, TYPE_MIN_VALUE (index_type)))), bitsize_one_node);
}

tree
size_of_type (tree type)
{
  if (TREE_CODE (type) == ARRAY_TYPE)
    return build_pascal_binary_op (MULT_EXPR, pascal_array_type_nelts (type), size_of_type (TREE_TYPE (type)));
  else if (TREE_CODE (type) == VOID_TYPE)
    return size_one_node;
  else
    return size_in_bytes (type);
}

/* Compare two integer constants which may both be either signed or unsigned.
   If either of the arguments is no INTEGER_CST node, return 0. */
int
const_lt (tree val1, tree val2)
{
  if (TREE_CODE (val1) != INTEGER_CST || TREE_CODE (val2) != INTEGER_CST)
    return 0;
  else
    {
      int large1 = TYPE_UNSIGNED (TREE_TYPE (val1))
                   && INT_CST_LT_UNSIGNED (TYPE_MAX_VALUE (long_long_integer_type_node), val1);
      int large2 = TYPE_UNSIGNED (TREE_TYPE (val2))
                   && INT_CST_LT_UNSIGNED (TYPE_MAX_VALUE (long_long_integer_type_node), val2);
      if (large1)
        return large2 && INT_CST_LT_UNSIGNED (val1, val2);
      else
        return large2 || INT_CST_LT (val1, val2);
    }
}

/* Return the smallest standard signed integer type that can hold
   the negative of the unsigned integer type TYPE. */
tree
select_signed_integer_type (tree type)
{
  int precision = TYPE_PRECISION (type);
  if (precision < TYPE_PRECISION (pascal_integer_type_node))
    return pascal_integer_type_node;
  else if (precision < TYPE_PRECISION (long_integer_type_node))
    return long_integer_type_node;
  else
    return long_long_integer_type_node;
}

/* Return a reasonable common type for the ordinal values VAL1 and VAL2.
   WHY is the operation intended for these values and might be NOP_EXPR. */
tree
select_integer_type (tree val1, tree val2, enum tree_code why)
{
  tree min_val, max_val;
  gcc_assert (TYPE_IS_INTEGER_TYPE (TREE_TYPE (val1)) &&
              TYPE_IS_INTEGER_TYPE (TREE_TYPE (val2)));

  if (TREE_CODE (val1) != INTEGER_CST || TREE_CODE (val2) != INTEGER_CST)
    {
      if (why == MINUS_EXPR || why == PLUS_EXPR)
        {
          int uns1 = TYPE_UNSIGNED (TREE_TYPE (val1))
              || (TREE_CODE (val1) == INTEGER_CST && tree_int_cst_sgn (val1) >= 0);
          int uns2 = TYPE_UNSIGNED (TREE_TYPE (val2))
              || (TREE_CODE (val2) == INTEGER_CST && tree_int_cst_sgn (val2) >= 0);
          int uns = uns1 && uns2;
          int prec1 = count_unsigned_bits (val1), prec2 = count_unsigned_bits (val2);
          int prec_unsigned = MAX (prec1, prec2);
          /* The difference of two unsigned values should be done unsigned
             (otherwise there's no way to compute in the top range), but if
             possible use a bigger type (so, e.g. `Cardinal - Cardinal' with
             small values doesn't easily lead to negative overflow. */
          if (uns && why == MINUS_EXPR && prec_unsigned < TYPE_PRECISION (long_long_integer_type_node))
            {
              prec_unsigned++;
              uns = 0;
            }
          if (prec_unsigned < TYPE_PRECISION (pascal_integer_type_node))
            return pascal_integer_type_node;
          else if (uns && prec_unsigned <= TYPE_PRECISION (pascal_cardinal_type_node))
            return pascal_cardinal_type_node;
          else if (prec_unsigned < TYPE_PRECISION (long_integer_type_node))
            return long_integer_type_node;
          else if (uns && prec_unsigned <= TYPE_PRECISION (long_unsigned_type_node))
            return long_unsigned_type_node;
          else if (!uns || prec_unsigned < TYPE_PRECISION (long_long_integer_type_node))
            return long_long_integer_type_node;
          else
            return long_long_unsigned_type_node;
        }
      if (TREE_CODE (val2) == INTEGER_CST)
        {
          tree tmp = val1;
          val1 = val2;
          val2 = tmp;
        }

      if (why != NOP_EXPR && MAX (TYPE_PRECISION (TREE_TYPE (val1)), TYPE_PRECISION (TREE_TYPE (val2))) < TYPE_PRECISION (pascal_integer_type_node))
        return pascal_integer_type_node;
      if (TREE_CODE (val1) == INTEGER_CST
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE (val2))
          && TYPE_MIN_VALUE (TREE_TYPE (val2))
          && TYPE_MAX_VALUE (TREE_TYPE (val2))
          && TREE_CODE (TYPE_MIN_VALUE (TREE_TYPE (val2))) == INTEGER_CST
          && TREE_CODE (TYPE_MAX_VALUE (TREE_TYPE (val2))) == INTEGER_CST
          && !const_lt (val1, TYPE_MIN_VALUE (TREE_TYPE (val2)))
          && !const_lt (TYPE_MAX_VALUE (TREE_TYPE (val2)), val1))
        return (why != NOP_EXPR && TYPE_PRECISION (TREE_TYPE (val2)) < TYPE_PRECISION (pascal_integer_type_node))
               ? pascal_integer_type_node : TYPE_MAIN_VARIANT (TREE_TYPE (val2));
      return common_type (TREE_TYPE (val1), TREE_TYPE (val2));
    }

  /* Everything constant. Make it as small as possible, but big
     enough to hold the result of the intended operation (if known)
     and not smaller than the largest explicit type. */
  if (const_lt (val1, val2))
    {
      min_val = val1;
      max_val = val2;
    }
  else
    {
      min_val = val2;
      max_val = val1;
    }
  if (!(TREE_CODE_CLASS (TREE_CODE (val1)) == tcc_constant
         && PASCAL_CST_FRESH (val1)))
    {
      if (const_lt (TYPE_MIN_VALUE (TREE_TYPE (val1)), min_val))
        min_val = TYPE_MIN_VALUE (TREE_TYPE (val1));
      if (const_lt (max_val, TYPE_MAX_VALUE (TREE_TYPE (val1))))
        max_val = TYPE_MAX_VALUE (TREE_TYPE (val1));
    }
  if (!(TREE_CODE_CLASS (TREE_CODE (val2)) == tcc_constant
         && PASCAL_CST_FRESH (val2)))
    {
      if (const_lt (TYPE_MIN_VALUE (TREE_TYPE (val2)), min_val))
        min_val = TYPE_MIN_VALUE (TREE_TYPE (val2));
      if (const_lt (max_val, TYPE_MAX_VALUE (TREE_TYPE (val2))))
        max_val = TYPE_MAX_VALUE (TREE_TYPE (val2));
    }
  switch (why)
  {
    case PLUS_EXPR:
    case MINUS_EXPR:
    case MULT_EXPR:
    case CEIL_DIV_EXPR:
    case ROUND_DIV_EXPR:
    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:
    case LSHIFT_EXPR:
    case RSHIFT_EXPR:
    case LROTATE_EXPR:
    case RROTATE_EXPR:
      {
        int sign = why == MINUS_EXPR ? const_lt (val1, val2)
          : (tree_int_cst_sgn (val1) < 0 || tree_int_cst_sgn (val2) < 0);
        tree type =  sign ? long_long_integer_type_node : long_long_unsigned_type_node;
        tree result = fold (build_binary_op (why, convert (type, val1), convert (type, val2)));
        if (const_lt (result, min_val))
          min_val = result;
        if (const_lt (max_val, result))
          max_val = result;
        break;
      }
    default:
      break;
  }

  if (const_lt (min_val, integer_zero_node))
    {
      if (const_lt (TYPE_MAX_VALUE (long_integer_type_node), max_val)
          || const_lt (min_val, TYPE_MIN_VALUE (long_integer_type_node)))
        return long_long_integer_type_node;
      else if (const_lt (TYPE_MAX_VALUE (pascal_integer_type_node), max_val)
               || const_lt (min_val, TYPE_MIN_VALUE (pascal_integer_type_node)))
        return long_integer_type_node;
      else
        return pascal_integer_type_node;
    }
  else
    {
      /* If `Integer' is sufficient to hold this value, use that. */
      if (const_lt (TYPE_MAX_VALUE (long_unsigned_type_node), max_val))
        return long_long_unsigned_type_node;
      else if (const_lt (TYPE_MAX_VALUE (pascal_cardinal_type_node), max_val))
        return long_unsigned_type_node;
      else if (const_lt (TYPE_MAX_VALUE (pascal_integer_type_node), max_val))
        return pascal_cardinal_type_node;
      else
        return pascal_integer_type_node;
    }
}

int
check_subrange (tree lo, tree hi)
{
  if (const_lt (hi, lo))
    {
      error ("invalid subrange type");
      return 0;
    }
  if (const_lt (lo, integer_zero_node) && const_lt (TYPE_MAX_VALUE (long_long_integer_type_node), hi))
    {
      error ("range too big");
      return 0;
    }
  if (co->range_checking)
    {
      tree l = TREE_CODE (lo) == INTEGER_CST ? lo : TYPE_MAX_VALUE (TREE_TYPE (lo));
      tree h = TREE_CODE (hi) == INTEGER_CST ? hi : TYPE_MIN_VALUE (TREE_TYPE (hi));
      if (TREE_CODE (l) != INTEGER_CST || TREE_CODE (h) != INTEGER_CST || const_lt (h, l))
        {
          tree pz = convert (pascal_integer_type_node, integer_zero_node);
          if (co->warn_dynamic_arrays)
            gpc_warning ("dynamic array");
          if (current_function_decl)  /* @@ otherwise do it in module constructor */
            expand_expr_stmt (build3 (COND_EXPR, pascal_integer_type_node,
              build_implicit_pascal_binary_op (LT_EXPR, hi, lo),
              build2 (COMPOUND_EXPR, pascal_integer_type_node,
                build_predef_call (p_SubrangeError, NULL_TREE), pz),
                pz));
        }
    }
  return 1;
}

static void
check_nonconstants (tree expr)
{
  tree t;
  enum tree_code code = TREE_CODE (expr);
  if (code == VAR_DECL && !PASCAL_INITIALIZED (expr) && !PASCAL_VALUE_ASSIGNED (expr)
      && !PASCAL_TREE_DISCRIMINANT (expr) && DECL_CONTEXT (expr) == current_function_decl)
    gpc_warning ("`%s' might be used uninitialized in type definition", IDENTIFIER_NAME (DECL_NAME (expr)));
  else if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (expr, i))
          check_nonconstants (TREE_OPERAND (expr, i));
    }
  else if (code == TREE_LIST)
    for (t = expr; t; t = TREE_CHAIN (t))
      {
        if (TREE_VALUE (t))
          check_nonconstants (TREE_VALUE (t));
        if (TREE_PURPOSE (t))
          check_nonconstants (TREE_PURPOSE (t));
      }
}

/* Find all nonconstant parts, except discriminants, in expr. For each one,
   create a temp variable, assign the nonconstant part to it and substitute
   that variable into a copy of the expression which is returned. */
tree
save_nonconstants (tree expr)
{
  enum tree_code code = TREE_CODE (expr);
  CHK_EM (expr);

  /* We are eliminating all non-constants, so we don't need SAVE_EXPR anymore. */
  if (code == SAVE_EXPR /* || code == NON_EFFECT_EXPR */)
    return save_nonconstants (TREE_OPERAND (expr, 0));

  /* Constant expressions are ok. Discriminants are substituted elsewhere. */
  if (TREE_CONSTANT (expr)
#if 0
      || ((code == VAR_DECL || code == FIELD_DECL || code == CONVERT_EXPR) && PASCAL_TREE_DISCRIMINANT (expr)))
#else
      || (code == COMPONENT_REF 
          && TREE_CODE (TREE_OPERAND (expr, 0)) == PLACEHOLDER_EXPR))
#endif
    return expr;

  if (code == COMPOUND_EXPR)
    {
      expand_expr_stmt1 (TREE_OPERAND (expr, 0));
      return save_nonconstants (TREE_OPERAND (expr, 1));
    }

  if (code != TREE_LIST && code != IDENTIFIER_NODE && !contains_discriminant (expr, NULL_TREE))
    {
      tree temp_var;
      check_nonconstants (expr);
      if (TREE_READONLY (expr))
        return expr;
      temp_var = make_new_variable ("nonconstant_expr", TREE_TYPE (expr));
      mark_lvalue (temp_var, "internal initialization", 1);
      if (current_function_decl)
        expand_expr_stmt (build_modify_expr (temp_var, NOP_EXPR, expr));
      else
        deferred_initializers = tree_cons (expr, temp_var, deferred_initializers);
      PASCAL_HAD_SIDE_EFFECTS (temp_var) = TREE_SIDE_EFFECTS (expr);
      return temp_var;
    }

  if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      expr = copy_node (expr);
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (expr, i))
          TREE_OPERAND (expr, i) = save_nonconstants (TREE_OPERAND (expr, i));
    }
  else if (code == TREE_LIST)
    {
      tree t;
      expr = copy_list (expr);
      for (t = expr; t; t = TREE_CHAIN (t))
        {
          if (TREE_VALUE (t))
            TREE_VALUE (t) = save_nonconstants (TREE_VALUE (t));
          if (TREE_PURPOSE (t))
            TREE_PURPOSE (t) = save_nonconstants (TREE_PURPOSE (t));
        }
    }
  return expr;
}

/* Build a subrange type. Like build_range_type, but derive the type from the values. */
tree
build_pascal_range_type (tree lowval, tree highval)
{
  tree type, range_type;
  int discr_lo = contains_discriminant (lowval, NULL_TREE);
  int discr_hi = contains_discriminant (highval, NULL_TREE);
  CHK_EM (lowval);
  CHK_EM (highval);
  if (!discr_lo)
    {
      STRIP_TYPE_NOPS (lowval);
      lowval = fold (lowval);
    }
  if (!discr_hi)
    {
      STRIP_TYPE_NOPS (highval);
      highval = fold (highval);
    }
  lowval  = save_nonconstants (lowval);
  highval = save_nonconstants (highval);
  if (!discr_lo && !discr_hi && !check_subrange (lowval, highval))
    return error_mark_node;

  if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (lowval)))
    type = select_integer_type (lowval, highval, NOP_EXPR);
  else
    type = base_type (TREE_TYPE (lowval));
  range_type = build_range_type (type, lowval, highval);

  /* Preserve character types */
  PASCAL_CHAR_TYPE (range_type) = PASCAL_CHAR_TYPE (type);

  /* Restore discriminants in case build_range_type() folded them away. */
  if (discr_lo)
    TYPE_MIN_VALUE (range_type) = build1 (CONVERT_EXPR, type, lowval);
  if (discr_hi)
    TYPE_MAX_VALUE (range_type) = build1 (CONVERT_EXPR, type, highval);

  TREE_SET_CODE (range_type, TREE_CODE (type));
  if (TREE_CODE (lowval) == INTEGER_CST)
    TYPE_UNSIGNED (range_type) = !const_lt (lowval, integer_zero_node);
  else
    TYPE_UNSIGNED (range_type) = TYPE_UNSIGNED (TREE_TYPE (lowval));
  if (discr_hi && !TYPE_UNSIGNED (TREE_TYPE (highval)))
    TYPE_UNSIGNED (range_type) = 0;
  return range_type;
}

/* Like build_pascal_range_type, but do some more checking and conversions. */
tree
build_pascal_subrange_type (tree lowval, tree highval, int pack)
{
  tree lower = maybe_schema_discriminant (string_may_be_char (lowval, 0));
  tree higher = maybe_schema_discriminant (string_may_be_char (highval, 0));
  tree type_lower = base_type (TREE_TYPE (lower));
  tree type_higher = base_type (TREE_TYPE (higher));
  tree res = error_mark_node;
  if (!ORDINAL_TYPE (TREE_CODE (type_lower)) || !ORDINAL_TYPE (TREE_CODE (type_higher)))
    error ("subrange bounds must be of ordinal type");
  else if (type_lower != type_higher &&
           !(TYPE_IS_INTEGER_TYPE (type_lower) &&
             TYPE_IS_INTEGER_TYPE (type_higher)))
    error ("subrange bounds are not of the same type");
  else
    {
      if (!TREE_CONSTANT (lower) || !TREE_CONSTANT (higher))
        chk_dialect ("non-constant subrange bounds are", E_O_PASCAL);
      res = build_pascal_range_type (lower, higher);
      if (pack)
        res = pack_type (res);
    }
  return res;
}

/* Look up component in a record etc. Return NULL_TREE if not found, otherwise
   a TREE_LIST, with each TREE_VALUE a FIELD_DECL stepping down the chain to
   the component, which is in the last TREE_VALUE of the list. The list is of
   length 1 unless the component is embedded within inner levels (variant parts
   or schema body). Since in Pascal all fields are in the same scope, there can
   be no duplicate names and we can search the levels in any order we like.
   mode 0: normal, 1: implicit (don't check private etc.), 2: just return the
   innermost field instead of the list */
tree
find_field (tree type, tree component, int mode)
{
  enum tree_code form = TREE_CODE (type);
  tree field = NULL_TREE;
  const char *kind = "field", *p;
  if (RECORD_OR_UNION (form))
    {
      /* TYPE_LANG_SORTED_FIELDS can contain the sorted field elements.
         Use a binary search on this array to quickly find the element.
         This doesn't handle inner levels, they're searched afterwards. */
      tree *sorted_fields = TYPE_LANG_SPECIFIC (type) ? TYPE_LANG_SORTED_FIELDS (type) : NULL;
      if (sorted_fields)
        {
          int bottom = 0, top = TYPE_LANG_FIELD_COUNT (type), i;
          while (top - bottom > 1)
            {
              int middle = (top + bottom) / 2;
              if (DECL_NAME (sorted_fields[middle]) == component)
                {
                  bottom = middle;
                  break;
                }
              if (DECL_NAME (sorted_fields[middle]) < component)
                bottom = middle;
              else
                top = middle;
            }
          if (DECL_NAME (sorted_fields[bottom]) == component)
            field = sorted_fields[bottom];
          else
            for (i = 0; i < TYPE_LANG_FIELD_COUNT (type); i++)
              {
                tree field2 = sorted_fields[i], ret;
                if (DECL_NAME (field2) == component)
                  {
                    field = field2;
                    break;
                  }
                else if (DECL_NAME (field2) && DECL_NAME (field2) != schema_id)
                  break;  /* we already checked the rest */
                if ((ret = find_field (TREE_TYPE (field2), component, mode)))
                  return mode == 2 ? ret : tree_cons (NULL_TREE, field2, ret);
              }
        }
      else
        {
          for (field = TYPE_FIELDS (type); field; field = TREE_CHAIN (field))
            if (DECL_NAME (field) == component
                && !(PASCAL_FIELD_SHADOWED (field)))
              break;
            else if (!DECL_NAME (field) || DECL_NAME (field) == schema_id)
              {
                tree ret = find_field (TREE_TYPE (field), component, mode);
                if (ret)
                  return mode == 2 ? ret : tree_cons (NULL_TREE, field, ret);
              }
        }
      if (!field)
        {
          tree fl = TYPE_METHODS (type);
          for (kind = "method"; fl; fl = TREE_CHAIN (fl))
            if (DECL_NAME (fl) == component
                && !(PASCAL_FIELD_SHADOWED (fl)))
              field = fl;
        }
    }
  if (!field || mode == 2)
    return field;
  if (mode == 0 && (p = check_private_protected (field)))
    error ("access to %s %s `%s'", p, kind, IDENTIFIER_NAME (component));
  return build_tree_list (NULL_TREE, field);
}

tree
build_component_ref_no_schema_dereference (tree datum, tree component, int implicit)
{
  tree type = TREE_TYPE (datum), field = NULL_TREE, ref;
  CHK_EM (datum);

  if (TREE_CODE (datum) == TYPE_DECL)
    {
      if (TREE_CODE (TREE_TYPE (datum)) == POINTER_TYPE
           && PASCAL_TYPE_CLASS (TREE_TYPE (datum)))
        type = TREE_TYPE (type);
      if (PASCAL_TYPE_OBJECT (type))
        {
          field = simple_get_field (component, type, "");
          if (!field || TREE_CODE (field) != FUNCTION_DECL)
            {
              error ("object has no method named `%s'", IDENTIFIER_NAME (component));
              return error_mark_node;
            }
          if (PASCAL_ABSTRACT_METHOD (field))
            error ("trying to access abstract method `%s'", IDENTIFIER_NAME (component));
        }
      else
        {
          error ("trying to access fields of a type definition");
          return error_mark_node;
        }
    }
  else if ((TREE_CODE (datum) == FUNCTION_DECL && RECORD_OR_UNION (TREE_CODE (TREE_TYPE (type))))
           || (TREE_CODE (type) == REFERENCE_TYPE && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE
               && RECORD_OR_UNION (TREE_CODE (TREE_TYPE (TREE_TYPE (type)))))
           || CALL_METHOD (datum))
    {
      datum = undo_schema_dereference (probably_call_function (datum));
      type = TREE_TYPE (datum);
    }

  if (TREE_CODE (type) == POINTER_TYPE && PASCAL_TYPE_CLASS (type))
    {
      datum = build_indirect_ref (datum, NULL);
      type = TREE_TYPE (datum);
    }

  gcc_assert (TREE_CODE (datum) != COND_EXPR);
  if (TREE_CODE (datum) == COMPOUND_EXPR)
    {
      tree value = build_component_ref (TREE_OPERAND (datum, 1), component);
      return build2 (COMPOUND_EXPR, TREE_TYPE (value),
                     TREE_OPERAND (datum, 0), value);
    }

  /* See if there is a field or component with name COMPONENT. */

  if (RECORD_OR_UNION (TREE_CODE (type)))
    {
      if (!TYPE_SIZE (type) && !PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
        {
          incomplete_type_error (NULL_TREE, type);
          return error_mark_node;
        }

      /* For Pascal: implicitly propagate to the inner layers
         of records and unions whose DECL_NAME is NULL_TREE.
         find_field() also constructs a TREE_LIST of fields and returns that. */
      field = find_field (type /* TREE_TYPE (datum) */, component, implicit);

      if (!field)
        {
          error ("record, schema or object has no field named `%s'", IDENTIFIER_NAME (component));
          return error_mark_node;
        }

      /* Generate COMPONENT_REFs to access the field */
      ref = datum;
      for (; field; field = TREE_CHAIN (field))
        {
          tree ref1, ftype = TREE_TYPE (TREE_VALUE (field));
          CHK_EM (ftype);
#ifndef GCC_4_0
          ref1 = build (COMPONENT_REF, ftype, ref, TREE_VALUE (field));
#else
          ref1 = build3 (COMPONENT_REF, ftype, ref, TREE_VALUE (field),
                          NULL_TREE);
#endif
          if (TREE_READONLY (ref) || TREE_READONLY (TREE_VALUE (field)))
            TREE_READONLY (ref1) = 1;
          if (TREE_THIS_VOLATILE (ref) || TREE_THIS_VOLATILE (TREE_VALUE (field)))
            TREE_THIS_VOLATILE (ref1) = 1;
#if 0
          if (DECL_BIT_FIELD (TREE_VALUE (field))
              && TREE_INT_CST_LOW (DECL_SIZE (field)) 
                 < TYPE_PRECISION (integer_type_node))
             ref1 = convert (integer_type_node, ref1);
#endif
          ref = fold (ref1);
        }
      return ref;
    }
  else if (!EM (type))
    {
      if (TREE_CODE (datum) == COMPONENT_REF
          && PASCAL_TYPE_SCHEMA (TREE_TYPE (TREE_OPERAND (datum, 0)))
          && DECL_NAME (TREE_OPERAND (datum, 1)) == schema_id)
        {
          if (TREE_CODE (TREE_TYPE (TREE_OPERAND (datum, 1))) == RECORD_TYPE)
            error ("record schema has no field or discriminant named `%s'", IDENTIFIER_NAME (component));
          else
            error ("schema has no discriminant named `%s'", IDENTIFIER_NAME (component));
        }
      else
        {
          error ("request for field `%s' in something not", IDENTIFIER_NAME (component));
          error (" a record, schema or object");
        }
    }
  return error_mark_node;
}

/* Return an expression to refer to the field named component (IDENTIFIER_NODE)
   of record value datum. */
tree
build_component_ref (tree datum, tree component)
{
  tree result;
  if (!EM (TREE_TYPE (datum)) && PASCAL_TYPE_RESTRICTED (TREE_TYPE (datum)))
    error ("accessing fields of a restricted record is not allowed");
  result = build_component_ref_no_schema_dereference (datum, component, 0);
  prediscriminate_schema (result);
  return result;
}

tree
simple_component_ref (tree expr, tree field)
{
#ifndef GCC_4_0
  tree ref = build (COMPONENT_REF, TREE_TYPE (field), expr, field);
#else
  tree ref = build3 (COMPONENT_REF, TREE_TYPE (field), expr, field, NULL_TREE);
#endif
  if (TREE_CODE (expr) == CONSTRUCTOR)
    ref = save_expr (ref);
  if (TREE_READONLY (expr) || TREE_READONLY (field))
    TREE_READONLY (ref) = 1;
  if (TREE_THIS_VOLATILE (expr) || TREE_THIS_VOLATILE (field))
    TREE_THIS_VOLATILE (ref) = 1;
  return fold (ref);
}

/* The two ways of specifying and accessing arrays, abbreviated (several index
   types in a row) and full (each index type separately), are equivalent.
   We represent arrays internally in their full form and mark intermediate
   arrays for pack_type. type is the element type, index_list is a list of
   index types in order of declaration. Returns the complete array type. */
tree
build_pascal_array_type (tree type, tree index_list)
{
  tree link, init;
  CHK_EM (type);
  if (TREE_CODE (type) == VOID_TYPE)
    {
      error ("array element type must not be `Void'");
      return error_mark_node;
    }
  if (PASCAL_TYPE_ANYFILE (type))
    error ("array element type must not be `AnyFile'");
  if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type)
      || PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
    {
      error ("array element type must not be an undiscriminated schema");
      return error_mark_node;
    }
  init = TYPE_GET_INITIALIZER (type);
  if (init)
    {
      gcc_assert (TREE_CODE (init) == TREE_LIST && !TREE_PURPOSE (init));
      init = TREE_VALUE (init);
    }
  for (link = nreverse (index_list); link; link = TREE_CHAIN (link))
    {
      tree index_type = TREE_VALUE (link);
      CHK_EM (index_type);
      if (!ORDINAL_TYPE (TREE_CODE (index_type)))
        {
          error ("array index type must be ordinal");
          return error_mark_node;
        }
      gcc_assert (!const_lt (TYPE_MAX_VALUE (index_type), TYPE_MIN_VALUE (index_type)));
      type = build_simple_array_type (type, index_type);
      if (!EM (type) && TREE_CHAIN (link))
        PASCAL_TYPE_INTERMEDIATE_ARRAY (type) = 1;
      if (init)
        init = build_tree_list (build_tree_list (NULL_TREE, NULL_TREE), init);
    }
  if (init)
    {
      allocate_type_lang_specific (type);
      TYPE_LANG_INITIAL (type) = build_tree_list (NULL_TREE, init);
    }
  return type;
}

/* Build a reference to an array slice. EP requires a string-type, but GPC
   allows slice accesses to all arrays. */
tree
build_array_slice_ref (tree expr, tree lower, tree upper)
{
  tree sub_domain, sub_type, res, lo, hi, lo_int, t, integer_index_type;
  tree component_type = char_type_node, min = NULL_TREE, max = NULL_TREE, max2 = NULL_TREE;
  int is_cstring = TYPE_MAIN_VARIANT (TREE_TYPE (expr)) == cstring_type_node;
  int is_string = is_string_type (expr, 1);
  int lvalue = lvalue_p (expr);
  if (is_string)
    chk_dialect ("substring access is", E_O_PASCAL);
  else
    chk_dialect ("array slice access to non-strings is", GNU_PASCAL);
  STRIP_TYPE_NOPS (lower);
  lower = fold (lower);
  STRIP_TYPE_NOPS (upper);
  upper = fold (upper);
  if (is_cstring)
    {
      min = integer_zero_node;
      max = pascal_maxint_node;
    }
  else if (!is_string)
    {
      if (TREE_CODE (TREE_TYPE (expr)) != ARRAY_TYPE)
        {
          error ("array slice access requires an array");
          return error_mark_node;
        }
      component_type = TREE_TYPE (TREE_TYPE (expr));
    }
  else if (TREE_CODE (TREE_TYPE (expr)) != ARRAY_TYPE)
    {
      min = integer_one_node;
      max = PASCAL_STRING_LENGTH (expr);
      if (PASCAL_TYPE_STRING (TREE_TYPE (expr)))
        max2 = TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (expr));
    }
  if (!min)
    min = TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (expr)));
  if (!max)
    max = TYPE_MAX_VALUE (TYPE_DOMAIN (TREE_TYPE (expr)));

  lo = save_expr (lower);
  hi = save_expr (upper);
  CHK_EM (lo);
  CHK_EM (hi);
  t = TYPE_MAIN_VARIANT (TREE_TYPE (min));
  if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (lo)), t) || !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (hi)), t))
    {
      error ("type mismatch in array slice index");
      return error_mark_node;
    }
  if (!check_subrange (lo, hi))
    return error_mark_node;

  lo = range_check_2 (min, max, lo);
  if (max2)
    hi = range_check_2 (hi, max2, hi);
  hi = range_check_2 (min, max, hi);
  CHK_EM (lo);
  CHK_EM (hi);

  if (TREE_CODE (expr) == STRING_CST && TREE_CODE (lower) == INTEGER_CST && TREE_CODE (upper) == INTEGER_CST)
    return build_string_constant (TREE_STRING_POINTER (expr) + TREE_INT_CST_LOW (lower) - 1,
      TREE_INT_CST_LOW (upper) - TREE_INT_CST_LOW (lower) + 1, 0);

  integer_index_type = type_for_size (MAX (TYPE_PRECISION (pascal_integer_type_node),
    MAX (TYPE_PRECISION (TREE_TYPE (lower)), TYPE_PRECISION (TREE_TYPE (upper)))),
    TYPE_UNSIGNED (TREE_TYPE (lower)) && TYPE_UNSIGNED (TREE_TYPE (upper)));
  lo_int = convert (integer_index_type, lo);

  /* Build an array type that has the same length as the sub-array access.
     In EP mode, the new array always starts from index 1. */
  if (co->pascal_dialect & E_O_PASCAL)
    sub_domain = build_range_type (integer_index_type, integer_one_node,
      build_pascal_binary_op (PLUS_EXPR, integer_one_node,
      build_pascal_binary_op (MINUS_EXPR, convert (integer_index_type, hi), lo_int)));
  else
    sub_domain = build_pascal_range_type (lo, hi);
  sub_type = build_pascal_array_type (component_type, build_tree_list (NULL_TREE, sub_domain));

  /* If the array is packed or a string, so is the subarray. */
  if (is_string || PASCAL_TYPE_PACKED (TREE_TYPE (expr)))
    sub_type = pack_type (sub_type);

  /* Build an access to the slice. */
  if (is_cstring)
    res = build_pascal_binary_op (PLUS_EXPR, expr, lo_int);
  else
    {
      tree actual_array = PASCAL_STRING_VALUE (expr);
      res = build_pascal_binary_op (MINUS_EXPR, build_pascal_binary_op (PLUS_EXPR,
              build1 (ADDR_EXPR, build_pointer_type (TREE_TYPE (TREE_TYPE (actual_array))), actual_array),
              lo_int), convert (integer_index_type, TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (actual_array)))));
    }
  res = build1 (INDIRECT_REF, sub_type, convert (build_pointer_type (sub_type), res));
  if (!lvalue)
    res = non_lvalue (res);
  return res;
}

/* BIT_FIELD_REF can only handle constant offsets. To work
   around, create a "read" access out of shift operations here. */
tree
build_pascal_packed_array_ref (tree array, tree bits, tree index, int is_read)
{
  tree long_type = packed_array_unsigned_long_type_node;
  tree short_type = packed_array_unsigned_short_type_node;
  tree half_bits_per_long_type = size_int (TYPE_PRECISION (long_type) / 2);
  tree half_bytes_per_long_type = size_int (TYPE_PRECISION (long_type) / (2 * BITS_PER_UNIT));
  tree short_type_ptr = build_pointer_type (short_type);
  tree low_var_access, high_var_access, offset, mask, access;
  tree element_type = TREE_TYPE (TREE_TYPE (array));
  unsigned HOST_WIDE_INT imask, smask;
  index = default_conversion (index);
  offset = build_pascal_binary_op (FLOOR_MOD_EXPR, index, half_bits_per_long_type);
  if (WORDS_BIG_ENDIAN)
    offset = build_pascal_binary_op (MINUS_EXPR,
      size_int (TYPE_PRECISION (long_type) - TREE_INT_CST_LOW (bits)), offset);
  imask = ((unsigned HOST_WIDE_INT) ~0) >> (HOST_BITS_PER_WIDE_INT - TREE_INT_CST_LOW (bits));
  mask = convert (long_type, size_int (imask));
  access = build_binary_op (PLUS_EXPR,
    convert (cstring_type_node, convert_array_to_pointer (array)),
    build_pascal_binary_op (MULT_EXPR, build_pascal_binary_op (FLOOR_DIV_EXPR,
      index, half_bits_per_long_type), half_bytes_per_long_type));

  /* Get the long_type value in two halfs to avoid alignment problems. */
  low_var_access = build_indirect_ref (convert (short_type_ptr, access), NULL);
  access = build_pascal_binary_op (PLUS_EXPR, access, half_bytes_per_long_type);
  high_var_access = build_indirect_ref (convert (short_type_ptr, access), NULL);
  if (WORDS_BIG_ENDIAN)
    {
      tree tmp = low_var_access;
      low_var_access = high_var_access;
      high_var_access = tmp;
    }

  /* OR the two parts (shifted), AND with the mask and shift down. */
  access = build_pascal_binary_op (BIT_AND_EXPR, build_pascal_binary_op (RSHIFT_EXPR,
    build_pascal_binary_op (BIT_IOR_EXPR, convert (long_type, low_var_access),
      build_pascal_binary_op (LSHIFT_EXPR, convert (long_type, high_var_access),
        half_bits_per_long_type)), offset), mask);

  /* sign extend the result when necessary */
  if (!TYPE_UNSIGNED (element_type))
    {
      smask = ((unsigned HOST_WIDE_INT) 1) << (TREE_INT_CST_LOW (bits) - 1);
      access = build3 (COND_EXPR, TREE_TYPE (access),
        build_pascal_binary_op (BIT_AND_EXPR, access, size_int (smask)),
        build_pascal_binary_op (BIT_IOR_EXPR, access, size_int (~imask)),
        access);
    }
  access = convert (element_type, access);
  CHK_EM (access);

  if (is_read)
    return access;

  return build_tree_list (access, build_tree_list (array, build_tree_list (
    build_tree_list (offset, mask), build_tree_list (low_var_access, high_var_access))));
}

tree
build_array_ref_or_constructor (tree t1, tree t2)
{
  if (TREE_CODE (t1) == TYPE_DECL && TREE_CODE (TREE_TYPE (t1)) == SET_TYPE)
    {
      chk_dialect ("structured value constructors are", E_O_PASCAL);
      return build_iso_set_constructor (TREE_TYPE (t1), t2, 0);
    }
  else
    {
      tree list = t2;
      while (list)
        {
          tree ind = TREE_PURPOSE (list);
          if (TREE_CODE (ind) == IDENTIFIER_NODE)
            ind = check_identifier (ind);
          TREE_PURPOSE (list) = TREE_VALUE (list);
          TREE_VALUE (list) = ind;
          list = TREE_CHAIN (list);
        }
      return build_pascal_array_ref (t1, t2);
    }
}

/* Constructs a reference to a Pascal array. INDEX_LIST is a
   TREE_LIST chain of expressions to index the array with.
   This INDEX_LIST is passed in forward order. */
tree
build_pascal_array_ref (tree array, tree index_list)
{
  tree link;
  CHK_EM (TREE_TYPE (array));
  array = probably_call_function (array);

  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (array)))
    error ("accessing a component of a restricted array is not allowed");

  for (link = index_list; link; link = TREE_CHAIN (link))
    {
      tree index;
      /* Catch `array_type[i]' etc. */
      DEREFERENCE_SCHEMA (array);
      if (TREE_CODE (array) == TYPE_DECL
          || (TREE_CODE (TREE_TYPE (array)) != ARRAY_TYPE
              && !PASCAL_TYPE_STRING (TREE_TYPE (array))
              && !(co->cstrings_as_strings
                   && TYPE_MAIN_VARIANT (TREE_TYPE (array)) == cstring_type_node)))
        {
          error ("subscripted object is not an array or string");
          if (TYPE_MAIN_VARIANT (TREE_TYPE (array)) == cstring_type_node)
            cstring_inform ();
          return error_mark_node;
        }

      index = probably_call_function (TREE_VALUE (link));
      CHK_EM (index);
      DEREFERENCE_SCHEMA (index);

      if (TREE_PURPOSE (link))
        {
          tree upper = probably_call_function (TREE_PURPOSE (link));
          CHK_EM (upper);
          DEREFERENCE_SCHEMA (upper);
          array = build_array_slice_ref (array, index, upper);
        }
      else if (TYPE_MAIN_VARIANT (TREE_TYPE (array)) == cstring_type_node)
        {
          if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (index)), pascal_integer_type_node))
            {
              error ("type mismatch in CString index");
              return error_mark_node;
            }
          array = build_indirect_ref (build_pascal_binary_op (PLUS_EXPR, array, index), NULL);
        }
      else
        {
          tree bits = NULL_TREE, domain, string = NULL_TREE;
          index = string_may_be_char (index,  1);
          if (PASCAL_TYPE_STRING (TREE_TYPE (array)))
            {
              string = save_expr_string (array);
              array = PASCAL_STRING_VALUE (string);
            }

          domain = TYPE_DOMAIN (TREE_TYPE (array));
          gcc_assert (domain);
          CHK_EM (domain);
          CHK_EM (index);

          if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (index)), TYPE_MAIN_VARIANT (domain)))
            {
              error ("type mismatch in array index");
              return error_mark_node;
            }

          /* Note: For strings, EP only allows access up to the current length,
                   BP to the capacity. We never want to allow access to the
                   extra element beyond the capacity (which is the maximum of
                   the domain), reserved for internal purposes. */
          if (string)
            index = range_check_2 (integer_one_node, (co->pascal_dialect & B_D_PASCAL)
              ? PASCAL_STRING_CAPACITY (string) : PASCAL_STRING_LENGTH (string), index);
          else
            index = range_check (domain, index);
          CHK_EM (index);

          if (PASCAL_TYPE_PACKED (TREE_TYPE (array)))
            bits = count_bits (TREE_TYPE (TREE_TYPE (array)), NULL);

          if (TREE_CODE (array) == STRING_CST && TREE_CODE (index) == INTEGER_CST)
            {
#ifndef GCC_4_0
              array = build_int_2 (TREE_STRING_POINTER (array)[TREE_INT_CST_LOW (index) - 1], 0);
              TREE_TYPE (array) = char_type_node;
#else
              array = build_int_cst_wide (char_type_node,
                TREE_STRING_POINTER (array)[TREE_INT_CST_LOW (index) - 1], 0);
#endif
            }
          else if (!bits || TREE_INT_CST_LOW (bits) == TREE_INT_CST_LOW (TYPE_SIZE (TREE_TYPE (TREE_TYPE (array)))))
            /* Not packed. Just a normal array reference. */
            array = build_array_ref (array, index);
          else
            {
              tree orig_index = index;
              tree indextype = sizetype;
              tree sindextype = ssizetype;
              /* Accessing a field of a packed array possibly not located on a byte boundary. */
              tree array_type = TREE_TYPE (array);

#ifdef EGCS
              if (LONG_TYPE_SIZE < 64)
                {
                  int big = 1;
                  if (TREE_CODE (TYPE_SIZE (array_type)) == INTEGER_CST
                      && tree_int_cst_lt (TYPE_SIZE (array_type),
                                          TYPE_MAX_VALUE (usizetype)))
                    big = 0;
#if 0
                  /* @@@@@ Non constant, guesstimate */
                  if (TREE_CODE (TYPE_SIZE (array_type)) != INTEGER_CST)
                    {
                      tree low = TYPE_MIN_VALUE (TYPE_DOMAIN (array_type));
                      tree high = TYPE_MAX_VALUE (TYPE_DOMAIN (array_type));
                      debug_tree (low);
                      debug_tree (high);
                    }
#endif
                  if (big)
                    {
                      indextype = bitsizetype;
                      sindextype = sbitsizetype;
                    }
                }
#endif
              bits = convert (indextype, bits);
              /* Index starting from 0. */
              index = size_binop (MINUS_EXPR,
                convert (sindextype, index),
                convert (sindextype, TYPE_MIN_VALUE (TYPE_DOMAIN (array_type))));

              /* Index measured in bits. */
#ifdef EGCS97
              index = size_binop (MULT_EXPR, convert (indextype, index), convert (indextype, bits));
#else
              /* gcc-2.95 only accepts `sizetype' in `size_binop'.
                 But bitsizetype may fail in type_for_size on some platforms
                 (e.g., OSF/Alpha), so better be safe than sorry ... */
              index = fold (build_pascal_binary_op (MULT_EXPR,
                        convert (long_long_integer_type_node, index),
                        convert (long_long_integer_type_node, bits)));
#endif
              STRIP_NOPS (index);

              /* Access the bits. */
              if (TREE_CODE (index) == INTEGER_CST)
                {
                  tree ar = array;
                  if (TREE_CODE (ar) == NON_LVALUE_EXPR)
                    ar = TREE_OPERAND (ar, 0);
                  /* Fold constant reference */
                  if (TREE_CODE (ar) == NOP_EXPR
#ifdef EGCS97
                      || TREE_CODE (ar) == VIEW_CONVERT_EXPR
#endif
                     )
                    {
                      tree t = TREE_TYPE (TREE_OPERAND (ar, 0)), elts;
                      if (TYPE_LANG_CODE_TEST (t, PASCAL_LANG_FAKE_ARRAY))
                        {
                          for (elts = TYPE_LANG_FAKE_ARRAY_ELEMENTS (t); elts; elts = TREE_CHAIN (elts))
                            if (tree_int_cst_equal (orig_index, TREE_PURPOSE (elts)))
                              return TREE_VALUE (elts);
                          gcc_unreachable ();
                        }
                    }
                  array = build3 (BIT_FIELD_REF, TREE_TYPE (array_type),
                                  array, convert (bitsizetype, bits),
                                  convert (bitsizetype, index));
                  BIT_FIELD_REF_UNSIGNED (array) = 
                      TYPE_UNSIGNED (TREE_TYPE (array_type));
                }
              else
                array = build3 (PASCAL_BIT_FIELD_REF, TREE_TYPE (array_type), array, bits, index);
            }
        }
      if (EM (array))
        break;
    }
  prediscriminate_schema (array);
  return array;
}

tree
fold_array_ref (tree t)
{
  tree arg0, arg1;
  gcc_assert (TREE_CODE (t) == ARRAY_REF);
  arg0 = TREE_OPERAND (t, 0);
  arg1 = TREE_OPERAND (t, 1);
  if (TREE_CODE (arg1) == INTEGER_CST && TREE_CODE (arg0) == STRING_CST)
    {
      arg1 = range_check_2 (integer_one_node, build_int_2 (TREE_STRING_LENGTH (arg0) - 1, 0), arg1);
      CHK_EM (arg1);
#ifndef GCC_4_0
      t = build_int_2 (TREE_STRING_POINTER (arg0)[TREE_INT_CST_LOW (arg1) - 1], 0);
      TREE_TYPE (t) = char_type_node;
#else
      t = build_int_cst_wide (char_type_node, 
         TREE_STRING_POINTER (arg0)[TREE_INT_CST_LOW (arg1) - 1], 0);
#endif
    }
  else if (TREE_CODE (arg1) == INTEGER_CST && TREE_CODE (arg0) == CONSTRUCTOR)
    {
#ifndef GCC_4_1
      tree elts = CONSTRUCTOR_ELTS (arg0);
      arg1 = range_check (TYPE_DOMAIN (TREE_TYPE (arg0)), arg1);
      CHK_EM (arg1);
      while (elts)
        {
          if (tree_int_cst_equal (arg1, TREE_PURPOSE (elts)))
            return TREE_VALUE (elts);
          elts = TREE_CHAIN (elts);
        }
#else
      VEC(constructor_elt,gc) *elts = CONSTRUCTOR_ELTS (arg0);
      tree index, value;
      unsigned HOST_WIDE_INT ix;
      arg1 = range_check (TYPE_DOMAIN (TREE_TYPE (arg0)), arg1);
      FOR_EACH_CONSTRUCTOR_ELT (elts, ix, index, value)
        {
          if (tree_int_cst_equal (arg1, index))
            return value;
        }
#endif
    }
  return t;
}

/* Handle array references (`a[i]'). If the array is a variable or a field,
   we generate a primitive ARRAY_REF. This avoids forcing the array out of
   registers, and can work on arrays that are not lvalues (for example,
   fields of structures returned by functions). */
tree
build_array_ref (tree array, tree index)
{
  tree res;
  int lvalue = lvalue_p (array);

  CHK_EM (TREE_TYPE (array));
  CHK_EM (TREE_TYPE (index));

  gcc_assert (index);

  if (!ORDINAL_TYPE (TREE_CODE (TREE_TYPE (index))))
    {
      error ("array index is not of ordinal type");
      return error_mark_node;
    }

  array = probably_call_function (array);
  index = default_conversion (index);

  gcc_assert (TREE_CODE (TREE_TYPE (array)) == ARRAY_TYPE);
  if (TREE_CODE (array) != INDIRECT_REF)
    {
      tree rval, type;

      /* An array that is indexed by a non-constant
         cannot be stored in a register; we must be able to do
         address arithmetic on its address.
         Likewise an array of elements of variable size. */
      if ((TREE_CODE (index) != INTEGER_CST
           || (TYPE_SIZE (TREE_TYPE (TREE_TYPE (array)))
               && TREE_CODE (TYPE_SIZE (TREE_TYPE (TREE_TYPE (array)))) != INTEGER_CST))
          && !mark_addressable2 (array, 1))
        return error_mark_node;

      if (pedantic && !lvalue)
        {
          if (DECL_REGISTER (array))
            pedwarn ("indexing of `register' array");
          else
            pedwarn ("indexing of non-lvalue array");
        }

      if (pedantic)
        {
          tree foo = array;
          while (TREE_CODE (foo) == COMPONENT_REF)
            foo = TREE_OPERAND (foo, 0);
          if (TREE_CODE (foo) == VAR_DECL && DECL_REGISTER (foo))
            pedwarn ("indexing of non-lvalue array");
        }

      type = TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (array)));
#ifndef GCC_4_0
      rval = build (ARRAY_REF, type, array, index);
#else
      rval = build4 (ARRAY_REF, type, array, index, NULL_TREE, NULL_TREE);
#endif
      /* Array ref is const/volatile if the array elements are or if the array is. */
      TREE_READONLY (rval) |= (TYPE_READONLY (TREE_TYPE (TREE_TYPE (array))) | TREE_READONLY (array));
      TREE_SIDE_EFFECTS (rval) |= (TYPE_VOLATILE (TREE_TYPE (TREE_TYPE (array))) | TREE_SIDE_EFFECTS (array));
      TREE_THIS_VOLATILE (rval) |= (TYPE_VOLATILE (TREE_TYPE (TREE_TYPE (array)))
                                   /* This was added by rms on 16 Nov 91. It fixes
                                        volatile struct foo *a;  a->elts[1]
                                      in an inline function. Hope it doesn't break something else. */
                                   | TREE_THIS_VOLATILE (array));
      res = fold_array_ref (rval);
    }
  else
    {
      tree ar = TYPE_MAIN_VARIANT (TREE_TYPE (array)) == cstring_type_node
                ? array : convert_array_to_pointer (array);
      CHK_EM (ar);
      gcc_assert (TREE_CODE (TREE_TYPE (ar)) == POINTER_TYPE
                  && TREE_CODE (TREE_TYPE (TREE_TYPE (ar))) != FUNCTION_TYPE);
      /* @@ jtv: Kenner's code does not handle non-zero low bound array
         indirect_refs, so I leave this code here. When it does
         this can be disabled partially. */
      res = build_indirect_ref (build_pascal_binary_op (PLUS_EXPR, ar,
        fold (build2 (MINUS_EXPR, ssizetype, convert (ssizetype, index),
        convert (ssizetype, TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (array))))))), NULL);
    }
  if (!lvalue)  /* e.g. indexing a string constant */
    res = non_lvalue (res);
  return res;
}

/* Create an expression whose value is that of EXPR, converted to type TYPE.
   The TREE_TYPE of the value is always TYPE. This function implements
   all reasonable conversions; callers should filter out those that are
   not permitted by the language being compiled.
   Change of width -- truncation and extension of integers or reals -- is
   represented with NOP_EXPR. Proper functioning of many things assumes that
   no other conversions can be NOP_EXPRs. Some backend functions assume that
   widening and narrowing is always done with a NOP_EXPR (cf. c-convert.c).
   Conversion between integer and pointer is represented with CONVERT_EXPR.
   Converting integer to real uses FLOAT_EXPR. */
tree
convert (tree type, tree e)
{
  enum tree_code code = TREE_CODE (type);
  gcc_assert (type && e);
  if (type == TREE_TYPE (e) || EM (e) || EM (type))
    return e;
  CHK_EM (TREE_TYPE (e));
/*
  if (code = INTEGER_TYPE || code == ENUMERAL_TYPE)
    e = copy_node (e);
*/
  /* Move NON_LVALUE outside to allow better constant folding */
  if (TREE_CODE (e) == NON_LVALUE_EXPR)
    {
      return build1 (NON_LVALUE_EXPR, type,
                     convert (type, TREE_OPERAND (e, 0)));
    }
  if (TYPE_MAIN_VARIANT (type) == TYPE_MAIN_VARIANT (TREE_TYPE (e)))
    return fold (build1 (NOP_EXPR, type, e));
  /* FIXME Why we do nothing here ??? */
  if (code == SET_TYPE && TREE_CODE (TREE_TYPE (e)) == SET_TYPE)
    return e;
  if (TREE_CODE (TREE_TYPE (e)) == VOID_TYPE)
    {
      error ("void value not ignored as it ought to be");
      return error_mark_node;
    }
  if (code == VOID_TYPE)
    return build1 (CONVERT_EXPR, type, e);
  if (TYPE_IS_CHAR_TYPE(type))
    {
      enum tree_code form = TREE_CODE (TREE_TYPE (e));
      if (TYPE_IS_CHAR_TYPE(TREE_TYPE (e)))
        return fold (build1 (NOP_EXPR, type, e));
      /* @@ If it does not fit? */
      if (ORDINAL_TYPE (form))
        return fold (build1 (CONVERT_EXPR, type, e));
      error ("cannot convert to a char type");
      return error_mark_node;
    }
  if (code == INTEGER_TYPE || code == ENUMERAL_TYPE)
    {
      /* @@ convert_to_integer can change the type of the expression itself
            from any ordinal to integer type. This may be ok in C, but not in
            Pascal (i.e., it's a backend bug). To work-around, we wrap the
            expression here to avoid this bug in case there are other
            references to it (as in fact there are in `case', casebool.pas). */
      enum tree_code c = TREE_CODE (e);
      tree e2 = (TREE_CODE_CLASS (c) == tcc_comparison || c == TRUTH_AND_EXPR
                 || c == TRUTH_ANDIF_EXPR || c == TRUTH_OR_EXPR
                 || c == TRUTH_ORIF_EXPR || c == TRUTH_XOR_EXPR
                 || c == TRUTH_NOT_EXPR) ? copy_node (e) : e;
      tree result = fold (convert_to_integer (type, e2));
      return result;
    }
  if (code == POINTER_TYPE)
    {
      /* @@@ REFERENCE_TYPE not utilized fully in GPC. Should be re-implemented.
             (I implemented var parameters before GCC had REFERENCE_TYPE) */
      if (TREE_CODE (TREE_TYPE (e)) == REFERENCE_TYPE)
        return fold (build1 (CONVERT_EXPR, type, e));
      return fold (convert_to_pointer (type, e));
    }
  /* @@@@ Note: I am not sure this is the correct place to try to fix the problem:
          -O6 in alpha compiling zap.pas traps here. But should the reference_type
          be trapped earlier?? */
  if (code == REFERENCE_TYPE)
    {
      if (TREE_CODE (TREE_TYPE (e)) == POINTER_TYPE)
        return fold (build1 (CONVERT_EXPR, type, e));
      return fold (build1 (CONVERT_EXPR, type,
                           fold (convert_to_pointer (build_pointer_type (TREE_TYPE (type)), e))));
    }
  if (code == REAL_TYPE)
    return fold (convert_to_real (type, e));
  if (code == COMPLEX_TYPE)
    return fold (convert_to_complex (type, e));
  if (code == BOOLEAN_TYPE)
    {
      enum tree_code form = TREE_CODE (TREE_TYPE (e));
      if (integer_zerop (e))
        return fold (build1 (NOP_EXPR, type, boolean_false_node));
      else if (integer_onep (e))
        return fold (build1 (NOP_EXPR, type, boolean_true_node));
      else if (form == BOOLEAN_TYPE)
        {
          if (TYPE_PRECISION (TREE_TYPE (e)) == TYPE_PRECISION (type))
            return fold (build1 (NOP_EXPR, type, e));
          else
            return build2 (NE_EXPR, type, e, convert (TREE_TYPE (e), boolean_false_node));
        }
      else if (ORDINAL_TYPE (form) || form == POINTER_TYPE)
        return fold (build1 (CONVERT_EXPR, type, e));
      error ("cannot convert to a boolean type");
      return error_mark_node;
    }
  error ("type mismatch");
  return error_mark_node;
}

tree
build_simple_array_type (tree elt_type, tree index_type)
{
  tree t;
  CHK_EM (elt_type);
  CHK_EM (index_type);
  t = make_node (ARRAY_TYPE);
  TREE_TYPE (t) = elt_type;
  TYPE_DOMAIN (t) = index_type;
  gcc_assert (index_type);
  layout_type (t);
  if (!TYPE_SIZE (t) || TREE_OVERFLOW (TYPE_SIZE (t))
      || (integer_zerop (TYPE_SIZE (t)) && !integer_zerop (TYPE_SIZE (elt_type))))
    {
      error ("size of array is too large");
      return error_mark_node;
    }
  return t;
}

/* Return a new Boolean type node with given precision. */
tree
build_boolean_type (unsigned precision)
{
  tree r = make_node (BOOLEAN_TYPE);
  TYPE_PRECISION (r) = precision;
  TYPE_UNSIGNED (r) = 1;
  fixup_unsigned_type (r);
  return r;
}

/* Give TYPE a new main variant. This is the right thing to do only when
   something "substantial" about TYPE is modified. */
void
new_main_variant (tree type)
{
  tree t;
  for (t = TYPE_MAIN_VARIANT (type); TYPE_NEXT_VARIANT (t); t = TYPE_NEXT_VARIANT (t))
    if (TYPE_NEXT_VARIANT (t) == type)
      {
        TYPE_NEXT_VARIANT (t) = TYPE_NEXT_VARIANT (type);
        break;
      }
  TYPE_MAIN_VARIANT (type) = type;
  TYPE_NEXT_VARIANT (type) = NULL_TREE;
}

#ifdef EGCS
/* Make a variant type in the proper way for C, propagating qualifiers
   down to the element type of an array. */
tree
c_build_qualified_type (tree type, int type_quals)
{
  tree t = build_qualified_type (type, type_quals);
  if (TREE_CODE (type) == ARRAY_TYPE)
    {
      t = build_type_copy (t);
      TREE_TYPE (t) = c_build_qualified_type (TREE_TYPE (type), type_quals);
    }
  return t;
}
#else
tree
c_build_type_variant (tree type, int constp, int volatilep)
{
  tree t = p_build_type_variant (type, constp, volatilep);
  if (TREE_CODE (type) == ARRAY_TYPE)
    {
      t = build_type_copy (t);
      TREE_TYPE (t) = c_build_type_variant (TREE_TYPE (type), constp, volatilep);
    }
  return t;
}
#endif

/* Build a Pascal variant of the TYPE. Qualifiers are only ever added, not removed. */
tree
pascal_type_variant (tree type, int qualifier)
{
  int protected  = !!(qualifier & TYPE_QUALIFIER_PROTECTED);
  int conformant = !!(qualifier & TYPE_QUALIFIER_CONFORMANT);
  int restricted = !!(qualifier & TYPE_QUALIFIER_RESTRICTED);
  int packed     = !!(qualifier & TYPE_QUALIFIER_PACKED);
  int bindable   = !!(qualifier & TYPE_QUALIFIER_BINDABLE);
  int need_new_variant;

  if (bindable && !PASCAL_TYPE_FILE (type))
    gpc_warning ("GPC supports `bindable' only for files");

  CHK_EM (type);

  /* Restricted types should not get a new TYPE_MAIN_VARIANT so they're
     compatible to the unrestricted ones in parameter lists. Same for conformant
     which is used for conformant array bounds (not the arrays), which must be
     compatible to the ordinary type which the actual parameters will have. */
  need_new_variant = (packed && !PASCAL_TYPE_PACKED (type))
                     /* Special case for `restricted Void' (fjf369*.pas) */
                     || (restricted && TREE_CODE (type) == VOID_TYPE);

  if (!(need_new_variant
        || PASCAL_TYPE_OPEN_ARRAY (type)
        || (protected  && !TYPE_READONLY (type))
        || (bindable   && !PASCAL_TYPE_BINDABLE (type))
        || (conformant && !PASCAL_TYPE_CONFORMANT_BOUND (type))
        || (restricted && !PASCAL_TYPE_RESTRICTED (type))))
    return type;

  type = build_type_copy (type);
  copy_type_lang_specific (type);

  /* This is a new type, so remove it from the variants of the old type */
  if (need_new_variant)
    new_main_variant (type);

  TYPE_READONLY (type) |= protected;
  PASCAL_TYPE_BINDABLE (type) |= bindable;
  PASCAL_TYPE_CONFORMANT_BOUND (type) |= conformant;
  PASCAL_TYPE_RESTRICTED (type) |= restricted;
  PASCAL_TYPE_PACKED (type) |= packed;
  PASCAL_TYPE_OPEN_ARRAY (type) = 0;

  /* Not allowed */
  if (PASCAL_TYPE_BINDABLE (type) && PASCAL_TYPE_RESTRICTED (type))
    error ("restricted types must not be bindable");

  return type;
}

/* @@ This is just a wrapper around build_type_variant that copies
      TYPE_LANG_SPECIFIC. Shouldn't it be merged with
      pascal_type_variant() (what's the difference, anyway)? -- Frank */
tree
p_build_type_variant (tree type, int constp, int volatilep)
{
  tree new_type;
  CHK_EM (type);
  new_type = build_type_variant (type, constp, volatilep);
  if (new_type != type
      && TYPE_LANG_SPECIFIC (new_type)
      && TYPE_LANG_SPECIFIC (new_type) == TYPE_LANG_SPECIFIC (type))
    copy_type_lang_specific (new_type);
  return new_type;
}
