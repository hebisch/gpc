/*Pascal declarations.

  Copyright (C) 1988-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

  Parts of this file were originally derived from GCC's `c-decl.c'.

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

#ifdef PROTECT_ERROR_MARK_NODE
#include <sys/mman.h>
#endif

/* Check <float.h> for DBL_MAX, DBL_MIN and DBL_EPSILON
   @@@@@@@@ This is not quite correct. It should use the target's
   <float.h>, but how (if at all) can we get at it? Perhaps it's
   better to let some RTS file include its (native!) <float.h> and
   define those constants. But this will require (a) the ability for
   Pascal code to include a C header (maybe in this case it will
   just work since it should contain only numeric defines, though
   it's a little dirty) and (b) that every GPC program uses some RTS
   interface automatically (which is planned, anyway). However, e.g.
   on DJGPP, they're not constants in <float.h>. :-( -- Frank */
#include <float.h>
#ifndef DBL_MAX
 #error DBL_MAX undefined
#endif
#ifndef DBL_MIN
 #error DBL_MIN undefined
#endif
#ifndef DBL_EPSILON
 #error DBL_EPSILON undefined
#endif

#ifndef EGCS97
#define warn_unused_label warn_unused
extern struct obstack permanent_obstack;
tree current_function_decl;
#endif

tree pascal_global_trees[PTI_MAX] = {0};

/* Nonzero while defining an explicitly `packed' record. */
int defining_packed_type = 0;

/* Nonzero means the size of a type may vary within one function context. */
int size_volatile = 0;

/* We let tm.h override the types used here, to handle trivial differences
   such as the choice of unsigned int or long unsigned int for size_t.
   When machines start needing nontrivial differences in the size type,
   it would be best to do something here to figure out automatically
   from other information what type to use. */

#ifndef CHAR_TYPE_SIZE
#define CHAR_TYPE_SIZE BITS_PER_UNIT
#endif

#ifndef SIZE_TYPE
#define SIZE_TYPE "long unsigned int"
#endif

#ifndef PTRDIFF_TYPE
#define PTRDIFF_TYPE "long int"
#endif

#ifndef EGCS97

#ifndef WCHAR_TYPE
#define WCHAR_TYPE "int"
#endif

#ifndef SHORT_TYPE_SIZE
#define SHORT_TYPE_SIZE (BITS_PER_UNIT * MIN ((UNITS_PER_WORD + 1) / 2, 2))
#endif

#ifndef INT_TYPE_SIZE
#define INT_TYPE_SIZE BITS_PER_WORD
#endif

#ifndef LONG_TYPE_SIZE
#define LONG_TYPE_SIZE BITS_PER_WORD
#endif

#ifndef LONG_LONG_TYPE_SIZE
#define LONG_LONG_TYPE_SIZE (BITS_PER_WORD * 2)
#endif

#ifndef FLOAT_TYPE_SIZE
#define FLOAT_TYPE_SIZE BITS_PER_WORD
#endif

#ifndef DOUBLE_TYPE_SIZE
#define DOUBLE_TYPE_SIZE (BITS_PER_WORD * 2)
#endif

#ifndef LONG_DOUBLE_TYPE_SIZE
#define LONG_DOUBLE_TYPE_SIZE (BITS_PER_WORD * 2)
#endif

#ifndef BOOL_TYPE_SIZE
#define BOOL_TYPE_SIZE CHAR_TYPE_SIZE
#endif

tree error_mark_node;
tree short_integer_type_node;
tree integer_type_node;
tree long_integer_type_node;
tree long_long_integer_type_node;
tree short_unsigned_type_node;
tree unsigned_type_node;
tree long_unsigned_type_node;
tree long_long_unsigned_type_node;
tree ptrdiff_type_node;
tree char_type_node;
tree float_type_node;
tree double_type_node;
tree long_double_type_node;
tree complex_double_type_node;
tree intQI_type_node;
tree intHI_type_node;
tree intSI_type_node;
tree intDI_type_node;
tree intTI_type_node;
tree unsigned_intQI_type_node;
tree unsigned_intHI_type_node;
tree unsigned_intSI_type_node;
tree unsigned_intDI_type_node;
tree unsigned_intTI_type_node;
tree void_type_node;
tree ptr_type_node, const_ptr_type_node;
tree integer_zero_node;
tree null_pointer_node;
tree integer_one_node;
tree integer_minus_one_node;
tree void_list_node;
#endif

#define EMPTY_PARENTHESES(list) ((list) == void_list_node)

/* For each binding contour we allocate a binding_level structure
   which records the names defined in that contour.
   Contours include:
   - the global one
   - for each routine definition one that contains the parameters and one
     for the main level of statements.
   - one (transparent) for each structured statement, see pushlevel_expand */

struct GTY(()) binding_level
{
  /* A chain of declarations. These are in the reverse of the order supplied. */
  tree names;

  /* A pointer to the end of the names chain. Only needed to facilitate
     a quick test if a decl is in the list by checking if its TREE_CHAIN
     is not NULL or it is names_end (in pushdecl_nocheck()). */
  tree names_end;

  /* A TREE_LIST of pending forward declarations:
     TREE_VALUE: *_DECL node
     TREE_PURPOSE: NULL_TREE (interface/object method)
                   void_type_node (forward declaration)
                   error_mark_node (error already given). */
  tree forward_decls;

  /* Labels that were set within this level. */
  tree labels_set;

  /* Labels that were used for `goto' from this level or any sublevel. */
  tree labels_used;

  /* A TREE_LIST of shadowed outer-level local definitions to be restored when
     this level is popped. TREE_PURPOSE: identifier, TREE_VALUE: old value. */
  tree shadowed;

  /* For each level (except the global one), a chain of BLOCK nodes for
     all the levels that were entered and exited one level down. */
  tree blocks;

  /* The BLOCK node for this level, if one has been preallocated.
     If NULL_TREE, the BLOCK is allocated (if needed) when the level is popped. */
  tree this_block;

  /* The binding level this one is contained in. */
  struct binding_level *next;

  /* Nonzero if the level shares the namespace with next. */
  char transparent;

  /* Nonzero if the level is the main level of a routine. */
  char routine;

  /* Nonzero if the level should be popped together with next. */
  char implicit;

  /* Number of markers that all levels below this one are temporary. */
  int marker;

  /* Scope Index. */
  long scope;

  struct lang_decl *shared_decl_lang_specific;
};

static long scope_index = 0;

/* The binding level currently in effect. */
static GTY(()) struct binding_level *current_binding_level = ((struct binding_level *) NULL);

/* The outermost binding level, for names of file scope. This is created when
   the compiler is started and exists through the entire run. */
static GTY(()) struct binding_level *global_binding_level;

static tree poplevel_expand_1 (int, int);
static int contains_aligned_field (tree);
static int find_duplicate_fields (tree, tree);
static int field_decl_cmp (const PTR, const PTR);
static tree shadow_one_level (tree, tree);
static int resolve_forward_decl (tree);
static tree lookup_c_type (const char *);
static tree make_real (double);
static tree gpc_builtin_routine (const char *, const char *, int, tree,
                                 tree, tree);
#if defined (EGCS97) && !defined (GCC_3_3)
static void mark_binding_level (void *);
#endif
static tree mangle_name (tree);
static int same_value (tree, tree);
static int same_imported (tree, tree);
static void check_id_redeclaration (tree, const char *);
static void check_field_list (tree);
static tree peek_name (tree);

/* Nonzero if we are currently in the global binding level. */
int
global_bindings_p (void)
{
  if (size_volatile)
    return -1;
  return pascal_global_bindings_p () ? -1 : 0;
}

int
pascal_global_bindings_p (void)
{
  /* current_module is always set except before start of Pascal code */
  return !current_module
         || current_binding_level == global_binding_level
         || (!(current_module && current_module->main_program)
             && current_binding_level->next == global_binding_level);
}

void
set_forward_decl (tree t, int interface)
{
  current_binding_level->forward_decls = tree_cons (interface ? NULL_TREE : void_type_node,
    t, current_binding_level->forward_decls);
}

void
clear_forward_decls (void)
{
  current_binding_level->forward_decls = NULL_TREE;
}

void
check_forward_decls (int finishing)
{
  tree decl;
  /* After a syntax error, these errors are often misleading. */
  if (!syntax_errors && (finishing || (co->pascal_dialect & C_E_O_PASCAL)))
    for (decl = current_binding_level->forward_decls; decl; decl = TREE_CHAIN (decl))
      if (TREE_PURPOSE (decl) != error_mark_node && (finishing || TREE_PURPOSE (decl)))
        {
          TREE_PURPOSE (decl) = error_mark_node;
          error_with_decl (TREE_VALUE (decl), "unresolved forward declaration `%s'");
        }
}

static int
resolve_forward_decl (tree name)
{
  tree *p;
  for (p = &current_binding_level->forward_decls; *p; p = &TREE_CHAIN (*p))
    if (DECL_NAME (TREE_VALUE (*p)) == name)
      {
        *p = TREE_CHAIN (*p);
        return 1;
      }
  return 0;
}

static void
alloc_new_scope (struct binding_level *level)
{
  struct lang_decl * sd;
#ifndef EGCS97
  sd = (struct lang_decl *) xmalloc (sizeof (*(sd)));
#else
  sd = (struct lang_decl *) ggc_alloc (sizeof (*(sd)));
#endif
  memset (sd, 0, sizeof (*(sd)));
  LANG_SPECIFIC_SHARED (sd) = self_id;
  sd->used_in_scope = level->scope = ++scope_index;
  level->shared_decl_lang_specific = sd;
}

struct scope_stack {
  struct scope_stack * next;
  long scope;
  struct lang_decl * shared_decl_lang_specific;
};

struct scope_stack *  scope_stack_top = 0;

void
push_scope (void)
{
  struct scope_stack * ns;
  ns = (struct scope_stack *) xmalloc (sizeof (*ns));
  ns->next = scope_stack_top;
  scope_stack_top = ns;
  ns->scope = current_binding_level->scope;
  ns->shared_decl_lang_specific = 
              current_binding_level->shared_decl_lang_specific;
  alloc_new_scope (current_binding_level);
}

/* Enter a new binding level. */
void
pushlevel (int transparent)
{
#ifndef GCC_3_3
  struct binding_level *newlevel = (struct binding_level *) xmalloc (sizeof (*newlevel));
#else
  struct binding_level *newlevel = (struct binding_level *) ggc_alloc (sizeof (*newlevel));
#endif
  memset (newlevel, 0, sizeof (*newlevel));
  newlevel->next = current_binding_level;
  current_binding_level = newlevel;
  newlevel->transparent = transparent;
  if (transparent)
    {
      newlevel->shared_decl_lang_specific = newlevel->next->shared_decl_lang_specific;
      newlevel->scope = newlevel->next->scope;
    }
  else
    alloc_new_scope (newlevel);
}

/* Exit a binding level.
   Pop the level off, and restore the state of the identifier-decl
   mappings that were in effect when this level was entered.

   If KEEP is nonzero, this level had explicit declarations, so
   create a BLOCK node for the level to record its declarations and
   subblocks for symbol table output.

   If REVERSE is nonzero, reverse the order of decls before putting
   them into the BLOCK.

   If ROUTINEBODY is nonzero, this level is the body of a function,
   so create a block as if KEEP were set. */
tree
poplevel (int keep, int reverse, int routinebody)
{
  tree decls, t, block;
  struct binding_level *level = current_binding_level;
  check_forward_decls (1);
  current_binding_level = current_binding_level->next;

  current_binding_level->labels_used = chainon (current_binding_level->labels_used, level->labels_used);

  /* The chain of decls was accumulated in reverse order.
     Put it into forward order, just for cleanliness. */
  decls = level->names;
  if (reverse)
    decls = nreverse (decls);

  /* Output any nested inline functions within this block if not done yet. */
  for (t = decls; t; t = TREE_CHAIN (t))
  /* @@@@@@@@@@@@@@ */
#ifndef GCC_4_0
    if (TREE_CODE (t) == FUNCTION_DECL
        && !TREE_ASM_WRITTEN (t)
        && DECL_INITIAL (t)
        && TREE_ADDRESSABLE (t)
        && DECL_SAVED_INSNS (t))
      {
        push_function_context ();
#ifdef EGCS97
        ggc_push_context ();
#endif
        output_inline_function (t);
#ifdef EGCS97
        ggc_pop_context ();
#endif
        pop_function_context ();
      }
    else 
#endif
    if (TREE_CODE (t) == LABEL_DECL)
      {
        gcc_assert (DECL_CONTEXT (t));
        if (!PASCAL_LABEL_SET (t))
          {
            error_with_decl (t, "label `%s' not set");
            /* Avoid crashing later. */
            emit_nop ();
            expand_label (t);
          }
        if (!TREE_USED (t))
          warning_with_decl (t, "label `%s' not used");
      }

  /* Clear out the local identifier meanings of this level. */
  for (t = decls; t; t = TREE_CHAIN (t))
    if (DECL_NAME (t))
      {
        if (DECL_EXTERNAL (t) && TREE_ADDRESSABLE (t))
          TREE_ADDRESSABLE (DECL_ASSEMBLER_NAME (t)) = 1;
        IDENTIFIER_VALUE (DECL_NAME (t)) = NULL_TREE;
      }
  restore_identifiers (level->shadowed);

  /* Not sure if this is a fix or work-around: Remove local external
     declarations because the gcc-3 backend seems to handle them wrong
     when outputting inlines. (fjf760*.pas) */
  if (level != global_binding_level)
    {
      tree *p = &decls;
      while (*p)
        if (DECL_EXTERNAL (*p))
          *p = TREE_CHAIN (*p);
        else
          p = &TREE_CHAIN (*p);
    }

  /* If there were any declarations in that level, or if this level is a
     routine body, create a BLOCK to record them for the life of the routine. */
  if (level->this_block)
    block = level->this_block;
  else if (keep || routinebody)
    block = make_node (BLOCK);
  else
    block = NULL_TREE;
  if (block)
    {
      /* If this is the top level block of a routine, the decls are the routine's
         parameters. Don't leave them in the BLOCK because they are found in the
         FUNCTION_DECL instead. */
      BLOCK_VARS (block) = routinebody ? NULL_TREE : decls;
      BLOCK_SUBBLOCKS (block) = level->blocks;
      TREE_USED (block) = 1;
#ifndef EGCS97
      remember_end_note (block);
#endif
    }
  /* In each subblock, record that this is its superior. */
  for (t = level->blocks; t; t = TREE_CHAIN (t))
    BLOCK_SUPERCONTEXT (t) = block;
  /* Put the current block into some higher level. If we did not make a block
     for the level just exited, any blocks made for inner levels (since they
     cannot be recorded as subblocks in that level) must be carried forward
     so they will later become subblocks of something else. */
  if (routinebody)
    DECL_INITIAL (current_function_decl) = block;
  else if (block)
    {
      if (!level->this_block)
        current_binding_level->blocks = chainon (current_binding_level->blocks, block);
    }
  else if (level->blocks)
    current_binding_level->blocks = chainon (current_binding_level->blocks, level->blocks);

#ifndef GCC_3_3
  free (level);
#endif

#ifdef GCC_4_0
  if (current_function_decl)
    plant_bind_block (block);
#endif

  return block;
}

void
pop_record_level (tree t)
{
  struct scope_stack * os = scope_stack_top;
  if (t)
    check_field_list (t);
  current_binding_level->scope = os->scope;
  current_binding_level->shared_decl_lang_specific =
                   os->shared_decl_lang_specific;
  scope_stack_top = os->next;
  free (os);
}

static void
check_param_redeclaration (tree name, tree res, const char * msg1,
                          const char * msg2);
static void
check_param_redeclaration (tree name, tree res, const char * msg1,
                          const char * msg2)
{
  if (name == res)
    {
      if (co->pascal_dialect & C_E_O_PASCAL)
        error (msg2, IDENTIFIER_NAME (name));
      else
        gpc_warning (msg2, IDENTIFIER_NAME (name));
    }
  check_id_redeclaration (name, msg1);
}

void
pop_param_level (tree args, tree res)
{
  args = EMPTY_PARENTHESES (args) ? NULL_TREE : args;
  for (; args ; args = TREE_CHAIN (args))
    {
      const char * msg1 = "`%s' used in parameter list, but shadowed by"
                          " a parameter";
      const char * msg2 = "parameter `%s' conflicts with result variable";
      if ( TREE_CODE (args) == FUNCTION_DECL)
        {
          gcc_assert (DECL_NAME (args));
          check_param_redeclaration (DECL_NAME (args), res, msg1, msg2);
        }
      else if (TREE_CODE (args) == TREE_LIST)
        {
          tree idlist = TREE_PURPOSE (args);
          tree type = TREE_VALUE (args);
          for (; idlist ; idlist = TREE_CHAIN (idlist))
            check_param_redeclaration (TREE_VALUE (idlist), res, msg1, msg2);
          if (type && TREE_CODE (type) == TREE_LIST && TREE_VALUE (type))
            for (; TREE_CODE (type) == TREE_LIST; type = TREE_CHAIN (type))
              {
                const char * m1 = "`%s' used in parameter list, but shadowed"
                  " by a conformant array bound";
                const char * m2 = "conformant array bound `%s' conflicts"
                                  " with result variable";
                check_param_redeclaration (TREE_PURPOSE (type), res, m1, m2);
                check_param_redeclaration (TREE_VALUE (type), res, m1, m2);
              }
        }
      else
        gcc_unreachable ();
    }
  if (res)
    {
      gcc_assert (TREE_CODE (res) == IDENTIFIER_NODE);
      check_id_redeclaration (res,
         "`%s' used in parameter list, but shadowed by result variable");
    }
  pop_record_level (NULL_TREE);
}

/* Push a level within a routine. This is for blocks to be made when necessary.
   It should not open a new scope (unlike in C), so make it transparent. */
void
pushlevel_expand (int implicit)
{
  pushlevel (1);
  current_binding_level->implicit = implicit;
#ifndef GCC_4_0
  clear_last_expr ();
#endif
  expand_start_bindings (0);
}

static tree
poplevel_expand_1 (int keep_if_subblocks, int do_uninitialize)
{
  tree decls = current_binding_level->names;
  int keep = decls || (keep_if_subblocks && current_binding_level->blocks) || keep_if_subblocks > 1;
  if (do_uninitialize)
    un_initialize_block (current_binding_level->names, 1, 0);
  expand_end_bindings (decls, keep, 0);
  return poplevel (keep, 1, 0);
}

tree
poplevel_expand (int keep_if_subblocks, int do_uninitialize)
{
  while (current_binding_level->implicit)
    poplevel_expand_1 (0, 1);
  return poplevel_expand_1 (keep_if_subblocks, do_uninitialize);
}

void
mark_temporary_levels (void)
{
  current_binding_level->marker++;
}

void
release_temporary_levels (void)
{
  while (!current_binding_level->marker)
    {
      gcc_assert (current_binding_level->implicit);
      poplevel_expand_1 (0, 1);
    }
  current_binding_level->marker--;
}

/* Insert BLOCK at the end of the list of subblocks of the
   current binding level. This is used when a BIND_EXPR is expanded,
   to handle the BLOCK node inside the BIND_EXPR. */
void
insert_block (tree block)
{
  TREE_USED (block) = 1;
  current_binding_level->blocks = chainon (current_binding_level->blocks, block);
}

/* Set the BLOCK node for the innermost scope (the one we are currently in). */
void
set_block (tree block)
{
  current_binding_level->this_block = block;
}

tree
de_capitalize (tree name)
{
  char *copy = alloca (IDENTIFIER_LENGTH (name) + 1);
  strcpy (copy, IDENTIFIER_POINTER (name));
  *copy = TOLOWER (*copy);
  return get_identifier (copy);
}

