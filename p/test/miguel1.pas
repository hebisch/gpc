program miguel1;

type
  pitem = ^descend;
  descend =
    object
      prev,next: pitem;
      i: char;
      constructor init(ii: char);
      destructor done; virtual;
    end;

  plist = ^list;
  list =
    object
      first,last: pitem;
      constructor init;
      destructor done;
      function extfirst: pitem;
      procedure add(l: pitem);
      procedure adddesc(i: char);
    end;

constructor descend.init(ii: char);
begin
  prev :=nil;
  next :=nil;
  i :=ii;
end;

destructor descend.done;
begin
  write(i);
end;

constructor list.init;
begin
  first :=nil; last :=nil;
end;

destructor list.done;
var a:pitem;
begin
  while (first<>nil) do
    dispose(extfirst,done);
end;

function list.extfirst: pitem;
var
  item: pitem;
begin
  extfirst :=first;
  if (first=nil) then exit;
  item :=first; first :=first^.next; item^.next :=nil;
  if (first<>nil) then first^.prev :=nil
  else last :=nil;
end;

procedure list.add(l: pitem);
begin
  if (first=nil) then first :=l
  else last^.next :=l;
  l^.prev :=last; last :=l;
end;

procedure list.adddesc(i: char);
begin
  add(new(pitem,init(i)));
end;

var
  alist: plist;

begin
  new(alist,init);
  alist^.adddesc('O');
  alist^.adddesc('K');
  dispose(alist,done);
  writeln
end.
