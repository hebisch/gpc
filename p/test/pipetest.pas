{ Test of the Pipes unit. (Very similar to PipeDemo.) }

program PipeTest;

uses GPC, Pipes;

const
  ResultMessage : array [TWaitPIDResult] of TString =
    ('did not terminate with status ',
     'terminated with status ',
     'was teminated by signal ',
     'was stopped by signal ',
     'did something unexpected with status ');

var
  ToInput : Text;
  FromOutput, FromStdErr : File;
  Process : PPipeProcess;
  WaitPIDResult : TWaitPIDResult;
  Status : Integer;
  Files : array [1 .. 2] of PAnyFile;
  Outputs : array [1 .. 2] of TString;

procedure CheckProcessOutput (TimeOut : LongInt);
var
  Nr, BytesRead : Integer;
  Buffer : array [1 .. 256] of Char;
begin
  Nr := -1;
  while (Nr <> 0) and ((Files [1] <> nil) or (Files [2] <> nil)) do
    begin
      Nr := IOSelectRead (Files, TimeOut);
      if Nr < 0 then
        begin
          WriteLn (StdErr, 'Error in `IOSelect''');
          Halt (1)
        end;
      if Nr > 0 then
        begin
          BlockRead (File (Files [Nr]^), Buffer, SizeOf (Buffer), BytesRead);
          if BytesRead = 0 then
            Files [Nr] := nil
          else
            Outputs [Nr] := Outputs [Nr] + Buffer [1 .. BytesRead]
        end
    end
end;

procedure DemoProcedure;
var s : TString;
begin
  Write (StdErr, 'qwe');
  while not EOF do
    begin
      ReadLn (s);
      WriteLn ('Writing `', s, ''' to Output.');
      WriteLn (StdErr, 'Writing `', s, ''' to Error.')
    end;
  Flush (Output);
  Flush (StdErr)
end;

begin
  {$ifdef _WIN32}
  WriteLn ('SKIPPED: IOSelect not yet implemented for mingw'); { @@ }
  Halt;
  {$endif}

  {$local I-}
  Pipe (ToInput, FromOutput, FromStdErr, '', Null, GetCEnvironment, Process, DemoProcedure);
  {$endlocal}
  if InOutRes <> 0 then
    begin
      WriteLn ('Could not create pipe: ', GetIOErrorMessage);
      Halt (1)
    end;
  Process^.Result := @WaitPIDResult;
  Process^.Status := @Status;
  Files [1] := @FromOutput;
  Files [2] := @FromStdErr;
  Outputs [1] := '';
  Outputs [2] := '';
  CheckProcessOutput (0);
  WriteLn (ToInput, 'foo');
  CheckProcessOutput (0);
  Sleep (1);
  WriteLn (ToInput, 'bar');
  CheckProcessOutput (0);
  Close (ToInput);
  CheckProcessOutput (- 1);
  Close (FromOutput);
  Close (FromStdErr);
  if Outputs [1] <> 'Writing `foo'' to Output.' + LineBreak + 'Writing `bar'' to Output.' + LineBreak then
    begin
      WriteLn ('Wrong output.');
      Halt (1)
    end;
  if Outputs [2] <> 'qweWriting `foo'' to Error.' + LineBreak + 'Writing `bar'' to Error.' + LineBreak then
    begin
      WriteLn ('Wrong standard error output.');
      Halt (1)
    end;
  if (WaitPIDResult = PIDExited) and (Status = 0) then
    WriteLn ('OK')
  else
    WriteLn ('The process ', ResultMessage [WaitPIDResult], Status, '.');
end.
