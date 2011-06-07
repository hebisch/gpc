program fjf357;

type
  foo = record a : integer end;
  bar = record a : integer end;

procedure baz (a : foo);
begin
  writeln ('failed')
end;

var a:bar;

begin
  baz (a)  { WRONG }
end.
