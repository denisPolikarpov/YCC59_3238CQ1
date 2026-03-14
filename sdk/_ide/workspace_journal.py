# 2026-03-14T12:08:30.331946100
import vitis

client = vitis.create_client()
client.set_workspace(path="sdk")

platform = client.get_component(name="platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

