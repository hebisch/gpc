program fjf540c;

var
  a: Integer;
  b: ^Byte;

begin
  {$typed-address}
  b := Addr (a);  { WRONG }
  WriteLn ('failed')
end.
