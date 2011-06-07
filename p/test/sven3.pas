Program Sven3;

uses
  Sven2;

procedure Check ( c: Char );
begin
  write(c);
end;

procedure CallAnyProc(H: HeadL; P: ProcP);
var
  HSave: HeadL;
begin
  HSave:= H;
  H:= '1234567890';
  H:= HSave;
  {$W-} P^ ( H ); {$W+}
  { Fixed: Extended Pascal allows assignments Char:= String. :-( }
end;

begin
  CallAnyProc('O', @Check);
  CallAnyProc('K', @Check);
  writeln;
end.
