program fjf864i5;

uses fjf864m;

type
  ooo = object (o)
    procedure uu;
  end;

procedure ooo.uu;
begin
  Self.s  { WRONG }
end;

begin
end.
