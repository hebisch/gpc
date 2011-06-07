program fjf772;

type
  Name = object
    procedure foo (var a: Name);
  end;

procedure Name.foo (var a: Name);
begin
end;

begin
  WriteLn ('OK')
end.
