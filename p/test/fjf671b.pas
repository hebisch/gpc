program fjf671b;

var
  foo: String (10) = 'x';

{$W-}

begin
  WriteLn ('failed ', foo._p_schema_[1])  { WRONG }
end.
