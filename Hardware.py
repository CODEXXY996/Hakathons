import matplotlib.pyplot as plt
import numpy as np

# PCB Dimensions (in mm)
pcb_width = 80
pcb_height = 50

# Mounting hole positions
hole_positions = [(5, 5), (75, 5), (5, 45), (75, 45)]  # (x, y) in mm
hole_diameter = 3  # 3mm diameter

# Component positions (approximate)
components = {
    "NodeMCU (ESP8266/ESP32)": (40, 25),
    "ZMPT101B Voltage Sensor": (15, 15),
    "ACS712 Current Sensor": (65, 15),
    "Relay Module": (40, 40),
    "OLED Display (SSD1306)": (40, 10),
    "Power Supply Module": (65, 35),
    "Fuse & MOV": (15, 35),
}

# Create the figure
fig, ax = plt.subplots(figsize=(8, 5))
ax.set_xlim(0, pcb_width)
ax.set_ylim(0, pcb_height)

# Draw PCB outline
ax.plot([0, pcb_width, pcb_width, 0, 0], [0, 0, pcb_height, pcb_height, 0], 'k-', lw=2, label="PCB Outline")

# Draw mounting holes
for x, y in hole_positions:
    hole = plt.Circle((x, y), hole_diameter/2, color='r', fill=False, lw=2, label="Mounting Hole" if hole_positions.index((x,y)) == 0 else "")
    ax.add_patch(hole)

# Draw component placements
for comp, (x, y) in components.items():
    ax.plot(x, y, 'bo', markersize=8, label=comp if list(components.keys()).index(comp) == 0 else "")
    ax.text(x + 2, y, comp, fontsize=9, verticalalignment='center', color='blue')

# Labels and grid
ax.set_title("EcoWatt PCB Layout with Dimensions (in mm)", fontsize=12, fontweight='bold')
ax.set_xlabel("Width (mm)")
ax.set_ylabel("Height (mm)")
ax.legend(loc="upper right", fontsize=8)
ax.grid(True, linestyle="--", alpha=0.6)

# Save the schematic
pcb_schematic_path = "/mnt/data/EcoWatt_PCB_Schematic.png"
plt.savefig(pcb_schematic_path, dpi=300, bbox_inches='tight')

# Show the figure
plt.show()

# Provide the file path
pcb_schematic_path
