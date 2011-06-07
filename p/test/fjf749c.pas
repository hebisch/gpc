program fjf749c;

type
  t1 = (a, b);
  t2 = (c, d);

procedure foo (a: t2);
begin
end;

var
  s: t1;

begin
  WriteLn ('failed');
  foo (s)  { WRONG }
end.
