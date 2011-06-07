program fjf346b;

const a = Ord ('K');

procedure baz;
type bar = (a) .. Ord ('O');
begin
  {$local W-} WriteLn (Chr (Ord (High (bar))), Chr (Ord (Low (bar)))) {$endlocal}
end;

begin
  baz
end.
