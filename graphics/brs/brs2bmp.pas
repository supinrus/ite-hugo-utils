uses SysUtils;

var pal:array [0..1023] of byte;
buf,image:array [0..5000000] of byte;
fn,dir:string;
sz:longint;
f,bmpf:file of byte;
ofs,num,nofs:longint;
i,j,k,n:longint;
w,h,xpos,ypos:longint;
headbmp:array [0..53] of byte;

function superChange(myfn:string):string;
var tmps:string;
ii:longint;
begin
	tmps:='';
	for ii:=1 to length(myfn) do if myfn[ii]='\' then begin
		//if not DirectoryExists(tmps) then MkDir(tmps);
		tmps:=tmps+'/'
	end else tmps:=tmps+myfn[ii];
	superChange:=tmps;
end;

procedure mkheadbmp(w,h:longint);
var t:longint;
ii:longint;
begin
	for ii:=0 to 53 do headbmp[ii]:=0;
	headbmp[0]:=ord('B');
	headbmp[1]:=ord('M');
	t:=w*h*4+54;
	for ii:=2 to 5 do begin
		headbmp[ii]:=t mod 256;
		t:=t div 256;
	end;
	headbmp[10]:=$36;
	headbmp[14]:=$28;
	t:=w;
	for ii:=18 to 21 do begin
		headbmp[ii]:=t mod 256;
		t:=t div 256;
	end;
	t:=h;
	for ii:=22 to 25 do begin
		headbmp[ii]:=t mod 256;
		t:=t div 256;
	end;
	headbmp[26]:=1;
	headbmp[28]:=$20;
	t:=w*h*4;
	for ii:=34 to 37 do begin
		headbmp[ii]:=t mod 256;
		t:=t div 256;
	end;
end;

function Makename(num:longint):string;
var tmp:string;
numt:longint;
lnum:longint;
ii:longint;
begin
	numt:=num;
	tmp:='00000.bmp';
	lnum:=10000;
	for ii:=1 to 5 do begin
		tmp[ii]:=chr(ord('0')+numt div lnum);
		numt:=numt mod lnum;
		lnum:=lnum div 10;
	end;
	Makename:=tmp;
end;

function PalLoaded(palfn:string):boolean;
var st:boolean;
palf:file of byte;
sect:array [0..2] of byte;
palcgf,palhead:array [0..31] of byte;
ii,sz1,sz2:longint;
txtpal:text;
headd:string;
begin
	st:=false;
	if FileExists(palfn) then begin
		if (palfn[length(palfn)-3]='.') then begin
			if (((palfn[length(palfn)-2]='t') or (palfn[length(palfn)-2]='T'))
			 and ((palfn[length(palfn)-1]='i') or (palfn[length(palfn)-1]='I'))
			 and ((palfn[length(palfn)]='l') or (palfn[length(palfn)]='L'))) or
			 (((palfn[length(palfn)-2]='l') or (palfn[length(palfn)-2]='L'))
			 and ((palfn[length(palfn)-1]='z') or (palfn[length(palfn)-1]='Z'))
			 and ((palfn[length(palfn)]='p') or (palfn[length(palfn)]='P'))) then begin
				assign(palf,palfn);
				reset(palf);
				seek(palf,$20);
				for ii:=0 to 255 do begin
					BlockRead(palf,sect[0],3);
					pal[ii*4]:=sect[2];
					pal[ii*4+1]:=sect[1];
					pal[ii*4+2]:=sect[0];
				end;
				close(palf);
				st:=true;
			end else if ((palfn[length(palfn)-2]='c') or (palfn[length(palfn)-2]='C'))
			 and ((palfn[length(palfn)-1]='g') or (palfn[length(palfn)-1]='G'))
			 and ((palfn[length(palfn)]='f') or (palfn[length(palfn)]='F')) then begin
				assign(palf,palfn);
				reset(palf);
				BlockRead(palf,palcgf[0],28);
				if (chr(palcgf[0])='C') and (chr(palcgf[1])='G') and (chr(palcgf[2])='F') and (chr(palcgf[3])='F') then begin
					sz1:=palcgf[20]+palcgf[21]*256+palcgf[22]*256*256+palcgf[23]*256*256*256;
					if sz1<>0 then begin
						sz1:=palcgf[12]+palcgf[13]*256+palcgf[14]*256*256+palcgf[15]*256*256*256;
						sz2:=palcgf[16]+palcgf[17]*256+palcgf[18]*256*256+palcgf[19]*256*256*256;
						seek(palf,$1C+sz1+sz2);
						sz1:=palcgf[20]+palcgf[21]*256+palcgf[22]*256*256+palcgf[23]*256*256*256;
						BlockRead(palf,pal[0],sz1*4);
						st:=true;
					end else writeln('(Palette Loader)',palfn,': palette not found');
				end else writeln('(Palette Loader)',palfn,' is not CGF file');
				close(palf);
			end else if ((palfn[length(palfn)-2]='p') or (palfn[length(palfn)-2]='P'))
			 and ((palfn[length(palfn)-1]='a') or (palfn[length(palfn)-1]='A'))
			 and ((palfn[length(palfn)]='l') or (palfn[length(palfn)]='L')) then begin
				assign(palf,palfn);
				reset(palf);
				BlockRead(palf,palhead[0],28);
				close(palf);
				if (chr(palhead[0])='P') and (chr(palhead[1])='A') and (chr(palhead[2])='L') then begin
					assign(txtpal,palfn);
					reset(txtpal);
					readln(txtpal,headd);
					readln(txtpal,sz1);
					for ii:=0 to sz1-1 do begin
						readln(txtpal,pal[ii*4+2],pal[ii*4+1],pal[ii*4]);
					end;
					close(txtpal);
					st:=true;
				end else if (chr(palhead[0])='C') and (chr(palhead[1])='P') and (chr(palhead[2])='A') and (chr(palhead[3])='L') then begin
					sz1:=(palhead[4]-ord('0'))*100+(palhead[5]-ord('0'))*10+palhead[6]-ord('0');
					if sz1=768 then sz1:=256;
					if (chr(palhead[7])='S') then sz2:=10 else
					if (chr(palhead[7])='X') then begin
						if (chr(palhead[9])='S') then sz2:=12 else
						if (chr(palhead[9])='A') then sz2:=14;
					end;
					assign(palf,palfn);
					reset(palf);
					seek(palf,sz2);
					for ii:=0 to sz1-1 do begin
						BlockRead(palf,sect[0],3);
						pal[ii*4]:=sect[2];
						pal[ii*4+1]:=sect[1];
						pal[ii*4+2]:=sect[0];
					end;
					close(palf);
					st:=true;
				end else writeln('(Palette Loader)',palfn,': is not PAL file')
			end else if (((palfn[length(palfn)-2]='r') or (palfn[length(palfn)-2]='R'))
			 and ((palfn[length(palfn)-1]='a') or (palfn[length(palfn)-1]='A'))
			 and ((palfn[length(palfn)]='w') or (palfn[length(palfn)]='W'))) or
			 (((palfn[length(palfn)-2]='b') or (palfn[length(palfn)-2]='B'))
			 and ((palfn[length(palfn)-1]='l') or (palfn[length(palfn)-1]='L'))
			 and ((palfn[length(palfn)]='k') or (palfn[length(palfn)]='K'))) or
			 (((palfn[length(palfn)-2]='p') or (palfn[length(palfn)-2]='P'))
			 and ((palfn[length(palfn)-1]='i') or (palfn[length(palfn)-1]='I'))
			 and ((palfn[length(palfn)]='c') or (palfn[length(palfn)]='C'))) then begin
				assign(palf,palfn);
				reset(palf);
				BlockRead(palf,palhead[0],32);
				sz1:=palhead[12]*256+palhead[13];
				for ii:=0 to sz1-1 do begin
					BlockRead(palf,sect[0],3);
					pal[ii*4]:=sect[2];
					pal[ii*4+1]:=sect[1];
					pal[ii*4+2]:=sect[0];
				end;
				close(palf);
				st:=true;
			end else writeln('(Palette Loader)',palfn,': unknown format');
		end else writeln('(Palette Loader)',palfn,': unknown format');
	end else writeln('(Palette Loader)',palfn,': File not found');
	PalLoaded:=st;
