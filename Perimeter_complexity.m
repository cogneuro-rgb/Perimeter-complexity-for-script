% Load the image and convert to binary
img = imread('image_name.PNG');
binImg = imbinarize(img);

% Compute the perimeter
offsets1 = [[-1,1,0]', [-1,0,1]'];
offsets1 = unique(nchoosek(offsets1(:), 2), 'rows');
offsets1(offsets1(:,1)==0 & offsets1(:,2)==0, :) = [];
offsets2 = offsets1(abs(offsets1(:,1)-offsets1(:,2))==1, :);

perimeter = binImg;
for i = 1:length(offsets1)
    x_offset = offsets1(i,1);
    y_offset = offsets1(i,2);
    perimeter = perimeter | circshift(binImg, [x_offset, y_offset]);
end
perimeter = perimeter & ~binImg;

% Thicken the perimeter
thickPerimeter = perimeter;
for i = 1:length(offsets2)
    x_offset = offsets2(i,1);
    y_offset = offsets2(i,2);
    thickPerimeter = thickPerimeter | circshift(perimeter, [x_offset, y_offset]);
end

% Compute the perimetric complexity
inkArea = sum(binImg(:));
perimeterLength = sum(thickPerimeter(:))/3;
PC = (perimeterLength^2) / (inkArea * 4 * pi);

% Display the results
figure;
imshowpair(perimeter, thickPerimeter, 'montage');
title('Perimeter (left) and Thickened Perimeter (right)');
disp(['Perimeter Length: ', num2str(perimeterLength)]);
disp(['Ink Area: ', num2str(inkArea)]);
disp(['Perimetric Complexity: ', num2str(PC)]);