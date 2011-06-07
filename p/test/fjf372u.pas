unit fjf372u;

interface

type
  t (n : Integer) = array [0 .. n, 0 .. n] of Integer;

var
  v : ^t;

procedure foo;

implementation

procedure foo;
var n: Integer;
begin
  New (v, 4);
  for n:=0 to 4 do v^[n,0] := 1;
  for n:=2 to 4 do v^[n,1] := v^[n-1,0] + n - 1;
  if v^[4,1] = 4 then WriteLn ('OK') else WriteLn ('failed ', v^[4,1])
end;

end.
