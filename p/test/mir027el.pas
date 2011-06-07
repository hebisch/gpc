program mir027el;
{Inc with enumerated out of bounds, lower}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;

var j,k,Res : TGrayScale;
    i: TMidTones;

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
   j:=Gray70; k:=Black;
   {k out of the range}
   i := j;
   repeat
     Dec (i)
   until i = k;
end.
