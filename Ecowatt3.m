clc;
clear;
close all;

% Define Thingspeak API parameters
channelID = 2859435; 
writeAPIKey = 'XHA7QTFOGABTLFSF'; 
url = sprintf('https://api.thingspeak.com/update?api_key=XHA7QTFOGABTLFSF&field1=0', writeAPIKey);

% Standard Power Ratings (in Volts)
devices = struct( ...
    'AC', struct('normal_voltage', 180), ...
    'TV', struct('normal_voltage', 113), ...
    'Fridge', struct('normal_voltage', 208), ...
    'Fan', struct('normal_voltage', 182), ...
    'Light', struct('normal_voltage', 163));

deviceNames = fieldnames(devices);
colors = lines(length(deviceNames));

% Time variables
t = 0;  % Initialize time
dt = 0.1; % Time step for updating the voltage (simulating real-time)
freq = 0.1; % Frequency of the sine wave
amplitude = 25; % Increase the amplitude for noticeable changes

% Create figure for real-time plotting
figure;
hold on;
grid on;
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Real-Time Sinusoidal Voltage Fluctuations');
legendEntries = gobjects(length(deviceNames), 1);
xlim([0, 20]); % Set fixed x-axis range
ylim([min(structfun(@(x) x.normal_voltage - amplitude, devices)), max(structfun(@(x) x.normal_voltage + amplitude, devices))]);

% Initialize empty plots for each device
for i = 1:length(deviceNames)
    legendEntries(i) = plot(nan, nan, 'Color', colors(i, :), 'LineWidth', 2, 'DisplayName', deviceNames{i});
end
legend(legendEntries, 'Location', 'best');

% Start real-time loop
while true
    t = t + dt; % Increment time
    for i = 1:length(deviceNames)
        device = deviceNames{i};
        normalVoltage = devices.(device).normal_voltage;

        % Generate continuously changing sinusoidal voltage with randomness
        voltage = normalVoltage + amplitude * sin(2 * pi * freq * t + i) + randi([-5, 5]);

        % Determine device status
        if voltage < normalVoltage - 15
            status = 'Low Power!';
        elseif voltage > normalVoltage + 15
            status = 'Overload!';
        else
            status = 'Normal';
        end

        % Display device voltage and status
        fprintf('%s: Voltage = %.2fV -> %s\n', device, voltage, status);

        % Update plot
        xData = get(legendEntries(i), 'XData');
        yData = get(legendEntries(i), 'YData');
        set(legendEntries(i), 'XData', [xData, t], 'YData', [yData, voltage]);

        % Upload Data to ThingSpeak
        try
            response = webwrite(url, 'field1', voltage);
        catch
            warning('Failed to upload data to ThingSpeak. Check your internet connection and API key.');
        end
    end

    % Pause for visualization
    pause(0.1);

    % Keep only recent data for display
    if t > 20
        for i = 1:length(deviceNames)
            xData = get(legendEntries(i), 'XData');
            yData = get(legendEntries(i), 'YData');
            set(legendEntries(i), 'XData', xData(xData > t - 20), 'YData', yData(xData > t - 20));
        end
    end
end
