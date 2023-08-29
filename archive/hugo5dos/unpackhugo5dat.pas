uses SysUtils;

var data:array [0..$40000] of byte;
buf:array [0..40000000] of byte;
f,fout:file of byte;
ofst,sz:longint;
num:longint;
i,j:longint;
fn:string;

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
	assign(f,'hugo.dat');
	reset(f);
	BlockRead(f,data[0],4);
	ofst:=data[0]+data[1]*256+data[2]*256*256+data[3]*256*256*256;
	seek(f,ofst+4);
	BlockRead(f,data[0],4);
	num:=data[0]+data[1]*256+data[2]*256*256+data[3]*256*256*256;
	BlockRead(f,data[0],num*$48);
	for i:=0 to num-1 do begin
		j:=i*$48;
		fn:='';
		ofst:=data[j+$40]+data[j+$41]*256+data[j+$42]*256*256+data[j+$43]*256*256*256;
		sz:=data[j+$44]+data[j+$45]*256+data[j+$46]*256*256+data[j+$47]*256*256*256;
		while (data[j]<>0) and (j-i*$48<$40) do begin
			fn:=fn+chr(data[j]);
			inc(j);
		end;
		writeln(fn);
		seek(f,ofst);
		BlockRead(f,buf[0],sz);
		assign(fout,superMkDir('unpack\'+fn));
		rewrite(fout);
		BlockWrite(fout,buf[0],sz);
		close(fout);
	end;
	close(f);
end.
