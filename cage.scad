
use <snap-pins.scad>;

PART = "cage"; // ["cage", "rail", "fan_shroud", "fan_mounting_pin", "test"]
// Select the grill style for the fan shroud.  Use custom and replace the fan_cover_custom.stl with your custom grill (see README.md for more details.)  Select none for an empty hole with an externally mounted grill cover.
grill_style = "fan_cover_web.stl"; // [fan_cover_crosshair.stl:crosshair,fan_cover_crosshex.stl:crosshex,fan_cover_grid.stl:grid,fan_cover_teardrop.stl:teardrop,fan_cover_web.stl:web,fan_cover_custom.stl:custom,fan_cover_none.stl:none]

include_fan_mount = true;
include_cd_bay_slots = false; // If the bay in your case has little shelf rails for drives to sit on

fan_grill_cover_height = 2;
shroud_h = 26;
shroud_inset = 11;
hdd_count = 5; // Max of 5
// Gap to leave between drives for airflow, can be larger with fewer drives
hdd_spacing = 0.5;

// How much tolerance to add to the prints. 
// This primarily impacts the rail channels, but also has some other impacts such as 
// the pins on the rail that plug into the hard drive, as well as the harddrive dimensions themselves
tolerance = .2;

// See https://toshiba.semicon-storage.com/us/storage/support/faq/storage-holes.html
// SFF-8301 3.5" Drive Specs
// Tolerances +-0.25mm unless otherwise specified
// Commented values are unused by this program, but useful for understanding the spec
hdd_a1  =  26.10 + 0; // Max Height - Can also be 17.8mm or 42.0mm
hdd_a2  = 147.00 + 0; // Max Length
hdd_a3  = 101.60 + 0; // Max Width
//hdd_a4  =  95.25 + 0; // Width of underside holes
hdd_a5  =   3.18 + 0; // Underside hole distance from close edge
//hdd_a6  =  44.45 + 0; // Distance between underside mounting holes closest to the connector and the middle underside mounting holes
hdd_a7  =  41.28 + 0; // Distance between the edge of the drive/connector and the closest row of underside mounting holes - +- 0.5mm
hdd_a8  =  28.50 + 0; // Distance between the edge of the drive and the closest side mounting hole - +- 0.5mm
hdd_a9  = 101.60 + 0; // Distance between the two side mounting holes
hdd_a10 =   6.35 + 0; // Distance from the bottom of the drive to the side mounting holes - +- 0.5mm
//hdd_a13 =  76.20 + 0; // Distance between the set of underside mounting holes closes to the edge of the drive/connector and farthest (3rd) row of underside mounting holes

// See SFF-8551
// All dimensions have 0.25mm tolerance
cd_a1  =  41.53 + 0; // Case Height
cd_a2  =  42.30 + 0; // Bezel Height
//cd_a3  = 148.00 + 0; // Bezel Width
cd_a4  = 202.80 + 0; // Case Length
cd_a5  = 146.05 + 0; // Case Width
//cd_a6  = 139.70 + 0; // Width of underside mounting holes
//cd_a7  =   3.18 + 0; // Underside hole distance from close edge
//cd_a8  =  79.25 + 0; // Distance lengthwise between the two sets of underside mounting holes
//cd_a9  =  47.40 + 0; // Distance from bezel to closest underside mounting holes
//cd_a10 =  47.40 + 0; // Distance from bezel to closest side mounting holes
cd_a11 =  79.25 + 0; // Distance lengthwise between the two sets of side mounting holes
cd_a13 =  10.00 + 0; // Distance from bottom to lower side mounting holes
cd_a14 =  21.84 + 0; // Distance from bottom to upper side mounting holes (optional)
cd_a16 =   6.50 + 0; // Bezel Length (inc eject button)
//cd_a17 =   5.00 + 0; // Bezel Length (exc eject button)

hdd_h = hdd_a1 + tolerance;
hdd_w = hdd_a3 + tolerance;
hdd_l = hdd_a2 + tolerance;

cd_bays = 3; // Set here for documentation; but because the harddrives are vertically mounted, this is the only sensical value
cd_cage_tolerance = -1;

