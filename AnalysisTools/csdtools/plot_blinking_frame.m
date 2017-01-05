function plot_blinking_frame(data1, data2, T, space, frame, yaxis,label1,label2)

subplot(1,2,1);
d = [];
for j=1:length(data1), d = [d ; data1(j).framemean(frame,:) ]; end;
plot_multichan(d',T,space);
axis([T(1) T(end) yaxis]);
set(gca,'ytick',[]);
xlabel('Time (s)');
title(label1);

subplot(1,2,2);
d = [];
for j=1:length(data2), d = [d ; data2(j).framemean(frame,:) ]; end;
plot_multichan(d',T,space);
axis([T(1) T(end) yaxis]);
set(gca,'ytick',[]);
title(label2);
xlabel('Time (s)');

