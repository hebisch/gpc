program fjf928;

type
  a = object
    b: Integer;
    procedure c;
  end;

procedure a.c;

  procedure d;
  begin
    b := 42
  end;

begin
  d
end;

var
  v: a;

begin
  v.b := 0;
  v.c;
  if v.b = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
