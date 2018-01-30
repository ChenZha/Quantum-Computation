T = 800;
n = 10;
t = linspace(0,T,n*T+1);
figure();plot(t,wave(t));

z = wave(t);
x = 0.002;
xita = angle(x,z);

phase = zeros(1,length(t)-1);
for i = 2:length(t)
    phase(i-1) = exp(-1i*integral(@(t)energy(t),0,t(i)));
end
dxita = diff(xita)/(t(2)-t(1));
dm = dxita.*phase;
m = trapz(t(2:length(t)),dm);
error = (sin(abs(m)/2))^2;
disp(error)


function z = wave(t)
width = 30;
x = 0.002;

% z = 0.150-(0.150./(1+exp(-(t-50)/width))-0.150./(1+exp(-(t-750)/width)));
p = atan(0.002/-0.150)+pi+(pi/2-atan(0.002/0.150)-pi)/2*(1-cos(2*pi.*t/800))-0.19*(1-cos(2*2*pi.*t/800));
z = x./tan(p);
end

function w = energy(t)
x = 0.002;
w = 2*pi*2*sqrt(x^2+wave(t).^2);
end
function xita = angle(x,z)
xita = atan(x./z);
end
