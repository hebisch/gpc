program fjf246b;

type
  s = String (2);

var
  b : s;
  a : ^const s = @b;

begin
  b := 'OK';
  WriteLn (a^)
end.
