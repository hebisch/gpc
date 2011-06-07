/*Pascal statements.

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

#define RTS_CONSTANT(NAME, VALUE) NAME = VALUE,
enum {
#include "rts/constants.def"
  RTS_CONSTANT_DUMMY
};

/* Work-around for bug with `for' loops on AIX with gcc-2.x */
#ifdef EGCS97
#define FOR_BUG_OK
#endif

static tree check_for_control_variable (tree);
static void init_record (tree, int, int, tree);
static void call_no_args (tree, int);
static const char *start_dummy_file_name (void);
static void end_dummy_file_name (const char *);

/* Like expand_expr_stmt, but defer the statement if called from a global
   declaration. @@ This is probably a kludge, it might be better to collect all
   statements and emit them per routine or so. (Probably after dropping gcc-2
   support.) */
void
expand_expr_stmt1 (tree stmt)
{
  if (!current_function_decl)
    deferred_initializers = tree_cons (stmt, NULL_TREE, deferred_initializers);
  else
    expand_expr_stmt (stmt);
}

/* Expand an `asm' statement with operands, handling output operands
   that are not variables or INDIRECT_REFs by transforming such
   cases into cases that expand_asm_operands can handle. */
void
pascal_expand_asm_operands (tree string, tree outputs, tree inputs, tree clobbers, int vol)
{
  int noutputs = list_length (outputs), i;
  /* o[I] is the place that output number I should be written.
     `+1' is just to avoid a possible 0 allocation. */
  tree *o = (tree *) alloca (noutputs * sizeof (tree) + 1);
  tree tail;

  if (PEDANTIC (GNU_PASCAL))
    {
      if (co->pascal_dialect & B_D_M_PASCAL)
        gpc_warning ("GPC and Borland Pascal have different `asm' syntax");
#if 0
      else
        chk_dialect ("`asm' is", B_D_M_PASCAL);
#endif
    }

  string = combine_strings (string, 2);
  gcc_assert (TREE_CODE (string) == STRING_CST);

  /* Record the contents of OUTPUTS before it is modified. */
  for (i = 0, tail = outputs; tail; tail = TREE_CHAIN (tail), i++)
    {
      o[i] = TREE_VALUE (tail);
      if (!mark_lvalue (TREE_VALUE (tail), "modification by `asm'", 1))
        return;
    }

  for (tail = inputs; tail; tail = TREE_CHAIN (tail))
    {
      TREE_VALUE (tail) = string_may_be_char (TREE_VALUE (tail), 0);
      if (TREE_CODE (TREE_VALUE (tail)) == INTEGER_CST)
        TREE_VALUE (tail) = convert (integer_type_node, TREE_VALUE (tail));
    }

#ifdef EGCS97
  /* Convert arguments to the form expected by expand_asm_operands.
     @@ After support for gcc-2.x has been dropped, change parse.y
        to create this form (and support the syntax extensions),
        and remove this kludge here. */
  for (tail = inputs; tail; tail = TREE_CHAIN (tail))
    TREE_PURPOSE (tail) = build_tree_list (NULL_TREE, TREE_PURPOSE (tail));
  for (tail = outputs; tail; tail = TREE_CHAIN (tail))
    TREE_PURPOSE (tail) = build_tree_list (NULL_TREE, TREE_PURPOSE (tail));
#endif

  /* Generate the ASM_OPERANDS insn; store into the TREE_VALUEs of OUTPUTS
     some trees for where the values were actually stored. */
  /* @@@ This is incompatible with C: it loses distinction between
     asm ('foo') and asm('foo':) */
  if (outputs || inputs || clobbers)
#ifndef GCC_3_4
    expand_asm_operands (string, outputs, inputs, clobbers, vol, input_filename, lineno);
#else
    {
      location_t loc_aux;
      loc_aux.file = input_filename;
      loc_aux.line = lineno;
      expand_asm_operands (string, outputs, inputs, clobbers, vol, loc_aux);
    }
#endif
  else
#ifdef EGCS97
    expand_asm (string, 1);  /* Simple asm statements are treated as volatile. */
#else
    expand_asm (string);
#endif

  /* Copy all the intermediate outputs into the specified outputs.
     (expand_asm_operands may have changed TREE_VALUE (...)). */
  for (i = 0, tail = outputs; tail; tail = TREE_CHAIN (tail), i++)
    {
      if (o[i] != TREE_VALUE (tail))
        {
          expand_expr_stmt (build_modify_expr (o[i], NOP_EXPR, TREE_VALUE (tail)));
          free_temp_slots ();
        }
      if (ORDINAL_TYPE (TREE_CODE (TREE_TYPE (o[i]))))
        {
          tree t = TREE_TYPE (o[i]), b = base_type (t);
          if (b != t)
            {
              tree c = convert (b, o[i]), rc = range_check (t, c);
              if (rc != c)
                {
                  TREE_SIDE_EFFECTS (rc) = 1;  /* @@ ? */
                  expand_expr_stmt (convert (void_type_node, rc));
                }
            }
        }
    }
}

/* Mark that we are using target as an lvalue and give warnings and
   errors as necessary.
   @@ For COMPONENT_REFs, we should rather flag the fields and look
      at the end of the function whether all fields were assigned.
      -- Will this work? What about arrays? */
int
mark_lvalue (tree target, const char *description, int modification)
{
  tree t, t0, type;

  while (TREE_CODE (target) == COMPOUND_EXPR)
    target = TREE_OPERAND (target, 1);

  /* See build_pascal_packed_array_ref()! */
  if (TREE_CODE (target) == NON_LVALUE_EXPR && PASCAL_TREE_PACKED (target))
    {
      gcc_assert (TREE_CODE (TREE_OPERAND (target, 1)) == TREE_LIST);
      target = TREE_PURPOSE (TREE_OPERAND (target, 1));
    }

  t = target;
  type = TREE_TYPE (target);
  while (TREE_CODE (t) == NOP_EXPR
         || TREE_CODE (t) == CONVERT_EXPR
         || TREE_CODE (t) == COMPONENT_REF
         || TREE_CODE (t) == ARRAY_REF
         || TREE_CODE (t) == BIT_FIELD_REF
         || TREE_CODE (t) == PASCAL_BIT_FIELD_REF)
    t = TREE_OPERAND (t, 0);

  t0 = t;
  if (TREE_CODE (t0) == INDIRECT_REF)
    {
      t0 = TREE_OPERAND (t0, 0);
      while (TREE_CODE (t0) == NOP_EXPR || TREE_CODE (t0) == CONVERT_EXPR)
        t0 = TREE_OPERAND (t0, 0);
      if (TREE_CODE (TREE_TYPE (t0)) != REFERENCE_TYPE)
        t0 = t;
    }
  if (modification && TREE_CODE (t0) == VAR_DECL)
    PASCAL_VALUE_ASSIGNED (t0) = 1;

  if (TREE_CODE (target) == COMPONENT_REF
      && PASCAL_TREE_DISCRIMINANT (TREE_OPERAND (target, 1)))
    {
      error ("%s of schema discriminant", description);
      return 0;
    }
  else if (TREE_CODE (t) == VAR_DECL && PASCAL_FOR_LOOP_COUNTER (t))
    {
      if (co->pascal_dialect & B_D_M_PASCAL)
        gpc_warning ("%s of `for' loop counter", description);
      else
        {
          error ("%s of `for' loop counter", description);
          return 0;
        }
    }
  else if (TREE_CONSTANT (t) || (modification && (TREE_READONLY (target) || TYPE_READONLY (type))))
    {
      t = target;
      while (TREE_CODE (t) == NOP_EXPR
             || TREE_CODE (t) == CONVERT_EXPR
             || ((TREE_CODE (t) == COMPONENT_REF || TREE_CODE (t) == ARRAY_REF)
                 && (TREE_READONLY (TREE_OPERAND (t, 0))
                     || TYPE_READONLY (TREE_TYPE (TREE_OPERAND (t, 0))))))
        t = TREE_OPERAND (t, 0);
      if (TREE_CODE (t) == VAR_DECL)
        error ("%s of read-only variable `%s'",
               description, IDENTIFIER_NAME (DECL_NAME (t)));
      else if (TREE_CODE (t) == PARM_DECL)
        error ("%s of protected parameter `%s'",
               description, IDENTIFIER_NAME (DECL_NAME (t)));
      else if (TREE_CODE (t) == COMPONENT_REF)
        error ("%s of read-only field `%s'",
               description, IDENTIFIER_NAME (DECL_NAME (TREE_OPERAND (t, 1))));
      else
        error ("%s of read-only location", description);
      return 0;
    }
  else if (modification && (co->warn_typed_const || PEDANTIC (B_D_M_PASCAL)))
    {
      while (TREE_CODE (target) == COMPONENT_REF || TREE_CODE (target) == ARRAY_REF)
        target = TREE_OPERAND (target, 0);
      if (TREE_CODE (target) == VAR_DECL && PASCAL_DECL_TYPED_CONST (target))
        {
          static int informed = 0;
          if (PEDANTIC (B_D_M_PASCAL))
            {
              error ("%s: typed const misused as initialized variable", description);
              return 0;
            }
          else
            gpc_warning ("%s: typed const misused as initialized variable", description);
          if (!informed)
            {
              gpc_warning (" (Better use ISO 10206 Extended Pascal initialized");
              gpc_warning (" types and variables: `var foo: integer value 7'.)");
              informed = 1;
            }
        }
    }
  return 1;
}

