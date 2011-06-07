unit fjf217v;

interface

uses fjf217w;

type
  e = object (be)
    fa, fb : Integer;
    constructor Init (a, b : Integer);
    procedure foo; virtual;
  end;

  pe = ^e;

implementation

constructor e.Init (a, b : Integer);
begin
  fa := a;
  fb := b;
end;

procedure e.foo;
begin
  writeln (chr (fa), chr (fb))
end;

end.
