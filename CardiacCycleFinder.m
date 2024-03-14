function vals = CardiacCycleFinder(filteredSignal,minProminence,minDistance,Rthresh,sampleRate)
% finds the avg duration of cardiac cycle
% minProminence = 0.08 seems to work
% minDistance = 230 seems to work
% use Rthresh = 0.75

    % First find all peaks (P, R, and T waves)
    [pks, locs] = findpeaks(filteredSignal,"MinPeakProminence",minProminence,"MinPeakDistance",minDistance);
    
    % initialize vectors to store peak info
    Rwaves = zeros(length(locs),2); % column 1 = pks1 values & column 2 = locs1 values
    Pwaves = zeros(1,2);
    Twaves = zeros(1,2);
    
    % initialize counter
    counter = 1;
    
    % assign peaks as P, R, and T waves
    for i = 2:length(locs)-1 % for every peak
        if pks(i) >= Rthresh % if the peak is an R wave
            Rwaves(counter,1) = pks(i);
            Rwaves(counter,2) = locs(i); 
            Pwaves(counter,1) = pks(i-1); % the peak before it is a P wave
            Pwaves(counter,2) = locs(i-1);
            Twaves(counter,1) = pks(i+1); % the peak after it is a T wave
            Twaves(counter,2) = locs(i+1);
            counter = counter + 1;
        end
    end

    baseline = -0.05; 

    % initialize vectors to store start of P and end of T
    Pstart = zeros(length(Pwaves(:,1)),2);
    Tend = zeros(length(Twaves(:,1)),2);
    
    for i = 2:length(Pwaves(:,1)) % for each P wave
        index = Pwaves(i,2);
        currentval = filteredSignal(index);
        while currentval > baseline % inspect preceding values until we hit baseline (then we call it start of P wave)
            index = index - 1;
            currentval = filteredSignal(index);
        end
        Pstart(i,1) = currentval;
        Pstart(i,2) = index;
    end
    
    for i = 1:length(Twaves(:,1))-1 % for each T wave
        index = Twaves(i,2);
        currentval = filteredSignal(index);
        while currentval > baseline % inspect following values until we hit baseline (then we call it end of T wave)
            index = index + 1;
            currentval = filteredSignal(index);
        end
        Tend(i,1) = currentval;
        Tend(i,2) = index;
    end
    
    
    % Finding Duration of Cardiac Cycle
    PstartLocs = Pstart(1:end-1,2);
    TendLocs = Tend(1:end-1,2);
    durations = (TendLocs - PstartLocs)/sampleRate; % duration in seconds, accounting for 2000 Hz sample rate
    average_duration = mean(durations);
    sd_duration = std(durations);
    vals = [average_duration, sd_duration];
    
end