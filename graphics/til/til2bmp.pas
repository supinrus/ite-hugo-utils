uses SysUtils;
var til,image:array [0..5000000] of byte;
buf:array[0..700000000] of byte;
headbmp:array [0..53] of byte;
fn:string;
dir:string;
f:file of byte;
sz,kol,w,h,w1,h1,i,j,k,l,z,fps:longint;

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
i:longint;
begin
 numt:=num;
 tmp:='00000.bmp';
 lnum:=10000;
 for i:=1 to 5 do begin
  tmp[i]:=chr(ord('0')+numt div lnum);
  numt:=numt mod lnum;
  lnum:=lnum div 10;
 end;
 Makename:=tmp;
end;

begin
 if ParamCount<>1 then begin
  writeln('Usage: til2bmp movie.til');
  exit;
 end;
 fn:=superChange(ParamStr(1));//'TRACKCB.TIL';
 if not FileExists(fn) then begin
  writeln(fn+': File not found');
  exit;
 end;
 dir:=fn;
 delete(dir,length(fn)-3,4);
 if not DirectoryExists(dir) then MkDir(dir);
 assign(f,fn);
 reset(f);
 BlockRead(f,til[0],5000000,sz);
 close(f);
 kol:=til[6]+til[7]*256+2;
 fps:=til[14]+til[15]*256;
 w:=til[$15]+til[$16]*256;
 h:=til[$17]+til[$18]*256;
 w:=w*16;
 h:=h*16;
 til[$20]:=0;
 til[$21]:=0;
 til[$22]:=0;
 mkheadbmp(w,h);
 for i:=0 to kol-1 do begin
  w1:=w div 16;
  h1:=h div 16;
  for j:=0 to h1-1 do begin
   for k:=0 to w1-1 do begin
    z:=til[i*w1*h1*2+j*w1*2+k*2+$320]+til[i*w1*h1*2+j*w1*2+k*2+$321]*256;
    //writeln(z);
    for l:=0 to $F do begin
     image[w*j*16+k*16+l*w]:=til[$320+kol*w1*h1*2+l*16+z*256];
     image[w*j*16+k*16+l*w+1]:=til[$320+kol*w1*h1*2+l*16+z*256+1];
     image[w*j*16+k*16+l*w+2]:=til[$320+kol*w1*h1*2+l*16+z*256+2];
     image[w*j*16+k*16+l*w+3]:=til[$320+kol*w1*h1*2+l*16+z*256+3];
     image[w*j*16+k*16+l*w+4]:=til[$320+kol*w1*h1*2+l*16+z*256+4];
     image[w*j*16+k*16+l*w+5]:=til[$320+kol*w1*h1*2+l*16+z*256+5];
     image[w*j*16+k*16+l*w+6]:=til[$320+kol*w1*h1*2+l*16+z*256+6];
     image[w*j*16+k*16+l*w+7]:=til[$320+kol*w1*h1*2+l*16+z*256+7];
     image[w*j*16+k*16+l*w+8]:=til[$320+kol*w1*h1*2+l*16+z*256+8];
     image[w*j*16+k*16+l*w+9]:=til[$320+kol*w1*h1*2+l*16+z*256+9];
     image[w*j*16+k*16+l*w+10]:=til[$320+kol*w1*h1*2+l*16+z*256+10];
     image[w*j*16+k*16+l*w+11]:=til[$320+kol*w1*h1*2+l*16+z*256+11];
     image[w*j*16+k*16+l*w+12]:=til[$320+kol*w1*h1*2+l*16+z*256+12];
     image[w*j*16+k*16+l*w+13]:=til[$320+kol*w1*h1*2+l*16+z*256+13];
     image[w*j*16+k*16+l*w+14]:=til[$320+kol*w1*h1*2+l*16+z*256+14];
     image[w*j*16+k*16+l*w+15]:=til[$320+kol*w1*h1*2+l*16+z*256+15];
    end;
   end;
  end;
  for j:=0 to h-1 do
   for k:=0 to w-1 do begin
    buf[(h-1-j)*w*3+k*3]:=til[$20+image[j*w+k]*3+2];
    buf[(h-1-j)*w*3+k*3+1]:=til[$20+image[j*w+k]*3+1];
    buf[(h-1-j)*w*3+k*3+2]:=til[$20+image[j*w+k]*3];
   end;
  assign(f,dir+'/'+Makename(i));
  rewrite(f);
  BlockWrite(f,headbmp[0],54);
  BlockWrite(f,buf[0],w*h*3);
  close(f);
 end;
end.