int
check_reference_parameter (tree val, int protected)
{
  if (!mark_lvalue (val, "reference parameter passing", !protected))
    return 0;
  if (TREE_CODE (val) == COMPONENT_REF)
    {
      tree r = TREE_TYPE (TREE_OPERAND (val, 0));
      if ((co->pascal_dialect & C_E_O_PASCAL)
          && PASCAL_TYPE_VARIANT_RECORD (r)
          && TREE_VALUE (TREE_PURPOSE (TYPE_LANG_VARIANT_TAG (r))) == TREE_OPERAND (val, 1))
        {
          error ("in ISO Pascal variant record selector cannot be passed by reference");
          return 0;
        }
    }
  return 1;
}

/* Expand a `Return' statement.
   RETVAL is the expression for what to return,
   or a null pointer for `Return' with no value. */
void
expand_return_statement (tree retval)
{
  tree valtype = TREE_TYPE (TREE_TYPE (current_function_decl));
  if (TREE_THIS_VOLATILE (current_function_decl))
    gpc_warning ("routine declared `noreturn' returns");
  /* This must be done before returning, otherwise it would jump over it. */
  cleanup_routine ();
  if (!retval)
    {
      if (valtype && TREE_CODE (valtype) != VOID_TYPE)
        error ("`Return' with no value in a function");
      expand_null_return ();
    }
  else if (!valtype || TREE_CODE (valtype) == VOID_TYPE)
    {
      error ("`Return' with a value in a procedure");
      expand_null_return ();
    }
  else
    {
      tree res = DECL_RESULT (current_function_decl);
      tree t = convert_for_assignment (valtype, retval, "`Return'", NULL_TREE, 0);
      if (EM (t))
        return;
      t = build (MODIFY_EXPR, TREE_TYPE (res), res, convert (TREE_TYPE (res), t));
      TREE_SIDE_EFFECTS (t) = 1;
      expand_return (t);
    }
}

/* Start a `case' statement, testing expression `exp'.
   Return the previous value of current_case_values. */
tree
pascal_expand_start_case (tree exp)
{
  tree type, index, old_ccv = current_case_values;
  exp = string_may_be_char (exp, 0);
  if (!ORDINAL_TYPE (TREE_CODE (TREE_TYPE (exp))))
    {
      if (!EM (exp))
        error ("`case' selector is not of ordinal type");
      current_case_values = error_mark_node;
      return old_ccv;
    }
  current_case_values = build_tree_list (NULL_TREE, exp);
  exp = default_conversion (exp);
  type = TREE_TYPE (exp);
  index = get_unwidened (exp, NULL_TREE);
  /* We can't strip a conversion from a signed type to an unsigned,
     because if we did, int_fits_type_p would do the wrong thing
     when checking case values for being in range,
     and it's too hard to do the right thing. */
  if (TYPE_UNSIGNED (type) == TYPE_UNSIGNED (TREE_TYPE (index)))
    exp = index;
  CHK_EM (exp);
  expand_start_case (1, exp, type, "`case' statement");
  return old_ccv;
}

void
pascal_pushcase (tree constants)
{
  tree type;
  if (EM (current_case_values))
    return;
  type = TYPE_MAIN_VARIANT (TREE_TYPE (TREE_VALUE (current_case_values)));
  for (; constants; constants = TREE_CHAIN (constants))
    {
      tree lo = TREE_VALUE (constants), hi = TREE_PURPOSE (constants);
      STRIP_TYPE_NOPS (lo);
      if (hi)
        STRIP_TYPE_NOPS (hi);
      if (EM (lo) || (hi && EM (hi)))
        ;
      else if (TREE_CODE (lo) != INTEGER_CST)
        {
          if (hi)
            {
              error ("lower value of `case' range does not reduce to");
              error (" a constant of ordinal type");
            }
          else
            error ("`case' constant does not reduce to a constant of ordinal type");
        }
      else if (hi && TREE_CODE (hi) != INTEGER_CST)
        {
          error ("upper value of `case' range does not reduce to");
          error (" a constant of ordinal type");
        }
      else if (!comptypes (type, TYPE_MAIN_VARIANT (TREE_TYPE (lo))))
        {
          if (hi)
            error ("type mismatch in lower value of `case' range");
          else
            error ("type mismatch in `case' element");
        }
      else if (hi && !comptypes (type, TYPE_MAIN_VARIANT (TREE_TYPE (hi))))
        error ("type mismatch in upper value of `case' range");
      else
        {
          if (!hi)
            hi = lo;
          if (co->pascal_dialect & B_D_PASCAL)
            {
              tree t;
              for (t = TREE_PURPOSE (current_case_values); t && lo; t = TREE_CHAIN (t))
                {
                  tree clo = TREE_VALUE (t), chi = TREE_PURPOSE (t);
                  if (!const_lt (hi, clo) && !const_lt (chi, lo))
                    {
                      tree elo = lo, ehi = hi, nlo = NULL_TREE, nhi = NULL_TREE;
                      if (const_lt (lo, clo))
                        nhi = fold (build (MINUS_EXPR, TREE_TYPE (clo), (elo = clo), convert (TREE_TYPE (clo), integer_one_node)));
                      if (const_lt (chi, hi))
                        nlo = fold (build (PLUS_EXPR, TREE_TYPE (chi), (ehi = chi), convert (TREE_TYPE (chi), integer_one_node)));
                      if (tree_int_cst_equal (elo, ehi))
                        gpc_warning ("duplicate `case' element %ld", (long) TREE_INT_CST_LOW (elo));
                      else
                        gpc_warning ("duplicate `case' range %ld .. %ld", (long) TREE_INT_CST_LOW (elo), (long) TREE_INT_CST_LOW (ehi));
                      if (!nlo && !nhi)
                        lo = hi = NULL_TREE;
                      else
                        {
                          if (nlo && nhi)
                            pascal_pushcase (build_tree_list (nhi, lo));
                          if (nlo)
                            lo = nlo;
                          else if (nhi)
                            hi = nhi;
                        }
                    }
                }
              if (lo)
                TREE_PURPOSE (current_case_values) = tree_cons (hi, lo, TREE_PURPOSE (current_case_values));
            }
          if (lo)
            {
              /* Clip to the expression range. Out of range case-values don't matter anyway. But note empty ranges. */
              if (const_lt (hi, lo))
                error ("empty `case' range");
              if (const_lt (lo, TYPE_MIN_VALUE (type)))
                lo = TYPE_MIN_VALUE (type);
              if (const_lt (TYPE_MAX_VALUE (type), hi))
                hi = TYPE_MAX_VALUE (type);
              if (!const_lt (hi, lo))
                {
                  tree label = build_decl (LABEL_DECL, NULL_TREE, NULL_TREE), duplicate;
                  int success = pushcase_range (lo, hi, convert_and_check, label, &duplicate);
                  if (success == 2)
                    {
                      error ("duplicate case-constant in `case' statement");
                      error_with_decl (duplicate, " this is the first entry for that constant");
                    }
                  else if (success == 3)
                    error ("`case' constant out of range");
                  else if (success == 4)
                    error ("empty `case' range");
                  else if (success == 5)
                    abort_confused ();  /* fjf511.pas */
                  else
                    gcc_assert (success == 0);
                }
            }
        }
    }
}

/* `for' loops */

