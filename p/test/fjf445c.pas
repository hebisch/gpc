program fjf445c;

type
  t = object
    i : Integer;
  end;

var
  v : t = (i : 42);

begin
  if (TypeOf (v) = TypeOf (t)) and (v.i = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
