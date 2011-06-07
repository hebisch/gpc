{ Heap management routines

  Copyright (C) 1991-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
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
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}

unit Heap; attribute (name = '_p__rts_Heap');

interface

uses RTSC, Error;

{ GPC implements both Mark/Release and Dispose. Both can be mixed
  freely in the same program. Dispose should be preferred, since
  it's faster. }

{ C heap management routines. NOTE: if Release is used anywhere in
  the program, CFreeMem and CReAllocMem may not be used for pointers
  that were not allocated with CGetMem. }
function  CGetMem     (Size: SizeType): Pointer;                       external name 'malloc';
procedure CFreeMem    (aPointer: Pointer);                             external name 'free';
function  CReAllocMem (aPointer: Pointer; NewSize: SizeType): Pointer; external name 'realloc';

type
  GetMemType     = ^function (Size: SizeType): Pointer;
  FreeMemType    = ^procedure (aPointer: Pointer);
  ReAllocMemType = ^function (aPointer: Pointer; NewSize: SizeType): Pointer;

{ These variables can be set to user-defined routines for memory
  allocation/deallocation. GetMemPtr may return nil when
  insufficient memory is available. GetMem/New will produce a
  runtime error then. }
var
  GetMemPtr    : GetMemType     = @CGetMem;     attribute (name = '_p_GetMemPtr');
  FreeMemPtr   : FreeMemType    = @CFreeMem;    attribute (name = '_p_FreeMemPtr');
  ReAllocMemPtr: ReAllocMemType = @CReAllocMem; attribute (name = '_p_ReAllocMemPtr');

  { Address of the lowest byte of heap used }
  HeapLow: PtrCard = 0; attribute (name = '_p_HeapLow');

  { Address of the highest byte of heap used }
  HeapHigh: PtrCard = 0; attribute (name = '_p_HeapHigh');

  { If set to true, `Dispose' etc. will raise a runtime error if
    given an invalid pointer. }
  HeapChecking: Boolean = False; attribute (name = '_p_HeapChecking');

const
  UndocumentedReturnNil = Pointer (-1);

{@internal}
procedure GPC_Mark     (var aMark: Pointer); attribute (name = '_p_Mark');
procedure GPC_Release  (aMark: Pointer);     attribute (name = '_p_Release');

{ GPC_New, GPC_Dispose and ReAllocMem call the actual routines
  through GetMemPtr, FreeMemPtr and ReAllocMemPtr, and do the stuff
  necessary for Mark and Release. New, GetMem and Dispose, FreeMem
  in a Pascal program will call GPC_New and GPC_Dispose,
  respectively, internally. }
function  GPC_New      (Size: SizeType) = p: Pointer; attribute (name = '_p_New');
procedure GPC_Dispose  (aPointer: Pointer);           attribute (name = '_p_Dispose');

{ The same, but side-stepping Mark and Release. }
function  InternalNew     (Size: SizeType) = p: Pointer; attribute (inline, name = '_p_InternalNew');
procedure InternalDispose (aPointer: Pointer);           attribute (inline, name = '_p_InternalDispose');
{@endinternal}

function  SuspendMark: Pointer;    attribute (name = '_p_SuspendMark');
procedure ResumeMark (p: Pointer); attribute (name = '_p_ResumeMark');

{ Calls the procedure Proc for each block that would be released
  with `Release (aMark)'. aMark must have been marked with Mark. For
  an example of its usage, see the HeapMon unit. }
procedure ForEachMarkedBlock (aMark: Pointer; procedure Proc (aPointer: Pointer; aSize: SizeType; aCaller: Pointer)); attribute (name = '_p_ForEachMarkedBlock');

procedure ReAllocMem (var aPointer: Pointer; NewSize: SizeType); attribute (name = '_p_ReAllocMem');

implementation

type
  PMarkList = ^TMarkList;
  TMarkList = record
    Next, Prev  : PMarkList;
    Marked      : Boolean;
    MaxIndexUsed,
    PointersUsed: Integer;
    Entries     : array [0 .. 255] of record
      Ptr   : Pointer;
      PSize : SizeType;
      Caller: Pointer
    end
  end;

var
  CurrentMarkList: PMarkList = nil; attribute (name = '_p_CurrentMarkList');

function SuspendMark: Pointer;
begin
  SuspendMark := CurrentMarkList;
  CurrentMarkList := nil
end;

procedure ResumeMark (p: Pointer);
begin
  CurrentMarkList := p
end;

procedure GPC_Mark (var aMark: Pointer);
var Temp: PMarkList;
begin
  SetReturnAddress (ReturnAddress (0));
  Temp := GetMemPtr^ (SizeOf (Temp^));  { don't use `New' here! }
  if (Temp = nil) or (Temp = UndocumentedReturnNil) then
    RuntimeErrorInteger (853, SizeOf (Temp^));  { out of heap when allocating %d bytes }
  RestoreReturnAddress;
  Temp^.Next := CurrentMarkList;
  Temp^.Prev := nil;
  if CurrentMarkList <> nil then CurrentMarkList^.Prev := Temp;
  Temp^.MaxIndexUsed := 0;
  Temp^.PointersUsed := 0;
  Temp^.Marked := @aMark <> nil;
  CurrentMarkList := Temp;
  if @aMark <> nil then aMark := Temp  { GPC_New calls GPC_Mark (Null) }
end;

procedure GPC_Release (aMark: Pointer);
var
  Temp: PMarkList;
  i: Integer;
begin
  Temp := CurrentMarkList;
  while (Temp <> nil) and (Temp <> aMark) do Temp := Temp^.Next;
  if Temp = nil then
    begin
      SetReturnAddress (ReturnAddress (0));
      RuntimeErrorInteger (852, PtrCard (aMark));  { address % is not valid for `Release' }
      RestoreReturnAddress
    end;
  repeat
    for i := CurrentMarkList^.MaxIndexUsed - 1 downto 0 do
      if CurrentMarkList^.Entries[i].Ptr <> nil then
        FreeMemPtr^ (CurrentMarkList^.Entries[i].Ptr);
    Temp := CurrentMarkList;
    CurrentMarkList := CurrentMarkList^.Next;
    FreeMemPtr^ (Temp)
  until Temp = aMark;
  if CurrentMarkList <> nil then CurrentMarkList^.Prev := nil
end;

procedure ForEachMarkedBlock (aMark: Pointer; procedure Proc (aPointer: Pointer; aSize: SizeType; aCaller: Pointer));
var
  Temp, Last: PMarkList;
  i: Integer;
begin
  Temp := CurrentMarkList;
  Last := nil;
  while (Temp <> nil) and (Last <> aMark) do
    begin
      for i := Temp^.MaxIndexUsed - 1 downto 0 do
        with Temp^.Entries[i] do
          if Ptr <> nil then Proc (Ptr, PSize, Caller);
      Last := Temp;
      Temp := Temp^.Next
    end
end;

procedure AddHeapRange (p: Pointer; Size: SizeType);
var Address: PtrCard;
begin
  Address := PtrCard (p);
  if (HeapLow = 0) or (Address < HeapLow) then HeapLow := Address;
  Inc (Address, Size - 1);
  if Address > HeapHigh then HeapHigh := Address
end;

procedure AddToMarkList (p: Pointer; Size: SizeType; aCaller: Pointer);
begin
  if CurrentMarkList^.MaxIndexUsed > High (CurrentMarkList^.Entries) then
    GPC_Mark (Null);  { this creates a new TMarkList item }
  with CurrentMarkList^.Entries[CurrentMarkList^.MaxIndexUsed] do
    begin
      Ptr := p;
      PSize := Size;
      Caller := aCaller
    end;
  Inc (CurrentMarkList^.MaxIndexUsed);
  Inc (CurrentMarkList^.PointersUsed)
end;

procedure PrepareDisposePointer (aPointer: Pointer);
var
  p: PMarkList;
  Found: Boolean;
  i: Integer;
begin
  if aPointer = nil then Exit;
  if HeapChecking and ((PtrCard (aPointer) < HeapLow) or (PtrCard (aPointer) > HeapHigh)) then
    RuntimeErrorInteger (858, PtrCard (aPointer));  { attempt to dispose of invalid pointer with address % }
  Found := False;
  p := CurrentMarkList;
  while p <> nil do
    begin
      if p^.MaxIndexUsed <> 0 then
        for i := p^.MaxIndexUsed - 1 downto 0 do
          if p^.Entries[i].Ptr = aPointer then
            begin
              p^.Entries[i].Ptr := nil;
              Dec (p^.PointersUsed);
              if (p^.PointersUsed = 0) and not p^.Marked then
                begin
                  if CurrentMarkList = p then CurrentMarkList := p^.Next;
                  if p^.Prev <> nil then p^.Prev^.Next := p^.Next;
                  if p^.Next <> nil then p^.Next^.Prev := p^.Prev;
                  FreeMemPtr^ (p)
                end
              else if i = p^.MaxIndexUsed - 1 then
                Dec (p^.MaxIndexUsed);
              Found := True;
              Break
            end;
      if Found then Break;  { we have to check this here, because then p might already be invalid }
      p := p^.Next
    end
end;

function InternalNew (Size: SizeType) = p: Pointer;
begin
  p := GetMemPtr^ (Size);
  if (p = nil) and (Size <> 0) then
    begin
      SetReturnAddress (ReturnAddress (0));
      RuntimeErrorInteger (853, Size);  { out of heap when allocating %d bytes }
      RestoreReturnAddress
    end;
  if p = UndocumentedReturnNil then Return nil;
  AddHeapRange (p, Size)
end;

procedure InternalDispose (aPointer: Pointer);
begin
  if aPointer <> nil then FreeMemPtr^ (aPointer)
end;

function GPC_New (Size: SizeType) = p: Pointer;
begin
  p := InternalNew (Size);
  if CurrentMarkList <> nil then
    begin
      SetReturnAddress (ReturnAddress (0));
      if CurrentReturnAddr <> nil then
        AddToMarkList (p, Size, CurrentReturnAddr)
      else
        AddToMarkList (p, Size, ReturnAddress (0));
      RestoreReturnAddress
    end
end;

procedure GPC_Dispose (aPointer: Pointer);
begin
  SetReturnAddress (ReturnAddress (0));
  PrepareDisposePointer (aPointer);
  RestoreReturnAddress;
  InternalDispose (aPointer)
end;

procedure ReAllocMem (var aPointer: Pointer; NewSize: SizeType);
begin
  SetReturnAddress (ReturnAddress (0));
  PrepareDisposePointer (aPointer);
  aPointer := ReAllocMemPtr^ (aPointer, NewSize);
  if (aPointer = nil) or (aPointer = UndocumentedReturnNil) then
    RuntimeErrorInteger (854, NewSize);  { out of heap when reallocating % bytes }
  AddHeapRange (aPointer, NewSize);
  if CurrentMarkList <> nil then
    if CurrentReturnAddr <> nil then
      AddToMarkList (aPointer, NewSize, CurrentReturnAddr)
    else
      AddToMarkList (aPointer, NewSize, ReturnAddress (0));
  RestoreReturnAddress
end;

begin
  InitMalloc (HeapWarning)
end.
