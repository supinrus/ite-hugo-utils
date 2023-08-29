uses SysUtils;
var buf:array [0..4000] of byte;
rz,i,j,k,kol,ww,hh,sm,l,n,m:longint;
f:file of byte;
b:byte;
image,mask:array [0..400000] of byte;
fn:string;
headbmp:array [0..53] of byte;
bmpimage:array [0..5000000] of byte;

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

procedure piclear;
var ii,jj:longint;
begin
	for ii:=0 to hh-1 do
		for jj:=0 to ww-1 do begin
			image[ii*ww+jj]:=0;
			mask[ii*ww+jj]:=0;
		end;
end;

begin
	if paramcount<>1 then begin
		writeln('Usage: decodespeach number');
		writeln('Example: decodespeach 6');
		exit;
	end;
	n:=strtoint(paramstr(1));
	fn:=getname(n);
	if not FileExists(fn) then begin
		writeln(fn,': File not found');
		exit;
	end;
	assign(f,fn);
	reset(f);
	BlockRead(f,buf[0],4000,rz);
	close(f);
	ww:=buf[$A]+buf[$B]*256;
	hh:=buf[$C]+buf[$D]*256;
	mkheadbmp(ww*8,hh);
	k:=$10;
	for l:=0 to 3 do begin
		i:=0;
		piclear;
		sm:=buf[$E]+buf[$F]*256;
		while (i<hh) do begin
			j:=0;
			while (j<ww) do begin
				b:=buf[sm];
				if b=0 then begin
					kol:=buf[sm+1];
					j:=j+kol;
					sm:=sm+2;
					while kol>0 do begin
						mask[i*ww+j-kol]:=0;
						dec(kol);
					end;
				end else begin
					b:=b xor $FF;
					if b=0 then begin
						kol:=buf[sm+1];
						sm:=sm+2;
						while kol>0 do begin
							image[i*ww+j]:=buf[k];
							mask[i*ww+j]:=$FF;
							inc(j);
							inc(k);
							dec(kol);
						end;
					end else begin
						image[i*ww+j]:=image[i*ww+j] and b;
						image[i*ww+j]:=image[i*ww+j] or buf[k];
						mask[i*ww+j]:=b xor $FF;
						inc(k);
						inc(j);
						sm:=sm+1;
					end;
				end;
			end;
			inc(i);
		end;
		writeln(k);
		for i:=0 to hh-1 do
			for j:=0 to ww-1 do
				for m:=0 to 7 do begin
					if mask[i*ww+j] and $80<>0 then begin
						if image[i*ww+j] and $80<>0 then begin
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3]:=$FF;
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3+1]:=$FF;
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3+2]:=$FF;
						end else begin
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3]:=0;
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3+1]:=0;
							bmpimage[((hh-1-i)*ww*8+j*8+m)*3+2]:=0;
						end;
					end else begin
						bmpimage[((hh-1-i)*ww*8+j*8+m)*3]:=0;
						bmpimage[((hh-1-i)*ww*8+j*8+m)*3+1]:=$FF;
						bmpimage[((hh-1-i)*ww*8+j*8+m)*3+2]:=0;
					end;
					image[i*ww+j]:=image[i*ww+j]*2;
					mask[i*ww+j]:=mask[i*ww+j]*2;
				end;
		assign(f,'SPEACH'+inttostr(n)+'-'+inttostr(l)+'.BMP');
		rewrite(f);
		BlockWrite(f,headbmp[0],54);
		BlockWrite(f,bmpimage[0],ww*hh*3*8);
		close(f);
	end;
	
end.
