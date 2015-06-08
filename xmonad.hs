-- 导入
import XMonad

import XMonad.Hooks.DynamicLog  -- statusbar
import XMonad.Hooks.ManageDocks -- dock/tray mgmt
import XMonad.Hooks.UrgencyHook -- window alert bells

import XMonad.Layout.Named    -- custom layout names
import XMonad.Layout.NoBorders  -- smart borders on solo clients
import XMonad.Layout.ToggleLayouts

import XMonad.Util.Run(spawnPipe)   -- spawnPipe and hPutStrLn
import XMonad.Util.EZConfig(additionalKeys) -- append key/mouse bindings

import System.IO
import XMonad.Actions.TopicSpace

-- 主程序
main = do
    xmobarPipe <- spawnPipe "/usr/bin/xmobar /home/bibaijin/.xmonad/xmobarrc"
    xmonad $ withUrgencyHook dzenUrgencyHook { args = ["-bg", "darkgreen", "-xs", "1"] }
        $ defaultConfig
            { terminal = "urxvt"
            , borderWidth = 2
            , normalBorderColor = "#dddddd"
            , focusedBorderColor = "#ff0000"
            , workspaces = myWorkspaces
            , layoutHook = myLayoutHook
            , manageHook = myManageHook <+> manageHook defaultConfig
            , logHook = myLogHook xmobarPipe
            , modMask = mod4Mask
            }
            `additionalKeys` myKeys

-- 具体配置
myWorkspaces = [ "1:Shell", "2:File", "3:Web", "4", "5", "6", "7", "8", "9:Daemon" ]

myLayoutHook = avoidStruts $ smartBorders $ toggleLayouts full workspaceLayouts
    where
        tiled = named "T" $ Tall 1 (5/100) (2/(1+(toRational(sqrt(5)::Double))))
        mtiled = named "M" $ Mirror tiled
        full = named "F" $ Full
        workspaceLayouts = mtiled ||| tiled

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "TUNet64" --> doShift "9:Daemon"
    , className =? "Firefox" --> doShift "3:Web"
    , manageDocks
    ]

myLogHook xmobarPipe = dynamicLogWithPP xmobarPrinter
    where
        xmobarPrinter = defaultPP
            { ppOutput = hPutStrLn xmobarPipe
            , ppCurrent = xmobarColor "green" "" .wrap "[" "]"
            , ppTitle = xmobarColor "green" "" . shorten 50
            }

myKeys = [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
         , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
         , ((0, xK_Print), spawn "scrot")
         , ((mod4Mask, xK_d), spawn "j4-dmenu-desktop")
         , ((mod4Mask, xK_f), sendMessage ToggleLayout)
         , ((mod4Mask, xK_g), spawn "gmrun")
         ]
