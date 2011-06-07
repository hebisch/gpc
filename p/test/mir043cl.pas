program mir043cl;
{schema with char subrange discriminant out of bounds, lower}
uses GPC;
const
  LB = 'c';
  UB = 'f';
type
  range = LB..UB;
  TIntegers (First, Last: range) = array [First .. Last] of Integer;
  PIntegers = ^TIntegers;
var u, l  : Char;
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
   l := Pred (LB);
   u := UB;
   {l bellow the range}
   New (sh, l, u);
   sh^[Pred (UB)] := 0;
   Dispose (sh);
end.
