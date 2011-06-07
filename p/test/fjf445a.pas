program fjf445a;

type
  t = object
    i : Integer;
    constructor foo;
  end;

constructor t.foo;
begin
  WriteLn ('failed');
  Halt
end;

const
  v : t = (i : 42);

begin
  if (TypeOf (v) = TypeOf (t)) and (v.i = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', PtrInt (TypeOf (v)), ' ', PtrInt (TypeOf (t)), ' ', v.i)
end.
