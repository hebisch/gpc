program fjf447;

var
  a : set of -13 .. 40 = [-5, -2, 5, 7];

type
  t = set of ByteInt;

procedure Test (const s : t);
var i: Integer = 0; attribute (static);
    n: Integer;
begin
  Inc (i);
  if a <> s then
    begin
      Write ('failed ', i, ': [');
      for n in a do Write (n, ', ');
      Write (#8#8, '] <> [');
      for n in s do Write (n, ', ');
      WriteLn (#8#8, ']');
      Halt
    end
end;

begin
  Test ([-5, -2, 5, 7]);
  a := a + [-3];
  Test ([-5, -3, -2, 5, 7]);
  Include (a, -1);
  Test ([-5, -3 .. -1, 5, 7]);
  a := a - [-5];
  Test ([-3 .. -1, 5, 7]);
  Exclude (a, -2);
  Test ([-3, -1, 5, 7]);
  a := a * [-3 .. 5];
  Test ([-3, -1, 5]);
  a := a >< [-1 .. 5];
  Test ([-3, 0 .. 4]);
  WriteLn ('OK')
end.
