program fjf245a;
var
  o: char='O'; attribute (static);
  k: char='K'; attribute (name = 'ka');
  x: char; {$local W-}external;{$endlocal}
  y: char; attribute (name = 'yy');
begin
  writeln(o,k)
end.
