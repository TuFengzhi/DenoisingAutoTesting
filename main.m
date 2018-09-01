clc; clear;
SR = 16000;
PESQ = 'D:\Github\PESQ\P862\Software\source\pesq.exe';
Noise_Path = './Noise/*.wav';
Speech_Path = './Speech/*.wav';
Dest_Path = './Speech_Noise/';

Noise_Set = dir(Noise_Path);
Speech_Set = dir(Speech_Path);

SNR = -5;

[N, NFS] = audioread(strcat(Noise_Set(1).folder, '/', Noise_Set(1).name));
N = N';
N = srconv(N, NFS, SR);
Seed = randperm(length(Speech_Set));
for index = 1:100
    index
    i = Seed(index);
    [S, SFS] = audioread(strcat(Speech_Set(1).folder, '/', Speech_Set(i).name));
    S = S';
    S = srconv(S, SFS, SR);

    data = add_noise(S, N, SR, SR, SNR);
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name), data, SR);
    
    Param1 = [' ', '+16000'];
    Param2 = [' ', strcat(Speech_Set(1).folder, '/', Speech_Set(i).name)];
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name)];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).name = Speech_Set(i).name;
    result(index).MOSOrigin = MOS;
    
    % Kalman Filter=
    Output = KalmanFilterSpeechEnhancement(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name));
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_K.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_K.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSKalman = MOS;
    
    % MMSE
    Output = MMSESTSA84(data(:,1), SR, 0.1);
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE84.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE84.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSMMSE84 = MOS;
    
    Output = MMSESTSA85(data(:,1), SR, 0.1);
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE85.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE85.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSMMSE85 = MOS;
    
    [s1, s2, s3] = denoisewithwavelet(data(:,1)');
    s1 = s1 / max(abs(s1));
    s2 = s2 / max(abs(s2));
    s3 = s3 / max(abs(s3));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav'), s1, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSS1 = MOS;
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav'), s2, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSS2 = MOS;
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav'), s3, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSS3 = MOS;
    
    Step = SR * 0.2;
    Output = [];
    w = zeros(32, 1);
    for j = 1 : length(S) / Step
        [en, w, yn] = lmsFunc(0.05, 32, N((j - 1)*Step + 1:j*Step), S((j - 1)*Step + 1:j*Step), w);
        Output=[Output en];
    end
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_LSM.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_LSM.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSLSM = MOS;
    Output = [];
    w = zeros(32, 1);
    for j = 1 : length(S) / Step
        [en, w, yn] = nlmsFunc(0.05, 32, N((j - 1)*Step + 1:j*Step), S((j - 1)*Step + 1:j*Step), 1e-4, w);
        Output=[Output en];
    end
    Output = Output / max(abs(Output));
    audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_NLSM.wav'), Output, SR);
    Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_NLSM.wav')];
    Cmd = [PESQ, Param1, Param2, Param3];
    [status, cmdout] = dos(Cmd);
    MOS = str2double(cmdout);
    result(index).MOSNLSM = MOS;
end
