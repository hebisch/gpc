program fjf696b;

type
  a = object
    p: procedure (e: d);  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
