function r = singlegaussian(p, x, wrap)

x = x(:)'; % x must be row vector

p(3) = mod(p(3),wrap);

r = p(1) + abs(p(2))*exp(-((angdiffwrap(x-p(3),wrap)).^2)./(2*p(4).^2));
