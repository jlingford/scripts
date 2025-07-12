from pymol import cmd


def coloraf_cat(selection="all"):
    """
    AUTHOR
    Christian Balbin

    DESCRIPTION
    Colors Alphafold structures by pLDDT

    USAGE
    coloraf_cat sele

    PARAMETERS

    sele (string)
    The name of the selection/object to color by pLDDT. Default: all
    """

    # cmd.color("blue", f"({selection}) and b > 90")
    cmd.color("0x1e66f5", f"({selection}) and b > 90")
    # cmd.color("cyan", f"({selection}) and b < 90 and b > 70")
    cmd.color("0x74c7ec", f"({selection}) and b < 90 and b > 70")
    # cmd.color("yellow", f"({selection}) and b < 70 and b > 50")
    cmd.color("0xf9e2af", f"({selection}) and b < 70 and b > 50")
    # cmd.color("orange", f"({selection}) and b < 50")
    cmd.color("0xfab387", f"({selection}) and b < 50")


cmd.extend("coloraf_cat", coloraf_cat)
cmd.auto_arg[0]["coloraf_cat"] = [cmd.object_sc, "object", ""]
