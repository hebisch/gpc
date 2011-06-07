program fontana1;
type P = procedure (S : String);
var S : String [255];
begin
 S := '123';
 Delete (S, 1, 1);
 if S = '23' then WriteLn ('OK') else WriteLn ('failed ', S)
end.
