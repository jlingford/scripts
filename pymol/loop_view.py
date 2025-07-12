from pymol import cmd
import os
import time


# def quick_view_all():
#     """Simplified version with default settings"""
#     model_list = cmd.get_names("objects")
#
#     for model in model_list:
#         cmd.hide("everything", "all")
#         cmd.show("cartoon", model)
#         # showing cysteines...
#         cmd.show("sticks", f"cyst and {model}")
#         cmd.zoom(model)
#         cmd.refresh()
#         time.sleep(2)
#         cmd.refresh()
#         # cmd.ray(1200, 900)
#         # cmd.png(f"{model}.png")
#         # print(f"Saved {model}.png")
#
#     # cmd.show("cartoon", "all")
#
#
# quick_view_all()


# def quick_view_all():
#     """Display each model sequentially with proper refresh"""
#     model_list = cmd.get_names("objects")
#
#     if not model_list:
#         print("No models found in the current PyMOL session.")
#         return
#
#     print(f"Found {len(model_list)} models: {model_list}")
#
#     for i, model in enumerate(model_list):
#         print(f"Showing model {i + 1}/{len(model_list)}: {model}")
#
#         # Hide everything first
#         cmd.hide("everything", "all")
#
#         # Show current model
#         cmd.show("cartoon", model)
#
#         # Show cysteines (fixed: should be 'cys' not 'cyst')
#         cmd.show("sticks", f"resn cys and {model}")
#         cmd.color("yellow", f"resn cys and {model}")
#
#         # Zoom to current model
#         cmd.zoom(model)
#
#         # Force PyMOL to refresh the display
#         cmd.refresh()
#
#         # Wait for 1 second - this should work in most PyMOL versions
#         time.sleep(4)
#
#         # Alternative: use PyMOL's internal refresh with delay
#         # cmd.refresh_now()
#         #
#
#
# quick_view_all()


# def quick_view_all_with_mplay():
#     """Alternative version using PyMOL's movie functionality for smoother transitions"""
#     model_list = cmd.get_names("objects")
#
#     if not model_list:
#         print("No models found in the current PyMOL session.")
#         return
#
#     # Set up movie frames
#     total_frames = len(model_list) * 30  # 30 frames per model (1 second at 30fps)
#     cmd.mset("1", total_frames)
#
#     frame = 1
#     for model in model_list:
#         print(f"Setting up frames for model: {model}")
#
#         # Set keyframe for this model
#         cmd.frame(frame)
#         cmd.hide("everything", "all")
#         cmd.show("cartoon", model)
#         cmd.show("sticks", f"resn cys and {model}")
#         cmd.color("yellow", f"resn cys and {model}")
#         cmd.zoom(model)
#         cmd.refresh()
#
#         # Store this view for the next 30 frames
#         for f in range(frame, min(frame + 30, total_frames + 1)):
#             cmd.frame(f)
#             cmd.mview("store")
#
#         frame += 30
#
#     # Play the movie
#     cmd.mplay()
#     print("Playing movie - use 'mstop' to stop")
#
#
# quick_view_all_with_mplay()


def quick_view_all_interactive():
    """Interactive version that waits for user input between models"""
    model_list = cmd.get_names("objects")

    if not model_list:
        print("No models found in the current PyMOL session.")
        return

    for i, model in enumerate(model_list):
        # Hide everything first
        cmd.hide("everything", "all")

        # Show current model
        cmd.show("cartoon", model)
        cmd.show("sticks", f"resn cys and {model}")
        cmd.color("yellow", f"resn cys and {model}")
        cmd.zoom(model)

        # Force refresh
        cmd.refresh()

        print(f"Showing model {i + 1}/{len(model_list)}: {model}")

        if i < len(model_list) - 1:  # Don't wait after the last model
            input("Press Enter to continue to next model...")


quick_view_all_interactive()
