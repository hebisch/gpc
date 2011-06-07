program fjf346a;

const a = Ord ('K') - 1;

procedure baz;
type bar = a + 1 .. Ord ('O');
begin
  {$local W-} WriteLn (Chr (Ord (High (bar))), Chr (Ord (Low (bar)))) {$endlocal}
end;

begin
  baz
end.
