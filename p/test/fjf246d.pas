{ FLAG -Werror }

program fjf246d;

type
  s = String (2);

const
  b : s = 'OK';

var
  a : ^const s = @b;

begin
  WriteLn (a^)
end.
