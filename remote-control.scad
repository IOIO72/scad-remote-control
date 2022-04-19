/*
Customizable Holder for Remote Controls or any other stuff
by IOIO72 aka Tamio Patrick Honma (https://honma.de)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.


Update

2021-11-26: Tablet to attach on top of the hooks added.


Description

This holder was originally intended for remote controls, which you attach to the couch armrest. 

In addition, it is possible to use the holder for all sorts of other purposes. This is especially possible due to the customizability of the 3D model. For example, you can also configure a holder for tools and material of the 3D printer or something for the garden, the workshop, the garage or the household.

Ultimately, the 3D model is a box, which can be subdivided as desired, and a holding device.


How to configure the box:

1. Set the general height and depth of the box.

2. Subdivision is done by a list of width specifications. It is important to keep the format: At the beginning and at the end of the list are square brackets and between them a comma-separated list of width specifications.

3. You can designate the individual subdivisions. The order of the entries corresponds to the list of width specifications. If you do not want any designations, enter the following there: `[""]`

4. The text size of the designations and the font used can also be set. For font selection, use the menu item "Help/ Font list" in OpenSCAD, select a font there and copy it to the clipboard. Then paste the font name into the "font" input field. It is important that you remove the quotation marks.


How to configure the hook for attachment:

All specifications refer to the inside of the hook, i.e. if you measure, for example, the width of your armrest, you can enter exactly this value. The walls of the hook are added around it.

1. Enter the width and height of the hook. The height is measured from the top edge of the box.

2. Enter the depth of the hook. This would be, for example, the width of your armrest.

3. Enter the height of the hook's attachment.

4. Set the type of hook. "Separate" is intended for mounting the hook to the box by glue. To make it easier to print, select "Separate printable". With the "Unibody" option, the hook becomes a part of the box. The latter can only be printed by support structures.


How to configure the tablet for attachment on top of the hook:

- Set the frame height of the tablet to 0, if you like to get a print tablet.
- Otherwise you can use this value to set the frame of the tablet.


Select the parts:

By selecting the parts, you can generate individual STL files for box and hook or generate a complete STL file for all components. This might be useful to place the parts on your print bed.


Help others:

Since I'm sure you have some good ideas for configuring mounts for various purposes, it would be great if you would share them with us.

Especially for people who do not configure, but only print finished STL files, would certainly be happy about suitable models.

So feel free to share your configurations via Make.

*/


// Wall Thickness
wall_thickness = 2.5;


/* [Box] */

// Height of Box
box_height = 60;

// Depth of Box
box_depth = 33;

// Widths of Remotes
remotes_widths = [45, 48, 54, 54, 39];

// Acronyms or Names for Remotes (use few letters)
remotes_names = ["Lights", "DVB", "BluRay", "Audio", "TV"];

// Text Size
text_size = 10;

// Font (use OpenSCAD menu "Help/Font list" and remove quote signs)
font = "Helvetica:style=Bold";


/* [Hook] */

// Width of Hook
hook_width = 30;

// Height of Hook
hook_height = 80;

// Depth of Hook
hook_depth = 100;

// Height of Hook Fixure
hook_fixure_height = 60;

// Hook mounting type
hook_type = "separate"; // [separate:Separate, printable:Separate printable, unibody:Unibody]


/* [Tablet] */

// Height of tablet frame
tablet_frame_height = 5;


/* [Parts] */

// Box
display_box = true;

// Left Hook
display_hook_left = true;

// Right Hook
display_hook_right = true;

// Tablet
display_tablet = true;


/* [Hidden] */


// Functions

function sumup_left(vector, count, sum = 0) =
  count == 0
    ? sum
    : sumup_left(vector, count - 1, sum + vector[count - 1]);

function sumup_value_when_vector_not_null(vector, value, count, sum = 0) =
  count == 0
    ? sum
    : sumup_value_when_vector_not_null(vector, value, count - 1, sum + (vector[count - 1] == 0 ? 0 : value));


// Calculated values

box_width =
  sumup_left(remotes_widths, len(remotes_widths))
  + sumup_value_when_vector_not_null(remotes_widths, abs(wall_thickness), len(remotes_widths));
    
hook_mounting_height = abs(box_height) / 2 + abs(wall_thickness);