static tree
mangle_name (tree name)
{
  gcc_assert (current_module);
  return pascal_mangle_names (NULL, IDENTIFIER_POINTER (name));
}

tree
pascal_mangle_names (const char *object_name, const char *name)
{
  static long serial_no = 0;
  char serial_str[22];
  const char *object_sep;
  const char *mn = IDENTIFIER_POINTER (current_module->assembler_name);
  sprintf (serial_str, "%ld", serial_no++);
  if (!object_name)
    {
      object_name = "";
      object_sep = "";
    }
  else
    object_sep = "_";
  return get_identifier (ACONCAT ((mn, "_S", serial_str,
    object_sep, object_name, "_", name, NULL)));
}

tree
build_formal_param (tree idlist, tree type, int value_var_or_const, int protected)
{
  tree t = build_tree_list (idlist, type);
  PASCAL_CONST_PARM (t) = value_var_or_const == 2 || value_var_or_const == 3;
  if (value_var_or_const == 3)
    {
      chk_dialect ("`const var' parameters are", GNU_PASCAL);
      value_var_or_const = !((TREE_CODE (type) == POINTER_TYPE
                              && PASCAL_TYPE_CLASS (type))
                             || TREE_CODE (type) == REFERENCE_TYPE);
    }
  else if (value_var_or_const == 2)
    {
      int size;
      chk_dialect ("`const' parameters are", B_D_M_PASCAL);
      value_var_or_const = TREE_CODE (type) == TREE_LIST  /* conformant/open array */
                           || TREE_CODE (type) == VOID_TYPE
                           || PASCAL_TYPE_OBJECT (type)
                           || PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type)
                           || (!PASCAL_TYPE_PREDISCRIMINATED_STRING (type)
                               && !PASCAL_TYPE_UNDISCRIMINATED_STRING (type)
                               && ((size = int_size_in_bytes (type)) == -1
                                   || (size > int_size_in_bytes (ptr_type_node)
                                       && !SCALAR_TYPE (TREE_CODE (type))
                                       && TREE_CODE (type) != SET_TYPE)));
    }
  PASCAL_REF_PARM (t) = value_var_or_const;
  TREE_PROTECTED (t) = protected;
  return t;
}

/* Return list of parameter types. If decls is not NULL, also return
   chain of parameter decls in *decls. */
tree
build_formal_param_list (tree list, tree object_type, tree *decls)
{
  tree decl, types = NULL_TREE, parms = NULL_TREE, t;
  int ellipsis = 0;
#ifndef EGCS97
  push_obstacks_nochange ();
  end_temporary_allocation ();
#endif

  if (object_type && !EM (object_type))  /* add implicit `Self' parameter */
    parms = add_parm_decl (parms, build_reference_type (object_type), self_id);

  for (t = EMPTY_PARENTHESES (list) ? NULL_TREE : list; t; t = TREE_CHAIN (t))
    if (TREE_CODE (t) == FUNCTION_DECL)
      {
        if (!TREE_TYPE (t))
          error ("result type of functional parameter `%s' undefined", IDENTIFIER_NAME (DECL_NAME (t)));
        else
          {
            parms = add_parm_decl (parms, build_reference_type (build_function_type (TREE_TYPE (t),
              build_formal_param_list (DECL_ARGUMENTS (t), DECL_CONTEXT (t), NULL))), DECL_NAME (t));
            PASCAL_PROCEDURAL_PARAMETER (parms) = 1;
          }
      }
    else
      {
        tree idlist = TREE_PURPOSE (t);
        tree type = TREE_VALUE (t), inner_type = NULL_TREE;
        int varparm = PASCAL_REF_PARM (t);
        int const_parm = PASCAL_CONST_PARM (t);
        int protected = TREE_PROTECTED (t);
        if (!type)
          {
            gcc_assert (!TREE_CHAIN (t));  /* ellipsis must be last */
            ellipsis = 1;
            chk_dialect ("ellipsis parameters are", MAC_PASCAL);
          }
        else if (EM (type))
          ;
        else if (TREE_CODE (type) == TREE_LIST && !TREE_VALUE (type))  /* Open arrays */
          {
            tree element_type = TREE_TYPE (type), link;
            inner_type = element_type;
            for (link = idlist; link; link = TREE_CHAIN (link))
              {
                int old_value = immediate_size_expand;
                /* Implicitly pass the length (index). */
                parms = add_parm_decl (parms, open_array_index_type_node,
                  get_unique_identifier ("open_array_length"));
                gcc_assert (TREE_CODE (parms) == PARM_DECL);
                /* TREE_PRIVATE (parms) = 1; */
                immediate_size_expand = 0;
                size_volatile++;

                TREE_USED (parms) = 1;

                /* Rebuild the array type using the length above as the upper bound. */
                type = build_simple_array_type (element_type,
                  build_range_type (pascal_integer_type_node, integer_zero_node, parms));
                if (!EM (type))
                  {
                    PASCAL_TYPE_OPEN_ARRAY (type) = 1;
                    if (protected)
                      type = p_build_type_variant (type, 1, TYPE_VOLATILE (type));
                    type = build_reference_type (type);
                    PASCAL_TYPE_VAL_REF_PARM (type) = !varparm;
                    PASCAL_CONST_PARM (type) = const_parm;
                    parms = add_parm_decl (parms, type, TREE_VALUE (link));
                  }
                immediate_size_expand = old_value;
                size_volatile--;
              }
          }
        else if (TREE_CODE (type) == TREE_LIST)  /* Conformant arrays */
          {
            /* Internally passed as follows:
                 LO1 HI1  outermost bounds
                 ...      ...
                 LOn HIn  innermost bounds
                 CARRAY0  first
                 ...      ...
                 CARRAYm  last array in one `,' separated list
               The types of the bounds have PASCAL_TYPE_CONFORMANT_BOUND set. */

            tree last = NULL_TREE, link, atype;
            int old_value;

            chk_dialect ("conformant arrays are", CLASSIC_PASCAL_LEVEL_1 | E_O_PASCAL);

            for (link = type; TREE_CODE (link) == TREE_LIST; link = TREE_CHAIN (link))
              {
                tree ctype = TREE_TYPE (link);
                if (!ORDINAL_TYPE (TREE_CODE (ctype)))
                  {
                    error ("conformant array index type must be ordinal");
                    ctype = pascal_integer_type_node;
                  }
                ctype = pascal_type_variant (ctype, TYPE_QUALIFIER_PROTECTED | TYPE_QUALIFIER_CONFORMANT);

                /* Bounds */
                TREE_PURPOSE (link) = parms = add_parm_decl (parms, ctype, TREE_PURPOSE (link));
                TREE_VALUE (link) = parms = add_parm_decl (parms, ctype, TREE_VALUE (link));

                last = link;
              }
            TREE_CHAIN (last) = NULL_TREE;  /* for the nreverse below */
            inner_type = atype = link;

            /* Build array with variable indices. It is handled specially in
               convert_arguments. Prevent conformant array size calculation
               until we enter the routine body. */
            old_value = immediate_size_expand;
            immediate_size_expand = 0;
            size_volatile++;
            for (link = nreverse (type); link; link = TREE_CHAIN (link))
              {
                tree lo = TREE_PURPOSE (link);
                tree hi = TREE_VALUE (link);
                tree itype = build_range_type (TREE_TYPE (lo), lo, hi);
                TREE_SET_CODE (itype, TREE_CODE (TREE_TYPE (lo)));
                TYPE_UNSIGNED (itype) = TYPE_UNSIGNED (TREE_TYPE (lo));
                atype = build_simple_array_type (atype, itype);
                if (PASCAL_TREE_PACKED (link))
                  atype = pack_type (atype);
                if (protected)
                  atype = p_build_type_variant (atype, 1, TYPE_VOLATILE (atype));
              }
            size_volatile--;
            immediate_size_expand = old_value;

            /* Always pass this by reference because of its variable size */
            if (!EM (atype))
              {
                atype = build_reference_type (atype);
                PASCAL_TYPE_VAL_REF_PARM (atype) = !varparm;
                PASCAL_CONST_PARM (atype) = const_parm;

                /* Add the conformant array parameters. */
                for (link = idlist; link; link = TREE_CHAIN(link))
                  {
                    parms = add_parm_decl (parms, atype, TREE_VALUE (link));
                    PASCAL_PAR_SAME_ID_LIST (parms) = link != idlist;
                  }
              }
          }
        else
          {
            tree link;
            /* If this is a protected parameter, make it read-only. */
            if (protected)
              type = p_build_type_variant (type, 1, TYPE_VOLATILE (type));
            if (varparm
                || PASCAL_TYPE_UNDISCRIMINATED_STRING (type)
                || PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type))
              {
                type = build_reference_type (type);
                if (!varparm)
                  {
                    type = build_type_copy (type);
                    PASCAL_TYPE_VAL_REF_PARM (type) = 1;
                  }
              }
            if (const_parm)
              {
                type = build_type_copy (type);
                PASCAL_CONST_PARM (type) = 1;
              }
            inner_type = type;
            if (TREE_CODE (type) == VOID_TYPE)
              error ("parameter `%s' declared `Void'", IDENTIFIER_NAME (TREE_VALUE (idlist)));
            else
              for (link = idlist; link; link = TREE_CHAIN (link))
                {
                  parms = add_parm_decl (parms, type, TREE_VALUE (link));
                  PASCAL_PAR_SAME_ID_LIST (parms) = link != idlist;
                }
          }

        if (TREE_VALUE (t) && TREE_CODE (TREE_VALUE (t)) == TREE_LIST
            && (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (inner_type)
                || PASCAL_TYPE_UNDISCRIMINATED_STRING (inner_type)))
          {
            error ("conformant/open array parameter element types must");
            error (" not be undiscriminated strings or schemata");
          }
        if (inner_type && !(varparm || const_parm) && contains_file_p (inner_type))
          error ("file types cannot be value parameters");
        else if (inner_type && !varparm && PASCAL_TYPE_OBJECT (inner_type))
          {
            if (TYPE_LANG_CODE_TEST (inner_type, PASCAL_LANG_ABSTRACT_OBJECT))
              error ("abstract object type declared as value parameter");
            else if (co->warn_object_assignment)
              gpc_warning ("object type declared as value parameter");
          }
      }
  for (decl = parms; decl; decl = TREE_CHAIN (decl))
    for (t = TREE_CHAIN (decl); t; t = TREE_CHAIN (t))
      if (DECL_NAME (t) == DECL_NAME (decl))
        error_with_decl (decl, "duplicate parameter `%s'");
  parms = nreverse (parms);
  for (decl = parms; decl; decl = TREE_CHAIN (decl))
    {
      types = tree_cons (NULL_TREE, TREE_TYPE (decl), types);
      PASCAL_PAR_SAME_ID_LIST (types) = PASCAL_PAR_SAME_ID_LIST (decl);
    }
  types = nreverse (types);
  if (!ellipsis)
    types = chainon (types, void_list_node);
  if (decls)
    *decls = parms;
#ifndef EGCS97
  pop_obstacks ();
#endif
  return types;
}

/* Add a parameter declaration to a list. Return the declaration which
   can be used to work with, and which is the head of the new list (items
   are inserted at the front, reversed in build_formal_param_list), to be
   passed to the next call of this function. */
tree
add_parm_decl (tree list, tree type, tree name)
{
  tree decl;
  /* Don't try computing parameter sizes now -- wait till routine is called. */
  int old_immediate_size_expand = immediate_size_expand;
  immediate_size_expand = 0;
  decl = gpc_build_decl (PARM_DECL, name, type);
  immediate_size_expand = old_immediate_size_expand;
  DECL_CONTEXT (decl) = current_function_decl;
  TREE_READONLY (decl) |= TYPE_READONLY (type);
  TREE_SIDE_EFFECTS (decl) |= TYPE_VOLATILE (type);
  TREE_THIS_VOLATILE (decl) |= TYPE_VOLATILE (type);
  prediscriminate_schema (decl);
  DECL_ARG_TYPE (decl) = TREE_TYPE (decl);
#ifndef GCC_4_0
  if (PROMOTE_PROTOTYPES && ORDINAL_TYPE (TREE_CODE (type)) && TYPE_PRECISION (type) < TYPE_PRECISION (integer_type_node))
    DECL_ARG_TYPE (decl) = integer_type_node;
#endif
  TREE_CHAIN (decl) = list;
  return decl;
}

tree
build_procedural_type (tree resulttype, tree parameters)
{
  tree types = build_formal_param_list (parameters, NULL_TREE, NULL);
  if (!resulttype)
    error ("missing function result type");
  else if (!EM (resulttype) && (!types || !EM (types)))
    return build_reference_type (build_function_type (resulttype, types));
  return error_mark_node;
}

static int
same_value (tree x, tree y)
{
  if (x == y)
    return 1;
  if (!x || !y || TREE_CODE (x) != TREE_CODE (y))
    return 0;

  /* @@ Compare structured values better. This only handles simple
        initializers wrapped in a list. */
  if (TREE_CODE (x) == TREE_LIST
      && !TREE_PURPOSE (x) && !TREE_CHAIN (x)
      && !TREE_PURPOSE (y) && !TREE_CHAIN (y))
    return same_value (TREE_VALUE (x), TREE_VALUE (y));

  if (TREE_CODE (x) == INTEGER_CST
      && comptypes (TREE_TYPE (x), TREE_TYPE (y))
      && tree_int_cst_equal (x, y))
    return 1;
  if (TREE_CODE (x) == STRING_CST
      && TREE_STRING_LENGTH (x) == TREE_STRING_LENGTH (y)
      && !memcmp (TREE_STRING_POINTER (x), TREE_STRING_POINTER (y), TREE_STRING_LENGTH (x)))
    return 1;
  if (TREE_CODE (x) == PASCAL_SET_CONSTRUCTOR
      && TREE_CODE (TREE_TYPE (x)) == SET_TYPE && TREE_CODE (TREE_TYPE (x)) == SET_TYPE
      && comptypes (TREE_TYPE (x), TREE_TYPE (y))
      && const_set_constructor_binary_op (EQ_EXPR, SET_CONSTRUCTOR_ELTS (x),
                SET_CONSTRUCTOR_ELTS (y)) == boolean_true_node)
    return 1;

  return 0;
}

static int
same_imported (tree x, tree y)
{
  tree tx = TREE_TYPE (x), ty = TREE_TYPE (y);
  if (TREE_CODE (x) != TREE_CODE (y)
      || ((TREE_CODE (x) == VAR_DECL || TREE_CODE (x) == TYPE_DECL)
          && TYPE_MAIN_VARIANT (tx) != TYPE_MAIN_VARIANT (ty)))
    return 0;
  switch (TREE_CODE (x))
  {
    case FUNCTION_DECL:
      if (!compare_routine_decls (x, y))
        return 0;
      /* FALLTHROUGH */
    case VAR_DECL:
      return DECL_EXTERNAL (x) && DECL_EXTERNAL (y)
             && DECL_ASSEMBLER_NAME (x) == DECL_ASSEMBLER_NAME (y);
    case TYPE_DECL:
      return TYPE_READONLY (tx) == TYPE_READONLY (ty)
             && TYPE_VOLATILE (tx) == TYPE_VOLATILE (ty)
             && PASCAL_TYPE_BINDABLE (tx) == PASCAL_TYPE_BINDABLE (ty)
             && same_value (TYPE_GET_INITIALIZER (tx), TYPE_GET_INITIALIZER (ty));
    case CONST_DECL:
      return same_value (DECL_INITIAL (x), DECL_INITIAL (y));
    default:
      break;
  }
  return 0;
}

/* Record a decl-node X as belonging to the current lexical scope.
   Check for errors (such as redeclarations in the same scope).
   Returns either X or a forward decl. If a forward decl is returned,
   it may have been smashed to agree with what X says. */
tree
pushdecl (tree x)
{
  tree t, t2;
  tree name = DECL_NAME (x);
  int weak = 0;
  CHK_EM (TREE_TYPE (x));
  gcc_assert (!PASCAL_DECL_WEAK (x));
  gcc_assert (!PASCAL_DECL_IMPORTED (x));

  /* @@ Can happen when called from the backend. */
  if (!name)
    {
      x = pushdecl_nocheck (x);
      DECL_CONTEXT (x) = current_function_decl;
      return x;
    }

  DECL_CONTEXT (x) = current_function_decl;
  /* A local external declaration doesn't constitute nesting. */
  if (/* TREE_CODE (x) == FUNCTION_DECL && !DECL_INITIAL (x) && */ DECL_EXTERNAL (x))
    DECL_CONTEXT (x) = NULL_TREE;

  if (co->warn_local_external && DECL_EXTERNAL (x) && !DECL_ARTIFICIAL (x) && !pascal_global_bindings_p ())
    gpc_warning ("local external declaration of `%s'", IDENTIFIER_NAME (name));

  t = lookup_name_current_level (name);
  /* Overloading an operator is ok. The decl is a dummy placeholder.
     No need to replace it with another one. */
  if (t && TREE_CODE (t) == OPERATOR_DECL && TREE_CODE (x) == OPERATOR_DECL)
    return t;

  if (t && PASCAL_DECL_WEAK (t))
    {
      t = NULL_TREE;
      weak = 1;
    }

  /* When called from start_routine, DECL_LANG_SPECIFIC might not be set, so
     compare_routine_decls would crash. We could set it there, but it would
     be redundant since it already checks the definition. So we cannot and
     do not have to compare_routine_decls here in this case. */
  if (t && (TREE_CODE (t) != FUNCTION_DECL || TREE_CODE (x) != FUNCTION_DECL
            || DECL_INITIAL (t) || (DECL_LANG_SPECIFIC (x) && !compare_routine_decls (t, x))))
    {
      error_with_decl (x, "redeclaration of `%s'");
      error_with_decl (t, " previous declaration");
      return x;
    }

  if (t && !EM (TREE_TYPE (x)) && !EM (TREE_TYPE (t)))
    {
      /* Copy all the DECL_... slots specified in the new decl
         except for any that we copy here from the old type. */
      DECL_ATTRIBUTES (x) = DECL_ATTRIBUTES (t);
      TREE_TYPE (x) = TREE_TYPE (t);
      DECL_SIZE (x) = DECL_SIZE (t);
      DECL_SECTION_NAME (x) = DECL_SECTION_NAME (t);
      DECL_DECLARED_INLINE_P (x) = DECL_DECLARED_INLINE_P (t);
      COPY_DECL_RTL (t, x);
      SET_DECL_ASSEMBLER_NAME (x, DECL_ASSEMBLER_NAME (t));

      TREE_PUBLIC (t) |= TREE_PUBLIC (x);
      if (DECL_EXTERNAL (x))
        {
          TREE_STATIC (x) = TREE_STATIC (t);
          DECL_EXTERNAL (x) = DECL_EXTERNAL (t);
          if (!DECL_EXTERNAL (x))
            DECL_CONTEXT (x) = DECL_CONTEXT (t);
        }

      /* Also preserve various other info from the definition. */
      if (!DECL_INITIAL (x))
        {
          DECL_RESULT (x) = DECL_RESULT (t);
#ifndef GCC_4_0
          /* @@@@@@@@@@@@@@@@@@@@@@ */
          DECL_SAVED_INSNS (x) = DECL_SAVED_INSNS (t);
#else
          DECL_STRUCT_FUNCTION (x) = DECL_STRUCT_FUNCTION (t);
#endif
          DECL_ARGUMENTS (x) = DECL_ARGUMENTS (t);
#ifndef EGCS97
          DECL_FRAME_SIZE (x) = DECL_FRAME_SIZE (t);
          if (DECL_INLINE (x))
            DECL_ABSTRACT_ORIGIN (x) = t;
#else
          DECL_SAVED_TREE (x) = DECL_SAVED_TREE (t);
          /* Set DECL_INLINE on the declaration if we've got a body from which to instantiate. */
#if 1
          if (DECL_DECLARED_INLINE_P (x) && !DECL_UNINLINABLE (x))
            DECL_ABSTRACT_ORIGIN (x) = DECL_ABSTRACT_ORIGIN (t);
#endif
#endif
        }

      DECL_UID (x) = DECL_UID (t);
      gcc_assert (TREE_CODE (x) == FUNCTION_DECL &&
                  TREE_CODE (t) == FUNCTION_DECL);
#ifndef GCC_4_1
      /* Copy decl-specific fields of x into t. */
      memcpy ((char *) t + sizeof (struct tree_common),
              (char *) x + sizeof (struct tree_common),
              sizeof (struct tree_decl) - sizeof (struct tree_common));
#else
      memcpy ((char *) t + sizeof (struct tree_common),
              (char *) x + sizeof (struct tree_common),
              tree_size (t) - sizeof (struct tree_common));
#endif
      return t;
    }

  /* For each type declaration, make a unique ..._TYPE node, so each type node
     has at most one DECL_NAME, that messages and debug info can refer to. */
  if (TREE_CODE (x) == TYPE_DECL && TYPE_NAME (TREE_TYPE (x)) != x)
    {
      tree tt = build_type_copy (TREE_TYPE (x));
      DECL_ORIGINAL_TYPE (x) = TREE_TYPE (x);
      TREE_TYPE (x) = tt;
      TYPE_NAME (tt) = x;
    }

  t2 = t = IDENTIFIER_VALUE (name);
  if (!t2 || (TREE_CODE (t2) == OPERATOR_DECL && PASCAL_BUILTIN_OPERATOR (t2)))
    {
      struct predef *p = IDENTIFIER_BUILT_IN_VALUE (name);
      if (p && (p->kind == bk_const || p->kind == bk_type || p->kind == bk_var))
        t2 = p->decl;
    }
  if (t2 && TREE_CODE_CLASS (TREE_CODE (t2)) == tcc_declaration
      && DECL_LANG_SPECIFIC (t2)
      && DECL_LANG_SPECIFIC (t2)->used_in_scope >= current_binding_level->scope)
    error ("identifier `%s' redeclared in a scope where an outer value was used", IDENTIFIER_NAME (name));

  /* Install the new declaration. */
  IDENTIFIER_VALUE (name) = x;

  if (current_module && current_module->bp_qualids
      && TREE_CODE (x) != NAMESPACE_DECL && !PASCAL_DECL_IMPORTED (x)
      && pascal_global_bindings_p ())
    IDENTIFIER_VALUE (build_qualified_id (current_module->name, name)) = x;

  if (current_function_decl && name == DECL_NAME (current_function_decl)
      && DECL_LANG_RESULT_VARIABLE (current_function_decl)
      && TREE_PRIVATE (DECL_LANG_RESULT_VARIABLE (current_function_decl)))
    {
      error_with_decl (current_function_decl, "shadowing function-identifier `%s' makes");
      error_with_decl (current_function_decl, " it impossible to assign a function result");
    }

  /* Maybe warn if shadowing something else (not for vars made for inlining). */
  if (!weak && t && warn_shadow && !DECL_FROM_INLINE (x))
    gpc_warning ("declaration of `%s' shadows an outer declaration", IDENTIFIER_NAME (name));

  /* Record a shadowed declaration for later restoration. */
  if (!weak && t)
    current_binding_level->shadowed = tree_cons (name, t, current_binding_level->shadowed);

  /* Put decls on list in reverse order. We will reverse them later if necessary. */
  TREE_CHAIN (x) = current_binding_level->names;
  current_binding_level->names = x;
  if (!TREE_CHAIN (x))
    current_binding_level->names_end = x;
  return x;
}

