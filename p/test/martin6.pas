Program martin6;

uses   GPC,
{       cstrings,}
        martin6u;

procedure make_standard_error(progname:TString);
var
     retval1:Integer;
     statrec:StatRecord;
begin
  retval1:=sys_stat(Cstr(progname+'.err'),statrec);
end;

begin
  Writeln('OK');
  make_standard_error('ml');
end.
