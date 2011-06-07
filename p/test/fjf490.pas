program fjf490;

var
  t: Text;
  c: Char;

begin
  Rewrite (t);
  Reset (t);
  c := t^;  { According to EP, the buffer variable is undefined. But GPC
              doesn't check undefined variable access at all yet. If
              it ever does, this test will need to be changed. }
  WriteLn ('OK')
end.
