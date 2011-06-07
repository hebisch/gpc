program Emil21c;

type
  Bar (L: Integer; U: Cardinal) = array [L .. U] of Char;

function Baz (F: Bar): Char;
begin
  Baz := F[-1]
end;

var
  A: Bar (-2, 0);

begin
  A[-1] := 'O';
  WriteLn (Baz (A), 'K')
end.
