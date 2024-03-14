%% ECG Time Domain Signal Analysis
filteredSignal = filtered1;

%% find QRS complexes
[pks1, locs1] = findpeaks(filteredSignal,'MinPeakHeight',0.8);
figure(1)
hold on
plot(filteredSignal);
scatter(locs1,pks1);
hold off

% find time btwn QRS complexes (time btwn beats)
durations1 = zeros(length(locs1)-1,1);
for i = 1:length(locs1)-1
    durations1(i) = locs1(i+1) - locs1(i);
end

% convert durations to seconds 
sampleRate = 2000; % Hz
durations1 = durations1/sampleRate;

% average duration with uncertainty
avgDuration1 = mean(durations1);
sdDuration1 = std(durations1); 
upperDuration1 = avgDuration1 + sdDuration1;
lowerDuration1 = avgDuration1 - sdDuration1;

% find bpm
upperBPM1 = 60/lowerDuration1;
lowerBPM1 = 60/upperDuration1;
rangeBPM1 = [upperBPM1,lowerBPM1];
avgBPM11 = mean(rangeBPM1);
uncertBPM1 = upperBPM1 - avgBPM11;

% another bpm approach
numBeats1 = length(locs1);
totalDuration1 = 500/60; % in minutes
avgBPM12 = numBeats1/totalDuration1;


%% Find All Peaks
[pks1, locs1] = findpeaks(filteredSignal,"MinPeakProminence",0.08, "MinPeakDistance",230);

Rwaves = zeros(length(locs1),2); % column 1 = pks1 values & column 2 = locs1 values
Pwaves = zeros(1,2);
Twaves = zeros(1,2);
counter = 1;

for i = 2:length(locs1)-1
    if pks1(i)>=0.75 % if the peak is a QRS complex
        Rwaves(counter,1) = pks1(i); % store the peak value
        Rwaves(counter,2) = locs1(i); 
        Pwaves(counter,1) = pks1(i-1);
        Pwaves(counter,2) = locs1(i-1);
        Twaves(counter,1) = pks1(i+1);
        Twaves(counter,2) = locs1(i+1);
        counter = counter + 1;
    end
end

figure()
hold on
plot(filteredSignal)
scatter(Rwaves(:,2),Rwaves(:,1),'c','filled')
scatter(Pwaves(:,2),Pwaves(:,1),'r','filled')
scatter(Twaves(:,2),Twaves(:,1),'g','filled')
legend("Filtered Signal", "R peaks", 'P peaks', 'T peaks')

%% Finding beginning of P wave and end of T wave
Pstart = zeros(length(Pwaves(:,1)),2);
Tend = zeros(length(Twaves(:,1)),2);
baseline = -0.05;
for i = 2:length(Pwaves(:,1)) % for each P wave
    index = Pwaves(i,2);
    currentval = filteredSignal(index);
    while currentval > baseline
        index = index - 1;
        currentval = filteredSignal(index);
    end
    Pstart(i,1) = currentval;
    Pstart(i,2) = index;
end

for i = 1:length(Twaves(:,1))-1 % for each T wave
    index = Twaves(i,2);
    disp(index)
    currentval = filteredSignal(index);
    while currentval > baseline
        index = index + 1;
        currentval = filteredSignal(index);
    end
    Tend(i,1) = currentval;
    Tend(i,2) = index;
end

figure()
hold on
plot(filteredSignal)
scatter(Tend(:,2),Tend(:,1),'r','filled')
scatter(Pstart(:,2),Pstart(:,1),'g','filled')

%% Finding Duration of Cardiac Cycle
% duration = end of T - begining of P
PstartLocs = Pstart(1:end-1,2);
TendLocs = Tend(1:end-1,2);
durations = (TendLocs - PstartLocs)/2000; % duration in seconds, accounting for 2000 Hz sample rate
average_duration = mean(durations);
sd_duration = std(durations);
upper_duration = average_duration + sd_duration;
lower_duration = average_duration - sd_duration;


%% Finding Q waves
Qwaves = zeros(1,2);
counter = 1;
for i = 1:length(Rwaves)
    Rlocation = Rwaves(i,2);
    if Rlocation ~= 0
        lowIndex = Rlocation - 500;
        [Qval, Qloc] = min(filteredSignal(lowIndex:Rlocation)); % this gives the index within the 501 point window
        Qwaves(counter,2) = Rlocation - (500-Qloc); % this gives the index within the entire signal
        Qwaves(counter,1) = Qval;
        counter = counter + 1;
    end
end

%% Find Start of Q Waves
Qstart = zeros(length(Pwaves(:,1)),2);
counter = 1;
for i = 2:length(Qwaves(:,1)) % for each Q wave
    index = Qwaves(i,2);
    currentval = filteredSignal(index);
    while currentval < baseline % scan backwards until we hit baseline (then call it start of Q wave)
        index = index - 1; 
        currentval = filteredSignal(index);
    end
    Qstart(i,1) = currentval;
    Qstart(i,2) = index;
end

QstartLocs = Qstart(1:end-1,2);
QTints = (TendLocs - QstartLocs)/sampleRate;
avgQT = mean(QTints);
sdQT = std(QTints);
upperQT = avgQT+sdQT;
lowerQT = avgQT-sdQT;
QTrange = [lowerQT,upperQT];

% to check if we've got the Q peaks
% figure()
% plot(filteredSignal)
% hold on
% scatter(Qwaves(:,2),Qwaves(:,1),'r','filled')
% scatter(Qstart(:,2),Qstart(:,1),'g','filled')

%% Convert sample number to time in seconds
xaxis_points = zeros(length(filteredSignal),1);
for i = 1:length(filteredSignal)
    xaxis_points(i) = i;
end
xaxis_time = xaxis_points/sampleRate;

%% Plot all identified peaks for subject 1
figure()
plot(xaxis_time,filteredSignal,'k')
hold on
scatter(Rwaves(:,2)/sampleRate,Rwaves(:,1),'b','filled')
scatter(Pwaves(:,2)/sampleRate,Pwaves(:,1),'r','filled')
scatter(Twaves(:,2)/sampleRate,Twaves(:,1),'g','filled')
scatter(Qwaves(:,2)/sampleRate,Qwaves(:,1),'m','filled')
legend('Filtered Signal', 'R peaks', 'P peaks', 'T peaks','Q peaks')
title("Subject 1")
ylabel("ECG signal [mV]")
xlabel("Time [s]")

%% Plot beginning and end of cardiac cycle
figure()
plot(xaxis_time,filteredSignal,'k')
hold on
scatter(Pstart(:,2)/sampleRate,Pstart(:,1),'b','filled')
scatter(Tend(:,2)/sampleRate,Tend(:,1),'r','filled')
legend('Filtered Signal', 'Start of P Wave', 'End of T Wave')
title("Subject 1")
ylabel("ECG signal [mV]")
xlabel("Time [s]")

%% Plot beginning and end of QT interval
figure()
plot(xaxis_time,filteredSignal,'k')
hold on
scatter(Qstart(:,2)/sampleRate,Qstart(:,1),'g','filled')
scatter(Tend(:,2)/sampleRate,Tend(:,1),'m','filled')
legend('Filtered Signal', 'Start of Q Wave', 'End of T Wave')
title("Subject 1")
ylabel("ECG signal [mV]")
xlabel("Time [s]")