program fjf996 (Output);

var
  i: Integer = 1234;

begin
  { there should be no setlimit problem }
  if i in [1234, 5678] then WriteLn ('OK') else WriteLn ('failed')
end.
