{ FLAG -O0 }

program fjf105b;

const u = 42;

uses fjf105u;

begin
  if u = 42
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
