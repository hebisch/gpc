program mir029el;
{assigning sets to smaler subrange, enumerated}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;

var k : Char;
    SetA : set of TMidTones Value [];
    SetB : set of TGrayScale Value [Black];

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
   SetA := SetB;
end.
