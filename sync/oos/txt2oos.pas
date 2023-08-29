uses SysUtils;

var buf:array [0..1000000] of byte;
l,fn:string;
i,num,nfr:longint;
txt:text;
f:file of byte;
begin
	if paramcount<>1 then begin
		writeln('Usage: txt2oos sync.txt');
		exit;
	end;
	fn:=paramstr(1);
	l:='SYNC2000H';
	for i:=1 to length(l) do buf[i-1]:=ord(l[i]);
	buf[9]:=1;
	buf[10]:=$32;
	buf[11]:=6;
	for i:=12 to 19 do buf[i]:=0;
	l:='File maked by txt2oos program';
	for i:=1 to length(l) do buf[$1B+i]:=ord(l[i]);
	i:=$1C+length(l);
	while i mod 4<>0 do inc(i);
	buf[$14]:=i mod 256;
	buf[$15]:=(i div 256) mod 256;
	buf[$16]:=((i div 256) div 256) mod 256;
	buf[$17]:=((i div 256) div 256) div 256;
	i:=i+4;
	buf[$18]:=i mod 256;
	buf[$19]:=(i div 256) mod 256;
	buf[$1A]:=((i div 256) div 256) mod 256;
	buf[$1B]:=((i div 256) div 256) div 256;
	if not FileExists(fn) then begin
		writeln(fn+': File not found');
		exit;
	end;
	assign(txt,fn);
	reset(txt);
	num:=0;
	while not eof(txt) do begin
		readln(txt,nfr);
		if nfr<255 then buf[i+num]:=nfr else writeln(nfr, ' should be less 256');
		inc(num);
	end;
	close(txt);
	buf[i-4]:=num mod 256;
	buf[i-3]:=(num div 256) mod 256;
	buf[i-2]:=((num div 256) div 256) mod 256;
	buf[i-1]:=((num div 256) div 256) div 256;
	delete(fn,length(fn)-3,4);
	fn:=fn+'.oos';
	i:=i+num;
	assign(f,fn);
	rewrite(f);
	BlockWrite(f,buf[0],i);
	close(f);
end.
