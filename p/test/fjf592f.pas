program fjf592f;

type
  TFoo = -1 .. MaxInt;

procedure Bar (var b: TFoo); forward;

procedure Bar (var b: Integer);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
