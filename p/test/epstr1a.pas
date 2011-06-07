{$extended-pascal}
program epstr1a(Output);
import GPC;
var Dir : String(5);
    BaseName : String(4);
    Ext : String(2);
begin
  SetEnv('Fooo', 'bar');
  FSplit('foo.bar', Dir, BaseName, Ext);
  if
     IsSuffixCase('bar', 'Foobar') and
     IsPrefixCase('Foo', 'Foobar') and
     (not IsSuffix('Foo', 'Foobar')) and
     (not IsPrefix('bar', 'Foobar')) and
     (LastPosTillCase('bar', 'Foobar', 2) = 0)  and
     (PosFromCase('bar', 'Foobar', 2) = 4)  and
     (LastPosTill('bar', 'Foobarbar', 6) = 4) and
     (PosFrom('bar', 'Foobarbar', 4) = 4) and
     (LastPosCase('bar', 'Foobarbar') = 7) and
     (PosCase('bar', 'Foobarbar') = 4) and
     (LastPos('bar', 'Foobarbar') = 7) and
     (Pos('bar', 'Foobarbar') = 4) and
     (not StrEqualCase ('bar', 'Foobarbar')) and
     (DataDirectoryName('', 'Foo') <> 'bar') and
     (ConfigFileName('', 'Foo', true) <> 'bar') and
     (FSearch('Foo', 'foobar') = '') and
     (FSearchExecutable('Foo', 'foobar') = '') and
     (FindNonQuotedStr('Foo', 'bazz', 1) = 0) and
     FileNameMatch('*.*', 'Foo.bar')  and
     MultiFileNameMatch('*.*', 'Foo.bar')
     then
       writeln('OK')
end
.
  
