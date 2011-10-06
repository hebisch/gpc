/*A Bison parser for ISO 7185 Pascal, ISO 10206 Extended Pascal,
  Borland Pascal and some PXSC, Borland Delphi and GNU Pascal extensions.

  Copyright (C) 1989-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>
           Bill Cox <bill@cygnus.com> (error recovery rules)

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

/*Note: Bison automatically applies a default action of `$$ = $1' for all
  derivations; this is applied before the explicit action, if one is given.
  Keep this in mind when reading the actions.

  The error recovery strategy (the placement of `error' and `yyerrok') used
  here was that suggested in "An Introduction to Compiler Construction with
  Unix", by Axel Schreiner and H. George Friedman, chapter four, published by
  Prentice-Hall, 1985. Since it was done, the grammar has changed a lot, and now
  error recovery is more or less arbitrary (and possibly dangerous with GLR).

  For efficiency we build various lists in reverse order and `nreverse' them at
  the end which is O(n) instead of O(n^2).

  BP style typed constants and variables initialized with `=' would
  normally cause a shift/reduce conflict. They clash with upper-bound
  expressions of subranges. For an example, write

      const Foo: Boolean = False;
  as
      const Foo: False .. 1 = 1 = 2 = 7;

  (Nitpick: The types `Boolean' and `False .. True' are compatible, but
  not equivalent, in Pascal. But that's irrelevant to this problem.)

  This cannot be parsed (even BP can't do it). But consider the following:

      const Foo: False .. True = 2 = 7;
  or
      const Foo: False .. (1 = 1) = 2 = 7;

  This is resolved with a hack in the lexer: In this context, the `='
  immediately before the initializer is not lexed as `=' but as the special
  token LEX_CONST_EQUAL. */

%{
#define YYMAXDEPTH 200000
#define OMIT_PARSE_H
#include "gpc.h"
#ifdef GCC_4_0
#include "cgraph.h"
#endif
%}

%debug
%defines
%locations
%glr-parser
%no-default-prec
%expect 62
%expect-rr 25

/* The semantic values */
%union {
  enum tree_code code;
  long itype;
  tree ttype;
}

/* The dangling `else' shift/reduce conflict is avoided by precedence rules.
   Also, some conflicts coming from error recovery rules are avoided by giving
   rules the precedence `lower_than_error'. To avoid unwanted effects we
   - declare `%no-default-prec'
   - don't use precedence for operators etc. where it can be avoided
   - use special `prec_...' symbols which are not used otherwise for rules */
%nonassoc prec_if prec_lower_than_error
%nonassoc prec_import
%nonassoc p_else p_uses error

/* Keywords */
%token
  p_and p_array p_begin p_case p_div p_do p_downto p_end p_file p_for p_function
  p_goto p_if p_in p_label p_mod p_nil p_not p_of p_or p_packed p_procedure p_to
  p_program p_record p_repeat p_set p_then p_type p_until p_var p_while p_with

%token <ttype>
  p_absolute p_abstract p_and_then p_as p_asm p_attribute p_bindable p_const
  p_constructor p_destructor p_external p_far p_finalization p_forward
  p_implementation p_import p_inherited p_initialization p_is p_near p_object
  p_only p_operator p_otherwise p_or_else p_pow p_qualified p_restricted p_shl
  p_shr p_unit p_uses p_value p_virtual p_xor p_asmname p_c p_c_language
  p_class p_override p_reintroduce p_view

/* Built-in identifiers with special syntax */
%token <ttype>
  p_Addr p_Assigned p_Dispose p_Exit p_FormatString p_New p_Return p_StringOf

/* Lexer tokens */
%token <ttype>
  LEX_INTCONST LEX_INTCONST_BASE LEX_STRCONST LEX_REALCONST
  LEX_BUILTIN_PROCEDURE LEX_BUILTIN_PROCEDURE_WRITE LEX_BUILTIN_FUNCTION
  LEX_ID LEX_CARET_WHITE

%token <itype>
  LEX_CARET_LETTER

%token
  LEX_ASSIGN LEX_RENAME LEX_RANGE LEX_ELLIPSIS LEX_CONST_EQUAL
  LEX_SYMDIFF LEX_NE LEX_GE LEX_LE LEX_POWER LEX_BPPLUS LEX_BPMINUS
  LEX_CEIL_PLUS LEX_CEIL_MINUS LEX_FLOOR_PLUS LEX_FLOOR_MINUS
  LEX_CEIL_MULT LEX_CEIL_DIV LEX_FLOOR_MULT LEX_FLOOR_DIV

/* Nonterminals */

%type <code>
  multiplying_operator adding_operator unary_operator for_direction and_operator
  relational_operator or_operator sign

%type <itype>
  implementation_decls any_declaration_part declarations_and_uses interface_decl
  implementation_decl declaration_or_uses asm_qualifier builtin_proc simple_decl
  uses_part interface_decl_part simple_decl_1 any_decl optional_statement packed
  optional_case_element_list optional_case_completer disable_function_calls

%type <ttype>
  variable_or_routine_access_no_builtin_function absolute_or_value_specification
  optional_variable_directive_list_no_external static_expression combined_string
  optional_routine_interface_directive_list case_constant_list simple_expression
  optional_variable_directive_list optional_parameter_form actual_parameter_list
  optional_routine_directive_list optional_unit_filename method_heading typename
  discriminant_specification_list write_actual_parameter untyped_file identifier
  variable_directive_no_external optional_program_heading export_list fixed_part
  optional_formal_parameter_list optional_combined_string i_protected expression
  builtin_actual_parameter_list new_ordinal_type_non_iso type_denoter open_array
  index_type_specification_list unpacked_structured_type bp_directive resulttype
  typename_or_conformant_array routine_or_method_heading asm_clobbers export_all
  type_denoter_with_attributes pxsc_multiplying_operator asm_operands typename_1
  set_constructor_element_list optional_import_qualifier type_inquiry label term
  discriminant_expression_list index_type_specification typename_or_untyped_file
  optional_value_specification direct_access_index_type caret_letter field_value
  write_actual_parameter_list variable_or_routine_access asm_operand factor null
  formal_schema_discriminants optional_module_parameters import_clause num_label
  actual_schema_discriminants optional_module_attributes with_variable enum_list
  structured_constructor_list discriminant_specification object_parent with_list
  start_of_assignment_or_call remote_directive_list attribute_list subrange_type
  nonempty_asm_operands index_expression_list object_field_list variant_selector
  index_expression_item formal_parameter_list member_designator string_constants
  typename_or_string255 array_value_completer one_case_constant export_list_item
  optional_par_id_list pxsc_adding_operator optional_protected record_field_list
  variable_declaration optional_fixed_part pointer_domain_type optional_abstract
  optional_result_def operator_result_def operator_identifier export_list_or_all
  object_field_list_1 new_procedural_type variant_part_value0 variable_directive
  bp_constructor_list ordinal_index_type import_clause_list new_label attributes
  variant_part_value optional_qualified component_value new_quid variant primary
  new_ordinal_type formal_parameter type_denoter_1 type_denoter_0 record_section
  field_value_list new_identifier_1 parameter_form object_section new_identifier
  unsigned_number id_list_limited set_constructor routine_heading bp_field_value
  array_index_list remote_directive operator_symbol string_constant variant_list
  rest_of_variant new_pointer_type conformant_array enumerated_type id_list1 err
  optional_rename attrib id_list id optional_formal_parameter_list0

%{
/* A few keywords of some dialects can be parsed as regular identifiers
   and checked from the parser actions => fewer special tokens. */
#define ASSERT_ID(id, location, pseudo_keyword) \
  do if (!IDENTIFIER_IS_BUILT_IN (id, pseudo_keyword) || !PD_ACTIVE (IDENTIFIER_BUILT_IN_VALUE (id))) \
    { yyerror_id (id, &location); YYERROR; } while (0)

enum { od_none, od_uses, od_label, od_const, od_type, od_var, od_routine };
static int check_decl_order (int, int);

extern int main_yyparse (void);
#define yyparse main_yyparse

union yyGLRStackItem;
static void locations (YYLTYPE *, const union yyGLRStackItem *, int);
#define YYLLOC_DEFAULT(DEST, SRC, N) locations (&DEST, SRC, N)
#ifndef GCC_3_4
#define LOCATION_NOTE(LOC) if (current_function_decl) emit_line_note ((LOC).first_file, (LOC).first_line)
#else
#define LOCATION_NOTE(LOC) if (current_function_decl) \
  { \
    location_t loc_aux = \
        pascal_make_location ((LOC).first_file, (LOC).first_line); \
    emit_line_note (loc_aux); \
  }
#endif
#define COPYLOC(D, S) /* @@ ? (* (YYLTYPE *) memcpy (&(D), &(S), sizeof (YYLTYPE))) */ (S)

#define YYASSERT gcc_assert
#define YYMALLOC (void *) xmalloc
#define YYREALLOC (void *) xrealloc
%}

%%

/* Main program, module and unit structure */

program_component:
    /* empty */
      { error ("empty input file"); }
  | program_component_1
      {
        if (co->ignore_garbage_after_dot)
          {
            discard_input ();
            YYACCEPT;
          }
      }
  ;

program_component_1:
    optional_program_heading optional_module_attributes
      { initialize_module (TREE_PURPOSE ($1), build_tree_list ($2 ? TREE_PURPOSE ($2) : NULL_TREE, TREE_VALUE ($1)), 0); }
    optional_import_part declarations_and_uses
      { start_main_program (); }
    compound_statement dot_or_error
      { finish_main_program (); }
  | module_declaration
      { finalize_module (0); }
  ;

module_declaration:
    p_unit new_identifier ';' optional_module_attributes LEX_ID
      { ASSERT_ID ($5, @5, p_interface); initialize_module ($2, $4, 1); }
    optional_import_part interface_decl_part
      { start_unit_implementation (); }
    optional_unit_implementation p_end dot_or_error
      { check_forward_decls (1); }
  | interface_module
  | implementatation_module
  | interface_module
      { $<ttype>$ = current_module->name; finalize_module (1); }
    implementatation_module
      {
        if ($<ttype>2 && current_module->name != $<ttype>2)
          error ("implementation of module `%s' following interface of module `%s'",
                 IDENTIFIER_NAME (current_module->name), IDENTIFIER_NAME ($<ttype>2));
      }
  | module new_identifier optional_module_parameters
      { initialize_module ($2, $3, 2); }
    module_interface ';'
      {
        if (co->interface_only)
          exit_compilation ();
      }
    module_block dot_or_error
  | module new_identifier optional_module_parameters
      { initialize_module ($2, $3, 4); }
    module_block dot_or_error
  ;

