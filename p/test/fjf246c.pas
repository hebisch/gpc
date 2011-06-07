program fjf246c;

type
  s = String (6);

var
  b : s;
  a : ^const s = @b;

begin
  a^ := 'failed';  { WARN }
  WriteLn (a^)
end.
