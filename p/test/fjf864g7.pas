program fjf864g7;

uses fjf864m;

type
  ooo = object (oo)
    procedure v;
  end;

procedure ooo.v;
begin
end;

var
  v: ooo;

begin
  v.s  { WRONG }
end.
