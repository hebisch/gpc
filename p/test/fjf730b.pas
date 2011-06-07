program fjf730b;

type
  foo = (a, b, c);

begin
  WriteLn ('failed ', not a)  { WRONG }
end.
