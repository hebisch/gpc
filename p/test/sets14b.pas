program Sets14b;

var
  foo: set of 1 .. 42 = [4 .. 27];
  i: Integer;

begin
  i := 15;
  Exclude (foo, i);
  i := 3;
  Include (foo, i);
  if foo = [3 .. 14, 16 .. 27] then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
