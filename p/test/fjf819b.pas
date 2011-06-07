{ More BP compatible than BP itself. ;-}

program fjf819b;

type
  a = array [1 .. 10] of ^c .. #4;
  b = record d: ^c .. #4 end;
  c = object e: ^c .. #4 end;
  d = record case Char of ^c .. #4: () end;
  e = array [1 .. 10] of #3 .. ^d;
  f = record d: #3 .. ^d end;
  g = object e: #3 .. ^d end;
  h = record case Char of #3 .. ^d: () end;

begin
  WriteLn ('OK')
end.
