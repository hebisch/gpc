Program Params;

Uses GPC;

Var
  s: TString;

begin
  if ParamCount = 1 then
    begin
      s:= ParamStr ( 0 );
      if (copy ( s, Length ( s ) - 4, 5 ) = 'a.out')
         or (LoCaseStr (copy ( s, Length ( s ) - 4, 5 )) = 'a.exe')
         or (s[Length ( s )] = 'a') then
        writeln ( 'OK' )
      else
        writeln ( 'failed: ', ParamStr ( 0 ) );
    end { if }
  else
    writeln ( 'failed: ', ParamCount, ' parameters' );
end.
