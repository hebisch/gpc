program NLGPP (Output);

procedure Fail;
begin
  WriteLn ('failed')
end;

procedure Recursive (n: Integer; procedure Proc);
label 1, 2;

  procedure DoGoto;
  begin
    goto 1
  end;

begin
  if n = 3 then
    Recursive (n - 1, DoGoto)
  else if n > 0 then
    Recursive (n - 1, Proc)
  else
    Proc;
  goto 2;

1:
  if n = 3 then
    WriteLn ('OK')
  else
    WriteLn ('failed ', n);

2:
end;

begin
  Recursive (10, Fail)
end.
