import requests
from bs4 import BeautifulSoup
import sys

if len(sys.argv) == 1:                        # If no args exist, return immediately.
    exit(1)

locID = sys.argv[1]

headers_Get = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }

def trimet(locID):
    s = requests.Session()
    url = 'https://developer.trimet.org/ws/V1/arrivals?locIDs=' + locID + '&appID=D6B5D36D2667315EAB93BC1CB'
    r = s.get(url, headers=headers_Get)

    soup = BeautifulSoup(r.text, "lxml")
    soup.find('scheduled')
    tags = soup.find_all('arrival')
    t = tags[0]

    print t.attrs['route']
    print t.attrs['scheduled'][:-3]                 # Remove last 3 digits, which converts milliseconds to seconds (epoch time).
    print t.attrs['shortsign']
    print t.attrs['fullsign']

r = trimet(locID)
