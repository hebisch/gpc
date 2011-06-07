{$W no-underscore}

program fjf787;

procedure __builtin_memcpy;
begin
  WriteLn ('failed')
end;

var
  s, t: String (2);

begin
  s := 'OK';
  t := s;
  WriteLn (t)
end.
