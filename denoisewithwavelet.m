function [s1, s2, s3] = denoisewithwavelet(signal)
    %=============================
    %画出原始信号
    % figure;
%     subplot(2,2,1);
%     plot(signal);
    % title('原始信号');
    %=============================
    %用db4小波对原始信号进行3层分解并提取系数
    [c,l]=wavedec(signal,3,'db4');
    a3=appcoef(c,l,'db4',3);
    d3=detcoef(c,l,3);
    d2=detcoef(c,l,2);
    d1=detcoef(c,l,1);
    %=============================
    %对信号进行强制性消噪处理并图示结果
    dd3=zeros(1,length(d3));
    dd2=zeros(1,length(d2));
    dd1=zeros(1,length(d1));
    c1=[a3 dd3 dd2 dd1];
    s1=waverec(c1,l,'db4');
%     subplot(2,2,2);
%     plot(s1);grid;
    % title('强制消噪后的信号');
    %=============================
    %用默认阈值对信号进行消噪处理并图示结果
    %用ddencmp函数获得信号的默认阈值
    [thr,sorh,keepapp]=ddencmp('den','wv',signal);
    s2=wdencmp('gbl',c,l,'db4',3,thr,sorh,keepapp);
%     subplot(2,2,3);
%     plot(s2);grid;
    % title('默认阈值消噪后的信号');
    %=============================
    %用给定的软阈值进行消噪处理
    softd1=wthresh(d1,'s',1.465 / 50);
    softd2=wthresh(d2,'s',1.823 / 50);
    softd3=wthresh(d3,'s',2.768 / 50);
    c2=[a3 softd3 softd2 softd1];
    s3=waverec(c2,l,'db4');
%     subplot(2,2,4);
%     plot(s3);grid;
    % title('给定软阈值消噪后的信号');
end