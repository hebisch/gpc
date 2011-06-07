program fjf540g;

var
  a: Integer;
  b: ^Byte;

begin
  {$T+}
  b := @a;  { WRONG }
  WriteLn ('failed')
end.