interface_module:
    module new_identifier LEX_ID
      { ASSERT_ID ($3, @3, p_interface); }
    optional_module_parameters
      { initialize_module ($2, $5, 2); }
    module_interface dot_or_error
      { clear_forward_decls ();  /* don't complain in poplevel */ }
  ;

module_interface:
    LEX_ID
      { ASSERT_ID ($1, @1, p_export); start_module_interface (); }
    export_part_list ';' optional_import_part interface_decl_part p_end
      { create_gpi_files (); }
  ;

implementatation_module:
    module new_identifier p_implementation ';'
      { initialize_module ($2, NULL_TREE, 3); }
    module_block dot_or_error
  ;

module_block:
      { current_module->implementation = 1; }
    optional_import_part1 implementation_decls
      { check_forward_decls (1); }
    optional_init_and_final_part p_end
  ;

optional_unit_implementation:
      { chk_dialect ("units without `implementation' part are", U_M_PASCAL); }
  | p_implementation optional_import_part1 declarations_and_uses optional_unit_init_and_final_part
  ;

optional_unit_init_and_final_part:
    p_begin
      { start_constructor (0); }
    rest_of_unit_constructor
  | unit_initialization
  | unit_initialization p_finalization
      { start_destructor (); }
    statement_sequence
      { finish_destructor (); }
  | optional_init_and_final_part
  ;

unit_initialization:
    p_initialization
      { start_constructor (0); }
    rest_of_unit_constructor
  ;

rest_of_unit_constructor:
    statement_sequence
      { finish_constructor (); }
  ;

optional_init_and_final_part:
    /* empty */
  | module_constructor module_destructor
  | module_constructor
  | module_destructor
  ;

module_constructor:
    p_to p_begin p_do
      { chk_dialect_name ("to begin do", E_O_PASCAL); start_constructor (0); }
    optional_statement ';'
      { finish_constructor (); }
  ;

module_destructor:
    p_to p_end p_do
      { chk_dialect_name ("to end do", E_O_PASCAL); start_destructor (); }
    optional_statement ';'
      { finish_destructor (); }
  ;

optional_program_heading:
    /* empty */
      { $$ = build_tree_list (NULL_TREE, NULL_TREE); }
  | p_program new_identifier optional_par_id_list ';'
      { $$ = build_tree_list ($2, $3); }
  | p_program error optional_par_id_list ';'
      { $$ = build_tree_list (NULL_TREE, $3); }
  ;

optional_module_parameters:
    optional_par_id_list ';' optional_module_attributes
      { $$ = build_tree_list ($3 ? TREE_PURPOSE ($3) : NULL_TREE, $1); }
  ;

optional_par_id_list:
    null
  | '(' id_list ')'
      { $$ = $2; }
  ;

optional_module_attributes:
    null
  | attributes ';'
  ;

export_part_list:
    export_part
  | export_part_list ';' export_part
      { yyerrok; }
  | error
      { error ("module specifications need an export part"); }
  | export_part_list error export_part
      { gpc_warning ("missing semicolon"); yyerrok; }
  | export_part_list ';' error
      { error ("extra semicolon"); }
  ;

export_part:
    new_identifier equals export_list_or_all
      { export_interface ($1, $3); }
  ;

export_list_or_all:
    '(' export_list ')'
      { $$ = $2; }
  | export_all
  | export_all '(' export_list ')'
      { $$ = chainon ($1, $3); }
  ;

export_all:
    LEX_ID
      { ASSERT_ID ($1, @1, p_all); $$ = build_tree_list (NULL_TREE, NULL_TREE); }
  ;

export_list:
    export_list_item
  | export_list ',' export_list_item
      { $$ = chainon ($1, $3); }
  | error
      { $$ = NULL_TREE; }
  | export_list error export_list_item
      { $$ = NULL_TREE; }
  | export_list ',' error
      { $$ = NULL_TREE; }
  ;

export_list_item:
    new_quid optional_rename
      { $$ = build_tree_list ($2, $1); }
  | new_quid LEX_RANGE new_quid
      { $$ = build_tree_list (NULL_TREE, build_tree_list ($1, $3)); }
  | i_protected new_quid optional_rename
      { $$ = build_tree_list ($3, $2); TREE_READONLY ($$) = 1; }
  ;

optional_import_part:
      { do_extra_import (); }
    optional_import_part1
  ;

optional_import_part1:
    /* empty */
  | p_import import_specification_list ';' %prec prec_import
  ;

import_specification_list:
    import_specification
  | import_specification_list ';' import_specification
  | import_specification_list error import_specification
      { gpc_warning ("missing semicolon"); yyerrok; }
  ;

import_specification:
    new_identifier optional_qualified optional_import_qualifier optional_unit_filename
      { import_interface ($1, $3, $2 ? IMPORT_QUALIFIED : IMPORT_ISO, $4); }
  ;

optional_qualified:
    null
  | p_qualified
  ;

optional_import_qualifier:
    null
  | '(' import_clause_list ')'
      { $$ = build_tree_list (NULL_TREE, $2); }
  | p_only '(' import_clause_list ')'
      { $$ = build_tree_list ($1, $3); }
  ;

import_clause_list:
    import_clause
  | import_clause_list ',' import_clause
      { $$ = chainon ($1, $3); }
  | error
      { $$ = NULL_TREE; }
  | import_clause_list error import_clause
      { error ("missing comma"); $$ = chainon ($1, $3); }
  | import_clause_list ',' error
      { $$ = NULL_TREE; }
  ;

import_clause:
    new_identifier optional_rename
      { $$ = build_tree_list ($1, $2); }
  ;

optional_rename:
    null
  | LEX_RENAME new_identifier
      { $$ = $2; }
  ;

declarations_and_uses:
    /* empty */
      { $$ = 2 * od_none; }
  | declarations_and_uses declaration_or_uses
      { $$ = check_decl_order ($1, $2); }
  ;

declaration_or_uses:
    uses_part
  | any_decl
  ;

any_declaration_part:
    /* empty */
      { $$ = 2 * od_none; }
  | any_declaration_part any_decl
      { $$ = check_decl_order ($1, $2); }
  ;

any_decl:
      { check_forward_decls (0); }
    simple_decl
      { $$ = $2; }
  | p_label label_list ';'
      { $$ = od_label; }
  | routine_declaration
      { $$ = od_routine; }
  ;

interface_decl_part:
    /* empty */
      { $$ = 2 * od_none; }
  | interface_decl_part interface_decl
      { $$ = check_decl_order ($1, $2); }
  ;

interface_decl:
    uses_part
  | simple_decl
  | routine_interface_decl
      { $$ = od_routine; }
  ;

implementation_decls:
    /* empty */
      { $$ = 2 * od_none; }
  | implementation_decls implementation_decl
      { $$ = check_decl_order ($1, $2); }
  ;

implementation_decl:
    uses_part
  |   { check_forward_decls (0); }
    simple_decl
      { $$ = $2; }
  | routine_declaration
      { $$ = od_routine; }
  ;

uses_part:
    p_uses uses_list ';'
      { $$ = od_uses; }
  ;

uses_list:
    uses_specification
  | uses_list ',' uses_specification
  | uses_list error uses_specification
      { gpc_warning ("missing comma"); yyerrok; }
  ;

uses_specification:
    new_identifier optional_unit_filename
      { import_interface ($1, NULL_TREE, IMPORT_USES, $2); }
  ;

optional_unit_filename:
    null
  | p_in expression
      { $$ = $2; chk_dialect ("file name specification with `in' is", BORLAND_DELPHI); }
  ;

simple_decl:
      {
#ifndef EGCS97
        push_obstacks_nochange ();
        end_temporary_allocation ();
#endif
      }
    simple_decl_1
      {
#ifndef EGCS97
        pop_obstacks ();
#endif
        $$ = $2;
      }
  ;

simple_decl_1:
    p_const constant_definition_list
      { $$ = od_const; }
  | p_type
      { current_type_list = build_tree_list (NULL_TREE, NULL_TREE); }
    type_definition_list ';'
      { declare_types (); $$ = od_type; }
  | p_var variable_declaration_list
      { $$ = od_var; }
  ;

/* Label declaration part */

label_list:
    new_label
      { declare_label ($1); }
  | label_list ',' new_label
      { declare_label ($3); }
  | error
      { error ("non-label in label_list"); }
  | label_list error new_label
      { declare_label ($3); error ("missing comma"); yyerrok; }
  | label_list ',' error
      { error ("extra comma"); }
  | label_list error
  ;

new_label:
    num_label
  | new_identifier
      { chk_dialect ("non-numeric labels are", B_D_M_PASCAL); }
  ;

constant_definition_list:
    constant_definition
  | constant_definition_list constant_definition
  | error
  ;

constant_definition:
    new_identifier equals static_expression ';'
      { declare_constant ($1, $3); }
  | new_identifier enable_lce ':' type_denoter_with_attributes
    LEX_CONST_EQUAL component_value optional_variable_directive_list_no_external ';'
      {
        lex_const_equal = -1;
        declare_variables (build_tree_list (NULL_TREE, $1), $4, build_tree_list (NULL_TREE, $6), VQ_BP_CONST, $7);
      }
  ;

variable_declaration_list:
    variable_declaration
  | variable_declaration_list variable_declaration
  ;

variable_declaration:
    id_list_limited enable_lce ':' type_denoter_with_attributes
      {
        tree t, ids = $<ttype>$ = nreverse ($1);
        if ((TREE_CODE ($4) == POINTER_TYPE || TREE_CODE ($4) == REFERENCE_TYPE)
            && TREE_CODE (TREE_TYPE ($4)) == FUNCTION_TYPE)
          TREE_PRIVATE (ids) = !!allow_function_calls (0);  /* kludge */
        /* With `begin var Foo: Integer; Foo := ...' where `Foo'
           is a built-in identifier, parser look-ahead would already get
           its special meaning before we get to declaring the variables.
           So mark the identifiers. (fjf791.pas) */
        for (t = ids; t; t = TREE_CHAIN (t))
          PASCAL_PENDING_DECLARATION (TREE_VALUE (t)) = 1;
      }
    absolute_or_value_specification optional_variable_directive_list ';'
      {
        tree t, ids = $<ttype>5;
        for (t = ids; t; t = TREE_CHAIN (t))
          PASCAL_PENDING_DECLARATION (TREE_VALUE (t)) = 0;
        lex_const_equal = -1;
        $$ = declare_variables (ids, $4, $6, 0, $7);
        if ((TREE_CODE ($4) == POINTER_TYPE || TREE_CODE ($4) == REFERENCE_TYPE)
            && TREE_CODE (TREE_TYPE ($4)) == FUNCTION_TYPE)
          allow_function_calls (TREE_PRIVATE (ids));
        yyerrok;
      }
  | error
      { $$ = NULL_TREE; lex_const_equal = -1; }
  ;

