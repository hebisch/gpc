/*Build expressions with Pascal type checking.

  Copyright (C) 1987-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

  Parts of this file were originally derived from GCC's `c-typeck.c'.

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

static int compatible_assignment_p (tree, tree);
static int check_simple_pascal_initializer (tree, tree);
static tree decl_constant_value (tree);
static int is_discriminant_of (tree, tree);
static tree pascal_fold (tree);
static tree re_fold (tree, tree, tree, int *);
static tree re_layout_type (tree, tree, tree);
static void assignment_error_or_warning (const char *, const char *, tree, int, int);
static void push_string (const char *);
static void push_member_name (tree);
static void push_array_index (int);
static char *print_spelling (void);
static const char *get_spelling (const char *);
static void initializer_error (const char *, const char *);
static void process_discriminants (tree);
static void process_init_list (tree);
static void really_start_incremental_init (tree);
static void push_init_level (void);
static tree build_bitfields_type (tree, int);
#ifndef GCC_4_1
static tree do_build_constructor_rev (tree, tree);
#else
static tree do_build_constructor_rev (tree, VEC(constructor_elt,gc) *);
#endif
static tree fill_one_record (tree *, tree, tree, tree *, HOST_WIDE_INT, HOST_WIDE_INT *);
static tree fake_packed_array_constructor (void);
static tree pop_init_level (void);
static void set_init_index (tree, tree, tree);
static void set_init_label (tree);
static void set_init_variant (tree);
static void process_otherwise (tree);
static void output_init_element (tree, tree, tree, int);
static void output_pending_init_elements (int);
static void process_init_element (tree);

void
cstring_inform (void)
{
  static int informed = 0;
  if (!informed)
    {
      informed = 1;
      error (" (Use `--cstrings-as-strings' to treat `CString' as a string.)");
    }
}

void
ptrarith_inform (void)
{
  static int informed = 0;
  if (!informed)
    {
      informed = 1;
      error (" (Use `--pointer-arithmetic' to enable pointer arithmetic.)");
    }
}

/* Do `exp = require_complete_type (exp);' to make sure exp
   does not have an incomplete type. (That includes void types.) */
tree
require_complete_type (tree value)
{
  tree type = TREE_TYPE (value);
  CHK_EM (type);
  /* First, detect a valid value with a complete type. */
  if (TYPE_SIZE (type) && TREE_CODE (type) != VOID_TYPE)
    return value;
  incomplete_type_error (value, type);
  return error_mark_node;
}

/* Print an error message for invalid use of an incomplete type.
   VALUE is the expression that was used (or 0 if that isn't known)
   and TYPE is the type that was invalid. */
void
incomplete_type_error (tree value, tree type)
{
  /* Avoid duplicate error message. */
  if (EM (type))
    return;
  while (TREE_CODE (type) == ARRAY_TYPE && TYPE_DOMAIN (type))
    type = TREE_TYPE (type);
  if (value && (TREE_CODE (value) == VAR_DECL || TREE_CODE (value) == PARM_DECL))
    error ("`%s' has an incomplete type", IDENTIFIER_NAME (DECL_NAME (value)));
  else if (TREE_CODE (value) == NAMESPACE_DECL)
    error ("invalid use of interface name");
  else if (TREE_CODE (type) == VOID_TYPE)
    error ("invalid use of void expression");
  else if (TREE_CODE (type) == ARRAY_TYPE)
    error ("invalid use of array with unspecified bounds");
  else if (TREE_CODE (type) == SET_TYPE)
    error ("invalid use of set type");
  else if (TREE_CODE (type) == LANG_TYPE)
    error ("invalid use of forward declared type");
  else
    gcc_unreachable ();
}

/* Return the common type of two types.
   We assume that comptypes has already been done and returned 1;
   if that isn't so, this may crash. In particular, we assume that qualifiers match.
   This is the type for the result of most arithmetic operations
   if the operands have the given two types. */
tree
common_type (tree t1, tree t2)
{
  enum tree_code code1, code2;
  tree attributes, tmp;
  int prec;

  /* Extend subranges of ordinal types to their full types.
     Otherwise, operations leaving the range won't work. */
  while (ORDINAL_TYPE (TREE_CODE (t1)) && TREE_TYPE (t1))
    t1 = TREE_TYPE (t1);
  while (ORDINAL_TYPE (TREE_CODE (t2)) && TREE_TYPE (t2))
    t2 = TREE_TYPE (t2);

  /* Save time if the two types are the same. */
  if (t1 == t2)
    return t1;

  /* If one type is nonsense, use the other. */
  if (EM (t1))
    return t2;
  if (EM (t2))
    return t1;

  /* Merge the attributes */
  attributes = merge_attributes (TYPE_ATTRIBUTES (t1), TYPE_ATTRIBUTES (t2));

  /* Treat an enum type as the unsigned integer type of the same width. */
  if (TREE_CODE (t1) == ENUMERAL_TYPE)
    t1 = type_for_size (TYPE_PRECISION (t1), 1);
  if (TREE_CODE (t2) == ENUMERAL_TYPE)
    t2 = type_for_size (TYPE_PRECISION (t2), 1);

  code1 = TREE_CODE (t1);
  code2 = TREE_CODE (t2);

  /* If one type is complex, form the common type of the non-complex
     components, then make that complex. Use T1 or T2 if it is the
     required type. */
  if (code1 == COMPLEX_TYPE || code2 == COMPLEX_TYPE)
    {
      tree subtype1 = code1 == COMPLEX_TYPE ? TREE_TYPE (t1) : t1;
      tree subtype2 = code2 == COMPLEX_TYPE ? TREE_TYPE (t2) : t2;
      tree subtype = common_type (subtype1, subtype2);

      if (code1 == COMPLEX_TYPE && TREE_TYPE (t1) == subtype)
        return build_type_attribute_variant (t1, attributes);
      else if (code2 == COMPLEX_TYPE && TREE_TYPE (t2) == subtype)
        return build_type_attribute_variant (t2, attributes);
      else
        return build_type_attribute_variant (build_complex_type (subtype), attributes);
    }

  switch (code1)
  {
    case INTEGER_TYPE:
      if (TYPE_IS_CHAR_TYPE (t1)) goto char_case;
      /* Falltrough */
    case REAL_TYPE:
      /* If only one is complex, use that for the result type */
      if (code2 == COMPLEX_TYPE)
        return build_type_attribute_variant (t2, attributes);

      /* If only one is real, use it as the result. */
      if (code1 == REAL_TYPE && code2 != REAL_TYPE)
        return build_type_attribute_variant (t1, attributes);
      if (code2 == REAL_TYPE && code1 != REAL_TYPE)
        return build_type_attribute_variant (t2, attributes);

      /* Both real or both integers; use the one with greater precision if signedness allows. */
      if (TYPE_PRECISION (t1) > TYPE_PRECISION (t2))
        {
          tmp = t1;
          t1 = t2;
          t2 = tmp;
        }
      if (TYPE_PRECISION (t2) > TYPE_PRECISION (t1))
        {
          if (code1 != REAL_TYPE  /* no sign issues with reals */
              && !TYPE_UNSIGNED (t1)  /* small unsigned fits in larger signed or unsigned */
              && TYPE_UNSIGNED (t2)  /* small signed or unsigned fits in larger signed */
              && TYPE_PRECISION (t2) < TYPE_PRECISION (long_long_integer_type_node))  /* no way to get larger */
            {
              for (prec = BITS_PER_UNIT; prec <= TYPE_PRECISION (t2); prec *= 2) ;
              t2 = make_signed_type (prec);
            }
          return build_type_attribute_variant (t2, attributes);
        }

      /* Same precision, different signedness */
      if (TYPE_UNSIGNED (t1) != TYPE_UNSIGNED (t2))
        {
          if (TYPE_PRECISION (t1) == TYPE_PRECISION (long_long_unsigned_type_node))
            return build_type_attribute_variant (long_long_integer_type_node, attributes);
          else
            {
              for (prec = BITS_PER_UNIT; prec <= TYPE_PRECISION (t2); prec *= 2) ;
              return build_type_attribute_variant (make_signed_type (prec), attributes);
            }
        }

      /* Same precision. Prefer longs to ints even when same size. */
      if (TYPE_MAIN_VARIANT (t1) == long_unsigned_type_node
          || TYPE_MAIN_VARIANT (t2) == long_unsigned_type_node)
        return build_type_attribute_variant (long_unsigned_type_node, attributes);

      if (TYPE_MAIN_VARIANT (t1) == long_integer_type_node
          || TYPE_MAIN_VARIANT (t2) == long_integer_type_node)
        {
          /* But preserve unsignedness from the other type,
             since long cannot hold all the values of an unsigned int. */
          if (TYPE_UNSIGNED (t1) || TYPE_UNSIGNED (t2))
             t1 = long_unsigned_type_node;
          else
             t1 = long_integer_type_node;
          return build_type_attribute_variant (t1, attributes);
        }

      /* Likewise, prefer long double to double even if same size. */
      if (TYPE_MAIN_VARIANT (t1) == long_double_type_node
          || TYPE_MAIN_VARIANT (t2) == long_double_type_node)
        return build_type_attribute_variant (long_double_type_node, attributes);

      /* Otherwise prefer the unsigned one. */

      if (TYPE_UNSIGNED (t1))
        return build_type_attribute_variant (t1, attributes);
      else
        return build_type_attribute_variant (t2, attributes);

    /* Since comptypes checks that code2 is ok, return this. */
    case COMPLEX_TYPE:
      return build_type_attribute_variant (t1, attributes);

    case SET_TYPE:
#if 1
      gcc_unreachable ();
#else
      return build_type_attribute_variant (t1, attributes);
#endif

    case POINTER_TYPE:
      /* For two pointers, do this recursively on the target type,
         and combine the qualifiers of the two types' targets. */
      {
        tree target = common_type (TYPE_MAIN_VARIANT (TREE_TYPE (t1)), TYPE_MAIN_VARIANT (TREE_TYPE (t2)));
        int constp = TYPE_READONLY (TREE_TYPE (t1)) || TYPE_READONLY (TREE_TYPE (t2));
        int volatilep = TYPE_VOLATILE (TREE_TYPE (t1)) || TYPE_VOLATILE (TREE_TYPE (t2));
        t1 = build_pointer_type (c_build_type_variant (target, constp, volatilep));
        return build_type_attribute_variant (t1, attributes);
      }

    case ARRAY_TYPE:
      {
        tree elt = common_type (TREE_TYPE (t1), TREE_TYPE (t2));
        /* Save space: see if the result is identical to one of the args. */
        if (elt == TREE_TYPE (t1) && TYPE_DOMAIN (t1))
          return build_type_attribute_variant (t1, attributes);
        if (elt == TREE_TYPE (t2) && TYPE_DOMAIN (t2))
          return build_type_attribute_variant (t2, attributes);
        /* Merge the element types, and have a size if either arg has one. */
        t1 = build_simple_array_type (elt, TYPE_DOMAIN (TYPE_DOMAIN (t1) ? t1 : t2));
        return build_type_attribute_variant (t1, attributes);
      }

    case FUNCTION_TYPE:
      /* Function types: merge the arg types and result types. */
      {
        tree valtype = common_type (TREE_TYPE (t1), TREE_TYPE (t2));
        tree p1 = TYPE_ARG_TYPES (t1), p2 = TYPE_ARG_TYPES (t2);
        tree newargs, n;
        int len, i;
        gcc_assert (p1 && p2);

        /* Save space: see if the result is identical to one of the args. */
        if (valtype == TREE_TYPE (t1) && !TYPE_ARG_TYPES (t2))
          return build_type_attribute_variant (t1, attributes);
        if (valtype == TREE_TYPE (t2) && !TYPE_ARG_TYPES (t1))
          return build_type_attribute_variant (t2, attributes);

        /* If both args specify argument types, we must merge the two
           lists, argument by argument. */
        len = list_length (p1);
        newargs = 0;
        for (i = 0; i < len; i++)
          newargs = tree_cons (NULL_TREE, NULL_TREE, newargs);

        n = newargs;

        for (; p1; p1 = TREE_CHAIN (p1), p2 = TREE_CHAIN (p2), n = TREE_CHAIN (n))
          {
            /* In Pascal, both types must have been specified. */
            gcc_assert (TREE_VALUE (p1) && TREE_VALUE (p2));

            /* Take the first type and avoid a recursive call to common_type() which does too much.
               For compatible function types, these must match anyway. @@ re-check it here
               (@@ Maybe it would be better to let common_type() do less?) */
            TREE_VALUE (n) = TREE_VALUE (p1);
          }

        t1 = build_function_type (valtype, newargs);
        /* FALLTHROUGH */
      }

    default:
      char_case:
      return build_type_attribute_variant (t1, attributes);
  }

}

/* Return 1 if TYPE1 and TYPE2 are compatible for some operations. */
int
comptypes (tree t1, tree t2)
{
  tree base1, base2;

  if (t1 == t2 || EM (t1) || EM (t2))
    return 1;

  /* Different classes of types can't be compatible. */
  if (TREE_CODE (t1) != TREE_CODE (t2))
    return 0;

  if ((STRUCTURED_TYPE (TREE_CODE (t1)) 
       || (TREE_CODE (t1) == SET_TYPE 
           && !PASCAL_TYPE_CANONICAL_SET (t1)
           && !PASCAL_TYPE_CANONICAL_SET (t2)))
      && PASCAL_TYPE_PACKED (t1) != PASCAL_TYPE_PACKED (t2))
    return 0;

  /* Qualifiers must match. */
#if 0  /* Nope -- only target (if assignment) must not be readonly, but
          this should have been checked elsewhere. -- Frank */
  if (TYPE_READONLY (t1) != TYPE_READONLY (t2))
    return 0;
#endif
  if (TYPE_VOLATILE (t1) != TYPE_VOLATILE (t2))
    return 0;

  if ((PASCAL_TYPE_STRING (t1) || PASCAL_TYPE_SCHEMA (t1)) && TYPE_LANG_BASE (t1))
    base1 = TYPE_MAIN_VARIANT (TYPE_LANG_BASE (t1));
  else
    base1 = base_type (t1);
  if ((PASCAL_TYPE_STRING (t2) || PASCAL_TYPE_SCHEMA (t2)) && TYPE_LANG_BASE (t2))
    base2 = TYPE_MAIN_VARIANT (TYPE_LANG_BASE (t2));
  else
    base2 = base_type (t2);
  if (base1 == base2)
    return 1;

  switch (TREE_CODE (t1))
  {
    case INTEGER_TYPE:
      /* INTEGER_TYPE means either integer or char type.  All integer
         types are compatible.  And all char types are compatible.
         So we check if integer is mixed with char. */
      return TYPE_IS_INTEGER_TYPE (t1) == TYPE_IS_INTEGER_TYPE (t2);
#ifndef GCC_4_2
    case CHAR_TYPE:     /* All char types are compatible. */
#endif
    case BOOLEAN_TYPE:  /* All Boolean types are compatible. */
      return 1;

    case SET_TYPE:
      return TREE_TYPE (t1) == TREE_TYPE (t2)
             || t1 == empty_set_type_node
             || t2 == empty_set_type_node
             || comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (t1)), TYPE_MAIN_VARIANT (TREE_TYPE (t2)));

    case POINTER_TYPE:
    case REFERENCE_TYPE:
      return TREE_TYPE (t1) == TREE_TYPE (t2)
             || TREE_TYPE (t1) == void_type_node
             || TREE_TYPE (t2) == void_type_node
             || ((TREE_TYPE (t1) != t1 || TREE_TYPE (t2) != t2) && comptypes (TREE_TYPE (t1), TREE_TYPE (t2)));

    case FUNCTION_TYPE:
      {
        tree args1, args2;
        if (!strictly_comp_types (TREE_TYPE (t1), TREE_TYPE (t2)))
          return 0;
        for (args1 = TYPE_ARG_TYPES (t1), args2 = TYPE_ARG_TYPES (t2); args1 && args2;
             args1 = TREE_CHAIN (args1), args2 = TREE_CHAIN (args2))
          {
            /* @@ Should probably be done in strictly_compare_types (see comment there). */
            if (   TREE_CODE (TREE_VALUE (args1)) == REFERENCE_TYPE
                && TREE_CODE (TREE_VALUE (args2)) == REFERENCE_TYPE
                && TYPE_READONLY (TREE_TYPE (TREE_VALUE (args1))) != TYPE_READONLY (TREE_TYPE (TREE_VALUE (args2))))
              return 0;
            if (!strictly_comp_types (TREE_VALUE (args1), TREE_VALUE (args2)))
              return 0;
          }
        return !args1 && !args2;
      }

    case RECORD_TYPE:
      return ( (TYPE_IS_CHAR_TYPE (t1) || is_of_string_type (t1, 1))
              && (TYPE_IS_CHAR_TYPE (t2) || is_of_string_type (t2, 1)))
             || (PASCAL_TYPE_ANYFILE (t1) && PASCAL_TYPE_FILE (t2));

    default:
      break;
  }
  return 0;
}

/* Return 1 if TYPE1 and TYPE2 are equivalent types, ignoring their qualifiers. */
int
strictly_comp_types (tree type1, tree type2)
{
  tree base1, base2;

  if (type1 == type2 || EM (type1) || EM (type2))
    return 1;

  if (TREE_CODE (type1) != TREE_CODE (type2))
    return 0;

  /* Qualifiers must match. */
#if 0
  /* @@ Hmm ... well, this depends. For formal and actual arguments,
        readonlyness does not have to match, but for comparing pointer
        types, it should. This whole type-checking must be completely
        reorganized. -- Frank */
  if (TYPE_READONLY (type1) != TYPE_READONLY (type2))
    return 0;
#endif

  /* In FUNCTION_TYPES, TYPE_VOLATILE has a different meaning. @@ Must check this better. */
  if (TREE_CODE (type1) != FUNCTION_TYPE && TYPE_VOLATILE (type1) != TYPE_VOLATILE (type2))
    return 0;

  /* Conformant and open arrays */
  if (TREE_CODE (type1) == ARRAY_TYPE
      /* @@ Ignore packing for char arrays (where it has no real effect,
            anyway), so string constants are compatible with unpacked
            arrays of char (fjf655b.pas). Maybe this is too general, but
            the information if this is a string constant is not available
            here I think since we only have the types. -- Frank */
      && (PASCAL_TYPE_PACKED (type1) == PASCAL_TYPE_PACKED (type2)
          || TYPE_IS_CHAR_TYPE (TREE_TYPE (type1)))
      && (PASCAL_TYPE_OPEN_ARRAY (type1)
          || PASCAL_TYPE_OPEN_ARRAY (type2)
          || (PASCAL_TYPE_CONFORMANT_ARRAY (type1)
              && comptypes (TYPE_DOMAIN (type1), TREE_TYPE (TYPE_MIN_VALUE (TYPE_DOMAIN (type2)))))
          || (PASCAL_TYPE_CONFORMANT_ARRAY (type2)
              && comptypes (TYPE_DOMAIN (type2), TREE_TYPE (TYPE_MIN_VALUE (TYPE_DOMAIN (type1))))))
      && strictly_comp_types (TREE_TYPE (type1), TREE_TYPE (type2)))
    return 1;

  base1 = type1;
  base2 = type2;
  /* An undiscriminated schema or string is compatible with both an
     undiscriminated and a discriminated one of the same base type,
     but two discriminated ones are generally not compatible. */
  if (   (PASCAL_TYPE_STRING (type1) && PASCAL_TYPE_STRING (type2)
          && !(PASCAL_TYPE_DISCRIMINATED_STRING (type1) || PASCAL_TYPE_DISCRIMINATED_STRING (type2)))
      || (PASCAL_TYPE_SCHEMA (type1) && PASCAL_TYPE_SCHEMA (type2)
          && !(PASCAL_TYPE_DISCRIMINATED_SCHEMA (type1) || PASCAL_TYPE_DISCRIMINATED_SCHEMA (type2))))
    {
      if (TYPE_LANG_BASE (type1))
        base1 = TYPE_LANG_BASE (type1);
      if (TYPE_LANG_BASE (type2))
        base2 = TYPE_LANG_BASE (type2);
    }

  base1 = TYPE_MAIN_VARIANT (base1);
  base2 = TYPE_MAIN_VARIANT (base2);
  if (base1 == base2)
    return 1;
  if ((TREE_CODE (type1) == REFERENCE_TYPE)
      /* @@ The following case occurs (e.g.?) when comparing the
            argument lists of functions (forward declarations etc.)
            which contain a pointer to an undiscriminated schema
            type (fjf604.pas). It might seem somewhat kludgy having
            to handle this here, but I'm not sure ...
            Note, don't call this function recursively for *all*
            pointers! This might lead to endless loops with recursive
            types, and result in too weak pointer type checking. For
            references (above) it doesn't seem an issue because there
            are no nested references in Pascal (AFAIK). -- Frank */
      || (   TREE_CODE (type1) == POINTER_TYPE
          && TREE_CODE (type2) == POINTER_TYPE
          && PASCAL_TYPE_SCHEMA (TREE_TYPE (type1))
          && PASCAL_TYPE_SCHEMA (TREE_TYPE (type2))))
    return strictly_comp_types (TREE_TYPE (type1), TREE_TYPE (type2));
  return TREE_CODE (base1) == FUNCTION_TYPE && comptypes (base1, base2);
}

/* Return 1 if TTL and TTR are pointers to types that are equivalent,
   ignoring their qualifiers. */
int
comp_target_types (tree ttl, tree ttr)
{
  return TYPE_MAIN_VARIANT (ttl) == TYPE_MAIN_VARIANT (ttr)
         || (PASCAL_TYPE_ANYFILE (TREE_TYPE (ttl))
             && PASCAL_TYPE_FILE (TREE_TYPE (ttr)))
         || strictly_comp_types (TREE_TYPE (ttl), TREE_TYPE (ttr));
}

/* Return 1 if two pointers to objects are assignment compatible;
   This is the case if rhs has the same type as lhs or is inherited from it. */
int
comp_object_or_schema_pointer_types (tree lhs, tree rhs, int param)
{
  tree r;
  if (TYPE_MAIN_VARIANT (lhs) == TYPE_MAIN_VARIANT (rhs))
    return 1;

  if ((PASCAL_TYPE_UNDISCRIMINATED_STRING (lhs) || PASCAL_TYPE_PREDISCRIMINATED_STRING (lhs))
      && PASCAL_TYPE_STRING (rhs))
    return 1;

  if (param && PASCAL_TYPE_PREDISCRIMINATED_SCHEMA (lhs) && PASCAL_TYPE_SCHEMA (rhs)
      && TYPE_MAIN_VARIANT (TYPE_LANG_BASE (lhs)) == TYPE_MAIN_VARIANT (TYPE_LANG_BASE (rhs)))
    return 1;

  if (PASCAL_TYPE_OBJECT (lhs) && PASCAL_TYPE_OBJECT (rhs))
    for (r = rhs; r; r = TYPE_LANG_BASE (r))
      {
        if (TREE_CODE (r) == POINTER_TYPE)
          {
            gcc_assert (PASCAL_TYPE_CLASS (r));
            r = TREE_TYPE (r);
          }
        if (TYPE_MAIN_VARIANT (lhs) == TYPE_MAIN_VARIANT (r))
          return 1;
      }
  return 0;
}

