{$implicit-result}

Program Chief39a;
type
Coord = record
  X, Y : integer;
end;
TCoord = Coord;

type bar = object
  function foo: TCoord;
end;

function bar.foo : TCoord;
begin
  Result.X := 0;
  Result.Y := 25;
end;

Var
i : integer;
b : bar;
begin
  i := b.foo.Y; // GPC barfs here
  if i = 25 then writeln ('OK') else writeln ('failed ', i)
end.
