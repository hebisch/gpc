program test;
var
  s: set of byte;
  t:byte;
begin
  s := [];
  t := 1;
  s := s + [t];
  if s = [1] then WriteLn ('OK') else WriteLn ('failed')
end.
