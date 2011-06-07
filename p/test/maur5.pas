program maur5;

{ Failed on systems without cosl in their libm.a, e.g. DJGPP }

var x:real; y:LongReal;

begin
   x:=1; y:=1;
   if (abs(cos(x)-0.540)<0.001) and (abs(cos(y)-0.540)<0.001) and
      (abs(cos(pi*x)+1)<0.001) then writeln('OK') else writeln('Failed')
end.
