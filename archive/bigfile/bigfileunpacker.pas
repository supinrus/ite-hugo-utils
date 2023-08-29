uses SysUtils;

function superMkDir(myfn:string):string;
var tmps:string;
ii:longint;
begin
	tmps:='';
	for ii:=1 to length(myfn) do if myfn[ii]='\' then begin
		if not DirectoryExists(tmps) then MkDir(tmps);
		tmps:=tmps+'/'
	end else tmps:=tmps+myfn[ii];
	superMkDir:=tmps;
end;

var fin,fout:file of byte;
fn,di,bigfile,fname:string;
i,j,ofs,sz,num:longint;
head,buf:array [0..500000000] of byte;
begin
	if ParamCount<>1 then begin
		writeln('Usage: bigfileunpacker file.big');
		exit;
	end;
	fn:=ParamStr(1);
	if not FileExists(fn) then begin
		writeln(fn+': File not found');
		exit;
	end;
	assign(fin,fn);
	reset(fin);
	BlockRead(fin,head[0],$B);
	bigfile:='';
	for i:=0 to 6 do bigfile:=bigfile+chr(head[i]);
	if bigfile<>'BIGFILE' then begin
		close(fin);
		writeln(fn+' is not BIGFILE');
		exit;
	end;
	ofs:=head[7]+head[8]*256+head[9]*256*256+head[10]*256*256*256;
	sz:=FileSize(fin)-ofs;
	seek(fin,ofs);
	BlockRead(fin,head[0],sz);
	num:=sz div $10C;
	di:=fn;
	delete(di,length(di)-3,4);
	for i:=0 to num-1 do begin
		j:=i*$10C;
		fname:='';
		while head[j]<>0 do begin
			fname:=fname+chr(head[j]);
			inc(j);
		end;
		write(fname+'...');
		j:=i*$10C+$104;
		ofs:=head[j]+head[j+1]*256+head[j+2]*256*256+head[j+3]*256*256*256;
		sz:=head[j+4]+head[j+5]*256+head[j+6]*256*256+head[j+7]*256*256*256;
		seek(fin,ofs);
		BlockRead(fin,buf[0],sz);
		fname:=SuperMkDir(di+'\'+fname);
		assign(fout,fname);
		rewrite(fout);
		BlockWrite(fout,buf[0],sz);
		close(fout);
		writeln('OK');
	end;
	close(fin);
end.
