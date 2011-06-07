program fjf219c;

uses GPC;

procedure DoneProc (var PrivateData);
begin
  Write ('O')
end;

var
  f : ^Text;

begin
  New (f);
  AssignTFDD (f^, nil, nil, nil, nil, nil, nil, nil, DoneProc, nil);
  Rewrite (f^);
  Dispose (f);  { DoneProc of f should automatically be called here }
  WriteLn ('K')
end.
