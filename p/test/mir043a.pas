program mir043a;
{schema with integer discrimintant out of bounds, lower}
uses GPC;
type
  TIntegers (Size: Integer) = array [1 .. Size] of Integer;
  PIntegers = ^TIntegers;
var k  : Integer;
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
   k:=0;
   {k < 1 bellow the lowerbound}
   New (sh, k);
end.