/* Return either DECL or its known constant value (if it has one). */
static tree
decl_constant_value (tree decl)
{
  if (/* Don't change a variable array bound or initial value to a constant
         in a place where a variable is invalid. */
      current_function_decl
      && !TREE_THIS_VOLATILE (decl)
      && TREE_READONLY (decl)
      && DECL_INITIAL (decl)
      && !EM (DECL_INITIAL (decl))
      /* This is invalid if initial value is not constant.
         If it has either a function call, a memory reference,
         or a variable, then re-evaluating it could give different results. */
      && TREE_CONSTANT (DECL_INITIAL (decl))
      /* Check for cases where this is sub-optimal, even though valid. */
      && TREE_CODE (DECL_INITIAL (decl)) != CONSTRUCTOR
      && TREE_CODE (DECL_INITIAL (decl)) != PASCAL_SET_CONSTRUCTOR
      && DECL_MODE (decl) != BLKmode)
    return DECL_INITIAL (decl);
  return decl;
}

/* Perform default promotions for values used in expressions.
   Ordinal values are converted to integer. */
tree
default_conversion (tree exp)
{
  tree type = TREE_TYPE (exp), orig_exp;
  enum tree_code code = TREE_CODE (type);

  /* Replace a nonvolatile const static variable with its value unless
     it is an array, in which case we must be sure that taking the
     address of the array produces consistent results.
     @@ Why only for arrays? -- Frank */
  if (optimize && TREE_CODE (exp) == VAR_DECL && code != ARRAY_TYPE)
    {
      exp = decl_constant_value (exp);
      type = TREE_TYPE (exp);
    }

  /* Strip NON_LVALUE_EXPRs and no-op conversions, since we aren't using as an lvalue. */
  orig_exp = exp;
  STRIP_TYPE_NOPS (exp);
#ifndef GCC_4_3
  if (HAS_EXP_ORIGINAL_CODE_FIELD (orig_exp) && HAS_EXP_ORIGINAL_CODE_FIELD (exp))
    SET_EXP_ORIGINAL_CODE (exp, EXP_ORIGINAL_CODE (orig_exp));
#endif

  /* Normally convert enums to integer, but convert wide enums to something wider. */
  if (ORDINAL_TYPE (code))
    return convert (type_for_size (MAX (TYPE_PRECISION (type), TYPE_PRECISION (pascal_integer_type_node)),
      (TYPE_PRECISION (type) >= TYPE_PRECISION (pascal_integer_type_node) && TYPE_UNSIGNED (type))), exp);

  if (code == VOID_TYPE)
    {
      error ("statement used as an expression");
      return error_mark_node;
    }
  /* @@@ Note: Now that the reference type works in the backend,
     maybe I should re-implement var parameter code once more. */
  /* Get rid of var parameter REFERENCE_TYPE */
  if (code == REFERENCE_TYPE)
    return convert (build_pointer_type (TREE_TYPE (type)), exp);
  return exp;
}

/* Convert ARRAY_TYPE to POINTER_TYPE.
   This code is equivalent to the code for C-arrays in default_conversion () above. */
tree
convert_array_to_pointer (tree exp)
{
  tree type = TREE_TYPE (exp), adr, ptrtype, restype = TREE_TYPE (type);
  int constp = TYPE_READONLY (type), volatilep = TYPE_VOLATILE (type);
  gcc_assert (TREE_CODE (type) == ARRAY_TYPE);

  if (TREE_CODE_CLASS (TREE_CODE (exp)) == tcc_reference || DECL_P (exp))
    {
      constp |= TREE_READONLY (exp);
      volatilep |= TREE_THIS_VOLATILE (exp);
    }

  if (constp || volatilep)
    restype = c_build_type_variant (restype, constp, volatilep);

  ptrtype = build_pointer_type (restype);

  if (TREE_CODE (exp) == INDIRECT_REF)
    return convert (ptrtype, TREE_OPERAND (exp, 0));

  if (TREE_CODE (exp) == COMPOUND_EXPR)
    {
      tree op1 = default_conversion (TREE_OPERAND (exp, 1));
      return build2 (COMPOUND_EXPR, TREE_TYPE (op1),
                     TREE_OPERAND (exp, 0), op1);
    }

  if (!lvalue_p (exp) 
      && !(TREE_CODE (exp) == CONSTRUCTOR && TREE_STATIC (exp))
      && !((TREE_CODE (exp) == NOP_EXPR
#ifdef EGCS97
            || TREE_CODE (exp) == VIEW_CONVERT_EXPR
#endif
           )
           && TREE_CODE (TREE_OPERAND (exp, 0)) == CONSTRUCTOR
           && TREE_STATIC (TREE_OPERAND (exp, 0))))
    {
      error ("invalid use of non-lvalue array");
      return error_mark_node;
    }

  if (TREE_CODE (exp) == VAR_DECL)
    {
      /* @@ This is not really quite correct in that the type of the
            operand of ADDR_EXPR is not the target type of the type
            of the ADDR_EXPR itself.
            Question is, can this lossage be avoided? */
      adr = build1 (ADDR_EXPR, ptrtype, exp);
      if (!mark_addressable (exp))
        return error_mark_node;
      TREE_CONSTANT (adr) = staticp (exp) != 0;
      TREE_SIDE_EFFECTS (adr) = 0;  /* Default would be, same as EXP. */
      return adr;
    }
  /* This way is better for a COMPONENT_REF since it can
     simplify the offset for a component. */
  return convert (ptrtype, build_unary_op (ADDR_EXPR, exp, 1));
}

static int
compatible_assignment_p (tree type0, tree type1)
{
  enum tree_code code0 = TREE_CODE (type0), code1;
  /* For things like fjf750a.pas. */
  while (PASCAL_TYPE_SCHEMA (type1))
    type1 = TREE_TYPE (TREE_VALUE (find_field (type1, schema_id, 1)));
  code1 = TREE_CODE (type1);
  if (code0 == ENUMERAL_TYPE || code1 == ENUMERAL_TYPE)
    return comptypes (type0, type1);
  else if ((TYPE_IS_CHAR_TYPE (type0) || is_of_string_type (type0, 0) ||
              TYPE_MAIN_VARIANT (type0) == cstring_type_node)
           && (TYPE_IS_CHAR_TYPE (type1) || is_of_string_type (type1, 0)))
    return 1;
  else if (TYPE_IS_CHAR_TYPE (type0))
    return TYPE_IS_CHAR_TYPE (type1);
  else
    return code0 == code1
           || (code0 == REAL_TYPE && TYPE_IS_INTEGER_TYPE (type1))
           || (code0 == COMPLEX_TYPE && (code1 == REAL_TYPE ||
               TYPE_IS_INTEGER_TYPE (type1)));
}


/* Helpers for convert_arguments */
struct argument_error_context {
  tree fundecl;
  long parmnum;
  int informed_decl;
};

static void argument_error (const char * msg, 
                            struct argument_error_context * errc);
static tree convert_arg1 (tree * tp, tree val,
                          struct argument_error_context * errc,
                          int keep_this_val, int * else_p,
                          int var_parm, int const_parm);
static tree convert_bounds (tree typetail, tree argtype, tree val,
                 struct argument_error_context * errc, long cnt);
static tree convert_conformal (tree type, tree val, int var_param);
static tree convert_one_arg (tree type, tree val, tree * last_valp,
               struct argument_error_context * errc, int conformal);
static tree convert_schema (tree * tp, tree val, tree last_val, int var_parm);
static tree copy_val_ref_parm (tree *tp, tree val, int const_parm);
static tree get_schema_plain_type (tree type);
static tree handle_typed_arg (tree type, tree val,
                  struct argument_error_context * errc, int const_parm);
static tree handle_vararg (tree val);
static tree scan_section (tree types, tree * argtype, long *sec_cntp,
                          long *bouns_cntp);

static void
argument_error (const char * msg, struct argument_error_context * errc)
{
  tree fundecl = errc->fundecl;
  long parmnum = errc->parmnum;
  int informed_decl = errc->informed_decl;

  if (fundecl && DECL_NAME (fundecl))
    {
      error (msg, parmnum, ACONCAT (("`", 
             IDENTIFIER_NAME (DECL_NAME (fundecl)), "'", NULL)));
      if (!informed_decl)
        {
          error_with_decl (fundecl, " routine declaration");
          errc->informed_decl = 1;
        }
    }
  else
    error (msg, parmnum, "indirect function call");
}


static tree
get_schema_plain_type (tree type)
{
  tree field;
  while (PASCAL_TYPE_SCHEMA (type))
    {
      field = simple_get_field (schema_id, type, "");
      type = TREE_TYPE (field);
    }
  return type;
}

static tree
convert_schema (tree * tp, tree val, tree last_val, int var_parm)
{
  tree type = *tp;
      /* If formal parameter is a schema, undo a possible implicit schema
         dereference of val and check discriminants. */
  tree partype = TREE_CODE (type) == REFERENCE_TYPE ? TREE_TYPE (type) : type;
      if (PASCAL_TYPE_SCHEMA (partype))
        {
          val = probably_call_function (val);
          val = undo_schema_dereference (val);
          if (PASCAL_TYPE_DISCRIMINATED_SCHEMA (partype))
            {
              tree ptype = get_schema_plain_type (partype);
              /* Is assignment compatibility enough ? */
              if (var_parm 
                   || !(ORDINAL_REAL_OR_COMPLEX_TYPE (TREE_CODE (ptype))
                        /*  @@@ not yet -- no set schema 
                        || TREE_CODE (ptype) == SET_TYPE */
                        || is_of_string_type (ptype, 0)))
                {
                  tree schema_check = check_discriminants (partype, val);
                  /* schema_check is error_mark_node in case of type mismatch.
                     Ignore this here, it will be reported below. */
                  if (!EM (schema_check))
                    {
                      if (TREE_CODE (schema_check) != INTEGER_CST)
                        val = build2 (COMPOUND_EXPR, TREE_TYPE (val),
                                     schema_check, val);
                      if (TREE_CODE (type) == REFERENCE_TYPE)
                        type = build_reference_type (TREE_TYPE (val));
                    }
                }
              /* Should avoid copy if types agree */
              else if (TYPE_MAIN_VARIANT (partype) 
                        != TYPE_MAIN_VARIANT (TREE_TYPE (val)))
                {
                  tree tmp = make_new_variable ("val_schema", partype);
                  tree ptmp = tmp;
                  tree nval = NULL_TREE;
                  DEREFERENCE_SCHEMA (val);
                  DEREFERENCE_SCHEMA (ptmp);
                  if (is_of_string_type (ptype, 0) 
                      && is_string_compatible_type (val, 0))
                    nval = assign_string (ptmp, val);
                  else if (ORDINAL_REAL_OR_COMPLEX_TYPE (TREE_CODE (ptype))
                           && comptypes (ptype, TREE_TYPE (val)))
                    nval = build_modify_expr (tmp, NOP_EXPR, val);
                  if (nval)
                    val = build2 (COMPOUND_EXPR, partype, nval, tmp);
                }
            }
          /* Check for same actual discriminants within an id_list. We enforce
             this only in strict EP mode. As we store the discriminants in the
             schemata anyway, this condition is not really necessary for us. */
          else if (last_val && (co->pascal_dialect & E_O_PASCAL))
            {
              tree schema_check = check_discriminants (last_val, val);
              if (!EM (schema_check) && TREE_CODE (schema_check) != INTEGER_CST)
                val = build2 (COMPOUND_EXPR, TREE_TYPE (val),
                              schema_check, val);
            }
        }
      else if (PASCAL_TYPE_STRING (partype))
        {
          tree cond = NULL_TREE;
          val = probably_call_function (val);
          /* discover string nature of schema value */
          if (!var_parm && !PASCAL_TYPE_STRING (TREE_TYPE (val)))
            DEREFERENCE_SCHEMA (val);
          if (var_parm
              && PASCAL_TYPE_DISCRIMINATED_STRING (partype)
              && PASCAL_TYPE_STRING (TREE_TYPE (val)))
            {
              type = build_reference_type (TREE_TYPE (val));
              cond = build_pascal_binary_op (NE_EXPR,
                TYPE_LANG_DECLARED_CAPACITY (partype),
                TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (val)));
            }
          else if (last_val && (co->pascal_dialect & E_O_PASCAL)
                   && is_string_compatible_type (val, 0)
                   && is_string_compatible_type (last_val, 0))
            {
              if (var_parm)
                cond = build_pascal_binary_op (NE_EXPR,
                  TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (last_val)),
                  TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (val)));
              else if (!PASCAL_TYPE_DISCRIMINATED_STRING (partype))
                cond = build_pascal_binary_op (NE_EXPR,
                  PASCAL_STRING_LENGTH (last_val),
                  PASCAL_STRING_LENGTH (val));
            }
          if (cond)
            {
              cond = discriminant_mismatch_error (cond);
              if (TREE_CODE (cond) != INTEGER_CST)
                val = build2 (COMPOUND_EXPR, TREE_TYPE (val), cond, val);
            }
        }

  *tp = type;
  return val;
}

static tree
convert_arg1 (tree * tp, tree val, struct argument_error_context * errc,
              int keep_this_val, int * else_p, int var_parm, int const_parm)
{
  tree type = *tp;
      tree sval = val;
      tree partype = TREE_CODE (type) == REFERENCE_TYPE ? 
                       TREE_TYPE (type) : type;
      DEREFERENCE_SCHEMA (sval);

      /* @@@@ Ughly klugde for compatibility */
      if (const_parm && TREE_CODE (partype) == VOID_TYPE
          && (TREE_CODE (val) == STRING_CST
              || (TREE_CODE (val) == CONSTRUCTOR
                  && !(TREE_CODE (TREE_TYPE (val)) == SET_TYPE))))
        return val;
        
      if (((var_parm && TREE_CODE (partype) != FUNCTION_TYPE)
          || (const_parm && TREE_CODE (partype) == VOID_TYPE))
          && !lvalue_p (val))
        {
          argument_error ("reference expected, value given in argument %ld",
                           errc);
          return error_mark_node;
        }
#if 1
  {
    tree vtype = TREE_TYPE (val);
    enum tree_code parcode = TREE_CODE (partype);
      /* Copy simple const parameters passed by reference */
      if (TREE_CODE (type) == REFERENCE_TYPE && const_parm
          && (!lvalue_p (val) || TYPE_MAIN_VARIANT (vtype)
                != TYPE_MAIN_VARIANT (partype))
/*          && parcode != CHAR_TYPE  */
          && SCALAR_TYPE (parcode)
          && SCALAR_TYPE (TREE_CODE (vtype))
          && !PASCAL_PROCEDURAL_TYPE (type)
          /* && comptypes (TREE_TYPE (val), partype) */)
        {
          tree temp = make_new_variable ("ref_const_parameter", partype);
          val = convert_for_assignment (partype, val, NULL, /* arg passing
*/ errc->fundecl, errc->parmnum);
          CHK_EM (val);
          val = build2 (COMPOUND_EXPR, partype, 
                  build_modify_expr (temp, NOP_EXPR, val), temp);
        }
  }
#endif
      /* Set types. */
      if (TREE_CODE (partype) == SET_TYPE 
          && TREE_CODE (TREE_TYPE (val)) == SET_TYPE)
         {
         if ((var_parm && TYPE_MAIN_VARIANT (partype)
               != TYPE_MAIN_VARIANT (TREE_TYPE (val)))
             || !comptypes (partype, TREE_TYPE (val))) 
           {
             argument_error ("type mismatch in argument %ld of %s", errc);
             return error_mark_node;
           }
         else
        {
          if (TREE_CODE (val) == PASCAL_SET_CONSTRUCTOR)
            /* Convert the set constructor to the corresponding set type */
#if 0
            val = construct_set (val, type, 2);
#else
            /* fjf880.pas */
            {
              tree temp = make_new_variable ("set_parameter", partype);
              if (!SET_CONSTRUCTOR_ELTS (val))
                {
                  construct_set (val, temp, 0);
                  val = temp;
                }
              else
                val = build2 (COMPOUND_EXPR, partype,
                              assign_set (temp, construct_set (val, temp, 0)),
                              temp);
            }
#endif
          else if (!var_parm)
            {
              tree domain_a = TYPE_DOMAIN (TREE_TYPE (val)),
                   domain_f = TYPE_DOMAIN (partype);
              if (!tree_int_cst_equal (TYPE_MIN_VALUE (domain_a), TYPE_MIN_VALUE (domain_f))
                  || !tree_int_cst_equal (TYPE_MAX_VALUE (domain_a), TYPE_MAX_VALUE (domain_f))
                  || (TREE_CODE (type) == REFERENCE_TYPE &&
                      !lvalue_p (val)))
                {
                  tree temp = make_new_variable ("set_parameter", partype);
                  val = build2 (COMPOUND_EXPR, partype,
                                 assign_set (temp, val), temp);
                }
            }
        }
        }

      /* Chars. */
      else if (TYPE_IS_CHAR_TYPE (partype) && !var_parm)
        {
          val = string_may_be_char (val, 1);
          if (is_string_type (val, 0))
            {
              tree string_val = val;
              /* Formal type `Char' must accept string values.
                 Assign the string to a temporary char variable and pass that. */
              val = make_new_variable ("char_parm", partype);
              expand_expr_stmt1 (assign_string (val, string_val));
            }
        }

      /* Strings. */
      else if (is_string_compatible_type (sval, 0)
               && (is_of_string_type (type, 0)
                   || (TREE_CODE (type) == REFERENCE_TYPE 
                       && (PASCAL_TYPE_STRING (TREE_TYPE (type))
                           || (const_parm && !keep_this_val 
                               && is_of_string_type (partype, 0))))))
        {
          int varparm = 0, val_ref_parm = 0, conforming, is_readonly, is_volatile;

          if (TREE_CODE (type) == REFERENCE_TYPE)
            {
              varparm = 1;
              val_ref_parm = PASCAL_TYPE_VAL_REF_PARM (type)
                             || PASCAL_CONST_PARM (type);
              is_readonly = TYPE_READONLY (TREE_TYPE (type));
              is_volatile = TYPE_VOLATILE (TREE_TYPE (type));
            }
          else
            {
              is_readonly = TYPE_READONLY (type);
              is_volatile = TYPE_VOLATILE (type);
            }

          /* should not happen: always passed by reference */
          gcc_assert (!PASCAL_TYPE_UNDISCRIMINATED_STRING (type));

          /* If the type is `String (X)' do not convert type, but still
             convert the CHAR or fixed-string to a new schema variable. */
          conforming = (varparm
                        && (PASCAL_TYPE_UNDISCRIMINATED_STRING (TREE_TYPE (type))
                            || PASCAL_TYPE_PREDISCRIMINATED_STRING (TREE_TYPE (type))))
                       || PASCAL_TYPE_PREDISCRIMINATED_STRING (type);

          /* See if the actual parameter is a variable length string
             and the formal is an undiscriminated string schema
             -> use type of actual parameter.
             If actual is not a variable-string, create a new variable string
             type with the proper length and use the new type. */
          if (conforming)
            {
              if (is_variable_string_type (TREE_TYPE (val)))
                type = TREE_TYPE (val);
              else if (!varparm)
                type = build_pascal_string_schema (PASCAL_STRING_LENGTH (val));
              if (is_readonly != TYPE_READONLY (type)
                  || is_volatile != TYPE_VOLATILE (type)
                  || PASCAL_TYPE_VAL_REF_PARM (type) != val_ref_parm)
                {
                  type = build_type_copy (type);
                  TYPE_READONLY (type) = is_readonly;
                  TYPE_VOLATILE (type) = is_volatile;
                  PASCAL_TYPE_VAL_REF_PARM (type) = val_ref_parm;
                }
              if (varparm && TREE_CODE (type) != REFERENCE_TYPE)
                {
                  type = build_type_copy (build_reference_type (type));
                  PASCAL_TYPE_VAL_REF_PARM (type) = val_ref_parm;
                }
            }

          /* The formal parameter is a discriminated string schema, the
             actual parameter is any string type. Create a new schema, copy
             the value there and pass that.

             @@ Create a new copy of string, but the size is now the same
             as the formal parameter's size, padding the value parameter with
             spaces if necessary. The result is then *again* copied to the
             stack as a value parameter.

             The first copy can be avoided if the formal and actual parameters
             are of same size. Now avoided if the types match. */

          if (!(var_parm || conforming) && TYPE_MAIN_VARIANT (TREE_TYPE (val)) != TYPE_MAIN_VARIANT (partype))
            val = new_string_by_model (partype, val, 1);
        }
      else
        *else_p = 1;
  *tp = type;
  return val;
}

