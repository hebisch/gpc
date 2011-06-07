program fjf642c;

type
  t = object
    function f: String;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
