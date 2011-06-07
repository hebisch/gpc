/*Object oriented programming support routines for GNU Pascal

  Copyright (C) 1987-2006 Free Software Foundation, Inc.

  Authors: Peter Gerwinski <peter@gerwinski.de>
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

static tree current_method (void);

/* Get a FIELD_DECL node of structured type type. This is only applied to
   structures with no variant part and no schemata, so it is much simpler
   than find_field(). We don't use the sorted fields here, because they
   should be either unimportant (schema_id) or not applicable (methods)
   anyway when this is called. */
tree
simple_get_field (tree name, tree type, const char *descr)
{
  tree field = TYPE_FIELDS (type);
  while (field && (DECL_NAME (field) != name
         || PASCAL_FIELD_SHADOWED (field)))
    field = TREE_CHAIN (field);
  if (field)
    return field;
  field = TYPE_METHODS (type);
  while (field && (DECL_NAME (field) != name 
         || PASCAL_METHOD_SHADOWED (field)))
    field = TREE_CHAIN (field);
  if (!descr)
    gcc_assert (field);
  if (!field && *descr)
    error ("%s `%s' not found", descr, IDENTIFIER_NAME (name));
  return field;
}

tree
get_vmt_field (tree obj)
{
  tree vmt_field;
  CHK_EM (obj);
  if ((TREE_CODE (TREE_TYPE (obj)) == FUNCTION_TYPE && RECORD_OR_UNION (TREE_CODE (TREE_TYPE (TREE_TYPE (obj)))))
      || CALL_METHOD (obj))
    obj = undo_schema_dereference (probably_call_function (obj));
  gcc_assert (TREE_CODE (obj) != COND_EXPR);
  if (TREE_CODE (obj) == COMPOUND_EXPR)
    {
      tree value = get_vmt_field (TREE_OPERAND (obj, 1));
      return build (COMPOUND_EXPR, TREE_TYPE (value), TREE_OPERAND (obj, 0), value);
    }
  vmt_field = TYPE_LANG_VMT_FIELD (TREE_TYPE (obj));
#ifndef GCC_4_0
  return build (COMPONENT_REF, TREE_TYPE (vmt_field), obj, vmt_field);
#else
  return build3 (COMPONENT_REF, TREE_TYPE (vmt_field), obj, vmt_field,
                   NULL_TREE);
#endif
}

static tree
current_method (void)
{
  struct function *p;
  tree decl;
#ifdef EGCS97
  for (p = outer_function_chain; p && p->outer; p = p->outer) ;
#else
  for (p = outer_function_chain; p && p->next; p = p->next) ;
#endif
  decl = p ? p->decl : current_function_decl;
  /* DECL_CONTEXT can be NULL after a previous error */
  return decl && PASCAL_METHOD (decl) && DECL_CONTEXT (decl) ? decl : NULL_TREE;
}

/* To implement `private' with unit/module scope: finish_object_type sets
   TREE_PRIVATE which by itself doesn't prevent access. When importing a field
   with TREE_PRIVATE set, also TREE_PROTECTED is set. So here we check the
   combination of both. TREE_PROTECTED alone means `protected'. */
const char *
check_private_protected (tree field)
{
  if (TREE_PROTECTED (field) && TREE_PRIVATE (field))
    return "private";
  if (TREE_PROTECTED (field))
    {
      tree t = current_method ();
      if (t)
        for (t = DECL_CONTEXT (t); t && t != DECL_CONTEXT (field);
             t = TYPE_LANG_BASE (t))
          if (TREE_CODE (t) == POINTER_TYPE)
            t = TREE_TYPE (t);
      if (!t)
        return "protected";
    }
  return NULL;
}

