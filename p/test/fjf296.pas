{ FLAG -Werror }

program fjf296;

{$B-}

type
  T = array [1..10000] of Integer;

var
  FooBar: Boolean;

function Foo = R : T;
var i : Integer;
begin
  for i := 1 to 10000 do R [i] := i;
  WriteLn ('failed (foo)');
  Halt (1)
end;

function Baz (const V : T) : Boolean;
begin
  Baz := V [42] = 42
end;

begin
  FooBar := False and (Baz (Foo));
  if FooBar then
    WriteLn ('failed (bar)')
  else
    WriteLn ('OK')
end.
