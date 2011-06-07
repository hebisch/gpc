program AtExit1;

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
  AtExit (O)
end.
