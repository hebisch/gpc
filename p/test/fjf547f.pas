program fjf547f;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (c + True))  { WRONG }
end.
