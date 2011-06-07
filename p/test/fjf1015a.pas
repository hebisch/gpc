program fjf1015a (Output);

type
  a (n: Integer) = Integer value n;

var
  Called: Boolean value False;

function f: Integer;
begin
  if Called then WriteLn ('failed 1');
  Called := True;
  f := 42
end;

var
  v: a (f);

begin
  if (v = 42) and (v = 42) and Called then WriteLn ('OK') else WriteLn ('failed')
end.
