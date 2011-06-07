{ BP compatible binobj utility (store the contents of a file in an
  object file as a single symbol. Another object (of the same name
  with `Size' appended) contains the size of the file.

  gcc is used to create the object file. If the environment variable
  CC is set, its content is used instead of gcc. This can be used
  for cross-building.

  @@ It is not very efficient on large files.

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 3.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA. }

{$gnu-pascal,I+}
{$if __GPC_RELEASE__ < 20030303}
{$error This program requires GPC release 20030303 or newer.}
{$endif}

program BinObj;

uses GPC;

const
  ObjSuffix = '.o';

var
  Source, Dest, TempName, PublicName, Compiler, s: TString;
  BytesRead, i, Status: Integer;
  SrcFile: File;
  TmpFile: Text;
  Buf: array [1 .. $10000] of Byte;

begin
  if (ParamCount = 1) and (ParamStr (1) = '--help') then
    begin
      WriteLn ('binobj for GPC

Copyright (C) 2001-2006 Free Software Foundation, Inc.

This program is part of GPC. GPC is free software; see the source
for copying conditions. There is NO warranty; not even for
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Usage: ', ParamStr (0), ' source[.bin] dest[', ObjSuffix, '] public-name');
      Halt
    end;
  if (ParamCount = 1) and (ParamStr (1) = '--version') then
    begin
      WriteLn ('binobj for GPC');
      WriteLn ('Copyright (C) 2001-2006 Free Software Foundation, Inc.');
      WriteLn ('Report bugs to <gpc@gnu.de>.');
      Halt
    end;
  if ParamCount <> 3 then
    begin
      WriteLn (StdErr, 'Usage: ', ParamStr (0), ' source[.bin] dest[', ObjSuffix, '] public-name');
      Halt (1)
    end;
  Source := ParamStr (1);
  Dest := ParamStr (2);
  if not IsSuffix (ObjSuffix, Dest) then Dest := Dest + ObjSuffix;
  PublicName := ParamStr (3);
  if (PublicName = '')
     or (CharPos ([Low (Char) .. High (Char)] - ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_'], PublicName) <> 0)
     or (PublicName[1] in ['0' .. '9']) then
    begin
      WriteLn (ParamStr (0), ': public-name must be a valid identifier');
      Halt (1)
    end;
  TempName := GetTempFileName;
  {$local I-}
  Reset (SrcFile, Source, 1);
  {$endlocal}
  if IOResult <> 0 then Reset (SrcFile, Source + '.bin', 1);
  Rewrite (TmpFile, TempName);
  WriteLn (TmpFile, 'unsigned char ', PublicName, '[] = {');
  s := '';
  while not EOF (SrcFile) do
    begin
      BlockRead (SrcFile, Buf, SizeOf (Buf), BytesRead);
      for i := 1 to BytesRead do
        begin
          WriteStr (s, s, Buf[i], ',');
          if i mod 32 = 0 then
            begin
              WriteLn (TmpFile, s);
              s := ''
            end
        end
    end;
  WriteLn (TmpFile, s);
  WriteLn (TmpFile, '};');
  WriteLn (TmpFile, 'int ', PublicName, 'Size = sizeof (', PublicName, ');');
  Close (TmpFile);
  Compiler := GetEnv ('CC');
  if Compiler = '' then Compiler := 'gcc';
  Status := Execute (Compiler + ' -x cpp-output -c ' + TempName + ' -o ' + Dest);
  Erase (TmpFile);
  Halt (Status)
end.
