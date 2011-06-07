Program AsmNames;

Var
  { This was:
    S: String ( 10 ); attribute (static); AsmName 'S';
    But I don't think this has to work. `static' for global
    declarations is a C thing, anyway, so why would someone use it
    in Pascal, in particular together with an asmname? -- Frank }
  S: String ( 10 ); attribute (name = 'S');
  OK: String ( 10 ); external name 'S';

Procedure puts ( C: CString ); external name 'puts';

begin
  S:= 'OK';
  puts ( OK );
end.
