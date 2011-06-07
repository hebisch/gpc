program fjf491;

var
  f: Text;
  s1, s2: String (10);

begin
  Rewrite (f);
  WriteLn (f, 'O');
  WriteLn (f, 'K');
  Reset (f);
  Read (f, s1);
  if EOF (f) then begin WriteLn ('failed 1'); Halt end;
  if not EOLn (f) then begin WriteLn ('failed 2'); Halt end;
  ReadLn (f);
  Read (f,s2);
  if EOF (f) then begin WriteLn ('failed 3'); Halt end;
  if not EOLn (f) then begin WriteLn ('failed 4'); Halt end;
  ReadLn (f);
  if not EOF (f) then begin WriteLn ('failed 5'); Halt end;
  WriteLn (s1, s2)
end.
