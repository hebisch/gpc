{$extended-pascal}

program fjf1026g (Output);

var
  a: record case a: Integer of 1: (case b: Char of 'x': (d: Integer)) end value [d: 4];  { WRONG }

begin
end.
