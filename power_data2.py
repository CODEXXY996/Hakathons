import json

# Define standard power ratings
devices = {
    "AC": {"normal_voltage": 180},
    "TV": {"normal_voltage": 113},
    "Fridge": {"normal_voltage": 208},
    "Fan": {"normal_voltage": 182},
    "Light": {"normal_voltage": 163}
}

# Save data to JSON file
with open("power_data.json", "w") as json_file:
    json.dump(devices, json_file, indent=4)

print("JSON file created successfully!")
