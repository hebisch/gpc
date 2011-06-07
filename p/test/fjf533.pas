{ FLAG --force-addr --unroll-loops }

program fjf533;

var
  v: array [1 .. 3] of record
    a: String (252);
    b: String (1)
  end;
  i: Integer;

begin
  for i := 1 to 3 do
    if (v[i].a.Capacity <> 252) or (v[i].b.Capacity <> 1) then
      begin
        WriteLn ('failed ', i, ' ', v[i].a.Capacity, ' ', v[i].b.Capacity);
        Halt
      end;
  WriteLn ('OK')
end.
