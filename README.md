# Team : Staria
# By : Sunoi

## Overview
- **Rover Mobility:** 6-wheel drive with 4-corner steering using `HingeConstraint`s, custom camera controls, and self-righting recovery.
- **Martian Geology:** Exploration and sample discovery around iconic *Opportunity* targets.
- **UI & Feedback:** Menu navigation, cutscenes, objective tracking, and stackable, auto-clearing notifications.

 ```text
src/
    ServerScriptService/
        Server.luau
     StarterGui/
        Cutscene/
            Cutscene_Controller.luau
        Menu/
            Menu_Controller.luau
        Notification/
            Notification_Controller.luau
        Objective/
            Objective_Controller.luau
     StarterPlayer/
        StarterPlayerScripts/
            Camera.luau
            Rover_Controller.luau
