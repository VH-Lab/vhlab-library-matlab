function [hlist,lengthwidth] = switchmenusheetlet(title,typeName,upperLeft)

button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = ['sheetlet_callback(''switchmenusheetlet_process'',''' typeName ''');'];

txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
txt.fontsize = 10; txt.fontweight = 'normal';
txt.HorizontalAlignment = 'center';txt.Style='text';

edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';

popup = txt; popup.style = 'popupmenu'; popup.Callback = button.Callback;

cb = txt; cb.Style = 'Checkbox'; cb.Callback = ['sheetlet_callback(''switchmenusheetlet_process'',''' typeName ''');'];
cb.fontsize = 12;

list=button;list.style='list';

hlist = [];
h = uicontrol(txt,'position',[upperLeft(1)+5 upperLeft(2)-7 50 20],'string',title,'Tag',[typeName 'SwitchMenuTxt'],'fontweight','bold');

h = uicontrol(popup,'position',[upperLeft(1)+5+50 upperLeft(2) 150 20],'string','','Tag',[typeName 'SwitchPopup'],'value',1);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','RestoreVars','visible','off','Tag',[typeName 'RestoreVarsBt']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','SaveVars','visible','off','Tag',[typeName 'SaveVarsBt']);
hlist = [hlist h];

lengthwidth = [250 25];
