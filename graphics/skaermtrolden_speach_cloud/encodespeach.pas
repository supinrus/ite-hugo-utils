uses SysUtils;

var headbmp:array [0..53] of byte;
bmpimage:array [0..5000000] of byte;
buf,blank,pic,head:array [0..4000] of byte;
image,mask:array [0..400000] of byte;
fn,bmpfn:string;
n:longint;
w,h:longint;
ofs:longint;
f:file of byte;
i,j,k,s1,s2,kol:longint;
b:byte;

function getname(num:longint):string;
var tmp:string;
nn:longint;
begin
	tmp:='SPEACH.000';
	nn:=num;
	tmp[length(tmp)]:=chr(ord('0')+nn mod 10);
	nn:=nn div 10;
	tmp[length(tmp)-1]:=chr(ord('0')+nn mod 10);
	nn:=nn div 10;
	tmp[length(tmp)-2]:=chr(ord('0')+nn mod 10);
	getname:=tmp;
end;

begin
	if paramcount<>1 then begin
		writeln('Usage: encodespeach number');
		writeln('Example: encodespeach 1');
		exit;
	end;
	if not trystrtoint(paramstr(1),n) then begin
		writeln(paramstr(1)+' is not number');
		exit;
	end; 
	fn:=getname(n);
	bmpfn:='SPEACH'+inttostr(n)+'-3.BMP';
	if not FileExists(bmpfn) then begin
		writeln(bmpfn+': File not found');
		exit;
	end;
	assign(f,bmpfn);
	reset(f);
	BlockRead(f,headbmp[0],54);
	ofs:=headbmp[10]+headbmp[11]*256+headbmp[12]*256*256+headbmp[13]*256*256*256;
	w:=headbmp[18]+headbmp[19]*256+headbmp[20]*256*256+headbmp[21]*256*256*256;
	h:=headbmp[22]+headbmp[23]*256+headbmp[24]*256*256+headbmp[25]*256*256*256;
	Seek(f,ofs);
	BlockRead(f,bmpimage[0],w*h*3);
	close(f);
	w:=w div 8;
	for i:=0 to h-1 do
		for j:=0 to w-1 do begin
			b:=$80;
			mask[i*w+j]:=0;
			image[i*w+j]:=0;
			for k:=0 to 7 do begin
				if (bmpimage[((h-1-i)*w*8+j*8+k)*3]<>0) or 
				   (bmpimage[((h-1-i)*w*8+j*8+k)*3+1]<>$FF) or 
				   (bmpimage[((h-1-i)*w*8+j*8+k)*3+2]<>0) then begin
					mask[i*w+j]:=mask[i*w+j] or b;
					if (bmpimage[((h-1-i)*w*8+j*8+k)*3]=$FF) or 
					   (bmpimage[((h-1-i)*w*8+j*8+k)*3+1]=$FF) or 
					   (bmpimage[((h-1-i)*w*8+j*8+k)*3+2]=$FF) then begin
						image[i*w+j]:=image[i*w+j] or b;
					end;
				end;
				b:=b div 2;
			end;
		end;
	i:=0;
	s1:=0;
	s2:=0;
	while (i<h) do begin
		j:=0;
		while (j<w) do begin
			kol:=0;
			while (mask[i*w+j+kol]=0) and (kol<$FF) and (j+kol<w) do inc(kol);
			if kol=0 then begin
				while (mask[i*w+j+kol]=$FF) and (kol<$FF) and (j+kol<w) do inc(kol);
				if kol=0 then begin
					buf[s1]:=mask[i*w+j];
					pic[s2]:=image[i*w+j];
					inc(s1);
					inc(s2);
					inc(j);
				end else begin
					buf[s1]:=$FF;
					buf[s1+1]:=kol;
					s1:=s1+2;
					while kol>0 do begin
						pic[s2]:=image[i*w+j];
						inc(s2);
						dec(kol);
						inc(j);
					end;
				end;
			end else begin
				buf[s1]:=0;
				buf[s1+1]:=kol;
				s1:=s1+2;
				j:=j+kol;
			end;
		end;
		inc(i);
	end;
	for i:=0 to s2-1 do blank[i]:=0;
	head[0]:=1;
	head[1]:=1;
	head[2]:=0;
	head[3]:=0;
	head[4]:=0;
	head[5]:=0;
	head[6]:=ord('t');
	head[7]:=ord('r');
	head[8]:=0;
	head[9]:=0;
	head[10]:=w mod 256;
	head[11]:=w div 256;
	head[12]:=h mod 256;
	head[13]:=h div 256;
	k:=s2*4+$10;
	head[14]:=k mod 256;
	head[15]:=k div 256;
	assign(f,fn);
	rewrite(f);
	BlockWrite(f,head,$10);
	BlockWrite(f,blank[0],s2);
	BlockWrite(f,pic[0],s2);
	BlockWrite(f,blank[0],s2);
	BlockWrite(f,pic[0],s2);
	BlockWrite(f,buf[0],s1);
	close(f);
end.
