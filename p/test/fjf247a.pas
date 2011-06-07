program fjf247a;

const t:array[1..2,-2..1] of integer=((1,2,3,4),(5,6,7,8));

begin
  if t[2,0]=7 then writeln('OK') else writeln('failed ',t[2,0])
end.
