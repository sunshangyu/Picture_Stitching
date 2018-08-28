% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');

function [num,X1,Y1,X2,Y2] = match(image1, image2)

% Find SIFT keypoints for each image
%拿到两张图片的sift关键点和关键点的描述子
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.2;

% For each descriptor in the first image, select its match to second image.
%转置，因为接下来des1(i,:)要和des2t进行电极，所以这里要将des2转置
des2t = des2';                          % Precompute matrix transpose
%一次处理一个关键点
for i = 1 : size(des1,1)
%计算点积，可以得出img1中的一个feature点与img2中所有点的点乘
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
%将点积的逆余弦排序
%对于向量a,b,a·b=|a|*|b|*cos<a,b>，那么acos(dotprods)就是当前img1特征向量和img2中所有的特征向量的夹角
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
%vals(1)和vals(2)分别是所夹最小角和次小角
%小角小于distRatio(const value)乘以次小角是match的条件
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

% Create a new image showing the two images side by side.
%将两个图片并排放
m = 1;
% Show a figure with lines joining the accepted matches.
cols1 = size(im1,2);
for i = 1: size(des1,1)
    if (match(i) > 0)
        X1(m)=loc1(i,2);
        Y1(m)=loc1(i,1);
        X2(m)=loc2(match(i),2);
        Y2(m)=loc2(match(i),1);
        m = m+1;
  end
end
num = sum(match > 0);
fprintf('Found %d matches.\n', num);
X1=X1';X2=X2';Y1=Y1';Y2=Y2';