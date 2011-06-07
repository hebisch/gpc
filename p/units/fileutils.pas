{ Some routines for file and directory handling on a higher level
  than those provided by the RTS.

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

unit FileUtils;

interface

uses GPC;

type
  TStringProc = procedure (const s: String);

{ Finds all files matching the given Mask in the given Directory and
  all subdirectories of it. The matching is done using all wildcards
  and brace expansion, like MultiFileNameMatch does. For each file
  found, FileAction is executed. For each directory found (including
  `.' and `..' if they match the Mask!), DirAction is executed. If
  MainDirFirst is True, this happens before processing the files in
  the directory and below, otherwise afterwards. (The former is
  useful, e.g., if this is used to copy a directory tree and
  DirAction does a MkDir, while the latter behaviour is required
  when removing a directory tree and DirAction does a RmDir.) Both
  FileAction and DirAction can be nil in which case nothing is done
  for files or directories found, respectively. (If DirAction is
  nil, the value of DirsFirst does not matter.) Of course,
  FileAction and DirAction may also be identical. The procedure
  leaves InOutRes set in case of any error. If FileAction or
  DirAction return with InOutRes set, FindFiles recognizes this and
  returns immediately. }
procedure FindFiles (const Directory, Mask: String; MainDirFirst: Boolean;
                     FileAction, DirAction: TStringProc); attribute (iocritical);

{ Creates the directory given by Path and all directories in between
  that are necessary. Does not report an error if the directory
  already exists, but, of course, if it cannot be created because of
  missing permissions or because Path already exists as a file. }
procedure MkDirs (const Path: String); attribute (iocritical);

{ Removes Path if empty as well as any empty parent directories.
  Does not report an error if the directory is not empty. }
procedure RmDirs (const Path: String); attribute (iocritical);

{ Copies the file Source to Dest, overwriting Dest if it exists and
  can be written to. Returns any errors in IOResult. If Mode >= 0,
  it will change the permissions of Dest to Mode immediately after
  creating it and before writing any data to it. That's useful,
  e.g., if Dest is not meant to be world-readable, because if you'd
  do a ChMod after FileCopy, you might leave the data readable
  (depending on the umask) during the copying. If Mode < 0, Dest
  will be set to the same permissions Source has. In any case, Dest
  will be set to the modification time of Source after copying. On
  any error, the destination file is erased. This is to avoid
  leaving partial files in case of full file systems (one of the
  most common reasons for errors). }
procedure FileCopy (const Source, Dest: String; Mode: Integer); attribute (iocritical);

{ Creates a backup of FileName in the directory BackupDirectory or,
  if BackupDirectory is empty, in the directory of FileName. Errors
  are returned in IOResult (and on any error, no partial backup file
  is left), but if FileName does not exist, this does *not* count as
  an error (i.e., BackupFile will just return without setting
  IOResult then). If OnlyUserReadable is True, the backup file will
  be given only user-read permissions, nothing else.

  The name chosen for the backup depends on the Simple and Short
  parameters. The short names will fit into 8+3 characters (whenever
  possible), while the long ones conform to the conventions used by
  most GNU tools. If Simple is True, a simple backup file name will
  be used, and previous backups under the same name will be
  overwritten (if possible). Otherwise, backups will be numbered,
  where the number is chosen to be larger than all existing backups,
  so it will be unique and increasing in chronological order. In
  particular:

  Simple  Short  Backup name
  True    True   Base name of FileName plus '.bak'
  False   True   Base name of FileName plus '.b' plus a number
  True    False  Base name plus extension of FileName plus '~'
  False   False  Base name plus extension of FileName plus '.~', a
                 number and '~' }
procedure BackupFile (const FileName, BackupDirectory: String; Simple, Short, OnlyUserReadable: Boolean); attribute (iocritical);

implementation

procedure FindFiles (const Directory, Mask: String; MainDirFirst: Boolean;
                     FileAction, DirAction: TStringProc);
var
  Dir: DirPtr;
  FileName, FullName: TString;
begin
  Dir := OpenDir (Directory);
  while InOutRes = 0 do
    begin
      FileName := ReadDir (Dir);
      if FileName = '' then Break;
      FullName := Directory + DirSeparator + FileName;
      if DirectoryExists (FullName) then
        begin
          if MainDirFirst and (@DirAction <> nil) and MultiFileNameMatch (Mask, FileName) then
            DirAction (FullName);
          if (InOutRes = 0) and (FileName <> DirSelf) and (FileName <> DirParent) then
            FindFiles (FullName, Mask, MainDirFirst, FileAction, DirAction);
          if not MainDirFirst and (@DirAction <> nil) and MultiFileNameMatch (Mask, FileName) then
            DirAction (FullName)
        end
      else
        if (@FileAction <> nil) and MultiFileNameMatch (Mask, FileName) then
          FileAction (FullName)
    end;
  CloseDir (Dir)
end;

procedure MkDirs (const Path: String);
var NewPath: TString;
begin
  if InOutRes <> 0 then Exit;
  NewPath := DirFromPath (RemoveDirSeparator (Path));
  if NewPath <> Path then MkDirs (NewPath);
  if not DirectoryExists (Path) then MkDir (Path)
end;

procedure RmDirs (const Path: String);
var NewPath: TString;
begin
  if InOutRes <> 0 then Exit;
  RmDir (Path);
  { We use IOResult which clears the error status because an
    error here should not be reported to the caller because
    RmDir will fail for the first non-empty parent directory. }
  if IOResult = 0 then
    begin
      NewPath := DirFromPath (RemoveDirSeparator (Path));
      if NewPath <> Path then RmDirs (NewPath)
    end
end;

procedure FileCopy (const Source, Dest: String; Mode: Integer);
var
  Buf: array [1 .. $10000] of Byte;
  BytesRead: SizeType;
  f, g: File;
  b: BindingType;
  i: Integer;
begin
  if InOutRes <> 0 then Exit;
  SetReturnAddress (ReturnAddress (0));
  Assign (f, Source);
  Reset (f, 1);
  b := Binding (f);
  Assign (g, Dest);
  Rewrite (g, 1);
  RestoreReturnAddress;
  if Mode < 0 then Mode := b.Mode;
  ChMod (g, Mode);
  while not EOF (f) and (InOutRes = 0) do
    begin
      BlockRead (f, Buf, SizeOf (Buf), BytesRead);
      BlockWrite (g, Buf, BytesRead)
    end;
  Close (f);
  SetFileTime (g, GetUnixTime (Null), b.ModificationTime);
  Close (g);
  if InOutRes <> 0 then
    begin
      i := IOResult;
      Erase (g);
      InOutRes := i
    end
end;

procedure BackupFile (const FileName, BackupDirectory: String; Simple, Short, OnlyUserReadable: Boolean);
var
  c, j, nr, r, Mode: Integer;
  BackupPath, p, p1, p2, n, e, g: TString;
  Buf: GlobBuffer;
begin
  if (InOutRes <> 0) or not FileExists (FileName) then Exit;
  if OSDosFlag then
    Short := True;
  FSplit (FileName, p, n, e);
  if BackupDirectory <> '' then
    p := ForceAddDirSeparator (BackupDirectory);
  if Short then
    p := p + n
  else
    p := p + n + e;
  if Simple then
    if Short then
      BackupPath := p + '.bak'
    else
      BackupPath := p + '~'
  else
    begin
      if Short then
        begin
          p1 := p + '.b';
          p2 := ''
        end
      else
        begin
          p1 := p + '.~';
          p2 := '~'
        end;
      c := 0;
      Glob (Buf, QuoteFileName (p1, WildCardChars) + '*' + p2);
      for j := 1 to Buf.Result^.Count do
        begin
          g := Buf.Result^[j]^;
          if IsPrefix (p1, g) then
            begin
              Delete (g, 1, Length (p1));
              if IsSuffix (p2, g) then
                begin
                  Delete (g, Length (g) - Length (p2) + 1);
                  Val (g, nr, r);
                  if r = 0 then c := Max (c, nr)
                end
            end
        end;
      GlobFree (Buf);
      repeat
        Inc (c);
        BackupPath := p1 + StringOfChar ('0', Ord (Short and (c < 10))) + Integer2String (c) + p2
      until not FileExists (BackupPath)
    end;
  if OnlyUserReadable then
    Mode := fm_UserReadable
  else
    Mode := -1;
  SetReturnAddress (ReturnAddress (0));
  FileCopy (FileName, BackupPath, Mode);
  RestoreReturnAddress
end;

end.
