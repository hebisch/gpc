unit adam2v;

interface

type
  MList = object
    constructor Init(ALimit: Integer);
  end;

implementation

constructor MList.Init(ALimit: Integer);
begin
  if ALimit = 8 then WriteLn ('OK') else WriteLn ('failed')
end;

end.