static tree
copy_val_ref_parm (tree *tp, tree val, int const_parm)
{
  tree type = *tp;
  gcc_assert (type);
      /* Actual CONST parameters may be constant values, although
         they are passed by reference. Create a temporary variable.
         The same has to be done for other value parameters passed
         by reference, e.g. schemata without specified discriminants. */
      if (TREE_CODE (type) == REFERENCE_TYPE
          && TREE_CODE (TREE_TYPE (type)) != VOID_TYPE
          && ((TYPE_READONLY (TREE_TYPE (type))
               && (TREE_CODE (val) == STRING_CST
                   || TREE_CODE (val) == CONSTRUCTOR
                   || TREE_CODE (val) == PASCAL_SET_CONSTRUCTOR
                   || !lvalue_p (val)
                   || ((PASCAL_TYPE_STRING (TREE_TYPE (type)) || TREE_CODE (TREE_TYPE (type)) == VOID_TYPE)
                       && (TYPE_IS_CHAR_TYPE (TREE_TYPE (val))
                           || (TREE_CODE (TREE_TYPE (val)) == ARRAY_TYPE
                               && TYPE_IS_CHAR_TYPE (TREE_TYPE (
                                      TREE_TYPE (val))))))))
              || PASCAL_TYPE_VAL_REF_PARM (type)))
        {
          if (PASCAL_TYPE_STRING (TREE_TYPE (type))
              && PASCAL_TYPE_VAL_REF_PARM (type)
              && (!PASCAL_TYPE_STRING (TREE_TYPE (val)) && is_string_compatible_type (val, 0)))
            {
              val = new_string_by_model (NULL_TREE, val, 1);

              /* Avoid "incompatible pointer type" warning ... */
              type = build_reference_type (p_build_type_variant (TREE_TYPE (val),
                       TYPE_READONLY (TREE_TYPE (type)),
                       TYPE_VOLATILE (TREE_TYPE (type))));
            }
          else if (TREE_CODE (val) == PASCAL_SET_CONSTRUCTOR
                   && TREE_CODE (TREE_TYPE (val)) == SET_TYPE)
            val = construct_set (val, NULL_TREE, 0);
          else if (TREE_CODE (val) == FUNCTION_DECL)
            val = build_routine_call (val, NULL_TREE);
          /* `const' string (or untyped) parameters are different from both
             `protected var' (they must accept values) and `protected' (they
             should be passed by reference if possible). */
          else if ((PASCAL_TYPE_VAL_REF_PARM (type) || const_parm)  && (!const_parm || !lvalue_p (val) || is_packed_field (val)))
            {
              tree temp_val = make_new_variable ("val_parm",
                     PASCAL_TYPE_STRING (TREE_TYPE (val))
                     ? (PASCAL_TYPE_DISCRIMINATED_STRING (TREE_TYPE (type)) ? TREE_TYPE (type) : build_pascal_string_schema (PASCAL_STRING_LENGTH (val)))  /* @@ kludge */
                     : TREE_TYPE (val));
              if (is_string_type (val, 0))
                {
                  expand_expr_stmt1 (assign_string (temp_val, val));
                  /* @@ Kludge (see "-> use type of actual parameter." above). (waldek11a.pas)
                        After dropping gcc-2, see if we can use variable-sized parameters instead. */
                  if (PASCAL_TYPE_VAL_REF_PARM (type) && PASCAL_TYPE_DISCRIMINATED_STRING (TREE_TYPE (type)))
                    expand_expr_stmt1 (build_modify_expr (build_component_ref (temp_val, get_identifier ("Capacity")), INIT_EXPR,
                      build_pascal_binary_op (MAX_EXPR, integer_one_node, PASCAL_STRING_LENGTH (temp_val))));
                }
              else if (PASCAL_TYPE_SCHEMA (TREE_TYPE (temp_val)))  /* don't dereference */
                {
                  tree t = build2 (MODIFY_EXPR, TREE_TYPE (temp_val),
                                   temp_val, val);
                  TREE_SIDE_EFFECTS (t) = 1;
                  expand_expr_stmt1 (t);
                }
              else
                expand_expr_stmt1 (build_modify_expr (temp_val, INIT_EXPR, val));
              if (TREE_CODE (val) == STRING_CST
                  && TREE_CODE (TREE_TYPE (type)) == ARRAY_TYPE
                  && TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_TYPE (type)))
                  && TREE_CODE (TYPE_SIZE (TREE_TYPE (type))) != INTEGER_CST)
                {
                  /* This is a string constant being passed to an "array of char" parameter of
                     variable size. Avoid "incompatible pointer type" warning ... */
                  type = build_reference_type (p_build_type_variant (TREE_TYPE (val),
                           TYPE_READONLY (TREE_TYPE (type)),
                           TYPE_VOLATILE (TREE_TYPE (type))));
                }
              val = temp_val;
            }
        }
  *tp = type;
  return val;
}

static tree
handle_typed_arg (tree type, tree val, struct argument_error_context * errc,
                  int const_parm)
{
  tree parmval;

  if (!TYPE_SIZE (type) && TREE_CODE (type) != VOID_TYPE)
    {
      argument_error ("type of formal parameter %d is incomplete", errc);
      parmval = val;
    }
  else
            {
              if (TREE_CODE (type) == REFERENCE_TYPE)  /* `var' parameter */
                {
                  /* Do about the same type checking like for pointers in convert_for_assignment(),
                     but produce an error message instead of a warning. */
                  int is_readonly = TYPE_READONLY (TREE_TYPE (type));
                  int val_ref_parm = PASCAL_TYPE_VAL_REF_PARM (type);
                  tree ttl = TREE_TYPE (type);
                  tree ttr = TREE_TYPE (val);
#undef SIMPLIFY_REFERENCES  /* Peter suggested this to simplify things, but it doesn't seem to work so easily. -- Frank */
#ifndef SIMPLIFY_REFERENCES
                  type = build_pointer_type (ttl);
#endif
                  if (is_packed_field (val))
                    {
                      argument_error ("packed fields may not be used as `var' parameters in argument %ld", errc);
                      return error_mark_node;
                    }
                  if (!(EM (ttr)
                        || TREE_CODE (ttr) == REFERENCE_TYPE
                        || TYPE_MAIN_VARIANT (ttl) == void_type_node
                        || TYPE_MAIN_VARIANT (ttr) == void_type_node
                        || (TYPE_MAIN_VARIANT (ttl) == ptr_type_node && TREE_CODE (ttr) == POINTER_TYPE)
                        || (TYPE_MAIN_VARIANT (ttr) == ptr_type_node && TREE_CODE (ttl) == POINTER_TYPE)
                        || (TREE_CODE (ttl) == FUNCTION_TYPE
                            && TYPE_MAIN_VARIANT (ttr) == ptr_type_node && integer_zerop (val))
                        || comp_target_types (type, build_pointer_type (ttr))
                        || comp_object_or_schema_pointer_types (ttl, ttr, 1)))
                    {
                      if (!(const_parm || lvalue_p (val)))
                        argument_error ("reference expected, value given in argument %ld", errc);
                      else 
                        argument_error ("type mismatch in argument %ld of %s", errc);
                      /* Avoid further warnings. */
                      return error_mark_node;
                    }

                  /* Passing a function result variable as a `var' parameter
                     (not `protected'/`const') can assign a value to it, so do
                     not warn about uninitialized function results afterwards.
                     (Not for procedural parameters -- these are represented
                     as REFERENCE_TYPE, but are like value parameters.)
                     `const' accepts values, `protected var' does not. */
                  if (!const_parm && TREE_CODE (ttl) != FUNCTION_TYPE && !check_reference_parameter (val, is_readonly))
                    return error_mark_node;

                  /* For untyped parameters, pass schemata including the discriminants. */
                  if (TREE_CODE (ttl) == VOID_TYPE)
                    val = undo_schema_dereference (val);

                  /* If the parameter is of REFERENCE_TYPE, we must
                     take the address of the actual parameter. */
#ifndef SIMPLIFY_REFERENCES
                  if (TREE_CODE (TREE_TYPE (val)) == REFERENCE_TYPE
                      && (comptypes (TREE_TYPE (type), TREE_TYPE (TREE_TYPE (val)))))
                    {
                      /* The parameter already is a reference type of
                         the correct type. Don't do anything serious. */
                      val = convert (type, val);
                    }
                  else if (TREE_CODE (ttl) == FUNCTION_TYPE
                           && TYPE_MAIN_VARIANT (ttr) == ptr_type_node
                           && integer_zerop (val))
                    {
                      chk_dialect ("passing `nil' as an actual parameter of procedural type is", B_D_M_PASCAL);
                      val = convert (type, val);
                    }
                  else
#endif
                    {
                      /* We have to take some effort to allow certain non-lvalues
                         (e.g. function results of string type) *if* the parameter
                         allows it (i.e., value or const/protected). */
                      if (const_parm || val_ref_parm)
                        {
                          tree stmts = NULL_TREE;
                          while (1)
                            if (TREE_CODE (val) == NOP_EXPR
                                || TREE_CODE (val) == CONVERT_EXPR
                                || TREE_CODE (val) == NON_LVALUE_EXPR)
                              val = TREE_OPERAND (val, 0);
                            else if (TREE_CODE (val) == COMPOUND_EXPR)
                              {
                                if (stmts)
                                  stmts = build2 (COMPOUND_EXPR,
                                                  void_type_node,
                                                  TREE_OPERAND (val, 0),
                                                  stmts);
                                else
                                  stmts = TREE_OPERAND (val, 0);
                                val = TREE_OPERAND (val, 1);
                              }
                            else
                              break;
                          if (TREE_CODE (val) == CALL_EXPR && mark_addressable (val))  /* fjf806e.pas */
                            val = build1 (ADDR_EXPR, build_pointer_type (TREE_TYPE (val)), val);
                          else
                            val = build_unary_op (ADDR_EXPR, val, 0);
                          if (stmts)
                            val = build2 (COMPOUND_EXPR, TREE_TYPE (val),
                                          stmts, val);
                        }
                      else
                        val = build_unary_op (ADDR_EXPR, val, 0);
#ifndef SIMPLIFY_REFERENCES
                      if (TREE_CODE (TREE_TYPE (type)) == POINTER_TYPE
                          && TREE_CODE (TREE_TYPE (TREE_TYPE (type))) == VOID_TYPE)
                        {
                          /* This is an untyped pointer reference parameter. */
                          if (TREE_CODE (TREE_TYPE (TREE_TYPE (val))) == POINTER_TYPE)
                            type = TREE_TYPE (val);
                        }
#endif
                    }
                }
#ifndef SIMPLIFY_REFERENCES
              else if (TREE_CODE (type) == POINTER_TYPE
                       && TYPE_MAIN_VARIANT (TREE_TYPE (type)) == void_type_node)
                {
                  /* Untyped pointer parameter (BP), accepts any pointer value as actual parameter. */
                  if (TREE_CODE (TREE_TYPE (val)) == POINTER_TYPE)
                    type = TREE_TYPE (val);
                }
#endif
              else if (TYPE_MAIN_VARIANT (type) == cstring_type_node)
                {
                  /* This is a CString parameter, which is a GPC extension
                     to make it easier to pass string types to C routines.
                     It accepts any string-type value as a parameter.

                     If the actual parameter is a STRING-TYPE value parameter (it cannot
                     be a CHAR_TYPE) the address of the string is passed, not the value!
                     Also, if it is of string schema type, the address of the character
                     store is passed, not the address of the string schema object. */
                  val = char_may_be_string (val);
                  if (is_string_type (val, 1))
                    val = convert_to_cstring (val);
                }
              else if (PASCAL_TYPE_OBJECT (type) && PASCAL_TYPE_OBJECT (TREE_TYPE (val))
                       && TYPE_MAIN_VARIANT (type) != TYPE_MAIN_VARIANT (TREE_TYPE (val)))
                {
                  /* Passing an object to a formal value parameter of parent type. */
                  tree temp_val = make_new_variable ("object_val_parm", type);
                  expand_expr_stmt1 (build_modify_expr (temp_val, INIT_EXPR, val));
                  val = temp_val;
                }

              parmval = convert_for_assignment (type, val, NULL, /* arg passing */ errc->fundecl, errc->parmnum);

#ifndef GCC_4_0
              if (PROMOTE_PROTOTYPES && ORDINAL_TYPE (TREE_CODE (type))
                  && (TYPE_PRECISION (type) < TYPE_PRECISION (integer_type_node)))
                parmval = default_conversion (parmval);
#endif
            }
  return parmval;
}

static tree
handle_vararg (tree val)
{
  tree result;
  if (TREE_CODE (TREE_TYPE (val)) == REAL_TYPE
      && (TYPE_PRECISION (TREE_TYPE (val)) < TYPE_PRECISION (double_type_node)))
    /* Convert `float' to `double'. */
    result = convert (double_type_node, val);
  else
        /* Varargs.
           Convert ordinal constants to integers.
           Convert short integers and fresh integer constants to `Integer'. */
    {
      val = string_may_be_char (val, 1);
      if (TREE_CODE (val) == INTEGER_CST)
        {
          if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (val))
              && PASCAL_CST_FRESH (val))
            val = convert (select_integer_type (val,
                             integer_zero_node, NOP_EXPR), val);
          if (TYPE_PRECISION (TREE_TYPE (val))
              < TYPE_PRECISION (integer_type_node))
            result = convert (integer_type_node, val);
          else
            result = val;
        }
      else if (TREE_CODE (val) == STRING_CST)
        result = build_pascal_unary_op (ADDR_EXPR, val);
      else
        result = default_conversion (val);
    }
  return result;
}


static tree
convert_one_arg (tree type, tree val, tree * last_valp, 
                 struct argument_error_context * errc, int conformal)
{
  tree partype = TREE_CODE (type) == REFERENCE_TYPE ? 
                    TREE_TYPE (type) : type;
  tree last_val = *last_valp;
  int const_parm = PASCAL_CONST_PARM (type);
  int is_schema = 0;
  int dummy;
  int var_parm = TREE_CODE (type) == REFERENCE_TYPE
                 && TREE_CODE (partype) != FUNCTION_TYPE
                 && !PASCAL_TYPE_VAL_REF_PARM (type)
                 && !PASCAL_CONST_PARM (type);

  if (EM (type))
    return error_mark_node;

  if ((PASCAL_TYPE_SCHEMA (partype)
                  || PASCAL_TYPE_STRING (partype)))
    {
      is_schema = 1;
      val = convert_schema (&type, val, last_val, var_parm);
      *last_valp = val;
    }
  if (!var_parm && TREE_CODE (partype) != FUNCTION_TYPE)
    val = probably_call_function (val);
  if (!is_schema)
    DEREFERENCE_SCHEMA (val);

  val = convert_arg1 (&type, val, errc, conformal, &dummy,
                        var_parm, const_parm);
  if (EM (val))
    return val;

  val = copy_val_ref_parm (&type, val, const_parm);

  gcc_assert (type);

  /* `var' parameters don't require a complete type. They may even
      be explicitly untyped. */

  if (TREE_CODE (type) != REFERENCE_TYPE)
    val = require_complete_type (val);

  return handle_typed_arg (type, val, errc, const_parm);
}

/* Reconstruct original argument section. We have:
   - optional conformal bounds 
        recognized using PASCAL_TYPE_CONFORMANT_BOUND
   - optional bound of dynamic arrays
        recognized using PASCAL_TYPE_OPEN_ARRAY  
   - main argument
   - optionally more arguments in the same section
        recognized using PASCAL_PAR_SAME_ID_LIST
*/

static tree
scan_section (tree types, tree * argtype, long *sec_cntp, long *bouns_cntp)
{
  tree type = NULL_TREE, nextt = NULL_TREE;
  *sec_cntp = 1;
  *bouns_cntp = 0;
  *argtype = 0;
  if (types)
    {
      * argtype = type = TREE_VALUE (types);
      nextt = TREE_CHAIN (types);
    }
  if (!type)
    return nextt;
  if (ORDINAL_TYPE (TREE_CODE (type)) && PASCAL_TYPE_CONFORMANT_BOUND (type))
    {
      tree type_scan = types, ttype;
      long conf_array_bounds = 0;
      while (type_scan)
        {
          ttype = TREE_VALUE (type_scan);

          if (TREE_CODE (ttype) == ARRAY_TYPE ||
              (TREE_CODE (ttype) == REFERENCE_TYPE 
               && TREE_CODE (TREE_TYPE (ttype)) == ARRAY_TYPE))
                    break;

          /* @@ Could check that PASCAL_TYPE_CONFORMANT_BOUND is set for all bounds */
          conf_array_bounds++;
          type_scan = TREE_CHAIN (type_scan);
        }
      gcc_assert (type_scan && !(conf_array_bounds & 1));
      gcc_assert (TREE_CODE (ttype) == REFERENCE_TYPE);
      nextt = TREE_CHAIN (type_scan);
      *bouns_cntp = conf_array_bounds;
      *argtype = ttype;
    }
  else if (PASCAL_TYPE_OPEN_ARRAY (type))
    {
      *bouns_cntp = 1;
      gcc_assert (nextt && TREE_VALUE (nextt));
      * argtype = TREE_VALUE (nextt);
      gcc_assert (TREE_CODE (*argtype) == REFERENCE_TYPE); 
      return TREE_CHAIN (nextt);
    }
  type = TREE_CODE (type) == REFERENCE_TYPE ? TREE_TYPE (type) : type;
  while (nextt && PASCAL_PAR_SAME_ID_LIST (nextt))
    {
      (*sec_cntp) ++;
      nextt = TREE_CHAIN (nextt);
    }
  return nextt;
}

static tree
convert_conformal (tree type, tree val, int var_param)
{
  gcc_assert (TREE_CODE (type) == ARRAY_TYPE);
  if (!var_param)
    val = probably_call_function (val);
  DEREFERENCE_SCHEMA (val);

  if (TREE_CODE (TREE_TYPE (val)) == ARRAY_TYPE)
    return val;


  if (!var_param && TYPE_IS_CHAR_TYPE (TREE_TYPE (type))
      && (PASCAL_TYPE_PACKED (type) 
          || !(co->pascal_dialect && !(co->pascal_dialect & (B_D_PASCAL))))
      && is_string_compatible_type (val, 0))
    val = new_string_by_model (
                build_pascal_string_schema (PASCAL_STRING_LENGTH (val)),                          val, 1);
  return val;
}

static tree
convert_bounds (tree typetail, tree argtype, tree val,
                struct argument_error_context * errc, long cnt)
{
  tree type = TREE_VALUE (typetail);
  tree atype = TREE_TYPE (val);
  tree dummy = NULL_TREE;
  int is_string = PASCAL_TYPE_STRING (atype);
  if (cnt == 1)
    /* Open arrays */
    {
      tree ival = NULL_TREE;

      if (is_string)
        ival = build_pascal_binary_op (MINUS_EXPR,
                 PASCAL_STRING_LENGTH (val), integer_one_node);
      /* Pointer as argument */
      else if (TREE_CODE (atype) == VOID_TYPE)
        ival = integer_zero_node;
      else if (TREE_CODE (atype) != ARRAY_TYPE)
        {
          error ("argument %ld does not match open array formal parameter");
          return error_mark_node;
        }
      else
        ival = build_pascal_binary_op (MINUS_EXPR,
                     convert (pascal_integer_type_node,
                                TYPE_MAX_VALUE (TYPE_DOMAIN (atype))),
                     convert (pascal_integer_type_node,
                                TYPE_MIN_VALUE (TYPE_DOMAIN (atype))));
      ival = convert_one_arg (type, ival, &dummy, errc, 0);
      return build_tree_list (NULL_TREE, ival);
    }
  else
   /* Conformant arrays */
    {
      int i;
      tree res = NULL_TREE;
      gcc_assert (!(cnt & 1));
      if (is_string)
        {
          tree bound;
          if (cnt != 2 || !comptypes (type, pascal_integer_type_node))
            {
              argument_error ("argument %ld does not match conformal array"
                       " formal parameter", errc);
              return error_mark_node;
            }
          bound = convert_one_arg (type, integer_one_node, &dummy, errc,
                                         0);
          res = build_tree_list (NULL_TREE, bound);
          bound = convert_one_arg (type, PASCAL_STRING_LENGTH (val),
                                     &dummy, errc, 0);
          res = tree_cons (NULL_TREE, bound, res);
        }
      else if (TREE_CODE (atype) == VOID_TYPE)
        {
          for (i = 0; i< cnt; i++)
            {
              res = tree_cons (NULL_TREE, TYPE_MIN_VALUE (type), res);
              typetail = TREE_CHAIN (typetail);
              type = TREE_VALUE (typetail);
            }
        }
      else 
        for (i = 0; i< cnt; i++)
          {
            tree bound, dtype;
            if (TREE_CODE (atype) != ARRAY_TYPE)
              {
                argument_error ("argument %d does not match conformal array"
                       " formal parameter", errc);
                return error_mark_node;
              }
            dtype = TYPE_DOMAIN (atype);
            if (!(i&1))
              bound = TYPE_MIN_VALUE (dtype);
            else 
              {
                bound = TYPE_MAX_VALUE (dtype);
                atype = TREE_TYPE (atype);
              }
            if (comptypes (type, dtype))
              {
                bound = convert_one_arg (type, bound, &dummy, errc,
                                         0);
                res = tree_cons (NULL_TREE, bound, res);
              }
            else
              {
                argument_error ("argument %d does not match conformal array"
                       " formal parameter", errc);
                return error_mark_node;
              }
            typetail = TREE_CHAIN (typetail);
            type = TREE_VALUE (typetail);
          }
      return res;
    }
}

/* Convert the argument expressions in the list VALUES
   to the types in the list TYPELIST. The result is a list of converted
   argument expressions. This is also where warnings about wrong number
   of args are generated.

   Pascal conformant array convention:

   An even number of array bounds are passed immediately preceding the
   conformant array parameter.
   The formal parameter decl TYPE nodes have the flag PASCAL_TYPE_CONFORMANT
   set if they are part of a conformant array parameter. One conformant array
   parameter consists of the indices, followed by one or more array_type
   parameters (value/var) that have the same indices and the same type.

   It is an error if the PASCAL_TYPE_CONFORMANT is set for other parameters
   or if the array parameter with this bit set is not preceded by
   another array with this bit set, or an even number of indices with
   this bit set. */

tree
convert_arguments (tree typelist, tree values, tree fundecl)
{
  tree typetail = typelist, valtail = values, result = NULL_TREE;
  long parmnum = !(fundecl && PASCAL_METHOD (fundecl));
  long sec_cnt = 0 ;
  int error_flag = 0;
  struct argument_error_context cur_errc;
  cur_errc.fundecl = fundecl;
  cur_errc.informed_decl = 0;
  cur_errc.parmnum = parmnum;
  for (valtail = values, typetail = typelist; valtail; )      
    {
      tree argtype, res1 = NULL_TREE, nextt;
      tree last_val = NULL_TREE;
      tree val = TREE_VALUE (valtail);
      long bounds_cnt;
      int var_parm;
      tree partype;
      /* Reconstruct Pascal parameter sections */
      nextt = scan_section (typetail, &argtype, &sec_cnt, &bounds_cnt);

      if (argtype == void_type_node)
        {
          argument_error ("too many (>%ld) arguments to routine %s", &cur_errc);
          break;
        }

      if (!argtype)
        {
          /* Varargs */
          while (valtail)
            {
              val = TREE_VALUE (valtail);
              /* Strip NON_LVALUE_EXPRs  */
              if (TREE_CODE (val) == NON_LVALUE_EXPR)
                val = TREE_OPERAND (val, 0);
              val = probably_call_function (val);
              val = require_complete_type (val);
              val = handle_vararg (val);
              if (error_flag || EM (val))
                error_flag = 1;
              else
                result = tree_cons (NULL_TREE, val, result);
              parmnum++;
              valtail = TREE_CHAIN (valtail);
            }
          gcc_assert(!typetail);
          sec_cnt = 0;
          break;
        }

      partype = TREE_CODE (argtype) == REFERENCE_TYPE ?
                TREE_TYPE (argtype) : argtype;
      var_parm = TREE_CODE (argtype) == REFERENCE_TYPE
                  && TREE_CODE (partype) != FUNCTION_TYPE
                  && !PASCAL_TYPE_VAL_REF_PARM (argtype)
                  && !PASCAL_CONST_PARM (argtype);

      if (bounds_cnt && !EM (val))
        {
          tree partype = TREE_CODE (argtype) == REFERENCE_TYPE ? 
                            TREE_TYPE (argtype) : argtype;
          val = convert_conformal (partype, val, var_parm);
          res1 = convert_bounds (typetail, argtype, val, &cur_errc, bounds_cnt);
          if (PASCAL_TYPE_STRING (TREE_TYPE (val)))
            val = PASCAL_STRING_VALUE (val);

          if (error_flag || EM (res1))
            error_flag = 1;
          else
            result = chainon (res1, result);
        }

      val = convert_one_arg (argtype, val, &last_val, &cur_errc, 
                             bounds_cnt);

      
      while (1)
        {
          if (error_flag || EM (val))
            error_flag = 1;
          else
            result = tree_cons (NULL_TREE, val, result);
          valtail = TREE_CHAIN (valtail);
          sec_cnt--;
          parmnum ++;
          cur_errc.parmnum = parmnum;
          if (!(sec_cnt > 0 && valtail))
            break;
          val = TREE_VALUE (valtail);
          if (bounds_cnt)
            {
              val = convert_conformal (partype, val, var_parm);
              if (PASCAL_TYPE_STRING (TREE_TYPE (val)))
                val = PASCAL_STRING_VALUE (val);
            }
          val = convert_one_arg (argtype, val, &last_val, &cur_errc, 
                                 bounds_cnt);
        }
      typetail = nextt;
    }
  if ((typetail && TREE_VALUE (typetail) != void_type_node)
      || sec_cnt > 0 )
    argument_error ("too few (%ld) arguments to function %s", &cur_errc);

  if (error_flag)
    return error_mark_node;

  return nreverse (result);
}


