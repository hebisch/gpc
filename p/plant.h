/* Compatibility macros: redirect expand_* calls to plant.c.

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

#define expand_goto(x) plant_goto (x)
#define expand_label(x) plant_label (x)
#define expand_decl(x) plant_decl (x)
#define label_rtx(x)  0
#define emit_line_note(x) plant_line_note (x)
#define emit_nop() plant_nop()
#define expand_decl_init(x) plant_decl_init(x)
#define expand_function_start(x, y) plant_function_start (x, y)
#define expand_function_end() plant_function_end ()
#define expand_return(x) plant_return (x)
#define expand_null_return() plant_null_return ()
#define expand_start_cond(x, y) plant_start_cond (x, y)
#define expand_end_cond() plant_end_cond ()
#define expand_start_else() plant_start_else ()
#define expand_exit_something() plant_exit_something ()
#define expand_start_case(x, y, z, w) plant_start_case(x, y, z, w)
#define expand_end_case(x) plant_end_case (x)
#define expand_start_loop_continue_elsewhere(x) plant_start_loop (x)
#define expand_loop_continue_here() plant_loop_continue_here ()
#define expand_continue_loop(x) plant_continue_loop(x)
#define expand_exit_loop(x) plant_exit_loop(x)
#define expand_exit_loop_if_false(x, y) plant_exit_loop_if_false (x, y)
#define expand_end_loop() plant_end_loop ()
#define expand_start_loop(x) plant_start_loop (x)
#define expand_start_bindings(x) plant_start_bindings (x)
#define expand_end_bindings(x, y, z) plant_end_bindings (x, y, z)
#define expand_expr_stmt(x) plant_expr_stmt (x)
#define expand_asm plant_asm
#define expand_asm_operands(x, y, z, u, v, w) plant_asm_operands(x, y, z, u, v, w)

/* #define pushcase(x, y, z, w) plant_case(x, y, z, w) */


extern void clear_last_expr (void);

extern int
pushcase (tree value, tree (*converter) (tree, tree), tree label,
          tree *duplicate);

extern int
pushcase_range (tree value1, tree value2, tree (*converter) (tree, tree),
                tree label, tree *duplicate);

extern void plant_line_note (location_t loc);

extern void plant_decl (tree decl);

extern void plant_decl_init (tree decl);

extern void plant_nop (void);

extern void plant_goto (tree label);

extern void plant_label (tree label);

/* extern void plant_decl (tree decl); */

extern void plant_asm (tree string, int vol);

extern void plant_asm_operands (tree string, tree outputs,
      tree inputs, tree clobbers, int vol, location_t loc_aux);

extern void plant_function_start (tree decl, int i);

extern void plant_function_end (void);

extern void plant_return (tree result);

extern void plant_null_return (void);

extern void plant_start_cond (tree condition, int i);

extern void plant_end_cond (void);

extern void plant_start_else (void);

extern void plant_exit_something (void);

extern void plant_start_case (int exit_flag, tree expr, tree type,
                   const char *printname);

extern void plant_end_case (tree expr);

extern struct plant_nesting * plant_start_loop_continue_elsewhere (int i);

extern struct plant_nesting * plant_start_loop (int i);

extern void plant_loop_continue_here (void);

extern int plant_continue_loop (struct plant_nesting * loop);

extern int plant_exit_loop (struct plant_nesting * loop);

extern int plant_exit_loop_if_false (struct plant_nesting * loop, tree condition);

extern void plant_end_loop (void);

extern void plant_start_bindings (int flags);

extern void plant_end_bindings (tree vars, int mark_ends, int dont_jump_in);

extern void plant_expr_stmt (tree expr);

extern void plant_bind_block (tree block);
