/*GNU Pascal compiler lexical analyzer

  Copyright (C) 1989-2006, Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>

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
#include "gpcpp.h"

#if !defined (HAVE_SIGALRM) && defined (SIGALRM)
#define HAVE_SIGALRM 1
#endif

#define LEX_SEMANTIC_VALUES 1
#define LEX_INVALID (-1)
#define LEX_WHITESPACE (-1)
#define LEX_COMMENT (-1)
#define LEX_COMMENT_BEGIN (-1)
#define LEX_COMMENT_CONTENT (-1)
#define LEX_COMMENT_END (-1)
#define LEX_DIRECTIVE_BEGIN (MIN_EXTRA_SYMBOL - 1)
#define LEX_DIRECTIVE_CONTENT (MIN_EXTRA_SYMBOL - 2)
#define LEX_DIRECTIVE_END (MIN_EXTRA_SYMBOL - 3)
int LEX_LINE_DIRECTIVE = MIN_EXTRA_SYMBOL - 4;
#define BITS_PER_BYTES 8
#define BYTES_PER_INTEGER 8
#define yyalloc xmalloc
#define yyrealloc xrealloc
#define YY_TYPEDEF_YY_SIZE_T
typedef size_t yy_size_t;
#include "pascal-lex.c"

/* USE_MAPPED_LOCATION */
#ifdef GCC_4_2
char * pascal_input_filename;
long lineno;
#endif

filename_t lexer_filename = NULL, compiler_filename = NULL;
int column = 0;
int lexer_lineno = 0, lexer_column = 0, compiler_lineno = 0, compiler_column = 0;
int syntax_errors = 0;

/* Determines what the lexer currently returns for `=':
   < 0 means: `='
   = 0 means: LEX_CONST_EQUAL
   > 0 means: `=', but after that many closing parentheses/brackets, return LEX_CONST_EQUAL */
int lex_const_equal = -1;

#ifdef EGCS
FILE *finput;
#endif

/* Newlines encountered in the preprocessed input (all files). */
static int preprocessed_lineno = 0;

static void handle_progress_messages (int);
static void do_directive (char *, int);

#ifdef GCC_3_4
location_t
pascal_make_location (const char * fname, long line)
{
#if !defined(GCC_4_2) || !defined(USE_MAPPED_LOCATION)
  location_t loc_aux;
  loc_aux.file = fname;
  loc_aux.line = line;
  return loc_aux;
#else
  UNKNOWN_LOCATION;
#endif
}
#endif

#ifdef HAVE_SIGALRM
/* Triggers for periodic progress output; set every
   PROGRESS_TIME_INTERVAL microseconds. */
#define PROGRESS_TIME_INTERVAL 200000  /* 5 Hz */
static volatile int progress_message_alarm = 0;
static void alarm_handler (int);

/* Called periodically for outputting status messages. */
static void alarm_handler (int sig)
{
  progress_message_alarm = 1;
  signal (sig, &alarm_handler);
#ifdef linux
  siginterrupt (sig, 0);
#endif
}
#endif

static void
handle_progress_messages (int ending)
{
  if (!ending)
    preprocessed_lineno++;
#ifdef HAVE_SIGALRM
  if (ending || progress_message_alarm)
    {
      if (flag_progress_messages)
        fprintf (stderr, "\001#progress# %s (%d)\n", pascal_input_filename,
                 lineno);
      if (flag_progress_bar)
        fprintf (stderr, "\001#progress-bar# %d\n", preprocessed_lineno);
      progress_message_alarm = 0;
    }
#else
  if (flag_progress_messages && (ending || (lineno % 16 == 0 && lineno > 0)))
    fprintf (stderr, "\001#progress# %s (%d)\n", pascal_input_filename, lineno);
  if (flag_progress_bar && (ending || preprocessed_lineno % 16 == 0))
    fprintf (stderr, "\001#progress-bar# %d\n", preprocessed_lineno);
#endif
}

void lex_error (const char *Msg, int Fatal)
{
  lineno = LexPos.Line;
  column = LexPos.Column;
  error (Msg);
  if (Fatal)
    exit (FATAL_EXIT_CODE);
}

void ExtraUserAction (const char *buf, unsigned int length)
{
  if (co->debug_source && length > 0)
    fwrite (buf, 1, length, stderr);
  if (flag_progress_messages || flag_progress_bar)
    while (length--)
      if (*buf++ == '\n')
        handle_progress_messages (0);
}

