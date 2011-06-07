/*Lexer for Standard and Extended Pascal with Borland and GNU
  extensions

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

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

/*Notes:

  Return everything, including whitespace and comments if the
  corresponding token values are >= 0.

  Call SaveTokenString before modifying yyleng or the content of yytext. */

%option noyywrap
%option nodefault
%option noyyalloc
%option noyyrealloc
%option noyyfree
%option nounput
%pointer

%x CaretLetter
%x Comment1
%x Comment2
%x Comment1B
%x Comment2B
%x Discard
%x DiscardComment

%{
typedef enum
{
  DoubleQuotedStrings,
  MultilineStrings,
  IntegersWithoutSeparator,
  IntegersBase,
  IntegersHex,
  RealsWithoutSeparator,
  RealsWithDotOnly,
  RealsWithoutExpDigits,
  CharConstantsHash,
  MixedComments,
  NestedComments,
  DelphiComments,
  LF_MAX
} TLexFeatureIndex;

typedef struct
{
  HOST_WIDE_INT IntegerValueBytes[BYTES_PER_INTEGER];
  int IntegerValue, IntegerValueOverflow;
  char *TokenString, *StringValue;
  int TokenStringLength, StringValueLength;
} TLexSem;

typedef struct
{
  int Line, Column;
  char *SrcName;
} TLexPos;

extern int CommentLevelCount;
extern int Directive;
extern TLexSem LexSem;
extern TLexPos LexPos;

int CheckFeature (TLexFeatureIndex Feature, int Message);
void ExtraUserAction (const char *buf, unsigned int length);
void SetFileName (int);
void InitLex (const char *, FILE *, int);
void DoneLex (void);
int lexscan (void);
void lex_error (const char *Msg, int Fatal);
#define YY_FATAL_ERROR(msg) lex_error (msg, 1)

int CommentLevelCount = 0, Directive = 0;
TLexSem LexSem;

static int TokenStringBufSize = 0;
static char *TokenStringBuf = NULL;

TLexPos LexPos = { 0, 0, NULL };
static TLexPos NewPos = { 0, 0, NULL }, CommentStartPos = { 0, 0, NULL };

#ifndef yyalloc
void *
yyalloc (yy_size_t size)
{
  void *p = (void *) malloc (size);
  if (!p)
    YY_FATAL_ERROR ("out of memory");
  return p;
}
#endif

#ifndef yyrealloc
void *
yyrealloc (void *p, yy_size_t size)
{
  p = (void *) realloc (p, size);
  if (!p)
    YY_FATAL_ERROR ("out of memory");
  return p;
}
#endif

#ifndef yyfree
#define yyfree free
#endif

static int (*DoInput)(char * buf, int max_size);
static int DoInputF (char *buf, int max_size);
static int DoInputP (char *buf, int max_size);

void InitLex (const char *SrcName, FILE *i, int IsInteractive)
{
  if (IsInteractive >= 0)
    yy_set_interactive (IsInteractive);
  if (LexPos.SrcName) free (LexPos.SrcName);
  LexPos.SrcName = yyalloc (strlen (SrcName) + 1);
  strcpy (LexPos.SrcName, SrcName);
  LexPos.Line = LexPos.Column = 1;
  NewPos = LexPos;
  if (!co->preprocessed)
    {
      init_gpcpp();
      gpcpp_main (SrcName, i);
      YY_CURRENT_BUFFER->yy_input_file = 0;
      YY_FLUSH_BUFFER;
      DoInput = DoInputP;
    }
  else
    {
      YY_CURRENT_BUFFER->yy_input_file = yyin = i;
      YY_FLUSH_BUFFER;
      DoInput = DoInputF;
    }
  (void) yy_fatal_error;  /* avoid a warning */
}

void DoneLex (void)
{
  LexPos.Line = LexPos.Column = 0;
  NewPos = LexPos;
}



#define YY_INPUT(buf, result, max_size) ((result) = DoInput ((buf), (max_size)))

static inline int DoFixInput (char *buf, int r)
{
  static char last = 0;
  int i;
  char *p, *q;
  for (p = q = buf, i = r; i; i--, p++)
    if ((last == '\r' && *p == '\n') || (last == '\n' && *p == '\r'))
      last = 0;
    else
      *q++ = (last = *p) == '\r' ? '\n' : *p;
  return q - buf;
}

static int DoInputF (char *buf, int max_size)
{
  int r = fread (buf, 1, max_size, yyin);
  if (r == 0 && ferror (yyin))
    YY_FATAL_ERROR ("input in flex scanner failed");
  return DoFixInput (buf, r);
}

static int DoInputP (char *buf, int max_size)
{
  int r = gpcpp_fillbuf(buf, max_size);
  return DoFixInput (buf, r);
}

#define YY_USER_ACTION UserAction ();
static inline void UserAction (void)
{
  char *c = yytext;
  int l = yyleng;
  LexSem.TokenString = yytext;
  LexSem.TokenStringLength = yyleng;
  LexSem.StringValue = NULL;
  LexSem.StringValueLength = 0;
  LexPos = NewPos;
  while (l--)
    if (*c++ == '\n')
      {
        NewPos.Line++;
        NewPos.Column = 1;
      }
    else
      NewPos.Column++;
  ExtraUserAction (yytext, yyleng);
}

static void SaveTokenString (void)
{
  if (!TokenStringBuf || TokenStringBufSize < yyleng + 1)
    {
      if (TokenStringBuf)
        free (TokenStringBuf);
      TokenStringBuf = yyalloc ((TokenStringBufSize = yyleng + 1));
    }
  strncpy (TokenStringBuf, yytext, yyleng + 1);
  LexSem.TokenString = TokenStringBuf;
}

static int Char2Digit (char c)
{
  if (c >= '0' && c <= '9')
    return c - '0';
  else if (c >= 'A' && c <= 'Z')
    return c - 'A' + 0xa;
  else if (c >= 'a' && c <= 'z')
    return c - 'a' + 0xa;
  else
    return -1;
}

static char *ReadIntegerConstant (char *p, int base)
{
  int digit, largest_digit = 0, overflow = 0, i, v;
  if (!LEX_SEMANTIC_VALUES) return p;
  for (i = 0; i < BYTES_PER_INTEGER; i++)
    LexSem.IntegerValueBytes[i] = 0;
  while (1)
    {
      digit = Char2Digit (*p);
      if (digit < 0) break;
      if (digit > largest_digit)
        largest_digit = digit;
      for (i = 0; i < BYTES_PER_INTEGER; i++)
        {
          v = LexSem.IntegerValueBytes[i] * base + digit;
          LexSem.IntegerValueBytes[i] = v & ((1 << BITS_PER_BYTES) - 1);
          digit = v >> BITS_PER_BYTES;
        }
      if (digit > 0)
        overflow = 1;
      p++;
    }
  if (largest_digit >= base)
    {
      if (base <= 10 && largest_digit >= 10)
        lex_error ("nondigits in integer constant whose radix <= 10", 0);
      else
        lex_error ("integer constant contains digits beyond the radix", 0);
    }
  else if (overflow)
    lex_error ("integer constant overflow", 0);
  LexSem.IntegerValue = 0;
  LexSem.IntegerValueOverflow = 0;
  for (i = 0, v = 1; i < BYTES_PER_INTEGER; i++, v <<= BITS_PER_BYTES)
    if (v != 0)
      LexSem.IntegerValue += v * LexSem.IntegerValueBytes[i];
    else if (LexSem.IntegerValueBytes[i] != 0)
      LexSem.IntegerValueOverflow = 1;
  return p;
}

static void ReadIntegerBase (void)
{
  char *p;
  CheckFeature (IntegersBase, 1);
  if (LEX_SEMANTIC_VALUES)
    {
      p = ReadIntegerConstant (yytext, 10);
      if (LexSem.IntegerValueOverflow || LexSem.IntegerValue < 2 || LexSem.IntegerValue > 36)
        {
          lex_error ("integer base out of range (2 .. 36)", 0);
          LexSem.IntegerValue = 10;
        }
      ReadIntegerConstant (p + 1, LexSem.IntegerValue);
    }
}

static inline void SetCharConst (int c)
{
  static char CharConstBuf[2] = { 0, 0 };
  CharConstBuf[0] = c;
  LexSem.StringValue = CharConstBuf;
  LexSem.StringValueLength = 1;
}

static void SetCaretCharConst (void)
{
  char c = yytext[1];
  if (c >= 'a' && c <= 'z')
    c -= 'a' - 'A';
  SetCharConst (c ^ 0x40);  /* sic! */
}

static void BPCharConstant (char *p, int base)
{
  CheckFeature (CharConstantsHash, 1);
  if (!LEX_SEMANTIC_VALUES) return;
  ReadIntegerConstant (p, base);
  if (LexSem.IntegerValueOverflow || LexSem.IntegerValue > 0xff)
    lex_error ("numeric value out of range for character constant", 0);
  SetCharConst (LexSem.IntegerValue);
}

static void SetString (int DoubleQuoted)
{
  char *c = yytext, *d = yytext;
  while (*c && *c != '\n')
    c++;
  if (*c)
    CheckFeature (MultilineStrings, 1);
  if (DoubleQuoted)
    CheckFeature (DoubleQuotedStrings, 1);
  if (!LEX_SEMANTIC_VALUES)
    return;
  SaveTokenString ();
  if (!DoubleQuoted)
    {
      for (c = yytext + 1; *c && c[1]; c++)
        if ((*d++ = *c) == '\'')
          c++;
    }
  else
    {
      for (c = yytext + 1; *c && *c != '"'; c++)
        if (*c != '\\')
          *d++ = *c;
        else
          switch (*++c)
            {
              case 'n':  *d++ = '\n' /* TARGET_NEWLINE */; break;
              case 't':  *d++ = '\t' /* TARGET_TAB */;     break;
              case 'r':  *d++ = '\r' /* TARGET_CR */;      break;
              case 'f':  *d++ = '\f' /* TARGET_FF */;      break;
              case 'b':  *d++ = '\b' /* TARGET_BS */;      break;
              case 'v':  *d++ = '\v' /* TARGET_VT */;      break;
              case 'a':  *d++ = '\a' /* TARGET_BELL */;    break;
              case 'e':
              case 'E':  *d++ = 27;             break;
              case 'x':  {
                           int v = 0, n = 0, overflow = 0;
                           while (1)
                             {
                               int digit = Char2Digit (*++c);
                               if (digit < 0 || digit >= 0x10) break;
                               v = 0x10 * v + digit;
                               overflow |= v > 0xff;
                               n++;
                             }
                           if (overflow)
                             lex_error ("hex character escape out of range", 0);
                           else if (!n)
                             lex_error ("hex character escape with no digits", 0);
                           *d++ = v;
                           c--;
                           break;
                         }
              case '0': case '1': case '2': case '3':
              case '4': case '5': case '6': case '7':
                         {
                           int v = 0, n = 1;
                           do
                             v = 8 * v + (*c++ - '0');
                           while (n++ < 3 && *c >= '0' && *c <= '7');
                           if (v > 0xff)
                             lex_error ("octal character escape out of range", 0);
                           *d++ = v;
                           c--;
                           break;
                         }
              case '\n': break;
              default:   *d++ = *c;
            }
    }
  *d = 0;
  LexSem.StringValue = yytext;
  LexSem.StringValueLength = d - yytext;
}

static void DoLineDir (int items)
{
  char *p1 = yytext;
  while (*p1 < '0' || *p1 > '9') p1++;
  ReadIntegerConstant (p1, 10);
  if (LexSem.IntegerValueOverflow)
    lex_error ("number in line directive out of range", 0);
  NewPos.Line = LexSem.IntegerValue;
  if (items >= 2)
    {
      int v = 0;
      char *p2, *q;
      while (*p1 != '"') p1++;
      p2 = ++p1;
      while (*p2 != '"') p2++;
      /* Never free an input filename, since copies of the pointer are
         kept around (in DECL_SOURCE_FILE etc.). */
      NewPos.SrcName = q = yyalloc (p2 - p1 + 1);
      while (p1 < p2)
        {
          if (*p1 == '\\')
            p1++;
          *q++ = *p1++;
        }
      *q = 0;
      if (items >= 3)
        {
          while (*p2 < '0' || *p2 > '9') p2++;
          p2 = ReadIntegerConstant (p2, 10);
          if (LexSem.IntegerValueOverflow)
            lex_error ("number in line directive out of range", 0);
          v = LexSem.IntegerValue;
        }
      SetFileName (v);
    }
}

static inline void StartComment (int IsDirective, int State, int StateBoth)
{
  CommentStartPos = LexPos;
  CommentLevelCount = 1;
  Directive = IsDirective;
  BEGIN (CheckFeature (MixedComments, 0) ? StateBoth : State);
}

#define CommentContent \
  RETURN_IF_DEFINED ((CommentLevelCount == 1 && Directive) ? LEX_DIRECTIVE_CONTENT : LEX_COMMENT_CONTENT)

#define EndComment \
  if (--CommentLevelCount == 0) \
    BEGIN (INITIAL); \
  RETURN_IF_DEFINED ((CommentLevelCount == 0 && Directive) ? LEX_DIRECTIVE_END : LEX_COMMENT_END);

#define RETURN_IF_DEFINED(x) do { if ((x) >= 0) return (x); } while (0)

#define YY_DECL int lexscan (void)
%}

