/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002, 2003, 2004, 2005, 2006 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     prec_lower_than_error = 258,
     prec_if = 259,
     prec_import = 260,
     p_uses = 261,
     p_else = 262,
     p_and = 263,
     p_array = 264,
     p_begin = 265,
     p_case = 266,
     p_div = 267,
     p_do = 268,
     p_downto = 269,
     p_end = 270,
     p_file = 271,
     p_for = 272,
     p_function = 273,
     p_goto = 274,
     p_if = 275,
     p_in = 276,
     p_label = 277,
     p_mod = 278,
     p_nil = 279,
     p_not = 280,
     p_of = 281,
     p_or = 282,
     p_packed = 283,
     p_procedure = 284,
     p_to = 285,
     p_program = 286,
     p_record = 287,
     p_repeat = 288,
     p_set = 289,
     p_then = 290,
     p_type = 291,
     p_until = 292,
     p_var = 293,
     p_while = 294,
     p_with = 295,
     p_absolute = 296,
     p_abstract = 297,
     p_and_then = 298,
     p_as = 299,
     p_asm = 300,
     p_attribute = 301,
     p_bindable = 302,
     p_const = 303,
     p_constructor = 304,
     p_destructor = 305,
     p_external = 306,
     p_far = 307,
     p_finalization = 308,
     p_forward = 309,
     p_implementation = 310,
     p_import = 311,
     p_inherited = 312,
     p_initialization = 313,
     p_is = 314,
     p_near = 315,
     p_object = 316,
     p_only = 317,
     p_operator = 318,
     p_otherwise = 319,
     p_or_else = 320,
     p_pow = 321,
     p_qualified = 322,
     p_restricted = 323,
     p_shl = 324,
     p_shr = 325,
     p_unit = 326,
     p_value = 327,
     p_virtual = 328,
     p_xor = 329,
     p_asmname = 330,
     p_c = 331,
     p_c_language = 332,
     p_class = 333,
     p_override = 334,
     p_reintroduce = 335,
     p_view = 336,
     p_Addr = 337,
     p_Assigned = 338,
     p_Dispose = 339,
     p_Exit = 340,
     p_FormatString = 341,
     p_New = 342,
     p_Return = 343,
     p_StringOf = 344,
     LEX_INTCONST = 345,
     LEX_INTCONST_BASE = 346,
     LEX_STRCONST = 347,
     LEX_REALCONST = 348,
     LEX_BUILTIN_PROCEDURE = 349,
     LEX_BUILTIN_PROCEDURE_WRITE = 350,
     LEX_BUILTIN_FUNCTION = 351,
     LEX_ID = 352,
     LEX_CARET_WHITE = 353,
     LEX_CARET_LETTER = 354,
     LEX_ASSIGN = 355,
     LEX_RENAME = 356,
     LEX_RANGE = 357,
     LEX_ELLIPSIS = 358,
     LEX_CONST_EQUAL = 359,
     LEX_SYMDIFF = 360,
     LEX_NE = 361,
     LEX_GE = 362,
     LEX_LE = 363,
     LEX_POWER = 364,
     LEX_BPPLUS = 365,
     LEX_BPMINUS = 366,
     LEX_CEIL_PLUS = 367,
     LEX_CEIL_MINUS = 368,
     LEX_FLOOR_PLUS = 369,
     LEX_FLOOR_MINUS = 370,
     LEX_CEIL_MULT = 371,
     LEX_CEIL_DIV = 372,
     LEX_FLOOR_MULT = 373,
     LEX_FLOOR_DIV = 374
   };
#endif


/* Copy the first part of user declarations.  */
#line 63 "parse.y"

#define YYMAXDEPTH 200000
#include "gpc.h"
#ifdef GCC_4_0
#include "cgraph.h"
#endif


#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE 
#line 80 "parse.y"
{
  enum tree_code code;
  long itype;
  tree ttype;
}
/* Line 2604 of glr.c.  */
#line 182 "parse.h"
	YYSTYPE;
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{

  int first_line;
  int first_column;
  int last_line;
  int last_column;

} YYLTYPE;
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;

extern YYLTYPE yylloc;


