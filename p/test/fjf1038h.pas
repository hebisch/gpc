program fjf1038h (Output);

label 1;

procedure p;
begin
  goto 1;
end;

var
  a: record b: Integer end;

begin
  with a do 1:  { WRONG }
end.