void
pushdecl_import (tree x, int is_weak)
{
  tree name = DECL_NAME (x);
  tree old = lookup_name_current_level (name);
  int old_weak = 0;
  gcc_assert (!PASCAL_DECL_WEAK (x));

  if (old && PASCAL_DECL_WEAK (old))
    {
      old = NULL_TREE;
      old_weak = 1;
    }

  /* `uses' does not override declarations from the current module/unit. */
  if (old && is_weak)
    return;

  /* Overloading an operator is ok. The decl is a dummy placeholder.
     No need to replace it with another one. */
  if (old && TREE_CODE (old) == OPERATOR_DECL && TREE_CODE (x) == OPERATOR_DECL)
    return;

  /* If the same thing is imported multiple times we just ignore the second
     declaration, unless it is the principal identifier of a constant. */
  if (old && PASCAL_DECL_IMPORTED (old) && same_imported (old, x))
    {
      if (TREE_CODE (x) == CONST_DECL && PASCAL_CST_PRINCIPAL_ID (x))
        {
          old = NULL_TREE;
          old_weak = 1;
        }
      else
        return;
    }

  if (old)
    {
      error ("bad import");
      error_with_decl (x, " redeclaration of `%s'");
      error_with_decl (old, " previous declaration");
      return;
    }

  if (!old_weak)
    old = IDENTIFIER_VALUE (name);
  if (old)
    current_binding_level->shadowed = tree_cons (name, old, current_binding_level->shadowed);
  PASCAL_DECL_WEAK (x) = is_weak;
  IDENTIFIER_VALUE (name) = pushdecl_nocheck (x);
}

/* Record a decl-node X as belonging to the current lexical scope
   uncondionally and without any errors etc. (unlike pushdecl).
   For module imports and implicit declarations. */
tree
pushdecl_nocheck (tree x)
{
  /* This might happen if the same decl is imported twice (e.g., an identifier
     imported twice -- should be avoided). Duplicates in
     current_binding_level->names lead to endless loops. */
  if (TREE_CHAIN (x) || x == current_binding_level->names_end)
    return x;
  TREE_CHAIN (x) = current_binding_level->names;
  current_binding_level->names = x;
  if (!TREE_CHAIN (x))
    current_binding_level->names_end = x;
  return x;
}

tree
numeric_label (tree num)
{
  char buf[64];
  if (INT_CST_LT (num, integer_zero_node))
    error ("label number must not be negative");
  else if (TREE_INT_CST_HIGH (num) != 0 || TREE_INT_CST_LOW (num) > 9999)
    chk_dialect ("label values greater than 9999 are", GNU_PASCAL);
  sprintf (buf, "%i", (int) TREE_INT_CST_LOW (num));
  return get_identifier (buf);
}

tree
declare_label (tree id)
{
  tree label = pushdecl (gpc_build_decl (LABEL_DECL, id, void_type_node));
  gcc_assert (!EM (label));
  if (!current_function_decl || co->longjmp_all_nonlocal_labels)
    /* Create a jmp_buf variable for non-local gotos to this label.
       `jmp_buf' is in fact `unsigned[5]' (see ../builtins.c). */
    {
      tree d = make_new_variable ("jmpbuf",
                build_simple_array_type (ptr_type_node,
                build_index_type (build_int_2 (5, 0))));
    DECL_LANG_LABEL_JMPBUF (label) = d;
    TREE_SIDE_EFFECTS (d) = TREE_THIS_VOLATILE (d) = 1;
    }
  else
    {
#ifndef GCC_4_0
      label_rtx (label);
      declare_nonlocal_label (label);
#endif
    }
  return label;
}

/* Set a label at the current location. t can be a LABEL_DECL or an IDENTIFIER_NODE. */
void
set_label (tree t)
{
  tree decl = TREE_CODE (t) == LABEL_DECL ? t : lookup_name (t);
  if (!decl || TREE_CODE (decl) != LABEL_DECL)
    error ("undeclared label `%s'", IDENTIFIER_NAME (t));
  else if (DECL_CONTEXT (decl) != current_function_decl)
    error ("label `%s' must be set in the block closest-containing it", IDENTIFIER_NAME (t));
  else if (PASCAL_LABEL_SET (decl))
    error ("duplicate label `%s'", IDENTIFIER_NAME (t));
  else
    {
      PASCAL_LABEL_SET (decl) = 1;
      emit_nop ();
      expand_label (decl);
      current_binding_level->labels_set = tree_cons (NULL_TREE, decl, current_binding_level->labels_set);
      if (PASCAL_LABEL_NONLOCAL (decl) && !current_binding_level->routine && !current_binding_level->next->routine)
        error ("invalid target for nonlocal `goto'");
      else if (TREE_USED (decl))
        {
          struct binding_level *b;
          tree l = NULL_TREE;
          for (b = current_binding_level->next; b && !l; b = b->next)
            for (l = b->labels_used; l && TREE_VALUE (l) != decl; l = TREE_CHAIN (l)) ;
          if (b)
            error_or_warning (pedantic || co->iso_goto_restrictions,
                              "invalid `goto' target");
        }
    }
}

/* Expand a Pascal `goto' statement. t can be a LABEL_DECL or an IDENTIFIER_NODE. */
void
pascal_expand_goto (tree t)
{
  tree decl = TREE_CODE (t) == LABEL_DECL ? t : lookup_name (t);
  if (!decl || TREE_CODE (decl) != LABEL_DECL)
    {
      error ("undeclared label `%s'", IDENTIFIER_NAME (t));
      return;
    }
  TREE_USED (decl) = 1;
  if (DECL_CONTEXT (decl) != current_function_decl)
    {
      PASCAL_LABEL_NONLOCAL (decl) = 1;
#ifdef GCC_4_0
      mark_decl_referenced (decl);
#endif
    }
  else
    {
      struct binding_level *b;
      tree l = NULL_TREE;
      for (b = current_binding_level; b && !l; b = b->next)
        for (l = b->labels_set; l && TREE_VALUE (l) != decl; l = TREE_CHAIN (l)) ;
      if (!b)
        {
          if (PASCAL_LABEL_SET (decl))
            error_or_warning (pedantic || co->iso_goto_restrictions,
                               "`goto' to invalid target");
          else
            {
#ifndef EGCS97
              push_obstacks_nochange ();
              end_temporary_allocation ();
#endif
              current_binding_level->labels_used = tree_cons (NULL_TREE, decl, current_binding_level->labels_used);
#ifndef EGCS97
              pop_obstacks ();
#endif
            }
        }
    }
#if 0 
  /* ndef GCC_4_0 */
  if (DECL_RTL_SET_P (decl))
#else
  if (DECL_CONTEXT (decl) == current_function_decl
       || !DECL_LANG_LABEL_JMPBUF (decl))
#endif
    expand_goto (decl);
  else if (DECL_CONTEXT (decl) || current_module->main_program)
    {
      expand_expr_stmt (build_routine_call (longjmp_routine_node,
        tree_cons (NULL_TREE, build_unary_op (ADDR_EXPR, DECL_LANG_LABEL_JMPBUF (decl), 0),
          build_tree_list (NULL_TREE, integer_one_node))));
      TREE_USED (DECL_LANG_LABEL_JMPBUF (decl)) = 1;
#ifndef GCC_3_3
      /* @@ Work-around: `function_cannot_inline_p' should check `current_function_calls_longjmp'. */
      current_function_has_nonlocal_goto = 1;
#endif
    }
  else
    error ("nonlocal `goto' into a unit constructor is not allowed");
}

/* for each label used with longjmp do `if (setjmp (jmp_buf)) goto label;' */
void
do_setjmp (void)
{
  tree d;
  /* "Steal" the global labels if we're in the main program or module constructor. */
  if (DECL_ARTIFICIAL (current_function_decl))
    {
      tree *tt;
      struct binding_level *b;
      if (current_module->main_program)
        b = global_binding_level;
      else
        for (b = current_binding_level; b->next != global_binding_level; b = b->next) ;
      tt = &(b->names);
      while (*tt)
        if (TREE_CODE (*tt) == LABEL_DECL)
          {
            tree t = *tt;
            *tt = TREE_CHAIN (t);
            TREE_CHAIN (t) = NULL_TREE;
            pushdecl_nocheck (t);
            DECL_CONTEXT (t) = current_function_decl;
          }
        else
          tt = &TREE_CHAIN (*tt);
      b->names_end = tree_last (b->names);
    }
  for (d = current_binding_level->names; d; d = TREE_CHAIN (d))
    if (TREE_CODE (d) == LABEL_DECL
#ifndef GCC_4_0
         && !DECL_RTL_SET_P (d)
#endif
        )
      {
#ifndef GCC_4_0
        label_rtx (d);
#endif
        /* Avoid calling `setjmp' for labels that are only used locally */
        if (DECL_LANG_LABEL_JMPBUF (d) 
            && TREE_USED (DECL_LANG_LABEL_JMPBUF (d)))
          {
            expand_start_cond (build_routine_call (setjmp_routine_node,
              build_tree_list (NULL_TREE, build_unary_op (ADDR_EXPR, DECL_LANG_LABEL_JMPBUF (d), 0))), 0);
            expand_goto (d);
            expand_end_cond ();
#ifndef EGCS97
            /* Work-around for gcc-2.95 (whose function_cannot_inline_p()
               forgets to check current_function_calls_setjmp). */
            current_function_contains_functions = 1;
#endif
          }
      }
}

/* Return the list of declarations of the current level. This list
   is in reverse order. */
tree
getdecls (void)
{
  return current_binding_level->names;
}

void
check_duplicate_id (tree t)
{
  tree *a = &t, b;
  while (*a)
    {
      for (b = TREE_CHAIN (*a); b && TREE_VALUE (b) != TREE_VALUE (*a); b = TREE_CHAIN (b)) ;
      if (b)
        {
          error ("duplicate identifier `%s'", IDENTIFIER_NAME (TREE_VALUE (*a)));
          *a = TREE_CHAIN (*a);
        }
      else
        a = &TREE_CHAIN (*a);
    }
}

/* Look up the current meaning of NAME. Return a *_DECL node or NULL_TREE if undefined. */
static tree
peek_name (tree name)
{
  tree t;
  for (t = current_type_list; t && TREE_VALUE (t) != name; t = TREE_CHAIN (t)) ;
  if (t && TREE_CODE (TREE_TYPE (TREE_PURPOSE (t))) != LANG_TYPE)
    t = TREE_PURPOSE (t);
  else
    {
      struct predef *p = IDENTIFIER_BUILT_IN_VALUE (name);
      t = IDENTIFIER_VALUE (name);
      if (t && (TREE_CODE (t) == OPERATOR_DECL && PASCAL_BUILTIN_OPERATOR (t)))
        t = NULL_TREE;
      if (!t && PD_ACTIVE (p) && (p->kind == bk_const || p->kind == bk_type || p->kind == bk_var))
        {
          if (p->user_disabled >= 0)
            chk_dialect_name (IDENTIFIER_NAME (name), p->dialect);
          t = p->decl;
        }
    }
  return t;
}

tree
lookup_name (tree name)
{
  tree t = peek_name (name);
  if (t && TREE_CODE_CLASS (TREE_CODE (t)) == tcc_declaration)
    {
      /* Record that the declaration was used in the current scope, thus the
         identifier may not be redefined there. Ideally, we'd store the scope
         index in the *_DECL node, but there is no field for it, so we do it in
         DECL_LANG_SPECIFIC. However, to avoid allocating one for each
         declaration, we used a shared one per scope for declarations that
         don't need its other fields. */
      if (!DECL_LANG_SPECIFIC (t)
          || LANG_SPECIFIC_SHARED (DECL_LANG_SPECIFIC (t)) == self_id)
        DECL_LANG_SPECIFIC (t) = current_binding_level->shared_decl_lang_specific;
      else
        DECL_LANG_SPECIFIC (t)->used_in_scope = current_binding_level->scope;
    }
  return t;
}

/* Similar to `lookup_name' but look only at current scope. */
tree
lookup_name_current_level (tree name)
{
  struct binding_level *level;
  tree t;
  if (!IDENTIFIER_VALUE (name))
    return NULL_TREE;
  for (level = current_binding_level; level; level = level->next)
    {
      for (t = level->names; t; t = TREE_CHAIN (t))
        if (DECL_NAME (t) == name)
          return t;
      if (!level->transparent)
        break;
    }
  return NULL_TREE;
}

/* Normally, this is similar to lookup_name. But within a type declaration part,
   a pointer domain has either been defined within this part, or is a potential
   forward type (even if another definition exists). */
tree
get_pointer_domain_type (tree name)
{
  tree decl, scan;
  for (scan = current_type_list; scan && TREE_VALUE (scan) != name; scan = TREE_CHAIN (scan)) ;
  if (scan)
    return TREE_TYPE (TREE_PURPOSE (scan));
  if (current_type_list)
    return TREE_TYPE (build_type_decl (name, make_node (LANG_TYPE), NULL_TREE));
  decl = lookup_name (name);
  if (decl && TREE_CODE (decl) == TYPE_DECL)
    return TREE_TYPE (decl);
  error ("pointer domain type undefined");
  return error_mark_node;
}

void
set_identifier_spelling (tree id, const char *spelling, const char *filename, int line, int col)
{
  if (IDENTIFIER_SPELLING (id))
    {
      if (!strcmp (IDENTIFIER_SPELLING (id), spelling) || !filename)
        return;
      /* @@@@ Kludge! Allow `Name' (identifier) and `name' directive. */
      if (!strcasecmp (spelling, "name")
          && !strcmp (IDENTIFIER_SPELLING (id) + 1, spelling + 1))
        return;
      if (co->warn_id_case && IDENTIFIER_SPELLING_FILE (id))
        {
#ifndef GCC_3_4
          warning_with_file_and_line (filename, line, "capitalisation of `%s' doesn't match", spelling);
          warning_with_file_and_line (IDENTIFIER_SPELLING_FILE (id), IDENTIFIER_SPELLING_LINENO (id),
                                      " previous capitalisation `%s'", IDENTIFIER_SPELLING (id));
#else
#ifndef GCC_4_2
          location_t loc_aux;
          loc_aux.file = filename;
          loc_aux.line = line;
          gpc_warning ("%Hcapitalisation of identifier `%s' doesn't match", &loc_aux, spelling);
          loc_aux.file = IDENTIFIER_SPELLING_FILE (id);
          loc_aux.line = IDENTIFIER_SPELLING_LINENO (id);
          gpc_warning ("%H previous capitalisation `%s'", &loc_aux, IDENTIFIER_SPELLING (id));
#else
          gpc_warning ("capitalisation of identifier `%s' doesn't match"
                       "previous capitalisation `%s'",
                       spelling, IDENTIFIER_SPELLING (id));
#endif
#endif
        }
    }
  IDENTIFIER_SPELLING (id) = PERMANENT_STRING (spelling);
  IDENTIFIER_SPELLING_FILE (id) = filename ? PERMANENT_STRING (filename) : NULL;
  IDENTIFIER_SPELLING_LINENO (id) = line;
  IDENTIFIER_SPELLING_COLUMN (id) = col;
}

tree
make_identifier (const char *buf, int length)
{
  static int underscore_warned = 0;
  int underscore_rep = 0, i;
  const char *p;
  char *s, *t;
  tree id;
  for (i = 0; i < length; i++)
    if (buf[i] == '_')
      {
        underscore_rep |= 1;
        if (i == 0)
          underscore_rep |= 2;
        else if (buf[i - 1] == '_')
          underscore_rep |= 4;
        if (i == length - 1)
          underscore_rep |= 8;
      }
  underscore_rep &= ~underscore_warned;
  if (underscore_rep && (co->warn_underscore || pedantic))
    {
      if (underscore_rep & 1)
        {
          if (PEDANTIC (NOT_CLASSIC_PASCAL))
            error ("ISO 7185 Pascal does not allow underscores in identifiers");
          else
            underscore_rep &= ~1;
        }
      if (underscore_rep & 2)
        error_or_warning (PEDANTIC (U_B_D_M_PASCAL), "identifiers should not start with an underscore");
      if (underscore_rep & 4)
        error_or_warning (PEDANTIC (U_B_D_M_PASCAL), "identifiers should not contain two adjacent underscores");
      if (underscore_rep & 8)
        error_or_warning (PEDANTIC (U_B_D_M_PASCAL), "identifiers should not end with an underscore");

      /* Give only one each compilation */
      underscore_warned |= underscore_rep;
    }

  /* Internally, the first character is upper-case, the rest is lower-case */
  t = s = alloca (length + 1);
  p = buf;
  *t++ = TOUPPER (*p++);
  for (i = 1; i < length; i++)
    *t++ = TOLOWER (*p++);
  *t = 0;
  id = get_identifier (s);
  memcpy (s, buf, length);  /* keep the 0 terminator */
  set_identifier_spelling (id, s, pascal_input_filename, lineno, column);
  return id;
}

