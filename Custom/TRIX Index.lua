-- TRIX index indicator
function Init()
    indicator:name("TRIX Index");
    indicator:description("The indicator eliminates cycles shorter than the selected indicator period. ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("P_N", "TRIX Periods", "", 14);
    indicator.parameters:addString("MA_1", "First Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_1", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_1", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_1", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_2", "Second Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_2", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_2", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_2", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_3", "Third Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_3", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_3", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_3", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("S_N", "Signal Periods", "", 9);
    indicator.parameters:addString("MA_S", "Signal Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_S", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_S", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_S", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_S", "Wilders*", "", "WMA");

    indicator.parameters:addColor("TRIX_color", "Color of trix line", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SIGNAL_color", "Color of signal line", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("HISTOGRAM_color", "Color of signal line", "", core.rgb(0, 0, 255));
end

local source;
local MA1, MA2, MA3, MA4;
local TRIX, SIGNAL, HISTOGRAM;

function Prepare()
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.P_N .. "," .. instance.parameters.S_N .. ")";
    instance:name(name);

    MA1 = core.indicators:create(instance.parameters.MA_1, instance.source, instance.parameters.P_N);
    MA2 = core.indicators:create(instance.parameters.MA_2, MA1.DATA, instance.parameters.P_N);
    MA3 = core.indicators:create(instance.parameters.MA_3, MA2.DATA, instance.parameters.P_N);

    TRIX = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.TRIX_color, MA3.DATA:first() + 1);
    TRIX:addLevel(0);

    MA4 = core.indicators:create(instance.parameters.MA_S, TRIX, instance.parameters.S_N);

    SIGNAL = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.SIGNAL_color, MA4.DATA:first());
	
	HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.HISTOGRAM_color, MA4.DATA:first());
end

function Update(period, mode)
    MA1:update(mode);
    MA2:update(mode);
    MA3:update(mode);

    if period >= TRIX:first() then
        TRIX[period] = (MA3.DATA[period] - MA3.DATA[period - 1]) / MA3.DATA[period - 1] * 100;
    end
    MA4:update(mode);
    if period >= SIGNAL:first() then
        SIGNAL[period] = MA4.DATA[period];
		HISTOGRAM[period] =TRIX[period] - MA4.DATA[period];
    end
end

