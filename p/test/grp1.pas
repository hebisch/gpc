{$extended-pascal}
program grp1(input, output);

{Undetected import error.  Type identifer 't1' imported through grp1b
does not denote the same type as type identifier 't1' imported through
grp1a.}

import grp1a; grp1b; { WRONG }

begin
writeln('FAIL');
end.
