program fjf390c;

uses GPC;

var
  x : CString;
  a: array [1 .. 3] of Char = 'xOK';

begin
  x := a [1 .. 2];
  if CStringComp (x, 'xO') <> 0 then
    begin
      WriteLn ('failed ', CString2String (x));
      Halt
    end;
  WriteLn (a [2 .. 3])
end.