/* Return 0 if init is a valid initializer for type, nonzero otherwise. In fact
   the initializer is not only checked, but some conversions are done as well.
   init is a TREE_LIST whose TREE_VALUE is a component_value. A component_value
   is either an expression or a TREE_LIST (possibly empty);
   PASCAL_BP_INITIALIZER_LIST is set for initializers in `()'; for each element,
   the TREE_VALUE is a component_value and the TREE_PURPOSE is a TREE_LIST
   (empty if field names/array indicies are omitted); each element is of one of
   the following kinds (TREE_PURPOSE, TREE_VALUE):
   - (identifier, NULL_TREE)         record field or array index
   - (expression, NULL_TREE)         array index
   - (expression, expression)        array index range
   - (NULL_TREE, identifier)         `case identifier: expression of'
   - (NULL_TREE, integer_zero_node)  `case expression of'
   - (NULL_TREE, NULL_TREE)          `otherwise' */
int
check_pascal_initializer (tree type, tree init)
{
  tree link, field;

  if (!init || EM (init) || EM (type))
    return 0;  /* avoid further error messages */

  if (TREE_CODE (init) != TREE_LIST)
    return 1;

  while (PASCAL_TYPE_SCHEMA (type))
    type = TREE_TYPE (simple_get_field (schema_id, type, NULL));

  if (!TREE_VALUE (init))  /* empty initializer `()' */
    {
      chk_dialect ("initializers in `()' are", B_D_M_PASCAL);
      return !STRUCTURED_TYPE (TREE_CODE (type));
    }

  if (TREE_CODE (TREE_VALUE (init)) != TREE_LIST)
    return check_simple_pascal_initializer (init, type);

  /* Structured initializer. */
  if (TREE_CODE (type) == ARRAY_TYPE)
    {
      int borland_list = PASCAL_BP_INITIALIZER_LIST (TREE_VALUE (init));
      if (borland_list)
        chk_dialect ("initializers in `()' are", B_D_M_PASCAL);
      else
        chk_dialect ("initializers in `[]' are", E_O_PASCAL);
      for (link = TREE_VALUE (init); link; link = TREE_CHAIN (link))
        {
          tree index = TREE_PURPOSE (link), domain = TYPE_MAIN_VARIANT (TYPE_DOMAIN (type));
          if (!borland_list && !index)
            chk_dialect ("omitting indices in array initializers is",
                           B_D_M_PASCAL);
          while (index)
            {
              tree t = TREE_PURPOSE (index), t2 = TREE_VALUE (index);
              if (!t && TREE_VALUE (index))
                {
                  error ("`case' in array initializer");
                  return 1;
                }
              if (t && TREE_CODE (t) == IDENTIFIER_NODE)
                t = TREE_PURPOSE (index) = check_identifier (t);

              /* @@@@@ We should use only one piece of code to verify 
                 case-constant-list, so the code below should be common 
                 to initializers, variant records and case instruction. */

              if (t && TREE_CODE (t) == NON_LVALUE_EXPR)
                t = TREE_OPERAND (t, 0);
              if (t2 && TREE_CODE (t2) == NON_LVALUE_EXPR)
                t2 = TREE_OPERAND (t2, 0);

              if ((t && TREE_CODE (t) != INTEGER_CST) 
                  || (t2 && TREE_CODE (t2) != INTEGER_CST))
                {
                  error ("array indices in initializers must be constant");
                  return 1;
                }
              if ((t && EM (t)) || (t2 && EM (t2)))
                return 1;
              if ((t && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (t)), domain))
                  || (t2 && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (t2)), domain)))
                {
                  error ("type mismatch in array initializer index");
                  return 1;
                }
              index = TREE_CHAIN (index);
            }
          if (check_pascal_initializer (TREE_TYPE (type), link) != 0)
            return 1;
        }
      return 0;
    }

  /* Don't let strings be initialized field by field (Capacity, ...) */
  if (RECORD_OR_UNION (TREE_CODE (type)) && !PASCAL_TYPE_STRING (type))
    {
      if (PASCAL_BP_INITIALIZER_LIST (TREE_VALUE (init)))
        chk_dialect ("initializers in `()' are", B_D_M_PASCAL);
      else
        chk_dialect ("initializers in `[]' are", E_O_PASCAL);
      /* Insert `nil' for the VMT pointer (will be initialized, anyway). */
      if (PASCAL_TYPE_OBJECT (type))
        TREE_VALUE (init) = tree_cons (NULL_TREE, null_pointer_node, TREE_VALUE (init));
      field = TYPE_FIELDS (type);
      for (link = TREE_VALUE (init); link; link = TREE_CHAIN (link))
        {
          tree fieldtag = TREE_PURPOSE (link);
          if (fieldtag)
            {
              tree ftype = NULL_TREE;
              if (!TREE_PURPOSE (fieldtag))
                {
                  tree tag_info, sel_field;
                  if (!TREE_VALUE (fieldtag))
                    {
                      error ("`otherwise' in record initializer");
                      return 1;
                    }
                  if (!PASCAL_TYPE_VARIANT_RECORD (type))
                    {
                      error ("`case' in initializer of record without variant part");
                      return 1;
                    }
                  tag_info = TYPE_LANG_VARIANT_TAG (type);
                  sel_field = TREE_VALUE (TREE_PURPOSE (tag_info));
                  if (sel_field && TREE_CODE (sel_field) == FIELD_DECL)
                    {
                      if (TREE_CODE (TREE_VALUE (fieldtag)) != IDENTIFIER_NODE)
                        {
                          error ("missing tag field identifier in initializer");
                          return 1;
                        }
                      if (TREE_VALUE (fieldtag) != DECL_NAME (sel_field))
                        {
                          error ("invalid tag field in initializer");
                          return 1;
                        }
                    }
                  else if (TREE_VALUE (fieldtag) != integer_zero_node)
                    {
                      error ("unexpected tag field identifier in initializer");
                      return 1;
                    }
                  if (check_pascal_initializer (TREE_PURPOSE (TREE_PURPOSE (tag_info)), link))
                    return 1;
                  field = find_variant (TREE_VALUE (link), TREE_PURPOSE (TREE_VALUE (tag_info)));
                  if (!field)
                    return 1;
                  if (sel_field && TREE_CODE (sel_field) != FIELD_DECL
                      && find_variant (sel_field, TREE_PURPOSE (TREE_VALUE (tag_info))) != field)
                    {
                      error ("variants selected by discriminant and initializer do not match");
                      return 1;
                    }
                  type = TREE_TYPE (field);
                  field = TYPE_FIELDS (type);
                  continue;
                }
              while (fieldtag)
                {
                  if (TREE_VALUE (fieldtag) || TREE_CODE (TREE_PURPOSE (fieldtag)) != IDENTIFIER_NODE)
                    return 1;
                  field = find_field (type, TREE_PURPOSE (fieldtag), 2);
                  if (!field || (ftype && ftype != TYPE_MAIN_VARIANT (TREE_TYPE (field))))
                    return 1;
                  ftype = TYPE_MAIN_VARIANT (TREE_TYPE (field));
                  fieldtag = TREE_CHAIN (fieldtag);
                }
            }
          else
            chk_dialect ("omitting field names in initializers is", GNU_PASCAL);
          if (!field || check_pascal_initializer (TREE_TYPE (field), link) != 0)
            return 1;
          field = TREE_CHAIN (field);
        }
      return 0;
    }

  if (TREE_CODE (type) == SET_TYPE && !PASCAL_BP_INITIALIZER_LIST (TREE_VALUE (init)))
    {
      tree t = build_iso_set_constructor (type, TREE_VALUE (init), 1);
      if (EM (t))
        return 1;
      TREE_VALUE (init) = save_expr (t);
      return 0;
    }

  /* Simple type, structured initializer, wrong. */
  if (TREE_CHAIN (TREE_VALUE (init)) || TREE_PURPOSE (TREE_VALUE (init))
      || !PASCAL_BP_INITIALIZER_LIST (TREE_VALUE (init)))
    return 1;

  /* Simple type with initializer in parentheses.
     Remove the parentheses and check again. */
  TREE_VALUE (init) = TREE_VALUE (TREE_VALUE (init));
  return check_pascal_initializer (type, init);
}

static int
check_simple_pascal_initializer (tree init, tree type)
{
  /* Call functions without parameters. */
  if (TREE_CODE (type) != REFERENCE_TYPE || TREE_CODE (TREE_TYPE (type)) != FUNCTION_TYPE)
    TREE_VALUE (init) = probably_call_function (TREE_VALUE (init));

  /* Char constants. */
  if (TYPE_IS_CHAR_TYPE (type))
    TREE_VALUE (init) = string_may_be_char (TREE_VALUE (init), 1);

  /* Strings. */
  if (PASCAL_TYPE_STRING (type)
      && (TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_VALUE (init)))
          || (TREE_CODE (TREE_TYPE (TREE_VALUE (init))) == ARRAY_TYPE
              && TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_TYPE (TREE_VALUE (init)))))))
    {
      tree capacity = TYPE_LANG_DECLARED_CAPACITY (type);
      tree string_length = PASCAL_STRING_LENGTH (TREE_VALUE (init));

      if (!capacity || TREE_CODE (capacity) != INTEGER_CST)
        {
          error ("string capacity is not constant");
          TREE_VALUE (init) = error_mark_node;
          return 1;
        }

      /* Do some trivial range checking. */
      if (TREE_CODE (string_length) == INTEGER_CST && const_lt (capacity, string_length))
        {
          if (co->truncate_strings)
            pedwarn ("string constant exceeds capacity -- truncated");
          else
            error ("string constant exceeds capacity");
          /* Truncate the string. */
          if (integer_zerop (capacity))
            TREE_VALUE (init) = empty_string_node;
          else if (TREE_CODE (TREE_VALUE (init)) == STRING_CST)
            {
            TREE_VALUE (init) = build_string_constant (TREE_STRING_POINTER (TREE_VALUE (init)),
              TREE_INT_CST_LOW (capacity), PASCAL_CST_FRESH (TREE_VALUE (init)));
              set_string_length (TREE_VALUE (init), 0, TREE_INT_CST_LOW (capacity) + 1);
            }
          else
            {
              /* We can't get here with char constants! */
              tree min = TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (TREE_VALUE (init))));
              TREE_VALUE (init) = build_array_slice_ref (TREE_VALUE (init), min,
                fold (build_pascal_binary_op (MINUS_EXPR, build_pascal_binary_op (PLUS_EXPR, min, capacity), integer_one_node)));
            }
          string_length = capacity;
        }
      else if (TREE_CODE (TREE_VALUE (init)) == STRING_CST)
        {
          set_string_length (TREE_VALUE (init), 0, TREE_INT_CST_LOW (capacity) + 1);
        }
      else if (TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_VALUE (init))))
        /* convert char to string: [1: char-value; 2 .. Capacity + 1: Chr (0)] */
        TREE_VALUE (init) = tree_cons (build_tree_list (integer_one_node, NULL_TREE), TREE_VALUE (init),
          build_tree_list (build_tree_list (build_int_2 (2, 0),
            fold (build_pascal_binary_op (PLUS_EXPR, capacity, integer_one_node))),
            convert (char_type_node, integer_zero_node)));

      /* @@ backend doesn't like array slices, so initialize char by char (gross!) */
      if (TREE_CODE (TREE_VALUE (init)) != TREE_LIST
          && TREE_CODE (TREE_VALUE (init)) != STRING_CST
          && !TYPE_IS_CHAR_TYPE (TREE_TYPE (TREE_VALUE (init))))
        {
          tree t = NULL_TREE, v = save_expr (TREE_VALUE (init));
          unsigned int i;
          for (i = TREE_INT_CST_LOW (capacity) + 1; i >= 1; i--)
            t = tree_cons (build_tree_list (build_int_2 (i, 0), NULL_TREE),
              i == TREE_INT_CST_LOW (capacity) + 1 ? convert (char_type_node, integer_zero_node)
              : build_array_ref (v, fold (build_pascal_binary_op (PLUS_EXPR,
                  TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (v))), build_int_2 (i - 1, 0)))), t);
          TREE_VALUE (init) = t;
        }

      /* A string schema is a record. Initialize it as such. */
      TREE_VALUE (init) = tree_cons (NULL_TREE, capacity,
        tree_cons (NULL_TREE, string_length,
        build_tree_list (NULL_TREE, TREE_VALUE (init))));
      return 0;
    }

  if (TREE_CODE (type) == ARRAY_TYPE
      && TYPE_MAIN_VARIANT (TREE_TYPE (type)) == char_type_node
      && IS_STRING_CST (TREE_VALUE (init)))
    {
      /* Initializing an array of char with a string constant.
         Make the length match by either cutting or padding with blanks.
         @@ Or else we can append a `Chr (0)' => ternary switch. */
      tree capacity = fold (build_pascal_binary_op (PLUS_EXPR,
        build_pascal_binary_op (MINUS_EXPR,
          convert (pascal_integer_type_node, TYPE_MAX_VALUE (TYPE_DOMAIN (type))),
          convert (pascal_integer_type_node, TYPE_MIN_VALUE (TYPE_DOMAIN (type)))), integer_one_node));
      TREE_VALUE (init) = char_may_be_string (TREE_VALUE (init));
      if (TREE_CODE (capacity) == INTEGER_CST)
        {
          if ((unsigned) TREE_STRING_LENGTH (TREE_VALUE (init))
              <= (unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (capacity))
            {
              char *buffer = alloca (TREE_INT_CST_LOW (capacity) + 1), *p;
              unsigned len = TREE_STRING_LENGTH (TREE_VALUE (init)) - 1;
              memcpy (buffer, TREE_STRING_POINTER (TREE_VALUE (init)), len);
              for (p = buffer + len; p < buffer + (unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (capacity); p++)
                *p = ' ';
              *p = 0;
              TREE_VALUE (init) = build_string (TREE_INT_CST_LOW (capacity), buffer);
              TREE_TYPE (TREE_VALUE (init)) = type;
            }
          else
            {
              if ((unsigned) TREE_STRING_LENGTH (TREE_VALUE (init)) - 1
                  > (unsigned HOST_WIDE_INT) TREE_INT_CST_LOW (capacity))
                {
                  if (co->truncate_strings)
                    pedwarn ("string constant exceeds capacity -- truncated");
                  else
                    error ("string constant exceeds capacity");
                }
              TREE_VALUE (init) = build_string_constant (TREE_STRING_POINTER (TREE_VALUE (init)),
                TREE_INT_CST_LOW (capacity), PASCAL_CST_FRESH (TREE_VALUE (init)));
            }
        }
      return 0;
    }

  if (TYPE_MAIN_VARIANT (type) == cstring_type_node)
    {
      TREE_VALUE (init) = char_may_be_string (TREE_VALUE (init));
      if (is_string_type (TREE_VALUE (init), 0))
        {
          /* Initializing a `CString' with a string value. Let the `CString' variable point to it. */
          TREE_VALUE (init) = convert (cstring_type_node,
            build_pascal_unary_op (ADDR_EXPR, PASCAL_STRING_VALUE (TREE_VALUE (init))));
          return 0;
        }
      /* Pointers to strings used as CStrings. */
#if 1
      if (TREE_CODE (TREE_VALUE (init)) == ADDR_EXPR)
        {
          tree s = TREE_OPERAND (TREE_VALUE (init), 0);
          if (TREE_CODE (s) == VAR_DECL && TREE_READONLY (s)
              && DECL_INITIAL (s)
              && TREE_CODE (DECL_INITIAL (s)) == CONSTRUCTOR
              && PASCAL_TYPE_DISCRIMINATED_STRING (
                   TREE_TYPE (DECL_INITIAL (s))))
            {
              int constant = TREE_CONSTANT (TREE_VALUE (init));
#ifndef GCC_4_1
              tree t = CONSTRUCTOR_ELTS (DECL_INITIAL (s));
              TREE_VALUE (init) = build1 (ADDR_EXPR, cstring_type_node,
                  TREE_VALUE (TREE_CHAIN (TREE_CHAIN (t))));
#else
              VEC(constructor_elt,gc) *elts = CONSTRUCTOR_ELTS (
                                                    DECL_INITIAL (s));
              TREE_VALUE (init) = build1 (ADDR_EXPR, cstring_type_node,
                  VEC_index (constructor_elt, elts, 2)->value);
#endif
              TREE_CONSTANT (TREE_VALUE (init)) = constant;
              return 0;
            }
        }
#else
      if (TREE_CODE (TREE_VALUE (init)) == ADDR_EXPR
          && TREE_CODE (TREE_OPERAND (TREE_VALUE (init), 0)) == CONSTRUCTOR
          && PASCAL_TYPE_DISCRIMINATED_STRING (TREE_TYPE (TREE_OPERAND (TREE_VALUE (init), 0))))
        {
          int constant = TREE_CONSTANT (TREE_VALUE (init));
#ifndef GCC_4_1
          tree t = CONSTRUCTOR_ELTS (TREE_OPERAND (TREE_VALUE (init), 0));
          TREE_VALUE (init) = build1 (ADDR_EXPR, cstring_type_node,
            TREE_VALUE (TREE_CHAIN (TREE_CHAIN (t))));
#else
          VEC(constructor_elt,gc) *elts = CONSTRUCTOR_ELTS (
                      TREE_OPERAND (TREE_VALUE (init), 0));
          TREE_VALUE (init) = build1 (ADDR_EXPR, cstring_type_node,
            VEC_index (constructor_elt, elts, 2)->value);
#endif
          TREE_CONSTANT (TREE_VALUE (init)) = constant;
          return 0;
        }
#endif
    }

  /* Procedural variables. (Pointers to routines should cause no problems.) */
  if (TREE_CODE (type) == REFERENCE_TYPE
      && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE
      && TREE_CODE (TREE_VALUE (init)) == CALL_EXPR
#ifndef GCC_4_3
      && !TREE_OPERAND (TREE_VALUE (init), 1)
#else
      &&  call_expr_nargs (TREE_VALUE (init)) == 0
#endif
     )
    {
      tree op = CALL_EXPR_FN (TREE_VALUE (init));
      if (TREE_CODE (op) == ADDR_EXPR)
        /* Set TREE_CONSTANT correctly, mark_addressable, etc. */
        op = build_pascal_address_expression (TREE_OPERAND (op, 0), 0);
      TREE_VALUE (init) = convert (type, op);
      return 0;
    }

  /* Sets. */
  if (TREE_CODE (TREE_VALUE (init)) == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (TREE_TYPE (TREE_VALUE (init))) == SET_TYPE
      && TREE_CODE (type) == SET_TYPE
      && TREE_TYPE (TREE_VALUE (init)) == empty_set_type_node)
    {
      /* The type of the set constructor was not known to the parser.
         Specify it now, but check it first. */
      tree elements = SET_CONSTRUCTOR_ELTS (TREE_VALUE (init));
      if (elements && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (TREE_PURPOSE (elements))),
                                  TYPE_MAIN_VARIANT (TREE_TYPE (type))))
        return 1;
      TREE_VALUE (init) = copy_node (TREE_VALUE (init));
      TREE_TYPE (TREE_VALUE (init)) = type;
      return 0;
    }

  /* Conformant arrays. */
  if (PASCAL_TYPE_CONFORMANT_ARRAY (type) && comptypes (type, TREE_VALUE (init)))
    return 0;

  /* Normal initialization. This is just a special case of an assignment. */
  TREE_VALUE (init) = convert_for_assignment (type, TREE_VALUE (init), "initialization", NULL_TREE, 0);
  return TREE_CODE (TREE_TYPE (TREE_VALUE (init))) != TREE_CODE (type);
}

/* Schema handling */
#if 0

/* Returns 1 if expr is the CONVERT_EXPR representing an unresolved
   schema discriminant belonging to one of the given fields. */
static int
is_discriminant_of (tree expr, tree fields)
{
  tree field, fix;
  for (field = fields; field; field = TREE_CHAIN (field))
    if (PASCAL_TREE_DISCRIMINANT (field))
      for (fix = DECL_LANG_FIXUPLIST (field); fix; fix = TREE_CHAIN (fix))
        if (TREE_VALUE (fix) == expr)
          return 1;
  return 0;
}
#endif

/* Returns 1 if type_or_expr contains somewhere in it an unresolved
   schema discriminant. If fields is NULL, any discriminant is
   recognized, otherwise only those belonging to the given fields. */
