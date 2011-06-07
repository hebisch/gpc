program fjf489;

var a, b: Char;

begin
  ReadStr (#10'OK', a, b);
  if a = ' ' then WriteLn (b, 'K') else WriteLn ('failed ', Ord (a))
end.
