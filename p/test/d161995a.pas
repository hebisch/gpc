{ Debian bug report #161995. Fixed in gpc-2.1 already. }

program gpc_in_bug;

var
  i: integer;

begin
  if 0 in i then begin end; { i is not a set -> gpc segfaults }  { WRONG }
  WriteLn ('failed')
end.