/* Build a method call out of a COMPONENT_REF. */
tree
call_method (tree cref, tree args)
{
  int is_virtual, is_destructor;
  tree obj = TREE_OPERAND (cref, 0);
  tree type = TREE_TYPE (obj);
  tree fun = TREE_OPERAND (cref, 1);
  tree constructor_call = NULL_TREE;
  tree cmeth = NULL_TREE;

  if (TREE_CODE (obj) == TYPE_DECL && PASCAL_TYPE_CLASS (type))
    type = TREE_TYPE (type);

  if (!PASCAL_TYPE_OBJECT (type))
    {
      error ("calling method of something not an object");
      return error_mark_node;
    }

  if (TREE_CODE (fun) != FUNCTION_DECL || TREE_CODE (TREE_TYPE (fun)) != FUNCTION_TYPE)
    {
      error ("invalid method call");
      return error_mark_node;
    }
  gcc_assert (PASCAL_METHOD (fun));

  /* @@ Is this the right place to do it? (fjf639x5.pas, fjf644.pas)
        It would seem logical to build a save_expr of the whole object,
        but it doesn't work (works only on scalar types I guess),
        so do it only for INDIRECT_REFs. -- Frank */
  if (TREE_CODE (obj) == INDIRECT_REF)
    obj = build1 (INDIRECT_REF, type, save_expr (TREE_OPERAND (obj, 0)));

  is_virtual = PASCAL_VIRTUAL_METHOD (fun);
  if (TREE_CODE (obj) == TYPE_DECL)
    {
      int is_class = PASCAL_TYPE_CLASS (TREE_TYPE (obj));
      cmeth = current_method ();
      if (PASCAL_CONSTRUCTOR_METHOD (fun) && is_class)
        constructor_call = tree_cons (NULL_TREE, 
                               obj, tree_cons (NULL_TREE, cref, args));

      if (is_class && PASCAL_DESTRUCTOR_METHOD (fun) &&
          (!cmeth || !PASCAL_DESTRUCTOR_METHOD (cmeth)))
        {
          error("Delphi/OOE continuing destructor activation outside a destructor");
          return error_mark_node;
        }

      /* @@@ We should delay expanding constructor for better error detection
         but expander does not work with 2.x */
      if (!cmeth /* && !constructor_call */)
        /* Somebody is looking for the address of this method. Give them the FUNCTION_DECL. */
        {
          if (constructor_call)
            return build_predef_call (p_New, constructor_call);
          return fun;
        }

#ifndef EGCS97
      if (constructor_call)
        {
           error("Constructor call inside a method not supported"
                 " with 2.x backends");
           return error_mark_node;
        }
#endif

      /* This is an explicit call to an ancestor's method. */
      fun = simple_get_field (DECL_NAME (fun), type, "method");
      if (!fun)
        return error_mark_node;
      obj = build_indirect_ref (lookup_name (self_id), "`Self' reference");
      is_virtual = 0;
      is_destructor = 0;
    }
  else
    /* @@@@@ Check if obj == Self ?? OOE says that in such case the
       object remains valid */
    is_destructor = PASCAL_DESTRUCTOR_METHOD (fun) 
                  && TYPE_POINTER_TO (TREE_TYPE (obj)) 
                  && PASCAL_TYPE_CLASS (TYPE_POINTER_TO (TREE_TYPE (obj)));

  if (is_virtual)
    {
      tree method = NULL_TREE, type_save, vmt = get_vmt_field (obj);
      tree vmt_deref = build_indirect_ref (vmt, NULL);
      char *n = ACONCAT (("method_", IDENTIFIER_POINTER (DECL_NAME (fun)), NULL));
      method = simple_get_field (get_identifier (n), TREE_TYPE (TREE_TYPE (TYPE_LANG_VMT_FIELD (TREE_TYPE (obj)))), NULL);
      type_save = TREE_TYPE (fun);
#ifndef GCC_4_0
      fun = build (COMPONENT_REF, TREE_TYPE (method), vmt_deref, method);
#else
      fun = build3 (COMPONENT_REF, TREE_TYPE (method), vmt_deref, 
                      method, NULL_TREE);
#endif
      /* In the VMT, only generic pointers are stored to avoid
         confusion in GPI files. Repair them here. */
      TREE_TYPE (fun) = build_pointer_type (type_save);
      if (co->object_checking)
        fun = fold (build (COND_EXPR, TREE_TYPE (fun),
          build_pascal_binary_op (TRUTH_ORIF_EXPR,
            build_pascal_binary_op (EQ_EXPR, vmt, null_pointer_node),
            build_pascal_binary_op (NE_EXPR, build_component_ref (vmt_deref, get_identifier ("Size")),
              build_pascal_unary_op (NEGATE_EXPR, build_component_ref (vmt_deref, get_identifier ("Negatedsize"))))),
          convert (TREE_TYPE (fun), build_predef_call (p_InvalidObjectError, NULL_TREE)), fun));
      fun = build_indirect_ref (fun, NULL);
    }
  else
    /* Not a virtual method. Use the function definition rather than the
       method field to allow for inline optimizations. */
    fun = DECL_LANG_METHOD_DECL (fun);

  /* Check if OBJ is an lvalue and do the call */
  if (lvalue_or_else (obj, "method call"))
    fun = build_routine_call (fun, tree_cons (NULL_TREE, obj, args));

  if (constructor_call)
    {
      if (!cmeth || !PASCAL_CONSTRUCTOR_METHOD (cmeth))
        fun = integer_zero_node;
      return build (PASCAL_CONSTRUCTOR_CALL, TYPE_POINTER_TO (type),
                   constructor_call, fun);
    }
      
  if (is_destructor)
    {
      tree vobj;
      gcc_assert (TREE_CODE (obj) == INDIRECT_REF);
      vobj = TREE_OPERAND (obj, 0);
      return build_predef_call (p_Dispose, tree_cons (NULL_TREE, vobj,
                 build_tree_list (NULL_TREE, fun)));
    }

  return fun;
}

tree
build_inherited_method (tree id)
{
  tree basetype, method = current_method ();
  if (!method)
    error ("`inherited' used outside of any method");
  else if (!(basetype = TYPE_LANG_BASE (DECL_CONTEXT (method))))
    error ("there is no parent type to inherit from");
  else
    return build_component_ref (TYPE_NAME (basetype), id);
  return error_mark_node;
}

#if 0
tree
build_class_of_type (tree base)
{
  error ("class types unimplemented");
  return error_mark_node;
}
#endif

/* Construct the internal name of a method. */
tree
get_method_name (tree object_name, tree method_name)
{
  tree t;
  const char *n = IDENTIFIER_POINTER (method_name);
  gcc_assert (object_name);
  t = get_identifier (ACONCAT ((IDENTIFIER_POINTER (object_name), "_",
                                (*n >= 'A' && *n <= 'Z') ? "" : "OBJ", n, NULL)));
  if (!IDENTIFIER_SPELLING (t) && IDENTIFIER_SPELLING (object_name) && IDENTIFIER_SPELLING (method_name))
    {
      char *s = ACONCAT ((IDENTIFIER_SPELLING (object_name), ".",
                          IDENTIFIER_SPELLING (method_name), NULL));
      set_identifier_spelling (t, s, NULL, 0, 0);
    }
  return t;
}

