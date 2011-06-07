program fjf308c;

operator + (a, b : Integer) = c : Integer;
begin
  c := a;
  Dec (c, b)
end;

const
  a : Integer = 50 + 8; { no more incorrect -- Frank, 20050117 }

begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