tree
get_identifier_with_spelling (const char *id, const char *name)
{
  tree t = get_identifier (id);
  if (!IDENTIFIER_SPELLING (t))
    set_identifier_spelling (t, name, NULL, 0, 0);
  return t;
}

/* Generate a unique identifier of the form `foo_42'. */
tree
get_unique_identifier (const char *template)
{
  static int idcount = 0;
  char *idbuf = alloca (strlen (template) + 20);
  gcc_assert (*template >= 'a' && *template <= 'z');
  sprintf (idbuf, "%s_%d", template, idcount++);
  return get_identifier (idbuf);
}

tree
build_qualified_id (tree interface_id, tree id)
{
  tree qid = get_identifier (ACONCAT ((IDENTIFIER_POINTER (interface_id), ".",
                                       IDENTIFIER_POINTER (id), NULL)));
  if (!IDENTIFIER_SPELLING (qid) && IDENTIFIER_SPELLING (interface_id)
                                 && IDENTIFIER_SPELLING (id))
    {
      char *s = ACONCAT ((IDENTIFIER_SPELLING (interface_id), ".",
                          IDENTIFIER_SPELLING (id), NULL));
      set_identifier_spelling (qid, s, NULL, 0, 0);
    }
  PASCAL_QUALIFIED_ID (qid) = 1;
  return qid;
}

tree
build_qualified_or_component_access (tree decl, tree id2)
{
  if (decl && TREE_CODE (decl) != NAMESPACE_DECL)
    return build_component_ref (undo_schema_dereference (decl), id2);
  else
    return check_identifier (build_qualified_id (DECL_NAME (decl), id2));
}

tree
check_identifier (tree id)
{
  tree decl = lookup_name (id);
  if (!decl)
    {
      tree locus = current_function_decl ? current_function_decl
                 : void_type_node  /* placeholder at global level */;
      if (IDENTIFIER_ERROR_LOCUS (id) != locus)
        {
          static int informed = 0;
          error ("undeclared identifier `%s' (first use in this routine)", IDENTIFIER_NAME (id));
          if (!informed)
            {
              error (" (Each undeclared identifier is reported only once");
              error (" for each routine it appears in.)");
              informed = 1;
            }
          /* Prevent repeated error messages */
          IDENTIFIER_ERROR_LOCUS (id) = locus;
        }
      return error_mark_node;
    }
  CHK_EM (decl);
  if (TREE_CODE (decl) == LABEL_DECL)
    {
      error ("invalid use of label");
      return error_mark_node;
    }
  if (!TREE_USED (decl))
    {
      if (DECL_P (decl) && DECL_EXTERNAL (decl))
        assemble_external (decl);
      TREE_USED (decl) = 1;
    }
  if (TREE_CODE (decl) == CONST_DECL)
    {
      gcc_assert (DECL_INITIAL (decl));
      decl = DECL_INITIAL (decl);
#ifdef GCC_4_0
      decl = unshare_expr (decl);
#endif
    }
  /* Set DECL_NONLOCAL if var is inherited in local routine (not for CONST_DECLs). */
  else if (DECL_P (decl) && DECL_CONTEXT (decl) && DECL_CONTEXT (decl) != current_function_decl)
    {
      DECL_NONLOCAL (decl) = 1;
      mark_addressable0 (decl);
    }
  if (TREE_CODE (TREE_TYPE (decl)) == REFERENCE_TYPE && !PASCAL_PROCEDURAL_TYPE (TREE_TYPE (decl)))
    decl = build_indirect_ref (decl, NULL);
  return decl;
}

#if defined (EGCS97) && !defined (GCC_3_3)
/* Mark ARG for GC. */
static void
mark_binding_level (void *arg)
{
  struct binding_level *level;
  for (level = *(struct binding_level **) arg; level; level = level->next)
    {
      ggc_mark_tree (level->names);
      ggc_mark_tree (level->names_end);
      ggc_mark_tree (level->forward_decls);
      ggc_mark_tree (level->labels_set);
      ggc_mark_tree (level->labels_used);
      ggc_mark_tree (level->shadowed);
      ggc_mark_tree (level->blocks);
      ggc_mark_tree (level->this_block);
      ggc_mark (level->shared_decl_lang_specific);
    }
}
#endif

#ifdef EGCS97
static void
pascal_adjust_rli (record_layout_info rli)
{
  tree f;
  for (f = TYPE_FIELDS (rli->t); f; f = TREE_CHAIN (f))
    if (DECL_BIT_FIELD (f))
      rli->packed_maybe_necessary = 1;
}
#endif

/* Needed because SIZE_TYPE etc. in the machine descriptions contain C style names. */
static tree
lookup_c_type (const char *name)
{
  if (!strcmp (name, "char"))
    return char_type_node;
  if (!strcmp (name, "short int"))
    return short_integer_type_node;
  if (!strcmp (name, "short unsigned int"))
    return short_unsigned_type_node;
  if (!strcmp (name, "int"))
    return integer_type_node;
  if (!strcmp (name, "unsigned int"))
    return unsigned_type_node;
  if (!strcmp (name, "long int"))
    return long_integer_type_node;
  if (!strcmp (name, "long unsigned int"))
    return long_unsigned_type_node;
  if (!strcmp (name, "long long int"))
    return long_long_integer_type_node;
  if (!strcmp (name, "long long unsigned int"))
    return long_long_unsigned_type_node;
  gcc_unreachable ();
}

static tree
make_real (double d)
{
  char buf[1024];
  tree res;
  /* Seems there is no backend function to convert directly from
     double to REAL_VALUE_TYPE. So we take a detour via a string. */
  int r = sprintf (buf, "%e", d);
  gcc_assert (r > 0);
  res = build_real (double_type_node, REAL_VALUE_ATOF (buf, DFmode));
  gcc_assert (TREE_TYPE (res) == double_type_node);
  return res;
}

/* Create the predefined types and some nodes representing standard constants.
   Initialize the global binding level. Declare built-in backend routines. */
