{-# OPTIONS_GHC -Wno-deprecations #-}
-- Main
import XMonad
import System.IO (hPutStrLn)
import System.Exit
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.GridSelect


-- Data
import Data.Semigroup
import Data.Monoid
import Data.Maybe (fromJust, isJust)
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, isDialog, doCenterFloat, doRectFloat)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedActions
import XMonad.Util.Scratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import Graphics.X11.ExtraTypes.XF86

------------------------------------------------------------------------
-- My Strings
------------------------------------------------------------------------
myTerminal :: String
myTerminal = "alacritty"          -- Default terminal

myDmenu :: String
myDmenu = "dmenu_run -b -i -nb '#2e3440' -nf '#a37acc' -sb '#55b4d4' -sf '#212733' -fn 'NotoMonoRegular:bold:pixelsize=11' -h 22" -- Dmenu

myModMask :: KeyMask
myModMask = mod4Mask              -- Super Key (--mod4Mask= super key --mod1Mask= alt key --controlMask= ctrl key --shiftMask= shift key)

myBorderWidth :: Dimension
myBorderWidth   = 0             -- Window border

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

------------------------------------------------------------------------
-- Colors
------------------------------------------------------------------------
myNormColor :: String       -- Border color of normal windows
myNormColor   = "#73cffe" 

myFocusColor :: String      -- Border color of focused windows
myFocusColor  = "#fe79c5"  


------------------------------------------------------------------------
-- Space between Tiling Windows
------------------------------------------------------------------------
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
--mySpacing i = spacingRaw False (Border 10 10 10 10) True (Border 10 10 10 10) True

------------------------------------------------------------------------
-- Layout Hook
------------------------------------------------------------------------
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts full
               $ mkToggle (NBFULL ?? NOBORDERS ?? MIRROR ?? EOT) myDefaultLayout
             where
               myDefaultLayout =      withBorder myBorderWidth grid
                                  ||| full
                                  ||| tall
                                  ||| mirror

