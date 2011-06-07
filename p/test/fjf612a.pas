program fjf612a;

type
  s (d: Integer) = array [1 .. d] of Integer;

procedure foo;
var
  a: Integer = 4;
  b: s (a);
begin
  if (SizeOf (b) <> 5 * SizeOf (Integer)) or (High (b) <> 4) then
    begin
      WriteLn ('failed 1 ', SizeOf (b), ' ', High (b));
      Halt
    end;
  a := 100;
  if (b.d <> 4) or (SizeOf (b) <> 5 * SizeOf (Integer)) or (High (b) <> 4) then
    begin
      WriteLn ('failed 2 ', b.d, ' ', SizeOf (b), ' ', High (b));
      Halt
    end;
  WriteLn ('OK')
end;

begin
  foo
end.