AU     [a-zA-Z_]
AN     [a-zA-Z0-9]
ANU    [a-zA-Z0-9_]
DS     [0-9]+
HEX    "$"[0-9A-Fa-f]+
NOHEX  [G-Zg-z_]
EXP    ([Ee]("+"|"-")?{DS})
NCE1   [^{}\n]*
NCE2   (("*"*"("+)?")"|"*"*"("*[^(*)\n])*"*"*"("*
NCEB   (("*"*"("+)?")"|"*"*"("*[^(*){}\n])*"*"*"("*
WS     [ \t\v]
DIRB   {WS}*"#"
LD1    {DIRB}{WS}+[0-9]+{WS}*
LD2    {LD1}\"[^"]*\"{WS}*
LD3    {LD2}[0-9]+.*

%%

[][().,:;@^<=>&|+*/-]      return yytext[0];
"("/"..."                  return '(';
"(."                       return '[';
".)"                       return ']';
":="                       return LEX_ASSIGN;
"<>"                       return LEX_NE;
">="                       return LEX_GE;
"<="                       return LEX_LE;
"><"                       return LEX_SYMDIFF;
"=>"                       return LEX_RENAME;
"**"                       return LEX_POWER;
"+>"                       return LEX_CEIL_PLUS;
"->"                       return LEX_CEIL_MINUS;
"*>"                       return LEX_CEIL_MULT;
"/>"                       return LEX_CEIL_DIV;
"+<"                       return LEX_FLOOR_PLUS;
"-<"                       return LEX_FLOOR_MINUS;
"*<"                       return LEX_FLOOR_MULT;
"/<"                       return LEX_FLOOR_DIV;
".."                       return LEX_RANGE;
"..."                      return LEX_ELLIPSIS;

