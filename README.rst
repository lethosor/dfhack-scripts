Lethosor's scripts
==================

A collection of DFHack scripts

Links: `Issue tracker <https://github.com/lethosor/dfhack-scripts/issues>`_ |
`Wiki <https://github.com/lethosor/dfhack-scripts/wiki>`_ |
`Forum thread <http://www.bay12forums.com/smf/index.php?topic=143875.0>`_

**Note:** manipulator is now located in a separate repository, `lethosor/dwarf-manipulator <https://github.com/lethosor/dwarf-manipulator>`_.

.. contents ::

adv-max-skills
--------------
When setting up an adventurer, raises all changeable skills and attributes to their maximum level.

* ``adv-max-skills``

devel/annc-monitor
------------------
Displays announcements and reports in the console.

* ``annc-monitor enable|start``: Begins monitoring
* ``annc-monitor disable|stop``: Stops monitoring
* ``annc-monitor interval X``: Sets the delay between checks for new announcements to ``X`` frames

devel/click-monitor
-------------------
Displays the grid coordinates of mouse clicks in the console. Useful for plugin/script development.

* ``click-monitor start`` to begin monitoring
* ``click-monitor stop`` to stop

color-adjust
------------
Adjusts the red, green, and/or blue components of all in-game colors.

* ``color-adjust -r 1.1`` multiplies the red components of all colors by 1.1
* ``color-adjust -gb 0.7`` multiplies the green and blue components of all colors by 0.7
* ``color-adjust -g 0.7 -b 0.7``: Equivalent to ``color-adjust -gb 0.7``
* ``color-adjust -a 0.9`` multiplies all (red, green, and blue) components of all colors by 0.9
* ``color-adjust -reset`` resets all colors to their original values.

    * Note that the original colors used by ``color-adjust`` are stored when ``color-adjust`` is first run in a DF session.
      If other scripts that change colors are run before ``color-adjust``, ``color-adjust -reset`` will restore the modified colors.
      To avoid this, run ``color-adjust -a 1`` before running other scripts.

embark-skills
-------------
Adjusts dwarves' skills when embarking.

Note that already-used skill points are not taken into account or reset.

* ``embark-skills points N``: Sets the skill points remaining of the selected dwarf to ``N``.
* ``embark-skills points N all``: Sets the skill points remaining of all dwarves to ``N``.
* ``embark-skills max``: Sets all skills of the selected dwarf to "Proficient".
* ``embark-skills max all``: Sets all skills of all dwarves to "Proficient".
* ``embark-skills legendary``: Sets all skills of the selected dwarf to "Legendary".
* ``embark-skills legendary all``: Sets all skills of all dwarves to "Legendary".

invert-colors
-------------
Proof-of-concept script that inverts the color scheme while DF is running.

* ``invert-colors``

load-screen
-----------
A replacement for the "continue game" screen.

* ``load-screen enable`` to enable
* ``load-screen disable`` to disable

modtools/raw-lint
-----------------
Checks for simple issues with raw files. Can be run automatically.

settings-manager
----------------
An in-game settings manager (init.txt/d_init.txt)

Recommended for use as a keybinding:

* ``keybinding add Alt-S@title settings-manager``
* ``keybinding add Alt-S@dwarfmode/Default settings-manager``

title-version
-------------
Displays the DFHack version on the title screen next to the version number.

* ``title-version [enable]``: Shows DFHack version
* ``title-version disable``: Hides DFHack version