optional_variable_directive_list:
    null
  | optional_variable_directive_list ';' variable_directive
      { $$ = chainon ($1, $3); }
  ;

variable_directive:
    variable_directive_no_external
  | p_external optional_combined_string
      { $$ = build_tree_list ($1, $2); }
  | p_external optional_combined_string LEX_ID
      { ASSERT_ID ($3, @3, p_name); }
    expression
      { $$ = tree_cons ($3, $5, build_tree_list ($1, $2)); }
  ;

optional_variable_directive_list_no_external:
    null
  | optional_variable_directive_list_no_external ';' variable_directive_no_external
      { $$ = chainon ($1, $3); }
  ;

variable_directive_no_external:
    p_asmname expression
      { $$ = build_tree_list ($1, $2); }
  | attributes
      { $$ = TREE_PURPOSE ($1); }
  ;

absolute_or_value_specification:
    optional_value_specification
  | p_absolute
      { $<itype>$ = allow_function_calls (0); lex_const_equal = -1; }
    expression
      {
        allow_function_calls ($<itype>2);
        $$ = build_tree_list (NULL_TREE, $3);
        PASCAL_ABSOLUTE_CLAUSE ($$) = 1;
      }
  | p_absolute error
      { $$ = NULL_TREE; }
  ;

type_definition_list:
    type_definition
  | type_definition_list ';' type_definition
      { yyerrok; }
  | error
  | type_definition_list error type_definition
      { error ("missing semicolon"); yyerrok; }
  | type_definition_list ';' error
      { error ("extra semicolon"); }
  | type_definition_list error
  ;

type_definition:
    new_identifier enable_lce equals type_denoter_with_attributes optional_value_specification
      {
        lex_const_equal = -1;
        if (!EM ($4))
          {
            if (PASCAL_TYPE_UNDISCRIMINATED_SCHEMA ($4))
              chk_dialect ("undiscriminated schemata on the right side of a type definition are", GNU_PASCAL);
            build_type_decl ($1, $4, $5);
          }
      }
  | new_identifier 
      { current_schema = start_struct (RECORD_TYPE); }
    formal_schema_discriminants equals
      {
        $<itype>$ = immediate_size_expand;
        immediate_size_expand = 0;
        size_volatile++;
      }
    type_denoter_with_attributes optional_value_specification
      {
        build_type_decl ($1, build_schema_type ($6, $3, $7, current_schema), 
                          NULL_TREE);
        immediate_size_expand = $<itype>5;
        size_volatile--;
        current_schema = NULL_TREE;
      }
  | new_identifier 
      { current_schema = start_struct (RECORD_TYPE); }
    formal_schema_discriminants error
      { build_schema_type (error_mark_node, $3, NULL_TREE, current_schema);
        current_schema = NULL_TREE;
      }
  | new_identifier enable_lce equals
      { $<ttype>$ = start_object_type ($1, 0); }
    optional_abstract p_object object_parent
      { push_scope (); }
    object_field_list p_end
      {
        lex_const_equal = -1;
        finish_object_type ($<ttype>4, $7, $9, $5 != NULL_TREE);
        pop_record_level ($<ttype>4);
        yyerrok;
      }

  | new_identifier enable_lce equals
      { $<ttype>$ = start_object_type ($1, 1); }
    optional_abstract p_class object_parent
      { push_scope (); }
    object_field_list p_end
      {
        lex_const_equal = -1;
        finish_object_type ($<ttype>4, $7, $9, $5 != NULL_TREE);
        pop_record_level ($<ttype>4);
        yyerrok;
      }

  | new_identifier enable_lce equals p_view p_of typename object_parent
      { push_scope (); }
    object_field_list p_end
      {
        lex_const_equal = -1;
        finish_view_type ($1, $6, $7, $9);
        pop_record_level (NULL_TREE);
        yyerrok;
      }
  | new_identifier enable_lce equals p_class object_parent
      {
        tree t = build_pascal_pointer_type (make_node (LANG_TYPE));
        PASCAL_TYPE_CLASS (t) = 1;
        build_type_decl ($1, t, NULL_TREE);
        gpc_warning ("ignored parent in Delphi forward class declaration");
      }
  | new_identifier enable_lce equals p_class LEX_RANGE p_end
      {
        tree t = build_pascal_pointer_type (make_node (LANG_TYPE));
	PASCAL_TYPE_CLASS (t) = 1;
	build_type_decl ($1, t, NULL_TREE); 
      }
  | new_identifier enable_lce equals p_object ';' p_forward
      {
        tree t = build_pascal_pointer_type (make_node (LANG_TYPE));
        PASCAL_TYPE_CLASS (t) = 1;
        build_type_decl ($1, t, NULL_TREE);
      }
  ;

formal_schema_discriminants:
    '(' discriminant_specification_list ')'
      { $$ = $2; }
  | '(' error ')'
      { error ("invalid schema discriminants"); $$ = NULL_TREE; }
  ;

discriminant_specification_list:
    discriminant_specification
  | discriminant_specification_list ';' discriminant_specification
      { $$ = chainon ($1, $3); }
  | discriminant_specification_list error discriminant_specification
      { $$ = chainon ($1, $3); error ("missing semicolon"); yyerrok; }
  | discriminant_specification_list ';' error
      { error ("extra semicolon"); }
  | discriminant_specification_list error
  ;

discriminant_specification:
    id_list ':' typename
      { $$ = build_discriminants ($1, $3, current_schema); }
  ;

type_denoter_with_attributes:
    type_denoter
  | type_denoter_with_attributes attributes
      { type_attributes (&$$, TREE_PURPOSE ($2)); }
  ;

/* Ensure that obstack change is active for all parts of type denoters. */
type_denoter:
      {
#ifndef EGCS97
        push_obstacks_nochange ();
        end_temporary_allocation ();
#endif
      }
    type_denoter_1
      {
#ifndef EGCS97
        pop_obstacks ();
#endif
        $$ = $2;
      }
  ;

type_denoter_1:
    type_denoter_0
  | p_bindable type_denoter_0
      { $$ = pascal_type_variant ($2, TYPE_QUALIFIER_BINDABLE); }
  ;

type_denoter_0:
    typename_or_string255
  | p_restricted typename_or_string255
      { $$ = pascal_type_variant ($2, TYPE_QUALIFIER_RESTRICTED); }
  | typename actual_schema_discriminants
      { $$ = build_discriminated_schema_type ($1, $2, 0); }
  | type_inquiry
  | new_ordinal_type
  | new_pointer_type
  | new_procedural_type
      { chk_dialect ("procedural variables and types are", B_D_M_PASCAL); }
  | unpacked_structured_type
  | packed unpacked_structured_type
      { defining_packed_type -= $1; $$ = $1 ? pack_type ($2) : $2; }
  ;

actual_schema_discriminants:
    '(' discriminant_expression_list ')'
      { chk_dialect ("schema/string discriminants are", E_O_M_PASCAL); $$ = $2; }
  | '[' expression ']'
      {
        chk_dialect ("string capacity in brackets is", U_B_D_M_PASCAL);
        $$ = build_tree_list (NULL_TREE, maybe_schema_discriminant (string_may_be_char ($2, 0)));
      }
  ;

discriminant_expression_list:
    expression
      /* This expression might be a discriminant of another schema. */
      { $$ = build_tree_list (NULL_TREE, maybe_schema_discriminant (string_may_be_char ($1, 0))); }
  | discriminant_expression_list ',' expression
      { $$ = chainon ($1, build_tree_list (NULL_TREE, maybe_schema_discriminant (string_may_be_char ($3, 0)))); yyerrok; }
  | error
      { error ("missing expression"); $$ = NULL_TREE; }
  | discriminant_expression_list error expression
      { error ("missing comma"); $$ = chainon ($1, build_tree_list (NULL_TREE, maybe_schema_discriminant (string_may_be_char ($3, 0)))); yyerrok; }
  | discriminant_expression_list ',' error
      { error ("extra comma"); }
  ;

unpacked_structured_type:
    p_array '[' array_index_list ']' p_of type_denoter
      { $$ = build_pascal_array_type ($6, $3); }
  | untyped_file
  | p_file direct_access_index_type p_of type_denoter
      { $$ = build_file_type ($4, $2, 0); }
  | p_set p_of type_denoter
      { $$ = build_set_type ($3); }
  | p_record { push_scope (); } record_field_list p_end
      { pop_record_level ($3); $$ = $3; yyerrok; }
  | p_record error p_end
      { $$ = build_record (NULL_TREE, NULL_TREE, NULL_TREE); }
  | err
  ;

direct_access_index_type:
    null
  | '[' ordinal_index_type ']'
      { $$ = TREE_VALUE ($2); }
  ;

array_index_list:
    ordinal_index_type
  | array_index_list ',' ordinal_index_type
      { $$ = chainon ($1, $3); yyerrok; }
  | array_index_list error ordinal_index_type
      { $$ = chainon ($1, $3); error ("missing comma"); yyerrok; }
  | array_index_list error
      { $$ = build_tree_list (error_mark_node, error_mark_node); }
  | error
      { $$ = build_tree_list (error_mark_node, error_mark_node); }
  ;

ordinal_index_type:
    new_ordinal_type
      { $$ = build_tree_list (NULL_TREE, $1); }
  | typename
      { $$ = build_tree_list (NULL_TREE, $1); }
  ;

record_field_list:
    /* empty */
      { $$ = build_record (NULL_TREE, NULL_TREE, NULL_TREE); }
  | fixed_part optional_semicolon
      { $$ = build_record ($1, NULL_TREE, NULL_TREE); }
  | optional_fixed_part p_case variant_selector p_of variant_list optional_semicolon rest_of_variant
      { $$ = build_record ($1, $3, chainon ($5, $7)); }
  ;

optional_fixed_part:
    null
  | fixed_part ';'
  ;

fixed_part:
    record_section
  | fixed_part ';' record_section
      { $$ = chainon ($1, $3); yyerrok; }
  | fixed_part error record_section
      { $$ = chainon ($1, $3); error ("missing semicolon"); yyerrok; }
  | fixed_part ';' error
      { error ("extra semicolon"); }
  | fixed_part error
  ;

record_section:
    id_list ':' type_denoter optional_value_specification
      { $$ = build_fields ($1, $3, $4); }
  ;

