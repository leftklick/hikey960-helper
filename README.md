# hikey960-helper
Scripts to help with managing the hikey960

Enter recovery/forced-download mode on HiKey960:

* Remove power from the board
* Change Jumper/DIP switch settings, to enter recovery/forced-download mode:

Name          | Link / Switch       | State
------------- | ------------------- | ----------
Auto Power up | Link 1-2 / Switch 1 | closed / ON
Recovery      | Link 3-4 / Switch 2 | closed / ON
Fastboot      | Link 5-6 / Switch 3 | open / OFF

* Apply power to the board using [96Boards compliant power supply](http://www.96boards.org/product/power/
)
* Insert USB Type-C cable (OTG port) to the board, and connect the other end to your Linux PC
* Check whether there is a device node "/dev/ttyUSBx". If there is, it means your PC has detected the tar
get board; If there is not, try to repeat previous steps.
* Run the script to start the install as follows:

```
./install_prebuilt_debian.sh
```

* The script will now flash a recovery firmware, boot into fastboot mode, download the correct OS image and associated images and flash them in the correct order.
* The default image that will be flashed is the console only LAVA image. If you'd like to change it, edit the script and change the image name.
