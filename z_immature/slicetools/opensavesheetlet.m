function [hlist,lengthwidth] = opensavesheetlet(title,typeName,upperLeft)

button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = ['sheetlet_callback(''opensavesheetlet_process'',''' typeName ''');'];

txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
txt.fontsize = 10; txt.fontweight = 'normal';
txt.HorizontalAlignment = 'center';txt.Style='text';

edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';

popup = txt; popup.style = 'popupmenu';

cb = txt; cb.Style = 'Checkbox'; cb.Callback = ['sheetlet_callback(''opensavesheetlet_process'',''' typeName ''');'];
cb.fontsize = 12;

list=button;list.style='list';

hlist = [];

h = uicontrol(button,'position',[upperLeft(1)+10 upperLeft(2)-7 50 20],'string','Open','Tag',[typeName 'OpenBt']);
hlist = [hlist h];

h = uicontrol(button,'position',[upperLeft(1)+10+50+5 upperLeft(2)-7 50 20],'string','Save','Tag',[typeName 'SaveBt']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','RestoreVars','visible','off','Tag',[typeName 'RestoreVarsBt']);
hlist = [hlist h];

h=uicontrol(button,'position',[0 0 1 1],'String','SaveVars','visible','off','Tag',[typeName 'SaveVarsBt']);
hlist = [hlist h];

lengthwidth = [110 25];
