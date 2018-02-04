#!/usr/bin/env python
# weatherbot ~ Script uses the OpenWeather API
# Copyright (c) 2017 David Kim
# This program is licensed under the "MIT License".
# Date of inception: 2/5/18

import requests
from bs4 import BeautifulSoup
import json

import sys

if len(sys.argv) == 1:                        # If no args exist, return immediately.
    exit(1)

payload = sys.argv[1]

headers_Get = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }

def trimet(payload):
    s = requests.Session()

    if payload.isdigit() and len(payload) == 5:
        url = 'http://api.openweathermap.org/data/2.5/weather?zip=' + payload + ',us&appid=4e323304a266bc0ce4da1508ba8a991d'
    else:
        url = 'http://api.openweathermap.org/data/2.5/weather?q=' + payload + '&appid=4e323304a266bc0ce4da1508ba8a991d'

    r = s.get(url, headers=headers_Get)

    soup = BeautifulSoup(r.text, "lxml")
    tags = soup.find_all('p')
    t = tags[0]
    t = t.contents
    t = t[0]
    return t

r = trimet(payload)
newDict=json.loads(str(r))

strs = str(newDict['weather'][0])
strs = strs.replace("'",'"')
strs = strs.replace('u"','"')
weatherDict = json.loads(strs)

print newDict['name']
print weatherDict['description']

strs = str(newDict['main'])
strs = strs.replace("'",'"')
strs = strs.replace('u"','"')
mainDict = json.loads(strs)

print mainDict['temp']
print mainDict['humidity']
