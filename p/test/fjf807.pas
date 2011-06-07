program fjf807;

{ `operator' before `(' is no keyword, but `(*' doesn't matter. }

operator (**) + (a, b: Integer) c: Integer;
begin
  c := a + b
end;

begin
  WriteLn ('OK')
end.
