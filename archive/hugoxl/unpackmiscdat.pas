uses SysUtils;
var head:array [0..$2000] of byte;
buf:array [0..$FFFFF] of byte;
f:file of byte;
rz,n,i,j,ofst,sz:longint;
fn:string;
b:byte;

function mymkdir(fld:string):string;
var tmp:string;
ii:longint;
begin
 tmp:='';
 for ii:=1 to length(fld) do begin
  if fld[ii]<>'\' then tmp:=tmp+fld[ii] else begin
   if not DirectoryExists(tmp) then mkdir(tmp);
   tmp:=tmp+'/';
  end;
 end;
 mymkdir:=tmp;
end;

begin
 assign(f,'Misc.dat');
 reset(f);
 BlockRead(f,buf[0],4,rz);
 n:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
 n:=n div 2;
 n:=n and $1ff;
 BlockRead(f,head[0],n*$48,rz);
 close(f);
 for i:=0 to n-1 do begin
  for j:=0 to $3f do if head[i*$48+j]<>0 then head[i*$48+j]:=head[i*$48+j] xor ($df-i);
  j:=0;
  fn:='';
  while head[i*$48+j]<>0 do begin fn:=fn+chr(head[i*$48+j]); inc(j); end;
  ofst:=head[i*$48+$40]+head[i*$48+$41]*256+head[i*$48+$42]*256*256+head[i*$48+$43]*256*256*256;
  sz:=head[i*$48+$44]+head[i*$48+$45]*256+head[i*$48+$46]*256*256+head[i*$48+$47]*256*256*256;
  writeln(fn);
  fn:=mymkdir(fn);
  assign(f,'Misc.dat');
  reset(f);
  seek(f,ofst);
  BlockRead(f,buf[0],sz,rz);
  close(f);
  b:=$fd;
  for j:=0 to sz-1 do begin
   buf[j]:=buf[j] xor b;
   rz:=b+$f3;
   b:=rz and $ff;
  end;
  assign(f,fn);
  rewrite(f);
  BlockWrite(f,buf[0],sz);
  close(f);
 end;
end.
