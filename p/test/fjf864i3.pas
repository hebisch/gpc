program fjf864i3;

uses fjf864m;

type
  ooo = object (o)
    procedure uu;
  end;

procedure ooo.uu;
begin
  WriteLn (Self.d)  { WRONG }
end;

begin
end.
