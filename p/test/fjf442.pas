program fjf442;

type
  foo = object
    bar : baz { WRONG }
  end;

begin
  WriteLn ('failed')
end.
