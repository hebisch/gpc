program foo;

type
  PString = ^String;
  o = object
    p : PString;
    destructor d;
  end;

destructor o.d;
begin
end;

type
  pl = ^tl;
  tl = record
    f : ^PString;
  end;

function c = p : pl;
begin
  New (p)
end;

var
  v : PString = @'OK';

begin
  with c^ do
    begin
      f := @v;
      WriteLn (f^^)
    end
end.
