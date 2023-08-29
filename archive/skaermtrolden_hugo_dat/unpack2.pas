uses SysUtils;

var a,b:array [0..$1000000] of byte;
fn:string;
sz:longint;
ns,pol,nm,db,nb:longint;
f:file of byte;
i:longint;
zn:array [0..$1B] of longint;
b1,b2:byte;
p1,p2,p3,cc:longint;
bts:array [0..$F] of byte = (6,10,10,18,1,1,1,1,2,3,3,4,4,5,7,14);


dr:file of byte;
head:array [0..3160] of byte;
num,ii,jj,ofs,kk,ofss,szz:longint;
name,ext:string;

function checkbyte:byte;
var outp:byte;
begin
	outp:=0;
	if b2=0 then begin
		b2:=a[pol-1];
		dec(pol);
		if b2 and $80<>0 then outp:=1;
		b2:=b2 shl 1;
	end else if b2=$80 then begin
		b2:=a[pol-1];
		dec(pol);
		if b2 and $80<>0 then outp:=1;
		b2:=b2 shl 1;
		b2:=b2+1;
	end else begin
		if b2 and $80<>0 then outp:=1;
		b2:=b2 shl 1;
	end;
	checkbyte:=outp;
end;

function mydecode:boolean;
var utp:boolean;
begin
	utp:=false;
	if (a[0]=$4D) and (a[1]=$47) and (a[2]=$21) and (a[3]=$32) then begin
		ns:=a[4]+a[5]*256;
		pol:=a[8]+a[9]*256;
		for i:=0 to 2 do begin
			a[i*4]:=a[pol+8-i*4];
			a[i*4+1]:=a[pol+9-i*4];
			a[i*4+2]:=a[pol+10-i*4];
			a[i*4+3]:=a[pol+11-i*4];
		end;
		pol:=pol+12;
		nm:=a[pol]+a[pol+1]*256;
		db:=a[pol+4]+a[pol+5]*256;
		if db=0 then writeln(fn+': checked 0');
		b1:=db div 256;
		b2:=db mod 256;
		//writeln(b1, ' ',b2);
		pol:=pol+6;
		for i:=0 to $D do begin
			zn[i*2]:=a[pol+i*2];
			zn[i*2+1]:=a[pol+i*2+1];
		end;
		i:=ns;
		pol:=pol-18;
		if b1=0 then pol:=pol-1;
		while i<>0 do begin
			while nm<>0 do begin
				b[i-1]:=a[pol-1];
				dec(i);
				dec(pol);
				dec(nm);
				if i=0 then nm:=0;
			end;
			if i>0 then begin
				if checkbyte=0 then begin
					p1:=2;
					p2:=0;
				end else begin
					if checkbyte=0 then begin
						p1:=3;
						p2:=1;
					end else begin
						if checkbyte=0 then begin
							p1:=4;
							p2:=2;
						end else begin
							if checkbyte=0 then begin
								p1:=5;
								p2:=3;
							end else begin
								if checkbyte=0 then begin
									p1:=checkbyte;
									p1:=p1*2;
									p1:=p1+checkbyte;
									p1:=p1*2;
									p1:=p1+checkbyte;
									p1:=p1+6;
									p2:=3;
								end else begin
									p1:=a[pol-1];
									dec(pol);
									p2:=3;
								end;
							end;
						end;
					end;
				end;
				cc:=p2;
				p3:=0;
				if checkbyte=1 then begin
					if checkbyte=0 then begin
						p3:=2;
						cc:=p2+4;
					end else begin
						p3:=bts[cc];
						cc:=p2+8;
					end;
				end;
				cc:=bts[cc+4];
				nm:=0;
				while cc<>0 do begin
					nm:=nm*2;
					nm:=nm+checkbyte;
					dec(cc);
				end;
				nm:=nm+p3;
				p3:=0;
				cc:=p2;
				if checkbyte=1 then begin
					if checkbyte=0 then begin
						p3:=zn[cc*2]+zn[cc*2+1]*256;
						cc:=cc+4;
					end else begin
						p3:=zn[cc*2+8]+zn[cc*2+9]*256;
						cc:=cc+8;
					end;
				end;
				cc:=zn[cc+16];
				nb:=0;
				while cc<>0 do begin
					nb:=nb*2;
					nb:=nb+checkbyte;
					dec(cc);
				end;
				p3:=p3+1+nb;
				//writeln(p3);
				while p1<>0 do begin
					b[i-1]:=b[i+p3-1];
					dec(p1);
					dec(i);
				end;
				//writeln(i,' ',nm);
			end;
		end;
		utp:=true;
		szz:=ns;
	end else writeln(name+'.'+ext+': file not packed');
	mydecode:=utp;
end;

begin
	assign(dr,'HUGO.DIR');
	reset(dr);
	BlockRead(dr,head[0],4);
	num:=head[2]+head[3]*256;
	BlockRead(dr,head[0],3156);
	close(dr);
	if not DirectoryExists('unpacked') then MkDir('unpacked');
	for ii:=0 to num-1 do begin
		name:='';
		jj:=ii*$C+7;
		while (head[jj]=$20) do dec(jj);
		while jj>=ii*$C do begin name:=chr(head[jj])+name; dec(jj); end;
		ofs:=head[ii*$C+8]+head[ii*$C+9]*256;
		kk:=head[ii*$C+10]+head[ii*$C+11]*256;
		for jj:=0 to kk-1 do begin
			ext:=chr(head[num*$c+ofs+jj*$C])+chr(head[num*$c+ofs+jj*$C+1])+chr(head[num*$c+ofs+jj*$C+2]);
			writeln(name+'.'+ext);
			ofss:=head[num*$c+ofs+jj*$C+3]+head[num*$c+ofs+jj*$C+4]*256+head[num*$c+ofs+jj*$C+5]*256*256;
			szz:=head[num*$c+ofs+jj*$C+6]+head[num*$c+ofs+jj*$C+7]*256;
			assign(dr,'HUGO.001');
			reset(dr);
			seek(dr,ofss);
			BlockRead(dr,a[0],szz);
			close(dr);
			if mydecode then begin
				assign(dr,'unpacked/'+name+'.'+ext);
				rewrite(dr);
				BlockWrite(dr,b[0],szz);
				close(dr);
			end else begin
				assign(dr,'unpacked/'+name+'.'+ext);
				rewrite(dr);
				BlockWrite(dr,a[0],szz);
				close(dr);
			end;
		end;
	end;
end.
