function [hlist, lengthwidth] = landmarkssheetlet(title,typeName,upperLeft)

button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = ['sheetlet_callback(''landmarkssheetlet_process'',''' typeName ''');'];

txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
txt.fontsize = 10; txt.fontweight = 'normal';
txt.HorizontalAlignment = 'center';txt.Style='text';

edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';

popup = txt; popup.style = 'popupmenu';popup.Callback = ['sheetlet_callback(''landmarkssheetlet_process'',''' typeName ''');'];

cb = txt; cb.Style = 'Checkbox'; cb.Callback = ['sheetlet_callback(''landmarkssheetlet_process'',''' typeName ''');'];
cb.fontsize = 12;

list=button;list.style='list';

hlist = [];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-7 200 20],'string','Landmarks',...
		'Tag',[typeName 'LMtxt'], 'fontweight', 'bold', 'horizontalalignment', 'left');
hlist = [hlist h];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-100-20-5-5 45 20],'string','Sort by',...
		'Tag',[typeName 'Sorttxt'], 'horizontalalignment', 'left');
hlist = [hlist h];
h = uicontrol(popup,'position',[upperLeft(1)+60 upperLeft(2)-100-20-5 70 20],'string',{'Name','kind'},...
		'Tag',[typeName 'SortPop']);
hlist = [hlist h];

h = uicontrol(txt,'position',[upperLeft(1)+10 upperLeft(2)-100-20-5-25 30 20],'string','Add',...
		'Tag',[typeName 'Addtxt'], 'horizontalalignment', 'left');
hlist = [hlist h];

h = uicontrol(popup,'position',[upperLeft(1)+40 upperLeft(2)-100-20-20-5 70 20],'string',landmark_types,...
		'Tag',[typeName 'AddPop']);
hlist = [hlist h];

h = uicontrol(button,'position',[upperLeft(1)+60+50+5 upperLeft(2)-100-20-20-5 50 20],'string','Delete',...
		'Tag',[typeName 'DeleteBt']);
hlist = [hlist h];

h = uicontrol(button,'position',[upperLeft(1)+10 upperLeft(2)-100-20-40-5 70 20],'string','Show/Hide',...
		'Tag',[typeName 'ShowHideBt']);
hlist = [hlist h];

h = uicontrol(list,'position',[upperLeft(1)+10 upperLeft(2)-100 150 100],'Tag',[typeName 'LMList']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','RestoreVars','visible','off','Tag',[typeName 'RestoreVarsBt']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','SaveVars','visible','off','Tag',[typeName 'SaveVarsBt']);
hlist = [hlist h];

lengthwidth = [200 185];