int CheckFeature (TLexFeatureIndex Feature, int Message)
{
  lineno = LexPos.Line;
  column = LexPos.Column;
  switch (Feature)
  {
    case DoubleQuotedStrings:
      if (!co->double_quoted_strings)
        error ("double quoted strings are a GNU Pascal extension");
      break;
    case MultilineStrings:
      chk_dialect ("line breaks in char and string constants are", GNU_PASCAL);
      break;
    case IntegersWithoutSeparator:
      if (PEDANTIC (B_D_M_PASCAL) || !co->pascal_dialect)
        error_or_warning (PEDANTIC (B_D_M_PASCAL), "missing white space after decimal integer constant");
      break;
    case IntegersBase:
      chk_dialect_name ("radix#value", E_O_PASCAL|SUN_PASCAL);
      break;
    case IntegersHex:
      chk_dialect ("hexadecimal numbers with `$' are", B_D_M_PASCAL);
      break;
    case RealsWithoutSeparator:
      if (PEDANTIC (B_D_M_PASCAL) || !co->pascal_dialect)
        error_or_warning (PEDANTIC (B_D_M_PASCAL), "missing white space after decimal real constant");
      break;
    case RealsWithDotOnly:
      if (!(co->pascal_dialect & B_D_PASCAL))
        error_or_warning (PEDANTIC (~C_E_O_PASCAL),
           "ISO Pascal requires a digit after the decimal point");
      break;
    case RealsWithoutExpDigits:
      error_or_warning (PEDANTIC (B_D_PASCAL), "real constant exponent has no digits");
      break;
    case CharConstantsHash:
      chk_dialect ("char constants with `#' are", B_D_M_PASCAL);
      break;
    case MixedComments:
      if (!co->mixed_comments)
        return 0;
      else if (Message && co->warn_mixed_comments)
        {
          gpc_warning ("comments starting with `(*' and ending with `}' or starting with");
          gpc_warning (" `{' and ending with `*)' are an obscure ISO Pascal feature");
        }
      break;
    case NestedComments:
      if (!co->nested_comments)
        {
          if (co->warn_nested_comments)
            gpc_warning ("comment opener found within a comment");
          return 0;
        }
      else if (Message && co->warn_nested_comments)
        gpc_warning ("nested comments are a GPC extension");
      break;
    case DelphiComments:
      if (!co->delphi_comments)
        error ("`//' comments are a Borland Delphi extension");
      break;
    case LF_MAX:
      /* nothing */ ;
  }
  return 1;
}

void
discard_input (void)
{
  while (getc (finput) != EOF) ;
}

/* Initialize the lexical analyzer. */
void
init_gpc_lex (const char *filename)
{
#ifdef HAVE_SIGALRM
  /* Periodically trigger the output of progress messages. */
  if (flag_progress_messages || flag_progress_bar)
    {
      static struct itimerval timerval = { { 0, PROGRESS_TIME_INTERVAL },
                                           { 0, PROGRESS_TIME_INTERVAL } };
      signal (SIGALRM, &alarm_handler);
#ifdef linux
      siginterrupt (SIGALRM, 0);
#endif
      setitimer (ITIMER_REAL, &timerval, 0);
    }
#endif
  lineno = column = 1;
  gcc_assert (filename);
  InitLex (filename, finput, 0);
}

static void
do_directive (char *s, int l)
{
  int is_whole_directive = 0, n;
  char in_string = 0, *p, *q;
  co = (struct options *) xmalloc (sizeof (struct options));
  memcpy (co, lexer_options, sizeof (struct options));
  lexer_options->next = co;
  lexer_options = co;
  co->counter++;
  if (l >= (n = strlen ("local")) && !strncmp (s, "local", n)
      && (s[n] == ' ' || s[n] == '\t' || s[n] == '\n'))
    {
      s[n] = 0;
      process_pascal_directive (s, n);
      s += n + 1;
      l -= n + 1;
    }
  for (p = q = s; p < s + l; p++)
    {
      int c = *p, is_white = c == ' ' || c == '\t' || c == '\n';
      if (in_string && c == in_string)
        in_string = 0;
      else if ((c == '"' || c == '\'') && !in_string && (p == s || p[-1] != '^'))
        in_string = c;
      else if (q == s && is_white)
        /* NOTHING */;
      else if (in_string || is_whole_directive || c != ',')
        {
          if (!in_string && !is_whole_directive && c >= 'A' && c <= 'Z')
            c += 'a' - 'A';
          *q++ = c;
          if (q - s == 2)
            is_whole_directive = is_white && (s[0] == 'm' || s[0] == 'l' || s[0] == 'r');
        }
      else
        {
          *q = 0;
          if (!process_pascal_directive (s, q - s))
            return;
          q = s;
        }
    }
  if (in_string)
    gpc_warning ("unterminated string in compiler directive");
  *q = 0;
  process_pascal_directive (s, q - s);
}

