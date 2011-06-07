program fjf635;

type
  p = ^Byte;

var
  a: ^Char;
  b: Boolean;

begin
  p (a) := @b;  { WRONG }
  WriteLn ('failed')
end.
