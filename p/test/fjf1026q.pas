program fjf1026q;

var
  a: record
       a: Integer;
     case b: Integer of
       1: (c: Integer)
     end value [2; case b: 1 of [3]];

begin
  if (a.a = 2) and (a.b = 1) and (a.c = 3) then WriteLn ('OK') else WriteLn ('failed ', a.a, ' ', a.b, ' ', a.c)
end.
