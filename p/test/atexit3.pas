program AtExit3;

uses GPC;

procedure O;
begin
  Write ('O')
end;

procedure K;
begin
  WriteLn ('K');
  Halt {!}
end;

begin
  AtExit (K);
  AtExit (O);
  RunError (42)
end.