void
init_decl_processing (void)
{
  unsigned int prec;

#ifndef EGCS97
  /* Make identifier nodes long enough for the language-specific slots. */
  set_identifier_size (sizeof (struct lang_identifier));
#endif

#if defined (EGCS97) && !defined (GCC_3_3)
  ggc_add_tree_root (pascal_global_trees, PTI_MAX);
  ggc_add_root (&current_binding_level, 1, sizeof (current_binding_level), mark_binding_level);
#endif

  flag_signed_char = 0;
  current_function_decl = NULL_TREE;

  self_id = get_identifier ("Self");
  schema_id = get_identifier ("_p_Schema_");
  vmt_id = get_identifier ("vmt");

  pushlevel (0);
  global_binding_level = current_binding_level;

#ifdef EGCS97
#ifdef GCC_4_0
  build_common_tree_nodes (0, 0);
#else
  build_common_tree_nodes (0);
#endif
#else
  error_mark_node = make_node (ERROR_MARK);
  TREE_TYPE (error_mark_node) = error_mark_node;
#endif

#if !defined (EGCS97) && defined (PROTECT_ERROR_MARK_NODE)
  /* Put error_mark_node in read-only memory. @@ Doesn't seem possible with gcc-3's GC. */
  {
    size_t pagesize = getpagesize ();
    tree t = valloc (pagesize);
    if (!t)
      error ("could not allocate memory to protect node");
    else
      {
        memcpy (t, error_mark_node, sizeof (struct tree_common));
        TREE_TYPE (t) = t;
        if (mprotect (t, pagesize, PROT_READ) < 0)
          perror ("mprotect");
        else
          error_mark_node = t;
      }
  }
#endif

#ifdef EGCS97
  byte_integer_type_node = make_signed_type (CHAR_TYPE_SIZE);
  byte_unsigned_type_node = make_unsigned_type (CHAR_TYPE_SIZE);
  set_sizetype (lookup_c_type (SIZE_TYPE));
  ptrdiff_type_node = lookup_c_type (PTRDIFF_TYPE);
  /* must be done after set_sizetype */
  wchar_type_node = make_unsigned_type (WCHAR_TYPE_SIZE);
#ifndef GCC_4_2
  TREE_SET_CODE (char_type_node, CHAR_TYPE);
  TREE_SET_CODE (wchar_type_node, CHAR_TYPE);
#else
  PASCAL_CHAR_TYPE (char_type_node) = 1;
  PASCAL_CHAR_TYPE (wchar_type_node) = 1;
#endif
  build_common_tree_nodes_2 (0);
#else
  integer_type_node = make_signed_type (INT_TYPE_SIZE);
  long_integer_type_node = make_signed_type (LONG_TYPE_SIZE);
  unsigned_type_node = make_unsigned_type (INT_TYPE_SIZE);
  long_unsigned_type_node = make_unsigned_type (LONG_TYPE_SIZE);
  long_long_integer_type_node = make_signed_type (LONG_LONG_TYPE_SIZE);
  long_long_unsigned_type_node = make_unsigned_type (LONG_LONG_TYPE_SIZE);
  short_integer_type_node = make_signed_type (SHORT_TYPE_SIZE);
  short_unsigned_type_node = make_unsigned_type (SHORT_TYPE_SIZE);
  byte_integer_type_node = make_signed_type (CHAR_TYPE_SIZE);
  byte_unsigned_type_node = make_unsigned_type (CHAR_TYPE_SIZE);
  char_type_node = make_node (CHAR_TYPE);
  TYPE_PRECISION (char_type_node) = CHAR_TYPE_SIZE;
  fixup_unsigned_type (char_type_node);
  TYPE_UNSIGNED (char_type_node) = 1;
#endif

  /* Define `integer' and `char' first (required by dbx).
     Lower-case to avoid conflicts with the real Pascal identifiers (predef.c) */
  TYPE_NAME (integer_type_node) = gpc_build_decl (TYPE_DECL, get_identifier ("integer"), integer_type_node);
  TYPE_NAME (char_type_node) = gpc_build_decl (TYPE_DECL, get_identifier ("char"), char_type_node);

#ifndef EGCS97
#ifdef EGCS
  set_sizetype (lookup_c_type (SIZE_TYPE));
#else
  sizetype = lookup_c_type (SIZE_TYPE);
#endif

  ptrdiff_type_node = lookup_c_type (PTRDIFF_TYPE);

  TREE_TYPE (TYPE_SIZE (integer_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (char_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (unsigned_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (long_unsigned_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (long_integer_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (long_long_integer_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (long_long_unsigned_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (short_integer_type_node)) = sizetype;
  TREE_TYPE (TYPE_SIZE (short_unsigned_type_node)) = sizetype;

  intQI_type_node = make_signed_type (GET_MODE_BITSIZE (QImode));
  intHI_type_node = make_signed_type (GET_MODE_BITSIZE (HImode));
  intSI_type_node = make_signed_type (GET_MODE_BITSIZE (SImode));
  intDI_type_node = make_signed_type (GET_MODE_BITSIZE (DImode));
  intTI_type_node = make_signed_type (GET_MODE_BITSIZE (TImode));
  unsigned_intQI_type_node = make_unsigned_type (GET_MODE_BITSIZE (QImode));
  unsigned_intHI_type_node = make_unsigned_type (GET_MODE_BITSIZE (HImode));
  unsigned_intSI_type_node = make_unsigned_type (GET_MODE_BITSIZE (SImode));
  unsigned_intDI_type_node = make_unsigned_type (GET_MODE_BITSIZE (DImode));
  unsigned_intTI_type_node = make_unsigned_type (GET_MODE_BITSIZE (TImode));

  float_type_node = make_node (REAL_TYPE);
  TYPE_PRECISION (float_type_node) = FLOAT_TYPE_SIZE;
  layout_type (float_type_node);

  double_type_node = make_node (REAL_TYPE);
  TYPE_PRECISION (double_type_node) = DOUBLE_TYPE_SIZE;
  layout_type (double_type_node);

  long_double_type_node = make_node (REAL_TYPE);
  TYPE_PRECISION (long_double_type_node) = LONG_DOUBLE_TYPE_SIZE;
  layout_type (long_double_type_node);

  complex_double_type_node = make_node (COMPLEX_TYPE);
  TREE_TYPE (complex_double_type_node) = double_type_node;
  layout_type (complex_double_type_node);

  integer_zero_node = build_int_2 (0, 0);
  TREE_TYPE (integer_zero_node) = integer_type_node;
  integer_one_node = build_int_2 (1, 0);
  TREE_TYPE (integer_one_node) = integer_type_node;
  integer_minus_one_node = build_int_2 (-1, -1);
  TREE_TYPE (integer_minus_one_node) = integer_type_node;

  size_zero_node = size_int (0);
  size_one_node = size_int (1);

  void_type_node = make_node (VOID_TYPE);
  layout_type (void_type_node);  /* Uses integer_zero_node */
  /* We are not going to have real types in Pascal with less than byte alignment,
     so we might as well not have any types that claim to have it. */
  TYPE_ALIGN (void_type_node) = BITS_PER_UNIT;

  wchar_type_node = lookup_c_type (WCHAR_TYPE);

#endif

  void_list_node = build_tree_list (NULL_TREE, void_type_node);

  ptr_type_node = build_pointer_type (void_type_node);
  const_ptr_type_node = build_pointer_type (p_build_type_variant (void_type_node, 1, 0));

  ptrsize_unsigned_type_node = make_unsigned_type (TREE_INT_CST_LOW (TYPE_SIZE (ptr_type_node)));
  ptrsize_integer_type_node = make_signed_type (TREE_INT_CST_LOW (TYPE_SIZE (ptr_type_node)));

  /* Pascal types. */

  /* Boolean types. */
  boolean_type_node = build_boolean_type (1);
  byte_boolean_type_node = build_boolean_type (TYPE_PRECISION (byte_unsigned_type_node));
  short_boolean_type_node = build_boolean_type (TYPE_PRECISION (short_unsigned_type_node));
  word_boolean_type_node = build_boolean_type (TYPE_PRECISION (pascal_cardinal_type_node));
  cword_boolean_type_node = build_boolean_type (TYPE_PRECISION (unsigned_type_node));
  long_boolean_type_node = build_boolean_type (TYPE_PRECISION (long_unsigned_type_node));
  long_long_boolean_type_node = build_boolean_type (TYPE_PRECISION (long_long_unsigned_type_node));
  cboolean_type_node = make_unsigned_type (BOOL_TYPE_SIZE);
  TREE_SET_CODE (cboolean_type_node, BOOLEAN_TYPE);
#ifndef GCC_4_0
  TYPE_MAX_VALUE (cboolean_type_node) = build_int_2 (1, 0);
  TREE_TYPE (TYPE_MAX_VALUE (cboolean_type_node)) = cboolean_type_node;
#else
  TYPE_MAX_VALUE (cboolean_type_node) = 
       build_int_cst_wide (cboolean_type_node, 1, 0);
#endif
  TYPE_PRECISION (cboolean_type_node) = 1;

  /* Set alignment. */
  set_word_size = set_alignment = TYPE_PRECISION (long_unsigned_type_node);
  set_words_big_endian = 0;

  complex_type_node = complex_double_type_node;

  /* Don't use sizetype for `SizeType' in Pascal because it has
     TYPE_IS_SIZETYPE set (see comments in tree.h). */
  size_type_node = long_unsigned_type_node;

  open_array_index_type_node = build_type_copy (pascal_integer_type_node);
  PASCAL_TYPE_OPEN_ARRAY (open_array_index_type_node) = 1;

  /* Some constants */
  boolean_false_node = TYPE_MIN_VALUE (boolean_type_node);
  boolean_true_node = TYPE_MAX_VALUE (boolean_type_node);
  pascal_maxint_node = convert (pascal_integer_type_node, TYPE_MAX_VALUE (pascal_integer_type_node));
  real_max_node = make_real (DBL_MAX);
  real_min_node = make_real (DBL_MIN);
  real_eps_node = make_real (DBL_EPSILON);
  real_zero_node = build_real (double_type_node, REAL_VALUE_ATOF ("0.0", DFmode));
  real_half_node = build_real (double_type_node, REAL_VALUE_ATOF ("0.5", DFmode));
  real_pi_node = build_real (long_double_type_node,
    REAL_VALUE_ATOF ("3.14159265358979323846264338327950288419717",
                     TYPE_MODE (long_double_type_node)));
  char_max_node = convert (char_type_node, TYPE_MAX_VALUE (char_type_node));
  complex_zero_node = build_complex (TREE_TYPE (real_zero_node), real_zero_node, real_zero_node);
#ifndef GCC_4_0
  null_pointer_node = build_int_2 (0, 0);
  TREE_TYPE (null_pointer_node) = ptr_type_node;
#else
  null_pointer_node = build_int_cst(ptr_type_node, 0);
#endif
  null_pseudo_const_node = build_indirect_ref (null_pointer_node, NULL);

  cstring_type_node = build_pointer_type (char_type_node);

  empty_string_node = build_string_constant ("", 0, 0);

  prec = TYPE_PRECISION (size_type_node);
  packed_array_unsigned_long_type_node = make_unsigned_type (prec);
  packed_array_unsigned_short_type_node = make_unsigned_type (prec / 2);

  empty_set_type_node = make_node (SET_TYPE);
  PASCAL_TYPE_CANONICAL_SET (empty_set_type_node) = 1;

#define dopar(type, next) tree_cons (NULL_TREE, type, next)

#define ATTR_NULL NULL_TREE
#define ATTR_NORETURN_NOTHROW_LIST \
  tree_cons (get_identifier ("noreturn"), NULL_TREE, NULL_TREE)
 /*           tree_cons (get_identifier ("nothrow"), NULL_TREE, NULL_TREE) */

  memcpy_routine_node = gpc_builtin_routine ("__builtin_memcpy", "memcpy",
    BUILT_IN_MEMCPY,
    ptr_type_node, dopar (ptr_type_node, dopar (const_ptr_type_node, dopar (sizetype, void_list_node))), ATTR_NULL);
  memset_routine_node = gpc_builtin_routine ("__builtin_memset", "memset", BUILT_IN_MEMSET,
    ptr_type_node, dopar (ptr_type_node, dopar (integer_type_node, dopar (sizetype, void_list_node))), ATTR_NULL);
  strlen_routine_node = gpc_builtin_routine ("__builtin_strlen", "strlen", BUILT_IN_STRLEN,
    sizetype, dopar (build_pointer_type (p_build_type_variant (char_type_node, 1, 0)), void_list_node), ATTR_NULL);
  setjmp_routine_node = gpc_builtin_routine ("__builtin_setjmp", "setjmp", BUILT_IN_SETJMP,
    integer_type_node, dopar (ptr_type_node, void_list_node), ATTR_NULL);
  longjmp_routine_node = gpc_builtin_routine ("__builtin_longjmp", "longjmp", BUILT_IN_LONGJMP,
    void_type_node, dopar (ptr_type_node, dopar (integer_type_node, void_list_node)), ATTR_NORETURN_NOTHROW_LIST);
  return_address_routine_node = gpc_builtin_routine ("__builtin_return_address", NULL, BUILT_IN_RETURN_ADDRESS,
    ptr_type_node, dopar (unsigned_type_node, void_list_node), ATTR_NULL);
  frame_address_routine_node = gpc_builtin_routine ("__builtin_frame_address", NULL, BUILT_IN_FRAME_ADDRESS,
    ptr_type_node, dopar (unsigned_type_node, void_list_node), ATTR_NULL);

#ifdef GCC_4_0
  build_common_builtin_nodes ();
  (*targetm.init_builtins) ();

  main_identifier_node = get_identifier ("main");
#endif

  pedantic_lvalues = pedantic;

#ifdef EGCS97
#ifndef GCC_4_2
  set_lang_adjust_rli (&pascal_adjust_rli);
#endif
#else
  start_identifier_warnings ();
#endif
}

/* Create a definition for a builtin function.
   FUNCTION_CODE tells later passes how to compile calls to this function.
   See tree.h for its possible values.
   If LIBRARY_NAME is nonzero, use that as the name to be called if we
   can't opencode the function. */
static tree
gpc_builtin_routine (const char *name, const char *library_name, int function_code, tree resulttype, tree args, tree attributes)
{
  tree decl = gpc_build_decl (FUNCTION_DECL, get_identifier (name), build_function_type (resulttype, args));
  DECL_EXTERNAL (decl) = 1;
  TREE_PUBLIC (decl) = 1;
  if (library_name)
    SET_DECL_ASSEMBLER_NAME (decl, get_identifier (library_name));
#ifdef EGCS97
#ifndef GCC_4_0
  make_decl_rtl (decl, NULL);
#endif
  DECL_BUILT_IN_CLASS (decl) = BUILT_IN_NORMAL;
  DECL_FUNCTION_CODE (decl) = function_code;
  decl_attributes (&decl, attributes, 0);
#else
  make_decl_rtl (decl, NULL, 1);
  DECL_BUILT_IN (decl) = 1;
  DECL_FUNCTION_CODE (decl) = function_code;
#endif
  return decl;
}

#ifdef EGCS97
tree
#ifdef GCC_3_3
builtin_function (const char *name, tree type, int function_code, enum built_in_class class ATTRIBUTE_UNUSED, const char *library_name, tree attributes)
#else
builtin_function (const char *name, tree type, int function_code, enum built_in_class class ATTRIBUTE_UNUSED, const char *library_name)
#endif
{
  return gpc_builtin_routine (name, library_name, function_code,
    TREE_TYPE (type), TYPE_ARG_TYPES (type),
#ifdef GCC_3_3
    attributes
#else
    NULL_TREE
#endif
  );
}
#endif

/* Allocate TYPE_LANG_SPECIFIC if not allocated yet. */
void
allocate_type_lang_specific (tree type)
{
  struct lang_type *td;
  if (TYPE_LANG_SPECIFIC (type))
    return;
#ifdef EGCS97
  td = (struct lang_type *) ggc_alloc (sizeof (*td));
#else
  td = (struct lang_type *) obstack_alloc (TYPE_OBSTACK (type), sizeof (*td));
#endif
  memset (td, 0, sizeof (*td));
  TYPE_LANG_SPECIFIC (type) = td;
}

/* Copy TYPE_LANG_SPECIFIC if allocated. */
void
copy_type_lang_specific (tree type)
{
  struct lang_type *td = TYPE_LANG_SPECIFIC (type);
  if (!td)
    return;
  TYPE_LANG_SPECIFIC (type) = NULL;
  allocate_type_lang_specific (type);
  memcpy (TYPE_LANG_SPECIFIC (type), td, sizeof (*td));
}

/* Allocate DECL_LANG_SPECIFIC if not allocated yet. */
void
allocate_decl_lang_specific (tree decl)
{
  struct lang_decl *ld, *od = DECL_LANG_SPECIFIC (decl);
  if (od && LANG_SPECIFIC_SHARED (od) != self_id)
    return;
#ifdef EGCS97
  ld = (struct lang_decl *) ggc_alloc (sizeof (*ld));
#else
  ld = (struct lang_decl *) obstack_alloc (&permanent_obstack, sizeof (*ld));
#endif
  memset (ld, 0, sizeof (*ld));
  if (od)
    ld->used_in_scope = od->used_in_scope;
  DECL_LANG_SPECIFIC (decl) = ld;
}

/* Copy DECL_LANG_SPECIFIC if allocated. */
void
copy_decl_lang_specific (tree decl)
{
  struct lang_decl *ld = DECL_LANG_SPECIFIC (decl);
  if (!ld || LANG_SPECIFIC_SHARED (ld) == self_id)
    return;
  DECL_LANG_SPECIFIC (decl) = NULL;
  allocate_decl_lang_specific (decl);
  memcpy (DECL_LANG_SPECIFIC (decl), ld, sizeof (*ld));
}

/* Start a RECORD_TYPE or UNION_TYPE.
   Also do a push_obstacks_nochange whose matching pop is in finish_struct. */
tree
start_struct (enum tree_code code)
{
  tree t;
#ifndef EGCS97
  push_obstacks_nochange ();
  if (current_binding_level == global_binding_level)
    end_temporary_allocation ();
#endif
  t = make_node (code);
  /* Create a fake nameless TYPE_DECL node whose TREE_TYPE is the structure
     just started. This fake decl helps dwarfout.c to know when it needs to
     output a representation of a type not yet finished. */
  TYPE_STUB_DECL (t) = gpc_build_decl (TYPE_DECL, NULL_TREE, t);
  return t;
}

/* Returns 1 if type is or contains a field of a type that must always
   be aligned on systems with strict alignment requirements. */
static int
contains_aligned_field (tree type)
{
  switch (TREE_CODE (type))
  {
    case ARRAY_TYPE:
      return contains_aligned_field (TREE_TYPE (type));
    case SET_TYPE:
      return 1;
    case RECORD_TYPE:
    case UNION_TYPE:
    case QUAL_UNION_TYPE:
      {
        tree field;
        if (PASCAL_TYPE_STRING (type)
            || PASCAL_TYPE_FILE (type)
            || PASCAL_TYPE_OBJECT (type)
            || TYPE_MAIN_VARIANT (type) == gpc_type_TimeStamp
            || TYPE_MAIN_VARIANT (type) == gpc_type_BindingType)
          return 1;
        for (field = TYPE_FIELDS (type); field; field = TREE_CHAIN (field))
          if (contains_aligned_field (TREE_TYPE (field)))
            return 1;
        break;
      }
    default:
      break;
  }
  return 0;
}

static int
field_decl_cmp (const PTR xp, const PTR yp)
{
  tree x = *(tree *) xp, y = *(tree *) yp;
  /* Make sure inner levels (variants and schema bodies) appear first */
  return (!DECL_NAME (x) || DECL_NAME (x) == schema_id
          || (DECL_NAME (y) && DECL_NAME (y) != schema_id
              && DECL_NAME (x) < DECL_NAME (y))) ? -1 : 1;
}

static long
visible_list_length (tree t);

static long
visible_list_length (tree t)
{
  long res = 0;
  while (t)
    {
      res += !PASCAL_FIELD_SHADOWED (t);
      t = TREE_CHAIN (t);
    }
  return res;
}

/* If there are lots of fields, sort them to speed up find_field(). We arbitrarily
   consider 8 fields to be "a lot" (so "lots" are 16 or more fields ;-). */

void
sort_fields (tree t)
{
  tree fieldlist = TYPE_FIELDS (t), x;
  long len = visible_list_length (fieldlist);
  if (len >= 16)
    {
#ifdef EGCS97
      tree *fields = (tree *) ggc_alloc (len * sizeof (tree));
#else
      tree *fields = (tree *) obstack_alloc (TYPE_OBSTACK (t), len * sizeof (tree));
#endif
      for (len = 0, x = fieldlist; x; x = TREE_CHAIN (x))
        {
          if (!(PASCAL_FIELD_SHADOWED (x)))
            fields[len++] = x;
        }
      qsort (fields, len, sizeof (tree), field_decl_cmp);
      allocate_type_lang_specific (t);
      TYPE_LANG_SORTED_FIELDS (t) = fields;
      TYPE_LANG_FIELD_COUNT (t) = len;
    }
  else if (TYPE_LANG_SPECIFIC (t))
    {
      TYPE_LANG_SORTED_FIELDS (t) = NULL;
      TYPE_LANG_FIELD_COUNT (t) = 0;
    }
}

static void
check_id_redeclaration (tree name, const char * msg)
{
  tree t = peek_name (name);
  if (t && TREE_CODE_CLASS (TREE_CODE (t)) == tcc_declaration
      && DECL_LANG_SPECIFIC (t)
      && DECL_LANG_SPECIFIC (t)->used_in_scope >= current_binding_level->scope)
    {
      if (co->pascal_dialect & C_E_O_PASCAL)
        error (msg, IDENTIFIER_NAME (name));
      else
        gpc_warning (msg, IDENTIFIER_NAME (name));
    }
}


static void
check_field_list (tree record)
{
  tree field;
  if (TREE_CODE (record) == POINTER_TYPE && PASCAL_TYPE_CLASS (record))
    record = TREE_TYPE (record);
  if (!RECORD_OR_UNION (TREE_CODE (record)))
    return;
  for (field = TYPE_FIELDS (record); field; field = TREE_CHAIN (field))
    if (!DECL_NAME (field) || DECL_NAME (field) == schema_id)
      check_field_list (TREE_TYPE (field));
    else
      {
        tree name = DECL_NAME (field);
        gcc_assert (name);
        check_id_redeclaration (name, 
             "field `%s' declared but an outer value was used");
      }
}

static int
find_duplicate_fields (tree main_type, tree current_type)
{
  int res = 0;
  tree field;
  if (!RECORD_OR_UNION (TREE_CODE (current_type)))
    return 0;
  for (field = TYPE_FIELDS (current_type); field; field = TREE_CHAIN (field))
    if (!DECL_NAME (field) || DECL_NAME (field) == schema_id)
      res += find_duplicate_fields (main_type, TREE_TYPE (field));
    else if (!(PASCAL_FIELD_SHADOWED (field)))
      {
        tree dup = find_field (main_type, DECL_NAME (field), 2);
        gcc_assert (dup);
        if (dup != field)
          {
            error_with_decl (field, "duplicate field `%s'");
            res++;
          }
      }
  return res;
}

/* Fill in the fields of a RECORD_TYPE or UNION_TYPE node, T.
   FIELDLIST is a chain of FIELD_DECL nodes for the fields.
   ATTRIBUTES are attributes to be applied to the structure.
   We also do a pop_obstacks to match the push in start_struct. */
tree
finish_struct (tree t, tree fieldlist, int allow_packed)
{
  tree x;
#ifndef EGCS97
  int old_momentary;
#endif
  int save_maximum_field_alignment = maximum_field_alignment;

  for (x = fieldlist; x; x = TREE_CHAIN (x))
    if (EM (TREE_TYPE (x)))
      {
#ifndef EGCS97
        /* The matching push is in start_struct. */
        pop_obstacks ();
#endif
        return error_mark_node;
      }

#ifndef EGCS97
  old_momentary = suspend_momentary ();
#endif

  TYPE_PACKED (t) = allow_packed && (defining_packed_type || flag_pack_struct);

  for (x = fieldlist; x; x = TREE_CHAIN (x))
    {
      int uns = 0;
      tree type = TREE_TYPE (x), bits = (allow_packed && defining_packed_type) ? count_bits (type, &uns) : NULL_TREE;
      DECL_FIELD_CONTEXT (x) = t;
      DECL_PACKED (x) |= TYPE_PACKED (t);
      DECL_PACKED_FIELD (x) = !!(allow_packed && defining_packed_type);
#ifndef EGCS97
      DECL_FIELD_SIZE (x) = 0;
#else
      DECL_SIZE (x) = 0;
      DECL_SIZE_UNIT (x) = 0;
#endif
      if (bits)
        {
          /* Explicit `packed' record, ordinal field (which can be bit-packed) */
#if 1
          if (uns != TYPE_UNSIGNED (type))
            {
              TREE_TYPE (x) = type = build_type_copy (type);
              new_main_variant (type);
              TYPE_UNSIGNED (type) = uns;
            }
#else
          /* @@@@ In principle we should do this, but it causes problems
             in inipak1[lm].pas and sam9.pas */
          TREE_TYPE (x) = type = build_type_copy (type);
          new_main_variant (type);
          TYPE_UNSIGNED (type) = uns;
          TYPE_PRECISION (type) = TREE_INT_CST_LOW (bits);
#endif
#ifdef EGCS97
          DECL_SIZE (x) = bitsize_int (TREE_INT_CST_LOW (bits));
#else
          DECL_FIELD_SIZE (x) = TREE_INT_CST_LOW (bits);
#endif
          DECL_BIT_FIELD (x) = 1;
#ifdef GCC_4_0
          DECL_NONADDRESSABLE_P (x) = 1;
#endif
#if 0
          DECL_PACKED (x) = 0;  /* suppress warning with `-Wpacked' */
#endif
        }
      else
        {
          /* Non-bitfields are aligned for their type, except packed fields
             which require only BITS_PER_UNIT alignment. However, on systems
             with strict alignment requirements (now on all systems), align
             records used by the RTS etc. */
          if (contains_aligned_field (type))
            /* necessary to let it be passed by reference to RTS routines, but also to user routines @@ */
            DECL_PACKED (x) = DECL_PACKED_FIELD (x) = 0;
          DECL_ALIGN (x) = MAX (DECL_ALIGN (x), DECL_PACKED (x) ? BITS_PER_UNIT : TYPE_ALIGN (type));
        }
    }
  TYPE_FIELDS (t) = fieldlist;
  if (!allow_packed || defining_packed_type)
    maximum_field_alignment = 0;
  layout_type (t);
  maximum_field_alignment = save_maximum_field_alignment;
  sort_fields (t);
  /* Do this here, so it can take advantage of sorted fields */
  find_duplicate_fields (t, t);
  if (!EM (t))
    for (x = TYPE_MAIN_VARIANT (t); x; x = TYPE_NEXT_VARIANT (x))
      {
        TYPE_FIELDS (x) = TYPE_FIELDS (t);
        TYPE_LANG_SPECIFIC (x) = TYPE_LANG_SPECIFIC (t);
        TYPE_ALIGN (x) = TYPE_ALIGN (t);
        TYPE_PACKED (x) = TYPE_PACKED (t);
        TYPE_NO_FORCE_BLK (x) = TYPE_NO_FORCE_BLK (t);
        TYPE_BINFO (x) = TYPE_BINFO (t);
#ifdef EGCS97
        TYPE_USER_ALIGN (x) = TYPE_USER_ALIGN (t);
#endif
      }

#ifndef EGCS97
  resume_momentary (old_momentary);
#endif

  /* Finish debugging output for this type. */
  if (!EM (t) && !current_type_list)
    rest_of_type_compilation (t, current_binding_level == global_binding_level);

#ifndef EGCS97
  /* The matching push is in start_struct. */
  pop_obstacks ();
#endif

  return t;
}

void
type_attributes (tree *d, tree attributes)
{
  tree *tt = &attributes;
  while (*tt)
    if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_size)
        && (TYPE_IS_INTEGER_TYPE (*d) || TREE_CODE (*d) == BOOLEAN_TYPE))
      {
        if (!TREE_VALUE (*tt) || list_length (TREE_VALUE (*tt)) != 1)
          error ("`%s' attribute must have one argument", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        else
          {
            tree b = TREE_VALUE (TREE_VALUE (*tt));
            STRIP_TYPE_NOPS (b);
            b = fold (b);
            if (TREE_CODE (b) != INTEGER_CST ||
                !TYPE_IS_INTEGER_TYPE (TREE_TYPE (b)))
              error ("integer bit specification must be an integer constant");
            else
              {
                unsigned HOST_WIDE_INT bits = TREE_INT_CST_LOW (b);
                if (TREE_INT_CST_HIGH (b) != 0 || bits == 0)
                  error ("invalid integer bit specification");
                else if (bits > TYPE_PRECISION (long_long_integer_type_node))
                  error ("integer type is too large (maximum %i bits)",
                         (int) TYPE_PRECISION (long_long_integer_type_node));
                if (TREE_CODE (*d) == BOOLEAN_TYPE)
                  *d = build_boolean_type (bits);
                else if (TYPE_UNSIGNED (*d))
                  *d = make_unsigned_type (bits);
                else
                  *d = make_signed_type (bits);
              }
          }
        *tt = TREE_CHAIN (*tt);
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_iocritical)
             && (TREE_CODE (*d) == POINTER_TYPE || TREE_CODE (*d) == REFERENCE_TYPE)
             && TREE_CODE (TREE_TYPE (*d)) == FUNCTION_TYPE)
      {
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        *d = build_type_copy (*d);
        TREE_TYPE (*d) = build_type_copy (TREE_TYPE (*d));
        PASCAL_TYPE_IOCRITICAL (TREE_TYPE (*d)) = 1;
        *tt = TREE_CHAIN (*tt);
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_volatile))
      {
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        *d = p_build_type_variant (*d, TYPE_READONLY (*d), 1);
        *tt = TREE_CHAIN (*tt);
      }
    else
      tt = &TREE_CHAIN (*tt);
  if ((TREE_CODE (*d) == POINTER_TYPE || TREE_CODE (*d) == REFERENCE_TYPE)
      && TREE_CODE (TREE_TYPE (*d)) == FUNCTION_TYPE)
    {
      TREE_TYPE (*d) = build_type_copy (TREE_TYPE (*d));
      pascal_decl_attributes (&(TREE_TYPE (*d)), attributes);
    }
  else
    pascal_decl_attributes (d, attributes);
}

void
routine_attributes (tree *d, tree attributes, tree *assembler_name)
{
  tree *tt = &attributes;
  while (*tt)
    if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_name))
      {
        if (TREE_VALUE (*tt) && list_length (TREE_VALUE (*tt)) == 1)
          *assembler_name = TREE_VALUE (TREE_VALUE (*tt));
        else
          error ("`%s' attribute must have one argument", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        *tt = TREE_CHAIN (*tt);
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_iocritical))
      {
        tree t = TREE_TYPE (*d) = build_type_copy (TREE_TYPE (*d));
        PASCAL_TYPE_IOCRITICAL (t) = 1;
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        *tt = TREE_CHAIN (*tt);
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_ignorable))
      {
        tree t = TREE_TYPE (*d) = build_type_copy (TREE_TYPE (*d));
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        if (TREE_CODE (TREE_TYPE (t)) == VOID_TYPE)
          gpc_warning ("`%s' is meaningless for a procedure", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        else
          PASCAL_TREE_IGNORABLE (t) = 1;
        *tt = TREE_CHAIN (*tt);
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_inline))
      {
        /* Record presence of `inline' if it is reasonable.
           @@ Only honour it if really inlining. I'm not sure if it's right
              to check this here, but at least it works. (maur3.pas) -- Frank */
        tree last = tree_last (TYPE_ARG_TYPES (TREE_TYPE (*d)));
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute", IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
        if (!last || TREE_CODE (TREE_VALUE (last)) != VOID_TYPE)
          gpc_warning ("inline declaration ignored for routine with `...'");
        else if (!flag_no_inline && optimize > 0)
          /* Assume that otherwise the function can be inlined. */
          DECL_DECLARED_INLINE_P (*d) = 1;
        *tt = TREE_CHAIN (*tt);
      }
#ifdef EGCS97
    else if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (*tt), p_noinline))
      {
        if (TREE_VALUE (*tt))
          error ("spurious argument to `%s' attribute",
                 IDENTIFIER_NAME (TREE_PURPOSE (*tt)));
         DECL_UNINLINABLE (*d) = 1;
         *tt = TREE_CHAIN (*tt);
      }
#endif
    else
      tt = &TREE_CHAIN (*tt);
  pascal_decl_attributes (d, attributes);
}

