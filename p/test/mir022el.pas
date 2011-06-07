program mir022el;
{procedure call with enumerated out of bounds, lower}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;

var k : TGrayScale;

procedure CallWithRange (myInt: TMidTones);
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
   k:=Black;
   {k bellow the range}
   CallWithRange (k);
end.
