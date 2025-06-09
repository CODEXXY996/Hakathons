import json
import random

# Define the voltage and current ranges for each device
devices = {
    "AC": {"voltage_range": (220, 240), "current_range": (7, 10)},
    "TV": {"voltage_range": (110, 240), "current_range": (0.8, 1.5)},
    "Fridge": {"voltage_range": (220, 240), "current_range": (1.2, 2.0)},
    "Fan": {"voltage_range": (110, 240), "current_range": (0.4, 0.8)},
    "Light": {"voltage_range": (110, 120), "current_range": (0.2, 0.5)}
}

# Generate power readings
power_data = {}
for device, specs in devices.items():
    voltage = random.randint(*specs["voltage_range"])
    current = round(random.uniform(*specs["current_range"]), 2)
    power = round(voltage * current, 2)  # Power calculation in Watts
    
    power_data[device] = {
        "Voltage (V)": voltage,
        "Current (A)": current,
        "Power (W)": power
    }

# Save to JSON file
json_filename = "power_data.json"
with open(json_filename, "w") as json_file:
    json.dump(power_data, json_file, indent=4)

print(f"Power readings saved to {json_filename}")
