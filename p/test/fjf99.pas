program fjf99;
type a(b:integer)=array[1..b] of integer;
     a1=a(1);
     a42=a(42);
begin
 if (sizeof(a1)=2*sizeof(integer)) and
    (sizeof(a42)=43*sizeof(integer))
   then writeln('OK')
   else writeln('Failed')
end.
