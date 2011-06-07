program fjf659o;

uses GPC;

var
  a: Text;

procedure DoneProc (var PrivateData);
begin
  Write ('O')
end;

begin
  AssignTFDD (a, nil, nil, nil, nil, nil, nil, nil, DoneProc, nil);
  Rewrite (a);
  Finalize (a);  { DoneProc of f should be called here }
  WriteLn ('K')
end.
