{ internal compiler error ... }

program fjf501b;

uses GPC, fjf501u;

procedure p (s : String);
begin
  WriteLn (s)
end;

var
  v : PString = @'OK';

begin
  p (v^)
end.
