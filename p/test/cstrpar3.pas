Program CStrPar3;

type
  TString = String (42);

function NewCString (const S : String): CString; external name '_p_NewCString';

function Get_TempFileName = Result : TString;
begin
  Result := 'OK'
end;

function Get_TempFileName_CString : CString;
begin
  Get_TempFileName_CString := NewCString (Get_TempFileName)
end;

{$x+}

begin
  writeln (Get_TempFileName_CString)
end.
