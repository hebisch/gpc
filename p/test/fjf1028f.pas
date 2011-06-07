program fjf1028f (Output);

type
  i2 = Integer value 2;
  t (i: i2) = record
    case i of
      1: (b: Integer value 3);
      2: (c: Integer value 4);
    end;

var
  v: ^t;

begin
  New (v, 2);
  if (v^.i = 2) and (v^.b = 4) then
    begin
      New (v, 1);
      if (v^.i = 1) and (v^.b = 3) then
        WriteLn ('OK')
      else
        WriteLn ('failed 2 ', v^.i, ' ', v^.b)
    end
  else
    WriteLn ('failed 1 ', v^.i, ' ', v^.b)
end.
