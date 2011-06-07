program Knuth3 (Output);

label
  42;

procedure Initialize;
begin
  WriteLn ('OK');
  goto 42;
  goto 42
end;

begin
  Initialize;
  WriteLn ('failed');
  42:
end.