end;

begin
	if (paramcount<>2) then begin
		writeln('Usage: cbr2bmp file.cbr palette.{raw,til,cgf,pal,lzp,blk}');
		exit;
	end;
	fn:=superChange(paramstr(1));
	if not FileExists(fn) then begin
		writeln(fn+': File not found');
		exit;
	end;
	if not PalLoaded(superChange(paramstr(2))) then begin
		writeln('Error: Pallete not loaded');
		exit;
	end;
	dir:=fn;
	delete(dir,length(fn)-3,4);
	if not DirectoryExists(dir) then MkDir(dir);
	assign(f,fn);
	reset(f);
	BlockRead(f,buf[0],5000000,sz);
	close(f);
	num:=0;
	i:=0;
	while i<sz do begin
		w:=buf[i]+buf[i+1]*256+buf[i+2]*256*256+buf[i+3]*256*256*256;
		h:=buf[i+4]+buf[i+5]*256+buf[i+6]*256*256+buf[i+7]*256*256*256;
		xpos:=buf[i+8]+buf[i+9]*256+buf[i+10]*256*256+buf[i+11]*256*256*256;
		ypos:=buf[i+12]+buf[i+13]*256+buf[i+14]*256*256+buf[i+15]*256*256*256;
		i:=i+16;
		mkheadbmp(w,h);
		for j:=0 to h-1 do
			for k:=0 to w-1 do begin
				image[(h-1-j)*w*4+k*4]:=pal[buf[i+j*w+k]*4];
				image[(h-1-j)*w*4+k*4+1]:=pal[buf[i+j*w+k]*4+1];
				image[(h-1-j)*w*4+k*4+2]:=pal[buf[i+j*w+k]*4+2];
				if buf[i+j*w+k]=0 then image[(h-1-j)*w*4+k*4+3]:=0 else image[(h-1-j)*w*4+k*4+3]:=255;
			end;
		assign(bmpf,dir+'/'+Makename(num));
		rewrite(bmpf);
		BlockWrite(bmpf,headbmp[0],54);
		BlockWrite(bmpf,image[0],w*h*4);
		close(bmpf);
		inc(num);
		i:=i+w*h;
	end;
end.
