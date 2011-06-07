program fjf97;
{$W-} type x=string; {$W+}
var a:x(1000);  { WRONG }
begin
{ if a.Capacity=1000 then writeln('OK') }
  writeln ( 'failed' );
end.
