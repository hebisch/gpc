{ Some routines to support writing programs portable between Dos and
  Unix. Perhaps it would be a good idea not to put features to make
  Dos programs Unix-compatible (shell redirections) and vice versa
  (reading Dos files from Unix) together into one unit, but rather
  into two units, DosCompat and UnixCompat or so -- let's wait and
  see, perhaps when more routines suited for this/these unit(s) will
  be found, the design will become clearer ...

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
  General Public License. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030412}
{$error This unit requires GPC release 20030412 or newer.}
{$endif}

unit DosUnix;

interface

uses GPC;

{ This function is meant to be used when you want to invoke a system
  shell command (e.g. via Execute or Exec from the Dos unit) and
  want to specify input/output redirections for the command invoked.
  It caters for the different syntax between DJGPP (with the `redir'
  utility) and other systems.

  To use it, code your redirections in bash style (see the table
  below) in your command line string, pass this string to this
  function, and the function's result to Execute or the other
  routines.

  The function translates the following bash style redirections
  (characters in brackets are optional) into a redir call under Dos
  systems except EMX, and leave them unchanged under other systems.
  Note: `redir' comes with DJGPP, but it should be possible to
  install it on other Dos systems as well. OS/2's shell, however,
  supports bash style redirections, I was told, so we don't
  translate on EMX.

  [0]<     file      redirect standard input from file
  [1]>[|]  file      redirect standard output to file
  [1]>>    file      append standard output to file
  [1]>&2             redirect standard output to standard error
  2>[|]    file      redirect standard error to file
  2>>      file      append standard error to file
  2>&1               redirect standard error to standard output
  &> file            redirect both standard output and standard
                     error to file }
function  TranslateRedirections (const Command: String) = s: TString;

{ Under Unix, translates CR/LF pairs to single LF characters when
  reading from f, and back when writing to f. Under Dos, does
  nothing because the run time system alrady does this job. In the
  result, you can read both Dos and Unix files, and files written
  will be Dos. }
procedure AssignDos (var f: AnyFile; const FileName: String);

{ Translates a character from the "OEM" charset used under Dos to
  the ISO-8859-1 (Latin1) character set. }
function  OEM2Latin1 (ch: Char): Char;
function  OEM2Latin1Str (const s: String) = r: TString;

{ Translates a character from the ISO-8859-1 (Latin1) character set
  to the "OEM" charset used under Dos. }
function  Latin12OEM (ch: Char): Char;
function  Latin12OEMStr (const s: String) = r: TString;

implementation

function TranslateRedirections (const Command: String) = s: TString;
{$if defined (__OS_DOS__) and not defined (__EMX__)}
const
  FileNameChars = ['A'..'Z', 'a'..'z', '0'..'9', '_', '/', '\', ':', '.', ',', '+', '-', '=', '!', '$', '?', '*', '[', ']', '~', '^', '%', '"', '''', '`', '#', #128..#255];

var
  i, k: Integer;
  Redir: TString;
  Redirs: (RNone, ROut, RErr, RBoth, ROutErr, RErrOut);
  AppendFlag: Boolean;
  InString: Char;

  procedure GetFileName;
  var j: Integer;
  begin
    j := k;
    while (j <= Length (s)) and (s[j] in [' ', #9]) do Inc (j);
    k := j;
    while (k <= Length (s)) and (s[k] in FileNameChars) do Inc (k);
    Redir := Redir + ' ' + Copy (s, j, k - j) + ' '
  end;

begin
  s := Command;
  Redir := '';
  InString := #0;
  i := 1;
  while i <= Length (s) do
    begin
      {$local R-} s[Length (s) + 1] := #0; {$endlocal}
      while (i <= Length (s)) and ((InString <> #0) or not (s[i] in ['<', '>'])) do
        begin
          if InString <> #0 then
            begin
              if s[i] = InString then
                InString := #0
            end
          else if s[i] in ['"', ''''] then
            InString := s[i];
          Inc (i)
        end;
      if i <= Length (s) then
        begin
          if s[i] = '<' then
            begin
              k := i + 1;
              if (i > 1) and (s[i - 1] = '0') then Dec (i);
              Redir := Redir + '-i';
              GetFileName
            end
          else
            begin
              Redirs := ROut;
              AppendFlag := False;
              k := i + 1;
              if i > 1 then
                case s[i - 1] of
                  '1': Dec (i);
                  '2': begin
                         Redirs := RErr;
                         Dec (i)
                       end;
                  '&': begin
                         Redirs := RBoth;
                         Dec (i)
                       end;
                end;
              if s[k] = '>' then
                begin
                  AppendFlag := True;
                  Inc (k)
                end;
              if s[k] = '|' then Inc (k);
              if s[k] = '&' then
                begin
                  Inc (k);
                  case s[k] of
                    '1': begin
                           if Redirs = RErr then
                             Redirs := RErrOut
                           else
                             Redirs := RNone;
                           Inc (k)
                         end;
                    '2': begin
                           if Redirs = ROut then
                             Redirs := ROutErr
                           else
                             Redirs := RNone;
                           Inc (k)
                         end;
                    else Redirs := RBoth
                  end
                end;
              case Redirs of
                ROut,
                RErr,
                RBoth  : begin
                           if Redirs = RErr then
                             Redir := Redir + '-e'
                           else
                             Redir := Redir + '-o';
                           if AppendFlag then Redir := Redir + 'a';
                           GetFileName;
                           if Redirs = RBoth then Redir := Redir + '-eo '
                         end;
                ROutErr: Redir := Redir + '-oe ';
                RErrOut: Redir := Redir + '-eo ';
              end
            end;
          Delete (s, i + 1, k - i - 1);
          s[i] := ' '
        end
    end;
  if Redir <> '' then s := 'redir ' + Redir + s
end;
{$else}
begin
  s := Command
end;
{$endif}

type
  TAssignDosData = record
    f: File;
    PendingChar: Integer
  end;

procedure AssignDosOpen (var PrivateData; Mode: TOpenMode);
var Data: TAssignDosData absolute PrivateData;
begin
  case Mode of
    fo_Rewrite: Rewrite (Data.f, 1);
    fo_Append : Append  (Data.f, 1);
    else        Reset   (Data.f, 1)
  end
end;

function AssignDosSelectFunc (var PrivateData; Writing: Boolean): Integer;
var Data: TAssignDosData absolute PrivateData;
begin
  Discard (Writing);
  AssignDosSelectFunc := FileHandle (Data.f)
end;

function AssignDosRead (var PrivateData; var Buffer; Size: SizeType) = BytesRead: SizeType;
var
  Data: TAssignDosData absolute PrivateData;
  CharBuf: array [1 .. Size] of Char absolute Buffer;
  i, j: SizeType;
  Temp: Char;
begin
  repeat
    BlockRead (Data.f, Buffer, Size - Ord ((Size > 1) and (Data.PendingChar >= 0)), BytesRead);
    if (InOutRes <> 0) or (BytesRead <= 0) then Exit;
    if Data.PendingChar >= 0 then
      if Size > 1 then
        begin
          for i := BytesRead downto 1 do CharBuf[i + 1] := CharBuf[i];
          CharBuf[1] := Chr (Data.PendingChar);
          Data.PendingChar := -1;
          Inc (BytesRead)
        end
      else if (Data.PendingChar = 13) and (CharBuf[1] = #10) then
        Data.PendingChar := -1
      else
        begin
          Temp := Chr (Data.PendingChar);
          Data.PendingChar := Ord (CharBuf[1]);
          CharBuf[1] := Temp
        end;
    i := 1;
    j := 0;
    while (i < BytesRead) or ((i = BytesRead) and ((CharBuf[i] <> #13) or (Data.PendingChar >= 0))) do
      begin
        if (CharBuf[i] = #13) and (CharBuf[i + 1] = #10) then Inc (i);
        Inc (j);
        CharBuf[j] := CharBuf[i];
        Inc (i)
      end;
    if i = BytesRead then Data.PendingChar := Ord (CharBuf[i]);
    BytesRead := j
  until BytesRead > 0
end;

function AssignDosWrite (var PrivateData; const Buffer; Size: SizeType) = BytesWritten: SizeType;
var
  Data: TAssignDosData absolute PrivateData;
  CharBuf: array [1 .. Size] of Char absolute Buffer;
  NewBuf: array [1 .. 2 * Size] of Char;
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Size do
    begin
      if CharBuf[i] = #10 then
        begin
          Inc (j);
          NewBuf[j] := #13
        end;
      Inc (j);
      NewBuf[j] := CharBuf[i]
    end;
  BlockWrite (Data.f, NewBuf, j, BytesWritten);
  if (InOutRes = 0) and (BytesWritten > 0) then BytesWritten := Max (0, BytesWritten + Size - j)
end;

procedure AssignDosFlush (var PrivateData);
var Data: TAssignDosData absolute PrivateData;
begin
  Flush (Data.f)
end;

procedure AssignDosClose (var PrivateData);
var Data: TAssignDosData absolute PrivateData;
begin
  Close (Data.f)
end;

procedure AssignDosDone (var PrivateData);
begin
  Dispose (@PrivateData)
end;

procedure AssignDos (var f: AnyFile; const FileName: String);
begin
  SetReturnAddress (ReturnAddress (0));
  Assign (f, FileName);
  {$ifndef __OS_DOS__}
  var Data: ^TAssignDosData;
  New (Data);
  Data^.PendingChar := -1;
  Assign (Data^.f, FileName);
  AssignTFDD (f, AssignDosOpen, AssignDosSelectFunc, nil, AssignDosRead, AssignDosWrite, AssignDosFlush, AssignDosClose, AssignDosDone, Data);
  {$endif}
  RestoreReturnAddress
end;

function OEM2Latin1 (ch: Char): Char;
const
  OEM2Latin1Table: array [#$80 .. #$ff] of Char =
    (#$c7, #$fc, #$e9, #$e2, #$e4, #$e0, #$e5, #$e7,   { 80 .. 87 }
     #$ea, #$eb, #$e8, #$ef, #$ee, #$ec, #$c4, #$c5,   { 88 .. 8f }
     #$c9, #$e6, #$c6, #$f4, #$f6, #$f2, #$fb, #$f9,   { 90 .. 97 }
     #$ff, #$d6, #$dc, #$f8, #$a3, #$d8, #$d7, #$83,   { 98 .. 9f }
     #$e1, #$ed, #$f3, #$fa, #$f1, #$d1, #$aa, #$ba,   { a0 .. a7 }
     #$bf, #$ae, #$ac, #$bd, #$bc, #$a1, #$ab, #$bb,   { a8 .. af }
     #$a6, #$a6, #$a6, #$a6, #$a6, #$c1, #$c2, #$c0,   { b0 .. b7 }
     #$a9, #$a6, #$a6, #$2b, #$2b, #$a2, #$a5, #$2b,   { b8 .. bf }
     #$2b, #$2d, #$2d, #$2b, #$2d, #$2b, #$e3, #$c3,   { c0 .. c7 }
     #$2b, #$2b, #$2d, #$2d, #$a6, #$2d, #$2b, #$a4,   { c8 .. cf }
     #$f0, #$d0, #$ca, #$cb, #$c8, #$69, #$cd, #$ce,   { d0 .. d7 }
     #$cf, #$2b, #$2b, #$a6, #$5f, #$a6, #$cc, #$af,   { d8 .. df }
     #$d3, #$df, #$d4, #$d2, #$f5, #$d5, #$b5, #$fe,   { e0 .. e7 }
     #$de, #$da, #$db, #$d9, #$fd, #$dd, #$af, #$b4,   { e8 .. ef }
     #$ad, #$b1, #$3d, #$be, #$b6, #$a7, #$f7, #$b8,   { f0 .. f7 }
     #$b0, #$a8, #$b7, #$b9, #$b3, #$b2, #$a6, #$a0);  { f8 .. ff }
begin
  if ch >= #$80 then
    OEM2Latin1 := OEM2Latin1Table[ch]
  else
    OEM2Latin1 := ch
end;

function OEM2Latin1Str (const s: String) = r: TString;
var i: Integer;
begin
  r := s;
  for i := 1 to Length (r) do r[i] := OEM2Latin1 (r[i])
end;

function Latin12OEM (ch: Char): Char;
const
  Latin12OEMTable: array [#$80 .. #$ff] of Char =
    (#$3f, #$3f, #$27, #$9f, #$22, #$2e, #$c5, #$ce,   { 80 .. 87 }
     #$5e, #$25, #$53, #$3c, #$4f, #$3f, #$3f, #$3f,   { 88 .. 8f }
     #$3f, #$27, #$27, #$22, #$22, #$07, #$2d, #$2d,   { 90 .. 97 }
     #$7e, #$54, #$73, #$3e, #$6f, #$3f, #$3f, #$59,   { 98 .. 9f }
     #$ff, #$ad, #$bd, #$9c, #$cf, #$be, #$dd, #$f5,   { a0 .. a7 }
     #$f9, #$b8, #$a6, #$ae, #$aa, #$f0, #$a9, #$ee,   { a8 .. af }
     #$f8, #$f1, #$fd, #$fc, #$ef, #$e6, #$f4, #$fa,   { b0 .. b7 }
     #$f7, #$fb, #$a7, #$af, #$ac, #$ab, #$f3, #$a8,   { b8 .. bf }
     #$b7, #$b5, #$b6, #$c7, #$8e, #$8f, #$92, #$80,   { c0 .. c7 }
     #$d4, #$90, #$d2, #$d3, #$de, #$d6, #$d7, #$d8,   { c8 .. cf }
     #$d1, #$a5, #$e3, #$e0, #$e2, #$e5, #$99, #$9e,   { d0 .. d7 }
     #$9d, #$eb, #$e9, #$ea, #$9a, #$ed, #$e8, #$e1,   { d8 .. df }
     #$85, #$a0, #$83, #$c6, #$84, #$86, #$91, #$87,   { e0 .. e7 }
     #$8a, #$82, #$88, #$89, #$8d, #$a1, #$8c, #$8b,   { e8 .. ef }
     #$d0, #$a4, #$95, #$a2, #$93, #$e4, #$94, #$f6,   { f0 .. f7 }
     #$9b, #$97, #$a3, #$96, #$81, #$ec, #$e7, #$98);  { f8 .. ff }
begin
  if ch >= #$80 then
    Latin12OEM := Latin12OEMTable[ch]
  else
    Latin12OEM := ch
end;

function Latin12OEMStr (const s: String) = r: TString;
var i: Integer;
begin
  r := s;
  for i := 1 to Length (r) do r[i] := Latin12OEM (r[i])
end;

end.
