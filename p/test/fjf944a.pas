{$object-pascal}

program fjf944a;

function f: Integer; forward;

function f = r: Integer;  { WRONG according to OOE draft }
begin
  r := 42
end;

begin
end.
