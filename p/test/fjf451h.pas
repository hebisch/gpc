{ This test tests object assignments. Like the whole object model, this is
  meant to be BP compatible. However, BP's implementation is intrinsically
  buggy: When the target of the assignment (here: x) is polymorphic, it tries
  to copy all the fields of its actual type (oo). However, the left hand
  side (v) does not have to be of that type (or a sub-object). It needs only
  to have the declared type (o), so it may not have all the fields that are
  read. This can cause read overruns. In fact, this program produces a runtime
  error in BP (at least in protected mode) for this reason.

  Therefore, we do not duplicate the buggy feature. We only copy the fields of
  the declared type. This is safe, though it yields a slightly different result
  in strange cases (see fjf451g.pas) and it may leave some fields of the target
  unassigned. Therefore we give an additional warning (fjf451i.pas). }

program fjf451h;

type
  o = object
    a: Integer;
    constructor i;
  end;

  oo = object (o)
    b: array [1 .. 1000] of Integer;
  end;

constructor o.i;
begin
end;

var
  w: oo;
  v: o;

procedure p (var x: o);
begin
  {$local W-} x := v {$endlocal}
end;

begin
  w.i;
  w.a := 1;
  v.i;
  v.a := 2;
  p (w);
  if w.a = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
