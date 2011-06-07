program fjf1029 (Output);

var
  a: record
       a: Integer;
     case b: Integer of
       2: (c: String (10))
     end = (a: 1; b: 2; c: 'OK');

begin
  if (a.a = 1) and (a.b = 2) then WriteLn (a.c) else WriteLn ('failed')
end.
