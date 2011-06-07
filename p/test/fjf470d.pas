{ FLAG --borland-pascal }

program fjf470d;

{$W underscore}

var
  _foo : Integer; { WARN }

begin
  WriteLn ('failed')
end.
