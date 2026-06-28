fnc_switchInfoPage = {
    params ["_direction"];
    
    if (!hasInterface) exitWith {};
    private _display = uiNamespace getVariable ["InfoDialog", displayNull];
    if (isNull _display) exitWith {};

    private _ctrl = _display displayCtrl 9001;
    if (isNull _ctrl) exitWith {};

    private _pages = [

    // Page 1: Rules of Engagement
    "<t size='1.2' align='center'>Rules of Engagement</t><br/><br/>"
    + "<t color='#FF0000'>NO TEAM KILLING</t><br/>"
    + "Deliberate harm to friendly forces is strictly prohibited. Accidental fire must be reported immediately. "
    + "Repeat violations will result in removal from the operation.<br/><br/>"
    + "<t color='#FF0000'>NO TROLLING</t><br/>"
    + "Disruptive behavior, voice spamming, griefing, or intentional sabotage of mission flow is not tolerated. "
    + "Respect your teammates and maintain immersion.<br/><br/>"
    + "<t color='#FF0000'>NO WASTING FRIENDLY SUPPLIES</t><br/>"
    + "All logistics assets — crates, vehicles, build resources — are mission-critical. "
    + "Do not hoard, destroy, or misuse supplies. Engineers and logistics roles are responsible for proper deployment.",


    // Page 2: Roles & Keybinds
    "<t size='1.2' align='center'>Roles and Keybinds</t><br/><br/>"
    + "<t color='#00FFFF'>[5]</t> Opens the utility panel<br/>"
    + "<t color='#00FFFF'>[6]</t> Interact key for all context-sensitive actions<br/>"
    + "<t color='#00FFFF'>[N]</t> Opens the build panel<br/><br/>"
    + "Roles are trait-based and determine access to specialized systems:<br/><br/>"
    + "<t color='#00FF00'>Construction</t> – Build fortifications and supply dumps<br/>"
    + "<t color='#00FF00'>Recon</t> – Perform ranged recon of enemy static emplacements<br/>"
    + "<t color='#00FF00'>Engineer</t> – Repair friendly vehicles using repair kits<br/>"
    + "<t color='#00FF00'>Medic</t> – Revive friendly players faster and more reliably<br/><br/>"
    + "Use the <t color='#00FF00'>Training Officer</t> at base to change your trait.",


    // Page 3: Construction Role – Supply Dump System
    "<t size='1.2' align='center'>Construction Role – Supply Dump System</t><br/><br/>"
    + "As a <t color='#00FF00'>Construction</t> role, you may deploy a single <t color='#FFCC00'>Global Supply Dump</t> at a time. "
    + "This dump acts as a forward logistics hub and unlocks advanced build capabilities.<br/><br/>"
    + "<t color='#FF0000'>Supply Dumps can ONLY be built inside active or <t color='#00FF00'>green</t> zones.</t><br/><br/>"
    + "Supplies within the dump can be <t color='#00FFFF'>emptied</t> and the dump itself can be <t color='#00FFFF'>torn down</t> if repositioning is needed. "
    + "Once deployed, the dump grants access to:<br/><br/>"
    + "<t color='#00FF00'>Vehicle Resupply Module</t> – Rearms friendly vehicles<br/>"
    + "<t color='#00FF00'>Vehicle Refueling Module</t> – Restores fuel to vehicles<br/>"
    + "<t color='#00FF00'>Vehicle Repairing Module</t> – Enables field repairs<br/>"
    + "<t color='#00FF00'>Weapon Crate Module</t> – Enables spawning of Ammo and Weapon crates",


    // Page 4: Recon Role – Spotting and Stealth Mechanics
    "<t size='1.2' align='center'>Recon Role – Spotting and Stealth Mechanics</t><br/><br/>"
    + "Recon players are equipped with advanced optics and spotting tools. When within <t color='#FFCC00'>400m</t> of enemy static emplacements, "
    + "they automatically mark targets globally for all players.<br/><br/>"
    + "These markers assist in coordinating fire missions, planning assaults, and avoiding ambushes.<br/><br/>"
    + "Additionally, up to <t color='#00FF00'>10 recon players</t> (depending on current player count) benefit from a <t color='#00FFFF'>20% chance</t> "
    + "to be ignored by enemy tracking forces within active zones. This stealth mechanic allows for deeper infiltration and safer observation.<br/><br/>"
    + "Recon roles are critical for battlefield intelligence and should operate ahead of the main force to identify threats and opportunities.",


    // Page 5: Resupplying the Supply Dump
    "<t size='1.2' align='center'>Resupplying the Supply Dump</t><br/><br/>"
    + "To resupply a deployed <t color='#FFCC00'>Supply Dump</t>, retrieve a <t color='#00FF00'>Supply Crate</t> from base (contains 50 sandbags).<br/><br/>"
    + "Bring the crate inside the blue zone surrounding the dump. You may either:<br/>"
    + "Place it on the ground<br/>"
    + "Leave it inside a vehicle parked within the zone<br/><br/>"
    + "Then interact with the dump’s radio and select <t color='#00FFFF'>Resupply This Station</t>. The crate’s contents will be added to the dump.<br/><br/>"
    + "Supplies can be used to:<br/>"
    + "Add vehicle modules (resupply, refuel, repair)<br/>"
    + "Enable the <t color='#FFCC00'>Weapon Crate Module</t> for access to specialized static weapons<br/><br/>"
    + "You may also <t color='#FF0000'>Teardown</t> the station. Be sure to export the supplies first.",


    // Page 6: AO (Area of Operation) Mechanics
    "<t size='1.2' align='center'>Area of Operation (AO)</t><br/><br/>"
    + "Each mission zone is an <t color='#FFCC00'>Area of Operation (AO)</t>. Only <t color='#00FF00'>one AO</t> can be active at a time.<br/><br/>"
    + "To clear an AO and turn it <t color='#00FF00'>green</t>, players must complete the following tasks:<br/><br/>"
    + "<t color='#FF0000'>1. Destroy NVA AA and Mortar Emplacements</t><br/>"
    + "These static defenses must be located and eliminated to weaken enemy control.<br/><br/>"
    + "<t color='#FF0000'>2. Locate NVA Intel</t><br/>"
    + "Inside the AO, find the NVA command site. Look for radios and interact with them using the <t color='#00FFFF'>[6]</t> key to search for intel.<br/><br/>"
    + "Searching <t color='#00FF00'>all</t> intel radios within an activated AO allows friendly forces to identify the correct site and intercept NVA communications, <t color='#00FFFF'>continue -></t>",

    //page 7 AO continue
    "<t size='1.2' align='center'>Area of Operation (AO)</t><br/><br/>"
    +"enabling real‑time tracking of enemy saboteur teams. Interception must be completed before the AO turns <t color='#00FF00'>green</t>.<br/><br/>"
    + "<t color='#FF0000'>3. Defend the AO</t><br/>"
    + "After destroying enemy assets and gathering intel, enemy forces will counterattack. Hold the AO until the assault ends.<br/><br/>"
    + "Once all tasks are complete and the defense succeeds, the AO turns <t color='#00FF00'>green</t>, allowing movement to the next AO.",
    
    //page 8 sab units
"<t size='1.2' align='center'>Enemy Saboteurs</t><br/><br/>"
+ "After friendly forces clear an <t color='#FFCC00'>Area of Operation</t>, the NVA will deploy specialized "
+ "<t color='#FF0000'>Saboteur Teams</t> to disrupt your logistics network.<br/><br/>"
+ "These units are more highly trained than standard NVA infantry and operate with stealth and precision. "
+ "Their primary objective is to infiltrate friendly lines and plant explosives on your <t color='#00FFFF'>Supply Dump Radio</t>.<br/><br/>"
+ "If successful, the explosion will <t color='#FF0000'>destroy the entire supply dump incl modules.</t><br/><br/>"
+ "<t color='#00FF00'>How to Counter Saboteurs:</t><br/>"
+ "• Maintain perimeter security around active supply dumps.<br/>"
+ "• Use patrols and recon to detect movement in key areas.<br/>"
+ "• <t color='#00FFFF'>Intercept Enemy Communications</t> by searching <t color='#FFCC00'>all intel radios</t> within an active (non‑green) AO."

];


    private _current = missionNamespace getVariable ["InfoPageIndex", 0];

    switch (_direction) do {
        case "next": { _current = (_current + 1) min (count _pages - 1); };
        case "prev": { _current = (_current - 1) max 0; };
        case "init": { _current = 0; };
    };

    _ctrl ctrlSetStructuredText parseText (_pages select _current);
    missionNamespace setVariable ["InfoPageIndex", _current];
};

missionNamespace setVariable ["fnc_switchInfoPage", fnc_switchInfoPage];