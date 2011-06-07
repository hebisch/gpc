program fjf998b (Output);

const
  a = 8 pow 5;
  b = 2;
  c = 15;
  d = b pow c;

begin
  if a = d then WriteLn ('OK') else WriteLn ('failed ', a, ', ', d)
end.
