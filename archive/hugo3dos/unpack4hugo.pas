uses SysUtils;
var buf:array [0..$8000] of byte;
buf2:array [0..8000000] of byte;
f,f2:file of byte;
ofst,sz,i,j,k,mx,numbig:longint;
fname,nw:string;
begin
  assign(f,'4hugo.dat');
  reset(f);
  ofst:=FileSize(f)-$8000;
  seek(f,ofst);
  BlockRead(f,buf[0],$8000);
  i:=0;
  mx:=0;
  numbig:=0;
  if not DirectoryExists('unpacked') then MkDir('unpacked');
  while (buf[i*40]<>0) do begin
    j:=0;
    fname:='';
    while ((buf[i*40+j]<>0) and (j<32)) do begin
      fname:=fname+chr(buf[i*40+j]);
      inc(j);
    end;
    ofst:=buf[i*40+32]+buf[i*40+33]*256+buf[i*40+34]*256*256+buf[i*40+35]*256*256*256;
    sz:=buf[i*40+36]+buf[i*40+37]*256+buf[i*40+38]*256*256+buf[i*40+39]*256*256*256;
    writeln(fname,' ',ofst,' ',sz);
    if sz>mx then mx:=sz;
    if fname='.\bigfile.bin' then begin
     fname:=fname+inttostr(numbig);
     inc(numbig);
    end;
    inc(i);
    seek(f,ofst);
    BlockRead(f,buf2[0],sz);
    nw:='unpacked/';
    for k:=1 to length(fname) do begin
      if (fname[k]='\') then begin
        if not DirectoryExists(nw) then MkDir(nw);
        nw:=nw+'/';
      end else nw:=nw+fname[k];
    end;
    writeln(nw);
    assign(f2,nw);
    rewrite(f2);
    BlockWrite(f2,buf2[0],sz);
    close(f2);
  end;
  writeln(mx);
  writeln(numbig);
  close(f);
end.