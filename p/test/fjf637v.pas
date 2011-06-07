program fjf637v;

type
  a = object
    procedure foo; abstract;
  end;

procedure a.bar;  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
