program fjf124a;
type Boolean=packed 0..1;
const a:array[Boolean,Boolean] of integer=((1,2),(3,4));
begin
 if a[true,true] >= 0 then writeln('Failed') { WRONG }
end.
