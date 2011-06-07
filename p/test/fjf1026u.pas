{$extended-pascal}

program fjf1026u (Output);

type
  a = record case Integer of 1: (b: Integer) end
        value [case 1 of [case 1 of [b: 4]]];  { WRONG }

begin
end.
