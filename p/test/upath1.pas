Program UPath1;

uses
  GPC;  { Automatically found in                            }
        { <prefix>/lib/gcc-lib/<platform>/<version>/units/. }

begin
  if OSDosFlag { declared in gpc.pas } in [False, True] then
    writeln ( 'OK' );
end.
