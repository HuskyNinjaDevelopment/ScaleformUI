MenuHandler = setmetatable({
    _currentMenu = nil,
    _currentPauseMenu = nil,
    ableToDraw = false
}, MenuHandler)
MenuHandler.__index = MenuHandler
MenuHandler.__call = function()
    return "MenuHandler"
end

---@class MenuHandler
---@field _currentMenu UIMenu
---@field _currentPauseMenu table
---@field ableToDraw boolean

function MenuHandler:SwitchTo(currentMenu, newMenu, newMenuCurrentSelection, inheritOldMenuParams)
    assert(currentMenu ~= nil, "The menu you're switching from cannot be null")
    assert(currentMenu == self._currentMenu, "The menu you're switching from must be opened")
    assert(newMenu ~= nil, "The menu you're switching to cannot be null")
    assert(newMenu ~= currentMenu, "You cannot switch a menu to itself")
    if BreadcrumbsHandler.SwitchInProgress then return end
    BreadcrumbsHandler.SwitchInProgress = true
    
    if newMenuCurrentSelection == nil then newMenuCurrentSelection = 1 end
    if inheritOldMenuParams == nil then inheritOldMenuParams = false end
    if inheritOldMenuParams then
        if currentMenu.TxtDictionary ~= "" and currentMenu.TxtDictionary ~= nil and currentMenu.TxtName ~= "" and currentMenu.TxtName ~= nil then
            newMenu.TxtDictionary = currentMenu.TxtDictionary
            newMenu.TxtName = currentMenu.TxtName
        end
            newMenu.Position = currentMenu.Position

        if currentMenu.Logo ~= nil then
            newMenu.Logo = currentMenu.Logo
        else
            newMenu.Logo = nil
            newMenu.Banner = currentMenu.Banner
        end

        newMenu.Glare = currentMenu.Glare
        newMenu.Settings.MouseControlsEnabled = currentMenu.Settings.MouseControlsEnabled
        newMenu.Settings.MouseEdgeEnabled = currentMenu.Settings.MouseEdgeEnabled
        newMenu:MaxItemsOnScreen(currentMenu:MaxItemsOnScreen())
        newMenu:AnimationEnabled(currentMenu:AnimationEnabled())
        newMenu:AnimationType(currentMenu:AnimationType())
        newMenu:BuildingAnimation(currentMenu:BuildingAnimation())
        newMenu:ScrollingType(currentMenu:ScrollingType())
    end
    currentMenu:FadeOutMenu()
    currentMenu:Visible(false)
    newMenu:CurrentSelection(newMenuCurrentSelection)
    newMenu:Visible(true)
    currentMenu:FadeInMenu()
    BreadcrumbsHandler:Forward(newMenu)
    BreadcrumbsHandler.SwitchInProgress = false
end

function MenuHandler:ProcessMenus()
    self:ProcessControl()
    self:Draw()
end

---ProcessControl
function MenuHandler:ProcessControl()
    if self._currentMenu ~= nil then
        self._currentMenu:ProcessControl()
        self._currentMenu:ProcessMouse()
    end

    if self._currentPauseMenu ~= nil then
        self._currentPauseMenu:ProcessControl()
        self._currentPauseMenu:ProcessMouse()
    end
end

---Draw
function MenuHandler:Draw()
    if self._currentMenu ~= nil then
        self._currentMenu:Draw()
    end
    if self._currentPauseMenu ~= nil then
        self._currentPauseMenu:Draw()
    end
end

function MenuHandler:CloseAndClearHistory()
    if self._currentMenu ~= nil and self._currentMenu:Visible() then
        self._currentMenu:Visible(false)
    end
    if self._currentPauseMenu ~= nil and self._currentPauseMenu:Visible() then
        self._currentPauseMenu:Visible(false)
    end
    BreadcrumbsHandler:Clear()
end

---IsAnyMenuOpen
function MenuHandler:IsAnyMenuOpen()
    return BreadcrumbsHandler:Count() > 0
end

function MenuHandler:IsAnyPauseMenuOpen()
    return self._currentPauseMenu ~= nil and self._currentPauseMenu:Visible()
end