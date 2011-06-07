unit fjf482u;

interface

uses GPC, fjf482v;

implementation

var
  SaveInitProc : ^procedure;

procedure MyInitProc;
begin
  if InitProcCalled <> 0 then
    begin
      WriteLn ('failed 3');
      Halt (1)
    end;
  InitProcCalled := 1;
  SaveInitProc^
end;

begin
  if InitProcCalled <> 0 then
    begin
      WriteLn ('failed 2');
      Halt (1)
    end;
  SaveInitProc := InitProc;
  InitProc := @MyInitProc
end.