------------------------------------------------------------------------
-- Tiling Layouts
------------------------------------------------------------------------
grid     = renamed [Replace "<fc=#95e6cb>Grid</fc>"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 5
           $ mkToggle (single MIRROR)
           -- $ Grid (16/10)
           $ ResizableTall 1 (3/100) (1/2) []  
tall     = renamed [Replace "<fc=#95e6cb>Tall</fc>"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 8
           $ mySpacing 5
           $ ResizableTall 1 (3/100) (1/2) []                
mirror     = renamed [Replace "<fc=#95e6cb>Mirror</fc>"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 6
           $ mySpacing 5
           $ Mirror  
           $ ResizableTall 1 (3/100) (1/2) []            
full     = renamed [Replace "<fc=#95e6cb>Full</fc>"]
           $ Full                     

------------------------------------------------------------------------
-- Workspaces
------------------------------------------------------------------------
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
    doubleLts x = [x]
myWorkspaces :: [String]
myWorkspaces = clickable . (map xmobarEscape)
    $ [" <fn=5>\61713</fn> ", " <fn=5>\61713</fn> ", " <fn=5>\61713</fn> ", " <fn=5>\61713</fn> ", " <fn=5>\61713</fn> "]
  where
    clickable l = ["<action=xdotool key super+" ++ show (i) ++ "> " ++ ws ++ "</action>" | (i, ws) <- zip [1 .. 5] l]
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


-----------------------------------------------------------------------
-- Start of Distrotube's config.
-----------------------------------------------------------------------

myNavigation :: TwoD a (Maybe a)
myNavigation = makeXEventhandler $ shadowWithKeymap navKeyMap navDefaultHandler
 where navKeyMap = M.fromList [
          ((0,xK_Escape), cancel)
         ,((0,xK_Return), select)
         ,((0,xK_slash) , substringSearch myNavigation)
         ,((0,xK_Left)  , move (-1,0)  >> myNavigation)
         ,((0,xK_h)     , move (-1,0)  >> myNavigation)
         ,((0,xK_Right) , move (1,0)   >> myNavigation)
         ,((0,xK_l)     , move (1,0)   >> myNavigation)
         ,((0,xK_Down)  , move (0,1)   >> myNavigation)
         ,((0,xK_j)     , move (0,1)   >> myNavigation)
         ,((0,xK_Up)    , move (0,-1)  >> myNavigation)
         ,((0,xK_k)     , move (0,-1)  >> myNavigation)
         ,((0,xK_y)     , move (-1,-1) >> myNavigation)
         ,((0,xK_i)     , move (1,-1)  >> myNavigation)
         ,((0,xK_n)     , move (-1,1)  >> myNavigation)
         ,((0,xK_m)     , move (1,-1)  >> myNavigation)
         ,((0,xK_space) , setPos (0,0) >> myNavigation)
         ]
       navDefaultHandler = const myNavigation

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                (0x28,0x2c,0x34) -- lowest inactive bg
                (0x28,0x2c,0x34) -- highest inactive bg
                (0xc7,0x92,0xea) -- active bg
                (0xc0,0xa7,0x9a) -- inactive fg
                (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_navigate    = myNavigation
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 180
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

runSelectedAction' :: GSConfig (X ()) -> [(String, X ())] -> X ()
runSelectedAction' conf actions = do
    selectedActionM <- gridselect conf actions
    case selectedActionM of
        Just selectedAction -> selectedAction
        Nothing -> return ()

-- gsCategories =
--   [ ("Games",      spawnSelected' gsGames)
--   --, ("Education",   spawnSelected' gsEducation)
--   , ("Internet",   spawnSelected' gsInternet)
--   , ("Multimedia", spawnSelected' gsMultimedia)
--   , ("Office",     spawnSelected' gsOffice)
--   , ("Settings",   spawnSelected' gsSettings)
--   , ("System",     spawnSelected' gsSystem)
--   , ("Utilities",  spawnSelected' gsUtilities)
--   ]

gsCategories =
  [ ("Games",      "xdotool key super+alt+1")
  , ("Education",  "xdotool key super+alt+2")
  , ("Internet",   "xdotool key super+alt+3")
  , ("Multimedia", "xdotool key super+alt+4")
  , ("Office",     "xdotool key super+alt+5")
  , ("Settings",   "xdotool key super+alt+6")
  , ("System",     "xdotool key super+alt+7")
  , ("Utilities",  "xdotool key super+alt+8")
  ]

gsGames =
  [ ("0 A.D.", "0ad")
  , ("Battle For Wesnoth", "wesnoth")
  , ("OpenArena", "openarena")
  , ("Sauerbraten", "sauerbraten")
  , ("Steam", "steam")
  , ("Unvanquished", "unvanquished")
  , ("Xonotic", "xonotic-glx")
  ]

gsEducation =
  [ ("GCompris", "gcompris-qt")
  , ("Kstars", "kstars")
  , ("Minuet", "minuet")
  , ("Scratch", "scratch")
  ]

gsInternet =
  [ ("Discord", "discord")
  , ("Chromium", "chromium")
  , ("Firefox", "firefox")
  , ("LBRY App", "lbry")
  , ("Qutebrowser", "qutebrowser")
  , ("Transmission", "transmission-gtk")
  ]

gsMultimedia =
  [ ("Audacity", "audacity")
  , ("Blender", "blender")
  , ("Deadbeef", "deadbeef")
  , ("Kdenlive", "kdenlive")
  , ("OBS Studio", "obs")
  , ("VLC", "vlc")
  ]

gsOffice =
  [ ("Document Viewer", "evince")
  , ("LibreOffice", "libreoffice")
  , ("LO Base", "lobase")
  , ("LO Calc", "localc")
  , ("LO Draw", "lodraw")
  , ("LO Impress", "loimpress")
  , ("LO Math", "lomath")
  , ("LO Writer", "lowriter")
  ]

gsSettings =
  [ ("ARandR", "arandr")
  , ("ArchLinux Tweak Tool", "archlinux-tweak-tool")
  , ("Customize Look and Feel", "lxappearance")
  ]

gsSystem =
  [ ("Alacritty", "alacritty")
  , ("Bash", (myTerminal ++ " -e bash"))
  , ("Htop", (myTerminal ++ " -e htop"))
  , ("Fish", (myTerminal ++ " -e fish"))
  , ("PCManFM", "pcmanfm")
  , ("VirtualBox", "virtualbox")
  , ("Virt-Manager", "virt-manager")
  , ("Zsh", (myTerminal ++ " -e zsh"))
  ]

gsUtilities =
  [ ("Emacs", "emacs")
  , ("Emacsclient", "emacsclient -c -a 'emacs'")
  , ("Nitrogen", "nitrogen")
  ]

-----------------------------------------------------------------------
-- End of Distrotube's config.
-----------------------------------------------------------------------


------------------------------------------------------------------------
-- Scratch Pads
------------------------------------------------------------------------
myScratchPads :: [NamedScratchpad]
myScratchPads =
  [
      NS "discord"              "discord"              (appName =? "discord")                   (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "thunderbird"          "thunderbird"          (appName =? "Mail")                      (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "ravenreader"          "ravenreader"          (appName =? "raven reader")              (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "pcmanfm"              "pcmanfm"              (appName =? "pcmanfm")                   (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "discord"              "discord"              (appName =? "discord")                   (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "spotify"              "spotify"              (appName =? "spotify")                   (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "nautilus"             "nautilus"             (className =? "Org.gnome.Nautilus")      (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "ncmpcpp"              launchMocp             (title =? "ncmpcpp")                     (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "whatsapp-for-linux"   "whatsapp-for-linux"   (appName =? "whatsapp-for-linux")        (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
    , NS "terminal"             launchTerminal         (title =? "scratchpad")                  (customFloating $ W.RationalRect 0.15 0.15 0.7 0.7)
  ]
  where
    launchMocp     = myTerminal ++ " -t ncmpcpp -e ncmpcpp"
    launchTerminal = myTerminal ++ " -t scratchpad"

------------------------------------------------------------------------
-- Custom Keys
------------------------------------------------------------------------
myKeys :: [(String, X ())]
myKeys =
    -- /START_KEYS/
    [
    -- Xmonad
        ("M-S-r", spawn "xmonad --recompile && xmonad --restart")         -- Recompile & Restarts xmonad
      , ("M-M1-S-e", io exitSuccess)                                         -- Quits xmonad

    -- System Volume (PulseAudio)
      , ("<XF86AudioRaiseVolume>", spawn "volumenoti.sh inc")            -- Volume Up
      , ("<XF86AudioLowerVolume>", spawn "volumenoti.sh dec")            -- Volume Down
      , ("<XF86AudioMute>", spawn "amixer set Master mute")              -- Mute
      , ("<XF86AudioPrevious>", spawn "playerctl previous")              -- Previous Music
      , ("<XF86AudioNext>", spawn "playerctl next")                      -- Next Music
      , ("<XF86AudioPlay>", spawn "playerctl play-pause")                -- Play/Pause Music
      , ("<XF86MonBrightnessUp>", spawn "sudo brightnessctl set 5%+")        -- Increase Brightness
      , ("<XF86MonBrightnessDown>", spawn "sudo brightnessctl set 5%-")      -- Decrease Brightness

      , ("M-<F5>", spawn "mpc prev")                  -- Previous Music
      , ("M-<F6>", spawn "mpc next")                  -- Next Music
      , ("M-<F7>", spawn "mpc toggle")                -- Play/Pause Music

    -- Run Prompt
      , ("M-r", spawn (myDmenu))                                                    -- Run Dmenu (rofi -show drun)

    -- Apps
      , ("M-f", spawn "firefox")                                                    -- Firefox
      , ("M-c", spawn "chromium")                                                   -- Chromium
      , ("M-S-f", spawn "firefox -private-window")                                  -- Firefox Private mode
      , ("M-S-c", spawn "chromium --incognito")                                     -- Chromium Private mode
      , ("M-<Return>", spawn (myTerminal))                                          -- Terminal

    -- Flameshot
      , ("M-<XF86Tools>", spawn "flameshot gui") -- Flameshot GUI (screenshot)
      , ("M-<XF86Tools> 1", spawn "flameshot screen -n 0 -p $HOME/Pictures/Screenshots")            -- Monitor 1
      , ("M-<XF86Tools> 2", spawn "flameshot screen -n 1 -p $HOME/Pictures/Screenshots")            -- Monitor 2
      , ("M-<XF86Tools> 3", spawn "flameshot screen -n 2 -p $HOME/Pictures/Screenshots")            -- Monitor 3
      , ("M-<XF86Tools> 4", spawn "sleep 5 && flameshot screen -n 0 -p $HOME/Pictures/Screenshots") -- Monitor 1
      , ("M-<XF86Tools> 5", spawn "sleep 5 && flameshot screen -n 1 -p $HOME/Pictures/Screenshots") -- Monitor 2
      , ("M-<XF86Tools> 6", spawn "sleep 5 && flameshot screen -n 2 -p $HOME/Pictures/Screenshots") -- Monitor 3      

    -- Windows navigation
      , ("M-<Space>", sendMessage NextLayout)                                       -- Rotate through the available layout algorithms
      , ("M1-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)        -- Toggles full width
      , ("M1-t", sinkAll)                                                           -- Push all windows back into tiling
      , ("M1-S-p>", withFocused $ windows . W.sink)                                 -- Push window back into tiling
      , ("M1-s", sendMessage (T.Toggle "floats"))                                   -- Toggles my 'floats' layout
      , ("M-<Left>", windows W.swapMaster)                                          -- Swap the focused window and the master window
      , ("M-<Up>", windows W.swapUp)                                                -- Swap the focused window with the previous window
      , ("M-<Down>", windows W.swapDown)                                            -- Swap the focused window with the next window     

    -- Workspaces
    --  , ("M-.", nextScreen)                                                         -- Switch focus to next monitor
    --  , ("M-,", prevScreen)                                                         -- Switch focus to prev monitor
      , ("M-S-.", shiftTo Next nonNSP >> moveTo Next nonNSP)                        -- Shifts focused window to next ws
      , ("M-S-,", shiftTo Prev nonNSP >> moveTo Prev nonNSP)                        -- Shifts focused window to prev ws

    -- Kill windows
      , ("M-q", kill1)                                                              -- Quit the currently focused client
      , ("M-S-w", killAll)                                                          -- Quit all windows on current workspace
      , ("M-<Escape>", spawn "xkill")                                               -- Kill the currently focused client

    -- Increase/decrease spacing (gaps)
      , ("M-C-j", decWindowSpacing 4)                                               -- Decrease window spacing
      , ("M-C-k", incWindowSpacing 4)                                               -- Increase window spacing
      , ("M-C-h", decScreenSpacing 4)                                               -- Decrease screen spacing
      , ("M-C-l", incScreenSpacing 4)                                               -- Increase screen spacing

    -- Window resizing
      , ("M1-<Left>", sendMessage Shrink)                                           -- Shrink horiz window width
      , ("M1-<Right>", sendMessage Expand)                                          -- Expand horiz window width
      , ("M1-<Down>", sendMessage MirrorShrink)                                     -- Shrink vert window width
      , ("M1-<Up>", sendMessage MirrorExpand)                                       -- Expand vert window width

    -- Redshift
      , ("C-<F1>", spawn "redshift -O 5000K")                                       -- Day Mode
      , ("C-<F2>", spawn "redshift -O 3000K")                                       -- Night mode
      , ("C-S-<F1>", spawn "redshift -x")                                           -- Reset redshift light      

    -- Scratchpad windows
      , ("M-m", namedScratchpadAction myScratchPads "ncmpcpp")                      -- Ncmpcpp Player
      , ("M-e", namedScratchpadAction myScratchPads "pcmanfm")                      -- PcmanFM
      , ("M-t", namedScratchpadAction myScratchPads "terminal")                     -- Terminal

    -- Grid Select
      , ("M-M1-<Return>", spawnSelected' $ gsGames ++ gsEducation ++ gsInternet ++ gsMultimedia ++ gsOffice ++ gsSettings ++ gsSystem ++ gsUtilities)
      , ("M-M1-c", spawnSelected' gsCategories)
      , ("M-M1-t", goToSelected $ mygridConfig myColorizer)
      , ("M-M1-b", bringSelected $ mygridConfig myColorizer)
      , ("M1-C-g", spawnSelected' gsGames)
      , ("M1-C-e", spawnSelected' gsEducation)
      , ("M1-C-i", spawnSelected' gsInternet)
      , ("M1-C-m", spawnSelected' gsMultimedia)
      , ("M1-C-o", spawnSelected' gsOffice)
      , ("M1-C-s", spawnSelected' gsSettings)
      , ("M1-C-k", spawnSelected' gsSystem)
      , ("M1-C-u", spawnSelected' gsUtilities)

      , ("M-S-/", spawn "~/.config/xmonad/scripts/keys.sh")

      , ("M-S-v", spawn "lights")                                                   -- Keyboard Lights
    ]
    -- /END_KEYS/
------------------------------------------------------------------------
-- Moving between WS
------------------------------------------------------------------------
      where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
            nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

------------------------------------------------------------------------
-- Floats
------------------------------------------------------------------------
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ className =? "confirm"                           --> doFloat
     , className =? "file_progress"                     --> doFloat
     , resource  =? "desktop_window"                    --> doIgnore
     , className =? "MEGAsync"                          --> doFloat
     , className =? "mpv"                               --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Gthumb"                            --> doCenterFloat
     , className =? "feh"                               --> doCenterFloat
     , className =? "Galculator"                        --> doCenterFloat
     , className =? "Viewnior"                          --> doCenterFloat
     , className =? "Yad"                               --> doCenterFloat
     , className =? "Gcolor3"                           --> doFloat
     , className =? "dialog"                            --> doFloat
     , className =? "Downloads"                         --> doFloat
     , className =? "Save As..."                        --> doFloat
     , className =? "Xfce4-appfinder"                   --> doFloat
     , className =? "Org.gnome.NautilusPreviewer"       --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Ristretto"                         --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Bitwarden"                         --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Xdg-desktop-portal-gtk"            --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Thunar"                            --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , className =? "Sublime_merge"                     --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
     , isFullscreen -->  doFullFloat
     , isDialog --> doCenterFloat
     ] <+> namedScratchpadManageHook myScratchPads

myHandleEventHook :: Event -> X All
myHandleEventHook = dynamicPropertyChange "WM_NAME" (title =? "Spotify" --> floating)
        where floating = doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)

------------------------------------------------------------------------
-- Startup Hooks
------------------------------------------------------------------------
myStartupHook = do
    spawnOnce "$HOME/.config/xmonad/scripts/autostart.sh"
    setWMName "LG3D"

------------------------------------------------------------------------
-- Main Do
------------------------------------------------------------------------
main :: IO ()
main = do
        xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0 ~/.config/xmobar/xmobarrc0"
--      xmproc1 <- spawnPipe "/usr/bin/xmobar -x 1 ~/.config/xmobar/xmobarrc1"
--      xmproc2 <- spawnPipe "/usr/bin/xmobar -x 2 ~/.config/xmobar/xmobarrc2"
        xmonad $ ewmh def
                { manageHook = myManageHook <+> manageDocks
                , handleEventHook  = docksEventHook <+> fullscreenEventHook
                , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc0 x -- xmobar on monitor 1
                                       -- >> hPutStrLn xmproc1 x -- xmobar on monitor 2
                                       -- >> hPutStrLn xmproc2 x -- xmobar on monitor 3
                         , ppCurrent = xmobarColor "#ff79c6" "" . \s -> " <fn=2>\61713</fn>"
                         , ppVisible = xmobarColor "#d4bfff" ""
                         , ppHidden = xmobarColor "#ff79c6" ""
                         , ppHiddenNoWindows = xmobarColor "#d4bfff" ""
                         , ppTitle = xmobarColor "#c7c7c7" "" . shorten 60
                         , ppSep =  "<fc=#212733>  <fn=1> </fn> </fc>"
                         , ppOrder  = \(ws:l:_:_)  -> [ws,l]
                        }
                , modMask            = mod4Mask
                , layoutHook         = myLayoutHook
                , workspaces         = myWorkspaces
                , terminal           = myTerminal
                , borderWidth        = myBorderWidth
                , startupHook        = myStartupHook
                , normalBorderColor  = myNormColor
                , focusedBorderColor = myFocusColor
                } `additionalKeysP` myKeys

-- Find app class name
-- xprop | grep WM_CLASS
-- https://xmobar.org/#diskio-disks-args-refreshrate
