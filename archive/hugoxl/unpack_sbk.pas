uses SysUtils;
var head,cfb:array [0..$2000] of byte;
buf:array [0..$FFFFF] of byte;
f,f2:file of byte;
rz,n,i,j,ofst,sz,freq,chan,k,tm:longint;
fn,ff:string;
b:byte;
st:boolean;
txt:text;

function mymkdir(fld:string):string;
var tmp:string;
ii:longint;
begin
 tmp:=ff+'/';
 if not DirectoryExists(ff) then mkdir(ff);
 for ii:=1 to length(fld) do begin
  if fld[ii]<>'\' then tmp:=tmp+fld[ii] else begin
   if not DirectoryExists(tmp) then mkdir(tmp);
   tmp:=tmp+'/';
  end;
 end;
 mymkdir:=tmp;
end;

begin
 write('File name: ');
 readln(ff);
 if not FileExists(ff+'.sbk') then begin
  writeln(ff+'.sbk: File not found');
  exit;
 end;
 assign(f,ff+'.sbk');
 reset(f);
 BlockRead(f,buf[0],8,rz);
 n:=buf[4]+buf[5]*256+buf[6]*256*256+buf[7]*256*256*256;
 BlockRead(f,head[0],n*$48,rz);
 assign(txt,ff+'.txt');
 rewrite(txt);
 for i:=0 to n-1 do begin
  //for j:=0 to $3f do if head[i*$48+j]<>0 then head[i*$48+j]:=head[i*$48+j] xor ($df-i);
  j:=0;
  fn:='';
  while head[i*$48+j]<>0 do begin fn:=fn+chr(head[i*$48+j]); inc(j); end;
  ofst:=head[i*$48+$40]+head[i*$48+$41]*256+head[i*$48+$42]*256*256+head[i*$48+$43]*256*256*256;
  sz:=head[i*$48+$44]+head[i*$48+$45]*256+head[i*$48+$46]*256*256+head[i*$48+$47]*256*256*256;
  writeln(txt,fn);
  if not FileExists(ff+'.cfb') then begin
   freq:=22050;
   chan:=1;
   writeln('Warning: '+ff+'.cfb not found: set freq=22050, channel=1');
  end else begin
   freq:=22050;
   chan:=1;
   assign(f2,ff+'.cfb');
   reset(f2);
   BlockRead(f2,cfb[0],$2000,rz);
   close(f2);
   st:=true;
   j:=0;
   while st do begin
    while (fn[1]<>chr(cfb[j])) and (j<rz) do inc(j);
    st:=false;
    if j=rz then writeln('Warning: Option in '+ff+'.cfb not found: set freq=22050, channel=1') else
    begin
     for k:=1 to length(fn) do if (fn[k]<>chr(cfb[j+k-1])) then st:=true;
     if not st then begin
      j:=j+length(fn)+1+5;
      freq:=0;
      while cfb[j]<>0 do begin freq:=freq*10+cfb[j]-$30; inc(j); end;
      j:=j+8;
      chan:=cfb[j]-$30;
     end else j:=j+1;
    end;
   end;
  end;
  fn:=mymkdir(fn);
  for j:=0 to $2f do buf[j]:=0;
  buf[0]:=ord('V');
  buf[1]:=ord('A');
  buf[2]:=ord('G');
  buf[3]:=ord('p');
  buf[7]:=6;
  tm:=sz;
  for j:=15 downto 12 do begin
   buf[j]:=tm mod 256;
   tm:=tm div 256;
  end;
  tm:=freq;
  for j:=19 downto 16 do begin
   buf[j]:=tm mod 256;
   tm:=tm div 256;
  end;
  buf[30]:=chan;
  BlockRead(f,buf[$30],sz,rz);
  assign(f2,fn);
  rewrite(f2);
  BlockWrite(f2,buf[0],sz+$30);
  close(f2);
 end;
 close(txt);
 close(f);
end.
