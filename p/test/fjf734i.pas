{$W implicit-io}

program fjf734i;

begin
  if False and EOF then Write (' ');  { WARN }
  WriteLn (Output, 'failed');
end.
