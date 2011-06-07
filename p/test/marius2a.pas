program AutoMakeBug;

{ This tests a bug in the automake mechanism. When the first program
  (marius2a.pas) is compiled, it works well, but when the second program
  (marius2b.pas, identical to marius2a.pas!) is compiled, and the
  pre-compiled units are already there, it fails. -- Just in case anyone
  wonders why there are two identical files in the test suite... }

uses
  First in 'marius2u.pas';

begin
  CallFirst;
end.
