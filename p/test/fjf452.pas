program fjf452;

type
  t = record
    i : Integer
  end;

procedure p (var k : t);
begin
  WriteLn ('failed')
end;

var
  v : packed record
    x : Boolean;
    y : t
  end;

begin
  p (v.y) { WRONG }
end.
