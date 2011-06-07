program fjf1050h (Output);

type
  a (n: Integer) = array [1 .. n] of Integer;

procedure p (a: array of Integer);
begin
  if High (a) <> 19 then WriteLn ('failed 1')
end;

procedure q (a: array [n .. m: Integer] of Integer);
begin
  if (n <> 1) or (m <> 20) or (High (a) <> 20) then
    WriteLn ('failed 2: ', n, ' ', m, ' ', High (a))
end;

var
  i: a (20);

begin
  p (i);
  q (i);
  WriteLn ('OK')
end.
