# Pinball Hardware Game

Xilinx Vivado based video game writen in Verilog that utilizes Bresenham’s Line Algorithm developed by Jack Bresenham with hardware implementation help by Stephen Edwards of Columbia University Computer Science Department and VGA functionality created by San Jose State Professor Eric Crabill of Xilinx.

This implementation works with for the 100Mhz generated clock onboard the Arxtix-7 based BASYS 3 Board by Digilent. It will comply with VESA Display Monitor Standards @ 640 xy 480 pixle resolution. To test the algorithm a .TIFF file will be generated on simulation that will indicated correct logical functionality along with VGA output of the algorithm.

### Features!

  - Bumpers fully implemented using 90 degree hitboxes. Each bumper has a physical button to control it
  - 255 x 255 image space
  - Fully movable ball with no aliasing
  - Collisions detected on a "per object" basis
  - Compiled for use with Basys 3 Board by Digilent


### Tech

Pinball uses materials listed below:

* [Vivado 2017.1] - Xilinx's ISE for programing their FPGA's
* [ISE WebPACK] - Vivado's Free development licence
* [Textastic] - Great text editor for Mac
* [Notepad++] - Windows text editor for code
* [Adobe Photoshop] - Phototediting software used to easily get coordinates

# Screenshots
### Welcome Screen
![Welcome Screen](https://github.com/ChristianAguilar614/Artix-7-PinballGame/blob/master/Images/Welcome%20page%20PIN%20BALL.png)
### Game Screen
![Welcome Screen](https://github.com/ChristianAguilar614/Artix-7-PinballGame/blob/master/Images/Game%20Board.png)
### End Game Screen
![Welcome Screen](https://github.com/ChristianAguilar614/Artix-7-PinballGame/blob/master/Images/Game%20Over%20.png)
### Installation

Currently limited to compiling on a personal computer with the listed software.
Instructions for doing that can be found [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/basys-3-getting-started/start)

### Todos

 - Fix Collision Edge Cases
 - Add colors
 - Utilize more screen space
 - UI improvements (score and ball lives)

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [Vivado 2017.1]: <https://www.xilinx.com/support/download.html>
   [ISE WebPACK]: <https://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.html>
   [Textastic]: <https://www.textasticapp.com/mac.html>
   [Adobe Photoshop]: <http://www.adobe.com/products/photoshop.html>
   [Notepad++]: <https://notepad-plus-plus.org/>

