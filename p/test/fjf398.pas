{ FLAG -Werror }

program fjf398;

type
  p = ^t;
  t = packed array [1 .. 2] of Char;

var
  s : String (10) = 'OK';
  v : p;

begin
  v := p (@s [1]);
  WriteLn (v^)
end.
