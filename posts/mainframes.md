title: Emulating the mainframe part 1
date: 2019-11-24 18:00
tags: misc
summary: Playing around with Hercules
---

After participating in IBM's [Master the Mainframe](https://www.ibm.com/it-infrastructure/z/education/master-the-mainframe) competition (which gives users access to a [z14](https://www.ibm.com/downloads/cas/MGYBLW61) machine running [z/OS](https://www.ibm.com/it-infrastructure/z/os)), I was keen to learn more about mainframes. Compared to a lot of computing hardware these days, mainframes are still very much the domain of large corporate entities such as banks, so emulation is probably the most accessible way to spin up your own big iron. However, getting a personal copy of the proprietory z/OS is expensive (although there are options such as [ZD&T](https://www.ibm.com/support/knowledgecenter/en/SSTQBD_12.0.0/com.ibm.zdt.install.doc/topics/zdt_pe.html)). Fortunately, some of the older IBM operating systems are now in the public domain, including MVS (*Multiple Virtual Storage*) up to version 3.8j. In this blog post I will detail my experience with setting up an emulator called [Hercules](http://www.hercules-390.org/) to run an MVS distrubtion, and some of the fun I've had compiling and running programs on my own mainframe.

I should note that there are many useful resources out there which go into more detail than I will, covering all things mainframe; in particular I highly recommend the YouTube channel of [moshix](https://www.youtube.com/user/moshe5760/featured) for some excellent tutorials on using Hercules and MVS.

---

### History

The first commerically available mainframe was the [UNIVAC I](https://www.thocp.net/hardware/univac.htm) made in 1951. IBM's first mainframes were the [700 series](https://www.ibm.com/ibm/history/ibm100/us/en/icons/ibm700series/transform/), led by the IBM 701 scientific computer released in 1952. Unlike modern supercomputer clusters (such as the IBM-built [Summit](https://www.olcf.ornl.gov/summit/)), the mainframe has historically been targeted at high-throughput computing (HTC) rather than high-performance computing (HPC). For example, mainframes have been adopted throughout the finance and banking industry to provide reliable transaction services.

In this post we will be emulating the IBM 3033 hardware, running the MVS operating system. First announced in 1977 and referred to as "*The Big One*", the 3033 processor boasted a CPU cycle time of 58 ns (about 17 MHz).

![IBM 3033](images/IBM_3033_with_users.jpg)

Image from the IBM Corporate Archives* showing some users interacting with an IBM 3033 mainframe. For more information about mainframes and IBM's role in their development, I highly recommend visiting their [Coporate Archives page](https://www.ibm.com/ibm/history/index.html).

### Setting up Hercules and MVS 3.8j Turnkey

In what follows I will try to keep the information host-system-agnostic, because in theory the Hercules emulator should run on UNIX-like (e.g. Linux, MacOS, etc.) and Windows systems alike. To get started we will need to:

1. install [Hercules](http://www.hercules-390.org/hercinst.html) on the host system,
2. download the [MVS 3.8j Turnkey 4-](http://wotho.ethz.ch/tk4-/) distribution,
3. install a [3270](https://en.wikipedia.org/wiki/IBM_3270) terminal emulator.

The Hercules webpage has detailed instructions for installing the emulator on different host systems. The MVS distribution that we will be using was originally created by Volke Banke, including all the necessary software and Hercules integration to run MVS out-of-the-box. This distribution has then been updated and further automated by Juergen Winkelmann. Make sure to download the "[Current TK4-](http://wotho.ethz.ch/tk4-/tk4-_v1.00_current.zip)" version, as this has all the latest patches pre-installed. Finally, in order to interact with your emulated mainframe you will need an emulator for the 3270 IBM terminal. There are a number of options out there for this, I'm using [x3270](http://x3270.bgp.nu/). I recommend having a look through the [Turnkey User Manual](http://wotho.ethz.ch/tk4-/MVS_TK4-_v1.00_Users_Manual.pdf) before starting.

The good news is that the MVS Turnkey distribution is extremely well integrated with Hercules, and all of the IPL'ing (*Initial Program Load*, c.f. bootloading) has been automated for us. Practically speaking, this means you should be able to boot up your mainframe just by using the provided `mvs` scripts in the `tk4-` directory (`mvs.bat` for Windows users, and the shell script `mvs` for *nix users). After starting these scripts from the command prompt of your choosing, you will see lots of start-up messages printed to the console. Hopefully you should eventually see the following, which means you are ready to logon to your system:

```
HHC01603I *
HHC01603I *                           ************   ****  *****          ||
HHC01603I *                           **   **   **    **    **           |||
HHC01603I *                           **   **   **    **   **           ||||
HHC01603I *                                **         **  **           || ||
HHC01603I *        |l      _,,,---,,_      **         ** **           ||  ||
HHC01603I * ZZZzz /,'.-'`'    -.  ;-;;,    **         ****           ||   ||
HHC01603I *      |,4-  ) )-,_. ,( (  ''-'  **         *****         ||    ||
HHC01603I *     '---''(_/--'  `-')_)       **         **  **       ||     ||    ||||||||||
HHC01603I *                                **         **   **      |||||||||||  Update 08
HHC01603I *       The MVS 3.8j             **         **    **            ||
HHC01603I *     Tur(n)key System           **         **     **           ||
HHC01603I *                              ******      ****     ***       ||||||
HHC01603I *
HHC01603I *            TK3 created by Volker Bandke       vbandke@bsp-gmbh.com
HHC01603I *            TK4- update by Juergen Winkelmann  winkelmann@id.ethz.ch
HHC01603I *                     see TK4-.CREDITS for complete credits
HHC01603I *
```

At this point you can fire up your 3270 emulator, and point it to connect to port 3270 on your machine (e.g. `localhost:3270`, or `127.0.0.1:3270`). As the first user logging on to the system you will need to press the `RESET` and `CLEAR` keys on your 3270 emulator in order to be presented with a logon prompt. Note: the 3270 terminal had a number of keys that may not be present on your modern keyboard, so the emulator that you use may have special keybindings in order to use them.

We are going to use the `HERC02` default user (password `CUL8TR`):

```
Logon ===> HERC02

ENTER CURRENT PASSWORD FOR HERC02-
CUL8TR
```

Having successfully logged on to TSO (*Time Sharing Option*), you will be presented with a little menu of TSO Applications. Choose option 1, RFE (*REVIEW Front End*), by hitting enter on:

```
Option ===> 1
```
From here we're ready to start playing with our mainframe!

### Getting around the system with RFE

TSO is a system that allows multiple users to access and use a mainframe simultaneously. Much like UNIX, it provides a command line for submitting programs for execution. However, it is generally more convenient to use a *productivity tool* to interact with the system. These tools are a text-based user interface somewhere in between the command-line and a full windowing graphical user interface. Users of modern z/OS systems may be familiar in particular with `ISPF` (*Interactive System Productivity Facility*) and `SDSF` (*System Display and Search Facility*), however these are both proprietory IBM programs which require a license. We will instead be using an open source facility maintained by Greg Price called `REVIEW`, and we will interact with it using the front-end `RFE`:

![Using RFE](images/using_RFE.png)

As you can see from the RFE main menu, we can use this program to manage our files (called *Data sets* in mainframe jargon) as well as execute our programs on TSO.

### Next time...

In the next post I will describe my experiences getting set up with some of the compilers that come with the Turnkey distribution. We will write, compile and run some fun programs written in FORTRAN IV, COBOL and C. [Read more...](/emulating-the-mainframe-part-2.html)

---

*Disclaimer: this image is used for noncommerical, educational purposes only. Note that the image and text files on the IBM Corporate Archives [Web site](https://www.ibm.com/ibm/history/request2/terms.html) are made available for noncommercial, educational, and personal use only.
