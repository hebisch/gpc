program mir043eu;
{schema with enumerated discriminant out of bounds, upper}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;
const
  LB = Gray30;
  UB = Gray70;
type
  range = LB..UB;
  TIntegers (First, Last: range) = array [First .. Last] of Integer;
  PIntegers = ^TIntegers;
var u, l  : TGrayScale;
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
