{$B+}

program fjf981b;

var
  p: ^Integer = nil;

begin
  if (p <> nil) & (p^ = 42) then WriteLn ('failed') else WriteLn ('OK')
end.
