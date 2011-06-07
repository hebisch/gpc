module fjf967n;

export fjf967n = (t, aa);

type
  t = packed record
        i: 0 .. 19;
        q: 2 .. 3;
      case c: 0 .. 5 of
        3: (x: packed array [1 .. 200] of 0..7)
        otherwise (y: Integer)
      end;

const
  aa = t [i: 4; q: 2; case c: 3 of [x: [1, 4 .. 177: 5; 182: 4 otherwise 2]]];

end;

end.
