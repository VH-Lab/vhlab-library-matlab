function r = doublegaussian180(p, x, wrap)

x = x(:)'; % x must be row vector

r = p(1) + p(2)*exp(-((angdiffwrap(x-p(3),wrap)).^2)./(2*p(4).^2)) + p(5)*exp(-((angdiffwrap(x-p(3)+180,wrap)).^2)./(2*p(4).^2));;
