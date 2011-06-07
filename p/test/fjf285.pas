program fjf285;

type
  po = ^o;
  o = object
  end;

  oo = object (o)
    constructor init;
    destructor done;
  end;

constructor oo.init;
var p : po;
begin
  new (p);
  dispose (p, done)  { WRONG }
end;

destructor oo.done;
begin
  writeln ('failed')
end;

var v : oo;

begin
  v.init
end.
