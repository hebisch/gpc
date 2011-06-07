{ A unit to watch the heap, i.e. check if all pointers that were
  allocated are released again. It is meant as a debugging help to
  detect memory leaks.

  Use it in the main program before all other units. When, at the
  end of the program, some pointers that were allocated, have not
  been released, the unit writes a report to StdErr or another file
  (see below). Only pointers allocated via the Pascal mechanisms
  (New, GetMem) are tracked, not pointers allocated with direct libc
  calls or from C code. After a runtime error, pointers are not
  checked.

  Note that many units and libraries allocate memory for their own
  purposes and don't always release it at the end. Therefore, the
  usefulness of this unit is rather limited.

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
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

unit HeapMon;

interface

uses GPC;

{ This unit is automatically activated when used. The following
  declarations are only needed for special purposes. }

{ The report generated at the end can be redirected to a certain
  file by pointing HeapMonOutput to it. If not set, the report will
  be printed to the error messages file given with `--gpc-rts'
  options if given, and StdErr otherwise. }
var
  HeapMonOutput: ^Text = nil;

{ HeapMonReport can be used to print a report on non-released memory
  blocks at an arbitrary point during a program run to the file f.
  It is invoked automatically at the end, so usually you don't have
  to call it. Returns True if any non-released blocks were found,
  False otherwise. }
function HeapMonReport (var f: Text; DoRestoreTerminal: Boolean) = Res: Boolean; attribute (ignorable);

implementation

var
  HeapMonitorMark: Pointer = nil;

function HeapMonReport (var f: Text; DoRestoreTerminal: Boolean) = Res: Boolean;
var
  Count: Integer;
  Size: SizeType;

  procedure CountBlock (aPointer: Pointer; aSize: SizeType; aCaller: Pointer);
  begin
    if not Res then
      begin
        Res := True;
        if DoRestoreTerminal then RestoreTerminal (True);
        WriteLn (f, 'Heap monitor: Pointers not disposed (caller, size):');
        WriteLn (f, ReturnAddr2Hex (aCaller))
      end;
    Inc (Count);
    Inc (Size, aSize);
    WriteLn (f, ReturnAddr2Hex (aCaller), ' ', aSize, ' address: ', PtrCard (aPointer))
  end;

begin
  Res := False;
  Count := 0;
  Size := 0;
  ForEachMarkedBlock (HeapMonitorMark, CountBlock);
  if Res then WriteLn (f, 'Total: ', Count, ' pointers, total size: ', Size)
end;

to begin do
  Mark (HeapMonitorMark);

to end do
  if (HeapMonitorMark <> nil) and (ErrorAddr = nil) then
    begin
      var TmpFile: Text;
      if HeapMonOutput = nil then
        if WriteErrorMessage ('', False) then
          begin
            var p: Pointer;
            p := SuspendMark;
            AssignHandle (TmpFile, RTSErrorFD, True);
            ResumeMark (p);
            Rewrite (TmpFile);
            HeapMonOutput := @TmpFile
          end
        else
          HeapMonOutput := @StdErr;
      var Res: Boolean = HeapMonReport (HeapMonOutput^, True);
      Close (TmpFile);
      if Res then Halt (7)
    end;

end.
