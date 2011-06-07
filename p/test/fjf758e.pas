program fjf758e;

type
  o = object
        constructor i;
        procedure p; virtual;  { WRONG }
      end;

constructor o.i;
begin
end;

begin
  WriteLn ('failed')
end.
