# Arduino-LCD
Assembly language programs for controlling an Arduino.

### Index
* [LCD Screen Assembly Program](#LCD)
* [LED Lights Assembly Program](#LED)

---

### LCD Screen Assembly Program
<a name="LCD"></a>

Our program looks under the hood at the inner workings of hardware, employing timers, interrupts, analog-to-digital conversion, and manipulation of ports and registers to operate the LCD screen on the Atmel Xmega Arduino platform using the AVR instruction set. The goal was to develop proficiency with low-level hardware, operating systems, and fundamental computer architecture. The Assembly code can be accessed [here](https://github.com/NeddTheRedd/Arduino-LCD/blob/main/Arduino_program.asm). A skeleton of an assembly-language program was provided, and the bulk of the code was built, debugged, and executed by myself in Microchip Studio. 

Below is a demonstration showcasing the capabilities of the final product:

![8q5dkf](https://github.com/NeddTheRedd/Arduino-LCD/assets/153869055/463da58c-3a02-4246-894f-cfabf1affb8a)
<br> Watch [here](https://www.youtube.com/watch?v=EpKo95vsFmU)


---

### LED Lights Assembly Program
<a name="LED"></a>

The focus for this program was on low-level parameter passing using available registers and the stack frame. The Assembly code can be accessed [here](https://github.com/NeddTheRedd/Arduino-LCD/blob/main/LED-signalling.asm). Much like the LED screen program, a skeleton of an assembly-language program was provided, and the bulk of the code was built, debugged, and executed by myself in Microchip Studio.

Here is a demonstration of intended outcome:

![8q5jor](https://github.com/NeddTheRedd/Arduino-LCD/assets/153869055/700283c6-3378-45f0-a3fa-1d1ebc1a1c6f)
<br> Watch [here](https://www.youtube.com/watch?v=_tRcKbYSZlY)
