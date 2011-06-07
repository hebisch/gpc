{
Hope it's fixed now (couldn't reproduce all cases) -- Frank:
Fails sometimes (<Pine.LNX.4.21.0106250242470.19920-100000@@rusty.russwhit.com>; Frank: Solaris)
}

program fjf469;
type
  bar = ^undef; { WRONG }
begin
end.
