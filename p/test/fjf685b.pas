program fjf685b;

type
  t (i: Integer) = object a: Integer end;  { WRONG }

begin
  i := 0;  { WRONG }
  WriteLn ('failed')
end.
