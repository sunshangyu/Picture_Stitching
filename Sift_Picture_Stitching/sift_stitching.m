clc;
clear all;
clear;
left=imread('bnu1.jpg');
imwrite(left,'b1.pgm','pgm');
right=imread('bnu2.jpg');
imwrite(right,'b2.pgm','pgm');
[m,X1,Y1,X2,Y2] = match('b1.pgm','b2.pgm');
Ip=mosaic('bnu1.jpg','bnu2.jpg',X1,X2,Y1,Y2,m);