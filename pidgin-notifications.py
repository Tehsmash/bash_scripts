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
    p1 = subprocess.Popen(['/bin/echo', 'naughty.notify({title = "%s", text = "%s", timeout = %d})' % (title, text, timeout)], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(['/usr/bin/awesome-client', '-'], stdin=p1.stdout, stdout=subprocess.PIPE)
    p2.communicate()

def cHTML(html):
    h = MLStripper()
    message = h.unescape(html) 
    h.feed(message)
    return h.get_data() 

def new_message(account, sender, message, conversation, flags):
    buddy = purple.PurpleFindBuddy(account, sender)
    buddy = purple.PurpleBuddyGetAlias(buddy)
    notify(buddy, cHTML(message), 15)

def logged_in(buddy):
    buddy = purple.PurpleBuddyGetAlias(buddy)
    notify(buddy, "Logged In", 15)

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

obj = bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")
purple = dbus.Interface(obj, "im.pidgin.purple.PurpleInterface")

bus.add_signal_receiver(new_message,
                        dbus_interface="im.pidgin.purple.PurpleInterface",
                        signal_name="ReceivedImMsg")

bus.add_signal_receiver(new_message,
                        dbus_interface="im.pidgin.purple.PurpleInterface",
                        signal_name="ReceivedChatMsg")

bus.add_signal_receiver(logged_in,
                        dbus_interface="im.pidgin.purple.PurpleInterface",
                        signal_name="BuddySignedOn")

notify("Running", "Pidgin Notifications", 5)

loop = gobject.MainLoop()
loop.run()
