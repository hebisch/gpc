program fjf124;
const a:array[Boolean,Boolean] of integer=((1,2),(3,4));
begin
 if a[true,true]=4 then writeln('OK') else writeln('Failed: ',
     a[false,false]:7, a[false,true]:7, a[true,false]:7, a[true,true]:7)
end.
