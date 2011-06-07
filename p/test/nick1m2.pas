module nick1m2 interface;
export nick1m2 = all;
import nick1m1;

procedure sSet (str_arg : mystr);
function sGet : mystr;
procedure iSet (int_arg : integer);
function iGet : integer;

end.

module nick1m2 implementation;
{ Removed, Frank 20030607, because duplication (cf. interface) not
  allowed according to EP. See nick1m3.pas.
import nick1m1; }

procedure sSet (str_arg : mystr);
begin
   writeln ('nick1m2 sset str_arg:',str_arg,'.');
   my_str_var := str_arg;
   writeln ('nick1m2 sset my_str_var:',my_str_var,'.');
end;

procedure iSet (int_arg : integer);
begin
   writeln ('nick1m2 sset int_arg:',int_arg,'.');
   my_int_var := int_arg;
   writeln ('nick1m2 sset my_int_var:',my_int_var,'.');
end;

function sGet : mystr;
begin
   sGet := my_str_var;
end;

function iGet : integer;
begin
   iGet := my_int_var;
end;

end.
