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

-- import XMonad.Actions.TopicSpace
import XMonad.Actions.GroupNavigation

import System.IO

-- 主程序
main :: IO ()
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
            , logHook = myLogHook xmobarPipe >> historyHook
            , modMask = mod4Mask
            }
            `additionalKeys` myKeys

-- 具体配置
myWorkspaces :: [[Char]]
myWorkspaces = [ "1:Web", "2:File", "3", "4", "5:Daemon", "6", "7", "8", "9" ]

-- myLayoutHook :: XMonad.Layout.LayoutModifier.ModifiedLayout
-- myLayoutHook :: XMonad.Layout.LayoutModifier.ModifiedLayout
myLayoutHook = avoidStruts $ smartBorders $ toggleLayouts full workspaceLayouts
    where
        tiled = named "T" $ Tall 1 (5/100) (2/(1+toRational(sqrt 5::Double)))
        mtiled = named "M" $ Mirror tiled
        full = named "F" Full
        workspaceLayouts = mtiled ||| tiled

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "TUNet64" --> doShift "5"
    , className =? "Firefox" --> doShift "1:Web"
    , manageDocks
    ]

myLogHook :: Handle -> X ()
myLogHook xmobarPipe = dynamicLogWithPP xmobarPrinter
    where
        xmobarPrinter = defaultPP
            { ppOutput = hPutStrLn xmobarPipe
            , ppCurrent = xmobarColor "green" "" .wrap "[" "]"
            , ppTitle = xmobarColor "green" "" . shorten 40
            }

myKeys :: [((KeyMask, KeySym), X ())]
myKeys = [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
         , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
         , ((0, xK_Print), spawn "scrot")
         , ((mod4Mask, xK_d), spawn "j4-dmenu-desktop")
         , ((mod4Mask, xK_f), sendMessage ToggleLayout)
         , ((mod4Mask, xK_g), spawn "gmrun")
         , ((mod4Mask, xK_o), nextMatch History (return True))
         ]
