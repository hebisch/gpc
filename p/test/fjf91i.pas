program fjf91i;

type
  str5 = String [5];

var
  s5: ^str5;
  s6: ^String;

begin
  New (s5);
  s5^ := 'OK';
  s6 := s5;
  Writeln (s6^)
end.
