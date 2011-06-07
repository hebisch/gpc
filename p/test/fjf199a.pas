{ FLAG -Werror }

program fjf199a;

procedure foo;
var
  a : array [1 .. 2] of Char = 'OK';
  b : array [1 .. 2] of Char absolute a;
begin
  WriteLn (b)
end;

begin
  foo
end.
