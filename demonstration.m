%% Demonstration file
% This script serves as a simple demonstration of this STIPA implementation.

addpath('control_measurements')

% generate STIPA test signal
duration = 25;
fs = 48000;
stipaSignal = generateStipaSignal(duration, fs);
fprintf('Generating %g seconds of STIPA test signal sampled at %d Hz.\n', ...
    duration, fs)

% plot Spectrogram of generated STIPA test signal
figure
spectrogram(stipaSignal, 1024, 512, 1024, fs, 'yaxis', 'minThreshold', -120)
fprintf('Plotting spectrogram of the generated STIPA test signal.\n')

% save STIPA test signal as WAV file
filename = 'stipaTestSignal.wav';
audiowrite(filename, stipaSignal, fs);
fprintf('Saving the generated STIPA test signal as ''%s''.\n', filename)

% load recorded STIPA signal after passing through the transmission channel
filenameRec = 'stipaMeasurement.wav';
[stipaRec, fsRec] = audioread(['/control_measurements/', filenameRec]);
fprintf('Loading measurement ''%s''.\n', filenameRec)

% plot Spectrogram of recorded STIPA signal
figure
spectrogram(stipaRec, 1024, 512, 1024, fsRec, 'yaxis', 'minThreshold', -120)
fprintf('Plotting spectrogram of the measurement signal.\n')

% crop silence from the recorded signal
startIdx = 22000;
endIdx = 885000;
stipaRec = stipaRec(startIdx : endIdx);
fprintf('Cropping silence segments, the final duration is %.2f seconds.\n', ...
    (endIdx - startIdx)/fs)

% compute STI value
STI = stipa(stipaRec, fsRec);
fprintf('Computed STI value: %.2f.\n', STI)
