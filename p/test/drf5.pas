program drf5 (Output);

uses GPC;

var
  a : 0 .. 2;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

{$classic-pascal}

begin
  AtExit (ExpectError);
  a := 1;
  case a of
    0 : ;
  end;
  WriteLn ('failed')
end.
