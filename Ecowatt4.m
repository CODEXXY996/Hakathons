clc;
clear;
close all;

% Define JSON File Name
jsonFile = 'power_data.json';

% Standard Power Ratings (Watts)
devices = struct(
    'AC', struct('normal_rating', 2000), ...
    'TV', struct('normal_rating', 300), ...
    'Fridge', struct('normal_rating', 150), ...
    'Fan', struct('normal_rating', 75), ...
    'Light', struct('normal_rating', 40));

% ThingSpeak Credentials
channelID = 2859435;
writeAPIKey = 'XHA7QTFOGABTLFSF';

% Time settings for sine wave plot
t = linspace(0, 2 * pi, 100);
figure;
hold on;

time_values = 0:0.1:10; % Time axis for plotting

while true
    % Generate Random Voltages (between 110V - 240V)
    rng('shuffle');
    data = struct( ...
    'AC', struct('voltage', randi([110, 240]), 'current', 9.5), ...
    'TV', struct('voltage', randi([110, 240]), 'current', 1.2), ...
    'Fridge', struct('voltage', randi([110, 240]), 'current', 1.5), ...
    'Fan', struct('voltage', randi([110, 240]), 'current', 0.6), ...
    'Light', struct('voltage', randi([110, 240]), 'current', 0.3) ...
);


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
    powerValues = zeros(length(deviceNames), 1);
    
    % Open log file
    logFile = fopen('power_log.txt', 'a');
    fprintf(logFile, "\n%s\n", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(logFile, "----------------------------------\n");
    
    % Store data for ThingSpeak
    thingSpeakData = struct();
    
    clf;
    hold on;
    
    for i = 1:length(deviceNames)
        device = deviceNames{i};
        voltage = data.(device).voltage;
        current = data.(device).current;
        power = voltage * current;
        
        devices.(device).usage = power;
        powerValues(i) = power;
        
        % Determine power status
        if power > devices.(device).normal_rating
            devices.(device).status = "Overload";
            plot(t, sin(t) * 20 + i * 50, 'r', 'LineWidth', 2); % Red sine wave for overload
        elseif power < 0.9 * devices.(device).normal_rating
            devices.(device).status = "Underpowered";
            plot(t, sin(t) * 20 + i * 50, 'b', 'LineWidth', 2); % Blue sine wave for underpowered
        else
            devices.(device).status = "Normal";
            plot(t, ones(size(t)) * (i * 50), 'g', 'LineWidth', 2); % Green constant line for normal
        end
        
        % Log Data
        fprintf(logFile, "%-10s %-15.2f %-10s\n", device, power, devices.(device).status);
        
        % Store for ThingSpeak
        thingSpeakData.(sprintf('field%d', i)) = power;
    end
    
    % Identify the Most Power-Hungry Device
    [~, idx] = max(powerValues);
    most_power_hungry = deviceNames{idx};
    fprintf(logFile, "Most Power-Hungry Device: %s\n", most_power_hungry);
    fclose(logFile);
    
    % Send Data to ThingSpeak
    try
        response = webwrite('https://api.thingspeak.com/update.json', 'api_key', writeAPIKey, thingSpeakData);
    catch ME
        warning("ThingSpeak upload failed: %s", ME.message);
    end
    
    % Display Power Readings
    clc;
    disp("Power Readings:");
    fprintf("%-10s %-15s %-10s\n", "Device", "Usage (W)", "Status");
    for i = 1:length(deviceNames)
        device = deviceNames{i};
        fprintf("%-10s %-15.2f %-10s\n", device, devices.(device).usage, devices.(device).status);
    end
    
    % Display Most Power-Hungry Device
    fprintf("\nMost Power-Hungry Device: %s\n", most_power_hungry);
    
    % Pause before next update
    pause(10);
end
