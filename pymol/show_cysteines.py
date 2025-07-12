from pymol import cmd
import os


def show_cysteines():
    """
    Select and show all cysteines
    """

    cmd.select("cysts", "resn cys")
    cmd.show("sticks", "cysts")
    cmd.color("good_yellow", "cysts and elem S")


show_cysteines()
