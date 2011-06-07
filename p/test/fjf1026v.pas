{$extended-pascal}

program fjf1026v (Output);

var
  a: record case Integer of 1: (case Char of 'x': (d: Integer)) end
       value [case 1 of [case 'x' of [d: 4]]];

begin
  if (a.d = 4) then WriteLn ('OK') else WriteLn ('failed')
end.
