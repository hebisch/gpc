program fjf134;

type
  PList1 = ^TList1;
  TList1 = record
    Next : PList1;
  end;

  PList2 = ^TList2;
  TList2 = record
    Next : PList2
  end;

procedure p (List : PList1);
begin
  writeln ( 'failed' );
end;

var b: PList2;
begin
  p (b) { WRONG }
end.
