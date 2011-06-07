program fjf685a;

type
  t (i: Integer) = record a: Undef end;  { WRONG }

begin
  i := 0;  { WRONG }
  WriteLn ('failed')
end.
