program AtExit2;

uses GPC;

procedure O;
begin
  Write ('O')
end;

procedure K;
begin
  WriteLn ('K')
end;

begin
  AtExit (K);
  AtExit (O);
  Halt (0)
end.
