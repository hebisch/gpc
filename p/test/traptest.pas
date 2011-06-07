{ Test of the Trap unit. }

program TrapTest;

uses Trap;

procedure Test (Trapped : Boolean);
var Counter : Integer = 0; attribute (static);
begin
  if Trapped then
    begin
      Inc (Counter);
      if Counter < 42 then
        Write (Ln (0))
      else
        Write ('K')
    end
  else
    begin
      Write ('O');
      Write (Ln (0))
    end
end;

begin
  TrapExec (Test);
  TrappedExitCode := 0;
  TrappedErrorAddr := nil;
  TrappedErrorMessageString := '';
  WriteLn
end.
