program fjf585;

type
  a = record
    c, d: Integer
  end;

  b = record
    c, d: Integer
  end;

var
  x: a;
  y: b;

begin
  x := y;  { WRONG }
  WriteLn ('failed')
end.
