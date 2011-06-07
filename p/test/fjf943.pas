{$extended-pascal}

program fjf943 (Output);

const
  s = 'JKLMNOPQ';

begin
  WriteLn (s[4 .. 7][3 .. 4][1], s[2 .. 4][1 .. 3][1])
end.
