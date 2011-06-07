program fjf636d;

type
  a = object
    f: Integer
  end;

  b = object (a)
    g: Integer
  end;

var
  v: a;
  w: b;
  p: PObjectType;

begin
  p := TypeOf (a);
  {$local X+} SetType (w, p); {$endlocal}
  if TypeOf (w) = TypeOf (v) then WriteLn ('OK') else WriteLn ('failed')
end.
