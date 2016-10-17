#!/usr/bin/env python

import dbus, gobject
from HTMLParser import HTMLParser
from dbus.mainloop.glib import DBusGMainLoop
import subprocess

class MLStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

def notify(title, text, timeout):
    timeout = str(timeout * 1000)
    subprocess.check_call(['notify-send', title, text, '-t', timeout])

def cHTML(html):
    h = MLStripper()
    message = h.unescape(html) 
    h.feed(message)
    return h.get_data() 

def new_message(subject, message):
    notify(subject, message, 500)

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

bus.add_signal_receiver(new_message,
                        dbus_interface="org.irssi.Irssi",
                        signal_name="IrssiNotify",
                        path='/org/irssi/Irssi')

notify("Running", "Irssi Notifications", 5)

loop = gobject.MainLoop()
loop.run()
