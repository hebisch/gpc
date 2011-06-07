BUG: Fails on alpha-dec-osf.

Program Foo;

const c = 1 shl (BitSizeOf (LongestInt) - 1);

var y:longint=2*c;  { WR-ONG } `-' so the failure because of the notice isn't mistaken as success

begin
  writeln ( 'failed: ', y );
end.
