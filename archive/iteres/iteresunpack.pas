uses SysUtils;

var fn,di,iteres,fname:string;
strt,nmb,tmp,i,j,sizefl,offs,nmbfl:longint;
head,buf:array [0..500000000] of byte;
fin,fout:file of byte;

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

begin
	if ParamCount<>1 then begin
		writeln('Usage:iteresunpack file.res');
		exit;
	end;
	fn:=ParamStr(1);
	if not FileExists(fn) then begin
		writeln(fn+': File not found');
		exit;
	end;
	di:=fn;
	delete(di,length(di)-3,4);
	assign(fin,fn);
	reset(fin);
	BlockRead(fin,head[0],$12);
	iteres:='';
	for i:=0 to 5 do iteres:=iteres+chr(head[i]);
	if iteres<>'ITERES' then begin
		close(fin);
		writeln(fn+' is not ITERES archive');
		exit;
	end;
	if not DirectoryExists(di) then MkDir(di);
	strt:=head[6]+head[7]*256+head[8]*256*256+head[9]*256*256*256;
	tmp:=head[10]+head[11]*256+head[12]*256*256+head[13]*256*256*256;
	nmb:=head[14]+head[15]*256+head[16]*256*256+head[17]*256*256*256;
	strt:=strt*tmp;
	seek(fin,0);
	BlockRead(fin,head[0],strt);
	i:=$12;
	tmp:=0;
	for j:=0 to nmb-1 do begin
		sizefl:=head[i]+head[i+1]*256+head[i+2]*256*256+head[i+3]*256*256*256;
		i:=i+4;
		offs:=head[i]+head[i+1]*256+head[i+2]*256*256+head[i+3]*256*256*256;
		i:=i+4;
		nmbfl:=head[i]+head[i+1]*256+head[i+2]*256*256+head[i+3]*256*256*256;
		i:=i+4;
		fname:='';
		while head[i]<>0 do begin
			fname:=fname+chr(head[i]);
			inc(i);
		end;
		inc(i);
		write(fname+'...');
		fname:=SuperMkDir(di+'\'+fname);
		seek(fin,strt+offs);
		BlockRead(fin,buf[0],sizefl);
		assign(fout,fname);
		rewrite(fout);
		BlockWrite(fout,buf[0],sizefl);
		close(fout);
		writeln('OK');
	end;
	close(fin);
end.