/* Check a `for' loop control variable */
static tree
check_for_control_variable (tree var)
{
  CHK_EM (var);

  if (PASCAL_TYPE_RESTRICTED (TREE_TYPE (var)))
    error ("`for' loop counter must not be restricted");

  if (TREE_CODE (var) == VAR_DECL && PASCAL_VALUE_ASSIGNED_SUBROUTINE (var))
    error_or_warning (co->pascal_dialect & C_E_O_PASCAL,
      "`for' loop counter is threatened in a subroutine");

  if (TREE_CODE (var) != VAR_DECL)
    chk_dialect ("`for' loop counters that are not entire variables are", B_D_M_PASCAL);
  /* ISO Pascal wants VAR to be in the closest possible scope.
     Borland Pascal also allows global variables. */
  else if (DECL_CONTEXT (var) != current_function_decl
           && (DECL_CONTEXT (var) ||
               !((co->pascal_dialect & B_D_PASCAL)
                 || (current_function_decl && DECL_ARTIFICIAL (current_function_decl)))))
    chk_dialect ("`for' loop counter not declared in the closest possible scope are", GNU_PASCAL);

  if (!ORDINAL_TYPE (TREE_CODE (TREE_TYPE (var)))
      && !(co->pointer_arithmetic && TREE_CODE (TREE_TYPE (var)) == POINTER_TYPE))
    {
      error ("`for' loop counter must be of ordinal type");
      if (TREE_CODE (TREE_TYPE (var)) == POINTER_TYPE)
        ptrarith_inform ();
      var = error_mark_node;
    }
  return var;
}

/* Allocate a temporary VAR_DECL for the loop upper bound and
   store the expression there.

   Both the lower and upper bounds must be evaluated before the `for' loop
   control variable is assigned. if not, the following does not work:

      for i := i + 1 to i + 10 do

   So allocate another temporary variable for the lower bound ...

   @@ Why doesn't it work like `tmp := i + 10; i := i + 1; ...'
      with only one temporary variable? -- Frank */
tree
start_for_loop (tree counter, tree low, tree high, enum tree_code direction)
{
#ifndef FOR_BUG_OK
  tree tempvar;
#endif
  DEREFERENCE_SCHEMA (counter);
  low = string_may_be_char (low, 1);
  high = string_may_be_char (high, 1);
  if (!lvalue_or_else (counter, "`for' loop") || EM (low) || EM (high))
    counter = error_mark_node;
  else if (!comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (low)), TYPE_MAIN_VARIANT (TREE_TYPE (high))))
    {
      error ("`for' loop bounds are of incompatible type");
      counter = error_mark_node;
    }
  counter = check_for_control_variable (counter);
  CHK_EM (counter);

  if (!TREE_CONSTANT (low))
    {
      tree t = low;
      low = make_new_variable ("for_lower", TREE_TYPE (counter));
      /* Assign the lower bound to temp */
      expand_expr_stmt (build_modify_expr (low, NOP_EXPR, t));
    }

  if (TREE_CONSTANT (high))
    high = convert_and_check (TREE_TYPE (counter), high);
  else
    {
      tree t = high;
      high = make_new_variable ("for_upper", TREE_TYPE (counter));
      expand_expr_stmt (build_modify_expr (high, NOP_EXPR, t));
    }

  /* necessary to prevent infinite loops when incrementing/decrementing
     would cause wrap-around at maxint/-maxint etc. */
  expand_start_cond (build_implicit_pascal_binary_op (direction, low, high), 0);

  expand_expr_stmt (build_modify_expr (counter, NOP_EXPR, low));
#ifdef FOR_BUG_OK
  expand_start_loop_continue_elsewhere (1);
#else
  tempvar = make_new_variable ("for_temp", boolean_type_node);
  expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, boolean_false_node));
  expand_start_loop (1);
  expand_start_cond (tempvar, 0);
  expand_exit_loop_if_false (0, fold (build_pascal_binary_op (NE_EXPR, counter, high)));
  if (TREE_CODE (TREE_TYPE (counter)) != POINTER_TYPE && TREE_CODE (TREE_TYPE (counter)) != INTEGER_TYPE)
    counter = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (counter)), TYPE_UNSIGNED (TREE_TYPE (counter))), counter);
  expand_expr_stmt (build_modify_expr (counter, direction == GE_EXPR ? MINUS_EXPR : PLUS_EXPR, integer_one_node));
  expand_end_cond ();
  expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, boolean_true_node));
#endif
  if (TREE_CODE (counter) == VAR_DECL)
    PASCAL_FOR_LOOP_COUNTER (counter) = 1;
  return build_tree_list (high, counter);
}

void
finish_for_loop (tree counter_and_high, enum tree_code direction ATTRIBUTE_UNUSED)
{
  tree counter;
  if (EM (counter_and_high))
    return;
  counter = TREE_VALUE (counter_and_high);
  if (TREE_CODE (counter) == VAR_DECL)
    PASCAL_FOR_LOOP_COUNTER (counter) = 0;
#ifdef FOR_BUG_OK
  expand_loop_continue_here ();
  expand_exit_loop_if_false (0, fold (build_implicit_pascal_binary_op (direction == LE_EXPR ? LT_EXPR : GT_EXPR, counter, TREE_PURPOSE (counter_and_high))));
  if (TREE_CODE (TREE_TYPE (counter)) != POINTER_TYPE && TREE_CODE (TREE_TYPE (counter)) != INTEGER_TYPE)
    counter = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (counter)), TYPE_UNSIGNED (TREE_TYPE (counter))), counter);
  expand_expr_stmt (build_modify_expr (counter, direction == GE_EXPR ? MINUS_EXPR : PLUS_EXPR, integer_one_node));
#endif
  expand_end_loop ();
  expand_end_cond ();
}

/* Set member iteration. For now, translate it to something like:
   for MyVar := Low (MySet) to High (MySet) do
     if MyVar in MySet then <body>; */
tree
start_for_set_loop (tree counter, tree expr)
{
  tree set_type = NULL_TREE;
  int empty_set = 0;
  DEREFERENCE_SCHEMA (counter);
  chk_dialect ("set member iteration is", E_O_PASCAL);
  if (!lvalue_or_else (counter, "`for' loop"))
    counter = error_mark_node;
  counter = check_for_control_variable (counter);
  CHK_EM (counter);

  /* Make a set out of a set constructor */
  if (TREE_CODE (expr) == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (TREE_TYPE (expr)) == SET_TYPE)
    expr = construct_set (expr, NULL_TREE, 0);
  if (TREE_CODE (TREE_TYPE (expr)) != SET_TYPE)
    {
      error ("operand of `for ... in' is not a set");
      empty_set = 1;
    }
  else if (TREE_TYPE (expr) == empty_set_type_node)
    {
      gpc_warning ("`for ... in []' (empty set) has no effect");
      /* Be as silent as possible to give the optimizer a chance to remove the whole loop. */
      empty_set = 1;
    }
  else
    gcc_assert (TREE_TYPE (TREE_TYPE (expr)));
  if (empty_set)
    {
      expand_start_cond (boolean_false_node, 0);
      /* We need a dummy loop so that `Break' and `Continue' within the loop behave correctly. */
      expand_start_loop (1);
    }
  else
    {
#ifndef FOR_BUG_OK
      tree counter1, tempvar;
#endif
      tree set_domain, set_var;
      set_type = TREE_TYPE (expr);
      set_domain = TYPE_DOMAIN (set_type);
      gcc_assert (set_domain);
      set_var = make_new_variable ("for_set", set_type);
      expand_expr_stmt (build_modify_expr (set_var, NOP_EXPR, expr));
      expand_expr_stmt (build_modify_expr (counter, NOP_EXPR,
        convert (TREE_TYPE (set_type), TYPE_MIN_VALUE (set_domain))));
#ifdef FOR_BUG_OK
      expand_start_loop_continue_elsewhere (1);
#else
      tempvar = make_new_variable ("for_temp", boolean_type_node);
      expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, boolean_false_node));
      expand_start_loop (1);
      expand_start_cond (tempvar, 0);
      expand_exit_loop_if_false (0, fold (build_pascal_binary_op (NE_EXPR, counter,
        convert (TREE_TYPE (set_type), TYPE_MAX_VALUE (set_domain)))));
      counter1 = counter;
      if (TREE_CODE (TREE_TYPE (counter1)) != POINTER_TYPE && TREE_CODE (TREE_TYPE (counter1)) != INTEGER_TYPE)
        counter1 = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (counter1)),
          TYPE_UNSIGNED (TREE_TYPE (counter1))), counter1);
      expand_expr_stmt (build_modify_expr (counter1, PLUS_EXPR, integer_one_node));
      expand_end_cond ();
      expand_expr_stmt (build_modify_expr (tempvar, NOP_EXPR, boolean_true_node));
#endif
      expand_start_cond (build_pascal_binary_op (IN_EXPR, counter, set_var), 0);
    }
  if (TREE_CODE (counter) == VAR_DECL)
    PASCAL_FOR_LOOP_COUNTER (counter) = 1;
  return set_type;
}

