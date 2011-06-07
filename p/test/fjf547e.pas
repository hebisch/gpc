program fjf547e;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (b + 'X'))  { WRONG }
end.
