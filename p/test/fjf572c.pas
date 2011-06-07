program fjf572c;
var i, j: Cardinal;
begin
  for j := 1 to 10 do
    for i := 0 to 42 do
      if (i * j) mod j <> 0 then
        begin
          WriteLn ('failed ', i, ' ', j);
          Halt
        end;
  WriteLn ('OK')
end.
