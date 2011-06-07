program fjf922;

type
  a = object
    procedure p;
  end;

  b = object (a)
  private
    procedure p;  { WRONG }
  end;

procedure a.p;
begin
end;

procedure b.p;
begin
end;

begin
end.
