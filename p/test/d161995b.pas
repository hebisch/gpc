{ Debian bug report #161995. Fixed in gpc-2.1 already. }

program gpc_in_bug;

var
  r: record end;

begin
  if 0 in r then begin end; { r is not a set -> gpc segfaults } { WRONG }
  WriteLn ('failed')
end.
