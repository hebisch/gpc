program fjf540e;

var
  a: Integer;
  b, c: ^Byte;

begin
  {$borland-pascal,T-}
  b := Addr (a);
  c := @a;
  if b = c then WriteLn ('OK') else WriteLn ('failed')
end.
