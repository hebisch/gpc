{$gnu-pascal}
program mir037em;
{conformant array write}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;

var v : array[TMidTones] of Integer;

procedure  conformantArray(a : array[l..u : TGrayScale] of Integer);
var j : Integer;
begin
   {reading out of lower limits of the conformant array}
   j := a[Pred(l)];
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
   conformantArray(v);
end.
