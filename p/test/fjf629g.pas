program fjf629g;

uses GPC;

const
  Expected = '*42*-1.2345000e+06*   3.14159*'#0'*False*%*False*a'#0'c*42*  -3*42*a'#0'c*';

function TransformString (const Foo: String): TString;
begin
  if Foo = 'foo'#0'bar' then
    TransformString := '*%@2s*%@5s*%@4s*'#0'*%@6s*%%*%@6s*%s*%i*%@3s*%@2i*%@1s*'
  else
    begin
      WriteLn ('failed in TransformString: ', Length (Foo), ' ', Foo);
      Halt
    end
end;

var
  i: Integer = -3;
  r: Real = -1234500;
  Res: TString;

begin
  FormatStringTransformPtr := @TransformString;
  Res := FormatString ('foo'#0'bar', 'a'#0'c', 42, i : 4, Pi : 10 : 5, r : 14, False);
  if Res = Expected then
    WriteLn ('OK')
  else
    begin
      WriteLn ('failed:');
      WriteLn (Res);
      WriteLn (Expected)
    end
end.
