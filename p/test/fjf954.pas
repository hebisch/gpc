program fjf954;

var
  k: array [0 .. 10, 'A' .. 'Z'] of Char;
  c: Char;
  i: Integer;

begin
  c := 'Q';
  i := 0;
  k[0, c] := 'X';
  k[i, c] := 'O';
  WriteLn (k[0, c], 'K')
end.
