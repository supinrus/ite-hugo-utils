uses SysUtils;

var data:array[0..$FFFF] of byte;
buf:array [0..40000000] of byte;
f,fout:file of byte;
i,j,ofst,sz:longint;
fn:string;
num:longint;

function superMkDir(myfn:string):string;
var tmp:string;
ii:longint;
begin
	tmp:='';
	for ii:=1 to length(myfn) do if myfn[ii]='\' then begin
		if not DirectoryExists(tmp) then MkDir(tmp);
		tmp:=tmp+'/'
	end else tmp:=tmp+myfn[ii];
	superMkDir:=tmp;
end;

begin
	if not FileExists('hugo.dat') then begin
		writeln('hugo.dat: File not found');
		exit;
	end;
	assign(f,'hugo.dat');
	reset(f);
	seek(f,filesize(f)-$10000);
	BlockRead(f,data[0],$10000);
	i:=0;
	num:=1;
	while i<$10000 do begin
		j:=i;
		fn:='';
		while (data[j]<>0) and (j-i<$40) do begin
			fn:=fn+chr(data[j]);
			inc(j);
		end;
		if fn<>'' then begin
			writeln(fn);
			if fn='.\bigfile.bin' then begin
				fn:='.\bigfile'+inttostr(num)+'.bin';
				inc(num);
			end;
			ofst:=data[i+$40]+data[i+$41]*256+data[i+$42]*256*256+data[i+$43]*256*256*256;
			sz:=data[i+$44]+data[i+$45]*256+data[i+$46]*256*256+data[i+$47]*256*256*256;
			seek(f,ofst);
			BlockRead(f,buf[0],sz);
			assign(fout,superMkDir('unpack\'+fn));
			rewrite(fout);
			BlockWrite(fout,buf[0],sz);
			close(fout);
		end;
		i:=i+$48;
	end;
	close(f);
end.
