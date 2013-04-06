--
-- initializes the indicator
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrWMA", resources:get("R_line_color_name"), string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_WMA_line_name")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", resources:get("R_line_width_name"), string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_WMA_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("style", resources:get("R_line_style_name"), string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_WMA_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first = 0;
local n = 0;
local k = 0;
local source = nil;
local out = nil;

-- initializes the instance of the indicator
function Prepare()
    source = instance.source;
    n = instance.parameters.N;
    n1 = 2 * n - 1;
    k = 2.0 / (n1 + 1.0);
    first = source:first() + n1 - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";

    out = instance:addStream("WMA", core.Line, name, "WMA", instance.parameters.clrWMA,  first);
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
    instance:name(name);
end

-- calculate the value
function Update(period)
    if (period == first) then
        out[period] = mathex.avg(source, period - n + 1, period);
    elseif (period > first) then
        out[period] = ((source[period] - out[period - 1]) * k) + out[period - 1];
    end
end