{AU}{ANU}*                 return LEX_ID;

{DS}                       ReadIntegerConstant (yytext, 10); return LEX_INTCONST;
{DS}/"."[.)]               ReadIntegerConstant (yytext, 10); return LEX_INTCONST;
{DS}/{AU}                  CheckFeature (IntegersWithoutSeparator, 1); ReadIntegerConstant (yytext, 10); return LEX_INTCONST;
{DS}"#"{AN}+               ReadIntegerBase (); return LEX_INTCONST_BASE;
{DS}"#"{AN}+/_             CheckFeature (IntegersWithoutSeparator, 1); ReadIntegerBase (); return LEX_INTCONST_BASE;
{HEX}                      CheckFeature (IntegersHex, 1); ReadIntegerConstant (yytext + 1, 0x10); return LEX_INTCONST_BASE;
{HEX}/{NOHEX}              CheckFeature (IntegersHex, 1); CheckFeature (IntegersWithoutSeparator, 1); ReadIntegerConstant (yytext + 1, 0x10); return LEX_INTCONST_BASE;

{DS}{EXP}                  |
{DS}"."{DS}{EXP}?          return LEX_REALCONST;
{DS}({EXP}|"."{DS}{EXP}?)/{AU}  CheckFeature (RealsWithoutSeparator, 1); return LEX_REALCONST;
{DS}"."                    CheckFeature (RealsWithDotOnly, 1); return LEX_REALCONST;
{DS}"."/"."[.)]            CheckFeature (RealsWithDotOnly, 1); return LEX_REALCONST;  /* note the `{DS}/"."[.)]' rule (fjf528b.pas) */
{DS}"."[Ee]                CheckFeature (RealsWithDotOnly, 1); CheckFeature (RealsWithoutExpDigits, 1); return LEX_REALCONST;
{DS}"."[Ee]/{AU}           CheckFeature (RealsWithDotOnly, 1); CheckFeature (RealsWithoutExpDigits, 1); CheckFeature (RealsWithoutSeparator, 1); return LEX_REALCONST;
{DS}"."{EXP}               CheckFeature (RealsWithDotOnly, 1); return LEX_REALCONST;
{DS}"."/{AU}               CheckFeature (RealsWithDotOnly, 1); CheckFeature (RealsWithoutSeparator, 1); return LEX_REALCONST;
{DS}"."{EXP}/{AU}          CheckFeature (RealsWithDotOnly, 1); CheckFeature (RealsWithoutSeparator, 1); return LEX_REALCONST;

