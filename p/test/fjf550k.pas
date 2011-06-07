program fjf550k;

procedure foo (const j: Integer);
var f: File;
begin
  BlockWrite (f, j, SizeOf (j))
end;

begin
  WriteLn ('OK')
end.
