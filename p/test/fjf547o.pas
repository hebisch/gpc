program fjf547o;

type foo = (a, b, c);

begin
  WriteLn ('failed ', Ord (b + c))  { WRONG }
end.
