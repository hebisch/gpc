
program fjf902a;
begin
  case 'x' of
    SubStr ('abc', 1, 1) .. 'z':  { WRONG }
  end
end.
