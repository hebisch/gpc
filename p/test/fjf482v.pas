unit fjf482v;

interface

uses GPC;

var
  InitProcCalled : Integer = 0;

implementation

var
  SaveInitProc : ^procedure;

procedure MyInitProc;
begin
  if InitProcCalled <> 1 then
    begin
      WriteLn ('failed 4');
      Halt (1)
    end;
  InitProcCalled := 2;
  SaveInitProc^
end;

begin
  if InitProcCalled <> 0 then
    begin
      WriteLn ('failed 1');
      Halt (1)
    end;
  SaveInitProc := InitProc;
  InitProc := @MyInitProc
end.
