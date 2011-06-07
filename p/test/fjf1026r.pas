program fjf1026r;

var
  a: record
       a: Integer;
     case Integer of
       1: (c: Integer);
       2: (d: Char)
     end value [2; case 2 of ['X']];

begin
  if (a.a = 2) and (a.d = 'X') then WriteLn ('OK') else WriteLn ('failed ', a.a, ' ', a.c)
end.
