program fjf124b;
type Boolean=packed 0..1;
const a:array[Boolean,Boolean] of integer=((1,2),(3,4));
begin
 if a[1,1] >= 0 then writeln('OK')
end.
