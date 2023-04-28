namespace RMC
{
    void RenderRMCMenu()
    {
#if TMNEXT
        if (Permissions::PlayLocalMap()) {
#endif
            UI::BeginTabBar("RMCActivitiesTabBar", UI::TabBarFlags::FittingPolicyResizeDown);
            //Random Map Challenge Tab
            if(UI::BeginTabItem(Icons::ClockO + " Challenge"))
            {
                if (UI::GreenButton(Icons::ClockO + " Start Random Map Challenge"))
                {
                    selectedGameMode = GameMode::Challenge;
                    startnew(Start);
                }
                UI::EndTabItem();
            }
            //Random Map Survival Tab
            if(UI::BeginTabItem(Icons::Heart + " Survival")) 
            {
                if (UI::GreenButton(Icons::Heart + " Start Random Map Survival"))
                {
                    selectedGameMode = GameMode::Survival;
                    startnew(Start);
                }
                UI::EndTabItem();
            }
            //Chaos Mode Tab
            if(UI::BeginTabItem(Icons::Fire + " Chaos")) 
            {
#if DEPENDENCY_CHAOSMODE
                if (UI::RedButton(Icons::Fire + " Start RMC with Chaos Mode")){
                    selectedGameMode = GameMode::ChallengeChaos;
                    ChaosMode::SetRMCMode(true);
                    startnew(Start);
                }
                if (UI::RedButton(Icons::Fire + " Start RMS with Chaos Mode")){
                    selectedGameMode = GameMode::SurvivalChaos;
                    ChaosMode::SetRMCMode(true);
                    startnew(Start);
                }
#else
                if (UI::RedButton(Icons::Fire + " Chaos Mode")){
                    Renderables::Add(ChaosModeIntroModalDialog());
                }
#endif
                UI::EndTabItem();
            }
            //Objective Mode Tab
            if(UI::BeginTabItem(Icons::Trophy + " Objective")) {
                UI::TextDisabled(Icons::InfoCircle + " Hover for infos");
                UI::SetPreviousTooltip("Set a goal, and get it done as quickly as possible!\nSkips are unlimited but costs you time spending on the map.");
                UI::Text("Goal:");
                UI::SameLine();
                UI::SetNextItemWidth(150);
                PluginSettings::RMC_ObjectiveMode_Goal = UI::InputInt("##ObjectiveMedals", PluginSettings::RMC_ObjectiveMode_Goal);
                if (PluginSettings::RMC_ObjectiveMode_Goal < 1)
                    PluginSettings::RMC_ObjectiveMode_Goal = 1;
                UI::SameLine();
                UI::Text("medals");

                if (UI::GreenButton(Icons::Trophy + " Start Random Map Objective")){
                    selectedGameMode = GameMode::Objective;
                    startnew(Start);
                }
                if (UI::Button(Icons::Table + " Objective Mode Standings"))
                    OpenBrowserURL("https://www.speedrun.com/tmce#Flinks_Random_Map_Challenge");
                UI::EndTabItem();
            }
            //Random Map Together
            if(UI::BeginTabItem(Icons::Users + " Together")) {
                if (Permissions::CreateActivity() )
                {
#if DEPENDENCY_NADEOSERVICES
                    UI::TextDisabled(Icons::InfoCircle + " Click for help");
                    if (UI::IsItemClicked()) {
                        Renderables::Add(RMTHelpModalDialog());
                    }
                    UI::Text("Club ID:");
                    UI::SameLine();
                    UI::SetNextItemWidth(150);
                    PluginSettings::RMC_Together_ClubId = Text::ParseInt(UI::InputText("##RMTSetClubID", tostring(PluginSettings::RMC_Together_ClubId), false, UI::InputTextFlags::CharsDecimal));

                    UI::Text("Room ID:");
                    UI::SameLine();
                    UI::SetNextItemWidth(150);
                    PluginSettings::RMC_Together_RoomId = Text::ParseInt(UI::InputText("##RMTSetRoomID", tostring(PluginSettings::RMC_Together_RoomId), false, UI::InputTextFlags::CharsDecimal));

                    bool RMT_isServerOK = false;

                    if (PluginSettings::RMC_Together_ClubId > 0 && PluginSettings::RMC_Together_RoomId > 0) {
                        UI::BeginDisabled(MXNadeoServicesGlobal::isCheckingRoom);
                        if (UI::Button("Check Room")) {
                            startnew(MXNadeoServicesGlobal::CheckNadeoRoomAsync);
                        }
                        UI::EndDisabled();
                        if (MXNadeoServicesGlobal::isCheckingRoom) {
                            int HourGlassValue = Time::Stamp % 3;
                            string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
                            UI::TextDisabled(Hourglass + " Checking...");
                        }
                        if (MXNadeoServicesGlobal::foundRoom !is null) {
                            RMT_isServerOK = true;
                            UI::Text("Room found:");
                            UI::Text("'"+MXNadeoServicesGlobal::foundRoom.name+"', in club '"+StripFormatCodes(MXNadeoServicesGlobal::foundRoom.clubName)+"'");
                        }
                    }
                    if (RMT_isServerOK && !TM::IsInServer()) {
                        UI::BeginDisabled();
                        UI::GreyButton(Icons::Users + " Start Random Map Together");
                        UI::Text("\\$a50" + Icons::ExclamationTriangle + " \\$zPlease join the room before continuing");
                        UI::EndDisabled();
                    }
                    if (RMT_isServerOK && TM::IsInServer() && UI::GreenButton(Icons::Users + " Start Random Map Together")){
                        selectedGameMode = GameMode::Together;
                        startnew(CoroutineFunc(Together.StartRMT));
                    }
#else
                    UI::Text("NadeoServices dependency not found, your Openplanet installation may be corrupt!");
#endif
                } 
                else {
                   UI::Text(Icons::TimesCircle + " You have not the permissions to play local maps");
                }
                UI::EndTabItem();
            }
            UI::EndTabBar();

            //Medal Type Selector
            UI::SetNextItemWidth(100);
            if (UI::BeginCombo("##GoalMedalObjectiveMode", PluginSettings::RMC_GoalMedal)){
                for (uint i = 0; i < RMC::Medals.Length; i++) {
                    string goalMedal = RMC::Medals[i];

                    if (UI::Selectable(goalMedal, PluginSettings::RMC_GoalMedal == goalMedal)) {
                        PluginSettings::RMC_GoalMedal = goalMedal;
                    }

                    if (PluginSettings::RMC_GoalMedal == goalMedal) {
                        UI::SetItemDefaultFocus();
                    }
                }
                UI::EndCombo();
            }
            UI::SameLine();
            UI::Text("medals");
        }

        //Bottom Settings
        UI::Separator();
        if (UI::Button(Icons::Table + " Standings")) {
            OpenBrowserURL("https://docs.google.com/spreadsheets/d/1Byoa0ZIakuhK02n3a5FcTNYIhJksX25tqU455Lg-vkI/edit?usp=sharing");
        }
        UI::SameLine();
        if (UI::PurpleButton(Icons::Cog)) {
            Renderables::Add(RMCSettingsModalDialog());
        }
        UI::SameLine();
        if (UI::IsOverlayShown() && UI::OrangeButton(Icons::Backward + " Go back")) {
            window.isInRMCMode = false;
        }

        if (
            RMC::GoalMedalCount > 0 ||
            Challenge.BelowMedalCount > 0 ||
            Survival.Skips > 0 ||
            Survival.SurvivedTime > 0
        ) {
            if (!UI::IsOverlayShown()) UI::Dummy(vec2(0, 10));
            UI::Separator();
            UI::Text("Last run stats:");
            vec2 pos_orig = UI::GetCursorPos();
            if (selectedGameMode == GameMode::Challenge) {
                Challenge.RenderGoalMedal();
                UI::SetCursorPos(vec2(UI::GetCursorPos().x+50, UI::GetCursorPos().y));
                Challenge.RenderBelowGoalMedal();
            }
            else if (selectedGameMode == GameMode::Survival) {
                Survival.RenderGoalMedal();
                UI::SetCursorPos(vec2(UI::GetCursorPos().x+50, UI::GetCursorPos().y));
                Survival.RenderBelowGoalMedal();
                UI::SetCursorPos(vec2(pos_orig.x, pos_orig.y+60));
                UI::Text("Survived time: " + RMC::FormatTimer(Survival.SurvivedTime));
            }
            else if (selectedGameMode == GameMode::Objective) {
                Objective.RenderGoalMedal();
                UI::SetCursorPos(vec2(UI::GetCursorPos().x+50, UI::GetCursorPos().y));
                Objective.RenderBelowGoalMedal();
                UI::SetCursorPos(vec2(pos_orig.x, pos_orig.y+60));
                UI::Text("Total time:");
                UI::SameLine();
                UI::PushFont(Objective.TimerFont);
                UI::Text(RMC::FormatTimer(Objective.RunTime));
                UI::PopFont();
            }
        }
    }

    void RenderRMCTimer()
    {
        if (selectedGameMode == GameMode::Challenge || selectedGameMode == GameMode::ChallengeChaos) Challenge.Render();
        else if (selectedGameMode == GameMode::Survival || selectedGameMode == GameMode::SurvivalChaos) Survival.Render();
        else if (selectedGameMode == GameMode::Objective) Objective.Render();
        else if (selectedGameMode == GameMode::Together) Together.Render();
    }

    void RenderBaseInfos()
    {
        UI::PushFont(g_fontHeader);
        UI::Text("Random Map Challenge / Survival");
        UI::PopFont();
        UI::TextWrapped("In the Random Map Challenge, you have to grab the maximum number of author medals in 1 hour.");
        UI::TextWrapped("In the Random Map Survival, you have to grab the maximum number of author medals before the timer reaches 0. You gain 3 minutes per medal won, you can skip but you lose 1 minute of your time limit");
        if (UI::GreenButton(Icons::ExternalLink + " More informations")) OpenBrowserURL("https://flinkblog.de/RMC/");
    }
}