void
finish_for_set_loop (tree counter, tree set_type)
{
  if (set_type && EM (set_type))
    return;
  if (TREE_CODE (counter) == VAR_DECL)
    PASCAL_FOR_LOOP_COUNTER (counter) = 0;
  if (set_type)
    {
      expand_end_cond ();
#ifdef FOR_BUG_OK
      expand_loop_continue_here ();
      expand_exit_loop_if_false (0, fold (build_implicit_pascal_binary_op (LT_EXPR, counter,
        convert (TREE_TYPE (set_type), TYPE_MAX_VALUE (TYPE_DOMAIN (set_type))))));
      if (TREE_CODE (TREE_TYPE (counter)) != POINTER_TYPE && TREE_CODE (TREE_TYPE (counter)) != INTEGER_TYPE)
        counter = convert (type_for_size (TYPE_PRECISION (TREE_TYPE (counter)), TYPE_UNSIGNED (TREE_TYPE (counter))), counter);
      expand_expr_stmt (build_modify_expr (counter, PLUS_EXPR, integer_one_node));
#endif
      expand_end_loop ();
    }
  else
    {
      expand_end_loop ();
      expand_end_cond ();
    }
}

/* For `New': Assign values to tag fields of a variant record. */
tree
assign_tags (tree record, tree tags)
{
  tree field = record, value, selector_field, tag_info, expr = NULL_TREE;
  while (tags)
    {
      tree tag_type, next_field;
      if (!PASCAL_TYPE_VARIANT_RECORD (TREE_TYPE (field)))
        {
          error ("too many arguments to `New'");
          break;
        }
      tag_info = TYPE_LANG_VARIANT_TAG (TREE_TYPE (field));
      selector_field = TREE_VALUE (TREE_PURPOSE (tag_info));
      tag_type = TREE_PURPOSE (TREE_PURPOSE (tag_info));
      value = string_may_be_char (TREE_VALUE (tags), 0);
      if (!comptypes (TYPE_MAIN_VARIANT (tag_type), TYPE_MAIN_VARIANT (TREE_TYPE (value))))
        {
          error ("tag value has incorrect type");
          break;
        }
      next_field = find_variant (value, TREE_PURPOSE (TREE_VALUE (tag_info)));
      if (selector_field && !PASCAL_TYPE_INITIALIZER_VARIANTS (TREE_TYPE (field)))
        {
          tree init = TYPE_GET_INITIALIZER (TREE_TYPE (field)), t;
          if (init)
            for (t = TREE_VALUE (init); t; t = TREE_CHAIN (t))
              if (!TREE_PURPOSE (TREE_PURPOSE (t)) && TREE_VALUE (TREE_PURPOSE (t)) == DECL_NAME (selector_field))
                {
                  tree v = TREE_VALUE (t);
                  if (TREE_CODE (v) == INTEGER_CST && find_variant (v, TREE_PURPOSE (TREE_VALUE (tag_info))) != next_field)
                    error ("variant doesn't match initializer");
                  /* @@ runtime check for schemata */
                }
        }
      if (!next_field)
        break;
      if (selector_field)
        {
          tree new_expr;
          /* schemata shouldn't get here in `New' */
          gcc_assert (TREE_CODE (selector_field) == FIELD_DECL);
          new_expr = build_modify_expr (
            build_component_ref (record, DECL_NAME (selector_field)), NOP_EXPR, value);
          if (!expr)
            expr = new_expr;
          else
            expr = build (COMPOUND_EXPR, TREE_TYPE (new_expr), expr, new_expr);
        }
      tags = TREE_CHAIN (tags);
      field = next_field;
    }
  return expr;
}

/* Subroutine of init_any */
static void
init_record (tree thing, int the_end, int implicit, tree base)
{
  tree field;
  for (field = TYPE_FIELDS (TREE_TYPE (thing)); field; field = TREE_CHAIN (field))
    if (DECL_NAME (field))
      {
        tree comp_ref;
        if (PASCAL_FIELD_SHADOWED (field))
           /* No need to recurse. Avoid `find_field' */
#ifndef GCC_4_0
           comp_ref = fold (build (COMPONENT_REF, TREE_TYPE (field),
                                    base, field));
#else
           comp_ref = fold (build3 (COMPONENT_REF, TREE_TYPE (field),
                                    base, field, NULL_TREE));
#endif
        else
          comp_ref = build_component_ref_no_schema_dereference (base,
                        DECL_NAME (field), 1);
        init_any (comp_ref, the_end, implicit);
      }
    else if (RECORD_OR_UNION (TREE_CODE (TREE_TYPE (field))))
      init_record (field, the_end, implicit, base);
    else
      gcc_unreachable ();
}

/* Return nonzero if TYPE contains a file. */
int
contains_file_p (tree type)
{
  if (!type)
    return 0;
  switch (TREE_CODE (type))
  {
    case ARRAY_TYPE:
      return contains_file_p (TREE_TYPE (type));
    case RECORD_TYPE:
    case UNION_TYPE:
    case QUAL_UNION_TYPE:
      {
        tree field;
        if (PASCAL_TYPE_FILE (type))
          return 1;
        for (field = TYPE_FIELDS (type); field; field = TREE_CHAIN (field))
          {
            tree inner_type = TREE_TYPE (field);
            gcc_assert (DECL_NAME (field) || RECORD_OR_UNION (TREE_CODE (inner_type)));
            if (contains_file_p (inner_type))
              return 1;
          }
        break;
      }
    default:
      break;
  }
  return 0;
}

/* Return nonzero if TYPE contains a file, schema or object
   that needs to be initialized. */
int
contains_auto_initialized_part (tree type, int the_end)
{
  switch (TREE_CODE (type))
  {
    case ARRAY_TYPE:
      return contains_auto_initialized_part (TREE_TYPE (type), the_end);
    case RECORD_TYPE:
    case UNION_TYPE:
    case QUAL_UNION_TYPE:
      {
        tree field;

        /* @@ Objects (especially OOE style) and undiscriminated strings
              will need auto-finalization in the future. */
        if (PASCAL_TYPE_FILE (type)
            || (!the_end && (PASCAL_TYPE_STRING (type) || PASCAL_TYPE_SCHEMA (type) || PASCAL_TYPE_OBJECT (type))))
          return 1;

        if (!the_end && PASCAL_TYPE_VARIANT_RECORD (type) && PASCAL_TYPE_INITIALIZER_VARIANTS (type)
            && TREE_VALUE (TREE_PURPOSE (TYPE_LANG_VARIANT_TAG (type))))
          return 1;

        for (field = TYPE_FIELDS (type); field; field = TREE_CHAIN (field))
          if (contains_auto_initialized_part (TREE_TYPE (field), the_end))
            return 1;
        break;
      }
    default:
      break;
  }
  return 0;
}

/* Un-/initialize all types that need it, recursing through structured types.
   the_end is nonzero if this is called to clean up at the end of a block. */
