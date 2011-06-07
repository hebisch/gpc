program fjf356;

type
  foo = array [1 .. 42] of integer;
  bar = array [1 .. 42] of integer;

procedure baz (a : foo);
begin
  writeln ('failed')
end;

var a:bar;

begin
  baz (a)  { WRONG }
end.
