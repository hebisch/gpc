program fjf592h;

type
  TFoo = -1 .. MaxInt;
  PFoo = ^TFoo;
  TBar = -1 .. 3;
  PBar = ^TBar;

procedure Bar (var b: PBar);
begin
end;

var
  a: PFoo;

begin
  Bar (a);  { WRONG }
  WriteLn ('failed')
end.
