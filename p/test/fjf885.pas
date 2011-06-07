program fjf885;

type
  t = set of Char;

function f: t;
begin
  f := ['O']
end;

function g: t;
begin
  Return ['K']
end;

var
  c: Char;

begin
  for c in f do Write (c);
  for c in g do Write (c);
  WriteLn
end.
