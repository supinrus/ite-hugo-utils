uses SysUtils;
var cgfhead:array [0..27] of byte;
cgfdata:array [0..$400000] of byte;
buf,image:array [0..700000000] of byte;
num,szdata,maxsz,numpal:longint;
sz:longint;
headbmp:array [0..53] of byte;
xpos,ypos,w,h,offset:longint;
pal:array [0..1023] of byte;
fn,dir,pln:string;
f,bmpf:file of byte;
nmb:longint;
i,j,k:longint;

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
palcgf,palhead:array [0..27] of byte;
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
			end else writeln('(Palette Loader)',palfn,': unknown format');
		end else writeln('(Palette Loader)',palfn,': unknown format');
	end else writeln('(Palette Loader)',palfn,': File not found');
	PalLoaded:=st;
end;

begin
	if ParamCount=0 then begin
		writeln('Usage: cgf2bmp pictures.cgf [palette.{pal;cgf;lzp;til}]');
		exit;
	end;
	fn:=superChange(ParamStr(1));
	if not FileExists(fn) then begin
		writeln(fn,': File not exists');
		exit;
	end;
	assign(f,fn);
	reset(f);
	BlockRead(f,cgfhead[0],28);
	if (chr(cgfhead[0])<>'C') or (chr(cgfhead[1])<>'G') or (chr(cgfhead[2])<>'F') or (chr(cgfhead[3])<>'F') then begin
		close(f);
		writeln(fn,' is not CGF file');
		exit;
	end;
	num:=cgfhead[8]+cgfhead[9]*256+cgfhead[10]*256*256+cgfhead[11]*256*256*256;
	szdata:=cgfhead[12]+cgfhead[13]*256+cgfhead[14]*256*256+cgfhead[15]*256*256*256;
	maxsz:=cgfhead[16]+cgfhead[17]*256+cgfhead[18]*256*256+cgfhead[19]*256*256*256;
	numpal:=cgfhead[20]+cgfhead[21]*256+cgfhead[22]*256*256+cgfhead[23]*256*256*256;
	BlockRead(f,cgfdata[0],szdata);
	if (numpal=0) or (ParamCount>=2) then begin
		if ParamCount>=2 then begin
			pln:=superChange(ParamStr(2));
			if not PalLoaded(pln) then begin
				close(f);
				exit;
			end;
		end else begin
			close(f);
			writeln(fn,': palette not found');
			exit;
		end;
	end else begin
		seek(f,$1C+szdata+maxsz);
		BlockRead(f,pal[0],numpal*4);
	end;
	dir:=fn;
	delete(dir,length(fn)-3,4);
	if not DirectoryExists(dir) then MkDir(dir);
	for i:=0 to num-1 do begin
		xpos:=cgfdata[i*24]+cgfdata[i*24+1]*256+cgfdata[i*24+2]*256*256+cgfdata[i*24+3]*256*256*256;
		ypos:=cgfdata[i*24+4]+cgfdata[i*24+5]*256+cgfdata[i*24+6]*256*256+cgfdata[i*24+7]*256*256*256;
		w:=cgfdata[i*24+8]+cgfdata[i*24+9]*256+cgfdata[i*24+10]*256*256+cgfdata[i*24+11]*256*256*256;
		h:=cgfdata[i*24+12]+cgfdata[i*24+13]*256+cgfdata[i*24+14]*256*256+cgfdata[i*24+15]*256*256*256;
		offset:=cgfdata[i*24+20]+cgfdata[i*24+21]*256+cgfdata[i*24+22]*256*256+cgfdata[i*24+23]*256*256*256;
		seek(f,$1C+szdata+offset);
		k:=0;
		if (w<0) or (h<0) then begin
			w:=0;
			h:=0;
		end;
		while k<w*h do begin
			BlockRead(f,buf[0],4);
			sz:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
			sz:=sz-4;
			BlockRead(f,buf[0],sz);
			j:=0;
			while j<sz do begin
				if buf[j]=0 then begin
					inc(j);
					nmb:=buf[j];
					inc(j);
					if (nmb=0) and (sz=2) then nmb:=1;
					while (nmb<>0) do begin
						image[k*2]:=0;
						image[k*2+1]:=0;
						inc(k);
						dec(nmb);
					end;
				end else if (buf[j]=1) then begin
					inc(j);
					nmb:=buf[j];
					inc(j);
					while (nmb<>0) do begin
						image[k*2]:=buf[j];
						image[k*2+1]:=buf[j+1];
						inc(k);
						j:=j+2;
						dec(nmb);
					end;
				end else if (buf[j]=2) then begin
					inc(j);
					nmb:=buf[j];
					inc(j);
					while (nmb<>0) do begin
						image[k*2]:=buf[j];
						image[k*2+1]:=buf[j+1];
						inc(k);
						dec(nmb);
					end;
					j:=j+2;
				end else if (buf[j]=3) then begin
					inc(j);
					nmb:=buf[j];
					inc(j);
					while (nmb<>0) do begin
						image[k*2]:=buf[j];
						image[k*2+1]:=255;
						inc(k);
						inc(j);
						dec(nmb);
					end;
				end else if (buf[j]=4) then begin
					inc(j);
					nmb:=buf[j];
					inc(j);
					while (nmb<>0) do begin
						image[k*2]:=buf[j];
						image[k*2+1]:=255;
						inc(k);
						dec(nmb);
					end;
					inc(j);
				end;
			end;
			while(k mod w<>0) do begin
				image[k*2]:=0;
				image[k*2+1]:=0;
				inc(k);
			end;
		end;
		mkheadbmp(w,h);
		for j:=0 to h-1 do
			for k:=0 to w-1 do begin
				buf[(h-1-j)*w*4+k*4]:=pal[image[j*w*2+k*2]*4];
				buf[(h-1-j)*w*4+k*4+1]:=pal[image[j*w*2+k*2]*4+1];
				buf[(h-1-j)*w*4+k*4+2]:=pal[image[j*w*2+k*2]*4+2];
				buf[(h-1-j)*w*4+k*4+3]:=image[j*w*2+k*2+1];
			end;
		if (w<>0) and (h<>0) then begin
			assign(bmpf,dir+'/'+Makename(i));
			rewrite(bmpf);
			BlockWrite(bmpf,headbmp[0],54);
			BlockWrite(bmpf,buf[0],w*h*4);
			close(bmpf);
		end;
	end;
	close(f);
end.
