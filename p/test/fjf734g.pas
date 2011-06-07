{$W implicit-io}

program fjf734g;

var
  i: Integer;

begin
  WriteLn (Output, 'failed');
  if False then Read (i)  { WARN }
end.
