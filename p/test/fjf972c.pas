{$borland-pascal}

program fjf972c;

type
  t = record a: Integer end;

const
  c = t[a: 0];  { WRONG }

begin
end.
