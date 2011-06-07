program fjf540b;

var
  a: Integer;
  b: ^Byte;

begin
  b := @a;  { WRONG }
  WriteLn ('failed')
end.
