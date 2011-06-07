program fjf247d;

{$local W-}
const t:array[1..2,0..4] of integer=((1,2,3,4),(5,6,7,8));
      foo=42;
{$endlocal}

begin
  if t[2,0]=5 then writeln('OK') else writeln('failed ',t[2,0])
end.
