program rick1(input,output);
var
   x : real;
   s : String (20);
begin
   x := 0.5000000000000E+00;
   WriteStr (s, x:10:3);
   if s = '     0.500' then WriteLn ('OK') else WriteLn ('failed')
end.
