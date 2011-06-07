program fjf642a;

type
  t = object
    function f: blah;  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