tree
start_object_type (tree name, int is_class)
{
  tree t = start_struct (RECORD_TYPE);
  tree res;
  if (co->objects_are_references)
    is_class = 1;
  if (is_class)
    {
      tree s, *pscan;
      pscan = &current_type_list;
      for (s = current_type_list; s && TREE_VALUE (s) != name;
           pscan = &TREE_CHAIN (s), s = TREE_CHAIN (s)) ;
      if (s && TREE_CODE (TREE_TYPE (TREE_PURPOSE (s))) == POINTER_TYPE
          && PASCAL_TYPE_CLASS (TREE_TYPE (TREE_PURPOSE (s)))
	  && TREE_CODE (TREE_TYPE (TREE_TYPE (TREE_PURPOSE (s)))) == LANG_TYPE)
        {
	  res = TREE_TYPE (TREE_PURPOSE (s));
	  patch_type (t, TREE_TYPE (res));
	  *pscan = TREE_CHAIN (s);
	}
      else
	{
          res = build_pointer_type (t);
          PASCAL_TYPE_CLASS (res) = 1;
	}
    }
  else
    res = t;
  if (!pascal_global_bindings_p ())
    error ("object type definition only allowed at top level");
  TYPE_MODE (t) = BLKmode;  /* may be used as a value parameter within its methods */
  TYPE_ALIGN (t) = BIGGEST_ALIGNMENT;
  allocate_type_lang_specific (t);
  TYPE_LANG_CODE (t) = PASCAL_LANG_OBJECT;
  build_type_decl (name, res, NULL_TREE);
  return res;
}

/* Finish an object type started with start_object_type. Note: Don't return
   prematurely in case of error to avoid leaving the type incomplete.
   Items is a mixed chain of:
   - FIELD_DECL
   - FUNCTION_DECL (result of build_routine_heading)
   - TREE_LIST
       VALUE:   IDENTIFIER_NODE (object directive)
       PURPOSE: void_type_node
      or
       VALUE:   IDENTIFIER_NODE (`virtual', `abstract', `attribute')
       PURPOSE: expression (for `virtual', optionally),
                or TREE_LIST (for `attribute')
                or NULL_TREE
     It would be nicer to have them attached to the method descriptions, but
     this seems to be hard to achieve in the parser. So we handle it here. */
