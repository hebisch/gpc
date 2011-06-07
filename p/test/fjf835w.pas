unit fjf835w;

interface

implementation

label 1;  { WRONG }

begin
  goto 1;
  WriteLn ('failed');
1:WriteLn ('OK')
end.
