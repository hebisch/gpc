program mir041el;
{local initializer out of bounds}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     lightRange = Gray50..White;
var k : TGrayScale;

procedure Local (parm: TGrayScale);
var ch : lightRange Value parm;
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
   k := Gray20;
   Local (k);
end.
