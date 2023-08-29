uses SysUtils;
var head,buf:array [0..$5000] of byte;
n,ofst,sz,i,j,k,l:longint;
ff,fn,opt:string;
cfb,f:file of byte;
txt,txt2:text;
begin
 if ParamCount<>1 then begin
  writeln('Usage: unpack_cfb mycfbfile');
  exit;
 end;
 ff:=ParamStr(1);
 if not FileExists(ff+'.cfb') then begin
  writeln(ff+'.cfb: File not found');
  exit;
 end;
 if not DirectoryExists(ff) then MkDir(ff);
 assign(cfb,ff+'.cfb');
 reset(cfb);
 BlockRead(cfb,buf[0],4,sz);
 n:=buf[0]+buf[1]*256+buf[2]*256*256+buf[3]*256*256*256;
 BlockRead(cfb,head[0],n*$2C,sz);
 assign(txt,ff+'/list.txt');
 rewrite(txt);
 for i:=0 to n-1 do begin
  opt:='';
  j:=0;
  while (head[i*$2C+j]<>0) do begin opt:=opt+chr(head[i*$2C+j]); inc(j); end;
  writeln(txt,opt);
  if not DirectoryExists(ff+'/'+opt) then MkDir(ff+'/'+opt);
  assign(f,ff+'/'+opt+'/head.raw');
  rewrite(f);
  BlockWrite(f,head[i*$2C],$24);
  close(f);
  sz:=head[i*$2C+$24]+head[i*$2C+$25]*256+head[i*$2C+$26]*256*256+head[i*$2C+$27]*256*256*256;
  ofst:=head[i*$2C+$28]+head[i*$2C+$29]*256+head[i*$2C+$2A]*256*256+head[i*$2C+$2B]*256*256*256;
  ofst:=ofst+4+n*$2C;
  Seek(cfb,ofst);
  BlockRead(cfb,buf[0],$5000,ofst);
  k:=0;
  assign(txt2,ff+'/'+opt+'/list.txt');
  rewrite(txt2);
  for j:=0 to sz-1 do begin
   fn:='';
   while (buf[k]<>0) do begin fn:=fn+chr(buf[k]); inc(k); end;
   writeln(txt2,fn);
   inc(k);
   l:=k;
   while (buf[l]<>0) do inc(l);
   l:=l-k;
   assign(f,ff+'/'+opt+'/'+fn+'.dat');
   rewrite(f);
   BlocKWrite(f,buf[k],l);
   close(f);
   k:=k+l;
   inc(k);
  end;
  close(txt2);
 end;
 close(txt);
 close(cfb);
end.