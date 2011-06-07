program fjf864g6;

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
  WriteLn (v.d)  { WRONG }
end.
