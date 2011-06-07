program fjf450i;

var
  a: Real;

begin
  a := Real ('x');  { Char -> Integer -> Real }  { WRONG Frank, 20030317 }
  if a = Ord ('x') then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
