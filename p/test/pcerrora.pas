program PCErrorA;

var
chs :packed array [1..10] of char;
ch1 :array[1..10] of char;

begin
pack(ch1,2,chs);  { WRONG }
end.
