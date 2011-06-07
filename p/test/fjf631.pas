program fjf631;

type
  foo = object
  end;

procedure qwe;
var
  f : foo;
begin
end;

var
  f : foo;

begin
  if TypeOf (f) = TypeOf (foo) then WriteLn ('OK') else WriteLn ('failed')
end.