"#"{DS}                    BPCharConstant (yytext + 1, 10); return LEX_STRCONST;
"#"{DS}/{AU}               CheckFeature (IntegersWithoutSeparator, 1); BPCharConstant (yytext + 1, 10); return LEX_STRCONST;
"#"{HEX}                   BPCharConstant (yytext + 2, 0x10); return LEX_STRCONST;
"#"{HEX}/{NOHEX}           CheckFeature (IntegersWithoutSeparator, 1); BPCharConstant (yytext + 2, 0x10); return LEX_STRCONST;

"^"/[][,.:;()<=>@^{\n+*/-] return '^';
"^"/{AU}{ANU}              return '^';
"^"/{AU}                   BEGIN (CaretLetter); return '^';
"^"[ \t\f\v]               SetCaretCharConst (); return LEX_CARET_WHITE;
"^".                       SetCaretCharConst (); return LEX_STRCONST;
<CaretLetter>{AU}          BEGIN (INITIAL); return LEX_CARET_LETTER;
<CaretLetter>.|\n          |
<CaretLetter><<EOF>>       lex_error ("internal lexer error", 1);

'([^']|'')*'               SetString (0); return LEX_STRCONST;
\"([^"\\]|\\(.|\n))*\"     SetString (1); return LEX_STRCONST;
['"]                       lex_error ("unterminated string constant", 0); BEGIN (Discard); RETURN_IF_DEFINED (LEX_INVALID);
<Discard>.*\n?             RETURN_IF_DEFINED (LEX_INVALID);

"//".*\n?                  CheckFeature (DelphiComments, 1); RETURN_IF_DEFINED (LEX_COMMENT);
"{"                        StartComment (0, Comment1, Comment1B); RETURN_IF_DEFINED (LEX_COMMENT_BEGIN);
"(*"                       StartComment (0, Comment2, Comment2B); RETURN_IF_DEFINED (LEX_COMMENT_BEGIN);
"{$"                       StartComment (1, Comment1, Comment1B); RETURN_IF_DEFINED (LEX_DIRECTIVE_BEGIN);
"(*$"                      StartComment (1, Comment2, Comment2B); RETURN_IF_DEFINED (LEX_DIRECTIVE_BEGIN);
<Comment1,Comment1B>"}"    |
<Comment2,Comment2B>"*)"   EndComment;
<Comment1B>"*)"            |
<Comment2B>"}"             CheckFeature (MixedComments, 1); EndComment;
<Comment1,Comment1B>"{"    |
<Comment2,Comment2B>"(*"   {
                             if (CheckFeature (NestedComments, 0))
                               {
                                 CheckFeature (NestedComments, 1);
                                 CommentLevelCount++;
                                 RETURN_IF_DEFINED (LEX_COMMENT_BEGIN);
                               }
                             else
                               CommentContent;
                           }
<Comment1B>"(*"            |
<Comment2B>"{"             {
                             if (CheckFeature (NestedComments, 0))
                               {
                                 CheckFeature (NestedComments, 1);
                                 CheckFeature (MixedComments, 1);
                                 CommentLevelCount++;
                                 /* Theoretically, we should adjust the lexer state.
                                    But this would require a stack to pop it back
                                    when the nested comment is closed. Since we have
                                    just given a warning for mixed comments (if
                                    requested), this effort seems unjustified just
                                    to give a possible further one. */
                                 RETURN_IF_DEFINED (LEX_COMMENT_BEGIN);
                               }
                             else
                               CommentContent;
                           }
<Comment1>{NCE1}\n                              |
<Comment2>{NCE2}\n                              |
<Comment1B,Comment2B>{NCEB}\n                   CommentContent;
<Comment1>{NCE1}/[{}]                           CommentContent;
<Comment2>{NCE2}/"(*"                           CommentContent;
<Comment2>{NCE2}/"*)"                           CommentContent;
<Comment1B,Comment2B>{NCEB}/[{}]                CommentContent;
<Comment1B,Comment2B>{NCEB}/"(*"                CommentContent;
<Comment1B,Comment2B>{NCEB}/"*)"                CommentContent;
<Comment1,Comment2,Comment1B,Comment2B>.        |
<Comment1,Comment2,Comment1B,Comment2B><<EOF>>  LexPos = CommentStartPos; lex_error ("unterminated comment", 0); BEGIN (DiscardComment); CommentContent;
<DiscardComment>.*\n?                           CommentContent;

^{LD1}\n                   DoLineDir (1); RETURN_IF_DEFINED (LEX_LINE_DIRECTIVE);
^{LD2}\n                   DoLineDir (2); RETURN_IF_DEFINED (LEX_LINE_DIRECTIVE);
^{LD3}\n                   DoLineDir (3); RETURN_IF_DEFINED (LEX_LINE_DIRECTIVE);
^{DIRB}{WS}+[0-9].*\n?     |
^{DIRB}[^0-9$].*\n?        lex_error ("invalid `#' directive", 0); RETURN_IF_DEFINED (LEX_INVALID);

[ \t\v\f]*\n?              RETURN_IF_DEFINED (LEX_WHITESPACE);
.                          lex_error ("invalid character", 0); RETURN_IF_DEFINED (LEX_INVALID);
<INITIAL,Discard,DiscardComment><<EOF>>  return 0;

%%