cage_h = (cd_a2 * cd_bays) + cd_cage_tolerance;
cage_w = cd_a5 + cd_cage_tolerance; 
cage_l = hdd_a2 - hdd_a7 + 20; // The distance between the rear of the drive and the frontmost mounting holes, plus some extra
cage_walls = 5; // Thinnest portion of the side walls, aside from cable routing cutouts

total_rail_height = 8 + 0;

// pin connector settings.
snap_pin_pointed = 1;
snap_pin_fins = 1;
snap_pin_preload = 0.2;
snap_pin_clearance = 0.2;
snap_pin_printable = 1;
snap_pin_shadow_socket = 1;
snap_pin_spacing = 20;
snap_pin_cylinder_thickness = 2;

snap_pin_length = 6;
snap_pin_diameter = 3.2;
snap_pin_snap = 0.4;
snap_pin_snapDepth = 1.2;
snap_pin_thickness = 1.0;

$fn=$preview ? 18 : 120;

module vertical_hdd(hdd_pocket_height) {
    translate([hdd_pocket_height-hdd_spacing, 0, 0]) {
        rotate([0, -90, 0]) {
            cube([hdd_w, hdd_l, hdd_pocket_height]);
            translate([-total_rail_height + 0.01, 0, hdd_a10])
                rotate([0, 90, 0])
                    rail(false);
            translate([hdd_w + total_rail_height - 0.01, 0, hdd_a10])
                rotate([0, -90, 0])
                    rail(false);
        }
    }
}

module caged_hdds() {
    hdds_area = cage_w - (cage_walls * 2);
    hdd_area = hdds_area / hdd_count;
    
    assert(hdd_area >= hdd_h+hdd_spacing)
    for(i = [0 : 1 : hdd_count-1 ]) {
        translate([i * (hdd_area-(1-hdd_spacing)), -1, (cage_h - hdd_w) / 2])
            vertical_hdd(hdd_area);
    }
}

module rail_spacing() {
    rail = 4; // Depth of slot
    rail_s = 3; // Width of slot
    offset = sqrt(2 * rail * rail)/2 - rail_s / 2;

    translate([0, 1, -rail_s/2])
        rotate([0, 45, 0])
            cube([rail, cage_l*2, rail], center=true);
    translate([-offset, 1, 0])
        cube([rail_s, cage_l * 2, rail_s], center=true);
    translate([offset, 1, 0])
        cube([rail_s, cage_l * 2, rail_s], center=true);
    translate([0, 1, rail_s/2])
        rotate([0, 45, 0])
            cube([rail, cage_l*2, rail], center=true);
}

module fan_mounting_sockets() {
    center_w = cage_w/2;
    center_h = cage_h/2;
    corner_w = cage_w/2 - 4;
    corner_h = cage_h/2 - 8;
    snap_pin_radius = snap_pin_diameter / 2;
    cylinder_r = snap_pin_radius + snap_pin_snap + snap_pin_cylinder_thickness;
    cylnder_h = snap_pin_length + snap_pin_cylinder_thickness;
    for(w = [-1 : 2 : 1]) {
        x = center_w + corner_w * w;
        for (h = [-1 : 2 : 1]) {
            z = center_h + corner_h * h;
            translate([x, 0, z])
                rotate([-90, 0, 0])
                    showSocket(radius = snap_pin_radius,
                                length = snap_pin_length,
                                snapDepth = snap_pin_snapDepth,
                                snap = snap_pin_snap,
                                thickness = snap_pin_thickness,
                                pointed = snap_pin_pointed,
                                fixed = 0,
                                fins = false,
                                printable = false,
                                cylinderRadius = cylinder_r,
                                cylinderHeight = cylnder_h);
        }
    }
}

