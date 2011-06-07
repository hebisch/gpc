program fjf962;

uses GPC;

var
  OldGetMem: GetMemType;
  OldFreeMem: FreeMemType;
  GetMemCount, FreeMemCount: Integer = 0;

function MyGetMem (Size: SizeType): Pointer;
begin
  Inc (GetMemCount);
  MyGetMem := OldGetMem^ (Size)
end;

procedure MyFreeMem (aPointer: Pointer);
begin
  Inc (FreeMemCount);
  OldFreeMem^ (aPointer)
end;

procedure p1;
var t: Text;
begin
end;

procedure p2;
var t: Text;
begin
  Exit
end;

procedure p3;
var t: Text;
begin
  Return
end;

begin
  OldGetMem := GetMemPtr;
  GetMemPtr := @MyGetMem;
  OldFreeMem := FreeMemPtr;
  FreeMemPtr := @MyFreeMem;
  p1;
  p2;
  p3;
  if (GetMemCount <> FreeMemCount) or not (GetMemCount in [0, 3]) then
    WriteLn ('failed ', GetMemCount, ' ', FreeMemCount)
  else
    WriteLn ('OK')
end.
