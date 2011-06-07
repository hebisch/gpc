program fjf726b;

type
  t (a: Integer) = Integer;

begin
  WriteLn ('failed ', AlignOf (t))  { WRONG }
end.
