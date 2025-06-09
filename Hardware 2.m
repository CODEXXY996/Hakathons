clc; 
clear all ; 
close all;

% Define component positions (x, y) in mm
components = struct( ...
    'RelayModule', [50, 40], ...
    'PowerSupply', [70, 40], ...
    'FuseMOV', [20, 35], ...
    'NodeMCU', [40, 25], ...
    'VoltageSensor', [30, 15], ...
    'OLEDDisplay', [45, 10], ...
    'CurrentSensor', [70, 10] ...
);

% Define wire connections (pairs of components)
connections = { ...
    'PowerSupply', 'NodeMCU'; ...
    'NodeMCU', 'RelayModule'; ...
    'NodeMCU', 'VoltageSensor'; ...
    'VoltageSensor', 'CurrentSensor'; ...
    'NodeMCU', 'OLEDDisplay'; ...
    'FuseMOV', 'NodeMCU' ...
};

% Plot PCB Layout
figure; hold on;
title('EcoWatt PCB Layout with Connections (in mm)');
xlabel('Width (mm)');
ylabel('Height (mm)');
xlim([0 80]); ylim([0 50]);
grid on;
axis equal;
set(gca, 'XColor', 'k', 'YColor', 'k', 'LineWidth', 2);

% Draw PCB boundary
rectangle('Position', [0, 0, 80, 50], 'EdgeColor', 'k', 'LineWidth', 2);

% Plot components
fields = fieldnames(components);
for i = 1:numel(fields)
    pos = components.(fields{i});
    plot(pos(1), pos(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
    text(pos(1) + 2, pos(2), fields{i}, 'Color', 'b', 'FontSize', 10);
end

% Draw wire connections
for i = 1:size(connections, 1)
    comp1 = components.(connections{i, 1});
    comp2 = components.(connections{i, 2});
    plot([comp1(1), comp2(1)], [comp1(2), comp2(2)], 'r-', 'LineWidth', 2);
end

hold off;
