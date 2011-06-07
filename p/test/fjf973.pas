program fjf973;

const
  c = ShortWord (2);

var
  a: record
     case Integer of
       LongInt (1) - (c - Sqr (Pred (3))): (a: Integer)
     end = [case 2 + 1 of [a: 42]];

begin
  if a.a = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
