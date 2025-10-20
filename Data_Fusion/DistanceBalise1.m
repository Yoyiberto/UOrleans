function DD=DistanceBalise1(x0);
% Equation de sortie = distance à balise B (xb, yb)
% Etat x0 = (x,y,theta)
% Balise B1
xb = 10;
yb = 10;

DD = sqrt((x0(1)-xb)^2 + (x0(2)-yb)^2);
end
