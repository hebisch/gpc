program fjf506;

type
  t (Count: Integer) = array [1 .. Count] of Integer;

procedure p (var v: t);
begin
end;

const
  c : t = (0, 1);  { WRONG (missing discriminant) }

begin
  WriteLn ('failed')
end.
