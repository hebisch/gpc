{$borland-pascal}

program fjf938b;

type
  a = object
    procedure p (...);  { WRONG }
  end;

procedure a.p (...);
begin
end;

begin
end.
