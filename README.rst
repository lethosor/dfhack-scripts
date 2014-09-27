dfhack-scripts
==============

A collection of DFHack scripts

Links: `Issue tracker <https://github.com/lethosor/dfhack-scripts/issues>`_ | 
`Wiki <https://github.com/lethosor/dfhack-scripts/wiki>`_ |
`Forum thread <http://www.bay12forums.com/smf/index.php?topic=143875.0>`_

.. contents ::

adv-max-skills
--------------
When setting up an adventurer, raises all changeable skills and attributes to their maximum level.

* ``adv-max-skills``

annc-monitor
------------
Displays announcements and reports in the console.

* ``annc-monitor start``: Begins monitoring
* ``annc-monitor stop``: Stops monitoring
* ``annc-monitor interval X``: Sets the delay between checks for new announcements to ``X`` frames 

click-monitor
-------------
Displays the grid coordinates of mouse clicks in the console. Useful for plugin/script development.

* ``click-monitor start`` to begin monitoring
* ``click-monitor stop`` to stop

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

manager-quantity
----------------
Allows changing the desired quantity of the currently-selected manager job.

Recommended for use as a keybinding:

* ``keybinding add Alt-Q@jobmanagement manager-quantity``

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