tree
check_assembler_name (tree name)
{
  const char *p;
  if (TREE_CODE (name) == STRING_CST)
    name = get_identifier (TREE_STRING_POINTER (name));
  if (TREE_CODE (name) != IDENTIFIER_NODE)
    {
      error ("linker name is no string constant");
      return get_unique_identifier ("dummy");  /* avoid crashing later */
    }
  p = IDENTIFIER_POINTER (name);
  if (!*p)
    error ("empty linker name");
  if (*p >= '0' && *p <= '9')
    error ("linker name `%s' starts with a digit", IDENTIFIER_POINTER (name));
  while (*p && *p != ' ' && *p != '\t')
    p++;
  if (*p)
    error ("linker name `%s' contains whitespace", IDENTIFIER_POINTER (name));
  return name;
}

/* Remote routine declaration (forward, external, interface). */
tree
declare_routine (tree heading, tree directives, int interface)
{
  int any_dir = 0, is_public = 0, is_forward = 0, is_external = 0, c_dir = 0;
  tree d, d1, dir, assembler_name = NULL_TREE, t;
  tree name = DECL_NAME (heading);
  tree args, argtypes = build_formal_param_list (DECL_ARGUMENTS (heading), DECL_CONTEXT (heading), &args);

  t = TREE_TYPE (heading);
  if (!t)
    error ("result type of function `%s' undefined", IDENTIFIER_NAME (name));
  if (!t || EM (t))
    return error_mark_node;

  d = gpc_build_decl (FUNCTION_DECL, name, build_function_type (t, argtypes));
  allocate_decl_lang_specific (d);

  for (dir = directives; dir; dir = TREE_CHAIN (dir))
    if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_name))
      {
        assembler_name = TREE_PURPOSE (dir);
        any_dir = 1;
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_asmname))
      {
        gpc_warning ("`%s' is deprecated; use `external name' or `attribute (name = ...)' instead",
                 IDENTIFIER_NAME (TREE_VALUE (dir)));
        assembler_name = TREE_PURPOSE (dir);
        any_dir = 1;
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_c)
             || IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_c_language))
      {
        gpc_warning ("`%s' is deprecated; use `external' instead",
                 IDENTIFIER_NAME (TREE_VALUE (dir)));
        any_dir = c_dir = is_public = 1;
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_external))
      {
        is_external = is_public = 1;
        if (TREE_PURPOSE (dir))
          gpc_warning ("library name in `external' is ignored");
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_forward))
      any_dir = is_forward = 1;
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_attribute))
      {
        routine_attributes (&d, TREE_PURPOSE (dir), &assembler_name);
        any_dir = 1;
      }
    else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_near)
             || IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_far))
      {
        if (co->warn_near_far)
          gpc_warning ("`%s' directive ignored because of flat memory model", IDENTIFIER_NAME (TREE_VALUE (dir)));
      }
    else
      error ("unknown directive `%s'", IDENTIFIER_NAME (TREE_VALUE (dir)));

  if (is_external && !assembler_name)
    {
      gpc_warning ("`external' without `name' has a different default now");
      gpc_warning (" (This gpc_warning will disappear in a future version)");
    }

  is_external |= c_dir;

  if (assembler_name)
    is_public = 1;
  if (interface)
    {
      is_forward = !is_external;
      is_public = 1;
    }

  TREE_PUBLIC (d) = is_public /*|| !is_forward */;
  DECL_EXTERNAL (d) = is_external /*TREE_PUBLIC (d) || pascal_global_bindings_p ()*/;
  DECL_LANG_RESULT_VARIABLE (d) = DECL_RESULT (heading);
  DECL_LANG_PARMS (d) = args;

  d1 = d;
  d = pushdecl (d);
  gcc_assert (!EM (d));

  /* Only allow `external' for previously declared routines. */
  if (d != d1 && any_dir)
    error ("attributes in previously declared routines are not allowed");

  PASCAL_FORWARD_DECLARATION (d) = is_forward;
  if (PASCAL_FORWARD_DECLARATION (d))
    set_forward_decl (d, interface);
  else if (!interface)
    resolve_forward_decl (name);

  if (assembler_name)
    SET_DECL_ASSEMBLER_NAME (d, check_assembler_name (assembler_name));
  else if (DECL_EXTERNAL (d))
    SET_DECL_ASSEMBLER_NAME (d, de_capitalize (name));
  else
    SET_DECL_ASSEMBLER_NAME (d, mangle_name (name));

#ifndef GCC_4_0
  rest_of_decl_compilation (d, 0, !DECL_CONTEXT (d), 1 /* for GPC */);
#endif

  /* Prevent the optimizer from removing it if it is public. */
  if (TREE_PUBLIC (d))
    mark_addressable0 (d);

  t = DECL_INITIAL (heading);
  SET_DECL_LANG_OPERATOR_DECL (d, t);
  handle_autoexport (name);
  if (t)
    handle_autoexport (DECL_NAME (t));
  return d;
}

tree
build_implicit_routine_decl (tree id, tree res_type, tree args, int attributes)
{
  tree t = build_function_type (res_type, args), d;
  if (attributes & ER_IOCRITICAL)
    {
      t = build_type_copy (t);
      PASCAL_TYPE_IOCRITICAL (t) = 1;
    }
  d = gpc_build_decl (FUNCTION_DECL, id, t);
  DECL_ARTIFICIAL (d) = 1;
  SET_DECL_ASSEMBLER_NAME (d, id);
  TREE_PUBLIC (d) = !(attributes & ER_STATIC);
  DECL_EXTERNAL (d) = !!(attributes & ER_EXTERNAL);
  if (attributes & ER_NORETURN)
    TREE_THIS_VOLATILE (d) = 1;
  if (attributes & ER_CONST)
    TREE_READONLY (d) = 1;
  mark_addressable0 (d);
#ifndef GCC_4_0
  rest_of_decl_compilation (d, NULL, 1, 1);
#endif
  return d;
}

/* Returns a dummy FUNCTION_DECL */
tree
build_routine_heading (tree object_name, tree name, tree parameters, tree resultvar, tree resulttype, int structor)
{
  tree t = make_node (FUNCTION_DECL);
  if (object_name)
    {
      tree object_type = lookup_name (object_name);
      if (object_type && TREE_CODE (object_type) == TYPE_DECL
          && TREE_CODE (TREE_TYPE (object_type)) == POINTER_TYPE
          && PASCAL_TYPE_CLASS (TREE_TYPE (object_type)))
        {
          name = get_method_name (object_name, name);
          DECL_CONTEXT (t) = TREE_TYPE (object_type);
        }
      else
      if (object_type && TREE_CODE (object_type) == TYPE_DECL && PASCAL_TYPE_OBJECT (TREE_TYPE (object_type)))
        {
          name = get_method_name (object_name, name);
          DECL_CONTEXT (t) = TREE_TYPE (object_type);
        }
      else
        error ("object type name expected, `%s' given", IDENTIFIER_NAME (object_name));
      PASCAL_METHOD (t) = 1;
    }
  DECL_NAME (t) = name;
  TREE_TYPE (t) = resulttype;
  DECL_ARGUMENTS (t) = parameters;
  DECL_RESULT (t) = resultvar;
  PASCAL_STRUCTOR_METHOD (t) = structor;
  return t;
}

tree
build_operator_heading (tree name, tree parameters, tree resultvar, tree resulttype)
{
  int l = 0;
  tree res, t, t1 = NULL_TREE, t2 = NULL_TREE, placeholder_decl = NULL_TREE, n = NULL_TREE;
  for (t = parameters; t; t = TREE_CHAIN (t))
    if (TREE_CODE (t) == TREE_LIST && !TREE_VALUE (t))  /* ellipsis */
      l = 3;
    else
      {
        if (l == 0)
          t1 = TREE_VALUE (t);
        if (l <= 1)
          t2 = TREE_VALUE (t);
        l += list_length (TREE_PURPOSE (t));
      }

  /* Attach a placeholder declaration to the identifier, for the error message
     when using it with wrong types, to detect duplicate declarations, and for
     weak keywords, to parse them as identifiers from now on, and put it in
     DECL_LANG_OPERATOR_DECL (elsewhere) to mark the routine as an operator.
     Mark with PASCAL_BUILTIN_OPERATOR weak keywords that are operator symbols
     so lookup_name will not shadow their built-in meanings (which should only
     be overloaded) -- but not if they were shadowed already (fjf802*.pas).
     We need the placeholder in any case (fjf919*.pas).
     `is' and `as' are no real operators: in the OOP meaning, their right
     "operand" is a type name. It's hard to parse this together with normal
     operator usage, so do shadow them when they're defined as an operator.
     OPERATOR_DECL is currently only used for these placeholders.
     In the future, it should point to the actual functions. */
  placeholder_decl = gpc_build_decl (OPERATOR_DECL, name, void_type_node);
  DECL_IGNORED_P (placeholder_decl) = 1;
  if ((IDENTIFIER_IS_BUILT_IN (name, p_and_then)
       || IDENTIFIER_IS_BUILT_IN (name, p_or_else)
       || IDENTIFIER_IS_BUILT_IN (name, p_pow)
       || IDENTIFIER_IS_BUILT_IN (name, p_shl)
       || IDENTIFIER_IS_BUILT_IN (name, p_shr)
       || IDENTIFIER_IS_BUILT_IN (name, p_xor))
      && !lookup_name_current_level (name))
    PASCAL_BUILTIN_OPERATOR (placeholder_decl) = 1;
  placeholder_decl = pushdecl (placeholder_decl);

  chk_dialect ("operator definitions are", PASCAL_SC);
  if (!resulttype)
    {
      error ("result type of operator undefined");
      resulttype = error_mark_node;
    }
  if (l != 2)
    error ("operator must have two arguments");
  else if (TREE_CODE (t1) == BOOLEAN_TYPE
           && (IDENTIFIER_IS_BUILT_IN (name, p_and)
               || IDENTIFIER_IS_BUILT_IN (name, p_and_then)
               || IDENTIFIER_IS_BUILT_IN (name, p_or)
               || IDENTIFIER_IS_BUILT_IN (name, p_or_else)))
    {
      /* This would conflict with the fjf226 kludge because the condition is already started for the left operand. */
      error ("GPC currently doesn't allow overloading the `%s' operator", IDENTIFIER_NAME (name));
      error (" with a left operand of Boolean type");
    }
  else
    n = get_operator (IDENTIFIER_POINTER (name), IDENTIFIER_NAME (name), t1, t2, 1);
  if (!n)  /* in case of error, avoid crashing later */
    n = get_unique_identifier ("dummy");
  res = build_routine_heading (NULL_TREE, n, parameters, resultvar, resulttype, 0);
  DECL_INITIAL (res) = placeholder_decl;
  return res;
}

int
compare_routine_decls (tree d1, tree d2)
{
  return check_routine_decl (DECL_LANG_PARMS (d1), TREE_TYPE (TREE_TYPE (d1)),
    DECL_LANG_RESULT_VARIABLE (d1), 0, PASCAL_METHOD (d1), PASCAL_STRUCTOR_METHOD (d1), d2, 1);
}

int
check_routine_decl (tree arg, tree restype, tree resvar, int empty_parentheses,
                    int method, int structor, tree old, int bothways)
{
  tree old_arg = DECL_LANG_PARMS (old);
  if (PASCAL_METHOD (old) != method || PASCAL_STRUCTOR_METHOD (old) != structor)
    return 0;
  if (method)
    {
      /* ignore `Self' */
      old_arg = TREE_CHAIN (old_arg);
      arg = TREE_CHAIN (arg);
    }
  if (!bothways && (structor || !restype || (restype == void_type_node && TREE_TYPE (TREE_TYPE (old)) == void_type_node))
      && !resvar && !arg && !empty_parentheses)
    return 1;  /* empty second heading */
  if (!restype || !strictly_comp_types (restype, TREE_TYPE (TREE_TYPE (old))))
    return 0;
  if (DECL_LANG_RESULT_VARIABLE (old) != resvar)
    {
      if (!bothways && !DECL_LANG_RESULT_VARIABLE (old))
        chk_dialect ("omitting result variables in forward declarations is", GNU_PASCAL);
      else
        return 0;
    }
  for (; arg && old_arg; arg = TREE_CHAIN (arg), old_arg = TREE_CHAIN (old_arg))
   { 
     tree t1 = TREE_TYPE (arg);
     tree t2 = TREE_TYPE (old_arg);
#define NCMP_A(c, x, y) (c(x) != c(y))
    if (NCMP_A (PASCAL_TYPE_OPEN_ARRAY, t1, t2)
        || (!PASCAL_TYPE_OPEN_ARRAY (t1)
            && DECL_NAME (arg) != DECL_NAME (old_arg))
        || NCMP_A (TYPE_READONLY, t1, t2)
        || NCMP_A (PASCAL_PAR_SAME_ID_LIST, arg, old_arg)
        || NCMP_A (TREE_CODE, t1, t2)
        || (TREE_CODE (t1) == REFERENCE_TYPE
            && NCMP_A (TYPE_READONLY, TREE_TYPE (t1), TREE_TYPE (t2)))
        || !strictly_comp_types (t1, t2))
      break;
#undef NCMP_A
    }
  return !arg && !old_arg;
}

/* Routine checks if there has been a definition with a directive
   for the routine we start declaring now. Parameters and result type
   are taken from the first definition if omitted here. For methods, it
   returns the identifiers shadowed by fields, otherwise NULL_TREE. */
tree
start_routine (tree heading, tree directive)
{
  tree type = TREE_TYPE (heading), operator_decl = DECL_INITIAL (heading);
  tree resvar = DECL_RESULT (heading), name = DECL_NAME (heading), context = NULL_TREE;
  tree arglist = DECL_ARGUMENTS (heading);
  tree args, argtypes = build_formal_param_list (arglist, DECL_CONTEXT (heading), &args);
  tree assembler_name = NULL_TREE, shadowed = NULL_TREE, parm, next, dir, old, decl;
  int method = PASCAL_METHOD (heading), structor = PASCAL_STRUCTOR_METHOD (heading);
  int is_extern = 0, was_forward, redeclaration = 0;
  int local = !pascal_global_bindings_p ();
  int old_immediate_size_expand = immediate_size_expand;

  associate_external_objects (current_module->parms);
  was_forward = resolve_forward_decl (name);
  old = lookup_name_current_level (name);

  if (method)
    {
      if (!pascal_global_bindings_p ())
        error ("method definition only allowed at top level");
      else if (!old)
        error ("no such method in object");
      else if (PASCAL_ABSTRACT_METHOD (old))
        {
          error ("trying to implement an abstract method");
          old = NULL_TREE;  /* avoid further errors */
        }
    }

  if (old && (!was_forward || TREE_CODE (old) != FUNCTION_DECL || DECL_INITIAL (old)))
    {
      if (!PASCAL_DECL_WEAK (old))
        {
          error ("redeclaration of `%s'", IDENTIFIER_NAME (name));
          error_with_decl (old, " previous declaration");
          redeclaration = 1;
        }
      old = NULL_TREE;
    }

  if (old)
    {
      if (DECL_EXTERNAL (old))
        is_extern = 1;
      if (!check_routine_decl (args, type, resvar, EMPTY_PARENTHESES (arglist), method, structor, old, 0))
        {
          /* Say `routine' since there might be a mismatch in whether it's
             supposed to be a procedure, function or structor. */
          error ("routine definition does not match previous declaration");
          error_with_decl (old, " previous declaration");
        }

      if (type && type != void_type_node && !structor)
        chk_dialect ("result types in forward declared functions are", U_B_D_M_O_PASCAL);
      if (method ? TREE_CHAIN (args) : args)
        chk_dialect ("parameters in forward declared routines are", U_B_D_M_O_PASCAL);
      /* use the fields from the previous declaration */
      context = DECL_CONTEXT (old);
      args = DECL_LANG_PARMS (old);
      argtypes = TYPE_ARG_TYPES (TREE_TYPE (old));
      type = TREE_TYPE (TREE_TYPE (old));
      if (!resvar)
        resvar = DECL_LANG_RESULT_VARIABLE (old);
    }
  else if (!type)
    {
      /* Only allowed when function has already been declared with a directive. */
      error ("result type of function `%s' undefined", IDENTIFIER_NAME (name));
      type = error_mark_node;
    }

  if (EM (type))
    /* Allow continuing without crashing, and without thinking we're
       outside of a routine. */
    type = integer_type_node;

  if (TREE_CODE (type) != VOID_TYPE && !TREE_CONSTANT (TYPE_SIZE (type)))
    {
      error ("GPC doesn't support function results of variable size, aborting");
      exit (FATAL_EXIT_CODE);  /* backend bug, would later crash */
    }

  /* Don't expand any sizes in the return type of the function. */
  immediate_size_expand = 0;
  decl = gpc_build_decl (FUNCTION_DECL, name, build_function_type (type, argtypes));
  immediate_size_expand = old_immediate_size_expand;

  DECL_CONTEXT (decl) = current_function_decl;

  for (dir = directive; dir; dir = TREE_CHAIN (dir))
    if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_near)
        || IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_far))
      {
        if (co->warn_near_far)
          gpc_warning ("`%s' directive ignored because of flat memory model", IDENTIFIER_NAME (TREE_VALUE (dir)));
      }
    else
      {
        gcc_assert (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (dir), p_attribute));
        if (old)
          error ("attributes in forward declared routines are not allowed");
        else
          routine_attributes (&decl, TREE_PURPOSE (dir), &assembler_name);
      }

  TREE_PUBLIC (decl) = !current_function_decl;

  if (assembler_name)
    {
      is_extern = 1;
      TREE_ADDRESSABLE (decl) = 1;
      SET_DECL_ASSEMBLER_NAME (decl, check_assembler_name (assembler_name));
    }
  else
    {
      if (!method /*&& !current_module->main_program*/
          && !(old && DECL_EXTERNAL (old)))
        TREE_PUBLIC (decl) = 0;
      SET_DECL_ASSEMBLER_NAME (decl, mangle_name (DECL_NAME (decl)));
    }

  if (is_extern && local)
    error ("local routine `%s' declared with linker name", IDENTIFIER_NAME (name));

  /* Make the initial value non-null so pushdecl knows this is not tentative.
     error_mark_node is replaced below (in poplevel) with the BLOCK. */
  DECL_INITIAL (decl) = error_mark_node;

  /* Routines exist in static storage. (This does not mean `static' in the C sense!) */
  TREE_STATIC (decl) = 1;

  announce_function (decl);

  /* Record the decl so that the routine name is defined. If we already
     have a decl for this name, and it is a FUNCTION_DECL, use the old decl. */
  if (!redeclaration)  /* avoid duplicate erorrs */
    decl = pushdecl (decl);
  gcc_assert (!EM (decl));
  allocate_decl_lang_specific (decl);

  /* Mark methods and operators as such. */
  PASCAL_METHOD (decl) = method;
  PASCAL_STRUCTOR_METHOD (decl) = structor;
  if (operator_decl)
    SET_DECL_LANG_OPERATOR_DECL (decl, operator_decl);

  if (local)
    {
#ifdef GCC_3_4
      DECL_CONTEXT (decl) = current_function_decl;
      SET_DECL_ASSEMBLER_NAME (decl, NULL);
#endif
      push_function_context ();
    }

  current_function_decl = decl;

#ifndef EGCS97
  make_function_rtl (decl);
#else
#ifndef GCC_4_0
  make_decl_rtl (decl, NULL);
#endif
#endif
  immediate_size_expand = 0;
  DECL_RESULT (decl) = gpc_build_decl (RESULT_DECL, NULL_TREE,
    PROMOTING_INTEGER_TYPE (type) ? integer_type_node : type);
  immediate_size_expand = old_immediate_size_expand;

  if (context)
    DECL_CONTEXT (decl) = context;  /* for object methods */
  /* DECL_NO_STATIC_CHAIN (decl) |= old && DECL_NO_STATIC_CHAIN (old); */

