{$W-,delphi}

program fjf493h;

type
  t = record
    a: Integer
  end;

var
  v: t = (a: 0);

function f: t;
begin
  f := v
end;

begin
  with f do a := 42;
  WriteLn ('OK')
end.