int
contains_discriminant (tree type_or_expr, tree fields)
{
  enum tree_code code = TREE_CODE (type_or_expr);
  gcc_assert (!fields || TREE_CODE_CLASS TREE_CODE ((fields)) == tcc_type);
  switch (code)
  {
    case ERROR_MARK:
      return 0;

    case COMPONENT_REF:
      {
        tree op0 = TREE_OPERAND (type_or_expr, 0);
        if (TREE_CODE (op0) == PLACEHOLDER_EXPR)
           return !fields || TREE_TYPE (op0) == fields;
        break; /* Check operand below */
      }

    case VAR_DECL:
#if 1
      return 0;
#else
      if (PASCAL_TREE_DISCRIMINANT (type_or_expr))
        {
          tree field;
          if (!fields)
            return 1;
          for (field = fields; field; field = TREE_CHAIN (field))
            if (field == type_or_expr)
              return 1;
        }
      break;

    case CONVERT_EXPR:
      if (PASCAL_TREE_DISCRIMINANT (type_or_expr)
          && (!fields || is_discriminant_of (type_or_expr, fields)))
        return 1;
      break;  /* Check operand below */
#endif

    case BOOLEAN_TYPE:
#ifndef GCC_4_2
    case CHAR_TYPE:
#endif
    case ENUMERAL_TYPE:
    case INTEGER_TYPE:
      return    contains_discriminant (TYPE_MIN_VALUE (type_or_expr), fields)
             || contains_discriminant (TYPE_MAX_VALUE (type_or_expr), fields)
             || (TREE_TYPE (type_or_expr) && contains_discriminant (TREE_TYPE (type_or_expr), fields));

    case ARRAY_TYPE:
      return    contains_discriminant (TYPE_DOMAIN (type_or_expr), fields)
             || contains_discriminant (TREE_TYPE (type_or_expr), fields);

    case RECORD_TYPE:
    case UNION_TYPE:
      if (PASCAL_TYPE_STRING (type_or_expr) && TYPE_LANG_DECLARED_CAPACITY (type_or_expr))
        return contains_discriminant (TYPE_LANG_DECLARED_CAPACITY (type_or_expr), fields);
      else
        {
          tree field;
          if (PASCAL_TYPE_VARIANT_RECORD (type_or_expr)
              && TREE_VALUE (TREE_PURPOSE (TYPE_LANG_VARIANT_TAG (type_or_expr)))
              && contains_discriminant (TREE_VALUE (TREE_PURPOSE (TYPE_LANG_VARIANT_TAG (type_or_expr))), fields))
            return 1;
          for (field = TYPE_FIELDS (type_or_expr); field; field = TREE_CHAIN (field))
            if (contains_discriminant (TREE_TYPE (field), fields))
              return 1;
            /* If this field is itself a discriminant, that's no reason yet to return 1.
               But if it has been discriminated, and the actual discriminant is another
               discriminant (of an outer schema), we have to detect this. (emil19*.pas) */
            else if (PASCAL_TREE_DISCRIMINANT (field)
                     && DECL_LANG_FIXUPLIST (field)
                     && TREE_CODE (DECL_LANG_FIXUPLIST (field)) != TREE_LIST
                     && contains_discriminant (DECL_LANG_FIXUPLIST (field), fields))
              return 1;
        }
      break;

#ifndef GCC_4_0
    case RTL_EXPR:
      return 0;
#endif

    case TREE_LIST:
      {
        tree t;
        for (t = type_or_expr; t; t = TREE_CHAIN (t))
          if ((TREE_VALUE (t) && contains_discriminant (TREE_VALUE (t), fields))
              || (TREE_PURPOSE (t) && contains_discriminant (TREE_PURPOSE (t), fields)))
            return 1;
        return 0;
      }

    default:
      break;
  }

  if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (type_or_expr, i) && contains_discriminant (TREE_OPERAND (type_or_expr, i), fields))
          return 1;
    }
  return 0;
}

#if 1
/* fold() doesn't know about our Boolean constants and constant array references.
   Important: Do this *after* folding the operands! */
static tree
pascal_fold (tree expr)
{
  enum tree_code code = TREE_CODE (expr);
  tree res;
  if ((code == NON_LVALUE_EXPR || code == CONVERT_EXPR || code == NOP_EXPR)
      && TREE_CODE (TREE_TYPE (expr)) == BOOLEAN_TYPE)
    {
      tree op = TREE_OPERAND (expr, 0);
      if (integer_zerop (op))
        return boolean_false_node;
      else if (integer_onep (op))
        return boolean_true_node;
    }
#if 0
  if (TREE_CODE (expr) == ARRAY_REF)
    return fold_array_ref (expr);
  return fold (expr);
#else
  if (TREE_CODE (expr) == ARRAY_REF)
    res = fold_array_ref (expr);
  else
    res = fold (expr);
  if (TREE_CODE (res) == INTEGER_CST)
    {
      res = copy_node (res);
    }
  return res;
#endif
}

/* fold() doesn't fold constants below (one or several) CONVERT_EXPR's
   and NOP_EXPR's that actually change the type. I guess that's because
   this normally never occurs because they're avoided during the
   construction. But it does happen if build_discriminated_schema_type()
   puts the actual discriminant values in the middle of an already
   constructed expression. So we must call fold() on each part of the
   expression, and we must do the folding bottom up, i.e. call fold() at
   the end, not at the beginning. @@ That's kind of a kludge. -- Frank
   p_foreign_discr is used to pass information about foreign discriminants
   up the recursion levels (but not down -- the local variable foreign_discr
   prevents this!). p_foreign_discr can be NULL, otherwise the variable it
   points to must have been initialized.
   This function is slightly tricky. ;-) */
#endif

static tree
re_fold (tree expr, tree stype, tree fields, int *p_foreign_discr)
{
  enum tree_code code = TREE_CODE (expr);
//  int foreign_discr = 0;
  CHK_EM (expr);

  if (code == COMPONENT_REF)
    {
       tree op0 = TREE_OPERAND (expr, 0);
       tree field = TREE_OPERAND (expr, 1);
       tree nf = fields;
       if (TREE_CODE (op0) == PLACEHOLDER_EXPR && TREE_TYPE (op0) == stype)
         /* Substitute value */
         {
           tree val;
           while (nf && TREE_PURPOSE (nf) != field)
           nf = TREE_CHAIN (nf);
           gcc_assert (nf);
           val = TREE_VALUE (nf);
           gcc_assert (TREE_CODE (val) != FUNCTION_DECL);
           if (TREE_CODE (val) != VAR_DECL)
             val = copy_node (val);
           return pascal_fold (re_fold (val,
                             stype, fields, p_foreign_discr));
         }
       if (TREE_CODE (op0) == PLACEHOLDER_EXPR && p_foreign_discr)
         *p_foreign_discr = 1;
    }
#if 0
  if (code == CONVERT_EXPR && PASCAL_TREE_DISCRIMINANT (expr))
    {
      if (!is_discriminant_of (expr, fields))
        /* The expr is a "foreign" discriminant (of an outer schema type).
           Don't fold it, which might destroy its placeholder. Also
           don't fold the expressions containing it. */
        foreign_discr = 1;
      else
        {
          /* This is our discriminant. */
          expr = copy_node (expr);
          CHK_EM (TREE_OPERAND (expr, 0) = re_fold (TREE_OPERAND (expr, 0), fields, &foreign_discr));
          /* Don't fold it if it contains a foreign discriminant. But
             clear the PASCAL_TREE_DISCRIMINANT flag to signal that our
             discrimination is done, so that the discrimination of the
             outer schema will not be stopped by the current one. (Clear
             the flag in any case -- if there's no foreign discriminant,
             pascal_fold() will probably throw away this CONVERT_EXPR, anyway,
             but if not, it's not a discriminant anymore.) */
          PASCAL_TREE_DISCRIMINANT (expr) = 0;
          if (!foreign_discr)
            return pascal_fold (expr);
        }
    }
  else 
#endif
  if (code == SAVE_EXPR)
    /* Copying a SAVE_EXPR is no good idea. ;-) Therefore, we can't
       modify its fields, i.e., we can't fold below it. This should only
       happen in `New' (hopefully) when it doesn't matter that the type
       can't be folded completely. */
    {
      if (contains_discriminant (expr, stype))
        gcc_unreachable ();
    }
  else if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      expr = copy_node (expr);
      for (i = FIRST_OPERAND (code); i < l; i++)
        if (TREE_OPERAND (expr, i))
          CHK_EM (TREE_OPERAND (expr, i) = re_fold (TREE_OPERAND (expr, i), stype, fields, p_foreign_discr));
        return pascal_fold (expr);
    }
  else if (code == TREE_LIST)
    {
      tree t;
      expr = copy_list (expr);
      for (t = expr; t; t = TREE_CHAIN (t))
        {
          if (TREE_VALUE (t))
            CHK_EM (TREE_VALUE (t) = re_fold (TREE_VALUE (t), stype, fields, p_foreign_discr));
          if (TREE_PURPOSE (t))
            CHK_EM (TREE_PURPOSE (t) = re_fold (TREE_PURPOSE (t), stype, fields, p_foreign_discr));
        }
    }
  return expr;
}

#if 1

/* Recursive subroutine of build_discriminated_schema_type:
   Re-build a type with actual discriminants replacing the formal ones. */
static tree
re_layout_type (tree type, tree stype, tree fields)
{
  int was_packed = PASCAL_TYPE_PACKED (type);

  /* This check (to avoid re-layouting those parts of a schema type
     that don't depend on the discriminants) is not only made for
     efficiency, it also prevents the creation of incompatible types
     (fjf590.pas). */
  if (!contains_discriminant (type, stype))
    return build_type_copy (type);

  CHK_EM (type);
  switch (TREE_CODE (type))
  {
    case BOOLEAN_TYPE:
#ifndef GCC_4_2
    case CHAR_TYPE:
#endif
    case ENUMERAL_TYPE:
    case INTEGER_TYPE:
      {
        int foreign_discr_min = 0, foreign_discr_max = 0;
        type = build_type_copy (type);
        copy_type_lang_specific (type);
        new_main_variant (type);

        CHK_EM (TYPE_MIN_VALUE (type) = re_fold (TYPE_MIN_VALUE (type), stype, fields, &foreign_discr_min));
        CHK_EM (TYPE_MAX_VALUE (type) = re_fold (TYPE_MAX_VALUE (type), stype, fields, &foreign_discr_max));

        /* size_volatile >= 2: prediscriminating (kludge?) */
        if (size_volatile < 2 && !foreign_discr_min && !foreign_discr_max && !check_subrange (TYPE_MIN_VALUE (type), TYPE_MAX_VALUE (type)))
          {
            error (" actual schema discriminant has invalid value");
            return error_mark_node;
          }

        /* Convert the min and max values to their actual type (so, e.g.,
           the size won't change), but not if they still contain another
           discriminant because converting might lose it. */
        if (!foreign_discr_min)
          TYPE_MIN_VALUE (type) = convert (type, TYPE_MIN_VALUE (type));
        if (!foreign_discr_max)
          TYPE_MAX_VALUE (type) = convert (type, TYPE_MAX_VALUE (type));

        /* Subrange type. */
        if (TREE_TYPE (type))
          CHK_EM (TREE_TYPE (type) = re_layout_type (TREE_TYPE (type), stype, fields));

        if (TYPE_PRECISION (type) < TYPE_PRECISION (TREE_TYPE (TYPE_MAX_VALUE (type))))
          TYPE_PRECISION (type) = TYPE_PRECISION (TREE_TYPE (TYPE_MAX_VALUE (type)));
        if (TYPE_PRECISION (type) < TYPE_PRECISION (TREE_TYPE (TYPE_MIN_VALUE (type))))
          TYPE_PRECISION (type) = TYPE_PRECISION (TREE_TYPE (TYPE_MIN_VALUE (type)));
#ifdef GCC_4_0
        TYPE_CACHED_VALUES_P (type) = 0;
        TYPE_CACHED_VALUES (type) = NULL_TREE;
#endif
        break;
      }
    case ARRAY_TYPE:
      type = build_simple_array_type (
               re_layout_type (TREE_TYPE (type), stype, fields),
               re_layout_type (TYPE_DOMAIN (type), stype, fields));
      CHK_EM (type);
      break;
    case RECORD_TYPE:
    case UNION_TYPE:
      if (PASCAL_TYPE_STRING (type))
        {
          tree capacity = TYPE_LANG_DECLARED_CAPACITY (type);
          int dummy = 0;
          if (capacity)
            CHK_EM (type = build_pascal_string_schema (
                  re_fold (capacity, stype, fields, &dummy)));
          break;
        }
      else
        {
          tree field, new_field, old_fields = TYPE_FIELDS (type);
          tree new_fields = NULL_TREE;
          tree old_type = type;
          struct lang_type *lang_specific = TYPE_LANG_SPECIFIC (type);
          int iv = PASCAL_TYPE_INITIALIZER_VARIANTS (type);
#ifndef EGCS97
          int mom = suspend_momentary ();
#endif
          int save_defining_packed_type;
          for (field = old_fields; field; field = TREE_CHAIN (field))
            {
              tree f = build_field (DECL_NAME (field),
                  re_layout_type (TREE_TYPE (field), stype, fields));
              CHK_EM (f);
              new_fields = chainon (new_fields, f);
            }
#ifndef EGCS97
          resume_momentary (mom);
#endif
          save_defining_packed_type = defining_packed_type;
          defining_packed_type = TYPE_PACKED (type);
          type = finish_struct (start_struct (TREE_CODE (type)), new_fields, 1);
          defining_packed_type = save_defining_packed_type;
          PASCAL_TYPE_INITIALIZER_VARIANTS (type) = iv;

          TYPE_LANG_SPECIFIC (type) = lang_specific;
          copy_type_lang_specific (type);
          sort_fields (type);

          if (PASCAL_TYPE_VARIANT_RECORD (type))
            {
              tree tag = TYPE_LANG_VARIANT_TAG (type), t = TREE_VALUE (TREE_PURPOSE (tag));
              if (t)
                {
                  int dummy;
                  t = re_fold (t, stype, fields, &dummy);
                  CHK_EM (t);
                  TYPE_LANG_VARIANT_TAG (type) = build_tree_list (
                    build_tree_list (TREE_PURPOSE (TREE_PURPOSE (tag)), t), TREE_VALUE (tag));
                }
            }

          /* Care for possible actual discriminants of inner schema types
             which may be expressions containing this schema's formal
             discriminants. @@ Top-level discriminants seem to be destroyed
             here and restored later in build_discriminated_schema_type() --
             is this good?
             First check whether we're at the main schema's record or a field
             which is a schema. @@ This check is a little dirty because it
             compares old_fields (former TYPE_FIELDS of the current type) with
             the fields parameter which refers to the main record's fields,
             but is actually passed for other purposes. But doing it like this
             saves us from passing another parameter through the recursion. */
#if 0
          if (old_fields != fields && PASCAL_TYPE_SCHEMA (type))
#else
          if (TYPE_MAIN_VARIANT (old_type) != stype 
               && PASCAL_TYPE_SCHEMA (type))
#endif
            for (field = old_fields, new_field = TYPE_FIELDS (type);
                 field && new_field;
                 field = TREE_CHAIN (field), new_field = TREE_CHAIN (new_field))
              if (PASCAL_TREE_DISCRIMINANT (field))
                {
                  /* Inner schemata must have been (formally) discriminated
                     before, i.e. PASCAL_TREE_DISCRIMINANT contains the
                     discriminant's initializer now. */
                  int dummy;
                  tree fixup = DECL_LANG_FIXUPLIST (field);
                  gcc_assert (fixup && TREE_CODE (fixup) != TREE_LIST);
                  PASCAL_TREE_DISCRIMINANT (new_field) = 1;
                  gcc_assert (!DECL_LANG_SPECIFIC (new_field));
                  allocate_decl_lang_specific (new_field);
                  CHK_EM (DECL_LANG_FIXUPLIST (new_field) = 
                    re_fold (fixup, stype, fields, &dummy));
                }
          break;
        }

    default:
      /* Nothing to re-layout (yet).
         (No need to re-layout a pointer or reference target.)
         contains_discriminant() should not have found such types */
      gcc_unreachable ();
      break;
  }

  TYPE_SIZE (type) = NULL_TREE;
  layout_type (type);

  if (was_packed)
    type = pack_type (type);

  return type;
}
#endif

/* Return a discriminated schema type derived from TYPE (which must
   be a schema type as returned by build_schema_type) using the
   actual discriminants held in the tree list DISCRIMINANTS. */
