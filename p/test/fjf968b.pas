program fjf968b;

var
  x: record
       a: Integer;
       b: 0 .. 5
     end = [a: 0; b: 0];  { Correct, cf. fjf968a.pas }

begin
  if (x.a = 0) and (x.b = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
