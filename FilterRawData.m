function [filtered1,filtered2,filtered3] = FilterRawData(data)
% raw data for each subject
subject1 = data(:,1);
subject2 = data(:,2);
subject3 = data(:,3);

% subtract mean signal
subject1 = subject1 - mean(subject1);
subject2 = subject2 - mean(subject2);
subject3 = subject3 - mean(subject3);

% apply fft
fft1 = fft(subject1);
fft2 = fft(subject2);
fft3 = fft(subject3);

% calculate power
power1 = (abs(fft1)).^2;
power2 = (abs(fft2)).^2;
power2 = (abs(fft3)).^2;

fs = 2000; % sampling rate (Hz)

% bandpass filter from 0.8 to 40 Hz
d = designfilt("bandpassiir",FilterOrder=14, ...
    HalfPowerFrequency1=0.8,HalfPowerFrequency2=40, ...
    SampleRate=fs);

% filtered data
filtered1 = filtfilt(d, subject1);
filtered2 = filtfilt(d,subject2);
filtered3 = filtfilt(d,subject3);


num = 15;
step = 10000;
start_s = 100+num*step;
end_s = 10000+ num*step;
plot(filtered3,'k')
ylim([-3 3])
% hold on 
% plot(hm(start_s:end_s),'r')

finish = 1

end