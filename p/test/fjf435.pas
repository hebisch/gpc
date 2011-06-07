program fjf435;

uses GPC;

procedure Foo (const FileName : String; LineNumber : Integer);
begin
  if (LineNumber = 14) and IsSuffix ('fjf435.pas', FileName) then
    Write ('failed 1')
  else
    Write ('failed ', FileName, ' ', LineNumber)
end;

{$debug-statement=foo}  { WARN -- not supported anymore, Frank, 20030418 }
begin
{$no-debug-statement}
  WriteLn;
end.
