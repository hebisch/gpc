program ProcBug;

type
  TProc = procedure;

procedure failed;

begin { failed }
  writeln ( 'failed' );
end { failed };

procedure OK;

begin { OK }
  writeln ( 'OK' );
end { OK };

procedure NoBug(X: TProc);
begin
  { X is passed by value as it should be }
  X:= failed;
end;

procedure Bug(var X: TProc);
begin
  { X is passed by value here too! }
  { If I tried to modify X, I would corrupt code of some procedure }
  X:= OK;
end;

var
  Tmp: TProc;

begin
  Tmp:= failed;
  NoBug(Tmp);  { These two calls in .S file are identical }
  Bug(Tmp);
  Tmp;
end.
