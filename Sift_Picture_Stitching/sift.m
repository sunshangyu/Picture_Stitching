% [image, descriptors, locs] = sift(imageFile)
%
% This function reads an image and returns its SIFT keypoints.
%   Input parameters:
%     imageFile: the file name for the image.
%
%   Returned:
%     image: the image array in double format
%     image: double��ʽ��ͼ��array
%     descriptors: a K-by-128 matrix, where each row gives an
%     invariant descriptor for one of the K keypoints.
%     The descriptor is a vector of 128 values normalized to unit length.
%     descriptors: K*128�ľ���ÿһ�ж���һ���ؼ��㣬��¼��128ά��sift������
%     locs: K-by-4 matrix, in which each row has the 4 values for a
%         keypoint location (row, column, scale, orientation).  The 
%         orientation is in the range [-PI, PI] radians.
%     locs: K*4�ľ��󣬼�¼�ؼ����λ�ã��У��У��߶ȣ����򣬷���Χ��[-PI,PI]
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
%��������ͼ���ǻҶ�ͼ�񣬾ͽ���תΪ�Ҷ�ͼ��


%�õ�ͼ�������������
[rows, cols] = size(image); 

% Convert into PGM imagefile, readable by "keypoints" executable
%תΪPGMͼ��
%�ļ�ͷ����
%�ļ�ͷ��������Ϣ������:
%1.PGM�ļ��ĸ�ʽ����(��P2����P5);
%2.ͼ��Ŀ��;
%3.ͼ��ĸ߶�;
%4.ͼ��Ҷ�ֵ���ܵ����ֵ;
%���ݲ���
%���ݲ��ּ�¼ͼ��ÿ�����صĻҶ�ֵ,����ͼ����ϵ���,�����ҵ�˳�����δ洢ÿ�����صĻҶ�ֵ.
%P5���õ��Ƕ����ƣ�ÿ������һ���ֽ�
f = fopen('tmp.pgm', 'w');
if f == -1
    error('Could not create file tmp.pgm.');
end
%����PGM�ļ��ĸ�ʽ����P5
%��ͼͼ��Ŀ��cols��ͼ��ĸ߶�rows��ͼ��Ҷ�ֵ���Ͻ�
fprintf(f, 'P5\n%d\n%d\n255\n', cols, rows);
%����ͼ����ÿһ�����ض���һ���޷�������
fwrite(f, image', 'uint8');
fclose(f);

% Call keypoints executable
if isunix
    command = '!./sift ';
else
    command = '!siftWin32 ';
end
%!siftWin32 ' <tmp.pgm >tmp.key'��ִ�г���siftWin32.exe��Ҫ�Ĳ���
%����仰�����þ�������������д��tmp.key�ļ�
command = [command ' <tmp.pgm >tmp.key'];
%ִ������
eval(command);

% Open tmp.key and check its header
g = fopen('tmp.key', 'r');
if g == -1
    error('Could not open file tmp.key.');
end
[header, count] = fscanf(g, '%d %d', [1 2]);
%~=������
if count ~= 2
    error('Invalid keypoint file beginning.');
end
%keypoint�ĸ���
num = header(1);
%�����ӣ�128ά
len = header(2);
if len ~= 128
    error('Keypoint descriptor length invalid (should be 128).');
end

% Creates the two output matrices (use known size for efficiency)
%����num*4��ȫ0���󣬹ؼ������Ϣ
locs = double(zeros(num, 4));
%����num*128��ȫ0���󣬹ؼ����������
descriptors = double(zeros(num, 128));

% Parse tmp.key
for i = 1:num
%�ؼ������Ϣ���У��У��Ҷȼ��𣬷���
    [vector, count] = fscanf(g, '%f %f %f %f', [1 4]); %row col scale ori
    if count ~= 4
        error('Invalid keypoint file format');
    end
    locs(i, :) = vector(1, :);
%descrip��������
    [descrip, count] = fscanf(g, '%d', [1 len]);
    if (count ~= 128)
        error('Invalid keypoint file value.');
    end
    % Normalize each input vector to unit length
%.^2�Ǿ����е�ÿ��Ԫ�ض���ƽ����^2��������ƽ����������ͬ�ľ������
%sum(x)�Ծ���x��ÿһ��Ϊ���󣬶�һ���ڵ�������͡�
%sum(x)����xΪ������ʱ����ָ��dim��ָ��dimΪ2�����Զ������������������ֵ�ĺͣ�
%���ָ��dimΪ1���������Ϊһ��������������ԭ������������ͬ��
%��һ������������Ϊ��ȥ�����ձ仯��Ӱ�죬��������������й�һ������
    descrip = descrip / sqrt(sum(descrip.^2));
    descriptors(i, :) = descrip(1, :);
end
fclose(g);