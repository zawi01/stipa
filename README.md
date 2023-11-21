# Speech Transmission Index for Public Address (STIPA)

Speech Transmission Index ([STI](https://en.wikipedia.org/wiki/Speech_transmission_index))
is a metric ranging between 0 and 1 representing the transmission quality of speech with respect to intelligibility by a speech transmission channel, defined in the [IEC&nbsp;60268-16](https://webstore.iec.ch/publication/26771) standard.
It is based on an analysis of the amplitude modulations, which simulate speech signals.

The full STI model consists of 98 separate test signals using 14 different modulation frequencies in 7 octave bands, which requires approximately 15 minutes of measurements.

STIPA is a simplified form of the full STI based on measurements using a lower number of modulation indices.
Specifically, STIPA uses only one test signal with 2 modulation frequencies in each of the 7 octave bands.
Recommended measurement duration shall be approximately 18 seconds, with a recommended range of 15 s to 25 s.

This MATLAB implementation of STIPA allows users to generate the STIPA test signal of defined length and sampling frequency and then compute the STI using the direct STIPA method. 

Apart from the direct STIPA method, the norm also specifies the indirect method usually denoted as STIPA(IR), which is based on measuring the impulse response.
However, the indirect method is not suitable for applications involving non-linear components in the transmission chain, such as loudspeakers, as it relies on the assumption of linearity and may lead to potential inaccuracies in measurements.

The quality of speech transmission and the likelihood of intelligibility of syllables, words, and sentences being comprehended for native speakers with healthy hearing can be represented by the following table.

| STI value | Quality according to<br>IEC 60268-16 | Intelligibility<br>of syllables in % | Intelligibility<br>of words in % | Intelligibility<br>of sentences in % |
|:----------------:|:---------:|:-------------:|:-------------:|:--------------:|
| 0 &ndash; 0.3    | bad       | 0 &ndash; 34  | 0 &ndash; 67  | 0 &ndash; 89   |
| 0.3 &ndash; 0.45 | poor      | 34 &ndash; 48 | 67 &ndash; 78 | 89 &ndash; 92  |
| 0.45 &ndash; 0.6 | fair      | 48 &ndash; 67 | 78 &ndash; 87 | 92 &ndash; 95  |
| 0.6 &ndash; 0.75 | good      | 67 &ndash; 90 | 87 &ndash; 94 | 95 &ndash; 96  |
| 0.75 &ndash; 1   | excellent | 90 &ndash; 96 | 94 &ndash; 96 | 96 &ndash; 100 |

The uncertainty associated with a single STIPA measurement is 0.02 to 0.03.
Thus, to obtain higher accuracy, it is recommended to perform multiple measurements and average the results.

Note, that to obtain correct measurements of STI, it is necessary to follow the recommendations according to [IEC&nbsp;60268-16](https://webstore.iec.ch/publication/26771).

## Usage

Typical usage of STIPA test consists of three steps:
1. Generate the STIPA test signal using [`generateStipaSignal`](https://github.com/zawi01/stipa/blob/master/generateStipaSignal.m).
2. Broadcast the STIPA test signal through the transmission channel and capture it.
3. Compute STI using [`stipa`](https://github.com/zawi01/stipa/blob/master/stipa.m).

A simple demonstration of the provided STIPA implementation is provided in [`demonstration.m`](https://github.com/zawi01/stipa/blob/master/demonstration.m) file.

### Generate STIPA test signal

The STIPA test signal can be generated using

```matlab
signal = generateStipaSignal(duration);
```
where `duration` specifies the duration of test signal in seconds. 

If no sampling frequency is specified, the default value of 96&nbsp;kHz is used.
To specify the sampling frequency, just call the function with the second parameter `fs` with the value of sampling frequency in Hz.
The minimum sampling frequency is 22,050&nbsp;Hz.

```matlab
signal = generateStipaSignal(duration, fs);
```

The generated test signal can be saved as audio file using the 
[`audiowrite`](https://www.mathworks.com/help/matlab/ref/audiowrite.html)
function, e.g.:

```matlab
audiowrite('./testSignal.wav', signal, fs);
```

### Compute STI

Since STIPA evaluates the quality of speech transmission system based on the modulation depths of the measured signal, only the vector of measured `signal` and its sampling frequency `fs` is required to compute the STI value:

```matlab
STI = stipa(signal, fs);
```

Note that the sampling frequency `fs` may differ from the sampling frequency of the generated STIPA test signal according to the recording device used.

Apart from the STI, the `stipa` function can also output the Modulation transfer ratios `mk`:

```matlab
[STI, mk] = stipa(signal, fs);
```

In special cases, the `stipa` function allows to input also `reference` signal and the Modulation Transfer values are computed as a ratio of `reference` and `signal` modulation depths:

```matlab
STI = stipa(signal, fs, reference);
```

and it is also possible to specify sampling frequency of reference signal `fsRef` if it differs from the sampling frequency of the measured `signal`:

```matlab
STI = stipa(signal, fs, reference, fsRef);
```

## Requirements

The code has been developed in MATLAB version R2022a. The implementation requires the following MATLAB toolboxes:
- Signal Processing Toolbox,
- Audio Toolbox.

## Verification tests
IEC-60286-16 revision 5 requires to verify STIPA implementations using the test signals described in Annexes A and C. 
Several test signals developed by Embedded Acoustics, along with the test signal description, are available at http://www.stipa.info/index.php/download-test-signals.

To verify the STIPA implementation in this repository, please follow these steps:
1. Download zip files with testing signals using the link above.
2. Unzip the folder with the testing signals into `verification` folder.
3. Run [`stipaVerificationTests.m`](https://github.com/zawi01/stipa/blob/master/stipaVerificationTests.m) script.

Note that the verification tests evaluates only 4 out of 5 tests available (Annex A.2.2, A.3.2.1, C.3.2, and C.4.2) since Annex C.3.3 aims at modulation depth testing of indirect method using impulse responses &ndash; STIPA(IR), which is not part of this implementation.

## License

The code of this toolbox is distributed under the terms of the [GNU General Public License 3](https://github.com/zawi01/stipa/blob/master/LICENSE).

---
Pavel Záviška, Brno University of Technology, 2023
