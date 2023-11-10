function signal = generateStipaSignal(duration, varargin)
%GENERATESTIPASIGNAL generates the STIPA test signal for measurement of
%the Speech Transmission Index (STI) according to IEC 60268-16:2020
%standard using the direct STIPA (Speech Transmission Index for Public
%Addressing Systems) method
%
%   SIGNAL = GENERATESTIPASIGNAL(DURATION) generates DURATION seconds of
%   the STIPA test signal. When no sampling frequency is given, the default
%   value 96 kHz is used.
%
%   SIGNAL = GENERATESTIPASIGNAL(DURATION, FS) generates DURATION seconds
%   of the STIPA test signal with a sampling frequency of FS Hertz.
%   The minimum FS is 22050 Hz.

% Copyright Pavel Záviška, Brno University of Technology, 2023

% Check number of input arguments
narginchk(1, 2);

% Parse input arguments
p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validSamplingFreq = @(x) isnumeric(x) && isscalar(x) && (x > 22050);
addRequired(p, 'duration', validScalarPosNum);

defaultFs = 96000;
addOptional(p, 'fs', defaultFs, validSamplingFreq);
parse(p, duration, varargin{:});
fs = p.Results.fs;

% Generate pink noise
N = duration * fs;
pinkNoise = pinknoise(N);

% Filtrate the pink noise
filteredPinkNoise = NaN(N, 7);
filterOrder = 20;
octaveBands = [125, 250, 500, 1000, 2000, 4000, 8000];

for bandIdx = 1:length(octaveBands)
    octFilt = octaveFilter(octaveBands(bandIdx), '1/2 octave', ...
        'SampleRate', fs, 'FilterOrder', filterOrder);
    filteredPinkNoise(:, bandIdx) = octFilt(pinkNoise);
end

% Modulate the frequencies
fm = [1.6, 1, 0.63, 2, 1.25, 0.8, 2.5; ... % modulation frequencies in Hz
    8, 5, 3.15, 10, 6.25, 4, 12.5];

t = linspace(0, duration, N).';
modulation = NaN(N, 7);

for bandIdx = 1:length(octaveBands)
    modulation(:, bandIdx) = sqrt(0.5 * (1 + 0.55 * ...
        (sin(2 * pi * fm(1, bandIdx) * t) - sin(2 * pi * fm(2, bandIdx) * t))));
end

% Set levels of the octave bands
levels = [-2.5, 0.5, 0, -6, -12, -18, -24]; % revision 5 band levels
G = 10 .^ (levels / 20); % acoustic pressure of bands

% Compute the final STIPA test signal
signal = sum(filteredPinkNoise .* modulation .* G, 2);

% Normalize the RMS of the final singal
targetRMS = 0.1; % empirically derived from the character of the STIPA test signal
signal = signal * targetRMS / rms(signal);
