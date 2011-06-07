program mir036eu;
{unpack range test}
uses GPC;
type TGrayScale = (Black, Gray10, Gray20, Gray30, Gray40, Gray50,
                   Gray60, Gray70, Gray80, Gray90, White);
     TMidTones = Gray30..Gray70;

var arry  : array [TMidTones] of Char;
    parry : packed array [TMidTones] of Char;
    k     : TGrayScale;

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
   k:=White;
   Unpack (parry, arry, k);
   {k above the range}
end.
