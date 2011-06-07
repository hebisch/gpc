unit fjf218u;

interface

type
  ppil = ^pil;
  pil = ^il;
  il  = record
    Next : pil;
    v    : Integer
  end;

  pm = ^m;
  m = object
    Next : pm;
    constructor Init;
    destructor Done; virtual;
  end;

  e = object (m) end;
  pe = ^e;

procedure dil (i : pil);

implementation

procedure dil (i : pil);
var t : pil;
begin
  while i <> nil do
    begin
      t := i;
      i := i^.Next;
      Dispose (t)
    end
end;

constructor m.Init;
begin
end;

destructor m.Done;
begin
end;

end.
