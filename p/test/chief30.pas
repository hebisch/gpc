Program filebug;
Type
TMyFile = File;
pFile = ^TMyFile;
Var
p:pFile;
begin
 New(p); { this line caused a compiler error in EGCS versions of GPC}
 writeln('OK')
end.
