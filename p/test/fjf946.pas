program fjf946;

type
  t = object
    procedure p (Self: Integer);  { WRONG }
  end;

procedure t.p (Self: Integer);
begin
end;

begin
end.