rest_of_variant:
    /* empty */
      { $$ = NULL_TREE; }
  | otherwise '(' record_field_list ')' optional_semicolon
      { $$ = build_tree_list (NULL_TREE, build_field (NULL_TREE, $3)); }
  ;

variant_selector:
    new_identifier ':' typename
      { $$ = build_tree_list ($3, build_field ($1, $3)); }
  | new_identifier ':' new_ordinal_type_non_iso
      { $$ = build_tree_list ($3, build_field ($1, $3)); }
  | id  /* type name or discriminant identifier! */
      { $$ = build_tree_list ($1, NULL_TREE); }
  | new_ordinal_type_non_iso
      { $$ = build_tree_list ($1, NULL_TREE); }
  ;

variant_list:
    variant
  | variant_list ';' variant
      { $$ = chainon ($1, $3); yyerrok; }
  | variant_list error variant
      { $$ = chainon ($1, $3); error ("missing semicolon"); yyerrok; }
  | error
      { $$ = NULL_TREE; }
  | variant_list error
  ;

variant:
    case_constant_list ':' '(' record_field_list ')'
      { $$ = build_tree_list ($1, build_field (NULL_TREE, $4)); }
  ;

new_ordinal_type_non_iso:
    new_ordinal_type
      { chk_dialect ("type denoters (no identifiers) as variant tag type are", U_B_D_M_PASCAL); }
  ;

new_ordinal_type:
    enumerated_type
  | subrange_type
  ;

enumerated_type:
    '(' enum_list ')'
      { $$ = build_enum_type (nreverse ($2)); }
  | '(' error ')'
      { $$ = error_mark_node; }
  ;

enum_list:
    new_identifier
      { $$ = build_tree_list ($1, NULL_TREE); }
  | enum_list ',' new_identifier
      { $$ = tree_cons ($3, NULL_TREE, $1); yyerrok; }
  | enum_list error new_identifier
      { $$ = tree_cons ($3, NULL_TREE, $1); error ("missing comma"); yyerrok; }
  | enum_list ',' error
      { error ("extra comma"); }
  | enum_list error
  ;

subrange_type:
    expression LEX_RANGE expression
      { $$ = build_pascal_subrange_type ($1, $3, 0); }
  | packed expression LEX_RANGE expression
      {
        defining_packed_type -= $1;
        chk_dialect ("packed subrange types are", B_D_PASCAL);
        $$ = build_pascal_subrange_type ($2, $4, $1);
      }
  ;

new_pointer_type:
    '@' pointer_domain_type
      { $$ = EM ($2) ? error_mark_node : build_pascal_pointer_type ($2); }
  | '^' pointer_domain_type
      { $$ = EM ($2) ? error_mark_node : build_pascal_pointer_type ($2); }
  | LEX_CARET_WHITE pointer_domain_type
      { $$ = EM ($2) ? error_mark_node : build_pascal_pointer_type ($2); }
  | pointer_char p_const pointer_domain_type
      { $$ = EM ($3) ? error_mark_node : build_pascal_pointer_type (p_build_type_variant ($3, 1, TYPE_VOLATILE ($3))); }
  ;

pointer_domain_type:
    new_identifier
      { $$ = get_pointer_domain_type ($1); }
  | new_procedural_type
      {
        chk_dialect ("pointers to routines are", GNU_PASCAL);
        gcc_assert (EM ($1) || (TREE_CODE ($1) == REFERENCE_TYPE && TREE_TYPE ($1)));
        $$ = TREE_TYPE ($1);
      }
  | untyped_file
  ;

new_procedural_type:
    p_procedure optional_formal_parameter_list
      { 
        pop_param_level ($2, NULL_TREE);
        $$ = build_procedural_type (void_type_node, $2);
      }
  | p_function optional_formal_parameter_list 
      { pop_param_level ($2, NULL_TREE); }
    resulttype
      { $$ = build_procedural_type ($4, $2); }
  ;

object_parent:
    null
  | '(' typename ')'
      { $$ = $2; }
  | '(' error ')'
      { $$ = NULL_TREE; }
  ;

optional_abstract:
    null
  | p_abstract
  ;

object_field_list:
    object_field_list_1 { $$ = $1; }
  | object_field_list_1 object_section { $$ = chainon ($1, $2); }
  | error
      { $$ = error_mark_node; }
  ;

object_field_list_1:
    null
  | object_field_list_1 LEX_ID  /* `public' etc. */
      { $$ = chainon ($1, build_tree_list (void_type_node, $2)); }
  | object_field_list_1 object_section ';'
      { $$ = chainon ($1, $2); yyerrok; }
  ;

object_section:
    id_list ':' type_denoter optional_value_specification
      { $$ = build_fields ($1, $3, $4); }
  | p_procedure new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($3, NULL_TREE);
        $$ = build_routine_heading (NULL_TREE, $2, $3, NULL_TREE,
                                      void_type_node, 0);
      }
  | p_function new_identifier optional_formal_parameter_list optional_result_def
      { pop_param_level ($3, $4); }
 resulttype
      { $$ = build_routine_heading (NULL_TREE, $2, $3, $4, $6, 0); }
  | p_constructor new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($3, NULL_TREE);
        $$ = build_routine_heading (NULL_TREE, $2, $3, NULL_TREE,
                                      boolean_type_node, 1);
      }
  | p_destructor new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($3, NULL_TREE);
        $$ = build_routine_heading (NULL_TREE, $2, $3, NULL_TREE,
                                      void_type_node, 1);
      }
  | p_virtual
      { $$ = build_tree_list (NULL_TREE, $1); }
  | p_virtual expression
      { $$ = build_tree_list ($2, $1); }
  | p_override
      { $$ = build_tree_list (NULL_TREE, $1); }
  | p_reintroduce
      { $$ = build_tree_list (NULL_TREE, $1); }
  | p_abstract
      { $$ = build_tree_list (NULL_TREE, $1); }
  | attributes
  ;

optional_value_specification:
    null
  | var_init component_value
      { $$ = build_tree_list (NULL_TREE, $2); }
  | var_init error
      { $$ = NULL_TREE; }
  ;

var_init:
    p_value { lex_const_equal = -1; }
  | LEX_ASSIGN
      { chk_dialect ("initialization with `:=' is", VAX_PASCAL|SUN_PASCAL); }
  | LEX_CONST_EQUAL
      { chk_dialect ("initialization with `=' is", BORLAND_DELPHI); }
  ;

/* Routines (procedures represented as functions returning void_type_node) */

routine_interface_decl:
    routine_heading ';' optional_routine_interface_directive_list
      { declare_routine ($1, $3, 1); }
  ;

/* Distinguish between
     procedure Foo; <attributes> <remote_directive> <attributes>
   and
     procedure Bar; <attributes>
     begin
     end; */
routine_declaration:
    routine_or_method_heading ';' remote_directive_list
      { declare_routine ($1, $3, 0); }
  | routine_or_method_heading ';' optional_routine_directive_list
      { $<ttype>$ = start_routine ($1, $3); }
    optional_import_part1 any_declaration_part
      {
        do_setjmp ();
        un_initialize_block (getdecls (), 0, 0);
      }
    compound_statement ';'
      { finish_routine ($<ttype>4); }
  ;

routine_or_method_heading:
    routine_heading
  | method_heading
  ;

routine_heading:
    p_procedure new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($3, NULL_TREE);
        $$ = build_routine_heading (NULL_TREE, $2, $3, NULL_TREE,
                                      void_type_node, 0);
      }
  | p_function new_identifier optional_formal_parameter_list optional_result_def
      { pop_param_level ($3, $4); }
 resulttype
      { $$ = build_routine_heading (NULL_TREE, $2, $3, $4, $6, 0); }
  | p_operator operator_identifier optional_formal_parameter_list operator_result_def
      { pop_param_level ($3, $4); }
 resulttype
      { $$ = build_operator_heading ($2, $3, $4, $6); }
  ;

/* Using identifier instead of new_identifier for the object type would cause
   conflicts with non-method routines and (in the future) accept qualified
   identifiers (which are pointless in the header of an object method
   implementation). With new_identifier we only have to check
   (in build_routine_heading) that the object type really exists. */
method_heading:
    p_procedure new_identifier '.' new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($5, NULL_TREE);
        $$ = build_routine_heading ($2, $4, $5, NULL_TREE,
                                      void_type_node, 0);
      }
  | p_function new_identifier '.' new_identifier optional_formal_parameter_list optional_result_def 
      { pop_param_level ($5, $6); }
resulttype
      { $$ = build_routine_heading ($2, $4, $5, $6, $8, 0); }
  | p_constructor new_identifier '.' new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($5, NULL_TREE);
        $$ = build_routine_heading ($2, $4, $5, NULL_TREE,
                                      boolean_type_node, 1);
      }
  | p_destructor new_identifier '.' new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($5, NULL_TREE);
        $$ = build_routine_heading ($2, $4, $5, NULL_TREE,
                                      void_type_node, 1);
      }
  ;

optional_routine_interface_directive_list:
    optional_routine_directive_list
  | remote_directive_list
  ;

remote_directive_list:
    optional_routine_directive_list remote_directive optional_routine_directive_list
      { $$ = chainon (chainon ($1, $2), $3); }
  ;

remote_directive:
    p_forward ';'
      { $$ = build_tree_list (NULL_TREE, $1); }
  | p_external optional_combined_string ';'
      { $$ = build_tree_list ($2, $1); }
  | p_external optional_combined_string LEX_ID
      { ASSERT_ID ($3, @3, p_name); }
    expression ';'
      { $$ = tree_cons ($5, $3, build_tree_list ($2, $1)); }
  | p_external optional_combined_string ';' p_asmname expression ';'
      { $$ = tree_cons ($5, $4, build_tree_list ($2, $1)); }
  | p_asmname expression ';' p_external optional_combined_string ';'
      { $$ = tree_cons ($2, $1, build_tree_list ($5, $4)); }
  | p_asmname expression ';'
      { $$ = build_tree_list ($2, $1); }
  | p_c ';'
      { $$ = build_tree_list (NULL_TREE, $1); }
  | p_c_language ';'
      { $$ = build_tree_list (NULL_TREE, $1); }
  ;

optional_routine_directive_list:
    null
  | optional_routine_directive_list attributes ';'
      { $$ = chainon ($1, $2); }
  | optional_routine_directive_list bp_directive ';'
      { $$ = tree_cons (NULL_TREE, $2, $1); }
  ;

attributes:
    p_attribute '(' attribute_list ')'
      { $$ = build_tree_list ($3, $1); }
  ;

attribute_list:
    attrib
  | attribute_list ',' attrib
      { $$ = chainon ($1, $3); }
  ;

