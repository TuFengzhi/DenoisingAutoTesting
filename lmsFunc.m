function [e,w,ee]=lmsFunc(mu,M,u,d, w)
% Normalized LMS
% Call:
% [e,w]=nlms(mu,M,u,d,a);
%
% Input arguments:
% mu = step size, dim 1x1
% M = filter length, dim 1x1
% u = input signal, dim Nx1
% d = desired signal, dim Nx1
% a = constant, dim 1x1
%
% Output arguments:
% e = estimation error, dim Nx1
% w = final filter coefficients, dim Mx1
%intial value 0
 
% w=zeros(M,1); %This is a vertical column
 
%input signal length
N=length(u);
%make sure that u and d are colon vectors
u=u(:);
d=d(:);
%NLMS
ee=zeros(1,N);
for n=M:N %Start at M (Filter Length) and Loop to N (Length of Sample)
    uvec=u(n:-1:n-M+1); %Array, start at n, decrement to n-m+1
    e(n)=d(n)-w'*uvec;
    w=w+2*mu*uvec*e(n);
    % y(n) = w'*uvec; %In ALE, this will be the narrowband noise.
end