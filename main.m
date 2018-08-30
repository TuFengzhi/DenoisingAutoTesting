clc; clear;
SR = 16000;
PESQ = 'D:\Github\PESQ\P862\Software\source\pesq.exe';
Noise_Path = './Noise/*.wav';
Speech_Path = './Speech/*.wav';
Dest_Path = './Speech_Noise/';

Noise_Set = dir(Noise_Path);
Speech_Set = dir(Speech_Path);

SNR = -5;

[s1, fs1] = audioread(strcat(Noise_Set(1).folder, '/', Noise_Set(1).name), 'native');
s1 = s1';
s1 = double(s1);
s1 = srconv(s1, fs1, SR);

for i = 1:100
    i
    [s2, fs2] = audioread(strcat(Speech_Set(1).folder, '/', Speech_Set(i).name), 'native');
    s2 = s2';
    s2 = double(s2);
    s2 = srconv(s2, fs2, SR);

    data = add_noise(s2, s1, SR, SR, SNR);
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name), data, SR);
    
    Param1 = [' ', '+16000'];
    Param2 = [' ', strcat(Speech_Set(1).folder, '/', Speech_Set(i).name)];
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name)];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).name = Speech_Set(i).name;
    result(i).MOSOrigin = MOS;
    
    % Kalman Filter=
    Output = KalmanFilterSpeechEnhancement(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name));
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_K.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_K.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOSKalman = MOS;
    
    % MMSE
    [data, SR]  = audioread(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name));
    Output = MMSESTSA84(data(:,1), SR, 0.1);
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_84.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_84.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOS84 = MOS;
    
    Output = MMSESTSA85(data(:,1), SR, 0.1);
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_85.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_85.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOS85 = MOS;
    
    [data, SR]  = audioread(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name));
    [s1, s2, s3] = denoisewithwavelet(data(:,1)');
    s1 = s1 / max(abs(s1));
    s2 = s2 / max(abs(s2));
    s3 = s3 / max(abs(s3));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav'), s1, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOSS1 = MOS;
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav'), s2, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOSS2 = MOS;
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav'), s3, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(i).MOSS3 = MOS;
    
end
