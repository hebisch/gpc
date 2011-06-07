{$extended-pascal}

program fjf1026w (Output);

type
  a = record case Integer of 1: (case Char of 'x': (d: Integer)) end
        value [case 1 of [case 'y' of [d: 4]]];  { WRONG }

begin
end.
