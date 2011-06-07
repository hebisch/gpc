{ FLAG --borland-pascal }

program fjf425;

{$W-}  { Does NOT turn off warnings in --borland-pascal }

function foo: Integer;  { So this will still WARN }
begin
end;

begin
  WriteLn ('failed ', foo)
end.
