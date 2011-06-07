program Eike1b;

type
  TFoo = packed 2.7 .. 2.8;  { WRONG }

begin
  WriteLn ('failed');
end.
