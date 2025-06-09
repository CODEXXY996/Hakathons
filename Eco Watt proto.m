clc;
clear;
close all;

% Read JSON File
jsonText = fileread('proto json'); % Ensure correct filename
data = jsondecode(jsonText);

% Standard Power Ratings (Watts)
devices = struct( ...
    'AC', struct('normal_rating', 2000), ...
    'TV', struct('normal_rating', 300), ...
    'Fridge', struct('normal_rating', 150), ...
    'Fan', struct('normal_rating', 75), ...
    'Light', struct('normal_rating', 40));

% Compute Power Usage (P = V × I)
deviceNames = fieldnames(data);
powerValues = zeros(length(deviceNames), 1); % Array to store power values

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
end

% Identify the Most Power-Hungry Device
[~, idx] = max(powerValues);
most_power_hungry = deviceNames{idx};

% Display Results
disp("Power Readings:");
disp(struct2table(devices));
fprintf("\nMost Power-Hungry Device: %s\n", most_power_hungry);
