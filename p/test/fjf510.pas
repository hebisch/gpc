{ What's that?!?!?!?!? It works with 63, but fails with (64-1),
  at least on i586-pc-linux-gnulibc1 }

program fjf510;
var m: word attribute (Size = 64);
begin
  m:= 1 shl (64-1);
  if m div 2 = 1 shl 62 then WriteLn ('OK') else WriteLn ('failed')
end.
