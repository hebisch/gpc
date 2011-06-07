/* Emulate old expand_* routines using Tree-SSA infrastructure.

  Copyright (C) 2006 Free Software Foundation, Inc.

  Authors: Waldek Hebisch <hebisch@math.uni.wroc.pl>

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

#include <gpc.h>

#ifdef GCC_3_3
#include <varray.h>

/* Made unconditional for 3.3 to avoid Makefile tricks */
typedef struct plant_nesting GTY(()) {
  enum tree_code code;
  int flags;
  struct plant_nesting * next;
  tree arg0;
  tree arg1;
  tree arg2;
  tree statement_list;
  location_t locus;
} plant_nesting;


/* static GGTY(()) tree current_statement_list = NULL_TREE; */

static GTY(()) plant_nesting * plant_stack = NULL;

static GTY(()) varray_type gimplified_types = 0;
static GTY(()) varray_type gimplified_sizes = 0;
static GTY(()) varray_type gimplified_size_addrs = 0;
#endif

#ifdef GCC_4_0
#include "cgraph.h"
#include "tree-gimple.h"
#include "tree-dump.h"

/* @@@@@@@@@@@@@@@@@@@@@@@@@@ */
int immediate_size_expand;
#if 0
int set_words_big_endian;
int set_word_size;
#endif

location_t plant_locus;
int plant_locus_initialized = 0;

#define LOOP_HAS_CONTINUE 1

void
clear_last_expr (void)
{
  gcc_assert (0);
}

void
plant_decl_init (tree decl)
{
  gcc_assert (0);
}

void
plant_decl (tree decl)
{
  tree de = build1 (DECL_EXPR, void_type_node, decl);
        {
          tree id = DECL_NAME (decl);
          const char * n = IDENTIFIER_POINTER (id);
//          fprintf(stderr, "var %s\n", n? n : "???");
        }

  plant_expr_stmt (de);
}

void
plant_line_note (location_t loc)
{
  plant_locus = loc;
  plant_locus_initialized = 1;
}

void
plant_nop (void)
{
  // gcc_assert (0);
}

void
plant_asm (tree string, int vol)
{
  tree ae = build4 (ASM_EXPR, void_type_node, string, 
                   NULL_TREE, NULL_TREE, NULL_TREE);
  ASM_INPUT_P (ae) = 1;
  ASM_VOLATILE_P (ae) = vol;
  plant_expr_stmt (ae);
}

void
plant_asm_operands (tree string, tree outputs,
      tree inputs, tree clobbers, int vol, location_t loc_aux)
{
  tree ae = build4 (ASM_EXPR, void_type_node, string, outputs,
                    inputs, clobbers);
  ASM_VOLATILE_P (ae) = vol;
  plant_expr_stmt (ae);
}

void
plant_function_start (tree decl, int i)
{
  // gcc_assert (0);
//  fprintf (stderr, "plant_function_start\n");
  struct plant_nesting * nest = ggc_alloc (sizeof (*nest));
  nest->code = FUNCTION_DECL;
  nest->arg0 = nest->arg1 = nest->arg2 = NULL_TREE;
  nest->next = plant_stack;
  nest->statement_list = current_statement_list;
  nest->locus = plant_locus;
  current_statement_list = NULL_TREE;
  plant_stack = nest;
}

static void
pascal_remember_gimplified_type (tree t)
{
  VARRAY_PUSH_TREE (gimplified_types, t);
}

static void
pascal_remember_gimplified_sizepos (tree * exp)
{
  VARRAY_PUSH_TREE (gimplified_sizes, * exp);
  VARRAY_PUSH_TREE_PTR (gimplified_size_addrs, exp);
}

#if 0
extern void (*lang_remember_gimplified_type)(tree);
extern void (*lang_remember_gimplified_sizepos)(tree *);
#endif

