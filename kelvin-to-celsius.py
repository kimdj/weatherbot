import sys

if len(sys.argv) == 1:                        # If no args exist, return immediately.
    exit(1)

payload = sys.argv[1]

def kToC(kelvin):
    return float(kelvin) - 273.15

print kToC(payload)