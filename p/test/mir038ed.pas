{$gnu-pascal}
program mir038ed;
{slice array write, what Francois has done for Integer here is for subrange}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;
var v   : array[TMidTones] of Integer;
    i,j : TGrayScale;
procedure  conformantArray(a: array[l..u : TMidTones] of Integer);
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
   i:=Gray80; j:=White;
   {i > upper, j > upper}
   conformantArray(v[i..j]);
end.
