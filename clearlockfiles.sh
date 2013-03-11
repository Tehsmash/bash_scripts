#!/bin/bash

find * -name '*~' | xargs rm
find * -name '*.orig' | xargs rm
