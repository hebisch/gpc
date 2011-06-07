program fjf911j;

type
  t = set of 1 .. 10;

var
  a, c: Byte;

procedure Foo (b: t);
begin
  if b = [8, 9, 10] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  a := 11;
  c := 12;
  Foo ([8 .. a] - [Pred (c)])
end.
