program fjf612b;

uses GPC;

type
  s (d: Integer) = array [1 .. d] of Integer;

var
  OldGetMem: GetMemType;
  a: Integer = 4;

function NewGetMem (Size: SizeType): Pointer;
begin
  if Size <> 5 * SizeOf (Integer) then
    begin
      WriteLn ('failed 1 ', Size);
      Halt
    end;
  a := 100;
  NewGetMem := OldGetMem^ (Size)
end;

procedure foo;
var
  b: ^s;
begin
  New (b, a);
  if (b^.d <> 4) or (SizeOf (b^) <> 5 * SizeOf (Integer)) or (High (b^) <> 4) then
    begin
      WriteLn ('failed 2 ', b^.d, ' ', SizeOf (b^), ' ', High (b^));
      Halt
    end;
  WriteLn ('OK')
end;

begin
  OldGetMem := GetMemPtr;
  GetMemPtr := @NewGetMem;
  foo
end.
