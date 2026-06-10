# Waju-Sims

Download links:

DMU: https://github.com/WCGH/Waju-Sims/releases/tag/dmu-0.2.x

FRU: https://github.com/WCGH/FRU-Sim/releases/tag/v1.8

DSR: https://github.com/WCGH/Dragonsong-Sim/releases/tag/v1.1

Discord: https://discord.gg/P9adFHADrX

## Note on renderer compatability issues and running on Linux:

If the sim fails to launch or consistently crashes, it is usually a rendering issue. The sim by default runs on DX12 but you can run it on Vulkan through cmd line arguments.

For Windows users: Shift+Right click anywhere inside the folder containing dmu-sim.exe > Open PowerShell window here > Enter `./dmu-sim.exe --rendering-driver vulkan`

The same arguments should also work for Linux users running it through Wine.

If you're on a laptop with integrated GPU and neither DX12 or Vulkan works, you can also try replacing `vulkan` with `opengl3`, though you will see a big drop in performance.


If you have any questions or feedback let me know on discord.