tree
finish_object_type (tree type, tree parent, tree items, int abstract)
{
  tree fields, methods, field, parm, vmt_entry, vmt_type, size, vmt_field, t;
  tree *pfields, *pmethods, cp, init, f, ti;
  tree object_type_name = DECL_NAME (TYPE_NAME (type));
  const char *object_name = IDENTIFIER_NAME (object_type_name), *n;
  int protected_private = 0, has_virtual_method = 0, has_constructor = 0, i;
  tree parent_type = parent;
  int is_class = 0;

  if (TREE_CODE (type) == POINTER_TYPE)
    {
      gcc_assert (PASCAL_TYPE_CLASS (type));
      type = TREE_TYPE (type);
      is_class = 1;
    }

  if (parent && EM (parent))
    parent_type = parent = NULL_TREE;

  if (parent && TREE_CODE (parent) == POINTER_TYPE
      && PASCAL_TYPE_CLASS (parent))
    {
      parent = TREE_TYPE (parent);
      if (TREE_CODE (parent) == LANG_TYPE)
        {
          error ("forward class used as parent");
          parent_type = parent = NULL_TREE;
        }
      else
        {
          gcc_assert (PASCAL_TYPE_OBJECT (parent));
          /* Check for unfinished (erroneous) parent */
          if (!TYPE_FIELDS (parent))
            parent_type = parent = NULL_TREE;
        }
    }

  if (parent && !PASCAL_TYPE_OBJECT (parent))
    {
      tree parent_name = TYPE_NAME (parent);
      if (TREE_CODE (parent_name) == TYPE_DECL)
        parent_name = DECL_NAME (parent_name);
      error ("parent object type expected, `%s' given", IDENTIFIER_NAME (parent_name));
      parent = NULL_TREE;
    }

  if (parent && PASCAL_TYPE_RESTRICTED (parent))
    error ("trying to declare a subtype of a restricted object type");

  pfields = &fields;
  pmethods = &methods;
  for (cp = items; cp && !EM (cp); cp = TREE_CHAIN (cp))
    if (TREE_CODE (cp) == TREE_LIST)
      {
        gcc_assert (TREE_CODE (TREE_VALUE (cp)) == IDENTIFIER_NODE);
        if (TREE_PURPOSE (cp) != void_type_node)
          error ("spurious `%s'", IDENTIFIER_NAME (TREE_VALUE (cp)));
        else
          {
            tree t = TREE_VALUE (cp);
            chk_dialect ("object directives are", B_D_M_PASCAL);
            if (IDENTIFIER_IS_BUILT_IN (t, p_public) || IDENTIFIER_IS_BUILT_IN (t, p_published))
              protected_private = 0;
            else if (IDENTIFIER_IS_BUILT_IN (t, p_protected))
              protected_private = 1;
            else if (IDENTIFIER_IS_BUILT_IN (t, p_private))
              protected_private = 2;
            else
              error ("unknown object directive `%s'", IDENTIFIER_NAME (t));
          }
      }
    else if (TREE_CODE (cp) != FUNCTION_DECL)
      {
        if (!EM (TREE_TYPE (cp)))
          {
            *pfields = cp;
            pfields = &TREE_CHAIN (cp);
            TREE_PROTECTED (cp) = protected_private == 1;
            TREE_PRIVATE (cp) = protected_private == 2;
          }
      }
    else
      {
        tree heading = cp, assembler_name = NULL_TREE, method, method_field;
        tree t = TREE_TYPE (heading), name = DECL_NAME (heading);
        tree method_name = get_method_name (object_type_name, name);
        tree args, argtypes = build_formal_param_list (DECL_ARGUMENTS (heading), type, &args);
        int virtual = 0, nv = 0, na = 0, override = 0, reintroduce = 0;
        filename_t save_input_filename = input_filename;
        int save_lineno = lineno, save_column = column;
        if (!t)
          error ("result type of method function `%s' undefined", IDENTIFIER_NAME (name));
        if (!t || EM (t))
          continue;
        if (co->methods_always_virtual && !(PASCAL_STRUCTOR_METHOD (heading) && t == boolean_type_node))
          virtual = 1;
        method = build_decl (FUNCTION_DECL, method_name, build_function_type (t, argtypes));
        input_filename = DECL_SOURCE_FILE (method) = DECL_SOURCE_FILE (heading);
        lineno = DECL_SOURCE_LINE (method) = DECL_SOURCE_LINE (heading);
        /*@@ column = DECL_SOURCE_COLUMN (method) = DECL_SOURCE_COLUMN (heading); */
        while (TREE_CHAIN (cp) && TREE_CODE (TREE_CHAIN (cp)) == TREE_LIST
               && TREE_CODE (TREE_VALUE (TREE_CHAIN (cp))) == IDENTIFIER_NODE
               && TREE_PURPOSE (TREE_CHAIN (cp)) != void_type_node)
          {
            cp = TREE_CHAIN (cp);
            if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (cp), p_virtual))
              {
                if (co->methods_always_virtual)
                  gpc_warning ("explicit `virtual' given with `--methods-always-virtual'");
                virtual = 1;
                nv++;
                if (TREE_PURPOSE (cp))
                  {
                    tree t = TREE_PURPOSE (cp);
                    STRIP_TYPE_NOPS (t);
                    t = fold (t);
                    if (TREE_CODE (t) != INTEGER_CST || TREE_CODE (TREE_TYPE (t)) != INTEGER_TYPE)
                      error ("dynamic method index must be an integer constant");
                    else if (const_lt (t, integer_one_node)
                             || TREE_INT_CST_HIGH (t) != 0 || TREE_INT_CST_LOW (t) > 65535)
                      error ("dynamic method index must be in the range 1 .. 65535");  /* BP's range */
                    /* anyway, ignore the index */
                  }
              }
            else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (cp), p_abstract))
              {
                virtual = 2;
                na++;
              }
            else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (cp), p_attribute))
              routine_attributes (&method, TREE_PURPOSE (cp), &assembler_name);
            else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (cp), p_override))
              override++;
            else if (IDENTIFIER_IS_BUILT_IN (TREE_VALUE (cp), p_reintroduce))
              reintroduce++;
            else
              error ("unknown object method directive `%s'", IDENTIFIER_NAME (TREE_VALUE (cp)));
          }
        if (na > 1 || nv > 1)
          error ("duplicate `virtual' or `abstract'");
        if (override > 1)
          {
            error ("duplicate `override'");
            override = 1;
          }
        if (reintroduce > 1)
          {
            error ("duplicate `reintroduce'");
            reintroduce = 1;
          }

        PASCAL_METHOD_REINTRODUCE (method) = reintroduce;
        PASCAL_METHOD_OVERRIDE (method) = override;
        DECL_EXTERNAL (method) = 1;
        PASCAL_FORWARD_DECLARATION (method) = virtual != 2;
        PASCAL_METHOD (method) = 1;
        TREE_PROTECTED (method) = protected_private == 1;
        TREE_PRIVATE (method) = protected_private == 2;
        if (assembler_name)
          assembler_name = check_assembler_name (assembler_name);
        else
          assembler_name = pascal_mangle_names (object_name, IDENTIFIER_POINTER (name));
        SET_DECL_ASSEMBLER_NAME (method, assembler_name);
        allocate_decl_lang_specific (method);
        DECL_LANG_PARMS (method) = args;
        DECL_LANG_RESULT_VARIABLE (method) = DECL_RESULT (heading);
        PASCAL_STRUCTOR_METHOD (method) = PASCAL_STRUCTOR_METHOD (heading);
        TREE_PUBLIC (method) = virtual == 2 || current_module->main_program || !current_module->implementation;
        if (virtual || TREE_PUBLIC (method))
          mark_addressable (method);
        /* Push also abstract methods (for better error messages on attempts to implement them). */
        method = pushdecl (method);
        gcc_assert (!EM (method));
#ifndef GCC_4_0
        rest_of_decl_compilation (method, 0, 1, 1);
