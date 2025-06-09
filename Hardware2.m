
clc; clear; close all;

% Define PCB dimensions
pcb_width = 80;  % mm
pcb_height = 50; % mm

% Define component positions (x, y)
components = struct(...
    'NodeMCU', [40, 25], ...
    'Relay', [50, 40], ...
    'PowerSupply', [70, 40], ...
    'FuseMOV', [20, 30], ...
    'VoltageSensor', [30, 15], ...
    'CurrentSensor', [70, 10], ...
    'OLEDDisplay', [50, 10]);

% Define wire connections (from -> to)
connections = {...
    'NodeMCU', 'Relay'; ...
    'NodeMCU', 'PowerSupply'; ...
    'NodeMCU', 'FuseMOV'; ...
    'NodeMCU', 'VoltageSensor'; ...
    'NodeMCU', 'OLEDDisplay'; ...
    'OLEDDisplay', 'CurrentSensor'};

% Open figure
figure;
hold on;
axis equal;
grid on;
xlim([0 pcb_width]);
ylim([0 pcb_height]);
xlabel('Width (mm)');
ylabel('Height (mm)');
title('EcoWatt PCB Design');

% Draw PCB board boundary
rectangle('Position', [0, 0, pcb_width, pcb_height], 'EdgeColor', 'k', 'LineWidth', 2);

% Draw components as circles with labels
fields = fieldnames(components);
for i = 1:numel(fields)
    pos = components.(fields{i});
    plot(pos(1), pos(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
    text(pos(1) + 2, pos(2), fields{i}, 'Color', 'blue', 'FontSize', 10);
end

% Draw wire connections (traces) as red lines
for i = 1:size(connections, 1)
    pos1 = components.(connections{i, 1});
    pos2 = components.(connections{i, 2});
    
    % Create right-angle routing for better clarity
    mid_x = pos1(1); % Midpoint for right-angle trace
    line([pos1(1), mid_x], [pos1(2), pos2(2)], 'Color', 'r', 'LineWidth', 2);
    line([mid_x, pos2(1)], [pos2(2), pos2(2)], 'Color', 'r', 'LineWidth', 2);
end

% Finalize
box on;
hold off;

% Export as DXF (for PCB fabrication)
filename = 'EcoWatt_PCB.dxf';
fprintf('Exporting PCB design to DXF file: %s\n', filename);
