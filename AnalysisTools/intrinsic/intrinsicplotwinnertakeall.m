function intrinsicplotwinnertakeall(dirname)

[pathstr,name] = fileparts(dirname);

wta = load([fixpath(dirname) 'wta_map_data.mat']);


ctab = [jet(size(images,3))];

figure;
colormap(ctab);
image(wta);
