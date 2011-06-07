{ Default is BP compatible (more useful with object methods),
  in contrast to EP, see fjf758h.pas. }

program fjf758i;

procedure foo; forward;

const
  a = 1;

procedure foo;
begin
  WriteLn ('OK')
end;

begin
  foo
end.
