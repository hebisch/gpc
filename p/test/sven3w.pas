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
  P^ ( H );  { Fixed: Extended Pascal allows assignments Char:= String. :-( }
end;

begin
  CallAnyProc('O', Check);  { WRONG }
  { Fixed: Passing a procedure to a function which expects a *pointer* to }
  { Fixed:   a procedure was not recognized as an error.                  }
  CallAnyProc('K', @Check);
  writeln;
end.