tree
build_discriminated_schema_type (tree type, tree discriminants, int prediscriminating)
{
  tree type_template = type, field, disc, fix;
  tree fix_list = NULL_TREE;
#ifndef EGCS97
  struct obstack *ambient_obstack;
#endif

  CHK_EM (type);
  if (PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
    {
      tree val = TREE_VALUE (discriminants);
      /* Strings are a special case. */
      if (TREE_CHAIN (discriminants))
        error ("too many discriminants for string schema");
      if (TREE_CODE (val) == INTEGER_CST
          && !INT_CST_LT (integer_zero_node, val))
        error ("string capacity must be > 0");
      if (!prediscriminating)
        val = save_nonconstants (val);
      return build_pascal_string_schema (val);
    }
  else if (!PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
    {
      error ("discriminated type is not a schema or string");
      return type;
    }

#ifndef EGCS97
  ambient_obstack = current_obstack;
  current_obstack = TYPE_OBSTACK (type);
#endif

  size_volatile++;

  for (field = TYPE_FIELDS (type_template), disc = discriminants;
       field && disc;
       field = TREE_CHAIN (field), disc = TREE_CHAIN (disc))
    {
      tree val = string_may_be_char (TREE_VALUE (disc), 0);
      if (!prediscriminating)
        val = save_nonconstants (val);
      TREE_VALUE (disc) = val;
      val = convert_for_assignment (TREE_TYPE (field), val, "schema discrimination", NULL_TREE, 0);

#if 0
      for (fix = DECL_LANG_FIXUPLIST (field); fix; fix = TREE_CHAIN (fix))
        {
          tree target = TREE_VALUE (fix);
          /* @@@@ We do all changes on the type template, lay out a copy,
             and finally restore the template. This is a kludge.
             It would be better to create the copy *without* modifying
             the template.
             Remember the old value of this to set it back after
             re_layout_type() has done its job. */
          gcc_assert (TREE_CODE (target) == CONVERT_EXPR && PASCAL_TREE_DISCRIMINANT (target));
          TREE_PURPOSE (fix) = TREE_OPERAND (target, 0);
          TREE_OPERAND (target, 0) = val;
        }
#else
    fix_list = tree_cons (field, val, fix_list);
#endif
  }
  fix_list = nreverse (fix_list);
  
  if (!field || DECL_NAME (field) != schema_id || disc)
    error ("number of discriminants does not match schema declaration");

  type = re_layout_type (type, TYPE_MAIN_VARIANT (type), fix_list);
  CHK_EM (type);

  TYPE_LANG_SPECIFIC (type) = TYPE_LANG_SPECIFIC (type_template);
  copy_type_lang_specific (type);
  sort_fields (type);

  if (TYPE_LANG_INITIAL (type))
    {
      int dummy;
      tree t = re_fold (TYPE_LANG_INITIAL (type), 
                         TYPE_MAIN_VARIANT (type_template), fix_list, &dummy);
      CHK_EM (t);
#if 0
      /* The check is useless (we already checked the initializer)
         and harmful (velo1.pas) */
      if (check_pascal_initializer (type, t))
        {
          error ("initial value of discriminated schema type is of wrong type");
          t = error_mark_node;
        }
#endif
      TYPE_LANG_INITIAL (type) = t;
    }

  /* If the schema depends on the discriminants only to a small
     extent or not at all, re_layout_type() may have gotten away
     with build_type_copy() only, and this doesn't change
     TYPE_MAIN_VARIANT, so we change it explicitly. */
  if (TYPE_MAIN_VARIANT (type) == TYPE_MAIN_VARIANT (type_template))
    new_main_variant (type);

#if 0
  /* Restore the type template for future use. */
  for (field = TYPE_FIELDS (type_template); field; field = TREE_CHAIN (field))
    if (PASCAL_TREE_DISCRIMINANT (field))
      for (fix = DECL_LANG_FIXUPLIST (field); fix; fix = TREE_CHAIN (fix))
        {
          TREE_OPERAND (TREE_VALUE (fix), 0) = TREE_PURPOSE (fix);
          TREE_PURPOSE (fix) = NULL_TREE;
        }
#endif

  CHK_EM (type);

  /* Store the values in the new type instead of the fixup-list.
     This is needed in init_any() to initialize these fields. But copy
     the list first, otherwise we'd overwrite it in the template. */
  TYPE_FIELDS (type) = copy_list (TYPE_FIELDS (type));
  for (field = TYPE_FIELDS (type), disc = discriminants;
       field && disc;
       field = TREE_CHAIN (field), disc = TREE_CHAIN (disc))
    {
      PASCAL_TREE_DISCRIMINANT (field) = 1;
      DECL_LANG_SPECIFIC (field) = NULL;
      allocate_decl_lang_specific (field);
      DECL_LANG_FIXUPLIST (field) = TREE_VALUE (disc);
    }

  /* Store TYPE_TEMPLATE in TYPE_LANG_SPECIFIC to allow for pointer
     compatibility checks. Do not use TYPE_MAIN_VARIANT because the
     size of schemata varies. */
  TYPE_LANG_CODE (type) = PASCAL_LANG_DISCRIMINATED_SCHEMA;
  TYPE_LANG_BASE (type) = type_template;  /* base type */

  /* Preserve unused flag, volatility and readonlyness. */
  TREE_USED (type) = TREE_USED (type_template);
  TYPE_READONLY (type) = TYPE_READONLY (type_template);
  TYPE_VOLATILE (type) = TYPE_VOLATILE (type_template);

  if (!prediscriminating && TYPE_LANG_INITIAL (type))
    (void) build_pascal_initializer (type, TYPE_LANG_INITIAL (type), "discriminated schema type", 0);

#ifndef EGCS97
  current_obstack = ambient_obstack;
#endif
  size_volatile--;
  return type;
}

/* Return nonzero if REF is an lvalue valid for this language.
   Lvalues can be assigned, unless their type has TYPE_READONLY.
   Lvalues can have their address taken, unless they have DECL_REGISTER. */
int
lvalue_p (tree ref)
{
  switch (TREE_CODE (ref))
  {
    case COMPONENT_REF:
    case BIT_FIELD_REF:
    case PASCAL_BIT_FIELD_REF:
      return lvalue_p (TREE_OPERAND (ref, 0));

    case COMPOUND_EXPR:
      return lvalue_p (TREE_OPERAND (ref, 1));

    /* Special case: a reference which has been converted to a pointer using `@' is an lvalue. */
    case CONVERT_EXPR:
      return TREE_CODE (TREE_TYPE (ref)) == POINTER_TYPE
             && TREE_CODE (TREE_TYPE (TREE_OPERAND (ref, 0))) == REFERENCE_TYPE;

    case INDIRECT_REF:
    case ARRAY_REF:
    case VAR_DECL:
    case PARM_DECL:
    case RESULT_DECL:
    case ERROR_MARK:
      return TREE_CODE (TREE_TYPE (ref)) != FUNCTION_TYPE && TREE_CODE (TREE_TYPE (ref)) != METHOD_TYPE;

    case BIND_EXPR:
#ifndef GCC_4_0
    case RTL_EXPR:
      return TREE_CODE (TREE_TYPE (ref)) == ARRAY_TYPE;
#endif

    case NOP_EXPR:
      {
        tree op0 = TREE_OPERAND (ref, 0);
        tree type = TREE_TYPE (ref);
        tree otype = TREE_TYPE (op0);
        if ((ORDINAL_TYPE (TREE_CODE (otype)) 
              || TREE_CODE (otype) == POINTER_TYPE
              || TREE_CODE (otype) == REFERENCE_TYPE)
            && (ORDINAL_TYPE (TREE_CODE (type)) 
                || TREE_CODE (type) == POINTER_TYPE
                || TREE_CODE (type) == REFERENCE_TYPE)
            && TYPE_PRECISION (type) == TYPE_PRECISION (otype))
          return lvalue_p (op0);
        else
          return 0;
      }

    default:
      return 0;
  }
}

/* Return nonzero if REF is an lvalue valid for this language;
   otherwise, print an error message and return zero. */
#ifdef EGCS
int
lvalue_or_else (tree ref, const char *string)
#else
int
lvalue_or_else (tree ref, char *string)
#endif
{
  int win = lvalue_p (ref);
  if (!win)
    error ("invalid lvalue in %s", string);
  return win;
}

/* Mark EXP saying that we need to be able to take the
   address of it; it should not be allocated in a register.
   Value is 1 if successful. */
#ifdef GCC_3_3
bool
#else
int
#endif
mark_addressable (tree exp)
{
  return mark_addressable2 (exp, 0);
}

#ifdef GCC_3_3
bool
#else
int
#endif
mark_addressable2 (tree exp, int allow_packed)
{
  tree x = exp;
  while (1)
    switch (TREE_CODE (x))
    {
      case COMPONENT_REF:
        if (DECL_PACKED_FIELD (TREE_OPERAND (x, 1)) && !allow_packed)
          {
            error ("cannot take address of packed record field `%s'",
                   IDENTIFIER_NAME (DECL_NAME (TREE_OPERAND (x, 1))));
            return 0;
          }
        /* FALLTHROUGH */

      case ADDR_EXPR:
      case ARRAY_REF:
      case REALPART_EXPR:
      case IMAGPART_EXPR:
        x = TREE_OPERAND (x, 0);
        break;

      case CONSTRUCTOR:
#ifdef GCC_4_1
      case PASCAL_SET_CONSTRUCTOR:
#endif
        TREE_ADDRESSABLE (x) = 1;
        return 1;

      case VAR_DECL:
      case PARM_DECL:
      case RESULT_DECL:
        if (DECL_REGISTER (x) && !TREE_ADDRESSABLE (x) && DECL_NONLOCAL (x))
          {
            if (TREE_PUBLIC (x))
              {
                error ("global register variable `%s' used in local function",
                       IDENTIFIER_NAME (DECL_NAME (x)));
                return 0;
              }
            pedwarn ("register variable `%s' used in local function",
                     IDENTIFIER_NAME (DECL_NAME (x)));
          }
        else if (DECL_REGISTER (x) && !TREE_ADDRESSABLE (x))
          {
            error ("address of register variable `%s' requested", IDENTIFIER_NAME (DECL_NAME (x)));
            return 0;
          }
  /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */
#ifndef GCC_4_0
#ifdef GCC_3_3
        put_var_into_stack (x, true);
#else
        put_var_into_stack (x);
#endif
#endif
        /* FALLTHROUGH */
      case FUNCTION_DECL:
        TREE_ADDRESSABLE (x) = 1;
        return 1;

      case CONST_DECL:
        gcc_unreachable ();

      default:
        return 1;
    }
}

/* Convert value RHS to type TYPE as preparation for an assignment to an lvalue of type TYPE.
   The real work of conversion is done by `convert'.
   The purpose of this function is to generate error messages for assignments that are not allowed in Pascal.
   ERRTYPE is a string to use in error messages:
   "assignment", "return", etc. If it is null, this is parameter passing for a function
   call (and different error messages are output). Otherwise, it may be a name stored
   in the spelling stack and interpreted by get_spelling.
   FUNDECL is the declaration of the function being called or null.
   PARMNUM is the number of the argument, for printing in error messages. */
tree
convert_for_assignment (tree type, tree rhs, const char *errtype, tree fundecl, int parmnum)
{
  enum tree_code codel = TREE_CODE (type), coder;
  tree rhstype;

  /* Strip NON_LVALUE_EXPRs since we aren't using as an lvalue.
     Do not use STRIP_NOPS here. We do not want an enumerator
     whose value is 0 to count as a null pointer constant. */
  if (TREE_CODE (rhs) == NON_LVALUE_EXPR && TREE_TYPE (TREE_OPERAND (rhs, 0)) == TREE_TYPE (rhs))
    rhs = TREE_OPERAND (rhs, 0);

  /* default_conversion() does not convert array and function types in GPC. */
  if (TREE_CODE (TREE_TYPE (rhs)) == FUNCTION_TYPE)
    {
      rhs = build_unary_op (ADDR_EXPR, rhs, 0);
      /* Create a reference rather than a pointer. */
      rhs = convert (build_reference_type (TREE_TYPE (TREE_TYPE (rhs))), rhs);
    }
  else if (optimize && TREE_CODE (rhs) == VAR_DECL)
    rhs = decl_constant_value (rhs);

  rhstype = TREE_TYPE (rhs);
  coder = TREE_CODE (rhstype);
  CHK_EM (rhstype);

  /* File assignments are never allowed.
     Exceptions: RTS parameters which are internally value file parameters.
     User-declared routines reject value file parameters on declaration,
     so we can accept all parameters here. */
  if (!parmnum && (contains_file_p (type) || contains_file_p (rhstype)))
    {
      error ("invalid assignment between files");
      return error_mark_node;
    }

  if (coder == VOID_TYPE)
    {
      error ("void value not ignored as it ought to be");
      return error_mark_node;
    }

  if (TYPE_MAIN_VARIANT (type) == TYPE_MAIN_VARIANT (rhstype))
    return convert_and_check (type, rhs);

  /* Assignments of different object types must have been handled before. */
  if (PASCAL_TYPE_OBJECT (type) || PASCAL_TYPE_OBJECT (rhstype))
    {
      error ("invalid object assignment");
      return error_mark_node;
    }

  /* Check if lhs is a subrange
     @@ Is it possible that non-integer type subranges should have size conversions?
     If so, we should construct a limited type from the correct type in
     the first place, not by having to use INTEGER_TYPE node as a range specifier. */
  codel = TREE_CODE (type);
  coder = TREE_CODE (rhstype);

  if (ORDINAL_REAL_OR_COMPLEX_TYPE (codel) && compatible_assignment_p (type, rhstype))
    return convert_and_check (type, rhs);

  /* Assignments of procedural variables. */
  else if (codel == REFERENCE_TYPE && TREE_CODE (TREE_TYPE (type)) == FUNCTION_TYPE)
    {
      if (coder == REFERENCE_TYPE
          && TREE_CODE (TREE_TYPE (rhstype)) == FUNCTION_TYPE
          && comp_target_types (type, rhstype))
        return convert (type, rhs);
      if (coder == POINTER_TYPE && integer_zerop (rhs))
        return convert (type, rhs);
    }

  else if (codel != coder)
    ;

  /* Conversions among pointers */
  else if (codel == POINTER_TYPE)
    {
      tree ttl = TREE_TYPE (type);
      tree ttr = TREE_TYPE (rhstype);
      CHK_EM (ttl);
      CHK_EM (ttr);

      /* Any non-function converts to an untyped pointer and vice versa;
         otherwise, targets must be the same.
         Meanwhile, the lhs target must have all the qualifiers of the rhs. */
      if (TYPE_MAIN_VARIANT (ttl) == void_type_node
          || TYPE_MAIN_VARIANT (ttr) == void_type_node
          || comp_target_types (type, rhstype)
          || comp_object_or_schema_pointer_types (ttl, ttr, parmnum != 0))
        {
          /* Const and volatile mean something different for function types,
             so the usual warnings are not appropriate. */
          if (TREE_CODE (ttr) != FUNCTION_TYPE && TREE_CODE (ttl) != FUNCTION_TYPE)
            {
#if 0
              if (!TYPE_READONLY (ttl) && TYPE_READONLY (ttr))
                assignment_error_or_warning ("%s discards `const' from pointer target type",
                                             errtype, fundecl, parmnum, 0);
              else 
#endif
              if (!TYPE_VOLATILE (ttl) && TYPE_VOLATILE (ttr))
                assignment_error_or_warning ("%s discards `volatile' from pointer target type",
                                             errtype, fundecl, parmnum, 0);
              else if (TYPE_IS_INTEGER_TYPE (ttl) && TYPE_IS_INTEGER_TYPE (ttr))
                {
                  if (TYPE_UNSIGNED (ttl) != TYPE_UNSIGNED (ttr))
                    {
                      if (TYPE_PRECISION (ttl) != TYPE_PRECISION (ttr))
                        assignment_error_or_warning ("pointer targets in %s differ in size and signedness",
                                                     errtype, fundecl, parmnum, 1);
                      else
                        assignment_error_or_warning ("pointer targets in %s differ in signedness",
                                                     errtype, fundecl, parmnum, 1);
                    }
                  else if (TYPE_PRECISION (ttl) != TYPE_PRECISION (ttr))
                    assignment_error_or_warning ("pointer targets in %s differ in size",
                                                 errtype, fundecl, parmnum, 1);
                }
            }
          else if (TREE_CODE (ttl) == FUNCTION_TYPE && TREE_CODE (ttr) == FUNCTION_TYPE)
            {
              /* Because const and volatile on functions are restrictions
                 that say the function will not do certain things,
                 it is okay to use a const or volatile function
                 where an ordinary one is wanted, but not vice-versa. */
              if (TYPE_READONLY (ttl) && !TYPE_READONLY (ttr))
                assignment_error_or_warning ("%s makes const function pointer from non-const",
                                             errtype, fundecl, parmnum, 0);
              if (TYPE_VOLATILE (ttl) && !TYPE_VOLATILE (ttr))
                assignment_error_or_warning ("%s makes volatile function pointer from non-volatile",
                                             errtype, fundecl, parmnum, 0);
            }
        }
      else
        assignment_error_or_warning ("%s from incompatible pointer type", errtype, fundecl, parmnum, 1);
      return convert (type, rhs);
    }
  /* Array assignments. */
  else if (codel == ARRAY_TYPE)
    {
      if (!comptypes (type, rhstype))
        {
          if (errtype)
            error ("type mismatch in array %s", get_spelling (errtype));
          else if (fundecl && DECL_NAME (fundecl))
            {
              error ("passing arg %d of `%s' from incompatible array", parmnum, IDENTIFIER_NAME (DECL_NAME (fundecl)));
              error_with_decl (fundecl, " routine declaration");
            }
          else
            error ("passing arg %d from incompatible array", parmnum);
          return error_mark_node;
        }
      return rhs;  /* No conversion */
    }
  /* Record assignments. */
  else if (codel == RECORD_TYPE)
    {
      if (!comptypes (type, rhstype))
        {
          if (errtype)
            error ("type mismatch in record %s", get_spelling (errtype));
          else if (fundecl && DECL_NAME (fundecl))
            {
              error ("passing arg %d of `%s' from incompatible record or schema",
                     parmnum, IDENTIFIER_NAME (DECL_NAME (fundecl)));
              error_with_decl (fundecl, " routine declaration");
            }
          else
            error ("passing arg %d from incompatible record or schema", parmnum);
          return error_mark_node;
        }
      else
        return rhs;
    }
  /* Set assignments. */
  else if (codel == SET_TYPE && rhstype == empty_set_type_node)
    return rhs;
  else if (codel == SET_TYPE)
    {
      if (comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (rhstype)), TYPE_MAIN_VARIANT (TREE_TYPE (type))))
        {
          tree lhs_domain = TYPE_DOMAIN (type);
          tree rhs_domain = TYPE_DOMAIN (rhstype);
          if (TYPE_MIN_VALUE (lhs_domain) == TYPE_MIN_VALUE (rhs_domain)
              && TYPE_MAX_VALUE (lhs_domain) == TYPE_MAX_VALUE (rhs_domain))
            return rhs;  /* No conversions */
          else
            return convert (type, rhs);
        }
    }
  /* Complex assignments. */
  else if (codel == COMPLEX_TYPE)
    {
      /* @@@@ Take care of ARG!!! */
      if (TREE_CODE (rhs) == REALPART_EXPR || TREE_CODE (rhs) == IMAGPART_EXPR)
        return rhs;
    }
  if (errtype)
    error ("incompatible types in %s", get_spelling (errtype));
  else if (fundecl && DECL_NAME (fundecl))
    {
      error ("incompatible type for argument %d of `%s'", parmnum, IDENTIFIER_NAME (DECL_NAME (fundecl)));
      error_with_decl (fundecl, " routine declaration");
    }
  else
    error ("incompatible type for argument %d of indirect function call", parmnum);
  return error_mark_node;
}

#if 0
tree
convert_for_assignment (tree type, tree rhs, const char *errtype, tree fundecl, int parmnum)
{
  tree res = convert_for_assignment0 (type, rhs, errtype, fundecl, parmnum);
  CHK_EM (res);
  if (TYPE_MAIN_VARIANT (type) != TYPE_MAIN_VARIANT (TREE_TYPE (res)))
    res = build (NOP_EXPR, type, res);
  return res;
}
#endif

/* Same as warn_for_assignment(), but as an error message. */
static void
assignment_error_or_warning (const char *msg, const char *errtype, tree fundecl, int argnum, int error_flag)
{
  static const char *const argstring = "passing arg %d of `%s'";
  static const char *const argnofun = "passing arg %d";
  const char *opname = get_spelling (errtype);
  tree name = fundecl ? DECL_NAME (fundecl) : NULL_TREE;
  if (!opname)
    {
      char *p;
      if (name)
        {
          /* Routine name is known; supply it. */
          p = (char *) alloca (strlen (IDENTIFIER_NAME (name)) + sizeof (argstring) + 25 /*%d*/ + 1);
          sprintf (p, argstring, argnum, IDENTIFIER_NAME (name));
        }
      else
        {
          /* Routine name unknown (call through ptr); just give arg number. */
          p = (char *) alloca (sizeof (argnofun) + 25 /*%d*/ + 1);
          sprintf (p, argnofun, argnum);
        }
      opname = p;
    }
  if (error_flag)
    {
      error (msg, opname);
      if (name)
        error_with_decl (fundecl, " routine declaration");
    }
  else
    {
      gpc_warning (msg, opname);
      if (name)
        warning_with_decl (fundecl, " routine declaration");
    }
}

#ifndef EGCS97
/* Return nonzero if VALUE is a valid constant-valued expression
   for use in initializing a static variable; one that can be an
   element of a "constant" initializer.
   Return null_pointer_node if the value is absolute;
   if it is relocatable, return the variable that determines the relocation.
   We assume that VALUE has been folded as much as possible; therefore, we
   do not need to check for such things as arithmetic-combinations of integers. */
tree
initializer_constant_valid_p (tree value, tree endtype)
{
  switch (TREE_CODE (value))
  {
    case CONSTRUCTOR:
      if (RECORD_OR_UNION (TREE_CODE (TREE_TYPE (value)))
          && TREE_CONSTANT (value)
          && CONSTRUCTOR_ELTS (value))
        return initializer_constant_valid_p (TREE_VALUE (CONSTRUCTOR_ELTS (value)), endtype);

      return TREE_STATIC (value) ? null_pointer_node : 0;

    case INTEGER_CST:
    case REAL_CST:
    case STRING_CST:
    case COMPLEX_CST:
      return null_pointer_node;

    case ADDR_EXPR:
      return TREE_OPERAND (value, 0);

    case NON_LVALUE_EXPR:
      return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

    case CONVERT_EXPR:
    case NOP_EXPR:
      /* Allow conversions between reference and pointer types. */
      if ((TREE_CODE (TREE_TYPE (value)) == POINTER_TYPE
           || TREE_CODE (TREE_TYPE (value)) == REFERENCE_TYPE)
          && (TREE_CODE (TREE_TYPE (TREE_OPERAND (value, 0))) == POINTER_TYPE
              || TREE_CODE (TREE_TYPE (TREE_OPERAND (value, 0))) == REFERENCE_TYPE))
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      /* Allow conversions between real types. */
      if (TREE_CODE (TREE_TYPE (value)) == REAL_TYPE
          && TREE_CODE (TREE_TYPE (TREE_OPERAND (value, 0))) == REAL_TYPE)
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      /* Allow length-preserving conversions between integer types. */
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (value))
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE (TREE_OPERAND (value, 0)))
          && (TYPE_PRECISION (TREE_TYPE (value)) == TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (value, 0)))))
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      /* Allow conversions between other integer types only if explicit value. */
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (value))
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE (TREE_OPERAND (value, 0))))
        {
          tree inner = initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);
          if (inner == null_pointer_node)
            return null_pointer_node;
          return 0;
        }

      /* Allow (int) &foo provided int is as wide as a pointer. */
      if (TYPE_IS_INTEGER_TYPE (TREE_TYPE (value))
          && TREE_CODE (TREE_TYPE (TREE_OPERAND (value, 0))) == POINTER_TYPE
          && (TYPE_PRECISION (TREE_TYPE (value)) >= TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (value, 0)))))
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      /* Likewise conversions from int to pointers. */
      if (TREE_CODE (TREE_TYPE (value)) == POINTER_TYPE
          && TYPE_IS_INTEGER_TYPE (TREE_TYPE (TREE_OPERAND (value, 0)))
          && (TYPE_PRECISION (TREE_TYPE (value)) <= TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (value, 0)))))
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      /* Allow conversion to array type (for packed arrays) */
      if (TREE_CODE (TREE_TYPE (value)) == ARRAY_TYPE)
        return initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);

      return 0;

    case PLUS_EXPR:
      if (TYPE_IS_INTEGER_TYPE (endtype)
          && TYPE_PRECISION (endtype) < POINTER_SIZE)
        return 0;
      {
        tree valid0 = initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);
        tree valid1 = initializer_constant_valid_p (TREE_OPERAND (value, 1), endtype);
        /* If either term is absolute, use the other terms relocation. */
        if (valid0 == null_pointer_node)
          return valid1;
        if (valid1 == null_pointer_node)
          return valid0;
        return 0;
      }

    case MINUS_EXPR:
      if (TYPE_IS_INTEGER_TYPE (endtype)
          && TYPE_PRECISION (endtype) < POINTER_SIZE)
        return 0;
      {
        tree valid0 = initializer_constant_valid_p (TREE_OPERAND (value, 0), endtype);
        tree valid1 = initializer_constant_valid_p (TREE_OPERAND (value, 1), endtype);
        /* Win if second argument is absolute. */
        if (valid1 == null_pointer_node)
          return valid0;
        /* Win if both arguments have the same relocation.
           Then the value is absolute. */
        if (valid0 == valid1)
          return null_pointer_node;
        return 0;
      }

    default:
      return 0;
  }
}
#endif

/* Methods for storing and printing names for error messages. */

/* Implement a spelling stack that allows components of a name to be pushed
   and popped. Each element on the stack is this structure. */
struct spelling
{
  int kind;
  union
  {
    int i;
    const char *s;
  } u;
};

#define SPELLING_STRING 1
#define SPELLING_MEMBER 2
#define SPELLING_INDEX 3

static struct spelling *spelling;       /* Next stack element (unused). */
static struct spelling *spelling_base;  /* Spelling stack base. */
static int spelling_size;               /* Size of the spelling stack. */

/* Macros to save and restore the spelling stack around push_... functions.
   Alternative to SAVE_SPELLING_STACK. */
#define SPELLING_DEPTH() (spelling - spelling_base)
#define RESTORE_SPELLING_DEPTH(depth) (spelling = spelling_base + depth)

/* Save and restore the spelling stack around arbitrary C code. */
#define SAVE_SPELLING_DEPTH(code) \
{ \
  int __depth = SPELLING_DEPTH (); \
  code; \
  RESTORE_SPELLING_DEPTH (__depth); \
}

/* Push an element on the spelling stack with type KIND and assign VALUE to MEMBER. */
#define PUSH_SPELLING(KIND, VALUE, MEMBER) \
{ \
  int depth = SPELLING_DEPTH (); \
  if (depth >= spelling_size) \
    { \
      spelling_size += 10; \
      if (!spelling_base) \
        spelling_base = (struct spelling *) xmalloc (spelling_size * sizeof (struct spelling)); \
      else  \
        spelling_base \
          = (struct spelling *) xrealloc (spelling_base, spelling_size * sizeof (struct spelling)); \
      RESTORE_SPELLING_DEPTH (depth); \
    } \
  spelling->kind = (KIND); \
  spelling->MEMBER = (VALUE); \
  spelling++; \
}

/* Push STRING on the stack. Printed literally. */
static void
push_string (const char *string)
{
  PUSH_SPELLING (SPELLING_STRING, string, u.s);
}

/* Push a member name on the stack. Printed as '.' STRING. */
static void
push_member_name (tree decl)
{
  if (DECL_NAME (decl))
    PUSH_SPELLING (SPELLING_MEMBER, IDENTIFIER_NAME (DECL_NAME (decl)), u.s)
  else
    push_string ("");
}

/* Push an array index on the stack. Printed as [index]. */
static void
push_array_index (int index)
{
  PUSH_SPELLING (SPELLING_INDEX, index, u.i);
}

/* Print the spelling to BUFFER and return it. */
static char *
print_spelling (void)
{
  char *buffer, *d;
  const char *s;
  int size = 0;
  struct spelling *p;
  for (p = spelling_base; p < spelling; p++)
    if (p->kind == SPELLING_INDEX)
      size += 25;
    else
      size += strlen (p->u.s) + 1;
  d = buffer = (char *) xmalloc (size + 1);
  for (p = spelling_base; p < spelling; p++)
    if (p->kind == SPELLING_INDEX)
      {
        sprintf (d, "[%d]", p->u.i);
        d += strlen (d);
      }
    else
      {
        if (p->kind == SPELLING_MEMBER)
          *d++ = '.';
        for (s = p->u.s; (*d = *s++); d++)
          ;
      }
  *d++ = 0;
  return buffer;
}

/* Provide a means to pass component names derived from the spelling stack. */
char initialization_message;

/* Interpret the spelling of the given ERRTYPE message. */
static const char *
get_spelling (const char *errtype)
{
  if (errtype == &initialization_message)
    return concat ("initialization of `", print_spelling (), "'", NULL);
  return errtype;
}

/* Issue an error message for a bad initializer component.
   FORMAT describes the message. OFWHAT is the name for the component.
   LOCAL is a format string for formatting the insertion of the name
   into the message.

   If OFWHAT is null, the component name is stored on the spelling stack.
   If the component name is a null string, then LOCAL is omitted entirely. */
static void
initializer_error (const char *format, const char *local)
{
  char *ofwhat = print_spelling ();
  if (*ofwhat)
    {
      char *buffer = (char *) alloca (strlen (local) + strlen (ofwhat) + 2);
      sprintf (buffer, local, ofwhat);
      error (format, buffer);
    }
  else
    error (format, "");
  free (ofwhat);
}

/* Digest parser output as an initializer for `type'. Return an expression of
   that type to represent the initial value. Setting require_constant requests
   errors if non-constant initializers or elements are seen. */