attrib:
    null
  | p_const
      { $$ = build_tree_list ($1, NULL_TREE); }
  | new_identifier
      { $$ = build_tree_list ($1, NULL_TREE); }
  | new_identifier equals expression
      { $$ = build_tree_list ($1, build_tree_list (NULL_TREE, $3)); }
  | new_identifier '(' expression ')'
      { $$ = build_tree_list ($1, build_tree_list (NULL_TREE, $3)); }
  | new_identifier '(' id ',' expression ')'
      { $$ = build_tree_list ($1, tree_cons (NULL_TREE, $3, $5)); }
  ;

bp_directive:
    p_far
  | p_near
  ;

operator_identifier:
    new_identifier
  | operator_symbol
  ;

operator_result_def:
    new_identifier
  | equals new_identifier
      { $$ = $2; chk_dialect ("operator result variables with `=' are", GNU_PASCAL); }
  | null
      { error ("missing operator result variable"); }
  ;

optional_formal_parameter_list:
  { push_scope (); } optional_formal_parameter_list0 { $$ = $2; }

optional_formal_parameter_list0:
    null
  | '(' ')'
      { chk_dialect ("empty parentheses are", BORLAND_DELPHI); $$ = void_list_node; }
  | '(' formal_parameter_list ')'
      { $$ = $2; }
  | '(' LEX_ELLIPSIS ')'
      { $$ = build_tree_list (NULL_TREE, NULL_TREE); }
  | '(' formal_parameter_list ';' LEX_ELLIPSIS ')'
      { $$ = chainon ($2, build_tree_list (NULL_TREE, NULL_TREE)); }
  | '(' error ')'
      { $$ = NULL_TREE; }
  ;

formal_parameter_list:
    formal_parameter
  | formal_parameter_list ';' formal_parameter
      { $$ = chainon ($1, $3); yyerrok; }
  | formal_parameter_list error formal_parameter
      { $$ = chainon ($1, $3); error ("missing semicolon"); yyerrok; }
  | formal_parameter_list ';' error
  ;

formal_parameter:
    id_list ':' parameter_form
      { $$ = build_formal_param ($1, $3, 0, 0); }
  | i_protected id_list ':' parameter_form
      { $$ = build_formal_param ($2, $4, 0, 1); }
  | optional_protected p_var id_list optional_parameter_form
      { $$ = build_formal_param ($3, $4, 1, !!$1); }
  | p_const p_var id_list ':' parameter_form
      { $$ = build_formal_param ($3, $5, 3, 1); }
  | p_const id_list optional_parameter_form
      { $$ = build_formal_param ($2, $3, 2, 1); }
  | p_procedure new_identifier optional_formal_parameter_list
      { 
        pop_param_level ($3, NULL_TREE); 
        $$ = build_routine_heading (NULL_TREE, $2, $3, NULL_TREE,
                                      void_type_node, 0);
      }
  | p_function new_identifier optional_formal_parameter_list optional_result_def
      { pop_param_level ($3, $4); }
 resulttype
      { $$ = build_routine_heading (NULL_TREE, $2, $3, $4, $6, 0); }
  ;

resulttype:
    empty_lte
      { $$ = NULL_TREE; }
  | ':' typename_or_string255
      { $$ = check_result_type ($2); }
  | err
  ;

optional_result_def:
    null
  | optional_result_equals new_identifier
      { $$ = $2; chk_dialect ("function result variable specifications are", E_O_PASCAL); }
  ;

optional_result_equals:
    equals
  | /* empty */
      { chk_dialect ("function result variables without `=' are", GNU_PASCAL); }
  ;

optional_protected:
    null
  | i_protected
  ;

optional_parameter_form:
    /* empty */
      { $$ = void_type_node; chk_dialect ("untyped parameters are", U_B_D_M_PASCAL); }
  | ':' parameter_form
      { $$ = $2; }
  ;

parameter_form:
    typename_or_conformant_array
  | type_inquiry
  | open_array
  ;

type_inquiry:
    p_type p_of expression
      { $$ = build_type_of ($3); }
  ;

typename_or_conformant_array:
    typename_or_untyped_file
  | conformant_array
  ;

conformant_array:
    p_array '[' index_type_specification_list ']' p_of typename_or_conformant_array
      { $$ = chainon ($3, $6); }
  | packed p_array '[' index_type_specification ']' p_of typename
      {
        defining_packed_type -= $1;
        PASCAL_TREE_PACKED ($4) = $1;
        $$ = chainon ($4, $7);
      }
  ;

index_type_specification_list:
    index_type_specification
  | index_type_specification_list ';' index_type_specification
      { $$ = chainon ($1, $3); yyerrok; }
  | index_type_specification_list error index_type_specification
      { error ("missing semicolon"); yyerrok; }
  | index_type_specification_list ';' error
  ;

index_type_specification:
    new_identifier LEX_RANGE new_identifier ':' typename
      { TREE_TYPE (($$ = build_tree_list ($1, $3))) = $5; }
  ;

open_array:
    p_array p_of typename_or_untyped_file
      { TREE_TYPE (($$ = build_tree_list (NULL_TREE, NULL_TREE))) = $3; }
  ;

typename_or_untyped_file:
    typename
  | untyped_file
  ;

/* Statements */

compound_statement:
    p_begin pushlevel statement_sequence poplevel p_end
      { yyerrok; }
  ;

statement_sequence:
    optional_statement_vd
  | statement_sequence ';' optional_statement_vd
      { yyerrok; }
  ;

optional_statement_vd:
    /* empty */
  | statement
  | p_var
      { chk_dialect ("variable declarations in the statement part are", GNU_PASCAL); pushlevel_expand (1); }
    variable_declaration
      { un_initialize_block ($3, 0, 0); }
    optional_statement_vd
  ;

optional_statement:
    empty_lte
      { $$ = 0; }
  | statement
      { $$ = 1; }
  ;

empty_lte:
    %prec prec_lower_than_error
  ;

statement:
      { mark_temporary_levels (); }
    statement_1
      { release_temporary_levels (); }
  ;

statement_1:
    set_label
  | set_label unlabelled_statement
  | unlabelled_statement
  ;

/* The condition of `repeat' and `while' loops must be within the pushlevel
   in case it creates temporary variables (fjf419b.pas). */

unlabelled_statement:
    compound_statement
  | start_of_assignment_or_call
      { expand_call_statement ($1); }
  | start_of_assignment_or_call
      { $<itype>$ = allow_function_calls (!PASCAL_PROCEDURAL_TYPE (TREE_TYPE ($1))); }
    assign expression
      { expand_pascal_assignment ($1, $4); allow_function_calls ($<itype>2); }
  | p_Return
      { build_predef_call (p_Return, NULL_TREE); }
  | p_Return expression
      { build_predef_call (p_Return, build_tree_list (NULL_TREE, $2)); }
  | p_Exit
      { build_predef_call (p_Exit, NULL_TREE); }
  | p_Exit '(' p_program ')'
      { build_predef_call (p_Exit, build_tree_list (NULL_TREE, void_type_node)); }
  | p_Exit '(' id ')'
      { build_predef_call (p_Exit, build_tree_list (NULL_TREE, $3)); }
  | p_Exit '(' id '.' id ')'
      { build_predef_call (p_Exit, build_tree_list ($3, $5)); }
  | builtin_procedure_statement
  | p_with with_list p_do pushlevel optional_statement poplevel
      { restore_identifiers ($2); }
  | if_then %prec prec_if
      { expand_end_cond (); }
  | if_then p_else
      { expand_start_else (); }
    pushlevel optional_statement poplevel
      {
        if (!$5 && extra_warnings)
          gpc_warning ("empty statement after `else'");
        expand_end_cond ();
      }
  | p_case expression p_of
      { $<ttype>$ = pascal_expand_start_case ($2); }
    optional_case_element_list
      {
        if (!EM (current_case_values))
          {
            tree duplicate;
            int res = pushcase (NULL_TREE, NULL, build_decl (LABEL_DECL, NULL_TREE, NULL_TREE), &duplicate);
            gcc_assert (!res);
          }
      }
    optional_case_completer p_end
      {
        if (!$5 && !$7)
          chk_dialect ("empty `case' statements are", MAC_PASCAL);
        expand_exit_something ();
        if (!EM (current_case_values))
          expand_end_case ($2);
        current_case_values = $<ttype>4;
        yyerrok;
      }
  | p_repeat
      { emit_nop (); expand_start_loop_continue_elsewhere (1); }
    pushlevel statement_sequence p_until
      { LOCATION_NOTE (@5); expand_loop_continue_here (); }
    expression
      { LOCATION_NOTE (@7); expand_exit_loop_if_false (0, build_pascal_unary_op (TRUTH_NOT_EXPR, check_boolean ($7))); }
    poplevel
      { expand_end_loop (); }
  | p_while
      { expand_start_loop (1); }
    pushlevel expression
      { LOCATION_NOTE (@4); expand_exit_loop_if_false (0, check_boolean ($4)); }
    p_do optional_statement poplevel
      { expand_end_loop (); }
  | p_for variable_or_routine_access assign expression for_direction expression
      { $<ttype>$ = start_for_loop ($2, $4, $6, $5); }
    p_do pushlevel optional_statement poplevel
      { LOCATION_NOTE (@5); finish_for_loop ($<ttype>7, $5); }
  | p_for variable_or_routine_access p_in expression
      { $<ttype>$ = start_for_set_loop ($2, $4); }
    p_do pushlevel optional_statement poplevel
      { LOCATION_NOTE (@3); finish_for_set_loop ($2, $<ttype>5); }
  | p_goto label
      { pascal_expand_goto ($2); }
  ;

set_label:
    label ':'
      { set_label ($1); }
  ;

with_list:
    with_variable
  | with_list ',' with_variable
      { $$ = chainon ($3, $1); yyerrok; }
  | error
      { $$ = NULL_TREE; }
  | with_list error with_variable
      { $$ = chainon ($3, $1); error ("missing comma"); yyerrok; }
  | with_list ',' error
      { error ("extra comma"); }
  ;

with_variable:
    expression
      { $$ = pascal_shadow_record_fields ($1, NULL_TREE); }
  | expression ':' new_identifier
      { $$ = pascal_shadow_record_fields ($1, $3); }
  ;

if_then:
    p_if expression p_then
      { expand_start_cond (check_boolean ($2), 0); }
    pushlevel optional_statement poplevel
      {
        if (!$6 && extra_warnings)
          gpc_warning ("empty statement after `then'");
      }
  ;

