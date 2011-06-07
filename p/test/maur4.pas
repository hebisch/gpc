program maur4;
var c:complex;
begin
   c:=cmplx(1,5);
   c:=c/2.0;
   if (re(c)>0.49) and (re(c)<0.51) and (im(c)>2.49) and (im(c)<2.51)
     then writeln ('OK') else writeln ('failed')
end.
