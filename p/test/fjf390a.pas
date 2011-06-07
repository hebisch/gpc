program fjf390a;

uses GPC;

procedure foo (x : CString);
begin
  if CStringComp (x, 'xO') <> 0 then
    begin
      WriteLn ('failed ', CString2String (x));
      Halt
    end
end;

var
  a: array [1 .. 3] of Char = 'xOK';

begin
  foo (a [1 .. 2]);
  WriteLn (a [2 .. 3])
end.
