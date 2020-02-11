#!/usr/local/bin/octave -q

pkg load image; %loads the required "image" package from Octave-forge

OVERLAYCONST=0.3; %controls intensity of green overlay
SE=fspecial('gaussian',[7 7],3)>0.017;
a=argv;
fn=a{1}; %MRC filename
ms=str2num(a{2}); %midsection
nw=str2num(a{3}); %number of wavelengths
px=str2num(a{4}); %pixel size
bins=[0:0.1:2]; %defines the shell sizes
if(px>0.1),bins+=0.055;end %to cope with pixel sizes >100nm, 2014-06-05pmc
rh=zeros(length(bins)-1,nw*3); % defines array to hold everything in for the final writeout.

for l=1:(length(bins)-1);for ll=1:nw; tdat{l}{ll}=[];end;end

%read in the whole image, then reshape it to ROWxCOLxZxWAV size
a=mrcread(fn);
s=size(a);
nz=s(3)/nw;
a=reshape(a,[s(1) s(2) nz nw]);

%find the mid-section: current method: local mean*std via colfilt, then sum
ad=squeeze(a(:,:,:,1));
adz=ad-ad;
for l=1:nz;
    adz(:,:,l)=colfilt(ad(:,:,l),[7 7],size(ad(:,:,1)),'sliding',inline("std(x)"));
    %adz(:,:,l)=colfilt(ad(:,:,l),[7 7],size(ad(:,:,1)),'sliding',inline("mean(x).*std(x)"));
end
for l=1:nz;
    rn(l)=median(adz(:,:,l)(:));
end
rp=polyfit(1:length(rn),rn,5);rp=polyval(rp,1:length(rn));origms=find(rp==max(rp));
%origms=find(rn==max(rn)); %to avoid polyfitting
%origms=ms; %ignoring all that and going with MEAN*STD as supplied in argv

mss=[origms-2:origms+2]; mss(find(mss<1))=[]; mss(find(mss>nz))=[];
%mss=origms; %to limit to 1 section


for ms=mss(1):mss(end),
    disp(strcat("Calculating file:",fn,"_using section:",num2str(ms)));

s=squeeze(a(:,:,ms,:));

%isolate the 1st (DAPI) wavelength
aa=s(:,:,1);

ac=conv2(aa,fspecial('gaussian',[5 5],3),'same');
ac=g2bw(ac);
ac=bwfill(ac,"holes");
[ac,nobs]=bwlabel(logical(ac));
%testname=strcat('test',num2str(ms),'.tif');
%imwrite(ac,testname);
maxacc=-1;
for li=1:nobs;
    ckacc=sum(ac(:)==li);
    if(maxacc<ckacc),maxacc=ckacc;tobj=li;
    end
end
ac=(ac==tobj);
%ac=bwmorph(ac,'dilate',5); %% extend past the actual edge somewhat
ac=dilate(ac,SE,2);
ac=bwfill(ac,"holes");
%imwrite(ac,strcat("fill",testname));
%take the Euclidean distance map of the inverse, to define the shells, and scale to pixel size
ae=bwdist(1-ac)*px;

%prepare an image to display the shells as alternating green overlays on purple DNA staining
if(ms==origms),
outimgGreen=aa-aa;
outimg=repmat(outimgGreen,[1 1 3]);
outimg(:,:,1)=nrm2d(aa);outimg(:,:,3)=outimg(:,:,1);
end

for l=1:length(bins)-1;
    f=find(ae>bins(l) & ae<=bins(l+1)); %burned here for a while using && instead of & - & is bitwise, && is logical AND
         if(ms==origms), outimgGreen(f)=OVERLAYCONST*((l/2)==floor(l/2));end %FOR OUTPUT PNG
    for ll=1:nw;
        tdat{l}{ll}=[tdat{l}{ll};nrm2d(s(:,:,ll))(f)]; 
    end
end
end

datname=strcat(fn,".alldata.mat");
save("-binary",datname,"tdat");

for l=1:length(bins)-1;
    for ll=1:nw;
        rh(l,(ll*3)-2)=bins(l+1);%+((ll/5)*bins(2));
        rh(l,(ll*3)-1)=mean(tdat{l}{ll}); %calculates mean intensity for all pixels in current shell
        rh(l,(ll*3))=std(tdat{l}{ll});    %id. for std
    end
end

outimg(:,:,2)=outimgGreen;
for l=1:3;outimg2(:,:,l)=flipud(outimg(:,:,l)');end

%write a tiff image and add the date as a tag
tiffname=strcat(fn,".shell.tif");
imwrite(outimg2,tiffname);
desctag=strcat(date,strftime("__%H:%M:%S",localtime(time)));
setstr=cstrcat('tiffset -s 270 ',desctag,' ',tiffname);
system(setstr);

fn2=strcat(fn,".NEint.csv");
csvwrite(fn2,rh);
%save("-text",fn2,"rh");
