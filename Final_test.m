clear; clc; close all;

filename    = '45KHz.txt';

% ADC properties 
ADCSampleRate = 100000;  % The sampling rate of the signal acquisition
dT            = 1/ADCSampleRate;
ADCbits       = 12;    % Number of bits on the ADC
Vdd           = 3.3;   % Reference voltage of controller

senseGain     = 1; % gain of the sense amplifier
dataColumn  = 1;       % The data is in first column
                      

% Import data from file:
importData  = readtable(filename);
rawData     = importData{:,dataColumn};

% Calibrate the data given the amplifier-ADC properties.
Vibsig      = (rawData/2^ADCbits) *Vdd/senseGain; % (V)
t           = 1:length(Vibsig) * 100000/ADCSampleRate; % ms


%  FFT on the Vibration Signal
Ym                  = fft(Vibsig);
P2                  = abs(Ym/length(Vibsig));
FFTSig              = P2(1 ...
                        ...
                        : length(Vibsig)/2+1);
FFTSig(2:end-1)     = 2*FFTSig(2:end-1);
fSig                = ADCSampleRate*(0:(length(Vibsig)/2))/length(Vibsig);



% Plot the time and frequency domain data
figure;
set(gcf,'color','w');
% Original signal
subplot(2,1,1)
    plot(t ,Vibsig );
    xlabel('time (s)')
    ylabel('amplitude')
    title('original Vib data')
subplot(2,1,2)
    loglog(fSig, FFTSig);
    xlabel('Frequency (Hz)')
    ylabel('amplitidude')
    title('Vib - whole signal frequency analysis')


% Threshold for identifying dominant frequencies.
threshold = 0.00004; % Adjust this value based on your application.

% Find the dominant frequencies by identifying the indices where the FFT magnitude is greater than the threshold.
DomFreqIndices = find(FFTSig > threshold);

% Create label vector presence (1), absence (0)-Dominant Frequencies
DomFreqLabels = zeros(size(FFTSig));
DomFreqLabels(DomFreqIndices) = 1;

% New table to store the labeled Freq domain data 
DataLabelFreq = table(FFTSig, DomFreqLabels, 'VariableNames', {'FrequencyDomain', 'HasDomFreq'});

% Save the frequency domain labeled data, label to a new text file.
newFilename = 'labeled_freq_domain_45KHz.txt'; % Specify a new filename
writetable(DataLabelFreq, newFilename, 'Delimiter', '\t'); % Adjust the delimiter as needed.

% 4. Prepare the data for machine learning:

% Use the frequency domain representation (FFTSig) as the feature for the machine learning model.
X = FFTSig;

% Assign the target labels (1 if the frequency is dominant, 0 otherwise).
y = DataLabelFreq.HasDomFreq;

% 5. Split the data - training and testing sets:
% Use 70% of the data for training and 30% for testing.
splitRatio = 0.7;
splitIdx = round(splitRatio * numel(X));
X_train = X(1:splitIdx);
y_train = y(1:splitIdx);
X_test = X(splitIdx+1:end);
y_test = y(splitIdx+1:end);

% 6. Train Random Forest model:
numTrees = 1000; % You can adjust this parameter
randomForestModel = TreeBagger(numTrees, X_train, y_train);

% 7. Model evaluation:
predictedLabels = predict(randomForestModel, X_test);
predictedLabels = str2double(predictedLabels);

accuracy = sum(predictedLabels == y_test) / numel(y_test);
disp(['Accuracy: ', num2str(accuracy)]);

