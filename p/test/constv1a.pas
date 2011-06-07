program constv1a;
const ss = 'foooxxxbbbbbbbbbbaaaaa';
type st = array[1..10] of char;
     ait = array[1..10] of integer;
     enu = (en1, en2);
     aet = array[1..5] of enu;
     sait(i: integer) = array[i..10] of integer;
     sait5 = sait(5);
const sa = st[1: 'f'; 2 : 'b' otherwise ' '];
      ci = ait[1..10:747];
      ce = aet[1..5: en2];
      csi = sait5[5..10: 17];
procedure p(const bar);
begin
end;

begin
  p(st[1: 'r'; 2 : 'c' otherwise 'x']);
  p(sa);
  p('Fii');
  p(ss);
  p(ait[1: 666; 2..10 : 11]);
  p(ci);
  p(aet[3: en1 otherwise en2]);
  p(ce);
  p(sait5[7: 7 otherwise 5]);
  p(csi);
  writeln('OK')
end
.
