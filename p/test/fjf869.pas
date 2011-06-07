program fjf869;

procedure foo (a: array [m .. n: Integer] of Char);
begin
  if (m = 1) and (n = 1) then Write (a[1])
end;

procedure bar (a : array of Char);
begin
  if (Low (a) = 0) and (High (a) = 0) then WriteLn (a[0])
end;

begin
  foo ('O');
  bar ('K')
end.
