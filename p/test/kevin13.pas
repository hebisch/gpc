{ BUG: The implementation of Kevin13FOO imports the Kevin13FOO
  interface which only contains the listed identifiers (twine, not
  String25).

  Solution: For every module interface, implicitly create another
  interface containing everything (like "export all"), and import
  that one in the implementation, instead of the GPM mechanism. }

{-----------------------------------------------------}
program KFoss( input, output );
import Kevin13F;

begin
  writeln ( twine ( 'OK' ) )
end.
