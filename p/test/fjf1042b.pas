program fjf1042b (Output);

var
  a: file [0 .. 100] of Char;
  b, c, d, e: Char;

begin
  Rewrite (a, 'test.dat');
  Write (a, 'b', 'c');
  Close (a);
  Extend (a);
  Write (a, 'd', 'e');
  SeekWrite (a, 1);
  Write (a, 'f');
  Reset (a);
  Read (a, b, c, d, e);
  if (b = 'b') and (c = 'f') and (d = 'd') and (e = 'e') and (Position (a) = 4) and (LastPosition (a) = 3) then WriteLn ('OK') else WriteLn ('failed')
end.