hook_total_height = abs(hook_height) + hook_mounting_height;

hook_separation_margin = 2 * abs(wall_thickness);

hook_separation_height =
  hook_total_height > hook_fixure_height
  ? hook_total_height
  : hook_fixure_height;


// Modules

module box(name, wall, width, depth, height, text_size, font) {
  translate([width / 2, 0, 0])
  difference() {
    cube([width + 2 * wall, depth + 2 * wall, height + 2 * wall], center = true);
    translate([0, 0, wall]) cube([width, depth, height + wall], center = true);
    translate([0, -depth / 2 -wall / 2, 0]) {
      rotate([90, 0, 0]) {
        linear_extrude(wall) {
          text(name, size = text_size, font = font, halign = "center", valign="center");
        }
      }
    }
  }
}

module hook(width, depth, height, fixure_height, mounting_height, wall) {
  rotate([90, 0, 90]) {
    linear_extrude(width) {
      polygon([
        [0, 0],
        [0, height + mounting_height + wall],
        [wall * 2 + depth, height + mounting_height + wall],
        [wall * 2 + depth, height + mounting_height - fixure_height],
        [wall + depth, height + mounting_height - fixure_height],
        [wall + depth, height + mounting_height],
        [wall, height + mounting_height],
        [wall, 0]
      ]);
    }
  }
  if (mounting_height > 0) {
    translate([0, - wall, mounting_height])
    cube([width, wall, wall]);
  }
}

module tablet(width, depth, wall, border_height) {
  difference() {
    cube([width, depth, wall + border_height]);
    translate([wall, wall, wall]) {
      cube([width - 2 * wall, depth - 2 * wall, border_height]);
    };
  };
}


// Macros

module hook_with_position(x = 0) {
  rotate([0, hook_type == "printable" ? -90 : 0, 0])
  translate([
    hook_type == "printable" ? - abs(box_height) / 2 - abs(wall_thickness) * 2 : 0,
    0,
    hook_type == "printable" ? - box_width : 0
  ])
  translate([
    hook_type == "printable" ? -x + abs(wall_thickness) : 0,
    hook_type == "printable" ? 2 * abs(wall_thickness) : 0,
    hook_type == "printable" && x > 0 ? hook_separation_height + hook_separation_margin : 0
  ])
  translate([
    x,
    abs(box_depth) / 2 + (hook_type == "unibody" ? 0 : abs(wall_thickness)),
    (hook_type == "unibody" ? hook_mounting_height : 0)
  ]) {
    hook(
      abs(hook_width),
      abs(hook_depth),
      abs(hook_height),
      abs(hook_fixure_height),
      hook_type == "unibody" ? 0 : hook_mounting_height,
      abs(wall_thickness)
    );
  }
}


// Main

if (display_box) {
  for(i = [0:len(remotes_widths) - 1]) {
    translate([
      sumup_left(remotes_widths, i) + sumup_value_when_vector_not_null(remotes_widths, abs(wall_thickness), i),
      0,
      0
    ]) {
      if (remotes_widths[i] > 0) {
        box(remotes_names[i], abs(wall_thickness), abs(remotes_widths[i]), abs(box_depth), abs(box_height), abs(text_size), font);
      }
    }
  }
}

if (display_hook_left) {
  hook_with_position(-abs(wall_thickness));
}

if (display_hook_right) {
  hook_with_position(box_width - abs(hook_width));
}

if (display_tablet) {
  translate([
    - abs(wall_thickness),
    abs(box_depth) * 0.5 + (hook_type == "unibody" ? 0 : abs(wall_thickness)),
    hook_type == "printable"
      ? - abs(box_height) * 0.5 - abs(wall_thickness)
      : abs(hook_height) + abs(hook_mounting_height) + abs(wall_thickness)
  ])
  translate([0, 0, hook_type == "unibody" ? - abs(wall_thickness) : 0])
  translate([0, hook_type == "printable" ? abs(hook_depth) + 5 * abs(wall_thickness) : 0, 0])
  tablet(
    abs(box_width) + abs(wall_thickness),
    abs(hook_depth) + 2 * abs(wall_thickness),
    abs(wall_thickness),
    abs(tablet_frame_height)
  );
}
