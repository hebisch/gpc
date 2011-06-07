program fjf390d;

uses GPC;

var
  x : CString;
  a: array [1 .. 2, 1 .. 2] of Char = ('ab', 'OK');

begin
  x := a[1];
  if CStringComp (x, 'ab') <> 0 then
    begin
      WriteLn ('failed ', CString2String (x));
      Halt
    end;
  WriteLn (a[2])
end.