tree
digest_init (tree type, tree init, int require_constant)
{
  enum tree_code code = TREE_CODE (type);
  tree inside_init = init;
  CHK_EM (init);

  /* Strip NON_LVALUE_EXPRs since we aren't using as an lvalue. */
  /* Do not use STRIP_NOPS here. We do not want an enumerator
     whose value is 0 to count as a null pointer constant. */
  if (TREE_CODE (init) == NON_LVALUE_EXPR)
    inside_init = TREE_OPERAND (init, 0);

  /* Initialization of an array of chars from a string constant
     optionally enclosed in braces. */

  if (code == ARRAY_TYPE)
    {
      tree typ1 = TYPE_MAIN_VARIANT (TREE_TYPE (type));
      if ((typ1 == char_type_node || typ1 == wchar_type_node)
          && ((inside_init && TREE_CODE (TREE_TYPE (inside_init)) == ARRAY_TYPE)))
        {
          if (comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (inside_init)), TYPE_MAIN_VARIANT (type)))
            return inside_init;

          if ((TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (inside_init))) != char_type_node)
              && TYPE_PRECISION (typ1) == TYPE_PRECISION (char_type_node))
            {
              initializer_error ("char-array%s initialized from wide string", " `%s'");
              return error_mark_node;
            }
          if ((TYPE_MAIN_VARIANT (TREE_TYPE (TREE_TYPE (inside_init))) == char_type_node)
              && TYPE_PRECISION (typ1) != TYPE_PRECISION (char_type_node))
            {
              initializer_error ("wide-char array%s initialized from non-wide string", " `%s'");
              return error_mark_node;
            }

          if (TREE_CODE (inside_init) == STRING_CST)
            {
              TREE_TYPE (inside_init) = type;
              if (TYPE_DOMAIN (type) && TREE_CODE (TYPE_SIZE (type)) == INTEGER_CST)
                {
                  int size = TREE_INT_CST_LOW (TYPE_SIZE (type));
                  size = (size + BITS_PER_UNIT - 1) / BITS_PER_UNIT;
                  /* Subtract 1 (or sizeof (wchar_t)) to ignore the terminating
                     null char that is counted in the length of the constant. */
                  if (size < TREE_STRING_LENGTH (inside_init)
                      - (TYPE_PRECISION (typ1) != TYPE_PRECISION (char_type_node)
                         ? TYPE_PRECISION (wchar_type_node) / BITS_PER_UNIT : 1))
                    initializer_error ("initializer-string for array of chars%s is too long", " `%s'");
                }
            }
          return inside_init;
        }
    }

  /* Any type can be initialized
     from an expression of the same type, optionally with braces. */

  if (inside_init && TREE_TYPE (inside_init)
      && (comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (inside_init)), TYPE_MAIN_VARIANT (type))
          || (code == ARRAY_TYPE && comptypes (TREE_TYPE (inside_init), type))
          || (code == SET_TYPE && comptypes (TREE_TYPE (inside_init), type))
          || (code == POINTER_TYPE
              && (TREE_CODE (TREE_TYPE (inside_init)) == ARRAY_TYPE
                  || TREE_CODE (TREE_TYPE (inside_init)) == FUNCTION_TYPE)
              && comptypes (TREE_TYPE (TREE_TYPE (inside_init)), TREE_TYPE (type)))))
    {
      if (code == POINTER_TYPE
          && (TREE_CODE (TREE_TYPE (inside_init)) == ARRAY_TYPE
              || TREE_CODE (TREE_TYPE (inside_init)) == FUNCTION_TYPE))
        inside_init = default_conversion (inside_init);

      if (optimize && TREE_CODE (inside_init) == VAR_DECL)
        inside_init = decl_constant_value (inside_init);

      if (require_constant && !TREE_CONSTANT (inside_init))
        {
          initializer_error ("initializer element%s is not constant", " for `%s'");
          inside_init = error_mark_node;
        }
      else if (require_constant && !initializer_constant_valid_p (inside_init, TREE_TYPE (inside_init)))
        {
          initializer_error ("initializer element%s is not computable at load time", " for `%s'");
          inside_init = error_mark_node;
        }

      return inside_init;
    }

  /* Handle scalar types, including conversions. */
  if (SCALAR_TYPE (code))
    {
      /* Note that convert_for_assignment calls default_conversion
         for arrays and functions. We must not call it in the
         case where inside_init is a null pointer constant. */
      inside_init = convert_for_assignment (type, init, "initialization", NULL_TREE, 0);

      if (EM (inside_init))
        ;
      else if (require_constant && !TREE_CONSTANT (inside_init))
        {
          initializer_error ("initializer element%s is not constant", " for `%s'");
          inside_init = error_mark_node;
        }
      else if (require_constant && !initializer_constant_valid_p (inside_init, TREE_TYPE (inside_init)))
        {
          initializer_error ("initializer element%s is not computable at load time", " for `%s'");
          inside_init = error_mark_node;
        }
      return inside_init;
    }

  /* Come here only for records and arrays. */
  if (TYPE_SIZE (type) && TREE_CODE (TYPE_SIZE (type)) != INTEGER_CST)
    {
      initializer_error ("variable-sized object%s may not be initialized", " `%s'");
      return error_mark_node;
    }
  initializer_error ("invalid initializer%s", " for `%s'");
  return error_mark_node;
}

/* Handle initializers that use braces. */

/* Type of object we are accumulating a constructor for.
   This type is always a RECORD_TYPE, UNION_TYPE or ARRAY_TYPE. */
static tree constructor_type;

/* For a RECORD_TYPE or UNION_TYPE, this is the chain of fields left to fill. */
static tree constructor_fields;

/* For an ARRAY_TYPE, this is the specified index
   at which to store the next element we get. */
static tree constructor_index;

/* For an ARRAY_TYPE, this is the end index of the range
   to initialize with the next element, or NULL in the ordinary case
   where the element is used just once. */
static tree constructor_range_end;

/* For an ARRAY_TYPE, this is the maximum index. */
static tree constructor_max_index;

/* For a RECORD_TYPE, this is the first field not yet written out. */
static tree constructor_unfilled_fields;

/* For an ARRAY_TYPE, this is the index of the first element
   not yet written out. */
static tree constructor_unfilled_index;

/* If we are saving up the elements rather than allocating them,
   this is the list of elements so far (in reverse order,
   most recent first). */
#ifndef GCC_4_1
static tree constructor_elements;
#else
static VEC(constructor_elt,gc) *constructor_elements;
#endif

/* 1 if so far this constructor's elements are all compile-time constants. */
static int constructor_constant;

/* 1 if so far this constructor's elements are all valid address constants. */
static int constructor_simple;

/* 1 if this constructor is erroneous so far. */
static int constructor_erroneous;

/* List of pending elements at this constructor level.
   These are elements encountered out of order which belong at
   places we haven't reached yet in actually writing the output. */
static tree constructor_pending_elts;

/* The SPELLING_DEPTH of this constructor. */
static int constructor_depth;

static int require_constant_value;
static int require_constant_elements;

/* This stack has a level for each structure level in the initializer, including
   the outermost one. It saves the values of most of the variables above. */
struct constructor_stack
{
  struct constructor_stack *next;
  tree type;
  tree fields;
  tree index;
  tree range_end;
  tree max_index;
  tree unfilled_index;
  tree unfilled_fields;
#ifndef GCC_4_1
  tree elements;
#else
  VEC(constructor_elt,gc) *elements;
#endif
  int offset;
  tree pending_elts;
  int depth;
  /* If nonzero, this value should replace the entire constructor at this level. */
  tree replacement_value;
  char constant;
  char simple;
  char erroneous;
  char outer;
};

struct constructor_stack *constructor_stack;

static void
process_discriminants (tree type)
{
  tree field;
  gcc_assert (PASCAL_TYPE_DISCRIMINATED_SCHEMA (type));
  for (field = TYPE_FIELDS (type);
       field && PASCAL_TREE_DISCRIMINANT (field);
       field = TREE_CHAIN (field))
    {
      tree discr = DECL_LANG_FIXUPLIST (field);
      gcc_assert (discr && TREE_CODE (discr) != TREE_LIST);
      process_init_element (discr);
    }
}

/* Recursive subroutine of build_pascal_initializer():
   Process one level (array or record) of a structured initializer. */
static void
process_init_list (tree init)
{
  /* Do not crash on errors */
  if (!constructor_type)
    return;
  if (PASCAL_TYPE_SCHEMA (constructor_type))
    {
      process_discriminants (constructor_type);
      set_init_label (schema_id);
      push_init_level ();
      process_init_list (init);
      process_init_element (pop_init_level ());
      return;
    }
  for (; init; init = TREE_CHAIN (init))
    {
      tree ninit, field = TREE_PURPOSE (init);
      if (field)
        {
          if (RECORD_OR_UNION (TREE_CODE (constructor_type)) && PASCAL_TYPE_RECORD_VARIANTS (constructor_type))
            {
              set_init_variant (TREE_PURPOSE (field));
              push_init_level ();
              process_init_list (init);
              process_init_element (pop_init_level ());
              return;
            }
          else if (TREE_CODE (constructor_type) == RECORD_TYPE)
            {
              tree cuf = constructor_unfilled_fields;
              if (!TREE_PURPOSE (field) && TREE_VALUE (field))
                {
                  tree sel_type, sel_val, sel_field, tag_info;
                  if (!PASCAL_TYPE_VARIANT_RECORD (constructor_type))
                    {
                      error ("`case' in initializer of record without variant part");
                      return;
                    }
                  tag_info = TYPE_LANG_VARIANT_TAG (constructor_type);
                  sel_type = TREE_PURPOSE (TREE_PURPOSE (tag_info));
                  sel_val = TREE_VALUE (init);
                  if (TREE_CODE (sel_val) != INTEGER_CST)
                    {
                      error ("non-constant `case' selector");
                      return;
                    }
                  sel_field = TREE_VALUE (TREE_PURPOSE (tag_info));
                  if (sel_field && PASCAL_TREE_DISCRIMINANT (sel_field))
                    {
#if 0
                      /* Should find selector value */
                      tree sv = DECL_LANG_FIXUPLIST (sel_field);
                      /* @@@@ Should emit runtime check for non-constant
                         discriminant */
                      if (TREE_CODE (sv) == INTEGER_CST
                          && !tree_int_cst_equal (sv, sel_val))
                        {
                          error ("`case' selector not equal to discriminant");
                          return;
                        }
#endif
                    }
                  if (!comptypes (TYPE_MAIN_VARIANT (sel_type),
                                  TYPE_MAIN_VARIANT (TREE_TYPE (sel_val))))
                    {
                      error ("type mismatch in `case' selector");
                      return;
                    }
                  if (const_lt (sel_val, TYPE_MIN_VALUE (sel_type))
                      || const_lt (TYPE_MAX_VALUE (sel_type), sel_val))
                    {
                      error ("`case' selector out of range");
                      return;
                    }
                  if (TREE_VALUE (field) != integer_zero_node)
                    {
                      set_init_label (TREE_VALUE (field));
                      if (sel_field != constructor_fields)
                        error ("`%s' is not a tag field", IDENTIFIER_NAME (TREE_VALUE (field)));
                      process_init_element (sel_val);
                    }
                  init = TREE_CHAIN (init);
                  while (cuf && DECL_NAME (cuf))
                    cuf = TREE_CHAIN (cuf);
                  gcc_assert (cuf && !TREE_CHAIN (cuf));
                  constructor_fields = cuf;
                  push_init_level ();
                  constructor_fields = find_variant (sel_val, TREE_PURPOSE (TREE_VALUE (tag_info)));
                  push_init_level ();
                  process_init_list (init);
                  process_init_element (pop_init_level ());
                  process_init_element (pop_init_level ());
                  return;
                }
              if (cuf && !DECL_NAME (cuf))
                {
                  chk_dialect ("variant initializers without `case' part are", B_D_M_PASCAL);
                  gcc_assert (RECORD_OR_UNION (TREE_CODE (TREE_TYPE (cuf))));
                  constructor_fields = cuf;
                  push_init_level ();
                  process_init_list (init);
                  process_init_element (pop_init_level ());
                  return;
                }
              else
                {
                  gcc_assert (!TREE_VALUE (field));
                  set_init_label (TREE_PURPOSE (field));
                }
             }
          else
            {
              gcc_assert (TREE_CODE (constructor_type) == ARRAY_TYPE);
              if (!TREE_PURPOSE (field) && !TREE_VALUE (field))
                {
                  tree value;
                  gcc_assert (!TREE_CHAIN (init) && TREE_VALUE (init));
                  if (TREE_CODE (TREE_VALUE (init)) == TREE_LIST)
                    {
                      push_init_level ();
                      process_init_list (TREE_VALUE (init));
                      value = pop_init_level ();
                    }
                  else
                    value = TREE_VALUE (init);
                  value = save_expr (value);
                  process_otherwise (value);
                  return;
                }
              else
                set_init_index (TYPE_DOMAIN (constructor_type), TREE_PURPOSE (field), TREE_VALUE (field));
            }
        }
      if (!TREE_VALUE (init) || TREE_CODE (TREE_VALUE (init)) == TREE_LIST)
        {
          push_init_level ();
          process_init_list (TREE_VALUE (init));
          ninit = pop_init_level ();
        }
      else
        ninit = TREE_VALUE (init);
      if (field && TREE_CHAIN (field))
        {
          tree value = save_expr (ninit);
          while (1)
            {
              process_init_element (value);
              field = TREE_CHAIN (field);
              if (!field)
                break;
              if (TREE_CODE (constructor_type) == RECORD_TYPE)
                {
                  gcc_assert (!TREE_VALUE (field));
                  set_init_label (TREE_PURPOSE (field));
                }
              else
                {
                  gcc_assert (TREE_CODE (constructor_type) == ARRAY_TYPE);
                  set_init_index (TYPE_DOMAIN (constructor_type),
                                  TREE_PURPOSE (field), TREE_VALUE (field));
                }
            }
        }
      else
        process_init_element (ninit);
    }
}

/* Build an actual constructor for type out of the tree list init. It is assumed
   that check_pascal_initializer already has been called for init and
   returned 0; otherwise this may crash.
   @@ require_constant is 0 in all callers now. If the code for non-constant
      initializers turns out to work well, we can drop this check here. */
tree
build_pascal_initializer (tree type, tree init, const char *name, int require_constant)
{
  if (!init || EM (init))
    return NULL_TREE;  /* avoid further error messages */
  gcc_assert (TREE_CODE (init) == TREE_LIST);

#ifndef GCC_4_1
  constructor_elements = NULL_TREE;
#else
  constructor_elements = NULL;
#endif
  constructor_stack = 0;
  spelling_base = 0;
  spelling_size = 0;
  RESTORE_SPELLING_DEPTH (0);
  require_constant_value = require_constant;
  require_constant_elements = require_constant
    /* For a scalar, you can always use any value to initialize, even within braces. */
    && STRUCTURED_TYPE (TREE_CODE (type));
  push_string (name);

  if (!TREE_VALUE (init) || TREE_CODE (TREE_VALUE (init)) == TREE_LIST)
    {
      really_start_incremental_init (type);
      process_init_list (TREE_VALUE (init));
      init = pop_init_level ();
    }
  else if (PASCAL_TYPE_SCHEMA (type))
    {
      really_start_incremental_init (type);
      process_discriminants (type);
      set_init_label (schema_id);
      process_init_element (TREE_VALUE (init));
      init = pop_init_level ();
    }
  else
    init = TREE_VALUE (init);
  /* Free the whole constructor stack of this initializer. */
  while (constructor_stack)
    {
      struct constructor_stack *q = constructor_stack;
      constructor_stack = q->next;
      free (q);
    }
  return digest_init (type, init, require_constant_value);
}

/* Call here when we see the initializer is surrounded by braces.
   This is instead of a call to push_init_level;
   it is matched by a call to pop_init_level. */
static void
really_start_incremental_init (tree type)
{
  struct constructor_stack *p = (struct constructor_stack *) xmalloc (sizeof (struct constructor_stack));
  p->type = constructor_type;
  p->fields = constructor_fields;
  p->index = constructor_index;
  p->range_end = constructor_range_end;
  p->max_index = constructor_max_index;
  p->unfilled_index = constructor_unfilled_index;
  p->unfilled_fields = constructor_unfilled_fields;
  p->elements = constructor_elements;
  p->constant = constructor_constant;
  p->simple = constructor_simple;
  p->erroneous = constructor_erroneous;
  p->pending_elts = constructor_pending_elts;
  p->depth = constructor_depth;
  p->replacement_value = NULL_TREE;
  p->outer = 0;
  p->next = NULL;
  constructor_stack = p;

  constructor_constant = 1;
  constructor_simple = 1;
  constructor_depth = SPELLING_DEPTH ();
  constructor_elements = NULL_TREE;
  constructor_pending_elts = NULL_TREE;
  constructor_type = type;

  if (PASCAL_TYPE_FILE (constructor_type))
    error ("file variables cannot have an initializer");

  if (RECORD_OR_UNION (TREE_CODE (constructor_type)))
    {
      constructor_fields = TYPE_FIELDS (constructor_type);
      constructor_unfilled_fields = constructor_fields;
    }
  else if (TREE_CODE (constructor_type) == ARRAY_TYPE)
    {
      constructor_range_end = NULL_TREE;
      gcc_assert (TYPE_DOMAIN (constructor_type));
      constructor_max_index = convert (ssizetype, TYPE_MAX_VALUE (TYPE_DOMAIN (constructor_type)));
      constructor_index = convert (ssizetype, TYPE_MIN_VALUE (TYPE_DOMAIN (constructor_type)));
      constructor_unfilled_index = constructor_index;
    }
  else
    {
      /* Handle the case of int x = { 5 }; */
      constructor_fields = constructor_type;
      constructor_unfilled_fields = constructor_type;
    }
}

/* Push down into a subobject, for initialization. */
static void
push_init_level (void)
{
  struct constructor_stack *p = (struct constructor_stack *) xmalloc (sizeof (struct constructor_stack));
  p->type = constructor_type;
  p->fields = constructor_fields;
  p->index = constructor_index;
  p->range_end = constructor_range_end;
  p->max_index = constructor_max_index;
  p->unfilled_index = constructor_unfilled_index;
  p->unfilled_fields = constructor_unfilled_fields;
  p->elements = constructor_elements;
  p->constant = constructor_constant;
  p->simple = constructor_simple;
  p->erroneous = constructor_erroneous;
  p->pending_elts = constructor_pending_elts;
  p->depth = constructor_depth;
  p->replacement_value = NULL_TREE;
  p->outer = 0;
  p->next = constructor_stack;
  constructor_stack = p;

  constructor_constant = 1;
  constructor_simple = 1;
  constructor_depth = SPELLING_DEPTH ();
#ifndef GCC_4_1
  constructor_elements = NULL_TREE;
#else
  constructor_elements = NULL;
#endif
  constructor_pending_elts = NULL_TREE;

  /* Don't die if an entire brace-pair level is superfluous in the containing level. */
  if (!constructor_type)
    ;
  else if (RECORD_OR_UNION (TREE_CODE (constructor_type)))
    {
      /* Don't die if there are extra init elts at the end. */
      if (!constructor_fields)
        constructor_type = 0;
      else
        {
          if (PASCAL_TYPE_SCHEMA (constructor_type))
            push_string ("");
          else
            push_member_name (constructor_fields);
          constructor_type = TREE_TYPE (constructor_fields);
          constructor_depth++;
        }
    }
  else if (TREE_CODE (constructor_type) == ARRAY_TYPE)
    {
      constructor_type = TREE_TYPE (constructor_type);
      push_array_index (tree_low_cst (constructor_index, 0));
      constructor_depth++;
    }

  if (!constructor_type)
    {
      initializer_error ("extra parenthesized group at end of initializer%s", " for `%s'");
      constructor_fields = NULL_TREE;
      constructor_unfilled_fields = NULL_TREE;
      return;
    }

  if (RECORD_OR_UNION (TREE_CODE (constructor_type)))
    {
      constructor_fields = TYPE_FIELDS (constructor_type);
      constructor_unfilled_fields = constructor_fields;
    }
  else if (TREE_CODE (constructor_type) == ARRAY_TYPE)
    {
      constructor_range_end = NULL_TREE;
      gcc_assert (TYPE_DOMAIN (constructor_type));
      constructor_max_index = convert (ssizetype, TYPE_MAX_VALUE (TYPE_DOMAIN (constructor_type)));
      constructor_index = convert (ssizetype, TYPE_MIN_VALUE (TYPE_DOMAIN (constructor_type)));
      constructor_unfilled_index = constructor_index;
    }
  else
    {
      initializer_error ("invalid initializer%s", " for `%s'");
      constructor_type = NULL_TREE;
      constructor_fields = NULL_TREE;
      constructor_unfilled_fields = NULL_TREE;
      return;
    }

  if (PASCAL_TYPE_FILE (constructor_type))
    error ("file variables cannot have an initializer");
}

static tree
build_bitfields_type (tree ftype, int fcnt)
{
  tree fields = NULL_TREE, type;
  int save_defining_packed_type = defining_packed_type;
  defining_packed_type = 1;
  while (fcnt--)
    {
      tree t;
      char namestr[20];
      sprintf (namestr, "f%d", fcnt);
      t = build_field (get_identifier (namestr), ftype);
      TREE_CHAIN (t) = fields;
      fields = t;
    }
  type = finish_struct (start_struct (RECORD_TYPE), fields, 1);
  defining_packed_type = save_defining_packed_type;
  return type;
}

#ifndef GCC_4_1
static tree
do_build_constructor_rev (tree type, tree el)
#else
static tree
do_build_constructor_rev (tree type, VEC(constructor_elt,gc) *el)
#endif
{
#ifndef GCC_4_1
  tree constructor = build_constructor (type, nreverse (el));
#else
  tree constructor = build_constructor (type, el);
#endif
  if (constructor_constant)
    {
      TREE_CONSTANT (constructor) = 1;
#ifdef GCC_4_0
      TREE_INVARIANT (constructor) = 1;
#endif
    }
  if (constructor_constant && constructor_simple)
    TREE_STATIC (constructor) = 1;
  return constructor;
}

static tree
fill_one_record (tree *pel, tree min, tree ptype, tree *fields, HOST_WIDE_INT maxnr, HOST_WIDE_INT *pnr)
{
#ifndef GCC_4_1
  tree prl = NULL_TREE;
#else
  VEC(constructor_elt,gc) * prl = NULL;
#endif
  tree el = *pel;
  HOST_WIDE_INT oanr = 0;
  int first = 1;
  while (el)
    {
      tree tnr = size_binop (MINUS_EXPR,
                   convert (sbitsizetype, TREE_PURPOSE (el)),
                   convert (sbitsizetype, min));
      HOST_WIDE_INT nr = TREE_INT_CST_LOW (tnr);
      HOST_WIDE_INT anr = nr / BITS_PER_UNIT;
      nr = nr % BITS_PER_UNIT;
      if (first)
        {
          if (anr >= maxnr)
            return NULL_TREE;
          *pnr = oanr = anr;
          first = 0;
        }
      if (anr != oanr)
        break;

      CONSTRUCTOR_APPEND_ELT (prl, fields[nr], TREE_VALUE (el));
      el = TREE_CHAIN (el);
      *pel = el;
    }
  return prl ? do_build_constructor_rev (ptype, prl) : NULL_TREE;
}

