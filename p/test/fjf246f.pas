program fjf246f;

type
  s = String (6);

const
  b : s = 'failed';

var
  a : ^const s = @b;

begin
  a^ := 'FAILED'; { WARN }
  WriteLn (a^)
end.
