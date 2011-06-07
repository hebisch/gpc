program fjf1046 (Output);

procedure f (const s: String);
begin
  WriteLn (s)
end;

var
  a: packed array [1 .. 2] of String (10) = ('KO', 'OK');

begin
  f (a[2])
end.
