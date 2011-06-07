program fjf643;

type
  o = object end;

  poo = ^oo;
  oo = object (o)
    procedure m (const s: String);
  end;

procedure oo.m;
begin
  WriteLn (s)
end;

var
  p: ^o;

begin
  p := New (poo);
  (p^ as oo).m ('OK')
end.
