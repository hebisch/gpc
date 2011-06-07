{ FLAG -Werror }

program fjf199b;

type
  t = array [1 .. 2] of Char;

procedure foo (a: t);
var b : t absolute a;
begin
  WriteLn (b)
end;

begin
  foo ('OK')
end.
