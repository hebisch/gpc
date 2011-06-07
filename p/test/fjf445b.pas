program fjf445b;

type
  t = object
    i : Integer;
  end;

const
  v : t = (i : 42);

begin
  if (TypeOf (v) = TypeOf (t)) and (v.i = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
