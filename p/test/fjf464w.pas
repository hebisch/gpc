unit fjf464w;

interface

implementation

uses GPC;

procedure d (var Dummy);
begin
  WriteLn ('OK')
end;

to begin do
  begin
    var f: Text;
    AssignTFDD (f, nil, nil, nil, nil, nil, nil, nil, d, nil)
  end;

end.
