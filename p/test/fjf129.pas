program fjf129;

var eps : real = 1e-14;

function realeq(x,y:LongestReal):Boolean;
begin
  realeq := Abs (x-y) <= eps * Abs(x)
end;

procedure test(val,int_val,frac_val:Double);
begin
  if not realeq(int(val),int_val) or not realeq(frac(val),frac_val) then
    begin
      writeln('Failed: ',val,': ',int(val),', ',int_val,'; ',frac(val),', ',frac_val);
      halt
    end;
  if val>0 then test(-val,-int_val,-frac_val)
end;

begin
  test(0,0,0);
  test(0.9,0,0.9);
  test(1.1,1,0.1);
  test(41.9999999,41,0.9999999);
  test(42,42,0);
  test(1e300,1e300,0);
  test(1e300+0.1,1e300,0);
  eps:=1e-3;
  test(1e12+0.1,1e12,(1e12+0.1)-1e12);
  test(8*2147483647+0.7,8*2147483647,0.7);
  writeln('OK')
end.