void
init_any (tree thing, int the_end, int implicit)
{
  tree type = TREE_TYPE (thing);
  int was_used = TREE_USED (thing);

  if (TREE_CODE (TREE_TYPE (thing)) == REFERENCE_TYPE && !PASCAL_PROCEDURAL_TYPE (TREE_TYPE (thing))
      && implicit && TREE_CODE (thing) == VAR_DECL)
    {
      build_predef_call (the_end ? p_Dispose : p_New, build_tree_list (NULL_TREE,
        convert (build_pointer_type (TREE_TYPE (TREE_TYPE (thing))), thing)));
      return;  /* New/Dispose calls init_any again */
    }

  /* A subroutine is what is between the declaration and initialization of a variable. */
  if (implicit && TREE_CODE (thing) == VAR_DECL && !the_end)
    PASCAL_VALUE_ASSIGNED_SUBROUTINE (thing) |= PASCAL_VALUE_ASSIGNED (thing);

  /* Do not initialize/finalize readonly variables. `external' variables can be
     initialized explicitly with `Initialize', so this is not prevented here. */
  if (TREE_CODE (thing) == VAR_DECL && TREE_READONLY (thing))
    return;

  /* Check whether type really needs initialization, to prevent, e.g.,
     creating empty loops for arrays that don't. */
  if (!contains_auto_initialized_part (type, the_end))
    return;

  /* Backend would crash */
  if (!current_function_decl)
    {
      error ("cannot evaluate this expression from a global declaration");
      return;
    }

  if (TREE_CODE (thing) == VAR_DECL && !DECL_ARTIFICIAL (thing))
#ifndef GCC_3_4
    emit_line_note (DECL_SOURCE_FILE (thing), DECL_SOURCE_LINE (thing));
#else
    emit_line_note (DECL_SOURCE_LOCATION (thing));
#endif

  mark_temporary_levels ();
  switch (TREE_CODE (type))
  {
    case ARRAY_TYPE:
      {
        tree domain = TYPE_DOMAIN (type), type = base_type (domain);
        tree index = make_new_variable ("init_index", type), index_as_integer = index;
        /* build_modify_expr requires an integer type. */
        if (TREE_CODE (type) != INTEGER_TYPE)
          index_as_integer = convert (type_for_size (TYPE_PRECISION (type), TYPE_UNSIGNED (type)), index);
        expand_expr_stmt (build_modify_expr (index, NOP_EXPR, TYPE_MIN_VALUE (domain)));
        expand_start_loop (1);
        init_any (undo_schema_dereference (build_pascal_array_ref (thing, build_tree_list (NULL_TREE, index))), the_end, implicit);
        expand_exit_loop_if_false (0, build_implicit_pascal_binary_op (LT_EXPR, index, TYPE_MAX_VALUE (domain)));
        expand_expr_stmt (build_modify_expr (index_as_integer, PLUS_EXPR, integer_one_node));
        expand_end_loop ();
        break;
      }

    case RECORD_TYPE:
      if (PASCAL_TYPE_FILE (type))
        {
          const char *temp;
          tree fname, file_size, file_kind, t;
          tree component_type = TREE_TYPE (type);
          unsigned long save_pascal_dialect = co->pascal_dialect;

          if (the_end)
            {
              /* Close the file on exit */
              co->pascal_dialect = ANY_PASCAL;
              build_predef_call (p_DoneFDR, build_tree_list (NULL_TREE, thing));
              co->pascal_dialect = save_pascal_dialect;
              break;
            }

          t = thing;
          while (TREE_CODE (t) == COMPONENT_REF || TREE_CODE (t) == ARRAY_REF)
            t = TREE_OPERAND (t, 0);
          if (TREE_CONSTANT (t)
              || TREE_READONLY (t)
              || TYPE_READONLY (TREE_TYPE (t))
              || (TREE_CODE (t) == VAR_DECL && PASCAL_DECL_TYPED_CONST (t)))
            gpc_warning ("constant file variables are pointless");

          /* Always pass the internal name to the RTS, not only for external files. */
          if (TREE_CODE (thing) == VAR_DECL)
            temp = IDENTIFIER_NAME (DECL_NAME (thing));
          else if (TREE_CODE (thing) == INDIRECT_REF)
            temp = "<allocated from heap>";
          else
            temp = "<name unknown>";

          fname = build_string_constant (temp, strlen (temp), 0);

          if (pedantic && PASCAL_TYPE_PACKED (type))
            gpc_warning ("`packed' has no effect on the external file format");

          /* Pass the size of the file buffer. */
          file_size = (TREE_CODE (component_type) == VOID_TYPE) ? size_one_node : size_in_bytes (component_type);

#define FLAG(VALUE, COND) ((COND) ? VALUE : 0)
          file_kind = size_int (
              FLAG (fkind_TEXT,     PASCAL_TYPE_TEXT_FILE (type))
            | FLAG (fkind_UNTYPED,  TREE_CODE (component_type) == VOID_TYPE)
            | FLAG (fkind_EXTERN,   TREE_CODE (thing) == VAR_DECL && PASCAL_EXTERNAL_OBJECT (thing))
            | FLAG (fkind_BINDABLE, PASCAL_TYPE_BINDABLE (type) || !(co->pascal_dialect & E_O_PASCAL))
            | FLAG (fkind_FILENAME, co->transparent_file_names));

          /* Call and construct parameters to the RTS routine that
             initializes a file buffer to a known state */
          co->pascal_dialect = ANY_PASCAL;
          build_predef_call (p_InitFDR,
            tree_cons (NULL_TREE, thing, tree_cons (NULL_TREE, fname, tree_cons (NULL_TREE, file_size,
              build_tree_list (NULL_TREE, file_kind)))));
          was_used = 1;  /* @@ */
          co->pascal_dialect = save_pascal_dialect;
          break;
        }
      else if (PASCAL_TYPE_DISCRIMINATED_STRING (type))
        {
          /* String schema discriminant identifier initializing. */
          if (!the_end)
            expand_expr_stmt (build_modify_expr (build_component_ref (thing, get_identifier ("Capacity")), INIT_EXPR,
              TYPE_LANG_DECLARED_CAPACITY (TREE_TYPE (thing))));
          break;
        }
      else if (!the_end && PASCAL_TYPE_DISCRIMINATED_SCHEMA (type))
        {
          tree field;
          for (field = TYPE_FIELDS (type);
               field && PASCAL_TREE_DISCRIMINANT (field);
               field = TREE_CHAIN (field))
            {
              tree discr = DECL_LANG_FIXUPLIST (field);
              gcc_assert (discr && TREE_CODE (discr) != TREE_LIST);
              expand_expr_stmt (build_modify_expr (simple_component_ref (thing, field), INIT_EXPR, discr));
            }
          /* FALLTHROUGH */
        }
      else if (!the_end && PASCAL_TYPE_OBJECT (type))
        {
          tree vmt_field = TYPE_LANG_VMT_FIELD (TREE_TYPE (thing));
          tree vmt = TYPE_LANG_VMT_VAR (TREE_TYPE (thing));
          gcc_assert (vmt_field && vmt);
          if (TYPE_LANG_CODE (TREE_TYPE (thing)) == PASCAL_LANG_ABSTRACT_OBJECT)
            error ("trying to instantiate an abstract object type");
          mark_addressable (thing);
          /* Assign the address of the VMT to the object's VMT field. */
          expand_expr_stmt (build_modify_expr (get_vmt_field (thing),
            INIT_EXPR, build_pascal_unary_op (ADDR_EXPR, vmt)));
          /* FALLTHROUGH */
        }
      else if (!the_end && PASCAL_TYPE_VARIANT_RECORD (type) && PASCAL_TYPE_INITIALIZER_VARIANTS (type)
               && TREE_VALUE (TREE_PURPOSE (TYPE_LANG_VARIANT_TAG (type))))
        {
          tree tag = TYPE_LANG_VARIANT_TAG (type), selector = TREE_VALUE (TREE_PURPOSE (tag));
          tree f = simple_component_ref (thing, TREE_VALUE (TREE_VALUE (tag))), variant, duplicate, ref;
          int have_otherwise = 0;
          if (TREE_CODE (selector) == FIELD_DECL)
            selector = simple_component_ref (thing, selector);
          expand_start_case (1, selector, TREE_TYPE (selector), "internal `case' statement");
          for (variant = TREE_PURPOSE (TREE_VALUE (tag)); variant; variant = TREE_CHAIN (variant))
            {
              tree field = TREE_VALUE (variant), init = TYPE_GET_INITIALIZER (TREE_TYPE (field));
              tree c = TREE_PURPOSE (variant);
              if (!c)  /* otherwise */
                {
                  tree label = build_decl (LABEL_DECL, NULL_TREE, NULL_TREE);
                  int r = pushcase (NULL_TREE, NULL, label, &duplicate);
                  gcc_assert (!r);
                  have_otherwise = 1;
                }
              else
                for (; c; c= TREE_CHAIN (c))
                  {
                    tree label = build_decl (LABEL_DECL, NULL_TREE, NULL_TREE);
                    int r = TREE_PURPOSE (c)
                      ? pushcase_range (TREE_VALUE (c), TREE_PURPOSE (c), convert_and_check, label, &duplicate)
                      : pushcase (TREE_VALUE (c), convert_and_check, label, &duplicate);
                    gcc_assert (!r);
                  }
              mark_temporary_levels ();
              ref = simple_component_ref (f, field);
              if (init)
                expand_expr_stmt (build_modify_expr (ref, INIT_EXPR,
                  build_pascal_initializer (TREE_TYPE (field), init, "variant record initializer", 0)));
              init_any (ref, the_end, implicit);
              release_temporary_levels ();
              expand_exit_something ();
            }
          if (!have_otherwise)
            {
              int r = pushcase (NULL_TREE, NULL, build_decl (LABEL_DECL, NULL_TREE, NULL_TREE), &duplicate);
              gcc_assert (!r);
            }
          expand_end_case (selector);
          /* FALLTHROUGH */
        }
    case UNION_TYPE:  /* variant record */
      init_record (thing, the_end, implicit, thing);
      break;

    default:
      /* NOTHING */ ;
  }
  release_temporary_levels ();
  TREE_USED (thing) = was_used;  /* Enable `unused' warnings for initialized types */
}