#ifndef EGCS97
  if (!local)
    /* Allocate further tree nodes temporarily during compilation of this function only. */
    temporary_allocation ();
#endif

  pushlevel (0);

  for (parm = nreverse (args); parm; parm = next)
    {
      next = TREE_CHAIN (parm);
      gcc_assert (!DECL_RTL_SET_P (parm));
      pushdecl (parm);
    }
  DECL_ARGUMENTS (decl) = getdecls ();

  /* Initialize the RTL code for the function. */
#ifndef GCC_3_4
  init_function_start (decl, input_filename, lineno);
#else
  init_function_start (decl);
#endif

  /* Set up parameters and prepare for return. */
  expand_function_start (decl, 0);

  if (type != void_type_node && !resvar && lookup_name_current_level (name))
    {
      error_with_decl (decl, "shadowing function-identifier `%s' by a formal");
      error_with_decl (decl, " parameter makes it impossible to assign a function result");
    }

  pushlevel_expand (0);
  current_binding_level->routine = 1;

  /* Declare the result variable for a function; create one if not specified. */
  if (type == void_type_node)
    gcc_assert (!resvar);
  else
    {
      tree t = declare_variable (resvar ? resvar : co->implicit_result ? get_identifier ("Result") : get_unique_identifier ("result"), type, NULL_TREE, 0);
      if (!EM (t))
        {
          TREE_PRIVATE (t) = !resvar;
#if 0  /* un_initialize_block does this already */
          init_any (t, 0, 1);
#endif
          if (PASCAL_STRUCTOR_METHOD (decl))
            expand_expr_stmt (build_modify_expr (t, NOP_EXPR, boolean_true_node));
          DECL_LANG_RESULT_VARIABLE (decl) = t;
          TREE_NO_WARNING (t) = !resvar;
        }
    }

  if (PASCAL_METHOD (decl))
    {
      /* Implicitly do `with Self do' */
      tree self = lookup_name (self_id), t;
      if (self && TREE_CODE (TREE_TYPE (self)) == REFERENCE_TYPE)
        {
          tree stp = TYPE_POINTER_TO (TREE_TYPE (TREE_TYPE (self)));
          if (stp && PASCAL_TYPE_CLASS (stp))
            {
              tree d = gpc_build_decl (CONST_DECL, self_id, stp);
              DECL_INITIAL (d) = convert (stp, self);
              IDENTIFIER_VALUE (self_id) = d;
              pushdecl_nocheck (d);
              DECL_CONTEXT (d) = current_function_decl;
            }
        } 
      if (self)
        shadowed = pascal_shadow_record_fields (build_indirect_ref (self, "`Self' reference"), NULL_TREE);
      /* Mark the fields as declared in the current scope (fjf280b.pas) */
      for (t = shadowed; t; t = TREE_CHAIN (t))
        {
          tree dummy = gpc_build_decl (CONST_DECL, TREE_PURPOSE (t), void_type_node);
          tree v = IDENTIFIER_VALUE (TREE_PURPOSE (t));
          gcc_assert (TREE_CODE (v) == COMPONENT_REF);
          v = TREE_OPERAND (v, 1);
#ifndef GCC_4_2
          DECL_SOURCE_FILE (dummy) = DECL_SOURCE_FILE (v);
          DECL_SOURCE_LINE (dummy) = DECL_SOURCE_LINE (v);
#else
          DECL_SOURCE_LOCATION (dummy) = DECL_SOURCE_LOCATION (v);
#endif
          pushdecl_nocheck (dummy);
          DECL_CONTEXT (dummy) = current_function_decl;
        }
    }

  if (co->nonlocal_exit)
    {
      tree t = declare_label (get_unique_identifier ("nonlocal_exit"));
      TREE_USED (t) = 1;
      allocate_decl_lang_specific (decl);
      DECL_LANG_NONLOCAL_EXIT_LABEL (decl) = t;
    }

  return shadowed;
}

/* decl is usually NULL_TREE, but if not, it's used instead of building one
   (id is ignored then). */
tree
start_implicit_routine (tree decl, tree id, tree result, tree args)
{
  tree t;
  args = nreverse (args);
  if (!decl)
    {
      tree a = NULL_TREE;
      for (t = args; t; t = TREE_CHAIN (t))
        a = chainon (a, build_tree_list (NULL_TREE, TREE_TYPE (t)));
      decl = gpc_build_decl (FUNCTION_DECL, id, build_function_type (result,
        chainon (a, void_list_node)));
      DECL_ARTIFICIAL (decl) = 1;
      TREE_PUBLIC (decl) = 1;
      SET_DECL_ASSEMBLER_NAME (decl, id);
    }
  allocate_decl_lang_specific (decl);
  TREE_STATIC (decl) = 1;
#ifdef EGCS97
  DECL_UNINLINABLE (decl) = 1;  /* in statements.c: call_no_args(), we treat is as external, so don't let it be inlined */
#endif
  DECL_ARGUMENTS (decl) = args;
  DECL_RESULT (decl) = gpc_build_decl (RESULT_DECL, NULL_TREE, result);
  announce_function (decl);
  pushdecl_nocheck (decl);
  current_function_decl = decl;
  pushlevel (0);
#ifndef EGCS97
  make_function_rtl (decl);
  temporary_allocation ();
#else
#ifndef GCC_4_0
  make_decl_rtl (decl, NULL);
#endif
#endif
#ifndef GCC_3_4
  init_function_start (decl, input_filename, lineno);
#else
  init_function_start (decl);
#endif
#ifndef EGCS97
  /* To avoid crashing when compiling a unit with `-O3', see obstack_empty_p in tree.c:restore_tree_status() */
  preserve_initializer ();
#endif
  expand_function_start (decl, 0);
  pushlevel_expand (0);
  current_binding_level->routine = 1;
  return decl;
}

/* Perhaps a kludge (returns should go through a single instance of cleanups). (fjf962.pas) */
void
cleanup_routine (void)
{
  struct binding_level *b;
  for (b = current_binding_level; b->transparent; b = b->next)
    un_initialize_block (b->names, 1, 0);
}

/* Finish up the declaration of a routine and let the backend compile it.
   This is called after parsing the body of the function definition. */
void
finish_routine (tree shadowed)
{
  tree fndecl = current_function_decl;
  tree resvar = DECL_LANG_RESULT_VARIABLE (fndecl);
  if (DECL_LANG_SPECIFIC (fndecl) && DECL_LANG_NONLOCAL_EXIT_LABEL (fndecl))
    set_label (DECL_LANG_NONLOCAL_EXIT_LABEL (fndecl));
  if (resvar)
    {
      if (!PASCAL_VALUE_ASSIGNED (resvar))
        error ("result of function `%s' not assigned", IDENTIFIER_NAME (DECL_NAME (fndecl)));
      expand_return_statement (resvar);
    }
  else  /* otherwise done from expand_return_statement */
    cleanup_routine ();

  poplevel_expand (1, 0);

  /* Can happen after syntax errors. Prevent backend from crashing. */
  if (current_binding_level->transparent)
    abort_confused ();
  poplevel (1, 0, 1);

  BLOCK_SUPERCONTEXT (DECL_INITIAL (fndecl)) = fndecl;

  /* Must mark the RESULT_DECL as being in this function. */
  DECL_CONTEXT (DECL_RESULT (fndecl)) = fndecl;

#ifndef GCC_4_0
  /* Obey `register' declarations if `setjmp' is called in this fn. */
  if (current_function_calls_setjmp)
    {
      setjmp_protect (DECL_INITIAL (fndecl));
      setjmp_protect_args ();
    }
#endif

  /* Generate rtl for function exit. */
#ifndef GCC_3_4
  expand_function_end (input_filename, lineno, 0);
#else
  expand_function_end ();
#endif

#ifndef EGCS97
  /* So we can tell if jump_optimize sets it to 1. */
  can_reach_end = 0;
#endif

#ifndef GCC_4_0
#ifdef EGCS97
  ggc_push_context ();
#endif
  /* Run the optimizers and output the assembler code for this function. */
  rest_of_compilation (fndecl);

#ifdef EGCS97
  ggc_pop_context ();
#endif
#endif

  if (DECL_LANG_RESULT_VARIABLE (fndecl))
    DECL_LANG_RESULT_VARIABLE (fndecl) = DECL_NAME (DECL_LANG_RESULT_VARIABLE (fndecl));

#ifndef EGCS97
  if (TREE_THIS_VOLATILE (fndecl) && can_reach_end)
    gpc_warning ("routine declared `noreturn' returns");
  if (!outer_function_chain)
    permanent_allocation (1);
#endif

#ifndef GCC_4_0
#ifndef GCC_4_0
  if (!DECL_SAVED_INSNS (fndecl))
#else
  if (!DECL_STRUCT_FUNCTION (fndecl))
#endif
    {
      /* Stop pointing to the local nodes about to be freed. But DECL_INITIAL
         must remain nonzero (unless rest_of_compilation set this to 0),
         so we know this was an actual function definition. */
      if (DECL_INITIAL (fndecl))
        DECL_INITIAL (fndecl) = error_mark_node;
      DECL_ARGUMENTS (fndecl) = NULL_TREE;
    }
#endif
  if (!pascal_global_bindings_p ())
    pop_function_context ();
  else
    current_function_decl = NULL;
  restore_identifiers (shadowed);
}

tree
build_enum_type (tree ids)
{
  int c = list_length (ids) - 1;
  tree r = make_node (ENUMERAL_TYPE), id;
  TYPE_STUB_DECL (r) = gpc_build_decl (TYPE_DECL, NULL_TREE, r);
  TYPE_UNSIGNED (r) = 1;
  TYPE_MIN_VALUE (r) = integer_zero_node;
  TYPE_MAX_VALUE (r) = build_int_2 (c, 0);
  TYPE_PACKED (r) = !!flag_short_enums;
  if (TYPE_PACKED (r))
    TYPE_PRECISION (r) = TYPE_PRECISION (type_for_size (c == 0 ? 1 : floor_log2 (c) + 1, 1));
  else
    TYPE_PRECISION (r) = TYPE_PRECISION (pascal_integer_type_node);
  layout_type (r);
  for (id = ids, c = 0; id; id = TREE_CHAIN (id), c++)
    {
      tree decl = gpc_build_decl (CONST_DECL, TREE_PURPOSE (id), r);
      tree v = convert (r, build_int_2 (c, 0));
      PASCAL_CST_FRESH (v) = 1;
      DECL_INITIAL (decl) = TREE_VALUE (id) = v;
      PASCAL_CST_PRINCIPAL_ID (decl) = 1;
      pushdecl (decl);
      handle_autoexport (TREE_PURPOSE (id));
      if (!TREE_CHAIN (id))
        TYPE_MAX_VALUE (r) = v;
    }
  TYPE_MIN_VALUE (r) = TREE_VALUE (ids);
  TYPE_VALUES (r) = ids;
  /* TREE_TYPE (r) = pascal_integer_type_node; */
  if (!current_type_list)
    rest_of_type_compilation (r, current_binding_level == global_binding_level);
  return r;
}

tree
build_type_decl (tree name, tree type, tree init)
{
  tree decl;
  CHK_EM (type);
  if (init)
    {
      type = add_type_initializer (type, init);
      (void) build_pascal_initializer (type, TYPE_GET_INITIALIZER (type), IDENTIFIER_NAME (name), 0);
    }
  if (!init && TYPE_NAME (type))  /* add_type_initializer makes a copy already */
    {
      type = build_type_copy (type);
      copy_type_lang_specific (type);
    }
  decl = gpc_build_decl (TYPE_DECL, name, type);
  TYPE_NAME (type) = decl;
  current_type_list = tree_cons (decl, name, current_type_list);
  return decl;
}

void
patch_type (tree type, tree otype)
{
  tree fwdtype = TYPE_MAIN_VARIANT (otype);
  for (; fwdtype; fwdtype = TYPE_NEXT_VARIANT (fwdtype))
    {
      tree t, new_variant = p_build_type_variant (type, TYPE_READONLY (fwdtype),
		                                  TYPE_VOLATILE (fwdtype));
      if (new_variant == type && fwdtype != otype)
        new_variant = build_type_copy (new_variant);
      if (TYPE_POINTER_TO (fwdtype))
      for (t = TYPE_MAIN_VARIANT (TYPE_POINTER_TO (fwdtype)); t; t = TYPE_NEXT_VARIANT (t))
        TREE_TYPE (t) = new_variant;
      if (TYPE_REFERENCE_TO (fwdtype))
        for (t = TYPE_MAIN_VARIANT (TYPE_REFERENCE_TO (fwdtype)); t; t = TYPE_NEXT_VARIANT (t))
          TREE_TYPE (t) = new_variant;
      TYPE_POINTER_TO (new_variant) = TYPE_POINTER_TO (fwdtype);
      TYPE_REFERENCE_TO (new_variant) = TYPE_REFERENCE_TO (fwdtype);
    }
}

/* Actually declare the types at the end of a type definition part.
   Resolve any forward types using existing types. */
void
declare_types (void)
{
  tree scan;

  /* Resolve forward types */
  for (scan = current_type_list; scan; scan = TREE_CHAIN (scan))
    if (TREE_PURPOSE (scan) && (TREE_CODE (TREE_TYPE (TREE_PURPOSE (scan))) == LANG_TYPE
          || (TREE_CODE (TREE_TYPE (TREE_PURPOSE (scan))) == POINTER_TYPE
	      && PASCAL_TYPE_CLASS (TREE_TYPE (TREE_PURPOSE (scan)))
	      && TREE_CODE (TREE_TYPE (TREE_TYPE (TREE_PURPOSE (scan))))
                 == LANG_TYPE)))
      {
        tree otype = TREE_TYPE (TREE_PURPOSE (scan));
        tree decl = lookup_name (TREE_VALUE (scan)), type;
        int is_class = TREE_CODE (otype) == POINTER_TYPE;
        if (decl && TREE_CODE (decl) == TYPE_DECL)
          {
            type = TREE_TYPE (decl);
	    if (is_class)
              {
                if (TREE_CODE (type) == POINTER_TYPE
                    && PASCAL_TYPE_CLASS (type))
		  {
	            type = TREE_TYPE (type);
                    if (TREE_CODE (type) != LANG_TYPE)
		      error ("duplicate forward class declaration for `%s'",
		               IDENTIFIER_NAME (TREE_VALUE (scan)));
                    else
                      {
                        error ("unresolved forward class `%s'",
                                IDENTIFIER_NAME (TREE_VALUE (scan)));
                        type = void_type_node;
                      }
		  }
	        else
		  {
		    error ("forward class %s' redefined as non-class",
	                    IDENTIFIER_NAME (TREE_VALUE (scan)));
		    type = void_type_node;
		  }
              }
	  }
        else if (is_class)
	  {
            gcc_unreachable ();
	    error ("unresolved forward class `%s'",
	           IDENTIFIER_NAME (TREE_VALUE (scan)));
	    type = void_type_node;
	  }
	else
          {
            error ("forward referenced type `%s' undefined", IDENTIFIER_NAME (TREE_VALUE (scan)));
            type = void_type_node;  /* dwarf2out.c doesn't like error_mark_node */
          }
        /* Patch all variants. */
	if (is_class)
	  otype = TREE_TYPE (otype);
	patch_type (type, otype);
      }

  /* Declare the types */
  for (scan = current_type_list; scan; scan = TREE_CHAIN (scan))
    if (TREE_PURPOSE (scan) && TREE_CODE (TREE_TYPE (TREE_PURPOSE (scan))) != LANG_TYPE)
      {
        tree type = TREE_TYPE (TREE_PURPOSE (scan));
        tree decl = pushdecl (TREE_PURPOSE (scan));
        gcc_assert (!EM (decl));
#ifndef GCC_4_0
        rest_of_decl_compilation (decl, NULL, !DECL_CONTEXT (decl), 0);
#endif
        handle_autoexport (TREE_VALUE (scan));
        if (TYPE_STUB_DECL (type))
          rest_of_type_compilation (type, current_binding_level == global_binding_level);
      }

  if (current_binding_level == global_binding_level)
    get_pending_sizes ();

  current_type_list = NULL_TREE;
}

/* Recursive subroutine of pascal_shadow_record_fields. Proceeds to the inner
   layers of Pascal variant records and to the contents of schemata. */
static tree
shadow_one_level (tree element, tree fields)
{
  tree field, shadowed = NULL_TREE;
  gcc_assert (TYPE_SIZE (TREE_TYPE (element)) && !PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (TREE_TYPE (element)));
  for (field = fields; field; field = TREE_CHAIN (field))
    /* omit forbidden fields */
    if (!check_private_protected (field) && !PASCAL_FIELD_SHADOWED (field))
      {
        tree name = DECL_NAME (field), ref, ftype = TREE_TYPE (field);
        CHK_EM (ftype);
        ref = simple_component_ref (element, field);
        /* Proceed through variant parts and schema contents. */
        if (!name || (name == schema_id && RECORD_OR_UNION (TREE_CODE (ftype))))
          shadowed = chainon (shadow_one_level (ref, TYPE_FIELDS (ftype)), shadowed);
        else
          {
            shadowed = tree_cons (name, IDENTIFIER_VALUE (name), shadowed);
            prediscriminate_schema (ref);
            IDENTIFIER_VALUE (name) = ref;
          }
      }
  return shadowed;
}

/* Call this function for each record in a `with' statement.

   It constructs a component_ref for each field in the record, and stores it to
   the identifier, so lookup_name will do the rest. The shadowed elements are
   returned.

   If the `with' element is not a VAR_DECL node, it creates a temporary variable
   and stores the address of the `with' element there. Then it creates an
   INDIRECT_REF node through this temporary variable to make sure that the
   `with' element expression is evaluated only once, as the standard requires. */
tree
pascal_shadow_record_fields (tree element, tree id)
{
  tree t = NULL_TREE;
  int lvalue = lvalue_p (element);
#ifndef EGCS97
  push_obstacks_nochange ();
  end_temporary_allocation ();
#endif
  element = undo_schema_dereference (element);
  if (!lvalue && !TREE_CONSTANT (element))
    error_or_warning (co->pascal_dialect & C_E_O_PASCAL, "`with' element is not a constant or an lvalue");
  if (!EM (TREE_TYPE (element)) && PASCAL_TYPE_RESTRICTED (TREE_TYPE (element)))
    {
      error ("restricted objects are not allowed in `with'");
      return NULL_TREE;
    }
  if (TREE_CODE (element) == CALL_EXPR && RECORD_OR_UNION (TREE_CODE (TREE_TYPE (element))))
    {
      tree temp_var = make_new_variable ("with_element", TREE_TYPE (element));
      expand_expr_stmt (build_modify_expr (temp_var, NOP_EXPR, element));
      element = temp_var;
    }
  if (TREE_CODE (TREE_TYPE (element)) == POINTER_TYPE
           &&PASCAL_TYPE_CLASS (TREE_TYPE (element)))
    element = build_indirect_ref (element, NULL);

  if (!EM (TREE_TYPE (element))
      && TREE_CODE (element) != VAR_DECL
      && TREE_CODE (element) != PARM_DECL
      && TREE_CODE (element) != CONSTRUCTOR)
    {
      tree elem_type = TREE_TYPE (element), rec_addr;
      if (TREE_READONLY (element))
        elem_type = p_build_type_variant (elem_type, 1, TYPE_VOLATILE (elem_type));
      rec_addr = make_new_variable ("with_element", build_pointer_type (elem_type));
      expand_expr_stmt (build_modify_expr (rec_addr, NOP_EXPR,
                          build_unary_op (ADDR_EXPR, element, 2)));
      element = build_indirect_ref (rec_addr, NULL);
      if (!lvalue)
        element = non_lvalue (element);
    }

  if (EM (TREE_TYPE (element)))
    ;
  else if (id)
    {
      chk_dialect ("tagging for `with' statements is", SUN_PASCAL);
      t = build_tree_list (id, IDENTIFIER_VALUE (id));
      IDENTIFIER_VALUE (id) = element;
    }
  else if (!RECORD_OR_UNION (TREE_CODE (TREE_TYPE (element))))
    error ("`with' element must be of record, schema, or object type");
  else
    t = chainon (shadow_one_level (element, TYPE_METHODS (TREE_TYPE (element))),
                 shadow_one_level (element, TYPE_FIELDS (TREE_TYPE (element))));

#ifndef EGCS97
  pop_obstacks ();
#endif
  return t;
}

