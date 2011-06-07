program fjf758d;

type
  o = object
        procedure p;  { WRONG }
      end;

begin
  WriteLn ('failed')
end.
