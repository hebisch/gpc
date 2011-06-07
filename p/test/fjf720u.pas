unit fjf720u;

interface

type
  foo = object
    procedure bar;
  end;

procedure foo.bar;  { WRONG }

implementation

procedure foo.bar;
begin
end;

end.
