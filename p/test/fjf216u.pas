unit fjf216u;

interface

type
  pj = ^j;
  j = record
    ba1,
    ba2 : Real;
    ba3,
    ba4 : Integer;
    ba5,
    ba6 : Boolean
  end;

  o = object
    constructor c;
    function  d : Boolean; virtual;
  end;

implementation

constructor o.c;
begin
end;

function o.d : Boolean;
type
  r = record
    fo1, fo2, fo3 : Real;
    fo4 : Integer;
  case Boolean of
    False : (fo5 : Real;
             fo6,
             fo7 : Boolean;
             fo8,
             fo9 : pj);
    True  : (fo10 : Real);
  end;

  t (Capacity : Integer) = record
    Size : 0..Capacity;
    Values : array [1..Capacity] of r
  end;

var
  v : t (42);

  function foo (const v : t) : Boolean; attribute (inline);
  begin
    foo := v.Size = 0
  end;

  function bar (var v : t) : Boolean;
  begin
    bar := foo (v)
  end;

begin
  v.Size := 0;
  d := bar (v)
end;

end.
