program fjf864g5;

uses fjf864m;

type
  ooo = object (oo)
    procedure v;
  end;

procedure ooo.v;
begin
  Self.s  { WRONG }
end;

begin
end.
