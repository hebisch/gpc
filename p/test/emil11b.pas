program Emil11b (Output);

const
  Bar = 1 / Sqrt (16);

var
  OK: Boolean value True;
  S: String (30);
  Y: Real;
  E: Integer;

procedure Baz (X: Integer);
begin
  if Odd (X) then WriteStr (S, Bar)
             else WriteStr (S, Bar);
  Val (S, Y, E);
  if (E <> 0) or (Y <> 0.25) then begin
    WriteLn ('Failed ', X, ': ', S);
    OK := False
  end
end;

begin
  WriteStr (S, Bar);
  Val (S, Y, E);
  if (E <> 0) or (Y <> 0.25) then begin
    WriteLn ('Failed main: ', S);
    OK := False
  end;
  Baz (0);
  Baz (1);
  Baz (2);
  Baz (3);
  if OK then WriteLn ('OK')
end.
