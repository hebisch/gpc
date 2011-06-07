program Emil21b;

type
  Bar (U: Cardinal) = array [0 .. U] of Char;

function Baz (F: Bar): Char;
begin
  Baz := F[-1]  { WRONG }
end;

begin
  WriteLn ('failed')
end.
