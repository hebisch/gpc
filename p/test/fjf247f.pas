program fjf247f;

const t:array[1..2,1..4] of integer=((1,2,3,4),(5,6,7,8));

begin
  if t[2,1]=5 then writeln('OK') else writeln('failed ',t[2,1])
end.