#endif
        if (PASCAL_FORWARD_DECLARATION (method))
          {
            set_forward_decl (method, 1);
            handle_autoexport (method_name);
          }
        DECL_CONTEXT (method) = type;
        DECL_NO_STATIC_CHAIN (method) = 1;  /* @@ ? */
        PASCAL_VIRTUAL_METHOD (method) = virtual != 0;
        PASCAL_ABSTRACT_METHOD (method) = virtual == 2;
        if (!is_class && virtual && PASCAL_CONSTRUCTOR_METHOD (method))
          error ("constructors must not be virtual or abstract");
        method_field = copy_node (method);
        PASCAL_FORWARD_DECLARATION (method_field) = 0;
        DECL_NAME (method_field) = name;
        /* Also affects method since DECL_LANG_SPECIFIC is not copied, but shouldn't hurt. */
        DECL_LANG_METHOD_DECL (method_field) = method;
        *pmethods = method_field;
        pmethods = &TREE_CHAIN (method_field);
        input_filename = save_input_filename;
        lineno = save_lineno;
        column = save_column;
      }
  *pmethods = NULL_TREE;
  *pfields = NULL_TREE;

  for (i = 0; i <= 1; i++)
    for (field = i ? methods : fields; field; field = TREE_CHAIN (field))
      {
        tree t;
#if 0
        for (t = parent; t && DECL_NAME (TYPE_NAME (t)) != DECL_NAME (field); t = TYPE_LANG_BASE (t)) ;
#else
        t = parent_type;
        while (t && DECL_NAME (TYPE_NAME (t)) != DECL_NAME (field))
          {
            if (TREE_CODE (t) == POINTER_TYPE)
              t = TREE_TYPE (t);
            t = TYPE_LANG_BASE (t);
          }
#endif
        if (t)
          {
            if (PEDANTIC (B_D_PASCAL))  /* forbidden by OOE */
              error ("%s `%s' conflicts with ancestor type name", i ? "method" : "field", IDENTIFIER_NAME (DECL_NAME (field)));
            else
              gpc_warning ("%s `%s' conflicts with ancestor type name", i ? "method" : "field", IDENTIFIER_NAME (DECL_NAME (field)));
          }
      }

  if (parent)
    {
      /* Inheritance */
      tree parent_methods, df, pf, *dm, *pm, t,
           parent_fields = copy_list (TYPE_FIELDS (parent));
      for (pf = parent_fields; pf; pf = TREE_CHAIN (pf))
        {
          if (PASCAL_FIELD_SHADOWED (pf))
            continue;
          for (df = fields; df && DECL_NAME (df) != DECL_NAME (pf); 
               df = TREE_CHAIN (df)) ;
          if (df)
            {
              if (co->delphi_method_shadowing)
                PASCAL_FIELD_SHADOWED (pf) = 1;
              else
                error ("cannot overwrite data field `%s' of parent object type", IDENTIFIER_NAME (DECL_NAME (df)));
              continue;
            }
          for (df = methods; df && DECL_NAME (df) != DECL_NAME (pf); df = TREE_CHAIN (df));
          if (df)
            {
              if (co->delphi_method_shadowing || PASCAL_METHOD_REINTRODUCE (df))
                PASCAL_FIELD_SHADOWED (pf) = 1;
              else
                error ("method `%s' conflicts with data field of parent object type", IDENTIFIER_NAME (DECL_NAME (df)));
            }
        }
      parent_methods = copy_list (TYPE_METHODS (parent));
      for (pm = &parent_methods; *pm; )
        {
          if (PASCAL_METHOD_SHADOWED (*pm))
            {
              pm = &TREE_CHAIN (*pm);
              continue;
            }
          for (df = fields; df && DECL_NAME (df) != DECL_NAME (*pm); df = TREE_CHAIN (df));
          if (df)
            error ("data field `%s' conflicts with method of parent object type", IDENTIFIER_NAME (DECL_NAME (df)));
          else
            {
              for (dm = &methods; *dm && DECL_NAME (*dm) != DECL_NAME (*pm); dm = &TREE_CHAIN (*dm));
              if (*dm)
                {
                  static const char *const descr[3] = { "public", "protected", "private" };
                  int p1 = PUBLIC_PRIVATE_PROTECTED (*pm), p2 = PUBLIC_PRIVATE_PROTECTED (*dm);
                  if (is_class && !PASCAL_METHOD_OVERRIDE (*dm))
                    {
                      if (co->delphi_method_shadowing 
                          || PASCAL_METHOD_REINTRODUCE (*dm))
                        {
                          PASCAL_METHOD_SHADOWED (*pm) = 1;
                          pm = &TREE_CHAIN (*pm);
                          continue;
                        }
                      else
                        error ("method `%s', overrides parent method",
                               IDENTIFIER_NAME (DECL_NAME (*dm)));
                    }
                  PASCAL_METHOD_OVERRIDE (*dm) = 0;
                  if (p1 < p2)
                    {
                      if (pedantic || !(co->pascal_dialect & B_D_PASCAL))
                        error ("%s method `%s', overrides %s method", descr[p2], IDENTIFIER_NAME (DECL_NAME (*dm)), descr[p1]);
                      else
                        gpc_warning ("%s method `%s', overrides %s method", descr[p2], IDENTIFIER_NAME (DECL_NAME (*dm)), descr[p1]);
                    }
                  if (PASCAL_VIRTUAL_METHOD (*pm))
                    {
                      if (!compare_routine_decls (*dm, *pm))
                        {
                          error_with_decl (*dm, "virtual method does not match inherited method");
                          error_with_decl (*pm, " inherited method");
                        }
                      if (PASCAL_TYPE_IOCRITICAL (TREE_TYPE (*dm))
                          && !PASCAL_TYPE_IOCRITICAL (TREE_TYPE (*pm)))
                        gpc_warning ("iocritical virtual method overrides non-iocritical one");
                    }
                  if (PASCAL_VIRTUAL_METHOD (*pm) && !PASCAL_VIRTUAL_METHOD (*dm))
                    {
                      /* Overridden virtual methods must be virtual. */
                      gpc_warning ("method `%s' is virtual", IDENTIFIER_NAME (DECL_NAME (*dm)));
                      PASCAL_VIRTUAL_METHOD (*dm) = 1;
                    }
                  /* If a virtual method overrides a non-virtual one, we must
                     not put the virtual one in the sequence of the parent
                     methods, so the VMT ordering is preserved (fjf702.pas). */
                  if (!PASCAL_VIRTUAL_METHOD (*pm) && PASCAL_VIRTUAL_METHOD (*dm))
                    {
                      if (PEDANTIC (B_D_PASCAL) || co->pascal_dialect == 0)
                        gpc_warning ("virtual method overrides non-virtual one");
                      *pm = TREE_CHAIN (*pm);
                      continue;
                    }
                  else
                    {
                      /* Replace the parent's method with the child's one */
                      t = TREE_CHAIN (*pm);
                      *pm = *dm;
                      *dm = TREE_CHAIN (*dm);
                      TREE_CHAIN (*pm) = t;
                    }
                }
            }
          pm = &TREE_CHAIN (*pm);
        }
      fields = chainon (parent_fields, fields);
      methods = chainon (parent_methods, methods);
      vmt_field = fields;  /* i.e., first field */
      gcc_assert (DECL_NAME (vmt_field) == vmt_id);
      gcc_assert (TREE_CODE (TREE_TYPE (vmt_field)) == POINTER_TYPE);
    }
  else
    {
      vmt_field = build_decl (FIELD_DECL, vmt_id, build_pointer_type (void_type_node));
      fields = chainon (vmt_field, fields);
    }

  TYPE_ALIGN (type) = 0;  /* to avoid blowing up the size unnecessarily */
  type = finish_struct (type, fields, 0);
  TYPE_MODE (type) = BLKmode;  /* be consistent with what was set in parse.y */
  TYPE_ALIGN (type) = BIGGEST_ALIGNMENT;
  TYPE_LANG_CODE (type) = abstract ? PASCAL_LANG_ABSTRACT_OBJECT : PASCAL_LANG_OBJECT;
  TYPE_LANG_VMT_FIELD (type) = vmt_field;
  TYPE_LANG_BASE (type) = parent_type;
  TYPE_METHODS (type) = methods;

  init = NULL_TREE;
  for (f = fields; f; f = TREE_CHAIN (f))
    if ((ti = TYPE_GET_INITIALIZER (TREE_TYPE (f))))
      {
        gcc_assert (TREE_CODE (ti) == TREE_LIST && !TREE_PURPOSE (ti));
        init = tree_cons (build_tree_list (DECL_NAME (f), NULL_TREE), TREE_VALUE (ti), init);
      }
  if (init)
    TYPE_LANG_INITIAL (type) = build_tree_list (NULL_TREE, init);

  /* Check whether the formal parameters and result variables of the methods
     conflict with fields of the object. Do not check inherited methods. */
  for (field = methods; field; field = TREE_CHAIN (field))
    if (DECL_CONTEXT (field) == type)
      {
        const char *name = IDENTIFIER_NAME (DECL_NAME (field));
        for (parm = DECL_LANG_PARMS (field); parm; parm = TREE_CHAIN (parm))
          if (find_field (type, DECL_NAME (parm), 2))
            error ("formal parameter `%s' of method `%s' conflicts with field or method",
                   IDENTIFIER_NAME (DECL_NAME (parm)), name);
        if (DECL_LANG_RESULT_VARIABLE (field) && find_field (type, DECL_LANG_RESULT_VARIABLE (field), 2))
          error ("result variable `%s' of method `%s' conflicts with field or method",
                 IDENTIFIER_NAME (DECL_LANG_RESULT_VARIABLE (field)), name);
      }
