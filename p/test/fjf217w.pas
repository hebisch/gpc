unit fjf217w;

interface

type
  pm = ^m;
  m = object
    Next : pm;
    constructor Init;
    procedure foo; virtual;
    destructor Done; virtual;
  end;

  be = object (m) end;

  pbe = ^be;

implementation

constructor m.Init;
begin
end;

procedure m.foo;
begin
end;

destructor m.Done;
begin
end;

end.