module cage() {
    cut = 7; // Corner chamfer
    difference() {
        // main area
        cube([cage_w, cage_l, cage_h]);
        // cut off harsh corners
        translate([0, cut, 0])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([cage_w, cut, 0])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([0, cut, cage_h])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([cage_w, cut, cage_h])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        // cut out socket for mounting pin for fan
        if (include_fan_mount) {
            fan_mounting_sockets();
        }
        // cut out space for cd bay rails
        if (include_cd_bay_slots){
            translate([cage_w, 0, cage_h*1/3 + 1.5])
                rail_spacing();
            translate([cage_w, 0, cage_h*2/3 + 1.5])
                rail_spacing();
            translate([0, 0, cage_h*1/3 + 1.5])
                rail_spacing();
            translate([0, 0, cage_h*2/3 + 1.5])
                rail_spacing();
        }
        
        translate([cage_walls, 0, 0])
            caged_hdds();
        
        // cut out 5.25" drive mounting holes.
        mounting_d = 3.0;
        for(drive = [0 : 1 : (cd_bays - 1)]) {
            drive_offset = drive * (cd_a2 + .5);
            for(set = [0 : 1 : 1]) {
                set_offset = cage_l - shroud_inset - (cd_a11 * set);
                for(mount = [0 : 1 : 1]) {
                    mount_offset = mount ? cd_a13 : cd_a14;
                    translate([-10, set_offset, drive_offset + mount_offset]) {
                        rotate([0, 90, 0]) {
                            cylinder(20, d=mounting_d);
                        }
                    }
                    translate([-10 + cage_w, set_offset, drive_offset + mount_offset]) {
                        rotate([0, 90, 0]) {
                            cylinder(20, d=mounting_d);
                        }
                    }
                }
            }
        }
        // cut out routing for fan power cable.
        center_w = cage_w/2;
        center_h = cage_h/2;
        corner_w = (cage_w)/2 - cage_walls*1.5;
        corner_h = hdd_w/2;
//        for(w = [-1 : 2 : 1]) {
// No space on the other side for cable routing.
        for(w = [-1 : 2 : -1]) {
            x = center_w + corner_w * w;
            for(h = [-1 : 2 : 1]) {
                z = center_h + corner_h * h;
                translate([x, cage_l/2, z])
                    rotate([90, 0, 0])
                        cylinder(cage_l + 2, r=2.5, center=true);
            }
        }
    }
}

module pin(pin_diameter, pin_length) {
    point = pin_diameter / 2;
    body = pin_length - point;

    rotate([0, 90, 0]) {
        translate([0, 0, -point/2]) {
            cylinder(h = body, d=pin_diameter, center=true);
            translate([0, 0, body/2])
                sphere(d = pin_diameter);
        }
    }
}

module clip(height, length, width) {
    angle = 16;

    translate([-width/2, 0, -height]) {
        difference() {
            rotate([angle, 0, 0])
                cube([width, length, height]);
            translate([-1, -2, height])
                cube([width * 2, length * 2, height + 2]);
            translate([-1, -length + 0.01, -0.01])
                cube([width * 2, length, height + 2]);
        }
    }
}

module handle(length, width, height, rail_height, positive=true) {
    s1_l = length / 2;
    s2_angle = 40;
    // math to make the length of section 2 be half the
    // length of section 1.
    s2_l = (s1_l / 2) / cos(s2_angle);
    s2_x = s1_l;
    s3_l = (s1_l / 2);
    s3_z = (s1_l / 2) * tan(s2_angle);
    extension = s2_angle / 90 * height;

    clip_h = 1.5;
    clip_l = 6;
    clip_w = width / 3;

    if (positive == true) {
        translate([-width/2, s1_l, 0])
            cube([width, s1_l, height]);
        translate([0, s1_l + 1, 0.01])
            clip(clip_h, clip_l, clip_w);
        translate([width/2, s1_l, 0])
            rotate([s2_angle, 0, 180])
                cube([width, s2_l + extension, height]);
        translate([-width/2, 0, s3_z])
            cube([width, s3_l + extension, height]);
        translate([-width/2, 0, s3_z - 2 + height])
            cube([width, 1, height]);
    } else {
        trim = width/2+tolerance*2;
        translate([-clip_w/2, s1_l + .4, -9])
            cube([clip_w + .4, clip_l/2 + .4, 10]);
        translate([-width/2, 0, 0])
            difference() {
                cube([width, length + 8, rail_height]);
                translate([0, length, rail_height - width/2]) rotate([0, 0, 45])
                    cube([trim*2, trim, trim]);;
                translate([width, length, rail_height - width/2]) rotate([0, 0, 45])
                    cube([trim, trim*2, trim]);
            }
    }
}

