program fjf642d;

type
  a (d: Integer) = Integer;

  t = object
    function f: a;  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
