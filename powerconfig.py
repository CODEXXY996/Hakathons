import json
import random

# Define the devices with corrected voltage ranges
devices = {
    "AC": {"voltage_range": (220, 240), "current_range": (7, 10)},
    "TV": {"voltage_range": (110, 240), "current_range": (0.8, 1.5)},
    "Fridge": {"voltage_range": (220, 240), "current_range": (1.2, 2.0)},
    "Fan": {"voltage_range": (110, 240), "current_range": (0.4, 0.8)},
    "Light": {"voltage_range": (110, 120), "current_range": (0.2, 0.5)}
}

# Generate power data
power_data = {}
for device, ranges in devices.items():
    voltage = random.randint(*ranges["voltage_range"])
    current = round(random.uniform(*ranges["current_range"]), 2)
    power_data[device] = {"voltage": voltage, "current": current}

# Save the data to a JSON file
json_file = "power_data.json"
with open(json_file, "w") as file:
    json.dump(power_data, file, indent=4)

print(f"Power data saved to {json_file}")
