local terminal = "kitty"
local fileManager = "kitty -e env EDITOR=nvim VISUAL=nvim yazi"
local fileManagerG = "pcmanfm"
local menu = "walker"
local browser = "zen-browser"
local power = "~/.dotfiles/scripts/power-menu.sh"
-- Falls back to brightnessctl so the keys still work if the script is missing.
local brightnessScript = "~/.config/hypr/scripts/brightness-ctl.sh"
local function brightness(dir)
    local fallback = "brightnessctl set 5%" .. (dir == "up" and "+" or "-")
    return hl.dsp.exec_cmd("if [ -x " .. brightnessScript .. " ]; then " .. brightnessScript .. " " .. dir
        .. "; else " .. fallback .. "; fi")
end
-- Volume goes through SwayOSD so the on-screen bar shows (max 150%, as before).
local volUp = "swayosd-client --max-volume 150 --output-volume +3"
local volDown = "swayosd-client --max-volume 150 --output-volume -3"
local pass = "~/.dotfiles/scripts/pass-walker"
local ssr = "hyprshot --clipboard -m region"
-- Screenshot dir is created on demand: if it is missing, grim used to fail
-- silently (no notification) and the keybind looked completely dead.
local ssDir = "~/pics/ss"
local ssFull = "mkdir -p " .. ssDir .. " && grim " .. ssDir
    .. "/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png"
local ssRegion = "mkdir -p " .. ssDir .. " && grim -g \"$(slurp)\" " .. ssDir
    .. "/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png"

hl.env("XCURSOR_THEME", "GoogleDot-Black")
hl.env("XCURSOR_SIZE", "18")
hl.env("GTK_ICON_THEME", "Tela-black")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("HYPRCURSOR_THEME", "GoogleDot-Black")
hl.env("HYPRCURSOR_SIZE", "18")

-- Session services are restarted (not started) so a unit that outlived the
-- previous Hyprland session picks up the new instance's environment.
local session_services = { "hypridle", "elephant.service", "power-mode-watch.service" }

hl.on("hyprland.start", function()
    -- Must come first, and must be the only thing that starts gnome-keyring.
    -- greetd never runs pam_gnome_keyring.so, so the login keyring would stay
    -- locked all session and Secret Service callers would hang or fail. The
    -- systemd units are masked so this isn't a race with a second daemon.
    hl.exec_cmd("~/.dotfiles/scripts/keyring-unlock.sh")
    hl.exec_cmd("swayosd-server")
    for _, cmd in ipairs({
        "waybar",
        "blueman-applet",
        "swaync",
        "nm-applet",
        "awww-daemon",
        "qs -p ~/.config/wallpaperCarousel",
        "~/.dotfiles/scripts/setrandwall",
        "sh -c 'mkdir -p ~/.local/state/hypr && echo 100 > ~/.local/state/hypr/gamma; pgrep -x hyprsunset >/dev/null || nohup hyprsunset --temperature 6500 --gamma_max 150 >/dev/null 2>&1 &'",
    }) do
        hl.exec_cmd(cmd)
    end
    -- WAYLAND_DISPLAY must be in the systemd user env for hypridle's
    -- ConditionEnvironment; start hypridle directly because
    -- graphical-session.target refuses manual start in this setup.
    -- Walker itself is invoked on demand (its --gapplication-service daemon
    -- segfaults in 2.17.0); elephant is its backend.
    -- power-mode-watch drops blur/shadows/animations + dims on battery.
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user restart "
        .. table.concat(session_services, " "))
end)

-- Stop session services when Hyprland exits, so a re-login doesn't leave
-- stale daemons from the previous session running.
hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop " .. table.concat(session_services, " "))
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
        -- Adaptive sync only for fullscreen apps (panel reports vrr_capable, 40-60Hz).
        vrr = 2,
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

hl.window_rule({
    name = "opaque-apps",
    match = {
        class = "^(steam_proton|virt-manager|burp-StartBurp|gimp|DBeaver|obsidian|org\\.wireshark\\.Wireshark|libreoffice-.*|org\\.gnome\\.Evince|mpv)$",
    },
    opacity = "1 1",
})

hl.window_rule({
    name = "mpv-noblur-noshadow",
    match = { class = "^(mpv)$" },
    no_blur = true,
    no_shadow = true,
})

hl.window_rule({
    name = "xwaylandvideobridge",
    match = { class = "^(xwaylandvideobridge)$" },
    opacity = "0 0",
    no_blur = true,
    no_anim = true,
    no_focus = true,
    max_size = { 1, 1 },
    no_initial_focus = true,
})

hl.window_rule({
    name = "zen-workspace",
    match = { class = "^(zen)$" },
    workspace = 2,
})

hl.window_rule({
    name = "claude-ai",
    match = { class = "^(com.anthropic.Claude)$" },
    workspace = 7,
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

-- Touchpad: 3-finger horizontal swipe switches workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.dotfiles/scripts/toggle-grayscale.sh"))

hl.bind("Print", hl.dsp.exec_cmd(ssFull))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(ssRegion))
hl.bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd(ssFull))
hl.bind(mainMod .. " + SHIFT + SEMICOLON", hl.dsp.exec_cmd(ssr))

hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exit())
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

hl.bind("XF86MonBrightnessUp", brightness("up"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", brightness("down"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(volUp),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(volDown),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + UP", hl.dsp.exec_cmd(volUp), { repeating = true })
hl.bind(mainMod .. " + DOWN", hl.dsp.exec_cmd(volDown), { repeating = true })

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("swaync-client --close-latest"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("swaync-client -t"))
