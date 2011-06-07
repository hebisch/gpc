program fjf299;

type
  pitem = ^descend;
  descend =
    object
      i: string(2);
      constructor init;
    end;

  plist = ^list;
  list =
    object
      first: pitem;
      constructor init;
      function extfirst: pitem;
    end;

constructor descend.init;
begin
  i := 'OK'
end;

constructor list.init;
begin
  new(first,init);
  writeln(extfirst^.i)
end;

function list.extfirst: pitem;
begin
  extfirst := first;
end;

var
  alist: plist;

begin
  new(alist,init)
end.
