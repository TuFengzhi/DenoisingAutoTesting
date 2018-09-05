function Output = KalmanFilterSpeechEnhancement(Filename)
    %% Setting up the variables before jumping into processing.
    WinLenSec = 0.02; % Window length in seconds.
    HopPercent = 1; % percentage of hopping.
    AROrder = 20; % Auto regressive filter order.
    NumIter = 3;

    %% Reading Input signal and creating noisy input as well.
    [Input, Fs] = audioread(Filename);
    Input = Input(:,1);
    Noise = normrnd(0,sqrt(0.01),size(Input));
    % NoisyInput = Input + Noise;
    NoisyInput = Input;
    Time = (0:1/Fs:(length(Input)-1)/Fs)';

    %% Chopping session.
    WinLenSamples = fix(WinLenSec * Fs);
    Window = ones(WinLenSamples,1);
    [ChoppedSignal, NumSegments] = Chopper(NoisyInput, WinLenSamples, Window, HopPercent);

    %% Matrix initializations.
    H = [zeros(1,AROrder-1),1];   % Measurement matrix.
    R = var(Noise);     % Variance of noise.

    [FiltCoeff, Q] = lpc(ChoppedSignal, AROrder);   % Finding filter coefficients.

    P = R * eye(AROrder,AROrder);   % Error covariance matrix.
    Output = zeros(1,size(NoisyInput,1));   % Allocating memory for output signal.
    Output(1:AROrder) = NoisyInput(1:AROrder,1)';   % Initializing output signal according to equation (13)
    OutputP = NoisyInput(1:AROrder,1);

    %% Iterators.
    i = AROrder+1;
    j = AROrder+1;

    %% Processing.
    for k = 1:NumSegments   % For every segment of chopped signal...
        jStart = j;     % Keeping track of AROrder+1 value for every iteration.
        OutputOld = OutputP;    % Keeping the first AROrder amount of samples for every iteration.

        for l = 1:NumIter
            A = [zeros(AROrder-1,1) eye(AROrder-1); fliplr(-FiltCoeff(k,2:end))];

            for ii = i:WinLenSamples
                OutputC = A * OutputP;
                Pc = (A * P * A') + (H' * Q(k) * H);
                K = (Pc * H')/((H * Pc * H') + R);
                OutputP = OutputC + (K * (ChoppedSignal(ii,k) - (H*OutputC)));
                Output(j-AROrder+1:j) = OutputP';
                P = (eye(AROrder) - K * H) * Pc;
                j = j+1;
            end

            i = 1;
            if l < NumIter
                j = jStart;
                OutputP = OutputOld;
            end

            % update lpc on filtered signal  
            [FiltCoeff(k,:), Q(k)] = lpc(Output((k-1)*WinLenSamples+1:k*WinLenSamples),AROrder);
        end
    end
    Output = Output';

    ol=length(Output);
    if ol<length(Input)
        Output=[Output;zeros(length(Input)-ol,1)];
    else
        Output=Output(1:length(Input));
    end

    %% Plotting the results
    % audiowrite('two_out.wav', Output, Fs);
    % figure
    % plot(Input)
    % xlabel('Time in seconds')
    % ylabel('Amlitude')
    % title('Clean speech signal')
    % figure
    % plot(Time, Noise)
    % xlabel('Time in seconds')
    % ylabel('Amlitude')
    % title('Observation noise')
    % figure
    % plot(Time, NoisyInput)
    % xlabel('Time in seconds')
    % ylabel('Amlitude')
    % title('Noisy input signal')
    % figure
    % plot(Output)
    % xlabel('Time in seconds')
    % ylabel('Amlitude')
    % title('Estimated clean output signal')

end