program fjf1015b (Output);

type
  a = record
    b, c: Integer
  end;

var
  Called: Boolean value False;

function f: Integer;
begin
  if Called then WriteLn ('failed 1');
  Called := True;
  f := 42
end;

begin
  {$local W-} with a [c: 3; b: f] do {$endlocal}
    if (b = 42) and (b = 14 * c) and Called then WriteLn ('OK') else WriteLn ('failed')
end.
