program fjf1042c (Output);

var
  a: Text;
  s, t: String (100);

begin
  Rewrite (a, 'test.dat');
  Write (a, 'b', 'c');
  Close (a);
  Extend (a);
  a^ := 'd';
  Update (a);
  a^ := 'e';
  Update (a);
  a^ := 'f';
  Update (a);
  a^ := 'g';
  Update (a);
  a^ := 'h';
  Update (a);
  Reset (a);
  ReadLn (a, s);
  ReadLn (a, t);
  if (s = 'bc') and (t = 'h') then WriteLn ('OK') else WriteLn ('failed ', s, ', ', t)
end.
