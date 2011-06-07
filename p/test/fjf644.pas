program fjf644;

type
  poo = ^oo;
  oo = object
    constructor a;
    procedure m (const s: String); virtual;
  end;

var
  Called: Integer = 0;

constructor oo.a;
begin
end;

procedure oo.m;
begin
  if Called = 1 then
    WriteLn (s)
  else
    WriteLn ('failed ', Called)
end;

function Foo = r: poo;
begin
  Inc (Called);
  New (r)
end;

begin
  Foo^.m ('OK')
end.
