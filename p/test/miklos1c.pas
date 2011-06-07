{ BUG: No runtime checks are done for [sub]string assignments. }

Program Miklos1c;

uses GPC;

Var
  str: String ( 13 );
  i, j: Integer;

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

begin
  AtExit (ExpectError);
  str:='1234567failed';
  str:='1234567OK';
  i:=8;
  j:=15;
  str[i..j]:= '';   { wipes out one character }
end.
