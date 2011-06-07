{ BUG: module implementations see only the exported identifiers
       from the interfaces }

Program UseBug ( Output );

import
  mod12m;

var
  Tmp: array [0 .. 10] of Char;

begin
  writeln ( CString2String ( StrPCopy ( Tmp, 'O' ) ) );
end.