static tree
fake_packed_array_constructor (void)
{
  tree rtype = NULL_TREE, rfields = NULL_TREE;
  tree type = constructor_type;
#ifndef GCC_4_1
  tree rl = NULL_TREE;
  tree el = nreverse (constructor_elements);
#else
  VEC(constructor_elt,gc) * rl = NULL;
  tree el = NULL_TREE;
#endif
  tree tsize = pascal_array_type_nelts (type), orig_el;
  HOST_WIDE_INT size = TREE_INT_CST_LOW (tsize), asize = size / BITS_PER_UNIT;
  int psize = size % BITS_PER_UNIT;

#ifdef GCC_4_1
  {
    VEC(constructor_elt,gc) *elts = constructor_elements;
    unsigned HOST_WIDE_INT ix;
    ix = VEC_length (constructor_elt, elts);
    while (ix > 0)
      {
        ix--;
        el = tree_cons (VEC_index (constructor_elt, elts, ix)->index,
                VEC_index (constructor_elt, elts, ix)->value, el);
      }
  }
#endif

  orig_el = el;

  if (size <= 0 || TREE_INT_CST_HIGH (tsize))
    {
      error ("array too large");
      return error_mark_node;
    }
  if (asize)
    {
      tree ptype = build_bitfields_type (TREE_TYPE (type), BITS_PER_UNIT);
      tree fields[BITS_PER_UNIT];
      tree atype, arfield, t;
#ifndef GCC_4_1
      tree al = NULL_TREE;
#else
      VEC(constructor_elt,gc) * al = NULL;
#endif
      int i;
      for (i = 0, t = TYPE_FIELDS (ptype); i < BITS_PER_UNIT; i++, t = TREE_CHAIN (t))
        fields[i] = t;
      atype = build_simple_array_type (ptype,
        build_pascal_range_type (integer_zero_node, build_int_2 (asize - 1, 0)));
      rfields = arfield = build_field (get_identifier ("array"), atype);
      while (el)
        {
          HOST_WIDE_INT anr;
          tree br = fill_one_record (&el, TYPE_MIN_VALUE (TYPE_DOMAIN (type)), ptype, fields, asize, &anr);
          if (!br)
            break;

          CONSTRUCTOR_APPEND_ELT (al, build_int_2 (anr, 0), br);
        }
      if (al)
        CONSTRUCTOR_APPEND_ELT (rl, arfield,
           do_build_constructor_rev (atype, al));
    }
  if (psize)
    {
      tree ptype1 = build_bitfields_type (TREE_TYPE (type), psize);
      tree *fields1 = alloca (psize * sizeof (*fields1));
      tree prfield, t;
      int i;
      for (i = 0, t = TYPE_FIELDS (ptype1); i < psize; i++, t = TREE_CHAIN (t))
        fields1[i] = t;
      prfield = build_field (get_identifier ("pad"), ptype1);
      if (rfields)
        TREE_CHAIN (rfields) = prfield;
      else
        rfields = prfield;
      if (el)
        {
          HOST_WIDE_INT anr;
          tree pr1 = fill_one_record (&el, TYPE_MIN_VALUE (TYPE_DOMAIN (type)), ptype1, fields1, asize + 1, &anr);
          if (pr1)
            CONSTRUCTOR_APPEND_ELT (rl, prfield, pr1);
        }
    }
  gcc_assert (!el);
  rtype = finish_struct (start_struct (RECORD_TYPE), rfields, 1);
  allocate_type_lang_specific (rtype);
  TYPE_LANG_CODE (rtype) = PASCAL_LANG_FAKE_ARRAY;
  TYPE_LANG_FAKE_ARRAY_ELEMENTS (rtype) = orig_el;
#ifndef EGCS97
  return build1 (NOP_EXPR, constructor_type, do_build_constructor_rev (rtype, rl));
#else
  return build1 (VIEW_CONVERT_EXPR, constructor_type, do_build_constructor_rev (rtype, rl));
#endif
}

/* Finish up at the end of a structure level of constructor.
   If we were outputting the elements as they are read, return 0
   from inner levels (process_init_element ignores that),
   but return error_mark_node from the outermost level
   (that's what we want to put in DECL_INITIAL).
   Otherwise, return a CONSTRUCTOR expression. */
static tree
pop_init_level (void)
{
  struct constructor_stack *p;
  tree constructor = NULL_TREE;

  p = constructor_stack;

  /* Warn when some struct elements are implicitly initialized to zero. */
  if (extra_warnings
      && constructor_type
      && TREE_CODE (constructor_type) == RECORD_TYPE
      && constructor_unfilled_fields)
    {
      push_member_name (constructor_unfilled_fields);
      RESTORE_SPELLING_DEPTH (constructor_depth);
    }

  /* Now output all pending elements. */
  output_pending_init_elements (1);

  /* Pad out the end of the structure. */

  if (p->replacement_value)
    /* If this closes a superfluous brace pair, just pass out the element between them. */
    constructor = p->replacement_value;
  else if (!constructor_type)
    ;
  else if (!STRUCTURED_TYPE (TREE_CODE (constructor_type)))
    {
      /* A scalar initializer -- just return the element, after
         verifying there is just one. */
#ifndef GCC_4_1
      gcc_assert (constructor_elements && !TREE_CHAIN (constructor_elements));
      constructor = TREE_VALUE (constructor_elements);
#else
      gcc_unreachable ();
#endif
    }
  else
    {
      if (constructor_erroneous)
        constructor = error_mark_node;
      else
        {
#ifndef EGCS97
          int momentary = suspend_momentary ();
#endif
          if (TREE_CODE (constructor_type) == ARRAY_TYPE
              && constructor_max_index
              && TREE_CODE (constructor_max_index) == INTEGER_CST
              && !tree_int_cst_lt (constructor_max_index, constructor_unfilled_index))
            error_or_warning (co->pascal_dialect & E_O_PASCAL, "too few initializers for array");
          if (TREE_CODE (constructor_type) == ARRAY_TYPE
               && PASCAL_TYPE_PACKED (constructor_type)
               && !is_string_compatible_type (constructor_type, 0)
               && count_bits (TREE_TYPE (constructor_type), NULL))
            constructor = fake_packed_array_constructor ();
          else
#ifndef GCC_4_1
            constructor = build_constructor (constructor_type, nreverse (constructor_elements));
#else
            constructor = build_constructor (constructor_type,
                                               constructor_elements);
#endif
          if (constructor_constant)
            {
              TREE_CONSTANT (constructor) = 1;
#ifdef GCC_4_0
              TREE_INVARIANT (constructor) = 1;
#endif
            }
          if (constructor_constant && constructor_simple)
            TREE_STATIC (constructor) = 1;
#ifndef EGCS97
          resume_momentary (momentary);
#endif
        }
    }

  constructor_type = p->type;
  constructor_fields = p->fields;
  constructor_index = p->index;
  constructor_range_end = p->range_end;
  constructor_max_index = p->max_index;
  constructor_unfilled_index = p->unfilled_index;
  constructor_unfilled_fields = p->unfilled_fields;
  constructor_elements = p->elements;
  constructor_constant = p->constant;
  constructor_simple = p->simple;
  constructor_erroneous = p->erroneous;
  constructor_pending_elts = p->pending_elts;
  constructor_depth = p->depth;
  RESTORE_SPELLING_DEPTH (constructor_depth);

  constructor_stack = p->next;
  free (p);

  if (constructor)
    return constructor;
  return error_mark_node;
}

/* Within an array initializer, specify the next index to be initialized.
   FIRST is that index. If LAST is nonzero, then initialize a range of
   indices, running from FIRST through LAST. */
static void
set_init_index (tree domain, tree first, tree last)
{
  first = convert_for_assignment (domain, probably_call_function (first), "array initializer index", NULL_TREE, 0);
  STRIP_NOPS (first);
  if (last)
    {
      last = convert_for_assignment (domain, probably_call_function (last), "array initializer index upper bound", NULL_TREE, 0);
      STRIP_NOPS (last);
    }
  if (EM (first) || (last && EM (last)))
    return;
  gcc_assert (constructor_unfilled_index);
  if (TREE_CODE (first) != INTEGER_CST)
    initializer_error ("nonconstant array index in initializer%s", " for `%s'");
  else if (last && TREE_CODE (last) != INTEGER_CST)
    initializer_error ("nonconstant array index in initializer%s", " for `%s'");
  else if (tree_int_cst_lt (first, constructor_unfilled_index))
    initializer_error ("duplicate array index in initializer%s", " for `%s'");
  else
    {
      constructor_index = convert (ssizetype, first);
      if (last && tree_int_cst_lt (last, first))
        initializer_error ("empty index range in initializer%s", " for `%s'");
      else
        constructor_range_end = last;
    }
}

/* Within a struct initializer, specify the next field to be initialized. */
static void
set_init_label (tree fieldname)
{
  tree tail;
  int passed = 0;
  gcc_assert (constructor_type);
  for (tail = TYPE_FIELDS (constructor_type); tail; tail = TREE_CHAIN (tail))
    {
      if (tail == constructor_unfilled_fields)
        passed = 1;
      if (DECL_NAME (tail) == fieldname)
        break;
    }
  if (!tail)
    error ("unknown field `%s' specified in initializer", IDENTIFIER_NAME (fieldname));
  else if (!passed)
    error ("field `%s' already initialized", IDENTIFIER_NAME (fieldname));
  else
    constructor_fields = tail;
}

static void
set_init_variant (tree fieldname)
{
  tree fieldlst = find_field (constructor_type, fieldname, 0);
  if (!fieldlst)
    error ("unknown field `%s' specified in initializer", IDENTIFIER_NAME (fieldname));
  else
    constructor_fields = TREE_VALUE (fieldlst);
}

tree
find_variant (tree value, tree variant_list)
{
  tree variant;
  if (TREE_CODE (value) != INTEGER_CST)
    error ("non-constant `case' selector");
  for (variant = variant_list; variant; variant = TREE_CHAIN (variant))
    {
      tree c = TREE_PURPOSE (variant);
      if (!c)  /* `otherwise' */
        break;
      while (c && !((!TREE_PURPOSE (c) && tree_int_cst_equal (TREE_VALUE (c), value))
                    || (TREE_PURPOSE (c)
                        && TREE_CODE (TREE_VALUE (c)) == INTEGER_CST
                        && TREE_CODE (TREE_PURPOSE (c)) == INTEGER_CST
                        && !const_lt (value, TREE_VALUE (c))
                        && !const_lt (TREE_PURPOSE (c), value))))
        c = TREE_CHAIN (c);
      if (c)
        break;
    }
  if (!variant)
    {
      error ("tag value does not match any variant");
      return NULL_TREE;
    }
  return TREE_VALUE (variant);
}

static void
process_otherwise (tree value)
{
  /* avoid inifinite loop */
  gcc_assert (TREE_CODE (constructor_max_index) == INTEGER_CST);
  gcc_assert (TREE_CODE (constructor_unfilled_index) == INTEGER_CST);
  while (!tree_int_cst_lt (constructor_max_index, constructor_unfilled_index))
    {
      constructor_index = constructor_unfilled_index;
      push_array_index (TREE_INT_CST_LOW (constructor_index));
      output_init_element (value, TREE_TYPE (constructor_type), constructor_index, 1);
      RESTORE_SPELLING_DEPTH (constructor_depth);
    }
}

/* Collect the next constructor element in a list from which we will make a CONSTRUCTOR.
   TYPE is the data type that the containing data type wants here.
   FIELD is the field (a FIELD_DECL) or the index that this element fills.
   PENDING if non-zero means output pending elements that belong
   right after this element. (PENDING is normally 1;
   it is 0 while outputting pending elements, to avoid recursion.) */
static void
output_init_element (tree value, tree type, tree field, int pending)
{
  int duplicate = 0;

  if (TREE_CODE (TREE_TYPE (value)) == FUNCTION_TYPE
      || (TREE_CODE (TREE_TYPE (value)) == ARRAY_TYPE
          && !(TREE_CODE (value) == STRING_CST
               && TREE_CODE (type) == ARRAY_TYPE
               && TYPE_IS_CHAR_TYPE (TREE_TYPE (type)))
          && !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (value)), TYPE_MAIN_VARIANT (type))))
    value = default_conversion (value);

  if (EM (value))
    constructor_erroneous = 1;
  else if (!TREE_CONSTANT (value))
    constructor_constant = 0;
  else if (!initializer_constant_valid_p (value, TREE_TYPE (value))
           || (RECORD_OR_UNION (TREE_CODE (constructor_type))
               && DECL_PACKED_FIELD (field)
               && TREE_CODE (value) != INTEGER_CST))
    constructor_simple = 0;

  if (EM (value))
    ;
  else if (require_constant_value && !TREE_CONSTANT (value))
    {
      initializer_error ("initializer element%s is not constant", " for `%s'");
      value = error_mark_node;
    }
  else if (require_constant_elements
           && !initializer_constant_valid_p (value, TREE_TYPE (value)))
    {
      initializer_error ("initializer element%s is not computable at load time", " for `%s'");
      value = error_mark_node;
    }

  /* If this element duplicates one on constructor_pending_elts, print a
     message and ignore it. Don't do this when we're processing elements taken
     off constructor_pending_elts, because we'd always get spurious errors. */
  if (pending)
    {
      if (RECORD_OR_UNION (TREE_CODE (constructor_type))
          && purpose_member (field, constructor_pending_elts))
        {
          initializer_error ("duplicate initializer%s", " for `%s'");
          duplicate = 1;
        }
      if (TREE_CODE (constructor_type) == ARRAY_TYPE)
        {
          tree tail;
          for (tail = constructor_pending_elts; tail; tail = TREE_CHAIN (tail))
            if (TREE_PURPOSE (tail)
                && TREE_CODE (TREE_PURPOSE (tail)) == INTEGER_CST
                && tree_int_cst_equal (TREE_PURPOSE (tail), constructor_index))
              break;

          if (tail)
            {
              initializer_error ("duplicate initializer%s", " for `%s'");
              duplicate = 1;
            }
        }
    }

  /* If this element doesn't come next in sequence,
     put it on constructor_pending_elts. */
  if (TREE_CODE (constructor_type) == ARRAY_TYPE
      && !tree_int_cst_equal (field, constructor_unfilled_index))
    {
      if (!duplicate)
        constructor_pending_elts = tree_cons (field,
          digest_init (type, value, require_constant_value), constructor_pending_elts);
    }
  else if (TREE_CODE (constructor_type) == RECORD_TYPE && field != constructor_unfilled_fields)
    {
      /* We do this for records but not for unions. In a union,
         no matter which field is specified, it can be initialized
         right away since it starts at the beginning of the union. */
      if (!duplicate)
        constructor_pending_elts = tree_cons (field,
          digest_init (type, value, require_constant_value), constructor_pending_elts);
    }
  else
    {
      /* Otherwise, output this element to constructor_elements. */
      if (!duplicate)
        {
          value = digest_init (type, value, require_constant_value);
          CONSTRUCTOR_APPEND_ELT (constructor_elements, field, value);
        }

      /* Advance the variable that indicates sequential elements output. */
      if (TREE_CODE (constructor_type) == ARRAY_TYPE)
        constructor_unfilled_index = size_binop (PLUS_EXPR, constructor_unfilled_index, ssize_int (1));
      else if (TREE_CODE (constructor_type) == RECORD_TYPE)
        constructor_unfilled_fields = TREE_CHAIN (constructor_unfilled_fields);
      else if (TREE_CODE (constructor_type) == UNION_TYPE)
        constructor_unfilled_fields = 0;

      /* Now output any pending elements which have become next. */
      if (pending)
        output_pending_init_elements (0);
    }
}

/* Output any pending elements which have become next.
   As we output elements, constructor_unfilled_{fields,index}
   advances, which may cause other elements to become next;
   if so, they too are output.

   If ALL is 0, we return when there are no more pending elements
   to output now.

   If ALL is 1, we output space as necessary so that
   we can output all the pending elements. */
static void
output_pending_init_elements (int all)
{
  tree tail, next;

 retry:

  /* Look thru the whole pending list. If we find an element that
     should be output now, output it. Otherwise, set NEXT to the
     element that comes first among those still pending. */

  next = 0;
  for (tail = constructor_pending_elts; tail; tail = TREE_CHAIN (tail))
    {
      if (TREE_CODE (constructor_type) == ARRAY_TYPE)
        {
          if (tree_int_cst_equal (TREE_PURPOSE (tail), constructor_unfilled_index))
            {
              output_init_element (TREE_VALUE (tail),
                                   TREE_TYPE (constructor_type),
                                   constructor_unfilled_index, 0);
              goto retry;
            }
          else if (tree_int_cst_lt (TREE_PURPOSE (tail), constructor_unfilled_index))
            ;
          else if (!next || tree_int_cst_lt (TREE_PURPOSE (tail), next))
            next = TREE_PURPOSE (tail);
        }
      else if (RECORD_OR_UNION (TREE_CODE (constructor_type)))
        {
          if (TREE_PURPOSE (tail) == constructor_unfilled_fields)
            {
              output_init_element (TREE_VALUE (tail), TREE_TYPE (constructor_unfilled_fields),
                                   constructor_unfilled_fields, 0);
              goto retry;
            }
          else if (!constructor_unfilled_fields
                   || tree_int_cst_lt (bit_position (TREE_PURPOSE (tail)),
                                       bit_position (constructor_unfilled_fields)))
            ;
          else if (!next || tree_int_cst_lt (bit_position (TREE_PURPOSE (tail)), bit_position (next)))
            next = TREE_PURPOSE (tail);

        }
    }

  /* Ordinarily return, but not if we want to output all
     and there are elements left. */
  if (!(all && next))
    return;

  if (TREE_CODE (constructor_type) == ARRAY_TYPE
      && constructor_max_index
      && TREE_CODE (constructor_max_index) == INTEGER_CST
      && !tree_int_cst_lt (constructor_max_index, constructor_unfilled_index))
    error_or_warning (co->pascal_dialect & E_O_PASCAL, "too few initializers for array");
  /* Just skip over the gap, so that after
     jumping to retry we will output the next successive element. */
  if (RECORD_OR_UNION (TREE_CODE (constructor_type)))
    constructor_unfilled_fields = next;
  else if (TREE_CODE (constructor_type) == ARRAY_TYPE)
    constructor_unfilled_index = convert (ssizetype, next);

  goto retry;
}

/* Add one non-braced element to the current constructor level.
   This adjusts the current position within the constructor's type.

   Once this has found the correct level for the new element,
   it calls output_init_element. */
static void
process_init_element (tree value)
{
  tree orig_value = value;
  int string_flag = TREE_CODE (value) == STRING_CST;

  /* Handle superfluous braces around string cst as in `char x[] = { "foo" };' */
  if (string_flag
      && constructor_type
      && TREE_CODE (constructor_type) == ARRAY_TYPE
      && TYPE_IS_CHAR_TYPE (TREE_TYPE (constructor_type))
      && integer_zerop (constructor_unfilled_index))
    {
      constructor_stack->replacement_value = value;
      return;
    }

  if (constructor_stack->replacement_value)
    {
      initializer_error ("excess elements in record initializer%s", " after `%s'");
      return;
    }

  /* Ignore elements of a brace group if it is entirely superfluous
     and has already been diagnosed. */
  if (!constructor_type)
    return;

  gcc_assert (value);
  if (RECORD_OR_UNION (TREE_CODE (constructor_type)) && PASCAL_TYPE_RECORD_VARIANTS (constructor_type))
    {
      tree fieldtype;
      enum tree_code fieldcode;

      if (!constructor_fields)
        {
          initializer_error ("excess elements in variant record initializer%s", " after `%s'");
          return;
        }

      fieldtype = TREE_TYPE (constructor_fields);
      if (!EM (fieldtype))
        fieldtype = TYPE_MAIN_VARIANT (fieldtype);
      fieldcode = TREE_CODE (fieldtype);

      /* Accept a string constant to initialize a subarray. */
      if (fieldcode == ARRAY_TYPE &&
          TYPE_IS_CHAR_TYPE (TREE_TYPE (fieldtype)) && string_flag)
        value = orig_value;

      if (!PASCAL_TYPE_SCHEMA (constructor_type))
        push_member_name (constructor_fields);
      output_init_element (value, fieldtype, constructor_fields, 1);
      RESTORE_SPELLING_DEPTH (constructor_depth);

      constructor_fields = 0;
    }
  else if (TREE_CODE (constructor_type) == RECORD_TYPE)
    {
      tree fieldtype;
      enum tree_code fieldcode;

      if (!constructor_fields)
        {
          initializer_error ("excess elements in record initializer%s", " after `%s'");
          return;
        }

      fieldtype = TREE_TYPE (constructor_fields);
      if (!EM (fieldtype))
        fieldtype = TYPE_MAIN_VARIANT (fieldtype);
      fieldcode = TREE_CODE (fieldtype);

      /* Accept a string constant to initialize a subarray. */
      if (fieldcode == ARRAY_TYPE &&
          TYPE_IS_CHAR_TYPE (TREE_TYPE (fieldtype)) && string_flag)
        value = orig_value;

      push_member_name (constructor_fields);
      output_init_element (value, fieldtype, constructor_fields, 1);
      RESTORE_SPELLING_DEPTH (constructor_depth);

      constructor_fields = TREE_CHAIN (constructor_fields);
    }
  else if (TREE_CODE (constructor_type) == ARRAY_TYPE)
    {
      tree elttype = TYPE_MAIN_VARIANT (TREE_TYPE (constructor_type));
      enum tree_code eltcode = TREE_CODE (elttype);

      /* Accept a string constant to initialize a subarray. */
      if (eltcode == ARRAY_TYPE &&
          TYPE_IS_CHAR_TYPE (TREE_TYPE (elttype)) && string_flag)
        value = orig_value;

      if (constructor_max_index && tree_int_cst_lt (constructor_max_index, constructor_index))
        {
          initializer_error ("excess elements in array initializer%s", " after `%s'");
          return;
        }

      /* In the case of [LO .. HI] = VALUE, only evaluate VALUE once. */
      if (constructor_range_end)
        {
          if (constructor_max_index && tree_int_cst_lt (constructor_max_index, constructor_range_end))
            {
              initializer_error ("excess elements in array initializer%s", " after `%s'");
              constructor_range_end = constructor_max_index;
            }
          value = save_expr (value);
        }

      /* Now output the actual element. Ordinarily, output once.
         If there is a range, repeat it till we advance past the range. */
      do
        {
          push_array_index (TREE_INT_CST_LOW (constructor_index));
          output_init_element (value, elttype, constructor_index, 1);
          RESTORE_SPELLING_DEPTH (constructor_depth);
          constructor_index = size_binop (PLUS_EXPR, constructor_index, ssize_int (1));
          /* avoid inifinite loop */
          gcc_assert (!constructor_range_end || TREE_CODE (constructor_range_end) == INTEGER_CST);
          gcc_assert (TREE_CODE (constructor_index) == INTEGER_CST);
        }
      while (constructor_range_end && !tree_int_cst_lt (constructor_range_end, constructor_index));
    }
  else
    {
      /* Handle the sole element allowed in a braced initializer for a scalar variable. */
      if (!constructor_fields)
        {
          initializer_error ("excess elements in scalar initializer%s", " after `%s'");
          return;
        }

      output_init_element (value, constructor_type, NULL_TREE, 1);
      constructor_fields = 0;
    }
}
