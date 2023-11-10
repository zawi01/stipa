%% STIPA verification steps according to IEC-60286-16 revision 5

% This script serves as a verification of the STIPA implementation using 
% the test signals described in Annexes A and C of IEC-60286-16 standard. 
% Necessary test signals developed by Embedded Acoustics, along with the 
% test signal description, are available at 
% http://www.stipa.info/index.php/download-test-signals.

% To verify this STIPA implementation, please follow these steps:
%   1. Download zip files with testing signals using the link above.
%   2. Unzip the folder with the testing signals into the `verification` folder.
%   3. Run this `stipaVerificationTests.m` script.

% Copyright Pavel Záviška, Brno University of Technology, 2023

% Add verification folder (and all subfolders) to Matlab path
addpath(genpath('verification'))


%% Annex A.2.2 - weight factor test

fprintf('\n')
fprintf('Running Test A.2.2 - weight factor test\n')
fprintf('=======================================\n')

fileNames = { ...
    'STIPA-sine-pair[125+250]STI=0.13', ...
    'STIPA-sine-pair[250+500]STI=0.28', ...
    'STIPA-sine-pair[500+1000]STI=0.4', ...
    'STIPA-sine-pair[1000+2000]STI=0.53', ...
    'STIPA-sine-pair[2000+4000]STI=0.49', ...
    'STIPA-sine-pair[4000+8000]STI=0.3'
    };

refSTI = [0.127; 0.279; 0.398; 0.531; 0.486; 0.302];
testThreshold = 0.001;

STI = NaN(length(fileNames), 1);

for n = 1:length(fileNames)
    
    [testSignal, fs] = audioread( ...
        ['verification\Annex A.2.2 - weight factor test\' ...
        fileNames{n} '.wav']);
    
    STI(n) = stipa(testSignal, fs);
    
    fprintf('%-38s', fileNames{n})
    fprintf('%-23s', ['Reference STI: ' num2str(refSTI(n), '%0.2f')])
    fprintf('%-22s', ['Computed STI: ' num2str(STI(n), '%0.2f')])
    if abs(refSTI(n) - STI(n)) < testThreshold
        fprintf('\x2714\n')
    else
        fprintf(2, '\x2716\n')
    end
    
end


%% Annex A.3.1.2 - filter bank phase test

fprintf('\n')
fprintf('Running Test A.3.1.2 - filter bank phase test\n')
fprintf("=============================================\n")

fileNames = { ...
    'STIPA-sine-edge-carriers-TI=0.1[m=0.059351]', ...
    'STIPA-sine-edge-carriers-TI=0.2[m=0.11182]', ...
    'STIPA-sine-edge-carriers-TI=0.3[m=0.20076]', ...
    'STIPA-sine-edge-carriers-TI=0.4[m=0.33386]', ...
    'STIPA-sine-edge-carriers-TI=0.5[m=0.5]', ...
    'STIPA-sine-edge-carriers-TI=0.6[m=0.66614]', ...
    'STIPA-sine-edge-carriers-TI=0.7[m=0.79924]', ...
    'STIPA-sine-edge-carriers-TI=0.8[m=0.88818]', ...
    'STIPA-sine-edge-carriers-TI=0.9[m=0.94065]', ...
    'STIPA-sine-edge-carriers-TI=0[m=0]', ...
    'STIPA-sine-edge-carriers-TI=1[m=1]'
    };

refSTI = [0.1; 0.2; 0.3; 0.4; 0.5; 0.6; 0.7; 0.8; 0.9; 0; 1];
testThreshold = 0.01;

STI = NaN(length(fileNames), 1);

for n = 1:length(fileNames)
    
    [testSignal, fs] = audioread( ...
        ['verification\Annex A.3.1.2 - filter bank phase test\' ...
        fileNames{n} '.wav']);
    
    STI(n) = stipa(testSignal, fs);
    
    fprintf('%-47s', fileNames{n})
    fprintf('%-23s', ['Reference STI: ' num2str(refSTI(n), '%0.2f')])
    fprintf('%-22s', ['Computed STI: ' num2str(STI(n), '%0.2f')])
    if abs(refSTI(n) - STI(n)) < testThreshold
        fprintf('\x2714\n')
    else
        fprintf(2, '\x2716\n')
    end
    
