program fjf997c (Output);

var
  a: Integer = 42;
  p: ^String;

begin
  New (p, a);
  p^ := 'OK';
  a := 4;
  if p^.Capacity = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
