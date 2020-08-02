local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinQuestIcon(_, block)
	local itemButton = block.itemButton
	if itemButton and not itemButton.styled then
		itemButton:SetNormalTexture("")
		itemButton:SetPushedTexture("")
		itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		itemButton.icon:SetTexCoord(unpack(DB.TexCoord))
		B.SetBD(itemButton)

		itemButton.styled = true
	end

	local rightButton = block.rightButton
	if rightButton and not rightButton.styled then
		rightButton:SetNormalTexture("")
		rightButton:SetPushedTexture("")
		rightButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		rightButton:SetSize(25, 25)
		rightButton.Icon:SetInside()
		B.SetBD(rightButton)

		rightButton.styled = true
	end
end

local function ReskinHeader(header)
	header.Text:SetTextColor(r, g, b)
	header.Background:Hide()
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(r, g, b, .8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
end

local function ReskinBarTemplate(bar)
	if bar.bg then return end

	B.StripTextures(bar)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(r, g, b)
	bar.bg = B.SetBD(bar)
	B:SmoothBar(bar)
end

local function ReskinProgressbar(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar

	if not bar.bg then
		bar:ClearAllPoints()
		bar:SetPoint("LEFT")
		ReskinBarTemplate(bar)
	end
end

local function ReskinProgressbarWithIcon(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	local icon = bar.Icon

	if not bar.bg then
		bar:SetPoint("LEFT", 22, 0)
		ReskinBarTemplate(bar)
		BonusObjectiveTrackerProgressBar_PlayFlareAnim = B.Dummy

		icon:SetMask(nil)
		icon.bg = B.ReskinIcon(icon, true)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 0)
		icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, 0)
	end

	if icon.bg then
		icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
	end
end

local function ReskinTimerBar(_, _, line)
	local timerBar = line.TimerBar
	local bar = timerBar.Bar

	if not bar.bg then
		ReskinBarTemplate(bar)
	end
end

local function ReskinMinimizeButton(button)
	B.ReskinExpandOrCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.expTex:SetTexCoord(.5625, 1, 0, .4375)
end

local function UpdateMinimizeButton(button, collapsed)
	if collapsed then
		button.expTex:SetTexCoord(0, .4375, 0, .4375)
	else
		button.expTex:SetTexCoord(.5625, 1, 0, .4375)
	end
end

local function ShowQuestLevel(_, _, _, title, level, _, isHeader, _, isComplete, frequency, questID)
	if ENABLE_COLORBLIND_MODE == "1" then return end

	for button in pairs(QuestScrollFrame.titleFramePool.activeObjects) do
		if title and not isHeader and button.questID == questID then
			local title = "["..level.."] "..title
			if isComplete then
				title = "|cffff78ff"..title
			elseif C_QuestLog_IsQuestReplayable(questID) then
				title = "|cff00ff00"..title
			elseif frequency == LE_QUEST_FREQUENCY_DAILY then
				title = "|cff3399ff"..title
			end
			button.Text:SetText(title)
			button.Text:SetPoint("TOPLEFT", 24, -5)
			button.Text:SetWidth(205)
			button.Text:SetWordWrap(false)
			button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth(), 0)
		end
	end
end

tinsert(C.defaultThemes, function()
	local r, g, b = DB.r, DB.g, DB.b
	local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY or 2
	local C_QuestLog_IsQuestReplayable = C_QuestLog.IsQuestReplayable

	-- QuestIcons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", ReskinQuestIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", ReskinQuestIcon)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddObjective", ReskinQuestIcon)

	-- Reskin Progressbars
	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressbar)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressbar)

	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", ReskinProgressbarWithIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressbarWithIcon)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", ReskinProgressbarWithIcon)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddTimerBar", ReskinTimerBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddTimerBar", ReskinTimerBar)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", ReskinTimerBar)

	-- Reskin Blocks
	hooksecurefunc("ScenarioStage_CustomizeBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.SetBD(block.GlowTexture, nil, 4, -2, -4, 2)
		end
	end)

	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", function()
		local widgetContainer = ScenarioStageBlock.WidgetContainer
		if not widgetContainer then return end

		local widgetFrame = widgetContainer:GetChildren()
		if widgetFrame and widgetFrame.Frame then
			widgetFrame.Frame:SetAlpha(0)

			for i = 1, widgetFrame.CurrencyContainer:GetNumChildren() do
				local bu = select(i, widgetFrame.CurrencyContainer:GetChildren())
				if bu and bu.Icon and not bu.styled then
					B.ReskinIcon(bu.Icon)
					bu.styled = true
				end
			end
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_ShowBlock", function()
		local block = ScenarioChallengeModeBlock
		if not block.bg then
			block.TimerBG:Hide()
			block.TimerBGBack:Hide()
			block.timerbg = B.CreateBDFrame(block.TimerBGBack, .3)
			block.timerbg:SetPoint("TOPLEFT", block.TimerBGBack, 6, -2)
			block.timerbg:SetPoint("BOTTOMRIGHT", block.TimerBGBack, -6, -5)

			block.StatusBar:SetStatusBarTexture(DB.normTex)
			block.StatusBar:SetStatusBarColor(r, g, b)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = B.SetBD(block, nil, 4, -2, -4, 0)
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_SetUpAffixes", B.AffixesSetup)

	-- Block in jail tower
	local mawBuffsBlock = ScenarioBlocksFrame.MawBuffsBlock
	local bg = B.SetBD(mawBuffsBlock, nil, 20, -10, -20, 10)
	bg:SetBackdropColor(0, .5, .5, .25)

	local blockContainer = mawBuffsBlock.Container
	B.StripTextures(blockContainer)
	blockContainer:GetPushedTexture():SetAlpha(0)
	blockContainer:GetHighlightTexture():SetAlpha(0)

	local blockList = blockContainer.List
	blockList.__bg = bg
	blockList:HookScript("OnShow", function(self)
		self.__bg:SetBackdropBorderColor(1, .8, 0, .5)

		for mawBuff in self.buffPool:EnumerateActive() do
			if mawBuff:IsShown() and not mawBuff.bg then
				mawBuff.Border:SetAlpha(0)
				mawBuff.CircleMask:Hide()
				mawBuff.CountRing:SetAlpha(0)
				mawBuff.HighlightBorder:SetColorTexture(1, 1, 1, .25)
				mawBuff.bg = B.ReskinIcon(mawBuff.Icon)
			end
		end
	end)
	blockList:HookScript("OnHide", function(self)
		self.__bg:SetBackdropBorderColor(0, 0, 0, 1)
	end)
	B.StripTextures(blockList)
	B.SetBD(blockList)

	-- Reskin Headers
	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
	}
	for _, header in pairs(headers) do
		ReskinHeader(header)
	end

	-- Minimize Button
	local mainMinimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	ReskinMinimizeButton(mainMinimize)
	mainMinimize.bg:SetBackdropBorderColor(1, .8, 0, .5)
	hooksecurefunc("ObjectiveTracker_Expand", function() mainMinimize.expTex:SetTexCoord(.5625, 1, 0, .4375) end)
	hooksecurefunc("ObjectiveTracker_Collapse", function() mainMinimize.expTex:SetTexCoord(0, .4375, 0, .4375) end)

	for _, header in pairs(headers) do
		local minimize = header.MinimizeButton
		if minimize then
			ReskinMinimizeButton(minimize)
			hooksecurefunc(minimize, "SetCollapsed", UpdateMinimizeButton)
		end
	end

	-- Show quest color and level
	--hooksecurefunc("QuestLogQuests_AddQuestButton", ShowQuestLevel) -- FIXME
end)