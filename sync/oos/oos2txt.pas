uses SysUtils;

var buf:array [0..1000000] of byte;
l,fn:string;
i,num,nfr,sz:longint;
txt:text;
f:file of byte;

begin
	if paramcount<>1 then begin
		writeln('Usage: oos2txt sync.oos');
		exit;
	end;
	fn:=paramstr(1);
	assign(f,fn);
	reset(f);
	BlockRead(f,buf[0],1000000,sz);
	close(f);
	l:='';
	for i:=0 to 8 do l:=l+chr(buf[i]);
	if l<>'SYNC2000H' then begin
		writeln(fn+' is not oos file');
		exit;
	end;
	i:=buf[$14]+buf[$15]*256+buf[$16]*256*256+buf[$17]*256*256*256;
	num:=buf[i]+buf[i+1]*256+buf[i+2]*256*256+buf[i+3]*256*256*256;
	i:=buf[$18]+buf[$19]*256+buf[$1A]*256*256+buf[$1B]*256*256*256;
	delete(fn,length(fn)-3,4);
	fn:=fn+'.txt';
	assign(txt,fn);
	rewrite(txt);
	while num>0 do begin
		writeln(txt,buf[i]);
		inc(i);
		dec(num);
	end;
	close(txt);
end.
