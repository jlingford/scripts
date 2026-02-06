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

    # original color palette by Balbin
    # cmd.color("blue", f"({selection}) and b > 90")
    # cmd.color("cyan", f"({selection}) and b < 90 and b > 70")
    # cmd.color("yellow", f"({selection}) and b < 70 and b > 50")
    # cmd.color("orange", f"({selection}) and b < 50")
    #
    # catppuccin color palette
    # cmd.color("0x1e66f5", f"({selection}) and b > 90")
    # cmd.color("0x74c7ec", f"({selection}) and b < 90 and b > 70")
    # cmd.color("0xf9e2af", f"({selection}) and b < 70 and b > 50")
    # cmd.color("0xfab387", f"({selection}) and b < 50")
    #
    # color palette used for Lorne poster
    cmd.color("0x3b4dc1", f"({selection}) and b > 90")
    cmd.color("0x7ea1f9", f"({selection}) and b < 90 and b > 70")
    cmd.color("0xf4c2aa", f"({selection}) and b < 70 and b > 50")
    cmd.color("0xc53233", f"({selection}) and b < 50")


cmd.extend("coloraf_cat", coloraf_cat)
cmd.auto_arg[0]["coloraf_cat"] = [cmd.object_sc, "object", ""]
