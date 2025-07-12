# PyMOL script to iterate through models and capture ray-traced images
from pymol import cmd
import os


def capture_model_images(output_dir="./images", width=900, height=900, dpi=300):
    """
    Iterate through each model in the current PyMOL session,
    hide all others, and capture a ray-traced image.

    Parameters:
    output_dir: Directory to save images (default: ./images)
    width: Image width in pixels (default: 1200)
    height: Image height in pixels (default: 900)
    dpi: Image resolution (default: 300)
    """

    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Get list of all objects (models) in the session
    model_list = cmd.get_names("objects")

    if not model_list:
        print("No models found in the current PyMOL session.")
        return

    print(f"Found {len(model_list)} models: {model_list}")

    # Set ray tracing parameters
    cmd.set("ray_width", width)
    cmd.set("ray_height", height)
    cmd.set("ray_trace_mode", 1)  # Enable ray tracing

    # Iterate through each model
    for i, model in enumerate(model_list, 1):
        print(f"Processing model {i}/{len(model_list)}: {model}")

        # Hide all models first
        cmd.hide("everything", "all")

        # Show only the current model
        cmd.show("cartoon", model)  # You can change this to 'sticks', 'spheres', etc.

        # Zoom to fit the current model
        cmd.zoom(model)

        # Generate filename
        filename = os.path.join(output_dir, f"{model}_raytrace.png")

        # Capture ray-traced image
        cmd.ray(width, height)
        cmd.png(filename, dpi=dpi)

        print(f"Saved: {filename}")

    # Show all models again at the end (optional)
    cmd.show("cartoon", "all")
    print(f"Completed! All images saved to: {output_dir}")


# Alternative simpler version if you just want basic functionality
def quick_capture_all():
    """Simplified version with default settings"""
    model_list = cmd.get_names("objects")

    # for showing cysteins too:
    # cmd.select("cyst", "resn cys")
    # cmd.color("good_yellow", "cyst and elem S")

    for model in model_list:
        cmd.hide("everything", "all")
        cmd.show("cartoon", model)
        # showing cysteines...
        cmd.show("sticks", f"cyst and {model}")
        cmd.zoom(model)
        cmd.ray(1000, 1000)
        cmd.png(f"{model}.png", dpi=300)
        print(f"Saved {model}.png")

    cmd.show("cartoon", "all")


quick_capture_all()

# Usage examples:
# 1. Basic usage with default settings:
# capture_model_images()

# 2. Custom output directory and image size:
# capture_model_images(output_dir="./my_protein_images", width=1600, height=1200)

# 3. Quick version:
# quick_capture_all()

# To run this script in PyMOL:
# 1. Save this script as a .py file (e.g., capture_models.py)
# 2. In PyMOL command line: run capture_models.py
# 3. Then execute: capture_model_images()
