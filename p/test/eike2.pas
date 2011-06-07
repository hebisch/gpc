program testcase;

var
  aCard: Cardinal;
  aInt: Integer;

begin
  aCard := 1;
  aInt := -1;

  { "FAIL" }
  if (aCard > aInt) then
    aInt := aInt { WriteLn ('OK') }
  else
    begin
      WriteLn ('FAIL 1');
      Halt
    end;

  { "FAIL" }
  {$local W-}
  if (aCard > -1) then
  {$endlocal}
    aInt := aInt { WriteLn ('OK') }
  else
    begin
      WriteLn ('FAIL 2');
      Halt
    end;

  { just for completeness: "OK" }
  if (1 > -1) then
    aInt := aInt { WriteLn ('OK') }
  else
    begin
      WriteLn ('FAIL 3');
      Halt
    end;

  WriteLn ('OK')
end.
