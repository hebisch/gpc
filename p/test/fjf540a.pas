program fjf540a;

var
  a: Integer;
  b: ^Byte;

begin
  b := Addr (a);  { WRONG }
  WriteLn ('failed')
end.
