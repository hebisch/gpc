program fjf997g;

var
  s: String(42)='OK';

type
  a = String(42) value s;

var
  b, c: a;

begin
  s := 'failed 1';
  if b = c then WriteLn (b) else WriteLn ('failed')
end.
