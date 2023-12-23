/*

Mostly accurate for 20 pins or less for most IC models.
This tool has cust first and last pin shaving off a bit of the tab,
as that was like the reference I had, not all manf. do this.

The loft angle for the IC package is determined not by the dimenions of the top of the package
but by a const 98% scale burried in the code, this is accurate enough for 8-14 pin
packages to "look good" but creates a lofted angle that is extreme for large packages
like the 64 pin 68000

I also don't cut out a notch or a have a pin 1 identifier, I was happy enough for this..

The license is WTFPL - http://www.wtfpl.net/

PLEASE use this, lol I don't know why I created it... I was just noodling around
it'd be cool if you dropped me a line telling me you used it or passed along some
merges, but not required... have fun.


        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                    Version 2, December 2004 

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 

 Everyone is permitted to copy and distribute verbatim or modified 
 copies of this license document, and changing it is allowed as long 
 as the name is changed. 

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT THE FUCK YOU WANT TO.
*/

module ic() {
  ic_body_thickness = 3.5;
  ic_body_width = 6.4;

  pin_count = 20;
  pin_spacing = 2.54;

  pin_ofs = 0.87;

  leg_angle = 15;

  leg_offset_from_body = 0.5;

  ic_body_length = pin_ofs + pin_ofs + (pin_spacing * (pin_count/2-1));

  // leg thickness
  thickness = 0.25;
  
  // width of portion coming from the body
  upper_width = thickness*5.6;
  // width of through hole pin portion
  lower_width = thickness*2;

  lower_length_top = upper_width * 1.2;  
  lower_length = 3.0;
  
  module ic_body_half() {
    linear_extrude(height=ic_body_thickness/2, scale=0.98) {
      square(size=[ic_body_length, ic_body_width], center=true);
    }
  }

  module ic_body() {
    union() {
      ic_body_half();  // First half
      rotate([180, 0, 0]) ic_body_half();  // Second half flipped and positioned
    }
  }

  module ic_leg() {
    scale_factor = lower_width / upper_width;
    // Base section (Box)
    translate([0, -leg_offset_from_body/2, 0]) {
      cube([upper_width, leg_offset_from_body, thickness], center=true);
    }

    // Cylinder (Bend)
    translate([0, -leg_offset_from_body, 0]) {
      rotate([0, 90, 0]) { // Rotating to align along the Y-axis
        cylinder(h=upper_width, r=thickness/2, center=true, $fn=32);
      }
    }

    translate([0, -leg_offset_from_body, 0])  {
      rotate([-leg_angle,0,0]) {
        translate([0, 0, -lower_length_top/2])  {
          cube([upper_width, thickness, lower_length_top], center=true);
        }

        translate([0, 0, -lower_length_top])  {
          rotate([0,180,0]) {
            linear_extrude(height = .2, scale = [scale_factor, 1]) {
              square([upper_width, thickness], center = true);
            }
          }
        }

        translate([0,0, -lower_length_top-lower_length/2]) {
          cube([lower_width, thickness, lower_length], center= true);
        }
      }
    }
  }

  module leg_array() {
    difference() {
      union() {
        for (i = [0 : pin_count/2-1]) {
          translate([i * pin_spacing, 0, 0])
          ic_leg();
        }
      }
      translate([-upper_width/2-(lower_width/2), -ic_body_width+1, -lower_length-lower_length_top-thickness])
        cube([upper_width/2, ic_body_width, lower_length+lower_length_top+thickness+thickness]);

      translate([(pin_count/2-1)*pin_spacing+lower_width/2, -ic_body_width+1, -lower_length-lower_length_top-thickness])
        cube([upper_width/2, ic_body_width, lower_length+lower_length_top+thickness+thickness]);
    }      
  }

  module legset() {
    x = -ic_body_width/2;
    left_ofs = -((pin_count/4) * pin_spacing) + (pin_spacing/2);
    translate([left_ofs, x, 0]) {  
      leg_array();
    }    
  }
  union() {
    ic_body();
    legset();
    rotate([0,0,180]) legset();
  }
}

ic();