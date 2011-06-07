program fjf594i;

var
  i: restricted Integer;

begin
  for i := 1 to 2 do WriteLn ('failed')  { restricted `for' variable }   { WRONG }
end.