static void
pascal_gimplify_function (tree fndecl)
{
  struct cgraph_node *cgn;
  static long gimplifying = 0;
#if 0
  if (!gimplifying)
    {
      VARRAY_TREE_INIT (gimplified_types, 32, "gimplified_types");
      VARRAY_TREE_INIT (gimplified_sizes, 64, "gimplified_sizes");
      VARRAY_TREE_PTR_INIT (gimplified_size_addrs, 64, 
                           "gimplified_size_addrs");
      lang_remember_gimplified_type = pascal_remember_gimplified_type;
      lang_remember_gimplified_sizepos = pascal_remember_gimplified_sizepos;
    }
#endif
  gimplifying ++;
  dump_function (TDI_original, fndecl);
  gimplify_function_tree (fndecl);
  dump_function (TDI_generic, fndecl);

  /* Convert all nested functions to GIMPLE now.  We do things in this order
     so that items like VLA sizes are expanded properly in the context of the
     correct function.  */
  cgn = cgraph_node (fndecl);
  for (cgn = cgn->nested; cgn; cgn = cgn->next_nested)
    pascal_gimplify_function (cgn->decl);
  gimplifying --;
  if (!gimplifying)
    {
      size_t i;
#if 0
      /* Restore sizes */
      i = VARRAY_ACTIVE_SIZE (gimplified_sizes);
      while (i > 0)
        {
          i--;
          *VARRAY_TREE_PTR (gimplified_size_addrs, i) = 
             VARRAY_TREE (gimplified_sizes, i);
        } 
      /* Restore types */
      i = VARRAY_ACTIVE_SIZE (gimplified_types);
      while (i > 0)
        {
          tree type = VARRAY_TREE (gimplified_types, i - 1);
          tree t = TYPE_NEXT_VARIANT (type);
          i--;
          TYPE_SIZES_GIMPLIFIED (type) = 0;
          for (; t; t = TYPE_NEXT_VARIANT (t))
            {
              TYPE_SIZE (t) = TYPE_SIZE (type);
              TYPE_SIZE_UNIT (t) = TYPE_SIZE_UNIT (type);
              TYPE_SIZES_GIMPLIFIED (t) = 0;
              switch (TREE_CODE (type))
                {
                case INTEGER_TYPE:
                case ENUMERAL_TYPE:
                case BOOLEAN_TYPE:
#ifndef GCC_4_2
                case CHAR_TYPE:
#endif
                case REAL_TYPE:
                  TYPE_MIN_VALUE (t) = TYPE_MIN_VALUE (type);
                  TYPE_MAX_VALUE (t) = TYPE_MAX_VALUE (type);
                  break;

                default:
                  break;
                }
            }
        }
#endif
        varray_type gimplified_types = 0;
        varray_type gimplified_sizes = 0;
        varray_type gimplified_size_addrs = 0;
    }
}

static void
pascal_dump_tree (tree t, int indent)
{
  int i;
  enum tree_code code;

  for (i=0; i<indent; i++)
    fputc(' ', stdout);
  if (!t)
    {
      fprintf(stdout, "<null_tree>\n");
      return;
    }
  code = TREE_CODE (t);
  fprintf(stdout, "<%s %p>\n", tree_code_name[code], t);
  switch (code) {
    case VAR_DECL:
    case CONST_DECL:
    case FUNCTION_DECL:
      return;
    case BIND_EXPR:
      pascal_dump_tree (BIND_EXPR_BODY (t), indent+2);
      return;
  }
  if (IS_EXPR_OR_REF_CODE_CLASS (TREE_CODE_CLASS (code)))
    {
      int i, l = NUMBER_OF_OPERANDS (code);
      for (i = FIRST_OPERAND (code); i < l; i++)
        pascal_dump_tree (TREE_OPERAND (t, i), indent+2);
    }
}

