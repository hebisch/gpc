program fjf629h;

procedure foo (var s: String);
begin
end;

begin
  WriteLn ('failed');
  Halt;
  foo (FormatString (''))  { WRONG }
end.
