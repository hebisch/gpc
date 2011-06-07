program fjf383;

type CharSet = set of Char;

procedure foo (const Characters : CharSet);
begin
  if Characters = [] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  foo ([])
end.
