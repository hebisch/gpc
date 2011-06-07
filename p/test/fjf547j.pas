program fjf547j;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (a + 0))  { WRONG }
end.
