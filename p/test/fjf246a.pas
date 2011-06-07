program fjf246a;

type
  s = String (2);

var
  a : ^const s;
  b : s;

begin
  a := @b;
  b := 'OK';
  WriteLn (a^)
end.
