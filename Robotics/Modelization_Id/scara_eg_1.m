a1=300; %mm
a2=300;
dx=[10,0]';
q1=30*pi/180;
q2=-60*pi/180;
J=[-a1*sin(q1)-a2*sin(q1+q2), -a2*sin(q1+q2);
    a1*cos(q1)+a2*cos(q1+q2), a2*cos(q1+q2)];
dq=inv(J)*dx %J\dxD:\Proyectos\EMINENT_D\2025-02\Numerical_systems
fprintf('dq1 is %d degrees\n',dq(1)*180/pi);
fprintf('dq2 is %d degrees\n',dq(2)*180/pi);
