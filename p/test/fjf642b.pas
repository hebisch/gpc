program fjf642b;

type
  t = object
    function f: Text;  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
