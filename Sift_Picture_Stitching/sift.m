% [image, descriptors, locs] = sift(imageFile)
%
% This function reads an image and returns its SIFT keypoints.
%   Input parameters:
%     imageFile: the file name for the image.
%
%   Returned:
%     image: the image array in double format
%     image: double格式的图像array
%     descriptors: a K-by-128 matrix, where each row gives an
%     invariant descriptor for one of the K keypoints.
%     The descriptor is a vector of 128 values normalized to unit length.
%     descriptors: K*128的矩阵，每一行都是一个关键点，记录了128维的sift描述子
%     locs: K-by-4 matrix, in which each row has the 4 values for a
%         keypoint location (row, column, scale, orientation).  The 
%         orientation is in the range [-PI, PI] radians.
%     locs: K*4的矩阵，记录关键点的位置，行，列，尺度，方向，方向范围是[-PI,PI]
% Credits: Thanks for initial version of this program to D. Alvaro and 
%          J.J. Guerrero, Universidad de Zaragoza (modified by D. Lowe)

function [image, descriptors, locs] = sift(imageFile)

% Load image
image = imread(imageFile);

% If you have the Image Processing Toolbox, you can uncomment the following
%   lines to allow input of color images, which will be converted to grayscale.
% if isrgb(image)
%    image = rgb2gray(image);
% end
%如果读入的图像不是灰度图像，就将其转为灰度图像


%得到图像的行数和列数
[rows, cols] = size(image); 

% Convert into PGM imagefile, readable by "keypoints" executable
%转为PGM图像
%文件头部分
%文件头包括的信息依次是:
%1.PGM文件的格式类型(是P2还是P5);
%2.图像的宽度;
%3.图像的高度;
%4.图像灰度值可能的最大值;
%数据部分
%数据部分记录图像每个像素的灰度值,按照图像从上到下,从左到右的顺序依次存储每个像素的灰度值.
%P5采用的是二进制，每个像素一个字节
f = fopen('tmp.pgm', 'w');
if f == -1
    error('Could not create file tmp.pgm.');
end
%存入PGM文件的格式类型P5
%存图图像的宽度cols，图像的高度rows，图像灰度值的上界
fprintf(f, 'P5\n%d\n%d\n255\n', cols, rows);
%存入图像本身，每一个像素都是一个无符号整形
fwrite(f, image', 'uint8');
fclose(f);

% Call keypoints executable
if isunix
    command = '!./sift ';
else
    command = '!siftWin32 ';
end
%!siftWin32 ' <tmp.pgm >tmp.key'可执行程序siftWin32.exe需要的参数
%而这句话的作用就是生成特征点写入tmp.key文件
command = [command ' <tmp.pgm >tmp.key'];
%执行命令
eval(command);

% Open tmp.key and check its header
g = fopen('tmp.key', 'r');
if g == -1
    error('Could not open file tmp.key.');
end
[header, count] = fscanf(g, '%d %d', [1 2]);
%~=不等于
if count ~= 2
    error('Invalid keypoint file beginning.');
end
%keypoint的个数
num = header(1);
%描述子，128维
len = header(2);
if len ~= 128
    error('Keypoint descriptor length invalid (should be 128).');
end

% Creates the two output matrices (use known size for efficiency)
%生成num*4的全0矩阵，关键点的信息
locs = double(zeros(num, 4));
%生成num*128的全0矩阵，关键点的描述子
descriptors = double(zeros(num, 128));

% Parse tmp.key
for i = 1:num
%关键点的信息，行，列，灰度级别，方向
    [vector, count] = fscanf(g, '%f %f %f %f', [1 4]); %row col scale ori
    if count ~= 4
        error('Invalid keypoint file format');
    end
    locs(i, :) = vector(1, :);
%descrip是行向量
    [descrip, count] = fscanf(g, '%d', [1 len]);
    if (count ~= 128)
        error('Invalid keypoint file value.');
    end
    % Normalize each input vector to unit length
%.^2是矩阵中的每个元素都求平方，^2是求矩阵的平方或两个相同的矩阵相乘
%sum(x)以矩阵x的每一列为对象，对一列内的数字求和。
%sum(x)，若x为行向量时，不指定dim或指定dim为2，则自动计算成所有行向量数值的和，
%如果指定dim为1，则计算结果为一个行向量，且与原来的行向量相同。
%归一化特征向量，为了去除光照变化的影响，需对特征向量进行归一化处理
    descrip = descrip / sqrt(sum(descrip.^2));
    descriptors(i, :) = descrip(1, :);
end
fclose(g);