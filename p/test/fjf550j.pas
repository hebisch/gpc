program fjf550j;

procedure foo (const j: Integer);
var f: File;
begin
  BlockRead (f, j, SizeOf (j))  { WRONG }
end;

begin
  WriteLn ('failed')
end.
