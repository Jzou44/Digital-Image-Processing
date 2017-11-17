function [im2, a] = autolevel_18( fname )
% AUTOLEVEL Levels background of an image.
% USAGE: [im2, a] = level( fname ) where 'fname' is a string representing
% the filename of the file containing the image, 'im2' is the levelled
% image, and 'a' is a vector of the 6 unknown coefficients.

im = imread( fname );
[rows,cols]=size(im);
M = 25; %sub block size
N = 25; %sub block size
i= 1;
j = 1;
x=[];  %selected background pixel coordinate array
y=[];  %selected background pixel coordinate array
I=[];  %selected background pixel graylevel array
while(i+M-1<=rows | j+N-1<=cols) % for each sub block
    submatrix = im(i:i+M-1,j:j+N-1);
    [submin,subminrowarray] = min(submatrix);
    [submin,submincol] = min(submin);
    subminrow = subminrowarray(submincol);
    subminrow = i + subminrow -1; % find lowest greylevel pixel's coordinate
    submincol = j + submincol -1;
    x = [x,[submincol]];
    y = [y,[subminrow]];
    I = [I,[im(subminrow,submincol)]];
    j=j+N;
    if (j+N-1>cols)
        j=1;
        i=i+M;
    end
    if (i+N-1>rows)
        break;
    end
end 

%show selected pixel in im
imshow(im)
hold on
plot(x, y, 'y+')

x=x';
y=y';
I=I';
I=double(I);

% Fit data at selected points to background function
%  Solve least-squares problem: [C]{a} = {k} using the
%    \ operator, i.e., {a} = [C]\{k}
%  First, compute elements of the matrix [C]
N = length(x);
Sx = sum(x);
Sy = sum(y);
Sxx = sum(x.*x);
Syy = sum(y.*y);
Sxy = sum(x.*y);
Sxxx = sum(x.^3);
Sxxy = sum(x.*x.*y);
Sxyy = sum(x.*y.*y);
Syyy = sum(y.^3);
Sxxxx = sum(x.^4);
Sxxxy = sum(y.*x.^3);
Sxxyy = sum(x.*x.*y.*y);
Sxyyy = sum(x.*y.^3);
Syyyy = sum(y.^4);
C = [N    Sx  Sy   Sxx   Syy   Sxy;
    Sx   Sxx Sxy  Sxxx  Sxyy  Sxxy;
    Sy   Sxy Syy  Sxxy  Syyy  Sxyy;
    Sxx Sxxx Sxxy Sxxxx Sxxyy Sxxxy;
    Syy Sxyy Syyy Sxxyy Syyyy Sxyyy;
    Sxy Sxxy Sxyy Sxxxy Sxyyy Sxxyy];
% Construct {k} 
SI = sum(I);
SxI = sum(x.*I);
SyI = sum(y.*I);
SxxI = sum(x.*x.*I);
SyyI = sum(y.*y.*I);
SxyI = sum(x.*y.*I);
k = [SI SxI SyI SxxI SyyI SxyI]';
% Solve
a = C\k;

% Remove background
% First compute background image
[rows, cols] = size(im);
[x, y] = meshgrid( 1:cols, 1:rows );
back = a(1) + a(2)*x + a(3)*y + a(4)*x.*x + a(5)*y.*y +a(6)*x.*y;
im2 = double(im) - back;
im2 = mat2gray(im2); % Convert matrix of type double to image of type double
im2 = im2uint8(im2); % Convert to uint8 image. Although you were not asked
                     % to do this, it is useful to make output same type as
                     % input image.