/* Un-/initialize all variables found in names. */
void
un_initialize_block (tree names, int the_end, int global)
{
  tree decl;
  if (global)
    for (decl = nreverse (deferred_initializers); decl; decl = TREE_CHAIN (decl))
      {
        if (!TREE_VALUE (decl))
          expand_expr_stmt (TREE_PURPOSE (decl));
        else
          {
            init_any (TREE_VALUE (decl), the_end, 1);
            if (TREE_PURPOSE (decl))
              expand_pascal_assignment2 (TREE_VALUE (decl),
                                         TREE_PURPOSE (decl), 1);
#if 0
          expand_expr_stmt (build_modify_expr (TREE_VALUE (decl), INIT_EXPR, TREE_PURPOSE (decl)));
#endif
          }
      }
  for (decl = names; decl; decl = TREE_CHAIN (decl))
    {
      /* Accept a chain of decls (from binding level) or a list with the decls
         in TREE_VALUE (variables in statement part). */
      tree t = decl;
      if (TREE_CODE (t) == TREE_LIST)
        t = TREE_VALUE (t);
      if (TREE_CODE (t) == VAR_DECL && !DECL_EXTERNAL (t))
        {
          if (global || !TREE_STATIC (t))
            {
              gcc_assert (the_end || !DECL_ARTIFICIAL (t) 
                 || !PASCAL_TYPE_FILE (TREE_TYPE (t)));
              if (!DECL_ARTIFICIAL (t) || !PASCAL_TYPE_FILE (TREE_TYPE (t)))
                init_any (t, the_end, 1);
            }
          else if (!the_end)
#ifndef EGCS97
            {
            push_obstacks_nochange ();
            end_temporary_allocation ();
#endif
            /* Defer local static variables to the global con-/destructors. */
            deferred_initializers = tree_cons (NULL_TREE, t, deferred_initializers);
#ifndef EGCS97
            pop_obstacks ();
            }
#endif
        }
    }
}

void
expand_call_statement (tree t)
{
  int function_called;
  gcc_assert (t);
  if (EM (TREE_TYPE (t)))
    return;
  function_called = TREE_CODE (t) == CALL_EXPR;
  if (MAYBE_CALL_FUNCTION (t))
    {
      t = maybe_call_function (t, 0);
      function_called = 1;
    }
  else if (CALL_METHOD (t))
    {
      t = call_method (t, NULL_TREE);
      function_called = 1;
    }
  if (TREE_CODE (t) == PASCAL_CONSTRUCTOR_CALL)
    {
      t = TREE_OPERAND (t, 1);
      if (t == integer_zero_node)
        {
          error("Constructor statement outside a constuctor");
          return;
        }
      t = convert (void_type_node, t);
      function_called = 1;
    }
  if (!EM (t))
    {
      if (PASCAL_TREE_IGNORABLE (t))
        {
          if (TREE_CODE_CLASS (TREE_CODE (t)) == tcc_constant)
            return;
        }
      else if (!function_called)
        {
          error ("expression used as a statement");
          return;
        }
      else if (TREE_CODE (t) == FUNCTION_DECL)
        {
          error ("missing arguments in routine call");
          return;
        }
      else if (TREE_TYPE (t) != void_type_node
               && !(TREE_CODE (t) == CALL_EXPR
                    && TREE_CODE (TREE_OPERAND (t, 0)) == ADDR_EXPR
                    && PASCAL_CONSTRUCTOR_METHOD (TREE_OPERAND (TREE_OPERAND (t, 0), 0))))
        error ("function call used as a statement");
      expand_expr_stmt (t);
    }
}

void
expand_pascal_assignment2 (tree target, tree source, int is_init)
{
  tree stmt, schema_source, schema_target;
  int allow_restricted_target = is_init, allow_restricted_source = is_init;
  if (EM (TREE_TYPE (source)) || EM (TREE_TYPE (target)))
    return;

  if (CALL_METHOD (target))
    {
      tree method_name = DECL_NAME (TREE_OPERAND (target, 1));
      tree op0 = TREE_OPERAND (target, 0);
      tree t = TREE_TYPE (op0);
      if (TYPE_POINTER_TO (t) && PASCAL_TYPE_CLASS (TYPE_POINTER_TO (t)))
        t = TYPE_POINTER_TO (t);
      target = lookup_name (get_method_name (
        DECL_NAME (TYPE_NAME (TYPE_MAIN_VARIANT (t))), method_name));
      if (!target)
        {
          error ("result of method `%s' assigned outside its block", IDENTIFIER_NAME (method_name));
          return;
        }
    }

  if (TREE_CODE (TREE_TYPE (target)) == REFERENCE_TYPE
      && TREE_CODE (TREE_TYPE (TREE_TYPE (target))) == FUNCTION_TYPE)
    chk_dialect ("assignments to procedural parameters are", B_D_M_PASCAL);

  if (TREE_CODE (target) == FUNCTION_DECL)
    {
      if (TREE_TYPE (TREE_TYPE (target)) == void_type_node || PASCAL_STRUCTOR_METHOD (target))
        {
          error ("you can't assign to a procedure");
          return;
        }
      if (target != current_function_decl)
        {
          struct function *p;
#ifdef EGCS97
          for (p = outer_function_chain; p && p->decl != target; p = p->outer) ;
#else
          for (p = outer_function_chain; p && p->decl != target; p = p->next) ;
#endif
          if (!p)
            {
              error ("result of function `%s' assigned outside its block",
                     IDENTIFIER_NAME (DECL_NAME (target)));
              return;
            }
        }
      target = DECL_LANG_RESULT_VARIABLE (target);
      if (!target || !TREE_PRIVATE (target))
        {
          error ("invalid assignment of function value");
          return;
        }

      /* Allow assignment of a non-restricted value to a restricted function result */
      allow_restricted_target = 1;
    }

  if (!mark_lvalue (target, is_init? "initialization" : "assignment", !is_init))
    return;

  schema_source = undo_schema_dereference (source);
  schema_target = undo_schema_dereference (target);
  DEREFERENCE_SCHEMA (source);
  DEREFERENCE_SCHEMA (target);
  CHK_EM (source);
  CHK_EM (target);

  /* Restricted types. @@@@ Maybe this needs further checking */
  if (TREE_CODE (source) == CALL_EXPR && PASCAL_TYPE_RESTRICTED (TREE_TYPE (source)))
    {
      allow_restricted_source = 1;
      allow_restricted_target = 1;
      if (!PASCAL_TYPE_RESTRICTED (TREE_TYPE (target)))
        {
          error ("a restricted function result may only be assigned");
          error (" to a restricted variable");
          return;
        }
    }

  if ((!allow_restricted_target && PASCAL_TYPE_RESTRICTED (TREE_TYPE (target)))
      || (!allow_restricted_source && PASCAL_TYPE_RESTRICTED (TREE_TYPE (source))))
    {
      error ("assigning a restricted value is not allowed");
      return;
    }

  if (TREE_CODE (TREE_TYPE (target)) == CHAR_TYPE)
    source = string_may_be_char (source, 1);
  if (TYPE_MAIN_VARIANT (TREE_TYPE (target)) == cstring_type_node)
    source = char_may_be_string (source);

  if (TREE_CODE (TREE_TYPE (target)) == SET_TYPE)
    stmt = assign_set (target, source);
  else if (is_string_type (target, 0) || is_string_type (source, 0))
    stmt = assign_string (target, source);
  else
    {
      tree schema_check = check_discriminants (schema_target, schema_source);
      if (!EM (schema_check))
        {
          if (!lvalue_or_else (schema_target, "assignment")
              || !mark_lvalue (schema_target, is_init ? "initialization" 
                                                : "assignment", is_init))
            return;
          stmt = build (MODIFY_EXPR, TREE_TYPE (schema_target),
                          schema_target, schema_source);
          TREE_SIDE_EFFECTS (stmt) = 1;
          if (TREE_CODE (schema_check) != INTEGER_CST)
            stmt = build (COMPOUND_EXPR, TREE_TYPE (stmt), schema_check, stmt);
        }
      else
        stmt = build_modify_expr (target,
                 is_init ? INIT_EXPR : NOP_EXPR, source);
    }
  if (stmt && !EM (stmt))
    expand_expr_stmt (stmt);
}

void
expand_pascal_assignment (tree target, tree source)
{
  expand_pascal_assignment2 (target, source, 0);
}

tree
assign_set (tree target, tree source)
{
  tree tdom, tmin, tmax, sdom, smin, smax;
  if (!lvalue_or_else (target, "assignment"))
    return error_mark_node;
  /* @@ Test new constructor code without this.
        Construct a set directly to the set variable. */
  if (TREE_CODE (source) == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (TREE_TYPE (source)) == SET_TYPE)
    {
      source = construct_set (source, target, 0);
      if (!source)
        return NULL_TREE;
    }
  if (TREE_CODE (TREE_TYPE (source)) != SET_TYPE
      || TREE_CODE (TREE_TYPE (target)) != SET_TYPE
      || !comptypes (TYPE_MAIN_VARIANT (TREE_TYPE (source)), TYPE_MAIN_VARIANT (TREE_TYPE (target))))
    {
      error ("assignment between incompatible sets");
      return error_mark_node;
    }
  tdom = TYPE_DOMAIN (TREE_TYPE (target));
  tmin = TYPE_MIN_VALUE (tdom);
  tmax = TYPE_MAX_VALUE (tdom);
  sdom = TYPE_DOMAIN (TREE_TYPE (source));
  smin = TYPE_MIN_VALUE (sdom);
  smax = TYPE_MAX_VALUE (sdom);
  if (co->range_checking
      && !(TREE_CODE (tmin) == INTEGER_CST && TREE_CODE (smin) == INTEGER_CST
           && TREE_CODE (tmax) == INTEGER_CST && TREE_CODE (smax) == INTEGER_CST
           && !const_lt (smin, tmin)
           && !const_lt (tmax, smax)))
    {
      source = save_expr (source);
      build_predef_call (p_Set_RangeCheck, tree_cons (NULL_TREE, source,
        tree_cons (NULL_TREE, convert (pascal_integer_type_node, tmin),
        build_tree_list (NULL_TREE, convert (pascal_integer_type_node, tmax)))));
    }
  return build_predef_call (p_Set_Copy, tree_cons (NULL_TREE, target, build_tree_list (NULL_TREE, source)));
}

