program bounds2;

uses GPC;

type
 a = array[1..10] of Integer;
var
  i : Integer;
  x,y : a;

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
  for i := 20 downto 1 do
    WriteLn( x[i], '  ', y[i] );
end.
