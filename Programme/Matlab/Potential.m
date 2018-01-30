f = linspace(-10*pi,10*pi,500);
plot(f,U(f));hold on;

function u = U(f)
f0 = 0.5;
beta = 100;
u = -beta*cos(f)+(f-2*pi*f0).^2/2;
end

