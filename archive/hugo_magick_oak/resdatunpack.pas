uses SysUtils;

function superMkDir(fname:string):string;
var tmp:string;
i:longint;
begin
	tmp:='';
	for i:=1 to length(fname) do begin
		if fname[i]='\' then begin
			if not DirectoryExists(tmp) then MkDir(tmp);
			tmp:=tmp+'/';
		end else tmp:=tmp+fname[i];
	end;
	superMkDir:=tmp;
end;

var buf:array [0..$FFFFFFF] of byte;
num:longint;
i:longint;
ofst:longint;
ofs,sz:longint;
fname:string;
f,f2:file of byte;
j:longint;
begin
	assign(f,'resource.dat');
	reset(f);
	BlockRead(f,buf[0],4);
	ofst:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
	seek(f,ofst+4);
	BlockRead(f,buf[0],4);
	num:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
	if not DirectoryExists('Data') then MkDir('Data');
	for i:=0 to num-1 do begin
		seek(f,ofst+8+i*$48);
		BlockRead(f,buf[0],$48);
		fname:='';
		j:=0;
		while (j<$40) and (buf[j]<>0) do begin
			fname:=fname+chr(buf[j]);
			inc(j);
		end;
		ofs:=buf[$40]+buf[$41]*256+buf[$42]*256*256+buf[$43]*256*256*256;
		sz:=buf[$44]+buf[$45]*256+buf[$46]*256*256+buf[$47]*256*256*256;
		fname:=superMkDir('Data/'+fname);
		write(fname+'...');
		seek(f,ofs);
		BlockRead(f,buf[0],sz);
		assign(f2,fname);
		rewrite(f2);
		BlockWrite(f2,buf[0],sz);
		close(f2);
		writeln('OK');
	end;
	close(f);
end.
