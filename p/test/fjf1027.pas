program fjf1027 (Output);

var
  a: file ['f' .. 'q'] of Char;
  b, c: Char;

begin
  Assign (a, ParamStr (1));
  SeekRead (a, 'i');
  Read (a, b, c);
  if (b = 'g') and (c = 'r') and (Position (a) = 'k') then WriteLn ('OK') else WriteLn ('failed')
end.
