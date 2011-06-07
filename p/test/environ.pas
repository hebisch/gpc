program Environ;

uses GPC;

begin
  SetEnv ('TEST_ENV', 'OK');
  writeln (GetEnv ('TEST_ENV'));
end.
