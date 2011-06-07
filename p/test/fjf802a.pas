program fjf802a;

procedure shl;
begin
end;

operator shl (a, b: Integer) c: Integer;  { WRONG (operator and routine
                                                   of the same name) }
begin
  c := a + b
end;

begin
end.
