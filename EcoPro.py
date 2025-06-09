import json
import random
import time
import datetime
import requests
import matplotlib.pyplot as plt
import numpy as np

# Define log file
log_file = "power_log.txt"

# Standard Power Ratings (Watts) and Voltage Ranges
devices = {
    "AC": {"normal_rating": 2000, "current_range": (7, 10), "voltage_range": (220, 240)},
    "TV": {"normal_rating": 300, "current_range": (0.8, 1.5), "voltage_range": (110, 240)},
    "Fridge": {"normal_rating": 150, "current_range": (1.2, 2.0), "voltage_range": (220, 240)},
    "Fan": {"normal_rating": 75, "current_range": (0.4, 0.8), "voltage_range": (110, 240)},
    "Light": {"normal_rating": 40, "current_range": (0.2, 0.5), "voltage_range": (110, 120)},
}

# Electricity Rate in India (₹ per kWh)
electricity_rate = 6  # ₹6 per kWh

# ThingSpeak Credentials
channel_id = 2859435
write_api_key = "XHA7QTFOGABTLFSF"
thingspeak_url = "https://api.thingspeak.com/update.json"

# Infinite Loop for Continuous Monitoring
while True:
    random.seed()  # Ensure randomness
    power_values = {}
    log_entries = []

    print("\nPower Readings:")
    print(f"{'Device':<10} {'Usage (W)':<15} {'Status':<10}")

    # Open log file
    with open(log_file, "a") as log:
        log.write(f"\n{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log.write("----------------------------------\n")

        for device, specs in devices.items():
            voltage = random.randint(*specs["voltage_range"])
            current = round(random.uniform(*specs["current_range"]), 2)
            power = round(voltage * current, 2)  # P = V × I
            status = "Normal"

            if power > 1.2 * specs["normal_rating"]:
                status = "Overload"
                gauge_color = "red"
            elif power < 0.8 * specs["normal_rating"]:
                status = "Underpowered"
                gauge_color = "blue"
            else:
                gauge_color = "green"

            # Store power usage
            power_values[device] = {"power_usage": power, "status": status}
            log_entries.append(f"{device:<10} {power:<15.2f} {status:<10}")

            print(f"{device:<10} {power:<15.2f} {status:<10}")

        # Log data
        log.write("\n".join(log_entries) + "\n")

    # Identify Most and Least Power-Consuming Devices
    max_device = max(power_values, key=lambda d: power_values[d]["power_usage"])
    min_device = min(power_values, key=lambda d: power_values[d]["power_usage"])
    max_power = power_values[max_device]["power_usage"]
    min_power = power_values[min_device]["power_usage"]

    # Cost Savings Suggestion
    hours_per_day = 5  # Assume the device runs 5 hours daily
    energy_saved_kwh = (max_power * hours_per_day) / 1000  # Convert W to kWh
    cost_saved = energy_saved_kwh * electricity_rate

    print(f"\nMost Power-Hungry Device: {max_device} ({max_power:.2f}W)")
    print(f"Least Power-Consuming Device: {min_device} ({min_power:.2f}W)")
    print(f"\n💡 Recommendation: Turn off the {max_device} to save ₹{cost_saved:.2f} per day!")

    # Log Analysis to File
    with open(log_file, "a") as log:
        log.write(f"\nMost Power-Hungry Device: {max_device} ({max_power:.2f}W)\n")
        log.write(f"Least Power-Consuming Device: {min_device} ({min_power:.2f}W)\n")
        log.write(f"\nRecommendation: Turn off the {max_device} to save ₹{cost_saved:.2f} per day!\n")

    # Visualization (Bar Graph)
    plt.figure(figsize=(8, 5))
    devices_list = list(power_values.keys())
    power_list = [power_values[dev]["power_usage"] for dev in devices_list]

    plt.bar(devices_list, power_list, color="cyan", edgecolor="black")
    plt.xlabel("Devices")
    plt.ylabel("Power Usage (W)")
    plt.title("Power Consumption by Device")
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.show()

    # Send Data to ThingSpeak
    try:
        print("Sending data to ThingSpeak...")
        response = requests.post(thingspeak_url, data={"api_key": write_api_key, **{f"field{i+1}": power_list[i] for i in range(len(power_list))}})
        print(f"ThingSpeak Response: {response.text}")
    except Exception as e:
        print(f"ThingSpeak upload failed: {e}")

    # Pause to Avoid ThingSpeak Rate Limit
    time.sleep(20)
