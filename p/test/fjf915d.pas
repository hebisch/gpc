program fjf915d;

type
  t = object
    constructor Value;
  end;

constructor t.Value;
begin
  WriteLn ('OK')
end;

var
  p: ^t;

begin
  New (p, Value)
end.
