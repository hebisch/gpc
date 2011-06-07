program mir046el;
{type with enumerated initializer out of bounds, lower}
uses GPC;

type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);


procedure localProc (parm: TGrayScale);
type Foo = Gray30..Gray70 Value parm;
var a: Foo;
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
   localProc (Gray20);
end.
