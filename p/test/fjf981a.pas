{$B+}

program fjf981a;

var
  p: ^Integer = nil;

begin
  if (p = nil) | (p^ = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
