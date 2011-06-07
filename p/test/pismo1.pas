program simple_test;
var
  t : string[20] ;
  i : integer ;
begin
  t := '' ;
  for i := 1 to 20 do
    t := t + chr(32) ;
  if t[1] = chr(32) then
    writeln('OK')
  else
    writeln('failed') ;
end.
