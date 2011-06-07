{$implicit-result}

Program Chief39c;
type
Coord = ^Integer;
TCoord = Coord;

type bar = object
  function foo: TCoord;
end;

function bar.foo : TCoord;
var a: Integer = 25; attribute (static);
begin
  Result := @a
end;

var
i : Integer;
b : bar;
begin
  i := b.foo^; // GPC barfs here
  if i = 25 then writeln ('OK') else writeln ('failed ', i)
end.
