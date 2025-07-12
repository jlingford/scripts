from pymol_remote.client import PymolSession

# Connect to the local PyMOL instance
pymol = PymolSession(hostname="localhost", port=9123)

# You can now send commands to PyMOL
pymol.fetch("6lyz")
pymol.do("remove solvent")
pymol.do("set valence, on")
pymol.get_state(format="cif")

# To see all available methods use
pymol.help()

# To get more help on a specific method, use
pymol.help("fetch")

# To get more general documentation information, use
pymol.print_help()
