program fjf997f;

var
  n: Integer value 42;

function f: Integer;
begin
  if n > 43 then WriteLn ('failed 1');
  f := n;
  Inc (n)
end;

var
  b, c: Integer value f;
  d: Integer value f;

begin
  if (b = 42) and (c = 42) and (d = 43) then WriteLn ('OK') else WriteLn ('failed ', b, ' ', c, ' ', d)
end.
