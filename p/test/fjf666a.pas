program fjf666a;

var
  i: Integer = -42;
  v: WordBool;

begin
  v := WordBool (i);
  if Ord (v) = High (Word) - 41 then WriteLn ('OK') else WriteLn ('failed ', Ord (v))
end.
