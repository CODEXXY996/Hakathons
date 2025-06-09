clc;
clear;
close all;

% Define Log File Name
logFile = 'power_log.txt';

% Standard Power Ratings (Watts)
devices = struct( ...
    'AC', struct('voltage_range', [220, 240], 'current_range', [7, 10], 'normal_rating', 2000), ...
    'TV', struct('voltage_range', [110, 240], 'current_range', [0.8, 1.5], 'normal_rating', 300), ...
    'Fridge', struct('voltage_range', [220, 240], 'current_range', [1.2, 2.0], 'normal_rating', 150), ...
    'Fan', struct('voltage_range', [110, 240], 'current_range', [0.4, 0.8], 'normal_rating', 75), ...
    'Light', struct('voltage_range', [110, 120], 'current_range', [0.2, 0.5], 'normal_rating', 40) ...
);

% Electricity Rate in India (₹ per kWh)
electricityRate = 6; % ₹6 per kWh

% ThingSpeak Credentials
channelID = 2859435;  
writeAPIKey = 'XHA7QTFOGABTLFSF';  

% Infinite Loop for Continuous Monitoring
while true
    rng('shuffle'); 
    deviceNames = fieldnames(devices);
    powerValues = zeros(length(deviceNames), 1); 
    
    % Open log file
    logFileID = fopen(logFile, 'a');
    fprintf(logFileID, "\n%s\n", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(logFileID, "----------------------------------\n");
    
    % Store data for ThingSpeak
    thingSpeakData = struct();
    
    figure(1); clf;
    numDevices = length(deviceNames);
    t = tiledlayout(ceil(numDevices / 2), 2, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    
    for i = 1:numDevices
        device = deviceNames{i};
        voltage = randi(devices.(device).voltage_range); % Random voltage within range
        current = rand() * diff(devices.(device).current_range) + devices.(device).current_range(1);
        power = voltage * current;
        
        % Store power usage
        devices.(device).usage = power;
        powerValues(i) = power;
        
        % Determine power status
        if power > 1.2 * devices.(device).normal_rating
            devices.(device).status = "Overload";
            gaugeColor = 'r'; % Red for overload
        elseif power < 0.8 * devices.(device).normal_rating
            devices.(device).status = "Underpowered";
            gaugeColor = 'b'; % Blue for underpowered
        else
            devices.(device).status = "Normal";
            gaugeColor = 'g'; % Green for normal
        end
        
        % Log Data
        fprintf(logFileID, "%-10s %-15.2f %-10s\n", device, power, devices.(device).status);
        thingSpeakData.(sprintf('field%d', i)) = power;
        
        % Car-Like Gauge Visualization
        nexttile;
        theta = linspace(0, pi, 100);
        r = ones(size(theta));
        [x, y] = pol2cart(theta, r * 0.8);
        [x2, y2] = pol2cart(theta, r * 1.2);
        fill([x fliplr(x2)], [y fliplr(y2)], gaugeColor, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        hold on;
        
        % Needle position based on power usage
        needleAngle = pi * (power / (1.5 * devices.(device).normal_rating));
        [xNeedle, yNeedle] = pol2cart([0 needleAngle], [0 1]);
        plot(xNeedle, yNeedle, 'k', 'LineWidth', 4);
        title(sprintf('%s: %.2fW', device, power));
        
        axis equal;
        xlim([-1.2, 1.2]);
        ylim([0, 1.2]);
        set(gca, 'XColor', 'none', 'YColor', 'none');
    end
    fclose(logFileID);
    
    % Identify most and least power-consuming devices
    [maxPower, maxIndex] = max(powerValues);
    [minPower, minIndex] = min(powerValues);
    mostPowerHungry = deviceNames{maxIndex};
    leastPowerConsuming = deviceNames{minIndex};
    
    % Calculate cost savings if most power-hungry device is turned off
    hoursPerDay = 5; % Assume the device runs 5 hours daily
    energySaved_kWh = (maxPower * hoursPerDay) / 1000; % Convert W to kWh
    costSaved = energySaved_kWh * electricityRate; % Cost in INR
    
    % Bar Graph Representation
    figure(2); clf;
    bar(powerValues, 'FaceColor', 'flat');
    colormap(jet(numDevices));
    xticks(1:numDevices);
    xticklabels(deviceNames);
    ylabel('Power Usage (W)');
    title('Power Consumption by Device');
    grid on;
    
    % Send Data to ThingSpeak
    try
        disp('Sending data to ThingSpeak...');
        response = webwrite('https://api.thingspeak.com/update.json', 'api_key', writeAPIKey, thingSpeakData);
        disp(['ThingSpeak Response: ', num2str(response)]);
    catch ME
        warning("ThingSpeak upload failed: %s", ME.message);
    end
    
    % Display Power Readings
    clc;
    disp("Power Readings:");
    fprintf("%-10s %-15s %-10s\n", "Device", "Usage (W)", "Status");
    for i = 1:numDevices
        device = deviceNames{i};
        fprintf("%-10s %-15.2f %-10s\n", device, devices.(device).usage, devices.(device).status);
    end
    
    % Display Power Analysis & Cost Saving Suggestion
    fprintf("\nMost Power-Hungry Device: %s (%.2fW)\n", mostPowerHungry, maxPower);
    fprintf("Least Power-Consuming Device: %s (%.2fW)\n", leastPowerConsuming, minPower);
    fprintf("\n Recommendation: Turn off the %s to save ₹%.2f per day!\n", mostPowerHungry, costSaved);
    
    % Write analysis to log file
    logFileID = fopen(logFile, 'a');
    fprintf(logFileID, "\nMost Power-Hungry Device: %s (%.2fW)\n", mostPowerHungry, maxPower);
    fprintf(logFileID, "Least Power-Consuming Device: %s (%.2fW)\n", leastPowerConsuming, minPower);
    fprintf(logFileID, "\nRecommendation: Turn off the %s to save ₹%.2f per day!\n", mostPowerHungry, costSaved);
    fclose(logFileID);
    
    % Increase Pause to Avoid ThingSpeak Rate Limit
    pause(20);
end
