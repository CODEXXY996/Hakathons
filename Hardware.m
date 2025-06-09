clc; clear; close all;

% PCB Dimensions (in mm)
pcb_width = 80;
pcb_height = 50;

% Mounting hole positions (each row is [x, y])
hole_positions = [5, 5; 75, 5; 5, 45; 75, 45]; % (x, y) in mm
hole_diameter = 3; % 3mm diameter

% Component positions (approximate)
components = { 
    'NodeMCU (ESP8266/ESP32)', 40, 25;
    'ZMPT101B Voltage Sensor', 15, 15;
    'ACS712 Current Sensor', 65, 15;
    'Relay Module', 40, 40;
    'OLED Display (SSD1306)', 40, 10;
    'Power Supply Module', 65, 35;
    'Fuse & MOV', 15, 35;
};

% Create figure
figure;
hold on;
axis([0 pcb_width 0 pcb_height]);
xlabel('Width (mm)');
ylabel('Height (mm)');
title('EcoWatt PCB Layout with Dimensions (in mm)');
grid on;

% Draw PCB outline
plot([0 pcb_width pcb_width 0 0], [0 0 pcb_height pcb_height 0], 'k-', 'LineWidth', 2);

% Draw mounting holes
for i = 1:size(hole_positions, 1)
    x = hole_positions(i, 1);
    y = hole_positions(i, 2);
    viscircles([x, y], hole_diameter/2, 'EdgeColor', 'r', 'LineWidth', 2);
end

% Draw component placements
for i = 1:size(components, 1)
    comp_name = components{i, 1};
    x = components{i, 2};
    y = components{i, 3};
    
    % Plot component position
    plot(x, y, 'bo', 'MarkerSize', 8, 'LineWidth', 2);
    
    % Display component name
    text(x + 2, y, comp_name, 'FontSize', 9, 'Color', 'blue', 'VerticalAlignment', 'middle');
end

hold off;