/* Assign a (char, string-type) to (char, string-type).
   Each string may be either a fixed or variable length string.
   @@@ No sophisticated checks are made for capacity violations. */
tree
assign_string2 (tree target, tree source, int is_init)
{
  tree length = NULL_TREE;
  tree t_type = base_type (TREE_TYPE (target));
  tree s_type = TREE_TYPE (source);
  tree expr, expr1 = NULL_TREE, expr2 = NULL_TREE;

  switch (TREE_CODE (s_type))
  {
    case CHAR_TYPE:
      /* target must be a string-type since source is a char */
      length = integer_one_node;
      expr1 = PASCAL_STRING_VALUE (target);
      expr1 = build_modify_expr (build_array_ref (expr1, TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (expr1)))), NOP_EXPR, source);
      break;

    case RECORD_TYPE:  /* String schema */
    case ARRAY_TYPE:
      if (is_string_type (source, 1)
          && (is_string_compatible_type (target, 1) || TYPE_MAIN_VARIANT (t_type) == cstring_type_node))
        {
          if (TREE_CODE (t_type) == CHAR_TYPE)
            {
              if (pedantic || !(co->pascal_dialect & E_O_PASCAL))
                gpc_warning ("assignment of string value to char variable");
              expr1 = PASCAL_STRING_VALUE (source);
              expr1 = build_modify_expr (target, NOP_EXPR, build_array_ref (expr1,
                TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (expr1)))));
            }
          else if (TYPE_MAIN_VARIANT (t_type) == cstring_type_node)
            expr1 = build_modify_expr (target, NOP_EXPR, convert_to_cstring (source));
          else
            {
              /* Silently truncate the string if it does not fit in the target. */
              tree capacity;
              if (is_variable_string_type (t_type))
                capacity = PASCAL_STRING_CAPACITY (target);
              else
                {
                  tree upper_bound, lower_bound;
                  gcc_assert (TREE_CODE (t_type) == ARRAY_TYPE);
                  upper_bound = TYPE_MAX_VALUE (TYPE_DOMAIN (t_type));
                  lower_bound = TYPE_MIN_VALUE (TYPE_DOMAIN (t_type));
                  capacity = fold (build_pascal_binary_op (PLUS_EXPR,
                    build_pascal_binary_op (MINUS_EXPR, convert (pascal_integer_type_node, upper_bound),
                      convert (pascal_integer_type_node, lower_bound)), integer_one_node));
                }

              /* Optimize assignment of the constant empty string */
              if (TREE_CODE (source) == STRING_CST && TREE_STRING_LENGTH (source) == 1)
                length = integer_zero_node;
              else
                {
                  /* Use save_expr_string, so the string is not evaluated 2
                     or 3 times (for the number of chars to move, assignment
                     to the target length and the chars). */
                  tree olen, las;
                  source = save_expr_string (source);
                  /* The code below looks silly: we are saving length
                     of already saved string.  But doing this copy
                     prevents gimplifier from messing fjf630e.pas */
                  olen = PASCAL_STRING_LENGTH (source);
                  length = make_new_variable ("str_len", TREE_TYPE (olen));
                  las = build_pascal_binary_op (MIN_EXPR, olen, capacity);
                  las = build_modify_expr (length, NOP_EXPR, fold (las));
                  /* The target needs to be an lvalue, but the source might
                     be e.g. an array returned by a function or whatever. */
                  expr1 = build_memcpy (
                            build_unary_op (ADDR_EXPR,
                                            PASCAL_STRING_VALUE (target), 1),
                            build1 (ADDR_EXPR, cstring_type_node,
                                    PASCAL_STRING_VALUE (source)),
                            length);
                  expr1 = build (COMPOUND_EXPR, TREE_TYPE (expr1), las, expr1);
                }
            }
          break;
        }
      /* FALLTHROUGH */
    default:
      error ("only Pascal string type, array of char, and char type");
      error (" are assignment compatible with a string");
      return error_mark_node;
  }

  if (is_variable_string_type (t_type))
    expr2 = build_modify_expr (PASCAL_STRING_LENGTH (target), NOP_EXPR, length);
  else if (length)
    {
      tree upper_bound = TYPE_MAX_VALUE (TYPE_DOMAIN (t_type));
      tree lower_bound = TYPE_MIN_VALUE (TYPE_DOMAIN (t_type));
      tree t_length = fold (build_pascal_binary_op (PLUS_EXPR,
        build_pascal_binary_op (MINUS_EXPR, convert (pascal_integer_type_node, upper_bound),
         convert (pascal_integer_type_node, lower_bound)), integer_one_node));
      /* Blank pad the fixed string target. */
      if (!tree_int_cst_equal (length, t_length))
        expr2 = build_memset (build_unary_op (ADDR_EXPR,
         build_array_ref (target, build_pascal_binary_op (PLUS_EXPR, lower_bound, length)), 1),
         build_pascal_binary_op (MINUS_EXPR, t_length, length), build_int_2 (' ', 0));
    }

  if (expr2)
    CHK_EM (expr2);
  if (expr1)
    {
      CHK_EM (expr1);
      expr = expr2 ? build (COMPOUND_EXPR, TREE_TYPE (expr2), expr1, expr2) : expr1;
    }
  else
    /* The only case where both expr1 and expr2 could be NULL are
       assignments of the constant empty string to a fixed array
       of the same size. Since zero-size arrays should not exist,
       this should not happen except after a previous error.
       Return a dummy. This may cause the warning `statement with
       no effect' further down which is quite true. :-) */
    expr = expr2 ? expr2 : integer_zero_node;
  return expr;
}

tree
assign_string (tree target, tree source)
{
  return assign_string2 (target, source, 0);
}

/* Main program, module initializers/finalizers. */

static void
call_no_args (tree id, int external)
{
  expand_expr_stmt (build_routine_call (build_implicit_routine_decl (
    id, void_type_node, void_list_node, external ? ER_EXTERNAL : 0), NULL_TREE));
}

static const char *
start_dummy_file_name (void)
{
  const char *tmp = input_filename;
  input_filename = "<implicit code>";
#ifdef EGCS97
  (*debug_hooks->start_source_file) (lineno, input_filename);
#else
  debug_start_source_file (input_filename);
#endif
  return tmp;
}

static void
end_dummy_file_name (const char *name)
{
#ifdef EGCS97
  (*debug_hooks->end_source_file) (lineno);
  input_filename = name;
#else
  debug_end_source_file (lineno);
  input_filename = (char *) name;
#endif
}

void
start_main_program (void)
{
  tree t;
  char *n;
  /* init_any does this when called from the implicit constructor.
     That's too late for the main program. */
  for (t = getdecls (); t; t = TREE_CHAIN (t))
    if (TREE_CODE (t) == VAR_DECL)
      PASCAL_VALUE_ASSIGNED_SUBROUTINE (t) |= PASCAL_VALUE_ASSIGNED (t);
  check_forward_decls (1);
  check_external_objects (current_module->parms);
  /* According to the standard the program name is in a separate name
     space, so we build a special name for the main program. */
  n = ACONCAT ((IDENTIFIER_POINTER (current_module->assembler_name),
    "_main_program", NULL));
  start_implicit_routine (NULL_TREE, get_identifier_with_spelling (n,
    "main program"), void_type_node, NULL_TREE);
  do_setjmp ();
}

