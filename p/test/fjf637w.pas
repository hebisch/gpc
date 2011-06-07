program fjf637w;

type
  a = object
    procedure foo; abstract;
  end;

procedure a.foo;  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
