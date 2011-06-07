program fsc37;
{? for with integer out of bounds}
uses GPC;
type range = 2..36; { :-) }
var j,k,Res : Integer;
    i: range;

procedure CallWithRange (myInt: range);
begin
end;

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
   AtExit(ExpectError);
   j:=2; k:=40;
   {k out of the range of i (char)}
   for i:=j to k do
      CallWithRange (k);
end.
