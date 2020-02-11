function a=nrm2d(b)
    %normalizes a 2d matrix to (0..1)

m=min(b(:));
b=b-m;
m=max(b(:));
if(m!=0),
a=b./m;
else
a=b;
end

