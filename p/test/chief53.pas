program delphibug;
{$delphi}                  { fails }
{$borland-pascal}     { so does this }
CONST foo = 'PK'#5#6; { this is the offending line }
begin
  Writeln ('OK');
end.
