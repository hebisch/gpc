module ModT7 interface;

export
  ModT7 = (r, st2..st4);  { Fixed: Exported ranges are supported now. }

type
  arange = (st1, st2, st3, st4, st5);

var
  r: arange;

end.

module ModT7 implementation;

end.
