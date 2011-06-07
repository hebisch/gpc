{ BUG: Parsing problem }

program fjf248;

const t:array[2-1..1+1] of integer=(42,24);

begin
  if t[2]=24 then writeln('OK') else writeln('failed ',t[2])
end.
