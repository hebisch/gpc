program fjf642m;

type
  t = object
    function f;  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
