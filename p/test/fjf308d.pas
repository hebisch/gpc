program fjf308d;

operator + (a, b : Integer) = c : Integer;
begin
  c := a;
  Dec (c, b)
end;

const
  a = 50 + 8; { WRONG }

begin
  WriteLn ('failed')
end.
