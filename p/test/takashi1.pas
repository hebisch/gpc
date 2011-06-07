program exercise28(input, output);
const smax  = 8;
      smax2 = 9;
      n     = 10;
type str    = packed array[1..smax] of char;
     str2   = packed array[1..smax2] of char;
var i, j: integer;
    s: array[1..n] of str; tmp: str;
    s2: array[1..n] of str2;
begin
{ the following part uses the 8 chars packed array}

   s[1]:='abababab';
   s[2]:='babababa';
   s[3]:='12121212';
   s[4]:='21212121';
   s[5]:='cdcdcdcd';
   s[6]:='dcdcdcdc';
   s[7]:='56565656';
   s[8]:='65656565';
   s[9]:='bcbcbcbc';
   s[10]:='cbcbcbcb';

   for i := 1 to n - 1 do
                for j := n - 1 downto i do
                        if s[j] > s[j + 1] then
                        begin
                                tmp := s[j];
                                s[j] := s[j + 1];
                                s[j + 1] := tmp
                        end;
        for i := 1 to n do
           writeln('s[', i:2, '] = ', s[i]);

{ the following part uses the 9 chars packed array}

   s2[1]:='abababab';
   s2[2]:='babababa';
   s2[3]:='12121212';
   s2[4]:='21212121';
   s2[5]:='cdcdcdcd';
   s2[6]:='dcdcdcdc';
   s2[7]:='56565656';
   s2[8]:='65656565';
   s2[9]:='bcbcbcbc';
   s2[10]:='cbcbcbcb';

   for i := 1 to n - 1 do
                for j := n - 1 downto i do
                        if s2[j] > s2[j + 1] then
                        begin
                                tmp := s2[j];
                                s2[j] := s2[j + 1];
                                s2[j + 1] := tmp
                        end;
        for i := 1 to n do
                writeln('s2[', i:2, '] = ', s2[i])
end.
