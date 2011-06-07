program fjf540f;

var
  a: Integer;
  b: ^Byte;

begin
  {$T+}
  b := Addr (a);  { WRONG }
  WriteLn ('failed')
end.
