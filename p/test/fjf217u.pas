unit fjf217u;

interface

uses fjf217w, fjf217x, fjf217v;

type
  o = object (TC)
    constructor i;
    procedure p (a, b : Integer);
  end;

implementation

constructor o.i;
begin
end;

procedure o.p (a, b : Integer);
begin
  RaiseMessage (New (pe, Init (a, b)))
end;

end.
