<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="SimpleCombatText" version="1.0.0" date="2021-04-04" >
    <VersionSettings gameVersion="1.4.8" windowsVersion="1.40" savedVariablesVersion="1.50" />

		<Author name="Idrinth"/>

		<Description text="A simple, aggregated display of combat events" />
		<Dependencies>
			<Dependency name="LibSlash" optional="true"/>
		</Dependencies>
		<Files>
			<File name="window.xml" />
            <File name="simple-combat-text.lua" />
		</Files>
		<OnInitialize>
            <CallFunction name="SimpleCombatText.OnInitialize" />
		</OnInitialize>
		<OnUpdate>
            <CallFunction name="SimpleCombatText.OnUpdate" />
		</OnUpdate>
        <SavedVariables>
            <SavedVariable name="SimpleCombatText.Settings" />
        </SavedVariables>
		<WARInfo>
			<Categories>
				<Category name="OTHER"/>
			</Categories>
		</WARInfo>

	</UiMod>
</ModuleFile>
