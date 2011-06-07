program fjf505;

type
  T = 1 .. 10;
  S (Count : T) = array [1 .. Count] of Integer;

var
  x : S (5);

begin
  if x.Count = 5 then WriteLn ('OK') else WriteLn ('failed')
end.
