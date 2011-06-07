{$nested-comments}

{ Regular expression matching and replacement

  The RegEx unit provides routines to match strings against regular
  expressions and perform substitutions using matched
  subexpressions.

  To use the RegEx unit, you will need the rx library which can be
  found in http://www.gnu-pascal.de/libs/

  Regular expressions are strings with some characters having
  special meanings. They describe (match) a class of strings. They
  are similar to wild cards used in file name matching, but much
  more powerful.

  There are two kinds of regular expressions supported by this unit,
  basic and extended regular expressions. The difference between
  them is not functionality, but only syntax. The following is a
  short overview of regular expressions. For a more thorough
  explanation see the literature, or the documentation of the rx
  library, or man pages of programs like grep(1) and sed(1).

  Basic           Extended        Meaning
  `.'             `.'             matches any single character
  `[aei-z]'       `[aei-z]'       matches either `a', `e', or any
                                  character from `i' to `z'
  `[^aei-z]'      `[^aei-z]'      matches any character but `a',
                                  `e', or `i' .. `z'
                                  To include in such a list the the
                                  characters `]', `^', or `-', put
                                  them first, anywhere but first, or
                                  first or last, resp.
  `[[:alnum:]]'   `[[:alnum:]]'   matches any alphanumeric character
  `[^[:digit:]]'  `[^[:digit:]]'  matches anything but a digit
  `[a[:space:]]'  `[a[:space:]]'  matches the letter `a' or a space
                                  character (space, tab)
  ...                             (there are more classes available)
  `\w'            `\w'            = [[:alnum:]]
  `\W'            `\W'            = [^[:alnum:]]
  `^'             `^'             matches the empty string at the
                                  beginning of a line
  `$'             `$'             matches the empty string at the
                                  end of a line
  `*'             `*'             matches zero or more occurences of
                                  the preceding expression
  `\+'            `+'             matches one or more occurences of
                                  the preceding expression
  `\?'            `?'             matches zero or one occurence of
                                  the preceding expression
  `\{N\}'         `{N}'           matches exactly N occurences of
                                  the preceding expression (N is an
                                  integer number)
  `\{M,N\}'       `{M,N}'         matches M to N occurences of the
                                  preceding expression (M and N are
                                  integer numbers, M <= N)
  `AB'            `AB'            matches A followed by B (A and B
                                  are regular expressions)
  `A\|B'          `A|B'           matches A or B (A and B are
                                  regular expressions)
  `\( \)'         `( )'           forms a subexpression, to override
                                  precedence, and for subexpression
                                  references
  `\7'            `\7'            matches the 7'th parenthesized
                                  subexpression (counted by their
                                  start in the regex), where 7 is a
                                  number from 1 to 9 ;-).
                                  *Please note:* using this feature
                                  can be *very* slow or take very
                                  much memory (exponential time and
                                  space in the worst case, if you
                                  know what that means ...).
  `\'             `\'             quotes the following character if
                                  it's special (i.e. listed above)
  rest            rest            any other character matches itself

  Precedence, from highest to lowest:
  * parentheses (`()')
  * repetition (`*', `+', `?', `{}')
  * concatenation
  * alternation (`|')

  When performing substitutions using matched subexpressions of a
  regular expression (see `ReplaceSubExpressionReferences'), the
  replacement string can reference the whole matched expression with
  `&' or `\0', the 7th subexpression with `\7' (just like in the
  regex itself, but using it in replacements is not slow), and the
  7th subexpression converted to upper/lower case with `\u7' or
  `\l7', resp. (which also works for the whole matched expression
  with `\u0' or `\l0'). A verbatim `&' or `\' can be specified with
  `\&' or `\\', resp.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

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
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License.

  Please also note the license of the rx library. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

unit RegEx;

interface

uses GPC;

const
  { `BasicRegExSpecialChars' contains all characters that have
    special meanings in basic regular expressions.
    `ExtRegExSpecialChars' contains those that have special meanings
    in extended regular expressions. }
  BasicRegExSpecialChars = ['.', '[', ']', '^', '$', '*', '\'];
  ExtRegExSpecialChars   = ['.', '[', ']', '^', '$', '*', '+', '?', '{', '}', '|', '(', ')', '\'];

type
  { The type used by the routines of the `RegEx' unit to store
    regular expressions in an internal format. The fields RegEx,
    RegMatch, ErrorInternal, From and Length are only used
    internally. SubExpressions can be read after `NewRegEx' and will
    contain the number of parenthesized subexpressions. Error should
    be checked after `NewRegEx'. It will be `nil' when it succeeded,
    and contain an error message otherwise. }
  RegExType = record
    RegEx, RegMatch: Pointer;  { Internal }
    ErrorInternal: CString;    { Internal }
    From, Length: CInteger;    { Internal }
    SubExpressions: CInteger;
    Error: PString
  end;

{ Simple interface to regular expression matching. Matches a regular
  expression against a string starting from a specified position.
  Returns the position of the first match, or 0 if it does not
  match, or the regular expression is invalid. }
function  RegExPosFrom (const Expression: String; ExtendedRegEx, CaseInsensitive: Boolean; const s: String; From: Integer) = MatchPosition: Integer;

{ Creates the internal format of a regular expression. If
  ExtendedRegEx is True, Expression is assumed to denote an extended
  regular expression, otherwise a basic regular expression.
  CaseInsensitive determines if the case of letters will be ignored
  when matching the expression. If NewLines is True, `NewLine'
  characters in a string matched against the expression will be
  treated as dividing the string in multiple lines, so that `$' can
  match before the NewLine and `^' can match after. Also, `.' and
  `[^...]' will not match a NewLine then. }
procedure NewRegEx (var RegEx: RegExType; const Expression: String; ExtendedRegEx, CaseInsensitive, NewLines: Boolean);

{ Disposes of a regular expression created with `NewRegEx'. *Must*
  be used after `NewRegEx' before the RegEx variable becomes invalid
  (i.e., goes out of scope or a pointer pointing to it is Dispose'd
  of). }
procedure DisposeRegEx (var RegEx: RegExType); external name '_p_DisposeRegEx';

{ Matches a regular expression created with `NewRegEx' against a
  string. }
function  MatchRegEx (var RegEx: RegExType; const s: String; NotBeginningOfLine, NotEndOfLine: Boolean): Boolean;

{ Matches a regular expression created with `NewRegEx' against a
  string, starting from a specified position. }
function  MatchRegExFrom (var RegEx: RegExType; const s: String; NotBeginningOfLine, NotEndOfLine: Boolean; From: Integer): Boolean;

{ Finds out where the regular expression matched, if `MatchRegEx' or
  `MatchRegExFrom' were successful. If n = 0, it returns the
  position of the whole match, otherwise the position of the n'th
  parenthesized subexpression. MatchPosition and MatchLength will
  contain the position (counted from 1) and length of the match, or
  0 if it didn't match. (Note: MatchLength can also be 0 for a
  successful empty match, so check whether MatchPosition is 0 to
  find out if it matched at all.) MatchPosition or MatchLength may
  be Null and is ignored then. }
procedure GetMatchRegEx (var RegEx: RegExType; n: Integer; var MatchPosition, MatchLength: Integer);

{ Checks if the string s contains any quoted characters or
  (sub)expression references to the regular expression RegEx created
  with `NewRegEx'. These are `&' or `\0' for the whole matched
  expression (if OnlySub is not set) and `\1' .. `\9' for the n'th
  parenthesized subexpression. Returns 0 if it does not contain any,
  and the number of references and quoted characters if it does. If
  an invalid reference (i.e. a number bigger than the number of
  subexpressions in RegEx) is found, it returns the negative value
  of the (first) invalid reference. }
function  FindSubExpressionReferences (var RegEx: RegExType; const s: String; OnlySub: Boolean): Integer;

{ Replaces (sub)expression references in ReplaceStr by the actual
  (sub)expressions and unquotes quoted characters. To be used after
  the regular expression RegEx created with `NewRegEx' was matched
  against s successfully with `MatchRegEx' or `MatchRegExFrom'. }
function  ReplaceSubExpressionReferences (var RegEx: RegExType; const s, ReplaceStr: String) = Res: TString;

{ Returns the string for a regular expression that matches exactly
  one character out of the given set. It can be combined with the
  usual operators to form more complex expressions. }
function  CharSet2RegEx (const Characters: CharSet) = s: TString;

implementation

{$L rx, regexc.c}

procedure CNewRegEx (var RegEx: RegExType; Expression: CString; ExpressionLength: CInteger; ExtendedRegEx, CaseInsensitive, NewLines: Boolean); external name '_p_CNewRegEx';
function CMatchRegExFrom (var RegEx: RegExType; aString: CString; StrLength: CInteger; NotBeginningOfLine, NotEndOfLine: Boolean; From: CInteger): Boolean; external name '_p_CMatchRegExFrom';
procedure CGetMatchRegEx (var RegEx: RegExType; n: CInteger; var MatchPosition, MatchLength: CInteger); external name '_p_CGetMatchRegEx';

procedure NewRegEx (var RegEx: RegExType; const Expression: String; ExtendedRegEx, CaseInsensitive, NewLines: Boolean);
begin
  CNewRegEx (RegEx, Expression, Length (Expression), ExtendedRegEx, CaseInsensitive, NewLines);
  if RegEx.ErrorInternal = nil then
    RegEx.Error := nil
  else
    RegEx.Error := NewString (CString2String (RegEx.ErrorInternal))
end;

function MatchRegEx (var RegEx: RegExType; const s: String; NotBeginningOfLine, NotEndOfLine: Boolean): Boolean;
begin
  MatchRegEx := CMatchRegExFrom (RegEx, s, Length (s), NotBeginningOfLine, NotEndOfLine, 1)
end;

function MatchRegExFrom (var RegEx: RegExType; const s: String; NotBeginningOfLine, NotEndOfLine: Boolean; From: Integer): Boolean;
begin
  MatchRegExFrom := CMatchRegExFrom (RegEx, s, Length (s), (From <> 1) or NotBeginningOfLine, NotEndOfLine, From)
end;

procedure GetMatchRegEx (var RegEx: RegExType; n: Integer; var MatchPosition, MatchLength: Integer);
var CMatchPosition, CMatchLength: CInteger;
begin
  CGetMatchRegEx (RegEx, n, CMatchPosition, CMatchLength);
  if @MatchPosition <> nil then MatchPosition := CMatchPosition;
  if @MatchLength   <> nil then MatchLength := CMatchLength
end;

function RegExPosFrom (const Expression: String; ExtendedRegEx, CaseInsensitive: Boolean; const s: String; From: Integer) = MatchPosition: Integer;
var RegEx: RegExType;
begin
  MatchPosition := 0;
  NewRegEx (RegEx, Expression, ExtendedRegEx, CaseInsensitive, False);
  if (RegEx.Error = nil) and MatchRegExFrom (RegEx, s, False, False, From) then
    GetMatchRegEx (RegEx, 0, MatchPosition, Null);
  DisposeRegEx (RegEx)
end;

function FindSubExpressionReferences (var RegEx: RegExType; const s: String; OnlySub: Boolean): Integer;
var
  i, j: Integer;
  ch: Char;
begin
  j := 0;
  i := 1;
  while i <= Length (s) do
    begin
      case s[i] of
        '&': if not OnlySub then Inc (j);
        '\': if i = Length (s) then
               Inc (j)
             else
               begin
                 ch := s[i + 1];
                 if (ch in ['u', 'l']) and (i + 1 < Length (s)) then
                   begin
                     Inc (i);
                     ch := s[i + 1]
                   end;
                 if (ch in ['0' .. '9']) and
                   (Ord (ch) - Ord ('0') > RegEx.SubExpressions) then
                   Return -(Ord (ch) - Ord ('0'))
                 else
                   begin
                     if not OnlySub or (ch <> '0') then Inc (j);
                     Inc (i)
                   end
               end;
      end;
      Inc (i)
    end;
  FindSubExpressionReferences := j
end;

function ReplaceSubExpressionReferences (var RegEx: RegExType; const s, ReplaceStr: String) = Res: TString;
var i: Integer;

  procedure DoReplace (l, n: Integer; CaseMode: Char);
  var
    MatchPosition, MatchLength: Integer;
    st: TString;
  begin
    GetMatchRegEx (RegEx, n, MatchPosition, MatchLength);
    Delete (Res, i, l);
    if (n <= RegEx.SubExpressions) and (MatchPosition > 0) { @@ rx-1.5 bug } and (MatchPosition + MatchLength - 1 <= Length (s)) then
      begin
        st := Copy (s, MatchPosition, MatchLength);
        case CaseMode of
          'u': UpCaseString (st);
          'l': LoCaseString (st);
        end;
        Insert (st, Res, i);
        Inc (i, MatchLength)
      end;
    Dec (i)
  end;

begin
  Res := ReplaceStr;
  i := 1;
  while i <= Length (Res) do
    begin
      case Res[i] of
        '&': DoReplace (1, 0, #0);
        '\': if (i < Length (Res)) and (Res[i + 1] in ['0' .. '9']) then
               DoReplace (2, Ord (Res[i + 1]) - Ord ('0'), #0)
             else if (i + 1 < Length (Res)) and (Res[i + 1] in ['u', 'l']) and (Res[i + 2] in ['0' .. '9']) then
               DoReplace (3, Ord (Res[i + 2]) - Ord ('0'), Res[i + 1])
             else
               Delete (Res, i, 1);
      end;
      Inc (i)
    end
end;

function CharSet2RegEx (const Characters: CharSet) = s: TString;
var
  i: Integer;
  c, c2: Char;
  s2, s3: String (1) = '';
begin
  if Characters = [] then Return '[^' + Low (Char) + '-' + High (Char) + ']';
  if Characters = ['^'] then Return '\^';  { A `^' alone cannot be handled within `[]'! }
  if Characters = ['^', '-'] then Return '[-^]';
  s := '';
  i := Ord (Low (Char));
  { we cannot use a Char for the loop, because it would overflow }
  while i <= Ord (High (Char)) do
    begin
      c := Chr (i);
      if c in Characters then
        case c of
          ']': s := c + s;  { `]' must come first }
          '^': s2 := c;  { `^' must not come first }
          '-': s3 := c;  { `-' must come last (or first) }
          else
            c2 := c;
            while (c2 < High (c)) and (Succ (c2) in Characters) do Inc (c2);
            if c2 = ']' then Dec (c2);  { `x-]' would be interpreted as a closing bracket }
            if c2 <= Succ (c) then
              s := s + c
            else
              begin
                s := s + c + '-' + c2;
                c := c2
              end
        end;
      i := Ord (c) + 1
    end;
  s := '[' + s + s2 + s3 + ']'
end;

end.
