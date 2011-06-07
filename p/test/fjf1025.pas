program fjf1025 (Output);

var
  a: LongestCard;
  s: String (100);

begin
  a := High (a) - 1;
  WriteStr (s, a);
  if (Length (s) >= 10) and (s[1] <> '-') and (a + LongCard (1) = High (a)) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', a)
end.
