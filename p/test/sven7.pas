program Bug;

function ReturnNum: Real;
begin
  ReturnNum := 0;
end;

function TestNum(AnyNum: Real): Real;
begin
  TestNum := AnyNum;
end;

var
  Test : Real;

begin
  Test := sqr(ReturnNum);
  { no compiler error }

  Test := TestNum(sin(ReturnNum));
  { no compiler error }

  Test := TestNum(sqr(0.1));
  { no compiler error }

  Test := TestNum(TestNum(ReturnNum));
  Test := TestNum(sqr(ReturnNum));
  Test := TestNum(abs(ReturnNum));
  Test := TestNum(round(ReturnNum));
  {
    the GPC compiler said:
      "argument to `Sqr' must be of integer, real or complex type"
  }

  writeln ( 'OK' );
end.
