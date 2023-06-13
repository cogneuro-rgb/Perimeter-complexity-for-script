% Specify the folder containing the binary images
folder = 'Path to the folder';

% Get a list of all the binary image files in the folder
files = dir(fullfile(folder, '*.PNG'));
numFiles = length(files);

% Initialize variables to store the results
fileNames = cell(numFiles, 1);
PCs = zeros(numFiles, 1);
inkAreas = zeros(numFiles, 1);
perimeterLengths = zeros(numFiles, 1);

% Loop over each binary image file in the folder
for i = 1:numFiles
    % Load the binary image
    fileName = files(i).name;
    fileNames{i} = fileName;
    binImg = imbinarize(imread(fullfile(folder, fileName)));

    % Compute the perimeter and perimetric complexity
    offsets1 = [[-1,1,0]', [-1,0,1]'];
    offsets1 = unique(nchoosek(offsets1(:), 2), 'rows');
    offsets1(offsets1(:,1)==0 & offsets1(:,2)==0, :) = [];
    offsets2 = offsets1(abs(offsets1(:,1)-offsets1(:,2))==1, :);

    perimeter = binImg;
    for j = 1:length(offsets1)
        x_offset = offsets1(j,1);
        y_offset = offsets1(j,2);
        perimeter = perimeter | circshift(binImg, [x_offset, y_offset]);
    end
    perimeter = perimeter & ~binImg;

    thickPerimeter = perimeter;
    for j = 1:length(offsets2)
        x_offset = offsets2(j,1);
        y_offset = offsets2(j,2);
        thickPerimeter = thickPerimeter | circshift(perimeter, [x_offset, y_offset]);
    end

    inkArea = sum(binImg(:));
    perimeterLength = sum(thickPerimeter(:))/3;
    PC = (perimeterLength^2) / (inkArea * 4 * pi);

    % Store the results for this binary image
    inkAreas(i) = inkArea;
    perimeterLengths(i) = perimeterLength;
    PCs(i) = PC;
end

% Save the results to a CSV file
resultsTable = table(fileNames, inkAreas, perimeterLengths, PCs);
writetable(resultsTable, 'perimeter_complexity_results.csv');