void
plant_function_end (void)
{
  tree the_fun = current_function_decl;
  location_t loc_aux = pascal_make_location (pascal_input_filename, lineno);

// fprintf (stderr, "plant_function_end\n");
//  fflush (0);
#if 1
  gcc_assert (plant_stack && plant_stack->code == FUNCTION_DECL
              && current_statement_list && the_fun
              && TREE_CODE (current_statement_list) == BIND_EXPR);
#endif
//  pascal_dump_tree (current_statement_list, 0);
  DECL_SAVED_TREE (current_function_decl) = current_statement_list;
  /* DECL_SOURCE_LOCATION (current_function_decl) = loc_aux; */

  cfun->function_end_locus = loc_aux;

  current_function_decl = DECL_CONTEXT (the_fun);

  if (!DECL_CONTEXT (the_fun)
      || TREE_CODE (DECL_CONTEXT (the_fun)) != FUNCTION_DECL)
    {
      current_function_decl = the_fun;
      pascal_gimplify_function (the_fun);
      cgraph_finalize_function (the_fun, false);
      current_function_decl = NULL_TREE;
    }
  else
    /* Register this function with cgraph just far enough to get it
       added to our parent's nested function list.  */
    (void) cgraph_node (the_fun);

#ifndef GCC_4_3
  cfun = NULL;
#else
  set_cfun (NULL);
#endif

  current_statement_list = plant_stack->statement_list;
  plant_stack = plant_stack->next;
}

void
plant_return (tree result)
{
  tree type = result? TREE_TYPE (result) : void_type_node;
//  fprintf (stderr, "plant_return_statement\n");
//  fflush (0);
  plant_expr_stmt (build1 (RETURN_EXPR, type, result));
}

void
plant_null_return (void)
{
  plant_return (NULL_TREE);
}

void
plant_start_cond (tree condition, int i)
{
  // gcc_assert (0);
  struct plant_nesting * nest = ggc_alloc (sizeof (*nest));
  nest->code = COND_EXPR;
  nest->arg0 = condition;
  nest->arg1 = nest->arg2 = NULL_TREE;
  nest->next = plant_stack;
  nest->statement_list = current_statement_list;
  nest->locus = plant_locus;
  current_statement_list = NULL_TREE;
  plant_stack = nest;
//  fprintf (stderr, "plant_start_cond\n");
//  fflush (0);
}

void
plant_end_cond (void)
{
  // gcc_assert (0);
  tree st1, st2;
//  fprintf (stderr, "plant_end_cond\n");
//  fflush (0);
  gcc_assert (plant_stack && plant_stack->code == COND_EXPR);
  if (!current_statement_list)
    current_statement_list = build_empty_stmt ();
  if (plant_stack->arg1)
    {
      st1 = plant_stack->arg1;
      st2 = current_statement_list;
    }
  else
    {
      st1 = current_statement_list;
      st2 = build_empty_stmt ();
    }
  st1 = build3 (COND_EXPR, void_type_node, plant_stack->arg0, st1, st2);
  SET_EXPR_LOCATION (st1, plant_stack->locus);
  current_statement_list = plant_stack->statement_list;
  plant_stack = plant_stack->next;
  plant_expr_stmt (st1);
}

void
plant_start_else (void)
{
  // gcc_assert (0);
//  fprintf (stderr, "plant_start_else\n");
//  fflush (0);
  gcc_assert (plant_stack && plant_stack->code == COND_EXPR);
  gcc_assert (!plant_stack->arg1);
  if (current_statement_list)
    {
      plant_stack->arg1 = current_statement_list;
      current_statement_list = NULL_TREE;
    }
  else
    plant_stack->arg1 = build_empty_stmt ();
}

void
plant_label (tree label)
{
  tree st = build1 (LABEL_EXPR, void_type_node, label);
  gcc_assert (DECL_CONTEXT (label) 
               && DECL_CONTEXT (label) == current_function_decl);
//  gcc_assert (0);
  plant_expr_stmt (st);
}

void
plant_goto (tree label)
{
  tree st = build1 (GOTO_EXPR, void_type_node, label);
//  gcc_assert (0);
  plant_expr_stmt (st);
}

/* pushcase */
void
plant_exit_something (void)
{
//  gcc_assert (0);
  tree jump_stmt;
//  fprintf (stderr, "plant_exit_something\n");
//  fflush (0);
  /* david3.pas, gale2a.pas */
  if (!plant_stack || plant_stack->code != SWITCH_EXPR)
    return;
  gcc_assert (plant_stack && (plant_stack->code == SWITCH_EXPR
                            /*  || plant_stack->code == LOOP_EXPR */));
  if (!plant_stack->arg2)
    {
      tree id = get_unique_identifier ("exit_something");
      tree label = build_decl (LABEL_DECL, id, void_type_node);
      plant_stack->arg2 = build1 (LABEL_EXPR, void_type_node, label);
    }
  gcc_assert (TREE_CODE (plant_stack->arg2) == LABEL_EXPR);
  jump_stmt = build_and_jump (&LABEL_EXPR_LABEL (plant_stack->arg2));
  plant_expr_stmt (jump_stmt);
}


