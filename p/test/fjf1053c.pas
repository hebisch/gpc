{$range-and-object-checking}

program fjf1053c (Output);

type
  o = object
    constructor Init;
    procedure p; virtual;
    procedure q;
  end;

constructor o.Init;
begin
end;

procedure o.p;
begin
  WriteLn ('OK')
end;

procedure o.q;
begin
  o.p  { no virtual call -> no check (as currently implemented) }
end;

var
  a: ^o;

begin
  New (a);
  SetType (a^, nil);
  a^.q
end.