#if 0
  return type;
}

tree
finish_object_type (tree type, tree parent, tree items, int abstract)
{
  tree field, methods, size, vmt_entry, vmt_type, vmt_field, t;
  int has_virtual_method = 0, has_constructor = 0;
  tree object_type_name = DECL_NAME (TYPE_NAME (type));
  const char *object_name = IDENTIFIER_NAME (object_type_name), *n ;
  type = finish_object_type1 (type, parent, items, abstract);
  /* Create a record type for the VMT. The fields will contain pointers to all virtual methods. */
  methods = TYPE_METHODS (type);
  vmt_field = TYPE_LANG_VMT_FIELD (type);
#endif
  vmt_entry = copy_list (gpc_fields_PObjectType);
  for (field = methods; field; field = TREE_CHAIN (field))
    if (PASCAL_VIRTUAL_METHOD (field))
      {
        /* The real type of this pointer is not needed for type checking
           because it already is in the field of the object. Repeating it
           here would only cause confusion in GPI files if the method has
           a prediscriminated parameter. So use just ptr_type_node. */
        char *n = ACONCAT (("method_", IDENTIFIER_POINTER (DECL_NAME (field)), NULL));
        tree nf = build_field (get_identifier (n), ptr_type_node);
        PASCAL_FIELD_SHADOWED (nf) = PASCAL_METHOD_SHADOWED (field);
        vmt_entry = chainon (vmt_entry, nf);
      }
  vmt_type = finish_struct (start_struct (RECORD_TYPE), vmt_entry, 0);
  TYPE_READONLY (vmt_type) = 1;

  /* Build an initializer for the VMT record */
  size = size_in_bytes (type);
  field = build_pascal_unary_op (NEGATE_EXPR, size);
  vmt_entry = tree_cons (NULL_TREE, size, build_tree_list (NULL_TREE, field));
  if (!parent)
    field = null_pointer_node;
  else
    field = convert (gpc_type_PObjectType, build_unary_op (ADDR_EXPR, TYPE_LANG_VMT_VAR (parent), 0));
  vmt_entry = chainon (vmt_entry, build_tree_list (NULL_TREE, field));
  field = build_pascal_address_expression (build_string_constant (object_name, strlen (object_name), 0), 0);
  vmt_entry = chainon (vmt_entry, build_tree_list (NULL_TREE, field));

  /* Virtual methods */
  for (field = methods; field; field = TREE_CHAIN (field))
    {
      if (PASCAL_VIRTUAL_METHOD (field))
        {
          tree method;
          if (!PASCAL_ABSTRACT_METHOD (field))
            method = build_unary_op (ADDR_EXPR, field, 0);
          else
            {
              if (TYPE_LANG_CODE (type) != PASCAL_LANG_ABSTRACT_OBJECT)
                {
                  TYPE_LANG_CODE (type) = PASCAL_LANG_ABSTRACT_OBJECT;
                  if (co->warn_implicit_abstract)
                    {
                      gpc_warning ("object type `%s' is implicitly abstract because", object_name);
                      gpc_warning (" it contains abstract method `%s'", IDENTIFIER_NAME (DECL_NAME (field)));
                    }
                }
              method = convert (ptr_type_node, integer_zero_node);
            }
          vmt_entry = chainon (vmt_entry, build_tree_list (NULL_TREE, method));
          has_virtual_method = 1;
        }
      if (PASCAL_CONSTRUCTOR_METHOD (field))
        has_constructor = 1;
    }

  if (TYPE_LANG_CODE (type) == PASCAL_LANG_ABSTRACT_OBJECT)
    {
      /* Set `Size' to 0 and `NegatedSize' to -1 for abstract objects */
      TREE_VALUE (vmt_entry) = size_zero_node;
      TREE_VALUE (TREE_CHAIN (vmt_entry)) = size_int (-1);
      if (co->warn_inherited_abstract && parent && TYPE_LANG_CODE (parent) != PASCAL_LANG_ABSTRACT_OBJECT)
        gpc_warning ("abstract object type `%s' inherits from non-abstract type `%s'",
                 object_name, IDENTIFIER_NAME (DECL_NAME (TYPE_NAME (parent))));
    }
  else if (has_virtual_method && !has_constructor && !is_class
           /* && (co->pascal_dialect & B_D_PASCAL) */)
    gpc_warning ("object type has virtual method, but no constructor");

  /* Now create a global var declaration (also for abstract types,
     for `is', `as' and explicit parent type access via VMT).
     VQ_IMPLICIT suppresses `unused variable' warning and prevents it
     from being pushed as a regular declaration (which is unnecessary). */
  n = ACONCAT (("vmt_", IDENTIFIER_POINTER (object_type_name), NULL));
  TYPE_LANG_VMT_VAR (type) = declare_variable (get_identifier (n), vmt_type,
    build_tree_list (NULL_TREE, vmt_entry), VQ_IMPLICIT | VQ_CONST |
      (current_module->implementation ? VQ_STATIC : 0));

  /* Attach VMT_TYPE to the implicit VMT field of the object.
     (Until here it still has the inherited type or ^void type.)
     We also need this for abstract types because their methods
     may call virtual methods via the VMT. */
  TREE_TYPE (vmt_field) = build_pointer_type (vmt_type);

  for (t = TYPE_MAIN_VARIANT (type); t; t = TYPE_NEXT_VARIANT (t))
    {
      TYPE_MODE (t) = TYPE_MODE (type);
      TYPE_LANG_CODE (t) = TYPE_LANG_CODE (type);
      TYPE_LANG_VMT_FIELD (t) = TYPE_LANG_VMT_FIELD (type);
      TYPE_LANG_VMT_VAR (t) = TYPE_LANG_VMT_VAR (type);
      TYPE_LANG_BASE (t) = TYPE_LANG_BASE (type);
      TYPE_METHODS (t) = TYPE_METHODS (type);
    }

  return type;
}