void
plant_start_case (int exit_flag, tree expr, tree type,
                   const char *printname)
{
//  gcc_assert (0);
  struct plant_nesting * nest = ggc_alloc (sizeof (*nest));
  nest->code = SWITCH_EXPR;
  nest->arg0 = expr;
  nest->arg1 = type;
  nest->arg2 = NULL_TREE;
  nest->next = plant_stack;
  nest->statement_list = current_statement_list;
  nest->locus = plant_locus;
  current_statement_list = NULL_TREE;
  plant_stack = nest;
//  fprintf (stderr, "plant_start_case\n");
//  fflush (0);
}


void
plant_end_case (tree expr)
{
//  gcc_assert (0);
  tree st;
  tree body = current_statement_list;
  gcc_assert (plant_stack);
  if (plant_stack->code != SWITCH_EXPR)
    {
      error ("unexpected end of case");
      return;
    }
  if (plant_stack->arg2)
    {
      tree label = LABEL_EXPR_LABEL (plant_stack->arg2);
//      body = build (COMPOUND_EXPR, void_type_node, plant_stack->arg2, body);
      body = build2 (COMPOUND_EXPR, void_type_node, body, plant_stack->arg2);
      pushdecl_nocheck (label);
      PASCAL_LABEL_SET (label) = 1;
      TREE_USED (label) = 1;
      DECL_CONTEXT (label) = current_function_decl;
//      st = build1 (DECL_EXPR, void_type_node, 
//                     LABEL_EXPR_LABEL (plant_stack->arg2));
//      body = build (COMPOUND_EXPR, void_type_node, st, body);
    }
  st = build3 (SWITCH_EXPR, void_type_node, plant_stack->arg0,
               body, NULL_TREE);
  SET_EXPR_LOCATION (st, plant_stack->locus);
  current_statement_list = plant_stack->statement_list;
  plant_stack = plant_stack->next;
  plant_expr_stmt (st); 
//  fprintf(stderr, "plant_end_case\n");
}

static void
plant_case_label (tree low, tree high, tree label)
{
  tree st = build3 (CASE_LABEL_EXPR,
                    void_type_node, 
                    low,
                    high,
                    label);
  if (!DECL_CONTEXT (label))
    DECL_CONTEXT (label) = current_function_decl;
  plant_expr_stmt (st);
//  fprintf(stderr, "plant_case_label\n"); 
}

int
pushcase (tree value, tree (*converter) (tree, tree), tree label,
          tree *duplicate)
{
//  gcc_assert (0);
  tree index_type;
  tree nominal_type;
  gcc_assert (plant_stack);
  if (plant_stack->code != SWITCH_EXPR)
    {
      error("unexpected case label");
      return 0;
    }
  index_type = TREE_TYPE (plant_stack->arg0);
  nominal_type = plant_stack->arg1;
  if (index_type == error_mark_node)
    return 0;

  /* Convert VALUE to the type in which the comparisons are nominally done.  */
  if (value != 0)
    value = (*converter) (nominal_type, value);
  
  plant_case_label (value, NULL_TREE, label);  
//  plant_case_label (value, value, label);
  return 0;
}

