function DD=DistanceBalise3(x0);
% Equation de sortie = distance à balise B1 (x_b1, y_b1)
% Etat x0 = (x,y,theta)
% Balise B3
xb = 10;
yb = -10;

DD = sqrt((x0(1)-xb)^2 + (x0(2)-yb)^2);
end
