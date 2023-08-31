uses SysUtils;
var lzphead:array [0..31] of byte;
lzpofs:array [0..$400000] of byte;
buf,image:array [0..700000000] of byte;
zbuf:array [0..$FFF] of byte;
pal:array [0..767] of byte;
headbmp:array [0..53] of byte;
fn,dir:string;
f,bmpf:file of byte;
sz,w,h,num,fps,offset:longint;
i,j,k,l:longint;
bt,b1,b2,rz:longint;

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
	headbmp[28]:=$18;
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

procedure PalLoaded(palfn:string);
var
palf:file of byte;
sect:array [0..3] of byte;
palcgf,palhead:array [0..27] of byte;
ii,sz1,sz2:longint;
txtpal:text;
headd:string;
begin
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
					//if (pal[ii*3]=0) and (pal[ii*3+1]=0) and (pal[ii*3+2]=0) then begin
						pal[ii*3]:=sect[0];
						pal[ii*3+1]:=sect[1];
						pal[ii*3+2]:=sect[2];
					//end;
				end;
				close(palf);
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
						for ii:=0 to sz1-1 do begin
							BlockRead(palf,sect[0],4);
							//if (pal[ii*3]=0) and (pal[ii*3+1]=0) and (pal[ii*3+2]=0) then begin
								pal[ii*3]:=sect[2];
								pal[ii*3+1]:=sect[1];
								pal[ii*3+2]:=sect[0];
							//end;
						end;
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
						readln(txtpal,sect[0],sect[1],sect[2]);
						//if (pal[ii*3]=0) and (pal[ii*3+1]=0) and (pal[ii*3+2]=0) then begin
							pal[ii*3]:=sect[0];
							pal[ii*3+1]:=sect[1];
							pal[ii*3+2]:=sect[2];
						//end;
					end;
					close(txtpal);
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
						//if (pal[ii*3]=0) and (pal[ii*3+1]=0) and (pal[ii*3+2]=0) then begin
							pal[ii*3]:=sect[0];
							pal[ii*3+1]:=sect[1];
							pal[ii*3+2]:=sect[2];
						//end;
					end;
					close(palf);
				end else writeln('(Palette Loader)',palfn,': is not PAL file')
			end else writeln('(Palette Loader)',palfn,': unknown format');
		end else writeln('(Palette Loader)',palfn,': unknown format');
	end else writeln('(Palette Loader)',palfn,': File not found');
end;

begin
	if (ParamCount<>1) and (ParamCount<>2) then begin
		writeln('Usage: lzp2bmp movie.lzp [palette.{pal,lzp,cgf,til}]');
		exit;
	end; 
	fn:=superChange(ParamStr(1));
	if not FileExists(fn) then begin
		writeln(fn,': File not found');
		exit;
	end;
	dir:=fn;
	delete(dir,length(fn)-3,4);
	if not DirectoryExists(dir) then MkDir(dir);
	assign(f,fn);
	reset(f);
	BlockRead(f,lzphead[0],32);
	BlockRead(f,pal[0],768);
	if (ParamCount=2) then PalLoaded(superChange(ParamStr(2)));
	pal[0]:=0;
	pal[1]:=0;
	pal[2]:=0;
	sz:=FileSize(f);
	num:=lzphead[0]+lzphead[1]*256+lzphead[2]*256*256+lzphead[3]*256*256*256;
	w:=lzphead[4]+lzphead[5]*256+lzphead[6]*256*256+lzphead[7]*256*256*256;
	h:=lzphead[8]+lzphead[9]*256+lzphead[10]*256*256+lzphead[11]*256*256*256;
	fps:=lzphead[12]+lzphead[13]*256+lzphead[14]*256*256+lzphead[15]*256*256*256;
	if w=0 then w:=320;
	if h=0 then h:=240;
	//seek(f,sz-num*4);
	//BlockRead(f,lzpofs[0],num*4);
	mkheadbmp(w,h);
	offset:=$320;
	for i:=0 to num-1 do begin
		//offset:=lzpofs[i*4]+lzpofs[i*4+1]*256+lzpofs[i*4+2]*256*256+lzpofs[i*4+3]*256*256*256;
		//seek(f,offset);
		BlockRead(f,buf[0],4);
		sz:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
		BlockRead(f,buf[0],sz);
		j:=0; k:=0; l:=$FEE;
		while (k<w*h) do begin
			bt:=buf[j]+$FF00;
			inc(j);
			while (bt>$FF) and (j<w*h) do begin
				if (bt mod 2 <> 0) then begin
					bt:=bt div 2;
					image[k]:=buf[j];
					zbuf[l]:=buf[j];
					inc(j);inc(k);inc(l);
					l:=l and $FFF;
				end else begin
					bt:=bt div 2;
					b1:=buf[j];
					b2:=buf[j+1];
					j:=j+2;
					rz:=b2 div 16;
					b1:=b1+$100*rz;
					b2:=b2 mod 16;
					b2:=b2+3;
					while (b2<>0) do begin
						image[k]:=zbuf[b1];
						zbuf[l]:=zbuf[b1];
						inc(k);inc(l);
						dec(b2);inc(b1);
						b1:=b1 and $FFF;
						l:=l and $FFF;
					end;
				end;
			end;
		end;
		for j:=0 to h-1 do
			for k:=0 to w-1 do begin
				buf[(h-j-1)*w*3+k*3]:=pal[image[j*w+k]*3+2];
				buf[(h-j-1)*w*3+k*3+1]:=pal[image[j*w+k]*3+1];
				buf[(h-j-1)*w*3+k*3+2]:=pal[image[j*w+k]*3];
			end;
		assign(bmpf,dir+'/'+Makename(i));
		rewrite(bmpf);
		BlockWrite(bmpf,headbmp[0],54);
		BlockWrite(bmpf,buf[0],w*h*3);
		close(bmpf);
	end;
	close(f);
end.