int
pushcase_range (tree value1, tree value2, tree (*converter) (tree, tree),
                tree label, tree *duplicate)
{
//  gcc_assert (0);
  tree index_type;
  tree nominal_type;
  gcc_assert (plant_stack);
  if (plant_stack->code != SWITCH_EXPR)
    {
      error("unexpected case label");
      return 0;
    }
  index_type = TREE_TYPE (plant_stack->arg0);
  nominal_type = plant_stack->arg1;
  if (index_type == error_mark_node)
    return 0;

  /* Convert VALUEs to type in which the comparisons are nominally done
     and replace any unspecified value with the corresponding bound.  */

  if (value1 == 0)
    value1 = TYPE_MIN_VALUE (index_type);
  if (value2 == 0)
    value2 = TYPE_MAX_VALUE (index_type);

  /* Fail if the range is empty.  Do this before any conversion since
     we want to allow out-of-range empty ranges.  */
  if (value2 != 0 && tree_int_cst_lt (value2, value1))
    return 4;

  /* If the max was unbounded, use the max of the nominal_type we are
     converting to.  Do this after the < check above to suppress false
     positives.  */
  if (value2 == 0)
    value2 = TYPE_MAX_VALUE (nominal_type);

  value1 = (*converter) (nominal_type, value1);
  value2 = (*converter) (nominal_type, value2);

  plant_case_label (value1, value2, label);

  return 0;
}



struct plant_nesting *
plant_start_loop (int i)
{
  // gcc_assert (0);
  struct plant_nesting * nest = ggc_alloc (sizeof (*nest));
//  fprintf (stderr, "plant_start_loop_continue_elsewhere(%d)\n", i);
//  fflush (0);
  
  nest->code = LOOP_EXPR;
  nest->flags = 0;
  nest->arg0 = nest->arg1 = nest->arg2 = NULL_TREE;
  nest->next = plant_stack;
  nest->statement_list = current_statement_list;
  nest->locus = plant_locus;
  current_statement_list = NULL_TREE;
  plant_stack = nest;
  return nest;
}

void
plant_loop_continue_here (void)
{
  // gcc_assert (0);
//  fprintf (stderr, "plant_loop_continue_here\n");
//  fflush (0);
  plant_nesting * ll = plant_stack;
  while (ll && ll->code == BIND_EXPR)
    ll = ll->next;
  gcc_assert (ll && ll->code == LOOP_EXPR);
  gcc_assert (!(LOOP_HAS_CONTINUE & ll->flags));
  if (!ll->arg0)
    ll->arg0 = build1 (LABEL_EXPR, void_type_node, NULL_TREE);
  gcc_assert (TREE_CODE (ll->arg0) == LABEL_EXPR);
  plant_expr_stmt (ll->arg0);
  ll->flags |= LOOP_HAS_CONTINUE;
}

int
plant_continue_loop (struct plant_nesting * loop)
{
  // gcc_assert (0);
  tree jump_stmt;
//  fprintf (stderr, "plant_continue_loop\n");
//  fflush (0);
  if (!loop)
    {
      loop = plant_stack;
      while (loop && loop->code != LOOP_EXPR)
        loop = loop->next;
    }
  /* gcc_assert (loop && loop->code == LOOP_EXPR); */
  if (!(loop && loop->code == LOOP_EXPR))
    return 0;
  if (!loop->arg0)
    loop->arg0 = build1 (LABEL_EXPR, void_type_node, NULL_TREE);
  gcc_assert (TREE_CODE (loop->arg0) == LABEL_EXPR);
  jump_stmt = build_and_jump (&LABEL_EXPR_LABEL (loop->arg0));
  plant_expr_stmt (jump_stmt);
  return 1;
}

int
plant_exit_loop (struct plant_nesting * loop)
{
  // gcc_assert (0);
  tree exit_st;
  gcc_assert (!loop);
//  fprintf (stderr, "plant_exit_loop\n");
//  fflush (0);
  if (!loop)
    {
      loop = plant_stack;
      while (loop && loop->code != LOOP_EXPR)
        loop = loop->next;
    }
  /* gcc_assert (loop && loop->code == LOOP_EXPR); */
  if (!(loop && loop->code == LOOP_EXPR))
    return 0;
  exit_st = build1 (EXIT_EXPR, void_type_node, boolean_true_node);
  plant_expr_stmt (exit_st);
  return 1;
}

int
plant_exit_loop_if_false (struct plant_nesting * loop, tree condition)
{
  // gcc_assert (0);
  tree exit_st;
  gcc_assert (!loop);
//  fprintf (stderr, "plant_exit_loop_if_false\n");
//  fflush (0);
  condition = build1 (TRUTH_NOT_EXPR, TREE_TYPE (condition), condition);
  exit_st = build1 (EXIT_EXPR, void_type_node, condition);
  plant_expr_stmt (exit_st);
  return 1;
}

