%一般情况下，可以将区域内的点分为3类
%a.平坦的点，b.边缘上的点，c.角点
%若对于这3类点分别求取x和y方向上的梯度Ix，Iy
%a类点的Ix和Iy都很小，b类点则是Ix和Iy有一个稍大一个稍小，
%角点c则是两个值都很大
%根据这种性质，可以区分出角点来
%求解Ix,Iy的过程：取3x3邻域计算
%Ix子模板：[-1 0 1;-1 0 1;-1 0 1]
%Iy子模板：[-1 -1 -1;0 0 0;1 1 1]
%清空变量，读取图像
clear;
clc;
image = imread('hall.jpg');
grayimage = rgb2gray(image);
%matlab中读取图片后保存的数据是uint8类型(8位无符号整数，即1个字节)
%以此方式存储的图像称作8位图像，好处相比较默认matlab数据类型双精度浮点double（64位，8个字节）
%可以节省很大一部分存储空间
%im2double()不仅仅是将uint8转换到double类型，而且把数据大小从0-255映射到0-1区间。 
grayimage = im2double(grayimage);
%缩放图像，减少运算时间，要不然matlab会报图像太大导致图像无法显示的错误
grayimage = imresize(grayimage, 0.5);
%计算X方向和Y方向的梯度及其平方
%函数名称：imfilter
%函数语法：g=imfilter(f,w,filtering_mode,boundary_options,size_optinos)
%函数功能：对任意类型数组或多维图像进行滤波
%参数介绍：f是输入图像，w为滤波模板，g为滤波结果；表1-1总结了其他参数的含义矩阵
X = imfilter(grayimage, [-1 0 1]);
%矩阵平方，点幂
X2 = X.^2;
Y = imfilter(grayimage, [-1 0 1]');
Y2 = Y.^2;
%点乘
XY = X.*Y;
%考虑到图像一般情况下的噪声影响，采用高斯滤波去除噪声点。
%生成高斯卷积核，对X2、Y2、XY进行平滑
%高斯低通滤波器，[5 1]表示模版尺寸，默认值为[3,3]
%1.5表示滤波器的标准差，单位为像素，默认值为0.5
h = fspecial('gaussian', [5 1], 1.5);
w = h * h';
A = imfilter(X2, w);
B = imfilter(Y2, w);
C = imfilter(XY, w);

%k一般取值0.04-0.06
k = 0.04;
RMax = 0;
%得到图像的高和宽
size = size(grayimage);
height = size(1);
width = size(2);
%计算角点的准则元素R（即用一个值来判断该点来衡量这个点是否是角点），并标记角点
%判断条件是R(i, j) > 0.01 * Rmax，且R(i, j)为3*3邻域局部最大值）。
%记录角点位置，角点处result的值不为0
R = zeros(height, width);
for h = 1 : height
    for w = 1 : width
        %计算M矩阵
        M = [A(h, w) C(h, w); C(h, w) B(h, w)];
        %计算R用于判断是否是边缘
        %det用于求一个方阵（square matrix）的行列式（Determinant）
        R(h, w) = det(M) - k * (trace(M))^2;
        %获得R的最大值，之后用于确定判断角点的阈值
        if(R(h, w) > RMax)
            RMax = R(h, w);
        end
    end
end

%用Q * RMax作为阈值，判断一个点是不是角点
Q = 0.01;
R_corner = (R >= (Q * RMax)).*R;

%寻找3*3邻域内的最大值，只有一个交点的R值在8邻域内是该邻域的最大点时，才认为该点是角点
fun = @(x) max(x(:)); 
R_localMax = nlfilter(R, [3 3], fun); 

%寻找既满足角点阈值，又在其8邻域内是最大值点的点作为角点
%注意：需要剔除边缘点
[row, col] = find(R_localMax(2 : height-1, 2 : width-1)...
    == R_corner(2 : height-1, 2 : width-1));

%绘制提取到的角点
figure('name', 'Harris');
imshow(grayimage),title('Harris'),
hold on
plot(col, row, 'y*'),
hold off