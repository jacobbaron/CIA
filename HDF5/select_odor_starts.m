function [odorIdx,preTime,postTime] = select_odor_starts(odorStrs)

f = figure('Units','normalized','Position', [.25 .25 .28 .35]);
lbox = uicontrol('Style','listbox','Position',[9 9 350 350],'String',odorStrs);
preTimeBox = uicontrol('Style','edit','Position',[375 350,35,25],'String','5');
postTimeBox = uicontrol('Style','edit','Position',[375 295,35,25],'String','5');
preTimeText = uicontrol('Style','text','Position',[415,345,80,25],'String','Pre-Time (s)');
postTimeText = uicontrol('Style','text','Position',[415,290,80,25],'String','Post-Time (s)');
enterBtn = uicontrol('Style','pushbutton','Position',[425,15,80,35],'String','Enter','Callback',{@enterbtn});
uiwait(f);
odorIdx = lbox.Value;
preTime = str2double(preTimeBox.String);
postTime = str2double(postTimeBox.String);
close(f);
    function enterbtn(varargin)
        uiresume(f);
    
        
    end
end