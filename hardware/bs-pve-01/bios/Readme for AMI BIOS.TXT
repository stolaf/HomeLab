================================================
Standard BIOS Update Procedure under UEFI Shell
================================================

1. Save this BIOS update package to your computer.

2. Extract the files to a USB stick. (Note: The USB stick doesn't have to be bootable, but has to be formatted with
   FAT/FAT32 file system.)

3. Plug the USB stick into USB port, boot to the Build-In UEFI Shell, and type FLASH.nsh BIOSname#.### to start the
   BIOS update:

     Shell> fs0:
     fs0:\> flash.nsh X11SAA6.C20

4. Do not interrupt the process until the BIOS update is complete.

5. After the message indicating BIOS update has completed, do the A/C power cycle.

6. Go to the BIOS setup screen and press F3 to load the default and press F4 to save and exit.


================================================
Super.ROM (see user's manual for details)
================================================
Recovery BIOS from a USB Device/Drive   **Warning:this method is only available for recovery current BIOS not for upgrade BIOS**

If the BIOS file is corrupted and the system is not able to boot up, this feature will
allow you to recover the BIOS image using a USB-attached device. A USB Flash
Drive or a USB CD/DVD ROM/RW drive may be used for this purpose. Please note
that a USB Hard Disk drive is NOT supported at this time. Follow the procedures
below recover the BIOS.

1. Using a different machine, copy the "Super.ROM" binary image file into the Root "\"
   directory of a USB device or a writable CD/DVD.

2. Insert the USB device that contains the new BIOS image ("Super.ROM") into your USB
   drive and reset the system when Supermicro logo appears.

3. After locating the healthy BIOS binary image, the system will enter the BIOS Recovery
   menu.

4. Use the arrow keys to select the item"Proceed with flash update" and press the <Enter> key. 
   DO NOT INTERRUPT THIS PROCESS UNTIL IT FINISHED!

5. After the Boot Sector Recovery Process is complete, press any key to reboot the system.

6. Using a different system, extract the BIOS package into a USB flash drive.

6. Boot into UEFI Shell again and please type FLASH.nsh BIOSname#.### to start BIOS update,
   just like in standard BIOS update procedure.

7. Do not interrupt the process until the flashing is complete.

8. After the message indicating BIOS update has completed, do the A/C power cycle.

9. Go to the BIOS Setup screen and press F3 to load the default and press F4 to save and exit.



** If the BIOS flash failed, you can contact our RMA dept. to have the bios chip reprogrammed.
This will require shipping the board to our RMA dept. for BIOS reprogramming.  
The RMA dept's email address is rma@supermicro.com



BIOS Name = PPPPPSSY.MDD

*********Here is a New BIOS Naming Convention****************

BIOS name     : PPPPPSSY.MDD

PPPPP          : 5-Bytes for project name

SS                 : 2-Bytes supplement for PPPPP

Y                   : Year,  9 -> 2009, 0-> 2010, 1->2011

MDD               : Month / Date



E.g. BIOS Build Date: 2010/1/15

X8ST3-F -> X8ST30.115

X8SIL-F -> X8SIL0.115