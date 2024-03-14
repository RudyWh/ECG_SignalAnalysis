%% Day 1 Analysis Work Flow for one lead (lead-2), all subjects

% Get filtered data
[filtered1,filtered2,filtered3] = FilterRawData(data);


% Define global variable
minProminence = 0.08;
minDistance = 230;
Rthresh = 0.8;
sampleRate = 2000;


% A-1: Find typical duration of heartbeat
disp("duration of heartbeat")
cycle1 = CardiacCycleFinder(filtered1,minProminence,minDistance,Rthresh,sampleRate);
cycle2 = CardiacCycleFinder(filtered2,minProminence,minDistance,Rthresh,sampleRate);
cycle3 = CardiacCycleFinder(filtered3,minProminence,minDistance,Rthresh,sampleRate);


% A-2: Find average BPM for each subject 
disp("mean BPM")
BPM1 = BPMFinder(filtered1,0.8,2000);
BPM2 = BPMFinder(filtered2,0.8,2000);
BPM3 = BPMFinder(filtered3,0.8,2000);


% A-3: Find instantaneous BPM for each subject
% We will need to check this with TAs, but let's say we want to find BPM of certain
% 30sec-period
disp("instantaneous BPM")
filtered_instant1 = filtered1(1:1+30*sampleRate,1);
BPM_instant1 = BPMFinder(filtered_instant1,0.8,2000);

filtered_instant2 = filtered2(1:1+30*sampleRate,1);
BPM = BPMFinder(filtered_instant2,0.8,2000);

hb_filtered_instant = filtered3(1:1+30*sampleRate,1);
hb_rangeBPM_instant = BPMFinder(hb_filtered_instant,0.8,2000);


% A-4: Find average QT time for eac subject
disp("QT interval")
hm_rangeQT = QTFinder(filtered1,minProminence,minDistance,Rthresh,sampleRate);
j_rangeQT = QTFinder(filtered2,minProminence,minDistance,Rthresh,sampleRate);
hb_rangeQT = QTFinder(filtered3,minProminence,minDistance,Rthresh,sampleRate);




