program fjf502;

uses GPC;

procedure r (aPointer: Pointer; aSize: SizeType; aCaller: Pointer);
begin
  WriteLn ('failed');
  Halt
end;

type
  { If the type is <= 8 bytes, the RTS does not do heap allocation,
    so the error does not occur. }
  t = file of array [1 .. 1000] of Byte;

var
  f: ^t;
  p: Pointer;

begin
  Mark (p);
  New (f);
  Dispose (f);  { This does not call _p_donefdr, leaving a memory leak for the file buffer }
  ForEachMarkedBlock (p, r);
  WriteLn ('OK')
end.
