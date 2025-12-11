# Example script to cycle through models
import getopt, sys
import os
from chimerax.core.commands import run
import time

# Get all models
models = session.models.list()

# Loop through models, showing one at a time
for i in range(10):  # Repeat 10 times
    for j, model in enumerate(models):
        # Hide all models
        run(session, "hide models")

        # Show current model
        run(session, f"show #{j}")

        # Wait for a moment (optional)
        time.sleep(1)
