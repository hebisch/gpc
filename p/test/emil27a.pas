program Emil27a;

uses GPC;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

begin
  AtExit (ExpectError);
  WriteLn ('failed ', {$local W-,extended-pascal} 0 pow (-1) {$endlocal})
end.
