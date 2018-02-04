import sys

if len(sys.argv) == 1:                        # If no args exist, return immediately.
    exit(1)

payload = sys.argv[1]

def kToF(kelvin):
    return float(kelvin) * (1.8) - 459.67

print kToF(payload)