const char *old_input_filename;

void set_old_input_filename (const char *s)
{
  old_input_filename = save_string (s);
}

void
SetFileName (int v)
{
  pascal_input_filename = NewPos.SrcName;
#ifndef EGCS97
  if (!main_input_filename)
    main_input_filename = pascal_input_filename;
#endif
  if (v == 1)
    {
      /* Pushing to a new file. */
      struct file_stack *p = (struct file_stack *) xmalloc (sizeof (struct file_stack));
#ifndef GCC_3_4
      input_file_stack->line = LexPos.Line;
      p->name = pascal_input_filename;
#else
      p->location = pascal_make_location (old_input_filename, LexPos.Line);
#endif
      p->next = input_file_stack;
      input_file_stack = p;
      input_file_stack_tick++;
#ifdef EGCS97
      /* Can use backend only after initialization (see err1.pas) */
      if (main_input_filename)
        (*debug_hooks->start_source_file) (LexPos.Line, pascal_input_filename);
#else
      debug_start_source_file (pascal_input_filename);
#endif
    }
  else if (v == 2)
    {
      /* Popping out of a file. */
#ifndef GCC_3_4
      if (input_file_stack->next)
#else
      if (input_file_stack)
#endif
        {
          struct file_stack *p = input_file_stack;
          input_file_stack = p->next;
          input_file_stack_tick++;
#ifdef EGCS97
#ifndef GCC_3_4
          (*debug_hooks->end_source_file) (input_file_stack->line);
#else
#ifndef GCC_4_2
          (*debug_hooks->end_source_file) (p->location.line);
#endif
#endif
#else
          debug_end_source_file (input_file_stack->line);
#endif
          free (p);
        }
      else
        error ("#-lines for entering and leaving files don't match");
    }
#ifdef EGCS97
  if (!main_input_filename)
    main_input_filename = pascal_input_filename;
#endif
  /* Now that we've pushed or popped the input stack,
     update the name in the top element. */
#ifndef GCC_3_4
  if (input_file_stack)
    input_file_stack->name = pascal_input_filename;
#else
  old_input_filename = pascal_input_filename;
#endif
}

/* Parser error handling */
void
yyerror (const char *string)
{
  const char *s = LexSem.TokenString, *buf;
  int c0 = s ? (unsigned char) *s : 0;
#ifndef GCC_3_4
  if (!s)
    buf = "%s at end of input";
  else if (c0 < 0x20 || c0 >= 0x7f)
    buf = "%s before character #%i";
  else
    buf = "%s before `%s'";
  error_with_file_and_line (lexer_filename, lexer_lineno, buf, string, s, c0);
#else
  location_t loc_aux = pascal_make_location (lexer_filename, lexer_lineno);
  if (!s)
    buf = "%H%s at end of input";
  else if (c0 < 0x20 || c0 >= 0x7f)
    buf = "%H%s before character #%i";
  else
    buf = "%H%s before `%s'";
  error (buf, &loc_aux, string, s, c0);
#endif
  syntax_errors++;
}

void
yyerror_id (tree id, const YYLTYPE *location)
{
#ifndef GCC_3_4
  error_with_file_and_line (location->last_file, location->last_line,
                            "syntax error before `%s'", IDENTIFIER_NAME (id));
#else
  location_t loc_aux = 
     pascal_make_location (location->last_file, location->last_line);

  error ("%Hsyntax error before `%s'", &loc_aux, IDENTIFIER_NAME (id));
#endif
  syntax_errors++;
}

static int get_token (int);
static int get_token (int update_pos)
{
  int value;
  while ((value = lexscan ()) == LEX_DIRECTIVE_BEGIN)
    {
      /* Directives can be fragmented by nested comments. Reassemble them here. */
      int l = 0;
      char *d = NULL;
      while ((value = lexscan ()) == LEX_DIRECTIVE_CONTENT)
        {
          int n = LexSem.TokenStringLength;
          char *dn = alloca (l + n + 2);
          if (d)
            {
              memcpy (dn, d, l);
              dn[l++] = ' ';
            }
          memcpy (dn + l, LexSem.TokenString, n + 1);
          l += n;
          d = dn;
        }
      gcc_assert (value == LEX_DIRECTIVE_END);
      if (!d)
        error ("empty compiler directive");
      else
        do_directive (d, l);
      if (update_pos)  /* @@ kludge, until peek_token is removed */
        {
          yylloc.first_file = NewPos.SrcName;
          yylloc.first_line = NewPos.Line;
          yylloc.first_column = NewPos.Column;
        }
    }
  return value;
}

