{ `Set Of Integer' doesn't work currently. It's not clear whether the
  range should be chosen so that it contains 1 (but that's no general
  solution), or cause a runtime error as it does now. In the former
  case, remove the error check. Anyway, GPC shouldn't crash itself. }

Program SetBug2;

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

procedure Try;
  var
    x : Integer = 1;
    {$local W-} OneSet : set of Integer = [x]; {$endlocal}
  begin
    if x in OneSet then WriteLn ('OK')
  end;

begin
  AtExit (ExpectError);
  Try
end.
