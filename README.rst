dfhack-scripts
==============

A collection of DFHack scripts

Per-script changelogs can be found in the `changelogs <https://github.com/lethosor/dfhack-scripts/tree/master/changelogs>`_ folder.

.. contents ::

adv-max-skills
--------------
When setting up an adventurer, raises all changeable skills and attributes to their maximum level.

* ``adv-max-skills``

click-monitor
-------------
Displays the grid coordinates of mouse clicks in the console. Useful for plugin/script development.

* ``click-monitor start`` to begin monitoring
* ``click-monitor stop`` to stop

invert-colors
-------------
Proof-of-concept script that inverts the color scheme while DF is running.

* ``invert-colors``

load-screen
-----------
A replacement for the "continue game" screen. See the `forum thread <http://www.bay12forums.com/smf/index.php?topic=138776>`_ for more details.

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
