{$implicit-result}

Program Chief39b;
type
Coord = array [1 .. 2] of Integer;
TCoord = Coord;

type bar = object
  function foo: TCoord;
end;

function bar.foo : TCoord;
begin
  Result[1] := 0;
  Result[2] := 25;
end;

Var
i : Integer;
b : bar;
begin
  i := b.foo[2]; // GPC barfs here
  if i = 25 then writeln ('OK') else writeln ('failed ', i)
end.
