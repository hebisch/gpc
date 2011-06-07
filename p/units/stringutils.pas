{ Some routines for string handling on a higher level than those
  provided by the RTS.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

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
  General Public License. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

unit StringUtils;

interface

uses GPC;

{ Various routines }

{ Appends Source to s, truncating the result if necessary. }
procedure AppendStr (var s: String; const Source: String);

{ Cuts s to MaxLength characters. If s is already MaxLength
  characters or shorter, it doesn't change anything. }
procedure StrCut (var s: String; MaxLength: Integer);

{ Returns the number of disjoint occurences of SubStr in s. Returns
  0 if SubStr is empty. }
function  StrCount (const SubStr: String; s: String): Integer;

{ Returns s, with all disjoint occurences of Source replaced by
  Dest. }
function  StrReplace (const s, Source, Dest: String) = Result: TString;

{ Sets of characters accepted for `True' and `False' by
  Char2Boolean and StrReadBoolean. }
var
  CharactersTrue : CharSet = ['Y', 'y'];
  CharactersFalse: CharSet = ['N', 'n'];

{ If ch is an element of CharactersTrue, Dest is set to True,
  otherwise if it is an element of CharactersFalse, Dest is set to
  False. In both cases True is returned. If ch is not an element of
  either set, Dest is set to False and False is returned. }
function  Char2Boolean (ch: Char; var Dest: Boolean): Boolean; attribute (ignorable);

{ Converts a digit character to its numeric value. Handles every
  base up to 36 (0 .. 9, a .. z, upper and lower case recognized).
  Returns -1 if the character is not a digit at all. If you want to
  use it for a base < 36, you have to check if the result is smaller
  than the base and not equal to -1. }
function  Char2Digit (ch: Char): Integer;

{ Encode a string in a printable format (quoted printable). All
  occurences of EscapeChar within the string are encoded. If
  QuoteHigh is True, all characters above the ASCII range are
  encoded as well (required in "7 bit" environments, as per several
  RFCs). `=' is always encoded, as required for proper decoding, as
  are all characters below space (control characters), so if you
  don't need an escape char yourself, you can pass #0 for
  EscapeChar. }
function  QuoteStringEscape (const s: String; EscapeChar: Char; QuoteHigh: Boolean): TString;

{ Encode a string in a printable format (quoted printable and
  surrounded with `"'). All occurences of `"' within the string are
  encoded, so the result string contains exactly two `"' characters
  (at the beginning and ending). This is useful to store arbitrary
  strings in text files while keeping them as readable as possible
  (which is the goal of the quoted printable encoding in general,
  see RFC 1521, section 5.1) and being able to read them back
  losslessly (with UnQuoteString). }
function  QuoteString (const s: String): TString;

{ Encode a string in a printable format suitable for StrReadEnum.
  All occurences of `,' within the string are encoded. }
function  QuoteEnum (const s: String): TString;

{ Decode a string encoded by QuoteString (removing the `"' and
  expanding quoted printable encoded characters). Returns True if
  successful and False if the string has an invalid form. A string
  returned by QuoteString is always valid. }
function  UnQuoteString (var s: String): Boolean; attribute (ignorable);

{ Decode a quoted-printable string (not enclosed in `"', unlike for
  UnQuoteString). Returns True if successful and False if the string
  has an invalid form. In the latter case, it still decodes as much
  as is valid, even after the error position. }
function  UnQPString (var s: String): Boolean; attribute (ignorable);

{ Quotes a string as done in shells, i.e. all special characters are
  enclosed in either `"' or `'', where `"', `$' and ``' are always
  enclosed in `'' and `'' is always enclosed in `"'. }
function  ShellQuoteString (const s: String) = Res: TString;

{ Replaces all tab characters in s with the appropriate amount of
  spaces, assuming tab stops at every TabSize columns. Returns True
  if successful and False if the expanded string would exceed the
  capacity of s. In the latter case, some, but not all of the tabs
  in s may have been expanded. }
function  ExpandTabs (var s: String; TabSize: Integer): Boolean; attribute (ignorable);

{ Returns s, with all occurences of C style escape sequences (e.g.
  `\n') replaced by the characters they mean. If AllowOctal is True,
  also octal character specifications (e.g. `\007') are replaced. If
  RemoveQuoteChars is True, any other backslashes are removed (e.g.
  `\*' -> `*' and `\\' -> `\'), otherwise they are kept, and also
  `\\' is left as two backslashes then. }
function  ExpandCEscapeSequences (const s: String; RemoveQuoteChars, AllowOctal: Boolean) = r: TString;

{ Routines for TPStrings }

{ Initialise a TPStrings variable, allocate Size characters for each
  element. This procedure does not dispose of any previously
  allocated storage, so if you use it on a previously used variable
  without freeing the storage yourself, this might cause memory
  leaks. }
procedure AllocateTPStrings (var Strings: TPStrings; Size: Integer);

{ Clear all elements (set them to empty strings), does not free any
  storage. }
procedure ClearTPStrings (var Strings: TPStrings);

{ Divide a string into substrings, using Separators as separator. A
  single trailing separator is ignored. Further trailing separators
  as well as any leading separators and multiple separators in a row
  produce empty substrings. }
function TokenizeString (const Source: String; Separators: CharSet) = Res: PPStrings;

{ Divide a string into substrings, using SpaceCharacters as
  separators. The splitting is done according the usual rules of
  shells, using (and removing) single and double quotes and
  QuotingCharacter. Multiple, leading, and trailing separators are
  ignored. If there is an error, a message is stored in ErrMsg (if
  not Null), and nil is returned. nil is also returned (without an
  error message) if s is empty. }
function ShellTokenizeString (const s: String; var ErrMsg: String) = Tokens: PPStrings;

{ String parsing routines }

{ All the following StrReadFoo functions behave similarly. They read
  items from a string s, starting at index i, to a variable Dest.
  They skip any space characters (spaces and tabs) by incrementing i
  first. They return True if successful, False otherwise. i is
  incremented accordingly if successful, otherwise i is left
  unchanged, apart from the skipping of space characters, and Dest
  is undefined. This behaviour makes it easy to use the functions in
  a row like this:

    i := 1;
    if StrReadInt    (s, i, Size)  and StrReadComma (s, i) and
       StrReadQuoted (s, i, Name)  and StrReadComma (s, i) and
       ...
       StrReadReal   (s, i, Angle) and (i > Length (s)) then ...

  (The check `i > Length (s)' is in case you don't want to accept
  trailing "garbage".) }

{ Just skip any space characters as described above. }
procedure StrSkipSpaces (const s: String; var i: Integer);

{ Read a quoted string (as produced by QuoteString) from a string
  and unquote the result using UnQuoteString. It is considered
  failure if the result (unquoted) would be longer than the capacity
  of Dest. }
function  StrReadQuoted (const s: String; var i: Integer; var Dest: String): Boolean; attribute (ignorable);

{ Read a string delimited with Delimiter from a string and return
  the result with the delimiters removed. It is considered failure
  if the result (without delimiters) would be longer than the
  capacity of Dest. }
function  StrReadDelimited (const s: String; var i: Integer; var Dest: String; Delimiter: Char): Boolean; attribute (ignorable);

{ Read a word (consisting of anything but space characters and
  commas) from a string. It is considered failure if the result
  would be longer than the capacity of Dest. }
function  StrReadWord (const s: String; var i: Integer; var Dest: String): Boolean; attribute (ignorable);

{ Check that a certain string is contained in s (after possible
  space characters). }
function  StrReadConst (const s: String; var i: Integer; const Expected: String) = Res: Boolean; attribute (ignorable);

{ A simpler to use version of StrReadConst that expects a `,'. }
function  StrReadComma (const s: String; var i: Integer) = Res: Boolean; attribute (ignorable);

{ Read an integer number from a string. }
function  StrReadInt (const s: String; var i: Integer; var Dest: Integer): Boolean; attribute (ignorable);

{ Read a real number from a string. }
function  StrReadReal (const s: String; var i: Integer; var Dest: Real): Boolean; attribute (ignorable);

{ Read a Boolean value, represented by a single character
  from CharactersTrue or CharactersFalse (cf. Char2Boolean), from a
  string. }
function  StrReadBoolean (const s: String; var i: Integer; var Dest: Boolean): Boolean; attribute (ignorable);

{ Read an enumerated value, i.e., one of the entries of IDs, from a
  string, and stores the ordinal value, i.e., the index in IDs
  (always zero-based) in Dest. }
function  StrReadEnum (const s: String; var i: Integer; var Dest: Integer; const IDs: array of PString): Boolean; attribute (ignorable);

{ String hash table }

const
  DefaultHashSize = 1403;

type
  THash = Cardinal;

  PStrHashList = ^TStrHashList;
  TStrHashList = record
    Next: PStrHashList;
    s: PString;
    i: Integer;
    p: Pointer
  end;

  PStrHashTable = ^TStrHashTable;
  TStrHashTable (Size: Cardinal) = record
    CaseSensitive: Boolean;
    Table: array [0 .. Size - 1] of PStrHashList
  end;

function  HashString          (const s: String): THash;
function  NewStrHashTable     (Size: Cardinal; CaseSensitive: Boolean) = HashTable: PStrHashTable;
procedure AddStrHashTable     (HashTable: PStrHashTable; s: String; i: Integer; p: Pointer);
procedure DeleteStrHashTable  (HashTable: PStrHashTable; s: String);
function  SearchStrHashTable  (HashTable: PStrHashTable; const s: String; var p: Pointer): Integer;  { p may be Null }
procedure StrHashTableUsage   (HashTable: PStrHashTable; var Entries, Slots: Integer);
procedure DisposeStrHashTable (HashTable: PStrHashTable);

implementation

procedure AppendStr (var s: String; const Source: String);
begin
  Insert (Source, s, Length (s) + 1)
end;

procedure StrCut (var s: String; MaxLength: Integer);
begin
  if Length (s) > MaxLength then Delete (s, MaxLength + 1)
end;

function StrCount (const SubStr: String; s: String): Integer;
var c, p: Integer;
begin
  if SubStr = '' then
    StrCount := 0
  else
    begin
      c := 0;
      p := 1;
      repeat
        p := PosFrom (SubStr, s, p);
        if p <> 0 then
          begin
            Inc (c);
            Inc (p, Length (SubStr))
          end
      until p = 0;
      StrCount := c
    end
end;

function StrReplace (const s, Source, Dest: String) = Result: TString;
var c: Integer;
begin
  Result := s;
  for c := Length (Result) - Length (Source) + 1 downto 1 do
    if Copy (Result, c, Length (Source)) = Source then
      begin
        Delete (Result, c, Length (Source));
        Insert (Dest, Result, c)
      end
end;

function Char2Boolean (ch: Char; var Dest: Boolean): Boolean;
begin
  Char2Boolean := True;
  Dest := False;
  if ch in CharactersTrue then
    Dest := True
  else if not (ch in CharactersFalse) then
    Char2Boolean := False
end;

function Char2Digit (ch: Char): Integer;
begin
  case ch of
    '0' .. '9': Char2Digit := Ord (ch) - Ord ('0');
    'A' .. 'Z': Char2Digit := Ord (ch) - Ord ('A') + $a;
    'a' .. 'z': Char2Digit := Ord (ch) - Ord ('a') + $a;
    else        Char2Digit := -1
  end
end;

function QuoteStringEscape (const s: String; EscapeChar: Char; QuoteHigh: Boolean): TString;
var
  q, t: TString;
  i, n: Integer;
  Chars: set of Char;
begin
  Chars := [#0 .. Pred (' '), EscapeChar, '='];
  if QuoteHigh then Chars := Chars + [#127 .. High (Char)];
  q := s;
  i := 0;
  repeat
    i := CharPosFrom (Chars, q, i + 1);
    if i = 0 then Break;
    n := Ord (q[i]);
    t := NumericBaseDigitsUpper[n div $10] + NumericBaseDigitsUpper[n mod $10];
    Insert (t, q, i + 1);
    q[i] := '=';
    Inc (i, Length (t))
  until False;
  QuoteStringEscape := q
end;

function QuoteString (const s: String): TString;
begin
  QuoteString := '"' + QuoteStringEscape (s, '"', True) + '"'
end;

function QuoteEnum (const s: String): TString;
begin
  QuoteEnum := QuoteStringEscape (s, ',', True)
end;

function UnQPString (var s: String): Boolean;
var i, j: Integer;
begin
  UnQPString := True;
  repeat
    i := Pos (' ' + NewLine, s);
    if i = 0 then Break;
    j := i;
    while (j > 1) and (s[j - 1] = ' ') do Dec (j);
    Delete (s, j, i - j + 1)
  until False;
  i := 0;
  repeat
    i := PosFrom ('=', s, i + 1);
    if i = 0 then Break;
    if (i <= Length (s) - 2) and (s[i + 1] in ['0' .. '9', 'A' .. 'F', 'a' .. 'f'])
                             and (s[i + 2] in ['0' .. '9', 'A' .. 'F', 'a' .. 'f']) then
      begin
        s[i] := Chr ($10 * Char2Digit (s[i + 1]) + Char2Digit (s[i + 2]));
        Delete (s, i + 1, 2)
      end
    else if (i <= Length (s) - 1) and (s[i + 1] = NewLine) then
      begin
        Delete (s, i, 2);
        Dec (i)
      end
    else
      UnQPString := False
  until False
end;

function ShellQuoteString (const s: String) = Res: TString;
var
  i: Integer;
  ch: Char;
begin
  if (s <> '') and (s[1] = '''') then
    ch := '"'
  else
    ch := '''';
  Res := ch;
  for i := 1 to Length (s) do
    begin
      if (s[i] = ch) or ((ch = '"') and (s[i] in ['$', '`'])) then
        begin
          Res := Res + ch;
          if ch = '''' then ch := '"' else ch := '''';
          Res := Res + ch
        end;
      Res := Res + s[i]
    end;
  Res := Res + ch
end;

function UnQuoteString (var s: String): Boolean;
begin
  UnQuoteString := False;
  if (Length (s) < 2) or (s[1] <> '"') or (s[Length (s)] <> '"') then Exit;
  Delete (s, 1, 1);
  Delete (s, Length (s));
  UnQuoteString := UnQPString (s)
end;

function ExpandTabs (var s: String; TabSize: Integer): Boolean;
const chTab = #9;
var i, TabSpaces: Integer;
begin
  ExpandTabs := True;
  repeat
    i := Pos (chTab, s);
    if i = 0 then Break;
    TabSpaces := TabSize - (i - 1) mod TabSize;
    if Length (s) + TabSpaces - 1 > High (s) then
      begin
        ExpandTabs := False;
        Break
      end;
    Delete (s, i, 1);
    Insert (StringOfChar (' ', TabSpaces), s, i)
  until False
end;

function ExpandCEscapeSequences (const s: String; RemoveQuoteChars, AllowOctal: Boolean) = r: TString;
const chEsc = #27;
var
  i, c, Digit, v: Integer;
  DelFlag: Boolean;
begin
  r := s;
  i := 1;
  while i < Length (r) do
    begin
      if r[i] = '\' then
        begin
          DelFlag := True;
          case r[i + 1] of
            'n': r[i + 1] := "\n";
            't': r[i + 1] := "\t";
            'r': r[i + 1] := "\r";
            'f': r[i + 1] := "\f";
            'b': r[i + 1] := "\b";
            'v': r[i + 1] := "\v";
            'a': r[i + 1] := "\a";
            'e',
            'E': r[i + 1] := chEsc;
            'x': begin
                   v := 0;
                   c := 2;
                   while i + c <= Length (r) do
                     begin
                       Digit := Char2Digit (r[i + c]);
                       if (Digit < 0) or (Digit >= $10) then Break;
                       v := $10 * v + Digit;
                       Inc (c)
                     end;
                   Delete (r, i + 1, c - 2);
                   r[i + 1] := Chr (v)
                 end;
            '0' .. '7' :
                 if AllowOctal then
                   begin
                     v := 0;
                     c := 1;
                     repeat
                       v := 8 * v + Ord (r[i + c]) - Ord ('0');
                       Inc (c)
                     until (i + c > Length (r)) or (c > 3) or not (r[i + c] in ['0' .. '7']);
                     Delete (r, i + 1, c - 2);
                     r[i + 1] := Chr (v)
                   end
                 else
                   DelFlag := False;
            else DelFlag := False
          end;
          if DelFlag or RemoveQuoteChars then
            Delete (r, i, 1)
          else
            Inc (i)
        end;
      Inc (i)
    end
end;

procedure AllocateTPStrings (var Strings: TPStrings; Size: Integer);
var i: Cardinal;
begin
  for i := 1 to Strings.Count do
    begin
      New (Strings[i], Max (1, Size));
      Strings[i]^ := ''
    end
end;

procedure ClearTPStrings (var Strings: TPStrings);
var i: Cardinal;
begin
  for i := 1 to Strings.Count do Strings[i]^ := ''
end;

function TokenizeString (const Source: String; Separators: CharSet) = Res: PPStrings;
var n: Integer;

  procedure ScanString;
  var i, TokenStart: Integer;
  begin
    n := 0;
    TokenStart := 1;
    for i := 1 to Length (Source) do
      if Source[i] in Separators then
        begin
          Inc (n);
          if Res <> nil then Res^[n] := NewString (Copy (Source, TokenStart, i - TokenStart));
          TokenStart := i + 1
        end;
    if TokenStart <= Length (Source) then  { ignore trailing separator }
      begin
        Inc (n);
        if Res <> nil then Res^[n] := NewString (Copy (Source, TokenStart))
      end
  end;

begin
  Res := nil;
  ScanString;  { count tokens }
  New (Res, n);
  if n <> 0 then ScanString  { assign tokens }
end;

function ShellTokenizeString (const s: String; var ErrMsg: String) = Tokens: PPStrings;
var
  TokenCount, i: Integer;
  Quoting: Char;
  SuppressEmptyToken, AddChar: Boolean;
  r: TString;

  procedure NextToken;
  var
    c: Integer;
    NewTokens: PPStrings;
  begin
    if (r = '') and SuppressEmptyToken then Exit;
    New (NewTokens, TokenCount + 1);
    for c := 1 to TokenCount do NewTokens^[c] := Tokens^[c];
    NewTokens^[TokenCount + 1] := NewString (r);
    Dispose (Tokens);
    Tokens := NewTokens;
    Inc (TokenCount);
    r := '';
    SuppressEmptyToken := True
  end;

begin
  if @ErrMsg <> nil then ErrMsg := '';
  Tokens := nil;
  TokenCount := 0;
  r := '';
  SuppressEmptyToken := True;
  Quoting := #0;
  for i := 1 to Length (s) do
    begin
      AddChar := True;
      case s[i] of
        '"',
        '''': if Quoting = #0 then
                begin
                  Quoting := s[i];
                  SuppressEmptyToken := False;
                  AddChar := False
                end
              else if Quoting = s[i] then
                begin
                  Quoting := #0;
                  AddChar := False
                end;
        ' ' : if Quoting = #0 then
                begin
                  NextToken;
                  AddChar := False
                end;
      end;
      if AddChar then r := r + s[i]
    end;
  NextToken;
  if Quoting <> #0 then
    begin
      if @ErrMsg <> nil then ErrMsg := 'Missing ' + Quoting;
      DisposePPStrings (Tokens);
      Tokens := nil
    end
end;

procedure StrSkipSpaces (const s: String; var i: Integer);
begin
  while (i >= 1) and (i <= Length (s)) and (s[i] in SpaceCharacters) do Inc (i)
end;

function StrReadQuoted (const s: String; var i: Integer; var Dest: String): Boolean;
var
  j: Integer;
  s1: TString;
begin
  StrReadQuoted := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i >= Length (s)) or (s[i] <> '"') then Exit;
  j := PosFrom ('"', s, i + 1);
  if j = 0 then Exit;
  s1 := s[i .. j];
  i := j + 1;
  if not UnQuoteString (s1) or (Length (s1) > Dest.Capacity) then Exit;
  Dest := s1;
  StrReadQuoted := True
end;

function StrReadDelimited (const s: String; var i: Integer; var Dest: String; Delimiter: Char): Boolean;
var j: Integer;
begin
  StrReadDelimited := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i >= Length (s)) or (s[i] <> Delimiter) then Exit;
  j := PosFrom (Delimiter, s, i + 1);
  if (j = 0) or (j - i - 1 > Dest.Capacity) then Exit;
  Dest := Copy (s, i + 1, j - i - 1);
  i := j + 1;
  StrReadDelimited := True
end;

function StrReadWord (const s: String; var i: Integer; var Dest: String): Boolean;
var j: Integer;
begin
  StrReadWord := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i > Length (s)) then Exit;
  j := CharPosFrom (SpaceCharacters + [','], s, i + 1);
  if j = 0 then j := Length (s) + 1;
  if j - i > Dest.Capacity then Exit;
  Dest := Copy (s, i, j - i);
  i := j;
  StrReadWord := True
end;

function StrReadConst (const s: String; var i: Integer; const Expected: String) = Res: Boolean;
begin
  StrSkipSpaces (s, i);
  Res := (i >= 1) and (Copy (s, i, Length (Expected)) = Expected);
  if Res then Inc (i, Length (Expected))
end;

function StrReadComma (const s: String; var i: Integer) = Res: Boolean;
begin
  StrSkipSpaces (s, i);
  Res := (i >= 1) and (i <= Length (s)) and (s[i] = ',');
  if Res then Inc (i)
end;

function StrReadInt (const s: String; var i: Integer; var Dest: Integer): Boolean;
var j, e: Integer;
begin
  StrReadInt := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i > Length (s)) then Exit;
  j := i + 1;  { This is so Val gets at least one character. Also, a possible
                 `-' sign is covered here, and does not have to be included
                 in the set in the following statement. }
  while (j <= Length (s)) and (s[j] in ['0' .. '9']) do Inc (j);
  Val (s[i .. j - 1], Dest, e);
  if e <> 0 then Exit;
  i := j;
  StrReadInt := True
end;

function StrReadReal (const s: String; var i: Integer; var Dest: Real): Boolean;
var j, e: Integer;
begin
  StrReadReal := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i > Length (s)) then Exit;
  j := i + 1;  { This is so Val gets at least one character. Also, a possible
                 `-' sign is covered here, and does not have to be included
                 in the set in the following statement. }
  while (j <= Length (s)) and (s[j] in ['0' .. '9', '+', '-', '.', 'E', 'e']) do Inc (j);
  Val (s[i .. j - 1], Dest, e);
  if e <> 0 then Exit;
  i := j;
  StrReadReal := True
end;

function StrReadBoolean (const s: String; var i: Integer; var Dest: Boolean): Boolean;
begin
  StrReadBoolean := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i > Length (s)) or not Char2Boolean (s[i], Dest) then Exit;
  Inc (i);
  StrReadBoolean := True
end;

function StrReadEnum (const s: String; var i: Integer; var Dest: Integer; const IDs: array of PString): Boolean;
var
  c, j: Integer;
  s1: TString;
begin
  StrReadEnum := False;
  StrSkipSpaces (s, i);
  if (i < 1) or (i > Length (s)) then Exit;
  j := PosFrom (',', s, i);
  if j = 0 then j := Length (s) + 1;
  s1 := Copy (s, i, j - i);
  if not UnQPString (s1) then Exit;
  c := 0;
  while (c <= High (IDs)) and (s1 <> IDs[c]^) do Inc (c);
  if c > High (IDs) then Exit;
  Dest := c;
  i := j;
  StrReadEnum := True
end;

function HashString (const s: String): THash;
var Hash, i: THash;
begin
  Hash := Length (s);
  for i := 1 to Length (s) do
    {$local R-} Hash := Hash shl 2 + Ord (s[i]); {$endlocal}
  HashString := Hash
end;

function NewStrHashTable (Size: Cardinal; CaseSensitive: Boolean) = HashTable: PStrHashTable;
var i: Cardinal;
begin
  SetReturnAddress (ReturnAddress (0));
  New (HashTable, Max (1, Size));
  RestoreReturnAddress;
  HashTable^.CaseSensitive := CaseSensitive;
  for i := 0 to HashTable^.Size - 1 do HashTable^.Table[i] := nil
end;

procedure AddStrHashTable (HashTable: PStrHashTable; s: String; i: Integer; p: Pointer);
var
  Hash: THash;
  pl: PStrHashList;
begin
  if not HashTable^.CaseSensitive then LoCaseString (s);
  Hash := HashString (s) mod HashTable^.Size;
  SetReturnAddress (ReturnAddress (0));
  New (pl);
  pl^.s := NewString (s);
  pl^.i := i;
  pl^.p := p;
  pl^.Next := HashTable^.Table[Hash];
  HashTable^.Table[Hash] := pl;
  RestoreReturnAddress
end;

procedure DeleteStrHashTable (HashTable: PStrHashTable; s: String);
var
  Hash: THash;
  pl: PStrHashList;
  ppl: ^PStrHashList;
begin
  if not HashTable^.CaseSensitive then LoCaseString (s);
  Hash := HashString (s) mod HashTable^.Size;
  ppl := @HashTable^.Table[Hash];
  while (ppl^ <> nil) and (ppl^^.s^ <> s) do ppl := @ppl^^.Next;
  if ppl^ <> nil then
    begin
      pl := ppl^;
      ppl^ := pl^.Next;
      Dispose (pl^.s);
      Dispose (pl)
    end
end;

function SearchStrHashTable (HashTable: PStrHashTable; const s: String; var p: Pointer): Integer;
var
  Hash: THash;
  pl: PStrHashList;
  ps: ^const String;
  sl: String (Length (s));
begin
  if HashTable^.CaseSensitive then
    ps := @s
  else
    begin
      sl := LoCaseStr (s);
      ps := @sl
    end;
  Hash := HashString (ps^) mod HashTable^.Size;
  pl := HashTable^.Table[Hash];
  while (pl <> nil) and (pl^.s^ <> ps^) do pl := pl^.Next;
  if pl = nil then
    begin
      if @p <> nil then p := nil;
      SearchStrHashTable := 0
    end
  else
    begin
      if @p <> nil then p := pl^.p;
      SearchStrHashTable := pl^.i
    end
end;

procedure StrHashTableUsage (HashTable: PStrHashTable; var Entries, Slots: Integer);
var
  i: Integer;
  pl: PStrHashList;
begin
  Entries := 0;
  Slots := 0;
  for i := 0 to HashTable^.Size - 1 do
    begin
      pl := HashTable^.Table[i];
      if pl <> nil then
        begin
          Inc (Slots);
          while pl <> nil do
            begin
              Inc (Entries);
              pl := pl^.Next
            end
        end
    end
end;

procedure DisposeStrHashTable (HashTable: PStrHashTable);
var
  i: Cardinal;
  pl, pt: PStrHashList;
begin
  for i := 0 to HashTable^.Size - 1 do
    begin
      pl := HashTable^.Table[i];
      HashTable^.Table[i] := nil;
      while pl <> nil do
        begin
          pt := pl;
          pl := pl^.Next;
          Dispose (pt^.s);
          Dispose (pt)
        end
    end;
  Dispose (HashTable)
end;

end.
