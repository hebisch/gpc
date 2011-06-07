program fjf720c;

type
  foo = object
    procedure bar;
  end;

procedure foo.bar; external;

procedure foo.bar;  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
