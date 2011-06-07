program fjf594f;

var
  i: restricted Integer;

begin
  i := 16#ffff;  { assignment target is restricted }  { WRONG }
  WriteLn ('failed')
end.
