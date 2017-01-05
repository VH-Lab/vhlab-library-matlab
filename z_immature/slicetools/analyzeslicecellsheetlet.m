function [hlist,lengthwidth] = analyzeslicecellsheetlet(title,typeName,upperLeft)

button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = ['sheetlet_callback(''analyzeslicecellsheetlet_process'',''' typeName ''');'];

txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
txt.fontsize = 10; txt.fontweight = 'normal';
txt.HorizontalAlignment = 'left';txt.Style='text';

edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';

popup = txt; popup.style = 'popupmenu';

cb = txt; cb.Style = 'Checkbox'; cb.Callback = ['sheetlet_callback(''analyzeslicecellsheetlet_process'',''' typeName ''');'];
cb.fontsize = 12;

list=button;list.style='list';

hlist = [];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-7 50 20],'string','Cell:','Tag',[typeName 'CellTxt']);
hlist = [hlist h];

h = uicontrol(popup,'position',[upperLeft(1)+10+50+5 upperLeft(2) 80 20],'string',{'test'},'Tag',[typeName 'CellPopup'],'value',1);
hlist = [hlist h];

h = uicontrol(button,'position',[upperLeft(1)+10+100+5+30 upperLeft(2) 50 20],'string','Load','Tag',[typeName 'CellLoadBt']);
hlist = [hlist h];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-7-25-7-7 50 20],'string','Mode:','Tag',[typeName 'ModeTxt']);
hlist = [hlist h];

h = uicontrol(list,'position',[upperLeft(1)+10+60 upperLeft(2)-7-25-7-7 70+70 40],'string','','Tag',[typeName 'ModeList'],'value',1);
hlist = [hlist h];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-7-25-40-7-7 60 20],'string','Condition:','Tag',[typeName 'ConditionTxt']);
hlist = [hlist h];

h = uicontrol(list,'position',[upperLeft(1)+10+60 upperLeft(2)-7-25-40-7-7-7 70+70 40],'string','','Tag',[typeName 'ConditionList']);
hlist = [hlist h];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-7-25-40-40-3*7 60 20],'string','Sites:','Tag',[typeName 'SitesTxt']);
hlist = [hlist h];

h = uicontrol(list,'position',[upperLeft(1)+10+60 upperLeft(2)-7-25-40-40-4*7 70+70 40],'string','','Tag',[typeName 'SitesList']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','RestoreVars','visible','off','Tag',[typeName 'RestoreVarsBt']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','SaveVars','visible','off','Tag',[typeName 'SaveVarsBt']);
hlist = [hlist h];

lengthwidth = [110 25+7+25+2*40+4*7];