end


%% Annex C.3.2 - direct method modulation depth test

fprintf('\n')
fprintf('Running Test C.3.2 - direct method modulation depth test\n')
fprintf('========================================================\n')

fileNames = { ...
    'STIPA-sinecarrier-M=0', ...
    'STIPA-sinecarrier-M=0.1', ...
    'STIPA-sinecarrier-M=0.2', ...
    'STIPA-sinecarrier-M=0.3', ...
    'STIPA-sinecarrier-M=0.4', ...
    'STIPA-sinecarrier-M=0.5', ...
    'STIPA-sinecarrier-M=0.6', ...
    'STIPA-sinecarrier-M=0.7', ...
    'STIPA-sinecarrier-M=0.8', ...
    'STIPA-sinecarrier-M=0.9', ...
    'STIPA-sinecarrier-M=1'
    };

refM = [0; 0.1; 0.2; 0.3; 0.4; 0.5; 0.6; 0.7; 0.8; 0.9; 1];
refSTI = [0; 0.18; 0.3; 0.38; 0.44; 0.5; 0.56; 0.62; 0.7; 0.82; 1];
testThreshold = 0.05;
testOverallOffsetThreshold = 0.01;

STI = NaN(length(fileNames), 1);

for n = 1:length(fileNames)
    
    [testSignal, fs] = audioread(['verification\Annex C.3.2\' fileNames{n} '.wav']);
    [STI(n), mk] = stipa(testSignal, fs);
    
    fprintf('%-27s', fileNames{n})
    fprintf('%-32s', ['Max abs m-value error: ' num2str(max(max(abs(mk - refM(n)))), '%0.3f')])
    fprintf('%-23s', ['Reference STI: ' num2str(refSTI(n), '%0.2f')])
    fprintf('%-22s', ['Computed STI: ' num2str(STI(n), '%0.2f')])
    
    if abs(refM(n) - mk) < testThreshold
        fprintf('\x2714\n')
    else
        fprintf(2, '\x2716\n')
    end
    
end

systematicError = sum(abs(refSTI - round(STI, 2)));
fprintf('-----------------------------------------------\n')
fprintf('%-46s', ['Systematic absolute error in the STI: ' num2str(systematicError, '%0.2f')])
if systematicError < testOverallOffsetThreshold
    fprintf('\x2714\n')
else
    fprintf(2, '\x2716\n')
end


%% Annex C.4.2 - direct method filter bank slope test

fprintf('\n')
fprintf('Running Test C.4.2 - direct method filter bank slope test\n')
fprintf('=========================================================\n')


fileNames = { ...
    'Filtertest_lowslope 125'; ...
    'Filtertest_lowslope 250'; ...
    'Filtertest_lowslope 500'; ...
    'Filtertest_lowslope 1000'; ...
    'Filtertest_lowslope 2000'; ...
    'Filtertest_lowslope 4000'; ...
    'Filtertest_lowslope 8000'; ...
    'Filtertest_highslope 125'; ...
    'Filtertest_highslope 250'; ...
    'Filtertest_highslope 500'; ...
    'Filtertest_highslope 1000'; ...
    'Filtertest_highslope 2000'; ...
    'Filtertest_highslope 4000'; ...
    'Filtertest_highslope 8000'
    };

minMvalue = 0.5;

for n = 1:length(fileNames)
    
    [testSignal, fs] = audioread(['verification\Annex C.4.2\' fileNames{n} '.wav']);
    [~, mk] = stipa(testSignal, fs);
    
    mk_f1 = mk(1, mod(n-1, 7) + 1) * 0.55;
    mk_f2 = mk(2, mod(n-1, 7) + 1) * 0.55;
    
    fprintf('%-29s', fileNames{n})
    fprintf('%-20s', ['f1 m-value: ' num2str(mk_f1, '%0.2f')])
    fprintf('%-20s', ['f2 m-value: ' num2str(mk_f2, '%0.2f')])
    
    if all([mk_f1, mk_f2] >= minMvalue)
        fprintf('\x2714\n')
    else
        fprintf(2, '\x2716\n')
    end
    
end