optional_case_completer:
    /* empty */
      {
        /* Create an implicit `otherwise' (in the rule above) to avoid warnings
           about unhandled cases. In ISO Pascal, this is a run-time error. */
        if (co->case_value_checking)
          build_predef_call (p_CaseNoMatchError, NULL_TREE);
        $$ = 0;
      }
  | otherwise pushlevel statement_sequence poplevel
      { $$ = 1; }
  ;

otherwise:
    p_else
      { chk_dialect ("`else' in `case' statements is", B_D_M_PASCAL); }
  | p_otherwise
  ;

optional_case_element_list:
    /* empty */
      { $$ = 0; }
  | case_element_list optional_semicolon
      { $$ = 1; }
  ;

case_element_list:
    case_element
  | case_element_list ';' case_element
      { yyerrok; }
  | error
      { error ("case element expected"); }
  | case_element_list error case_element
      { error ("missing semicolon"); yyerrok; }
  | case_element_list ';' error
      { error ("extra semicolon"); }
  ;

case_element:
    case_constant_list ':'
      { pascal_pushcase ($1); }
    pushlevel optional_statement poplevel
      { expand_exit_something (); }
  ;

case_constant_list:
    one_case_constant
  | case_constant_list ',' one_case_constant
      { $$ = chainon ($1, $3); yyerrok; }
  | case_constant_list ',' error
      { error ("extra comma"); }
  | case_constant_list error one_case_constant
      { $$ = chainon ($1, $3); error ("missing comma"); yyerrok; }
  | case_constant_list error
  ;

one_case_constant:
    static_expression %prec prec_lower_than_error
      { $$ = build_tree_list (NULL_TREE, $1); }
  | static_expression LEX_RANGE static_expression
      { chk_dialect ("`case' ranges are", NOT_CLASSIC_PASCAL); $$ = build_tree_list ($3, $1); }
  | static_expression error static_expression
      { $$ = build_tree_list ($3, $1); error ("missing `..'"); yyerrok; }
  | static_expression LEX_RANGE error
      { error ("extra `..'"); $$ = build_tree_list (NULL_TREE, string_may_be_char ($1, 0)); }
  ;

for_direction:
    p_to
      { $$ = LE_EXPR; }
  | p_downto
      { $$ = GE_EXPR; }
  | error
      { error ("missing `to' or `downto'"); $$ = LE_EXPR; }
  ;

start_of_assignment_or_call:
    variable_or_routine_access
  | '@' variable_or_routine_access
      { $$ = build_pascal_lvalue_address_expression ($2); }
  ;

assign:
    LEX_ASSIGN
  | equals
      { error ("using `=' instead of `:=' in assignment"); }
  ;

builtin_procedure_statement:
    builtin_proc builtin_actual_parameter_list
      { build_predef_call ($1, $2); }
  | LEX_BUILTIN_PROCEDURE_WRITE
      { build_predef_call (IDENTIFIER_BUILT_IN_VALUE ($1)->symbol, NULL_TREE); }
  | LEX_BUILTIN_PROCEDURE_WRITE '(' write_actual_parameter_list ')'
      { build_predef_call (IDENTIFIER_BUILT_IN_VALUE ($1)->symbol, $3); yyerrok; }
  | p_Dispose '(' expression ')'
      { build_new_dispose (p_Dispose, $3, NULL_TREE, NULL_TREE); }
  | p_Dispose '(' expression ',' actual_parameter_list ')' %dprec 1
      { build_new_dispose (p_Dispose, $3, NULL_TREE, $5); }
  | p_Dispose '(' expression ',' new_identifier builtin_actual_parameter_list ')' %dprec 2
      { build_new_dispose (p_Dispose, $3, $5, $6); }
  | p_asm asm_qualifier '(' string_constants ')'
      { pascal_expand_asm_operands ($4, NULL_TREE, NULL_TREE, NULL_TREE, $2); }
  | p_asm asm_qualifier '(' string_constants ':' asm_operands ')'
      { pascal_expand_asm_operands ($4, $6, NULL_TREE, NULL_TREE, $2); }
  | p_asm asm_qualifier '(' string_constants ':' asm_operands ':' asm_operands ')'
      { pascal_expand_asm_operands ($4, $6, $8, NULL_TREE, $2); }
  | p_asm asm_qualifier '(' string_constants ':' asm_operands ':' asm_operands ':' asm_clobbers ')'
      { pascal_expand_asm_operands ($4, $6, $8, $10, $2); }
  ;

asm_qualifier:
    /* empty */
      { $$ = 0; }
  | LEX_ID
      { ASSERT_ID ($1, @1, p_volatile); $$ = 1; }
  ;

asm_operands:
    null
  | nonempty_asm_operands
  ;

nonempty_asm_operands:
    asm_operand
  | nonempty_asm_operands ',' asm_operand
      { $$ = chainon ($1, $3); }
  ;

asm_operand:
    combined_string '(' expression ')'
      { $$ = build_tree_list ($1, $3); }
  ;

asm_clobbers:
    combined_string
      { $$ = build_tree_list (NULL_TREE, $1); }
  | asm_clobbers ',' combined_string
      { $$ = tree_cons (NULL_TREE, $3, $1); }
  ;

/* Expressions */

static_expression:
    expression
      {
        $$ = string_may_be_char ($1, 0);
        if (PEDANTIC (NOT_CLASSIC_PASCAL)
            && ( PASCAL_CST_PARENTHESES ($$)
                 || !(TREE_CODE ($$) == STRING_CST
                      || (TREE_CODE_CLASS (TREE_CODE ($$)) == tcc_constant
                          && PASCAL_CST_FRESH ($$)))))
          error ("ISO 7185 Pascal allows only simple constants");
      }
  ;

expression:
    simple_expression
      { $$ = fold ($1); }
  | simple_expression relational_operator simple_expression
      { $$ = fold (parser_build_binary_op ($2, $1, $3)); }
  ;

simple_expression:
    term
  | sign term
      { $$ = build_pascal_unary_op ($1, $2); }
  | simple_expression adding_operator term
      { $$ = parser_build_binary_op ($2, $1, $3); }
  | simple_expression pxsc_adding_operator term
      { $$ = build_operator_call ($2, $1, $3, 1); }
  | simple_expression or_operator
      { $<ttype>$ = start_boolean_binary_op ($2, $1); }
    term
      { if ($<ttype>3) LOCATION_NOTE (COPYLOC (@$, @4)); $$ = finish_boolean_binary_op ($2, $1, $4, $<ttype>3); }
  ;

term:
    factor
  | term multiplying_operator factor
      { $$ = parser_build_binary_op ($2, $1, $3); }
  | term pxsc_multiplying_operator factor
      { $$ = build_operator_call ($2, $1, $3, 1); }
  | term and_operator
      { $<ttype>$ = start_boolean_binary_op ($2, $1); }
    factor
      { if ($<ttype>3) LOCATION_NOTE (COPYLOC (@$, @4)); $$ = finish_boolean_binary_op ($2, $1, $4, $<ttype>3); }
  ;

factor:
    primary
  | factor id primary
      { $$ = build_operator_call ($2, $1, $3, 0); }
  | primary p_pow primary
      { $$ = parser_build_binary_op (POW_EXPR, $1, $3); }
  | primary LEX_POWER primary
      { $$ = parser_build_binary_op (POWER_EXPR, $1, $3); }
  | factor p_is typename
      { $$ = build_is_as ($1, $3, p_is); }
  | factor p_as typename
      { $$ = build_is_as ($1, $3, p_as); }
  ;

primary:
    unary_operator primary
      { $$ = set_exp_original_code (build_pascal_unary_op ($1, $2), $1); }
  | '@' primary
      { chk_dialect ("the address operator is", B_D_M_PASCAL); $$ = build_pascal_address_expression ($2, !co->typed_address); }
  | combined_string
  | unsigned_number
  | p_nil
      { $$ = null_pointer_node; }
  | set_constructor
  | variable_or_routine_access
      { $$ = build_variable_or_routine_access ($1); }
  ;

unsigned_number:
    LEX_INTCONST
  | LEX_INTCONST_BASE
  | LEX_REALCONST
  ;

optional_combined_string:
    null
  | combined_string
  ;

combined_string:
    string_constants
      { $$ = combine_strings ($1, 1); }
  ;

string_constants:
    string_constant
      { $$ = build_tree_list (NULL_TREE, $1); }
  | string_constants string_constant
      { $$ = chainon ($1, build_tree_list (NULL_TREE, $2)); }
  ;

string_constant:
    LEX_STRCONST
  | LEX_CARET_WHITE
  | '^' caret_chars
      { $$ = build_caret_string_constant ($<itype>2); }
  ;

caret_chars:
    LEX_CARET_LETTER
  | ',' | '.' | ':' | ';' | '(' | ')' | '[' | ']'
  | '+' | '-' | '*' | '/' | '<' | '=' | '>' | '@' | '^'
  ;

typename_or_string255:
    typename
      {
        if (PASCAL_TYPE_UNDISCRIMINATED_STRING ($$))
          {
            if (!(co->pascal_dialect & B_D_M_PASCAL))
              error_or_warning (co->pascal_dialect & E_O_PASCAL, "missing string capacity -- assuming 255");
            $$ = string255_type_node;
          }
      }
  ;

typename:
    typename_1
      {
        tree decl = lookup_name ($1);
        $$ = error_mark_node;
        if (!decl)
          error ("unknown identifier `%s'", IDENTIFIER_NAME ($1));
        else if (TREE_CODE (decl) != TYPE_DECL)
          error ("type name expected, `%s' given", IDENTIFIER_NAME ($1));
        else
          $$ = TREE_TYPE (decl);
      }
  ;

typename_1:
    id
  | id '.' id
      { $$ = build_qualified_id ($1, $3); }
  ;

variable_or_routine_access:
    LEX_BUILTIN_FUNCTION builtin_actual_parameter_list
      { $$ = build_predef_call (IDENTIFIER_BUILT_IN_VALUE ($1)->symbol, $2); }
  | variable_or_routine_access_no_builtin_function
  ;