void
restore_identifiers (tree list)
{
  for (; list; list = TREE_CHAIN (list))
    IDENTIFIER_VALUE (TREE_PURPOSE (list)) = TREE_VALUE (list);
}

tree
declare_constant (tree name, tree value)
{
  tree d;
  CHK_EM (value);

  /* @@ We currently represent some real operations with RTS calls.
        With constant operands we must do them at compile time instead. */
  if (!TREE_CONSTANT (value)
      && TREE_CODE (TREE_TYPE (value)) != REAL_TYPE
      && TREE_CODE (TREE_TYPE (value)) != COMPLEX_TYPE
      && TREE_CODE (value) != FIX_TRUNC_EXPR)
    error ("constant has non-constant value");
  if (!TREE_CONSTANT (value))  /* @@ Better: if contains SAVE_EXPR ... */
#ifndef GCC_4_0
    value = unsave_expr (value);
#else
    if (pascal_global_bindings_p () && !EM (TREE_TYPE (value)))
      value = save_nonconstants (value);
#endif

  value = set_exp_original_code (value, ERROR_MARK);
  d = gpc_build_decl (CONST_DECL, name, TREE_TYPE (value));
  DECL_INITIAL (d) = value;
  pushdecl (d);
  handle_autoexport (name);
#ifndef GCC_4_0
  rest_of_decl_compilation (d, NULL, pascal_global_bindings_p (), 0);
#endif
  return d;
}

tree
declare_variables (tree name_list, tree type, tree init, int qualifiers, tree attributes)
{
  tree assembler_name = NULL_TREE, *t, v, d, res = NULL_TREE, value = NULL_TREE;
  int local_static;
  if (EM (type))
    return NULL_TREE;
  if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA (type)
      || PASCAL_TYPE_UNDISCRIMINATED_STRING (type))
    {
      error ("missing schema discriminants");
      return NULL_TREE;
    }
  if (TREE_CODE (type) == VOID_TYPE)
    {
      error ("variable declared `Void'");
      return NULL_TREE;
    }
  if (PASCAL_TYPE_ANYFILE (type))
    error ("variables cannot be declared of type `AnyFile'");

  if (attributes && !(qualifiers & VQ_IMPLICIT))
    chk_dialect ("variable attributes are", GNU_PASCAL);
  for (t = &attributes; *t; )
    {
      int handled = 1;
      tree id = TREE_PURPOSE (*t);
      tree arg = TREE_VALUE (*t);
      if (arg && TREE_CODE (arg) == TREE_LIST)
        {
          if (list_length (TREE_VALUE (*t)) == 1)
            arg = TREE_VALUE (arg);
          else
            arg = NULL_TREE;
        }
      if (IDENTIFIER_IS_BUILT_IN (id, p_static))
        qualifiers |= VQ_STATIC;
      else if (IDENTIFIER_IS_BUILT_IN (id, p_volatile))
        qualifiers |= VQ_VOLATILE;
      else if (IDENTIFIER_IS_BUILT_IN (id, p_register))
        qualifiers |= VQ_REGISTER;
      else if (IDENTIFIER_IS_BUILT_IN (id, p_const))
        qualifiers |= VQ_CONST;
      else if (IDENTIFIER_IS_BUILT_IN (id, p_external))
        {
          qualifiers |= VQ_EXTERNAL;
          if (arg)
            gpc_warning ("library name in `external' is ignored");
        }
      else if (arg && IDENTIFIER_IS_BUILT_IN (id, p_name))
        assembler_name = arg;
      else if (arg && IDENTIFIER_IS_BUILT_IN (id, p_asmname))
        {
          gpc_warning ("`%s' is deprecated; use `external name' or `attribute (name = ...)' instead",
                   IDENTIFIER_NAME (id));
          assembler_name = arg;
        }
      else
        handled = 0;
      if (handled)
        *t = TREE_CHAIN (*t);
      else
        t = &TREE_CHAIN (*t);
    }

  if ((qualifiers & VQ_EXTERNAL) && !(qualifiers & VQ_IMPLICIT) && !assembler_name)
    {
      gpc_warning ("`external' without `name' has a different default now");
      gpc_warning (" (This gpc_warning will disappear in a future version.)");
    }

  if (init && PASCAL_ABSOLUTE_CLAUSE (init))
    {
      /* No initial value but an absolute clause. */
      chk_dialect ("`absolute' clauses are", B_D_PASCAL);
      if (qualifiers & VQ_EXTERNAL)
        error ("variable declared both `external' and `absolute'");
      if (assembler_name)
        error ("`absolute' variables cannot have a linker name");

      init = TREE_VALUE (init);
      STRIP_TYPE_NOPS (init);
      init = fold (init);
      if (TREE_CODE (init) == INTEGER_CST)
        {
          if (!TYPE_IS_INTEGER_TYPE (TREE_TYPE (init)))
            {
              error ("type mismatch in absolute address specification");
              return NULL_TREE;
            }
          if (co->warn_absolute)
            gpc_warning ("variables at absolute adresses may cause problems");
        }
      else
        {
          int indirect = 0;
          tree address = build_pascal_unary_op (ADDR_EXPR, init);
          if (EM (init))
            return NULL_TREE;
          if (warn_cast_align
              && TREE_CODE (TREE_TYPE (init)) != VOID_TYPE
              && TREE_CODE (TREE_TYPE (init)) != FUNCTION_TYPE
              && TYPE_ALIGN (type) > TYPE_ALIGN (TREE_TYPE (init)))
            gpc_warning ("`absolute' declaration increases required alignment");
          while (TREE_CODE (init) == NOP_EXPR
                 || TREE_CODE (init) == NON_LVALUE_EXPR
                 || TREE_CODE (init) == CONVERT_EXPR
                 || (TREE_CODE (init) == INDIRECT_REF && ++indirect))
            init = TREE_OPERAND (init, 0);
          if (!TREE_CONSTANT (address)
              && co->warn_absolute
              /* Local variables and parameters are okay. (Rather arbitrary,
                 especially for `var' parameters, but BP compatible.) */
              && !((indirect == 0 && TREE_CODE (init) == VAR_DECL)
                   || (indirect == 0 && TREE_CODE (init) == PARM_DECL)
                   || (indirect == 1 && TREE_CODE (init) == PARM_DECL
                       && TREE_CODE (TREE_TYPE (init)) == REFERENCE_TYPE)))
            gpc_warning ("`absolute' variable has non-constant address");
          TREE_USED (init) = 1;
          init = address;
        }
      init = build_indirect_ref (convert (build_pointer_type (type), init), NULL);
      if (EM (init))
        return NULL_TREE;
      for (v = name_list; v; v = TREE_CHAIN (v))
        {
          d = gpc_build_decl (CONST_DECL, TREE_VALUE (v), type);
          DECL_INITIAL (d) = init;
#if 0
          TREE_USED (d) |= !current_module->implementation;
#endif
          handle_autoexport (TREE_VALUE (v));
          pushdecl (d);
          res = tree_cons (NULL_TREE, d, res);
        }
      return res;
    }

  if (qualifiers & VQ_BP_CONST)
    chk_dialect ("typed constants are", B_D_M_PASCAL);

  if (qualifiers & VQ_BP_CONST && !pascal_global_bindings_p ())
    qualifiers |= VQ_STATIC;

  if (assembler_name && TREE_CHAIN (name_list))
    error ("declaring multiple variables with one linker name");

  if (TYPE_VOLATILE (type))
    {
      if (qualifiers & VQ_VOLATILE)
        gpc_pedwarn ("duplicate `volatile'");
      else
        qualifiers |= VQ_VOLATILE;
    }

  local_static = !pascal_global_bindings_p () && (qualifiers & VQ_STATIC)
                 && !(qualifiers & VQ_EXTERNAL);  /* cf. deferred_initializers */

  /* If variable initialization is not given, try the type initializer
     (which was already checked). */
  if (!init)
    init = TYPE_GET_INITIALIZER (type);
  else
    {
      if (TREE_CODE (type) == RECORD_TYPE && PASCAL_TYPE_INITIALIZER_VARIANTS (type))
        {
          type = build_type_copy (type);
          PASCAL_TYPE_INITIALIZER_VARIANTS (type) = 0;
        }
      if (!(qualifiers & VQ_IMPLICIT) && check_pascal_initializer (type, init) != 0)
        {
          error ("initial value is of wrong type");
          init = NULL_TREE;
        }
      else if (!local_static)
        init = save_nonconstants (init);
    }
  if (init && (qualifiers & VQ_EXTERNAL))
    {
      error ("`external' variables may not be initialized");
      init = NULL_TREE;
    }

  if (TREE_CODE (TYPE_SIZE (type)) != INTEGER_CST)
    {
      if (init)
        {
          error ("variables of non-constant size may not be initialized");
          init = NULL_TREE;
        }
      if (pascal_global_bindings_p ())
        {
          gcc_assert (!init);
          type = build_reference_type (type);
        }
      else if (local_static)
        {
          error ("local static variables of non-constant size are not supported");
          return NULL_TREE;
        }
    }

  for (v = name_list; v; v = TREE_CHAIN (v))
    {
      tree assembler_name0 = NULL_TREE;
#ifndef EGCS97
      if (local_static)
        {
          push_obstacks_nochange ();
          end_temporary_allocation ();
        }
#endif
      d = gpc_build_decl (VAR_DECL, TREE_VALUE (v), type);
      TREE_USED (d) = TREE_USED (type);
      DECL_CONTEXT (d) = current_function_decl;
      DECL_ARTIFICIAL (d) = !!(qualifiers & VQ_IMPLICIT);
      TREE_READONLY (d) = TYPE_READONLY (type) || (qualifiers & VQ_CONST);
      TREE_SIDE_EFFECTS (d) = TREE_THIS_VOLATILE (d) = !!(qualifiers & VQ_VOLATILE);
      DECL_EXTERNAL (d) = !!(qualifiers & VQ_EXTERNAL);
      DECL_REGISTER (d) = !!(qualifiers & VQ_REGISTER);
      PASCAL_DECL_TYPED_CONST (d) = !!(qualifiers & VQ_BP_CONST);
      TREE_STATIC (d) = !!(qualifiers & VQ_STATIC);
      if (TREE_STATIC (d) + DECL_EXTERNAL (d) + DECL_REGISTER (d) > 1)
        error ("multiple storage classes in variable declaration");
      if (pascal_global_bindings_p ())
        {
          TREE_PUBLIC (d) = !TREE_STATIC (d) && !DECL_REGISTER (d)
             && (DECL_EXTERNAL (d) || !current_module->implementation
                 || assembler_name);
          if (TREE_PUBLIC (d) && !assembler_name && !DECL_EXTERNAL (d))
            assembler_name0 = mangle_name (TREE_VALUE (v));
          TREE_STATIC (d) = !DECL_EXTERNAL (d);
        }
      else
        TREE_PUBLIC (d) = DECL_EXTERNAL (d);
      DECL_COMMON (d) = !TREE_PUBLIC (d);
      if (assembler_name0)
        SET_DECL_ASSEMBLER_NAME (d, assembler_name0);
      else
        {
          tree new_name = assembler_name;
          if (new_name)
            new_name = check_assembler_name (new_name);
          else if (qualifiers & VQ_EXTERNAL)
            new_name = de_capitalize (TREE_VALUE (v));
          else if (local_static)
            new_name = get_unique_identifier (ACONCAT (("static_",
                         IDENTIFIER_POINTER (TREE_VALUE (v)), NULL)));
          else
#ifdef GCC_3_4
          if (pascal_global_bindings_p ())
#endif
            new_name = TREE_VALUE (v);
          SET_DECL_ASSEMBLER_NAME (d, new_name);
        }
      pascal_decl_attributes (&d, attributes);
      if (DECL_EXTERNAL (d) || TREE_STATIC (d))
        {
          if (TREE_CODE (DECL_SIZE (d)) == INTEGER_CST)
            constant_expression_warning (DECL_SIZE (d));
          else
            error_with_decl (d, "storage size of `%s' isn't constant");
        }

#ifndef EGCS97  /* gcc-3 backend does this already */
      /* If requested, warn about definitions of large data objects. */
      if (warn_larger_than && !DECL_EXTERNAL (d)
          && DECL_SIZE (d) && TREE_CODE (DECL_SIZE (d)) == INTEGER_CST
          && (TREE_INT_CST_HIGH (DECL_SIZE (d))
              || TREE_INT_CST_LOW (DECL_SIZE (d)) / BITS_PER_UNIT > (unsigned long int) larger_than_size))
        warning_with_decl (d, "size of `%s' larger than %lu bytes", (unsigned long int) larger_than_size);
#endif

      if (init && !value)
        {
          value = build_pascal_initializer (TREE_TYPE (d), init, IDENTIFIER_NAME (DECL_NAME (d)), 0);
          if (local_static)
            {
               tree raw_value = value;
               STRIP_NOPS (raw_value);
               /* The second case is needed for nicola4c.pas with gcc-4.x */
               if (!TREE_CONSTANT (value) || 
                   (TREE_CODE (raw_value) == ADDR_EXPR && 
                    TREE_CODE (TREE_OPERAND (raw_value, 0)) == FUNCTION_DECL &&
                    DECL_CONTEXT (TREE_OPERAND (raw_value, 0))))
                 error ("local static variables cannot have non-constant initializers");
            }
          if (!TREE_CONSTANT (value) && TREE_CHAIN (v))
            value = save_expr (value);
        }
      if (value)
        {
          if (!TREE_CONSTANT (value) && (pascal_global_bindings_p () || TREE_STATIC (d)))
            deferred_initializers = tree_cons (value, d, deferred_initializers);
          else
            DECL_INITIAL (d) = value;
          PASCAL_INITIALIZED (d) = 1;
          STRIP_TYPE_NOPS (value);
          constant_expression_warning (value);  /* @@ -> digest_init? */
          if (TREE_CONSTANT (value))
            value = NULL_TREE;
        }

      /* For a local variable, define the RTL now. */
      if (!pascal_global_bindings_p ())
        {
          /* Similar check as in expand_decl */
          if (!current_binding_level->routine  /* not necessary for regular local variables */
              && (TREE_CODE (TYPE_SIZE (type)) != INTEGER_CST
                  || (flag_stack_check && !STACK_CHECK_BUILTIN
#ifdef EGCS97
                      && compare_tree_int (TYPE_SIZE_UNIT (type), STACK_CHECK_MAX_VAR_SIZE) > 0)))
#else
                      && (TREE_INT_CST_HIGH (TYPE_SIZE (type))
                          || (TREE_INT_CST_LOW (TYPE_SIZE (type)) > STACK_CHECK_MAX_VAR_SIZE * BITS_PER_UNIT)))))
#endif
            pushlevel_expand (1);
          expand_decl (d);
        }

      if (!DECL_ARTIFICIAL (d))
        d = pushdecl (d);
#if 1 
      /* def GCC_4_0 */
      else
        pushdecl_nocheck (d);
#endif
      gcc_assert (!EM (d));

      if (local_static)
        DECL_CONTEXT (d) = NULL_TREE;  /* for deferred initializers */

      /* Output the assembler code and/or RTL code. */
#ifdef GCC_4_0
      if (pascal_global_bindings_p () && current_module
          && current_module->implementation)
        {
          if (!DECL_INITIAL (d))
            DECL_DEFER_OUTPUT (d) = 1;
          rest_of_decl_compilation (d, true, 0);
        }
#else
      rest_of_decl_compilation (d, NULL, !DECL_CONTEXT (d), 1 /* for GPC */);
#endif

#ifndef GCC_4_0
      /* Compute and store the initial value. */
      if (DECL_CONTEXT (d))
        expand_decl_init (d);
#endif

      /* d might be a pointer to an undiscriminated schema. At this point,
         we can pre-discriminate it using its own contents. */
      prediscriminate_schema (d);

      if (!(qualifiers & VQ_IMPLICIT))
        handle_autoexport (TREE_VALUE (v));

#ifndef EGCS97
      if (local_static)
        pop_obstacks ();
#endif

      res = tree_cons (NULL_TREE, d, res);
    }
  /* At the end of a declaration, throw away any variable type sizes
     of types defined inside that declaration. There is no use
     computing them in the following function definition. */
  if (current_binding_level == global_binding_level)
    get_pending_sizes ();
  return res;
}

tree
declare_variable (tree id, tree type, tree init, int qualifiers)
{
  tree t = declare_variables (build_tree_list (NULL_TREE, id), type, init, qualifiers, NULL_TREE);
  return t ? TREE_VALUE (t) : error_mark_node;
}

/* Create and return a new variable of type TYPE with a name constructed
   from template + unique number. */
tree
make_new_variable (const char *name_template, tree type)
{
  tree var = declare_variable (get_unique_identifier (name_template), TYPE_MAIN_VARIANT (type), NULL_TREE, VQ_IMPLICIT);
  CHK_EM (var);

  if (current_function_decl)
    init_any (var, 0, 1);
  else
    deferred_initializers = tree_cons (NULL_TREE, var, deferred_initializers);

  if (TREE_CODE (TREE_TYPE (var)) == REFERENCE_TYPE && !PASCAL_PROCEDURAL_TYPE (TREE_TYPE (var)))
    var = build_indirect_ref (var, NULL);

  /* In case the size of this variable can only be determined at run
     time, labels in this level will need fixups even if we thought they
     wouldn't need any. @@@@@@@ What to do?
     Is this contourbug? -- Frank
  if (!TREE_CONSTANT (TYPE_SIZE (TREE_TYPE (var))))
    ;
  */

  return var;
}

/* Create a new variable of string type MODEL.
   Copy the value of DATA to the new VAR_DECL if COPY is nonzero.
   If MODEL is NULL_TREE, the string capacity is the same as in
   the char or string type node in DATA. If DATA is a string schema,
   the capacity will be the current length of the string in DATA. */
tree
new_string_by_model (tree model, tree data, int copy)
{
  tree type, new_string;
  data = string_may_be_char (data, 0);  /* produces better code */
  if (!model || PASCAL_TYPE_UNDISCRIMINATED_STRING (model))
    {
      int isstring = is_string_compatible_type (data, 1);
      tree slen, olen;
      gcc_assert (isstring);
      olen = PASCAL_STRING_LENGTH (data);
#if 0
      /* @@@@@ this caused problem with cstrassign.pas */       
      if (copy)
        {
          slen = make_new_variable ("string_len", TREE_TYPE (olen));
          expand_expr_stmt1 (build_modify_expr (slen, NOP_EXPR, olen));
        }
      else
#endif
        slen = save_expr (olen);
      type = build_pascal_string_schema (
                  build_pascal_binary_op (MAX_EXPR, integer_one_node, slen));
    }
  else
    type = TYPE_MAIN_VARIANT (model);
  new_string = make_new_variable ("tmp_string", type);
  if (copy)
    expand_expr_stmt1 (assign_string (new_string, data));
  return new_string;
}

#ifdef GCC_3_3
struct GTY(()) language_function
{
  int unused;
};

#include "gt-p-declarations.h"
#endif
