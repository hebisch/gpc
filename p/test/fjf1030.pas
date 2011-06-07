program fjf1030 (Output);

var
  a: Byte = 2;

begin
  if a - LongestCard (3) = -1 then WriteLn ('OK') else WriteLn ('failed ', a - LongestCard (3))
end.
