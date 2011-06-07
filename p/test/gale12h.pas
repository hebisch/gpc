{ FLAG --range-checking }

{$R+}

program rangecheck4;

uses GPC;

var i: 1..5;

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
         i:= 4;
         i:= i+2;
         WriteLn( 'i = ', i);
end.
