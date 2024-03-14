function rangeBPM = BPMFinder(filteredSignal,Rthresh,sampleRate)
% given a filtered ECG signal, R wave threshold, and sample rate, calculate
% average BPM +/- sd

% finding R wave peaks
[~, locs] = findpeaks(filteredSignal,'MinPeakHeight',Rthresh);

% find number of points between R waves
durations = zeros(length(locs)-1,1);
for i = 1:length(locs)-1
    durations(i) = locs(i+1) - locs(i);
end

% convert durations to seconds 
durations = durations/sampleRate;

% average duration with uncertainty
avgDuration = mean(durations);
sdDuration = std(durations); 
upperDuration1 = avgDuration + sdDuration;
lowerDuration1 = avgDuration - sdDuration;

% find bpm
upperBPM = 60/lowerDuration1;
lowerBPM = 60/upperDuration1;
avgBPM = (upperBPM+lowerBPM)/2;
sdBPM = upperBPM - avgBPM;
rangeBPM = [avgBPM,sdBPM];
% samples = length(durations)
end