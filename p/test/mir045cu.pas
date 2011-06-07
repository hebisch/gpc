program mir045cu;
{schema with integer discriminant out of bounds, upper}
uses GPC;
const
  LBX = 'c';
  UBX = 'f';
  LBY = 'm';
  UBY = 'q';
type
  range1 = LBX..UBX;
  range2 = LBY..UBY;
  TIntegers (lx, ux: range1;
             ly, uy: range2) = array [lx..ux] of array [ly..uy] of Integer;
  PIntegers = ^TIntegers;
var u, l, v, m : Char;
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
   l := LBX;
   m := LBY;
   u := Succ (UBX);
   v := UBY;
   New (sh, l, u, m, v);
   Dispose (sh);
end.
