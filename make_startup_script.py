#!/bin/env python3


import os 
import os.path
import sys
import json

from jinja2 import Environment, FileSystemLoader, select_autoescape

empty_settings = {
    "host_aliases":  []
}

current_dir = os.path.dirname(__file__)
template_source_path = os.path.join(current_dir, "templates/")


env = Environment(
    loader=FileSystemLoader(template_source_path),
    autoescape=select_autoescape(['sh'])
)

t = env.get_template("startup_script.template")

settings_path = os.path.join(current_dir, "settings.json")

if os.path.exists(settings_path)
    settings = json.load(open(settings_path))
else:
    settings = empty_settings

s = t.render(settings)
with open(os.path.join(current_dir, "startup_script.sh"), "w") as out:
    out.write(s)
