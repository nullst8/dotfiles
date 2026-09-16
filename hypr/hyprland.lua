local terminal = "kitty"
local fileManager = "kitty -e env EDITOR=nvim VISUAL=nvim yazi"
local fileManagerG = "pcmanfm"
local menu = "walker"
local browser = "zen-browser"
local power = "~/.dotfiles/scripts/power-menu.sh"
local pass = "~/.dotfiles/scripts/pass-walker"
local ss = "hyprshot -m output"
local ssr = "hyprshot --clipboard -m region"

hl.env("XCURSOR_THEME", "GoogleDot-Black")
hl.env("XCURSOR_SIZE", "18")
hl.env("GTK_ICON_THEME", "Tela-black")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("HYPRCURSOR_THEME", "GoogleDot-Black")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("swaync")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("qs -p ~/.config/wallpaperCarousel")
    hl.exec_cmd("~/.dotfiles/scripts/setrandwall")
    hl.exec_cmd(
        "sh -c 'mkdir -p ~/.local/state/hypr && echo 100 > ~/.local/state/hypr/gamma; pgrep -x hyprsunset >/dev/null || nohup hyprsunset --temperature 6500 --gamma_max 150 >/dev/null 2>&1 &'")
    -- WAYLAND_DISPLAY must be in the systemd user env for hypridle's
    -- ConditionEnvironment; start hypridle directly because
    -- graphical-session.target refuses manual start in this setup.
    hl.exec_cmd(
    "systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user start hypridle")
    -- Walker launcher backend (Walker itself is invoked on demand; its
    -- --gapplication-service daemon segfaults in 2.17.0, so don't use it)
    hl.exec_cmd("systemctl --user start elephant.service")
    -- AC/battery watcher: drops blur/shadows/animations + dims on battery
    hl.exec_cmd("systemctl --user start power-mode-watch.service")
end)

-- Stop session services when Hyprland exits, so a re-login doesn't leave
-- stale daemons from the previous session running.
hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop hypridle")
    hl.exec_cmd("systemctl --user stop elephant.service")
    hl.exec_cmd("systemctl --user stop power-mode-watch.service")
end)

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 4,
        border_size = 1,
        col = {
            active_border = "rgba(cba6f7ff)",
            inactive_border = "rgba(6c7086ff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },
    cursor = {
        no_hardware_cursors = true,
        enable_hyprcursor = false,
    },
    decoration = {
        rounding = 2,
        active_opacity = 0.85,
        inactive_opacity = 0.9,
        dim_inactive = false,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            noise = 0.01,
            contrast = 0.9,
            brightness = 1.0,
            vibrancy = 0.1,
        },
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(1a1a1acc)",
        },
    },
    animations = {
        enabled = true,
        bezier = {
            "overshot, 0.05, 0.9, 0.1, 1.05",
            "smoothOut, 0.36, 0, 0.66, -0.56",
            "smoothIn, 0.25, 1, 0.5, 1",
        },
        animation = {
            "windows, 1, 5, smoothOut, popin",
            "windowsOut, 1, 5, smoothIn, popin 80%",
            "fade, 1, 5, smoothOut",
            "workspaces, 1, 6, overshot, slidevert",
            "border, 1, 5, smoothOut",
        },
    },
    dwindle = {
        preserve_split = true,
    },
    binds = {
        allow_workspace_cycles = true,
    },
    master = {
        mfact = 0.5,
        new_status = "slave",
    },
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo = true,
        enable_swallow = true,
        swallow_regex = "^(Alacritty|kitty|footclient)$",
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_mouse_windowdragging = true,
        -- Allow a fresh lock to be created/restored after a stale lock state
        -- (e.g. after suspend/resume), so the resume reconciler can re-lock.
        allow_session_lock_restore = true,
    },
    render = {
        direct_scanout = true,
    },
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        accel_profile = "flat",
        left_handed = true,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

local high_opacity_apps = {
    "^(steam_proton)$",
    "^(virt-manager)$",
    "^(burp-StartBurp)$",
    "^(gimp)$",
    "^(DBeaver)$",
    "^(obsidian)$",
    "^(org.wireshark.Wireshark)$",
    "^(libreoffice-.*)$",
    "^(org.gnome.Evince)$",
    "^(mpv)$",
}

for _, class in ipairs(high_opacity_apps) do
    hl.window_rule({
        name = class .. "-opacity",
        match = { class = class },
        opacity = "1 1",
    })
end

hl.window_rule({
    name = "mpv-noblur-noshadow",
    match = { class = "^(mpv)$" },
    no_blur = true,
    no_shadow = true,
})

hl.window_rule({
    name = "xwaylandvideobridge-opacity",
    match = { class = "^(xwaylandvideobridge)$" },
    opacity = "0 0",
})

hl.window_rule({
    name = "xwaylandvideobridge-noblur",
    match = { class = "^(xwaylandvideobridge)$" },
    no_blur = true,
})

hl.window_rule({
    name = "xwaylandvideobridge-noanim",
    match = { class = "^(xwaylandvideobridge)$" },
    no_anim = true,
})

hl.window_rule({
    name = "xwaylandvideobridge-nofocus",
    match = { class = "^(xwaylandvideobridge)$" },
    no_focus = true,
})

hl.window_rule({
    name = "xwaylandvideobridge-maxsize",
    match = { class = "^(xwaylandvideobridge)$" },
    max_size = { 1, 1 },
})

hl.window_rule({
    name = "xwaylandvideobridge-noinitfocus",
    match = { class = "^(xwaylandvideobridge)$" },
    no_initial_focus = true,
})

hl.window_rule({
    name = "zen-workspace",
    match = { class = "^(zen)$" },
    workspace = 2,
})

hl.window_rule({
    name = "bat-threshold-popup",
    match = { class = "^bat-threshold$" },
    float = true,
    pin = true,
    center = true,
    fullscreen = false,
    border_size = 2,
    opacity = "1.0 override",
})

hl.window_rule({
    name = "perf-mode-popup",
    match = { class = "^perf-mode$" },
    float = true,
    pin = true,
    center = true,
    fullscreen = false,
    border_size = 2,
    opacity = "1.0 override",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.dotfiles/scripts/toggle-grayscale.sh"))

hl.bind("Print", hl.dsp.exec_cmd("grim ~/ss/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/ss/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png"))
hl.bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd("grim ~/ss/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png"))
hl.bind(mainMod .. " + SHIFT + SEMICOLON", hl.dsp.exec_cmd(ssr))

hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("pkill Hyprland"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManagerG))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(power))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/wallpaperCarousel/wallpaper-carousel toggle"))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.exec_cmd("~/.config/wallpaperCarousel/wallpaper-carousel cycleNext"))
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.exec_cmd("~/.config/wallpaperCarousel/wallpaper-carousel cyclePrevious"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("~/.dotfiles/quickshell-lockscreen/lock.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(pass))

hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

hl.bind(mainMod .. " + H", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + L", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { repeating = true })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { repeating = true })

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.layout("swapwithmaster"))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness-ctl.sh up"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness-ctl.sh down"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + UP", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+"), { repeating = true })
hl.bind(mainMod .. " + DOWN", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"), { repeating = true })

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("swaync-client --close-latest"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("swaync-client -t"))
