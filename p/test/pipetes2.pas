{ Test of the Pipes unit. }

program PipeTest2;

uses GPC, Pipes;

const
  ResultMessage : array [TWaitPIDResult] of TString =
    ('did not terminate with status ',
     'terminated with status ',
     'was teminated by signal ',
     'was stopped by signal ',
     'did something unexpected with status ');

var
  ToInput, f : Text;
  Process : PPipeProcess;
  WaitPIDResult : TWaitPIDResult;
  Status : Integer;
  IsEOF : Boolean;
  Result, s : TString;
  Parameters : TPStrings (1) = (@'exit-42');

begin
  if ParamStr (1) = 'exit-42' then Halt (42);
  s := ParamStr (0);
  {$ifdef __GO32__}
  if Copy (s, Length (s) - 3) = '.out' then s := Copy (s, 1, Length (s) - 4) + '.exe';
  {$endif}
  {$local I-}
  Pipe (ToInput, f, f, s, Parameters, GetCEnvironment, Process, nil);
  {$endlocal}
  if InOutRes <> 0 then
    begin
      WriteLn ('Could not create pipe: ', GetIOErrorMessage);
      Halt (1)
    end;
  Process^.Result := @WaitPIDResult;
  Process^.Status := @Status;
  Close (ToInput);
  IsEOF := EOF (f);
  if not IsEOF then ReadLn (f, Result);
  Close (f);
  if not IsEOF then
    WriteLn ('Unexpected output `', Result, '''')
  else if (WaitPIDResult = PIDExited) and (Status = 42) then
    WriteLn ('OK')
  else
    WriteLn ('The process ', ResultMessage [WaitPIDResult], Status, '.');
end.
