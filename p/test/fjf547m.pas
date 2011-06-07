program fjf547m;

type foo = (a, b, c);
     bar = (d, e, f);

begin
  WriteLn ('failed ', Ord (b + e))  { WRONG }
end.
