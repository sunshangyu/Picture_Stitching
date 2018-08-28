%һ������£����Խ������ڵĵ��Ϊ3��
%a.ƽ̹�ĵ㣬b.��Ե�ϵĵ㣬c.�ǵ�
%��������3���ֱ���ȡx��y�����ϵ��ݶ�Ix��Iy
%a����Ix��Iy����С��b�������Ix��Iy��һ���Դ�һ����С��
%�ǵ�c��������ֵ���ܴ�
%�����������ʣ��������ֳ��ǵ���
%���Ix,Iy�Ĺ��̣�ȡ3x3�������
%Ix��ģ�壺[-1 0 1;-1 0 1;-1 0 1]
%Iy��ģ�壺[-1 -1 -1;0 0 0;1 1 1]
%��ձ�������ȡͼ��
clear;
clc;
image = imread('hall.jpg');
grayimage = rgb2gray(image);
%matlab�ж�ȡͼƬ�󱣴��������uint8����(8λ�޷�����������1���ֽ�)
%�Դ˷�ʽ�洢��ͼ�����8λͼ�񣬺ô���Ƚ�Ĭ��matlab��������˫���ȸ���double��64λ��8���ֽڣ�
%���Խ�ʡ�ܴ�һ���ִ洢�ռ�
%im2double()�������ǽ�uint8ת����double���ͣ����Ұ����ݴ�С��0-255ӳ�䵽0-1���䡣 
grayimage = im2double(grayimage);
%����ͼ�񣬼�������ʱ�䣬Ҫ��Ȼmatlab�ᱨͼ��̫����ͼ���޷���ʾ�Ĵ���
grayimage = imresize(grayimage, 0.5);
%����X�����Y������ݶȼ���ƽ��
%�������ƣ�imfilter
%�����﷨��g=imfilter(f,w,filtering_mode,boundary_options,size_optinos)
%�������ܣ�����������������άͼ������˲�
%�������ܣ�f������ͼ��wΪ�˲�ģ�壬gΪ�˲��������1-1�ܽ������������ĺ������
X = imfilter(grayimage, [-1 0 1]);
%����ƽ��������
X2 = X.^2;
Y = imfilter(grayimage, [-1 0 1]');
Y2 = Y.^2;
%���
XY = X.*Y;
%���ǵ�ͼ��һ������µ�����Ӱ�죬���ø�˹�˲�ȥ�������㡣
%���ɸ�˹����ˣ���X2��Y2��XY����ƽ��
%��˹��ͨ�˲�����[5 1]��ʾģ��ߴ磬Ĭ��ֵΪ[3,3]
%1.5��ʾ�˲����ı�׼���λΪ���أ�Ĭ��ֵΪ0.5
h = fspecial('gaussian', [5 1], 1.5);
w = h * h';
A = imfilter(X2, w);
B = imfilter(Y2, w);
C = imfilter(XY, w);

%kһ��ȡֵ0.04-0.06
k = 0.04;
RMax = 0;
%�õ�ͼ��ĸߺͿ�
size = size(grayimage);
height = size(1);
width = size(2);
%����ǵ��׼��Ԫ��R������һ��ֵ���жϸõ�������������Ƿ��ǽǵ㣩������ǽǵ�
%�ж�������R(i, j) > 0.01 * Rmax����R(i, j)Ϊ3*3����ֲ����ֵ����
%��¼�ǵ�λ�ã��ǵ㴦result��ֵ��Ϊ0
R = zeros(height, width);
for h = 1 : height
    for w = 1 : width
        %����M����
        M = [A(h, w) C(h, w); C(h, w) B(h, w)];
        %����R�����ж��Ƿ��Ǳ�Ե
        %det������һ������square matrix��������ʽ��Determinant��
        R(h, w) = det(M) - k * (trace(M))^2;
        %���R�����ֵ��֮������ȷ���жϽǵ����ֵ
        if(R(h, w) > RMax)
            RMax = R(h, w);
        end
    end
end

%��Q * RMax��Ϊ��ֵ���ж�һ�����ǲ��ǽǵ�
Q = 0.01;
R_corner = (R >= (Q * RMax)).*R;

%Ѱ��3*3�����ڵ����ֵ��ֻ��һ�������Rֵ��8�������Ǹ����������ʱ������Ϊ�õ��ǽǵ�
fun = @(x) max(x(:)); 
R_localMax = nlfilter(R, [3 3], fun); 

%Ѱ�Ҽ�����ǵ���ֵ��������8�����������ֵ��ĵ���Ϊ�ǵ�
%ע�⣺��Ҫ�޳���Ե��
[row, col] = find(R_localMax(2 : height-1, 2 : width-1)...
    == R_corner(2 : height-1, 2 : width-1));

%������ȡ���Ľǵ�
figure('name', 'Harris');
imshow(grayimage),title('Harris'),
hold on
plot(col, row, 'y*'),
hold off