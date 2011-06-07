program fjf1033 (Output);

var
  f: file of Integer;
  i, j, k: Integer;

begin
  Rewrite (f);
  for i := 1 to 10000 do Write (f, i);
  SeekRead (f, 2);
  Read (f, i);
  j := f^;
  SeekRead (f, 9990);
  Read (f, k);
  if (i = 3) and (j = 4) and (k = 9991) then WriteLn ('OK') else WriteLn ('failed ', i, ' ', j, ' ', k)
end.
