program fjf547l;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (True + c))  { WRONG }
end.
