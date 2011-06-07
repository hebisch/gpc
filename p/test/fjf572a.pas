program fjf572a;
var i, j: Integer;
begin
  for j := 1 to 10 do
    for i := 3 downto -3 do
      if (i * j) mod j <> 0 then
        begin
          WriteLn ('failed ', i, ' ', j);
          Halt
        end;
  WriteLn ('OK')
end.
