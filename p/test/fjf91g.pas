program fjf91g;

type
  str5 = string [5];
  str6 = string [5];  { still WRONG because separately declared types }

var
  s5: ^str5;
  s6: ^str6;

begin
  New (s5);
  s6 := s5;
  WriteLn ('failed')
end.
