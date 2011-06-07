program fjf1026m;

var
  a: record
       a: Integer;
     case Integer of
       1: (c: Integer)
     end value [2; case 1 of [3]];

begin
  if (a.a = 2) and (a.c = 3) then WriteLn ('OK') else WriteLn ('failed ', a.a, ' ', a.c)
end.
