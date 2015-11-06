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
            , modMask = myModMask
            }
            `additionalKeys` myKeys

-- 具体配置
myWorkspaces :: [String]
myWorkspaces = [ "1:Web", "2:File", "3", "4", "5", "6", "7", "8", "9:Daemon" ]

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
    [ className =? "TUNet64" --> doShift "9:Daemon"
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

myModMask :: KeyMask
myModMask = mod1Mask
myKeys :: [((KeyMask, KeySym), X ())]
myKeys = [ ((myModMask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
         , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
         , ((0, xK_Print), spawn "scrot")
         , ((myModMask, xK_d), spawn "j4-dmenu-desktop")
         , ((myModMask, xK_f), sendMessage ToggleLayout)
         , ((myModMask, xK_g), spawn "gmrun")
         , ((myModMask, xK_o), nextMatch History (return True))
         , ((myModMask, xK_p), spawn "echo 'hello'")
         , ((myModMask .|. shiftMask, xK_q), spawn "echo 'hello'")
         ]