static int next_token = 0;

int
peek_token (int do_dir)
{
  if (!do_dir)
    {
      int value = get_token (0);
      if (value != LEX_LINE_DIRECTIVE)
        next_token = value;
      LEX_LINE_DIRECTIVE = -1;
      return 0;
    }
  if (!next_token)
    next_token = get_token (0);
  return next_token;
}

/* The main function of the lexical analyzer, as called from the parser. */
int
yylex (void)
{
#ifndef EGCS97
  int old_momentary = suspend_momentary ();
#endif
  static int last_token = 0;
  int value;

  pascal_input_filename = lexer_filename;
  lineno = lexer_lineno;
  column = lexer_column;
  activate_options (lexer_options, 1);
  yylloc.first_file = pascal_input_filename;
  yylloc.first_line = lineno;
  yylloc.first_column = column;

  if (next_token)
    {
      value = next_token;
      next_token = 0;
    }
  else
    value = get_token (1);

  lineno = NewPos.Line;
  column = NewPos.Column;

  switch (value)
  {
    case 0:
      LexSem.TokenString = NULL;
      handle_progress_messages (1);
      break;

    case LEX_STRCONST:
    case LEX_CARET_WHITE:
      yylval.ttype = build_string_constant (LexSem.StringValue, LexSem.StringValueLength, 1);
      break;

    case LEX_INTCONST:
    case LEX_INTCONST_BASE:
      {
        tree t, type;
        HOST_WIDE_INT *v = LexSem.IntegerValueBytes;
        /* This is simplified by the fact that our constant is always positive. */
#if HOST_BITS_PER_WIDE_INT <= 32
        t = build_int_2 ((v[3] << 24) + (v[2] << 16) + (v[1] << 8) + v[0],
                         (v[7] << 24) + (v[6] << 16) + (v[5] << 8) + v[4]);
#else
        t = build_int_2 ((v[7] << 56) + (v[6] << 48) + (v[5] << 40) + (v[4] << 32)
                       + (v[3] << 24) + (v[2] << 16) + (v[1] << 8) + v[0], 0);
#endif
        /* The type of "fresh" constants doesn't matter much. Use one that fits. */
        if (!INT_CST_LT_UNSIGNED (TYPE_MAX_VALUE (pascal_integer_type_node), t))
          type = pascal_integer_type_node;
        else if (!INT_CST_LT_UNSIGNED (TYPE_MAX_VALUE (pascal_cardinal_type_node), t))
          type = pascal_cardinal_type_node;
        else if (!INT_CST_LT_UNSIGNED (TYPE_MAX_VALUE (long_long_integer_type_node), t))
          type = long_long_integer_type_node;
        else
          type = long_long_unsigned_type_node;
#ifdef GCC_4_0
        t = build_int_cst_wide (type, 
                                TREE_INT_CST_LOW (t),
                                TREE_INT_CST_HIGH (t));
#else
        TREE_TYPE (t) = type;
#endif
        PASCAL_CST_FRESH (t) = 1;
        yylval.ttype = t;
        break;
      }

    case LEX_REALCONST:
      {
        tree t, type = long_double_type_node;
        int esign = 1, expon = 0, adjust_exp = 0, zero = 0;
        const char *p = LexSem.TokenString;
        char *d = (char *) alloca (LexSem.TokenStringLength + 64), *q = d;
        REAL_VALUE_TYPE rval;
        while (*p == '0')
          p++;
        if (*p == '.')
          {
            /* Compress out the leading zeros by adjusting the exponent */
            do adjust_exp--; while (*++p == '0');
            if (*p < '0' || *p > '9')
              {
                *q++ = '0';  /* zero */
                zero = 1;
              }
            else
              {
                *q++ = *p++;
                *q++ = '.';
              }
          }
        if (!zero)
          {
            while ((*p >= '0' && *p <= '9') || *p == '.')
              *q++ = *p++;
            if (q > d && q[-1] == '.')
              *q++ = '0';
            /* Only valid numbers should get here. */
            while (*p)
              {
                if (*p >= '0' && *p <= '9')
                  expon = 10 * expon + *p - '0';
                else if (*p == '-')
                  esign = -1;
                p++;
              }
            expon = esign * expon + adjust_exp;
            if (expon)
              {
                char *r;
                int e;
                *q++ = 'E';
                if (expon < 0)
                  {
                    *q++ = '-';
                    expon = -expon;
                  }
                e = expon;
                do q++, e /= 10; while (e);
                r = q;
                do *--r = expon % 10 + '0', expon /= 10; while (expon);
              }
          }
        *q = 0;
        rval = REAL_VALUE_ATOF (d, TYPE_MODE (type));
        t = build_real (type, rval);
        if (REAL_VALUE_ISINF (rval))
          error ("real constant out of range");
        TREE_TYPE (t) = type;
        PASCAL_CST_FRESH (t) = 1;
        yylval.ttype = t;
        break;
      }

    case LEX_ID:
      {
        tree id = make_identifier (LexSem.TokenString, LexSem.TokenStringLength);
        struct predef *pd = IDENTIFIER_BUILT_IN_VALUE (id);
        int declared;
        yylval.ttype = id;

        /* With `-pedantic' warn about any dialect specific keyword encountered.
           At this point we don't know yet if it will be used as a keyword or an
           identifier, but it doesn't matter. Both usages are not completely
           portable. (That's `-pedantic' at its best! ;-) */
        if (pedantic && pd && (pd->kind == bk_none || pd->kind == bk_keyword) && pd->dialect != ANY_PASCAL)
          warn_about_keyword_redeclaration (id, 0);

        if (PASCAL_PENDING_DECLARATION (id))
          declared = 1;
        else
          {
            tree t = IDENTIFIER_VALUE (id);
            if (t)
              declared = !(TREE_CODE (t) == OPERATOR_DECL && PASCAL_BUILTIN_OPERATOR (t));
            else
              {
                for (t = current_type_list; t && TREE_VALUE (t) != id; t = TREE_CHAIN (t));
                declared = t != NULL_TREE;
              }
          }

        if (PD_ACTIVE (pd) && (!declared || (pd->kind == bk_keyword 
             && !(pd->attributes & KW_WEAK))))
          {
            switch (pd->kind)
            {
              case bk_none:
              /* handled in module.c */
              case bk_interface:
              /* handled in lookup_name */
              case bk_const:

              case bk_type:
              case bk_var:
                break;

              case bk_keyword:
              case bk_special_syntax:
                value = pd->symbol;
                break;

              case bk_routine:
                if (pd->signature[0] == '-')
                  value = LEX_BUILTIN_PROCEDURE;
                else if (pd->signature[0] == '>')
                  value = LEX_BUILTIN_PROCEDURE_WRITE;
                else
                  value = LEX_BUILTIN_FUNCTION;
                break;

              default:
                gcc_unreachable ();
            }
            if (value != LEX_ID && pd->user_disabled >= 0)
              chk_dialect_name (IDENTIFIER_NAME (id), pd->dialect);
          }
        break;
      }

    default:
      yylval.itype = LexSem.TokenString[0];  /* for `caret_chars' */
  }

  /* `+' and `-' have different precedence in BP than in Pascal.
     To handle this we have to use different tokens. */
  if (co->pascal_dialect & B_D_M_PASCAL)
    switch (value)
    {
      case '+': value = LEX_BPPLUS;  break;
      case '-': value = LEX_BPMINUS; break;
    }

  if (value == ';' && co->warn_semicolon)
    switch (last_token)
    {
      case p_then: gpc_warning ("`;' after `then'"); break;
      case p_else: gpc_warning ("`;' after `else'"); break;
      case p_do:   gpc_warning ("`;' after `do'");   break;
    }
  last_token = value;

  if (value == '=' && lex_const_equal == 0)
    {
      lex_const_equal = -1;
      value = LEX_CONST_EQUAL;
    }
  if (value == LEX_ASSIGN)
    lex_const_equal = -1;
  if (lex_const_equal >= 0)
    switch (value)
    {
      case '(': case '[': lex_const_equal++; break;
      case ')': case ']': lex_const_equal--; break;
    }

  yylloc.last_file = NewPos.SrcName;
  yylloc.last_line = NewPos.Line;
  yylloc.last_column = NewPos.Column;
  yylloc.option_id = lexer_options->counter;
  lexer_filename = pascal_input_filename;
  lexer_lineno = lineno;
  lexer_column = column;
  pascal_input_filename = compiler_filename;
  lineno = compiler_lineno;
  column = compiler_column;
  activate_options (compiler_options, 1);

#ifndef EGCS97
  resume_momentary (old_momentary);
#endif
  return value;
}
