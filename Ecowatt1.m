clc;
clear;
close all;

%Define JSON File Name

jsonFile = 'power_data.json';

%Standard Power Ratings (Watts)
devices = struct( ...
    'AC', struct('normal_rating', 2000), ...
    'TV', struct('normal_rating', 300), ...
    'Fridge', struct('normal_rating', 150), ...
    'Fan', struct('normal_rating', 75), ...
    'Light', struct('normal_rating', 40));

%ThingSpeak Credentials
channelID = 2859435;  
% Replace with your ThingSpeak channel ID
%Replace with your API key
writeAPIKey = 'XHA7QTFOGABTLFSF';  
% Infinite Loop for Continuous Monitoring
while true
    % Generate Random Voltages (between 110V - 240V)
    rng('shuffle'); % Ensures different random values each run
    data = struct( ...
        'AC', struct('voltage', randi([110, 240]), 'current', 9.5), ...
        'TV', struct('voltage', randi([110, 240]), 'current', 1.2), ...
        'Fridge', struct('voltage', randi([110, 240]), 'current', 1.5), ...
        'Fan', struct('voltage', randi([110, 240]), 'current', 0.6), ...
        'Light', struct('voltage', randi([110, 240]), 'current', 0.3));

    % Write Updated Data to JSON File
    jsonText = jsonencode(data);
    fid = fopen(jsonFile, 'w');
    fprintf(fid, jsonText);
    fclose(fid);
    
    % Read JSON File
    jsonText = fileread(jsonFile);
    data = jsondecode(jsonText);
    
    % Compute Power Usage (P = V × I)
    deviceNames = fieldnames(data);
    powerValues = zeros(length(deviceNames), 1); % Store power values
    
    % Open log file
    logFile = fopen('power_log.txt', 'a');

    % Print Header
    fprintf(logFile, "\n%s\n", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(logFile, "----------------------------------\n");

    % Store data for ThingSpeak
    thingSpeakData = struct();

    for i = 1:length(deviceNames)
        device = deviceNames{i};
        voltage = data.(device).voltage;
        current = data.(device).current;
        power = voltage * current;
        
        devices.(device).usage = power;
        powerValues(i) = power;

        % Check for Overload
        if power > devices.(device).normal_rating
            devices.(device).status = "Overload";
        else
            devices.(device).status = "Normal";
        end

        % Log Data
        fprintf(logFile, "%-10s %-15.2f %-10s\n", device, power, devices.(device).status);
        
        % Store for ThingSpeak
        thingSpeakData.(sprintf('field%d', i)) = power;
    end

    % Identify the Most Power-Hungry Device
    [~, idx] = max(powerValues);
    most_power_hungry = deviceNames{idx};

    % Log the most power-hungry device
    fprintf(logFile, "Most Power-Hungry Device: %s\n", most_power_hungry);
    fclose(logFile);

    % Send Data to ThingSpeak
    try
        response = webwrite('https://api.thingspeak.com/update.json', ...
                            'api_key', writeAPIKey, ...
                            thingSpeakData);
    catch ME
        warning("ThingSpeak upload failed: %s", ME.message);
    end

    % Display Power Readings
    clc; % Clear console for updated values
    disp("Power Readings:");
    fprintf("%-10s %-15s %-10s\n", "Device", "Usage (W)", "Status");

    for i = 1:length(deviceNames)
        device = deviceNames{i};
        usage = devices.(device).usage;
        status = devices.(device).status;
        fprintf("%-10s %-15.2f %-10s\n", device, usage, status);
    end

    % Display Most Power-Hungry Device
    fprintf("\nMost Power-Hungry Device: %s\n", most_power_hungry);

    % Pause before next update (adjust interval as needed)
    pause(10); % Updates every 10 seconds (change if needed)
end