module rail(positive=true) {
    pin_len = 6;
    pin_d = 2.7 - tolerance; //.1140 * 25.4;
    t = (positive) ? 0 : tolerance * 2;
    top_width = (pin_d > 3) ? pin_d + t: 3 + t;
    top_height=total_rail_height / 3 + t;
    bottom_width= (positive) ? (hdd_a10 - tolerance) * 2 : hdd_a10*2;
    bottom_height=total_rail_height * 2 / 3 + t;
    total_height=top_height + bottom_height;
    top_y = (top_height + bottom_height)/2;
    mid_y = top_y - top_height;
    bottom_y = -top_y;
    
    main_length = 4 * 25.4;
    main_rail_offset = hdd_a2 - hdd_a8 - hdd_a9 - pin_d/2;

    //  A_|_B
    //C /   \D
    //E|_____|F
    points = [
        [-top_width/2, top_y], // A
        [top_width/2, top_y], // B
        [bottom_width/2, mid_y], // D
        [bottom_width/2, bottom_y], // F
        [-bottom_width/2, bottom_y], // E
        [-bottom_width/2, mid_y], // C
    ];
    faces = [[0, 1, 2, 3, 4, 5]];

    echo("main_rail_offset = ", main_rail_offset);
    translate([0, main_rail_offset, -bottom_y]) {
        rotate([90, 0, 180]) 
            linear_extrude(main_length + pin_d)
                polygon(points, faces);
    }
    if (positive) {
        translate([0, main_rail_offset, total_height + pin_len/2-0.01]) {
        translate([0, pin_d/2, 0])
            rotate([0, -90, 0])
                pin(pin_d, pin_len);
        translate([0, main_length + pin_d/2, 0])
            rotate([0, -90, 0])
                pin(pin_d, pin_len);
        }
    }
    handle(main_rail_offset, bottom_width, 1.5, total_height, positive);
}

module fan_shroud() {
    shroud_t = 4;
    outer_wall = cage_h - 110;