void
plant_end_loop (void)
{
  // gcc_assert (0);
  tree body = current_statement_list;
//  fprintf (stderr, "plant_end_loop\n");
//  fflush (0);
  gcc_assert (plant_stack && plant_stack->code == LOOP_EXPR);
  if (plant_stack->arg0 && LABEL_EXPR_LABEL (plant_stack->arg0) 
      && !(LOOP_HAS_CONTINUE & plant_stack->flags))
     body = build2 (COMPOUND_EXPR, void_type_node, plant_stack->arg0, body);
  if (plant_stack->arg0 && !LABEL_EXPR_LABEL (plant_stack->arg0))
    LABEL_EXPR_LABEL (plant_stack->arg0) = create_artificial_label ();
  body = build1 (LOOP_EXPR, void_type_node, body);
  SET_EXPR_LOCATION (body, plant_stack->locus);
  current_statement_list = plant_stack->statement_list;
  plant_stack = plant_stack->next;
  plant_expr_stmt (body);
}


void
plant_start_bindings (int flags)
{
#if 1
  // gcc_assert (0);
  struct plant_nesting * nest = ggc_alloc (sizeof (*nest));
  nest->code = BIND_EXPR;
  nest->arg0 = nest->arg1 = nest->arg2 = NULL_TREE;
  nest->next = plant_stack;
  nest->statement_list = current_statement_list;
  nest->locus = plant_locus;
  current_statement_list = NULL_TREE;
  plant_stack = nest;

//  fprintf (stderr, "plant_start_bindings\n");
  fflush (0);
#endif
}

void
plant_end_bindings (tree vars, int mark_ends, int dont_jump_in)
{
#if 1
  // gcc_assert (0);
//  fprintf (stderr, "plant_end_bindings\n");
//  if (!vars)
//    fprintf (stderr, "  no vars\n");
//  else
//    debug_tree (vars);
  fflush (0);
#endif
}


void
plant_expr_stmt (tree expr)
{
//  fprintf (stderr, "plant_expr_stmt\n");
//  fflush (0);
  if (EM (expr))
    return;
  if (!EXPR_HAS_LOCATION (expr) 
       && TREE_CODE (expr) != LABEL_EXPR
       && TREE_CODE (expr) != COMPOUND_EXPR
       && plant_locus_initialized) 
    SET_EXPR_LOCATION (expr, plant_locus);
  if (current_statement_list)
    current_statement_list = build2 (COMPOUND_EXPR, 
                                  TREE_TYPE (expr),
                                  current_statement_list,
                                  expr);
  else
    current_statement_list = expr;
}


void
plant_bind_block (tree block)
{
  tree statement_list;
#if 0
  fprintf (stderr, "plant_bind_block\n");
  if (block)
    debug_tree(block);
  else
    fprintf (stderr, " no block\n");
  fflush (0);
#endif
  if (errorcount && !(plant_stack->code == BIND_EXPR
              || plant_stack->code == FUNCTION_DECL))
    {
      exit_compilation ();
    }
  gcc_assert (plant_stack->code == BIND_EXPR 
              || plant_stack->code == FUNCTION_DECL);
  statement_list = current_statement_list;
  if (block)
    {
      tree t;
#if 0
      for (t = BLOCK_VARS (block); t ; t = TREE_CHAIN (t))
        {
          tree id = DECL_NAME (t);
          const char * n = IDENTIFIER_POINTER (id);
          fprintf(stderr, "block var %s\n", n? n : "???");
        }
#endif

      if (!statement_list)
        statement_list = build_empty_stmt ();
#if 1
      statement_list = build3 (BIND_EXPR,
                               void_type_node,
                               BLOCK_VARS (block),
                               statement_list,
                               block);
#endif
   }
   if (plant_stack->code != FUNCTION_DECL)
     {
       current_statement_list = plant_stack->statement_list;
       if (statement_list)
         plant_expr_stmt (statement_list);
       plant_stack = plant_stack->next;
     }
   else
     current_statement_list = statement_list;
}
#endif
#ifdef GCC_3_3
#include "gt-p-plant.h"
#endif
