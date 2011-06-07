program fjf671c;

type
  t (i: Integer) = array [1 .. i] of Integer;

var
  foo: t (10);

{$W-}

begin
  WriteLn ('failed ', foo._p_schema_[1])  { WRONG }
end.
