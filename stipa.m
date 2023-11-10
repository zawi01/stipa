function [STI, mk] = stipa(signal, fs, varargin)
%STIPA computes the Speech Transmission Index according to IEC 60268-16:2020
%standard using the direct STIPA (Speech Transmission Index for Public
%Addressing Systems) method.
%
%   [STI, MK] = STIPA(SIGNAL, FS) computes the Speech Transmission Index
%   from the test signal SIGNAL and its sampling frequency FS in Hz,
%   returning the Speech Transmission index STI and a 2-by-7 matrix of the
%   respective modulation transfer values MK for each octave band and
%   modulation frequency.
%
%   [STI, MK] = STIPA(SIGNAL, FS, REFERENCE) computes the Speech
%   Transmission Index using the REFERENCE signal instead of the default
%   value 0.55, which results from the STIPA test signal. If the sampling
%   frequency of the REFERENCE is not specified, it is assumed that the
%   sampling frequency is the same as the sampling frequency of the test
%   SIGNAL FS.
%
%   [STI, MK] = STIPA(SIGNAL, FS, REFERENCE, FSREF) computes the Speech
%   Transmission Index using the REFERENCE signal and its sampling
%   frequency FSREF.

% Copyright Pavel Záviška, Brno University of Technology, 2023

% Check number of input arguments
narginchk(2, 4);

% Parse input arguments:
p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validColumnVector = @(x) iscolumn(x);
addRequired(p, 'signal', validColumnVector);
addRequired(p, 'fs', validScalarPosNum);
addOptional(p, 'reference', NaN, validColumnVector);
addOptional(p, 'fsRef', fs, validScalarPosNum);
parse(p, signal, fs, varargin{:});

% Band-filter the input signal and cut the first 200 ms to suppress the
% transient effects of the used IIR octave filters
signalFiltered = bandFiltering(signal, fs);
signalFiltered = signalFiltered(0.2 * fs : end, :);

% Detect the envelope
signalEnvelope = envelopeDetection(signalFiltered, fs);

% Compute modulation depths of the input signal
mk_o = MTF(signalEnvelope, fs);

if nargin > 2 % Compute modulation depths of the reference signal if it was passed to the STIPA function
    reference = p.Results.reference;
    fsRef = p.Results.fsRef;
    
    referenceFiltered = bandFiltering(reference, fsRef);
    referenceEnvelope = envelopeDetection(referenceFiltered, fsRef);
    mk_i = MTF(referenceEnvelope, fsRef);
    mk = mk_o ./ mk_i;
else % Use the default modulation depth 0.55
    mk = mk_o ./ 0.55;
end

% Limit the value of modulation transfer values mk to avoid complex values in SNR
mk(mk > 1) = 1;

% Calculate SNR from the modulation transfer values and limit the range to [-15; 15] dB
SNR = computeSNR(mk);
SNR = clipSNR(SNR);

% Calculate Trasmission Index
TI = computeTI(SNR);

% Calculate Modulation Transmission Index
MTI = computeMTI(TI);

% Calculate the final value of Speech Transmission index
STI = computeSTI(MTI);


    function y = bandFiltering(x, fs)
    % Filter input signal using a octave filter of 18th order to achieve a
    % minimum of 42 dB attenuation at the cener frequency of each adjacent
    % band.
        
        filterOrder = 18;
        octaveBands = [125, 250, 500, 1000, 2000, 4000, 8000];
        
        y = NaN(length(x), length(octaveBands));
        
        for bandIdx = 1:length(octaveBands)
            octFilt = octaveFilter(octaveBands(bandIdx), '1 octave', ...
                'SampleRate', fs, 'FilterOrder', filterOrder);
            
            y(:, bandIdx) = octFilt(x);
        end
        
    end

    function envelope = envelopeDetection(x, fs)
    % Compute the intensity envelope by squaring the outputs of the
    % bandpass filters and applying a low pass filter at a cut-off
    % frequency of 100 Hz.
        
        envelope = x .* x;
        envelope = lowpass(envelope, 100, fs);
    end

    function mk = MTF(signalEnvelope, fs)
    % Compute the modulation depths of the received signal's envelope for
    % each octave band k.
        
        fm = [1.6, 1, 0.63, 2, 1.25, 0.8, 2.5; ... % modulation frequencies in Hz
            8, 5, 3.15, 10, 6.25, 4, 12.5];
        seconds = length(signalEnvelope) / fs; % duration of the signal in seconds
        
        mk = NaN(2, 7);
        
        for k = 1:7 % iterate over octave bands
            Ik = signalEnvelope(:, k); % signal envelope of k-th octave band
            
            for n = 1:2 % iterate over each modulation frequency in k-th octave band
                % Calculate the duration and index of the signal for a whole number of periods
                secondsWholePeriod = floor(fm(n, k) * seconds) / fm(n, k);
                indexWholePeriod = round(secondsWholePeriod * fs);
                t = linspace(0, secondsWholePeriod, indexWholePeriod).';
                
                % Calculate the modulation depths using a whole number of
                % periods for each specific modulation frequency
                mk(n, k) = 2 * sqrt(sum(Ik(1:indexWholePeriod) .* sin(2 * pi * fm(n, k) * t)) ^ 2 + ...
                    sum(Ik(1:indexWholePeriod) .* cos(2 * pi * fm(n, k) * t)) ^ 2) / sum(Ik(1:indexWholePeriod));
            end
            
        end
        
    end

    function SNR = computeSNR(mk)
    % Compute the Signal-to-Noise Ratio (SNR) from the MTF matrix
    % consisting of modulation ratios mk.
        
        SNR = 10 * log10(mk ./ (1 - mk));
    end

    function SNR_clipped = clipSNR(SNR)
    % Limit the SNR values to fit the range from -15 to 15 dB.
        
        SNR_clipped = SNR;
        SNR_clipped(SNR_clipped > 15) = 15;
        SNR_clipped(SNR_clipped < -15) = -15;
    end

    function TI = computeTI(SNR)
    % Compute the Transmission index from the SNR.
        
        TI = (SNR + 15) / 30;
    end

    function MTI = computeMTI(TI)
    % Compute the Modulation Transfer index (MTI) from the Transmission index TI.
        
        MTI = mean(TI);
    end

    function STI = computeSTI(MTI)
    % Compute the final Speech Transmission Index (STI) from the Modulation
    % transfer indices MTI.
        
        % weighting factors for male speech according to the standard
        alpha_k = [0.085, 0.127, 0.230, 0.233, 0.309, 0.224, 0.173];
        
        % redundancy factors for male speech according to the standard
        beta_k = [0.085, 0.078, 0.065, 0.011, 0.047, 0.095];
        
        STI = min(sum(alpha_k .* MTI) - sum(beta_k .* sqrt(MTI(1:end - 1) .* MTI(2:end))), 1);
    end

end
