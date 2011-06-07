program fjf890d;

type
  a = object
    b: array [False .. TypeOf (a) <> nil] of Integer  { WRONG }
  end;

begin
end.
