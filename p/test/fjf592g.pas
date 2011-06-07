program fjf592g;

type
  TFoo = -1 .. MaxInt;
  TBar = -1 .. 3;

procedure Bar (var b: TFoo); forward;

procedure Bar (var b: TBar);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
