program fjf464e;

uses GPC;

procedure f;

  procedure d (var Dummy);
  begin
    WriteLn ('OK')
  end;

begin
  var f: Text;
  AssignTFDD (f, nil, nil, nil, nil, nil, nil, nil, d, nil)
end;

begin
  f
end.
