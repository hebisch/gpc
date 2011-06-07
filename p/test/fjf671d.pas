program fjf671d;

{$W-}

type
  t (i: Integer) = record _p_schema: Integer end;

var
  foo: t (10);

begin
  foo._p_schema := 42;
  if foo._p_schema = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