variable_or_routine_access_no_builtin_function:
    identifier
  | untyped_file
      { $$ = TYPE_NAME ($1); }
  | '(' expression ')'
      { $$ = set_exp_original_code ($2, NOP_EXPR); }
  | variable_or_routine_access '.' new_identifier
      { $$ = build_qualified_or_component_access ($1, $3); }
  | variable_or_routine_access pointer_char
      { $$ = build_pascal_pointer_reference ($1); }
  | variable_or_routine_access '[' index_expression_list ']' %dprec 1
      { $$ = build_array_ref_or_constructor ($1, $3); }
  | variable_or_routine_access '[' structured_constructor_list ']' %dprec 2
      { $$ = build_iso_constructor ($1, nreverse ($3)); }
  | variable_or_routine_access_no_builtin_function '(' ')'
      { chk_dialect ("empty parentheses are", BORLAND_DELPHI | MAC_PASCAL); $$ = build_call_or_cast ($1, NULL_TREE); }
  | variable_or_routine_access_no_builtin_function '(' disable_function_calls actual_parameter_list ')'
      { allow_function_calls ($<itype>3); $$ = build_call_or_cast ($1, $4); }
  | p_inherited new_identifier
      { $$ = build_inherited_method ($2); }
  | p_FormatString '(' write_actual_parameter_list ')'
      { $$ = build_predef_call (p_FormatString, $3); }
  | p_StringOf '(' write_actual_parameter_list ')'
      { $$ = build_predef_call (p_StringOf, $3); }
  | p_Assigned '(' disable_function_calls expression ')'
      { $$ = build_predef_call (p_Assigned, build_tree_list (NULL_TREE, $4)); allow_function_calls ($<itype>2); }
  | p_Addr '(' variable_or_routine_access ')'
      { $$ = build_pascal_address_expression ($3, co->pascal_dialect & B_D_M_PASCAL); }
  | p_New '(' variable_or_routine_access ')'
      { $$ = build_new_dispose (p_New, $3, NULL_TREE, NULL_TREE); }
  | p_New '(' variable_or_routine_access ',' actual_parameter_list ')' %dprec 1
      { $$ = build_new_dispose (p_New, $3, NULL_TREE, $5); }
  | p_New '(' variable_or_routine_access ',' new_identifier builtin_actual_parameter_list ')' %dprec 2
      { $$ = build_new_dispose (p_New, $3, $5, $6); }
  ;

builtin_actual_parameter_list:
    null
  | '(' disable_function_calls actual_parameter_list ')' %dprec 1
      { $$ = $3; allow_function_calls ($<itype>1); yyerrok; }
  | '(' disable_function_calls variable_or_routine_access ')' %dprec 2
      {
        $$ = build_tree_list (NULL_TREE, TREE_CODE ($3) == TYPE_DECL ? $3 : build_variable_or_routine_access ($3));
        allow_function_calls ($<itype>1);
        yyerrok;
      }
  ;

disable_function_calls:
      { $$ = allow_function_calls (0); }
  ;

actual_parameter_list:
    expression
      { $$ = build_tree_list (NULL_TREE, $1); }
  | actual_parameter_list ',' expression
      { $$ = chainon ($1, build_tree_list (NULL_TREE, $3)); yyerrok; }
  | error
      { $$ = build_tree_list (NULL_TREE, error_mark_node); }
  | actual_parameter_list ',' error
      { $$ = build_tree_list (NULL_TREE, error_mark_node); error ("extra comma"); }
  ;

write_actual_parameter_list:
    write_actual_parameter
  | write_actual_parameter_list ',' write_actual_parameter
      { $$ = chainon ($1, $3); yyerrok; }
  | write_actual_parameter_list error write_actual_parameter
      { $$ = chainon ($1, $3); error ("missing comma"); yyerrok; }
  | write_actual_parameter_list ',' error
      { error ("extra comma"); }
  ;

/* `:' specifiers are represented as a list in TREE_PURPOSE of each actual parameter. */
write_actual_parameter:
    expression
      { $$ = build_tree_list (NULL_TREE, $1); }
  | expression ':' expression
      { $$ = build_tree_list (build_tree_list (NULL_TREE, $3), $1); }
  | expression ':' expression ':' expression
      { $$ = build_tree_list (build_tree_list ($5, $3), $1); }
  ;

untyped_file:
    p_file
      { chk_dialect ("untyped files are", U_B_D_M_PASCAL); $$ = untyped_file_type_node; }
  ;

structured_constructor_list:
    field_value_list optional_semicolon
  | field_value_list ';' variant_part_value
      { $$ = chainon ($3, $1); }
  | field_value_list optional_semicolon array_value_completer
      { TREE_CHAIN (($$ = $3)) = $1; }
  | variant_part_value
  | array_value_completer
  ;

field_value_list:
    field_value
  | field_value_list ';' field_value
      { TREE_CHAIN (($$ = $3)) = $1; }
  ;

field_value:
    index_expression_list ':' component_value
      { $$ = build_tree_list ($1, $3); }
  | component_value
      { $$ = build_tree_list (NULL_TREE, $1); }
  ;

variant_part_value:
    p_case new_identifier ':' expression p_of variant_part_value0
      { $$ = chainon ($6, build_tree_list (build_tree_list (NULL_TREE, $2), $4)); }
  | p_case expression p_of variant_part_value0
      { $$ = chainon ($4, build_tree_list (build_tree_list (NULL_TREE, integer_zero_node), $2)); }
  ;

variant_part_value0:
    '[' structured_constructor_list ']' optional_semicolon
      { $$ = $2; }
  ;

array_value_completer:
    p_otherwise component_value optional_semicolon
      { $$ = build_tree_list (build_tree_list (NULL_TREE, NULL_TREE), $2); }
  ;

component_value:
    expression %dprec 1
      { $$ = maybe_schema_discriminant ($1); }
  | '(' ')'
      { $$ = NULL_TREE; }
  | '(' bp_constructor_list ')' %dprec 2
      { PASCAL_BP_INITIALIZER_LIST (($$ = nreverse ($2))) = 1; }
  | '[' structured_constructor_list ']' %dprec 2
      { $$ = nreverse ($2); }
  | '[' error ']'
      { error ("invalid component value"); $$ = error_mark_node; }
  ;

bp_constructor_list:
    bp_field_value
  | bp_constructor_list initializer_separator bp_field_value
      { TREE_CHAIN (($$ = $3)) = $1; }
  | bp_constructor_list error bp_field_value
      { TREE_CHAIN (($$ = $3)) = $1; error ("missing separator"); }
  ;

initializer_separator:
    ';'
  | ','
      { chk_dialect ("initializers separated with `,' are", B_D_M_PASCAL); }
  ;

bp_field_value:
    index_expression_item ':' component_value
      { $$ = build_tree_list ($1, $3); }
  | component_value
      { $$ = build_tree_list (NULL_TREE, $1); }
  ;

index_expression_list:
    index_expression_item
  | index_expression_list ',' index_expression_item
      { $$ = chainon ($1, $3); yyerrok; }
  | error
      { error ("missing index expression"); $$ = NULL_TREE; }
  | index_expression_list error index_expression_item
      { $$ = chainon ($1, $3); error ("missing comma"); yyerrok; }
  | index_expression_list ',' error
      { error ("extra comma"); }
  ;

index_expression_item:
    new_identifier %dprec 2
      { $$ = build_tree_list ($1, NULL_TREE); }
  | expression %dprec 1
      { $$ = build_tree_list (string_may_be_char ($1, 1), NULL_TREE); }
  | expression LEX_RANGE expression
      { $$ = build_tree_list (string_may_be_char ($1, 1), string_may_be_char ($3, 1)); }
  ;

set_constructor:
    '[' ']'
      { $$ = build_set_constructor (NULL_TREE); }
  | '[' set_constructor_element_list ']'
      { $$ = build_set_constructor (nreverse ($2)); }
  ;

set_constructor_element_list:
    member_designator
  | set_constructor_element_list ',' member_designator
      { TREE_CHAIN (($$ = $3)) = $1; yyerrok; }
  | set_constructor_element_list error member_designator
      { TREE_CHAIN (($$ = $3)) = $1; error ("missing comma"); yyerrok; }
  | set_constructor_element_list ',' error
      { error ("extra comma"); }
  ;

member_designator:
    expression
      { $$ = build_tree_list ($1, NULL_TREE); }
  | expression LEX_RANGE expression
      { $$ = build_tree_list ($1, $3); }
  ;

/* Operators */

sign:
    '+' { $$ = CONVERT_EXPR; }
  | '-' { $$ = NEGATE_EXPR; }
  ;

unary_operator:
    LEX_BPPLUS  { $$ = CONVERT_EXPR; }
  | LEX_BPMINUS { $$ = NEGATE_EXPR; }
  | p_not       { $$ = TRUTH_NOT_EXPR; }
  ;

relational_operator:
    LEX_NE { $$ = NE_EXPR; }
  | LEX_LE { $$ = LE_EXPR; }
  | LEX_GE { $$ = GE_EXPR; }
  | '='    { $$ = EQ_EXPR; }
  | '<'    { $$ = LT_EXPR; }
  | '>'    { $$ = GT_EXPR; }
  | p_in   { $$ = IN_EXPR; }
  ;

adding_operator:
    '+'         { $$ = PLUS_EXPR; }
  | LEX_BPPLUS  { $$ = PLUS_EXPR; }
  | '-'         { $$ = MINUS_EXPR; }
  | LEX_BPMINUS { $$ = MINUS_EXPR; }
  | p_xor       { $$ = TRUTH_XOR_EXPR; }
  | LEX_SYMDIFF { $$ = SYMDIFF_EXPR; }
  ;

multiplying_operator:
    '*'   { $$ = MULT_EXPR; }
  | '/'   { $$ = RDIV_EXPR; }
  | p_div { $$ = TRUNC_DIV_EXPR; }
  | p_mod { $$ = (co->pascal_dialect & B_D_M_PASCAL) ? TRUNC_MOD_EXPR : FLOOR_MOD_EXPR; }
  | p_shl { $$ = LSHIFT_EXPR; }
  | p_shr { $$ = RSHIFT_EXPR; }
  ;

or_operator:
    p_or        { $$ = TRUTH_OR_EXPR; }
  | p_or p_else { $$ = TRUTH_ORIF_EXPR; chk_dialect ("`or else' (without underscore) is", GNU_PASCAL); }
  | p_or_else   { $$ = TRUTH_ORIF_EXPR; }
  | '|'         { $$ = TRUTH_ORIF_EXPR; chk_dialect ("`|' is", MAC_PASCAL); }
  ;

and_operator:
    p_and        { $$ = TRUTH_AND_EXPR; }
  | p_and p_then { $$ = TRUTH_ANDIF_EXPR; chk_dialect ("`and then' (without underscore) is", GNU_PASCAL); }
  | p_and_then   { $$ = TRUTH_ANDIF_EXPR; }
  | '&'          { $$ = TRUTH_ANDIF_EXPR; chk_dialect ("`&' is", MAC_PASCAL); }
  ;

