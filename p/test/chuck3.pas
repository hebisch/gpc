program Chuck3 (Output);

var
  t: Text;
  r: Real;
  s: String (20);

begin
  Rewrite (t);
  WriteLn (t, '2.5..2.8');
  Reset (t);
  ReadLn (t, r, s);
  if (r = 2.5) and (s = '..2.8') then WriteLn ('OK') else WriteLn ('failed')
end.
