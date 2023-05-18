local DummyCmdTbl = {};_G2.DummyCmdTbl=DummyCmdTbl
local MenuLayout = {};Info.MenuLayout=MenuLayout



local MenuMain = menu.my_root()
MenuLayout.Main = MenuMain



MenuLayout.Vehicle = MenuMain:list("Vehicle Related Options", DummyCmdTbl, "")
