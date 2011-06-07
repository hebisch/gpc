program fsc37;
{? for with integer out of bounds}
uses GPC;
type range = 20000000000..20000000036; { :-) }
var j,k,Res : LongInt;
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
   j:=20000000000; k:=20000000040;
   {k out of the range of i (char)}
   for i:=j to k do
      CallWithRange (k);
end.
