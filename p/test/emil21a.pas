program Emil21a;

type
  Bar (U: Cardinal) = array [-1 .. U] of Char;

function Baz (F: Bar): Char;
begin
  Baz := F[-1]
end;

var
  A: Bar (0);

begin
  A[-1] := 'O';
  WriteLn (Baz (A), 'K')
end.
