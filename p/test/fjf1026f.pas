{$extended-pascal}

program fjf1026f (Output);

var
  a: record case a: Integer of 1: (case b: Char of 'x': (d: Integer)) end
       value [case a: 1 of [case b: 'x' of [d: 4]]];

begin
  if (a.a = 1) and (a.b = 'x') and (a.d = 4) then WriteLn ('OK') else WriteLn ('failed')
end.
