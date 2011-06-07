program fjf540d;

var
  a: Integer;
  b: ^Byte;

begin
  {$typed-address}
  b := @a;  { WRONG }
  WriteLn ('failed')
end.
