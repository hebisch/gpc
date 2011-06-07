program fjf864g3;

uses fjf864m;

type
  ooo = object (oo)
    procedure v;
  end;

procedure ooo.v;
begin
  WriteLn (Self.d)  { WRONG }
end;

begin
end.
