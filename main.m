clc; clear;
SR = 16000;
PESQ = 'D:\Github\PESQ\P862\Software\source\pesq.exe';
Noise_Path = './Noise/plane.wav';
Speech_Path = './Speech/*.wav';
Dest_Path = './PlaneNoiseDemo/';

if ~exist(Dest_Path, 'dir') mkdir(Dest_Path); end

Speech_Set = dir(Speech_Path);

SNRS = [15, 10, 5, 0, -5, -10];

[N, NFS] = audioread(Noise_Path);
N = N';
N = srconv(N, NFS, SR);

Seed = randperm(length(Speech_Set));

for SNR = SNRS
    if ~exist([Dest_Path '/' int2str(SNR)], 'dir') mkdir([Dest_Path '/' int2str(SNR)]); end
    for index = 1:500
        [SNR index]
        i = Seed(index);
        Speech_Set(i).name = 'B15_401.wav';
        [S, SFS] = audioread(strcat(Speech_Set(1).folder, '/', Speech_Set(i).name));
        S = S';
        S = srconv(S, SFS, SR);
        
        result(index).name = Speech_Set(i).name;

        data = add_noise(S, N, SR, SR, SNR);
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name), data, SR);
        
        % Origin
        Param1 = [' ', '+16000'];
        Param2 = [' ', strcat(Speech_Set(1).folder, '/', Speech_Set(i).name)];
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name)];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, data, SR);
        result(index).MOSOrigin = MOS;
        result(index).STOIOrigin = d;
        
        % Kalman Filter
        Output = KalmanFilterSpeechEnhancement(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name));
        Output = Output / max(abs(Output));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_Kalman.wav'), Output, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_Kalman.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, Output, SR);
        result(index).MOSKalman = MOS;
        result(index).STOIKalman = d;
        
        % MMSE84
        Output = MMSESTSA84(data(:,1), SR, 0.1);
        Output = Output / max(abs(Output));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE84.wav'), Output, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE84.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, Output, SR);
        result(index).MOSMMSE84 = MOS;
        result(index).STOIMMSE84 = d;
        
        % MMSE85
        Output = MMSESTSA85(data(:,1), SR, 0.1);
        Output = Output / max(abs(Output));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE85.wav'), Output, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_MMSE85.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, Output, SR);
        result(index).MOSMMSE85 = MOS;
        result(index).STOIMMSE85 = d;
        
        % Wavelet S1
        [s1, s2, s3] = denoisewithwavelet(data(:,1)');
        s1 = s1 / max(abs(s1));
        s2 = s2 / max(abs(s2));
        s3 = s3 / max(abs(s3));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav'), s1, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S1.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, s1, SR);
        result(index).MOSS1 = MOS;
        result(index).STOIS1 = d;

        % Wavelet S2
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav'), s2, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S2.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, s2, SR);
        result(index).MOSS2 = MOS;
        result(index).STOIS2 = d;

        % Wavelet S3
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav'), s3, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_S3.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, s3, SR);
        result(index).MOSS3 = MOS;
        result(index).STOIS3 = d;
        
        % LMS
        Step = SR * 0.02;
        Output = [];
        w = zeros(32, 1);
        for j = 1 : length(S) / Step
            [en, w, yn] = lmsFunc(0.05, 32, N((j - 1)*Step + 1:j*Step), data((j - 1)*Step + 1:j*Step), w);
            Output=[Output en];
        end
        ol=length(Output);
        if ol<length(data)
            Output=[Output zeros(length(data)-ol,1)'];
        end
        Output = Output / max(abs(Output));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_LMS.wav'), Output, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_LMS.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, Output, SR);
        result(index).MOSLMS = MOS;
        result(index).STOILMS = d;
        
        % NLMS
        Output = [];
        w = zeros(32, 1);
        for j = 1 : length(S) / Step
            [en, w, yn] = nlmsFunc(0.05, 32, N((j - 1)*Step + 1:j*Step), data((j - 1)*Step + 1:j*Step), 1e-4, w);
            Output=[Output en];
        end
        ol=length(Output);
        if ol<length(data)
            Output=[Output zeros(length(data)-ol,1)'];
        end
        Output = Output / max(abs(Output));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_NLMS.wav'), Output, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_NLMS.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, Output, SR);
        result(index).MOSNLMS = MOS;
        result(index).STOINLMS = d;

        % Wiener Filter - esTSNR
        [esTSNR, esHRNR] = WienerNoiseReduction(data, SR, 0.2 * SR);
        esTSNR = esTSNR / max(abs(esTSNR));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_esTSNR.wav'), esTSNR, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_esTSNR.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, esTSNR, SR);
        result(index).MOSNesTSNR = MOS;
        result(index).STOIesTSNR = d;

        % Wiener Filter - esHRNR
        esHRNR = esHRNR / max(abs(esHRNR));
        audiowrite(strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_esHRNR.wav'), esHRNR, SR);
        Param3 = [' ', strcat(Dest_Path, int2str(SNR), '/', Speech_Set(i).name(1:end-4), '_esHRNR.wav')];
        Cmd = [PESQ, Param1, Param2, Param3];
        [status, cmdout] = dos(Cmd);
        MOS = str2double(cmdout);
        d = stoi(S, esHRNR, SR);
        result(index).MOSesHRNR = MOS;
        result(index).STOIesHRNR = d;
    end
    writetable(struct2table(result), [int2str(SNR) '.xlsx']);
end