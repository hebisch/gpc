{ Same as nlgpp.pas, but with more paranoia checks. }

program NLGPP2 (Output);

procedure Fail;
begin
  WriteLn ('failed')
end;

procedure Recursive (n: Integer; procedure Proc);
label 1, 2;

  procedure DoGoto;
  begin
    WriteLn ('DoGoto ', n, ' ', @Proc = @Fail);
    goto 1
  end;

begin
  WriteLn ('Recursive start ', n, ' ', @Proc = @Fail);
  if n = 3 then
    Recursive (n - 1, DoGoto)
  else if n > 0 then
    Recursive (n - 1, Proc)
  else
    Proc;
  WriteLn ('Recursive before goto ', n, ' ', @Proc = @Fail);
  goto 2;

1:
  if n = 3 then
    WriteLn ('OK')
  else
    WriteLn ('failed ', n);

2:
  WriteLn ('Recursive end ', n, ' ', @Proc = @Fail);
end;

begin
  WriteLn ('Main start');
  Recursive (10, Fail);
  WriteLn ('Main end')
end.
