program mir043lu;
{schema with long integer discriminant out of bounds, upper}
uses GPC;
const
  LB = 200000000012;
  UB = 200000000042;
type
  range = LB..UB;
  TIntegers (First, Last: range) = array [First .. Last] of Integer;
  PIntegers = ^TIntegers;
var u, l  : LongInt;
    sh : ^TIntegers;

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
   l := LB;
   u := Succ (UB);
   {u above the range}
   New (sh, l, u);
   sh^[Pred (UB)] := 0;
   Dispose (sh);
end.