void
mark_fields_shadowed (tree fields, tree mask);
void
mark_fields_shadowed (tree fields, tree mask)
{
  tree field;
  for (field = fields; field; field = TREE_CHAIN (field))
    {
      tree t, name;
      if (PASCAL_FIELD_SHADOWED (field))
        continue;
      name = DECL_NAME (field);
      for (t = mask; t && DECL_NAME (t) != name ; t = TREE_CHAIN (t)) ;
      if (t)
        continue;
      PASCAL_FIELD_SHADOWED (field) = 1;
    }
}

tree
finish_view_type (tree name, tree base, tree parent, tree items)
{
  tree res, type;
  tree base_fields, base_methods, cp, fields, methods;
  tree *pfields, *pmethods;
  CHK_EM (base);
  if (TREE_CODE (base) != POINTER_TYPE || !PASCAL_TYPE_CLASS (base)
      || TREE_CODE (base) == LANG_TYPE)
    {
      error ("Only can view a class");
      return error_mark_node;
    }
  else
    base = TREE_TYPE (base);
  /* Make new variant, so can modify */
  type = build_type_copy (base);
  res = build_pointer_type (type);
  PASCAL_TYPE_CLASS (res) = 1;
  base_fields = copy_list (TYPE_FIELDS (type));
  base_methods = copy_list (TYPE_METHODS (type));

  /* Check that parent is an ancestor of the base */
  if (parent)
    error ("Class views with parents unimplemented");

  pfields = &fields;
  pmethods = &methods;

  /* Separate items, check that all are visible and
     agree with old definition */
  for (cp = items; cp && !EM (cp); cp = TREE_CHAIN (cp))
    if (TREE_CODE (cp) == TREE_LIST)
      {
        gcc_assert (TREE_CODE (TREE_VALUE (cp)) == IDENTIFIER_NODE);
        error ("spurious `%s'", IDENTIFIER_NAME (TREE_VALUE (cp)));
      }
    else if (TREE_CODE (cp) != FUNCTION_DECL)
      {
        if (!EM (TREE_TYPE (cp)))
          {
            tree of = simple_get_field (DECL_NAME (cp), base, "base field");
            if (TREE_TYPE (of) != TREE_TYPE (cp))
              error ("Attempt to change field type");
            *pfields = cp;
            pfields = &TREE_CHAIN (cp);
          }
      }
   else
     {
       tree om = simple_get_field (DECL_NAME (cp), base, "base method");
       tree args;
       build_formal_param_list (DECL_ARGUMENTS (cp), type, &args);
       if (!check_routine_decl (args, TREE_TYPE (cp),
            DECL_RESULT (cp), 0, 1, PASCAL_STRUCTOR_METHOD (cp), om, 1))
         error ("Attempt to change method signature");
       *pmethods = cp;
       pmethods = &TREE_CHAIN (cp);
     }
  *pmethods = NULL_TREE;
  *pfields = NULL_TREE;

  /* Mark fields&methods as shadowed */
  gcc_assert (DECL_NAME (base_fields) == vmt_id);
  mark_fields_shadowed (TREE_CHAIN (base_fields), fields);
  mark_fields_shadowed (base_methods, methods);

  TYPE_FIELDS (type) = base_fields;
  TYPE_METHODS (type) = base_methods;
  TYPE_LANG_VMT_FIELD (type) = base_fields;
  build_type_decl (name, res, NULL_TREE);
  return type;
}

