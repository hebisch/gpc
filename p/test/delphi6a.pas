program delphi6;
uses delphi6u;
type tp = procedure;
     pp = ^ tp;
     ap = array [0..5] of tp;
     rp = record p : tp end;
procedure dummy;
begin
end;
function fpp : pp;
  var a : pp;
  begin
    new (a);
    a^ := dummy;
    fpp := a
  end;
function frp : rp;
  var a : rp;
  begin
    a.p := dummy;
    frp := a
  end;
function fap : ap;
  var a : ap;
      i : integer;
  begin
    for i:=0 to 5 do a[i] := dummy;
    fap := a
  end;
begin
  fap()[0];
  fap()[0]();
  fap[0]();
  frp().p;
  frp().p();
  frp.p();
  fpp()^;
  fpp()^();
  fpp^();
  fpp()^ := dummy;
  ov.p(); { calls ffd, f }
  ov.pdd;
  pv(pd); { calls ppd, pd }
  pdv(p); { calls pdp, p, ov.pd }
  pdd;
  if (iv = 20) and (ffd(fd) = 77) then
    writeln('OK')
  else
    writeln('failed')
end
.
