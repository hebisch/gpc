program fjf713;

type
  a = object
    x: a  { WRONG }
  end;

begin
  WriteLn ('failed')
end.
