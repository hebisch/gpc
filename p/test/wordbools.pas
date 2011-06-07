program WordBools;

var
  x: Word;

procedure Foo (y: WordBool);
begin
  x := Word (y)
end;

begin
  Foo (False);
  if WordBool (x) then
    WriteLn ('failed')
  else
    WriteLn ('OK')
end.
