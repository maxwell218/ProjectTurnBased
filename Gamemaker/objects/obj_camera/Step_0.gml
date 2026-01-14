/// @description Move the camera

move_camera();

// Smooth follow
x = lerp(x, target_x, 0.15); // 0.15 = smoothing factor (tweak)
y = lerp(y, target_y, 0.15);

// Apply new camera position
camera_set_view_pos(view_camera[0], round(x), round(y));