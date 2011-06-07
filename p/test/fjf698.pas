{ FLAG --extended-pascal }

program fjf698 (Output);

type
  foo = ^const Integer;  { WRONG }

begin
  WriteLn ('failed')
end.
