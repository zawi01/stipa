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
spectrogram(stipaSignal, 1024, 512, 1024, fs, 'yaxis', 'minThreshold', -100)
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
spectrogram(stipaRec, 1024, 512, 1024, fsRec, 'yaxis', 'minThreshold', -100)
fprintf('Plotting spectrogram of the measurement signal.\n')

% crop silence from the recorded signal
startIdx = 22000;
endIdx = 885000;
stipaRec = stipaRec(startIdx : endIdx);
fprintf('Cropping silence segments, the final duration is %.2f seconds.\n', ...
    (endIdx - startIdx + 1)/fs)

% compute STI value
STI = stipa(stipaRec, fsRec);
fprintf('Computed STI value: %.2f.\n', STI)

% compute STI value adjusted to auditory masking and ambient noise
Lsk = [72.2, 72.3, 70.1, 59.7, 51.5, 42.8, 36.4]; % measured signal levels
Lnk = [41.7, 42.0, 44.3, 38.1, 24.2, 21.0, 19.6]; % measured levels of ambient noise
STI_ = stipa(stipaRec, fsRec, 'Lsk', Lsk, 'Lnk', Lnk);
fprintf(['Computed STI value adjusted for auditory masking ' ...
    'and ambient noise: %.2f.\n'], STI_)
