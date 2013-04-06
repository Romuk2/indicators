-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 17 "Adaptive Techniques" (page 440)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrARSI", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ARSI_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthARSI", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ARSI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleARSI", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ARSI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleARSI", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local rsi = nil
-- Streams block
local ARSI = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n + 1;
    rsi = core.indicators:create("RSI", source.close, n);

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    ARSI = instance:addStream("ARSI", core.Line, name, "ARSI", instance.parameters.clrARSI, first)
    ARSI:setWidth(instance.parameters.widthARSI);
    ARSI:setStyle(instance.parameters.styleARSI);
end

-- Indicator calculation routine
function Update(period, mode)
    rsi:update(mode);
    if period > first then
        local sc = rsi.DATA[period] / 100;
        sc = math.abs(sc - 0.5) * 2;
        local arsiPrev = ARSI[period - 1];
        ARSI[period] = arsiPrev + sc * (source.close[period] - arsiPrev);    
    elseif period == first then
        ARSI[period] = source.close[period];
    end
end