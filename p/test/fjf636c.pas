program fjf636c;

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

begin
  {$local X+} SetType (w, TypeOf (v)); {$endlocal}
  if TypeOf (w) = TypeOf (a) then WriteLn ('OK') else WriteLn ('failed')
end.