/* Build an `is' or `as' expression */
tree
build_is_as (tree left, tree right, int op)
{
  const char *opname = (op == p_is) ? "is" : "as";
  int want_class = 0;
  tree oleft = left;
  if (TREE_CODE (right) == POINTER_TYPE && PASCAL_TYPE_CLASS (right))
    {
      right = TREE_TYPE (right);
      want_class = 1;
    }
  if (TREE_CODE (TREE_TYPE (left)) == POINTER_TYPE
      && PASCAL_TYPE_CLASS (TREE_TYPE (left)))
    left = build_indirect_ref (left, NULL);
  if (!PASCAL_TYPE_OBJECT (right))
    error ("right operand of `%s' must be an object type", opname);
  else if (!PASCAL_TYPE_OBJECT (TREE_TYPE (left)))
    error ("left operand of `%s' must be an object", opname);
  else
    {
      tree t = right, tl = TYPE_MAIN_VARIANT (TREE_TYPE (left));
      tree l = left;
      while (TREE_CODE (l) == NOP_EXPR
             || TREE_CODE (l) == CONVERT_EXPR
             || TREE_CODE (l) == NON_LVALUE_EXPR)
        l = TREE_OPERAND (l, 0);
      while (t && TYPE_MAIN_VARIANT (t) != tl)
        {
          t = TYPE_LANG_BASE (t);
          if (t && TREE_CODE (t) == POINTER_TYPE)
            t = TREE_TYPE (t);
        }
      if (!t)
        {
          error ("right operand of `%s' must be a derived type", opname);
          error (" of the declared type of the left operand");
        }
      else if (TYPE_MAIN_VARIANT (right) == tl)
        {
          if (op == p_is)
            {
              gpc_warning ("`is' always yields `True' if the right operand");
              gpc_warning (" is the declared type of the left operand.");
              if (TREE_SIDE_EFFECTS (left))
                gpc_warning (" Operand with side-effects is not evaluated.");
              return boolean_true_node;
            }
          else
            {
              gpc_warning ("`as' has no effect if the right operand is");
              gpc_warning (" the declared type of the left operand");
              return oleft;
            }
        }
      /* Variables, value parameters and components are not polymorphic.
         (Reference parameters are INDIRECT_REF.) */
      else if (TREE_CODE (l) == VAR_DECL
               || TREE_CODE (l) == PARM_DECL
               || TREE_CODE (l) == COMPONENT_REF
               || TREE_CODE (l) == ARRAY_REF)
        {
          if (op == p_is)
            {
              gpc_warning ("`is' always yields `False' if the left operand is not");
              gpc_warning (" polymorphic and the right operand is not its type");
              if (TREE_SIDE_EFFECTS (left))
                gpc_warning (" Operand with side-effects is not evaluated.");
              return boolean_false_node;
            }
          else
            {
              error ("`as' can never succeed if the left operand is not");
              error (" polymorphic and the right operand is not its type");
            }
        }
      else
        {
          tree vmt_left = get_vmt_field (left);
          tree vmt_right = build_pascal_unary_op (ADDR_EXPR, TYPE_LANG_VMT_VAR (right));
          if (!EM (vmt_left) && !EM (vmt_right))
            {
              tree p_right;
              tree res = build_predef_call (p_is, tree_cons (NULL_TREE, vmt_left,
                           build_tree_list (NULL_TREE, vmt_right)));
              if (op == p_is)
                return res;

              /* (((Left is Right) ? : ObjectTypeAsError), ^Right (@Left))^
                 Note: Moving the `^' inside the COMPOUND_EXPR fails because
                 a later build_component_ref for a method call would move the
                 component ref into the COMPOUND_EXPR's operand, and
                 CALL_METHOD doesn't recognize the (still existing) COMPOUND_EXPR
                 (maybe CALL_METHOD should be fixed, but it works this way).
                 The `((Left is Right) ? : ObjectTypeAsError)' part is not done
                 within the RTS so the compiler can optimize a construction like
                 `if foo is bar then something (foo as bar)'. */
              p_right = build_pointer_type (right);
              res = save_expr (
                       build (COMPOUND_EXPR, p_right,
                         build (COND_EXPR, void_type_node, res,
                                convert (void_type_node, integer_zero_node),
                                build_predef_call (p_as, NULL_TREE)),
                         convert (p_right, build_pascal_unary_op (ADDR_EXPR, left))));
              return want_class ? res : build_indirect_ref (res, NULL);
            }
        }
    }
  return error_mark_node;
}
