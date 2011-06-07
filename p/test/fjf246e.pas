{ FLAG -Werror }

program fjf246e;

type
  s = String (2);

const
  b : s = 'OK';

var
  a : ^const s;

begin
  a := @b;
  WriteLn (a^)
end.
