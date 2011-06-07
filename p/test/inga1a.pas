program Inga1a;

type
  t = set of 0 .. 255;

var
  v: t;
  c: Integer = 0;

function f (a: t): t;
begin
  Inc (c);
  f := a
end;

begin
  v := f ([]);
  if c = 1 then WriteLn ('OK') else WriteLn ('failed ', c)
end.
