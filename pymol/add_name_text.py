from pymol import cmd
from pymol.cgo import *
import time


def add_corner_info(info_text, corner="bottom_left", color="black"):
    """
    Add information text in screen corners

    Parameters:
    info_text: Text to display
    corner: "bottom_left", "bottom_right", "top_left", "top_right"
    color: Text color
    """

    # Get the current view extent
    extent = cmd.get_extent("all")
    if extent:
        x_range = extent[1][0] - extent[0][0]
        y_range = extent[1][1] - extent[0][1]
        z_range = extent[1][2] - extent[0][2]

        # Calculate position based on corner
        if corner == "bottom_left":
            # pos = [
            #     extent[0][0] - x_range * 0.1,
            #     extent[0][1] - y_range * 0.1,
            #     extent[0][2],
            # ]
            pos = [-100, -800, 0]
        elif corner == "bottom_right":
            pos = [
                extent[1][0] + x_range * 0.1,
                extent[0][1] - y_range * 0.1,
                extent[0][2],
            ]
        elif corner == "top_left":
            pos = [
                extent[0][0],
                extent[1][1],
                extent[1][2],
            ]
        else:  # top_right
            pos = [
                extent[1][0] + x_range * 0.1,
                extent[1][1] + y_range * 0.1,
                extent[1][2],
            ]

        label_name = f"corner_label_{corner}"
        cmd.delete(label_name)
        cmd.pseudoatom(label_name, pos=pos)
        cmd.hide("everything", label_name)
        cmd.label(label_name, f'"{info_text}"')
        cmd.set("label_color", color, label_name)
        cmd.set("label_size", 25, label_name)


add_corner_info("foobar", corner="bottom_left")
