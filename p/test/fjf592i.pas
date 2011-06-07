program fjf592i;

type
  TFoo = -1 .. MaxInt;
  TBar = -1 .. 3;

procedure Bar (var b: TBar);
begin
end;

var
  a: TFoo;

begin
  Bar (a);  { WRONG }
  WriteLn ('failed')
end.
