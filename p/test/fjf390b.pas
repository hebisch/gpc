program fjf390b;

uses GPC;

procedure foo (x : CString);
begin
  if CStringComp (x, 'ab') <> 0 then
    begin
      WriteLn ('failed ', CString2String (x));
      Halt
    end
end;

var
  a: array [1 .. 2, 1 .. 2] of Char = ('ab', 'OK');

begin
  foo (a[1]);
  WriteLn (a[2])
end.
