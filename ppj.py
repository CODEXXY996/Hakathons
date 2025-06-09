import json
import random

# 🔹 Define Electronic Devices & Their Voltage/Current Ranges
devices = {
    "AC": {"voltage_range": (210, 240), "current_range": (8, 12)},
    "TV": {"voltage_range": (220, 240), "current_range": (0.8, 2)},
    "Fridge": {"voltage_range": (210, 230), "current_range": (0.5, 1.5)},
    "Fan": {"voltage_range": (200, 230), "current_range": (0.3, 1)},
    "Light": {"voltage_range": (100, 120), "current_range": (0.1, 0.5)}
}

# 🔹 Generate Random Power Readings
power_data = {}
for device, ranges in devices.items():
    voltage = round(random.uniform(*ranges["voltage_range"]), 2)
    current = round(random.uniform(*ranges["current_range"]), 2)
    power_data[device] = {"voltage": voltage, "current": current}

# 🔹 Save as JSON File
with open("power_data.json", "w") as json_file:
    json.dump(power_data, json_file, indent=4)

print("✅ Random Power Data Saved to 'power_data.json'")
