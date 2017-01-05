function plot_stimcond(data, T, space, cond1, cond2, cond3, yaxis,label1,label2,label3)

subplot(1,3,1);
plot_multichan(data(:,:,cond1),T,space);
axis([T(1) T(end) yaxis]);
set(gca,'ytick',[]);
xlabel('Time (s)');
title(label1);

subplot(1,3,2);
plot_multichan(data(:,:,cond2),T,space);
axis([T(1) T(end) yaxis]);
set(gca,'ytick',[]);
title(label2);
xlabel('Time (s)');

subplot(1,3,3);
plot_multichan(data(:,:,cond3),T,space);
axis([T(1) T(end) yaxis]);
set(gca,'ytick',[]);
title(label3);
xlabel('Time (s)');