    import(grill_style);
    translate([0, 0, shroud_h/2]) {
        difference() {
            cube([cage_w, cage_h, shroud_h], center=true);
            cube([119.99, 119.99, shroud_h + 10], center=true);
            translate([0, 0, fan_grill_cover_height + 2])
                cube([cage_w - outer_wall, 120, shroud_h], center=true);
            translate([-cage_w/2, -cage_h/2, shroud_h/2])
                rotate([-90, 0, 0])
                    fan_mounting_sockets();

            // Cut out finger grips to pull the shroud off
//            translate([-cage_w/2 - 0.01, 0, -shroud_h/2 + 2])
//                fan_shroud_grip();
//            translate([cage_w/2 + 0.01, 0, -shroud_h/2 + 2])
//                rotate([0, 0, 180])
//                    fan_shroud_grip();

            // Cut out space for the bay rails
            rail_spacing_z = cage_l - shroud_h/2 + shroud_inset - 2;
            translate([cage_w/2, cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([cage_w/2, -cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([-cage_w/2, cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([-cage_w/2, -cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();

            // cut off harsh corners
            cut=7;
            translate([cage_w/2, cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([cage_w/2, -cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([-cage_w/2, cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([-cage_w/2, -cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);

        }
        translate([-cage_w/2 + .1, 0, -shroud_h/2 + 2])
            fan_shroud_texture(2);
        translate([cage_w/2 - .1, 0, -shroud_h/2 + 2])
            fan_shroud_texture(1.75);
    }
}

module fan_mounting_pin() {
    showPin(radius = snap_pin_diameter/2,
            length = snap_pin_length,
            snapDepth = snap_pin_snapDepth,
            snap = snap_pin_snap,
            thickness = snap_pin_thickness,
            clearance = snap_pin_clearance,
            preload = snap_pin_preload,
            pointed = snap_pin_pointed,
            printable = snap_pin_printable,
            shadowSocket = snap_pin_shadow_socket);
}

module ridge_line(diameter, length) {
    end_offset = (length - diameter) / 2;
    rotate([90, 0, 0]) {
        translate([0, 0, end_offset]) sphere(d = diameter);
        cylinder(h = length - diameter, d = diameter, center=true);
        translate([0, 0, -end_offset]) sphere(d = diameter);
    }
}

// https://www.dummies.com/article/academics-the-arts/math/calculus/how-to-graph-an-ellipse-190940
module fan_shroud_texture(diameter) {
    a = 25.4;
    b = a / 2;
    a2 = a * a;
    b2 = b * b;
    // x^2 / a^2 + y^2 / b^2 = 1
    for(y = [0 : b/5 : b - .1]) {
        x = sqrt((1 - (y * y) / b2) * a2);
        echo ("y = ", y, "  ;  x = ", x);
        translate([0, 0, y]) ridge_line(diameter, x);
    }
}

module fan_shroud_grip() {
    grip_w = 25.4;
    grip_d = 4;
    x_scale = grip_d / 25.4;
    z_scale = (grip_w * 1.5) / grip_w;

    scale([x_scale, 1, z_scale]) {
        difference() {
            sphere(d=grip_w);
            translate([0, 0, -grip_w/2]) cube(grip_w, center=true);
            translate([-grip_w/2, 0, 0]) cube(grip_w, center=true);
        }
    }

}

if (PART == "cage") {
    translate([0, 0, cage_l])
        rotate([-90, 0, 0])
            cage();
} else if (PART == "rail") {
    translate([0, 0, total_rail_height*3/4])
        rotate([0, 90, 0])
            rail();
} else if (PART == "fan_shroud") {
    fan_shroud();
} else if (PART == "fan_mounting_pin") {
    fan_mounting_pin();
} else if (PART == "test") {
    translate([-cage_w/2 + 10, 0, cage_l]) {
        difference() {
            rotate([-90, 0, 0]) {
                cage();
            }
            translate([-hdd_h*1.25-5, -5, -cage_l-10])
                cube([cage_w+10, cage_h+10, cage_l+50]);
            translate([10, -10, -cage_l-10])
                cube([cage_w+10, cage_h - total_rail_height/2, cage_l + 50]);
        }
    }
    cage_face_h = 5;
    translate([0, cage_w, cage_face_h]) {
        rotate([0, 0, -90]){
            difference() {
                rotate([-90, 0, 0]) {
                    cage();
                }
                translate([-10, -10, -cage_l - 1]) {
                    cube([cage_w+20, cage_h+20, cage_l - cage_face_h + 1]);
                }
            }
        }
    }
    translate([cage_w / 2 - 10, cage_w * 1.6, -(shroud_h - 9)]) {
        rotate([0, 0, 90]) {
            difference() {
                fan_shroud();
                translate([-10, 5, (shroud_h - 10)/2])
                    cube([cage_w + 10, cage_h + 20, shroud_h - 8], center=true);
                translate([10, 0, shroud_h / 2])
                    cube([cage_w-10, cage_h+20, shroud_h + 5], center=true);
            }
        }
    }
    translate([20, 15, total_rail_height*3/4]) {
        rotate([0, 90, 0]) {
            rail();
        }
    }
    translate([40, 25, 0]) {
        fan_mounting_pin();
    }
} else {
    translate([0, 0, 30])
        handle(15.525, 15, 1.5, total_rail_height, true);
    translate([-20, 0, 30])
        translate([-total_rail_height, 0, 0])
            handle(15.525, 15, 1.5, total_rail_height, false);

    translate([cage_w/2 + 20, -4*2 - 20, cage_h/2])
        rotate([-90, 0, 0])
            fan_shroud();
    translate([20, 0, 0])
        cage();
    translate([0, 0, total_rail_height*3/4])
        rotate([0, 90, 0])
            rail();
    translate([-20, 0, hdd_a5 + (.1380 * 25.4)/2])
        rotate([0, 90, 0])
            rail(false);

}
