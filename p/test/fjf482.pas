program fjf482;

uses fjf482u, fjf482v;

begin
  if InitProcCalled <> 2 then
    begin
      WriteLn ('failed 5');
      Halt (1)
    end;
  WriteLn ('OK')
end.
