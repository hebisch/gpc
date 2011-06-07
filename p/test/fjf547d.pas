program fjf547d;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (0 + a))  { WRONG }
end.
