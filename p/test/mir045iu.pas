program mir045iu;
{schema with integer discriminant out of bounds, upper}
uses GPC;
const
  LBX = 12;
  UBX = 42;
  LBY = 50;
  UBY = 64;
type
  range1 = LBX..UBX;
  range2 = LBY..UBY;
  TIntegers (lx, ux: range1;
             ly, uy: range2) = array [lx..ux] of array [ly..uy] of Integer;
  PIntegers = ^TIntegers;
var u, l, v, m : Integer;
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
