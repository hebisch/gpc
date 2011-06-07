program fjf594j;

var
  i: restricted Integer;

begin
  for i in [1, 3] do WriteLn ('failed')  { restricted `for' variable }   { WRONG }
end.