builtin_proc:
    LEX_BUILTIN_PROCEDURE
      { $$ = IDENTIFIER_BUILT_IN_VALUE ($1)->symbol; }
  /* operators used as "procedures" */
  | p_and { $$ = p_and; }
  | p_or  { $$ = p_or; }
  | p_not { $$ = p_not; }
  | p_xor { $$ = p_xor; }
  | p_shl { $$ = p_shl; }
  | p_shr { $$ = p_shr; }
  ;

/* Don't use identifiers like `Plus' for symbols which would set a
   strange spelling for a possible such user-defined identifier. */
operator_symbol:
    '+'         { $$ = get_identifier_with_spelling ("BPlus", "+"); }
  | LEX_BPPLUS  { $$ = get_identifier_with_spelling ("BPlus", "+"); }
  | '-'         { $$ = get_identifier_with_spelling ("BMinus", "-"); }
  | LEX_BPMINUS { $$ = get_identifier_with_spelling ("BMinus", "-"); }
  | '*'         { $$ = get_identifier_with_spelling ("BMult", "*"); }
  | '/'         { $$ = get_identifier_with_spelling ("RDiv", "/"); }
  | p_div       { $$ = get_identifier ("Div"); }
  | p_mod       { $$ = get_identifier ("Mod"); }
  | LEX_POWER   { $$ = get_identifier_with_spelling ("RPower", "**"); }
  | p_in        { $$ = get_identifier ("In"); }
  | '<'         { $$ = get_identifier_with_spelling ("LT", "<"); }
  | equals      { $$ = get_identifier_with_spelling ("EQ", "="); }
  | '>'         { $$ = get_identifier_with_spelling ("GT", ">"); }
  | LEX_NE      { $$ = get_identifier_with_spelling ("NE", "<>"); }
  | LEX_GE      { $$ = get_identifier_with_spelling ("GE", ">="); }
  | LEX_LE      { $$ = get_identifier_with_spelling ("LE", "<="); }
  | p_and       { $$ = get_identifier ("And"); }
  | '&'         { $$ = get_identifier_with_spelling ("SAnd", "&"); }
  | p_or        { $$ = get_identifier ("Or"); }
  | '|'         { $$ = get_identifier_with_spelling ("SOr", "|"); }
  | LEX_SYMDIFF { $$ = get_identifier_with_spelling ("SymDiff", "<>"); }
  | pxsc_multiplying_operator
  | pxsc_adding_operator
  ;

pxsc_adding_operator:
    LEX_CEIL_PLUS   { $$ = get_identifier_with_spelling ("CeilPlus", "+>"); }
  | LEX_CEIL_MINUS  { $$ = get_identifier_with_spelling ("CeilMinus", "->"); }
  | LEX_FLOOR_PLUS  { $$ = get_identifier_with_spelling ("FloorPlus", "+<"); }
  | LEX_FLOOR_MINUS { $$ = get_identifier_with_spelling ("FloorMinus", "-<"); }
  ;

pxsc_multiplying_operator:
    LEX_CEIL_MULT  { $$ = get_identifier_with_spelling ("CeilMult", "*>"); }
  | LEX_CEIL_DIV   { $$ = get_identifier_with_spelling ("CeilRDiv", "/>"); }
  | LEX_FLOOR_MULT { $$ = get_identifier_with_spelling ("FloorMult", "*<"); }
  | LEX_FLOOR_DIV  { $$ = get_identifier_with_spelling ("FloorRDiv", "/<"); }
  ;

/* To avoid parse conflicts with `otherwise'. No need to check the dialect here,
   this happens already when the label is declared. */
label:
    num_label
  | id
  ;

num_label:
    LEX_INTCONST
      { $$ = numeric_label ($1); }
  ;

id_list:
    id_list1 %prec prec_lower_than_error
      { $$ = nreverse ($1); }
  ;

id_list1:
    new_identifier
      { $$ = build_tree_list (NULL_TREE, $1); }
  | id_list1 ',' new_identifier
      { $$ = tree_cons (NULL_TREE, $3, $1); }
  | id_list1 error new_identifier
      {
        $$ = tree_cons (NULL_TREE, $3, $1);
        error ("comma missing after `%s'", IDENTIFIER_NAME (TREE_VALUE ($1)));
        yyerrok;
      }
  | id_list1 ',' error
      { error ("extra comma following identifier list"); }
  | id_list1 error
  ;

id_list_limited:
    new_identifier
      { $$ = build_tree_list (NULL_TREE, $1); }
  | id_list_limited ',' new_identifier
      { $$ = tree_cons (NULL_TREE, $3, $1); }
  ;

new_quid:
    new_identifier
  | new_identifier '.' new_identifier
      { $$ = build_qualified_id ($1, $3); }
  ;

new_identifier:
    new_identifier_1
      { warn_about_keyword_redeclaration ($$, 1); }
  ;

new_identifier_1:
    id
  | LEX_BUILTIN_PROCEDURE
  | LEX_BUILTIN_PROCEDURE_WRITE
  | LEX_BUILTIN_FUNCTION
  | p_Return
  | p_Exit
  | p_Addr
  | p_Assigned
  | p_New
  | p_Dispose
  | p_FormatString
  | p_absolute
  | p_abstract
  | p_and_then
  | p_as
  | p_asm
  | p_asmname
  | p_attribute
  | p_bindable
  | p_c
  | p_c_language
  | p_class
  | p_constructor
  | p_destructor
  | p_external
  | p_finalization
  | p_implementation
  | p_import
  | p_inherited
  | p_initialization
  | p_is
  | p_object
  | p_only
  | p_operator
  | p_or_else
  | p_otherwise
  | p_pow
  | p_qualified
  | p_restricted
  | p_shl
  | p_shr
  | p_unit
  | p_uses
  | p_value
  | p_view
  | p_xor
  ;

identifier:
    id
      { $$ = check_identifier ($1); }
  ;

id:
    LEX_ID
  | caret_letter
  | p_far
  | p_forward
  | p_near
/* | p_overload */
  | p_override
  | p_reintroduce
  | p_virtual
  ;

caret_letter:
    LEX_CARET_LETTER
      { char c = $1; $$ = make_identifier (&c, 1); }
  ;

/* Support states */

pushlevel:
    /* empty */
      { pushlevel_expand (0); }
  ;

poplevel:
    /* empty */
      { poplevel_expand (0, 1); }
  ;

enable_lce:
    /* empty */
      { lex_const_equal = 0; }
  ;

packed:
    p_packed
      { defining_packed_type += $$ = !co->ignore_packed;  /* can be nested */ }
  ;

i_protected:
    LEX_ID
      { ASSERT_ID ($1, @1, p_protected); }
  ;

module:
    LEX_ID
      { ASSERT_ID ($1, @1, p_module); }
  ;

optional_semicolon:
    /* empty */
      { yyerrok; }
  | ';'
      { yyerrok; }
  ;

pointer_char:
    '^'
  | LEX_CARET_WHITE
  | '@'
  ;

equals:
    '='
  | LEX_CONST_EQUAL
  ;

dot_or_error:
    '.'
  | error
      { gpc_warning ("missing `.' at the end of program/unit/module"); }
  ;

null:
    /* empty */
      { $$ = NULL_TREE; }
  ;

err:
    error
      { $$ = error_mark_node; }
  ;

%%

/* Check the order of declarations for various standards */
static int
check_decl_order (int prev, int new)
{
  int prev_decl_order = prev / 2, prev_import = prev & 1;
  if (new == od_none)
    return prev;
  if (new <= prev_decl_order && new < od_routine)
    chk_dialect ("mixed order of declaration parts is", NOT_CLASSIC_PASCAL);
  if (new == od_uses)
    {
      if (prev_import)
        chk_dialect ("multiple `uses' parts are", GNU_PASCAL);
      if (prev_decl_order > od_uses)
        chk_dialect ("`uses' after other declarations is", GNU_PASCAL);
      prev_import = 1;
    }
  return (2 * new) | prev_import;
}

static void
locations (YYLTYPE *dest, const /*YYLTYPE*/ union yyGLRStackItem *src, int n)
{
  int i;
  for (i = n; i > 0 && !YYRHSLOC (src, i).first_line; i--) ;
  if (i == 0)
    {
      pascal_input_filename = compiler_filename;
      lineno = compiler_lineno;
      column = compiler_column;
      dest->first_file = dest->last_file = NULL;
      dest->first_line = dest->last_line = dest->first_column = dest->last_column = 0;
    }
  else
    {
      pascal_input_filename = compiler_filename =
          dest->last_file = YYRHSLOC (src, i).last_file;
      lineno = compiler_lineno = dest->last_line = YYRHSLOC (src, i).last_line;
      column = compiler_column = dest->last_column = YYRHSLOC (src, i).last_column;
      for (i = 1; i <= n && !YYRHSLOC (src, i).first_line; i++) ;
      dest->first_file = YYRHSLOC (src, i).first_file;
      dest->first_line = YYRHSLOC (src, i).first_line;
      dest->first_column = YYRHSLOC (src, i).first_column;
      /* This does emit a few line notes too many. But putting line notes in the
         parser in the right places causes some conflicts (especially
         assignments with nontrivial expressions on their left side are
         problematic). A better solution might be possible when we don't emit
         things so early. */
      if (current_function_decl)
#ifndef GCC_3_4
        emit_line_note (dest->first_file, dest->first_line);
#else
        {
          location_t loc_aux =
              pascal_make_location (dest->first_file, dest->first_line);
          emit_line_note (loc_aux);
        }
#endif
    }
  dest->option_id = 0;
  for (i = 1; i <= n; i++)
    while (YYRHSLOC (src, i).option_id > compiler_options->counter)
      {
        struct options *tmp = compiler_options;
        compiler_options = tmp->next;
        free (tmp);
      }
  if (compiler_options != co)
    activate_options (compiler_options, 0);
}

/* Set the value of the 'yydebug' variable to VALUE. This is a function
   so we don't have to have YYDEBUG defined in order to build the compiler. */
void
set_yydebug (int value)
{
#if YYDEBUG != 0
  yydebug = value;
#else
  gpc_warning ("YYDEBUG not defined.");
#endif
}

#undef yyparse
int
yyparse (void)
{
  int res;
  init_predef ();
  res = main_yyparse ();
#ifdef GCC_4_0
  /* @@@@@ cgraphunit do not notice if address of a routine is
     referenced from static global variable */
  {
    tree decl = getdecls();
    while (decl) 
      {
        if (TREE_CODE (decl) == FUNCTION_DECL && TREE_ADDRESSABLE (decl))
          mark_decl_referenced (decl);
        decl = TREE_CHAIN (decl);
      }
  }
  cgraph_finalize_compilation_unit ();
  cgraph_optimize ();
#endif
  return res;
}
