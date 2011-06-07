program fjf681d;

var
  a: Pointer;

begin
  a := @[1,2];  { WRONG }
  WriteLn ('failed')
end.
