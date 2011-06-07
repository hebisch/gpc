unit delphi6u;
interface
procedure pd();
procedure pdd();
procedure p;
function fd(): integer;
function f: integer;
procedure ppd(procedure pd());
procedure pdp(procedure p);
function ffd(function fd(): integer): integer;

type dob = object
  procedure pd();
  procedure pdd();
  procedure p;
end;

type pt = procedure ();
     pdt = procedure (pd : pt);

var pv, pdv: pdt;
    iv : integer;
    ov : dob;
implementation
procedure pd;
begin
  pdv := pdp
end;
procedure pdd();
begin
  iv := iv + 2;
end;
procedure p();
begin
  ov.pd();
end;
function fd: integer;
begin
  fd := 77
end;
function f(): integer;
begin
  f := 17
end;
procedure dob.pd;
begin
  iv := iv + 1;
end;
procedure dob.pdd();
begin
  pv := ppd
end;
procedure dob.p();
begin
  iv := ffd(f)
end;
procedure ppd(procedure pd);
begin
  pd
end;
procedure pdp(procedure p());
begin
  p
end;
function ffd(function fd: integer): integer;
begin
  ffd := fd()
end;

end
.
