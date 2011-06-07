program fjf226d;

uses GPC;

const
  a : CString = CString (1);

begin
  CParamCount := 2;
  CParameters := PCStrings (@a);
  if false and (paramstr (0) <> 'foobar') then writeln ('failed') else writeln ('OK')
end.