void
finish_main_program (void)
{
  const char *save_filename;
  char *n;
  int options = FLAG (ro_SP_EOLn, co->pascal_dialect & C_E_O_PASCAL);

  store_executable_name ();
  finish_routine (NULL_TREE);

  save_filename = start_dummy_file_name ();

#if 0
  /* Finalize the variables -- including those imported from modules and units -- in a destructor.
     @@ Too early (fjf464a.pas) ... */
  tree decls = getdecls ();
  start_destructor ();
  un_initialize_block (decls, 1, 1);
  finish_destructor ();
#endif

  /* Initialize the variables of the main program in a constructor. */
  start_constructor (1);
  finish_constructor ();

  /* Construct the following function:

     extern void _p_initialize (int argc, char **argv, char **envp, int options);
     extern void _p_finalize (void);
     extern volatile int RTS_VERSION_CHECK;

     int main_program_name (int argc, char **argv, char **envp)
     {
       (void) RTS_VERSION_CHECK;
       _p_initialize (argc, argv, envp, options);
       init_pascal_main_program ();
       pascal_main_program ();
       _p_finalize ();
     }

     main_program_name is usually `main' but can be redefined
     with the `--gpc-main=foo' option. This allows for working
     with libraries that export their own `main()' function. */
  {
  tree rts_vc = declare_variable (get_identifier (RTS_VERSION_CHECK),
    pascal_integer_type_node, NULL_TREE, VQ_VOLATILE | VQ_EXTERNAL | VQ_IMPLICIT);

  /* Construct implicit main program that is invoked as
     main_program_name (int argc, char **argv, char **envp) */
  const char *name = gpc_main ? gpc_main : "main";
  tree cstring_ptr_type_node = build_pointer_type (cstring_type_node);
  tree decl_argc = add_parm_decl (NULL_TREE, integer_type_node, get_identifier ("argc"));
  tree decl_argv = add_parm_decl (decl_argc, cstring_ptr_type_node, get_identifier ("argv"));
  tree decl_envp = add_parm_decl (decl_argv, cstring_ptr_type_node, get_identifier ("envp"));
  start_implicit_routine (NULL_TREE, get_identifier (name), integer_type_node, decl_envp);
  
  TREE_USED (decl_argc) = TREE_USED (decl_argv) = TREE_USED (decl_envp) = 1;

  /* If it is called `main', let the backend do any necessary magic. */
  if (!strcmp (name, "main"))
    expand_main_function ();

  expand_expr_stmt (build1 (CONVERT_EXPR, void_type_node, rts_vc));

  /* Call _p_initialize (argc, argv, envp, options). */
  expand_expr_stmt (build_routine_call (
    build_implicit_routine_decl (get_identifier ("_p_initialize"), void_type_node,
      tree_cons (NULL_TREE, integer_type_node,
      tree_cons (NULL_TREE, cstring_ptr_type_node,
      tree_cons (NULL_TREE, cstring_ptr_type_node,
      tree_cons (NULL_TREE, integer_type_node,
      void_list_node)))), ER_EXTERNAL),
    tree_cons (NULL_TREE, decl_argc, tree_cons (NULL_TREE, decl_argv,
      tree_cons (NULL_TREE, decl_envp,
      build_tree_list (NULL_TREE, build_int_2 (options, 0)))))));

  /* Call the main program's constructor which will call the other constructors. */
  call_no_args (TREE_VALUE (current_module->initializers), 1);

  /* Call the Pascal main program. */
  n = ACONCAT ((IDENTIFIER_POINTER (current_module->assembler_name), "_main_program", NULL));
  call_no_args (get_identifier (n), 0);

  /* Call the RTS finalization routine. */
  call_no_args (get_identifier ("_p_finalize"), 1);

  expand_return_statement (integer_zero_node);
  finish_routine (NULL_TREE);
  }

  end_dummy_file_name (save_filename);
}

/* Generate special code at the beginning of a module/unit/program constructor. */
void
start_constructor (int implicit)
{
  tree run_condition, imported_interface, initializers, decls = getdecls ();
  current_module->initializer = start_implicit_routine (NULL_TREE,
    TREE_VALUE (current_module->initializers), void_type_node, NULL_TREE);
  do_setjmp ();

  /* var RunCondition: Boolean = False; attribute (static);
     if not RunCondition then
       begin
         RunCondition := True;
         <run constructors of modules used from this one>;
         AtExit (@fini_Foo);  { if needed }
         { to be continued in finish_constructor() } */
  run_condition = declare_variable (get_unique_identifier ("ctor_run_condition"), boolean_type_node,
    build_tree_list (NULL_TREE, boolean_false_node), VQ_STATIC | VQ_IMPLICIT);
  expand_start_cond (build_unary_op (TRUTH_NOT_EXPR, run_condition, 0), 0);
  pushlevel_expand (0);
  expand_expr_stmt (build_modify_expr (run_condition, NOP_EXPR, boolean_true_node));

  /* Call constructors of directly imported interfaces (they call those
     of indirectly imported ones). */
  for (imported_interface = current_module->imports;
       imported_interface; imported_interface = TREE_CHAIN (imported_interface))
    for (initializers = itab_get_initializers (IMPORT_INTERFACE (TREE_VALUE (imported_interface)));
         initializers; initializers = TREE_CHAIN (initializers))
      call_no_args (TREE_VALUE (initializers), 1);

#ifndef EGCS97
#define ISIDNUM(c) (isalnum ((unsigned char) (c)) || (c) == '_')
#endif

#define SKIP_WHITE() do { while (*p == ' ' || *p == '\t') p++; } while (0)
  if (extra_inits)
    {
      char *buffer = alloca (strlen (extra_inits) + 1), *p = extra_inits;
      char module_name_len[23];
      while (*p)
        {
          char *q = buffer, *name;
          tree t;
          SKIP_WHITE ();
          if (*p == '\'')
            {
              p++;
              while (*p)
                {
                  if (*p == '\'')
                    {
                      if (p[1] == '\'')
                        p++;
                      else
                        break;
                    }
                  *q++ = *p++;
                }
              *q = 0;
              if (*p != '\'')
                error ("unterminated string in `--init-modules'");
              else
                p++;
              name = ACONCAT ((buffer, "_init", NULL));
            }
          else
            {
              while (*p && ISIDNUM (*p))
                {
                  if (q == buffer)
                    {
                      if (*p >= '0' && *p <= '9')
                        error ("invalid name in `--init-modules'");
                      *q++ = TOUPPER (*p++);
                    }
                  else
                    *q++ = TOLOWER (*p++);
                }
              *q = 0;
              sprintf (module_name_len, "%ld_", (long) strlen (buffer));
              name = ACONCAT (("_p__M", module_name_len, buffer, "_init", NULL));
            }
          SKIP_WHITE ();
          if (*p && *p != ',' && *p != ':')
            {
              error ("invalid character in name in `--init-modules'");
              while (*p && *p != ',' && *p != ':') p++;
            }
          if (*p)
            p++;
          /* Don't call our own constructor recursively. This check
             is redundant currently, since the run_condition flag
             prevents the recursion, anyway, but relying on this
             seems a little too fragile to me (and doing the check
             makes the generated code a little shorter as well). */
          t = current_module->initializers;
          while (t && strcmp (name, IDENTIFIER_POINTER (TREE_VALUE (t))) != 0)
            t = TREE_CHAIN (t);
          if (!t)
            call_no_args (get_identifier (name), 1);
        }
    }
  extra_inits_used = 1;

  /* Initialize this module's variables after calling the constructors since
     they might require another module's initialized variables (fjf1021h.pas). */
  un_initialize_block (decls, 0, 1);

  if (!implicit || DECL_INITIAL (current_module->finalizer))
    {
    expand_expr_stmt (build_routine_call (
      build_implicit_routine_decl (get_identifier ("_p_AtExit"), void_type_node,
        tree_cons (NULL_TREE, ptr_type_node, void_list_node), ER_EXTERNAL),
      build_tree_list (NULL_TREE, convert(ptr_type_node, 
              build_unary_op (ADDR_EXPR, current_module->finalizer, 0)))
         ));
//      TREE_USED (current_module->finalizer) = 1;
    }
  if (current_module->main_program)
    call_no_args (get_identifier ("_p_DoInitProc"), 1);
}

/* Generate special code at the end of a module/unit constructor. */
void
finish_constructor (void)
{
  poplevel_expand (0, 1);
  expand_end_cond ();  /* close the open `if' from start_constructor */
  mark_addressable (current_function_decl);
  finish_routine (NULL_TREE);
}

void
start_destructor (void)
{
  start_implicit_routine (current_module->finalizer, NULL_TREE, void_type_node, NULL_TREE);
}

void
finish_destructor (void)
{
  finish_routine (NULL_TREE);
}

void
implicit_module_structors (void)
{
  const char *save_filename = start_dummy_file_name ();
  if (/* 1 TREE_USED (current_module->finalizer) && */ !DECL_INITIAL (current_module->finalizer) )
    {
      start_destructor ();
      finish_destructor ();
    }
  if (!current_module->initializer)
    {
      start_constructor (1);
      finish_constructor ();
    }
  end_dummy_file_name (save_filename);
}
