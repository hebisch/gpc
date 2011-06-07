program fjf445d;

type
  t = object
    i : Integer;
  end;

const
  v : t = (nil, 42);  { WRONG }

begin
end.
