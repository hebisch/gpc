program fjf1007a;

var
  a: array [2 .. 2] of Char = 'O';
  c: Char = 'X';

begin
  {$local W-} c := a {$endlocal};
  WriteLn (c, 'K')
end.
